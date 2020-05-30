--------------------------------------------------------
--  DDL for Package PAC_SEND_MAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SEND_MAIL" IS
/******************************************************************************
   NOMBRE:       PAC_SEND_MAIL
   PROPÓSITO: Funciones para envio correos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/02/2011   ACC                1. Creación del package.
******************************************************************************/

   ----------------------- Secció Personalitzable -----------------------

   -- Personalitzar el servidor SMTP, el port, el nom de domini, autentificació.
   smtp_host      VARCHAR2(256) := NVL(f_parinstalacion_t('MAIL_SERV'), 'smtp.csi-ti.com');
   smtp_port      PLS_INTEGER := NVL(f_parinstalacion_n('MAIL_PORT'), 25);
   smtp_domain    VARCHAR2(256) := NVL(f_parinstalacion_t('MAIL_DOMAIN'), 'csi-ti.com');
   smtp_auth      VARCHAR2(256) := NVL(f_parinstalacion_t('MAIL_AUTH'), 'N');
   smtp_user      VARCHAR2(256) := NVL(f_parinstalacion_t('MAIL_USER'), '');
   smtp_passw     VARCHAR2(256) := NVL(f_parinstalacion_t('MAIL_PASSWD'), '');
   -- Personalitzar la signatura que apareix a la capçalera MIME del correu electrònic.
   mailer_id CONSTANT VARCHAR2(256) := 'Mailer by iAxis';
   mine_charset_text CONSTANT VARCHAR2(100) := 'iso-8859-1';
   --------------------- End Secció Personalitzable ---------------------

   -- Una cadena única que demarca els límits de les parts en un correu electrònic de diverses parts
   -- La cadena no ha d'aparèixer dins del cos d'arreu del correu electrònic.
   -- Personalitzar aquest si cal o generar aquest aleatòriament de forma dinàmica.
   boundary CONSTANT VARCHAR2(256) := '-----7D81B75CCC90D2974F7A1CBD';
   -- JLB
    mime_version CONSTANT VARCHAR2(256) := '1.0';
    -- JLB - end
   first_boundary CONSTANT VARCHAR2(256) := '--' || boundary || UTL_TCP.crlf;
   last_boundary CONSTANT VARCHAR2(256) := '--' || boundary || '--' || UTL_TCP.crlf;
   -- Un tipus MIME que marca el correu electrònic de diverses parts (MIME) missatges.
   multipart_mime_type CONSTANT VARCHAR2(256)
                                           := 'multipart/mixed; boundary="' || boundary || '"';
   max_base64_line_width CONSTANT PLS_INTEGER := 76 / 4 * 3;

   -- Un simple correu electrònic de l'API per a l'enviament de correu electrònic en text sense format en una sola trucada.
   -- El format d'una adreça de correu electrònic és un dels següents:
   -- someone@some-domain.com
   -- "Algú en algun domini" <someone@some-domain.com>
   -- Algú en algun domini <someone@some-domain.com>
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
      cco IN VARCHAR2 DEFAULT NULL);

   -- Ampliació de l'API de correu per enviar correu electrònic en format HTML o text pla, sense límit de mida.
   -- En primer lloc, començar el correu electrònic per begin_mail(). Després, crideu write_text () diverses vegades
   -- per enviar correu electrònic en ASCII peça per peça. O, crideu write_mb_text() per enviar
   -- e-mail no-ASCII o conjunt de caràcters multi-byte.
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
      RETURN UTL_SMTP.connection;

/*************************************************************************
    Escriu cos del correu electrònic en format ASCII
    param in out conn: conexió
    param in message: cos del correu electrònic
*************************************************************************/
   PROCEDURE write_text(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN VARCHAR2);

/*************************************************************************
    Escriure en el cos del correu electrònic no ASCII (incloent multi-byte).
    El cos del correu electrònic serà enviat en el conjunt de caràcters de la base de dades.
    param in out conn: conexió
    param in message: cos del correu electrònic
*************************************************************************/
   PROCEDURE write_mb_text(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN VARCHAR2);

/*************************************************************************
    Escriu cos del correu electrònic en format binari
    param in out conn: conexió
    param in message: cos del correu electrònic
*************************************************************************/
   PROCEDURE write_raw(conn IN OUT NOCOPY UTL_SMTP.connection, MESSAGE IN RAW);

   -- API per enviar correu electrònic amb arxius adjunts. Arxius adjunts
   -- enviats per correu electrònic l'enviament de "multipart/mixed"
   -- en format MIME. Especifica que el format MIME en començar un correu
   -- electrònic amb begin_mail().

   /*************************************************************************
       Enviar un arxiu adjunt de text únic.
       param in out conn: conexió
       param in data: dades adjunts
       param in mime_type: "Content-Type" capçalera MIME
       param in inline: Content-Disposition. TRUE= inline ; FALSE= attachment
       param in filename: nom fitxer a adjuntar
       param in last: límit de missatges part. Establir <last> en TRUE per el límit anterior
   *************************************************************************/
   PROCEDURE attach_text(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      DATA IN VARCHAR2,
      mime_type IN VARCHAR2 DEFAULT 'text/plain',
      inline IN BOOLEAN DEFAULT TRUE,
      filename IN VARCHAR2 DEFAULT NULL,
      LAST IN BOOLEAN DEFAULT FALSE);

/*************************************************************************
    Enviar un arxiu adjunt de text únic llegit des de UTL_FILE Directory.
    param in out conn: conexió
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
      LAST IN BOOLEAN DEFAULT FALSE);

         /*************************************************************************
       Enviar un arxiu adjunt de text únic llegit des de UTL_FILE Directory.
       param in out conn: conexió
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
      LAST IN BOOLEAN DEFAULT FALSE);

/*************************************************************************
    Enviar un arxiu adjunt binari. L'adjunt ha de ser codificat en format
    de codificació Base-64.
    param in out conn: conexió
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
      LAST IN BOOLEAN DEFAULT FALSE);

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
       param in out conn: conexió
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
      transfer_enc IN VARCHAR2 DEFAULT NULL);

/*************************************************************************
    Fi de les dades adjunts.
    param in out conn: conexió
    param in last: límit de missatges part. Establir <last> en TRUE per el límit anterior
*************************************************************************/
   PROCEDURE end_attachment(
      conn IN OUT NOCOPY UTL_SMTP.connection,
      LAST IN BOOLEAN DEFAULT FALSE);

/*************************************************************************
    Fi del correu electrònic.
    param in out conn: conexió
*************************************************************************/
   PROCEDURE end_mail(conn IN OUT NOCOPY UTL_SMTP.connection);

   -- Extensió del API de correu per enviar missatges de correu electrònic
   -- múltiples en una sessió per a una millor rendiment. En primer lloc,
   -- iniciar una sessió de correu electrònic amb begin_session().
   -- Després, començar cada correu electrònic amb una sessió cridant
   -- begin_mail_in_session() en lloc de begin_mail().
   -- Fi del correu electrònic amb end_mail_in_session() lloc de end_mail().
   -- Finalitzar la sessió de correu electrònic end_session().

   /*************************************************************************
       Iniciar sessió smtp.
       return     : conexió
   *************************************************************************/
   FUNCTION begin_session
      RETURN UTL_SMTP.connection;

/*************************************************************************
    Començar un correu electrònic en una sessió.
    El format d'una adreça de correu electrònic és un dels següents:
        - someone@some-domain.com
        - "Algú en algun domini" <someone@some-domain.com>
        - Algú en algun domini <someone@some-domain.com>
    param in out conn: conexió
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
      priority IN PLS_INTEGER DEFAULT NULL);

/*************************************************************************
    Fi d'un correu electrònic en una sessió.
    param in out conn: conexió
*************************************************************************/
   PROCEDURE end_mail_in_session(conn IN OUT NOCOPY UTL_SMTP.connection);

/*************************************************************************
    Finalitzar una sessió de correu electrònic.
    param in out conn: conexió
*************************************************************************/
   PROCEDURE end_session(conn IN OUT NOCOPY UTL_SMTP.connection);
END pac_send_mail;

/

  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SEND_MAIL" TO "PROGRAMADORESCSI";
