--------------------------------------------------------
--  DDL for Function F_ACT_HISSEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ACT_HISSEG" (psseguro IN NUMBER, pnmovimi IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /***********************************************************************
       F_ACT_HISSEG: Funció que inserta a la taula historicoseguros amb la
                     informació prèvia a una modificació de la taula seguros.
           Retorna 0 => Si no hi ha error, <>0 => número d'error.
       MODIFICAT: 05-01-2007 XCG S'afegeix el camp SEGUROS_AHO.NDURPER en el traspas de taules
       MODIFICAT: 17-12-2007 ACC S'afegeix els camps SEGUROS.CTIPBAN SEGUROS.CTIPCOB
       3.0        03/01/2012   JMF             3. 0020761 LCOL_A001- Quotes targetes
       4.0        11/04/2012   ETM             4. 0021924: MDP - TEC - Nuevos campos en pantalla de Gestión (Tipo de retribución, Domiciliar 1º recibo, Revalorización franquicia)
       5.0        17/03/2016   JAEG            5. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
   ***********************************************************************/

   -- ini BUG 0026070  - 18/02/2013 - JMF
   v_obj          VARCHAR2(200) := 'f_act_hisseg';
   v_par          VARCHAR2(200) := 'psseguro=' || psseguro || ' pnmovimi=' || pnmovimi;
   v_pas          NUMBER(4) := 1;
   -- fin BUG 0026070  - 18/02/2013 - JMF
   lerror         NUMBER := 0;
   xf1paren       DATE := NULL;
   xfcarult       DATE := NULL;
   xttexto        VARCHAR2(50);
   xndurper       NUMBER(6);
   xfrevisio      DATE;
   xcgasges       NUMBER(3);
   xcgasred       NUMBER(3);
   xcmodinv       NUMBER(4);
   xfrevant       DATE;
   -- BUG 0022839 - FAL - 24/07/2012
   x_ctipcol      seguroscol.ctipcol%TYPE;
   x_ctipcob      seguroscol.ctipcob%TYPE;
   x_ctipvig      seguroscol.ctipvig%TYPE;
   x_recpor       seguroscol.recpor%TYPE;
   x_cagrupa      seguroscol.cagrupa%TYPE;
   x_prorrexa     seguroscol.prorrexa%TYPE;
   x_cmodalid     seguroscol.cmodalid%TYPE;
   x_fcorte       seguroscol.fcorte%TYPE;
   x_ffactura     seguroscol.ffactura%TYPE;
   -- FI BUG 0022839
   -- BUG 23074 - JLB - 30/07/2012
   x_cagastexp    seguroscol.cagastexp%TYPE;
   x_cperiogast   seguroscol.cperiogast%TYPE;
   x_iimporgast   seguroscol.iimporgast%TYPE;
   v_nmovimi      movseguro.nmovimi%TYPE;
-- BUG - F - 23074
BEGIN
   v_pas := 100;

   BEGIN
      BEGIN
         SELECT f1paren
           INTO xf1paren
           FROM seguros_ren
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            xf1paren := NULL;
      END;

      BEGIN
         SELECT fcarult
           INTO xfcarult
           FROM seguros_assp
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            xfcarult := NULL;
      END;

      --Bug 24680/136868 - XVM - 14/02/2013
      v_pas := 120;

      SELECT NVL(MAX(nmovimi), pnmovimi)   --Si no encontramos nada, que haga lo mismo que hasta ahora
        INTO v_nmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND nmovimi <= pnmovimi
         AND cmovseg NOT IN(52);   --que no sea anulación ni regularización

      --Bug 24680/136868 - XVM - 14/02/2013
      BEGIN
         SELECT ttexto
           INTO xttexto
           FROM bloqueoseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND finicio = (SELECT MAX(finicio)
                             FROM bloqueoseg
                            WHERE sseguro = psseguro
                              AND nmovimi = v_nmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            xttexto := NULL;
      END;

      --modificació : XCG 05-01-2007 afegim el camp ndurper
      BEGIN
         SELECT ndurper, frevisio, frevant
           INTO xndurper, xfrevisio, xfrevant
           FROM seguros_aho
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            xndurper := NULL;
      END;

      --modificació : RSC 17-09-2007 afegim els camps de despeses de Unit Linked
      BEGIN
         SELECT cgasges, cgasred
           INTO xcgasges, xcgasred
           FROM seguros_ulk
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            xcgasges := NULL;
            xcgasred := NULL;
      END;

      --modificació : RSC 20-09-2007 afegim el camp de model d'inversió de Unit Linked
      BEGIN
         SELECT cmodinv
           INTO xcmodinv
           FROM seguros_ulk
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            xcmodinv := NULL;
      END;

      -- BUG 0022839 - FAL - 24/07/2012
      BEGIN
         SELECT ctipcol, ctipcob, ctipvig, recpor, cagrupa, prorrexa, cmodalid,
                fcorte, ffactura   -- BUG 23074 - JLB - 30/07/2012
                                , cagastexp,
                cperiogast, iimporgast
           -- BUG -F - 23074
         INTO   x_ctipcol, x_ctipcob, x_ctipvig, x_recpor, x_cagrupa, x_prorrexa, x_cmodalid,
                x_fcorte, x_ffactura   -- BUG 23074 - JLB - 30/07/2012
                                    , x_cagastexp,
                x_cperiogast, x_iimporgast
           -- BUG - F - 23074
         FROM   seguroscol
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            x_ctipcol := NULL;
            x_ctipcob := NULL;
            x_ctipvig := NULL;
            x_recpor := NULL;
            x_cagrupa := NULL;
            x_prorrexa := NULL;
            x_cmodalid := NULL;
            x_fcorte := NULL;
            x_ffactura := NULL;
            -- BUG 23074 - JLB - 30/07/2012
            x_cagastexp := NULL;
            x_cperiogast := NULL;
            x_iimporgast := NULL;
      -- BUG -F - 23074
      END;

      -- FI BUG 0022839

      -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
      -- BUG 0022839 - FAL - 24/07/2012
      -- FI BUG 0022839
      -- BUG 23074 - JLB - 30/07/2012
      -- BUG 23074
      -- BUG 0026070  - 18/02/2013 - JMF: añadir FRENOVA
      v_pas := 200;

      BEGIN
          DELETE historicoseguros
           WHERE sseguro = psseguro
             AND nmovimi = v_nmovimi;
      EXCEPTION
        WHEN OTHERS THEN
            NULL;
      END;

      INSERT INTO historicoseguros
                  (sseguro, nmovimi, fmovimi, casegur, cagente, nsuplem, fefecto, creafac,
                   ctarman, cobjase, ctipreb, cactivi, ccobban, ctipcoa, ctiprea, crecman,
                   creccob, ctipcom, fvencim, femisio, fanulac, fcancel, csituac, cbancar,
                   ctipcol, fcarant, fcarpro, fcaranu, cduraci, nduraci, nanuali, iprianu,
                   cidioma, nfracci, cforpag, pdtoord, nrenova, crecfra, tasegur, creteni,
                   ndurcob, sciacoa, pparcoa, npolcoa, nsupcoa, tnatrie, pdtocom, prevali,
                   irevali, ncuacoa, nedamed, crevali, cempres, cagrpro, nsolici, f1paren,
                   fcarult, ttexto, ccompani, ndurper, frevisio, cgasges, cgasred, cmodinv,
                   ctipban, ctipcob, sprodtar, frevant, ncuotar, ctipretr, cindrevfran,
                   precarg, pdtotec, preccom, cplancolect, ccobtip, ctipvig, recpor, cagrupa,
                   prorrexa, cmodalid, fcorte, ffactura, cagastexp, cperiogast, iimporgast,
                   frenova,
                   fefeplazo, fvencplazo) -- BUG 41143/229973 - 17/03/2016 - JAEG)
         (SELECT sseguro, v_nmovimi, f_sysdate, casegur, cagente, nsuplem, fefecto, creafac,
                 ctarman, cobjase, ctipreb, cactivi, ccobban, ctipcoa, ctiprea, crecman,
                 creccob, ctipcom, fvencim, femisio, fanulac, fcancel, csituac, cbancar,
                 ctipcol, fcarant, fcarpro, fcaranu, cduraci, nduraci, nanuali, iprianu,
                 cidioma, nfracci, cforpag, pdtoord, nrenova, crecfra, tasegur, creteni,
                 ndurcob, sciacoa, pparcoa, npolcoa, nsupcoa, tnatrie, pdtocom, prevali,
                 irevali, ncuacoa, nedamed, crevali, cempres, cagrpro, nsolici, xf1paren,
                 xfcarult, xttexto, ccompani, xndurper, xfrevisio, xcgasges, xcgasred,
                 xcmodinv, ctipban, ctipcob, sprodtar, xfrevant, ncuotar, ctipretr,
                 cindrevfran, precarg, pdtotec, preccom, x_ctipcol, x_ctipcob, x_ctipvig,
                 x_recpor, x_cagrupa, x_prorrexa, x_cmodalid, x_fcorte, x_ffactura,
                 x_cagastexp, x_cperiogast, x_iimporgast, frenova,
                 fefeplazo, fvencplazo -- BUG 41143/229973 - 17/03/2016 - JAEG
            FROM seguros
           WHERE sseguro = psseguro);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_obj, v_pas, v_par,
                     'mov=' || v_nmovimi || ' f1p=' || xf1paren || ' car=' || xfcarult
                     || ' tec=' || xttexto || ' sqlerrm=' || SQLERRM);
         -- Error a l'insertar a la taula historicoseguros
         lerror := 109383;
   END;

   RETURN lerror;
END f_act_hisseg;

/

  GRANT EXECUTE ON "AXIS"."F_ACT_HISSEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ACT_HISSEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ACT_HISSEG" TO "PROGRAMADORESCSI";
