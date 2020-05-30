--------------------------------------------------------
--  DDL for Function F_PPABIERTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PPABIERTO" (
   p_sseguro IN NUMBER DEFAULT NULL,
   p_codpla IN NUMBER DEFAULT NULL,
   p_fecha IN DATE)
   RETURN VARCHAR2 IS
   -- JAMR - 03/2004
   -- Función de planes de pensiones que en función del seguro o el código del plan
   -- de pensiones y a una fecha determinada devuelve una 'A'  si el plan se encuentra
   -- abierto o una 'C' si está cerrado y una 'X' si no existe valor liquidativo para ese día
   -- y ese plan o contrato.
   --estado         VARCHAR2(1);
   w_retorn       NUMBER;
   w_sproduc      seguros.sproduc%TYPE;
--
BEGIN
   -- 12442.NMM.31/12/2009.i.
   SELECT sproduc
     INTO w_sproduc
     FROM seguros
    WHERE sseguro = p_sseguro;

   w_retorn := pac_val_finv.f_valida_ulk_abierto(p_sseguro, w_sproduc, p_fecha);
   /*IF pcodpla IS NOT NULL THEN
      SELECT planestado.cestado
        INTO estado
        FROM planpensiones, planestado
       WHERE planpensiones.ccodpla = pcodpla
         AND planpensiones.ccodpla = planestado.ccodpla
         AND TRUNC(planestado.fvalora) = TRUNC(pfecha);
   ELSE
      SELECT planestado.cestado
        INTO estado
        FROM seguros, proplapen, planestado
       WHERE seguros.sseguro = psseguro
         AND seguros.sproduc = proplapen.sproduc
         AND proplapen.ccodpla = planestado.ccodpla
         AND TRUNC(planestado.fvalora) = TRUNC(pfecha);
   END IF;

   RETURN estado;*/
   RETURN(w_retorn);
-- 12442.NMM.31/12/2009.f.
EXCEPTION
   WHEN OTHERS THEN
      RETURN(140720);   -- Error a l'obtenir el codi de producte.
END f_ppabierto;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_PPABIERTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PPABIERTO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PPABIERTO" TO "PROGRAMADORESCSI";
