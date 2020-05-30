--------------------------------------------------------
--  DDL for Package Body PAC_ALBSGT_CS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBSGT_CS" IS
/***************************************************************
    PAC_ALBSGT_cs: Cuerpo del paquete de las funciones para
        el cáculo de las preguntas relacionadas con
        productos
   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -           -             Creación del package.
   2.0        17/04/2009   APD             Bug 9685 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
****************************************************************************/
   FUNCTION f_continente_contenido(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER IS
      ramo           NUMBER;
      modali         NUMBER;
      tipseg         NUMBER;
      colect         NUMBER;
      error          NUMBER;
      valor_tipo     NUMBER;
      importe        NUMBER;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO ramo, modali, tipseg, colect
        FROM seguros
       WHERE seguros.sseguro = psseguro;

      FOR registro IN (SELECT icapital, cgarant
                         FROM garanseg
                        WHERE sseguro = psseguro
                          AND ffinefe IS NULL
                          AND nriesgo = pnriesgo) LOOP
     -- Bug 9685 - APD - 17/04/2009 - en lugar de coger la acticad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
--     error := f_pargaranpro( ramo, modali, tipseg, colect, NULL, REGISTRO.CGARANT ,'TIPO',VALOR_TIPO );
         error := f_pargaranpro(ramo, modali, tipseg, colect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo),
                                registro.cgarant, 'TIPO', valor_tipo);

         -- Bug 9685 - APD - 17/04/2009 - Fin
         IF error = 0
            AND valor_tipo = ptipo THEN
            importe := NVL(importe, 0) + registro.icapital;
         END IF;
      END LOOP;

      RETURN(NVL(importe, 0));
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_continente_contenido;

   FUNCTION f_capital_maquinaria(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      kapital        NUMBER;
   BEGIN
      SELECT icapital
        INTO kapital
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant = 102;

      RETURN kapital;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
      WHEN OTHERS THEN
         RETURN -1;
   END f_capital_maquinaria;

   FUNCTION f_responsabilidad_civil(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      RESULT         NUMBER;
   BEGIN
/******************
select crespue into Result
from pregunseg
where sseguro=psseguro
  and nriesgo=pnriesgo
  and cpregun=1012;
******************/
      SELECT 0
        INTO RESULT
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cgarant IN(103, 104);

      RETURN RESULT;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 1;   -- No hay contratada garantía de RC
      WHEN TOO_MANY_ROWS THEN
         RETURN 0;   -- Están cotratadas las dos garantías de RC
      WHEN OTHERS THEN
         RETURN -1;
   END f_responsabilidad_civil;

   FUNCTION f_dias_obra(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      data_inici     NUMBER;
      data_efecto    DATE;
      dias           NUMBER;
   BEGIN
      SELECT crespue
        INTO data_inici
        FROM pregunseg
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo
         AND cpregun = 1009;

      SELECT fefecto
        INTO data_efecto
        FROM seguros
       WHERE sseguro = psseguro;

      data_efecto := TO_DATE(TO_NUMBER(TO_CHAR(data_efecto, 'YYYYMMDD')), 'YYYYMMDD');
      dias := TO_DATE(data_inici, 'YYYYMMDD') - data_efecto;
      RETURN dias;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_dias_obra;

   FUNCTION f_tipo_obra(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER IS
      xcactivi       NUMBER;
   BEGIN
      SELECT cactivi
        INTO xcactivi
        FROM seguros
       WHERE sseguro = psseguro;

      RETURN xcactivi;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_tipo_obra;
END pac_albsgt_cs;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_CS" TO "PROGRAMADORESCSI";
