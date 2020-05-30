--------------------------------------------------------
--  DDL for Package PK_FORMULAS_ALB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_FORMULAS_ALB" authid current_user IS
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
END pk_formulas_alb;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_FORMULAS_ALB" TO "PROGRAMADORESCSI";
