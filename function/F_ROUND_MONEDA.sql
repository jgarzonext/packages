--------------------------------------------------------
--  DDL for Function F_ROUND_MONEDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ROUND_MONEDA" (
   pnimport IN NUMBER,
   pcmoneda IN eco_codmonedas.cmoneda%TYPE DEFAULT pac_eco_monedas.f_obtener_moneda_defecto)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_ROUND_MONEDA: Redondeamos el importe pasado segun la moneda. En caso de no
            pasar moneda se usará la de la instalación.
***********************************************************************/
BEGIN
   RETURN ROUND(pnimport, NVL(pac_eco_monedas.f_decimales(pcmoneda), 0));
END f_round_moneda;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_ROUND_MONEDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ROUND_MONEDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ROUND_MONEDA" TO "PROGRAMADORESCSI";
