--------------------------------------------------------
--  DDL for Function F_ABREV_TIDENTI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ABREV_TIDENTI" ( psperson NUMBER, pcidioma NUMBER)
   RETURN VARCHAR2 IS

  /*CVALOR=672 Valor fijo para el campo de identificación
  Si no son los valores identificados, devuelve el asignado en detvalores
  03/08/2005 MCA  */
  vtidenti		VARCHAR2(60);
BEGIN
   SELECT DECODE(tidenti,1,'NIF',2,'CIF',3,'PAS',4,'TRE',6,'FNA',
      (select tatribu from detvalores
	   where cvalor=672 and cidioma=pcidioma and catribu=p.tidenti))
   INTO vtidenti
   FROM personas p
   WHERE p.sperson = psperson;

   RETURN vtidenti;

EXCEPTION
  WHEN OTHERS THEN
      RETURN NULL;
END f_abrev_tidenti;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ABREV_TIDENTI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ABREV_TIDENTI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ABREV_TIDENTI" TO "PROGRAMADORESCSI";
