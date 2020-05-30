CREATE OR REPLACE PACKAGE BODY "PAC_COMISIONES" IS
   /******************************************************************************
      NOMBRE:     PAC_COMISIONES
      PROP脫SITO:  Funciones de cuadros de comisiones

      REVISIONES:
      Ver        Fecha        Autor             Descripci贸n
      ---------  ----------  ---------------  ------------------------------------
      1.0        21/07/2010   AMC               1. Creaci贸n del package.
      2.0        14/09/2010   ICV               2. 0015137: MDP Desarrollo de Cuadro Comisiones
      3.0        19/10/2010   JMF               3. 0016305 CEM902 - CANVI COMISSIONS POST-ACORD MAPFRE
      4.0        31/05/2011   DRA               4. 0018078: LCOL - Proceso Traspaso de Cartera y Consulta de procesos
      5.0        31/05/2011   JBL               5. 0016363: MDP003 - Errores en el Cuadro Comisiones
      6.0        12/09/2011   JTS               6. 19316: CRT - Adaptar pantalla de comisiones
      7.0        03/10/2011   DRA               7. 0019069: LCOL_C001 - Co-corretaje
      8.0        02/11/2011   JMP               7. 0018423: LCOL705 - Multimoneda
      9.0        22/11/2011   JTS               8. 0020182: LCOL_C001 - Problema con las alturas de comisiones
      10.0       29/10/2012   DRA               10. 0022402: LCOL_C003: Adaptaci贸n del co-corretaje
      11.0       21/11/2012   DRA               11. 0024802: LCOL_C001-LCOL: Anulaci?n de p?liza con co-corretaje
      12.0       04/12/2012   FPG               12 0024477: RSA101 - Producto Masivo. Parametrizacion
      13.0       02/12/2014   RDD               13. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
      14.0       21/05/2015   VCG               14 033977-204336: MSV: Creaci髇 de funciones
    15.0       22/01/2019   ACL             15. TCS_2 Se crean las funciones f_valida_cuadro y f_anular_cuadro.
      16.0       15/08/2019   JLTS              15 IAXIS-5040: Se adiciona el parametro pccompan en la funcion f_alt_comisionrec
   ******************************************************************************/

   /*************************************************************************
      Recupera un cuadro de comisiones
      param in pccomisi   : codigo de comision
      param in ptcomisi   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param in pidioma    : codigo del idioma
      param out pquery    : select a ejecutar
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadroscomision(
      pccomisi IN NUMBER,
      ptcomisi IN VARCHAR2,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pffechaini IN DATE,
      pffechafin IN DATE,
      pidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := ' SELECT C.CCOMISI,D.TCOMISI,C.CTIPO,V.FINIVIG,V.FFINVIG,V.CESTADO'
                || ' FROM CODICOMISIO C,COMISIONVIG V,DESCOMISION D'
                || ' WHERE c.CCOMISI = v.CCOMISI' || ' AND v.ccomisi = d.CCOMISI'
                || ' AND d.CIDIOMA =' || pidioma || ' AND (c.CCOMISI = ''' || pccomisi
                || ''' or ''' || pccomisi || ''' IS NULL)'
                || ' AND upper(d.tcomisi) like upper(''%' || ptcomisi || '%' || CHR(39) || ')'
                || ' AND (c.ctipo = ''' || pctipo || ''' or ''' || pctipo || ''' IS NULL)  '
                || ' AND (v.cestado = ''' || pcestado || ''' or ''' || pcestado
                || ''' IS NULL)';

      IF pffechaini IS NOT NULL THEN
         pquery := pquery || ' AND FINIVIG >= ' || 'TO_DATE('''
                   || TO_CHAR(pffechaini, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') ';
      END IF;

      IF pffechafin IS NOT NULL THEN
         pquery := pquery || ' AND FFINVIG <= ' || 'TO_DATE('''
                   || TO_CHAR(pffechafin, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') ';
      ELSE
         pquery := pquery || ' AND (FFINVIG IS NULL or ffinvig > f_sysdate) ';
      END IF;

      pquery := pquery || 'order by ccomisi desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_cuadroscomision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_cuadroscomision;

   FUNCTION f_set_cab_comision(
      pccomisi IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER IS
      vfmax          DATE;
      /* BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
      vcestado       NUMBER := 0;
      vexiste        NUMBER := 0;
      vvalidar       NUMBER := 0;
   /* FIN BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
   BEGIN
      /* BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
      /* BUG 20182 - 22/11/2011 - JTS - LCOL_C001 - Problema con las alturas de comisiones*/
      /*      IF pffinvig IS NOT NULL THEN*/
      /*         IF pfinivig > pffinvig THEN*/
      /*            RETURN 101922;   --fecha inicial no mayor que final*/
      /*         END IF;*/
      /*      END IF;*/
      /*      SELECT GREATEST(MAX(finivig), MAX(ffinvig))*/
      /*        INTO vfmax*/
      /*        FROM comisionvig*/
      /*       WHERE ccomisi = pccomisi;*/
      /*      IF pfinivig <= vfmax THEN*/
      /*         RETURN 108884;   --fecha de inicio tiene que ser mayor a la de los registros anteriores*/
      /*      END IF;*/
          /*      -- FIN BUG 20182 - 22/11/2011 - JTS - LCOL_C001 - Problema con las alturas de comisiones*/
      IF pffinvig IS NOT NULL THEN
         IF pfinivig > pffinvig THEN
            RETURN 101922;   /*fecha inicial no mayor que final*/
         END IF;
      END IF;

      /* BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
      vvalidar := 1;

      BEGIN
         SELECT cestado
           INTO vcestado
           FROM comisionvig
          WHERE ccomisi = pccomisi
            AND finivig = pfinivig;

         vexiste := 1;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcestado := -1;
            vexiste := 0;
      END;

      IF vexiste = 1 THEN
         IF vcestado = pcestado THEN
            vvalidar := 0;
         ELSE
            IF vcestado = 1
               AND pcestado IN(2, 3) THEN
               vvalidar := 0;
            ELSE
               vvalidar := 1;
            END IF;
         END IF;
      ELSE
         vvalidar := 1;
      END IF;

      IF vvalidar = 1 THEN
         /* FIN BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
         SELECT MAX(finivig)
           INTO vfmax
           FROM comisionvig
          WHERE ccomisi = pccomisi;

         IF pfinivig <= vfmax THEN
            RETURN 108884;   /*fecha de inicio tiene que ser mayor a la de los registros anteriores*/
         END IF;
      END IF;

      /* FIN BUG 24477 - 04-12-2012 - FPG - Error al validar el cuadro*/
      BEGIN
         INSERT INTO codicomisio
                     (ccomisi, ctipo)
              VALUES (pccomisi, pctipo);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE codicomisio
               SET ctipo = pctipo
             WHERE ccomisi = pccomisi;
      END;

      BEGIN
         UPDATE comisionvig
            SET ffinvig = pfinivig - 1
          WHERE ccomisi = pccomisi
            AND ffinvig IS NULL;

         INSERT INTO comisionvig
                     (ccomisi, finivig, ffinvig, cestado)
              VALUES (pccomisi, pfinivig, pffinvig, pcestado);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE comisionvig
               SET cestado = pcestado,
                   ffinvig = pffinvig
             WHERE ccomisi = pccomisi
               AND finivig = pfinivig;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_set_cab_comision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_cab_comision;

   FUNCTION f_set_desccomision(pccomisi IN NUMBER, pcidioma IN NUMBER, ptcomisi IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO descomision
                     (ccomisi, cidioma, tcomisi)
              VALUES (pccomisi, pcidioma, ptcomisi);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE descomision
               SET tcomisi = ptcomisi
             WHERE ccomisi = pccomisi
               AND cidioma = pcidioma;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_set_desccomision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_desccomision;

   /*************************************************************************
      Duplica un cuadro de comisiones
      param in pccomisi_ori   : codigo de comision original
      param in pccomisi_nuevo : codigo de comision nuevo
      param in ptcomisi_nuevo : texto cuadro comision
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro(
      pccomisi_ori IN NUMBER,
      pccomisi_nuevo IN NUMBER,
      ptcomisi_nuevo IN VARCHAR2,
      pidioma IN NUMBER)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT COUNT(ccomisi)
        INTO vcount
        FROM codicomisio
       WHERE ccomisi = pccomisi_nuevo;

      IF vcount > 0 THEN
         RETURN 9901353;
      END IF;

      SELECT COUNT('1')
        INTO vcount
        FROM codicomisio c, comisionvig v
       WHERE c.ccomisi = v.ccomisi
         AND c.ccomisi = pccomisi_ori
         AND(v.ffinvig IS NULL
             OR v.ffinvig > TRUNC(f_sysdate));

      IF vcount = 0 THEN
         RETURN 9901454;
      END IF;

      INSERT INTO codicomisio
                  (ccomisi, ctipo)
         (SELECT pccomisi_nuevo, ctipo
            FROM codicomisio
           WHERE ccomisi = pccomisi_ori);

      vpasexec := 2;

      INSERT INTO descomision
                  (cidioma, ccomisi, tcomisi)
           VALUES (pidioma, pccomisi_nuevo, ptcomisi_nuevo);

      vpasexec := 3;

      INSERT INTO comisionvig
                  (ccomisi, finivig, ffinvig, cestado)
         (SELECT pccomisi_nuevo, finivig, ffinvig, 1   /*El estado siempre 1 al duplicar*/
            FROM comisionvig v
           WHERE ccomisi = pccomisi_ori
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      vpasexec := 4;

      /*------*/
      INSERT INTO comisionprod
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi, sproduc,
                   finivig, ninialt, nfinalt)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, pccomisi_nuevo, p.cmodcom,
                 p.pcomisi, p.sproduc, p.finivig, ninialt, nfinalt
            FROM comisionprod p, comisionvig v
           WHERE p.ccomisi = pccomisi_ori
             AND p.ccomisi = v.ccomisi
             AND p.finivig = (SELECT NVL(MAX(pp.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                                FROM comisionprod pp
                               WHERE pp.ccomisi = p.ccomisi
                                 AND pp.cramo = p.cramo
                                 AND pp.cmodali = p.cmodali
                                 AND pp.ctipseg = p.ctipseg
                                 AND pp.ccolect = p.ccolect
                                 AND pp.sproduc = p.sproduc
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      /* nuevas tabla comisionprod_criterio.*/
      INSERT INTO comisionprod_criterio
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, ninialt, nfinalt,
                   ccriterio, finivig, ffinvig, ndesde, nhasta, pcomisi, falta, cusualta)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, pccomisi_nuevo, p.cmodcom,
                 p.ninialt, p.nfinalt, c.ccriterio, p.finivig, c.ffinvig, c.ndesde, c.nhasta,
                 c.pcomisi, c.falta, c.cusualta
            FROM comisionprod p, comisionvig v, comisionprod_criterio c
           WHERE p.ccomisi = pccomisi_ori
             AND p.ccomisi = v.ccomisi
             AND c.cramo = p.cramo
             AND c.cmodali = p.cmodali
             AND c.ctipseg = p.ctipseg
             AND c.ccolect = p.ccolect
             AND c.ninialt = p.ninialt
             AND c.nfinalt = p.nfinalt
             AND c.ccomisi = p.ccomisi
             AND c.cmodcom = p.cmodcom
             AND p.finivig = (SELECT NVL(MAX(pp.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                                FROM comisionprod pp
                               WHERE pp.ccomisi = p.ccomisi
                                 AND pp.cramo = p.cramo
                                 AND pp.cmodali = p.cmodali
                                 AND pp.ctipseg = p.ctipseg
                                 AND pp.ccolect = p.ccolect
                                 AND pp.sproduc = p.sproduc
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      /* fin nuevas tabla comisionprod_criterio.*/
      vpasexec := 5;

      INSERT INTO comisionacti
                  (ccomisi, cactivi, cramo, cmodcom, pcomisi, cmodali, ctipseg, ccolect,
                   sproduc, finivig, ninialt, nfinalt)
         (SELECT pccomisi_nuevo, a.cactivi, a.cramo, a.cmodcom, a.pcomisi, a.cmodali,
                 a.ctipseg, a.ccolect, a.sproduc, a.finivig, ninialt, nfinalt
            FROM comisionacti a, comisionvig v
           WHERE a.ccomisi = pccomisi_ori
             AND a.ccomisi = v.ccomisi
             AND a.finivig = (SELECT MAX(pp.finivig)
                                FROM comisionacti pp
                               WHERE pp.ccomisi = a.ccomisi
                                 AND pp.cramo = a.cramo
                                 AND pp.cmodali = a.cmodali
                                 AND pp.ctipseg = a.ctipseg
                                 AND pp.ccolect = a.ccolect
                                 AND pp.sproduc = a.sproduc
                                 AND pp.cactivi = a.cactivi
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      /* nuevas tabla comisionacti_criterio.*/
      INSERT INTO comisionacti_criterio
                  (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom, ninialt,
                   nfinalt, ccriterio, finivig, ffinvig, ndesde, nhasta, pcomisi, falta,
                   cusualta)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, c.cactivi, pccomisi_nuevo,
                 p.cmodcom, p.ninialt, p.nfinalt, c.ccriterio, p.finivig, c.ffinvig, c.ndesde,
                 c.nhasta, c.pcomisi, c.falta, c.cusualta
            FROM comisionacti p, comisionvig v, comisionacti_criterio c
           WHERE p.ccomisi = pccomisi_ori
             AND p.ccomisi = v.ccomisi
             AND c.cramo = p.cramo
             AND c.cmodali = p.cmodali
             AND c.ctipseg = p.ctipseg
             AND c.ccolect = p.ccolect
             AND c.ccomisi = p.ccomisi
             AND c.cactivi = p.cactivi
             AND c.ninialt = p.ninialt
             AND c.nfinalt = p.nfinalt
             AND c.cmodcom = p.cmodcom
             AND p.finivig = (SELECT NVL(MAX(pp.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                                FROM comisionprod pp
                               WHERE pp.ccomisi = p.ccomisi
                                 AND pp.cramo = p.cramo
                                 AND pp.cmodali = p.cmodali
                                 AND pp.ctipseg = p.ctipseg
                                 AND pp.ccolect = p.ccolect
                                 AND pp.sproduc = p.sproduc
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      /* fin nuevas tabla comisionacti_criterio.*/
      vpasexec := 6;

      INSERT INTO comisiongar
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                   pcomisi, sproduc, finivig, ninialt, nfinalt)
         (SELECT g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant,
                 pccomisi_nuevo, g.cmodcom, g.pcomisi, g.sproduc, g.finivig, ninialt, nfinalt
            FROM comisiongar g, comisionvig v
           WHERE g.ccomisi = pccomisi_ori
             AND g.ccomisi = v.ccomisi
             AND g.finivig = (SELECT MAX(pp.finivig)
                                FROM comisiongar pp
                               WHERE pp.ccomisi = g.ccomisi
                                 AND pp.cramo = g.cramo
                                 AND pp.cmodali = g.cmodali
                                 AND pp.ctipseg = g.ctipseg
                                 AND pp.ccolect = g.ccolect
                                 AND pp.sproduc = g.sproduc
                                 AND pp.cactivi = g.cactivi
                                 AND pp.cgarant = g.cgarant
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      /* nuevas tabla comisiongar_criterio.*/
      INSERT INTO comisiongar_criterio
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                   ninialt, nfinalt, ccriterio, finivig, ffinvig, ndesde, nhasta, pcomisi,
                   falta, cusualta)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, c.cactivi, c.cgarant,
                 pccomisi_nuevo, p.cmodcom, p.ninialt, p.nfinalt, c.ccriterio, p.finivig,
                 c.ffinvig, c.ndesde, c.nhasta, c.pcomisi, c.falta, c.cusualta
            FROM comisiongar p, comisionvig v, comisiongar_criterio c
           WHERE p.ccomisi = pccomisi_ori
             AND p.ccomisi = v.ccomisi
             AND c.cramo = p.cramo
             AND c.cmodali = p.cmodali
             AND c.ctipseg = p.ctipseg
             AND c.ccolect = p.ccolect
             AND c.ccomisi = p.ccomisi
             AND c.cactivi = p.cactivi
             AND c.cgarant = p.cgarant
             AND c.ninialt = p.ninialt
             AND c.nfinalt = p.nfinalt
             AND c.cmodcom = p.cmodcom
             AND p.finivig = (SELECT NVL(MAX(pp.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                                FROM comisionprod pp
                               WHERE pp.ccomisi = p.ccomisi
                                 AND pp.cramo = p.cramo
                                 AND pp.cmodali = p.cmodali
                                 AND pp.ctipseg = p.ctipseg
                                 AND pp.ccolect = p.ccolect
                                 AND pp.sproduc = p.sproduc
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      BEGIN
         vpasexec := 7;

         INSERT INTO comisionprod_concep
                     (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, finivig, ninialt,
                      cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, pccomisi_nuevo, c.cmodcom,
                    c.finivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionprod_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi_nuevo
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisionprod_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.finivig >= v.finivig)
                AND(v.ffinvig IS NULL
                    OR v.ffinvig > TRUNC(f_sysdate)));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro', vpasexec,
                        'No existen comisiones desglosadas de Productos', SQLERRM);
      END;

      vpasexec := 8;

      BEGIN
         INSERT INTO comisionacti_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom, finivig,
                      ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.ccomisi, c.cmodcom,
                    c.finivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionacti_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi_nuevo
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisionacti_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.cactivi = c.cactivi
                                    AND c2.finivig >= v.finivig)
                AND(v.ffinvig IS NULL
                    OR v.ffinvig > TRUNC(f_sysdate)));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro', vpasexec,
                        'No existen comisiones desglosadas de Actividades', SQLERRM);
      END;

      vpasexec := 9;

      BEGIN
         INSERT INTO comisiongar_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                      finivig, ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.cgarant, c.ccomisi,
                    c.cmodcom, c.finivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc,
                    c.nfinalt
               FROM comisiongar_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi_nuevo
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisiongar_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.cactivi = c.cactivi
                                    AND c2.cgarant = c.cgarant
                                    AND c2.finivig >= v.finivig)
                AND(v.ffinvig IS NULL
                    OR v.ffinvig > TRUNC(f_sysdate)));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro', vpasexec,
                        'No existen comisiones desglosadas de Garant韆s', SQLERRM);
      END;

      /* FIN nuevas tabla comisiongar_criterio.*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_duplicar_cuadro;

   FUNCTION f_get_detalle_comision(
      pccomisi IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      ptodos IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      porderby IN NUMBER,
      pidioma IN NUMBER,
      pcmodcon IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vquery         VARCHAR2(32000);
      vwhere         VARCHAR2(32000);
      vwhereact      VARCHAR2(32000);
      vwheregar      VARCHAR2(32000);
      vwhereact2     VARCHAR2(32000);
      vwheregar2     VARCHAR2(32000);
      vwherepro      VARCHAR2(32000);
      vorder         VARCHAR2(32000);
      vquery_tot     VARCHAR2(32000);
      vwhere_vig     VARCHAR2(32000);
      vpfinivig      VARCHAR2(50);
      /**/
      vwhereproalt   VARCHAR2(32000);
      vwhereactalt   VARCHAR2(32000);
      vwheregaralt   VARCHAR2(32000);
   BEGIN
      IF pccomisi IS NOT NULL THEN
         vwhere := vwhere || ' and  c.ccomisi =' || pccomisi;
      END IF;

      IF pcagrprod IS NOT NULL THEN
         vwhere := vwhere || ' and  p.cagrpro =' || pcagrprod;
      END IF;

      IF pcramo IS NOT NULL THEN
         vwhere := vwhere || ' and  c.cramo =' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and  c.sproduc =' || psproduc;
      END IF;

      IF pcactivi IS NOT NULL THEN
         vwhereact := vwhereact || ' and  c.cactivi =' || pcactivi;
      END IF;

      IF pcgarant IS NOT NULL THEN
         vwheregar := vwheregar || ' and  c.cgarant =' || pcgarant;
      END IF;

      IF pcmodcon IS NOT NULL THEN
         vwhere := vwhere || ' and  c.cmodcom =' || pcmodcon;

         IF pcgarant IS NULL THEN
            vwheregar2 := vwheregar2 || ' and 1=2 ';
         END IF;

         IF pcactivi IS NULL
            OR pcgarant IS NOT NULL THEN
            vwhereact2 := vwhereact2 || ' and 1=2 ';
         END IF;

         IF pcactivi IS NOT NULL
            OR pcgarant IS NOT NULL THEN
            vwherepro := vwherepro || ' and 1=2 ';
         END IF;
      /*ELSE   --filtre per a nomes mostrar una altura
         vwheregaralt :=
            ' and c.ninialt = (select min(cc.ninialt)
      from comisiongar cc
      where c.ccomisi = cc.ccomisi
      and c.sproduc = cc.sproduc
      and c.cactivi = cc.cactivi
      and c.cgarant = cc.cgarant
      and c.cmodcom = cc.cmodcom
      and c.finivig = cc.finivig
      and c.cramo = cc.cramo
      and c.cmodali = cc.cmodali
      and c.ctipseg = cc.ctipseg
      and c.ccolect = cc.ccolect) ';
         vwhereactalt :=
            ' and c.ninialt = (select min(cc.ninialt)
      from comisionacti cc
      where c.ccomisi = cc.ccomisi
      and c.sproduc = cc.sproduc
      and c.cactivi = cc.cactivi
      and c.cmodcom = cc.cmodcom
      and c.finivig = cc.finivig
      and c.cramo = cc.cramo
      and c.cmodali = cc.cmodali
      and c.ctipseg = cc.ctipseg
      and c.ccolect = cc.ccolect) ';
         vwhereproalt :=
            ' and c.ninialt = (select min(cc.ninialt)
      from comisionprod cc
      where c.ccomisi = cc.ccomisi
      and c.sproduc = cc.sproduc
      and c.cmodcom = cc.cmodcom
      and c.finivig = cc.finivig
      and c.cramo = cc.cramo
      and c.cmodali = cc.cmodali
      and c.ctipseg = cc.ctipseg
      and c.ccolect = cc.ccolect) ';*/
      END IF;

      IF pfinivig IS NOT NULL THEN
         vwhere_vig := vwhere_vig || ' AND v.FINIVIG <= ' || 'TO_DATE('''
                       || TO_CHAR(pfinivig, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') '
                       || 'and v.finivig = (select max(vv.finivig) from comisionvig vv '
                       || 'where vv.ccomisi = v.ccomisi ' || 'and vv.finivig <= TO_DATE('''
                       || TO_CHAR(pfinivig, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY''))';
      END IF;

      vpfinivig := ' TO_DATE(''' || TO_CHAR(pfinivig, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') ';

      IF pffinvig IS NOT NULL THEN
         vwhere_vig := vwhere_vig || ' AND v.FFINVIG >= ' || 'TO_DATE('''
                       || TO_CHAR(pffinvig, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') ';
      ELSIF pfinivig IS NOT NULL THEN
         vwhere_vig := vwhere_vig
                       || ' and (v.ffinvig is null
		         OR v.ffinvig >= TO_DATE(''' || TO_CHAR(pfinivig, 'DD/MM/YYYY')
                       || ''', ''DD/MM/YYYY'') )';
      ELSE
         vwhere_vig := vwhere_vig || ' and v.ffinvig is null ';
      END IF;

      /*vwhere := vwhere || vwhereact || vwheregar;*/
      vquery :=
         'SELECT   sproduc,ttitulo,  trotulo, cactivi,tactivi,  cgarant,  tgarant,nivel, ccomisi,  finivig,
		         cmodcom, tmodcom, pcomisi, ninialt, nfinalt, ccriterio, ndesde, nhasta, tcriterio
		         from
		         ( SELECT   c.sproduc, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 1, '
         || pidioma
         || ') ttitulo, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 2, '
         || pidioma
         || ') trotulo,
		         NULL cactivi, NULL tactivi, NULL cgarant, NULL tgarant, 1 nivel, c.ccomisi, c.finivig,
		         c.cmodcom,
		         ff_desvalorfijo(67, '
         || pidioma
         || ', c.cmodcom) tmodcom,  nvl(ccr.pcomisi,c.pcomisi) pcomisi, c.ninialt, c.nfinalt, ccr.ccriterio, ccr.ndesde, ccr.nhasta, ff_desvalorfijo(1200, '
         || pidioma
         || ', ccr.ccriterio) tcriterio
		    FROM comisionprod c, productos p, comisionvig v, comisionprod_criterio ccr
		    where p.cramo = c.cramo
		    and p.cmodali = c.cmodali
		    and p.ctipseg = c.ctipseg
		    and p.ccolect = c.ccolect
		    and c.ccomisi = v.ccomisi
		    and ccr.cramo(+) = c.cramo
		    and ccr.CMODALI(+) = c.cmodali
		    and ccr.CTIPSEG(+) = c.ctipseg
		    and ccr.CCOLECT(+) = c.ccolect
		    and ccr.CCOMISI (+)= c.ccomisi
		    and ccr.ninialt(+) = c.ninialt
		    and ccr.nfinalt(+) = c.nfinalt
		    and ccr.CMODCOM(+) = c.CMODCOM
		    and c.finivig = (select max(cc.finivig)
		      from comisionprod cc
		      where cc.ccomisi = c.ccomisi
		      and cc.cramo = c.cramo
		      and cc.cmodali = c.cmodali
		      and cc.ctipseg = c.ctipseg
		      and cc.ccolect = c.ccolect
		      and cc.finivig <= nvl('
         || vpfinivig || ',v.finivig) ) ' || vwhere || vwherepro || vwhere_vig || vwhereproalt
         || '
		UNION
		SELECT   c.sproduc, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 1, '
         || pidioma
         || ') ttitulo,f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 2, '
         || pidioma
         || ') trotulo,
		         c.cactivi, (SELECT tactivi
		                     FROM activisegu
		                    WHERE cidioma = '
         || pidioma
         || '
		                      AND cramo = c.cramo
		                      AND cactivi = c.cactivi) tactivi, NULL cgarant, NULL tgarant,2 nivel,
		         c.ccomisi, c.finivig, c.cmodcom, ff_desvalorfijo(67, '
         || pidioma
         || ', c.cmodcom) tmodcom,  nvl(ccr.pcomisi,c.pcomisi) pcomisi, c.ninialt, c.nfinalt, ccr.ccriterio, ccr.ndesde, ccr.nhasta, ff_desvalorfijo(1200, '
         || pidioma
         || ', ccr.ccriterio) tcriterio
		    FROM comisionacti c, productos p, comisionvig v,comisionacti_criterio ccr
		    where p.cramo = c.cramo
		    and p.cmodali = c.cmodali
		    and p.ctipseg = c.ctipseg
		    and p.ccolect = c.ccolect
		    and c.ccomisi = v.ccomisi
		    and ccr.cramo(+) = c.cramo
		    and ccr.CMODALI(+) = c.cmodali
		    and ccr.CTIPSEG(+) = c.ctipseg
		    and ccr.CCOLECT(+) = c.ccolect
		    and ccr.CCOMISI(+) = c.ccomisi
		    and ccr.CACTIVI(+) = c.CACTIVI
		    and ccr.ninialt(+) = c.ninialt
		    and ccr.nfinalt(+) = c.nfinalt
		    and ccr.CMODCOM(+) = c.CMODCOM
		    and c.finivig = (select max(cc.finivig)
		      from comisionacti cc
		      where cc.ccomisi = c.ccomisi
		      and cc.cramo = c.cramo
		      and cc.cmodali = c.cmodali
		      and cc.ctipseg = c.ctipseg
		      and cc.ccolect = c.ccolect
		      and cc.cactivi = c.cactivi
		      and cc.finivig <= nvl('
         || vpfinivig || ',v.finivig) ) ' || vwhere || vwhere_vig || vwhereact || vwhereact2
         || vwhereactalt
         || '
		UNION
		SELECT   c.sproduc, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 1, '
         || pidioma
         || ') ttitulo,f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 2, '
         || pidioma
         || ') trotulo,
		         c.cactivi, (SELECT tactivi
		                     FROM activisegu
		                    WHERE cidioma = '
         || pidioma
         || '
		                      AND cramo = c.cramo
		                      AND cactivi = c.cactivi) tactivi, c.cgarant,
		         ff_desgarantia(c.cgarant, '
         || pidioma
         || ') tgarant,  3 nivel, c.ccomisi, c.finivig, c.cmodcom, ff_desvalorfijo(67, '
         || pidioma
         || ', c.cmodcom) tmodcom,  nvl(ccr.pcomisi,c.pcomisi) pcomisi, c.ninialt, c.nfinalt, ccr.ccriterio, ccr.ndesde, ccr.nhasta, ff_desvalorfijo(1200, '
         || pidioma
         || ', ccr.ccriterio) tcriterio
		    FROM comisiongar c, productos p, comisionvig v, comisiongar_criterio ccr
		    where p.cramo = c.cramo
		    and p.cmodali = c.cmodali
		    and p.ctipseg = c.ctipseg
		    and p.ccolect = c.ccolect
		    and c.ccomisi = v.ccomisi
		    and ccr.cramo(+) = c.cramo
		    and ccr.CMODALI(+) = c.cmodali
		    and ccr.CTIPSEG(+) = c.ctipseg
		    and ccr.CCOLECT(+) = c.ccolect
		    and ccr.CCOMISI(+) = c.ccomisi
		    and ccr.CACTIVI(+) = c.CACTIVI
		    and ccr.CGARANT(+) = c.CGARANT
		    and ccr.ninialt(+) = c.ninialt
		    and ccr.nfinalt(+) = c.nfinalt
		    and ccr.CMODCOM(+) = c.CMODCOM
		    and c.finivig = (select max(cc.finivig)
		      from comisiongar cc
		      where cc.ccomisi = c.ccomisi
		      and cc.cramo = c.cramo
		      and cc.cmodali = c.cmodali
		      and cc.ctipseg = c.ctipseg
		      and cc.ccolect = c.ccolect
		      and cc.cactivi = c.cactivi
		      and cc.cgarant = c.cgarant

		      and cc.finivig <= nvl('
         || vpfinivig || ',v.finivig) ) ' || vwhere || vwhere_vig || vwhereact || vwheregar
         || vwheregar2 || vwheregaralt;

      /*TODOS*/
      IF NVL(ptodos, 0) = 1 THEN
         vquery_tot :=
            '  union
		                SELECT p.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1, '
            || pidioma
            || ') ttitulo,
		                   f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 2, '
            || pidioma
            || ') trotulo, NULL cactivi,
		                   NULL tactivi, NULL cgarant, NULL tgarant, 1 nivel, NULL ccomisi, NULL finivig,
		                   d.catribu cmodcom, ff_desvalorfijo(67, '
            || pidioma
            || ', d.catribu) tmodcom, NULL pcomisi, null ninialt, null nfinalt,  null ccriterio, null ndesde, null nhasta, null tcriterio
		                FROM productos p, detvalores d, codiram cod
		                WHERE NOT EXISTS(SELECT ''1''
		                                FROM comisionprod c, productos p2, comisionvig v
		                               WHERE p2.cramo = c.cramo
		                                 AND p2.cmodali = c.cmodali
		                                 AND p2.ctipseg = c.ctipseg
		                                 AND p2.ccolect = c.ccolect
		                                 AND c.ccomisi = v.ccomisi
		                                 AND c.finivig = v.finivig
		                                 AND v.ffinvig IS NULL
		                                 AND c.ccomisi = '
            || pccomisi
            || 'AND c.cmodcom = d.catribu
		                                 and p2.sproduc =  p.sproduc)
		               AND d.cvalor = 67
		               AND d.cidioma = '
            || pidioma
            || 'and cod.cempres = pac_iax_common.f_get_cxtempresa
		                         and cod.cramo = p.cramo'
            || ' union
		    SELECT p.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1, '
            || pidioma
            || ') ttitulo,
		       f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 2, '
            || pidioma
            || ') trotulo,
		       a.cactivi cactivi,
		       (SELECT tactivi
		          FROM activisegu
		         WHERE cidioma = '
            || pidioma
            || '
		           AND cramo = p.cramo
		           AND cactivi = a.cactivi) tactivi, NULL cgarant, NULL tgarant, 2 nivel, NULL ccomisi,
		       NULL finivig, d.catribu cmodcom, ff_desvalorfijo(67, '
            || pidioma
            || ', d.catribu) tmodcom,
		       NULL pcomisi, null ninialt, null nfinalt,  null ccriterio, null ndesde, null nhasta, null tcriterio
		  FROM productos p, detvalores d, activiprod a, codiram cod
		 WHERE d.cvalor = 67
		   AND d.cidioma = '
            || pidioma
            || '
		   and cod.cempres = pac_iax_common.f_get_cxtempresa
		   and cod.cramo = p.cramo
		   AND a.cmodali = p.cmodali
		   AND a.cramo = p.cramo
		   AND a.ccolect = p.ccolect
		   AND a.ctipseg = p.ctipseg
		   AND NOT EXISTS(SELECT ''1''
		                    FROM comisionacti c, productos p2, comisionvig v
		                   WHERE p.cramo = c.cramo
		                     AND p.cmodali = c.cmodali
		                     AND p.ctipseg = c.ctipseg
		                     AND p.ccolect = c.ccolect
		                     AND c.ccomisi = v.ccomisi
		                     AND c.finivig = v.finivig
		                     AND v.ffinvig IS NULL
		                     AND c.ccomisi = '
            || pccomisi
            || 'AND p2.sproduc = p.sproduc
		                     AND c.cmodcom = d.catribu
		                     AND c.cactivi = a.cactivi)'
            || '
		    union
		    SELECT p.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1, '
            || pidioma
            || ') ttitulo,
		       f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 2, '
            || pidioma
            || ') trotulo, g.cactivi,
		       (SELECT tactivi
		          FROM activisegu
		         WHERE cidioma = '
            || pidioma
            || '
		           AND cramo = p.cramo
		           AND cactivi = g.cactivi) tactivi, g.cgarant, ff_desgarantia(g.cgarant, '
            || pidioma
            || ') tgarant,
		       3 nivel, NULL ccomisi, NULL finivig, d.catribu cmodcom,
		       ff_desvalorfijo(67, '
            || pidioma
            || ', d.catribu) tmodcom, NULL pcomisi, null ninialt, null nfinalt, null ccriterio, null ndesde, null nhasta, null tcriterio
		  FROM productos p, detvalores d, garanpro g, codiram cod
		 WHERE d.cvalor = 67
		   AND d.cidioma = '
            || pidioma
            || '
		   and cod.cempres = pac_iax_common.f_get_cxtempresa
		   and cod.cramo = p.cramo
		   AND g.cmodali = p.cmodali
		   AND g.ccolect = p.ccolect
		   AND g.ctipseg = p.ctipseg
		   AND g.cramo = p.cramo
		   AND NOT EXISTS(SELECT ''1''
		                    FROM comisiongar c, productos p2, comisionvig v
		                   WHERE p2.cramo = c.cramo
		                     AND p2.cmodali = c.cmodali
		                     AND p2.ctipseg = c.ctipseg
		                     AND p2.ccolect = c.ccolect
		                     AND c.ccomisi = v.ccomisi
		                     AND c.finivig = v.finivig
		                     AND v.ffinvig IS NULL
		                     AND c.ccomisi = '
            || pccomisi
            || '
		                     AND p2.sproduc = p.sproduc
		                     AND c.cmodcom = d.catribu
		                     AND c.cactivi = g.cactivi
		                     AND c.cgarant = g.cgarant)';
         vquery := vquery || vquery_tot;
      END IF;

      IF porderby IS NULL
         OR porderby = 1 THEN
         vorder :=
            vorder
            || ') ORDER BY sproduc ASC, cactivi DESC, cgarant DESC, ccomisi, cmodcom, ninialt';
      ELSIF porderby = 2 THEN
         vorder :=
            vorder
            || ') ORDER BY ccomisi, cmodcom, sproduc ASC, cactivi DESC, cgarant DESC, ninialt';
      END IF;

      pquery := vquery || vorder;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_detalle_comision;

   FUNCTION f_set_detalle_comision(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pfinivig IN DATE,
      pcmodcom IN NUMBER,
      pccomisi IN NUMBER,
      ppcomisi IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER,
      pccriterio IN NUMBER,
      pndesde IN NUMBER,
      pnhasta IN NUMBER)
      RETURN NUMBER IS
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vpcomisi       NUMBER;
      vfinivig       DATE;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      IF pccriterio IS NULL THEN
         vpcomisi := ppcomisi;
      ELSE
         vpcomisi := 0;
      END IF;

      IF pcgarant IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM comisiongar
                WHERE ccomisi = pccomisi
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cmodcom = pcmodcom;

               /*bug 32077*/
               IF vfinivig IS NULL THEN
                  SELECT MAX(finivig)
                    INTO vfinivig
                    FROM comisionvig
                   WHERE ccomisi = pccomisi;
               END IF;
            END IF;

            INSERT INTO comisiongar
                        (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi,
                         cmodcom, pcomisi, sproduc, finivig,
                         ninialt, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcgarant, pccomisi,
                         pcmodcom, vpcomisi, psproduc, NVL(pfinivig, vfinivig),
                         NVL(pninialt, 1), pnfinalt);

            /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1, 'pccriterio'||pccriterio, SQLERRM);*/
            IF pccriterio IS NOT NULL THEN
               BEGIN
                  INSERT INTO comisiongar_criterio
                              (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                               ccomisi, cmodcom, ninialt, nfinalt, ccriterio,
                               finivig, ffinvig, ndesde, nhasta, pcomisi,
                               falta, cusualta)
                       VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcgarant,
                               pccomisi, pcmodcom, NVL(pninialt, 1), pnfinalt, pccriterio,
                               NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                               f_sysdate, f_user);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE comisiongar_criterio
                        SET pcomisi = ppcomisi,
                            nfinalt = pnfinalt,
                            ccriterio = pccriterio,
                            ndesde = pndesde,
                            nhasta = pnhasta
                      WHERE cramo = vcramo
                        AND cmodali = vcmodali
                        AND ctipseg = vctipseg
                        AND ccolect = vccolect
                        AND cactivi = pcactivi
                        AND cgarant = pcgarant
                        AND ccomisi = pccomisi
                        AND cmodcom = pcmodcom
                        AND finivig = NVL(pfinivig, vfinivig)
                        AND ninialt = NVL(pninialt, 1);
               END;
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE comisiongar
                  SET pcomisi = ppcomisi,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);

               /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1, 'pccriterio'||pccriterio, SQLERRM);*/
               IF pccriterio IS NOT NULL THEN
                  BEGIN
                     INSERT INTO comisiongar_criterio
                                 (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant,
                                  ccomisi, cmodcom, ninialt, nfinalt, ccriterio,
                                  finivig, ffinvig, ndesde, nhasta, pcomisi,
                                  falta, cusualta)
                          VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcgarant,
                                  pccomisi, pcmodcom, NVL(pninialt, 1), pnfinalt, pccriterio,
                                  NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                                  f_sysdate, f_user);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE comisiongar_criterio
                           SET pcomisi = ppcomisi,
                               nfinalt = pnfinalt,
                               ccriterio = pccriterio,
                               ndesde = pndesde,
                               nhasta = pnhasta
                         WHERE cramo = vcramo
                           AND cmodali = vcmodali
                           AND ctipseg = vctipseg
                           AND ccolect = vccolect
                           AND cactivi = pcactivi
                           AND cgarant = pcgarant
                           AND ccomisi = pccomisi
                           AND cmodcom = pcmodcom
                           AND finivig = NVL(pfinivig, vfinivig)
                           AND ninialt = NVL(pninialt, 1);
                  END;
               END IF;
         END;
      ELSIF pcactivi IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM comisionacti
                WHERE ccomisi = pccomisi
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cmodcom = pcmodcom;

               /*bug 32077*/
               IF vfinivig IS NULL THEN
                  SELECT MAX(finivig)
                    INTO vfinivig
                    FROM comisionvig
                   WHERE ccomisi = pccomisi;
               END IF;
            END IF;

            INSERT INTO comisionacti
                        (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom,
                         pcomisi, sproduc, finivig, ninialt,
                         nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pccomisi, pcmodcom,
                         vpcomisi, psproduc, NVL(pfinivig, vfinivig), NVL(pninialt, 1),
                         pnfinalt);

            /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1,'pccriterio'||pccriterio, SQLERRM);*/
            IF pccriterio IS NOT NULL THEN
               BEGIN
                  INSERT INTO comisionacti_criterio
                              (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi,
                               cmodcom, ninialt, nfinalt, ccriterio,
                               finivig, ffinvig, ndesde, nhasta, pcomisi,
                               falta, cusualta)
                       VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pccomisi,
                               pcmodcom, NVL(pninialt, 1), pnfinalt, pccriterio,
                               NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                               f_sysdate, f_user);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE comisionacti_criterio
                        SET pcomisi = ppcomisi,
                            nfinalt = pnfinalt,
                            ccriterio = pccriterio,
                            ndesde = pndesde,
                            nhasta = pnhasta
                      WHERE cramo = vcramo
                        AND cmodali = vcmodali
                        AND ctipseg = vctipseg
                        AND ccolect = vccolect
                        AND cactivi = pcactivi
                        AND ccomisi = pccomisi
                        AND cmodcom = pcmodcom
                        AND finivig = NVL(pfinivig, vfinivig)
                        AND ninialt = NVL(pninialt, 1);
               END;
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE comisionacti
                  SET pcomisi = vpcomisi,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);

               /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1,'pccriterio'||pccriterio, SQLERRM);*/
               IF pccriterio IS NOT NULL THEN
                  BEGIN
                     INSERT INTO comisionacti_criterio
                                 (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi,
                                  cmodcom, ninialt, nfinalt, ccriterio,
                                  finivig, ffinvig, ndesde, nhasta, pcomisi,
                                  falta, cusualta)
                          VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pccomisi,
                                  pcmodcom, NVL(pninialt, 1), pnfinalt, pccriterio,
                                  NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                                  f_sysdate, f_user);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE comisionacti_criterio
                           SET pcomisi = ppcomisi,
                               nfinalt = pnfinalt,
                               ccriterio = pccriterio,
                               ndesde = pndesde,
                               nhasta = pnhasta
                         WHERE cramo = vcramo
                           AND cmodali = vcmodali
                           AND ctipseg = vctipseg
                           AND ccolect = vccolect
                           AND cactivi = pcactivi
                           AND ccomisi = pccomisi
                           AND cmodcom = pcmodcom
                           AND finivig = NVL(pfinivig, vfinivig)
                           AND ninialt = NVL(pninialt, 1);
                  END;
               END IF;
         END;
      ELSIF psproduc IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM comisionprod
                WHERE ccomisi = pccomisi
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cmodcom = pcmodcom;

               /*bug 32077*/
               IF vfinivig IS NULL THEN
                  SELECT MAX(finivig)
                    INTO vfinivig
                    FROM comisionvig
                   WHERE ccomisi = pccomisi;
               END IF;
            END IF;

            INSERT INTO comisionprod
                        (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi,
                         sproduc, finivig, ninialt, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pccomisi, pcmodcom, vpcomisi,
                         psproduc, NVL(pfinivig, vfinivig), NVL(pninialt, 1), pnfinalt);

            /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1,'pccriterio'||pccriterio, SQLERRM);*/
            IF pccriterio IS NOT NULL THEN
               BEGIN
                  INSERT INTO comisionprod_criterio
                              (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom,
                               ninialt, nfinalt, ccriterio,
                               finivig, ffinvig, ndesde, nhasta, pcomisi,
                               falta, cusualta)
                       VALUES (vcramo, vcmodali, vctipseg, vccolect, pccomisi, pcmodcom,
                               NVL(pninialt, 1), pnfinalt, pccriterio,
                               NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                               f_sysdate, f_user);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE comisionprod_criterio
                        SET pcomisi = ppcomisi,
                            nfinalt = pnfinalt,
                            ccriterio = pccriterio,
                            ndesde = pndesde,
                            nhasta = pnhasta
                      WHERE cramo = vcramo
                        AND cmodali = vcmodali
                        AND ctipseg = vctipseg
                        AND ccolect = vccolect
                        AND ccomisi = pccomisi
                        AND cmodcom = pcmodcom
                        AND finivig = NVL(pfinivig, vfinivig)
                        AND ninialt = NVL(pninialt, 1);
               END;
            END IF;
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE comisionprod
                  SET pcomisi = vpcomisi,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);

               /*p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_comision', 1,'pccriterio'||pccriterio, SQLERRM);*/
               IF pccriterio IS NOT NULL THEN
                  BEGIN
                     INSERT INTO comisionprod_criterio
                                 (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom,
                                  ninialt, nfinalt, ccriterio,
                                  finivig, ffinvig, ndesde, nhasta, pcomisi,
                                  falta, cusualta)
                          VALUES (vcramo, vcmodali, vctipseg, vccolect, pccomisi, pcmodcom,
                                  NVL(pninialt, 1), pnfinalt, pccriterio,
                                  NVL(pfinivig, vfinivig), NULL, pndesde, pnhasta, ppcomisi,
                                  f_sysdate, f_user);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE comisionprod_criterio
                           SET pcomisi = ppcomisi,
                               nfinalt = pnfinalt,
                               ccriterio = pccriterio,
                               ndesde = pndesde,
                               nhasta = pnhasta
                         WHERE cramo = vcramo
                           AND cmodali = vcmodali
                           AND ctipseg = vctipseg
                           AND ccolect = vccolect
                           AND ccomisi = pccomisi
                           AND cmodcom = pcmodcom
                           AND finivig = NVL(pfinivig, vfinivig)
                           AND ninialt = NVL(pninialt, 1);
                  END;
               END IF;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_set_detalle_comision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_detalle_comision;

   FUNCTION f_get_hist_cuadrocomision(
      pccomisi IN NUMBER,
      pidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := ' SELECT C.CCOMISI,D.TCOMISI,C.CTIPO,V.FINIVIG,V.FFINVIG,V.CESTADO'
                || ' FROM CODICOMISIO C,COMISIONVIG V,DESCOMISION D'
                || ' WHERE c.CCOMISI = v.CCOMISI' || ' AND v.ccomisi = d.CCOMISI'
                || ' AND d.CIDIOMA =' || pidioma || ' AND (c.CCOMISI = ''' || pccomisi
                || ''' or ''' || pccomisi
                || ''' IS NULL)
		                order by finivig desc ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.hist_cuadrocomision', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_hist_cuadrocomision;

   /*************************************************************************
      Devuelve los cuadros de comision con su % si lo tiene asignado
      param in psproduc   : codigo de producto
      param in pcactivi   : codigo de la actividad
      param in pcgarant   : codigo de la garantia
      param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
      param in pidioma    : codigo de idioma
      param out psquery   : consulta a ejecutar

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_porproducto(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcfinivig IN DATE,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      /* BUG16363:JBL:31/05/2011:Inici*/
      IF pcnivel = 1 THEN
         psquery :=
            ' SELECT b.tcomisi, b.ccomisi, pc.pcomisi, pc.ninialt, pc.nfinalt, b.cmodcom, b.tmodcom, pc.finivig'
            || ' ,pc.ccriterio, pc.ndesde, pc.nhasta, pc.tcriterio'
            || ' FROM (SELECT d.tcomisi, d.ccomisi, v.catribu cmodcom, v.tatribu tmodcom'
            || ' FROM codicomisio cc, descomision d, detvalores v'
            || ' WHERE d.ccomisi = cc.ccomisi' || ' AND d.cidioma =' || pcidioma
            || ' AND v.cvalor = 67' || ' AND v.cidioma = d.cidioma) b,'
            || ' (SELECT cp.ccomisi, cp.pcomisi , cp.cmodcom, cp.ninialt, cp.nfinalt, cp.finivig'
            || ' ,cp.ccriterio, cp.ndesde, cp.nhasta, ff_desvalorfijo(67, ' || pcidioma
            || ' ,cp.ccriterio) tcriterio' || ' FROM productos p, comisionprod cp'
            || ' WHERE p.sproduc = ' || psproduc
            || ' AND cp.finivig = (SELECT MAX(finivig) FROM comisionprod ccp WHERE ccp.ccomisi = cp.ccomisi) '   -- || CHR(39)
            /*|| pcfinivig || CHR(39)*/
            || ' AND p.cramo = cp.cramo' || ' AND p.cmodali = cp.cmodali'
            || ' AND p.ctipseg = cp.ctipseg' || ' AND p.ccolect = cp.ccolect) pc'
            || ' WHERE b.ccomisi = pc.ccomisi(+)' || ' AND b.cmodcom = pc.cmodcom(+)'
            || ' order by ccomisi,cmodcom,ninialt';
      ELSIF pcnivel = 2 THEN
         psquery :=
            ' SELECT b.tcomisi, b.ccomisi, pc.pcomisi, pc.ninialt, pc.nfinalt, b.cmodcom, b.tmodcom, pc.finivig'
            || ' ,pc.ccriterio, pc.ndesde, pc.nhasta, pc.tcriterio'
            || ' FROM (SELECT d.tcomisi, d.ccomisi, v.catribu cmodcom, v.tatribu tmodcom'
            || ' FROM codicomisio cc, descomision d, detvalores v'
            || ' WHERE d.ccomisi = cc.ccomisi' || ' AND d.cidioma =' || pcidioma
            || ' AND v.cvalor = 67' || ' AND v.cidioma = d.cidioma) b,'
            || ' (SELECT ca.ccomisi, ca.pcomisi, ca.cmodcom, ca.ninialt, ca.nfinalt, ca.finivig'
            || ' ,ca.ccriterio, ca.ndesde, ca.nhasta, ff_desvalorfijo(67, ' || pcidioma
            || ', ca.ccriterio) tcriterio' || ' FROM comisionacti ca, productos p'
            || ' WHERE p.sproduc = ' || psproduc || ' AND ca.cactivi = ' || pcactivi
            || ' AND ca.finivig = ' || CHR(39) || pcfinivig || CHR(39)
            || ' AND p.cramo = ca.cramo' || ' AND p.cmodali = ca.cmodali'
            || ' AND p.ctipseg = ca.ctipseg' || ' AND p.ccolect = ca.ccolect) pc'
            || ' WHERE b.ccomisi = pc.ccomisi(+)' || ' AND b.cmodcom = pc.cmodcom(+)'
            || ' order by ccomisi,cmodcom,ninialt';
      ELSIF pcnivel = 3 THEN
         psquery :=
            ' SELECT b.tcomisi, b.ccomisi, pc.pcomisi, pc.ninialt, pc.nfinalt, b.cmodcom, b.tmodcom, pc.finivig'
            || ' ,pc.ccriterio, pc.ndesde, pc.nhasta, pc.tcriterio'
            || ' FROM (SELECT d.tcomisi, d.ccomisi, v.catribu cmodcom, v.tatribu tmodcom'
            || ' FROM codicomisio cc, descomision d, detvalores v'
            || ' WHERE d.ccomisi = cc.ccomisi' || ' AND d.cidioma =' || pcidioma
            || ' AND v.cvalor = 67' || ' AND v.cidioma = d.cidioma) b,'
            || ' (SELECT cg.ccomisi, cg.pcomisi,  cg.cmodcom, cg.ninialt, cg.nfinalt, cg.finivig'
            || ' ,cg.ccriterio, cg.ndesde, cg.nhasta, ff_desvalorfijo(67, ' || pcidioma
            || ', cg.ccriterio) tcriterio' || ' FROM comisiongar cg, productos p'
            || ' WHERE p.sproduc = ' || psproduc || ' AND cg.cactivi = ' || pcactivi
            || ' AND cg.cgarant = ' || pcgarant || ' AND cg.finivig = ' || CHR(39)
            || pcfinivig || CHR(39) || ' AND p.cramo = cg.cramo'
            || ' AND p.cmodali = cg.cmodali' || ' AND p.ctipseg = cg.ctipseg'
            || ' AND p.ccolect = cg.ccolect) pc' || ' WHERE b.ccomisi = pc.ccomisi(+)'
            || ' AND b.cmodcom = pc.cmodcom(+)' || ' order by ccomisi,cmodcom,ninialt';
      END IF;

      /* BUG16363:JBL:31/05/2011:Fi*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_porproducto', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_porproducto;

   /****************************************************************
      Duplica el detalle de comisi贸n apartir de un ccomisi y una fecha
      param in pccomisi   : codigo de comisi贸n
      param in pfinivi   : Fecha de inicio de vigencia      return : codigo de error
   *************************************************************************/
   FUNCTION f_dup_det_comision(pccomisi IN NUMBER, pfinivig IN DATE)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER;
   BEGIN
      vpasexec := 1;

      INSERT INTO comisionprod
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi, sproduc,
                   finivig, ninialt, nfinalt)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.ccomisi, p.cmodcom, p.pcomisi,
                 p.sproduc, pfinivig, ninialt, nfinalt
            FROM comisionprod p, comisionvig v
           WHERE p.ccomisi = pccomisi
             AND p.ccomisi = v.ccomisi
             AND p.finivig = (SELECT NVL(MAX(cc.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
                                FROM comisionprod cc
                               WHERE cc.ccomisi = p.ccomisi
                                 AND cc.cramo = p.cramo
                                 AND cc.cmodali = p.cmodali
                                 AND cc.ctipseg = p.ctipseg
                                 AND cc.ccolect = p.ccolect
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      vpasexec := 2;

      INSERT INTO comisionacti
                  (ccomisi, cactivi, cramo, cmodcom, pcomisi, cmodali, ctipseg, ccolect,
                   sproduc, finivig, ninialt, nfinalt)
         (SELECT a.ccomisi, a.cactivi, a.cramo, a.cmodcom, a.pcomisi, a.cmodali, a.ctipseg,
                 a.ccolect, a.sproduc, pfinivig, ninialt, nfinalt
            FROM comisionacti a, comisionvig v
           WHERE a.ccomisi = pccomisi
             AND a.ccomisi = v.ccomisi
             AND a.finivig = (SELECT MAX(cc.finivig)
                                FROM comisionacti cc
                               WHERE cc.ccomisi = a.ccomisi
                                 AND cc.cramo = a.cramo
                                 AND cc.cmodali = a.cmodali
                                 AND cc.ctipseg = a.ctipseg
                                 AND cc.ccolect = a.ccolect
                                 AND cc.cactivi = a.cactivi
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      vpasexec := 3;

      INSERT INTO comisiongar
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                   pcomisi, sproduc, finivig, ninialt, nfinalt)
         (SELECT g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant, g.ccomisi,
                 g.cmodcom, g.pcomisi, g.sproduc, pfinivig, ninialt, nfinalt
            FROM comisiongar g, comisionvig v
           WHERE g.ccomisi = pccomisi
             AND g.ccomisi = v.ccomisi
             AND g.finivig = (SELECT MAX(cc.finivig)
                                FROM comisiongar cc
                               WHERE cc.ccomisi = g.ccomisi
                                 AND cc.cramo = g.cramo
                                 AND cc.cmodali = g.cmodali
                                 AND cc.ctipseg = g.ctipseg
                                 AND cc.ccolect = g.ccolect
                                 AND cc.cactivi = g.cactivi
                                 AND cc.cgarant = g.cgarant
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      /*INI RAL BUG 0036900: No se gener?distribucion de acceso preferente y uso de canal en comisiones de La Araucana (bug hermano interno)*/
      /*Arrastrar desglose de la vigencia*/
      BEGIN
         vpasexec := 4;

         INSERT INTO comisionprod_concep
                     (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, finivig, ninialt,
                      cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.ccomisi, c.cmodcom, pfinivig,
                    c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionprod_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisionprod_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.finivig >= v.finivig)
                AND v.ffinvig =(pfinivig - 1));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_dup_det_comision', vpasexec,
                        'No existen comisiones desglosadas de Productos', SQLERRM);
      END;

      vpasexec := 5;

      BEGIN
         INSERT INTO comisionacti_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom, finivig,
                      ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.ccomisi, c.cmodcom,
                    pfinivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionacti_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisionacti_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.cactivi = c.cactivi
                                    AND c2.finivig >= v.finivig)
                AND v.ffinvig =(pfinivig - 1));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_dup_det_comision', vpasexec,
                        'No existen comisiones desglosadas de Actividades', SQLERRM);
      END;

      vpasexec := 6;

      BEGIN
         INSERT INTO comisiongar_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                      finivig, ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.cgarant, c.ccomisi,
                    c.cmodcom, pfinivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc,
                    c.nfinalt
               FROM comisiongar_concep c, comisionvig v
              WHERE c.ccomisi = pccomisi
                AND c.ccomisi = v.ccomisi
                AND c.finivig = (SELECT MAX(c2.finivig)
                                   FROM comisiongar_concep c2
                                  WHERE c2.ccomisi = c.ccomisi
                                    AND c2.cramo = c.cramo
                                    AND c2.cmodali = c.cmodali
                                    AND c2.ctipseg = c.ctipseg
                                    AND c2.ccolect = c.ccolect
                                    AND c2.cactivi = c.cactivi
                                    AND c2.cgarant = c.cgarant
                                    AND c2.finivig >= v.finivig)
                AND v.ffinvig =(pfinivig - 1));
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_dup_det_comision', vpasexec,
                        'No existen comisiones desglosadas de Garant韆s', SQLERRM);
      END;

      /*FIN RAL BUG 0036900: No se gener?distribucion de acceso preferente y uso de canal en comisiones de La Araucana (bug hermano interno)*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_dup_det_comision', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_dup_det_comision;

   /*************************************************************************
      Anula comisi贸n recibo.
      param in p_NRECIBO : N煤mero recibo
      param in p_CESTREC : Estado recibo
      param in p_FMOVDIA : Fecha d铆a que se hace el movimiento
      param in p_ICOMBRU : Comisi贸n bruta
      param in p_ICOMRET : Retenci贸n s/Comisi贸n
      param in p_ICOMDEV : Comisi贸n devengada
      param in p_IRETDEV : Retenci贸n devengada
      return             : 0=OK, 1=Error

      Bug 0016305 - 19/10/2010 - JMF
   *************************************************************************/
   FUNCTION f_anu_comisionrec(
      p_nrecibo IN NUMBER,
      p_cestrec IN NUMBER,
      p_fmovdia IN DATE,
      p_icombru IN NUMBER DEFAULT NULL,
      p_icomret IN NUMBER DEFAULT NULL,
      p_icomdev IN NUMBER DEFAULT NULL,
      p_iretdev IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL, /* BUG22402:DRA:29/10/2012*/
      p_ctipcom IN VARCHAR2 DEFAULT 'TRASPASO')
      RETURN NUMBER IS
      v_tobj         VARCHAR2(500) := 'PAC_COMISIONES.F_ANU_COMISIONREC';
      v_tpar         VARCHAR2(2000)
         := 'p_nrecibo=' || p_nrecibo || ' p_cestrec=' || p_cestrec || ' p_fmovdia='
            || TO_CHAR(p_fmovdia, 'dd-mm-yyyy') || ' p_icombru=' || p_icombru || ' p_icomret='
            || p_icomret || ' p_icomdev=' || p_icomdev || ' p_iretdev=' || p_iretdev
            || ' p_cagente=' || p_cagente || ' p_cgarant=' || p_cgarant || ' p_ctipcom='
            || p_ctipcom;
      v_ntra         NUMBER(5) := 1;
      n_nnumcom      comrecibo.nnumcom%TYPE;
      n_cagente      comrecibo.cagente%TYPE;
      d_fcontab      comrecibo.fcontab%TYPE;
      n_err          NUMBER;
      d_hoy          DATE;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      e_salir        EXCEPTION;
      v_cempres      recibos.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_femisio      DATE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmoncia      parempresas.nvalpar%TYPE;
      v_cmonpol      monedas.cmoneda%TYPE;
   BEGIN
      v_ntra := 1;
      n_err := 0;

      SELECT MAX(a.cagente), TRUNC(f_sysdate), MAX(b.nnumcom), MAX(a.cempres), MAX(a.femisio)
        INTO n_cagente, d_hoy, n_nnumcom, v_cempres, v_femisio
        FROM recibos a, comrecibo b
       WHERE a.nrecibo = p_nrecibo
         AND b.nrecibo(+) = a.nrecibo;

      v_ntra := 2;

      /* BUG19069:DRA:03/10/2011:Inici*/
      SELECT sseguro
        INTO v_sseguro
        FROM recibos
       WHERE nrecibo = p_nrecibo;

      v_ntra := 4;

      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = v_sseguro;

      IF p_cagente IS NOT NULL THEN
         n_cagente := p_cagente;
      END IF;

      /* BUG19069:DRA:03/10/2011:Fi*/
      v_ntra := 3;

      IF n_cagente IS NULL THEN
         n_err := 101731;
         RAISE e_salir;
      END IF;

      v_ntra := 4;
      /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(v_cempres, 'MONEDAEMP');
         n_err := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, v_femisio, 2,
                                                     v_itasa, v_fcambio);
         /*Bug 29237: Diferencia Valores Poliza Cocorretaje   MCA*/
         v_ntra := 6;

         SELECT NVL(cdivisa, v_cmoncia)
           INTO v_cmonpol
           FROM seguros s, productos p
          WHERE s.sproduc = p.sproduc
            AND sseguro = v_sseguro;

         /*Bug 29237  Fin*/
         IF n_err <> 0 THEN
            RAISE e_salir;
         END IF;
      END IF;

      /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
      IF n_nnumcom IS NULL
         AND NVL(p_ctipcom, 'TRASPASO') = 'TRASPASO' THEN
         /* Si no existe, creamos registro con la comisi贸n actual.*/
         v_ntra := 3;
         n_nnumcom := 1;

         SELECT MAX(fefeadm)
           INTO d_fcontab
           FROM movrecibo
          WHERE nrecibo = p_nrecibo
            AND fmovdia = p_fmovdia
            AND cestrec = p_cestrec;

         IF d_fcontab IS NULL THEN
            n_err := 104939;
            RAISE e_salir;
         END IF;

         v_ntra := 5;

         INSERT INTO comrecibo
                     (nrecibo, nnumcom, cagente, cestrec, fmovdia, fcontab,
                      icombru,
                      icomret,
                      icomdev,
                      iretdev, nmovimi,
                      /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                      icombru_moncia,
                      icomret_moncia,
                      icomdev_moncia,
                      iretdev_moncia,
                      fcambio,
                              /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                              cgarant)   /* BUG22402:DRA:29/10/2012*/
              VALUES (p_nrecibo, n_nnumcom, n_cagente, p_cestrec, p_fmovdia, d_fcontab,
                      f_round(NVL(p_icombru, 0), v_cmonpol), /*Bug 29237*/
                      f_round(NVL(p_icomret, 0), v_cmonpol),
                      f_round(NVL(p_icomdev, 0), v_cmonpol),
                      f_round(NVL(p_iretdev, 0), v_cmonpol), /*Bug 29237 fin*/ v_nmovimi, /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                      f_round(NVL(p_icombru, 0) * v_itasa, v_cmoncia),
                      f_round(NVL(p_icomret, 0) * v_itasa, v_cmoncia),
                      f_round(NVL(p_icomdev, 0) * v_itasa, v_cmoncia),
                      f_round(NVL(p_iretdev, 0) * v_itasa, v_cmoncia),
                      DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, v_femisio)),
                                                                              /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                                                                              p_cgarant);   /* BUG22402:DRA:29/10/2012*/
      END IF;

      v_ntra := 7;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CONTA_DIA'), 0) = 1 THEN
         d_fcontab := NULL;
      ELSE
         d_fcontab := d_hoy;
      END IF;

      n_nnumcom := NVL(n_nnumcom, 0) + 1;
      v_ntra := 9;

      /* Registro con los importes negativos*/
      INSERT INTO comrecibo
                  (nrecibo, nnumcom, cagente, cestrec, fmovdia, fcontab,
                   icombru,
                   icomret,
                   icomdev,
                   iretdev, nmovimi,
                   /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                   icombru_moncia,
                   icomret_moncia,
                   icomdev_moncia,
                   iretdev_moncia,
                   fcambio,
                           /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                           cgarant)   /* BUG22402:DRA:29/10/2012*/
           VALUES (p_nrecibo, n_nnumcom, n_cagente, p_cestrec, p_fmovdia, d_fcontab,
                   f_round(NVL(p_icombru, 0), v_cmonpol) *(-1), /*Bug 29237*/
                   f_round(NVL(p_icomret, 0), v_cmonpol) *(-1),
                   f_round(NVL(p_icomdev, 0), v_cmonpol) *(-1),
                   f_round(NVL(p_iretdev, 0), v_cmonpol) *(-1), /*Bug 29237 Fin*/ v_nmovimi, /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                   f_round(NVL(p_icombru, 0) *(-1) * v_itasa, v_cmoncia),
                   f_round(NVL(p_icomret, 0) *(-1) * v_itasa, v_cmoncia),
                   f_round(NVL(p_icomdev, 0) *(-1) * v_itasa, v_cmoncia),
                   f_round(NVL(p_iretdev, 0) *(-1) * v_itasa, v_cmoncia),
                   DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, v_femisio)),
                                                                           /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                                                                           p_cgarant);   /* BUG22402:DRA:29/10/2012*/

      v_ntra := 11;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, v_tobj, v_ntra, v_tpar, n_err);
         RETURN n_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobj, v_ntra, v_tpar, SQLCODE || ' ' || SQLERRM);
         RETURN 108190;
   END f_anu_comisionrec;

   /*************************************************************************
      Alta comisi贸n recibo.
      param in p_NRECIBO : N煤mero recibo
      param in p_CESTREC : Estado recibo
      param in p_FMOVDIA : Fecha d铆a que se hace el movimiento
      param in p_ICOMBRU : Comisi贸n bruta
      param in p_ICOMRET : Retenci贸n s/Comisi贸n
      param in p_ICOMDEV : Comisi贸n devengada
      param in p_IRETDEV : Retenci贸n devengada
      return             : 0=OK, 1=Error

      Bug 0016305 - 19/10/2010 - JMF
   *************************************************************************/
   FUNCTION f_alt_comisionrec(
      p_nrecibo IN NUMBER,
      p_cestrec IN NUMBER,
      p_fmovdia IN DATE,
      p_icombru IN NUMBER DEFAULT NULL,
      p_icomret IN NUMBER DEFAULT NULL,
      p_icomdev IN NUMBER DEFAULT NULL,
      p_iretdev IN NUMBER DEFAULT NULL,
      p_cagente IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL, /* BUG22402:DRA:29/10/2012*/
      p_icomcedida IN NUMBER DEFAULT NULL,
      p_ccompan IN NUMBER DEFAULT 0) -- IAXIS-5040 - JLTS - 17/08/2019
      RETURN NUMBER IS
      v_tobj         VARCHAR2(500) := 'PAC_COMISIONES.F_ALT_COMISIONREC';
      v_tpar         VARCHAR2(2000)
         := 'p_nrecibo=' || p_nrecibo || ' p_cestrec=' || p_cestrec || ' p_fmovdia='
            || TO_CHAR(p_fmovdia, 'dd-mm-yyyy') || ' p_icombru=' || p_icombru || ' p_icomret='
            || p_icomret || ' p_icomdev=' || p_icomdev || ' p_iretdev=' || p_iretdev
            || ' p_cagente=' || p_cagente || ' p_cgarant=' || p_cgarant;
      v_ntra         NUMBER(5) := 1;
      n_nnumcom      comrecibo.nnumcom%TYPE;
      n_cagente      comrecibo.cagente%TYPE;
      d_fcontab      comrecibo.fcontab%TYPE;
      n_err          NUMBER;
      d_hoy          DATE;
      e_salir        EXCEPTION;
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_sseguro      seguros.sseguro%TYPE;
      v_cempres      recibos.cempres%TYPE;
      v_cmultimon    parempresas.nvalpar%TYPE;
      v_femisio      DATE;
      v_itasa        eco_tipocambio.itasa%TYPE;
      v_fcambio      DATE;
      v_cmoncia      parempresas.nvalpar%TYPE;
      v_cmonpol      monedas.cmoneda%TYPE;
   BEGIN
      v_ntra := 1;
      n_err := 0;

      SELECT MAX(a.cagente), TRUNC(f_sysdate), MAX(b.nnumcom), MAX(a.cempres), MAX(a.femisio)
        INTO n_cagente, d_hoy, n_nnumcom, v_cempres, v_femisio
        FROM recibos a, comrecibo b
       WHERE a.nrecibo = p_nrecibo
         AND b.nrecibo(+) = a.nrecibo;

      v_ntra := 3;

      /* BUG19069:DRA:03/10/2011:Inici*/
      SELECT sseguro
        INTO v_sseguro
        FROM recibos
       WHERE nrecibo = p_nrecibo;

      v_ntra := 4;

      SELECT MAX(nmovimi)
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = v_sseguro;

      v_ntra := 5;

      IF p_cagente IS NOT NULL THEN
         n_cagente := p_cagente;
      END IF;

      /* BUG19069:DRA:03/10/2011:Fi*/
      /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 1 THEN
         v_cmoncia := pac_parametros.f_parempresa_n(v_cempres, 'MONEDAEMP');
         n_err := pac_oper_monedas.f_datos_contraval(NULL, p_nrecibo, NULL, v_femisio, 2,
                                                     v_itasa, v_fcambio);
         /*Bug 29237: Diferencia Valores Poliza Cocorretaje   MCA*/
         v_ntra := 6;

         SELECT NVL(cdivisa, v_cmoncia)
           INTO v_cmonpol
           FROM seguros s, productos p
          WHERE s.sproduc = p.sproduc
            AND sseguro = v_sseguro;

         /*Bug 29237  Fin*/
         IF n_err <> 0 THEN
            RAISE e_salir;
         END IF;
      END IF;

      /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
      v_ntra := 7;

      IF n_cagente IS NULL THEN
         n_err := 101731;
         RAISE e_salir;
      END IF;

      v_ntra := 8;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'CONTA_DIA'), 0) = 1 THEN
         d_fcontab := NULL;
      ELSE
         d_fcontab := d_hoy;
      END IF;

      n_nnumcom := NVL(n_nnumcom, 0) + 1;
      v_ntra := 9;
      -- INI - IAXIS-5040 - JLTS - 17/08/2019
      INSERT INTO comrecibo
                  (nrecibo, nnumcom, cagente, cestrec, fmovdia, fcontab,
                   icombru,
                   icomret,
                   icomdev,
                   iretdev, nmovimi,
                   /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                   icombru_moncia,
                   icomret_moncia,
                   icomdev_moncia,
                   iretdev_moncia,
                   fcambio,
                           /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                           cgarant, /* BUG22402:DRA:29/10/2012*/
                   icomcedida,
                   icomcedida_moncia,
                   ccompan )
           VALUES (p_nrecibo, n_nnumcom, n_cagente, p_cestrec, p_fmovdia, d_fcontab,
                   f_round(NVL(p_icombru, 0), v_cmonpol), /*Bug 29237*/
                   f_round(NVL(p_icomret, 0), v_cmonpol),
                   f_round(NVL(p_icomdev, 0), v_cmonpol),
                   f_round(NVL(p_iretdev, 0), v_cmonpol), /*Bug 29237 Fin*/ v_nmovimi, /* BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                   f_round(NVL(p_icombru, 0) * v_itasa, v_cmoncia),
                   f_round(NVL(p_icomret, 0) * v_itasa, v_cmoncia),
                   f_round(NVL(p_icomdev, 0) * v_itasa, v_cmoncia),
                   f_round(NVL(p_iretdev, 0) * v_itasa, v_cmoncia),
                   DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, v_femisio)),
                                                                           /* FIN BUG 18423 - 02/11/2011 - JMP - LCOL705 - Multimoneda*/
                                                                           p_cgarant,
                   f_round(NVL(p_icomcedida, 0), v_cmonpol),
                   f_round(NVL(p_icomcedida, 0) * v_itasa, v_cmoncia),p_ccompan);   /* BUG22402:DRA:29/10/2012*/ 
        -- FIN - IAXIS-5040 - JLTS - 17/08/2019
      v_ntra := 11;
      RETURN 0;
   EXCEPTION
      WHEN e_salir THEN
         p_tab_error(f_sysdate, f_user, v_tobj, v_ntra, v_tpar, n_err);
         RETURN n_err;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_tobj, v_ntra, v_tpar, SQLCODE || ' ' || SQLERRM);
         RETURN 108190;
   END f_alt_comisionrec;

   /*************************************************************************
      Duplica un cuadro de comisiones de un producto
      param in pccomisi_ori   : codigo de comision original
      param in pccomisi_nuevo : codigo de comision nuevo
      param in ptcomisi_nuevo : texto cuadro comision
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro_prod(pcsproduc IN NUMBER, pcfinivig IN DATE)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER;
      vdatemax       DATE;
   BEGIN
      vpasexec := 1;

      SELECT NVL(MAX(p.finivig), TO_DATE('01/01/1900', 'dd/mm/yyyy'))
        INTO vdatemax
        FROM comisionprod p, productos prod
       WHERE p.cramo = prod.cramo
         AND p.cmodali = prod.cmodali
         AND p.ctipseg = prod.ctipseg
         AND p.ccolect = prod.ccolect
         AND prod.sproduc = pcsproduc;

      INSERT INTO comisionprod
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi, sproduc,
                   finivig, ninialt, nfinalt, ccriterio, ndesde, nhasta)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.ccomisi, p.cmodcom, p.pcomisi,
                p.sproduc, pcfinivig, ninialt, nfinalt, p.ccriterio, p.ndesde, p.nhasta
           FROM comisionprod p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      vpasexec := 5;

      INSERT INTO comisionacti
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi, sproduc,
                   finivig, cactivi, ninialt, nfinalt, ccriterio, ndesde, nhasta)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.ccomisi, p.cmodcom, p.pcomisi,
                p.sproduc, pcfinivig, p.cactivi, ninialt, nfinalt, p.ccriterio, p.ndesde,
                p.nhasta
           FROM comisionacti p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      vpasexec := 6;

      INSERT INTO comisiongar
                  (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, pcomisi, sproduc,
                   finivig, cactivi, cgarant, ninialt, nfinalt, ccriterio, ndesde, nhasta)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.ccomisi, p.cmodcom, p.pcomisi,
                p.sproduc, pcfinivig, p.cactivi, p.cgarant, ninialt, nfinalt, p.ccriterio,
                p.ndesde, p.nhasta
           FROM comisiongar p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      BEGIN
         vpasexec := 7;

         INSERT INTO comisionprod_concep
                     (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom, finivig, ninialt,
                      cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.ccomisi, c.cmodcom, pcfinivig,
                    c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionprod_concep c, productos prod
              WHERE c.cramo = prod.cramo
                AND c.cmodali = prod.cmodali
                AND c.ctipseg = prod.ctipseg
                AND c.ccolect = prod.ccolect
                AND prod.sproduc = pcsproduc
                AND c.finivig = vdatemax);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro_prod', vpasexec,
                        'No existen comisiones desglosadas de Productos', SQLERRM);
      END;

      vpasexec := 8;

      BEGIN
         INSERT INTO comisionacti_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom, finivig,
                      ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.ccomisi, c.cmodcom,
                    pcfinivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc, c.nfinalt
               FROM comisionacti_concep c, productos prod
              WHERE c.cramo = prod.cramo
                AND c.cmodali = prod.cmodali
                AND c.ctipseg = prod.ctipseg
                AND c.ccolect = prod.ccolect
                AND prod.sproduc = pcsproduc
                AND c.finivig = vdatemax);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro_prod', vpasexec,
                        'No existen comisiones desglosadas de Actividades', SQLERRM);
      END;

      vpasexec := 9;

      BEGIN
         INSERT INTO comisiongar_concep
                     (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi, cmodcom,
                      finivig, ninialt, cconcepto, pcomisi, sproduc, nfinalt)
            (SELECT c.cramo, c.cmodali, c.ctipseg, c.ccolect, c.cactivi, c.cgarant, c.ccomisi,
                    c.cmodcom, pcfinivig, c.ninialt, c.cconcepto, c.pcomisi, c.sproduc,
                    c.nfinalt
               FROM comisiongar_concep c, productos prod
              WHERE c.cramo = prod.cramo
                AND c.cmodali = prod.cmodali
                AND c.ctipseg = prod.ctipseg
                AND c.ccolect = prod.ccolect
                AND prod.sproduc = pcsproduc
                AND c.finivig = vdatemax);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro_prod', vpasexec,
                        'No existen comisiones desglosadas de Garant韆s', SQLERRM);
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_duplicar_cuadro', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_duplicar_cuadro_prod;

   /*************************************************************************
      Inserta el desglose del % de comision
      param in pcactivi     C贸digo de la actividad
      param in pcgarant     C贸digo de la garantia
      param in pccomisi     C贸digo comisi贸n
      param in pcmodcom     C贸digo de la modalidad de comisi贸n
      param in pfinivig     Fecha inicio vigencia comisi贸n
      param in pninialt     Inicio de la altura
      param in pcconcepto   C贸digo concepto
      param in ppcomisi     Porcentaje de comisi贸n
      param in psproduc     Codi producte
      param in pnfinalt     Fin de la altura

      return : codigo de error
      Bug 24905/131645 - 11/12/2012 - AMC
   *************************************************************************/
   FUNCTION f_set_comisiondesglose(
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccomisi IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      pcconcepto IN NUMBER,
      ppcomisi IN NUMBER,
      psproduc IN NUMBER,
      pnfinalt IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vfinivig       DATE;
   BEGIN
      vpasexec := 1;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      IF pcactivi IS NOT NULL
         AND pcgarant IS NOT NULL THEN
         IF pfinivig IS NULL THEN
            SELECT finivig
              INTO vfinivig
              FROM comisiongar
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = pcactivi
               AND cgarant = pcgarant
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND ninialt = pninialt;
         END IF;

         BEGIN
            vpasexec := 2;

            INSERT INTO comisiongar_concep
                        (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, ccomisi,
                         cmodcom, finivig, ninialt, cconcepto, pcomisi,
                         sproduc, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcgarant, pccomisi,
                         pcmodcom, NVL(pfinivig, vfinivig), pninialt, pcconcepto, ppcomisi,
                         psproduc, pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpasexec := 3;

               UPDATE comisiongar_concep
                  SET pcomisi = ppcomisi,
                      sproduc = psproduc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = pninialt
                  AND cconcepto = pcconcepto;
         END;
      ELSIF pcactivi IS NOT NULL THEN
         IF pfinivig IS NULL THEN
            SELECT finivig
              INTO vfinivig
              FROM comisionacti
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = pcactivi
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND ninialt = pninialt;
         END IF;

         BEGIN
            vpasexec := 2;

            INSERT INTO comisionacti_concep
                        (cramo, cmodali, ctipseg, ccolect, cactivi, ccomisi, cmodcom,
                         finivig, ninialt, cconcepto, pcomisi, sproduc,
                         nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pccomisi, pcmodcom,
                         NVL(pfinivig, vfinivig), pninialt, pcconcepto, ppcomisi, psproduc,
                         pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpasexec := 3;

               UPDATE comisionacti_concep
                  SET pcomisi = ppcomisi,
                      sproduc = psproduc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = pninialt
                  AND cconcepto = pcconcepto;
         END;
      ELSE
         IF pfinivig IS NULL THEN
            SELECT MAX(finivig)
              INTO vfinivig
              FROM comisionprod
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND ninialt = pninialt;

            /*bug 32077*/
            IF vfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM comisionvig
                WHERE ccomisi = pccomisi;
            END IF;
         END IF;

         BEGIN
            vpasexec := 4;

            INSERT INTO comisionprod_concep
                        (cramo, cmodali, ctipseg, ccolect, ccomisi, cmodcom,
                         finivig, ninialt, cconcepto, pcomisi, sproduc,
                         nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pccomisi, pcmodcom,
                         NVL(pfinivig, vfinivig), pninialt, pcconcepto, ppcomisi, psproduc,
                         pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vpasexec := 5;

               UPDATE comisionprod_concep
                  SET pcomisi = ppcomisi,
                      sproduc = psproduc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND ccomisi = pccomisi
                  AND cmodcom = pcmodcom
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = pninialt
                  AND cconcepto = pcconcepto;
         END;
      END IF;

      vpasexec := 6;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_set_comisiondesglose', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 140999;
   END f_set_comisiondesglose;

   /*************************************************************************
     Borra el desglose del % de comision
     param in pcactivi     C贸digo de la actividad
     param in pcgarant     C贸digo de la garantia
     param in pccomisi     C贸digo comisi贸n
     param in pcmodcom     C贸digo de la modalidad de comisi贸n
     param in pfinivig     Fecha inicio vigencia comisi贸n
     param in pninialt     Inicio de la altura
     param in psproduc     Codi producte
     param in pnfinalt     Fin de la altura

     return : codigo de error
     Bug 24905/131645 - 11/12/2012 - AMC
   *************************************************************************/
   FUNCTION f_del_comisiondesglose(
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccomisi IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      psproduc IN NUMBER,
      pnfinalt IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vfinivig       DATE;
   BEGIN
      vpasexec := 1;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      IF pcactivi IS NOT NULL
         AND pcgarant IS NOT NULL THEN
         vpasexec := 2;

         DELETE      comisiongar_concep
               WHERE cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect
                 AND cactivi = pcactivi
                 AND cgarant = pcgarant
                 AND ccomisi = pccomisi
                 AND cmodcom = pcmodcom
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
      ELSIF pcactivi IS NOT NULL THEN
         vpasexec := 3;

         DELETE      comisionacti_concep
               WHERE cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect
                 AND cactivi = pcactivi
                 AND ccomisi = pccomisi
                 AND cmodcom = pcmodcom
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
      ELSE
         vpasexec := 4;

         DELETE      comisionprod_concep
               WHERE cramo = vcramo
                 AND cmodali = vcmodali
                 AND ctipseg = vctipseg
                 AND ccolect = vccolect
                 AND ccomisi = pccomisi
                 AND cmodcom = pcmodcom
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
      END IF;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_del_comisiondesglose', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 140999;
   END f_del_comisiondesglose;

   /*************************************************************************
      Recupera el desglose del % de comision
      param in pcactivi     C贸digo de la actividad
      param in pcgarant     C贸digo de la garantia
      param in pccomisi     C贸digo comisi贸n
      param in pcmodcom     C贸digo de la modalidad de comisi贸n
      param in pfinivig     Fecha inicio vigencia comisi贸n
      param in pninialt     Inicio de la altura
      param in psproduc     Codi producte
      param in pnfinalt     Fin de la altura
      param out pdesglose   Sumatorio de los % de comision

      return : codigo de error
      Bug 24905/131645 - 17/12/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_comisiondesglose(
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccomisi IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      psproduc IN NUMBER,
      pnfinalt IN NUMBER,
      pdesglose OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vfinivig       DATE;
   BEGIN
      vpasexec := 1;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      vpasexec := 2;

      IF pcactivi IS NOT NULL
         AND pcgarant IS NOT NULL THEN
         vpasexec := 3;

         BEGIN
            SELECT SUM(pcomisi)
              INTO pdesglose
              FROM comisiongar_concep
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = pcactivi
               AND cgarant = pcgarant
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND finivig = pfinivig
               AND ninialt = pninialt;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pdesglose := 0;
         END;
      ELSIF pcactivi IS NOT NULL THEN
         vpasexec := 3;

         BEGIN
            SELECT SUM(pcomisi)
              INTO pdesglose
              FROM comisionacti_concep
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND cactivi = pcactivi
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND finivig = pfinivig
               AND ninialt = pninialt;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pdesglose := 0;
         END;
      ELSE
         vpasexec := 4;

         BEGIN
            SELECT SUM(pcomisi)
              INTO pdesglose
              FROM comisionprod_concep
             WHERE cramo = vcramo
               AND cmodali = vcmodali
               AND ctipseg = vctipseg
               AND ccolect = vccolect
               AND ccomisi = pccomisi
               AND cmodcom = pcmodcom
               AND finivig = pfinivig
               AND ninialt = pninialt;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pdesglose := 0;
         END;
      END IF;

      vpasexec := 5;
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 120135;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_comisiondesglose', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 140999;
   END f_get_comisiondesglose;

   /******************************************************************************
           NOMBRE:     f_pcomespecial
           PROP脫SITO:  Funci贸n que encuentra el valor de la comisi贸n

           REVISIONES:
           Ver        Fecha        Autor             Descripci贸n
           ---------  ----------  ---------------  ------------------------------------
           1.0       25/06/2014  FBL               1. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management). Creaci贸n de la funci贸n
           1.1       01/10/2014  RDD               1. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management). Creaci贸n de la funci贸n
   ******************************************************************************/
   FUNCTION f_pcomespecial(
      p_sseguro NUMBER,
      p_nriesgo NUMBER,
      p_cgarant NUMBER,
      p_nrecibo NUMBER,
      p_ctipcom NUMBER,
      p_cconcep NUMBER,
      p_fecrec DATE,
      p_modocal VARCHAR2,
      p_icomisi_total OUT NUMBER,
      p_icomisi_monpol_total OUT NUMBER,
      p_pcomisi OUT NUMBER,
      p_sproces NUMBER DEFAULT NULL,
      p_nmovimi NUMBER DEFAULT NULL,
      p_prorrata NUMBER DEFAULT 1)   /*, drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, drec.cageven, drec.nmovima*/
      RETURN NUMBER IS
      v_ctipcom      NUMBER;

      CURSOR c_comisiones_directas(
         p_seguro NUMBER,
         p_sproces NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nmovimi NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, car.pcomisi, 'CAR' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, car.ipricom,
                  car.cmodcom
             FROM garancarcom car, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND cmodcom IN(1, 2, 5, 6)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(ninialt - 1) * 12) RDD*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, car.pcomisi, 'CAR', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, car.cageven, drec.nmovima, car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, seg.ipricom,
                  seg.cmodcom
             FROM garansegcom seg, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.cgarant = drec.cgarant
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, seg.cageven, drec.nmovima, seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom) ipricom,
                  seg.cmodcom
             FROM garansegcom seg, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              /*AND seg.cgarant = 48   --p_cgarant*/
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              /*AND seg.cgarant = drec.cgarant*/
              /*AND drec.cgarant = 282*/
              /*and rec.ctiprec = 4*/
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_indirectas(
         p_seguro NUMBER,
         p_sproces NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nmovimi NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, car.pcomisi, 'CAR' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, car.ipricom,
                  car.cmodcom
             FROM garancarcom car, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.cgarant = drec.cgarant
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND cmodcom IN(3, 4, 7, 8)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, car.pcomisi, 'CAR', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, car.cageven, drec.nmovima, car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, seg.ipricom,
                  seg.cmodcom
             FROM garansegcom seg, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.cgarant = drec.cgarant
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND rec.nrecibo = p_nrecibo
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, seg.cageven, drec.nmovima, seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS /savings*/
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom) ipricom,
                  seg.cmodcom
             FROM garansegcom seg, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              /*AND seg.cgarant = drec.cgarant*/
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND rec.nrecibo = p_nrecibo
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_directas_dev(
         p_seguro NUMBER,
         p_sproces NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nmovimi NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, car.pcomisi, 'CAR' modocal, s.fcaranu fecha_seg,
                  ADD_MONTHS(car.finiefe, 12 * car.nfinalt) fecha_gar, car.finiefe fecha_desde,
                  drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven,
                  drec.nmovima, car.ipricom, car.cmodcom
             FROM garancarcom car, seguros s, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.sseguro = s.sseguro
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(1, 2, 5, 6)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, car.pcomisi, 'CAR', s.fcaranu,
                  ADD_MONTHS(car.finiefe, 12 * car.nfinalt), car.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima,
                  car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  seg.ipricom, seg.cmodcom
             FROM garansegcom seg, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = s.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.sseguro = seg.sseguro
              AND rec.nrecibo = p_nrecibo
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS /savings*/
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom) ipricom,
                  seg.cmodcom
             FROM garansegcom seg, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND seg.sseguro = s.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND rec.sseguro = seg.sseguro
              AND rec.nrecibo = p_nrecibo
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_indirectas_dev(
         p_seguro NUMBER,
         p_sproces NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nmovimi NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, car.pcomisi, 'CAR' modocal, s.fcaranu fecha_seg,
                  ADD_MONTHS(car.finiefe, 12 * car.nfinalt) fecha_gar, car.finiefe fecha_desde,
                  drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven,
                  drec.nmovima, car.ipricom, car.cmodcom
             FROM garancarcom car, seguros s, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.sseguro = s.sseguro
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(3, 4, 7, 8)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, car.pcomisi, 'CAR', s.fcaranu,
                  ADD_MONTHS(car.finiefe, 12 * car.nfinalt), car.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima,
                  car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  seg.ipricom, seg.cmodcom
             FROM garansegcom seg, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = s.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.sseguro = seg.sseguro
              AND rec.nrecibo = p_nrecibo
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, seg.pcomisi, 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom) ipricom,
                  seg.cmodcom
             FROM garansegcom seg, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND seg.sseguro = s.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND rec.sseguro = seg.sseguro
              AND rec.nrecibo = p_nrecibo
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, seg.pcomisi, 'SEG', s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_directas_segu(
         p_seguro NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, drec.iconcep *(cse.pcomisi / 100) AS importe, 'CAR' modocal,
                  drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven,
                  drec.nmovima, cse.pcomisi, car.ipricom, car.cmodcom
             FROM garancarcom car, comisionsegu cse, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.sseguro = cse.sseguro
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(1, 2, 5, 6)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(car.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, drec.iconcep * cse.pcomisi, 'CAR', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi,
                  car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, seg.ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = cse.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, DECODE(rec.ctiprec,
                                      4, drec.iconcep_monpol,
                                      seg.ipricom) ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND seg.sseguro = cse.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_indirectas_segu(
         p_seguro NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, drec.iconcep *(cse.pcomisi / 100) AS importe, 'CAR' modocal,
                  drec.nrecibo, drec.cconcep, drec.nriesgo, drec.iconcep, car.cageven,
                  drec.nmovima, cse.pcomisi, car.cmodcom
             FROM garancarcom car, comisionsegu cse, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.sseguro = cse.sseguro
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(3, 4, 7, 8)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(car.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, drec.iconcep * cse.pcomisi, 'CAR', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi,
                  car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = cse.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              /*AND seg.cgarant = p_cgarant*/
              AND seg.sseguro = cse.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  seg.cmodcom;

      CURSOR c_comisiones_dir_segu_dev(
         p_seguro NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, drec.iconcep *(cse.pcomisi / 100) AS importe, 'CAR' modocal,
                  s.fcaranu fecha_seg, ADD_MONTHS(car.finiefe, 12 * car.nfinalt) fecha_gar,
                  car.finiefe fecha_desde, drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi, car.ipricom,
                  car.cmodcom
             FROM garancarcom car, comisionsegu cse, seguros s, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.sseguro = cse.sseguro
              AND car.sseguro = s.sseguro
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(1, 2, 5, 6)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(car.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, drec.iconcep * cse.pcomisi, 'CAR', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi,
                  car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), seg.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, seg.ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = cse.sseguro
              AND seg.sseguro = s.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), seg.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, DECODE(rec.ctiprec,
                                      4, drec.iconcep_monpol,
                                      seg.ipricom) ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              /*AND seg.cgarant = p_cgarant*/
              AND seg.sseguro = cse.sseguro
              AND seg.sseguro = s.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(1, 2, 5, 6)
              /*AND seg.ipricom > 0*/
              /*AND rec.ctiprec = 4*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_comisiones_ind_segu_dev(
         p_seguro NUMBER,
         p_nriesgo NUMBER,
         p_cgarant NUMBER,
         p_nrecibo NUMBER,
         p_cconcep_base NUMBER,
         p_modo VARCHAR2,
         p_fecha_rec DATE) IS
         SELECT   car.cgarant, drec.iconcep *(cse.pcomisi / 100) AS importe, 'CAR' modocal,
                  s.fcaranu fecha_seg, ADD_MONTHS(car.finiefe, 12 * car.nfinalt) fecha_gar,
                  car.finiefe fecha_desde, drec.nrecibo, drec.cconcep, drec.nriesgo,
                  drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi, car.ipricom,
                  car.cmodcom
             FROM garancarcom car, comisionsegu cse, seguros s, detrecibos drec
            WHERE car.sseguro = p_seguro
              AND car.sproces = p_sproces
              AND car.nriesgo = p_nriesgo
              AND car.cgarant = p_cgarant
              AND car.sseguro = cse.sseguro
              AND car.sseguro = s.sseguro
              AND car.cgarant = drec.cgarant
              AND drec.nrecibo = p_nrecibo
              AND drec.cconcep = p_cconcep_base
              AND car.cmodcom IN(3, 4, 7, 8)
              /*AND car.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(car.finiefe,(car.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(car.finiefe, 12 * car.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY car.cgarant, drec.iconcep * cse.pcomisi, 'CAR', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, car.cageven, drec.nmovima, cse.pcomisi,
                  car.ipricom, car.cmodcom
         UNION ALL
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), seg.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, seg.ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              AND seg.cgarant = p_cgarant
              AND seg.sseguro = cse.sseguro
              AND seg.sseguro = s.sseguro
              AND seg.cgarant = drec.cgarant
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' != p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  seg.ipricom, seg.cmodcom
         UNION ALL   /*APORTACIONES EXTRAORDINARIAS / savings*/
         SELECT   seg.cgarant, drec.iconcep *(cse.pcomisi / 100), 'SEG' modocal, s.fcaranu,
                  ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt), seg.finiefe, drec.nrecibo,
                  drec.cconcep, drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima,
                  cse.pcomisi, DECODE(rec.ctiprec,
                                      4, drec.iconcep_monpol,
                                      seg.ipricom) ipricom, seg.cmodcom
             FROM garansegcom seg, comisionsegu cse, seguros s, detrecibos drec, recibos rec
            WHERE seg.sseguro = p_seguro
              AND seg.nmovimi = NVL(p_nmovimi, 1)
              AND seg.nriesgo = p_nriesgo
              /*AND seg.cgarant = p_cgarant*/
              AND seg.sseguro = cse.sseguro
              AND seg.sseguro = s.sseguro
              /*AND seg.cgarant = drec.cgarant*/
              AND seg.cgarant = DECODE(rec.ctiprec, 4, 48, p_cgarant)
              AND drec.cgarant = DECODE(rec.ctiprec, 4, 282, p_cgarant)
              AND rec.nrecibo = p_nrecibo
              AND rec.sseguro = seg.sseguro
              AND rec.nmovimi = seg.nmovimi
              AND NVL(rec.nriesgo, seg.nriesgo) = seg.nriesgo
              AND drec.nrecibo = rec.nrecibo
              AND drec.cconcep = p_cconcep_base
              AND seg.cmodcom IN(3, 4, 7, 8)
              /*AND seg.ipricom > 0*/
              /*AND p_fecha_rec >= ADD_MONTHS(seg.finiefe,(seg.ninialt - 1) * 12) rdd*/
              /*AND p_fecha_rec < ADD_MONTHS(seg.finiefe, 12 * seg.nfinalt) rdd*/
              AND 'CAR' = p_modo
         GROUP BY seg.cgarant, drec.iconcep * cse.pcomisi, 'SEG', drec.nrecibo, drec.cconcep,
                  drec.nriesgo, drec.iconcep, seg.cageven, drec.nmovima, cse.pcomisi,
                  DECODE(rec.ctiprec, 4, drec.iconcep_monpol, seg.ipricom), seg.cmodcom;

      CURSOR c_ipricom_positivo(p_sseguro NUMBER, p_nmovimi NUMBER) IS
         SELECT 1
           FROM garansegcom g
          WHERE g.sseguro = p_sseguro
            AND g.nmovimi = p_nmovimi
            AND g.ipricom < 0;

      v_icomisi_total NUMBER := 0;
      v_icomisi_monpol NUMBER := 0;
      v_icomisi_monpol_total NUMBER := 0;
      v_itasa        NUMBER;
      v_fcambio      DATE;
      v_res          NUMBER;
      v_cmonpol      VARCHAR2(100);
      v_importe_devengado NUMBER;
      v_sqlcode      NUMBER;
      v_sqlerrm      VARCHAR2(1000);
      v_concep_base  NUMBER;
      v_importe_comision NUMBER;
      v_numlin       NUMBER := 0;
      v_ipricom_positivo VARCHAR2(1) := 'N';
      vobj           VARCHAR2(500) := 'F_PCOMESPECIAL';
      vpar           VARCHAR2(900)
         := 'p_sseguro=' || p_sseguro || ' p_nriesgo=' || p_nriesgo || ' p_cgarant='
            || p_cgarant || ' p_nrecibo=' || p_nrecibo || ' p_ctipcom=' || p_ctipcom
            || ' p_cconcep=' || p_cconcep || ' p_fecrec=' || TO_CHAR(p_fecrec, 'DD/MM/YYYY')
            || ' p_modocal=' || p_modocal || ' p_sproces=' || p_sproces || ' p_nmovimi='
            || p_nmovimi || ' p_prorrata=' || p_prorrata;
      vpas           NUMBER(5) := 0;
   BEGIN
      p_icomisi_total := 0;
      p_icomisi_monpol_total := 0;
      v_res := pac_oper_monedas.f_datos_contraval(p_sseguro, NULL, NULL, p_fecrec, 3, v_itasa,
                                                  v_fcambio);
      v_cmonpol := pac_oper_monedas.f_monpol(p_sseguro);

      IF p_cconcep IN(11, 17) THEN
         v_concep_base := 0;
      ELSIF p_cconcep IN(15, 19) THEN
         v_concep_base := 21;
      END IF;

      /*test. No puedo insertar el pcconcep 15 tomando como bnase el 21 antes de que se haya insertado el 15 en detrecibos, porque sino casca por fk*/
      /*v_concep_base := p_cconcep;*/
      v_ipricom_positivo := 'Y';

      FOR i IN c_ipricom_positivo(p_sseguro, p_nmovimi) LOOP
         v_ipricom_positivo := 'N';
         EXIT;
      END LOOP;

      vpas := 1;

      IF v_ipricom_positivo = 'Y' THEN
         IF p_ctipcom = 0 THEN
            IF p_cconcep = 11 THEN   /* nueva producci贸n*/
               vpas := 2;

               FOR i IN c_comisiones_directas(p_sseguro, p_sproces, p_nriesgo, p_cgarant,
                                              p_nmovimi, p_nrecibo, v_concep_base, p_modocal,
                                              p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_importe_comision := (i.pcomisi / 100) * i.ipricom * p_prorrata;
                  v_icomisi_monpol := f_round(v_importe_comision * v_itasa, v_cmonpol);   /* calcular importe segun moneda4*/

                  /*);*/
                  IF i.modocal /*p_modocal*/ = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant,
                                            /*rdd*/
                                            i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_comision, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_comision, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_comision;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 17 THEN   /* indirectas*/
               vpas := 3;

               FOR i IN c_comisiones_indirectas(p_sseguro, p_sproces, p_nriesgo, p_cgarant,
                                                p_nmovimi, p_nrecibo, v_concep_base,
                                                p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_importe_comision := (i.pcomisi / 100) * i.ipricom * p_prorrata;   /*(i.pcomisi / 100) * i.iconcep * p_prorrata;*/
                  v_icomisi_monpol := f_round(v_importe_comision * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant,
                                            /*rdd*/
                                            i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_comision, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_comision, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_comision;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 15 THEN   /* nueva producci贸n devengadas*/
               vpas := 4;

               FOR i IN c_comisiones_directas_dev(p_sseguro, p_sproces, p_nriesgo, p_cgarant,
                                                  p_nmovimi, p_nrecibo, v_concep_base,
                                                  p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_importe_comision := (i.pcomisi / 100) * i.ipricom * p_prorrata;   /*(i.pcomisi / 100) * i.iconcep * p_prorrata;*/
                  /*v_importe_devengado := v_importe_comision * floor(abs(months_between (i.fecha_desde, least (i.fecha_gar, i.fecha_seg))));*/
                  v_importe_devengado := (i.pcomisi / 100) * i.ipricom;
                  v_icomisi_monpol := f_round(v_importe_devengado * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_devengado;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 19 THEN   /* indirectas devengadas*/
               vpas := 5;

               FOR i IN c_comisiones_indirectas_dev(p_sseguro, p_sproces, p_nriesgo,
                                                    p_cgarant, p_nmovimi, p_nrecibo,
                                                    v_concep_base, p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_importe_comision := (i.pcomisi / 100) * i.ipricom * p_prorrata;   /*(i.pcomisi / 100) * i.iconcep * p_prorrata;*/
                  /*v_importe_devengado := v_importe_comision * floor(abs(months_between (i.fecha_desde, least (i.fecha_gar, i.fecha_seg))));*/
                  v_importe_devengado := (i.pcomisi / 100) * i.ipricom;
                  v_icomisi_monpol := f_round(v_importe_devengado * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_devengado;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            END IF;
         ELSIF p_ctipcom = 90 THEN
/*-----------------------------------------------------------------------------------------------------------------*/
            IF p_cconcep = 11 THEN   /* nueva producci贸n*/
               vpas := 6;

               FOR i IN c_comisiones_directas_segu(p_sseguro, p_nriesgo, p_cgarant, p_nrecibo,
                                                   v_concep_base, p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_icomisi_monpol := f_round(i.importe * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, i.importe, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, i.importe, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + i.importe;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 17 THEN   /* indirectas*/
               vpas := 7;

               FOR i IN c_comisiones_directas_segu(p_sseguro, p_nriesgo, p_cgarant, p_nrecibo,
                                                   v_concep_base, p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  v_icomisi_monpol := f_round(i.importe * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, i.importe, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, i.importe, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + i.importe;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 15 THEN   /* nueva producci贸n devengadas*/
               vpas := 8;

               FOR i IN c_comisiones_dir_segu_dev(p_sseguro, p_nriesgo, p_cgarant, p_nrecibo,
                                                  v_concep_base, p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  /*v_importe_devengado := i.importe * floor(abs(months_between (i.fecha_desde, least (i.fecha_gar, i.fecha_seg))));*/
                  v_importe_devengado := (i.pcomisi / 100) * i.ipricom;
                  v_icomisi_monpol := f_round(v_importe_devengado * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_devengado;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            ELSIF p_cconcep = 19 THEN   /* indirectas devengadas*/
               vpas := 9;

               FOR i IN c_comisiones_ind_segu_dev(p_sseguro, p_nriesgo, p_cgarant, p_nrecibo,
                                                  v_concep_base, p_modocal, p_fecrec) LOOP
                  p_pcomisi := i.pcomisi;
                  /*v_importe_devengado := i.importe * floor(abs(months_between (i.fecha_desde, least (i.fecha_gar, i.fecha_seg))));*/
                  p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                              'OCHO p_pcomisi ' || p_pcomisi || ' I.IPRICOM ' || i.ipricom);
                  v_importe_devengado := (i.pcomisi / 100) * i.ipricom;
                  v_icomisi_monpol := f_round(v_importe_devengado * v_itasa, v_cmonpol);   /* calcular importe segun moneda*/

                  IF i.modocal = 'CAR' THEN
                     INSERT INTO detreciboscarcom
                                 (sproces, nrecibo, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol)
                          VALUES (p_sproces, i.nrecibo, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol);
                  ELSE
                     v_numlin := v_numlin + 1;

                     INSERT INTO detreciboscom
                                 (nrecibo, nmovimc, cconcep, cmodcom, ctipcom,
                                  cgarant, nriesgo, iconcep, cageven, nmovima,
                                  fcambio, icomisi, icomisi_monpol, nnumlin)
                          VALUES (i.nrecibo, p_nmovimi, p_cconcep, i.cmodcom, p_ctipcom,
                                  i.cgarant, i.nriesgo, i.ipricom, i.cageven, i.nmovima,
                                  p_fecrec, v_importe_devengado, v_icomisi_monpol, v_numlin);
                  END IF;

                  v_icomisi_total := v_icomisi_total + v_importe_devengado;
                  v_icomisi_monpol_total := v_icomisi_monpol_total + v_icomisi_monpol;
               END LOOP;
            END IF;
         ELSIF p_ctipcom = 99 THEN
            vpas := 10;
            v_icomisi_total := 0;
         END IF;

         p_icomisi_total := v_icomisi_total;
         p_icomisi_monpol_total := v_icomisi_monpol_total;
      ELSE
         vpas := 11;
         p_icomisi_total := 0;
         p_icomisi_monpol_total := 0;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         /* no deber铆a ocurrir nunca...*/
         v_sqlcode := SQLCODE;
         v_sqlerrm := SQLERRM;
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                     ' SQLCODE: ' || ' ' || v_sqlcode || ' SQLERRM: ' || ' ' || v_sqlerrm);
         RETURN v_sqlcode;
   END f_pcomespecial;

   FUNCTION f_grabarcomisionmovimiento(
      p_cempres IN NUMBER,
      p_sseguro IN NUMBER,
      p_cgarant IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_fecha IN DATE,
      p_modo IN VARCHAR2, /*, ?AR? ?P?*/
      p_ipricom IN NUMBER,
      p_cmodcom IN NUMBER,
      p_sproces IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      e_param_error  EXCEPTION;   /*rdd*/
      e_object_error EXCEPTION;   /*rdd*/
      v_object       VARCHAR2(200) := 'PAC_COMISIONES.F_GRABARCOMISIONMOVIMIENTO';
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(1) := NULL;
      v_cramo        NUMBER(8);
      v_cmodali      NUMBER(2);
      v_ctipseg      NUMBER(2);
      v_ccolect      NUMBER(2);
      v_cactivi      NUMBER(4);
      v_fvencim      DATE;
      v_fefecto      DATE;
      v_nduraci      NUMBER(5, 2);
      v_cagente      NUMBER;
      v_anuali       NUMBER(2);
      v_ccomisi      NUMBER;
      v_ccomisiind   NUMBER;
      v_agentepadre  NUMBER;
      v_ccomisipadre NUMBER;
      v_nivel        VARCHAR2(10);
      v_criterio     NUMBER;
      /*v_ncriterio    NUMBER;*/
      v_res          NUMBER;
      v_select       VARCHAR2(4000);
      v_where        VARCHAR2(4000);   /* SEGUN EL NIVEL , GARANTIA, ACTIVIDAD, PRODUCTO*/
      v_sentencia    VARCHAR2(4000);
      v_from         VARCHAR2(100);
      v_pcomisi      NUMBER;
      v_ninialt      NUMBER;
      v_nfinalt      NUMBER;
      v_iprianu_gar  NUMBER;
      v_modo         VARCHAR2(10);   --'CAR' o 'NP'
      v_cmodcom      comisionprod.cmodcom%TYPE := NULL;   /*rdd*/
      v_cmodcom2     comisionprod.cmodcom%TYPE := NULL;   /*rdd*/

      TYPE t_cursor_criterios IS REF CURSOR;

      v_cursor_criterios t_cursor_criterios;
      ex_seguro_no_existe EXCEPTION;
      ex_acceso_seguro EXCEPTION;
      ex_mas_de_una_garantia EXCEPTION;
      ex_mas_de_una_actividad EXCEPTION;
      ex_mas_de_un_producto EXCEPTION;
      ex_error_leer_producto EXCEPTION;
      ex_error_leer_actividad EXCEPTION;
      ex_error_leer_garantia EXCEPTION;
      v_ccomisi_actual NUMBER;
      v_agente_actual NUMBER;
      v_parametros   VARCHAR2(4000);
      v_rescriterio_duracion NUMBER;
      v_rescriterio_duracion2 NUMBER;
   BEGIN
      v_parametros := 'p_cempres: ' || p_cempres || '- p_sseguro: ' || p_sseguro
                      || '- p_cgarant: ' || p_cgarant || '- p_nriesgo: ' || p_nriesgo
                      || '- p_nmovimi: ' || p_nmovimi || '- p_fecha: '
                      || TO_CHAR(p_fecha, 'DD/MM/YYYY') || '- p_modo: ' || p_modo
                      || '- p_ipricom: ' || p_ipricom || '- p_cmodcom: ' || p_cmodcom;

      IF p_modo != 'R' THEN
         BEGIN
            SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                   NVL(s.fvencim, NVL(s.fcaranu, NVL(s.fcarpro, ADD_MONTHS(s.fefecto, 12)))),
                   s.nduraci, s.cagente, a.ccomisi, s.fefecto
              INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                   v_fvencim,
                   v_nduraci, v_cagente, v_ccomisi, v_fefecto
              FROM seguros s,
                   (SELECT z.cagente, z.ccomisi, z.finivig,
                           NVL(z.ffinvig, TO_DATE('01013000', 'DDMMYYYY')) ffinvig
                      FROM comisionvig_agente z
                     WHERE z.ccomind = 0) a   /*RDD*/
             WHERE s.sseguro = p_sseguro
               AND s.cagente = a.cagente
               AND a.finivig <= p_fecha
               AND a.ffinvig >= p_fecha;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               /* tractament del error seguro no existe*/
               v_pasexec := 2;
               RAISE ex_seguro_no_existe;
            WHEN OTHERS THEN
               /* tractament del error*/
               v_pasexec := 2;
               RAISE ex_acceso_seguro;
         END;
      ELSE
         BEGIN
            SELECT cramo, cmodali, ctipseg, ccolect, cactivi, fecha, nduraci,
                   cagente, nanuali, ccomisi, modo, fefecto
              INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, v_fvencim, v_nduraci,
                   v_cagente, v_anuali, v_ccomisi, v_modo, v_fefecto
              FROM (SELECT e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                           NVL(e.fvencim,
                               NVL(e.fcaranu, NVL(e.fcarpro, ADD_MONTHS(e.fefecto, 12))))
                                                                                         fecha,
                           e.nduraci, e.cagente, e.nanuali, a.ccomisi, 'NP' modo, e.fefecto
                      FROM estseguros e,
                           (SELECT z.cagente, z.ccomisi, z.finivig,
                                   NVL(z.ffinvig, TO_DATE('01013000', 'DDMMYYYY')) ffinvig
                              FROM comisionvig_agente z
                             WHERE z.ccomind = 0) a
                     WHERE e.sseguro = p_sseguro   /*RDD*/
                       AND e.cagente = a.cagente(+)
                       AND a.finivig(+) <= p_fecha
                       AND a.ffinvig(+) >= p_fecha
                    UNION
                    SELECT e.cramo, e.cmodali, e.ctipseg, e.ccolect, e.cactivi,
                           NVL(e.fvencim,
                               NVL(e.fcaranu, NVL(e.fcarpro, ADD_MONTHS(e.fefecto, 12))))
                                                                                         fecha,
                           e.nduraci, e.cagente, e.nanuali, a.ccomisi, 'CAR' modo, e.fefecto
                      FROM seguros e,
                           (SELECT z.cagente, z.ccomisi, z.finivig,
                                   NVL(z.ffinvig, TO_DATE('01013000', 'DDMMYYYY')) ffinvig
                              FROM comisionvig_agente z
                             WHERE z.ccomind = 0) a
                     WHERE e.sseguro = p_sseguro   /*RDD*/
                       AND e.cagente = a.cagente(+)
                       AND a.finivig(+) <= p_fecha
                       AND a.ffinvig(+) >= p_fecha);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               /* tractament del error seguro no existe*/
               v_pasexec := 3;
               RAISE ex_seguro_no_existe;
            WHEN OTHERS THEN
               v_pasexec := 3;
               /* tractament del error*/
               RAISE ex_acceso_seguro;
         END;
      END IF;

      IF p_modo = 'TRASP_CAR' THEN
         v_modo := p_modo;
      END IF;

      IF v_cagente IS NOT NULL THEN
         v_res := pac_agentes.f_get_ccomind(pcempres => p_cempres, pcagente => v_cagente,
                                            pfecha => p_fecha, pccomind => v_ccomisiind,
                                            pcpadre => v_agentepadre);

         IF v_agentepadre IS NOT NULL
            AND v_agentepadre != 0 THEN
            /*EN ESTA PARTE CON EL PARAMETRO GEN_COMI_IN_PADRE DEFINIMOS SI AL PADRE SE LE GENERA COMISION INDIRECTA, 1 = SI, 0 = NO,
            POR DEFAULT SE USARA QUE SI.  DEVOLVERA NULL AL CUADRO DE COMISION INDIRECTO DEL PADRE SI NO SE USA ENTONCES NO ENCONTRARA
            MAS ADELANTE VALORES PARA GENERAR LA COMISION*/
            SELECT DECODE
                      (NVL((SELECT MAX(b.nvalpar)
                              FROM age_paragentes b
                             WHERE b.cparam = 'GEN_COMI_IN_PADRE'
                               AND b.cagente = v_cagente), 1),
                       1, a.ccomisi,
                       NULL)   /* RDD campo ccomisi_indirect de tabla agentes  06/08/2014*/
              INTO v_ccomisipadre
              FROM comisionvig_agente a
             WHERE a.cagente = v_agentepadre
               AND p_fecha BETWEEN a.finivig AND NVL(a.ffinvig,
                                                     TO_DATE('01013000', 'DDMMYYYY'))
               AND a.ccomind = 1;   /*INDIRECTA = 1; DIRECTA = 0*/
         ELSE
            v_ccomisipadre := NULL;
         END IF;
      ELSE
         /* aqu?ue pasa? Si no tenemos agente? en la tabla estseguros el agente es opcional...*/
         RAISE ex_acceso_seguro;
      END IF;

      /* esto debe repetirse para el agente y para el agente padre*/
      /* nos inventamos un bucle de 1 a 2 y cambiamos los valores del ccomisi agente por los del agente padre enla segunda vuelta*/
      FOR i IN 1 .. 2 LOOP
         IF i = 1 THEN
            /* calculamos cuadro para el agente*/
            v_ccomisi_actual := v_ccomisi;
            v_agente_actual := v_cagente;
         ELSE
            /* calculamos el cuadro para el agente padre*/
            v_ccomisi_actual := v_ccomisipadre;
            v_agente_actual := v_agentepadre;
         /*tengo que fijarme en el tipo de comsiion que tiene el padre, su cmodcom que sera diferente si tiene*/
         END IF;

         /*p_tab_error(f_sysdate, f_user, v_object, 21, 'PASANDO CON AGENTE ' || v_agente_actual,0);*/
         IF v_ccomisi_actual IS NOT NULL THEN
            IF pac_parametros.f_parempresa_n(p_cempres, '1') = 0 THEN
               BEGIN
                  SELECT DISTINCT 'GAR', ccriterio
                             INTO v_nivel, v_criterio
                             FROM comisiongar cg
                            WHERE cramo = v_cramo
                              AND cmodali = v_cmodali
                              AND ctipseg = v_ctipseg
                              AND ccolect = v_ccolect
                              AND cactivi = v_cactivi
                              AND cgarant = p_cgarant
                              AND ccomisi = v_ccomisi_actual
                              /*AND cmodcom = p_cmodcom   --rdd*/
                              AND NVL(v_anuali, 1) <= nfinalt
                              /*                     and add_months(finivig, nfinalt * 12) >= trunc(p_fecha);*/
                              AND finivig = (SELECT finivig
                                               FROM comisionvig
                                              WHERE ccomisi = v_ccomisi_actual
                                                AND cestado = 2
                                                AND TRUNC(p_fecha) BETWEEN finivig
                                                                       AND NVL(ffinvig,
                                                                               TRUNC(p_fecha)));
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     /* Tractament del error*/
                     RAISE ex_mas_de_una_garantia;
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT DISTINCT 'ACTI', ccriterio
                                   INTO v_nivel, v_criterio
                                   FROM comisionacti ca
                                  WHERE cramo = v_cramo
                                    AND cmodali = v_cmodali
                                    AND ccolect = v_ccolect
                                    AND ctipseg = v_ctipseg
                                    /*AND cmodcom = p_cmodcom  --rdd*/
                                    AND ccomisi = v_ccomisi_actual
                                    AND cactivi = v_cactivi
                                    AND NVL(v_anuali, 1) <= nfinalt
                                    /*                        and add_months(finivig, nfinalt * 12) >= trunc(p_fecha);*/
                                    AND finivig =
                                          (SELECT finivig
                                             FROM comisionvig
                                            WHERE ccomisi = v_ccomisi_actual
                                              AND cestado = 2
                                              AND TRUNC(p_fecha) BETWEEN finivig
                                                                     AND NVL(ffinvig,
                                                                             TRUNC(p_fecha)));
                     EXCEPTION
                        WHEN TOO_MANY_ROWS THEN
                           v_pasexec := 4;
                           RAISE ex_mas_de_una_actividad;
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              SELECT DISTINCT 'PROD', ccriterio
                                         INTO v_nivel, v_criterio
                                         FROM comisionprod cp
                                        WHERE cramo = v_cramo
                                          AND cmodali = v_cmodali
                                          AND ctipseg = v_ctipseg
                                          AND ccolect = v_ccolect
                                          /*AND cmodcom = p_cmodcom  --rdd*/
                                          AND ccomisi = v_ccomisi_actual
                                          AND NVL(v_anuali, 1) <= nfinalt
                                          /*                                 and add_months(finivig, nfinalt * 12) >= trunc(p_fecha);*/
                                          AND finivig =
                                                (SELECT finivig
                                                   FROM comisionvig
                                                  WHERE ccomisi = v_ccomisi_actual
                                                    AND cestado = 2
                                                    AND TRUNC(p_fecha) BETWEEN finivig
                                                                           AND NVL
                                                                                 (ffinvig,
                                                                                  TRUNC
                                                                                       (p_fecha)));
                           EXCEPTION
                              WHEN TOO_MANY_ROWS THEN
                                 v_pasexec := 4;
                                 RAISE ex_mas_de_un_producto;
                              WHEN NO_DATA_FOUND THEN
                                 /*pasar al siguiente tipo de comisiones, no hi han comis definides d'aquest tipus                      -- Comissi??existent*/
                                 NULL;
                              WHEN OTHERS THEN
                                 RAISE ex_error_leer_producto;
                           END;
                        WHEN OTHERS THEN
                           RAISE ex_error_leer_actividad;
                     END;
                  WHEN OTHERS THEN
                     RAISE ex_error_leer_garantia;
               END;
            ELSE
               /* comisiones basadas en criterios*/
                 /* Calculamos el importe total de la p??a garant?como suma del importe de las garant? ya que en este momento no tenemos informada la columna iprianu de estseguros*/
               IF v_modo = 'CAR' THEN
                  SELECT TRUNC(NVL(SUM(iprianu), 0))
                    INTO v_iprianu_gar
                    FROM tmp_garancar
                   WHERE sproces = p_sproces;
               ELSE
                  /* nueva producci??*/
                  SELECT TRUNC(NVL(SUM(iprianu), 0))
                    INTO v_iprianu_gar
                    FROM estgaranseg
                   WHERE sseguro = p_sseguro
                     AND nriesgo = p_nriesgo
                     AND nmovimi = p_nmovimi
                     AND finiefe = p_fecha;
               END IF;

               BEGIN
                  v_rescriterio_duracion := TRUNC(MONTHS_BETWEEN(p_fecha, v_fefecto) / 12) + 1;
                  /*CUANTON DURA LA POLIZA*/
                  v_rescriterio_duracion2 := TRUNC(MONTHS_BETWEEN(v_fvencim, v_fefecto) / 12);

                  SELECT DISTINCT 'GAR', ccriterio
                             INTO v_nivel, v_criterio
                             FROM comisiongar_criterio cg
                            WHERE cramo = v_cramo
                              AND cmodali = v_cmodali
                              AND ctipseg = v_ctipseg
                              AND ccolect = v_ccolect
                              AND cactivi = v_cactivi
                              AND cgarant = p_cgarant
                              AND ccomisi = v_ccomisi_actual
                              /*AND cmodcom = p_cmodcom  --rdd*/
                              AND p_fecha BETWEEN finivig AND NVL(ffinvig, p_fecha + 1)
                              AND v_iprianu_gar BETWEEN ndesde AND nhasta
                              AND finivig = (SELECT finivig
                                               FROM comisionvig
                                              WHERE ccomisi = v_ccomisi_actual
                                                AND cestado = 2
                                                AND TRUNC(p_fecha) BETWEEN finivig
                                                                       AND NVL(ffinvig,
                                                                               TRUNC(p_fecha)));
               EXCEPTION
                  WHEN TOO_MANY_ROWS THEN
                     /* Tractament del error*/
                     RAISE ex_mas_de_una_garantia;
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        SELECT DISTINCT 'ACTI', ccriterio
                                   INTO v_nivel, v_criterio
                                   FROM comisionacti_criterio ca
                                  WHERE cramo = v_cramo
                                    AND cmodali = v_cmodali
                                    AND ccolect = v_ccolect
                                    AND ctipseg = v_ctipseg
                                    /*AND cmodcom = p_cmodcom  --rdd*/
                                    AND ccomisi = v_ccomisi_actual
                                    AND cactivi = v_cactivi
                                    AND p_fecha BETWEEN finivig AND NVL(ffinvig, p_fecha + 1)
                                    AND v_iprianu_gar BETWEEN ndesde AND nhasta
                                    AND finivig =
                                          (SELECT finivig
                                             FROM comisionvig
                                            WHERE ccomisi = v_ccomisi_actual
                                              AND cestado = 2
                                              AND TRUNC(p_fecha) BETWEEN finivig
                                                                     AND NVL(ffinvig,
                                                                             TRUNC(p_fecha)));
                     EXCEPTION
                        WHEN TOO_MANY_ROWS THEN
                           v_pasexec := 4;
                           RAISE ex_mas_de_una_actividad;
                        WHEN NO_DATA_FOUND THEN
                           BEGIN
                              /*p_tab_error(f_sysdate, f_user, v_object, 22,
                                          'v_cramo ' || v_cramo || ' ' || 'v_cmodali '
                                          || v_cmodali || ' ' || 'v_ctipseg ' || v_ctipseg
                                          || ' ' || 'v_ccolect ' || v_ccolect || ' '
                                          || 'v_ccomisi ' || v_ccomisi_actual || ' '
                                          || 'p_fecha ' || p_fecha || ' ' || 'v_iprianu_gar '
                                          || v_iprianu_gar || ' ',
                                          0);*/
                              /*EN QUE A袿 DE LA VIDA DE LA POLIZA ME ENCUENTRO*/
                              v_rescriterio_duracion :=
                                              TRUNC(MONTHS_BETWEEN(p_fecha, v_fefecto) / 12)
                                              + 1;
                              /*CUANTON DURA LA POLIZA*/
                              v_rescriterio_duracion2 :=
                                               TRUNC(MONTHS_BETWEEN(v_fvencim, v_fefecto) / 12);

                              /*el criterio que uso*/
                              SELECT DISTINCT 'PROD', ccriterio
                                         INTO v_nivel, v_criterio
                                         FROM comisionprod_criterio cp
                                        WHERE cramo = v_cramo
                                          AND cmodali = v_cmodali
                                          AND ctipseg = v_ctipseg
                                          AND ccolect = v_ccolect
                                          /*AND cmodcom = p_cmodcom  --rdd*/
                                          AND ccomisi = v_ccomisi_actual
                                          AND p_fecha BETWEEN finivig AND NVL(ffinvig,
                                                                              p_fecha + 1)
                                          /*AND v_iprianu_gar BETWEEN ndesde AND nhasta*/
                                          AND DECODE(ccriterio,
                                                     1, v_iprianu_gar,
                                                     v_rescriterio_duracion2) >= ndesde
                                          AND DECODE(ccriterio,
                                                     1, v_iprianu_gar,
                                                     v_rescriterio_duracion2) <= nhasta
                                          AND v_rescriterio_duracion >= ninialt
                                          AND v_rescriterio_duracion <= nfinalt
                                          AND finivig =
                                                (SELECT finivig
                                                   FROM comisionvig
                                                  WHERE ccomisi = v_ccomisi_actual
                                                    AND cestado = 2
                                                    AND TRUNC(p_fecha) BETWEEN finivig
                                                                           AND NVL
                                                                                 (ffinvig,
                                                                                  TRUNC
                                                                                       (p_fecha)));
                           EXCEPTION
                              WHEN TOO_MANY_ROWS THEN
                                 v_pasexec := 4;
                                 RAISE ex_mas_de_un_producto;
                              WHEN NO_DATA_FOUND THEN
                                 /*pasar al siguiente tipo de comisiones, no hi han comis definides d'aquest tipus                      -- Comissi??existent*/
                                 NULL;
                              WHEN OTHERS THEN
                                 RAISE ex_error_leer_producto;
                           END;
                        WHEN OTHERS THEN
                           RAISE ex_error_leer_actividad;
                     END;
                  WHEN OTHERS THEN
                     RAISE ex_error_leer_garantia;
               END;
            END IF;

            /* buscar datos para obtener el % de comisi??*/
            v_where := ' WHERE CRAMO = ' || v_cramo || ' AND cmodali = ' || v_cmodali
                       || ' AND ctipseg = ' || v_ctipseg || ' AND ccolect = ' || v_ccolect
                       || ' AND cmodcom = cmodcom ' || /*p_cmodcom */ ' AND ccomisi = '   --rdd
                       || v_ccomisi_actual   --|| ' AND '|| NVL(v_anuali, 1) || ' <= nfinalt '
                       || ' AND finivig =  (SELECT finivig ' || ' FROM comisionvig '
                       || ' WHERE ccomisi = ' || v_ccomisi_actual || ' AND cestado = 2 '
                       || ' AND TRUNC (to_date(''' || TO_CHAR(p_fecha, 'DD/MM/YYYY')
                       || ''', ''DD/MM/YYYY'')) ' || ' BETWEEN finivig '
                       || ' AND NVL  (ffinvig, TRUNC (to_date('''
                       || TO_CHAR(p_fecha, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')))' || ')';

            /*                        || ' and add_months(finivig, nfinalt * 12) >= trunc(to_date('''|| to_char(p_fecha, 'DD/MM/YYYY')|| ''', ''DD/MM/YYYY''))';*/
            IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'COMIS_CRITERIO'), 0) = 0 THEN
               IF v_nivel = 'GAR' THEN
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rdd el cmodcom
                  v_from := ' FROM COMISIONGAR ';
                  v_where := v_where || ' ' || ' AND cgarant = ' || p_cgarant
                             || ' AND cactivi = ' || v_cactivi || NVL(v_anuali, 1)
                             || ' <= nfinalt ';
               ELSIF v_nivel = 'ACTI' THEN
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rddel cmodcom
                  v_from := ' FROM COMISIONACTI ';
                  v_where := v_where || ' ' || ' AND cactivi = ' || v_cactivi;
               ELSE
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rdd el cmodcom
                  v_from := ' FROM COMISIONPROD ';
               END IF;

               v_where := v_where || ' AND ' || NVL(v_anuali, 1) || ' <= nfinalt ';
            ELSE
               /* comisiones por criterio*/
               IF v_nivel = 'GAR' THEN
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rdd
                  v_from := ' FROM COMISIONGAR_CRITERIO ';
                  v_where := v_where || ' ' || ' AND cgarant = ' || p_cgarant
                             || ' AND cactivi = ' || v_cactivi;
               ELSIF v_nivel = 'ACTI' THEN
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rdd
                  v_from := ' FROM COMISIONACTI_CRITERIO ';
                  v_where := v_where || ' ' || ' AND cactivi = ' || v_cactivi;
               ELSE
                  v_select := 'SELECT cmodcom,PCOMISI, ninialt, nfinalt';   --rdd
                  v_from := ' FROM COMISIONPROD_CRITERIO ';
               END IF;

               v_where := v_where || ' and trunc(to_date(''' || TO_CHAR(p_fecha, 'DD/MM/YYYY')
                          || ''', ''DD/MM/YYYY'')) '
                          || ' between finivig and nvl(ffinvig, to_date('''
                          || TO_CHAR(p_fecha, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'')) ';
               /*IF v_criterio = 1 THEN
                  v_ncriterio := TRUNC(p_ipricom);
               END IF;

               IF v_criterio = 2 THEN
                  --v_ncriterio := TRUNC(MONTHS_BETWEEN(v_fvencim, p_fecha) / 12);
                  v_ncriterio := TRUNC(MONTHS_BETWEEN(v_fefecto, p_fecha) / 12);
               END IF;*/
               v_where := v_where || ' AND DECODE(ccriterio,1, ' || TO_CHAR(v_iprianu_gar)
                          || ',' || TO_CHAR(v_rescriterio_duracion2)
                          || ') >= ndesde AND DECODE(ccriterio,1, ' || TO_CHAR(v_iprianu_gar)
                          || ',' || TO_CHAR(v_rescriterio_duracion2) || ') <= nhasta AND '
                          || TO_CHAR(v_rescriterio_duracion) || ' >= ninialt AND '
                          || TO_CHAR(v_rescriterio_duracion) || ' <= nfinalt';
            END IF;

            v_sentencia := v_select || v_from || v_where;
            /*p_tab_error(f_sysdate, f_user, v_object, 666,
                        'pac_comisiones.f_grabarcomisionmovimiento',
                        SUBSTR(v_sentencia, 1, 2500));*/

            BEGIN
               /*               EXECUTE IMMEDIATE v_sentencia*/
                   /*                            INTO v_pcomisi, v_ninialt, v_nfinalt;*/
               OPEN v_cursor_criterios FOR v_sentencia;

               /* Fetch rows from result set one at a time:*/
               LOOP
                  FETCH v_cursor_criterios
                   INTO v_cmodcom, v_pcomisi, v_ninialt, v_nfinalt;

                  IF v_modo = 'CAR' THEN
                     BEGIN
                        INSERT INTO garancarcom
                                    (sseguro, nriesgo, cgarant, sproces, finiefe,
                                     cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                     ipricom, cageven)
                             VALUES (p_sseguro, p_nriesgo, p_cgarant, p_sproces, p_fecha, /*p_cmodcom*/
                                     v_cmodcom, v_pcomisi, v_ninialt, v_nfinalt, NULL, /*rdd*/
                                     p_ipricom, v_agente_actual);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE garancarcom
                              SET pcomisi = v_pcomisi,
                                  nfinalt = v_nfinalt,
                                  pcomisicua = NULL,
                                  ipricom = p_ipricom
                            WHERE sseguro = p_sseguro
                              AND nriesgo = p_nriesgo
                              AND cgarant = p_cgarant
                              AND sproces = p_sproces
                              AND finiefe = p_fecha
                              AND cmodcom = v_cmodcom   /*rdd*/
                              AND ninialt = v_ninialt
                              AND cageven = v_agente_actual;
                     END;
                  ELSIF v_modo = 'TRASP_CAR' THEN   --Nuevo traspaso de cartera
                     /*p_tab_error(f_sysdate, f_user, v_object, 21, 'ENTRO PORTFOLIO ', 3);*/
                     BEGIN
                        INSERT INTO garansegcom
                                    (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                                     cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                     ipricom, cageven)
                             VALUES (p_sseguro, p_nriesgo, p_cgarant, p_nmovimi, p_fecha,
                                     v_cmodcom, v_pcomisi, v_ninialt, v_nfinalt, NULL,
                                     p_ipricom, v_agente_actual);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE garansegcom
                              SET pcomisi = v_pcomisi,
                                  nfinalt = v_nfinalt,
                                  pcomisicua = NULL,
                                  ipricom = p_ipricom
                            WHERE sseguro = p_sseguro
                              AND nriesgo = p_nriesgo
                              AND cgarant = p_cgarant
                              AND nmovimi = p_nmovimi
                              AND finiefe = p_fecha
                              AND cmodcom = v_cmodcom   /*rdd*/
                              AND ninialt = v_ninialt
                              AND cageven = v_agente_actual;
                     END;
                  ELSE
                     BEGIN
                        INSERT INTO estgaransegcom
                                    (sseguro, nriesgo, cgarant, nmovimi, finiefe,
                                     cmodcom, pcomisi, ninialt, nfinalt, pcomisicua,
                                     ipricom, cageven)
                             VALUES (p_sseguro, p_nriesgo, p_cgarant, p_nmovimi, p_fecha,
                                     v_cmodcom, v_pcomisi, v_ninialt, v_nfinalt, NULL,
                                     p_ipricom, v_agente_actual);
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX THEN
                           UPDATE estgaransegcom
                              SET pcomisi = v_pcomisi,
                                  nfinalt = v_nfinalt,
                                  pcomisicua = NULL,
                                  ipricom = p_ipricom
                            WHERE sseguro = p_sseguro
                              AND nriesgo = p_nriesgo
                              AND cgarant = p_cgarant
                              AND nmovimi = p_nmovimi
                              AND finiefe = p_fecha
                              AND cmodcom = v_cmodcom   /*rdd*/
                              AND ninialt = v_ninialt
                              AND cageven = v_agente_actual;
                     END;
                  END IF;

                  EXIT WHEN v_cursor_criterios%NOTFOUND;
               END LOOP;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  /* esta excepci??e captura porque el proceso se ejctuta dos veces desde la pantalla, tanto al darle al boton de fixin rates como al guardar la poliza*/
                  NULL;
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END IF;   /* if v_pcomisi_actual is not null*/
      END LOOP;   /* fin bucle agente padre/hijo*/

      /*INSERT INTO consulta
           VALUES ('regresa 0');*/
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN 1;
      WHEN ex_seguro_no_existe THEN
         RETURN 103286;
      WHEN ex_acceso_seguro THEN
         RETURN 9906355;
      WHEN ex_mas_de_una_garantia THEN
         RETURN 9906356;
      WHEN ex_mas_de_una_actividad THEN
         RETURN 9906357;
      WHEN ex_mas_de_un_producto THEN
         RETURN 9906358;
      WHEN ex_error_leer_producto THEN
         RETURN 103216;
      WHEN ex_error_leer_actividad THEN
         RETURN 103628;
      WHEN ex_error_leer_garantia THEN
         RETURN 110824;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(p_mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_grabarcomisionmovimiento;

   /*************************************************************************
   Insereix el par鄊etre de percentatge de retrocessi?de comissions
   param in pnempres     : C骴igo empresa
   param in pnmesi      : Mes inicial
   param in pnmesf     : Mes final
   param in pnanulac  : Porcentaje de retrocesi騨
   return              : 0.- OK, 1.- KO
   Bug 33977-204337 - 13/05/2015 - VCG
   *************************************************************************/
   FUNCTION f_ins_confclawback(
      pnempres IN NUMBER,
      pnmesi IN NUMBER,
      pnmesf IN NUMBER,
      pnanulac IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros  - pnempres: ' || pnempres || ' - pnmesi: ' || pnmesi || ' - pnmesf: '
            || pnmesf || ' - pnanulac: ' || pnanulac;
      vobject        VARCHAR2(200) := 'PAC_COMISIONES.f_ins_confclawback';
   BEGIN
      BEGIN
         INSERT INTO clawback_conf
                     (cempres, nmes_i, nmes_f, panulac)
              VALUES (pnempres, pnmesi, pnmesf, pnanulac);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE clawback_conf
               SET nmes_i = pnmesi,
                   nmes_f = pnmesf,
                   panulac = pnanulac
             WHERE cempres = pnempres
               AND nmes_i = pnmesi
               AND nmes_f = pnmesf
               AND panulac = pnanulac;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ins_confclawback;

   /*************************************************************************
    Actualitza el par鄊etre de percentatge de retrocessi?de comissions
    param in pnempres     : C骴igo empresa
    param in pnmesi      : Mes inicial
    param in pnmesf     : Mes final
    param in pnanulac  : Porcentaje de retrocesi騨
    return              : 0.- OK, 1.- KO
    Bug 33977-204337 - 13/05/2015 - VCG
    *************************************************************************/
   FUNCTION f_upd_confclawback(
      pnempres IN NUMBER,
      pnmesi_old IN NUMBER,
      pnmesi_new IN NUMBER,
      pnmesf_old IN NUMBER,
      pnmesf_new IN NUMBER,
      pnanulac_old IN NUMBER,
      pnanulac_new IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros  - pnempres: ' || pnempres || ' - pnmesi: ' || pnmesi_old
            || ' - pnmesf: ' || pnmesf_old || ' - pnanulac: ' || pnanulac_old;
      vobject        VARCHAR2(200) := 'PAC_COMISIONES.f_upd_confclawback';
   BEGIN
      IF pnmesi_new IS NOT NULL
         AND pnmesf_new IS NOT NULL
         AND pnanulac_new IS NOT NULL THEN
         UPDATE clawback_conf
            SET nmes_i = pnmesi_new,
                nmes_f = pnmesf_new,
                panulac = pnanulac_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NOT NULL
         AND pnmesf_new IS NOT NULL
         AND pnanulac_new IS NULL THEN
         UPDATE clawback_conf
            SET nmes_i = pnmesi_new,
                nmes_f = pnmesf_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NOT NULL
         AND pnmesf_new IS NULL
         AND pnanulac_new IS NOT NULL THEN
         UPDATE clawback_conf
            SET nmes_i = pnmesi_new,
                panulac = pnanulac_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NOT NULL
         AND pnmesf_new IS NULL
         AND pnanulac_new IS NULL THEN
         UPDATE clawback_conf
            SET nmes_i = pnmesi_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NULL
         AND pnmesf_new IS NOT NULL
         AND pnanulac_new IS NOT NULL THEN
         UPDATE clawback_conf
            SET nmes_f = pnmesf_new,
                panulac = pnanulac_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NULL
         AND pnmesf_new IS NOT NULL
         AND pnanulac_new IS NULL THEN
         UPDATE clawback_conf
            SET nmes_f = pnmesf_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;

      IF pnmesi_new IS NULL
         AND pnmesf_new IS NULL
         AND pnanulac_new IS NOT NULL THEN
         UPDATE clawback_conf
            SET panulac = pnanulac_new
          WHERE cempres = pnempres
            AND nmes_i = pnmesi_old
            AND nmes_f = pnmesf_old
            AND panulac = pnanulac_old;

         RETURN 0;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_upd_confclawback;

   /*************************************************************************
      Esborra el par鄊etre de percentatge de retrocessi?de comissions
      param in pnempres     : C骴igo empresa
      param in pnmesi      : Mes inicial
      param in pnmesf     : Mes final
      param in pnanulac  : Porcentaje de retrocesi騨
      return              : 0.- OK, 1.- KO
      Bug 33977-204337 - 13/05/2015 - VCG
      *************************************************************************/
   FUNCTION f_del_confclawback(
      pnempres IN NUMBER,
      pnmesi IN NUMBER,
      pnmesf IN NUMBER,
      pnanulac IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(8) := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'parametros  - pnempres: ' || pnempres || ' - pnmesi: ' || pnmesi || ' - pnmesf: '
            || pnmesf || ' - pnanulac: ' || pnanulac;
      vobject        VARCHAR2(200) := 'PAC_COMISIONES.f_upd_confclawback';
   BEGIN
      DELETE      clawback_conf
            WHERE cempres = pnempres
              AND nmes_i = pnmesi
              AND nmes_f = pnmesf
              AND panulac = pnanulac;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_confclawback;

   /*************************************************************************
         Recupera  los datos de porcentajes de retrocesi髇 de comisiones
         param in pnempres     : C骴igo empresa
         param in pnmesi      : Mes inicial
         param in pnmesf     : Mes final
         param in pnanulac  : Porcentaje de retrocesi騨
         return              : codigo de error
      *************************************************************************/
   FUNCTION f_get_confclawback(squery IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := SUBSTR(squery, 1, 1900);
      vobject        VARCHAR2(200) := 'PAC_COMISIONES.f_get_confclawback';
      terror         VARCHAR2(200) := 'No se puede recuperar la informaci??n';
   BEGIN
      OPEN cur FOR squery;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_confclawback;


/*************************************************************************
	Recupera  los datos de cuadros de comisiones ya existentes
	param in ccomisi     : Código de comision
	return               : Numero de codigo de comision
	*************************************************************************/

   	FUNCTION f_valida_cuadro(
			pccomisi	IN	NUMBER
	) RETURN NUMBER
	IS
      e_params EXCEPTION;
	  vobjectname    VARCHAR2(500):='PAC_COMISIONES.f_valida_cuadro';
	  vparam         VARCHAR2(100):=' pccomisi='
	                         || pccomisi;
	  vpasexec       NUMBER(5):=1;
    v_igualdad     NUMBER := 0;
    v_conteo_new   NUMBER := 0;
    v_contador     NUMBER := 0;

    CURSOR ca ( w_conteo_new   NUMBER ) IS
        SELECT COUNT(1), c.ccomisi
        FROM comisionprod c
        WHERE c.ccomisi != pccomisi
        GROUP BY c.ccomisi
        HAVING
            COUNT(1) = v_conteo_new
        ORDER BY c.ccomisi;

    CURSOR c0 ( w_ccomisi   NUMBER ) IS
        SELECT c.sproduc, c.pcomisi
        FROM comisionprod c
        WHERE c.ccomisi = w_ccomisi
        ORDER BY c.sproduc, c.ccomisi;

    CURSOR c2 IS
        SELECT * FROM comisionprod c
        WHERE c.ccomisi = pccomisi
        ORDER BY c.sproduc;

BEGIN
    IF pccomisi IS NULL THEN
       RAISE e_params;
    END IF;

    SELECT COUNT(1)
    INTO v_conteo_new
    FROM comisionprod c
    WHERE c.ccomisi = pccomisi;

    FOR ca_r IN ca(v_conteo_new) LOOP
        SELECT COUNT (1)
        INTO v_contador
        FROM comisionprod c, comisionprod d
        WHERE c.pcomisi = d.pcomisi
            AND c.sproduc = c.sproduc
            AND c.ccomisi = pccomisi
            AND d.ccomisi = ca_r.ccomisi;

        IF
            v_contador > 0
        THEN
        SELECT distinct d.ccomisi
        INTO v_igualdad
        FROM comisionprod c, comisionprod d
        WHERE c.pcomisi = d.pcomisi
            AND c.sproduc = c.sproduc
            AND c.ccomisi = pccomisi
            AND d.ccomisi = ca_r.ccomisi;
        END IF;
    END LOOP;

     RETURN v_igualdad;
	EXCEPTION
	  WHEN e_params THEN
	             RETURN 103135;
	END f_valida_cuadro;


	/*************************************************************************
	Elimina  los datos del cuadro de comision elegido
	param in ccomisi     : Código de comision
	return               : Mensaje de error
	*************************************************************************/
   FUNCTION f_anular_cuadro(
      pccomisi IN NUMBER)
      RETURN NUMBER IS
      v_return       NUMBER := 0;
      vparam         VARCHAR2(2000) := 'parámetros - pccomisi = ' || pccomisi;
      vobject        VARCHAR2(200) := 'PAC_COMISIONES.F_ANULAR_CUADRO';
      v_cestado      NUMBER;
      BEGIN

      IF pccomisi IS NULL THEN
         RETURN -1;
      ELSE
          SELECT DISTINCT c.cestado
          INTO v_cestado
          FROM COMISIONVIG c
          WHERE c.ccomisi = pccomisi;

       IF v_cestado = 1 THEN
         delete from comisionprod c
            where c.ccomisi = pccomisi;
        delete from COMISIONVIG m
            where m.ccomisi = pccomisi;
        delete from descomision d
            where d.ccomisi = pccomisi;
        delete from CODICOMISIO s
            where s.ccomisi = pccomisi;
         COMMIT;
         RETURN v_return;
        ELSE
         RETURN 1;
        END IF;
      END IF;
   END f_anular_cuadro;
END pac_comisiones;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMISIONES" TO "PROGRAMADORESCSI";
