--------------------------------------------------------
--  DDL for Package Body PAC_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DESCUENTOS" IS
   /******************************************************************************
      NOMBRE:     PAC_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuentos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        29/02/2012   JRB               1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
      Recupera un cuadro de descuentos
      param in pcdesc   : codigo de descuento
      param in ptdesc   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param in pidioma    : codigo del idioma
      param out pquery    : select a ejecutar
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrosdescuento(
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pffechaini IN DATE,
      pffechafin IN DATE,
      pidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := ' SELECT C.CDESC,D.TDESC,C.CTIPO,V.FINIVIG,V.FFINVIG,V.CESTADO'
                || ' FROM CODIDESC C,DESCVIG V,DESDESC D' || ' WHERE c.CDESC = v.CDESC'
                || ' AND v.cdesc = d.CDESC' || ' AND d.CIDIOMA =' || pidioma
                || ' AND (c.CDESC = ''' || pcdesc || ''' or ''' || pcdesc || ''' IS NULL)'
                || ' AND upper(d.tdesc) like upper(''%' || ptdesc || '%' || CHR(39) || ')'
                --|| ' AND (c.ctipo = ''' || pctipo || ''' or ''' || pctipo || ''' IS NULL)  '
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
         pquery := pquery || ' AND FFINVIG IS NULL ';
      END IF;

      pquery := pquery || 'order by cdesc desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_get_cuadrosdescuento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_cuadrosdescuento;

   FUNCTION f_set_cab_descuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE)
      RETURN NUMBER IS
      vfmax          DATE;
   BEGIN
      IF pffinvig IS NOT NULL THEN
         IF pfinivig > pffinvig THEN
            RETURN 101922;   --fecha inicial no mayor que final
         END IF;
      END IF;

      -- BUG 20826 - 103313 - GAG - LCOL_C001: Incidencias de Cuadros de comisión
      BEGIN
         SELECT finivig
           INTO vfmax
           FROM descvig
          WHERE cdesc = pcdesc
            AND ffinvig IS NULL;

         IF pfinivig < vfmax THEN
            RETURN 108884;   --fecha de inicio tiene que ser mayor a la de los registros anteriores
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      -- FIN BUG 20182 - 22/11/2011 - JTS - LCOL_C001 - Problema con las alturas de comisiones
      BEGIN
         INSERT INTO codidesc
                     (cdesc, ctipo)
              VALUES (pcdesc, NVL(pctipo, 1));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE codidesc
               SET ctipo = NVL(pctipo, 1)
             WHERE cdesc = pcdesc;
      END;

      BEGIN
         UPDATE descvig
            SET ffinvig = pfinivig - 1
          WHERE cdesc = pcdesc
            AND ffinvig IS NULL;

         INSERT INTO descvig
                     (cdesc, finivig, ffinvig, cestado)
              VALUES (pcdesc, pfinivig, pffinvig, pcestado);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE descvig
               SET cestado = pcestado,
                   ffinvig = pffinvig
             WHERE cdesc = pcdesc
               AND finivig = pfinivig;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user,
                     'pac_descuentos.f_set_cab_descuento pcdesc=' || pcdesc || ' pctipo='
                     || pctipo,
                     1, 'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_cab_descuento;

   FUNCTION f_set_descdescuento(pcdesc IN NUMBER, pcidioma IN NUMBER, ptdesc IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      BEGIN
         INSERT INTO desdesc
                     (cdesc, cidioma, tdesc)
              VALUES (pcdesc, pcidioma, ptdesc);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE desdesc
               SET tdesc = ptdesc
             WHERE cdesc = pcdesc
               AND cidioma = pcidioma;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_set_descdescuento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_descdescuento;

   /*************************************************************************
      Duplica un cuadro de descuentos
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro(
      pcdesc_ori IN NUMBER,
      pcdesc_nuevo IN NUMBER,
      ptdesc_nuevo IN VARCHAR2,
      pidioma IN NUMBER)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER;
   BEGIN
      vpasexec := 1;

      SELECT COUNT(cdesc)
        INTO vcount
        FROM codidesc
       WHERE cdesc = pcdesc_nuevo;

      IF vcount > 0 THEN
         RETURN 9901353;
      END IF;

      SELECT COUNT('1')
        INTO vcount
        FROM codidesc c, descvig v
       WHERE c.cdesc = v.cdesc
         AND c.cdesc = pcdesc_ori
         AND(v.ffinvig IS NULL
             OR v.ffinvig > TRUNC(f_sysdate));

      IF vcount = 0 THEN
         RETURN 9901454;
      END IF;

      INSERT INTO codidesc
                  (cdesc, ctipo)
         (SELECT pcdesc_nuevo, NVL(ctipo, 1)
            FROM codidesc
           WHERE cdesc = pcdesc_ori);

      vpasexec := 2;

      INSERT INTO desdesc
                  (cidioma, cdesc, tdesc)
           VALUES (pidioma, pcdesc_nuevo, ptdesc_nuevo);

      vpasexec := 3;

      INSERT INTO descvig
                  (cdesc, finivig, ffinvig, cestado)
         (SELECT pcdesc_nuevo, finivig, ffinvig, 1   --El estado siempre 1 al duplicar
            FROM descvig v
           WHERE cdesc = pcdesc_ori
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      vpasexec := 4;

--------
      INSERT INTO descprod
                  (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc, sproduc, finivig,
                   ninialt, nfinalt)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, pcdesc_nuevo, p.cmoddesc, p.pdesc,
                 p.sproduc, p.finivig, ninialt, nfinalt
            FROM descprod p, descvig v
           WHERE p.cdesc = pcdesc_ori
             AND p.cdesc = v.cdesc
             AND p.finivig = (SELECT MAX(pp.finivig)
                                FROM descprod pp
                               WHERE pp.cdesc = p.cdesc
                                 AND pp.cramo = p.cramo
                                 AND pp.cmodali = p.cmodali
                                 AND pp.ctipseg = p.ctipseg
                                 AND pp.ccolect = p.ccolect
                                 AND pp.sproduc = p.sproduc
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      vpasexec := 5;

      INSERT INTO descacti
                  (cdesc, cactivi, cramo, cmoddesc, pdesc, cmodali, ctipseg, ccolect, sproduc,
                   finivig, ninialt, nfinalt)
         (SELECT pcdesc_nuevo, a.cactivi, a.cramo, a.cmoddesc, a.pdesc, a.cmodali, a.ctipseg,
                 a.ccolect, a.sproduc, a.finivig, ninialt, nfinalt
            FROM descacti a, descvig v
           WHERE a.cdesc = pcdesc_ori
             AND a.cdesc = v.cdesc
             AND a.finivig = (SELECT MAX(pp.finivig)
                                FROM descacti pp
                               WHERE pp.cdesc = a.cdesc
                                 AND pp.cramo = a.cramo
                                 AND pp.cmodali = a.cmodali
                                 AND pp.ctipseg = a.ctipseg
                                 AND pp.ccolect = a.ccolect
                                 AND pp.sproduc = a.sproduc
                                 AND pp.cactivi = a.cactivi
                                 AND pp.finivig >= v.finivig)
             AND(v.ffinvig IS NULL
                 OR v.ffinvig > TRUNC(f_sysdate)));

      vpasexec := 6;

      INSERT INTO descgar
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cdesc, cmoddesc, pdesc,
                   sproduc, finivig, ninialt, nfinalt)
         (SELECT g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant, pcdesc_nuevo,
                 g.cmoddesc, g.pdesc, g.sproduc, g.finivig, ninialt, nfinalt
            FROM descgar g, descvig v
           WHERE g.cdesc = pcdesc_ori
             AND g.cdesc = v.cdesc
             AND g.finivig = (SELECT MAX(pp.finivig)
                                FROM descgar pp
                               WHERE pp.cdesc = g.cdesc
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

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_duplicar_cuadro', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_duplicar_cuadro;

   FUNCTION f_get_detalle_descuento(
      pcdesc IN NUMBER,
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
      pcmoddesc IN NUMBER,
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
      --
      vwhereproalt   VARCHAR2(32000);
      vwhereactalt   VARCHAR2(32000);
      vwheregaralt   VARCHAR2(32000);
   BEGIN
      IF pcdesc IS NOT NULL THEN
         vwhere := vwhere || ' and  c.cdesc =' || pcdesc;
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

      IF pcmoddesc IS NOT NULL THEN
         vwhere := vwhere || ' and  c.cmoddesc =' || pcmoddesc;

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
      END IF;

      IF pfinivig IS NOT NULL THEN
         vwhere_vig := vwhere_vig || ' AND v.FINIVIG <= ' || 'TO_DATE('''
                       || TO_CHAR(pfinivig, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY'') '
                       || 'and v.finivig = (select max(vv.finivig) from descvig vv '
                       || 'where vv.cdesc = v.cdesc ' || 'and vv.finivig <= TO_DATE('''
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

      vquery :=
         'SELECT   sproduc,ttitulo,  trotulo, cactivi,tactivi,  cgarant,  tgarant,nivel, cdesc,  finivig,
         cmoddesc, tmoddesc, pdesc, ninialt, nfinalt, ffinvig
         from
         ( SELECT   c.sproduc, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 1, '
         || pidioma
         || ') ttitulo, f_desproducto_t(c.cramo, c.cmodali, c.ctipseg, c.ccolect, 2, '
         || pidioma
         || ') trotulo,
         NULL cactivi, NULL tactivi, NULL cgarant, NULL tgarant, 1 nivel, c.cdesc, c.finivig,
         c.cmoddesc,
         ff_desvalorfijo(67, '
         --CAMBIAR EL VALOR FIJO
         || pidioma
         || ', cmoddesc) tmoddesc,  c.pdesc, c.ninialt, c.nfinalt, CASE WHEN v.cestado = 2 THEN f_sysdate ELSE v.ffinvig END ffinvig
    FROM descprod c, productos p, descvig v
    where p.cramo = c.cramo
    and p.cmodali = c.cmodali
    and p.ctipseg = c.ctipseg
    and p.ccolect = c.ccolect
    and c.cdesc = v.cdesc
    and c.finivig = (select max(cc.finivig)
      from descprod cc
      where cc.cdesc = c.cdesc
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
         c.cdesc, c.finivig, cmoddesc, ff_desvalorfijo(67, '
         --CAMBIAR EL VALOR FIJO
         || pidioma
         || ', cmoddesc) tmoddesc,  c.pdesc, c.ninialt, c.nfinalt, CASE WHEN v.cestado = 2 THEN f_sysdate ELSE v.ffinvig END ffinvig
    FROM descacti c, productos p, descvig v
    where p.cramo = c.cramo
    and p.cmodali = c.cmodali
    and p.ctipseg = c.ctipseg
    and p.ccolect = c.ccolect
    and c.cdesc = v.cdesc
    and c.finivig = (select max(cc.finivig)
      from descacti cc
      where cc.cdesc = c.cdesc
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
         ff_desgarantia(cgarant, '
         || pidioma
         || ') tgarant,  3 nivel, c.cdesc, c.finivig, cmoddesc, ff_desvalorfijo(67, '
         --CAMBIAR EL VALOR FIJO
         || pidioma
         || ', cmoddesc) tmoddesc,  c.pdesc, c.ninialt, c.nfinalt, CASE WHEN v.cestado = 2 THEN f_sysdate ELSE v.ffinvig END ffinvig
    FROM descgar c, productos p, descvig v
    where p.cramo = c.cramo
    and p.cmodali = c.cmodali
    and p.ctipseg = c.ctipseg
    and p.ccolect = c.ccolect
    and c.cdesc = v.cdesc
    and c.finivig = (select max(cc.finivig)
      from descgar cc
      where cc.cdesc = c.cdesc
      and cc.cramo = c.cramo
      and cc.cmodali = c.cmodali
      and cc.ctipseg = c.ctipseg
      and cc.ccolect = c.ccolect
      and cc.cactivi = c.cactivi
      and cc.cgarant = c.cgarant
      and cc.finivig <= nvl('
         || vpfinivig || ',v.finivig) ) ' || vwhere || vwhere_vig || vwhereact || vwheregar
         || vwheregar2 || vwheregaralt;

      --TODOS
      IF NVL(ptodos, 0) = 1 THEN
         vquery_tot :=
            '  union
                SELECT p.sproduc, f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 1, '
            || pidioma
            || ') ttitulo,
                   f_desproducto_t(p.cramo, p.cmodali, p.ctipseg, p.ccolect, 2, '
            || pidioma
            || ') trotulo, NULL cactivi,
                   NULL tactivi, NULL cgarant, NULL tgarant, 1 nivel, NULL cdesc, NULL finivig,
                   d.catribu cmoddesc, ff_desvalorfijo(67, '
            --CAMBIAR EL VALOR FIJO
            || pidioma
            || ', d.catribu) tmoddesc, NULL pdesc, null ninialt, null nfinalt, null ffinvig
                FROM productos p, detvalores d, codiram cod
                WHERE NOT EXISTS(SELECT ''1''
                                FROM descprod c, productos p2, descvig v
                               WHERE p2.cramo = c.cramo
                                 AND p2.cmodali = c.cmodali
                                 AND p2.ctipseg = c.ctipseg
                                 AND p2.ccolect = c.ccolect
                                 AND c.cdesc = v.cdesc
                                 AND c.finivig = v.finivig
                                 AND v.ffinvig IS NULL
                                 AND c.cdesc = '
            || pcdesc
            || 'AND c.cmoddesc = d.catribu
                                 and p2.sproduc =  p.sproduc)
               AND d.cvalor = 67
               AND d.cidioma = '
            --CAMBIAR EL VALOR FIJO
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
           AND cactivi = a.cactivi) tactivi, NULL cgarant, NULL tgarant, 2 nivel, NULL cdesc,
       NULL finivig, d.catribu cmoddesc, ff_desvalorfijo(67, '
            --CAMBIAR EL VALOR FIJO
            || pidioma
            || ', d.catribu) tmoddesc,
       NULL pdesc, null ninialt, null nfinalt, null ffinvig
  FROM productos p, detvalores d, activiprod a, codiram cod
 WHERE d.cvalor = 67
   AND d.cidioma = '
            --CAMBIAR EL VALOR FIJO
            || pidioma
            || '
   and cod.cempres = pac_iax_common.f_get_cxtempresa
   and cod.cramo = p.cramo
   AND a.cmodali = p.cmodali
   AND a.cramo = p.cramo
   AND a.ccolect = p.ccolect
   AND a.ctipseg = p.ctipseg
   AND NOT EXISTS(SELECT ''1''
                    FROM descacti c, productos p2, descvig v
                   WHERE p.cramo = c.cramo
                     AND p.cmodali = c.cmodali
                     AND p.ctipseg = c.ctipseg
                     AND p.ccolect = c.ccolect
                     AND c.cdesc = v.cdesc
                     AND c.finivig = v.finivig
                     AND v.ffinvig IS NULL
                     AND c.cdesc = '
            || pcdesc
            || 'AND p2.sproduc = p.sproduc
                     AND c.cmoddesc = d.catribu
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
       3 nivel, NULL cdesc, NULL finivig, d.catribu cmoddesc,
       ff_desvalorfijo(67, '
            --CAMBIAR EL VALOR FIJO
            || pidioma
            || ', d.catribu) tmoddesc, NULL pdesc, null ninialt, null nfinalt, null ffinvig
  FROM productos p, detvalores d, garanpro g, codiram cod
 WHERE d.cvalor = 67
   AND d.cidioma = '
            --CAMBIAR EL VALOR FIJO
            || pidioma
            || '
   and cod.cempres = pac_iax_common.f_get_cxtempresa
   and cod.cramo = p.cramo
   AND g.cmodali = p.cmodali
   AND g.ccolect = p.ccolect
   AND g.ctipseg = p.ctipseg
   AND g.cramo = p.cramo
   AND NOT EXISTS(SELECT ''1''
                    FROM descgar c, productos p2, descvig v
                   WHERE p2.cramo = c.cramo
                     AND p2.cmodali = c.cmodali
                     AND p2.ctipseg = c.ctipseg
                     AND p2.ccolect = c.ccolect
                     AND c.cdesc = v.cdesc
                     AND c.finivig = v.finivig
                     AND v.ffinvig IS NULL
                     AND c.cdesc = '
            || pcdesc
            || '
                     AND p2.sproduc = p.sproduc
                     AND c.cmoddesc = d.catribu
                     AND c.cactivi = g.cactivi
                     AND c.cgarant = g.cgarant)';
         vquery := vquery || vquery_tot;
      END IF;

      IF porderby IS NULL
         OR porderby = 1 THEN
         vorder :=
            vorder
            || ') ORDER BY sproduc ASC, cactivi DESC, cgarant DESC, cdesc, cmoddesc, ninialt';
      ELSIF porderby = 2 THEN
         vorder :=
            vorder
            || ') ORDER BY cdesc, cmoddesc, sproduc ASC, cactivi DESC, cgarant DESC, ninialt';
      END IF;

      pquery := vquery || vorder;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_comisiones.f_get_detalle_desc', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_detalle_descuento;

   FUNCTION f_set_detalle_descuento(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pfinivig IN DATE,
      pcmoddesc IN NUMBER,
      pcdesc IN NUMBER,
      ppdesc IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER)
      RETURN NUMBER IS
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vfinivig       DATE;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      IF pcgarant IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM descgar
                WHERE cdesc = pcdesc
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cmoddesc = pcmoddesc;
            END IF;

            INSERT INTO descgar
                        (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cdesc,
                         cmoddesc, pdesc, sproduc, finivig,
                         ninialt, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcgarant, pcdesc,
                         pcmoddesc, ppdesc, psproduc, NVL(pfinivig, vfinivig),
                         NVL(pninialt, 1), pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE descgar
                  SET pdesc = ppdesc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND cgarant = pcgarant
                  AND cdesc = pcdesc
                  AND cmoddesc = pcmoddesc
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);
         END;
      ELSIF pcactivi IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM descacti
                WHERE cdesc = pcdesc
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cactivi = pcactivi
                  AND cmoddesc = pcmoddesc;
            END IF;

            INSERT INTO descacti
                        (cramo, cmodali, ctipseg, ccolect, cactivi, cdesc, cmoddesc,
                         pdesc, sproduc, finivig, ninialt, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcactivi, pcdesc, pcmoddesc,
                         ppdesc, psproduc, NVL(pfinivig, vfinivig), NVL(pninialt, 1), pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE descacti
                  SET pdesc = ppdesc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cactivi = pcactivi
                  AND cdesc = pcdesc
                  AND cmoddesc = pcmoddesc
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);
         END;
      ELSIF psproduc IS NOT NULL THEN
         BEGIN
            IF pfinivig IS NULL THEN
               SELECT MAX(finivig)
                 INTO vfinivig
                 FROM descprod
                WHERE cdesc = pcdesc
                  AND cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND sproduc = psproduc
                  AND cmoddesc = pcmoddesc;
            END IF;

            INSERT INTO descprod
                        (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc,
                         sproduc, finivig, ninialt, nfinalt)
                 VALUES (vcramo, vcmodali, vctipseg, vccolect, pcdesc, pcmoddesc, ppdesc,
                         psproduc, NVL(pfinivig, vfinivig), NVL(pninialt, 1), pnfinalt);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE descprod
                  SET pdesc = ppdesc,
                      nfinalt = pnfinalt
                WHERE cramo = vcramo
                  AND cmodali = vcmodali
                  AND ctipseg = vctipseg
                  AND ccolect = vccolect
                  AND cdesc = pcdesc
                  AND cmoddesc = pcmoddesc
                  AND finivig = NVL(pfinivig, vfinivig)
                  AND ninialt = NVL(pninialt, 1);
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_set_detalle_descuento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_set_detalle_descuento;

   FUNCTION f_get_hist_cuadrodescuento(pcdesc IN NUMBER, pidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := ' SELECT C.CDESC,D.TDESC,C.CTIPO,V.FINIVIG,V.FFINVIG,V.CESTADO'
                || ' FROM CODIDESC C,DESCVIG V,DESDESC D' || ' WHERE c.CDESC = v.CDESC'
                || ' AND v.cdesc = d.CDESC' || ' AND d.CIDIOMA =' || pidioma
                || ' AND (c.CDESC = ''' || pcdesc || ''' or ''' || pcdesc
                || ''' IS NULL)
                order by finivig desc ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.hist_cuadrodescuento', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_hist_cuadrodescuento;

   /*************************************************************************
      Devuelve los cuadros de descuento con su % si lo tiene asignado
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
      -- BUG16363:JBL:31/05/2011:Inici
      IF pcnivel = 1 THEN
         psquery :=
            ' SELECT b.tdesc, b.cdesc, pc.pdesc, pc.ninialt, pc.nfinalt, b.cmoddesc, b.tmoddesc'
            || ' FROM (SELECT d.tdesc, d.cdesc, v.catribu cmoddesc, v.tatribu tmoddesc'
            || ' FROM codidesc cc, desdesc d, detvalores v' || ' WHERE d.cdesc = cc.cdesc'
            || ' AND d.cidioma =' || pcidioma || ' AND v.cvalor = 67'
            || ' AND v.cidioma = d.cidioma) b,'
            --CAMBIAR LA LISTA DE VALORES
            || ' (SELECT cp.cdesc, cp.pdesc , cp.cmoddesc, cp.ninialt, cp.nfinalt'
            || ' FROM productos p, descprod cp' || ' WHERE p.sproduc = ' || psproduc
            || ' AND cp.finivig = ' || CHR(39) || pcfinivig || CHR(39)
            || ' AND p.cramo = cp.cramo' || ' AND p.cmodali = cp.cmodali'
            || ' AND p.ctipseg = cp.ctipseg' || ' AND p.ccolect = cp.ccolect) pc'
            || ' WHERE b.cdesc = pc.cdesc(+)' || ' AND b.cmoddesc = pc.cmoddesc(+)'
            || ' order by cdesc,cmoddesc,ninialt';
      ELSIF pcnivel = 2 THEN
         psquery :=
            ' SELECT b.tdesc, b.cdesc, pc.pdesc, pc.ninialt, pc.nfinalt, b.cmoddesc, b.tmoddesc'
            || ' FROM (SELECT d.tdesc, d.cdesc, v.catribu cmoddesc, v.tatribu tmoddesc'
            || ' FROM codidesc cc, desdesc d, detvalores v' || ' WHERE d.cdesc = cc.cdesc'
            || ' AND d.cidioma =' || pcidioma || ' AND v.cvalor = 67'
            || ' AND v.cidioma = d.cidioma) b,'
            --CAMBIAR EL VALOR FIJO
            || ' (SELECT ca.cdesc, ca.pdesc, ca.cmoddesc, ca.ninialt, ca.nfinalt'
            || ' FROM descacti ca, productos p' || ' WHERE p.sproduc = ' || psproduc
            || ' AND ca.cactivi = ' || pcactivi || ' AND ca.finivig = ' || CHR(39)
            || pcfinivig || CHR(39) || ' AND p.cramo = ca.cramo'
            || ' AND p.cmodali = ca.cmodali' || ' AND p.ctipseg = ca.ctipseg'
            || ' AND p.ccolect = ca.ccolect) pc' || ' WHERE b.cdesc = pc.cdesc(+)'
            || ' AND b.cmoddesc = pc.cmoddesc(+)' || ' order by cdesc,cmoddesc,ninialt';
      ELSIF pcnivel = 3 THEN
         psquery :=
            ' SELECT b.tdesc, b.cdesc, pc.pdesc, pc.ninialt, pc.nfinalt, b.cmoddesc, b.tmoddesc'
            || ' FROM (SELECT d.tdesc, d.cdesc, v.catribu cmoddesc, v.tatribu tmoddesc'
            || ' FROM codidesc cc, desdesc d, detvalores v' || ' WHERE d.cdesc = cc.cdesc'
            || ' AND d.cidioma =' || pcidioma || ' AND v.cvalor = 67'
            || ' AND v.cidioma = d.cidioma) b,'
            --CAMBIAR EL VALOR FIJO
            || ' (SELECT cg.cdesc, cg.pdesc,  cg.cmoddesc, cg.ninialt, cg.nfinalt'
            || ' FROM descgar cg, productos p' || ' WHERE p.sproduc = ' || psproduc
            || ' AND cg.cactivi = ' || pcactivi || ' AND cg.cgarant = ' || pcgarant
            || ' AND cg.finivig = ' || CHR(39) || pcfinivig || CHR(39)
            || ' AND p.cramo = cg.cramo' || ' AND p.cmodali = cg.cmodali'
            || ' AND p.ctipseg = cg.ctipseg' || ' AND p.ccolect = cg.ccolect) pc'
            || ' WHERE b.cdesc = pc.cdesc(+)' || ' AND b.cmoddesc = pc.cmoddesc(+)'
            || ' order by cdesc,cmoddesc,ninialt';
      END IF;

      -- BUG16363:JBL:31/05/2011:Fi
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_get_porproducto', 1,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_get_porproducto;

   /****************************************************************
      Duplica el detalle de descuento a partir de un cdesc y una fecha
      param in pcdesc   : codigo de descuento
      param in pfinivi   : Fecha de inicio de vigencia      return : codigo de error
   *************************************************************************/
   FUNCTION f_dup_det_descuento(pcdesc IN NUMBER, pfinivig IN DATE)
      RETURN NUMBER IS
      vcount         NUMBER;
      vpasexec       NUMBER;
   BEGIN
      vpasexec := 1;

      INSERT INTO descprod
                  (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc, sproduc, finivig,
                   ninialt, nfinalt)
         (SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.cdesc, p.cmoddesc, p.pdesc,
                 p.sproduc, pfinivig, ninialt, nfinalt
            FROM descprod p, descvig v
           WHERE p.cdesc = pcdesc
             AND p.cdesc = v.cdesc
             AND p.finivig = (SELECT MAX(cc.finivig)
                                FROM descprod cc
                               WHERE cc.cdesc = p.cdesc
                                 AND cc.cramo = p.cramo
                                 AND cc.cmodali = p.cmodali
                                 AND cc.ctipseg = p.ctipseg
                                 AND cc.ccolect = p.ccolect
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      vpasexec := 2;

      INSERT INTO descacti
                  (cdesc, cactivi, cramo, cmoddesc, pdesc, cmodali, ctipseg, ccolect, sproduc,
                   finivig, ninialt, nfinalt)
         (SELECT a.cdesc, a.cactivi, a.cramo, a.cmoddesc, a.pdesc, a.cmodali, a.ctipseg,
                 a.ccolect, a.sproduc, pfinivig, ninialt, nfinalt
            FROM descacti a, descvig v
           WHERE a.cdesc = pcdesc
             AND a.cdesc = v.cdesc
             AND a.finivig = (SELECT MAX(cc.finivig)
                                FROM descacti cc
                               WHERE cc.cdesc = a.cdesc
                                 AND cc.cramo = a.cramo
                                 AND cc.cmodali = a.cmodali
                                 AND cc.ctipseg = a.ctipseg
                                 AND cc.ccolect = a.ccolect
                                 AND cc.cactivi = a.cactivi
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      vpasexec := 3;

      INSERT INTO descgar
                  (cramo, cmodali, ctipseg, ccolect, cactivi, cgarant, cdesc, cmoddesc, pdesc,
                   sproduc, finivig, ninialt, nfinalt)
         (SELECT g.cramo, g.cmodali, g.ctipseg, g.ccolect, g.cactivi, g.cgarant, g.cdesc,
                 g.cmoddesc, g.pdesc, g.sproduc, pfinivig, ninialt, nfinalt
            FROM descgar g, descvig v
           WHERE g.cdesc = pcdesc
             AND g.cdesc = v.cdesc
             AND g.finivig = (SELECT MAX(cc.finivig)
                                FROM descgar cc
                               WHERE cc.cdesc = g.cdesc
                                 AND cc.cramo = g.cramo
                                 AND cc.cmodali = g.cmodali
                                 AND cc.ctipseg = g.ctipseg
                                 AND cc.ccolect = g.ccolect
                                 AND cc.cactivi = g.cactivi
                                 AND cc.cgarant = g.cgarant
                                 AND cc.finivig >= v.finivig)
             AND v.ffinvig =(pfinivig - 1));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_dup_det_descuento', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_dup_det_descuento;

   /*************************************************************************
      Duplica un cuadro de descuentos de un producto
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
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

      SELECT MAX(p.finivig)
        INTO vdatemax
        FROM descprod p, productos prod
       WHERE p.cramo = prod.cramo
         AND p.cmodali = prod.cmodali
         AND p.ctipseg = prod.ctipseg
         AND p.ccolect = prod.ccolect
         AND prod.sproduc = pcsproduc;

      INSERT INTO descprod
                  (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc, sproduc, finivig,
                   ninialt, nfinalt)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.cdesc, p.cmoddesc, p.pdesc,
                p.sproduc, pcfinivig, ninialt, nfinalt
           FROM descprod p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      vpasexec := 5;

      INSERT INTO descacti
                  (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc, sproduc, finivig,
                   cactivi, ninialt, nfinalt)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.cdesc, p.cmoddesc, p.pdesc,
                p.sproduc, pcfinivig, p.cactivi, ninialt, nfinalt
           FROM descacti p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      vpasexec := 6;

      INSERT INTO descgar
                  (cramo, cmodali, ctipseg, ccolect, cdesc, cmoddesc, pdesc, sproduc, finivig,
                   cactivi, cgarant, ninialt, nfinalt)
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.cdesc, p.cmoddesc, p.pdesc,
                p.sproduc, pcfinivig, p.cactivi, p.cgarant, ninialt, nfinalt
           FROM descgar p, productos prod
          WHERE p.cramo = prod.cramo
            AND p.cmodali = prod.cmodali
            AND p.ctipseg = prod.ctipseg
            AND p.ccolect = prod.ccolect
            AND prod.sproduc = pcsproduc
            AND p.finivig = vdatemax;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_descuentos.f_duplicar_cuadro', vpasexec,
                     'error no controlado', SQLERRM);
         RETURN 1;
   END f_duplicar_cuadro_prod;
END pac_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DESCUENTOS" TO "PROGRAMADORESCSI";
