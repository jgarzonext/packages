--------------------------------------------------------
--  DDL for Package Body PAC_LIMITES_AHORRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_LIMITES_AHORRO" AS
/******************************************************************************
   NOMBRE:      PAC_LIMITES_AHORRO
   PROPÓSITO:   Funciones para calcular los limites de aportaciones para PIAS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0          xxx          xxx           1. Creación del package.
   2.0        08/05/2009     APD           2. Bug 9922: se añade el parametro porigen a las
                                              funciones:
                                              . ff_calcula_importe
                                              . ff_importe_por_aportar_persona
                                              . f_aportaciones_limite
                                             Si porigen = 1 utilizar tablas EST, si porigen = 2,
                                             utilizar tablas REALES
   3.0       30/07/2009      RSC           3. Detalle de garantía (Tarificación)
                                              Pasamos de >= a > ya que la select anterior causaba TOO_MANY_ROWS.
   4.0       18/02/2010      RSC           4 0017707: CEM800 - 2010: Modelo 345
   5.0       20/11/2013      AGG           5.0028906: CALI800-Parametrizar producto PIAS para poder gestionar traspasos
   5.0       21/11/2013      AGG           5.0028906: CALI800-Parametrizar producto PIAS para poder gestionar traspasos
******************************************************************************/

   -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
   -- Pasamos de >= a > ya que la select anterior causaba TOO_MANY_ROWS.
   FUNCTION ff_iaporttotal(pctiplim IN NUMBER, pdatainici IN DATE)
      RETURN NUMBER IS
      vaporttotal    limites_ahorro.iaporttotal%TYPE;
   BEGIN
      SELECT iaporttotal
        INTO vaporttotal
        FROM limites_ahorro
       WHERE ctiplim = pctiplim
         AND finici <= TRUNC(pdatainici)
         AND(ffin > TRUNC(pdatainici)
             -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
             OR ffin IS NULL);

      RETURN vaporttotal;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.ff_iaporttotal', 0, SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END ff_iaporttotal;

   -- Fin Bug 10350

   -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
   -- Pasamos de >= a > ya que la select anterior causaba TOO_MANY_ROWS.
   FUNCTION ff_iaportanual(pctiplim IN NUMBER, pdatainici IN DATE)
      RETURN NUMBER IS
      vaportanual    limites_ahorro.iaportanual%TYPE;
   BEGIN
      /***********************************************************************
        RSC 30/01/2008
        CREACIÓN FUNCIÓN QUE DEVUELVE LA APORTACIÓN ANUAL PASANDOLE COMO PARAMETROS
        EL TIPO Y LA FECHA DE INICIO
      ***********************************************************************/
      SELECT iaportanual
        INTO vaportanual
        FROM limites_ahorro
       WHERE ctiplim = pctiplim
         AND finici <= TRUNC(pdatainici)
         AND(ffin > TRUNC(pdatainici)
             -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
             OR ffin IS NULL);

      RETURN vaportanual;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.FF_IAPORTANUAL', 0, SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END ff_iaportanual;

   -- Fin Bug 10350

   -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
   -- Pasamos de >= a > ya que la select anterior causaba TOO_MANY_ROWS.
   FUNCTION ff_limite_polizas(pctiplin IN NUMBER, datainici IN DATE)
      RETURN NUMBER IS
      /***********************************************************************
        FUNCIÓN QUE DEVUELVE EL LÍMITE DE CONTRATACIÓN DE PÓLIZAS
        PASÁNDOLE COMO PARÁMETROS EL LÍMITE Y LA FECHA DE INICIO
      ***********************************************************************/
      v_max          limites_ahorro.nmaxpol%TYPE;
   BEGIN
      SELECT nmaxpol
        INTO v_max
        FROM limites_ahorro
       WHERE ctiplim = pctiplin
         AND finici <= TRUNC(datainici)
         AND(ffin > TRUNC(datainici)
             -- Bug 10350 - RSC - 30/07/2009 - Detalle de garantía (Tarificación)
             OR ffin IS NULL);

      RETURN v_max;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.FF_LIMITE_POLIZAS', 0, SQLCODE,
                     SQLERRM);
         RETURN NULL;
   END;

   -- Fin Bug 10350

   -- RSC 30/01/2008
   -- Form aladm411.fmb --> Aport. acumuladas
   FUNCTION ff_calcula_importe(
      pctiplim IN NUMBER,
      psperson IN NUMBER,
      pany IN NUMBER DEFAULT NULL,
      porigen IN NUMBER DEFAULT 2,
      -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
      pmodo IN NUMBER DEFAULT 1)
      -- Bug 17707 - RSC - 18/02/2010 - CEM800 - 2010: Modelo 345
   RETURN NUMBER IS
      impctaseguro   NUMBER(25, 10);
   BEGIN
      IF pany IS NULL THEN
         -- *** Bucamos el total de los movimientos realizados de todos las pólizas
         --    de esa persona para todos los años aportados
         -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen. Si porigen = 1 utilizar
         -- tablas EST, si porigen = 2, utilizar tablas REALES
         IF porigen = 1 THEN   -- tablas EST
            SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi, 51, -imovimi, 56, imovimi
                                                                                            --Traspaso (aportaciones realizadas en la entidad externa)
                           ), 0))
              INTO impctaseguro
              FROM estriesgos, ctaseguro, estseguros, productos
             WHERE ctaseguro.sseguro = estriesgos.sseguro
               AND estriesgos.sperson = psperson
               AND estseguros.sproduc = productos.sproduc
               AND estseguros.sseguro = estriesgos.sseguro
               AND NVL(f_parproductos_v(estseguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
               AND estseguros.csituac = 0;
         ELSE   -- tablas REALES
            SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi, 51, -imovimi, 56, imovimi
                                                                                            --Traspaso (aportaciones realizadas en la entidad externa)
                           ), 0))
              INTO impctaseguro
              FROM riesgos, ctaseguro, seguros, productos
             WHERE ctaseguro.sseguro = riesgos.sseguro
               AND riesgos.sperson = psperson
               AND seguros.sproduc = productos.sproduc
               AND seguros.sseguro = riesgos.sseguro
               AND NVL(f_parproductos_v(seguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
               AND seguros.csituac = 0;
         END IF;
      -- Bug 9922 - APD - 08/05/2009 - fin
      ELSE
         -- *** Bucamos el total de los movimientos realizados este año
         -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen. Si porigen = 1 utilizar
         -- tablas EST, si porigen = 2, utilizar tablas REALES
         IF porigen = 1 THEN   -- tablas EST
            IF pmodo = 1 THEN
               SELECT SUM(NVL(DECODE(cmovimi,
                                     1, imovimi,
                                     2, imovimi,
                                     --49,-IMOVIMI,
                                     51, -imovimi,
                                     56, imovimi
                                                --Traspaso (aportaciones realizadas en la entidad externa)
                                    ),
                              0))
                 INTO impctaseguro
                 FROM estriesgos, ctaseguro, estseguros, productos
                WHERE ctaseguro.sseguro = estriesgos.sseguro
                  AND estriesgos.sperson = psperson
                  AND estseguros.sproduc = productos.sproduc
                  AND estseguros.sseguro = estriesgos.sseguro
                  AND NVL(f_parproductos_v(estseguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                  AND TO_DATE(TO_CHAR(pany, '9999'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
                  AND estseguros.csituac = 0;
            ELSE
               SELECT SUM(NVL(DECODE(cmovimi,
                                     1, imovimi,
                                     2, imovimi,
                                     --49,-IMOVIMI,
                                     51, -imovimi,
                                     56, imovimi
                                                --Traspaso (aportaciones realizadas en la entidad externa)
                                    ),
                              0))
                 INTO impctaseguro
                 FROM estriesgos, ctaseguro, estseguros, productos
                WHERE ctaseguro.sseguro = estriesgos.sseguro
                  AND estriesgos.sperson = psperson
                  AND estseguros.sproduc = productos.sproduc
                  AND estseguros.sseguro = estriesgos.sseguro
                  AND NVL(f_parproductos_v(estseguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                  AND TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY') <=
                                                         TO_DATE(TO_CHAR(pany, '9999'), 'YYYY')
                  AND estseguros.csituac = 0;
            END IF;
         ELSE   -- tablas REALES
            IF pmodo = 1 THEN
               SELECT SUM(NVL(DECODE(cmovimi,
                                     1, imovimi,
                                     2, imovimi,
                                     --49,-IMOVIMI,
                                     51, -imovimi,
                                     56, imovimi
                                                --Traspaso (aportaciones realizadas en la entidad externa)
                                    ),
                              0))
                 INTO impctaseguro
                 FROM riesgos, ctaseguro, seguros, productos
                WHERE ctaseguro.sseguro = riesgos.sseguro
                  AND riesgos.sperson = psperson
                  AND seguros.sproduc = productos.sproduc
                  AND seguros.sseguro = riesgos.sseguro
                  AND NVL(f_parproductos_v(seguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                  AND TO_DATE(TO_CHAR(pany, '9999'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
                  AND seguros.csituac = 0;
            ELSE
               SELECT SUM(NVL(DECODE(cmovimi,
                                     1, imovimi,
                                     2, imovimi,
                                     --49,-IMOVIMI,
                                     51, -imovimi,
                                     56, imovimi
                                                --Traspaso (aportaciones realizadas en la entidad externa)
                                    ),
                              0))
                 INTO impctaseguro
                 FROM riesgos, ctaseguro, seguros, productos
                WHERE ctaseguro.sseguro = riesgos.sseguro
                  AND riesgos.sperson = psperson
                  AND seguros.sproduc = productos.sproduc
                  AND seguros.sseguro = riesgos.sseguro
                  AND NVL(f_parproductos_v(seguros.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                  AND TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY') <=
                                                         TO_DATE(TO_CHAR(pany, '9999'), 'YYYY')
                  AND seguros.csituac = 0;
            END IF;
         END IF;
      -- Bug 9922 - APD - 08/05/2009 - fin
      END IF;

      RETURN impctaseguro;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.ff_calcula_importe', 1,
                     'pctiplim = ' || pctiplim || 'psperson = ' || psperson || ' pany = '
                     || pany,
                     SQLERRM);
         RETURN NULL;
   END ff_calcula_importe;

   /***************************************************************************************
   -- Para alta de pólizas:
   --    PAC_REF_CONTRATA_AHO.f_valida_garantias_aho -->
   --    PAC_VAL_COMU.f_valida_capital_persona -->
   --    PAC_LIMITES_AHORRO.ff_importe_por_aportar_persona
     Esta función retorna el importe pendiente al igual que ff_iaportpendientes del mismo package
     con una diferencia, teniendo en cuenta el picapital. Esta función se utilizaria en el contexto
     de un alta de póliza de PIAS o una aportación extraordinaria. Mientras de la función
     ff_iaportpendientes nos será valida para saber directamente lo que la persona puede aportar
     lo que tiene "Pendiente".
   ****************************************************************************************/
   FUNCTION ff_importe_por_aportar_persona(
      pany IN NUMBER,
      pctiplim IN NUMBER,
      psperson IN NUMBER,
      pfefecto IN DATE,
      porigen IN NUMBER DEFAULT 2)
      -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
   RETURN NUMBER IS
      vlimatotal     NUMBER;
      vlimaanual     NUMBER;
      vacumanual     NUMBER;
      vacumtotal     NUMBER;
      vpendienteanual NUMBER;
      vpendientetotal NUMBER;
      resultat       NUMBER;
      seguro         NUMBER;
      vlimanualtraspaso NUMBER := 0;
      vperson        NUMBER;
      vseguros       NUMBER;
   BEGIN
      -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
      vacumanual := NVL(pac_limites_ahorro.ff_calcula_importe(pctiplim, psperson, pany,
                                                              porigen),
                        0);
      vacumtotal := NVL(pac_limites_ahorro.ff_calcula_importe(pctiplim, psperson, NULL,
                                                              porigen),
                        0);
      -- Bug 9922 - APD - 08/05/2009 - fin
      vlimatotal := NVL(pac_limites_ahorro.ff_iaporttotal(pctiplim, pfefecto), 0);
      vlimaanual := NVL(pac_limites_ahorro.ff_iaportanual(pctiplim, pfefecto), 0);

      --21/11/2013 AGG Bug: 0028906 Se añade la comprobaciónde aportación anual de traspasos
      SELECT COUNT(1)
        INTO vperson
        FROM personas
       WHERE sperson = psperson;

      --Si existe la persona
      IF (vperson > 0) THEN
         SELECT COUNT(1)
           INTO vseguros
           FROM riesgos
          WHERE sperson = psperson
            AND ROWNUM = 1;

         --Si tiene alguna póliza contratada
         IF (vseguros > 0) THEN
            SELECT sseguro
              INTO seguro
              FROM riesgos
             WHERE sperson = psperson
               AND ROWNUM = 1;

            vlimanualtraspaso := NVL(pac_ppa_planes.calcula_importe_anual_persona(pany, 1,
                                                                                  seguro, 1,
                                                                                  psperson),
                                     0);
         END IF;
      END IF;

      vpendienteanual := vlimaanual -(vacumanual + vlimanualtraspaso);
      vpendientetotal := vlimatotal - vacumtotal;

      SELECT LEAST(vpendienteanual, vpendientetotal)
        INTO resultat
        FROM DUAL;

      RETURN(resultat);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.ff_importe_por_aportar_persona',
                     1,
                     'pany = ' || pany || 'pctiplim = ' || pctiplim || 'psperson = '
                     || psperson || 'pfefecto = ' || pfefecto || ' pany = ' || pany,
                     SQLERRM);
         RETURN NULL;
   END ff_importe_por_aportar_persona;

   -- RSC 31/01/2008 (función equivalente a PAC_TFV.f_cumulos_pp)
   FUNCTION f_aportaciones_limite(
      pctiplim IN NUMBER,
      psseguro IN seguros.sseguro%TYPE,
      psperson IN per_personas.sperson%TYPE,
      pcidioma IN idiomas.cidioma%TYPE,
      ocoderror OUT literales.slitera%TYPE,
      omsgerror OUT literales.tlitera%TYPE,
      porigen IN NUMBER DEFAULT 2)
      -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen
   RETURN ct_datos_pias IS
      v_cursor       ct_datos_pias;
   BEGIN
      -- Bug 9922 - APD - 08/05/2009 - se añade el parametro porigen. Si porigen = 1 utilizar
      -- tablas EST, si porigen = 2, utilizar tablas REALES
      IF porigen = 1 THEN   -- tablas EST
         OPEN v_cursor FOR
            SELECT   --DECODE (ntipo,
                     --        1, 'APORT.PIAS',
                     --) tatribu
                   d.tatribu, nseguros,
                   NVL
                      (pac_limites_ahorro.ff_calcula_importe
                                                   (pctiplim, sperson,
                                                    TO_NUMBER(TO_CHAR(f_sysdate,
                                                                      'YYYY')),
                                                    porigen),
                       0) aportanual,
                   NVL(pac_limites_ahorro.ff_calcula_importe(pctiplim, sperson,
                                                             NULL, porigen),
                       0) aporttotal,
                   NVL(pac_limites_ahorro.ff_iaportanual(pctiplim, f_sysdate), 0) imaxanual,
                   NVL(pac_limites_ahorro.ff_iaporttotal(pctiplim, f_sysdate), 0) imaxtotal
              FROM (SELECT   t.sperson, COUNT(*) nseguros
                        FROM estseguros s, esttomadores t
                       WHERE NVL(f_parproductos_v(s.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                         AND s.sseguro = t.sseguro
                         AND(s.sseguro = psseguro
                             OR psseguro IS NULL)
                         AND(t.sperson = psperson
                             OR psperson IS NULL)
                    GROUP BY t.sperson) x,
                   detvalores d
             WHERE d.cvalor = 280   -- Valor Fijo
               AND d.cidioma = pcidioma
               AND d.catribu = pctiplim;
      ELSE   -- tablas REALES
         OPEN v_cursor FOR
            SELECT   --DECODE (ntipo,
                     --        1, 'APORT.PIAS',
                     --) tatribu
                   d.tatribu, nseguros,
                   NVL
                      (pac_limites_ahorro.ff_calcula_importe
                                                   (pctiplim, sperson,
                                                    TO_NUMBER(TO_CHAR(f_sysdate,
                                                                      'YYYY')),
                                                    porigen),
                       0) aportanual,
                   NVL(pac_limites_ahorro.ff_calcula_importe(pctiplim, sperson,
                                                             NULL, porigen),
                       0) aporttotal,
                   NVL(pac_limites_ahorro.ff_iaportanual(pctiplim, f_sysdate), 0) imaxanual,
                   NVL(pac_limites_ahorro.ff_iaporttotal(pctiplim, f_sysdate), 0) imaxtotal
              FROM (SELECT   t.sperson, COUNT(*) nseguros
                        FROM seguros s, tomadores t
                       WHERE NVL(f_parproductos_v(s.sproduc, 'TIPO_LIMITE'), 0) = pctiplim
                         AND s.sseguro = t.sseguro
                         AND(s.sseguro = psseguro
                             OR psseguro IS NULL)
                         AND(t.sperson = psperson
                             OR psperson IS NULL)
                    GROUP BY t.sperson) x,
                   detvalores d
             WHERE d.cvalor = 280   -- Valor Fijo
               AND d.cidioma = pcidioma
               AND d.catribu = pctiplim;
      END IF;

      -- Bug 9922 - APD - 08/05/2009 - fin
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 103212;
         omsgerror := f_axis_literales(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'PAC_LIMITES_AHORRO.f_aportaciones_limite', 1,
                     'psseguro=' || psseguro || ' psperson= ' || psperson || ' pcidioma='
                     || pcidioma,
                     SQLERRM);

         CLOSE v_cursor;

         RETURN v_cursor;
   END f_aportaciones_limite;
END pac_limites_ahorro;

/

  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_LIMITES_AHORRO" TO "PROGRAMADORESCSI";
