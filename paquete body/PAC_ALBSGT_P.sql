--------------------------------------------------------
--  DDL for Package Body PAC_ALBSGT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBSGT_P" IS
/****************************************************************************

   NOMBRE:       PAC_ALBSGT_P
   PROPÓSITO:  Cuerpo del paquete de las funciones para
             el cáculo de las preguntas relacionadas con
             productos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0         28/04/2009   DCT             1. Modificar f_pargaranpro
****************************************************************************/
   FUNCTION f_continente_contenido(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      psseguro2 IN NUMBER,
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

      --BUG 9783 - 29/04/2009 - DCT - Modificar cactivi por pac_seguros.ff_get_actividad(psseguro, pnriesgo)

      FOR registro IN (SELECT icapital, cgarant
                         FROM garanseg
                        WHERE sseguro = psseguro
                          AND ffinefe IS NULL
                          AND nriesgo = pnriesgo) LOOP
         error := f_pargaranpro(ramo, modali, tipseg, colect,
                                pac_seguros.ff_get_actividad(psseguro, pnriesgo),
                                registro.cgarant, 'TIPO', valor_tipo);

      --FI BUG 9783 - 29/04/2009 - DCT

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
END pac_albsgt_p;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_P" TO "PROGRAMADORESCSI";
