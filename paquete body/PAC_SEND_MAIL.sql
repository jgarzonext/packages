--------------------------------------------------------
--  DDL for Package Body PAC_SEND_MAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SEND_MAIL" IS
/******************************************************************************
   NOMBRE:       PAC_SEND_MAIL
   PROPÓSITO: Funciones para envio correos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/02/2011   ACC                1. Creación del package.
   2.0        03/09/2013   FAL                2. 0025720: RSAG998 - Numeración de pólizas por rangos
******************************************************************************/

   ----------------------- Secció privada -----------------------

   /*************************************************************************
    Retorna l'adreça de correu electrònic següent en la llista d'adreces de
    correu electrònic, separades per una "," o un ";".
    El format de bústia de correu pot estar en un dels següents:
    someone@some-domain.com
    "Algú en algun domini" <someone@some-domain.com>
    Algú en algun domini <someone@some-domain.com>
    param in out addr_list: llista adreçes
    return: adreça
   *************************************************************************/
   FUNCTION get_address(addr_list IN OUT VARCHAR2)
      RETURN VARCHAR2 IS
      addr           VARCHAR2(256);
      i              PLS_INTEGER;

      FUNCTION lookup_unquoted_char(str IN VARCHAR2, chrs IN VARCHAR2)
         RETURN PLS_INTEGER AS
         c              VARCHAR2(5);
         i              PLS_INTEGER;
         len            PLS_INTEGER;
         inside_quote   BOOLEAN;
      BEGIN
         inside_quote := FALSE;
         i := 0;
         len := LENGTH(str);

         WHILE(i <= len) LOOP
            c := SUBSTR(str, i, 1);

            IF (inside_quote) THEN
               IF (c = '"') THEN
                  inside_quote := FALSE;
               ELSIF(c = '\') THEN
                  i := i + 1;   -- Saltar la cita de caràcter
               END IF;

               GOTO next_char;
            END IF;

            IF (c = '"') THEN
               inside_quote := TRUE;
               GOTO next_char;
            END IF;

            IF (INSTR(chrs, c) >= 1) THEN
               RETURN i;
            END IF;

            <<next_char>>
            i := i + 1;
         END LOOP;

         RETURN 0;
      END lookup_unquoted_char;
   BEGIN
      addr_list := LTRIM(addr_list);
      i := lookup_unquoted_char(addr_list, ',;');

      IF (i >= 1) THEN
         addr := SUBSTR(addr_list, 1, i - 1);
         addr_list := SUBSTR(addr_list, i + 1);
      ELSE
         addr := addr_list;
         addr_list := '';
      END IF;

      i := lookup_unquoted_char(addr, '<');

      IF (i >= 1) THEN
         addr := SUBSTR(addr, i + 1);
         i := INSTR(addr, '>');

         IF (i >= 1) THEN
            addr := SUBSTR(addr, 1, i - 1);
         END IF;
      END IF;

      RETURN addr;
   END get_address;

   /*************************************************************************
    Retorna un texte formatat amb el charset especificat com a definició del
    package i global el mail.
    param in text: texte
    return: texte formatat
   *************************************************************************/
   FUNCTION get_charsettext(text IN VARCHAR2)
      RETURN VARCHAR2 IS
   BEGIN
      RETURN ' =?' || mine_charset_text || '?Q?'
             || UTL_RAW.cast_to_varchar2
                                (UTL_ENCODE.quoted_printable_encode(UTL_RAW.cast_to_raw(text)))
             || '?=';
   END get_charsettext;

   /*************************************************************************
    Escriviu una capçalera MIME
    param in out conn: conexió
    param in name: nom
    param in value: valor
   *************************************************************************/
   PROCEDURE write_mime_header(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      NAME IN VARCHAR2,
      VALUE IN VARCHAR2) IS
   BEGIN
      UTL_SMTP.write_data(conn, NAME || ': ' || VALUE || UTL_TCP.crlf);
   END write_mime_header;

   /*************************************************************************
    Marca un límit de missatges part.
    param in out conn: connexió
    param in last: límit de missatges part. Establir <last> en TRUE per el
                   límit anterior
   *************************************************************************/
   PROCEDURE write_boundary(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      LAST IN BOOLEAN DEFAULT FALSE) AS
   BEGIN
      IF (LAST) THEN
         UTL_SMTP.write_data(conn, last_boundary);
      ELSE
         UTL_SMTP.write_data(conn, first_boundary);
      END IF;
   END write_boundary;

   ----------------------- End Secció privada -----------------------

   -- Un simple correu electrònic de l'API per a l'enviament de correu
   -- electrònic en text sense format en una sola trucada.
   -- El format d'una adreça de correu electrònic és un dels següents:
   --   - someone@some-domain.com
   --   - "Algú en algun domini" <someone@some-domain.com>
   --   - Algú en algun domini <someone@some-domain.com>
   -- Els recipients és una llista d'adreces de correu electrònic han estar
   -- separades per "," o bé un ";"

   /*************************************************************************
       Enviament mail.
       El format d'una adreça de correu electrònic és un dels següents:
        - someone@some-domain.com
        - "Algú en algun domini" <someone@some-domain.com>
        - Algú en algun domini <someone@some-domain.com>
       param in sender: emisor del mail.
       param in recipients: receptor del mail.
       param in subject: assumpte del mail
       param in MESSAGE: cos del correu electrònic
       param in cc: receptor copia del mail.
       param in cc0: receptor copia oculta del mail.
   *************************************************************************/
   PROCEDURE mail(
      sender IN VARCHAR2,
      recipients IN VARCHAR2,
      subject IN VARCHAR2,
      MESSAGE IN VARCHAR2,
      cc IN VARCHAR2 DEFAULT NULL,
      cco IN VARCHAR2 DEFAULT NULL) IS
      conn           UTL_SMTP.connection;
   BEGIN
      -- BUG 25720 - FAL - 03/09/2013
      --conn := begin_mail(sender, recipients, subject, cc, cco);
      conn := begin_mail(sender, recipients, subject, cc, cco, 'text/html');   -- mime_type = html
      -- FI BUG 25720 - FAL - 03/09/2013
      write_text(conn, MESSAGE);
      end_mail(conn);
   END mail;

   -- Ampliació de l'API de correu per enviar correu electrònic en
   -- format HTML o text pla, sense límit de mida.
   -- En primer lloc, començar el correu electrònic per begin_mail().
   -- Després, crideu write_text () diverses vegades
   -- per enviar correu electrònic en ASCII peça per peça. O, crideu
   -- write_mb_text() per enviar e-mail no-ASCII o conjunt de caràcters multi-byte.
   -- Fi del correu electrònic amb end_mail().

   /*************************************************************************
       Inici enviament mail.
       El format d'una adreça de correu electrònic és un dels següents:
        - someone@some-domain.com
        - "Algú en algun domini" <someone@some-domain.com>
        - Algú en algun domini <someone@some-domain.com>
       param in sender: emisor del mail.
       param in recipients: receptor del mail.
       param in subject: assumpte del mail
       param in cc: receptor copia del mail.
       param in cc0: receptor copia oculta del mail.
       param in mime_type: "Content-Type" capçalera MIME
       param in priority: prioritat
       return conexio
   *************************************************************************/
   FUNCTION begin_mail(
      sender IN VARCHAR2,
      recipients IN VARCHAR2,
      subject IN VARCHAR2,
      cc IN VARCHAR2 DEFAULT NULL,
      cco IN VARCHAR2 DEFAULT NULL,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      priority IN PLS_INTEGER DEFAULT NULL)
      RETURN UTL_SMTP.connection IS
      conn           UTL_SMTP.connection;
   BEGIN
      conn := begin_session;
      begin_mail_in_session(conn, sender, recipients, subject, cc, cco, mime_type, priority);
      RETURN conn;
   END begin_mail;

   /*************************************************************************
       Escriu cos del correu electrònic en format ASCII
       param in out conn: connexió
       param in message: cos del correu electrònic
   *************************************************************************/
   PROCEDURE write_text(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN VARCHAR2) IS
   BEGIN
      UTL_SMTP.write_data(conn, MESSAGE);
   END write_text;

   /*************************************************************************
    Escriure en el cos del correu electrònic no ASCII (incloent multi-byte).
    El cos del correu electrònic serà enviat en el conjunt de caràcters de
    la base de dades.
    param in out conn: connexió
    param in message: cos del correu electrònic
   *************************************************************************/
   PROCEDURE write_mb_text(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN VARCHAR2) IS
   BEGIN
      UTL_SMTP.write_raw_data(conn, UTL_RAW.cast_to_raw(MESSAGE));
   END write_mb_text;

   /*************************************************************************
    Escriu cos del correu electrònic en format binari
    param in out conn: connexió
    param in message: cos del correu electrònic
   *************************************************************************/
   PROCEDURE write_raw(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN RAW) IS
   BEGIN
      UTL_SMTP.write_raw_data(conn, MESSAGE);
   END write_raw;

   -- API per enviar correu electrònic amb arxius adjunts. Arxius adjunts
   -- enviats per correu electrònic l'enviament de "multipart/mixed"
   -- en format MIME. Especifica que el format MIME en començar un correu
   -- electrònic amb begin_mail().

   /*************************************************************************
       Enviar un arxiu adjunt de text únic.
       param in out conn: connexió
       param in data: dades adjunts
       param in mime_type: "Content-Type" capçalera MIME
       param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
       param in filename: nom fitxer a adjuntar
       param in last: límit de missatges part. Establir <last> en TRUE per el
                      límit anterior
   *************************************************************************/
   PROCEDURE attach_text(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      DATA IN VARCHAR2,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      inline IN BOOLEAN DEFAULT TRUE,
      filename IN VARCHAR2 DEFAULT NULL,
      LAST IN BOOLEAN DEFAULT FALSE) IS
   BEGIN
      begin_attachment(conn, mime_type, inline, filename);

      if (UPPER(mime_type) = UPPER('text/html')) THEN
        write_raw(conn, utl_raw.cast_to_raw(DATA));
      ELSE
        write_text(conn, DATA);
      END IF;

      end_attachment(conn, LAST);
   END attach_text;

   /*************************************************************************
    Enviar un arxiu adjunt de text únic llegit des de UTL_FILE Directory.
    param in out conn: connexió
    param in directory: UTL_FILE Directory. Directori de ubicació del fitxer
    param in filename: nom fitxer a adjuntar
    param in mime_type: "Content-Type" capçalera MIME
    param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
    param in last: límit de missatges part. Establir <last> en TRUE per el límit anterior
   *************************************************************************/
   PROCEDURE attach_text_readfile(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      DIRECTORY IN VARCHAR2,
      filename IN VARCHAR2,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      inline IN BOOLEAN DEFAULT TRUE,
      LAST IN BOOLEAN DEFAULT FALSE) IS
      idfitxer       UTL_FILE.file_type;
      DATA           CLOB;
   BEGIN
      begin_attachment(conn, mime_type, inline, filename);
      idfitxer := UTL_FILE.fopen(DIRECTORY, filename, 'R');

      LOOP
         BEGIN
            -- recuperem la línia
            UTL_FILE.get_line(idfitxer, DATA);
            write_text(conn, DATA || UTL_TCP.crlf);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT;
         END;
      END LOOP;

      UTL_FILE.fclose(idfitxer);
      end_attachment(conn, LAST);
   END attach_text_readfile;

   /*************************************************************************
    Enviar un arxiu adjunt de text únic llegit des de UTL_FILE Directory.
    param in out conn: connexió
    param in directory: UTL_FILE Directory. Directori de ubicació del fitxer
    param in filename: nom fitxer a adjuntar
    param in mime_type: "Content-Type" capçalera MIME
    param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
    param in last: límit de missatges part. Establir <last> en TRUE per el límit anterior
   *************************************************************************/
   PROCEDURE attach_base64_readfile(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      DIRECTORY IN VARCHAR2,
      filename IN VARCHAR2,
      mime_type IN VARCHAR2 DEFAULT 'application/octet',
      inline IN BOOLEAN DEFAULT TRUE,
      LAST IN BOOLEAN DEFAULT FALSE) IS
      idfitxer       UTL_FILE.file_type;
      DATA           RAW(57);
   BEGIN
      begin_attachment(conn, mime_type, inline, filename, 'base64');
      idfitxer := UTL_FILE.fopen(DIRECTORY, filename, 'rb');

      LOOP
         BEGIN
            -- recuperem la línia
            UTL_FILE.get_raw(idfitxer, DATA, max_base64_line_width);
            write_raw(conn, UTL_ENCODE.base64_encode(DATA));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               EXIT;
         END;
      END LOOP;

      UTL_FILE.fclose(idfitxer);
      end_attachment(conn, LAST);
   END attach_base64_readfile;

/*************************************************************************
    Enviar un arxiu adjunt binari. L'adjunt ha de ser codificat en format
    de codificació Base-64.
    param in out conn: connexió
    param in data: dades adjunts codificats amb Base64
    param in mime_type: "Content-Type" capçalera MIME
    param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
    param in filename: nom fitxer a adjuntar
    param in last: límit de missatges part. Establir <last> en TRUE per el
                   límit anterior
*************************************************************************/
   PROCEDURE attach_base64(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      DATA IN RAW,
      mime_type IN VARCHAR2 DEFAULT 'application/octet',
      inline IN BOOLEAN DEFAULT TRUE,
      filename IN VARCHAR2 DEFAULT NULL,
      LAST IN BOOLEAN DEFAULT FALSE) IS
      i              PLS_INTEGER;
      len            PLS_INTEGER;
   BEGIN
      begin_attachment(conn, mime_type, inline, filename, 'base64');
      -- Dividir les dades adjunts codificats amb Base64 en diverses línies
      i := 1;
      len := UTL_RAW.LENGTH(DATA);

      WHILE(i < len) LOOP
         IF (i + max_base64_line_width < len) THEN
            UTL_SMTP.write_raw_data
                              (conn,
                               UTL_ENCODE.base64_encode(UTL_RAW.SUBSTR(DATA, i,
                                                                       max_base64_line_width)));
         ELSE
            UTL_SMTP.write_raw_data(conn, UTL_ENCODE.base64_encode(UTL_RAW.SUBSTR(DATA, i)));
         END IF;

         UTL_SMTP.write_data(conn, UTL_TCP.crlf);
         i := i + max_base64_line_width;
      END LOOP;

      end_attachment(conn, LAST);
   END attach_base64;

   -- Enviar un arxiu adjunt sense límit de mida. En primer lloc, començar
   -- l'arxiu adjunt amb begin_attachment(). Després, cridar a write_text()
   -- diverses vegades per enviar l'arxiu peça per peça. Si l'arxiu adjunt es
   -- basa en text, sinó no-ASCII o conjunt de caràcters multi-byte, utilitzar
   -- write_mb_text() en el seu lloc.
   -- Per enviar fitxers adjunts binaris, el contingut binari primer ha de ser
   -- codificat en base-64 en format de codificació amb el paquet de
   -- utl_encode.base64_encode.
   -- Posar fi a la unió amb end_attachment().

   /*************************************************************************
       Inici d'ajunció de fitxers.
       param in out conn: connexió
       param in mime_type: "Content-Type" capçalera MIME
       param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
       param in filename: nom fitxer a adjuntar
       param in transfer_enc: Content-Transfer-Encoding
   *************************************************************************/
   PROCEDURE begin_attachment(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      inline IN BOOLEAN DEFAULT TRUE,
      filename IN VARCHAR2 DEFAULT NULL,
      transfer_enc IN VARCHAR2 DEFAULT NULL) IS
   BEGIN
      write_boundary(conn);
      write_mime_header(conn, 'Content-Type', mime_type);

      IF (filename IS NOT NULL) THEN
         IF (inline) THEN
            write_mime_header(conn, 'Content-Disposition',
                              'inline; filename="' || filename || '"');
         ELSE
            write_mime_header(conn, 'Content-Disposition',
                              'attachment; filename="' || filename || '"');
         END IF;
      END IF;

      IF (transfer_enc IS NOT NULL) THEN
         write_mime_header(conn, 'Content-Transfer-Encoding', transfer_enc);
      END IF;

      UTL_SMTP.write_data(conn, UTL_TCP.crlf);
   END begin_attachment;

/*************************************************************************
    Fi de les dades adjunts.
    param in out conn: connexió
    param in last: límit de missatges part. Establir <last> en TRUE per el
                   límit anterior
*************************************************************************/
   PROCEDURE end_attachment(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      LAST IN BOOLEAN DEFAULT FALSE) IS
   BEGIN
      UTL_SMTP.write_data(conn, UTL_TCP.crlf);

      IF (LAST) THEN
         write_boundary(conn, LAST);
      END IF;
   END end_attachment;

/*************************************************************************
    Fi del correu electrònic.
    param in out conn: connexió
*************************************************************************/
   PROCEDURE end_mail(conn IN OUT NOCOPY UTL_SMTP.connection) IS
   BEGIN
      end_mail_in_session(conn);
      end_session(conn);
   END end_mail;

   -- Extensió del API de correu per enviar missatges de correu electrònic
   -- múltiples en una sessió per a una millor rendiment. En primer lloc,
   -- iniciar una sessió de correu electrònic amb begin_session().
   -- Després, començar cada correu electrònic amb una sessió cridant
   -- begin_mail_in_session() en lloc de begin_mail().
   -- Fi del correu electrònic amb end_mail_in_session() lloc de end_mail().
   -- Finalitzar la sessió de correu electrònic end_session().

   /*************************************************************************
       Iniciar sessió smtp.
       return     : connexió
   *************************************************************************/
   FUNCTION begin_session
      RETURN UTL_SMTP.connection IS
      conn           UTL_SMTP.connection;
      r              UTL_SMTP.reply;
   BEGIN
      -- obrir SMTP connexió
      
      --conn := UTL_SMTP.open_connection(smtp_host, smtp_port);
      conn := UTL_SMTP.open_connection('smtp.confianza.com.co', 25);
      
      -- es necessari autentificació
      IF (smtp_auth = 'S') THEN      
         r := UTL_SMTP.command(conn, 'AUTH LOGIN');
        /* r :=
            UTL_SMTP.command
               (conn,
                UTL_RAW.cast_to_varchar2
                                     (UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw(smtp_user))));*/

         r :=
            UTL_SMTP.command
               (conn,
                UTL_RAW.cast_to_varchar2
                                     (UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw('smtpiaxis'))));                                     
                                     
         /*r :=
            UTL_SMTP.command
               (conn,
                UTL_RAW.cast_to_varchar2
                                    (UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw(smtp_passw)))); */ 
                                    
            r :=
            UTL_SMTP.command
               (conn,
                UTL_RAW.cast_to_varchar2
                                    (UTL_ENCODE.base64_encode(UTL_RAW.cast_to_raw('C30l0mb1@'))));                                    
      END IF;         
      UTL_SMTP.helo(conn, smtp_domain);
      RETURN conn;
   END begin_session;

/*************************************************************************
    Començar un correu electrònic en una sessió.
    El format d'una adreça de correu electrònic és un dels següents:
        - someone@some-domain.com
        - "Algú en algun domini" <someone@some-domain.com>
        - Algú en algun domini <someone@some-domain.com>
    param in out conn: connexió
    param in sender: emisor del mail.
    param in recipients: receptor del mail.
    param in subject: assumpte del mail
    param in cc: receptor copia del mail.
    param in cc0: receptor copia oculta del mail.
    param in mime_type: "Content-Type" capçalera MIME
    param in priority: prioritat
*************************************************************************/
   PROCEDURE begin_mail_in_session(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      sender IN VARCHAR2,
      recipients IN VARCHAR2,
      subject IN VARCHAR2,
      cc IN VARCHAR2 DEFAULT NULL,
      cco IN VARCHAR2 DEFAULT NULL,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      priority IN PLS_INTEGER DEFAULT NULL) IS
      my_recipients  VARCHAR2(32767) := recipients;
      my_sender      VARCHAR2(32767) := sender;
      my_cc          VARCHAR2(32767) := cc;
      my_cco         VARCHAR2(32767) := cco;
   BEGIN
      -- Indiqueu l'adreça del remitent (el nostre servidor permet a la
      -- direcció falsa, sempre que es tracta d'una adreça de correu
      -- electrònica completa (xxx@yyy.com).
      UTL_SMTP.mail(conn, get_address(my_sender));

      -- Destinatari(s) del correu electrònic.
      WHILE(my_recipients IS NOT NULL) LOOP
         UTL_SMTP.rcpt(conn, get_address(my_recipients));
      END LOOP;

      -- Destinari(s) del correu amb copia
      WHILE(my_cc IS NOT NULL) LOOP
         UTL_SMTP.rcpt(conn, get_address(my_cc));
      END LOOP;

      -- Destinari(s) del correu amb copia oculta
      WHILE(my_cco IS NOT NULL) LOOP
         UTL_SMTP.rcpt(conn, get_address(my_cco));
      END LOOP;

      -- Inici del cos del correu electrònic.
      UTL_SMTP.open_data(conn);
      -- Establir "Data" de la capçalera MIME.
      write_mime_header(conn, 'Date',
                        TO_CHAR(f_sysdate, 'dd Mon yy hh24:mi:ss',
                                'nls_date_language=AMERICAN'));
      -- Establir "De" de la capçalera MIME.
      write_mime_header(conn, 'From', sender);
      -- Establir "A" capçalera MIME
      write_mime_header(conn, 'To', recipients);

      -- Establir "CC" capçalera MIME
      IF cc IS NOT NULL THEN
         write_mime_header(conn, 'Cc', cc);
      END IF;

      -- Establir "Assumpte" capçalera MIME
      write_mime_header(conn, 'Subject', get_charsettext(subject));

      -- jlb - pongo el tipo de mime
      write_mime_header(conn, 'MIME-Version', mime_version);
      -- jlb -end

      -- Establir "Content-Type" capçalera MIME
      write_mime_header(conn, 'Content-Type', mime_type);
      -- Establir "X-Mailer" capçalera MIME
      write_mime_header(conn, 'X-Mailer', mailer_id);

      -- Establir prioritat:
      --   High      Normal       Low
      --   1     2     3     4     5
      IF (priority IS NOT NULL) THEN
         write_mime_header(conn, 'X-Priority', priority);
      END IF;

      -- Enviar una línia en blanc al final de MIME marca el començament
      -- de capçaleres i cos del missatge.
      UTL_SMTP.write_data(conn, UTL_TCP.crlf);

      IF (mime_type LIKE 'multipart/mixed%') THEN
         write_text(conn, 'This is a multi-part message in MIME format.' || UTL_TCP.crlf);
      END IF;
   END begin_mail_in_session;

/*************************************************************************
    Fi d'un correu electrònic en una sessió.
    param in out conn: connexió
*************************************************************************/
   PROCEDURE end_mail_in_session(conn IN OUT NOCOPY UTL_SMTP.connection) IS
   BEGIN
       UTL_SMTP.close_data(conn);
   END end_mail_in_session;

/*************************************************************************
    Finalitzar una sessió de correu electrònic.
    param in out conn: connexió
*************************************************************************/
   PROCEDURE end_session(conn IN OUT NOCOPY UTL_SMTP.connection) IS
   BEGIN
      UTL_SMTP.quit(conn);
   END end_session;
END pac_send_mail;

/

  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "PROGRAMADORESCSI";
