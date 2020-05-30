--------------------------------------------------------
--  DDL for Function F_CALCULA_PRIMA_DEV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALCULA_PRIMA_DEV" (psseguro  NUMBER,
                                               pcgarant  NUMBER,
                                               pfefecto  DATE,
                                               pnriesgo  NUMBER,
                                               pnmovimi  NUMBER,
                                               pxiprianu NUMBER,
                                               psproduc  NUMBER,
                                               perror    OUT NUMBER)
   RETURN NUMBER IS
   --
   /******************************************************************************
      NOMBRE:    pac_iax_contragarantias
      PROPÓSITO: Funciones para contragarantias

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        02/03/2016  JAE              1. Creaciónn del objeto.

   ******************************************************************************/
   --
   difiprianu    NUMBER;
   xxcgarant     NUMBER;
   xxnriesgo     NUMBER;
   xxfiniefe     DATE;
   xxiprianu     NUMBER;
   xxffinefe     DATE;
   xxidtocom     NUMBER;
   vexitegar     BOOLEAN;
   xxcageven_gar NUMBER;
   xxnmovima_gar NUMBER;
   xxcampanya    NUMBER;
   xnmovima      NUMBER;
   xnasegur      NUMBER;
   error         NUMBER := 0;
   xnmovimiant   NUMBER;
   vobj          VARCHAR2(200) := 'F_CALCULA_PRIMA_DEV ';
   vpas          NUMBER := 1;
   vpar          VARCHAR2(500) := SUBSTR('1=' || psseguro || ' 2= ' ||
                                         pcgarant || '3 =' || pfefecto || '4=' ||
                                         pnriesgo || '5=' || pnmovimi || '6=' ||
                                         pxiprianu || '7=' || psproduc,
                                         1,
                                         500);
BEGIN
   --

   error := f_buscanmovimi(psseguro, 1, 1, xnmovimiant);
   --
   BEGIN
      --
      xnasegur := NULL;
      --
      SELECT DECODE(nasegur, NULL, 1, nasegur),
             nmovima
        INTO xnasegur,
             xnmovima
        FROM riesgos
       WHERE sseguro = psseguro
         AND nriesgo = pnriesgo;
      --
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         RETURN 103836;
         --
      WHEN OTHERS THEN
         --
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 103509);
         --
         RETURN 103509;
         --
   END;
   --
   BEGIN
      --
      xxcgarant := NULL;
      xxnriesgo := NULL;
      xxfiniefe := NULL;
      xxiprianu := NULL;
      xxffinefe := NULL;
      xxidtocom := NULL;
      vexitegar := TRUE;
      --
      SELECT cgarant,
             nriesgo,
             finiefe,
             ipritot,
             ffinefe,
             idtocom,
             cageven,
             nmovima,
             ccampanya
        INTO xxcgarant,
             xxnriesgo,
             xxfiniefe,
             xxiprianu,
             xxffinefe,
             xxidtocom,
             xxcageven_gar,
             xxnmovima_gar,
             xxcampanya
        FROM garanseg
       WHERE sseguro = psseguro
         AND cgarant = pcgarant
         AND nriesgo = pnriesgo
         AND nmovimi = xnmovimiant;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         --
         vexitegar := FALSE;
         --
      WHEN TOO_MANY_ROWS THEN
         --
         error := 102310; -- Garantia-Risc repetida en GARANSEG
         --
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || error);
         RETURN error;
         --
      WHEN OTHERS THEN
         --
         error := 103500; -- Error al llegir de GARANSEG
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || error);
         RETURN error;
         --
   END;
   --
   IF NVL(f_parproductos_v(psproduc, 'PRIMA_VIG_AMPARO'), 0) = 0
   THEN
      --
      difiprianu := (pxiprianu * xnasegur) - NVL(xxiprianu * xnasegur, 0);
      --
   ELSE
      --
      difiprianu := f_prima_vig_amparo(psseguro,
                                       pcgarant,
                                       pfefecto,
                                       pnriesgo,
                                       xnmovimiant,
                                       pnmovimi,
                                       pxiprianu,
                                       xxiprianu,
                                       xnasegur,
                                       error);
      --
   END IF;
   --
   perror := 0;
   RETURN difiprianu;
   --
END f_calcula_prima_dev;

/

  GRANT EXECUTE ON "AXIS"."F_CALCULA_PRIMA_DEV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALCULA_PRIMA_DEV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALCULA_PRIMA_DEV" TO "PROGRAMADORESCSI";
