--------------------------------------------------------
--  DDL for Package PAC_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_XML" IS
   FUNCTION hostb2b(p_empresa IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE parsear(p_clob IN CLOB, p_parser IN OUT xmlparser.parser);

   PROCEDURE finalizar_parser(v_parser IN OUT xmlparser.parser);

   PROCEDURE anadirnodotexto(
      p_doc xmldom.domdocument,
      p_node xmldom.domnode,
      p_tag IN VARCHAR2,
      p_texto IN VARCHAR2);

   FUNCTION buscarnodotexto(p_doc xmldom.domdocument, p_tag IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION tratarerror(
      p_doc xmldom.domdocument,
      p_nrosecuencia NUMBER,
      p_terror IN OUT VARCHAR2)
      RETURN NUMBER;

   PROCEDURE peticion_host(
      p_url IN VARCHAR2,
      p_tipoint IN VARCHAR2,
      p_msg IN VARCHAR2,
      p_parser IN OUT xmlparser.parser);

   -------------------------------------------------------------
-- Este procedimiento realiza la petición al host y te devuelve el resultado en
-- un objeto de tipo xmlparser.parser el cual monta una estructura DOM del resultado
   PROCEDURE peticion_host_codigos(
      p_url IN VARCHAR2,
      p_timeout IN NUMBER,
      p_msg IN VARCHAR2,
      p_parser IN OUT xmlparser.parser);
END pac_xml;

/

  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_XML" TO "PROGRAMADORESCSI";
