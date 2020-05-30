--------------------------------------------------------
--  DDL for Package Body PAC_INT_ONLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_INT_ONLINE" 
IS
  /******************************************************************************
  NOMBRE:       PAC_INT_ONLINE
  REVISIONES:
  Ver        Fecha        Autor             Descripci¿n
  ---------  ----------  ---------------  ------------------------------------
  1.0        XX/XX/XXXX   XXX                1. Creaci¿n del package.
  2.0        03/08/2010   PFA                2. 15631: AXISLISTENER con trazas - Parte PL
  3.0        12/08/2010   PFA                3. 13893: CEM800 - INTERFICIES: Recuperar PAIS per defecte via parametritzaci¿ de BD
  4.0        26/08/2010   SRA                4. 14365: CRT002 - Gestion de personas
  5.0        16/01/2010   MAL                5. 0025129: RSA002 - Interafz WS cliente paridad peso-dolar
  6.0        23/10/2013   FPG                6. 28263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
  ******************************************************************************/
  PROCEDURE p_inicializar_sinterf
  IS
  BEGIN
    SELECT sinterf.NEXTVAL INTO pac_int_online.vsinterf FROM DUAL;
  END p_inicializar_sinterf;
  FUNCTION f_obtener_sinterf
    RETURN NUMBER
  IS
  BEGIN
    RETURN(pac_int_online.vsinterf);
  END f_obtener_sinterf;
  FUNCTION f_obtener_posicionamiento
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN(pac_int_online.vposicionamiento);
  END f_obtener_posicionamiento;
-------------------------------------------------------------
  PROCEDURE parsear(
      p_clob   IN CLOB,
      p_parser IN OUT xmlparser.parser)
  IS
  BEGIN
    --insert into tmp_mv(sinterf, v_res) values (f_obtener_sinterf,'Entro en parsear'||dbms_lob.substr(p_clob,2000,1));
    p_parser := xmlparser.newparser;
    xmlparser.setvalidationmode(p_parser, FALSE);
    IF DBMS_LOB.getlength(p_clob) > 32767 THEN
      xmlparser.parseclob(p_parser, p_clob);
    ELSE
      xmlparser.parsebuffer(p_parser, DBMS_LOB.SUBSTR(p_clob, DBMS_LOB.getlength(p_clob), 1));
    END IF;
  END;
-------------------------------------------------------------
  PROCEDURE finalizar_parser(
      v_parser IN OUT xmlparser.parser)
  IS
  BEGIN
    xmlparser.freeparser(v_parser);
  END;
  PROCEDURE p_guardar_log(
      ptinter IN VARCHAR2,
      pmsgin  IN VARCHAR2,
      pmsgout IN VARCHAR2,
      pmodo   IN VARCHAR2)
  IS
    v_domdoc xmldom.domdocument;
    v_msgin        VARCHAR2(32767) := NULL;
    v_error        NUMBER          := 0;
    vcoderr        VARCHAR2(250);
    vcampo         VARCHAR2(250);
    v_dirmail_to   VARCHAR2(100);
    v_dirmail_from VARCHAR2(100);
    vformato       VARCHAR2(100);
    w_txt          VARCHAR2(32760);
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    IF pac_int_online.vsinterf IS NULL THEN
      SELECT sinterf.NEXTVAL INTO pac_int_online.vsinterf FROM DUAL;
    END IF;
    IF pmodo = '1' THEN
      -- missatge d'anada
      INSERT
      INTO int_mensajes
        (
          sinterf,
          cinterf,
          finterf,
          tmenout,
          tmenin
        )
        VALUES
        (
          pac_int_online.vsinterf,
          ptinter,
          f_sysdate,
          pmsgin,
          NULL
        );
      COMMIT;
    ELSIF pmodo = '2' THEN
      -- guardem la URL a la que hem enviat el missatge
      UPDATE int_mensajes
      SET tmenout = '****URL: '
        || vurl
        || '****'
        || CHR(10)
        || tmenout
      WHERE sinterf = pac_int_online.vsinterf
      AND(tmenin   IS NULL
      OR tmenin LIKE 'Error parsing%');
      COMMIT;
    ELSIF pmodo = '3' THEN
      -- missatge de tornada
      IF NOT(pac_int_online.vprot <> 'STRING' OR SUBSTR(pac_int_online.vprot, 1, 4) <> 'FILE') THEN
        BEGIN
          --ho necessitem en format domdocument per la part antiga de BM. Desapareixar¿
          v_domdoc := xmlparser.getdocument(pac_int_online.vparser);
        EXCEPTION
        WHEN OTHERS THEN
          --hi ha hagut algun error a la resposta
          v_msgin := 'ERROR';
        END;
      END IF;
      IF v_msgin IS NULL THEN
        -- no hi ha cap error a la resposta
        v_msgin := pmsgout;
      ELSE
        v_msgin := NULL;
      END IF;
      -- CPM 31/12/03: nom¿s modifiquem el registre que encara no tingui
      --         missatge de tornada.
      UPDATE int_mensajes
      SET tmenin    = v_msgin
      WHERE sinterf = pac_int_online.vsinterf
      AND(tmenin   IS NULL
      OR tmenin LIKE 'Error parsing%');
      COMMIT;
      IF NOT(pac_int_online.vprot <> 'STRING' OR SUBSTR(pac_int_online.vprot, 1, 4) <> 'FILE') THEN
        -- tractem l'error
        -- busquem respostes buides
        IF v_msgin IS NULL THEN
          vcoderr  := '0000-Respuesta vacia';
        ELSE
          -- busquem errors de format
          vcoderr    := RTRIM(LTRIM(pac_map.buscartexto(xmldom.makenode(v_domdoc), 'codigo')));
          IF vcoderr IS NOT NULL THEN
            vcoderr  := vcoderr || '-Error formato respuesta';
          END IF;
          -- busquem errors en camps concrets retornats pel host
          IF vcoderr   IS NULL THEN
            vcoderr    := RTRIM(LTRIM(pac_map.buscartexto(xmldom.makenode(v_domdoc), 'MensError')));
            IF vcoderr IS NOT NULL THEN
              vcoderr  := vcoderr || '-' || RTRIM (LTRIM(pac_map.buscartexto(xmldom.makenode(v_domdoc), 'DenMensaje')));
            END IF;
          END IF;
          vcampo := RTRIM(LTRIM(pac_map.buscartexto(xmldom.makenode(v_domdoc), 'NombreCampoError')));
        END IF;
        IF vcoderr IS NOT NULL THEN
          INSERT
          INTO int_errores
            (
              sinterf,
              ccoderr,
              ccampo
            )
            VALUES
            (
              pac_int_online.vsinterf,
              vcoderr,
              vcampo
            );
          COMMIT;
          -- tractem l'error en el adeudo, ja que ¿s l'¿nic tipus de missatge que realitza
          --  transaccions a BM.
          vformato         := pac_map.buscartexto(xmldom.makenode(v_domdoc), 'Formato');
          IF ptinter        = '4202' AND vformato IS NULL THEN
            v_dirmail_to   := f_parinstalacion_t('MAILADEUDO');
            v_dirmail_from := f_parinstalacion_t('MAILERRFROM');
            p_enviar_correo(v_dirmail_from, v_dirmail_to, v_dirmail_from, v_dirmail_to, 'Error en el adeudo recibo host sinterf = ' || pac_int_online.vsinterf, 'Error en el adeudo recibo host sinterf = ' || pac_int_online.vsinterf);
          END IF;
        END IF;
      END IF;
    ELSIF pmodo = '4' THEN
      w_txt    := SUBSTR('Error parsing: ' || pmsgout, 1, 32760);
      UPDATE int_mensajes
      SET tmenin    = w_txt
      WHERE sinterf = pac_int_online.vsinterf
      AND tmenin   IS NULL;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.p_guardar_log', 1, 'Error incontrolado, psinterf: ' || pac_int_online.vsinterf, SQLERRM);
  END p_guardar_log;
  FUNCTION f_busca_siguiente_url(
      purl_ini IN VARCHAR2)
    RETURN VARCHAR2
  IS
    v_req UTL_HTTP.req;
    v_msgout VARCHAR2(32767);
    v_clob CLOB;
    v_parser xmlparser.parser;
    v_domdoc xmldom.domdocument;
    mynode xmldom.domnode;
    nl xmldom.domnodelist;
    vv       VARCHAR2(250);
    vurl_fin VARCHAR2(500);
    i        NUMBER := 0;
    --
    v_resp UTL_HTTP.resp;
    FUNCTION redireccio(
        purl_ini   IN VARCHAR2,
        purl_canvi IN VARCHAR2)
      RETURN VARCHAR2
    IS
      vurl_canvi VARCHAR2(256);
      vurl_fin   VARCHAR2(256);
      nvegades   NUMBER := 1;
    BEGIN
      vurl_canvi                    := purl_canvi;
      WHILE INSTR(vurl_canvi, '../') = 1
      LOOP
        nvegades   := nvegades + 1;
        vurl_canvi := SUBSTR(vurl_canvi, 4);
      END LOOP;
      vurl_fin := purl_ini;
      FOR i IN 1 .. 7
      LOOP
        vurl_fin := SUBSTR(vurl_fin, 1, INSTR(vurl_fin, '/', -1) - 1);
      END LOOP;
      vurl_fin := vurl_fin || '/' || vurl_canvi;
      RETURN vurl_fin;
    END;
  BEGIN
    WHILE i < 2 AND vv IS NULL
    LOOP
      v_req := UTL_HTTP.begin_request(purl_ini, 'GET');
      UTL_HTTP.set_follow_redirect(0);
      UTL_HTTP.set_transfer_timeout(v_req, 60);
      v_resp := UTL_HTTP.get_response(v_req);
      UTL_HTTP.get_header_by_name(v_resp, 'Location', vv, 1);
      UTL_HTTP.end_response(v_resp);
      i := i + 1;
    END LOOP;
    --vurl_fin := redireccio(purl_ini,vv);
    vurl_fin := vv;
    RETURN vurl_fin;
  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
  END f_busca_siguiente_url;
-------------------------------------------------------------
-- Este procedimiento realiza la petici¿n al host y te devuelve el resultado en
-- un objeto de tipo xmlparser.parser el cual monta una estructura DOM del resultado
  PROCEDURE peticion_host(
      pemp      IN VARCHAR2,
      p_tipoint IN VARCHAR2,
      p_msg     IN VARCHAR2,
      p_msgout  IN OUT VARCHAR2)
  IS
    v_req UTL_HTTP.req;
    v_resp UTL_HTTP.resp;
    v_parser xmlparser.parser;
    v_domdoc xmldom.domdocument;
    v_xmlin  VARCHAR2(32767);
    v_xmlout VARCHAR2(32767);
    v_xmlraw RAW(32767);
    v_res VARCHAR2(32767);
    v_clob CLOB;
    v_clobaux CLOB;
    i NUMBER := 0;
    --vprot definida como variable en la especificaci¿n del paquete
    --vurl definida como variable en la especificaci¿n del paquete
    vssl int_hostb2b.ssl%TYPE;
    vmetodo int_hostb2b.metodo%TYPE;
    vhttpver int_hostb2b.httpversion%TYPE;
    vconttype int_hostb2b.contenttype%TYPE;
    vsoapac int_hostb2b.soapaction%TYPE;
    vuser int_hostb2b.userauthent%TYPE;
    vpass int_hostb2b.passauthent%TYPE;
    vescape int_hostb2b.tescape%TYPE;
    vntimeout int_hostb2b.ntimeout%TYPE;
    vverns int_hostb2b.VERNS%TYPE;
    v_unescape NUMBER := 0;
    v_nomprop  VARCHAR2(2000);
    v_valprop  VARCHAR2(2000);
    vblob BLOB;
    vdir     VARCHAR2(250);
    vurl_aux VARCHAR2(2000);
    vurl_get VARCHAR2(32000);
    vini     NUMBER;
    vfin     NUMBER;
    /*PROTOCOLO SOAP*/
    soap_req_msg  CLOB;
    soap_resp_msg CLOB;
    -- HTTP REQUEST/RESPONSE
    http_req UTL_HTTP.req;
    http_resp UTL_HTTP.resp;
verror VARCHAR2(250);
  BEGIN
    vurl_aux := SUBSTR(p_msg, 1, 2000);
    DBMS_OUTPUT.put_line('ENTRO A AQUESTA FUNCIO');
    --Recuperamos los par¿metros de conexi¿n
    SELECT protocolo,
      url,
      ssl,
      metodo,
      httpversion,
      contenttype,
      soapaction,
      userauthent,
      passauthent,
      tescape,
      NVL(ntimeout, 240),
VERNS
    INTO vprot,
      vurl,
      vssl,
      vmetodo,
      vhttpver,
      vconttype,
      vsoapac,
      vuser,
      vpass,
      vescape,
      vntimeout,
vverns
    FROM int_hostb2b
    WHERE activo    = 'S'
    AND empresa     = pemp
    AND cinterf     = p_tipoint;
    IF vprot        = 'SOAP' THEN
      soap_req_msg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:csi="'||vverns||'">
<soapenv:Header/>
<soapenv:Body>


<'||vsoapac||'>#TEXT_BODY#</'||vsoapac||'>
</soapenv:Body>
</soapenv:Envelope>';
      v_xmlin      := REPLACE(p_msg, '<?xml version="1.0"?>','');
      soap_req_msg := REPLACE (soap_req_msg,'#TEXT_BODY#',v_xmlin);
      dbms_output.put_line('XML ENVIO SOAP:');
      DBMS_OUTPUT.PUT_line(soap_req_msg);
      DBMS_OUTPUT.put_line('1');
      BEGIN
        http_req := UTL_HTTP.begin_request(vurl,vmetodo,vhttpver);
        DBMS_OUTPUT.put_line('2');
        UTL_HTTP.set_header(http_req, 'Content-Type', vconttype);
        UTL_HTTP.set_header(http_req, 'Content-Length', LENGTH(soap_req_msg));
        --UTL_HTTP.set_header(http_req, 'SOAPAction', vsoapac);
        DBMS_OUTPUT.put_line('3');
        UTL_HTTP.write_text(http_req, soap_req_msg);
        DBMS_OUTPUT.put_line('4');
        --
        -- Invoke Request and get Response.
        --
        http_resp := UTL_HTTP.get_response(http_req);
        DBMS_OUTPUT.put_line('5');
        UTL_HTTP.READ_TEXT(http_resp, soap_resp_msg);
        verror:=recuperaTagErrorRespGenerWS(soap_resp_msg);
        DBMS_OUTPUT.put_line('6');
        UTL_HTTP.end_response(http_resp);
        DBMS_OUTPUT.put_line('***************************************************************************************');
        DBMS_OUTPUT.put_line('Output: ' || soap_resp_msg);
        p_msgout := soap_resp_msg;
        --printElementAttributes(soap_resp_msg);
      EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLERRM);
        UTL_HTTP.end_response(http_resp);
      END;
    ELSE
      IF SUBSTR(vprot, INSTR(vprot, '|') + 1, 2) = 'RD' THEN
        --venim d'una adre¿a variable i aquesta ve al par¿metre p_msg.
        vurl := vurl_aux;
      END IF;
      IF vssl = 1 THEN
        --Si el servidor es seguro, establecemos el directorio de certificados
        UTL_HTTP.set_wallet('file:' || f_parinstalacion_t('PATH_WALLT'), decr_pwd(f_parinstalacion_t('USER_WALLT'), f_parinstalacion_t('PASS_WALLT')));
      END IF;
      --utl_http.set_body_charset('UTF8');
      -- jlb - codifica mal los acentos
      UTL_HTTP.set_body_charset('UTF-8');
      IF SUBSTR(vprot, 1, 4) = 'FILE' THEN --OJO de momento solo Winterthur.
        UTL_HTTP.set_follow_redirect(1);
      END IF;
      IF vescape IS NOT NULL THEN
        -- Codificamos formato URL
        --        v_xmlin:= vescape||utl_url.escape(p_msg,TRUE);
        v_xmlin   := vescape || utl_url.ESCAPE(REPLACE(REPLACE(p_msg, '<Entrada xmlns="">', '<Entrada>'), '<input xmlns="">', '<input>'), TRUE);
        IF vmetodo = 'GET' THEN
          --hi ha par¿metres per la petici¿ (que venen al missatge),
          --  per tant els concatenem a la URL.
          vurl_get := vurl || v_xmlin;
        END IF;
      ELSE
        v_xmlin := p_msg;
      END IF;
      -- Inicializamos una petici¿n http
      IF vurl_get IS NOT NULL THEN
        v_req     := UTL_HTTP.begin_request(vurl_get, vmetodo, vhttpver);
      ELSE
        v_req := UTL_HTTP.begin_request(vurl, vmetodo, vhttpver);
      END IF;
      --utl_http.set_body_charset(v_req, 'UTF-8');
      -- XXX
      /*   if vconttype is not null then
      utl_http.set_header(v_req,'Content-Type',vconttype);
      end if;
      */
      -- XXX
      IF vprot = 'SOAP' THEN
        --Inicializamos la acci¿n SOAP
        DBMS_OUTPUT.put_line('PROTOCOLO SOAP');
        UTL_HTTP.set_header(v_req, 'SOAPAction', vsoapac);
      END IF;
      IF vuser IS NOT NULL THEN
        --Inicializamos los par¿metros para autenticaci¿n
        vpass := decr_pwd(vuser, vpass);
        UTL_HTTP.set_authentication(v_req, vuser, vpass);
      END IF;
      --Inicilizamos el timeout
      UTL_HTTP.set_transfer_timeout(v_req, vntimeout);
      -- INI JMF 03-06-2005: Cambio literal cia por c¿digo.
      IF pemp = '1' THEN
        UTL_HTTP.set_persistent_conn_support(v_req, TRUE);
      END IF;
      IF vmetodo = 'POST' THEN
        --UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(v_xmlin));
        UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(CONVERT(v_xmlin, 'utf8')));
        UTL_HTTP.set_header(v_req, 'Content-Type', vconttype);
        -- Escribimos el body
        UTL_HTTP.write_text(v_req, v_xmlin);
      END IF;
      -- Realizamos la petici¿n
      v_resp  := UTL_HTTP.get_response(v_req);
      IF vprot = 'STRING' THEN
        BEGIN
          UTL_HTTP.read_raw(v_resp, v_xmlraw);
          p_msgout := UTL_RAW.cast_to_varchar2(v_xmlraw);
          UTL_HTTP.end_response(v_resp);
        EXCEPTION
        WHEN UTL_HTTP.end_of_body THEN
          UTL_HTTP.end_response(v_resp);
        WHEN OTHERS THEN
          pac_int_online.verror_peticion_host := SQLCODE;
          p_tab_error(f_sysdate, f_user, 'pac_int_online.peticion_host', 1, 'Error incontrolado', SQLERRM);
          -- ens interessa capturar l'excepci¿ a la funci¿ que crida a aquesta (f_int)
          BEGIN
            --intentem tancar les connexions obertes
            UTL_HTTP.end_request(v_req);
          EXCEPTION
          WHEN OTHERS THEN
            --ens interesa que "peti" per sobre de tot.
            RAISE;
          END;
          RAISE;
        END;
      ELSIF SUBSTR(vprot, 1, 4) = 'FILE' THEN
        BEGIN
          -- Creamos una c_lob temporal para almacenar el resultado
          DBMS_LOB.createtemporary(vblob, TRUE);
          DBMS_LOB.OPEN(vblob, DBMS_LOB.lob_readwrite);
          -- Leemos el BODY de la respuesta en este caso un fichero
          i := 1;
          LOOP
            v_xmlraw := NULL;
            i        := i + 1;
            UTL_HTTP.read_raw(v_resp, v_xmlraw, 32000);
            DBMS_LOB.writeappend(vblob, UTL_RAW.LENGTH(v_xmlraw), v_xmlraw);
          END LOOP;
          UTL_HTTP.end_response(v_resp);
        EXCEPTION
          -- Entrar¿ cuando haya llegado toda la respuesta
        WHEN UTL_HTTP.end_of_body THEN
          UTL_HTTP.end_response(v_resp);
        WHEN OTHERS THEN
          pac_int_online.verror_peticion_host := SQLCODE;
          p_tab_error(f_sysdate, f_user, 'pac_int_online.peticion_host', 2, 'Error incontrolado', SQLERRM);
          -- ens interessa capturar l'excepci¿ a la funci¿ que crida a aquesta (f_int)
          BEGIN
            --intentem tancar les connexions obertes
            UTL_HTTP.end_request(v_req);
          EXCEPTION
          WHEN OTHERS THEN
            --ens interesa que "peti" per sobre de tot.
            RAISE;
          END;
          RAISE;
        END;
        BEGIN
          vdir := p_msgout; --directorio + nombre fichero + extension
          --Exportblob (vdir, vblob);
          DBMS_LOB.CLOSE(vblob);
          DBMS_LOB.freetemporary(vblob);
        EXCEPTION
        WHEN OTHERS THEN
          p_tab_error(f_sysdate, f_user, 'pac_int_online.peticion_host', 3, 'Error incontrolado', SQLERRM);
          RAISE;
        END;
      ELSE
        BEGIN
          --buscamos el formato de la respuesta
          i      := 1;
          WHILE i > 0
          LOOP
            BEGIN
              UTL_HTTP.get_header(v_resp, i, v_nomprop, v_valprop);
            EXCEPTION
            WHEN OTHERS THEN
              EXIT;
            END;
            IF v_nomprop = 'Content-type' THEN
              IF v_valprop LIKE 'application/x-www-form-urlencoded%' THEN
                v_unescape := 1;
              END IF;
              EXIT;
            ELSE
              i := i + 1;
            END IF;
          END LOOP;
          -- Creamos una c_lob temporal para almacenar el resultado
          DBMS_LOB.createtemporary(v_clob, TRUE);
          DBMS_LOB.OPEN(v_clob, DBMS_LOB.lob_readwrite);
          -- Leemos el BODY de la respuesta
          i := 1;
          LOOP
            v_xmlraw := NULL;
            v_xmlout := NULL;
            i        := i + 1;
            -- JLB - I- problemas de incompatibilidad
            --           utl_http.read_raw(v_resp,v_xmlraw);
            --         v_xmlout := utl_raw.cast_to_varchar2(v_xmlraw);
            UTL_HTTP.read_text(v_resp, v_xmlout);
            -- JLB - F - problemas de incompatibilidad
            -- I - pone mal los acentos
            --v_xmlout := convert (v_xmlout,'WE8ISO8859P1','UTF8');
            -- F - pone mal los acentos
            IF v_xmlout IS NOT NULL THEN
              -- ho guardem per si despr¿s no podem parsejar-lo
              p_guardar_log(p_tipoint, NULL, v_xmlout, '4');
            END IF;
            IF v_unescape = 1 THEN
              v_res      := utl_url.unescape(v_xmlout);
            ELSE
              v_res := v_xmlout;
            END IF;
            IF v_res IS NOT NULL THEN
              -- Almacenamos el resultado en la clob
              DBMS_LOB.writeappend(v_clob, LENGTH(v_res), v_res);
            END IF;
          END LOOP;
          UTL_HTTP.end_response(v_resp);
          DBMS_LOB.CLOSE(v_clob);
          DBMS_LOB.freetemporary(v_clob);
        EXCEPTION
          -- Entrar¿ cuando haya llegado toda la respuesta
        WHEN UTL_HTTP.end_of_body THEN
          UTL_HTTP.end_response(v_resp);
          IF p_tipoint <> 'I052' THEN
            parsear(v_clob, v_parser);
          END IF;
          DBMS_LOB.CLOSE(v_clob);
          --la fem p¿blica per la part espec¿fica de guardarlog de BM de la part antiga.
          --   a la llarga hauria de desapar¿ixer.
          pac_int_online.vparser       := v_parser;
          IF DBMS_LOB.getlength(v_clob) > 32767 THEN
            p_msgout                   := '<msg>Respuesta de mas de 32767 caracteres. No se puede mostrar.</msg>';
          ELSE
            v_domdoc := xmlparser.getdocument(v_parser);
            xmldom.writetobuffer(v_domdoc, p_msgout);
          END IF;
          DBMS_LOB.freetemporary(v_clob);
        WHEN OTHERS THEN
          --guardem el error a la variable
          pac_int_online.verror_peticion_host := SQLCODE;
          p_tab_error(f_sysdate, f_user, 'pac_int_online.peticion_host', 4, 'Error incontrolado', SQLERRM);
          -- ens interessa capturar l'excepci¿ a la funci¿ que crida a aquesta (f_int)
          BEGIN
            --intentem tancar les connexions obertes
            UTL_HTTP.end_request(v_req);
          EXCEPTION
          WHEN OTHERS THEN
            --ens interesa que "peti" per sobre de tot.
            RAISE;
          END;
          RAISE;
        END;
      END IF;
    END IF;
  END;
  FUNCTION f_seguir_int_bm(
      pnservei  IN VARCHAR2,
      pcformato IN VARCHAR2)
    RETURN VARCHAR2
  IS
    --aquesta funci¿ determinar¿ si cal seguir fent peticions al host i amb quin format
    vseguir VARCHAR2(10) := '0';
  BEGIN
    SELECT NVL(rpposicionamiento, '0')
    INTO vseguir
    FROM int_servicios_formato
    WHERE cinterf = pnservei
    AND cformato  = pcformato;
    RETURN vseguir;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.f_seguir_int', 1, 'Error incontrolado', SQLERRM);
    RETURN 151852; --error al intentar seguir la interfaz
  END;
  FUNCTION f_int_fichero(
      pccompani  IN VARCHAR2,
      pnservei   IN VARCHAR2,
      purl_ini   IN VARCHAR2,
      pnomfitxer IN VARCHAR2,
      ptexto     IN VARCHAR2)
    RETURN NUMBER
  IS
    vsinterf   NUMBER;
    vnvegades  NUMBER;
    vnomfitxer VARCHAR2(250);
    verror     VARCHAR2(2000);
  BEGIN
    pac_int_online.p_inicializar_sinterf;
    vsinterf   := pac_int_online.f_obtener_sinterf;
    vnomfitxer := pnomfitxer;
    vurl       := purl_ini;
    p_guardar_log(pnservei, '****URL: ' || purl_ini || '****' || CHR(10) || 'Se realiza la petici¿n para obtener el fichero.' || ptexto, NULL, '1');
    --mirem si hi ha redireccions
    SELECT SUBSTR(pac_map.f_valor_linia('|', protocolo, 1, 1), 3)
    INTO vnvegades
    FROM int_hostb2b
    WHERE cinterf = pnservei;
    p_guardar_log(pnservei, NULL, NULL, '2');
    pac_int_online.peticion_host(pccompani, pnservei, vurl, vnomfitxer);
    p_guardar_log(pnservei, NULL, 'Se ha obtenido el fichero ' || vnomfitxer, '3');
    INSERT
    INTO int_resultado
      (
        sinterf,
        smapead,
        cresultado
      )
      VALUES
      (
        vsinterf,
        0,
        0
      );
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    verror := SQLERRM;
    INSERT
    INTO int_resultado
      (
        sinterf,
        smapead,
        cresultado,
        terror
      )
      VALUES
      (
        vsinterf,
        0,
        1,
        SUBSTR(verror, 1, 2000)
      );
    p_tab_error(f_sysdate, f_user, 'pac_int_online.f_int_fichero', 1, 'Error incontrolado', verror);
    RETURN 151851; --error en la interfaz
  END;
  FUNCTION f_int
    (
      pemp       IN VARCHAR2,
      psinterf   IN NUMBER,
      pnservei   IN VARCHAR2,
      plinia_ida IN VARCHAR2
    )
    RETURN NUMBER
  IS
    -- funci¿ gen¿rica per interf¿cies
    vlinia_ida_ini VARCHAR2(500);
    -- Variable con plinea_ida menos formato (caso BM). NO UTILIZAR plinia_ida.
    vlinia_ida VARCHAR2(500);
    v_msg      VARCHAR2(32700);
    v_msg1     VARCHAR2(32700);
    verror     NUMBER;
    v_domdoc xmldom.domdocument;
    plinia_vuelta VARCHAR2(500);
    vsinterf      NUMBER;
    vnrosecuencia NUMBER;
    vnode xmldom.domnode;
    vnresultado     NUMBER;
    vtresultado     VARCHAR2(512);
    vcmapead_ida    VARCHAR2(5);
    vcmapead_vuelta VARCHAR2(5);
    vttipomap_out   NUMBER;
    vttipomap_in    NUMBER;
    vsmapead        NUMBER;
    vformato int_servicios_formato.cformato%TYPE;
    n_traza NUMBER;
    PROCEDURE debug_mensaje
      (
        p_texto IN VARCHAR2
      )
    IS
    BEGIN
      ----p_control_error(f_user,'f_int-'||to_char(n_traza),p_texto);
      NULL;
    END;
  BEGIN
    n_traza        := 0;
    vlinia_ida_ini := plinia_ida;
    -------------------------------------------
    --          CASO GENERICO                --
    -------------------------------------------
    n_traza                             := 1000;
    pac_int_online.verror_peticion_host := NULL;
    IF psinterf                         IS NULL THEN
      n_traza                           := 1010;
      pac_int_online.p_inicializar_sinterf;
      n_traza  := 1020;
      vsinterf := pac_int_online.f_obtener_sinterf;
    ELSE
      vsinterf := psinterf;
    END IF;
    debug_mensaje('1 sinterf ' || vsinterf);
    n_traza := 1030;
    SELECT s.cmapead_out,
      m.ttipomap,
      m2.ttipomap,
      s.cmapead_in
    INTO vcmapead_ida,
      vttipomap_out,
      vttipomap_in,
      vcmapead_vuelta
    FROM int_servicios s,
      map_cabecera m,
      map_cabecera m2
    WHERE s.cinterf   = pnservei
    AND s.cmapead_out = m.cmapead
    AND s.cmapead_in  = m2.cmapead;
    --al par¿metre plinea_ida hi ha la linea d'entrada pel map d'anada concatenada amb
    -- una @ i concatenada amb la linea d'entrada pel map de tornada
    debug_mensaje('vlinia_ida_ini ' || vlinia_ida_ini);
    n_traza                      := 1040;
    IF INSTR(vlinia_ida_ini, '@') = 0 THEN
      vlinia_ida                 := vsinterf || '|' || vlinia_ida_ini;
    ELSE
      vlinia_ida := vsinterf || '|' || SUBSTR(vlinia_ida_ini, 1, INSTR(vlinia_ida_ini, '@') - 1);
    END IF;
    vlinia_ida     := REPLACE(vlinia_ida, '[$#ARROBA#$]', '@');
    vlinia_ida_ini := REPLACE(vlinia_ida_ini, '[$#ARROBA#$]', '@');
    debug_mensaje('vlinia_ida ' || vlinia_ida);
    IF vttipomap_out = 3 THEN
      n_traza       := 1050;
      pac_map.p_genera_parametros_xml(vcmapead_ida, vlinia_ida);
      n_traza := 1060;
      verror  := pac_map.genera_map(vcmapead_ida, vsmapead);
      n_traza := 1070;
      v_msg   := pac_map.f_obtener_xml_texto;
      --v_msg := pac_map.f_obtener_xml_texto || '          ';
      IF vcmapead_ida = 'I009S' THEN
        v_msg        := REPLACE(v_msg, '¿', '[N]');
        v_msg        := REPLACE(v_msg, '¿', '[n]');
        v_msg        := REPLACE(v_msg, '¿', '[C]');
        v_msg        := REPLACE(v_msg, '¿', '[c]');
      END IF;
      FOR i IN 0 .. ROUND(LENGTH(v_msg) / 240, 0)
      LOOP
        debug_mensaje(SUBSTR(v_msg, i * 240 + 1, 240));
      END LOOP;
      n_traza := 1080;
      p_guardar_log(pnservei, v_msg, NULL, '1');
    ELSE
      n_traza := 1090;
      pac_map.p_carga_parametros_fichero(vcmapead_ida, vlinia_ida);
      n_traza := 1100;
      verror  := pac_map.carga_map(vcmapead_ida, vsmapead);
      n_traza := 1110;
      --            select cadena
      --            into v_msg
      --          from int_cadena
      --       where sinterf=vsinterf
      --       and cmapead=vcmapead_ida;
      --         n_traza := 1120;
      p_guardar_log(pnservei, v_msg, NULL, '1');
    END IF;
    IF verror <> 0 THEN
      --encara que hi hagi hagut error en la generaci¿ del map mostrem el missatge
      --   i guardem el log
      RETURN verror;
    END IF;
    BEGIN
      n_traza := 1130;
      peticion_host(pemp, pnservei, v_msg, v_msg1);
      debug_mensaje('despr¿s de peticion_host');
      --   --guardem la url
      --   p_guardar_log (pnservei, null, v_msg1, '2');
      debug_mensaje('RESPOSTA ');
      n_traza := 1150;
      --    v_msg1 := convert (v_msg1,'WE8ISO8859P1','UTF8');
      IF pnservei <> 'I052' THEN
        FOR i IN 0 .. ROUND(LENGTH(v_msg1) / 240, 0)
        LOOP
          debug_mensaje(SUBSTR(v_msg1, i * 240 + 1, 240));
        END LOOP;
      END IF;
      --guardem la url
      n_traza := 1160;
      p_guardar_log(pnservei, NULL, v_msg1, '2');
    EXCEPTION
    WHEN OTHERS THEN
      n_traza                                := 1170;
      IF pac_int_online.verror_peticion_host IS NULL THEN
        --si falla per parsing no captura al when others de peticion host, sino aqu¿.
        --Potser tamb¿ altres errors...
        n_traza                             := 1180;
        pac_int_online.verror_peticion_host := SQLCODE;
      END IF;
      debug_mensaje(SUBSTR('f_int: ha petat la funci¿ peticion_host. sqlerrm ' || SQLERRM, 1, 250));
      --s'ha produit un error a la petici¿
      --guardem la url
      n_traza := 1190;
      p_guardar_log(pnservei, NULL, v_msg1, '2');
      n_traza                               := 1200;
      IF pac_int_online.verror_peticion_host = -29273 THEN
        debug_mensaje('estem a f_int amb error -29273: timeout');
        n_traza := 1210;
        INSERT
        INTO int_resultado
          (
            sinterf,
            cmapead,
            smapead,
            cresultado,
            terror
          )
          VALUES
          (
            vsinterf,
            vcmapead_ida,
            smapead.NEXTVAL,
            4,
            'La petici¿n no ha obtenido ninguna respuesta. Error: '
            || pac_int_online.verror_peticion_host
          );
      ELSIF pac_int_online.verror_peticion_host = -20100 THEN
        debug_mensaje('estem a f_int amb error -20100: error de parsing');
        n_traza := 1220;
        INSERT
        INTO int_resultado
          (
            sinterf,
            cmapead,
            smapead,
            cresultado,
            terror
          )
          VALUES
          (
            vsinterf,
            vcmapead_ida,
            smapead.NEXTVAL,
            5,
            'La respuesta obtenida es incorrecta y no puede parsearse. Error: '
            || pac_int_online.verror_peticion_host
          );
      ELSE
        -- es comenten les recepcions d'aquests errors, ja que mai funcionen.
        --      verror := utl_http.get_detailed_sqlcode;
        --      vterror := utl_http.get_detailed_sqlerrm;
        n_traza := 1230;
        INSERT
        INTO int_resultado
          (
            sinterf,
            cmapead,
            smapead,
            cresultado,
            terror
          )
          VALUES
          (
            vsinterf,
            vcmapead_ida,
            smapead.NEXTVAL,
            6,
            'La petici¿n ha obtenido una respuesta incorrecta. Error: '
            || pac_int_online.verror_peticion_host
          );
        IF v_msg1 IS NOT NULL THEN
          -- guardem el log abans de retornar amb l'error
          n_traza := 1240;
          p_guardar_log(pnservei, NULL, v_msg1, '3');
        END IF;
      END IF;
      IF vttipomap_out = 3 THEN
        n_traza       := 1250;
        finalizar_parser(pac_int_online.vparser);
      END IF;
      RETURN 0;
    END;
    IF v_msg1 IS NOT NULL THEN
      n_traza := 1260;
      p_guardar_log(pnservei, NULL, v_msg1, '3');
    END IF;
    n_traza                                := 1270;
    IF pac_int_online.verror_peticion_host IS NOT NULL THEN
      RETURN pac_int_online.verror_peticion_host;
    ELSE
      -- Obtenci¿n respuesta
      n_traza                      := 1280;
      IF INSTR(vlinia_ida_ini, '@') = 0 THEN
        plinia_vuelta              := vsinterf;
      ELSE
        plinia_vuelta := vsinterf || '|' || SUBSTR(vlinia_ida_ini, INSTR(vlinia_ida_ini, '@') + 1);
      END IF;
      IF vttipomap_in = 3 THEN
        n_traza      := 1290;
        v_domdoc     := xmlparser.getdocument(pac_int_online.vparser);
        pac_map.p_carga_parametros_xml(v_domdoc, plinia_vuelta);
      ELSE
        debug_mensaje('vcmapead_vuelta: ' || vcmapead_vuelta || ',plinia_vuelta: ' || plinia_vuelta);
        n_traza := 1300;
        pac_map.p_carga_parametros_fichero(vcmapead_vuelta, plinia_vuelta);
      END IF;
      n_traza := 1310;
      verror  := pac_map.carga_map(vcmapead_vuelta, vsmapead);
      debug_mensaje('2 smapead de carga: ' || vsmapead);
    END IF;
    IF vttipomap_out = 3 THEN
      n_traza       := 1320;
      finalizar_parser(pac_int_online.vparser);
    END IF;
    n_traza := 1330;
    RETURN verror;
  EXCEPTION
  WHEN OTHERS THEN
    DECLARE
      n_errorcode NUMBER;
      n_errortext VARCHAR2(2000);
    BEGIN
      n_errorcode := SQLCODE;
      n_errortext := SQLERRM;
      --
      debug_mensaje(SUBSTR('al when others de f_int: ' || n_errorcode || '-' || n_errortext, 1, 250));
      --
      p_tab_error(f_sysdate, f_user, 'pac_int_online.f_int', n_traza, 'Error incontrolado ' || n_errorcode, n_errortext);
    END;
    RETURN 151851; --error en la interfaz
  END f_int;
  FUNCTION f_recuperar_error
    (
      pemp     IN VARCHAR2,
      psinterf IN NUMBER,
      pcidioma IN NUMBER,
      pnresultado OUT VARCHAR2,
      ptresultado OUT VARCHAR2
    )
    RETURN NUMBER
  IS
    vcresultado  VARCHAR2(100);
    vnerror      VARCHAR2(100);
    vtcampoerror VARCHAR2(100);
    vterror      VARCHAR2(2500);
    verror       NUMBER := 0;
    vtexto       VARCHAR2(256);
    ntraza       NUMBER;
    vclave       VARCHAR2(2000);
  BEGIN
    ntraza := 10;
    vclave := 'e=' || pemp || ' i=' || TO_CHAR(psinterf) || ' p=' || TO_CHAR(pcidioma);
    SELECT r1.cresultado,
      r1.nerror,
      r1.tcampoerror,
      r1.terror
    INTO vcresultado,
      vnerror,
      vtcampoerror,
      vterror
    FROM int_resultado r1
    WHERE r1.sinterf = psinterf
    AND r1.smapead   =
      (SELECT MAX(r2.smapead) FROM int_resultado r2 WHERE r2.sinterf = psinterf
      );
    BEGIN
      ntraza      := 20;
      vclave      := 'e=' || pemp;
      pnresultado := f_obtener_valor_axis(pemp, 'TIPO ERROR', vcresultado);
      verror      := 0;
    EXCEPTION
    WHEN OTHERS THEN
      verror := SQLCODE;
    END;
    IF verror         = 0 THEN
      IF pnresultado <> 0 THEN
        -- hi ha hagut un error, per tant recuperem el text
        IF vnerror    IS NOT NULL THEN
          ntraza      := 30;
          vclave      := '120125 vnerror=' || vnerror;
          vtexto      := f_axis_literales(120125, pcidioma);
          ptresultado := ptresultado || ' - ' || vtexto || ': ' || vnerror;
        END IF;
        IF vtcampoerror IS NOT NULL THEN
          ntraza        := 30;
          vclave        := '151849 vtcampoerror=' || vtcampoerror;
          vtexto        := f_axis_literales(151849, pcidioma);
          ptresultado   := ptresultado || ' - ' || vtexto || ': ' || vtcampoerror;
        END IF;
        IF vterror    IS NOT NULL THEN
          ntraza      := 40;
          vclave      := 'vterror=' || vterror;
          ptresultado := ptresultado || ' - ' || vterror;
        END IF;
        ptresultado := SUBSTR(ptresultado, 4);
      END IF;
    END IF;
    ntraza := 50;
    vclave := 'return verror=' || verror;
    RETURN verror;
  EXCEPTION
  WHEN OTHERS THEN
    --P_Tab_Error(F_SYSDATE, f_USER, 'pac_int_online.f_recuperar_error', 1,'Error incontrolado', SQLERRM);
    p_tab_error(f_sysdate, f_user, 'pac_int_online.f_recuperar_error', ntraza, 'Error incontrolado ' || SQLCODE, vclave || ' -->' || SQLERRM);
    RETURN 151850; --error al recuperar l'error d'interf¿cie
  END f_recuperar_error;
  FUNCTION f_obtener_valor_axis(
      pemp    IN VARCHAR2,
      pcampo  IN VARCHAR2,
      pvalemp IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vvalaxis int_codigos_emp.cvalaxis%TYPE;
  BEGIN
    BEGIN
      SELECT cvalaxis
      INTO vvalaxis
      FROM int_codigos_emp
      WHERE ccodigo = pcampo
      AND cempres   = pemp
      AND cvalemp   = NVL(pvalemp, 'NULL');
    EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      BEGIN
        SELECT cvalaxisdef
        INTO vvalaxis
        FROM int_codigos_emp
        WHERE ccodigo = pcampo
        AND cempres   = pemp
        AND cvalemp   = NVL(pvalemp, 'NULL')
        GROUP BY cvalaxisdef;
        IF vvalaxis IS NULL THEN
          -- no est¿ permesa l'ambig¿itat
          p_tab_error(f_sysdate, f_user, 'obtener valor axis', 1, pcampo || ' ' || pemp || ' ' || pvalemp, SQLERRM);
          RAISE TOO_MANY_ROWS;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'obtener valor axis', 1, pcampo || ' ' || pemp || ' ' || pvalemp, SQLERRM);
        RAISE TOO_MANY_ROWS;
      END;
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'obtener valor axis', 1, pcampo || ' ' || pemp || ' ' || pvalemp, SQLERRM);
      RAISE TOO_MANY_ROWS;
    END;
    IF vvalaxis = 'NULL' THEN
      vvalaxis := NULL;
    END IF;
    RETURN vvalaxis;
  END;
----------------
  FUNCTION f_obtener_valor_emp(
      pemp     IN VARCHAR2,
      pcampo   IN VARCHAR2,
      pvalaxis IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vvalemp int_codigos_emp.cvalemp%TYPE;
  BEGIN
    BEGIN
      SELECT cvalemp
      INTO vvalemp
      FROM int_codigos_emp
      WHERE ccodigo = pcampo
      AND cempres   = pemp
      AND cvalaxis  = NVL(pvalaxis, 'NULL');
    EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      BEGIN
        SELECT cvaldef
        INTO vvalemp
        FROM int_codigos_emp
        WHERE ccodigo = pcampo
        AND cempres   = pemp
        AND cvalaxis  = NVL(pvalaxis, 'NULL')
        GROUP BY cvaldef;
        IF vvalemp IS NULL THEN
          -- no est¿ permesa l'ambig¿itat
          p_tab_error(f_sysdate, f_user, 'obtener valor emp', 1, pcampo || ' ' || pemp || ' ' || pvalaxis, SQLERRM);
          RAISE TOO_MANY_ROWS;
        END IF;
      EXCEPTION
      WHEN OTHERS THEN
        p_tab_error(f_sysdate, f_user, 'obtener valor emp', 1, pcampo || ' ' || pemp || ' ' || pvalaxis, SQLERRM);
        RAISE TOO_MANY_ROWS;
      END;
    WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'obtener valor emp', 1, pcampo || ' ' || pemp || ' ' || pvalaxis, SQLERRM);
      RAISE TOO_MANY_ROWS;
    END;
    IF vvalemp = 'NULL' THEN
      vvalemp := NULL;
    END IF;
    RETURN vvalemp;
  END;
----------------
  FUNCTION f_buscar_valor_axis(
      pemp    IN VARCHAR2,
      pcampo  IN VARCHAR2,
      pvalemp IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vvalaxis int_codigos_emp.cvalaxis%TYPE;
  BEGIN
    vvalaxis := f_obtener_valor_axis(pemp, pcampo, pvalemp);
    RETURN vvalaxis;
  EXCEPTION
  WHEN OTHERS THEN
    --se retorna un valor (en principio imposible) para indicar
    --  que la traducci¿n no ha sido posible
    RETURN '@@SINVALOR@@';
  END;
----------------
  FUNCTION f_buscar_valor_emp(
      pemp     IN VARCHAR2,
      pcampo   IN VARCHAR2,
      pvalaxis IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vvalemp int_codigos_emp.cvalemp%TYPE;
  BEGIN
    vvalemp := f_obtener_valor_emp(pemp, pcampo, pvalaxis);
    RETURN vvalemp;
  EXCEPTION
  WHEN OTHERS THEN
    --se retorna un valor (en principio imposible) para indicar
    --  que la traducci¿n no ha sido posible
    RETURN '@@SINVALOR@@';
  END;
/*
Dada una descripcio de pais, devuelve el codigo del pais
Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia
*/
  FUNCTION f_buscar_pais(
      ptpais IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vcpais paises.cpais%TYPE;
  BEGIN
    SELECT cpais INTO vcpais FROM paises WHERE UPPER(tpais) = UPPER(ptpais);
    RETURN vcpais;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Dada una codigo iso de pais, devuelve el codigo del pais
Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia
*/
  FUNCTION f_buscar_pais_iso(
      pcodiso IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vcpais paises.cpais%TYPE;
  BEGIN
    SELECT cpais
    INTO vcpais
    FROM paises
    WHERE TO_NUMBER(codiso) = TO_NUMBER(pcodiso);
    RETURN vcpais;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Dada una descripcion de una provincia, devuelve el codigo de la provincia
Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia.
Opcional el codigo de pais
*/
  FUNCTION f_buscar_provincia(
      ptprovincia IN VARCHAR2,
      pcpais      IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
  IS
    vcprovin provincias.cprovin%TYPE;
  BEGIN
    SELECT cprovin
    INTO vcprovin
    FROM provincias
    WHERE UPPER(tprovin) = UPPER(ptprovincia)
    AND cpais            = NVL(pcpais, cpais);
    RETURN vcprovin;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Dado una descripcio de una poblaci¿n  y opcionalmente la provincia a la que pertenece, devuelve el codigo de la polbaci¿n.
Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia
*/
  FUNCTION f_buscar_poblacion(
      ptpoblacion IN VARCHAR2,
      pcprovincia IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2
  IS
    vcpoblac poblaciones.cpoblac%TYPE;
  BEGIN
    SELECT cpoblac
    INTO vcpoblac
    FROM poblaciones
    WHERE UPPER(tpoblac) = UPPER(ptpoblacion)
    AND cprovin          = NVL(pcprovincia, cprovin);
    RETURN vcpoblac;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Dada una descripcio de un profesi¿n devuelve el c¿digo de la profesi¿n.
Si el retorno es null, es que no ha encotrado el codigo, o habia mas de una correspondencia.
*/
  FUNCTION f_buscar_profesion(
      ptprofesion IN VARCHAR2)
    RETURN VARCHAR2
  IS
    vcprofes profesiones.cprofes%TYPE;
  BEGIN
    SELECT DISTINCT p.cprofes
    INTO vcprofes
    FROM profesiones p
    WHERE UPPER(p.tprofes) = UPPER(ptprofesion)
    AND p.cidioma          =
      (SELECT MIN(p2.cidioma) FROM profesiones p2 WHERE p.tprofes = p2.tprofes
      );
    RETURN vcprofes;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
  FUNCTION f_obtener_terminal(
      pcempres  IN terminales.cempres%TYPE,
      pcmaqfisi IN terminales.cmaqfisi%TYPE)
    RETURN terminales.cterminal%TYPE
  IS
    vcterminal terminales.cterminal%TYPE;
  BEGIN
    BEGIN
      SELECT cterminal
      INTO vcterminal
      FROM terminales
      WHERE cempres = pcempres
      AND cmaqfisi  = pcmaqfisi;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vcterminal := NULL;
    WHEN TOO_MANY_ROWS THEN
      vcterminal := NULL;
    END;
    RETURN vcterminal;
  END f_obtener_terminal;
  FUNCTION f_obtiene_codigo_agente(
      p_nombre_completo IN VARCHAR2)
    RETURN agentes.cagente%TYPE
  IS
    vcagente agentes.cagente%TYPE;
  BEGIN
    BEGIN
      SELECT DISTINCT a.cagente
      INTO vcagente
      FROM per_detper p,
        agentes a
      WHERE a.sperson             = p.sperson
      AND TRIM(UPPER(p.tapelli1)) = TRIM(UPPER(p_nombre_completo));
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      vcagente := NULL;
    WHEN TOO_MANY_ROWS THEN
      vcagente := NULL;
    END;
    RETURN vcagente;
  END f_obtiene_codigo_agente;
/*
*/
  FUNCTION f_log_hostin(
      psinterf    IN NUMBER,
      ptmeninhost IN CLOB)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE int_mensajes SET tmeninhost = ptmeninhost WHERE sinterf = psinterf;
    COMMIT;
    IF SQL%ROWCOUNT <> 1 THEN
      RETURN 1;
    END IF;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.F_LOG_HOSTIN', 1, psinterf, SQLERRM);
    RETURN SQLCODE;
  END;
  FUNCTION f_log_hostout(
      psinterf     IN NUMBER,
      ptmenouthost IN CLOB)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE int_mensajes SET tmenouthost = ptmenouthost WHERE sinterf = psinterf;
    COMMIT;
    IF SQL%ROWCOUNT <> 1 THEN
      RETURN 1;
    END IF;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.F_LOG_HOSTOUT', 1, psinterf, SQLERRM);
    RETURN SQLCODE;
  END;
/*
Dado una abreviatura, nos recupere el codigo del tipo de via -- mantis 8600
*/
  FUNCTION f_obtiene_tipo_via(
      ptsiglas IN tipos_via.tsiglas%TYPE)
    RETURN NUMBER
  IS
    vcsiglas tipos_via.csiglas%TYPE;
  BEGIN
    SELECT csiglas
    INTO vcsiglas
    FROM tipos_via
    WHERE UPPER(tsiglas) = UPPER(ptsiglas);
    RETURN vcsiglas;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Crea una nueva poblacion para la provincia indicada O A¿ADE UN NUEVO COD POSTAL SI NO EXISTE.-- mantis 8600
*/
  FUNCTION f_crear_poblacion(
      p_nombre_poblacion VARCHAR2,
      p_cod_provincia    NUMBER,
      p_codigo_postal    VARCHAR2,
      p_cod_poblacion OUT NUMBER)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    vcpoblac poblaciones.cpoblac%TYPE;
    lv_cuantos NUMBER := 0;
  BEGIN
    IF p_nombre_poblacion IS NULL OR p_cod_provincia IS NULL OR p_codigo_postal IS NULL THEN
      RETURN 1; -- error ning¿n par¿metro puede ser nulo
    END IF;
    SELECT COUNT('p')
    INTO lv_cuantos
    FROM poblaciones
    WHERE cprovin = p_cod_provincia
    AND UPPER(tpoblac) LIKE UPPER(p_nombre_poblacion);
    IF lv_cuantos > 0 THEN
      SELECT DISTINCT cpoblac
      INTO vcpoblac
      FROM poblaciones
      WHERE cprovin = p_cod_provincia
      AND UPPER(tpoblac) LIKE UPPER(p_nombre_poblacion);
      SELECT COUNT('p')
      INTO lv_cuantos
      FROM codpostal
      WHERE cprovin = p_cod_provincia
      AND cpostal   = p_codigo_postal
      AND cpoblac   = vcpoblac;
      IF lv_cuantos > 0 THEN
        RETURN 1; --error, ya existe
      ELSE
        INSERT
        INTO codpostal
          (
            cprovin,
            cpoblac,
            cpostal
          )
          VALUES
          (
            p_cod_provincia,
            vcpoblac,
            p_codigo_postal
          );
      END IF;
    ELSE
      SELECT MAX(cpoblac) + 1 --nuevo cod poblaci¿n
      INTO vcpoblac
      FROM poblaciones
      WHERE cprovin = p_cod_provincia;
      INSERT
      INTO poblaciones
        (
          cprovin,
          cpoblac,
          tpoblac
        )
        VALUES
        (
          p_cod_provincia,
          vcpoblac,
          p_nombre_poblacion
        );
      INSERT
      INTO codpostal
        (
          cprovin,
          cpoblac,
          cpostal
        )
        VALUES
        (
          p_cod_provincia,
          vcpoblac,
          p_codigo_postal
        );
    END IF;
    COMMIT;
    p_cod_poblacion := vcpoblac; --retorno el codigo de poblaci¿n
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN 1;
  END;
/*
Dado un tipo cta Host devuelve el codigo interno de AXIS
*/
  FUNCTION f_obtener_tipocuenta
    (
      p_ctipcuentahost IN VARCHAR2
    )
    RETURN NUMBER
  IS
    vctipcuenta ctacategoria_orden.ctipcuenta%TYPE;
  BEGIN
    SELECT ctipcuenta
    INTO vctipcuenta
    FROM ctacategoria_orden
    WHERE UPPER(ctipcuentahost) = UPPER(p_ctipcuentahost);
    RETURN vctipcuenta;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    vctipcuenta := f_crear_tipocuenta(p_ctipcuentahost);
    RETURN vctipcuenta;
  WHEN OTHERS THEN
    RETURN NULL;
  END;
/*
Da de alta un registro en CTACATEGORIA_ORDEN.
Devuelve la columna CTIPCUENTA creada
*/
  FUNCTION f_crear_tipocuenta(
      p_ctipcuentahost IN VARCHAR2)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    vctipcuenta ctacategoria_orden.ctipcuenta%TYPE;
  BEGIN
    SELECT MAX(ctipcuenta) + 1 INTO vctipcuenta FROM ctacategoria_orden;
    INSERT
    INTO ctacategoria_orden
      (
        ctipcuenta,
        nprior,
        ctipcuentahost
      )
      VALUES
      (
        vctipcuenta,
        999,
        p_ctipcuentahost
      );
    COMMIT;
    RETURN vctipcuenta;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
--Bug 13893 - PFA - 12/08/2010
/*
Retorna el c¿digo del pais por defecto, informado en PARINSTALCION = PAIS_DEF.
Puede que retorna nulo.
*/
  FUNCTION f_buscar_pais_defecto
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN pac_parametros.f_parinstalacion_n('PAIS_DEF');
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  END;
--Fi Bug 13893 - PFA - 12/08/2010
--Bug 15631 - PFA - 03/08/2010
/*
Produce trazas de log en BBDD para investigar incidencias
Devuelve la secuencia para la interfaz.
Bug 28263 FPG - 23/10/2013: cambiar par¿metro psinterf a IN OUT
*/
  FUNCTION f_inicializar_log_listener
    (
      pcinterf IN VARCHAR,
      ptmenout IN CLOB,
      psinterf IN OUT NUMBER
    )
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
    vsinterf NUMBER;
  BEGIN
    --MLUIS 16/01/2013 Validar que el numero de interfaz es nulo para crear uno nuevo
    IF psinterf IS NULL OR psinterf = 0 THEN
      pac_int_online.p_inicializar_sinterf;
      vsinterf := pac_int_online.f_obtener_sinterf;
      psinterf := vsinterf;
    ELSE
      vsinterf := psinterf;
    END IF;
    INSERT
    INTO int_mensajes
      (
        sinterf,
        cinterf,
        tmenout,
        finterf
      )
      VALUES
      (
        vsinterf,
        pcinterf,
        ptmenout,
        f_sysdate
      );
    COMMIT;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    RETURN SQLCODE;
  END;
--Fi Bug 15631 - PFA - 03/08/2010
-- Bug 14365 - 26/08/2010 - SRA - funci¿n que devuelve un cursor con todas las equivalencias entre c¿digos origen de la empresa
-- y su c¿digo equivalente en AXIS
  FUNCTION f_obtener_valores_axis
    (
      pemp   IN VARCHAR2,
      pcampo IN VARCHAR2
    )
    RETURN sys_refcursor
  IS
    vpasexec    NUMBER := 0;
    v_ncontador NUMBER;
    cur_vvalaxis sys_refcursor;
  BEGIN
    vpasexec := 1;
    SELECT COUNT(1)
    INTO v_ncontador
    FROM int_codigos_emp
    WHERE cempres  = pemp
    AND ccodigo    = pcampo;
    IF v_ncontador = 0 THEN
      OPEN cur_vvalaxis FOR SELECT NULL
    AS
      co,
      NULL
    AS
      ce FROM DUAL;
    ELSE
      vpasexec := 2;
      OPEN cur_vvalaxis FOR SELECT cvalemp
    AS
      co,
      cvalaxis
    AS
      ce FROM int_codigos_emp WHERE cempres = pemp AND ccodigo = pcampo ORDER BY cvalemp;
    END IF;
    vpasexec := 3;
    RETURN cur_vvalaxis;
  EXCEPTION
  WHEN OTHERS THEN
    -- BUG -21546_108724- 10/02/2012 - JLTS - Cierre de posibles cursores abiertos
    IF cur_vvalaxis%ISOPEN THEN
      CLOSE cur_vvalaxis;
    END IF;
    p_tab_error(f_sysdate, f_user, 'pac_int_online.f_obtener_valores_axis', vpasexec, 'pcampo: ' || pcampo || ', pemp: ' || pemp, SQLERRM);
    RAISE;
  END f_obtener_valores_axis;
-- Bug 14365 - 26/08/2010 - SRA - funci¿n que devuelve un cursor con todas las equivalencias entre c¿digos origen en AXIS
-- y su c¿digo equivalente en la empresa
  FUNCTION f_obtener_valores_emp(
      pemp   IN VARCHAR2,
      pcampo IN VARCHAR2)
    RETURN sys_refcursor
  IS
    vpasexec    NUMBER := 0;
    v_ncontador NUMBER;
    cur_vvalemp sys_refcursor;
  BEGIN
    vpasexec := 1;
    SELECT COUNT(1)
    INTO v_ncontador
    FROM int_codigos_emp
    WHERE cempres  = pemp
    AND ccodigo    = pcampo;
    IF v_ncontador = 0 THEN
      OPEN cur_vvalemp FOR SELECT NULL
    AS
      co,
      NULL
    AS
      ce FROM DUAL;
    ELSE
      vpasexec := 2;
      OPEN cur_vvalemp FOR SELECT cvalaxis
    AS
      co,
      cvalemp
    AS
      ce FROM int_codigos_emp WHERE cempres = pemp AND ccodigo = pcampo ORDER BY cvalemp;
    END IF;
    vpasexec := 3;
    RETURN cur_vvalemp;
  EXCEPTION
  WHEN OTHERS THEN
    -- BUG -21546_108724- 10/02/2012 - JLTS - Cierre de posibles cursores abiertos
    IF cur_vvalemp%ISOPEN THEN
      CLOSE cur_vvalemp;
    END IF;
    p_tab_error(f_sysdate, f_user, 'pac_int_online.f_obtener_valores_emp', vpasexec, 'pcampo: ' || pcampo || ', pemp: ' || pemp, SQLERRM);
    RAISE;
  END f_obtener_valores_emp;
  FUNCTION f_log_proceso(
      psinterf      IN NUMBER,
      psxml         IN NUMBER,
      pxmlrespuesta IN CLOB)
    RETURN NUMBER
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    UPDATE int_datos_xml
    SET xml_respuesta = pxmlrespuesta
    WHERE sinterf     = psinterf
    AND sxml          = psxml;
    COMMIT;
    IF SQL%ROWCOUNT <> 1 THEN
      RETURN 1;
    END IF;
    RETURN 0;
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.F_LOG_HOSTIN', 1, psinterf, SQLERRM);
    RETURN SQLCODE;
  END;

  --AAC_INI-CONF_480-20161125
  FUNCTION recuperaTagErrorRespGenerWS(
      xml_clob CLOB)
    RETURN VARCHAR2
  IS
    v_doc dbms_xmldom.domdocument;
    v_nodelist dbms_xmldom.DOMNODELIST;
    v_node dbms_xmldom.DomNode;
  BEGIN
    v_doc      := dbms_xmldom.newdomdocument(xml_clob);
    v_nodelist := dbms_xmldom.getelementsbytagname(v_doc, 'error');
    v_node     := dbms_xmldom.getfirstchild(dbms_xmldom.item(v_nodelist, 0));
    DBMS_OUTPUT.put_line('node := ' ||dbms_xmldom.getnodevalue(v_node));
    IF dbms_xmldom.getnodevalue(v_node) <> 0 THEN
      p_control_error('AAC_480','pac_int_online.f_alta_persona','recuperaTagErrorRespGenerWS:' || dbms_xmldom.getnodevalue(v_node));
      pac_int_online.verror_peticion_host := dbms_xmldom.getnodevalue(v_node);
    END IF;
    RETURN dbms_xmldom.getnodevalue(v_node);
  EXCEPTION
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, 'pac_int_online.recuperaTagRespuestaGenericaWS', 1, -1, SQLERRM);
  END;
--AAC_FI-CONF_480-20161125
END pac_int_online;

/

  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_INT_ONLINE" TO "PROGRAMADORESCSI";
