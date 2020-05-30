--------------------------------------------------------
--  DDL for Package Body PAC_IMPAGA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IMPAGA" IS
   /******************************************************************************
      NOMBRE:     PAC_IMPAGA
      PROPÓSITO:  Funciones para la gestión de impagados

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        28/01/2010   NCC                1. BUG11425 : Creación del package.
      2.0        13/06/2012   APD                2. 0022342: MDP_A001-Devoluciones
   ******************************************************************************/
   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_get_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pctipoimp IN NUMBER,
      pidioma IN NUMBER,
      pfiltroprod IN VARCHAR2,
      pcagente IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psproduc=' || psproduc || ' pcramo= ' || pcramo || ' pctipoimp=' || pctipoimp
            || ' pidioma=' || pidioma || ' pfiltroprod=' || pfiltroprod || ' pcagente='
            || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.F_get_prodreprec';
      vwhere         VARCHAR2(300);
   BEGIN
      -- Bug 22342 - APD - 13/06/2012 - el producto o el agente deben estar informados
      IF ((psproduc IS NULL
           AND pcagente IS NULL)
          OR pidioma IS NULL) THEN
         RETURN 180261;
      END IF;

      -- fin Bug 22342 - APD - 13/06/2012
      IF pctipoimp IS NOT NULL THEN
         vwhere := vwhere || ' and ctipoimp = ' || pctipoimp;
      END IF;

      IF psidprodp IS NOT NULL THEN
         vwhere := vwhere || ' and sidprodp = ' || psidprodp;
      END IF;

      -- Bug 22342 - APD - 13/06/2012 - se añade filtro psproduc
      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and sproduc = ' || psproduc;
      END IF;

      -- fin Bug 22342 - APD - 13/06/2012

      -- Bug 22342 - APD - 13/06/2012 - se añade filtro pcagente
      IF pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and cagente = ' || pcagente;
      END IF;

      -- fin Bug 22342 - APD - 13/06/2012
      psquery :=
         'SELECT sidprodp, finiefe, ffinefe,
                   ff_desvalorfijo(223,' || pidioma
         || ', ctipnimp) tiponumimpaga,  ff_desvalorfijo(212,' || pidioma
         || ', ctipoimp) ttipoimp,ctipoimp, ctipnimp
              FROM prodreprec WHERE 1=1 ';
      psquery := psquery || vwhere || ' order by ctipoimp, finiefe desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_get_prodreprec;

   FUNCTION f_elimina_prodreprec(psidprodp IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'psproduc=' || psidprodp;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_elimina_prodreprec';
   BEGIN
      IF (psidprodp IS NULL) THEN
         RETURN 180261;
      END IF;

      UPDATE prodreprec
         SET ffinefe = NULL
       WHERE (sproduc = (SELECT sproduc
                           FROM prodreprec
                          WHERE sidprodp = psidprodp)
              OR cagente = (SELECT cagente
                              FROM prodreprec
                             WHERE sidprodp = psidprodp))
         AND ctipoimp = (SELECT ctipoimp
                           FROM prodreprec
                          WHERE sidprodp = psidprodp)
         AND ffinefe = (SELECT finiefe - 1
                          FROM prodreprec
                         WHERE sidprodp = psidprodp);

      DELETE FROM detprodreprec
            WHERE sidprodp = psidprodp;

      DELETE FROM prodreprec
            WHERE sidprodp = psidprodp;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_elimina_prodreprec;

   -- Bug 22342 - APD - 13/06/2012 - se añade el parametro pcagente
   FUNCTION f_set_prodreprec(
      psidprodp IN NUMBER,
      psproduc IN NUMBER,
      pfiniefe IN DATE,
      pctipoimp IN NUMBER,
      pctipnimp IN NUMBER,
      pcagente IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psproduc=' || psproduc || ' pfiniefe= ' || pfiniefe || ' pctipoimp=' || pctipoimp
            || ' pctipnimp=' || pctipnimp || ' pcagente=' || pcagente;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_set_prodreprec';
      wfini          DATE;
      wnewsidprodp   NUMBER;
      vcont          NUMBER;
   BEGIN
      -- Bug 22342 - APD - 13/06/2012 - el producto o el agente deben estar informados
      IF ((psproduc IS NULL
           AND pcagente IS NULL)
          OR pfiniefe IS NULL
          OR pctipoimp IS NULL) THEN
         RETURN 180261;
      END IF;

      -- fin Bug 22342 - APD - 13/06/2012

      -- Bug 22342 - APD - 13/06/2012 - se añade la condicion OR cagente = pcagente
      SELECT MAX(finiefe)
        INTO wfini
        FROM prodreprec
       WHERE (sproduc = psproduc
              OR cagente = pcagente)
         AND ctipoimp = pctipoimp;

      -- fin Bug 22342 - APD - 13/06/2012
      IF pfiniefe <= wfini THEN
         RETURN 108884;
      END IF;

      IF psidprodp IS NOT NULL THEN
         wnewsidprodp := psidprodp;

         -- Bug 22342 - APD - 13/06/2012 - se añade la condicion OR cagente = pcagente
         SELECT COUNT(1)
           INTO vcont
           FROM prodreprec
          WHERE pfiniefe BETWEEN finiefe AND ffinefe
            AND(sproduc = psproduc
                OR cagente = pcagente)
            AND sidprodp != psidprodp
            AND pctipoimp = ctipoimp;

         -- fin Bug 22342 - APD - 13/06/2012
         IF vcont > 0 THEN
            RETURN 108884;
         END IF;
      ELSE
         SELECT sidprodp.NEXTVAL
           INTO wnewsidprodp
           FROM DUAL;
      END IF;

      BEGIN
         -- Bug 22342 - APD - 13/06/2012 - se añade el campo cagente
         INSERT INTO prodreprec
                     (sidprodp, sproduc, ctipoimp, finiefe, ffinefe, ctipnimp, cagente)
              VALUES (wnewsidprodp, psproduc, pctipoimp, pfiniefe, NULL, pctipnimp, pcagente);
      -- fin Bug 22342 - APD - 13/06/2012
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE prodreprec
               SET ctipoimp = pctipoimp,
                   finiefe = pfiniefe,
                   ctipnimp = pctipnimp
             WHERE sidprodp = wnewsidprodp;
      END;

      IF psidprodp IS NULL THEN
         -- Bug 22342 - APD - 13/06/2012 - se añade la condicion OR cagente = pcagente
         UPDATE prodreprec
            SET ffinefe = pfiniefe - 1
          WHERE (sproduc = psproduc
                 OR cagente = pcagente)
            AND ctipoimp = pctipoimp
            AND finiefe = wfini;
      -- fin Bug 22342 - APD - 13/06/2012
      ELSE
         -- Bug 22342 - APD - 13/06/2012 - se añade la condicion OR cagente = pcagente
         SELECT MAX(finiefe)
           INTO wfini
           FROM prodreprec
          WHERE (sproduc = psproduc
                 OR cagente = pcagente)
            AND ctipoimp = pctipoimp
            AND ffinefe IS NOT NULL;

         -- fin Bug 22342 - APD - 13/06/2012

         -- Bug 22342 - APD - 13/06/2012 - se añade la condicion OR cagente = pcagente
         UPDATE prodreprec
            SET ffinefe = pfiniefe - 1
          WHERE (sproduc = psproduc
                 OR cagente = pcagente)
            AND ctipoimp = pctipoimp
            AND finiefe = wfini;
      -- fin Bug 22342 - APD - 13/06/2012
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_set_prodreprec;

   FUNCTION f_get_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psidprodp=' || psidprodp || ' pcmotivo= ' || pcmotivo || ' pnimpagad='
            || pnimpagad || ' pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_get_detprodreprec';
      vwhere         VARCHAR2(500);
   BEGIN
      IF (psidprodp IS NULL
          OR pidioma IS NULL) THEN
         RETURN 180261;
      END IF;

      IF pcmotivo IS NOT NULL THEN
         vwhere := ' AND cmotivo = ' || pcmotivo;
      END IF;

      IF pnimpagad IS NOT NULL THEN
         vwhere := vwhere || ' AND nimpagad = ' || pnimpagad;
      END IF;

      /* psquery :=
          'SELECT nimpagad, pac_impaga.f_get_desctipcarta(cmodimm) cartaimme,
                         ff_desvalorfijo(204,'
          || pidioma
          || ', cactimm) acccionimme, ndiaavis dias,
                         pac_impaga.f_get_desctipcarta(cmodelo) carta, ff_desvalorfijo(204,'
          || pidioma
          || ', cactimp) accion
                       FROM detprodreprec
                     WHERE sidprodp = '
          || psidprodp || vwhere;*/
      psquery :=
         'SELECT  NIMPAGAD , CMOTIVO, ff_desvalorfijo(73,' || pidioma
         || ',cmotivo) TMOTIVO, NDIAAVIS,d.CMODELO,pac_impaga.f_get_desctipcarta( d.cmodelo,'
         || pidioma || ') tmodelo, CACTIMP,
ff_desvalorfijo(204,' || pidioma
         || ',CACTIMP) TACTIMP, CMODIMM ,
pac_impaga.f_get_desctipcarta( d.CMODIMM,' || pidioma || ') tmodeloimm ,
ff_desvalorfijo(204,' || pidioma
         || ',CACTIMM) TACTIMM,
CACTIMM,   CDIAAVIS,FF_DESVALORFIJO(224,' || pidioma
         || ',CDIAAVIS) TDIAAVIS
                      FROM detprodreprec d
                    WHERE sidprodp = '
         || psidprodp || vwhere || ' order by cmotivo, nimpagad asc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_get_detprodreprec;

   FUNCTION f_get_lstcartas(pidioma IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pidioma=' || pidioma;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_get_lstcartas';
      vwhere         VARCHAR2(500);
   BEGIN
      psquery :=
         ' SELECT t.ctipcar catribu, d.ttipcar tatribu
        FROM tiposcarta t, destiposcarta d
       WHERE t.cagrup = 0
         AND t.ctipcar = d.ctipcar
         and cidioma = '
         || pidioma;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_get_lstcartas;

   FUNCTION f_get_desctipcarta(pctipcar IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pctipcar=' || pctipcar;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_get_descTipcarta';
      wttipcar       VARCHAR2(200);
   BEGIN
      IF (pctipcar IS NULL) THEN
         RETURN '';
      END IF;

      SELECT d.ttipcar
        INTO wttipcar
        FROM tiposcarta t, destiposcarta d
       WHERE cagrup = 0
         AND t.ctipcar = pctipcar
         AND d.ctipcar = t.ctipcar
         AND d.cidioma = pcidioma;

      RETURN wttipcar;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN '';
   END f_get_desctipcarta;

   FUNCTION f_elimina_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pnimpagad IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psidprodp=' || psidprodp || ' pcmotivo= ' || pcmotivo || ' pnimpagad='
            || pnimpagad;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_elimina_detprodreprec';
      wfini          DATE;
      wnewsidprodp   NUMBER;
   BEGIN
      IF (psidprodp IS NULL
          OR pcmotivo IS NULL
          OR pnimpagad IS NULL) THEN
         RETURN 180261;
      END IF;

      DELETE FROM detprodreprec
            WHERE sidprodp = psidprodp
              AND cmotivo = pcmotivo
              AND nimpagad = pnimpagad;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_elimina_detprodreprec;

   FUNCTION f_set_detprodreprec(
      psidprodp IN NUMBER,
      pcmotivo IN NUMBER,
      pcmodimm IN NUMBER,
      pcactimm IN NUMBER,
      pcdiaavis IN NUMBER,
      pcmodelo IN NUMBER,
      pcactimp IN NUMBER,
      pndiaavis IN NUMBER,
      pnimpagad IN NUMBER,
      pmodo IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psidprodp=' || psidprodp || ' pcmotivo= ' || pcmotivo || ' pcmodimm=' || pcmodimm
            || 'pcactimm=' || pcactimm || ' pcdiaavis= ' || pcdiaavis || ' pcmodelo='
            || pcmodelo || 'pcactimp=' || pcactimp || ' pndiaavis= ' || pndiaavis
            || ' pnimpagad=' || pnimpagad || ' pmodo:' || pmodo;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_set_detprodreprec';
      wnimpagad      NUMBER;
   BEGIN
      IF (psidprodp IS NULL
          OR pcmotivo IS NULL) THEN
         RETURN 180261;
      END IF;

      IF (pcactimp IS NULL
          AND pcactimm IS NULL) THEN
         RETURN 180261;
      END IF;

      wnimpagad := pnimpagad;

      IF pmodo = 'ALTA' THEN
         IF pnimpagad IS NULL THEN
            SELECT NVL(MAX(nimpagad), 0) + 1
              INTO wnimpagad
              FROM detprodreprec
             WHERE sidprodp = psidprodp
               AND cmotivo = pcmotivo;
         END IF;

         BEGIN
            INSERT INTO detprodreprec
                        (sidprodp, nimpagad, cmotivo, ndiaavis, cmodelo, cactimp,
                         cmodimm, cactimm, cdiaavis)
                 VALUES (psidprodp, wnimpagad, pcmotivo, pndiaavis, pcmodelo, pcactimp,
                         pcmodimm, pcactimm, pcdiaavis);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               RETURN 108959;
         END;
      ELSIF pmodo = 'MODIF' THEN
         UPDATE detprodreprec
            SET cmodimm = pcmodimm,
                cactimm = pcactimm,
                cdiaavis = pcdiaavis,
                cmodelo = pcmodelo,
                cactimp = pcactimp,
                ndiaavis = pndiaavis
          WHERE sidprodp = psidprodp
            AND cmotivo = pcmotivo
            AND nimpagad = wnimpagad;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_set_detprodreprec;

   -- Bug 22342 - APD - 13/06/2012 - se modifican los parametros de entrada
   FUNCTION f_get_impagados(
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pctiprec IN NUMBER,
      pfaccini IN DATE,
      pfaccfin IN DATE,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnrecibo IN NUMBER,
      pnimpagad IN NUMBER,
      pcoficina IN NUMBER,
      pcagente IN NUMBER,
      pcmotivo IN NUMBER,
      pccarta IN NUMBER,
      pcactimp IN NUMBER,
      pcidioma IN NUMBER,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pcramo=' || pcramo || ' psproduc=' || psproduc
            || ' pctiprec=' || pctiprec || ' pfaccini=' || TO_CHAR(pfaccini, 'dd/mm/yyyy')
            || ' pfaccfin=' || TO_CHAR(pfaccfin, 'dd/mm/yyyy') || ' pnpoliza=' || pnpoliza
            || ' pncertif=' || pncertif || ' pnrecibo=' || pnrecibo || ' pnimpagad='
            || pnimpagad || ' pcoficina=' || pcoficina || ' pcagente=' || pcagente
            || ' pcmotivo=' || pcmotivo || ' pccarta=' || pccarta || ' pcactimp=' || pcactimp
            || ' pcidioma=' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.F_get_impagados';
      vwhere         VARCHAR2(10000);
   BEGIN
      IF psseguro IS NOT NULL THEN
         vwhere := vwhere || ' and s.sseguro = ' || psseguro;
      END IF;

      IF pcramo IS NOT NULL THEN
         vwhere := vwhere || ' and s.cramo = ' || pcramo;
      END IF;

      IF psproduc IS NOT NULL THEN
         vwhere := vwhere || ' and s.sproduc = ' || psproduc;
      END IF;

      IF pctiprec IS NOT NULL THEN
         vwhere := vwhere || ' and r.ctiprec = ' || pctiprec;
      END IF;

      IF pfaccini IS NOT NULL THEN
         vwhere := vwhere || ' and trunc(ti.ffejecu) between ' || CHR(39) || pfaccini
                   || CHR(39);

         IF pfaccfin IS NULL THEN
            vwhere := vwhere || ' and ' || CHR(39) || f_sysdate || CHR(39);
         END IF;
      END IF;

      IF pfaccfin IS NOT NULL
         AND pfaccini IS NOT NULL THEN
         vwhere := vwhere || ' and ' || CHR(39) || pfaccfin || CHR(39);
      END IF;

      IF pnpoliza IS NOT NULL THEN
         vwhere := vwhere || ' and s.npoliza = ' || pnpoliza;
      END IF;

      IF pncertif IS NOT NULL THEN
         vwhere := vwhere || ' and s.ncertif = ' || pncertif;
      END IF;

      IF pnrecibo IS NOT NULL THEN
         vwhere := vwhere || ' and r.nrecibo = ' || pnrecibo;
      END IF;

      IF pnimpagad IS NOT NULL THEN
         vwhere := vwhere || ' and ti.nimpagad = ' || pnimpagad;
      END IF;

      IF pcoficina IS NOT NULL THEN
         vwhere :=
            vwhere
            || ' and pac_redcomercial.f_busca_padre(r.cempres, r.cagente, null, null) = '
            || pcoficina;
      END IF;

      IF pcagente IS NOT NULL THEN
         vwhere := vwhere || ' and r.cagente = ' || pcagente;
      END IF;

      IF pcmotivo IS NOT NULL THEN
         vwhere := vwhere || ' and ti.cmotivo = ' || pcmotivo;
      END IF;

      IF pccarta IS NOT NULL THEN
         vwhere := vwhere || ' and ti.ccarta = ' || pccarta;
      END IF;

      IF pcactimp IS NOT NULL THEN
         vwhere := vwhere || ' and ti.cactimp = ' || pcactimp;
      END IF;

      psquery :=
         'Select s.sproduc,
f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,' || pcidioma
         || ') tproducto,
ra.cramo, ra.tramo,
r.sseguro,
s.npoliza, s.ncertif,
ti.nrecibo,
r.cagente'
         || '||'' - ''||'
         || 'f_desagente_t(r.cagente) tcagente,
ti.ffejecu faccion,
r.ctiprec,
ff_desvalorfijo(8,'
         || pcidioma || ',r.ctiprec) ttiprec,
ti.nimpagad,
ti.cmotivo,
ff_desvalorfijo(73,' || pcidioma
         || ',ti.cmotivo) tmotivo,
d.ctipcar,
d.ttipcar,
ti.cactimp,
ff_desvalorfijo(204,' || pcidioma || ',ti.cactimp) taccion,
ti.ctractat,
ff_desvalorfijo(92,' || pcidioma
         || ',ti.ctractat) ttractat,
pac_redcomercial.f_busca_padre(r.cempres, r.cagente, null, null) coficina,
f_desagente_t(pac_redcomercial.f_busca_padre(r.cempres, r.cagente, null, null)) toficina,
r.cempres, pac_isqlfor.f_empresa(s.sseguro) tempresa
from tmp_impagados ti, recibos r, seguros s, destiposcarta d, ramos ra
Where ti.nrecibo = r.nrecibo
And r.sseguro = s.sseguro
And ti.ccarta = d.ctipcar(+)
And ra.cramo = s.cramo '
         || ' And d.cidioma(+) = ' || pcidioma || ' And ra.cidioma = ' || pcidioma;
      psquery := psquery || vwhere || ' Order by ti.ffejecu desc';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_get_impagados;

   FUNCTION f_get_detimpagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      psquery OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
           := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.F_get_detimpagado';
   BEGIN
      psquery :=
         'SELECT s.npoliza, t.nrecibo, t.cmotivo motivodev, t.ffejecu faccion, t.ffecalt falta,
                    t.cactimp accion, t.ctractat situacion, t.ttexto infoadd, t.terror
                    FROM tmp_impagados t, seguros s
                    WHERE t.sseguro = s.sseguro
                       AND t.sseguro ='
         || psseguro || ' AND t.nrecibo = ' || pnrecibo || ' AND t.ffejecu = ' || pfaccion;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_get_detimpagado;

   FUNCTION f_set_impagado(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pfaccion IN DATE,
      pfalta IN DATE,
      pcmotdev IN NUMBER,
      pcaccion IN NUMBER,
      pcsituac IN NUMBER,
      pttexto IN VARCHAR2,
      pterror IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion
            || 'pfalta=' || pfalta || ' pcmotdev= ' || pcmotdev || ' pcaccion=' || pcaccion
            || 'pcsituac=' || pcsituac || ' pttexto= ' || pttexto || ' pterror=' || pterror;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_set_impagado';
      wsseguro       NUMBER;
   BEGIN
      IF (psseguro IS NULL
          OR pnrecibo IS NULL) THEN
         RETURN 180261;
      END IF;

      SELECT sseguro
        INTO wsseguro
        FROM recibos
       WHERE nrecibo = pnrecibo;

      IF (wsseguro <> psseguro) THEN
         RETURN 180261;
      END IF;

      BEGIN
         INSERT INTO tmp_impagados
                     (sseguro, nrecibo, ffejecu, ffecalt, cactimp, ctractat, ttexto,
                      cmotivo, terror, ccarta, nimpagad, sdevolu, smovrec)
              VALUES (psseguro, pnrecibo, pfaccion, pfalta, pcaccion, pcsituac, pttexto,
                      pcmotdev, pterror, NULL, NULL, NULL, NULL);

         RETURN 0;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE tmp_impagados
               SET ffejecu = pfaccion,
                   ffecalt = pfalta,
                   cactimp = pcaccion,
                   ctractat = pcsituac,
                   ttexto = pttexto,
                   terror = pterror
             WHERE sseguro = psseguro
               AND nrecibo = pnrecibo;

            RETURN 0;
      END;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_set_impagado;

   FUNCTION f_elimina_impagado(psseguro IN NUMBER, pnrecibo IN NUMBER, pfaccion IN DATE)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
           := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pfaccion=' || pfaccion;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_elimina_impagado';
   BEGIN
      DELETE      tmp_impagados
            WHERE sseguro = psseguro
              AND nrecibo = pnrecibo
              AND ffejecu = pfaccion;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, NULL, vparam, SQLERRM);
         RETURN 1000132;
   END f_elimina_impagado;

   -- Funcion para modificar la acción o la carta de un impagado
   -- Bug 22342 - APD - 13/06/2012 - se crea la funcion
   FUNCTION f_set_acccarta(
      psseguro IN NUMBER,
      pnrecibo IN NUMBER,
      pcactimp IN NUMBER,
      pffejecu IN DATE,
      pcactact IN NUMBER,
      pccarta IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'psseguro=' || psseguro || ' pnrecibo= ' || pnrecibo || ' pcactimp=' || pcactimp
            || 'pffejecu=' || TO_CHAR(pffejecu, 'DD/MM/YYYY') || ' pcactact= ' || pcactact
            || ' pccarta=' || pccarta;
      vobject        VARCHAR2(200) := 'PAC_IMPAGA.f_set_acccarta';
      wsseguro       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnrecibo IS NULL
         OR pcactimp IS NULL
         OR pffejecu IS NULL
         OR pcactact IS NULL THEN
         RETURN 180261;
      END IF;

      vpasexec := 2;

      -- pcactimp: Acción a realizar anterior
      -- pcactact: Acción a realizar actual
      UPDATE tmp_impagados
         SET ccarta = pccarta,
             cactimp = pcactact
       WHERE nrecibo = pnrecibo
         AND sseguro = psseguro
         AND cactimp = pcactimp
         AND ffejecu = pffejecu;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;
   END f_set_acccarta;
END pac_impaga;

/

  GRANT EXECUTE ON "AXIS"."PAC_IMPAGA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMPAGA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMPAGA" TO "PROGRAMADORESCSI";
