--------------------------------------------------------
--  DDL for Package PK_FORMULAS_AUX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FORMULAS_AUX" authid current_user IS
  TYPE terr IS TABLE OF VARCHAR2(50) INDEX BY BINARY_INTEGER;
  nsesion    NUMBER := 0;
  terrs      terr;
  errs       NUMBER := 1;
  q          NUMBER;
  nid        NUMBER;
  i_global   NUMBER;
  sinonim    VARCHAR2(30);
  FUNCTION search_string(s         IN OUT VARCHAR2,
                         modo      IN VARCHAR2,
                         numsesion IN NUMBER
                        )
    RETURN NUMBER;
  FUNCTION analiz_token(token IN VARCHAR2, numsesion IN NUMBER)
    RETURN NUMBER;
  FUNCTION eval (formula  IN OUT VARCHAR2, numsesion IN NUMBER)
    RETURN NUMBER;
  PROCEDURE verifica_token(token IN VARCHAR2);
  FUNCTION get_terrs(nerr IN NUMBER)
    RETURN VARCHAR2;
--  PROCEDURE print_toks;
END pk_formulas_aux;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_AUX" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_AUX" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_AUX" TO "PROGRAMADORESCSI";
