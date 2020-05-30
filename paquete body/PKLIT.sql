--------------------------------------------------------
--  DDL for Package Body PKLIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PKLIT" IS
/***************************************************************************
	PKLIT: Cuerpo del paquete que gestiona los literales.
***************************************************************************/
    PROCEDURE lee_lits IS
  CURSOR lites IS
     SELECT slitera, tlitera, cidioma
       FROM LITERALES
	 WHERE length(tlitera) < 21
       order by slitera, cidioma;
BEGIN
  FOR lite IN lites
  LOOP
    idx := idx + 1;
    lit1.nlit := lite.slitera;
    lit1.mlit := lite.tlitera;
    lit1.cidi := lite.cidioma;
    lits(idx) := lit1;
  END LOOP;
  leido := 1;
  EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
END lee_lits;
PROCEDURE print_lits
 IS
BEGIN
  FOR i IN 1..100
  LOOP
    lit1 := lits(i);
    dbms_output.put_line(TO_CHAR(lit1.nlit)||'='||lit1.mlit);
  END LOOP;
END print_lits;
FUNCTION get_lits
 RETURN tlit
   IS
BEGIN
  RETURN lits;
END get_lits;
  FUNCTION leer_idx RETURN NUMBER IS
  BEGIN
	RETURN idx;
  END leer_idx;
  FUNCTION leer_leido RETURN NUMBER IS
  BEGIN
	RETURN leido;
  END leer_leido;
  FUNCTION leer_lit (indice IN NUMBER) RETURN NUMBER IS
  BEGIN
	RETURN lits(indice).nlit;
  END leer_lit;
  FUNCTION leer_texlit (indice IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
	RETURN lits(indice).mlit;
  END leer_texlit;
  FUNCTION leer_idioma (indice IN NUMBER) RETURN VARCHAR2 IS
  BEGIN
	RETURN lits(indice).cidi;
  END leer_idioma;
END pklit;

/

  GRANT EXECUTE ON "AXIS"."PKLIT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PKLIT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PKLIT" TO "PROGRAMADORESCSI";
