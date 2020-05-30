--------------------------------------------------------
--  DDL for Function F_CALRETPAGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALRETPAGO" (psperson IN NUMBER, piconret IN NUMBER,
ppretenc IN OUT NUMBER, piretenc IN OUT NUMBER, pimpiva IN OUT NUMBER
, pactivi IN NUMBER, pfordpag IN DATE DEFAULT sysdate)
/************************************************************************
 F_calretpago
  Añadimos la fecha del pago y tenemos en cuenta la base
  imponible.
  Devolvemos el porcentaje de IVA i no el importe
  Necesitamos la actividad profesional
*************************************************************************/
RETURN NUMBER authid current_user IS
 num_err NUMBER := 0;
-- pfordpag  DATE := sysdate;
BEGIN
 BEGIN
     SELECT  t.ptipiva
     INTO pimpiva
     FROM TIPOIVA t, PROFESIONALES s
     WHERE t.finivig <= pfordpag
  AND (t.ffinvig > pfordpag OR t.ffinvig IS NULL)
  AND t.ctipiva = s.ctipiva
  AND (s.cactpro = pactivi OR pactivi IS NULL)
  AND s.sperson = psperson;
 EXCEPTION
     WHEN others THEN
  num_err := 101527;
  pimpiva := null;
 END;
 BEGIN
     SELECT  r.pretenc, r.pretenc * piconret
     INTO ppretenc, piretenc
     FROM RETENCIONES r, PROFESIONALES s
     WHERE r.finivig <= pfordpag
  AND (r.ffinvig > pfordpag OR r.ffinvig IS NULL)
  AND r.cretenc = s.cretenc
  AND (s.cactpro = pactivi OR pactivi IS NULL)
  AND s.sperson = psperson;
 EXCEPTION
     WHEN others THEN
  num_err := 101524;
 END;
 return (num_err);
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CALRETPAGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALRETPAGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALRETPAGO" TO "PROGRAMADORESCSI";
