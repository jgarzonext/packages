--------------------------------------------------------
--  DDL for Package PK_FORMULAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FORMULAS" AUTHID CURRENT_USER IS
   TYPE t_parametros IS TABLE OF VARCHAR2(4000)
      INDEX BY VARCHAR2(30);

   TYPE t_sesiones IS TABLE OF t_parametros
      INDEX BY BINARY_INTEGER;

   v_tokens       t_sesiones;

   TYPE terr IS TABLE OF VARCHAR2(50)
      INDEX BY BINARY_INTEGER;

   nsesion        NUMBER := 0;
   terrs          terr;
   errs           NUMBER := 1;
   q              NUMBER;
   nid            NUMBER;
   i_global       NUMBER;
   sinonim        VARCHAR2(30);

   FUNCTION search_string(
      s IN OUT VARCHAR2,
      modo IN VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION analiz_token(
      token IN VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION eval(
      formula IN OUT VARCHAR2,
      numsesion IN NUMBER,
      numsesion_1 IN NUMBER DEFAULT NULL,
      praiz IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   PROCEDURE verifica_token(token IN VARCHAR2);

   FUNCTION get_terrs(nerr IN NUMBER)
      RETURN VARCHAR2;
--  PROCEDURE print_toks;
END pk_formulas;

/

  GRANT EXECUTE ON "AXIS"."PK_FORMULAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS" TO "PROGRAMADORESCSI";
