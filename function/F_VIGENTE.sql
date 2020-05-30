--------------------------------------------------------
--  DDL for Function F_VIGENTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VIGENTE" (psseguro IN NUMBER, pnpoliza IN NUMBER, pfecha IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   NOMBRE:       F_VIGENTE
   PROPÓSITO:    Comprueba que un seguro esté vigente en una fecha
                 determinada.Se puede entrar por sseguro o por póliza

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació de la funció
   2.0        19/10/2009   FAL              0011497: CRE - Optimizar el cierre de provisiones. Optimitzar select per comprobar si vigent
   3.0        23/05/2012   DRA              0021927: MDP - TEC - Parametrización producto de Hogar (MHG) - Nueva producción
   4.0        25/06/2013   RCL     			0024697: Canvi mida camp sseguro
****************************************************************************/

   /****************************************************************************
      F_VIGENTE : Comprueba que un seguro esté vigente en una fecha
            determinada.Se puede entrar por sseguro o por póliza
      ALLIBCTR
   Se añade la condicion  MOVSEGURO.fcontab is not null
   Miramos si la fecha es mayor que la de vencimiento
   Tenim en compte les regularitzacions
   ****************************************************************************/
   v_sseguro      NUMBER;
   seguro         NUMBER;
   vencim         DATE;
BEGIN
   IF psseguro IS NULL
      AND pnpoliza IS NOT NULL THEN
      SELECT sseguro
        INTO v_sseguro
        FROM seguros
       WHERE npoliza = pnpoliza;
   ELSIF psseguro IS NOT NULL
         AND pnpoliza IS NULL THEN
      v_sseguro := psseguro;
   ELSIF psseguro IS NOT NULL
         AND pnpoliza IS NOT NULL THEN
      RETURN 101901;
   END IF;

   SELECT fvencim
     INTO vencim
     FROM seguros
    WHERE sseguro = v_sseguro;

   IF pfecha > vencim THEN
      RETURN 101484;   --La póliza ya ha vencido
   END IF;

   -- BUG 11497 - 19/10/2009 - FAL - 0011497: CRE - Optimizar el cierre de provisiones. Optimitzar select per comprobar si vigent
   SELECT m2.cmovseg
     INTO seguro
     FROM movseguro m2
    WHERE m2.sseguro = v_sseguro
      AND m2.nmovimi IN(SELECT MAX(m1.nmovimi)
                          FROM movseguro m1
                         WHERE m1.sseguro = m2.sseguro
                           AND m1.fefecto <= pfecha
                           AND m1.cmovseg NOT IN(6, 52))
      AND m2.cmovseg <> 3
      AND DECODE(m2.femisio, NULL, m2.cmovseg, 1) <> 0;

   -- Fi BUG 11497 - 19/10/2009 - FAL
   RETURN 0;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 102607;   ---Esta póliza no está vigente
END f_vigente;

/

  GRANT EXECUTE ON "AXIS"."F_VIGENTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VIGENTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VIGENTE" TO "PROGRAMADORESCSI";
