--------------------------------------------------------
--  DDL for Package PKLIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PKLIT" authid current_user IS
/***************************************************************************
	PKLIT: Especificación del paquete que gestiona los literales.

***************************************************************************/
  TYPE lit IS RECORD (nlit NUMBER, mlit VARCHAR2(100), cidi NUMBER);
  TYPE tlit IS TABLE OF lit INDEX BY BINARY_INTEGER;
  lit1 lit;
  lits tlit;
  leido NUMBER := 0;
  idx NUMBER :=0;
  PROCEDURE lee_lits;
  PROCEDURE print_lits;
  FUNCTION get_lits RETURN tlit;
  FUNCTION leer_idx RETURN NUMBER;
  FUNCTION leer_leido RETURN NUMBER;
  FUNCTION leer_lit (indice IN NUMBER) RETURN NUMBER;
  FUNCTION leer_texlit (indice IN NUMBER) RETURN VARCHAR2;
  FUNCTION leer_idioma (indice IN NUMBER) RETURN VARCHAR2;
END pklit;
 
 

/

  GRANT EXECUTE ON "AXIS"."PKLIT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PKLIT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PKLIT" TO "PROGRAMADORESCSI";
