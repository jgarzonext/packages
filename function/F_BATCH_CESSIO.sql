--------------------------------------------------------
--  DDL for Function F_BATCH_CESSIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BATCH_CESSIO" (
   p_cempres IN NUMBER,
   p_scontra IN NUMBER,
   p_nversioa IN NUMBER,
   p_nversion IN NUMBER,
   p_fec IN DATE)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_BATCH_CESSIO: Aquesta funció permet crear moviments de
               regularització de pòlisses a CESIONESREA quant hi ha un
               canvi de contracte que afecta a la cessió ja generada amb
               la versió anterior.
                Poden regularitzar els moviments amb els següents CGENERA:
                  1 - regularitzacions
                  3 - nova producció
                  4 - suplement
                  5 - renovació
                  9 - rehabilitació
                 40 - allargament
                Es crean moviments amb els següents CGENERA:
                 1  - cessió possitiva amb la nova versió
                 30 - cessió negativa corresponent a la versió anterior
           Adaptació per corregir el càlcul de la cessió
              possitiva quant es tracta d'una pòlissa amb varies garanties
              alguna del les quals van al contracte general per producte
              i d'altres al corresponent per garantia.
          Condiderar els darrers canvis en la tarificació
                        per les pòlisses de vida.
          Per la tarificació es busca la data de cartera del
                        moviment que es regularitza.
         S'entran els paràmetres de recàrrec a la taula
                        auxiliar CESIONESAUX per la tarificació de Vida.
     Incorporación tema Decenales.

    Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   2.0        14/04/2009  XCG                1. Modificació de la funció. Utilizar la función ff_get_actividad para buscar la actividad BUG9614
   3.0        16/09/2009  FAL                2. 0011100: CRE046 - Revisión de cesionesrea. Crida a la pac_cesionesrea.f_gar_rea per si garantia reasegurable
   4.0        17/11/2009  JMF                3. 0011802 CRE - Regularització per canvi de versió
   5.0        16/03/2010  AVT                4. 0013504: CRE - Reaseguro del PPJ dinámico igual que el Credit Vida
   6.0        15/04/2010  AVT                5. 0014079: CRE206 - Retrocesión del contrato del reaseguro del PPJ Dinàmic en el detalle del recibo
   7.0        14/05/2010  AVT                6. 0014536: CRE200 - Reaseguro: Se requiere que un contrato se pueda utilizar
                                                en varias agrupaciones de producto
   8.0        13/08/2010  AVT                7. 0015744: CRE800 - Tancament de Reaseguro - pòlisses assignades a versions antigues de contracte
   9.0        22/10/2010  AVT                8. 0016329: CRE800 - Revisió processos de tancament
  10.0        23/02/2011  JGR                9. 0017672: CEM800 - Contracte Reaseguro 2011 - Añadir nuevo parámetro w_cdetces
  11.0        07/03/2012   AVT              10. 21559: LCOL999-Cambios en el Reaseguro: ceder con la versión inicial de la póliza o con la temporalidad del plan
  12.0        09/01/2013  AVT               11. 25545: LCOL_A004-Versiones 2013 Contratos Reaseguro
  13.0        25/05/2013  LCF               12.  0025803: RSA001 - Ampliar los decimales que utiliza iAXIS
  14.0        11/03/2013  AVT               13. 25545: LCOL_A004-Versiones 2013 Contratos Reaseguro (detectat error a la regularització de cúmuls)
  15.0        04/04/2013  KBR               14. 25545: LCOL_A004-Versiones 2013 Contratos Reaseguro (no evaluar pólizas que no cambien de versión)
  16.0        15/04/2013  AVT               15. 26203: Qtracker: 0006471: La poliza 1333 no esta cedida. PROD
  17.0        16/01/2015  AVT               16. 33910: Nuevos productos (bug hermano interno)
  18.0        23/12/2015  FAL               17. 0039441: Aplicar cambios contrato reaseguro Convenios Colectivos 2016 (bug hermano interno)
***************************************************************************/

   -- ini Bug 0011802 - 17/11/2009 - JMF
   v_errfun       VARCHAR2(030) := 'F_BATCH_CESSIO';
   v_errlin       NUMBER := 0;
   v_errpar       VARCHAR2(200)
      := 'e=' || p_cempres || ' c=' || p_scontra || ' va=' || p_nversioa || ' vn='
         || p_nversion || ' f=' || p_fec;
   -- fin Bug 0011802 - 17/11/2009 - JMF
   p_moneda       NUMBER;
   p_proces       procesoscab.sproces%TYPE;   --25803
   ttexto         VARCHAR2(100);
   codi_error     NUMBER := 0;
   err            NUMBER := 0;
   numlin         NUMBER := 0;
   w_fconini      cesionesrea.fefecto%TYPE;   --25803
   w_fconfin      cesionesrea.fefecto%TYPE;   --25803
   w_icapital     cesionesaux.icapital%TYPE;   --25803
   w_iprirea      NUMBER;   --25803
   w_iprianu      cesionesaux.iprirea%TYPE;   --25803
   w_cobjase      seguros.cobjase%TYPE;   --25803
   w_nasegur      riesgos.nasegur%TYPE;
   w_prima        NUMBER;   --25803;
   w_sseguro      cesionesrea.sseguro%TYPE;   --25803
   w_nmovimi      cesionesrea.nmovimi%TYPE;   --25803
   w_nriesgo      cesionesrea.nriesgo%TYPE;   --25803
   w_cgarant      cesionesrea.cgarant%TYPE;   --25803
   w_cfacult      seguros.creafac%TYPE;   --25803
   w_numlin       NUMBER(6) := 0;
   w_cramo        agr_contratos.cramo%TYPE;   --25803
   w_cmodali      seguros.cmodali%TYPE;   --25803
   w_ctipseg      seguros.ctipseg%TYPE;   --25803
   w_ccolect      seguros.ccolect%TYPE;   --25803
   w_cactivi      seguros.cactivi%TYPE;   --25803
   w_creaseg      NUMBER(1);
   w_scumulo      reariesgos.scumulo%TYPE;   --25803
   w_scontra      reariesgos.scontra%TYPE;   --25803
   w_nversio      reariesgos.nversio%TYPE;   --25803
   w_fsinies      DATE;
   w_scesrea      cesionesrea.scesrea%TYPE;   --25803--   w_sidepag      NUMBER(8); 14536 AVT 15-06-2010
   w_notractar    NUMBER := 0;
   quants         NUMBER := 0;
   w_scontra2     reariesgos.scontra%TYPE := 0;   --25803
   w_nversio2     reariesgos.nversio%TYPE := 0;   --25803
   w_trovat       NUMBER(1);
   w_ctarifa      tarifrea.ctarifa%TYPE;   --25803
   w_cvidaga      codicontratos.cvidaga%TYPE;   --25803
   w_ctipatr      coditarifa.ctipatr%TYPE;   --25803
   w_paplica      tarifrea.paplica%TYPE;   --25803
   edat           NUMBER;
   sexe           NUMBER;
   w_fedad        movseguro.fefecto%TYPE;   --25803;
   preg1          pregunseg.cpregun%TYPE;   --25803;
   preg5          pregunseg.cpregun%TYPE;   --25803;
   preg109        pregunseg.cpregun%TYPE;   --25803;
   w_ccolum       NUMBER(2);
   w_cfila        NUMBER(2);
   w_nanuali      NUMBER(2);
   w_pdtorea      NUMBER(5, 2);
   w_ipritar      cesionesaux.iprirea%TYPE;   --25803;
   w_atribu       NUMBER;
   w_iprima       NUMBER;
   fpolefe        cesionesrea.fefecto%TYPE;
   fpolvto        cesionesrea.fefecto%TYPE;
   w_nagrupa      NUMBER(4);
   w_fefecto      movseguro.fefecto%TYPE;   --25803;
   resul          NUMBER;   -- Decenales
   w_cvalpar      parproductos.cvalpar%TYPE;   --25803 -- Decenales
   w_crespue      pregunseg.crespue%TYPE;   --25803  -- Decenales
   w_icapaci      contratos.icapaci%TYPE;   --25803
   w_ipleno       contratos.iretenc%TYPE;   --25803
   w_sgt          NUMBER;
   w_ctarman      seguros.ctarman%TYPE;   --25803
   w_cforpag      seguros.cforpag%TYPE;   --25803
   w_cidioma      seguros.cidioma%TYPE;   --25803
   w_dias_origen  NUMBER;
   w_dias         NUMBER;
   w_icesion      cesionesrea.icesion%TYPE;   --25803
   w_ipritarrea   cesionesrea.ipritarrea%TYPE;   --25803
   w_idtosel      cesionesrea.idtosel%TYPE;   --25803
   pmoneda        NUMBER := 1;
   lnmovigen      cesionesrea.nmovigen%TYPE;   --25803
   avui           cesionesrea.fgenera%TYPE;   --25803
   w_finici       cesionesrea.fefecto%TYPE;   --25803
   v_retira       codicontratos.cretira%TYPE;   --25803   -- 13504 AVT 08-03-2010
   v_hiha         NUMBER;   -- 13504 AVT 16-03-2010
   v_detces       cesionesaux.cdetces%TYPE;   --25803   -- 14079 AVT 13-04-2010
   v_fvencim      cesionesrea.fvencim%TYPE;   --25803  -- 14536 AVT 08-06-2010
   v_pago         reembactosfac.ipago%TYPE;   --25803   -- 14536 AVT 08-06-2010
   vcmonpag       sin_tramita_pago.cmonpag%TYPE;   --25803
   vnsinies       sin_tramita_pago.nsinies%TYPE;   --25803
   vctippag       sin_tramita_pago.ctippag%TYPE;   --25803
   w_cdetces      cesionesaux.cdetces%TYPE;   --25803    -- BUG: 17672 JGR 23/02/2011
   w_fpolefe      cesionesrea.fefecto%TYPE;   --25803  -- 21559 AVT 07/03/2012
   v_tratar_seguro BOOLEAN;   --- 25545 KBR 04042013

   -- Bug 0011802 - 21/12/2009 - JMF Control cesiones sin duplicados.
   CURSOR cur_cesiones(
      c_scontra IN NUMBER,
      c_nversioa IN NUMBER,
      c_nversion IN NUMBER,   -- BUG 14536 AVT 28-05-2010
      c_fec IN DATE,
      c_retira IN NUMBER) IS
      SELECT UNIQUE sseguro, scontra, nversio, nmovimi, nriesgo, fefecto, fvencim, fanulac,
                    fregula, cgarant, scumulo, cgenera
               FROM cesionesrea
              WHERE scontra = c_scontra
                AND nversio >= c_nversioa   -- BUG 14536 AVT 28-05-2010
                AND nversio < c_nversion
                AND(icesion <> 0
                    AND icapces <> 0)   -- 33910 AVT 16/01/2015
                AND(cgenera = 01
                    OR cgenera = 03
                    OR cgenera = 04
                    OR cgenera = 05
                    OR cgenera = 09
                    OR cgenera = 40)
                AND(fefecto < fanulac
                    OR fanulac IS NULL)
                AND(fefecto < fregula
                    OR fregula IS NULL)   -- 15744 AVT 12-08-2010
                -- 13504 AVT 08-03-2010 s'afegeix si retira o no cartera
                AND((fefecto >= c_fec
                     AND c_retira = 0)
                    OR c_retira = 1)
                -- 13504 fi
                AND fvencim > c_fec   -- BUG 14536 AVT 28-05-2010
                AND(fanulac > c_fec
                    OR fanulac IS NULL)   --  evita que tiri enrera
                AND(fregula > c_fec
                    OR fregula IS NULL)
           ORDER BY sseguro, nmovimi, nriesgo, cgarant;

   -- Bug 0011802 - 21/12/2009 - JMF Agafa totes les anulacions.
   -- Bug 0011802 - 22/12/2009 - JMF Afegir moviment, risc i garantia.
   CURSOR cur_cesiones_anula(
      c_scontra IN NUMBER,
      c_nversioa IN NUMBER,
      c_nversion IN NUMBER,   -- BUG 14536 AVT 28-05-2010
      c_fec IN DATE,
      c_retira IN NUMBER,
      pc_sseguro IN NUMBER,
      pc_nmovimi IN NUMBER,
      pc_nriesgo IN NUMBER,
      pc_cgarant IN NUMBER) IS
      SELECT c.*, LEAST(c.fvencim, NVL(c.fanulac, c.fvencim), NVL(c.fregula, c.fvencim)) ffin
        FROM cesionesrea c
       WHERE scontra = c_scontra
         AND nversio >= c_nversioa   -- BUG 14536 AVT 28-05-2010
         AND nversio < c_nversion
         AND(cgenera = 01
             OR cgenera = 03
             OR cgenera = 04
             OR cgenera = 05
             OR cgenera = 09
             OR cgenera = 40)
         AND(fefecto < fanulac
             OR fanulac IS NULL)
         AND(fefecto < fregula
             OR fregula IS NULL)   -- 15744 AVT 12-08-2010
         -- 13504 AVT 08-03-2010 s'afegeix si retira o no cartera
         AND((fefecto >= c_fec
              AND c_retira = 0)
             OR c_retira = 1)
         -- 13504 fi
         AND fvencim > c_fec   -- BUG 14536 AVT 28-05-2010
         AND(fanulac > c_fec
             OR fanulac IS NULL)   --  evita que tiri enrera
         AND(fregula > c_fec
             OR fregula IS NULL)
         AND sseguro = pc_sseguro
         AND nmovimi = pc_nmovimi
         AND nriesgo = pc_nriesgo
         AND(cgarant = pc_cgarant
             OR(pc_cgarant IS NULL
                AND cgarant IS NULL));   -- Bug 29564/165198 - 04/02/2014 - AMC

   -- aquells registres ja anul.lats
   CURSOR cur_garant IS
      SELECT *
        FROM garanseg
       WHERE sseguro = w_sseguro
         AND nmovimi = w_nmovimi
         AND nriesgo = w_nriesgo
         AND(w_cgarant IS NULL
             OR(w_cgarant IS NOT NULL
                AND cgarant = w_cgarant));

--  Cursor per Vida
   CURSOR cur_cesaux2 IS
      SELECT *
        FROM cesionesaux
       WHERE scontra IS NOT NULL
         AND nversio IS NOT NULL
         AND sproces = p_proces;

   CURSOR cur_resp(w_sseguro IN NUMBER, w_nriesgo IN NUMBER) IS
      SELECT crespue, cpregun
        FROM pregunseg
       WHERE sseguro = w_sseguro
         AND nriesgo = w_nriesgo
         AND nmovimi IN(SELECT MAX(nmovimi)
                          FROM pregunseg
                         WHERE sseguro = w_sseguro
                           AND nriesgo = w_nriesgo);

----- Fins aquí els cursors de vida ----------
   CURSOR cur_pagos(c_ctr IN NUMBER, c_ver IN NUMBER, c_ver_n IN NUMBER, c_fec IN DATE) IS
      SELECT UNIQUE sseguro, nriesgo, cgarant, fcontab, fefecto, NVL(sidepag, 0) sidepag,
                    NVL(nsinies, 0) nsinies, NVL(nreemb, 0) nreemb, NVL(nfact, 0) nfact,
                    NVL(nlinea, 0) nlinea
               FROM cesionesrea c
              WHERE scontra = c_ctr
                AND nversio >= c_ver
                AND nversio < c_ver_n
                AND EXISTS(SELECT 1
                             FROM siniestros si, seguros se
                            WHERE c.sseguro = si.sseguro
                              AND c.nsinies = si.nsinies
                              AND fsinies >= c_fec
                              AND si.sseguro = se.sseguro
                              AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'),
                                      0) = 0
                           UNION
                           SELECT 1
                             FROM sin_siniestro si, seguros se
                            WHERE c.sseguro = si.sseguro
                              AND TO_CHAR(c.nsinies) = si.nsinies   -- 25545 09/01/2013 AVT
                              AND fsinies >= c_fec
                              AND si.sseguro = se.sseguro
                              AND NVL(pac_parametros.f_parempresa_n(se.cempres, 'MODULO_SINI'),
                                      0) = 1)
                AND cgenera = 2;

-- 14079 AVT 13-04-2010 detall per rebut
   CURSOR cur_rebut(
      ctr IN NUMBER,
      ver_a IN NUMBER,
      ver_n IN NUMBER,
      fini IN DATE,
      c_retira IN NUMBER) IS
      SELECT DISTINCT r.sseguro, r.nrecibo, r.fefecte, r.fvencim, cramo, cmodali, ctipseg,
                      ccolect, cactivi,
                      s.sproduc   -- 33910 AVT 26/01/2015 se está entrando tantas veces como garantías haya --> , c.cgarant   --25545 KBR 04042013
                 FROM reasegemi r, detreasegemi d, seguros s, cesionesrea c
                WHERE r.sreaemi = d.sreaemi
                  AND r.sseguro = s.sseguro
                  AND r.fefecte >= fini
                  AND d.scontra = ctr
                  AND d.nversio >= ver_a
                  AND d.nversio < ver_n
                  AND NVL(f_cestrec(nrecibo, r.fefecte), 0) < 2
                  AND d.scesrea = c.scesrea   -- 15744 AVT 12-08-2010
                  AND c.scontra = ctr
                  AND c.nversio >= ver_a   -- BUG 14536 AVT 28-05-2010
                  AND c.nversio < ver_n
                  AND(c.cgenera = 01
                      OR c.cgenera = 03
                      OR c.cgenera = 04
                      OR c.cgenera = 05
                      OR c.cgenera = 09
                      OR c.cgenera = 40)
                  AND(c.fefecto < c.fanulac
                      OR c.fanulac IS NULL)
                  -- 13504 AVT 08-03-2010 s'afegeix si retira o no cartera
                  AND((c.fefecto >= fini
                       AND c_retira = 0)
                      OR c_retira = 1)
                  -- 13504 fi
                  AND c.fvencim > fini   -- BUG 14536 AVT 28-05-2010
                  AND(c.fanulac > fini
                      OR c.fanulac IS NULL)   --  evita que tiri enrera
             ORDER BY r.sseguro, r.nrecibo, r.fefecte;

/*---------------------------------------------------------------------------------
-- 25545 KBR 04042013 Contratos de Reaseguro 2013
-- Función que se encarga de validar si el sseguro cambia de versión de contrato
-- y así indicar si se debe regularizar o no.
----------------------------------------------------------------------------------*/
   FUNCTION f_valida_version_contrato(
      p_sseguro IN NUMBER,
      p_nversio_act IN NUMBER,
      p_cgarant IN NUMBER)
      RETURN BOOLEAN IS
      v_wfpolefe     seguros.fefecto%TYPE;
      v_fpolvto      seguros.fvencim%TYPE;
      v_fpolefe      seguros.fefecto%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cfacult      seguros.creafac%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_scontra      contratos.scontra%TYPE;
      v_nversio      contratos.nversio%TYPE;
      v_ipleno       cesionesrea.ipleno%TYPE;
      v_icapci       cesionesrea.icapaci%TYPE;
      v_cdetces      cesionesrea.cdetces%TYPE;
      v_resul        NUMBER;
      v_hiha         NUMBER;   -- 33910 AVT 16/01/2015
   BEGIN
      v_errlin := 10;
      -- 33910 AVT 16/01/2015 només fem la validació si hi ha algún producte amb aquest tipus de producte
      v_hiha := 0;

      SELECT COUNT(*)
        INTO v_hiha
        FROM parproductos
       WHERE cparpro = 'PER_REV_NO_ANUAL_REA'
         AND cvalpar <> 1;

      IF NVL(v_hiha, 0) > 0 THEN
         SELECT s.fefecto, DECODE(s.fcaranu, NULL, s.fvencim, s.fcaranu), s.cramo, s.cmodali,
                s.ccolect, s.ctipseg, s.cactivi, s.cempres, s.creafac, s.sproduc
           INTO v_fpolefe, v_fpolvto, v_cramo, v_cmodali,
                v_ccolect, v_ctipseg, v_cactivi, v_cempres, v_cfacult, v_sproduc
           FROM seguros s
          WHERE s.sseguro = p_sseguro;

         v_wfpolefe := NULL;
         v_errlin := 20;

         IF (NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PER_REV_NO_ANUAL_REA'), 0) > 1) THEN
            v_errlin := 21;
            v_wfpolefe := pac_cesionesrea.f_renovacion_anual_rea(p_sseguro, v_fpolvto);
            v_errlin := 22;
            v_resul := f_buscacontrato(p_sseguro, v_wfpolefe, v_cempres, p_cgarant, v_cramo,
                                       v_cmodali, v_ctipseg, v_ccolect, v_cactivi, 1,
                                       v_scontra, v_nversio, v_ipleno, v_icapci, v_cdetces);

            IF v_resul = 0 THEN
               --Si la versión actual es diferente a la nueva versión se procesará la póliza
               IF p_nversio_act <> v_nversio THEN
                  RETURN TRUE;
               ELSE
                  RETURN FALSE;
               END IF;

               RETURN FALSE;
            ELSE
               RETURN FALSE;
            END IF;
         ELSE
            v_errlin := 31;
            --  v_wfpolefe := v_fpolefe; - 33910 AVT 16/01/2015
            -- 33910 AVT 16/01/2015 en las renovaciones anuales siempre se debe regualrizar
            RETURN TRUE;
         END IF;
      --Si ocurre algún error al buscar el contrato retornamos FALSE
      ELSE
         -- 33910 AVT 16/01/2015 només fem la validació si hi ha algún producte amb aquest tipus de producte sino, sempre es regularitza
         RETURN TRUE;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- 25545 KBR 08/04/2013
         codi_error := SQLCODE;
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                     v_errpar || ' error ' || codi_error);
         RETURN FALSE;
   END f_valida_version_contrato;
------------------------------
------------------------------
BEGIN
---------------------------
--  AQUÍ S'EXECUTA EL PROCÉS DIFERIT DE REGULARITZACIÓ DE CESSIONS PER
--  CAUSA D'UNA MODIFICACIÓ DE CONTRACTE...
--  Anul.lació de la part regularitzada de les cessions...
---------------------------
   avui := f_sysdate;
   v_errlin := 1000;
   -- bug: 13504 10-03-2010 AVT un sprocés diferent per cada moviment tractat
   codi_error := f_procesini(f_user, p_cempres, 'F_BATCH_CESSIO', 'Diferido Modif. Contrato',
                             p_proces);
   p_moneda := f_parinstalacion_n('MONEDAINST');

   -- Tira enrera els moviments afectats per la data d'efecte de la nova versió del contracte

   --P_Control_Error ('BATCH_CESSIO','f_atras3','p_nversioa='||p_nversioa||'p_fec'||p_fec);
   IF codi_error = 0 THEN
      --CPM 12/1/06: Calculem el nou ple
      BEGIN
         v_errlin := 1010;

         SELECT iretenc, icapaci
           INTO w_ipleno, w_icapaci
           FROM contratos
          WHERE scontra = p_scontra
            AND nversio = p_nversion;
--P_Control_Error ('BATCH_CESSIO','contratos','w_ipleno='||w_ipleno||';w_icapaci'||w_icapaci);
      EXCEPTION
         WHEN OTHERS THEN
            codi_error := 104672;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' error ' || codi_error);
      END;

      -- 25545 AVT 13-03-2013 actualitzem el contracte a l'inici.
      BEGIN
         BEGIN
            v_errlin := 1450;

            UPDATE contratos
               SET fconfin = NULL
             WHERE scontra = p_scontra
               AND nversio >= p_nversion;   -- BUG 14536 AVT 28-05-2010

            v_errlin := 1460;

            UPDATE contratos
               SET fconfin = p_fec
             WHERE scontra = p_scontra
               AND nversio = p_nversioa;

            -- Bug 0011802 - 17/11/2009 - JMF: actualitzar contracte per a que el batch no el torni agafar.
            v_errlin := 1470;

            UPDATE codicontratos
               SET cvalid = 0
             WHERE scontra = p_scontra;
         EXCEPTION
            WHEN OTHERS THEN
               err := 103822;
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' e=' || err);
         END;
      EXCEPTION
         WHEN OTHERS THEN
            err := 103822;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' e=' || err);
      END;
   END IF;

   IF codi_error <> 0 THEN
      ROLLBACK;
      err := f_proceslin(p_proces, 'Diferido Modif. Contrato', codi_error, numlin);
      err := codi_error;
      codi_error := f_procesfin(p_proces, err);
      RETURN(err);
   ELSE
      COMMIT;
   END IF;

--  Moviments positius de regularització amb el nou contracte...
--  ************************************************************
--  Aquí es prepara i es crea el registre de CESIONESAUX corresponent per
--  poder crear el moviment positiu, cridant després a la funció F_CESSIO...
   v_errlin := 1020;

   -- 13504 AVT 08-03-2010 Retirada de Cartera
   BEGIN
      SELECT NVL(cretira, 0)
        INTO v_retira
        FROM codicontratos
       WHERE scontra = p_scontra;
   EXCEPTION
      WHEN OTHERS THEN
         err := 104516;
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                     v_errpar || ' p_scontra=' || p_scontra || ' e=' || err);
   END;

   -- 13504 AVT 08-03-2010 s'afegeix la Retirada de Cartera
   FOR regcesion IN cur_cesiones(p_scontra, p_nversioa, p_nversion, p_fec, v_retira) LOOP
      -- ini Bug 0011802 - 17/11/2009 - JMF: Es posa la funció dintre bucle.
      v_errlin := 1030;
      -- 25545 KBR 04042013
      v_tratar_seguro := f_valida_version_contrato(regcesion.sseguro, p_nversioa,
                                                   regcesion.cgarant);

      -- Fin 25545 KBR 04042013
      IF v_tratar_seguro THEN   -- 25545 KBR 04042013
         --BUG:13504 15-03-2010 AVT la versió del suplement és la de la darrera cartera o poducció
         IF regcesion.cgenera IN(1, 4)   -- 25545 AVT 11/03/2013 només alta i carteres
            AND v_retira = 0 THEN
            v_hiha := 0;

            BEGIN
               SELECT COUNT(*)
                 INTO v_hiha
                 FROM cesionesrea
                WHERE cgenera IN(3, 5)
                  AND sseguro = regcesion.sseguro
                  AND scontra = regcesion.scontra
                  AND nversio = regcesion.nversio
                  --AND nriesgo = regcesion.nriesgo - BUG 0039441 - FAL - 23/12/2015 - En renovaciones con alta de riesgo debe regularizar el nuevo riesgo
                  --AND nmovimi < regcesion.nmovimi
                  AND nmovimi <=
                        regcesion.nmovimi   -- 26203 AVT 15/04/2013 podemos tener regularizacion (cg:1) con = nmovimi que el alta o renovación
                  AND fefecto >= p_fec
                  AND(fanulac >= p_fec
                      OR fanulac IS NULL)
                  AND(fregula >= p_fec
                      OR fregula IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  codi_error := 105297;
                  -- 25545 KBR 08/04/2013
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                              v_errpar || ' error ' || codi_error);
            END;
         ELSE
            v_hiha := 1;
         END IF;

         IF v_hiha > 0 THEN
            -- Bug 0011802 - 22/12/2009 - JMF Afegir moviment, risc i garantia.
            -- 13504 AVT 08-03-2010 s'afegeix la Retirada de Cartera
            FOR reg_anula IN cur_cesiones_anula(p_scontra, p_nversioa, p_nversion, p_fec,
                                                v_retira, regcesion.sseguro,
                                                regcesion.nmovimi, regcesion.nriesgo,
                                                regcesion.cgarant) LOOP
               DECLARE
                  e_fianullacio  EXCEPTION;
               BEGIN
                  -- 13504 AVT 08-03-2010 Retirada de Cartera
                  --w_finici := reg_anula.fefecto;
                  IF v_retira = 0 THEN
                     w_finici := reg_anula.fefecto;
                  ELSE
                     IF p_fec >= reg_anula.fefecto THEN
                        w_finici := p_fec;
                     ELSE
                        w_finici := reg_anula.fefecto;
                     END IF;
                  END IF;

                  BEGIN
                     SELECT NVL(MAX(nmovigen), 0) + 1
                       INTO lnmovigen
                       FROM cesionesrea
                      WHERE sseguro = reg_anula.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        lnmovigen := 1;
                        -- 25545 KBR 08/04/2013
                        codi_error := SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                                    v_errpar || ' error ' || codi_error);
                  END;

                  BEGIN
                     UPDATE cesionesrea
                        SET fregula = w_finici
                      WHERE scesrea = reg_anula.scesrea;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        codi_error := 104738;
                        RAISE e_fianullacio;
                     WHEN OTHERS THEN
                        codi_error := 104739;
                        RAISE e_fianullacio;
                  END;

                  -- Bug 0011802 - 17/11/2009 - JMF: Canvi tipus 3=modul360 per tipus 1=real
                  --codi_error := f_difdata(reg_anula.fefecto, reg_anula.fvencim, 1, 3, w_dias_origen);
                  codi_error := f_difdata(reg_anula.fefecto, reg_anula.fvencim, 3, 3,
                                          w_dias_origen);   -- BUG 0039509 - FAL - 14/01/2016

                  IF codi_error <> 0 THEN
                     RAISE e_fianullacio;
                  END IF;

                  IF w_dias_origen < 1 THEN
                     w_dias_origen := 1;
                  END IF;

                  -- Bug 0011802 - 17/11/2009 - JMF: Canvi tipus 3=modul360 per tipus 1=real
                  codi_error := f_difdata(w_finici, reg_anula.ffin, 1, 3, w_dias);

                  IF codi_error <> 0 THEN
                     RAISE e_fianullacio;
                  END IF;

                  IF w_dias < 1 THEN
                     w_dias := 1;
                  END IF;

                  w_icesion := -1 * reg_anula.icesion * w_dias / w_dias_origen;
                  w_ipritarrea := -1 * reg_anula.ipritarrea * w_dias / w_dias_origen;
                  w_idtosel := -1 * reg_anula.idtosel * w_dias / w_dias_origen;

                  -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  BEGIN
                     SELECT pac_monedas.f_moneda_producto(sproduc)
                       INTO pmoneda
                       FROM seguros
                      WHERE sseguro = reg_anula.sseguro;
                  EXCEPTION
                     WHEN OTHERS THEN
                        -- 25545 KBR 08/04/2013
                        codi_error := SQLCODE;
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                                    v_errpar || ' error ' || codi_error);
                        pmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
                  END;

                  -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  w_icesion := f_round(w_icesion, pmoneda);
                  w_ipritarrea := f_round(w_ipritarrea, pmoneda);
                  w_idtosel := f_round(w_idtosel, pmoneda);

                  -- 14536 AVT 08-06-2010
                  IF reg_anula.fvencim < reg_anula.ffin THEN
                     v_fvencim := reg_anula.fvencim;
                  ELSE
                     v_fvencim := reg_anula.ffin;
                  END IF;

                  -- fin Bug 0011802 - 17/11/2009 - JMF: canvi calcul.
                  SELECT scesrea.NEXTVAL
                    INTO w_scesrea
                    FROM DUAL;

                  BEGIN
                     INSERT INTO cesionesrea
                                 (scesrea, ncesion, icesion, icapces,
                                  sseguro, nversio, scontra,
                                  ctramo, sfacult, nriesgo,
                                  icomisi, icomreg, scumulo,
                                  cgarant, spleno, ccalif1,
                                  ccalif2, nmovimi, fefecto, fvencim,
                                  pcesion, sproces, cgenera, fgenera, ipritarrea,
                                  idtosel, psobreprima, cdetces,
                                  fanulac, fregula, nmovigen,
                                  ipleno, icapaci)
                          VALUES (w_scesrea, reg_anula.ncesion, w_icesion, reg_anula.icapces,
                                  reg_anula.sseguro, reg_anula.nversio, reg_anula.scontra,
                                  reg_anula.ctramo, reg_anula.sfacult, reg_anula.nriesgo,
                                  reg_anula.icomisi, reg_anula.icomreg, reg_anula.scumulo,
                                  reg_anula.cgarant, reg_anula.spleno, reg_anula.ccalif1,
                                  reg_anula.ccalif2, reg_anula.nmovimi, w_finici, v_fvencim,
                                  reg_anula.pcesion, p_proces, 30, avui, w_ipritarrea,
                                  w_idtosel, reg_anula.psobreprima, reg_anula.cdetces,
                                  reg_anula.fanulac, reg_anula.fregula, lnmovigen,
                                  reg_anula.ipleno, reg_anula.icapaci);

                     codi_error := 0;
                  EXCEPTION
                     WHEN OTHERS THEN
                        codi_error := 104740;
                        -- 25545 KBR 08/04/2013
                        p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                                    v_errpar || ' error ' || codi_error);
                        RAISE e_fianullacio;
                  END;
               EXCEPTION
                  WHEN e_fianullacio THEN
                     -- Simula sortida returns que abans tenia el f_atras3
                     NULL;
               END;

               IF codi_error <> 0 THEN
                  ROLLBACK;
                  err := f_proceslin(p_proces,
                                     'Diferido Modif. Contrato sseguro=' || regcesion.sseguro,
                                     codi_error, numlin);
                  err := codi_error;
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                              v_errpar || ' s=' || regcesion.sseguro || ' e=' || codi_error);
                  codi_error := f_procesfin(p_proces, err);
                  RETURN(err);
               END IF;
            END LOOP;

-- fi anulació  --------------------------------------------------------------------------------------------------

            -- fin Bug 0011802 - 17/11/2009 - JMF
            -- Preparació de dates límit...
            v_errlin := 1040;

            -- 13504 AVT 08-03-2010 Retirada de Cartera
            --w_fconini := regcesion.fefecto;
            IF v_retira = 0 THEN
               w_fconini := regcesion.fefecto;
            ELSE
               IF p_fec >= regcesion.fefecto THEN
                  w_fconini := p_fec;
               ELSE
                  w_fconini := regcesion.fefecto;
               END IF;
            END IF;

            --  per moviments amb suplements posteriors
            IF regcesion.fanulac IS NULL THEN
               w_fconfin := regcesion.fvencim;
            ELSIF regcesion.fanulac IS NOT NULL THEN
               w_fconfin := regcesion.fanulac;
            END IF;
         END IF;
      END IF;   -- Fin 25545 KBR 04042013
   END LOOP;   -- ACABEM LA GESTIÓ PER GARANTIA

--- 25545 AVT 13/03/2013 ANEM A LA FUNCIÓ GENERAL
-- 0033910 AVT 16/01/2015 aunque la anulación haya realizado dos trozos  la cesión positiva se hace para todo
   FOR reg IN (SELECT DISTINCT sseguro, nmovimi, MIN(fefecto) fefecto, MAX(fvencim) fvencim
                          FROM cesionesrea
                         WHERE sproces = p_proces
                           AND cgenera = 30
                      GROUP BY sseguro, nmovimi
                      ORDER BY sseguro, nmovimi) LOOP
      -- w_fconfin := regcesion.fvencim;
      -- fi AVT
      --    Preparació de capitals i primes...
      v_errlin := 1050;
      codi_error := f_buscactrrea(reg.sseguro, reg.nmovimi, p_proces, 01, pmoneda, 1,
                                  reg.fefecto, reg.fvencim);

      IF codi_error <> 0 THEN
         ROLLBACK;
         codi_error := f_proceslin(p_proces,
                                   'Diferido Modif. Contrato sseguro=' || reg.sseguro, err,
                                   numlin);
         codi_error := f_procesfin(p_proces, err);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                     v_errpar || ' s=' || reg.sseguro || ' e=' || err);
         v_errlin := 1051;

         BEGIN
            DELETE      cesionesrea
                  WHERE cgenera = 30
                    AND sproces = p_proces
                    AND sseguro = reg.sseguro
                    AND nmovimi = reg.nmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' s=' || reg.sseguro || ' e=' || codi_error);
         END;

         v_errlin := 1052;

         BEGIN
            UPDATE cesionesrea
               SET fregula = NULL
             WHERE sseguro = reg.sseguro
               AND fregula >= p_fec
               AND nmovimi = reg.nmovimi;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' s=' || reg.sseguro || ' e=' || codi_error);
         END;

         COMMIT;
--            RETURN(err);
      ELSE
         v_errlin := 1400;
         codi_error := f_cessio(p_proces, 01, pmoneda);

         IF codi_error <> 0
            AND codi_error <> 99 THEN
            ROLLBACK;
            err := f_proceslin(p_proces, 'Diferido Modif. Contrato sseguro=' || reg.sseguro,
                               codi_error, numlin);
            err := codi_error;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' s=' || reg.sseguro || ' e=' || codi_error);
            codi_error := f_procesfin(p_proces, err);
            RETURN(err);
         END IF;

         COMMIT;
      END IF;

      -- AVT Control de pòlisses que haurien d'haver quedat parades per facultatiu
      IF codi_error = 99 THEN
         --ROLLBACK;
         err := f_proceslin(p_proces,
                            'Diferido Modif. Contrato' || ' - Seg: ' || w_sseguro
                            || ' - Nmov:' || w_nmovimi || ' - Nrie:' || w_nriesgo,
                            codi_error, numlin);
         err := 0;
      ELSE
         v_errlin := 1053;

         -- 04/02/2014 AVT esborrem totes les cessions que s'hagin generat i que no siguin del contracte que estem tractant
         BEGIN
            DELETE      cesionesrea
                  WHERE cgenera = 1
                    AND sproces = p_proces
                    AND sseguro = reg.sseguro
                    AND nmovimi = reg.nmovimi
                    AND scontra <> p_scontra;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' s=' || reg.sseguro || ' e=' || codi_error);
         END;

         v_errlin := 1054;

         BEGIN
            UPDATE cesionesrea
               SET fregula = NULL
             WHERE sseguro = reg.sseguro
               AND fregula >= p_fec
               AND nmovimi = reg.nmovimi
               AND scontra <> p_scontra;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' s=' || reg.sseguro || ' e=' || codi_error);
         END;

         COMMIT;
      -- 04/01/2014 AVT  fi ----------------------------------------------------
      END IF;

         -- END IF;   -- BUG: 13504 AVT
      -- END LOOP; TREIEM TOTA LA PART DEL CGENERA = 1  DEL CURSOR DE GARANTIES
      codi_error := f_procesfin(p_proces, err);
   END LOOP;

-----------------------------------------------------------
-- 14079 AVT 13-04-2010 Retrocessió del detall per rebut --
-----------------------------------------------------------
-- 14536 AVT 15-06-2010 es treu del cursor de cessions
   err := f_procesini(f_user, p_cempres, 'F_BATCH_CESSIO', 'Diferido Modif. Contrato Recibo',
                      p_proces);

   FOR reb IN cur_rebut(p_scontra, p_nversioa, p_nversion, p_fec, v_retira) LOOP
-- 33910 AVT 26/01/2015 no hace falta validar garantía a garantía ya se ha hecho en CESIONESREA
--      -- 25545 KBR 04042013
--      v_tratar_seguro := f_valida_version_contrato(reb.sseguro, p_nversioa, reb.cgarant);

      --      -- Fin 25545 KBR 04042013
      -- IF v_tratar_seguro THEN
         -- 1er anul·lem les cessions del rebut que es va generar a l'emissió
      err := pac_cesionesrea.f_cesdet_anu(reb.nrecibo);

      IF err = 0 THEN
         -- 2n generem les cessions apuntant contra les noves versions
         err := pac_cesionesrea.f_cessio_det(p_proces, reb.sseguro, reb.nrecibo, reb.cactivi,
                                             reb.cramo, reb.cmodali, reb.ctipseg, reb.ccolect,
                                             reb.fefecte, reb.fvencim, NULL,

                                                 -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             --1,
                                             pac_monedas.f_moneda_producto(reb.sproduc),
                                             -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                             4);

         IF err <> 0 THEN
            codi_error := f_proceslin(p_proces, 'Diferido Modif. Contrato recibo 2',
                                      codi_error, reb.nrecibo);
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' s=' || reb.sseguro || ' r=' || reb.nrecibo || ' e='
                        || codi_error);
            codi_error := f_procesfin(p_proces, err);
            ROLLBACK;
         ELSE   -- 33910 AVT 26/01/2015
            COMMIT;
         END IF;
      ELSE
         codi_error := f_proceslin(p_proces, 'Diferido Modif. Contrato recibo 1', codi_error,
                                   reb.nrecibo);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                     v_errpar || ' s=' || reb.sseguro || ' r=' || reb.nrecibo || ' e='
                     || codi_error);
         codi_error := f_procesfin(p_proces, err);
         ROLLBACK;
      END IF;
   --END IF;   -- 25545 KBR 04042013 33910 AVT 26/01/2015
   END LOOP;

   codi_error := f_procesfin(p_proces, err);
   -- 14079 AVT 13-04-2010 fi --------------------------------

   ----------------------------------------
--  Moviments de regularització del pagaments de sinistres...
--  *********************************************************
   v_errlin := 1410;
   err := f_procesini(f_user, p_cempres, 'F_BATCH_CESSIO', 'Diferido Modif. Contrato Pagos',
                      p_proces);

-- 14536 AVT 15-06-2010 s'ajusta la regularització dels pagaments i s'afegeix la dels reemborsaments
   FOR regpag IN cur_pagos(p_scontra, p_nversioa, p_nversion, p_fec) LOOP
      IF regpag.sidepag = 0 THEN
         --- REEMBORSAMENTS ---
         IF regpag.fcontab IS NULL THEN
            -- S'esborren els moviments anteriors...
            BEGIN
               v_errlin := 1430;

               DELETE FROM cesionesrea
                     WHERE nreemb = regpag.nreemb
                       AND nfact = regpag.nfact
                       AND nlinea = regpag.nlinea;
            END;
         ELSE
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            -- es genera un apunt negatiu per compensar el registre ja contabilitzat
            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra, ctramo,
                         sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant, spleno, ccalif1,
                         ccalif2, nsinies, fefecto, fvencim, fcontab, pcesion, sproces,
                         cgenera, fgenera, fregula, fanulac, nmovimi, sidepag, ipritarrea,
                         idtosel, psobreprima, cdetces, ipleno, icapaci, nmovigen, iextrap,
                         iextrea, nreemb, nfact, nlinea)
               SELECT w_scesrea, ncesion, -icesion, icapces, sseguro, nversio, scontra, ctramo,
                      sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant, spleno, ccalif1,
                      ccalif2, nsinies, fefecto, fvencim, NULL, pcesion, sproces, cgenera,
                      fgenera, fregula, fanulac, nmovimi, sidepag, ipritarrea, idtosel,
                      psobreprima, cdetces, ipleno, icapaci, nmovigen, iextrap, iextrea,
                      nreemb, nfact, nlinea
                 FROM cesionesrea
                WHERE nreemb = regpag.nreemb
                  AND nfact = regpag.nfact
                  AND nlinea = regpag.nlinea;
         END IF;

         -----
         BEGIN
            SELECT ipago
              INTO v_pago
              FROM reembactosfac
             WHERE nreemb = regpag.nreemb
               AND nfact = regpag.nfact
               AND nlinea = regpag.nlinea;
         EXCEPTION
            WHEN OTHERS THEN
               err := SQLERRM;
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' nr=' || regpag.nreemb || ' nf=' || regpag.nfact
                           || ' nl=' || regpag.nlinea || ' e=' || codi_error);
         END;

         codi_error := f_reembrea(regpag.sseguro, regpag.nriesgo, regpag.cgarant,
                                  regpag.nreemb, regpag.nfact, regpag.nlinea, regpag.fefecto,
                                  v_pago);

         IF codi_error <> 0 THEN
            err := codi_error;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' nr=' || regpag.nreemb || ' nf=' || regpag.nfact
                        || ' nl=' || regpag.nlinea || ' e=' || codi_error);
         END IF;
      ELSE
         --- PAGAMENTS DE SINISTRES ---
         IF regpag.fcontab IS NULL THEN
            -- S'esborren els moviments anteriors...
            BEGIN
               v_errlin := 1430;

               DELETE FROM cesionesrea
                     WHERE sidepag = regpag.sidepag;
            END;
         ELSE
            SELECT scesrea.NEXTVAL
              INTO w_scesrea
              FROM DUAL;

            -- es genera un apunt negatiu per compensar el registre ja contabilitzat
            INSERT INTO cesionesrea
                        (scesrea, ncesion, icesion, icapces, sseguro, nversio, scontra, ctramo,
                         sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant, spleno, ccalif1,
                         ccalif2, nsinies, fefecto, fvencim, fcontab, pcesion, sproces,
                         cgenera, fgenera, fregula, fanulac, nmovimi, sidepag, ipritarrea,
                         idtosel, psobreprima, cdetces, ipleno, icapaci, nmovigen, iextrap,
                         iextrea, nreemb, nfact, nlinea)
               SELECT w_scesrea, ncesion, -icesion, icapces, sseguro, nversio, scontra, ctramo,
                      sfacult, nriesgo, icomisi, icomreg, scumulo, cgarant, spleno, ccalif1,
                      ccalif2, nsinies, fefecto, fvencim, NULL, pcesion, sproces, cgenera,
                      fgenera, fregula, fanulac, nmovimi, sidepag, ipritarrea, idtosel,
                      psobreprima, cdetces, ipleno, icapaci, nmovigen, iextrap, iextrea,
                      nreemb, nfact, nlinea
                 FROM cesionesrea
                WHERE sidepag = regpag.sidepag;
         END IF;

--         creació dels nous moviments...
--         ******************************
         v_errlin := 1440;

         -- 16329 AVT 22-10-2010 adaptació al nou mòdul de reassegurança
         IF NVL(pac_parametros.f_parempresa_n(p_cempres, 'MODULO_SINI'), 0) = 0 THEN
            -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
            BEGIN
               SELECT pac_monedas.f_moneda_producto(sproduc)
                 INTO pmoneda
                 FROM seguros
                WHERE sseguro = regpag.sseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  -- 25545 KBR 08/04/2013
                  codi_error := SQLCODE;
                  p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                              v_errpar || ' error ' || codi_error);
                  pmoneda := pac_md_common.f_get_parinstalacion_n('MONEDAINST');
            END;

            -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
            codi_error := f_sinrea(regpag.sidepag,
                                   --p_moneda
                                   pmoneda);
         ELSE
            SELECT cmonpag, nsinies, ctippag
              INTO vcmonpag, vnsinies, vctippag
              FROM sin_tramita_pago
             WHERE sidepag = regpag.sidepag;

            codi_error := pac_siniestros.f_sin_rea(regpag.sidepag, vcmonpag, vnsinies,
                                                   vctippag, regpag.fefecto);
         END IF;

         IF codi_error <> 0 THEN
            err := codi_error;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' s=' || regpag.sidepag || ' m=' || p_moneda || ' e='
                        || codi_error);
         END IF;
      END IF;

      IF err <> 0 THEN
         ROLLBACK;
         codi_error := f_proceslin(p_proces, 'Diferido Modif. Contrato', err, numlin);
         codi_error := f_procesfin(p_proces, err);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' e=' || err);
         RETURN(err);
      ELSE   -- 0033910 16/01/2015 AVT hem d'anar guardant els canvis EN SINISTRES ok
         COMMIT;
      END IF;
   END LOOP;

   codi_error := f_procesfin(p_proces, err);

-- 15545 AVT 13-03-2013 fem l'actualització a l'inici i ho tornem a deixar com estava en cas d'error
   IF codi_error <> 0
      AND codi_error <> 99 THEN
      -- Actualitzem les dates finals de la versió anterior i la nova per
      -- actualitzar el nou estat de vigència.
      BEGIN
         BEGIN
            v_errlin := 1451;

            UPDATE contratos
               SET fconfin = NULL
             WHERE scontra = p_scontra
               AND nversio = p_nversioa;

            v_errlin := 1461;

            UPDATE contratos
               SET fconfin = p_fec
             WHERE scontra = p_scontra
               AND nversio = p_nversion;

            v_errlin := 1471;

            UPDATE codicontratos
               SET cvalid = 1
             WHERE scontra = p_scontra;
         EXCEPTION
            WHEN OTHERS THEN
               err := 103822;
               p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                           v_errpar || ' e=' || err);
         END;
      EXCEPTION
         WHEN OTHERS THEN
            err := 103822;
            p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM,
                        v_errpar || ' e=' || err);
      END;

      IF err <> 0 THEN
         ROLLBACK;
         codi_error := f_proceslin(p_proces, 'Diferido Modif. Contrato', err, numlin);
         p_tab_error(f_sysdate, f_user, v_errfun, v_errlin, SQLERRM, v_errpar || ' e=' || err);
      END IF;
   ELSE
      ROLLBACK;
   END IF;

   IF codi_error <> 0
      AND codi_error <> 99 THEN
      err := codi_error;
   END IF;

   v_errlin := 1480;
   RETURN(err);
END f_batch_cessio;

/

  GRANT EXECUTE ON "AXIS"."F_BATCH_CESSIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BATCH_CESSIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BATCH_CESSIO" TO "PROGRAMADORESCSI";
