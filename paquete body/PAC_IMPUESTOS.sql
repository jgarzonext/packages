--------------------------------------------------------
--  DDL for Package Body PAC_IMPUESTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IMPUESTOS" IS
/******************************************************************************
   NOMBRE:     PAC_IMPUESTOS
   PROP¿SITO:  Funciones del modelo de impuestos

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        XX/XX/XXXX   XXX                1. Creaci¿n del package.
   1.1        30/01/2009   JTS                2. Se corrigen fallos.
   1.2        27/03/2009   APD                3. Bug 9446 (precisiones var numericas)
   2.0        09/06/2010   AMC                4. Se a¿aden nuevas funciones bug 14748
   3.0        21/11/2011   JMP                5. BUG 18423: LCOL000 - Multimoneda
   4.0        29/11/2011   FAL                6. 0020314: GIP003 - Modificar el c¿lculo del Selo
   5.0        19/03/2012   JMF                0021655 MDP - TEC - C¿lculo del Consorcio
   6.0        15/06/2012   DRA                6. 0021927: MDP - TEC - Parametrizaci¿n producto de Hogar (MHG) - Nueva producci¿n
   7.0        01/08/2012   APD                7. 0023074: LCOL_T010-Tratamiento Gastos de Expedici¿n
   8.0        22/02/2013   JMF                0025826: LCOL_T031-LCOL - Fase 3 - (176-10) - Parametrizaci¿n Gastos de Expedici¿n e Impuestos
   9.0        19/06/2015   VCG                9. AMA-209-Redondeo SRI
   10.0       10/02/2017   FAC                10. CONF-439 CONF_ADM-05_CAMBIOS_PROCESO_COMISIONES

******************************************************************************/
   FUNCTION f_insert_impempres(pcconcep IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF pcempres IS NULL THEN
         RETURN 110203;   -- Es obligatorio introducir el c¿digo de la empresa.
      END IF;

      IF pcconcep IS NULL THEN
         RETURN(104534);   -- Concepto obligatorio
      END IF;

      INSERT INTO imp_empres
                  (cconcep, cempres)
           VALUES (pcconcep, pcempres);

      RETURN(0);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_insert_impempres', 99, SQLCODE,
                     SQLERRM);
         RETURN(108959);   -- Este registro ya existe
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_insert_impempres', 99, SQLCODE,
                     SQLERRM);
         RETURN(SQLCODE);
   END f_insert_impempres;

   FUNCTION f_delete_impempres(pcconcep IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER IS
      xcont_imprec   NUMBER := 0;
   BEGIN
      IF pcempres IS NULL THEN
         RETURN(110203);
      -- Es obligatorio introducir el c¿digo de la empresa.
      END IF;

      IF pcconcep IS NULL THEN
         RETURN(104534);   -- Concepto obligatorio
      END IF;

      SELECT COUNT('1')
        INTO xcont_imprec
        FROM imprec
       WHERE cconcep = pcconcep
         AND cempres = pcempres;

      IF xcont_imprec > 0 THEN
         RETURN(2292);   -- No se puede borrar. Existen registros asociados.
      ELSE
         DELETE FROM imp_empres
               WHERE cconcep = pcconcep
                 AND cempres = pcempres;
      --COMMIT;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_delete_impempres', 99, SQLCODE,
                     SQLERRM);
         RETURN(SQLCODE);
   END f_delete_impempres;

   /*************************************************************************
      Inserta los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pcramo    : codigo ramo
      param in psproduc  : codigo de modalidad
      param in pcactivi  : codigo de actividad
      param in pcgarant  : codigo de garantia
      param in pfinivig  : fecha inicio vigencia
      param in pffinvig  : fecha fin vigencia
      param in pctipcon  : c¿digo tipo concepto
      param in pnvalcon  : valor del concepto
      param in pcfracci  : fraccionar
      param in pcbonifi  : aplicar a prima con bonificaci¿n
      param in pcrecfra  : aplicar a prima con recargo fraccionamiento

      return             : numero de error
   *************************************************************************/
   FUNCTION f_insert_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pctipcon IN NUMBER,
      pnvalcon IN NUMBER,
      pcfracci IN NUMBER,
      pcbonifi IN NUMBER,
      pcrecfra IN NUMBER)
      RETURN NUMBER IS
      vncont         NUMBER;
      xnconcep       imprec.nconcep%TYPE;   -- NUMBER(6);
      xcont_impempres NUMBER;
      nerror         NUMBER;
      xnconcep_aux   imprec.nconcep%TYPE;   -- NUMBER(6);
      cont_pk        NUMBER;
      cont_update    NUMBER;
      pcmodali       productos.cmodali%TYPE;   --NUMBER(2);
      pctipseg       productos.ctipseg%TYPE;   --NUMBER(2);
      pccolect       productos.ccolect%TYPE;   --NUMBER(2);
      vpcramo        productos.cramo%TYPE;   --NUMBER(2);
   BEGIN
      IF pcconcep IS NULL THEN
         RETURN 104534;   -- Concepto obligatorio
      ELSIF pcconcep = 8
            AND pcforpag IS NULL THEN
         RETURN 120079;   -- Falta informar la forma de pago
      ELSIF pcempres IS NULL THEN
         RETURN 110203;   -- Es obligatorio introducir el c¿digo de la empresa.
      ELSIF pfinivig IS NULL THEN
         RETURN 105308;   -- Fecha inicial obligatoria
      ELSIF pctipcon IS NULL THEN
         RETURN 152831;
      ELSIF pnvalcon IS NULL THEN
         RETURN 152832;
      END IF;

      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO vpcramo, pcmodali, pctipseg, pccolect
           FROM productos
          WHERE sproduc = psproduc;
      EXCEPTION
         WHEN OTHERS THEN
            vpcramo := pcramo;
            pcmodali := NULL;
            pctipseg := NULL;
            pccolect := NULL;
      END;

      IF pnconcep IS NULL THEN
         IF pcforpag IS NULL THEN
            IF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NOT NULL
               AND pccolect IS NOT NULL
               AND pcactivi IS NOT NULL
               AND pcgarant IS NOT NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NOT NULL
                  AND pcactivi IS NOT NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NOT NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            ELSIF vpcramo IS NULL
                  AND pcmodali IS NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT('1')
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo IS NULL
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo IS NULL
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL
                  AND cforpag IS NULL;
            END IF;
         ELSE
            IF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NOT NULL
               AND pccolect IS NOT NULL
               AND pcactivi IS NOT NULL
               AND pcgarant IS NOT NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cforpag = pcforpag
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NOT NULL
                  AND pcactivi IS NOT NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cforpag = pcforpag
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi = pcactivi
                  AND cgarant IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NOT NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cforpag = pcforpag
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi IS NULL
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect = pccolect
                  AND cactivi IS NULL
                  AND cgarant IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NOT NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg = pctipseg
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NOT NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali = pcmodali
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;
            ELSIF vpcramo IS NOT NULL
                  AND pcmodali IS NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cforpag = pcforpag
                  AND cramo = vpcramo
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo = vpcramo
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;
            ELSIF vpcramo IS NULL
                  AND pcmodali IS NULL
                  AND pctipseg IS NULL
                  AND pccolect IS NULL
                  AND pcactivi IS NULL
                  AND pcgarant IS NULL THEN
               SELECT COUNT(1)
                 INTO vncont
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cforpag = pcforpag
                  AND cramo IS NULL
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;

               SELECT NVL(MAX(nconcep), 0) + 1
                 INTO xnconcep
                 FROM imprec
                WHERE cconcep = pcconcep
                  AND cempres = pcempres
                  AND cramo IS NULL
                  AND cmodali IS NULL
                  AND ctipseg IS NULL
                  AND ccolect IS NULL
                  AND cactivi IS NULL
                  AND cgarant IS NULL;
            END IF;
         END IF;
      END IF;

      -- A¿adido LPS, para control de PK.
      IF pnconcep IS NULL THEN
         SELECT COUNT('1'), MAX(nconcep) + 1
           INTO cont_pk, xnconcep_aux
           FROM imprec
          WHERE cconcep = pcconcep
            AND cempres = pcempres
            AND finivig = pfinivig;

         IF cont_pk > 0
            AND xnconcep_aux <> xnconcep THEN
-- Comprbamos si es actualizaci¿n (mismo nivel), o nuevo registro (se aumetar¿ el xnconcep)
            SELECT COUNT('1')
              INTO cont_update
              FROM imprec
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND finivig = pfinivig
               AND nconcep = xnconcep
               AND(pcforpag IS NULL
                   OR cforpag = pcforpag)
               AND(vpcramo IS NULL
                   OR cramo = vpcramo)
               AND(pcmodali IS NULL
                   OR cmodali = pcmodali)
               AND(pctipseg IS NULL
                   OR ctipseg = pctipseg)
               AND(pccolect IS NULL
                   OR ccolect = pccolect)
               AND(pcactivi IS NULL
                   OR cactivi = pcactivi)
               AND(pcgarant IS NULL
                   OR cgarant = pcgarant)
               AND(pcforpag IS NULL
                   OR cforpag = pcforpag);

            IF cont_update = 0 THEN   -- Nuevo registro (aumentamos el xnconcep)
               xnconcep := xnconcep_aux;
            END IF;
         END IF;
      END IF;

      -- Bug 14748 - 09/06/2010 - AMC
      BEGIN
         INSERT INTO imprec
                     (cconcep, cempres, nconcep, cforpag, cramo,
                      cmodali, ctipseg, ccolect, cactivi, cgarant, finivig, ctipcon,
                      nvalcon, cfracci, cbonifi, crecfra)
              VALUES (pcconcep, pcempres, NVL(pnconcep, xnconcep), pcforpag, vpcramo,
                      pcmodali, pctipseg, pccolect, pcactivi, pcgarant, pfinivig, pctipcon,
                      pnvalcon, pcfracci, pcbonifi, pcrecfra);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE imprec
               SET cforpag = pcforpag,
                   cramo = vpcramo,
                   cmodali = pcmodali,
                   ctipseg = pctipseg,
                   ccolect = pccolect,
                   cactivi = pcactivi,
                   cgarant = pcgarant,
                   ctipcon = pctipcon,
                   nvalcon = pnvalcon,
                   cfracci = pcfracci,
                   cbonifi = pcbonifi,
                   crecfra = pcrecfra
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep = NVL(pnconcep, xnconcep)
               AND finivig = pfinivig;
      END;

      -- Fi Bug 14748 - 09/06/2010 - AMC
      BEGIN
         SELECT COUNT('1')
           INTO xcont_impempres
           FROM imp_empres
          WHERE cconcep = pcconcep
            AND cempres = pcempres;

         IF xcont_impempres = 0 THEN
            nerror := f_insert_impempres(pcconcep, pcempres);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 140999;
      END;

      --IF pcforpag IS NOT NULL THEN
      IF vncont > 0 THEN
         IF vpcramo IS NOT NULL
            AND pcmodali IS NOT NULL
            AND pctipseg IS NOT NULL
            AND pccolect IS NOT NULL
            AND pcactivi IS NOT NULL
            AND pcgarant IS NOT NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND cempres = pcempres
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi
               AND cgarant = pcgarant;
         ELSIF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NOT NULL
               AND pccolect IS NOT NULL
               AND pcactivi IS NOT NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi = pcactivi
               AND cgarant IS NULL;
         ELSIF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NOT NULL
               AND pccolect IS NOT NULL
               AND pcactivi IS NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect
               AND cactivi IS NULL
               AND cgarant IS NULL;
         ELSIF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NOT NULL
               AND pccolect IS NULL
               AND pcactivi IS NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect IS NULL
               AND cactivi IS NULL
               AND cgarant IS NULL;
         ELSIF vpcramo IS NOT NULL
               AND pcmodali IS NOT NULL
               AND pctipseg IS NULL
               AND pccolect IS NULL
               AND pcactivi IS NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali = pcmodali
               AND ctipseg IS NULL
               AND ccolect IS NULL
               AND cactivi IS NULL
               AND cgarant IS NULL;
         ELSIF vpcramo IS NOT NULL
               AND pcmodali IS NULL
               AND pctipseg IS NULL
               AND pccolect IS NULL
               AND pcactivi IS NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo = vpcramo
               AND cmodali IS NULL
               AND ctipseg IS NULL
               AND ccolect IS NULL
               AND cactivi IS NULL
               AND cgarant IS NULL;
         ELSIF vpcramo IS NULL
               AND pcmodali IS NULL
               AND pctipseg IS NULL
               AND pccolect IS NULL
               AND pcactivi IS NULL
               AND pcgarant IS NULL THEN
            UPDATE imprec
               SET ffinvig = pfinivig - 1
             WHERE cconcep = pcconcep
               AND cempres = pcempres
               AND nconcep <> NVL(pnconcep, xnconcep)
               AND((pcforpag IS NULL
                    AND cforpag IS NULL)
                   OR(pcforpag IS NOT NULL
                      AND cforpag = pcforpag))
               AND ffinvig IS NULL
               AND cramo IS NULL
               AND cmodali IS NULL
               AND ctipseg IS NULL
               AND ccolect IS NULL
               AND cactivi IS NULL
               AND cgarant IS NULL;
         END IF;
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_insert_imprec', 99, SQLCODE, SQLERRM);
         RETURN 140999;
   END f_insert_imprec;

   /*************************************************************************
      Calcula importe del concepto

      pnvalcon      IN NUMBER,                -- Valor del concepto.
      piconcep0     IN NUMBER,                -- Prima neta.
      piconcep21    IN NUMBER,                -- Prima devengada.
      pidto         IN NUMBER,                -- Descuento comercial.
      pidto21       IN NUMBER,                -- Descuento comercial (Bonificacion Anualizada).
      pidtocam      IN NUMBER,                -- Descuento campa¿a.
      picapital     IN NUMBER,                -- Capital (para impuestos sobre capital)
      ptotrecfracc  IN NUMBER,                -- Total Recargo de fraccionamiento
      pprecfra      IN NUMBER,                -- Porcentaje de recargo de fraccionamiento.
      pctipcon      IN NUMBER,                -- Tipo de concepto.
      pcforpag      IN NUMBER,                -- Forma de pago.
      pcfracci      IN NUMBER,                -- Fraccionamiento.
      pcbonifi      IN NUMBER,                -- No se utiliza por ahora (NULL).
      pcrecfra      IN NUMBER,                -- Recargo por fraccionamiento.
      oiconcep      OUT NUMBER,               -- Importe resultante para el concepto.
      pgastos       IN NUMBER DEFAULT NULL,   -- Gastos de emisi¿n. Concepto 14. derechos de registro
      pcderreg      IN NUMBER DEFAULT NULL,   -- si aplica derechos de registro en el calculo de impuestos
      piconcep0neto IN NUMBER DEFAULT NULL,   -- prima neta retenida (solo iconcep0), en el pincocep0, llega en icocep0 + inconcep50
      pfefecto      IN DATE   DEFAULT NULL,
      psseguro      IN NUMBER DEFAULT NULL,
      pnriesgo      IN NUMBER DEFAULT NULL,
      pcgarant      IN NUMBER DEFAULT NULL,
      pcmoneda      IN NUMBER DEFAULT NULL,
      pttabla       IN VARCHAR2 DEFAULT 'SEG' -- Tablas SEG=Reales, EST=Estudio
      --BUG 24656-XVM-16/11/2012.A¿adir paccion
      paccion       IN NUMBER DEFAULT 1  Indica si estamos en suplemento o no. 0-Nueva Prod. 2-Suplemento

      return        : 0=Correcto, numero=C¿digo de error
      -- Bug 0021655 - 19/03/2012 - JMF
   *************************************************************************/
   FUNCTION f_calcula_impconcepto(
      pnvalcon IN NUMBER,
      piconcep0 IN NUMBER,
      piconcep21 IN NUMBER,
      pidto IN NUMBER,
      pidto21 IN NUMBER,
      pidtocam IN NUMBER,
      picapital IN NUMBER,
      ptotrecfracc IN NUMBER,
      pprecfra IN NUMBER,
      pctipcon IN NUMBER,
      pcforpag IN NUMBER,
      pcfracci IN NUMBER,
      pcbonifi IN NUMBER,
      pcrecfra IN NUMBER,
      oiconcep OUT NUMBER,
      pgastos IN NUMBER DEFAULT NULL,
      pcderreg IN NUMBER DEFAULT NULL,
      piconcep0neto IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL,
      pnriesgo IN NUMBER DEFAULT NULL,
      pcgarant IN NUMBER DEFAULT NULL,
      pcmoneda IN NUMBER DEFAULT NULL,
      pttabla IN VARCHAR2 DEFAULT 'SEG',
      paccion IN NUMBER DEFAULT 1,
      parbitri IN NUMBER DEFAULT NULL,
      pnmovimi IN NUMBER DEFAULT NULL,
      ptipomovimiento IN NUMBER DEFAULT NULL)   -- BUG 0034505 - FAL - 17/03/2015
      RETURN NUMBER IS
      viconcep       NUMBER;
      vidto          NUMBER;
      totrecfracc    NUMBER;
      num_err        NUMBER;
      vporcentaje    NUMBER;
      -- ini Bug 0021655 - 19/03/2012 - JMF
      vimportefijo   NUMBER;
      v_origen       NUMBER;
      -- fin Bug 0021655 - 19/03/2012 - JMF
      v_sproduc      seguros.sproduc%TYPE;
      vvcaccion      NUMBER;
      vcmovseg       NUMBER;
      pcempres       NUMBER := pac_parametros.f_parinstalacion_n('EMPRESADEF');
      pcagente       NUMBER;
   BEGIN
      IF NVL(pcfracci, 0) = 0 THEN   -- No se fracciona, todo va al primer recibo
         viconcep := NVL(piconcep21, 0);
         vidto := NVL(pidto21, 0);
      ELSIF pcfracci = 1 THEN   -- Se fracciona sobre prima total
         viconcep := NVL(piconcep0, 0);
         vidto := NVL(pidto, 0);
      ELSIF pcfracci = 2 THEN   -- se fracciona sobre la prima nete de cesi¿n
         viconcep := NVL(piconcep0neto, 0);   -- solo la parte neta (0), sin la cesion (50)
         vidto := NVL(pidto, 0);
      END IF;

      IF pprecfra IS NOT NULL THEN   -- Recargo en porcentaje (al emitir).
         totrecfracc := (NVL(viconcep, 0) / 100) * pprecfra;
      ELSE
         totrecfracc := NVL(ptotrecfracc, 0);
      -- Recargo por par¿metro (al tarifar).
      END IF;

      -- BUG21927:DRA:15/06/2012:Inici
      IF psseguro IS NOT NULL THEN
         num_err := pac_seguros.f_get_sproduc(psseguro, pttabla, v_sproduc);
      END IF;

      -- BUG21927:DRA:15/06/2012:Fi
      IF pctipcon = 1 THEN   -- Tasa
         oiconcep :=
            f_round
               (((NVL(viconcep, 0)
                  +(NVL(pcderreg, 0) * NVL(pgastos, 0))   -- Bug 0020314 - FAL - 29/11/2011. Suma derechos registro si pcderreg=1
                  +(NVL(pcbonifi, 0) * NVL(vidto, 0)) +(NVL(pcrecfra, 0) * NVL(totrecfracc, 0)))
                 * NVL(pnvalcon, 0)),
                pcmoneda, NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));
      ELSIF pctipcon = 2 THEN   -- Importe fijo
         oiconcep := f_round(NVL(pnvalcon, 0), pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      ELSIF pctipcon = 3 THEN   -- Porcentaje
         oiconcep :=
            f_round
               (((NVL(viconcep, 0)
                  +(NVL(pcderreg, 0) * NVL(pgastos, 0))   -- Bug 0020314 - FAL - 29/11/2011. Suma derechos registro si pcderreg=1
                  +(NVL(pcbonifi, 0) * NVL(vidto, 0)) +(NVL(pcrecfra, 0) * NVL(totrecfracc, 0)))
                 *(NVL(pnvalcon, 0) / 100)),
                pcmoneda, NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));
      ELSIF pctipcon = 4 THEN   -- Por mil a capital
         oiconcep := f_round(((NVL(picapital, 0) / 1000) *(NVL(pnvalcon, 0))), pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));
      ELSIF pctipcon = 5 THEN   -- FORMULA
         -- I Bug 19089 - 09/06/2010 - JLB
         -- Bug 25826 - APD - 04/03/2013
         IF pttabla = 'EST' THEN
            v_origen := 1;
         ELSE
            v_origen := 2;
         END IF;

         viconcep := viconcep +(NVL(pcrecfra, 0) * NVL(totrecfracc, 0));
         -- fin Bug 25826 - APD - 04/03/2013
         --BUG 24656-XVM-16/11/2012.A¿adir paccion
         --BUG 25826-APD-04/03/2013.A¿adir v_origen
         num_err := pac_calculo_formulas.calc_formul(pfefecto,   --p_fefecto,
                                                     v_sproduc,   --p_sproduc,
                                                     NULL,   --p_cactivi,
                                                     pcgarant, pnriesgo, psseguro, pnvalcon,   --pcformula,
                                                     vporcentaje, NULL, NULL, v_origen, NULL,
                                                     NULL, NULL, paccion);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         -- F Bug 19089 - 09/06/2010 - JLB
         oiconcep := f_round(viconcep * vporcentaje, pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      -- ini Bug 0021655 - 19/03/2012 - JMF
      ELSIF pctipcon = 6 THEN   -- F¿rmula que devuelve un % a aplicar al capital
         IF pttabla = 'EST' THEN
            v_origen := 1;
         ELSE
            v_origen := 2;
         END IF;

         --BUG 24656-XVM-16/11/2012.A¿adir paccion
         num_err :=
            pac_calculo_formulas.calc_formul(pfefecto, v_sproduc,   --p_sproduc,
                                             NULL,   --p_cactivi,
                                             pcgarant, pnriesgo, psseguro, pnvalcon,   --pclave,

                                             -- vporcentaje, NULL,   --pnmovimi
                                             vporcentaje, pnmovimi,   -- BUG 0034505 - FAL - 17/03/2015
                                             NULL,   --psesion
                                             v_origen,   --porigen
                                             NULL, NULL, NULL, paccion);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         oiconcep := f_round(NVL(picapital, 0) * vporcentaje, pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      ELSIF pctipcon = 7 THEN   -- F¿rmula devolver¿ un importe fijo
         IF pttabla = 'EST' THEN
            v_origen := 1;
         ELSE
            v_origen := 2;
         END IF;

         IF pnmovimi IS NOT NULL THEN
            IF pnmovimi > 1 THEN
               IF pttabla = 'EST' THEN
                  vvcaccion := 2;
               ELSE
                  BEGIN
                     SELECT cmovseg
                       INTO vcmovseg
                       FROM movseguro
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi;

                     IF vcmovseg = 2
                        OR NVL(ptipomovimiento, 0) IN(21, 22)   --(Renovacion,Cartera)
                                                             THEN
                        vvcaccion := 3;
                     ELSE
                        vvcaccion := 2;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        vvcaccion := 3;
                  END;
               END IF;
            ELSE
               vvcaccion := 0;
            END IF;
         END IF;

         --BUG 24656-XVM-16/11/2012.A¿adir paccion
         num_err := pac_calculo_formulas.calc_formul(pfefecto, v_sproduc,   --p_sproduc,
                                                     NULL,   --p_cactivi,
                                                     pcgarant, pnriesgo, psseguro, pnvalcon,   --pclave,
                                                     vimportefijo, NULL,   --pnmovimi
                                                     NULL,   --psesion
                                                     v_origen,   --porigen
                                                     NULL, NULL, NULL, NVL(paccion, vvcaccion));

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         oiconcep := f_round(NVL(vimportefijo, 0), pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      -- fin Bug 0021655 - 19/03/2012 - JMF
      -- Bug 23074 - APD - 01/08/2012 - se a¿ade el nuevo tipo de concepto
      ELSIF pctipcon = 8 THEN   -- Porcentaje sobre Gastos de Expedicion (v.f.313)
         oiconcep := f_round(NVL(pcderreg, 0) *(NVL(pnvalcon, 0) / 100), pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      -- fin Bug 23074 - APD - 01/08/2012
      ELSIF pctipcon = 9 THEN
         oiconcep :=
            f_round
               (((NVL(viconcep, 0) + NVL(parbitri, 0)
                  +(NVL(pcderreg, 0) * NVL(pgastos, 0))   -- Bug 0020314 - FAL - 29/11/2011. Suma derechos registro si pcderreg=1
                  +(NVL(pcbonifi, 0) * NVL(vidto, 0)) +(NVL(pcrecfra, 0) * NVL(totrecfracc, 0)))
                 * NVL(pnvalcon, 0)),
                pcmoneda, NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));

      ELSIF pctipcon = 10 THEN   -- F¿rmula que devuelve un % a aplicar a gastos expedici¿n
         -- Bug 0025826 - 22/02/2013 - JMF
         IF pttabla = 'EST' THEN
            v_origen := 1;
         ELSE
            v_origen := 2;
         END IF;

         num_err := pac_calculo_formulas.calc_formul(pfefecto, v_sproduc, NULL, pcgarant,
                                                     pnriesgo, psseguro, pnvalcon, vporcentaje,
                                                     NULL, NULL, v_origen, NULL, NULL, NULL,
                                                     paccion);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         oiconcep := NVL(pcderreg, 0) * vporcentaje;
      ELSIF pctipcon = 11 THEN   --FAC calculos impuestos sobre comision

          select cagente into pcagente from seguros where sseguro=psseguro;
          num_err := pac_liquida.f_calc_formula_agente(pcagente, pnvalcon, pfefecto, vporcentaje, v_sproduc);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         --P_CONTROL_ERROR('FAC','FAC001',piconcep0||'//'||vporcentaje||'//'||pcmoneda||'//'||pnvalcon);
         oiconcep := f_round(piconcep0 * vporcentaje, pcmoneda,
                             NVL(pac_parametros.f_parempresa_n(pcempres, 'REDONDEO_SRI'), 0));
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_calcula_impconcepto', 99, SQLCODE,
                     SQLERRM);
         RETURN SQLCODE;
   END f_calcula_impconcepto;

   FUNCTION f_calcula_impuestocapital(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pmode IN VARCHAR2,
      pcampimp IN VARCHAR2,
      ototcapital OUT NUMBER,
      pcgarant IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vselect        VARCHAR2(4000);
      vselect1       VARCHAR2(4000);
      vtotcapital    NUMBER;
      vtotcapanterior NUMBER;

      TYPE tcursor IS REF CURSOR;

      curgaran       tcursor;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pnriesgo IS NULL
         --OR pmode IS NULL then
         OR pcampimp IS NULL THEN
         RETURN(101901);   --Pas incorrecte de par¿metres a la funci¿
      END IF;

      IF pmode = 'EST' THEN
         vselect :=
            'SELECT sum(icapital) icapital
                   FROM estgaranseg eg, estseguros es, garanpro gp WHERE eg.sseguro = es.sseguro
                   AND es.cramo = gp.cramo AND es.cmodali = gp.cmodali AND es.ccolect = gp.ccolect AND es.ctipseg = gp.ctipseg AND gp.cgarant = eg.cgarant
                   AND es.sseguro = '
            || psseguro || '  AND eg.nmovimi = ' || pnmovimi;

         IF pnriesgo IS NOT NULL THEN
            vselect := vselect || ' AND eg.nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect := vselect || ' AND eg.cgarant = ' || pcgarant;
         END IF;

         IF pcampimp IS NOT NULL
            AND pcampimp <> 'SIN_CONCEPTO' THEN
            vselect := vselect || ' AND NVL(gp.' || pcampimp || ',0) = 1';
         END IF;

         --capital del movimiento anterior
         vselect1 :=
            'SELECT SUM(icapital) icapital
           FROM estgaranseg eg, estseguros es, garanpro gp WHERE es.sseguro = '
            || psseguro
            || ' AND es.cramo = gp.cramo AND es.cmodali = gp.cmodali AND es.ccolect = gp.ccolect AND es.ctipseg = gp.ctipseg AND gp.cgarant = eg.cgarant AND eg.sseguro = es.sseguro
            AND eg.nmovimi = (SELECT MAX(e.nmovimi)
                                FROM estgaranseg e
                               WHERE e.sseguro = eg.sseguro
                                 AND e.nmovimi < '
            || pnmovimi || ')';

         IF pnriesgo IS NOT NULL THEN
            vselect1 := vselect1 || ' AND eg.nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect1 := vselect1 || ' AND eg.cgarant = ' || pcgarant;
         END IF;

         IF pcampimp IS NOT NULL
            AND pcampimp <> 'SIN_CONCEPTO' THEN
            vselect1 := vselect1 || ' AND NVL(gp.' || pcampimp || ',0) = 1';
         END IF;

         vtotcapital := 0;

         OPEN curgaran FOR vselect1;

         FETCH curgaran
          INTO vtotcapanterior;

         WHILE curgaran%FOUND LOOP
            vtotcapital := NVL(vtotcapital, 0) + NVL(vtotcapanterior, 0);

            FETCH curgaran
             INTO vtotcapanterior;
         END LOOP;

         CLOSE curgaran;

         vtotcapanterior := NVL(vtotcapital, 0);
      ELSIF pmode = 'CAR'   --Para cartera
                         THEN
         vselect :=
            'SELECT sum(icapital) icapital
                   FROM garancar eg, seguros es, garanpro gp WHERE eg.sseguro = es.sseguro
                   AND es.cramo = gp.cramo AND es.cmodali = gp.cmodali AND es.ccolect = gp.ccolect AND es.ctipseg = gp.ctipseg AND gp.cgarant = eg.cgarant
                   AND es.sseguro = '
            || psseguro;

         IF pnriesgo IS NOT NULL THEN
            vselect := vselect || ' AND eg.nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect := vselect || ' AND eg.cgarant = ' || pcgarant;
         END IF;

         IF pcampimp IS NOT NULL THEN
            vselect := vselect || ' AND NVL(gp.' || pcampimp || ',0) = 1';
         END IF;
      ELSE   --reales
         vselect :=
            'SELECT sum(icapital) icapital
                   FROM garanseg gs, seguros s, garanpro gp WHERE gs.sseguro = s.sseguro
                   AND s.cramo = gp.cramo AND s.cmodali = gp.cmodali AND s.ccolect = gp.ccolect AND s.ctipseg = gp.ctipseg AND gp.cgarant = gs.cgarant
                   AND s.sseguro = '
            || psseguro || '  AND gs.nmovimi = ' || pnmovimi;

         IF pnriesgo IS NOT NULL THEN
            vselect := vselect || ' AND gs.nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect := vselect || ' AND gs.cgarant = ' || pcgarant;
         END IF;

         IF pcampimp IS NOT NULL
            AND pcampimp <> 'SIN_CONCEPTO' THEN
            vselect := vselect || ' AND NVL(gp.' || pcampimp || ',0) = 1';
         END IF;

         vselect1 :=
            'SELECT SUM(icapital) icapital
              FROM garanseg eg, seguros es, garanpro gp, movseguro m WHERE es.sseguro = '
            || psseguro
            || ' AND es.cramo = gp.cramo AND es.cmodali = gp.cmodali AND es.ccolect = gp.ccolect AND es.ctipseg = gp.ctipseg AND gp.cgarant = eg.cgarant AND eg.sseguro = es.sseguro
               AND eg.nmovimi = (SELECT MAX(e.nmovimi)
                                   FROM garanseg e
                                  WHERE e.sseguro = eg.sseguro
                                    AND e.nmovimi < '
            || pnmovimi
            || ') AND m.sseguro = eg.sseguro AND m.nmovimi = eg.nmovimi AND m.cmovseg NOT IN (0, 2)';

         IF pnriesgo IS NOT NULL THEN
            vselect1 := vselect1 || ' AND eg.nriesgo = ' || pnriesgo;
         END IF;

         IF pcgarant IS NOT NULL THEN
            vselect1 := vselect1 || ' AND eg.cgarant = ' || pcgarant;
         END IF;

         IF pcampimp IS NOT NULL
            AND pcampimp <> 'SIN_CONCEPTO' THEN
            vselect1 := vselect1 || ' AND NVL(gp.' || pcampimp || ',0) = 1';
         END IF;

         vtotcapital := 0;

         OPEN curgaran FOR vselect1;

         FETCH curgaran
          INTO vtotcapanterior;

         WHILE curgaran%FOUND LOOP
            vtotcapital := NVL(vtotcapital, 0) + NVL(vtotcapanterior, 0);

            FETCH curgaran
             INTO vtotcapanterior;
         END LOOP;

         CLOSE curgaran;

         vtotcapanterior := NVL(vtotcapital, 0);
      END IF;

      OPEN curgaran FOR vselect;

      FETCH curgaran
       INTO vtotcapital;

      WHILE curgaran%FOUND LOOP
         ototcapital := NVL(ototcapital, 0) + NVL(vtotcapital, 0) - NVL(vtotcapanterior, 0);

         FETCH curgaran
          INTO vtotcapital;
      END LOOP;

      CLOSE curgaran;

      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_calcula_impuestocapital', 99,
                     SQLCODE, SQLERRM);

         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF curgaran%ISOPEN THEN
            CLOSE curgaran;
         END IF;

         RETURN(SQLCODE);
   END f_calcula_impuestocapital;

   /*************************************************************************
      Borra los impuestos en la tabla imprec
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pcforpag  : codigo formad pago
      param in pfinivig  : fecha inicio vigencia

      return             : numero de error

      Bug 14748 - 10/06/2010 - AMC
   *************************************************************************/
   FUNCTION f_del_imprec(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pcforpag IN NUMBER,
      pfinivig IN DATE)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IMPUESTOS.f_del_imprec';
      vparam         VARCHAR2(1000)
         := ' pcconcep:' || pcconcep || ' pcempres:' || pcempres || ' pnconcep:' || pnconcep
            || ' pcforpag:' || pcforpag || ' pfinivig:' || pfinivig;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcconcep IS NULL THEN
         RETURN 104534;   -- Concepto obligatorio
      ELSIF pcconcep = 8
            AND pcforpag IS NULL THEN
         RETURN 120079;   -- Falta informar la forma de pago
      ELSIF pcempres IS NULL THEN
         RETURN 110203;   -- Es obligatorio introducir el c¿digo de la empresa.
      ELSIF pfinivig IS NULL THEN
         RETURN 105308;   -- Fecha inicial obligatoria
      END IF;

      DELETE      imprec
            WHERE cconcep = pcconcep
              AND nconcep = pnconcep
              AND cempres = pcempres
              AND finivig = pfinivig;

      vpasexec := 2;

      IF pnconcep > 1 THEN
         vpasexec := 3;

         UPDATE imprec
            SET ffinvig = NULL
          WHERE cconcep = pcconcep
            AND cempres = pcempres
            AND cforpag = pcforpag
            AND finivig = (SELECT MAX(finivig)
                             FROM imprec
                            WHERE cconcep = pcconcep
                              AND cempres = pcempres
                              AND cforpag = pcforpag);
      ELSE
         vpasexec := 4;

         DELETE      imp_empres
               WHERE cconcep = pcconcep
                 AND cempres = pcempres;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, vpasexec, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_del_imprec;

   /*************************************************************************
      Devuelve un reargo por fraccionamiento
      param in pcempres  : empresa
      param in pcconcep  : impuesto
      param in pnconcep  : secuencia de concepto
      param in pfinivig  : fecha inicio vigencia
      param out pctipcon : codigo tipo de concepto
      param out pnvalcon : valor del concepto
      param out pcbonifi : si aplica a prima con bonificacion
      param out pcfracci : fraccionar
      param out pcrecfra : si aplica a prima con recargo fraccionamiento
      return             : numero de error

      Bug 14748 - 13/09/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_recargo(
      pcconcep IN NUMBER,
      pcempres IN NUMBER,
      pnconcep IN NUMBER,
      pfinivig IN DATE,
      pctipcon OUT NUMBER,
      pnvalcon OUT NUMBER,
      pcbonifi OUT NUMBER,
      pcfracci OUT NUMBER,
      pcrecfra OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(100) := 'PAC_IMPUESTOS.f_get_recargo';
      vparam         VARCHAR2(1000)
         := ' pcconcep:' || pcconcep || ' pcempres:' || pcempres || ' pnconcep:' || pnconcep
            || ' pfinivig:' || pfinivig;
      vpasexec       NUMBER := 1;
   BEGIN
      IF pcconcep IS NULL THEN
         RETURN 104534;   -- Concepto obligatorio
      ELSIF pcempres IS NULL THEN
         RETURN 110203;   -- Es obligatorio introducir el c¿digo de la empresa.
      ELSIF pfinivig IS NULL THEN
         RETURN 105308;   -- Fecha inicial obligatoria
      END IF;

      SELECT ctipcon, nvalcon, cbonifi, cfracci, crecfra
        INTO pctipcon, pnvalcon, pcbonifi, pcfracci, pcrecfra
        FROM imprec
       WHERE cconcep = pcconcep
         AND nconcep = pnconcep
         AND cempres = pcempres
         AND finivig = pfinivig;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname || vparam, vpasexec, SQLERRM, SQLCODE);
         RETURN 140999;
   END f_get_recargo;

    /*************************************************************************
               FUNCTION f_reteica_provin
      Encontrar el valor reteica
      param in pcagente    : codigo agente
      param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_provin(pcagente IN NUMBER)
      RETURN NUMBER IS
      v_cont         NUMBER;
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_retorno      NUMBER;
      ex_nodeclared  EXCEPTION;
      e_param_error  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_IMPUESTOS')
        INTO v_propio
        FROM DUAL;

      v_ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_reteica_provin('''
              || pcagente || ''')' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_reteica_provin', 1,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS  ', SQLERRM);
         RETURN 0;
      WHEN ex_nodeclared THEN
         --  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
         --  a una funci¿n, procedimiento, etc. inexistente o no declarado.
         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_reteica_provin', 2, SQLCODE, SQLERRM);
         RETURN 0;
   END f_reteica_provin;

    /*************************************************************************
               FUNCTION f_reteica_poblac
      Encontrar el valor reteica
      param in pcagente    : codigo agente
      param out pvalor  : devuelve el valor de la provincia para aplicar el reteica
   *************************************************************************/
   FUNCTION f_reteica_poblac(pcagente IN NUMBER)
      RETURN NUMBER IS
      v_cont         NUMBER;
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_retorno      NUMBER;
      ex_nodeclared  EXCEPTION;
      e_param_error  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_IMPUESTOS')
        INTO v_propio
        FROM DUAL;

      v_ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_reteica_poblac('''
              || pcagente || ''')' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_reteica_poblac', 1,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS  ', SQLERRM);
         RETURN 0;
      WHEN ex_nodeclared THEN
         --  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
         --  a una funci¿n, procedimiento, etc. inexistente o no declarado.
         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_reteica_poblac', 2, SQLCODE, SQLERRM);
         RETURN 0;
   END f_reteica_poblac;

   --Ini Bug: 22443  MCA Unificaci¿n de los impuestos
   /*************************************************************************
            FUNCTION f_retefuente
      Encontrar el valor retefuente
      param in pcagente    : codigo agente
      param out pretefuente  : devuelve el valor del retefuente a buscar dentro de las vigencias
   *************************************************************************/
   FUNCTION f_retefuente(pcagente IN NUMBER)
      RETURN NUMBER IS
      v_cont         NUMBER;
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_retorno      NUMBER;
      ex_nodeclared  EXCEPTION;
      e_param_error  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
   BEGIN
      IF pcagente IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'PAC_IMPUESTOS')
        INTO v_propio
        FROM DUAL;

      v_ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_retefuente(''' || pcagente
              || ''')' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_retefuente', 1,
                     'PARAMETROS OBLIGATORIOS NO INFORMADOS  ', SQLERRM);
         RETURN 0;
      WHEN ex_nodeclared THEN
         --  Esta excepci¿n (ORA-6550 saltar¿ siempre que se realiza una llamada
         --  a una funci¿n, procedimiento, etc. inexistente o no declarado.
         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         RETURN 0;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_impuestos.f_retefuente', 2, SQLCODE, SQLERRM);
         RETURN 0;
   END f_retefuente;
END pac_impuestos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMPUESTOS" TO "PROGRAMADORESCSI";
