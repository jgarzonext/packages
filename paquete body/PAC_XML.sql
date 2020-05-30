--------------------------------------------------------
--  DDL for Package Body PAC_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_XML" AS
   FUNCTION hostb2b(p_empresa IN VARCHAR2)
      RETURN VARCHAR2 IS
      CURSOR c_host IS
         SELECT url
           FROM hostb2b
          WHERE empresa = p_empresa
            AND activo = 'S';

      v_url          c_host%ROWTYPE;
   BEGIN
      OPEN c_host;

      FETCH c_host
       INTO v_url;

      IF c_host%NOTFOUND THEN
         CLOSE c_host;

         RETURN NULL;
      END IF;

      CLOSE c_host;

      RETURN v_url.url;
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_host%ISOPEN THEN
            CLOSE c_host;
         END IF;

         RETURN NULL;
   END;

-------------------------------------------------------------
   PROCEDURE parsear(p_clob IN CLOB, p_parser IN OUT xmlparser.parser) IS
   BEGIN
      --insert into prueba(linea) values ('Entro en parsear'||dbms_lob.substr(p_clob,2000,1));commit;
      p_parser := xmlparser.newparser;
      xmlparser.setvalidationmode(p_parser, FALSE);

      IF DBMS_LOB.getlength(p_clob) > 32767 THEN
         xmlparser.parseclob(p_parser, p_clob);
      ELSE
         xmlparser.parsebuffer(p_parser,
                               DBMS_LOB.SUBSTR(p_clob, DBMS_LOB.getlength(p_clob), 1));
      END IF;
   END;

-------------------------------------------------------------
   PROCEDURE finalizar_parser(v_parser IN OUT xmlparser.parser) IS
   BEGIN
      xmlparser.freeparser(v_parser);
   END;

-------------------------------------------------------------
   PROCEDURE anadirnodotexto(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_tag IN VARCHAR2,
      p_texto IN VARCHAR2) IS
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      myelement := xmldom.createelement(p_doc, p_tag);
      mytextnode := xmldom.createtextnode(p_doc, p_texto);
      mynode := xmldom.appendchild(p_node, xmldom.makenode(myelement));
      mynode := xmldom.appendchild(mynode, xmldom.makenode(mytextnode));
   END;

-------------------------------------------------------------
-- Buscar el valor del texto del primer nodo con tag p_tag
-------------------------------------------------------------
   FUNCTION buscarnodotexto(p_doc xmldom.domdocument, p_tag IN VARCHAR2)
      RETURN VARCHAR2 IS
      nl             xmldom.domnodelist;
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      nl := xmldom.getelementsbytagname(p_doc, p_tag);

      IF xmldom.getlength(nl) <> 0 THEN
         mynode := xmldom.item(nl, 0);
         mynode := xmldom.getfirstchild(mynode);

         IF NOT xmldom.isnull(mynode) THEN
            RETURN xmldom.getnodevalue(mynode);
         ELSE
            RETURN NULL;
         END IF;
      ELSE
         RETURN NULL;
      END IF;
   END;

-------------------------------------------------------------
-- Routina para tratar los posibles errores del host o del servidor
-------------------------------------------------------------
   FUNCTION tratarerror(
      p_doc xmldom.domdocument,
      p_nrosecuencia NUMBER,
      p_terror IN OUT VARCHAR2)
      RETURN NUMBER IS
      nl             xmldom.domnodelist;
      v_formato      VARCHAR2(2);
      v_msgout       VARCHAR2(32767);
   BEGIN
      IF f_parinstalacion_n('DEBUG') = 1 THEN
         xmldom.writetobuffer(p_doc, v_msgout);

         INSERT INTO tmp_mv
                     (sinterf, v_res)
              VALUES (pac_xml_mv.vsinterf, v_msgout);
      END IF;

      IF TO_CHAR(p_nrosecuencia) <> buscarnodotexto(p_doc, 'NroMensaje') THEN
         p_terror := 'Error fatal en la sincronización';
         RETURN(151303);
      END IF;

      nl := xmldom.getelementsbytagname(p_doc, 'Error');

      IF xmldom.getlength(nl) <> 0 THEN
         p_terror := 'Error Host: ' || buscarnodotexto(p_doc, 'DenMensaje');
         RETURN(151304);
      END IF;

      nl := xmldom.getelementsbytagname(p_doc, 'error');

      IF xmldom.getlength(nl) <> 0 THEN
         p_terror := 'Error Peticion: ' || buscarnodotexto(p_doc, 'mensaje');
         RETURN(151305);
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_xml.tratarError', 1,
                     'Error incontrolado: ' || pac_xml_mv.vsinterf, SQLERRM);
   END;

-------------------------------------------------------------
-- Este procedimiento realiza la petición al host y te devuelve el resultado en
-- un objeto de tipo xmlparser.parser el cual monta una estructura DOM del resultado
   PROCEDURE peticion_host(
      p_url IN VARCHAR2,
      p_tipoint IN VARCHAR2,
      p_msg IN VARCHAR2,
      p_parser IN OUT xmlparser.parser) IS
      v_req          UTL_HTTP.req;
      v_resp         UTL_HTTP.resp;
      v_xmlin        VARCHAR2(10000);
      v_xmlout       VARCHAR2(10000);
      v_res          VARCHAR2(32767);
      v_clob         CLOB;
      v_clobaux      CLOB;
      i              NUMBER := 0;
   BEGIN
      -- Inicializamos una petición http
      v_req := UTL_HTTP.begin_request(p_url, 'POST', 'HTTP/1.0');

      IF p_tipoint = '4202' THEN
          --estem a l'adeudo de recibo, esperarem 4 minuts ja que és una transacció
         --  problemàtica que fa "commits" als dos sistemes
         UTL_HTTP.set_transfer_timeout(240);
      ELSE
         UTL_HTTP.set_transfer_timeout(15);
      END IF;

      UTL_HTTP.set_header(v_req, 'Content-Type', 'application/x-www-form-urlencoded');
      -- Codificamos formato URL
      v_xmlin := 'msg=' || utl_url.ESCAPE(p_msg, TRUE);
      --UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(v_xmlin));
      UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(CONVERT(v_xmlin, 'utf8')));
      -- Escribimos el body
      UTL_HTTP.write_text(v_req, v_xmlin);
      -- Inicilizamos la respuesta
      v_resp := UTL_HTTP.get_response(v_req);
      -- Creamos una c_lob temporal para almacenar el resultado
      DBMS_LOB.createtemporary(v_clob, TRUE);
      DBMS_LOB.OPEN(v_clob, DBMS_LOB.lob_readwrite);

      -- Leemos el BODY de la respuesta
      LOOP
         i := i + 1;
         UTL_HTTP.read_line(v_resp, v_xmlout, TRUE);
         v_res := utl_url.unescape(v_xmlout);

         IF v_res IS NOT NULL THEN
            -- Almacenamos el resultado en la clob
            DBMS_LOB.writeappend(v_clob, LENGTH(v_res), v_res);
         END IF;
      END LOOP;

      UTL_HTTP.end_response(v_resp);
      DBMS_LOB.CLOSE(v_clob);
      DBMS_LOB.freetemporary(v_clob);
   EXCEPTION
      -- Entrará cuando haya llegado toda la respuesta
      WHEN UTL_HTTP.end_of_body THEN
         UTL_HTTP.end_response(v_resp);
         parsear(v_clob, p_parser);
         DBMS_LOB.CLOSE(v_clob);
         DBMS_LOB.freetemporary(v_clob);
/* comentem aquesta excepció ja que ens interessa més capturar-la al package pac_xml_mv
      WHEN others THEN
         p_tab_error(f_sysdate, F_USER, 'pac_xml.peticion_host', 1,
          'Error incontrolado: '||pac_xml_mv.vsinterf, sqlerrm);
*/
   END;

   -------------------------------------------------------------
-- Este procedimiento realiza la petición al host y te devuelve el resultado en
-- un objeto de tipo xmlparser.parser el cual monta una estructura DOM del resultado
   PROCEDURE peticion_host_codigos(
      p_url IN VARCHAR2,
      p_timeout IN NUMBER,
      p_msg IN VARCHAR2,
      p_parser IN OUT xmlparser.parser) IS
      v_req          UTL_HTTP.req;
      v_resp         UTL_HTTP.resp;
      v_xmlin        VARCHAR2(10000);
      v_xmlout       VARCHAR2(10000);
      v_res          VARCHAR2(32767);
      v_clob         CLOB;
      v_clobaux      CLOB;
      i              NUMBER := 0;
   BEGIN
      -- Inicializamos una petición http
      v_req := UTL_HTTP.begin_request(p_url, 'POST', 'HTTP/1.0');
      UTL_HTTP.set_transfer_timeout(p_timeout);
      --UTL_HTTP.set_header(v_req, 'Content-Type', 'application/x-www-form-urlencoded');
      UTL_HTTP.set_header(v_req, 'Content-Type', 'text/xml;charset=UTF-8');
          -- Codificamos formato URL
      --    v_xmlin:= 'msg='||utl_url.escape(p_msg,TRUE);
      v_xmlin := p_msg;
      --UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(v_xmlin));
      UTL_HTTP.set_header(v_req, 'Content-Length', LENGTH(CONVERT(v_xmlin, 'utf8')));
      -- Escribimos el body
      UTL_HTTP.write_text(v_req, v_xmlin);
      -- Inicilizamos la respuesta
      v_resp := UTL_HTTP.get_response(v_req);
      -- Creamos una c_lob temporal para almacenar el resultado
      DBMS_LOB.createtemporary(v_clob, TRUE);
      DBMS_LOB.OPEN(v_clob, DBMS_LOB.lob_readwrite);

      -- Leemos el BODY de la respuesta
      LOOP
         i := i + 1;
         UTL_HTTP.read_line(v_resp, v_xmlout, TRUE);
         v_res := utl_url.unescape(v_xmlout);

         IF v_res IS NOT NULL THEN
            -- Almacenamos el resultado en la clob
            DBMS_LOB.writeappend(v_clob, LENGTH(v_res), v_res);
         END IF;
      END LOOP;

      UTL_HTTP.end_response(v_resp);
      DBMS_LOB.CLOSE(v_clob);
      DBMS_LOB.freetemporary(v_clob);
   EXCEPTION
      -- Entrará cuando haya llegado toda la respuesta
      WHEN UTL_HTTP.end_of_body THEN
         UTL_HTTP.end_response(v_resp);
         parsear(v_clob, p_parser);
         DBMS_LOB.CLOSE(v_clob);
         DBMS_LOB.freetemporary(v_clob);
/* comentem aquesta excepció ja que ens interessa més capturar-la al package pac_xml_mv
      WHEN others THEN
         p_tab_error(f_sysdate, F_USER, 'pac_xml.peticion_host', 1,
          'Error incontrolado: '||pac_xml_mv.vsinterf, sqlerrm);
*/
   END;
END pac_xml;

/

  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "PROGRAMADORESCSI";
