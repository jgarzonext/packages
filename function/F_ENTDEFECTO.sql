--------------------------------------------------------
--  DDL for Function F_ENTDEFECTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ENTDEFECTO" (PCEMPRES IN NUMBER, PCDELEGA IN NUMBER,
                       PAGRUPACION IN NUMBER,PENTIDAD OUT NUMBER) RETURN NUMBER
authid current_user IS
--
-- FUNCION DE ALLIBADM
-- CML. DEVUELVE LA ENTIDAD POR DEFECTO PARA UNA EMPRESA,DELEGACION, AGRUPACION.
--
BEGIN
  BEGIN
    SELECT CENTIDA
      INTO PENTIDAD
      FROM CTACARGO
     WHERE CEMPRES = PCEMPRES
       AND CDELEGA = PCDELEGA
       AND CAGRPRO = PAGRUPACION
       AND FVIGFIN IS NULL
       AND CDEFECT = 1;
  EXCEPTION
    WHEN TOO_MANY_ROWS THEN
      RETURN 105880;       -- HAY MAS DE UNA CTA POR DEFECTO
    WHEN NO_DATA_FOUND THEN
	RETURN 105881;       -- NO HAY CTA POR DEFECTO
    WHEN OTHERS THEN
	RETURN 105493;       -- ERROR AL LLEGIR DE LA TAULA
  END;
  RETURN 0;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ENTDEFECTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ENTDEFECTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ENTDEFECTO" TO "PROGRAMADORESCSI";
