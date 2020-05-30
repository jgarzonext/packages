--------------------------------------------------------
--  DDL for Package Body PAC_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PSU" IS
/******************************************************************************
   NOMBRE    : PAC_PSU
   PROPÓSITO : Package con funciones propias de la funcionalidad de
               Política de Subscripción.

   REVISIONES:
   Ver    Fecha      Autor     Descripción
   ------ ---------- --------- ------------------------------------------------
   1.0    19-05-2009 M.R.B     Creación del package.
   1.1    05-06-2009 M.R.B     Adaptació a rebre només resultats numèrics de
                               les fòrmules.
   1.2    10-06-2009 M.R.B     Actualització Controls Autoritzats/Rebutjats i
                               ref_cursor amb els controls existents.
   1.3    11-06-2009 M.R.B     S'incorpora CGARANT a CONTROLSEG i ESTCONTROLSEG
                               Es treu CTIPCONT de CODCONTROL_PSU
                               Es crea la funció f_polizas_con_control
   1.4    22-06-2009 A.C.C.    Afegir funció f_grabaobservaciones
   1.5    01-07-2009 M.R.B.    A la funció F_LEE_CONTROLES, s'afegeix el llegir
                               de les taules EST, segons el paràmetre P_TABLAS.
   1.6    18-01-2010 M.R.B.    Adaptació a la nova definició de les taules i
                               opcions (Nova Producció, Suplements i Renovació).

   1.7    19/10/2011 M.R.B.    Adaptacions LIBERTY
   1.8    19/01/2012 M.R.B.    Modificació NMOVIMI per si no hi ha moviments
                               anteriors de PSU.
   2.0    11/10/2012 DRA       0023717: LCOL - Revisar y continuar con la parametrización de PSUs - Vida Grupo - Fase 2
   3.0    17/01/2013 APD       0025731: LCOL - TEC - PSU en cartera
   4.0    10/02/2013  JMC      0025853: LCOL_T010-LCOL - Revision incidencias qtracker (IV) 24/01/2013
   5.0    13/03/2013  ECP      0026092: LCOL_T031-LCOL - Fase 3 - (176-11) - Parametrizaci?n PSU's. Nota 140055
   6.0    14/08/2013 RCL       6. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
   7.0    10/12/2013 RCL       7. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
   8.0    18/12/2013 APD       8. 0027048/155371: LCOL_T010-Revision incidencias qtracker (V)
   9.0    19/02/2014 RCL       9. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
   10.0   21/02/2014 JDS       10. 0027416: POSRA300 - Configuracion Ramo Accidentes - Accidentes Corto Plazo
   11.0   11/03/2014 APD       11. 0030448/169258: LCOL_T010-Revision incidencias qtracker (2014/03)
   12.0   08/04/2014 JSV       12. 0030842: LCOL_T010-Revision incidencias qtracker (2014/04)
   13.0   02/07/2015 IGIL      13. 0036596/208749 AIS_MANUAL_UNDERWRITING
*****************************************************************************/

   /*****************************************************************************
    Trata todas las reglas de Política de Subscripción del producto al cual
    pertenece la póliza.

    param in      : P_TABLAS  Determina tablas EST o SEG
    param in      : P_SSEGURO Número identificativo interno de SEGUROS
    param in      : P_ACCION  Codi de l'acció que estem fent:
                              1 = Nova Producció
                              2 = Suplement
                              3 = Renovació
    param in      : P_CIDIOMA Codigo del idioma del Usuario
    param in out  : P_CRETENI 0 => No retener; 2 => Retener;
                    Sólo devolveremos 0 => No retener, si todos los controles
                    PSU, hayan quedado autorizados y el valor que nos ha llegado
                    en CRETENI también es cero. (Se respetan los otros controles
                    existentes).

    Devuelve      : 0 => Correcto ó 1 => Error.

   *****************************************************************************/
   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      p_cidioma IN NUMBER,
      p_creteni IN OUT NUMBER)
      RETURN NUMBER IS
----------------------------------------------------------------------------
      sortida_error  EXCEPTION;
----------------------------------------------------------------------------
      v_error        NUMBER := 0;
      v_text_error   tab_error.tdescrip%TYPE := '';
      v_resultat     NUMBER;
      v_inciden      psucontrolseg.observ%TYPE := '';
      v_nivreq       psucontrolseg.cnivelr%TYPE;
      v_nivelusu     psu_usuagru_nivel.cnivel%TYPE;
      v_conta        NUMBER := 0;
      v_cmotret      NUMBER;

----------------------------------------------------------------------------
      CURSOR c_seguros(p_sseguro IN NUMBER) IS
         SELECT *
           FROM seguros
          WHERE sseguro = p_sseguro;

----------------------------------------------------------------------------
      CURSOR c_estseguros(p_sseguro IN NUMBER) IS
         SELECT *
           FROM estseguros
          WHERE sseguro = p_sseguro;

----------------------------------------------------------------------------
      CURSOR c_pds_estsegurosupl(p_sseguro IN NUMBER) IS
         SELECT   *
             FROM pds_estsegurosupl
            WHERE sseguro = p_sseguro
         ORDER BY fsuplem DESC;

----------------------------------------------------------------------------
      CURSOR c_riesgos(p_sseguro IN NUMBER) IS
         SELECT   *
             FROM riesgos
            WHERE sseguro = p_sseguro
         ORDER BY nriesgo;

----------------------------------------------------------------------------
      CURSOR c_estriesgos(p_sseguro IN NUMBER) IS
         SELECT   *
             FROM estriesgos
            WHERE sseguro = p_sseguro
         ORDER BY nriesgo;

----------------------------------------------------------------------------
      CURSOR c_garanseg(p_sseguro IN NUMBER, p_nriesgo IN NUMBER) IS
         SELECT   *
             FROM garanseg
            WHERE sseguro = p_sseguro
              AND nriesgo = p_nriesgo
         ORDER BY nriesgo, cgarant;

----------------------------------------------------------------------------
      CURSOR c_estgaranseg(p_sseguro IN NUMBER, p_nriesgo IN NUMBER) IS
         SELECT   *
             FROM estgaranseg
            WHERE sseguro = p_sseguro
              AND nriesgo = p_nriesgo
              AND cobliga = 1   -- Patch AXIS3812 26/01/2012 MRB.
         ORDER BY nriesgo, cgarant;

----------------------------------------------------------------------------
      -- Bug 23940 - APD - 07/11/2012 - se añade p.renovaci = '2' (Post-cartera)
      -- and p_accion = 4 (PSU POST)
      CURSOR c_psu_controlpro(
         p_sproduc IN NUMBER,
         p_accion IN NUMBER,
         p_ctratar IN NUMBER,
         pc_sseguro IN NUMBER,
         pcgarant IN NUMBER DEFAULT NULL) IS
         SELECT   p.ccontrol, p.sproduc, p.ctratar, p.cgarant, p.producci, p.renovaci,
                  p.suplemen, p.cotizaci, p.autmanual, p.establoquea, p.ordenbloquea,
                  p.autoriprev, p.cretenpor, p.cformula, p.ccambio
             FROM psu_controlpro p, seguros s
            WHERE p_tablas = 'POL'
              AND p.sproduc = p_sproduc
              AND p.ctratar = p_ctratar
              AND((p_ctratar = 1
                   AND p.cgarant = pcgarant)
                  OR p_ctratar IN(2, 3))   -- BUG23717:DRA:11/10/2012
              AND(((p.producci = '1'
                    AND p_accion = 1)
                   OR(p.producci = '2'
                      AND p_accion = 5))   -- BUG23717:DRA:11/10/2012
                  OR(p.suplemen = '1'
                     AND p_accion = 2)
                  OR(p.renovaci = '1'
                     AND p_accion = 3)
                  OR(p.renovaci = '2'
                     AND p_accion = 4)
                  OR(p.cotizaci = '1'
                     AND p_accion = 6))   -- Bug 23940 - APD - 07/11/2012
              AND s.sseguro = pc_sseguro
              -- BUG23717:DRA:11/10/2012:Inici
              AND(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0
                  OR(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                     --AND pac_seguros.f_get_escertifcero(s.npoliza) <> 0))
                     --Bug 30842/172106
                     AND pac_seguros.f_soycertifcero(p.sproduc, s.npoliza, s.sseguro) <> 0))
              -- BUG23717:DRA:11/10/2012:Fi
         -- BUG23717:DRA:11/10/2012:Inici
         UNION ALL
         SELECT   p.ccontrol, p.sproduc, p.ctratar, p.cgarant, p.producci, p.renovaci,
                  p.suplemen, p.cotizaci, p.autmanual, p.establoquea, p.ordenbloquea,
                  p.autoriprev, p.cretenpor, p.cformula, p.ccambio
             FROM psu_controlpro p, seguros s
            WHERE p_tablas = 'POL'
              AND p.sproduc = p_sproduc
              --AND p.ctratar = p_ctratar
              AND((p_ctratar = 1
                   AND p.ctratar = 4
                   AND p.cgarant = pcgarant)
                  OR(p_ctratar = 2
                     AND p.ctratar = 5)
                  OR(p_ctratar = 3
                     AND p.ctratar = 6))
              AND(((p.producci = '1'
                    AND p_accion = 1)
                   OR(p.producci = '2'
                      AND p_accion = 5))   -- BUG23717:DRA:11/10/2012
                  OR(p.suplemen = '1'
                     AND p_accion = 2)
                  OR(p.renovaci = '1'
                     AND p_accion = 3)
                  OR(p.renovaci = '2'
                     AND p_accion = 4)
                  OR(p.cotizaci = '1'
                     AND p_accion = 6))   -- Bug 23940 - APD - 07/11/2012
              AND s.sseguro = pc_sseguro
              AND(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  -- AND(pac_seguros.f_get_escertifcero(s.npoliza) = 0
                  -- Bug 30842/172106
                  AND(pac_seguros.f_soycertifcero(p.sproduc, s.npoliza, s.sseguro) = 0
                      OR s.ncertif = 0))
         -- BUG23717:DRA:11/10/2012:Fi
         UNION ALL
         SELECT   p.ccontrol, p.sproduc, p.ctratar, p.cgarant, p.producci, p.renovaci,
                  p.suplemen, p.cotizaci, p.autmanual, p.establoquea, p.ordenbloquea,
                  p.autoriprev, p.cretenpor, p.cformula, p.ccambio
             FROM psu_controlpro p, estseguros s
            WHERE p_tablas = 'EST'
              AND p.sproduc = p_sproduc
              AND p.ctratar = p_ctratar
              AND((p_ctratar = 1
                   AND p.cgarant = pcgarant)
                  OR p.ctratar IN(2, 3))   -- BUG23717:DRA:11/10/2012
              AND(((p.producci = '1'
                    AND p_accion = 1)
                   OR(p.producci = '2'
                      AND p_accion = 5))   -- BUG23717:DRA:11/10/2012
                  OR(p.suplemen = '1'
                     AND p_accion = 2)
                  OR(p.renovaci = '1'
                     AND p_accion = 3)
                  OR(p.renovaci = '2'
                     AND p_accion = 4)
                  OR(p.cotizaci = '1'
                     AND p_accion = 6))   -- Bug 23940 - APD - 07/11/2012
              AND s.sseguro = pc_sseguro
              -- BUG23717:DRA:11/10/2012:Inici
              AND(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 0
                  OR(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                     -- Bug 0030842/0172106 -
                     --AND pac_seguros.f_get_escertifcero(s.npoliza) <> 0
                     --AND pac_seguros.f_get_escertifcero(NULL, s.ssegpol) = 0
                     AND pac_seguros.f_soycertifcero(p.sproduc, s.npoliza, s.ssegpol) <> 0
                     AND p_accion <> 2)
                  OR(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                     AND p_accion = 2
                     AND ncertif <> 0))   -- BUG23717:DRA:11/10/2012:Fi
         -- BUG23717:DRA:11/10/2012:Inici
         UNION ALL
         SELECT   p.ccontrol, p.sproduc, p.ctratar, p.cgarant, p.producci, p.renovaci,
                  p.suplemen, p.cotizaci, p.autmanual, p.establoquea, p.ordenbloquea,
                  p.autoriprev, p.cretenpor, p.cformula, p.ccambio
             FROM psu_controlpro p, estseguros s
            WHERE p_tablas = 'EST'
              AND p.sproduc = p_sproduc
              --AND p.ctratar = p_ctratar
              AND((p_ctratar = 1
                   AND p.ctratar = 4
                   AND p.cgarant = pcgarant)
                  OR(p_ctratar = 2
                     AND p.ctratar = 5)
                  OR(p_ctratar = 3
                     AND p.ctratar = 6))
              AND(((p.producci = '1'
                    AND p_accion = 1)
                   OR(p.producci = '2'
                      AND p_accion = 5))   -- BUG23717:DRA:11/10/2012
                  OR(p.suplemen = '1'
                     AND p_accion = 2)
                  OR(p.renovaci = '1'
                     AND p_accion = 3)
                  OR(p.renovaci = '2'
                     AND p_accion = 4)
                  OR(p.cotizaci = '1'
                     AND p_accion = 6))   -- Bug 23940 - APD - 07/11/2012
              AND s.sseguro = pc_sseguro
              AND(NVL(f_parproductos_v(p.sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
                  -- Bug 0030842/0172106 -
                  --AND(pac_seguros.f_get_escertifcero(s.npoliza) = 0
                  AND(pac_seguros.f_soycertifcero(p.sproduc, s.npoliza, s.ssegpol) = 0
                      OR s.ncertif = 0))
         -- BUG23717:DRA:11/10/2012:Fi
         ORDER BY ccontrol;

      vnmovimi       NUMBER;
      vcsituac       NUMBER;
      vcreteni       NUMBER;
      v_nocurre      NUMBER := NULL;
      v_nocurrex     NUMBER := 1;
      v_nmovimi_ant  NUMBER;
      v_nmovimi_act  NUMBER;
      w_nmovimi      NUMBER;
      v_antesguardada NUMBER := 0;
      w_nmovimi_est  estdetmovseguro.nmovimi%TYPE;   --M.R.B. 2/12/2011 BUG 19684
      w_fefecto      DATE;   -- MRB. 20759 Tema EFECTE dels SUPLEMENTS 16/01/2012
      v_cont         NUMBER;   -- Bug 25731 - APD - 17/01/2013
      v_sproduc      productos.sproduc%TYPE;
      v_cmotmov      movseguro.cmotmov%TYPE;
----------------------------------------------------------------------------
   BEGIN
      IF p_tablas = 'EST' THEN
         --Si previamente hemos guardado, borramos los registros de la psu
         BEGIN
            SELECT nmovimi, s.csituac, s.creteni
              INTO vnmovimi, vcsituac, vcreteni
              FROM movseguro m, seguros s, estseguros es
             WHERE s.sseguro = es.ssegpol
               AND es.sseguro = p_sseguro
               AND s.sseguro = m.sseguro
               AND m.nmovimi = (SELECT MAX(mm.nmovimi)
                                  FROM movseguro mm
                                 WHERE mm.sseguro = s.sseguro);

            IF vcsituac IN(4, 5)
               AND vcreteni IN(1) THEN
               DELETE      estpsucontrolseg
                     WHERE sseguro = p_sseguro
                       AND nmovimi = vnmovimi;

               DELETE      estpsu_retenidas
                     WHERE sseguro = p_sseguro
                       AND nmovimi = vnmovimi;

               v_antesguardada := 1;
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               --no hacemos nada sino existe en reales
               NULL;
         END;

         IF v_antesguardada = 0 THEN
            SELECT MAX(nmovimi)
              INTO v_nmovimi_ant
              FROM estseguros es, psucontrolseg ps
             WHERE es.ssegpol = ps.sseguro
               AND es.sseguro = p_sseguro;

            SELECT MAX(p.nmovimi)
              INTO v_nmovimi_act
              FROM estpsucontrolseg p
             WHERE p.sseguro = p_sseguro;

            IF v_nmovimi_ant IS NOT NULL
               AND NVL(v_nmovimi_act, 0) <> NVL(v_nmovimi_ant, 0) THEN
               --Si estamos en un nuevo movimiento, inicializamos el nocurre
               v_nocurre := 1;
            ELSE
               --Si estamos en el mismo nmovimi, cogemos el máximo nocurre
               SELECT MAX(nocurre)
                 INTO v_nocurre
                 FROM estseguros es, psucontrolseg ps
                WHERE es.ssegpol = ps.sseguro
                  AND es.sseguro = p_sseguro
                  AND ps.nmovimi = (SELECT MAX(p.nmovimi)
                                      FROM psucontrolseg p
                                     WHERE p.sseguro = ps.sseguro);
            END IF;

            --Borrem les taules est si estem en el fluxe
            IF v_nocurre IS NOT NULL THEN
               v_nocurrex := v_nocurre + 1;

               DELETE      estpsucontrolseg ps
                     WHERE ps.sseguro = p_sseguro
                       AND ps.nocurre = v_nocurrex
                       AND ps.nmovimi = (SELECT MAX(ep.nmovimi)
                                           FROM estpsucontrolseg ep
                                          WHERE ep.sseguro = p_sseguro);
            ELSE
               DELETE      estpsucontrolseg ps
                     WHERE ps.sseguro = p_sseguro;

               DELETE      estpsu_retenidas ps
                     WHERE ps.sseguro = p_sseguro;
            END IF;
         END IF;

         FOR regp IN c_estseguros(p_sseguro) LOOP
            -- M.R.B. 2/12/2011 Busco el nmovimi que estem fent BUG 19684
            /*
            SELECT MAX(nmovimi)
              INTO w_nmovimi_est
              FROM estdetmovseguro
             WHERE sseguro = p_sseguro;
            */
            -- M.R.B. 27/11/2012 Bug 24895
            SELECT MAX(nmovimi)
              INTO w_nmovimi_est
              FROM estgaranseg
             WHERE sseguro = p_sseguro;

------------------------------
            w_fefecto := NULL;

            -- BUG 20759 16/01/2012 M.R.B. Tema EFECTO SUPLEMENTS
            IF w_nmovimi_est IS NULL THEN
               w_nmovimi_est := 1;
               w_fefecto := regp.fefecto;
            ELSE
               FOR regsupl IN c_pds_estsegurosupl(regp.sseguro) LOOP
                  w_fefecto := regsupl.fsuplem;
                  EXIT;
               END LOOP;
            END IF;

            IF w_fefecto IS NULL THEN
               w_fefecto := regp.fefecto;
            END IF;

            v_nivelusu := f_nivel_usuari_psu(f_user, regp.sproduc);

            FOR regr IN c_estriesgos(regp.sseguro) LOOP
               FOR regc IN c_estgaranseg(regp.sseguro, regr.nriesgo) LOOP
                  FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 1, regp.sseguro,   -- BUG23717:DRA:11/10/2012
                                                 regc.cgarant) LOOP   -- Tratamiento de Controles a nivel de Garantía
                     prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                             regp.sproduc, regp.cactivi, regr.nriesgo,
                                             regc.cgarant, regpsu.cformula, regpsu.ccontrol,
                                             v_nivelusu, regpsu.autmanual, v_nocurre,

                                             -- Ini Bug 26092 --ECP-- 13/03/2013
                                             w_nmovimi_est, p_accion, regpsu.ccambio);
                                             -- Fin Bug 26092 --ECP-- 13/03/2013
                  -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell garantia
                  END LOOP;   -- De regpsu IN c_controlpro_psu (Nivel Garantías)
               END LOOP;   -- De regc IN c_estgaranseg

               -- Tratamiento de Controles a nivel de Riesgo
               FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 2, regp.sseguro) LOOP   -- BUG23717:DRA:11/10/2012
                  prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                          regp.sproduc, regp.cactivi, regr.nriesgo, NULL,
                                          regpsu.cformula, regpsu.ccontrol, v_nivelusu,
                                          regpsu.autmanual, v_nocurre, w_nmovimi_est,

                                          -- Ini Bug 26092 --ECP-- 13/03/2013
                                          p_accion, regpsu.ccambio
                                                  -- Fin Bug 26092 --ECP-- 13/03/2013
                  );
               -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell risc
               END LOOP;   -- De regpsu IN c_control_psu (Nivel Riesgos)
            END LOOP;   -- De regr IN c_estriesgos

            -- Tratamiento de Controles a nivel de Póliza
            FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 3, regp.sseguro) LOOP   -- BUG23717:DRA:11/10/2012
               --
               prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                       regp.sproduc, regp.cactivi, NULL, NULL,
                                       regpsu.cformula, regpsu.ccontrol, v_nivelusu,
                                       regpsu.autmanual, v_nocurre, w_nmovimi_est,
                                       -- Ini Bug 26092 --ECP-- 13/03/2013
                                       p_accion, regpsu.ccambio
                                               -- Fin Bug 26092 --ECP-- 13/03/2013
               );
            -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell pòlissa
            END LOOP;   -- De regpsu IN c_control_psu (Nivel Póliza)
         END LOOP;   -- De regp in c_estseguros

         -- Miramos si hemos grabado algo en las tablas estpsu
         SELECT COUNT(*)
           INTO v_conta
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro;

         IF v_conta > 0 THEN
            --Si hay registros en la psucontrolseg, actualizaremos la tabla psu_retenidas
            p_creteni := f_grabar_retenidas(p_tablas, p_sseguro, NULL, NULL, NULL, NULL, NULL,
                                            p_cidioma);
         ELSE
            --Si no hay registros, borraremos la tabla padre
            DELETE      estpsu_retenidas ps
                  WHERE ps.sseguro = p_sseguro;
         END IF;
      ELSIF p_tablas IN('CAR', 'POL') THEN
         SELECT nmovimi, cmotmov
           INTO w_nmovimi, v_cmotmov
           FROM movseguro
          WHERE sseguro = p_sseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM movseguro   -- detmovseguro
                            WHERE sseguro = p_sseguro);

         IF p_accion = 5 THEN
            BEGIN
               INSERT INTO psucontrolseg
                           (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, nocurre, cgarant,
                            cnivelr, establoquea, ordenbloquea, autoriprev, nvalor, nvalorinf,
                            nvalorsuper, nvalortope, cusumov, cnivelu, cautrec, autmanual,
                            fautrec, cusuaur, observ, isvisible)
                  (SELECT sseguro, w_nmovimi, fmovpsu, ccontrol, nriesgo, 1, cgarant, cnivelr,
                          establoquea, ordenbloquea, autoriprev, nvalor, nvalorinf,
                          nvalorsuper, LEAST(nvalortope, nvalorsuper), cusumov, cnivelu,
                          cautrec, autmanual, fautrec, cusuaur, observ, isvisible
                     FROM psucontrolseg
                    WHERE sseguro = p_sseguro
                      -- 23935 MRB 09/10/2012 --
                      AND NVL(autoriprev, 'S') != 'N'
                      --
                      AND nmovimi IN(SELECT MAX(nmovimi)
                                       FROM psucontrolseg
                                      WHERE sseguro = p_sseguro)
                      AND nocurre IN(SELECT MAX(nocurre)
                                       FROM psucontrolseg
                                      WHERE sseguro = p_sseguro
                                        AND nmovimi IN(SELECT MAX(nmovimi)
                                                         FROM psucontrolseg
                                                        WHERE sseguro = p_sseguro)));
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END IF;

         FOR regp IN c_seguros(p_sseguro) LOOP
            -- M.R.B. 2/12/2011 Busco el nmovimi que estem fent BUG 19684
            w_fefecto := NULL;

            -- BUG 20759 16/01/2012 M.R.B. Tema EFECTO SUPLEMENTS
            IF w_nmovimi IS NULL THEN
               w_nmovimi := 1;
               w_fefecto := regp.fefecto;
            /* ELSE
               FOR regsupl IN c_pds_estsegurosupl(regp.sseguro) LOOP
                   w_fefecto := regsupl.fsuplem;
                   EXIT;
                END LOOP;*/
            END IF;

            IF w_fefecto IS NULL THEN
               w_fefecto := regp.fefecto;
            END IF;

            -- Bug 25731 - APD - 17/01/2013
            --Si ya existen controles para el movimiento a tratar, debe coger el MAX(nocurre)
            SELECT COUNT(1)
              INTO v_cont
              FROM psucontrolseg ps
             WHERE ps.sseguro = p_sseguro
               AND ps.nmovimi = w_nmovimi;

            IF v_cont <> 0 THEN
               SELECT MAX(nocurre)
                 INTO v_nocurre
                 FROM psucontrolseg ps
                WHERE ps.sseguro = p_sseguro
                  AND ps.nmovimi = w_nmovimi;
            END IF;

            -- fin Bug 25731 - APD - 17/01/2013
            v_nivelusu := f_nivel_usuari_psu(f_user, regp.sproduc);

            FOR regr IN c_riesgos(regp.sseguro) LOOP
               FOR regc IN c_garanseg(regp.sseguro, regr.nriesgo) LOOP
                  FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 1, regp.sseguro,
                                                 regc.cgarant) LOOP   -- Tratamiento de Controles a nivel de Garantía
                     prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                             regp.sproduc, regp.cactivi, regr.nriesgo,
                                             regc.cgarant, regpsu.cformula, regpsu.ccontrol,
                                             v_nivelusu, regpsu.autmanual, v_nocurre,
                                             w_nmovimi,
                                             -- Ini Bug 26092 --ECP-- 13/03/2013
                                             p_accion, regpsu.ccambio
                                                     -- Fin Bug 26092 --ECP-- 13/03/2013
                     );
                  -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell garantia
                  END LOOP;   -- De regpsu IN c_controlpro_psu (Nivel Garantías)
               END LOOP;   -- De regc IN c_estgaranseg

               FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 2, regp.sseguro) LOOP   -- Tratamiento de Controles a nivel de Riesgo
                  prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                          regp.sproduc, regp.cactivi, regr.nriesgo, NULL,
                                          regpsu.cformula, regpsu.ccontrol, v_nivelusu,
                                          regpsu.autmanual, v_nocurre, w_nmovimi,
                                          -- Ini Bug 26092 --ECP-- 13/03/2013
                                          p_accion, regpsu.ccambio
                                                  -- Fin Bug 26092 --ECP-- 13/03/2013
                  );
               -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell risc
               END LOOP;   -- De regpsu IN c_control_psu (Nivel Riesgos)
            END LOOP;   -- De regr IN c_estriesgos

            FOR regpsu IN c_psu_controlpro(regp.sproduc, p_accion, 3, regp.sseguro) LOOP   -- Tratamiento de Controles a nivel de Póliza
               prepara_graba_controles(p_tablas, regp.sseguro, p_cidioma, w_fefecto,
                                       regp.sproduc, regp.cactivi, NULL, NULL,
                                       regpsu.cformula, regpsu.ccontrol, v_nivelusu,
                                       regpsu.autmanual, v_nocurre, w_nmovimi,
                                       -- Ini Bug 26092 --ECP-- 13/03/2013
                                       p_accion, regpsu.ccambio
                                               -- Fin Bug 26092 --ECP-- 13/03/2013
               );
            -- M.R.B. 2/12/2011 S'AFEGEIX P_NMOVIMI BUG 19684 -- Nivell pòlissa
            END LOOP;   -- De regpsu IN c_control_psu (Nivel Póliza)
         END LOOP;   -- De regp in c_estseguros

         -- Miramos si hemos grabado algo en las tablas psu
         SELECT COUNT(*)
           INTO v_conta
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND nmovimi = w_nmovimi;   -- BUG23717:DRA:22/10/2012

         IF v_conta > 0 THEN
            --Si hay registros en la psucontrolseg, actualizaremos la tabla psu_retenidas
            p_creteni := f_grabar_retenidas(p_tablas, p_sseguro, NULL, NULL, NULL, NULL, NULL,
                                            p_cidioma);
         ELSE
            --Si no hay registros, borraremos la tabla padre
            DELETE      psu_retenidas ps
                  WHERE ps.sseguro = p_sseguro
                    AND ps.nmovimi = w_nmovimi;   -- BUG23717:DRA:22/10/2012
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN sortida_error THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU ERROR PUNT 1', NULL,
                     v_text_error || ' PARAMETRES *' || ' ptablas = ' || p_tablas || ' ; '
                     || ' psseguro = ' || p_sseguro || ' ; ' || ' pcidioma = ' || p_cidioma,
                     'exception sortida_error ** Codi Error = ' || SQLERRM);
         RETURN 9001805;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU ERROR PUNT 2', NULL,
                     v_text_error || ' PARAMETRES *' || ' ptablas = ' || p_tablas || ' ; '
                     || ' psseguro = ' || p_sseguro || ' ; ' || ' pcidioma = ' || p_cidioma,
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN 9001805;
   END f_inicia_psu;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
/***************************************************************************
 Ejecuta las reglas de Política de Subscripción del producto al cual
 pertenece la póliza.

 param in      : P_SSEGURO  Número identificativo interno de SEGUROS
 param in      : P_FEFECTO  Fecha del efecto de la póliza/suplemento
 param in      : P_SPRODUC  Código del producto
 param in      : P_CACTIVI  Código de la actividad
 param in      : P_NRIESGO  Número de riesgo
 param in      : P_CGARANT  Código de la garantía
 param in      : P_CCONTROL Código del Control que estamos tratando
 param in      : P_CFORMULA Codigo de la fórmula a ejecutar
 param out     : P_RESULTAT Resultado obtenido por la fórmula

 Devuelve      : 0 => Correcto ó 1 => Error.
***************************************************************************/
	FUNCTION f_trata_formulas_psu(p_sseguro  IN NUMBER,
								  p_fefecto  IN DATE,
								  p_sproduc  IN NUMBER,
								  p_cactivi  IN NUMBER,
								  p_nriesgo  IN NUMBER,
								  p_cgarant  IN NUMBER,
								  p_ccontrol IN NUMBER,
								  p_cformula IN NUMBER,
								  p_nmovimi  IN NUMBER,
								  p_resultat OUT NUMBER,
								  p_tablas   IN VARCHAR2 DEFAULT 'EST',
								  -- Ini Bug 26092 --ECP-- 13/03/2013
								  origenpsu IN NUMBER DEFAULT NULL,
								  pccambio  IN NUMBER DEFAULT NULL)
								  -- Fin Bug 26092 --ECP-- 13/03/2013
	RETURN NUMBER IS
	   --
	   v_error      NUMBER := 0;
	   xxsesion     NUMBER;
	   v_origen     NUMBER;
	   mensajes     t_iax_mensajes;
	   v_monedainst VARCHAR2(10) := NULL;
	   p_cambio     VARCHAR2(10);
	   --
	BEGIN
	   --
	   -- Asigno una sesión para cada fórmula para poder grabar el parámetro CCONTROLPSU
	   SELECT sgt_sesiones.nextval INTO xxsesion FROM dual;

	   -- Creamos el parámetro con el CCONTROLPSU que estamos tratando.
	   v_error := pac_calculo_formulas.graba_param(xxsesion,
												   'CCONTROLPSU',
												   p_ccontrol);

	   --
	   IF v_error != 0
	   THEN
		  p_tab_error(f_sysdate,
					  f_user,
					  'PAC_PSU',
					  NULL,
					  'PAC_PSU.F_TRATA_FORMULAS DESPUES PAC_CALCULO_FORMULAS.GRABAPARAM ' ||
					  ' Sesió = ' || xxsesion || ' Ccontrol = ' || p_ccontrol ||
					  ' Error = ' || v_error,
					  'Codi Error = ' || SQLERRM);
		  RETURN v_error;
	   END IF;

	   xxsesion := NULL; -- M.R.B. 2012-01-17

	   IF p_tablas = 'EST'
	   THEN
		  v_origen := 1;
	   ELSE
		  v_origen := 2;
	   END IF;

	   -- Ejecuto la fórmula i recojo el resultado en p_resulat
	   v_error := pac_calculo_formulas.calc_formul(p_fefecto,
												   p_sproduc,
												   p_cactivi,
												   p_cgarant,
												   p_nriesgo,
												   p_sseguro,
												   p_cformula,
												   p_resultat,
												   p_nmovimi,
												   xxsesion,
												   v_origen,
												   p_fefecto,
												   'R',
												   NULL,
												   1,
												   -- Ini Bug 26092 --ECP-- 13/03/2013
												   origenpsu
												   -- Fin Bug 26092 --ECP-- 13/03/2013
												   );

	   -- 2/12/2011 M.R.B. S'AFEGEIXEN TOTS ELS PARÀMETRES BUG 19684
	   -- P_NMOVIMI, XXSESION, 1, P_FEFECTO, 'R', NULL);
	   -------------------------------------------------------------
	   --psesion => xxsesion

	   -- pac_psu_2011
	   IF v_error != 0
	   THEN
		  p_tab_error(f_sysdate,
					  f_user,
					  'PAC_PSU',
					  NULL,
					  'PAC_PSU.F_TRATA_FORMULAS DESPUES PAC_CALCULO_FORMULAS.CALC_FORMUL' ||
					  p_cformula || ' * ' || v_error,
					  '** Codi Error = ' || SQLERRM);
		  RETURN v_error;
	   END IF;

	   IF pccambio = 1
	   THEN
		  --
		  p_resultat := pac_iax_utiles.f_importe_cambio(p_moneda_inicial => pac_monedas.f_moneda_producto_char(p_sproduc),
														p_moneda_final   => v_monedainst,
														p_fecha          => f_sysdate,
														p_importe        => p_resultat,
														p_cambio         => p_cambio,
														mensajes         => mensajes);
		  --
		  IF p_resultat IS NULL
		  THEN
			 RETURN 1;
		  END IF;
	   END IF;

	   --
	   RETURN 0;
	EXCEPTION
	   WHEN OTHERS THEN
		  p_tab_error(f_sysdate,
					  f_user,
					  'PAC_PSU',
					  NULL,
					  'PAC_PSU.F_TRATA_FORMULAS ERROR ' || p_cformula || ' * ' ||
					  v_error,
					  '** Codi Error = ' || SQLERRM);
		  RETURN 1;
		  --
	END f_trata_formulas_psu;
----------------------------------------------------------------------------
----------------------------------------------------------------------------
/***************************************************************************
 Busca en la tabla NIVEL_CONTROL_PSU, el nivel requerido para el control que
 estamos tratando, según el valor calculado por la fórmula asociada al control.
 Este valor siempre es un varchar2, pero en función del campo CTIPCONT de la
 tabla CODCONTROL_PSU, lo trataremos como Num(1), Varchar(2) o Fecha(3).

 param in      : P_CCONTROL Código del Control que estamos tratando

                           (1 = Emisión ; 2 = Siniestros)
 param in      : P_SPRODUC  Identificador del producto
 param in      : P_NVALOR   Valor que nos llega de ehjecutar la fórmula del control
 param out     : P_NIVREQ   Código del nivel requerido para el control
 param out     : P_INCIDEN  Texto que se grabará en obseraciones de las tabla CONTROLSEG

 Devuelve      : 0 => Correcto ó 1 => error.

***************************************************************************/
   FUNCTION f_nivel_requerido_psu(
      p_control IN NUMBER,
      p_sproduc IN NUMBER,
      p_valor IN NUMBER,
      p_nivreq OUT NUMBER,
      p_nivinf OUT NUMBER,
      p_nivsup OUT NUMBER,
      p_inciden OUT VARCHAR)
      RETURN NUMBER IS
   --
   BEGIN
      --
      --
      SELECT cnivel, nvalinf, nvalsup
        INTO p_nivreq, p_nivinf, p_nivsup
        FROM psu_nivel_control
       WHERE ccontrol = p_control
         AND sproduc = p_sproduc
         AND p_valor BETWEEN nvalinf AND nvalsup;

      --
      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.F_NIVEL_REQUERIDO ERROR NIVEL REQUERIDO CCONTROL = '
                     || p_control,
                     '** Codi Error = ' || SQLERRM);
         p_inciden := '*** PROGRAM ERROR PAC_PSU NIVEL CONTROL ' || p_control;
         RETURN 9001805;
   --
   END f_nivel_requerido_psu;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
/***************************************************************************
 Busca en la tabla USUAGRU_NIVEL_PSU, el nivel que tiene el usuario para el
 producto al que pertenece la póliza y dentro del área que estemos validando.

 La no existencia del Grupo al que pertenece el usuario, o el nivel para este
 producto, no provocará ningún error, sino que se devolverá el valor 0 (Cero)
 que corresponde al mínimo nivel. De esta manera, los usuarios que tengan el
 nivel mínimo, no hará falta introducirlos en el sistema PSU.

 param in      : P_USUARIO Identificador del usuario
 param in      : P_SPRODUC Identificador del producto

 Devuelve      : Nivel del usuario para este PRODUCTO.

 O.K. MRB REVISION LIBERTY 19/10/2011

***************************************************************************/
   FUNCTION f_nivel_usuari_psu(p_usuario IN VARCHAR2, p_sproduc IN NUMBER)
      RETURN NUMBER IS
      --
      v_codagru      psu_codusuagru.cusuagru%TYPE;
      v_cnivel       psu_usuagru_nivel.cnivel%TYPE;
   --
   BEGIN
      BEGIN
         SELECT cusuagru
           INTO v_codagru
           FROM psu_usuagru
          WHERE cusuari = p_usuario;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END;

      --
      BEGIN
         SELECT cnivel
           INTO v_cnivel
           FROM psu_usuagru_nivel
          WHERE cusuagru = v_codagru
            AND sproduc = p_sproduc;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 0;
      END;

      --
      RETURN v_cnivel;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_nivel_usuario', NULL, 'f_detalle_control',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN 0;
   END f_nivel_usuari_psu;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
/***************************************************************************
 Ejecuta las fórmula de Política de Subscripción del producto al cual
 pertenece la póliza y prepara la grabación de las tablas CONTROLSEG y
 ESTCONTROLSEG.

 param in      : P_TABLAS   Indica si tratamos tablas EST o SEG
 param in      : P_SSEGURO  Número identificativo interno de SEGUROS
 param in      : P_CIDIOMA  Código del idioma
 param in      : P_FEFECTO  Fecha del efecto de la póliza/suplemento
 param in      : P_SPRODUC  Código del producto
 param in      : P_CACTIVI  Código de la actividad
 param in      : P_NRIESGO  Número de riesgo
 param in      : P_CGARANT  Código de la garantía
 param in      : P_CFORMULA Codigo de la fórmula a ejecutar
 param in      : P_CCONTROL Código del Control que estamos tratando
 param in      : P_NIVELUSU Código del Nivel del usuario para el producto

***************************************************************************/
   PROCEDURE prepara_graba_controles(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_fefecto IN DATE,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_cformula IN NUMBER,
      p_ccontrol IN NUMBER,
      p_nivelusu IN NUMBER,
      p_cautmanual IN VARCHAR2,
      p_nocurre IN NUMBER,
      p_nmovimi IN NUMBER,
      -- Ini Bug 26092 --ECP-- 13/03/2013
      origenpsu IN NUMBER DEFAULT NULL,
      pccambio  IN NUMBER DEFAULT NULL
                                      -- Fin Bug 26092 --ECP-- 13/03/2013
   ) IS
      --
      v_error        NUMBER := 0;
      v_resultat     NUMBER;
      v_inciden      psucontrolseg.observ%TYPE := '';
      v_nivreq       psucontrolseg.cnivelr%TYPE;
      v_nivinf       NUMBER;   --NUMBER(12, 2);
      v_nivsup       NUMBER;   --NUMBER(12, 2);
      v_solomanual   psu_controlpro.autmanual%TYPE;
      v_establoquea  psu_controlpro.establoquea%TYPE;
      v_ordenbloquea psu_controlpro.ordenbloquea%TYPE;
      v_autoriprev   psu_controlpro.autoriprev%TYPE;
   --
   BEGIN
      v_error := f_detalle_control(p_ccontrol, p_sproduc, p_cgarant, v_solomanual,
                                   v_establoquea, v_ordenbloquea, v_autoriprev);

      IF v_error != 0 THEN
         v_establoquea := 'N';
         v_ordenbloquea := NULL;
         v_autoriprev := 'S';
      END IF;

      -- Bug 27048/155371 - APD - 17/12/2013 -
      IF p_tablas = 'EST' THEN
         -- si se estan ejecutando las PSU 3.-Pre-Cartera y PSU 4.-Pos-Cartera
         -- borrar el control de las EST para que lo trate siempre como
         -- NO AUTORIZADO PREVIAMENTE
         IF origenpsu IN(3, 4) THEN
            v_autoriprev := 'N';

            DELETE FROM estpsucontrolseg
                  WHERE sseguro = p_sseguro
                    AND nmovimi = p_nmovimi
                    AND nriesgo = NVL(p_nriesgo, 1)
                    AND ccontrol = p_ccontrol
                    AND nocurre = p_nocurre
                    AND cgarant = NVL(p_cgarant, 0);
         END IF;
      END IF;

      -- fin Bug 27048/155371 - APD - 17/12/2013 -
      -- M.R.B. CANVIAT ORDER DE P_CCONTROL I P_CFORMULA 26/01/2011 AXIS3812
      v_error := f_trata_formulas_psu(p_sseguro, p_fefecto, p_sproduc, p_cactivi, p_nriesgo,
                                      p_cgarant, p_ccontrol, p_cformula, p_nmovimi, v_resultat,

                                      -- Ini Bug 26092 --ECP-- 13/03/2013
                                      p_tablas, origenpsu, pccambio);

                                       -- Ini Bug 26092 --ECP-- 13/03/2013
      -- M.R.B. 2/12/2011 S'afegeix P_NMOVIMI BUG 19684
      IF v_error != 0 THEN
         -- Si ha dado error al buscar el resultado de la fórmula grabaremos el
         -- control con el máximo nivel de autorización necesaria y en el campo
         -- observaciones indicaremos que se ha producido una incidencia.
         graba_tabla_controles_psu(p_tablas, p_cidioma, p_sseguro, p_nriesgo, p_cgarant,
                                   p_ccontrol, 999999, NULL, p_nivelusu,
                                   '*** PROGRAM ERROR PAC_PSU FORMULA *** CCONTROL = '
                                   || p_ccontrol,
                                   v_solomanual, v_establoquea, v_ordenbloquea, v_autoriprev,
                                   v_nivinf, v_nivsup, p_cautmanual, p_nocurre);
      ELSE
         -- Buscamos el nivel requerido para el control tratado
         --
         --
         v_error := f_nivel_requerido_psu(p_ccontrol, p_sproduc, v_resultat, v_nivreq,
                                          v_nivinf, v_nivsup, v_inciden);

         --
         IF v_error != 0 THEN
            -- Si ha dado error al buscar el nivel requerido para el control grabaremos el
            -- control con el máximo nivel de autorización necesaria y en el campo
            -- observaciones indicaremos que se ha producido una incidencia.
            v_nivreq := 999999;
         END IF;

         --
         graba_tabla_controles_psu(p_tablas, p_cidioma, p_sseguro, p_nriesgo, p_cgarant,
                                   p_ccontrol, v_nivreq, v_resultat, p_nivelusu, v_inciden,
                                   v_solomanual, v_establoquea, v_ordenbloquea, v_autoriprev,
                                   v_nivinf, v_nivsup, p_cautmanual, p_nocurre);
      --
      END IF;
   --
   END prepara_graba_controles;

/*
Comprobamos si existe un control anterior que tengamos que actualizar como No aplica.
No aplicará siempre que en el actual nocurre no este registrado.
XPL
*/
   PROCEDURE p_control_anterior(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_nocurre IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cgarant IN NUMBER,
      p_nriesgo IN NUMBER) IS
      --
      v_error        NUMBER := 0;
      v_resultat     NUMBER;
      v_inciden      psucontrolseg.observ%TYPE := '';
      v_nivreq       psucontrolseg.cnivelr%TYPE;
      v_nivinf       NUMBER;   --NUMBER(12, 2);
      v_nivsup       NUMBER;   --NUMBER(12, 2);
      v_solomanual   psu_controlpro.autmanual%TYPE;
      v_establoquea  psu_controlpro.establoquea%TYPE;
      v_ordenbloquea psu_controlpro.ordenbloquea%TYPE;
      v_autoriprev   psu_controlpro.autoriprev%TYPE;
      v_anterior     NUMBER;
   BEGIN
      IF p_tablas = 'EST' THEN
         SELECT COUNT(1)
           INTO v_anterior
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro
            AND nriesgo = p_nriesgo
            AND ccontrol = p_ccontrol
            AND cgarant = NVL(p_cgarant, 0)
            AND nmovimi = p_nmovimi
            AND nocurre = p_nocurre;

         IF v_anterior > 0 THEN
            UPDATE estpsucontrolseg
               SET cautrec = 3   --No aplica
             WHERE sseguro = p_sseguro
               AND nriesgo = p_nriesgo
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = p_nmovimi
               AND nocurre = p_nocurre - 1   --actualizamos anterior ocurre
               AND ccontrol NOT IN(SELECT DISTINCT (ccontrol)
                                              FROM estpsucontrolseg
                                             WHERE sseguro = p_sseguro
                                               AND nriesgo = p_nriesgo
                                               AND ccontrol = p_ccontrol
                                               AND cgarant = NVL(p_cgarant, 0)
                                               AND nmovimi = p_nmovimi
                                               AND nocurre = p_nocurre);   --Miramos si existe en el actual nocurre
         END IF;
      ELSIF p_tablas IN('CAR', 'POL') THEN
         SELECT COUNT(1)
           INTO v_anterior
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND nriesgo = p_nriesgo
            AND ccontrol = p_ccontrol
            AND cgarant = NVL(p_cgarant, 0)
            AND nmovimi = p_nmovimi
            AND nocurre = p_nocurre;

         IF v_anterior > 0 THEN
            UPDATE psucontrolseg
               SET cautrec = 3   --No aplica
             WHERE sseguro = p_sseguro
               AND nriesgo = p_nriesgo
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = p_nmovimi
               AND nocurre = p_nocurre - 1   --actualizamos anterior ocurre
               AND ccontrol NOT IN(SELECT DISTINCT (ccontrol)
                                              FROM psucontrolseg
                                             WHERE sseguro = p_sseguro
                                               AND nriesgo = p_nriesgo
                                               AND ccontrol = p_ccontrol
                                               AND cgarant = NVL(p_cgarant, 0)
                                               AND nmovimi = p_nmovimi
                                               AND nocurre = p_nocurre);   --Miramos si existe en el actual nocurre
         END IF;
      END IF;
   END p_control_anterior;

/*
Actualizaremos la tabla padre, psu_retenidas, mirando lo grabado en la tabla de las psucontrolseg/estpsucontrolseg
RETURN : Devolvemos el estado de la póliza
XPL
*/
   FUNCTION f_grabar_retenidas(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pcusuret IN VARCHAR2,
      pffecret IN DATE,
      pcusuaut IN VARCHAR2,
      pffecaut IN DATE,
      pobserv IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      --
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cautrec      psucontrolseg.cautrec%TYPE;
      v_fautrec      psucontrolseg.fautrec%TYPE;
      v_cusuaur      psucontrolseg.cusuaur%TYPE;
      v_observ       psucontrolseg.observ%TYPE;
      v_autorizado_antes VARCHAR2(1) := 'N';
      v_usuantes     usuarios.cusuari%TYPE;
      v_autmanual    psucontrolseg.autmanual%TYPE;
      v_nocurre      psucontrolseg.nocurre%TYPE;
      --v_csubsti      psucontrolseg.csubsti%TYPE;
      v_establoquea  VARCHAR2(10);
      vcmotret       NUMBER;
      v_total        NUMBER := 0;
      v_autorizados  NUMBER := 0;
      v_pendiente    NUMBER := 0;
      v_autorizados_aut NUMBER := 0;
      v_pendiente_nobloqueo NUMBER := 0;
      v_fmovimi      DATE;
      v_creteni      NUMBER := 0;
      v_nivelbpm     NUMBER;
      vobserv        VARCHAR2(2000) := pobserv;
      vcusuaut       VARCHAR2(400) := pcusuaut;
      vffecaut       DATE := pffecaut;
   --
   BEGIN
      IF ptablas = 'EST' THEN
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM estpsucontrolseg
          WHERE sseguro = psseguro;

         IF v_nmovimi IS NULL THEN
            --Si no hay registros en las tablas estpsucontrolseg, buscamos el nmovimi en las estgaranseg
            SELECT MAX(NVL(nmovimi, 1))
              INTO v_nmovimi
              FROM estgaranseg ms
             WHERE ms.sseguro = psseguro;
         END IF;

         --Con el Nmovimi obtenido, miramos que en que NOCURRE estamos
         SELECT MAX(nocurre)
           INTO v_nocurre
           FROM estpsucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi;

         v_nocurre := NVL(v_nocurre, 1);

         --Miramos cuantos registros para este NOCURRE tenemos
         SELECT COUNT(1)
           INTO v_total
           FROM estpsucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND nocurre = NVL(v_nocurre, 1);

         --Miramos cuantos registros estan autorizados
         SELECT COUNT(1)
           INTO v_autorizados
           FROM estpsucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND cautrec = 1
            AND nocurre = NVL(v_nocurre, 1);

         IF v_total = v_autorizados THEN   --Si todos esta autorizado
            SELECT COUNT(1)
              INTO v_autorizados_aut
              FROM estpsucontrolseg
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi
               AND cautrec = 1
               AND nocurre = NVL(v_nocurre, 1)
               AND autmanual = 'A';   --Miramos los registros autorizados automaticamente.

            v_nivelbpm := pac_psu.f_nivel_bpm(ptablas, psseguro);   --recuperamos el nivel BPM

            IF v_autorizados_aut = v_autorizados THEN
               --Si todos los registros estan autorizados automaticamente
               vcmotret := 0;   --Autorizada
               v_creteni := 0;   -- OK
               vobserv := f_axis_literales(9902734, pcidioma);   --Autorización automática
            ELSE
               vcmotret := 0;   --Autorizada
               v_creteni := 0;   -- OK
               vobserv := f_axis_literales(9900990, pcidioma);   -- Póliza con todos los Controles autorizados.
            END IF;
         ELSE   --Si no estan todos los controles autorizados
            --Cuantos hay pendientes de autorizar
            SELECT COUNT(1)
              INTO v_pendiente
              FROM estpsucontrolseg
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi
               AND nocurre = NVL(v_nocurre, 1)
               AND cautrec = 0;   --Pendiente autorizar

            IF v_pendiente > 0 THEN
               --Si hay registros pendientes a autorizar
               SELECT COUNT(1)
                 INTO v_pendiente_nobloqueo
                 FROM estpsucontrolseg
                WHERE sseguro = psseguro
                  AND nmovimi = v_nmovimi
                  AND cautrec = 0
                  AND nocurre = NVL(v_nocurre, 1)
                  AND establoquea = 'B';   -- Comportamiento Bloqueante

               IF v_pendiente_nobloqueo = 0 THEN
                  --No hay registros bloqueantes
                  vcmotret := 2;   -- Pendiente autorizar
                  v_creteni := 2;   --Pendiente

                  SELECT MAX(cnivelr)
                    INTO v_nivelbpm
                    FROM estpsucontrolseg
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi
                     AND nocurre = NVL(v_nocurre, 1)
                     AND cautrec = 0;

                  vobserv := f_axis_literales(9902735, pcidioma);   --Retenida, pendiente de autorizar
               ELSE
                  --Hay registros bloqueantes
                  vcmotret := 3;   --Bloqueada
                  v_creteni := 2;   --Pendiente

                  SELECT MIN(cnivelr)
                    INTO v_nivelbpm
                    FROM estpsucontrolseg
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi
                     AND nocurre = NVL(v_nocurre, 1)
                     AND cautrec = 0
                     AND establoquea = 'B';

                  vobserv := f_axis_literales(9902736, pcidioma);   --Bloquejada, pendent de desbloqueig
               END IF;
            END IF;
         END IF;

         SELECT MAX(fmovpsu)
           INTO v_fmovimi
           FROM estpsucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND nocurre = NVL(v_nocurre, 1);

         IF v_fmovimi IS NULL THEN
            SELECT MAX(NVL(fmovimi, f_sysdate))
              INTO v_fmovimi
              FROM movseguro ms, estseguros s
             WHERE ms.sseguro = s.ssegpol
               AND s.sseguro = psseguro
               AND ms.nmovimi = v_nmovimi;
         END IF;

         IF vcmotret = 0 THEN
            --Si esta autorizada, insertamos usuario y fecha de autorización
            vcusuaut := f_user;
            vffecaut := f_sysdate;
         ELSE
            vcusuaut := NULL;
            vffecaut := NULL;
         END IF;

         BEGIN
            INSERT INTO estpsu_retenidas
                        (sseguro, nmovimi, fmovimi, cmotret,
                         cnivelbpm, cusuret,
                         ffecret, cusuaut, ffecaut, observ)
                 VALUES (psseguro, v_nmovimi, v_fmovimi, vcmotret,
                         pac_psu.f_nivel_bpm(ptablas, psseguro), NVL(pcusuret, f_user),
                         NVL(pffecret, f_sysdate), vcusuaut, vffecaut, NVL(vobserv, '-'));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE estpsu_retenidas
                  SET cnivelbpm = pac_psu.f_nivel_bpm(ptablas, psseguro),
                      cmotret = vcmotret,
                      cusuret = NVL(pcusuret, f_user),
                      ffecret = NVL(pffecret, f_sysdate),
                      observ = NVL(vobserv, '-'),
                      cusuaut = vcusuaut,
                      ffecaut = vffecaut
                WHERE sseguro = psseguro
                  AND nmovimi = v_nmovimi;
         END;
      ELSE
         --recuperamos nmovimi
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = psseguro;

         --recuperamos nocurre
         SELECT MAX(nocurre)
           INTO v_nocurre
           FROM psucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi;

         v_nocurre := NVL(v_nocurre, 1);

         SELECT COUNT(1)
           INTO v_total
           FROM psucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND nocurre = NVL(v_nocurre, 1);

         SELECT COUNT(1)
           INTO v_autorizados
           FROM psucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND cautrec = 1
            AND nocurre = NVL(v_nocurre, 1);

         IF v_total = v_autorizados THEN
            SELECT COUNT(1)
              INTO v_autorizados_aut
              FROM psucontrolseg
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi
               AND cautrec = 1
               AND nocurre = NVL(v_nocurre, 1)
               AND autmanual = 'A';

            v_nivelbpm := pac_psu.f_nivel_bpm(ptablas, psseguro);

            IF v_autorizados_aut = v_autorizados THEN
               vcmotret := 0;
               v_creteni := 0;
               vobserv := f_axis_literales(9902734, pcidioma);
            ELSE
               vcmotret := 0;   --Autorizada
               v_creteni := 0;   -- OK
               vobserv := f_axis_literales(9900990, pcidioma);   -- Póliza con todos los Controles autorizados.
            END IF;
         ELSE
            SELECT COUNT(1)
              INTO v_pendiente
              FROM psucontrolseg
             WHERE sseguro = psseguro
               AND nmovimi = v_nmovimi
               AND nocurre = NVL(v_nocurre, 1)
               AND cautrec = 0;

            IF v_pendiente > 0 THEN
               SELECT COUNT(1)
                 INTO v_pendiente_nobloqueo
                 FROM psucontrolseg
                WHERE sseguro = psseguro
                  AND nmovimi = v_nmovimi
                  AND cautrec = 0
                  AND nocurre = NVL(v_nocurre, 1)
                  AND establoquea = 'B';

               IF v_pendiente_nobloqueo = 0 THEN
                  vcmotret := 2;
                  v_creteni := 2;

                  SELECT MAX(cnivelr)
                    INTO v_nivelbpm
                    FROM psucontrolseg
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi
                     AND nocurre = NVL(v_nocurre, 1)
                     AND cautrec = 0;

                  vobserv := f_axis_literales(9902735, pcidioma);
               ELSE
                  vcmotret := 3;
                  v_creteni := 2;

                  SELECT MIN(ordenbloquea)
                    INTO v_nivelbpm
                    FROM psucontrolseg
                   WHERE sseguro = psseguro
                     AND nmovimi = v_nmovimi
                     AND nocurre = NVL(v_nocurre, 1)
                     AND cautrec = 0
                     AND establoquea = 'B';

                  vobserv := f_axis_literales(9902736, pcidioma);
               END IF;
            END IF;
         END IF;

         SELECT MAX(fmovpsu)
           INTO v_fmovimi
           FROM psucontrolseg
          WHERE sseguro = psseguro
            AND nmovimi = v_nmovimi
            AND nocurre = NVL(v_nocurre, 1);

         IF vcmotret = 0 THEN
            vcusuaut := f_user;
            vffecaut := f_sysdate;
         ELSE
            vcusuaut := NULL;
            vffecaut := NULL;
         END IF;

         BEGIN
            INSERT INTO psu_retenidas
                        (sseguro, nmovimi, fmovimi, cmotret,
                         cnivelbpm, cusuret,
                         ffecret, cusuaut, ffecaut, observ)
                 VALUES (psseguro, v_nmovimi, v_fmovimi, vcmotret,
                         pac_psu.f_nivel_bpm(ptablas, psseguro), NVL(pcusuret, f_user),
                         NVL(pffecret, f_sysdate), vcusuaut, vffecaut, NVL(vobserv, '-'));
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE psu_retenidas
                  SET cnivelbpm = pac_psu.f_nivel_bpm(ptablas, psseguro),
                      cmotret = vcmotret,
                      cusuret = NVL(pcusuret, f_user),
                      ffecret = NVL(pffecret, f_sysdate),
                      observ = NVL(vobserv, '-'),
                      cusuaut = vcusuaut,
                      ffecaut = vffecaut
                WHERE sseguro = psseguro
                  AND nmovimi = v_nmovimi;
         END;
      END IF;

      --
      RETURN v_creteni;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.GRABA_TABLA_CONTROLES PSSEGURO = ' || psseguro,
                     '** Codi Error = ' || SQLERRM);
         RETURN v_creteni;
   --
   END f_grabar_retenidas;

----------------------------------------------------------------------------
----------------------------------------------------------------------------
/***************************************************************************
 Graba la tablas de Política de Subscripción
   PSU_CONTROLSEG o PSU_ESTCONTROLSEG para
   cada Control efectuado para la póliza que se esta tratando.

 param in      : P_TABLAS   Determina tablas EST o SEG
 param in      : P_CIDIOMA  Código del Idioma
 param in      : P_SSEGURO  Número identificativo interno de SEGUROS
 param in      : P_NRIESGO  Número de riesgo
 param in      : P_CGARANT  Códi de garantia
 param in      : P_CCONTROL Código del CONTROL
  param in      : P_CNIVELR  Nivel requerido para superar el Control
 param in      : P_NVALOR   Valor(Numérico) devuelto por las fórmulas del Control
 param in      : P_CNIVELU  Nivel del Usuario
 param in      : P_OBSERV   Observaciones que se grabarán en CONTROLSEG/ESTCONTROLSEG
 param in      : P_SOLOMANUAL Si el control NO se autoriza automáticamente
 param in      : P_ESTABLOQUEA Si el control es Bloqueante
 param in      : P_ORDENBLOQUEA Orden del control dentro de los Bloqueantes
 param in      : P_AUTORIPREV Si se acepta en base a una autorización previa

***************************************************************************/
   PROCEDURE graba_tabla_controles_psu(
      p_tablas IN VARCHAR2,
      p_cidioma IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cnivelr IN NUMBER,
      p_nvalor IN NUMBER,
      p_cnivelu IN NUMBER,
      p_observ IN VARCHAR,
      p_solomanual IN VARCHAR,
      p_establoquea IN VARCHAR,
      p_ordenbloquea IN NUMBER,
      p_autoriprev IN VARCHAR,
      p_nivinf IN NUMBER,
      p_nivsup IN NUMBER,
      p_cautmanual IN VARCHAR2,
      p_nocurre IN NUMBER) IS
      --
      v_nmovimi      movseguro.nmovimi%TYPE;
      v_cautrec      psucontrolseg.cautrec%TYPE;
      v_fautrec      psucontrolseg.fautrec%TYPE;
      v_cusuaur      psucontrolseg.cusuaur%TYPE;
      v_observ       psucontrolseg.observ%TYPE;
      v_autorizado_antes VARCHAR2(2) := 'N';
      v_usuantes     usuarios.cusuari%TYPE;
      v_autmanual    psucontrolseg.autmanual%TYPE;
      v_nocurre      psucontrolseg.nocurre%TYPE := p_nocurre;
      v_nvalortope   NUMBER;
      v_exite        NUMBER;
      v_iguales      NUMBER;
      v_sproduc      NUMBER;
      vcretenpor     NUMBER;
      v_nvalorant    NUMBER;
      v_nvalorinf    NUMBER;
      v_cgarant      NUMBER := p_cgarant;
      v_fautrecant   DATE;
      v_visible      NUMBER := 1;
      vcnivelr       NUMBER;
      vcautrec       NUMBER;
      --v_csubsti      psucontrolseg.csubsti%TYPE;
   --
   BEGIN
      IF p_tablas = 'EST' THEN
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro;

         -- M.R.B. 19/01/2012 sumem 1 al nmovimi de movseguro, per que els
         -- moviments que no tenien PSU_CONTROLSEG ho facin bé.
         -- Amb la col.laboració de R.Sangrós.
         IF v_nmovimi IS NULL THEN
            SELECT MAX(NVL(nmovimi, 1))
              INTO v_nmovimi
              FROM estgaranseg ms
             WHERE ms.sseguro = p_sseguro;

            IF v_nmovimi IS NULL THEN
               v_nmovimi := 1;
            END IF;
         END IF;

         SELECT sproduc
           INTO v_sproduc
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT MAX(nmovimi)
           INTO v_nmovimi
           FROM movseguro
          WHERE sseguro = p_sseguro;

         IF v_nmovimi IS NULL THEN
            v_nmovimi := 1;
         END IF;

         SELECT sproduc
           INTO v_sproduc
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      v_observ := p_observ;

      --v_csubsti := 'N';

      -- Bug 26488 - QT: 7939 - 18/06/2013 - Se añade p_autoriprev = 'N'
      IF p_solomanual = 'M'
         AND p_autoriprev = 'N'
         OR(v_nmovimi = 1
            AND p_solomanual = 'M') THEN   -- Sí es forzado que se autorice manualmente, no miramos niveles.
         -- Fin Bug 26488
         IF p_cnivelr = 0 THEN
            v_cautrec := 1;
         ELSE
            v_cautrec := 0;
         END IF;

         v_fautrec := NULL;
         v_cusuaur := NULL;
         v_autmanual := 'M';
         v_observ := '';   --f_axis_literales(9902734, p_cidioma);
         v_iguales := 1;
      ELSE
          --miramos si ha sido autorizado anterioemente
         /* IF p_autoriprev = 'N' THEN
             v_autorizado_antes := 'N';
             v_iguales := 2;
          ELSE*/
         v_autorizado_antes := 'N';
         v_autorizado_antes := f_autorizado_antes(p_sseguro, p_nriesgo, p_ccontrol, p_cnivelr,
                                                  p_nvalor, p_cgarant, v_nocurre, v_nmovimi,
                                                  p_tablas, v_usuantes, v_autmanual,
                                                  v_cautrec, v_nvalortope, v_observ,
                                                  v_iguales, v_nvalorant, v_cgarant,
                                                  v_nvalorinf, v_fautrecant);

         --  END IF;
         BEGIN
            SELECT cretenpor
              INTO vcretenpor
              FROM psu_controlpro
             WHERE ccontrol = p_ccontrol
               AND sproduc = v_sproduc
               AND NVL(cgarant, 0) = NVL(p_cgarant, 0);
         EXCEPTION
            WHEN OTHERS THEN
               SELECT cretenpor
                 INTO vcretenpor
                 FROM psu_controlpro
                WHERE ccontrol = p_ccontrol
                  AND sproduc = v_sproduc
                  AND ROWNUM = 1;
         END;

         --  IF NVL(v_autorizado_antes, 'N') = 'S' THEN
         IF v_iguales = 1 THEN   -- no son iguales
            v_visible := 1;

            IF v_cautrec <> 0 THEN
               IF p_nvalor > v_nvalortope THEN
                  IF v_cautrec IN(1, 3) THEN
                     IF vcretenpor IN(2, 3) THEN   --por mayor o diferente
                        IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                           v_cautrec := 1;   --Lo grabaremos como autorizado
                           v_observ := f_axis_literales(9902734, p_cidioma);
                        ELSE
                           v_cautrec := 0;   --pendiente autorizar
                           v_observ := '';
                        END IF;

                        v_nvalortope := p_nivsup;

                        -- actualizamos anterior
                        IF p_tablas = 'EST' THEN
                           UPDATE estpsucontrolseg
                              SET cautrec = 3   -- no aplica
                            WHERE sseguro = p_sseguro
                              AND nmovimi = v_nmovimi
                              AND nriesgo = p_nriesgo
                              AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                              AND ccontrol = p_ccontrol
                              AND nocurre = NVL(v_nocurre, 1);
                        ELSIF p_tablas IN('CAR', 'POL') THEN
                           UPDATE psucontrolseg
                              SET cautrec = 3   -- no aplica
                            WHERE sseguro = p_sseguro
                              AND nmovimi = v_nmovimi
                              AND nriesgo = p_nriesgo
                              AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                              AND ccontrol = p_ccontrol
                              AND nocurre = NVL(v_nocurre, 1);
                        END IF;
                     END IF;
                  ELSIF v_cautrec = 2 THEN
                     IF vcretenpor IN(2, 3) THEN   --por mayor o diferente
                        IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                           v_cautrec := 1;   --Lo grabaremos como autorizado
                           v_observ := f_axis_literales(9902734, p_cidioma);
                        ELSE
                           v_cautrec := 0;   --pendiente autorizar
                           v_observ := '';
                        END IF;

                        v_nvalortope := p_nivsup;
                     END IF;
                  END IF;
               ELSIF p_nvalor < v_nvalorinf THEN
                  IF v_cautrec IN(1, 3) THEN
                     IF vcretenpor = 1 THEN   --por menor
                        IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                           v_cautrec := 1;   --Lo grabaremos como autorizado
                           v_observ := f_axis_literales(9902734, p_cidioma);
                        ELSE
                           v_cautrec := 0;   --pendiente autorizar
                           v_observ := '';
                        END IF;

                        v_nvalortope := p_nivsup;

                        -- actualizamos anterior
                        IF p_tablas IN('EST') THEN
                           UPDATE estpsucontrolseg
                              SET cautrec = 3   -- no aplica
                            WHERE sseguro = p_sseguro
                              AND nmovimi = v_nmovimi
                              AND nriesgo = p_nriesgo
                              AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                              AND ccontrol = p_ccontrol
                              AND nocurre = NVL(v_nocurre, 1);
                        ELSIF p_tablas IN('CAR', 'POL') THEN
                           UPDATE psucontrolseg
                              SET cautrec = 3   -- no aplica
                            WHERE sseguro = p_sseguro
                              AND nmovimi = v_nmovimi
                              AND nriesgo = p_nriesgo
                              AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                              AND ccontrol = p_ccontrol
                              AND nocurre = NVL(v_nocurre, 1);
                        END IF;
                     END IF;
                  ELSIF v_cautrec = 2 THEN
                     IF vcretenpor = 1 THEN   --por menor
                        IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                           v_cautrec := 1;   --Lo grabaremos como autorizado
                           v_observ := f_axis_literales(9902734, p_cidioma);
                        ELSE
                           v_cautrec := 0;   --pendiente autorizar
                           v_observ := '';
                        END IF;

                        v_nvalortope := p_nivsup;
                     END IF;
                  END IF;
               END IF;
            ELSE
               IF p_nvalor > v_nvalortope THEN
                  IF vcretenpor IN(2, 3) THEN   --por mayor o diferente
                     IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                        v_cautrec := 1;   --Lo grabaremos como autorizado
                        v_observ := f_axis_literales(9902734, p_cidioma);
                     ELSE
                        v_cautrec := 0;   --pendiente autorizar
                        v_observ := '';
                     END IF;

                     IF p_tablas IN('EST') THEN
                        UPDATE estpsucontrolseg
                           SET cautrec = 3   -- no aplica
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                           AND nriesgo = p_nriesgo
                           AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                           AND ccontrol = p_ccontrol
                           AND nocurre = NVL(v_nocurre, 1);
                     ELSIF p_tablas IN('CAR', 'POL') THEN
                        UPDATE psucontrolseg
                           SET cautrec = 3   -- no aplica
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                           AND nriesgo = p_nriesgo
                           AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                           AND ccontrol = p_ccontrol
                           AND nocurre = NVL(v_nocurre, 1);
                     END IF;

                     v_nvalortope := p_nivsup;
                  END IF;
               ELSIF p_nvalor < v_nvalorinf THEN
                  IF vcretenpor IN(1) THEN   --por mayor o diferente
                     IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                        v_cautrec := 1;   --Lo grabaremos como autorizado
                        v_observ := f_axis_literales(9902734, p_cidioma);
                     ELSE
                        v_cautrec := 0;   --pendiente autorizar
                        v_observ := '';
                     END IF;

                     IF p_tablas IN('EST') THEN
                        UPDATE estpsucontrolseg
                           SET cautrec = 3   -- no aplica
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                           AND nriesgo = p_nriesgo
                           AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                           AND ccontrol = p_ccontrol
                           AND nocurre = NVL(v_nocurre, 1);
                     ELSIF p_tablas IN('CAR', 'POL') THEN
                        UPDATE psucontrolseg
                           SET cautrec = 3   -- no aplica
                         WHERE sseguro = p_sseguro
                           AND nmovimi = v_nmovimi
                           AND nriesgo = p_nriesgo
                           AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                           AND ccontrol = p_ccontrol
                           AND nocurre = NVL(v_nocurre, 1);
                     END IF;

                     v_nvalortope := p_nivsup;
                  END IF;
               END IF;
            END IF;
         -- END IF;
         ELSIF v_iguales = 0 THEN   -- Iguales
            v_visible := NULL;

            IF v_autorizado_antes = 'NV' THEN
               v_visible := 0;
            END IF;

            --  v_fautrec := f_sysdate;
            v_fautrec := v_fautrecant;
            v_cusuaur := v_usuantes;
         /* IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- Lo grabaremos como autorizado
             IF p_nvalor BETWEEN p_nivinf AND NVL(v_nvalortope, p_nivsup) THEN
                v_cautrec := 1;
             END IF;
          END IF;*/
         ELSIF v_iguales IN(2) THEN   --No existe
            v_visible := 1;

            IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- Lo grabaremos como autorizado
               IF p_tablas IN('EST') THEN
                  SELECT MAX(nvalortope)
                    INTO v_nvalortope
                    FROM estpsucontrolseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = v_nmovimi
                     AND nriesgo = p_nriesgo
                     AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                     AND ccontrol = p_ccontrol
                     AND nocurre = NVL(v_nocurre, 1);
               ELSIF p_tablas IN('CAR', 'POL') THEN
                  SELECT MAX(nvalortope)
                    INTO v_nvalortope
                    FROM psucontrolseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = v_nmovimi
                     AND nriesgo = p_nriesgo
                     AND NVL(cgarant, 0) = NVL(p_cgarant, 0)
                     AND ccontrol = p_ccontrol
                     AND nocurre = NVL(v_nocurre, 1);
               END IF;

               IF v_nvalortope IS NULL THEN
                  v_nvalortope := p_nivsup;
               END IF;

               IF p_nvalor BETWEEN p_nivinf AND NVL(v_nvalortope, p_nivsup) THEN
                  v_cautrec := 1;
                  v_fautrec := f_sysdate;
                  v_cusuaur := f_user;

                  IF p_tablas IN('EST') THEN
                     SELECT COUNT(1)
                       INTO v_exite
                       FROM estpsucontrolseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = v_nmovimi
                        AND ccontrol = p_ccontrol
                        AND NVL(cgarant, 0) = NVL(p_cgarant, 0);
                  ELSIF p_tablas IN('CAR', 'POL') THEN
                     SELECT COUNT(1)
                       INTO v_exite
                       FROM psucontrolseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = v_nmovimi
                        AND ccontrol = p_ccontrol
                        AND NVL(cgarant, 0) = NVL(p_cgarant, 0);
                  END IF;

                  IF NVL(v_nocurre, 1) = 1
                     OR v_exite > 0 THEN
                     v_autmanual := 'A';
                  ELSE
                     v_autmanual := 'M';
                  END IF;
               ELSE
                  v_cautrec := 0;
                  v_fautrec := f_sysdate;
                  v_cusuaur := f_user;
                  v_autmanual := 'M';
                  v_observ := ' ';
               END IF;

               IF v_observ IS NULL
                  AND v_autmanual != 'M' THEN
                  v_observ := f_axis_literales(9902734, p_cidioma);
               END IF;
            ELSE
               IF NVL(p_cnivelu, 0) >= NVL(p_cnivelr, 999999) THEN   -- --mirar si el usuario tiene nivel si es q si lo autorizamo
                  v_cautrec := 1;   --Lo grabaremos como autorizado
                  v_observ := f_axis_literales(9902734, p_cidioma);
               ELSE
                  v_cautrec := 0;   --pendiente autorizar
                  v_observ := '';
               END IF;

               v_fautrec := f_sysdate;
               v_cusuaur := f_user;
               v_autmanual := 'A';
            END IF;
         END IF;
      END IF;

        /*  IF NVL(v_autorizado_antes, 'N') = 'N' THEN
             v_cautrec := 0;   -- Lo grabaremos como pendiente de autorización o rechazo
             v_fautrec := NULL;
             v_cusuaur := NULL;
             v_autmanual := NULL;
          ELSE   -- Si había sido autorizado con anterioridad lo dejaremos autorizado.
             v_cautrec := 1;
             v_fautrec := f_sysdate;
             v_cusuaur := v_usuantes;

             IF v_observ IS NULL THEN
                v_observ := f_axis_literales(9001774, p_cidioma);
             END IF;
          END IF;*/
       -- miramos de autorizarlo
      -- END IF;
      v_nocurre := NVL(v_nocurre, 0) + 1;

      --
      IF p_tablas = 'EST' THEN
         --
         IF v_nmovimi IS NULL THEN
            SELECT MAX(NVL(nmovimi, 0)) + 1
              INTO v_nmovimi
              FROM movseguro ms, estseguros s
             WHERE ms.sseguro = s.ssegpol
               AND s.sseguro = p_sseguro;
         END IF;

         IF v_cgarant IS NULL THEN
            v_cgarant := p_cgarant;
         END IF;

         -- m.r.b. i x.p 27/01/2012 U.A.T. 3634 AXIS3812
         IF v_cautrec = 0 THEN
            SELECT autmanual
              INTO v_autmanual
              FROM psu_controlpro
             WHERE ccontrol = p_ccontrol
               AND sproduc = v_sproduc
               AND NVL(cgarant, 0) = NVL(p_cgarant, 0);
         END IF;

         -- FI m.r.b. i x.p.
         IF v_iguales <> 0 THEN
            IF v_cautrec = 0 THEN
               v_visible := 1;
            END IF;

            INSERT INTO estpsucontrolseg
                        (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo,
                         cgarant, cnivelr, nvalor, cusumov, cnivelu, cautrec,
                         establoquea, ordenbloquea, autoriprev, fautrec, cusuaur,
                         observ, nocurre, nvalorinf, nvalorsuper, autmanual,
                         nvalortope, isvisible)
                 VALUES (p_sseguro, v_nmovimi, f_sysdate, p_ccontrol, NVL(p_nriesgo, 1),
                         NVL(v_cgarant, 0), p_cnivelr, p_nvalor, f_user, p_cnivelu, v_cautrec,
                         p_establoquea, p_ordenbloquea, p_autoriprev, v_fautrec, v_cusuaur,
                         v_observ, v_nocurre, p_nivinf, p_nivsup, v_autmanual,
                         LEAST(NVL(v_nvalortope, p_nivsup), p_nivsup), NVL(v_visible, 1));
         ELSE
            SELECT cnivelr, cautrec
              INTO vcnivelr, vcautrec
              FROM estpsucontrolseg
             WHERE sseguro = p_sseguro
               AND nriesgo = NVL(p_nriesgo, 1)
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = v_nmovimi
               AND nocurre = p_nocurre;

            IF vcautrec = 0 THEN
               v_visible := 1;
            END IF;

            INSERT INTO estpsucontrolseg
                        (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, cgarant, cnivelr,
                         nvalor, cusumov, cnivelu, cautrec, establoquea, ordenbloquea,
                         autoriprev, fautrec, cusuaur, observ, nocurre, nvalorinf, nvalorsuper,
                         autmanual, nvalortope, isvisible)
               (SELECT p_sseguro, v_nmovimi, fmovpsu, ccontrol, nriesgo, cgarant, cnivelr,
                       nvalor, cusumov, cnivelu, cautrec, establoquea, ordenbloquea,
                       autoriprev, fautrec, cusuaur, observ, v_nocurre, nvalorinf, nvalorsuper,
                       autmanual, LEAST(nvalortope, nvalorsuper),
                       NVL(v_visible, NVL(isvisible, 1))
                  FROM estpsucontrolseg
                 WHERE sseguro = p_sseguro
                   AND nriesgo = NVL(p_nriesgo, 1)
                   AND ccontrol = p_ccontrol
                   AND cgarant = NVL(p_cgarant, 0)
                   AND nmovimi = v_nmovimi
                   AND nocurre = p_nocurre);
         END IF;
      ELSE
         -- m.r.b. i x.p 27/01/2012 U.A.T. 3634 AXIS3812
         IF v_cautrec = 0 THEN
            SELECT autmanual
              INTO v_autmanual
              FROM psu_controlpro
             WHERE ccontrol = p_ccontrol
               AND sproduc = v_sproduc
               AND NVL(cgarant, 0) = NVL(p_cgarant, 0);
         END IF;

         -- FI m.r.b. i x.p.
         IF v_nmovimi IS NULL THEN
            SELECT MAX(nmovimi)
              INTO v_nmovimi
              FROM movseguro
             WHERE sseguro = p_sseguro;
         END IF;

         IF v_cgarant IS NULL THEN
            v_cgarant := p_cgarant;
         END IF;

         -- Bug 25731 - APD - 17/01/2013 - se añade el if igual que en las EST
         IF v_iguales <> 0 THEN
            IF v_cautrec = 0 THEN
               v_visible := 1;
            END IF;

            INSERT INTO psucontrolseg
                        (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo,
                         cgarant, cnivelr, nvalor, cusumov, cnivelu, cautrec,
                         establoquea, ordenbloquea, autoriprev, fautrec, cusuaur,
                         observ, nocurre, nvalorinf, nvalorsuper, autmanual,
                         nvalortope, isvisible)
                 VALUES (p_sseguro, v_nmovimi, f_sysdate, p_ccontrol, NVL(p_nriesgo, 1),
                         NVL(v_cgarant, 0), p_cnivelr, p_nvalor, f_user, p_cnivelu, v_cautrec,
                         p_establoquea, p_ordenbloquea, p_autoriprev, v_fautrec, v_cusuaur,
                         v_observ, v_nocurre, p_nivinf, p_nivsup, v_autmanual,
                         NVL(v_nvalortope, p_nivsup), NVL(v_visible, 1));
         ELSE
            SELECT cnivelr, cautrec
              INTO vcnivelr, vcautrec
              FROM psucontrolseg
             WHERE sseguro = p_sseguro
               AND nriesgo = NVL(p_nriesgo, 1)
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = v_nmovimi
               AND nocurre = p_nocurre;

            IF vcautrec = 0 THEN
               v_visible := 1;
            END IF;

            INSERT INTO psucontrolseg
                        (sseguro, nmovimi, fmovpsu, ccontrol, nriesgo, cgarant, cnivelr,
                         nvalor, cusumov, cnivelu, cautrec, establoquea, ordenbloquea,
                         autoriprev, fautrec, cusuaur, observ, nocurre, nvalorinf, nvalorsuper,
                         autmanual, nvalortope, isvisible)
               (SELECT p_sseguro, v_nmovimi, fmovpsu, ccontrol, nriesgo, cgarant, cnivelr,
                       nvalor, cusumov, cnivelu, cautrec, establoquea, ordenbloquea,
                       autoriprev, fautrec, cusuaur, observ, v_nocurre, nvalorinf, nvalorsuper,
                       autmanual, LEAST(nvalortope, nvalorsuper),
                       NVL(v_visible, NVL(isvisible, 1))
                  FROM psucontrolseg
                 WHERE sseguro = p_sseguro
                   AND nriesgo = NVL(p_nriesgo, 1)
                   AND ccontrol = p_ccontrol
                   AND cgarant = NVL(p_cgarant, 0)
                   AND nmovimi = v_nmovimi
                   AND nocurre = p_nocurre);
         END IF;
      -- fin Bug 25731 - APD - 17/01/2013
      END IF;

      p_control_anterior(p_tablas, p_sseguro, v_nmovimi, v_nocurre, p_ccontrol, p_cgarant,
                         p_nriesgo);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.GRABA_TABLA_CONTROLES PSSEGURO = ' || p_sseguro
                     || ' CCONTROL = ' || p_ccontrol,
                     '** Codi Error = ' || SQLERRM);
   --
   END graba_tabla_controles_psu;

   /***************************************************************************
    Recupera los datos del detalle del control tratado en la tabla CONTROLPRO

    param in      : P_CCONTROL     Código del CONTROL
    param in      : P_SPRODUC      Codi del producte que tractem
    param in      : P_SOLOMANUAL   Si el control NO se autoriza automáticamente
    param out     : P_ESTABLOQUEA  Control bloqueante
    param out     : P_ORDENBLOQUEA Orden dentro de los bloqueantes
    param out     : P_AUTORIPREV   Autorizamos según autorización previa (S-N)

    DEVUELVE      : 0 = O.K.;  1 => Error

   ***************************************************************************/
   FUNCTION f_detalle_control(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cgarant IN NUMBER,
      p_solomanual OUT VARCHAR,
      p_establoquea OUT VARCHAR,
      p_ordenbloquea OUT NUMBER,
      p_autoriprev OUT VARCHAR)
      RETURN NUMBER IS
      --
      v_nvalor       psucontrolseg.nvalor%TYPE;
      v_cnivelr      psucontrolseg.cnivelr%TYPE;
      v_cusuaur      psucontrolseg.cusuaur%TYPE;
      v_resultat     VARCHAR2(1) := 'N';
   --
   BEGIN
      --
      SELECT establoquea, ordenbloquea, autoriprev, autmanual
        INTO p_establoquea, p_ordenbloquea, p_autoriprev, p_solomanual
        FROM psu_controlpro
       WHERE ccontrol = p_ccontrol
         AND sproduc = p_sproduc
         AND NVL(cgarant, 0) = NVL(p_cgarant, 0);

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_establoquea := 'N';
         p_ordenbloquea := NULL;
         p_autoriprev := 'N';
         p_tab_error(f_sysdate, f_user, 'f_detalle_control', NULL, 'f_detalle_control',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN 0;
   --

   --
   END f_detalle_control;

----------------------------------------------------------------------------

   /***************************************************************************
    Comprueba si el control ya había sido autorizado con anterioridad en otro
    movimiento de la póliza.

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_CNIVELR  Nivel requerido para superar el Control
    param in      : P_NVALOR   Valor(Numérico) devuelto por las fórmulas del Control
    param out     : P_USUANTES Usuario que autorizó en su momento
    param out     : P_AUTMANUAL Si el control NO se autoriza automáticamente

    Devuelve:     'S' => El control YA habia sido autorizado con anterioridad
                  'N' => El control NO se habia autorizado con anterioridad
   ***************************************************************************/
   FUNCTION f_autorizado_antes(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cnivelr IN NUMBER,
      p_nvalor IN NUMBER,
      p_cgarant IN NUMBER,
      p_nocurre IN NUMBER,
      p_nmovimi IN NUMBER,
      p_tablas IN VARCHAR2,
      p_usuantes OUT VARCHAR2,
      p_autmanual OUT VARCHAR2,
      p_cautrec OUT NUMBER,
      p_nvalortope OUT NUMBER,
      p_observ OUT VARCHAR2,
      p_iguales OUT NUMBER,
      p_nvalorant OUT NUMBER,
      p_cgarant_out OUT NUMBER,
      p_nvalorinf OUT NUMBER,
      p_fautrecant OUT DATE)
      RETURN VARCHAR2 IS
      --
      v_nvalor       psucontrolseg.nvalor%TYPE;
      v_cnivelr      psucontrolseg.cnivelr%TYPE;
      v_cusuaur      psucontrolseg.cusuaur%TYPE;
      v_resultat     VARCHAR2(2) := 'N';
      v_anterior     NUMBER;
      v_nmovimiant   NUMBER;
      v_iguales      NUMBER;
      v_diferentes   NUMBER;
      v_nvalorinf    NUMBER;
      v_nvalortope   NUMBER;
      v_autorizado   NUMBER;
      v_dispara_psu VARCHAR2(1);--indica si se debe disparar siempre la psu
   --
   BEGIN
      --
      BEGIN
         IF p_tablas IN('EST') THEN
            SELECT COUNT(1)
              INTO v_anterior
              FROM estpsucontrolseg
             WHERE sseguro = p_sseguro
               AND nriesgo = NVL(p_nriesgo, 1)
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = p_nmovimi
               AND nocurre = p_nocurre;

            IF v_anterior > 0 THEN
               SELECT cusuaur, autmanual, cautrec, nvalortope, observ,
                      nvalor, cgarant, nvalorinf, fautrec
                 INTO p_usuantes, p_autmanual, p_cautrec, p_nvalortope, p_observ,
                      p_nvalorant, p_cgarant_out, p_nvalorinf, p_fautrecant
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND ccontrol = p_ccontrol
                  AND cgarant = NVL(p_cgarant, 0)
                  AND nmovimi = p_nmovimi
                  AND nocurre = p_nocurre;

               SELECT COUNT(1)
                 INTO v_autorizado
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND ccontrol = p_ccontrol
                  AND cgarant = NVL(p_cgarant, 0)
                  AND nmovimi = p_nmovimi
                  AND nocurre = p_nocurre
                  AND cautrec = 0;

               IF v_autorizado > 0 THEN
                  v_resultat := 'N';
               ELSE
                  v_resultat := 'S';
               END IF;

               BEGIN
                  SELECT 'S'
                    INTO v_dispara_psu
                    FROM detvalores
                   WHERE cvalor = 8002005
                     AND cidioma = 8
                     AND tatribu = p_ccontrol;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_dispara_psu := 'N';
               END;

               IF (p_nvalor BETWEEN p_nvalorinf AND p_nvalortope
                  OR p_nvalor = p_nvalorant)
                  AND NVL(v_dispara_psu, 'N') != 'S'
                  THEN
                  p_iguales := 0;   -- iguales

                  SELECT MAX(nmovimi)
                    INTO v_nmovimiant
                    FROM movseguro m, estseguros es
                   WHERE m.sseguro = es.ssegpol
                     AND es.sseguro = p_sseguro;

                  IF p_nocurre = 1
                     AND NVL(p_nmovimi, 1) <> NVL(v_nmovimiant, 1) THEN
                     v_resultat := 'NV';
                  END IF;
               ELSIF p_nvalor < p_nvalorinf
                     OR p_nvalor > p_nvalortope THEN
                  p_iguales := 1;   -- se ha modificado el nvalor
               END IF;
            /* IF p_nvalor BETWEEN v_nvalorinf AND v_nvalortope THEN
                p_iguales := 0;   -- iguales
             ELSIF p_nvalor < v_nvalorinf
                   OR p_nvalor > v_nvalortope THEN
                p_iguales := 1;   -- se ha modificado el nvalor
             END IF;*/
            ELSE
               p_iguales := 2;   --no existe
               v_resultat := 'N';
            END IF;
         --
         -- Si el valor resultado de aplicar la fórmula del control és igual al que
         -- se autorizó con anterioridad, consideraremos que ahora también se autoriza
         -- automàticamente, pese a que el nivel del usuario del movimiento sea inferior
         -- al nivel requerido por el resultado del control.
         -- También se considerará autorizado cuando el nivel que se requiere en la
         -- actualidad, es inferior al nivel requerido con el que se autorizó en su
         -- momento, pese a que el valor sea distinto.
         --
         ELSIF p_tablas IN('CAR', 'POL') THEN
            SELECT COUNT(1)
              INTO v_anterior
              FROM psucontrolseg
             WHERE sseguro = p_sseguro
               AND nriesgo = NVL(p_nriesgo, 1)
               AND ccontrol = p_ccontrol
               AND cgarant = NVL(p_cgarant, 0)
               AND nmovimi = p_nmovimi
               AND nocurre = p_nocurre;

            IF v_anterior > 0 THEN
               SELECT cusuaur, autmanual, cautrec, nvalortope, observ,
                      nvalor, cgarant, nvalorinf, fautrec
                 INTO p_usuantes, p_autmanual, p_cautrec, p_nvalortope, p_observ,
                      p_nvalorant, p_cgarant_out, p_nvalorinf, p_fautrecant
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND ccontrol = p_ccontrol
                  AND cgarant = NVL(p_cgarant, 0)
                  AND nmovimi = p_nmovimi
                  AND nocurre = p_nocurre;

               SELECT COUNT(1)
                 INTO v_autorizado
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro
                  AND nriesgo = NVL(p_nriesgo, 1)
                  AND ccontrol = p_ccontrol
                  AND cgarant = NVL(p_cgarant, 0)
                  AND nmovimi = p_nmovimi
                  AND nocurre = p_nocurre
                  AND cautrec = 0;

               IF v_autorizado > 0 THEN
                  v_resultat := 'N';
               ELSE
                  v_resultat := 'S';
               END IF;

               IF p_nvalor BETWEEN p_nvalorinf AND p_nvalortope
                  OR p_nvalor = p_nvalorant THEN
                  p_iguales := 0;   -- iguales

                  SELECT MAX(nmovimi)
                    INTO v_nmovimiant
                    FROM movseguro m, seguros es
                   WHERE m.sseguro = es.sseguro
                     AND es.sseguro = p_sseguro;

                  IF p_nocurre = 1
                     AND NVL(p_nmovimi, 1) <> NVL(v_nmovimiant, 1) THEN
                     v_resultat := 'NV';
                  END IF;
               ELSIF p_nvalor < p_nvalorinf
                     OR p_nvalor > p_nvalortope THEN
                  p_iguales := 1;   -- se ha modificado el nvalor
               END IF;
            ELSE
               p_iguales := 2;   --no existe
               v_resultat := 'N';
            END IF;
         --
         END IF;
      --
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                        'PAC_PSU.f_autorizado_antes PSSEGURO = ' || p_sseguro
                        || ' CCONTROL = ' || p_ccontrol,
                        '** Codi Error = ' || SQLERRM);
            --
            v_resultat := 'N';
      --
      END;

      --
      RETURN v_resultat;
   --
   END f_autorizado_antes;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que actualitza l'estat del control, ja sigui autoritzat com rebutjat

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Codi de la garantia.
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_CNIVELU  Nivel del Usuario que trata el control
    param in      : P_ACCIO    1 = Autorizar, 2 = Rechazar.
    param in      : P_OBSERV   Observaciones que se grabarán en ESTCONTROLSEG

    Devuelve:     : 0 = O.K.

   ***************************************************************************/
   FUNCTION f_actualiza(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_cnivelu IN NUMBER,
      p_accio IN VARCHAR2,
      p_observ IN VARCHAR2,
      p_nvalortope IN NUMBER,
      p_nocurre IN NUMBER,
      p_nvalor IN NUMBER,
      p_nvalorinf IN NUMBER,
      p_nvalorsuper IN NUMBER,
      p_nivelr IN NUMBER,
      p_establoquea IN NUMBER,
      p_autmanual IN NUMBER,
      p_tablas IN VARCHAR2,
      p_modo IN NUMBER,
      p_numriesgo IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER IS
      vautmanual     NUMBER := 0;
      v_cont         NUMBER;
      v_fefecto      DATE;
      v_sproduc      NUMBER;
      v_cactivi      NUMBER;
      v_resultat     NUMBER;
      v_nivreq       NUMBER;
      v_inciden      VARCHAR2(500);
      i              NUMBER := 1;
      v_error        NUMBER;
      v_modo         NUMBER;
      v_nivinf       NUMBER;
      v_nivsup       NUMBER;
      v_nvalorinf    NUMBER;
      v_nvalorsuper  NUMBER;
      v_establoquea  VARCHAR2(10) := p_establoquea;
      v_autmanual    VARCHAR2(10) := p_autmanual;
      v_cmotret      NUMBER;
      v_total        NUMBER;
      v_autorizados  NUMBER;
      vobserv        VARCHAR2(1000);
      v_nmovimi      NUMBER := p_nmovimi;
   /* CURSOR c_psu_controlpro(
       p_sproduc IN NUMBER,
       p_accion IN NUMBER,
       p_ctratar IN NUMBER,
       pccontrol IN NUMBER) IS
       SELECT   *
           FROM psu_controlpro
          WHERE sproduc = p_sproduc
            AND ctratar = p_ctratar
            AND((producci = '1'
                 AND p_accion = 1)
                OR(suplemen = '1'
                   AND p_accion = 2)
                OR(renovaci = '1'
                   AND p_accion = 3))
            AND ccontrol = pccontrol
       ORDER BY ccontrol;*/
   BEGIN
      IF p_establoquea = 1 THEN
         v_establoquea := 'E';
      ELSE
         v_establoquea := 'B';
      END IF;

      IF p_autmanual = 1 THEN
         v_autmanual := 'A';
      ELSE
         v_autmanual := 'M';
      END IF;

      IF p_tablas = 'EST' THEN
         SELECT fefecto, sproduc, cactivi, csituac
           INTO v_fefecto, v_sproduc, v_cactivi, v_modo
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT fefecto, sproduc, cactivi, csituac
           INTO v_fefecto, v_sproduc, v_cactivi, v_modo
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      /*  IF p_modo IS NOT NULL THEN
           v_modo := p_modo;
        ELSE
           IF v_modo = 4 THEN
              v_modo := 1;   --Nova Producció
           ELSIF v_modo = 5 THEN
              v_modo := 2;   --Suplement
           END IF;
        END IF;*/
      IF p_nivelr IS NOT NULL
         AND p_nivelr > p_cnivelu THEN
         RETURN 109905;
      END IF;

      IF p_ccontrol IS NOT NULL THEN
         /*   WHILE i < 4 LOOP
               FOR regpsu IN c_psu_controlpro(v_sproduc, v_modo, i, p_ccontrol) LOOP
                  v_error := f_trata_formulas_psu(p_sseguro, v_fefecto, v_sproduc, v_cactivi,
                                                  p_nriesgo, p_cgarant, p_ccontrol, regpsu.cformula,
                                                  v_resultat);
                  v_error := f_nivel_requerido_psu(p_ccontrol, v_sproduc, v_resultat, v_nivreq,
                                                   v_nivinf, v_nivsup, v_inciden);

                  IF v_nivreq > p_cnivelu THEN
                     RETURN 109905;
                  END IF;
               END LOOP;

               i := i + 1;
            END LOOP;*/
         IF p_nvalortope < p_nvalorinf
            OR p_nvalortope > p_nvalorsuper THEN
            RETURN 180018;
         END IF;

         IF p_tablas = 'EST' THEN
            IF NVL(p_accio, 0) IN(0, 1, 2) THEN
               /* SELECT nvalorinf, nvalorsuper
                  INTO v_nvalorinf, v_nvalorsuper
                  FROM estpsucontrolseg
                 WHERE sseguro = p_sseguro
                   AND(p_nriesgo IS NULL
                       OR nriesgo = p_nriesgo)
                   AND ccontrol = p_ccontrol
                   AND nmovimi = p_nmovimi
                   AND cgarant = NVL(p_cgarant, cgarant)
                   AND nocurre = p_nocurre;*/

               --BUG 27262/160330 - 10/12/2013 - RCL: Si p_modo esta informat amb 4 (Autorizar todo) o 5 (Rechazar todo),
               --   deixem el observ amb el valor que tenia, sempre que aquest no sigui null.
               --   Si observ es null o p_modo es null (vol dir que accedim a aquesta funció, autoritzant/rebutjant un control o masivament)
               --   sempre es posa la observació introduida en el pop-up
               UPDATE estpsucontrolseg
                  SET cautrec = p_accio,
                      cusuaur = f_user,
                      fautrec = f_sysdate,
                      observ = DECODE(p_modo,
                                      4, NVL(observ, p_observ),
                                      5, NVL(observ, p_observ),
                                      p_observ),
                      cnivelu = p_cnivelu,
                      nvalortope = p_nvalortope,
                      autmanual = 'M',
                      establoquea = v_establoquea,
                      risknum = p_numriesgo
                WHERE sseguro = p_sseguro
                  AND(p_nriesgo IS NULL
                      OR nriesgo = p_nriesgo)
                  AND ccontrol = p_ccontrol
                  AND nmovimi = p_nmovimi
                  AND cgarant = NVL(p_cgarant, cgarant)
                  AND nocurre = p_nocurre;

                 /*   UPDATE estpsu_retenidas
                     SET cnivelbpm = pac_psu.f_nivel_bpm('EST', p_sseguro)
                   WHERE sseguro = p_sseguro
                     AND nmovimi = p_nmovimi;
                 IF p_accio = 1 THEN
                      UPDATE estpsu_retenidas
                         SET cmotret = 2
                       WHERE sseguro = p_sseguro
                         AND nmovimi = p_nmovimi;
                   ELSIF p_accio = 2 THEN
                      UPDATE estpsu_retenidas
                         SET cmotret = 4
                       WHERE sseguro = p_sseguro
                         AND nmovimi = p_nmovimi;
                   END IF;*/--miramos si hay algun control no autorizado retenemos la póliza,
                            --en caso contrario la desretenemos
                           /* SELECT COUNT(*)
                              INTO v_cont
                              FROM estpsucontrolseg
                             WHERE sseguro = p_sseguro
                               AND nmovimi = p_nmovimi
                               AND cautrec <> 1;

                --parámetros - p_sseguro: 191930, p_nriesgo: 1, p_cgarant: 1 ,p_ccontrol: 510001, p_tobserv: OK!!!
                            IF v_cont > 0 THEN
                               UPDATE estseguros
                                  SET creteni = 5
                                WHERE sseguro = p_sseguro;
                            ELSE
                               UPDATE estseguros
                                  SET creteni = 0
                                WHERE sseguro = p_sseguro;
                            END IF;*/
                         --
               -- v_nmovimi := NVL(v_nmovimi, 0) + 1;
               SELECT COUNT(1)
                 INTO v_total
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND nocurre = NVL(p_nocurre, 1);

               SELECT COUNT(1)
                 INTO v_autorizados
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND cautrec = 1
                  AND nocurre = NVL(p_nocurre, 1);

               IF v_total = v_autorizados THEN
                  /*  v_error := pac_psu.f_grabar_retenidas('EST', p_sseguro, f_user, f_sysdate,
                                                          f_user, f_sysdate, '', 1);*/
                  UPDATE estpsu_retenidas
                     SET cnivelbpm = pac_psu.f_nivel_bpm('EST', p_sseguro),
                         cmotret = 2
                   WHERE sseguro = p_sseguro
                     AND nmovimi = p_nmovimi;
               END IF;
            END IF;
         ELSE
            IF NVL(p_accio, 0) IN(0, 1, 2) THEN
               --BUG 27262/160330 - 10/12/2013 - RCL: Si p_modo esta informat amb 4 (Autorizar todo) o 5 (Rechazar todo),
               --   deixem el observ amb el valor que tenia, sempre que aquest no sigui null.
               --   Si observ es null o p_modo es null (vol dir que accedim a aquesta funció, autoritzant/rebutjant un control o masivament)
               --   sempre es posa la observació introduida en el pop-up
               UPDATE psucontrolseg
                  SET cautrec = p_accio,
                      cusuaur = f_user,
                      fautrec = f_sysdate,
                      observ = DECODE(p_modo,
                                      4, NVL(observ, p_observ),
                                      5, NVL(observ, p_observ),
                                      p_observ),
                      cnivelu = p_cnivelu,
                      nvalortope = p_nvalortope,
                      autmanual = 'M',
                      establoquea = v_establoquea,
                      risknum = p_numriesgo
                WHERE sseguro = p_sseguro
                  AND(p_nriesgo IS NULL
                      OR nriesgo = p_nriesgo)
                  AND ccontrol = p_ccontrol
                  AND nmovimi = p_nmovimi
                  AND cgarant = NVL(p_cgarant, cgarant)
                  AND nocurre = p_nocurre;

                --miramos si hay algun control no autorizado retenemos la póliza,
                   --en caso contrario la desretenemos
               /* SELECT COUNT(*)
                  INTO v_cont
                  FROM psucontrolseg
                 WHERE sseguro = p_sseguro
                   AND nmovimi = p_nmovimi
                   AND cautrec <> 1;

                IF v_cont > 0 THEN
                   UPDATE seguros
                      SET creteni = 5
                    WHERE sseguro = p_sseguro;
                ELSE
                   UPDATE seguros
                      SET creteni = 0
                    WHERE sseguro = p_sseguro;
                END IF;*/
               SELECT COUNT(1)
                 INTO v_total
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND nocurre = NVL(p_nocurre, 1);

               SELECT COUNT(1)
                 INTO v_autorizados
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND cautrec = 1
                  AND nocurre = NVL(p_nocurre, 1);

               IF v_total = v_autorizados THEN
                  /*  v_error := pac_psu.f_grabar_retenidas('EST', p_sseguro, f_user, f_sysdate,
                                                          f_user, f_sysdate, '', 1);*/
                  UPDATE psu_retenidas
                     SET cnivelbpm = pac_psu.f_nivel_bpm('POL', p_sseguro),
                         cmotret = 2   --penduiente autorizar para poder emitir
                   WHERE sseguro = p_sseguro
                     AND nmovimi = p_nmovimi;
               END IF;
            /* v_error := pac_psu.f_grabar_retenidas('POL', p_sseguro, f_user, f_sysdate,
                                                   f_user, f_sysdate, '', 1);

                                                   */
            END IF;
         END IF;
      ELSE
         IF p_tablas = 'EST' THEN
            vautmanual := 0;

            FOR i IN (SELECT *
                        FROM estpsucontrolseg
                       WHERE sseguro = p_sseguro
                         AND(p_nriesgo IS NULL
                             OR nriesgo = p_nriesgo)
                         AND nmovimi = (SELECT MAX(nmovimi)
                                          FROM estpsucontrolseg
                                         WHERE sseguro = p_sseguro)   --p_nmovimi
                         AND cgarant = NVL(p_cgarant, cgarant)
                         AND nocurre = (SELECT MAX(nocurre)
                                          FROM estpsucontrolseg
                                         WHERE sseguro = p_sseguro
                                           AND(p_nriesgo IS NULL
                                               OR nriesgo = p_nriesgo)
                                           AND nmovimi = (SELECT MAX(nmovimi)
                                                            FROM estpsucontrolseg
                                                           WHERE sseguro = p_sseguro)   --p_nmovimi
                                           AND cgarant = NVL(p_cgarant, cgarant))) LOOP
               IF i.autmanual = 'M'
                  AND i.cautrec = 0 THEN
                  vautmanual := vautmanual + 1;
               END IF;

               IF i.cnivelr > p_cnivelu THEN
                  RETURN 109905;
               END IF;
            END LOOP;

            IF p_accio = 1 THEN
               vobserv := f_axis_literales(9902810, pcidioma);
            ELSIF p_accio = 2 THEN
               vobserv := f_axis_literales(9902809, pcidioma);
            END IF;

            UPDATE estpsucontrolseg
               SET observ = DECODE(cautrec, 1, observ, vobserv),
                   cautrec = p_accio,
                   cusuaur = f_user,
                   fautrec = f_sysdate,
                   cnivelu = p_cnivelu,
                   autmanual = 'A',
                   risknum = p_numriesgo
             WHERE sseguro = p_sseguro
               AND(p_nriesgo IS NULL
                   OR nriesgo = p_nriesgo)
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estpsucontrolseg
                               WHERE sseguro = p_sseguro)   --p_nmovimi
               AND cgarant = NVL(p_cgarant, cgarant)
               AND nocurre = (SELECT MAX(nocurre)
                                FROM estpsucontrolseg pp
                               WHERE pp.sseguro = p_sseguro
                                 AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                     FROM estpsucontrolseg
                                                    WHERE sseguro = p_sseguro))
               AND(estpsucontrolseg.cautrec <> 0
                   OR(estpsucontrolseg.ccontrol IN(
                         SELECT psu_controlpro.ccontrol
                           FROM psu_controlpro
                          WHERE psu_controlpro.ccontrol = estpsucontrolseg.ccontrol
                            AND NVL(psu_controlpro.cgarant, 0) =
                                                               NVL(estpsucontrolseg.cgarant, 0)
                            AND psu_controlpro.autmanual != 'M'
                            AND psu_controlpro.sproduc = (SELECT seguros.sproduc
                                                            FROM seguros
                                                           WHERE seguros.sseguro = p_sseguro))
                      AND estpsucontrolseg.cautrec = 0));

            /*  IF vautmanual > 0 THEN
                 COMMIT;
                 RETURN 9901030;
              END IF;*/

            --AND nocurre = p_nocurre;
            IF p_accio = 2 THEN
               v_cmotret := 4;
            ELSIF p_accio = 1 THEN
               v_cmotret := 2;
            END IF;

            UPDATE estpsu_retenidas
               SET cmotret = v_cmotret,
                   cusuaut = f_user,
                   ffecaut = f_sysdate,
                   cnivelbpm = pac_psu.f_nivel_bpm('EST', p_sseguro)
             WHERE sseguro = p_sseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM estpsucontrolseg
                               WHERE sseguro = p_sseguro);   --p_nmovimi--p_nmovimi;
         ELSE
            IF p_nmovimi IS NULL THEN
               SELECT MAX(nmovimi)
                 INTO v_nmovimi
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro;
            END IF;

            vautmanual := 0;

            FOR i IN (SELECT *
                        FROM psucontrolseg
                       WHERE sseguro = p_sseguro
                         AND(p_nriesgo IS NULL
                             OR nriesgo = p_nriesgo)
                         AND nmovimi = v_nmovimi
                         AND cgarant = NVL(p_cgarant, cgarant)
                         AND nocurre = (SELECT MAX(nocurre)
                                          FROM psucontrolseg
                                         WHERE sseguro = p_sseguro
                                           AND(p_nriesgo IS NULL
                                               OR nriesgo = p_nriesgo)
                                           AND nmovimi = v_nmovimi
                                           AND cgarant = NVL(p_cgarant, cgarant))) LOOP
               IF i.autmanual = 'M'
                  AND i.cautrec = 0 THEN
                  vautmanual := vautmanual + 1;
               END IF;

               IF i.cnivelr > p_cnivelu THEN
                  RETURN 109905;
               END IF;
            END LOOP;

            IF p_accio = 1 THEN
               vobserv := f_axis_literales(9902810, pcidioma);
            ELSIF p_accio = 2 THEN
               vobserv := f_axis_literales(9902809, pcidioma);
            END IF;

            UPDATE psucontrolseg
               SET observ = DECODE(cautrec, 1, observ, vobserv),
                   cautrec = p_accio,
                   cusuaur = f_user,
                   fautrec = f_sysdate,
                   cnivelu = p_cnivelu,
                   autmanual = 'A',
                   risknum = p_numriesgo
             WHERE sseguro = p_sseguro
               AND(p_nriesgo IS NULL
                   OR nriesgo = p_nriesgo)
               AND nmovimi = v_nmovimi
               AND cgarant = NVL(p_cgarant, cgarant)
               AND nocurre = (SELECT MAX(nocurre)
                                FROM psucontrolseg pp
                               WHERE pp.sseguro = p_sseguro
                                 AND pp.nmovimi = v_nmovimi)
               AND(psucontrolseg.cautrec <> 0
                   OR(psucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                                  FROM psu_controlpro
                                                 WHERE psu_controlpro.ccontrol =
                                                                         psucontrolseg.ccontrol
                                                   AND NVL(psu_controlpro.cgarant, 0) =
                                                                  NVL(psucontrolseg.cgarant, 0)
                                                   AND psu_controlpro.autmanual != 'M'
                                                   AND psu_controlpro.sproduc =
                                                            (SELECT seguros.sproduc
                                                               FROM seguros
                                                              WHERE seguros.sseguro = p_sseguro))
                      AND psucontrolseg.cautrec = 0));   --p_nmovimi);

            -- AND autmanual != 'M';
            /*IF vautmanual > 0 THEN
               COMMIT;
               RETURN 9901030;
            END IF;*/
            IF p_accio = 2 THEN
               v_cmotret := 4;
            ELSIF p_accio = 1 THEN
               v_cmotret := 2;
            END IF;

            UPDATE psu_retenidas
               SET cmotret = v_cmotret,
                   cusuaut = f_user,
                   ffecaut = f_sysdate,
                   cnivelbpm = pac_psu.f_nivel_bpm('POL', p_sseguro)
             WHERE sseguro = p_sseguro
               AND nmovimi = v_nmovimi;
         --AND nocurre = p_nocurre;
         END IF;
      --  END LOOP;
      END IF;

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.f_actualiza = ' || p_sseguro || ' CCONTROL = ' || p_ccontrol,
                     '** Codi Error = ' || SQLERRM);
         --
         RETURN 9001805;
   --
   END f_actualiza;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna el nivell d'autorització, que determina els usuaris que
    poden autoritzar o rebutjar la proposta/pólissa.

    Té en compte el tema dels controls bloquejants i el seu ordre.

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS

    Devuelve:     : Nivel que tienen que tener los usarios que quieran
                    interactura con la propuesta/póliza con referencia a
                    la autorización o rechazo de los controles.
                    El mínimo nivel para los BLOQUEANTES y el máximo de
                    los ESTANDARS caso de no existir bloqueantes.

   ***************************************************************************/
   FUNCTION f_nivel_bpm(p_tablas IN VARCHAR, p_sseguro IN NUMBER)
      RETURN NUMBER IS
      --
      v_nivel_bpm    psucontrolseg.cnivelr%TYPE := 0;

      --
      CURSOR c_estpsu IS
         SELECT   DECODE(a.establoquea, 'B', 0, 1), a.ordenbloquea, a.cnivelr
             FROM estpsucontrolseg a
            WHERE a.sseguro = p_sseguro
              AND a.nmovimi = (SELECT MAX(b.nmovimi)   -- Para el màximo movimiento
                                 FROM estpsucontrolseg b
                                WHERE b.sseguro = p_sseguro)
              --AND a.cautrec = 0   -- Los controles pendientes
              AND nocurre = (SELECT MAX(b.nocurre)   -- Para el màximo nocurre
                               FROM estpsucontrolseg b
                              WHERE b.sseguro = p_sseguro
                                AND nmovimi = a.nmovimi)
         --AND a.csubsti = 0  -- Los controles que no hayan sido substituidos
         ORDER BY 1, 2, 3 DESC;

      --
      CURSOR c_segpsu IS
         SELECT   DECODE(a.establoquea, 'B', 0, 1), a.ordenbloquea, a.cnivelr
             FROM psucontrolseg a
            WHERE a.sseguro = p_sseguro
              AND a.nmovimi = (SELECT MAX(b.nmovimi)   -- Para el màximo movimiento
                                 FROM psucontrolseg b
                                WHERE b.sseguro = p_sseguro)
              AND nocurre = (SELECT MAX(b.nocurre)   -- Para el màximo nocurre
                               FROM psucontrolseg b
                              WHERE b.sseguro = p_sseguro
                                AND nmovimi = a.nmovimi)
              AND a.cautrec = 0   -- Los controles pendientes
         --AND a.csubsti = 0  -- Los controles que no hayan sido substituidos
         ORDER BY 1, 2, 3 DESC;
   --
   BEGIN
      --
      IF p_tablas = 'EST' THEN
         FOR regest IN c_estpsu LOOP
            v_nivel_bpm := regest.cnivelr;
            EXIT;
         END LOOP;   -- De FOR regest IN c_estpsu
      --
      ELSE
         --
         FOR regseg IN c_segpsu LOOP
            v_nivel_bpm := regseg.cnivelr;
            EXIT;
         END LOOP;   -- De FOR regest IN c_estpsu
      --
      END IF;

      --
      RETURN v_nivel_bpm;
   --
   END f_nivel_bpm;

   /***************************************************************************
    Funció que llegix la capçalera dels controls d'una pòlissa retornan
    un sys_refcursor

    param in      : P_TABLAS   Determina tablas EST o SEG
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NMOVIMI  Número de Movimiento
                    (Si el número de movimiento es nulo, devolverá todos los
                     controles del último movimiento en que exista un control,
                     de lo contrario, sólo devolverá los controles del movimiento
                     en particular).
    param in      : P_CIDIOMA  Código del idioma

    Devuelve      Literal a mostrar en la cabecera.
                  Nivel requerido global (NIVEL_BPM)

   ***************************************************************************/
   FUNCTION f_lee_retenidas(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor IS
      --
      v_select       VARCHAR2(1000);
      v_from         VARCHAR2(1000);
      v_where        VARCHAR2(1000);
      v_order        VARCHAR2(1000);
      v_cursor       sys_refcursor;
   --
   BEGIN
      --
      NULL;
   --
   END f_lee_retenidas;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que llegix tots els controls d'una pòlissa retornan un sys_refcursor

    param in      : P_TABLAS   Determina tablas EST o SEG
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
                    (Si el número de riesgo es nulo, devolverá todos los
                     controles de todos los riesgos, de lo contrario, sólo
                     devolverá los controles del riesgo en particular).
    param in      : P_NMOVIMI  Número de Movimiento
                    (Si el número de movimiento es nulo, devolverá todos los
                     controles del último movimiento en que exista un control,
                     de lo contrario, sólo devolverá los controles del movimiento
                     en particular).
    param in      : CUSUARI    Usuario autorizador
    param in      : CIDIOMA    Código del idioma

    Devuelve      SYS_REFCURSOR Lista de los controles.

   ***************************************************************************/
   FUNCTION f_lee_controles(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cusuari IN VARCHAR2,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor IS
      --
      v_select       VARCHAR2(1000);
      v_from         VARCHAR2(1000);
      v_where        VARCHAR2(1000);
      v_order        VARCHAR2(1000);
      v_cursor       sys_refcursor;
   --
   BEGIN
      --
      v_select := 'SELECT a.sseguro, a.npoliza, e.observ, e.cusuaur, e.nriesgo'
                  || ', d.tapelli' || CHR(39) || ' ' || CHR(39) || 'd.tnombre tomador'
                  || ', e.ccontrol, pac_psu.f_tccontrol(e.ccontrol, ' || p_cidioma || ', '
                  || p_sseguro || ', ' || p_nmovimi || ', ' || NVL(p_nriesgo, 1) || ', '''
                  || p_tablas || ''', e.cgarant )'
                  || ' tccontrol, e.cgarant, pac_psu.f_tcgarant(e.cgarant,' || p_cidioma
                  || ') tcgarant'
                  || ', e.cautrec, pac_psu.f_tcautrec(e.ccontrol,a.sproduc,e.cautrec,'
                  || p_cidioma || ',e.cgarant)' || ' tcautrec, e.fautrec'
                  || ' pac_psu.f_descrisc(' || p_tablas || ',' || p_sseguro || ','
                  || 'e.nriesgo,' || p_cidioma || ') trisc'
                  || ', case when (e.cnivelr > pac_psu.f_nivel_usuari_psu(' || p_cusuari
                  || ',  a.sproduc)) then 0 else 1 end editar';

      --
      IF p_tablas = 'EST' THEN
         v_from := ' FROM estseguros a, esttomadores b, estpersonas d, estpsucontrolseg e ';
      ELSE
         v_from := ' FROM seguros a, tomadores b, personas d, psucontrolseg e ';
      END IF;

      --
      IF p_tablas = 'EST' THEN
         v_where := ' WHERE a.sseguro = ' || p_sseguro
                    || ' AND ((p_nmovimi is NULL AND e.nmovimi ='
                    || ' (SELECT MAX(c.nmovimi) FROM estpsucontrolseg c'
                    || ' WHERE c.sseguro = ' || p_sseguro || ' AND (' || p_nriesgo
                    || ' IS NULL OR c.nriesgo = ' || p_nriesgo || '))) OR e.nmovimi = '
                    || p_nmovimi || ')' || ' AND (p_nriesgo IS NULL OR e.nriesgo = '
                    || p_nriesgo || ')'
                    || ' AND b.sseguro = a.sseguro and b.nordtom = (select min'
                    || '(c.nordtom) FROM esttomadores c where c.sseguro = a.sseguro)'
                    || ' AND d.sperson = b.sperson and e.sseguro = a.sseguro';
      ELSE
         v_where := ' WHERE a.sseguro = ' || p_sseguro
                    || ' AND ((p_nmovimi is NULL AND e.nmovimi ='
                    || ' (SELECT MAX(c.nmovimi) FROM psucontrolseg c' || ' WHERE c.sseguro = '
                    || p_sseguro || ' AND (' || p_nriesgo || ' IS NULL OR c.nriesgo = '
                    || p_nriesgo || '))) OR e.nmovimi = ' || p_nmovimi || ')'
                    || ' AND (p_nriesgo IS NULL OR e.nriesgo = ' || p_nriesgo || ')'
                    || ' AND b.sseguro = a.sseguro and b.nordtom = (select min'
                    || '(c.nordtom) FROM tomadores c where c.sseguro = a.sseguro)'
                    || ' AND d.sperson = b.sperson and e.sseguro = a.sseguro';
      END IF;

      --
      v_order := 'ORDER BY a.sseguro desc, NVL(e.nriesgo,0), NVL(e.cgarant,0);';

      --
      OPEN v_cursor FOR v_select || v_from || v_where || v_order;

      --
      RETURN v_cursor;
   --
   EXCEPTION
      WHEN OTHERS THEN
         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         p_tab_error(f_sysdate, f_user, 'f_lee_control', NULL, 'f_lee_control',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN NULL;
   --
   END f_lee_controles;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna totes les pòlisses que tenen controls segons els criteris
    que em passin per paràmetres.

    param in      : P_SPRODUC    Codi del Producte
    param in      : P_NSOLICI    Nombre de la sol.licitut
    param in      : P_NPOLIZA    Nombre de la pòlissa
    param in      : P_AUTREC     0 => Pendent
                                 1 => Autoritzat
                                 2 => Rebutjat
    param in      : P_CIDIOMA    Códi del idioma

    Devuelve      : SYS_REFCURSOR amb les pòlisses i els seus controls i amb
                    un indicador de si el usuari pot autoritzar cada control.
   ***************************************************************************/
   FUNCTION f_polizas_con_control(
      p_sproduc IN NUMBER,
      p_nsolici IN NUMBER,
      p_npoliza IN NUMBER,
      p_cautrec IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN sys_refcursor IS
      --
      v_select       VARCHAR2(1000);
      v_from         VARCHAR2(1000);
      v_where        VARCHAR2(1000);
      v_order        VARCHAR2(1000);
      v_cursor       sys_refcursor;
   --
   BEGIN
      --
      v_select := 'SELECT a.sseguro, a.npoliza, a.nsolici, a.fefecto, a.fcancel'
                  || ', pac_psu.f_tcsituac(a.csituac,' || p_cidioma || ') tcsituac, a.csituac'
                  || ', d.tapelli' || CHR(39) || ' ' || CHR(39)
                  || 'd.tnombre tomador, d.numide' || ', pac_psu.f_producte(a.sproduc,'
                  || p_cidioma || ') tsproduc';
      v_from := ' FROM seguros a, tomadores b, personas d, psucontrolseg e ';
      v_where := ' WHERE b.sseguro = a.sseguro and b.nordtom = (select min'
                 || '(c.nordtom) FROM tomadores c where c.sseguro = a.sseguro)'
                 || ' and d.sperson = b.sperson and e.sseguro = a.sseguro';

      IF p_sproduc IS NOT NULL THEN
         v_where := v_where || ' AND a.sproduc = ' || p_sproduc;
      END IF;

      --
      IF p_nsolici IS NOT NULL THEN
         v_where := v_where || ' AND a.nsolici = ' || p_nsolici;
      END IF;

      --
      IF p_npoliza IS NOT NULL THEN
         v_where := v_where || ' AND a.npoliza = ' || p_npoliza;
      END IF;

      --
      IF p_cautrec IS NOT NULL THEN
         v_where := v_where || ' AND e.cautrec = ' || p_cautrec;
      END IF;

      --
      v_order := 'order by a.npoliza desc;';

      --
      OPEN v_cursor FOR v_select || v_from || v_where || v_order;

      --
      RETURN v_cursor;
   --
   EXCEPTION
      WHEN OTHERS THEN
         IF v_cursor%ISOPEN THEN
            CLOSE v_cursor;
         END IF;

         p_tab_error(f_sysdate, f_user, 'f_polizas_con_control', NULL, 'f_poliza_con_control',
                     'exception when others ** Codi Error = ' || SQLERRM);
         --
         RETURN v_cursor;
   --
   END f_polizas_con_control;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la situació de les pòlisses (CSITUAC - DETVALORES = 61)

    param in      : P_CSITUAC    Codi de CSITUAC de SEGUROS
    param in      : P_CIDIOMA    Codi del Idioma

    Devuelve      : Descripció de la situació de la pòlissa
   ****************************************************************************/
   FUNCTION f_tcsituac(p_csituac IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     detvalores.tatribu%TYPE;
   --
   BEGIN
      --
      SELECT tatribu
        INTO v_resultat
        FROM detvalores
       WHERE cvalor = 61
         AND catribu = p_csituac
         AND cidioma = p_cidioma;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tcsituac', NULL, 'f_tcsituac',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tcsituac;

   /***************************************************************************
    Funció que torna la descripció del resultat dels CONTROLS (CCONTROL -
    DESCONTROL_PSU)

    param in :  p_ccontrol   Codi del control
    param in :  p_cidioma    Codi del idioma
    param in :  p_sseguro    Codi del seguro
    param in :  p_nmovimi    numero de movimiento
    param in :  p_nriesgo    numero de riesgo
    param in :  p_tablas     Clasificacion de tablas EST y reales
    Devuelve      : Descripció del control
   ****************************************************************************/
   FUNCTION f_tccontrol(
      p_ccontrol IN NUMBER,
      p_cidioma IN NUMBER,
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_tablas IN VARCHAR2 DEFAULT 'EST',
      p_cgarant IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     psu_descontrol.tcontrol%TYPE;
      v_sproduc      productos.sproduc%TYPE;
      v_cempres      empresas.cempres%TYPE;
      v_pusext       NUMBER;
      v_number       NUMBER;
      v_replace      VARCHAR2(50);
      v_caseid       NUMBER;
      v_existe_action NUMBER;
      v_action       VARCHAR2(2000);
      v_traza        NUMBER := 0;
      v_params       VARCHAR2(2000);
   --
   BEGIN
      --
      v_params := '[IN] - p_ccontrol: ' || p_ccontrol || ' p_cidioma: ' || p_cidioma
                  || ' p_sseguro: ' || p_sseguro || ' p_nmovimi: ' || p_nmovimi
                  || ' p_nriesgo: ' || p_nriesgo || ' p_tablas: ' || p_tablas;

      SELECT tcontrol
        INTO v_resultat
        FROM psu_descontrol
       WHERE ccontrol = p_ccontrol
         AND cidioma = p_cidioma;

      v_traza := 1;

      IF p_tablas = 'EST' THEN
         v_traza := 2;

         SELECT sproduc, cempres
           INTO v_sproduc, v_cempres
           FROM estseguros
          WHERE sseguro = p_sseguro;
      ELSE
         v_traza := 3;

         SELECT sproduc, cempres
           INTO v_sproduc, v_cempres
           FROM seguros
          WHERE sseguro = p_sseguro;
      END IF;

      v_traza := 4;

      SELECT NVL(psuext, 0)
        INTO v_pusext
        FROM psu_controlpro
       WHERE ccontrol = p_ccontrol
         AND sproduc = v_sproduc
         AND cgarant = p_cgarant;

      v_traza := 5;

      IF v_pusext = 1 THEN
         v_traza := 6;
         v_number := SUBSTR(v_resultat, INSTR(v_resultat, '#') + 1);
         v_replace := SUBSTR(v_resultat, INSTR(v_resultat, '#'));

         IF p_tablas = 'EST' THEN
            v_traza := 7;

            SELECT rio.sorden
              INTO v_caseid
              FROM estseguros estseg, estriesgos_ir rir, estriesgos_ir_ordenes rio
             WHERE estseg.sseguro = p_sseguro
               AND estseg.sseguro = rio.sseguro
               AND rir.sseguro = estseg.sseguro
               AND rir.nmovimi = p_nmovimi
               AND rir.nriesgo = p_nriesgo
               AND rir.nmovimi = rio.nmovimi
               AND estseg.cempres = v_cempres
               AND rio.cempres = estseg.cempres
               AND rir.nriesgo = rio.nriesgo;
         ELSE
            v_traza := 8;

            SELECT rio.sorden
              INTO v_caseid
              FROM seguros estseg, riesgos_ir rir, riesgos_ir_ordenes rio
             WHERE estseg.sseguro = p_sseguro
               AND estseg.sseguro = rio.sseguro
               AND rir.sseguro = estseg.sseguro
               AND rir.nmovimi = p_nmovimi
               AND rir.nriesgo = p_nriesgo
               AND rir.nmovimi = rio.nmovimi
               AND estseg.cempres = v_cempres
               AND rio.cempres = estseg.cempres
               AND rir.nriesgo = rio.nriesgo;
         END IF;

         v_traza := 9;

         -- Luego vamos a mirar si existe la acción
         IF p_tablas = 'EST' THEN
            v_traza := 10;

            SELECT COUNT(1)
              INTO v_existe_action
              FROM estactions_undw
             WHERE sseguro = p_sseguro
               AND nmovimi = p_nmovimi
               AND nriesgo = p_nriesgo
               AND cempres = v_cempres
               AND sorden = v_caseid
               AND norden = v_number;
         ELSE
            v_traza := 11;

            SELECT COUNT(1)
              INTO v_existe_action
              FROM actions_undw
             WHERE sseguro = p_sseguro
               AND nmovimi = p_nmovimi
               AND nriesgo = p_nriesgo
               AND cempres = v_cempres
               AND sorden = v_caseid
               AND norden = v_number;
         END IF;

         v_traza := 12;

         IF v_existe_action = 1 THEN
            v_traza := 13;

            IF p_tablas = 'EST' THEN
               v_traza := 14;

               SELECT action
                 INTO v_action
                 FROM estactions_undw
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND nriesgo = p_nriesgo
                  AND cempres = v_cempres
                  AND sorden = v_caseid
                  AND norden = v_number;
            ELSE
               v_traza := 15;

               SELECT action
                 INTO v_action
                 FROM actions_undw
                WHERE sseguro = p_sseguro
                  AND nmovimi = p_nmovimi
                  AND nriesgo = p_nriesgo
                  AND cempres = v_cempres
                  AND sorden = v_caseid
                  AND norden = v_number;
            END IF;

            v_traza := 16;
            v_resultat := REPLACE(v_resultat, v_replace, v_action);
            v_traza := 17;
         END IF;
      END IF;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU.f_tccontrol', NULL, 'PAC_PSU.f_tccontrol',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tccontrol;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció dels CONTROLS(CCONTROL-PSU_DESRESULTADO)

    param in :  p_ccontrol   Codi del control
    param in :  p_sproduc    Codi del productre
    param in :  p_cnivel     Codi del nivell necesario
    param in :  p_cidioma    Codi del idioma

    Devuelve      : Descripció del control
   ****************************************************************************/
   FUNCTION f_tdesresultado(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cnivel IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     psu_desresultado.tdesniv%TYPE;
   --
   BEGIN
      --
      SELECT tdesniv
        INTO v_resultat
        FROM psu_desresultado
       WHERE ccontrol = p_ccontrol
         AND sproduc = p_sproduc
         AND cnivel = (SELECT MIN(cnivel)
                         FROM psu_desresultado
                        WHERE ccontrol = p_ccontrol
                          AND sproduc = p_sproduc
                          AND cnivel >= p_cnivel)
         AND cidioma = p_cidioma;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tdesresultado', NULL, 'f_tdesresultado',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tdesresultado;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna l'estat dels CONTROLS (CAUTREC - DETVALORES = 1001)

    param in      : P_CCONTROL   Codi de CAUTREC de CONTROLSEG
    param in      : P_CIDIOMA    Codi del Idioma

    Devuelve      : Descripció del codi de estat del control.
   ****************************************************************************/
   FUNCTION f_tcautrec(
      p_ccontrol IN NUMBER,
      p_sproduc IN NUMBER,
      p_cautrec IN NUMBER,
      p_cidioma IN NUMBER,
      p_cgarant IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     detvalores.tatribu%TYPE;
      v_autmanual    VARCHAR2(5);
   --
   BEGIN
      --
      SELECT tatribu
        INTO v_resultat
        FROM detvalores
       WHERE cvalor = 445
         AND catribu = p_cautrec
         AND cidioma = p_cidioma;

      SELECT ' (' || autmanual || ')'
        INTO v_autmanual
        FROM psu_controlpro
       WHERE ccontrol = p_ccontrol
         AND sproduc = p_sproduc
         AND NVL(cgarant, 0) = NVL(p_cgarant, 0);

      --
      RETURN v_resultat || v_autmanual;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tcautrec', NULL, 'f_tcautrec',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tcautrec;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció dels NIVELLS (CNIVEL - DESNIVEL_PSU)

    param in      : P_CNIVEL    Codi de CNIVEL de usuario o de control
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tcnivel(p_cnivel IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     psu_desnivel.tnivel%TYPE;
   --
   BEGIN
      --
      SELECT tnivel
        INTO v_resultat
        FROM psu_desnivel
       WHERE cnivel = p_cnivel
         AND cidioma = p_cidioma;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tcnivel', NULL, 'f_tcnivel',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tcnivel;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció del PRODUCTE

    param in      : P_SPRODUC   Codi del Producte
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tproducte(p_sproduc IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     titulopro.ttitulo%TYPE;
   --
   BEGIN
      --
      SELECT ttitulo
        INTO v_resultat
        FROM titulopro a, productos b
       WHERE a.ctipseg = b.ctipseg
         AND a.cramo = b.cramo
         AND a.cmodali = b.cmodali
         AND a.ccolect = b.ccolect
         AND a.cidioma = p_cidioma
         AND b.sproduc = p_sproduc;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tproducte', NULL, 'f_tproducte',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tproducte;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que torna la descripció de la garantía

    param in      : P_CGARANT   Codi de la Garantía
    param in      : P_CIDIOMA   Codi del Idioma

    Devuelve      : Descripció del nivell
   ****************************************************************************/
   FUNCTION f_tcgarant(p_cgarant IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultado    garangen.tgarant%TYPE;
   BEGIN
      --
      IF p_cgarant IS NULL THEN
         v_resultado := ' ';
      ELSE
         --
         BEGIN
            --
            SELECT tgarant
              INTO v_resultado
              FROM garangen
             WHERE cgarant = p_cgarant
               AND cidioma = p_cidioma;
         EXCEPTION
            WHEN OTHERS THEN
               v_resultado := '';
         --
         END;
      --
      END IF;

      RETURN v_resultado;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_tcgarant', NULL, 'f_tcgarant',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_tcgarant;

----------------------------------------------------------------------------

   /***************************************************************************
    Función que devuelve la descripción del riesgo.

    param in      : P_TABLAS   EST o SEGUROS
    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : C_IDIOMA   Código de Idioma

    Devuelve la descripción del riesgo.
                  ' pac_psu.f_descrisc('||p_sseguro||','||p_nriesgo
                                                   ||','||p_cidioma||') trisc'       ||
   ***************************************************************************/
   FUNCTION f_descrisc(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_error        NUMBER(10);
      v_desc1        VARCHAR2(100);
      v_desc2        VARCHAR2(100);
      v_desc3        VARCHAR2(100);
      v_resultado    VARCHAR2(300);
      v_cobjase      seguros.cobjase%TYPE;
   --
   BEGIN
      --
      IF p_tablas = 'EST' THEN
         --
         BEGIN
            SELECT cobjase
              INTO v_cobjase
              FROM estseguros
             WHERE sseguro = p_sseguro;
         EXCEPTION
            WHEN OTHERS THEN
               v_cobjase := 0;
         END;

         --
         v_error := f_estdesriesgo1(p_sseguro, p_nriesgo, v_cobjase, v_resultado, 100);
      ELSE
         v_error := f_desriesgo(p_sseguro, p_nriesgo, NULL, p_cidioma, v_desc1, v_desc2,
                                v_desc3);
      END IF;

      --
      IF v_error != 0 THEN
         v_resultado := '';
      ELSE
         v_resultado := v_desc1 || v_desc2 || v_desc3;
      END IF;

      --
      RETURN v_resultado;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_descrisc', NULL, 'f_descrisc',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_descrisc;

----------------------------------------------------------------------------

   /***************************************************************************
    Funció que actualitza les observacions del control

    param in      : P_SSEGURO  Número identificativo interno de SEGUROS
    param in      : P_NRIESGO  Número de riesgo
    param in      : P_CGARANT  Codi de la garantia.
    param in      : P_CCONTROL Código del CONTROL
    param in      : P_OBSERV   Observaciones que se grabarán en PSU_ESTCONTROLSEG

    Devuelve:     : 0 = O.K.
   ***************************************************************************/
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_observ IN VARCHAR2)
      RETURN NUMBER IS
   --
   BEGIN
      --
      UPDATE psucontrolseg
         SET observ = p_observ
       WHERE sseguro = p_sseguro
         AND(p_nriesgo IS NULL
             OR nriesgo = p_nriesgo)
         AND ccontrol = p_ccontrol
         AND NVL(cgarant, 0) = NVL(p_cgarant, 0);

      --
      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.F_GRABAOBSERVACIONES = ' || p_sseguro || ' CCONTROL = '
                     || p_ccontrol,
                     '** Codi Error = ' || SQLERRM);
         --
         RETURN 9001805;
   --
   END f_grabaobservaciones;

----------------------------------------------------------------------------

   /***************************************************************************
    Función para el período de pruebas.
    Se llama desde una fórmula. En concreto de la 500002 asociada a la garantía
    5103 (28-05-2009).

    param in      : PSESION   Sesión que estamos ejecutando
    param in      : SSEGURO  Número identificativo interno de SEGUROS
    param in      : ORIGEN      0 => Tablas SOL; 1 => Tabla EST; 2 => SEG
    param in      : CCONTROLPSU Código del CONTROL que estamos ejecutando.

    DEVUELVE      : Resultado de la fórmula

   ***************************************************************************/
   FUNCTION f_prova(psession IN NUMBER, sseguro IN NUMBER, origen IN NUMBER, ccontrolpsu NUMBER)
      RETURN NUMBER IS
   --
   BEGIN
      --
      RETURN 2 * ccontrolpsu;
   --
   END f_prova;

----------------------------------------------------------------------------

   /***************************************************************************
      Funció que torna la descripció del resultat dels CONTROLS (CCONTROL -
      DESCONTROL_PSU)

      param in :  p_ccontrol   Codi del control
      param in :  p_cidioma    Codi del idioma

      Devuelve      : Descripció del control
     ****************************************************************************/
   FUNCTION f_detcontrol(
      p_ccontrol IN NUMBER,
      psproduc IN NUMBER,
      pcnivel IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2 IS
      --
      v_resultat     psu_desresultado.tdesniv%TYPE;
   --
   BEGIN
      --
      SELECT tdesniv
        INTO v_resultat
        FROM psu_desresultado
       WHERE ccontrol = p_ccontrol
         AND cidioma = p_cidioma
         AND sproduc = psproduc
         AND cnivel = pcnivel;

      --
      RETURN v_resultat;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_detcontrol ' || p_ccontrol, NULL, 'f_detcontrol',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN '';
   --
   END f_detcontrol;

   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_idioma IN idiomas.cidioma%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_vquery OUT VARCHAR2,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2)
      RETURN NUMBER IS
      --
      v_select       VARCHAR2(1000);
      v_from         VARCHAR2(1000);
      v_where        VARCHAR2(1000);
      v_order        VARCHAR2(1000);
      v_nerror       NUMBER;
      --
      vhaytomador    NUMBER;
      w_cautrec      NUMBER;
      w_cmotret      NUMBER;
      w_cnivelbpm    NUMBER;
      w_total        NUMBER;
      w_nmovimi      NUMBER := NULL;
      v_niv_compl_ok NUMBER;   -- BUG 33346/0193174 - FAL - 5/1/2015
   --
   BEGIN
      IF p_sseguro IS NULL THEN
         RETURN(9000505);   -- Faltan parametros
      ELSIF p_idioma IS NULL THEN
         RETURN(9000505);   -- Faltan parametros
      END IF;

      IF p_tablas = 'EST' THEN
         SELECT COUNT(*)
           INTO w_total
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro;

         IF w_total > 0 THEN
            IF w_nmovimi IS NULL THEN
               SELECT MAX(nmovimi)
                 INTO w_nmovimi
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro;
            END IF;

            SELECT COUNT(*)
              INTO w_total
              FROM estpsucontrolseg
             WHERE sseguro = p_sseguro
               AND nmovimi = w_nmovimi
               AND nocurre = (SELECT MAX(nocurre)
                                FROM estpsucontrolseg
                               WHERE sseguro = p_sseguro
                                 AND nmovimi = w_nmovimi);

            SELECT COUNT(*)
              INTO w_cautrec
              FROM estpsucontrolseg
             WHERE sseguro = p_sseguro
               AND nmovimi = w_nmovimi
               AND nocurre = (SELECT MAX(nocurre)
                                FROM estpsucontrolseg
                               WHERE sseguro = p_sseguro
                                 AND nmovimi = w_nmovimi)
               AND cautrec = 3;

            SELECT cmotret, cnivelbpm
              INTO w_cmotret, w_cnivelbpm
              FROM estpsu_retenidas
             WHERE sseguro = p_sseguro
               AND nmovimi = w_nmovimi;

            IF w_total = w_cautrec
               OR w_total = 0 THEN
               --Póliza sin controles. Ningún registro o cautrec = 3
               p_testpol := f_axis_literales(9902672, p_idioma);
               p_cestpol := 0;
               p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
               p_cnivelbpm := w_cnivelbpm;
            ELSE
               SELECT COUNT(*)
                 INTO w_cautrec
                 FROM estpsucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = w_nmovimi
                  AND nocurre = (SELECT MAX(nocurre)
                                   FROM estpsucontrolseg
                                  WHERE sseguro = p_sseguro
                                    AND nmovimi = w_nmovimi)
                  AND cautrec = 1;

               IF w_total = w_cautrec THEN   --miramos si estan todos autorizdos
                  IF w_cmotret = 2 THEN
                     p_testpol := f_axis_literales(9902673, p_idioma);
                     p_cestpol := 2;
                     p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                     p_cnivelbpm := w_cnivelbpm;
                  ELSE
                     IF w_cmotret = 0 THEN
                        p_testpol := f_axis_literales(9902674, p_idioma);
                        p_cestpol := 3;
                        p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                        p_cnivelbpm := w_cnivelbpm;
                     END IF;
                  END IF;
               ELSE
                  SELECT COUNT(*)
                    INTO w_cautrec
                    FROM estpsucontrolseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = w_nmovimi
                     AND nocurre = (SELECT MAX(nocurre)
                                      FROM estpsucontrolseg
                                     WHERE sseguro = p_sseguro
                                       AND nmovimi = w_nmovimi)
                     AND cautrec = 0;

                  IF w_cautrec > 0 THEN
                     p_testpol := f_axis_literales(9902675, p_idioma);
                     p_cestpol := 1;
                     p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                     p_cnivelbpm := w_cnivelbpm;
                  ELSE
                     SELECT COUNT(*)
                       INTO w_cautrec
                       FROM estpsucontrolseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = w_nmovimi
                        AND nocurre = (SELECT MAX(nocurre)
                                         FROM estpsucontrolseg
                                        WHERE sseguro = p_sseguro
                                          AND nmovimi = w_nmovimi)
                        AND cautrec = 2;

                     IF w_cautrec > 0 THEN
                        p_testpol := f_axis_literales(9902676, p_idioma);
                        p_cestpol := 1;
                        p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                        p_cnivelbpm := w_cnivelbpm;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         IF w_nmovimi IS NULL THEN
            SELECT MAX(nmovimi)
              INTO w_nmovimi
              FROM movseguro mv, estseguros s
             WHERE s.sseguro = p_sseguro
               AND mv.sseguro = s.ssegpol;
         END IF;
      ELSE
         /*SELECT COUNT(*)
           INTO w_cautrec
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND nmovimi = p_nmovimi
            AND cautrec <> 1;*/
         SELECT COUNT(1)
           INTO w_total
           FROM psucontrolseg
          WHERE sseguro = p_sseguro;

         IF w_total > 0 THEN
            w_nmovimi := p_nmovimi;

            IF w_nmovimi IS NULL THEN
               SELECT MAX(nmovimi)
                 INTO w_nmovimi
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro;

               IF w_nmovimi IS NULL THEN
                  SELECT MAX(nmovimi)
                    INTO w_nmovimi
                    FROM movseguro
                   WHERE sseguro = p_sseguro;
               END IF;
            END IF;

            SELECT COUNT(*)
              INTO w_total
              FROM psucontrolseg
             WHERE sseguro = p_sseguro
               AND nmovimi = w_nmovimi
               AND nocurre = (SELECT MAX(NVL(nocurre, 0))
                                FROM psucontrolseg
                               WHERE sseguro = p_sseguro
                                 AND nmovimi = w_nmovimi);

            SELECT COUNT(*)
              INTO w_cautrec
              FROM psucontrolseg
             WHERE sseguro = p_sseguro
               AND nmovimi = w_nmovimi
               AND nocurre = (SELECT MAX(nocurre)
                                FROM psucontrolseg
                               WHERE sseguro = p_sseguro
                                 AND nmovimi = w_nmovimi)
               AND cautrec = 3;

            IF w_total > 0 THEN
               BEGIN
                  SELECT cmotret, cnivelbpm
                    INTO w_cmotret, w_cnivelbpm
                    FROM psu_retenidas
                   WHERE sseguro = p_sseguro
                     AND nmovimi = w_nmovimi;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     w_cmotret := NULL;
                     w_cnivelbpm := NULL;
               END;
            END IF;

            IF w_total = w_cautrec
               OR w_total = 0 THEN
               --Póliza sin controles. Ningún registro o cautrec = 3
               p_testpol := f_axis_literales(9902672, p_idioma);
               p_cestpol := 0;
               p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
               p_cnivelbpm := w_cnivelbpm;
            ELSE
               SELECT COUNT(*)
                 INTO w_cautrec
                 FROM psucontrolseg
                WHERE sseguro = p_sseguro
                  AND nmovimi = w_nmovimi
                  AND nocurre = (SELECT MAX(nocurre)
                                   FROM psucontrolseg
                                  WHERE sseguro = p_sseguro
                                    AND nmovimi = w_nmovimi)
                  AND cautrec = 1;

               IF w_total = w_cautrec THEN
                  IF w_cmotret = 2 THEN
                     p_testpol := f_axis_literales(9902673, p_idioma);
                     p_cestpol := 2;
                     p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                     p_cnivelbpm := w_cnivelbpm;
                  ELSE
                     IF w_cmotret = 0 THEN
                        p_testpol := f_axis_literales(9902674, p_idioma);
                        p_cestpol := 3;
                        -- p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                        p_cnivelbpm := w_cnivelbpm;

                        BEGIN
                           SELECT COUNT(1)
                             INTO w_cautrec
                             FROM psu_retenidas
                            WHERE cmotret = 0
                              AND sseguro = p_sseguro
                              AND nmovimi = w_nmovimi;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              w_cautrec := 0;
                        END;

                        IF w_cautrec > 0 THEN
                           p_testpol := '';   --f_axis_literales(9902115, p_idioma);
                        END IF;
                     END IF;
                  END IF;
               ELSE
                  SELECT COUNT(*)
                    INTO w_cautrec
                    FROM psucontrolseg
                   WHERE sseguro = p_sseguro
                     AND nmovimi = w_nmovimi
                     AND nocurre = (SELECT MAX(nocurre)
                                      FROM psucontrolseg
                                     WHERE sseguro = p_sseguro
                                       AND nmovimi = w_nmovimi)
                     AND cautrec = 0;

                  IF w_cautrec > 0 THEN   --algun pendiente
                     p_testpol := f_axis_literales(9902675, p_idioma);
                     p_cestpol := 1;
                     p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                     p_cnivelbpm := w_cnivelbpm;
                  ELSE
                     SELECT COUNT(*)
                       INTO w_cautrec
                       FROM psucontrolseg
                      WHERE sseguro = p_sseguro
                        AND nmovimi = w_nmovimi
                        AND nocurre = (SELECT MAX(nocurre)
                                         FROM psucontrolseg
                                        WHERE sseguro = p_sseguro
                                          AND nmovimi = w_nmovimi)
                        AND cautrec = 2;

                     IF w_cautrec > 0 THEN
                        p_testpol := f_axis_literales(9902676, p_idioma);
                        p_cestpol := 1;
                        p_tnivelbpm := pac_psu.f_tcnivel(w_cnivelbpm, p_idioma);
                        p_cnivelbpm := w_cnivelbpm;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         IF w_nmovimi IS NULL THEN
            SELECT MAX(nmovimi)
              INTO w_nmovimi
              FROM movseguro
             WHERE sseguro = p_sseguro;
         END IF;
      END IF;

      IF p_tablas = 'EST' THEN
         SELECT COUNT(1)
           INTO vhaytomador
           FROM esttomadores
          WHERE sseguro = p_sseguro;
      ELSE
         SELECT COUNT(1)
           INTO vhaytomador
           FROM tomadores
          WHERE sseguro = p_sseguro;
      END IF;

/*
      IF w_cautrec > 0 THEN
         -- Pòlissa Retinguda. Hi han Controls pendents d''autoritzar.
         p_testpol := f_axis_literales(9900989, p_idioma);
         p_cestpol := 1;
      ELSE
         -- Pòlissa amb tots els Controls autoritzats.
         p_cestpol := 0;
         p_testpol := f_axis_literales(9900990, p_idioma);
      END IF;
*/    --
      IF w_nmovimi IS NULL THEN
         w_nmovimi := 1;
      END IF;

      v_select :=
         'SELECT a.sseguro, a.npoliza, e.observ, e.cusuaur, (SELECT tusunom FROM usuarios WHERE cusuari = e.cusuaur) tusuaur,
         e.nriesgo, e.cnivelr, pac_psu.f_tcnivel(e.cnivelr,'
         || p_idioma
         || ' ) tnivelr, e.nvalor, e.cusumov, (SELECT     tusunom
    FROM    usuarios
    WHERE    cusuari =  e.cusumov) tusumov, e.cnivelu, pac_psu.f_tcnivel(e.cnivelu,'
         || p_idioma || ' ) tnivelu,';

      IF vhaytomador > 0 THEN
         v_select := v_select || ' f_nombre(b.sperson,1) tomador, ';
      ELSE
         v_select := v_select || ' null tomador, ';
      END IF;

      v_select :=
         v_select || ' e.ccontrol, pac_psu.f_tccontrol(e.ccontrol,' || p_idioma || ', '
         || p_sseguro || ', ' || w_nmovimi || ', ' || NVL(p_nriesgo, 1) || ', ''' || p_tablas
         || ''', e.cgarant) tcontrol,pac_psu.f_detcontrol(e.ccontrol,a.sproduc,e.cnivelr ,'
         || p_idioma || ') tdesniv, e.cgarant, pac_psu.f_tcgarant(e.cgarant,' || p_idioma
         || ') tgarant, e.cautrec, ff_desvalorfijo(445,' || p_idioma || ',e.cautrec) ||'
         || CHR(39) || ' (' || CHR(39) || ' ||e.autmanual||' || CHR(39) || ')' || CHR(39)
         || ' tautrec, e.fautrec, case when (e.cnivelr > pac_psu.f_nivel_usuari_psu( f_user,  a.sproduc)) then 0 else 1 end editar,e.fmovpsu, e.nmovimi, '
         || ' e.nocurre, decode(e.establoquea,''E'',1,2) establoquea, e.ordenbloquea,e.nvalorinf, e.nvalorsuper, e.nvalortope, decode(e.autmanual,''A'',1,0) autmanual, e.risknum ';

      --
      IF vhaytomador > 0 THEN
         IF p_tablas = 'EST' THEN
            v_from := ' FROM estseguros a, esttomadores b, estpsucontrolseg e ';
         ELSE
            v_from := ' FROM seguros a, tomadores b, psucontrolseg e ';
         END IF;
      ELSE
         IF p_tablas = 'EST' THEN
            v_from := ' FROM estseguros a, estpsucontrolseg e ';
         ELSE
            v_from := ' FROM seguros a, psucontrolseg e ';
         END IF;
      END IF;

      v_niv_compl_ok := pac_parametros.f_parempresa_n(NVL(pac_md_common.f_get_cxtempresa,
                                                          f_parinstalacion_n('EMPRESADEF')),
                                                      'NIVEL_CORRECTO_PSU');   -- BUG 33346/0193174 - FAL - 5/1/2015

      IF p_tablas = 'EST' THEN
         -- BUG 33346/0193174 - FAL - 5/1/2015
         IF v_niv_compl_ok IS NOT NULL THEN
            v_where := ' WHERE (((e.cnivelr NOT IN (0,' || v_niv_compl_ok
                       || ')) and nvl(e.isvisible,1) = 1) OR e.cautrec = 0) and e.nmovimi = '
                       || w_nmovimi || ' and a.sseguro = ' || p_sseguro;
         ELSE
            -- FI BUG 33346/0193174 - FAL - 5/1/2015
            v_where :=

               --BUG 029665/166752 - RCL - 19/02/2014
               ' WHERE (((e.cnivelr <> 0 ) and nvl(e.isvisible,1) = 1) OR e.cautrec = 0) and e.nmovimi = '
               || w_nmovimi || ' and a.sseguro = ' || p_sseguro;
         END IF;

         IF p_nriesgo IS NOT NULL THEN
            v_where := v_where || ' and e.nriesgo = ' || p_nriesgo;

            IF w_nmovimi IS NULL THEN
               v_where :=
                  v_where
                  || ' and e.nmovimi= (select max(c.nmovimi)
                                                from estpsucontrolseg c
                                                 where c.sseguro = '
                  || p_sseguro
                  || '
                                                 and c.nriesgo = ' || p_nriesgo || ')';
            END IF;
         ELSE
            IF w_nmovimi IS NOT NULL THEN
               v_where :=
                  v_where
                  || ' and e.nmovimi= (select max(c.nmovimi)
                                                     from estpsucontrolseg c
                                                     where c.sseguro = '
                  || p_sseguro
                  || '
                                                     and c.nriesgo = e.nriesgo)';
            END IF;
         END IF;

         IF vhaytomador > 0 THEN
            v_where := v_where || ' AND b.sseguro = a.sseguro and b.nordtom = (select min'
                       || '(c.nordtom) FROM esttomadores c where c.sseguro = a.sseguro)';
         END IF;

         v_where := v_where || '  and e.sseguro = a.sseguro';
      ELSE
         -- BUG 33346/0193174 - FAL - 5/1/2015
         IF v_niv_compl_ok IS NOT NULL THEN
            v_where := ' WHERE (((e.cnivelr NOT IN (0,' || v_niv_compl_ok
                       || ')) and nvl(e.isvisible,1) = 1) OR e.cautrec = 0) and e.nmovimi = '
                       || w_nmovimi || ' and a.sseguro = ' || p_sseguro;
         ELSE
            -- FI BUG 33346/0193174 - FAL - 5/1/2015
            v_where :=   --BUG 029665/166752 - RCL - 19/02/2014
               ' WHERE (((e.cnivelr <> 0 ) and nvl(e.isvisible,1) = 1) OR e.cautrec = 0) and e.nmovimi = '
               || w_nmovimi || ' and a.sseguro = ' || p_sseguro;
         END IF;

         IF p_nriesgo IS NOT NULL THEN
            v_where := v_where || ' and e.nriesgo = ' || p_nriesgo;

            IF w_nmovimi IS NULL THEN
               v_where :=
                  v_where
                  || ' and e.nmovimi= (select max(c.nmovimi)
                                                from psucontrolseg c
                                                 where c.sseguro = '
                  || p_sseguro
                  || '
                                                 and c.nriesgo = ' || p_nriesgo || ')';
            END IF;
         /* ELSE
             IF w_nmovimi IS NOT NULL THEN
                v_where :=
                   v_where
                   || ' and e.nmovimi= (select max(c.nmovimi)
                                                      from psucontrolseg c
                                                      where c.sseguro = '
                   || p_sseguro
                   || '
                                                      and c.nriesgo = e.nriesgo)';
             END IF;*/
         END IF;

         IF vhaytomador > 0 THEN
            v_where := v_where || ' AND b.sseguro = a.sseguro and b.nordtom = (select min'
                       || '(c.nordtom) FROM tomadores c where c.sseguro = a.sseguro)';
         END IF;

         v_where := v_where || '  and e.sseguro = a.sseguro';
      END IF;

      IF p_tablas = 'EST' THEN
         v_where :=
            v_where
            || ' and e.nocurre =  (select max(x.nocurre) from estpsucontrolseg x where x.sseguro = a.sseguro and x.nmovimi = e.nmovimi) ';
      ELSE
         v_where :=
            v_where
            || ' and e.nocurre =  (select max(x.nocurre) from psucontrolseg x where x.sseguro = a.sseguro and x.nmovimi = e.nmovimi) ';
      END IF;

      --
      v_order := ' ORDER BY a.sseguro desc, NVL(e.nriesgo,0), NVL(e.cgarant,0)';
      p_vquery := v_select || v_from || v_where || v_order;
      v_nerror := pac_log.f_log_consultas(p_vquery, 'PAC_PSU.f_get_colec_psu', 1);
      RETURN(0);
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_colec_psu', NULL, 'f_get_colec_psu',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN(1);
   END f_get_colec_psu;

   FUNCTION f_get_lstniveles(pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      pquery := 'select * from psu_desnivel where cidioma =  ' || pcidioma;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'f_get_lstniveles', NULL, 'f_get_lstniveles',
                     'exception when others ** Codi Error = ' || SQLERRM);
         RETURN(1);
   END;

     /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(p_sseguro IN NUMBER, p_tablas IN VARCHAR2)
      RETURN NUMBER IS
      --
      vcontrolmanual NUMBER;
   BEGIN
      --
      IF p_tablas = 'EST' THEN
         SELECT COUNT(1)
           INTO vcontrolmanual
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro
            AND cautrec = 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpsucontrolseg
                            WHERE sseguro = p_sseguro)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM estpsucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpsucontrolseg
                                                 WHERE sseguro = p_sseguro))
            AND estpsucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                               FROM psu_controlpro
                                              WHERE psu_controlpro.ccontrol =
                                                                      estpsucontrolseg.ccontrol
                                                AND NVL(psu_controlpro.cgarant, 0) =
                                                               NVL(estpsucontrolseg.cgarant, 0)
                                                AND psu_controlpro.autmanual = 'M'
                                                AND psu_controlpro.sproduc =
                                                         (SELECT estseguros.sproduc
                                                            FROM estseguros
                                                           WHERE estseguros.sseguro = p_sseguro));   --p_nmovimi);
      ELSE
         SELECT COUNT(1)
           INTO vcontrolmanual
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND cautrec = 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM psucontrolseg
                            WHERE sseguro = p_sseguro)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM psucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM psucontrolseg
                                                 WHERE sseguro = p_sseguro))
            AND psucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                            FROM psu_controlpro
                                           WHERE psu_controlpro.ccontrol =
                                                                         psucontrolseg.ccontrol
                                             AND NVL(psu_controlpro.ccontrol, 0) =
                                                                 NVL(psucontrolseg.ccontrol, 0)
                                             AND psu_controlpro.autmanual = 'M'
                                             AND psu_controlpro.sproduc =
                                                            (SELECT seguros.sproduc
                                                               FROM seguros
                                                              WHERE seguros.sseguro = p_sseguro));   --p_nmovimi);
      END IF;

      IF vcontrolmanual > 0 THEN
         RETURN 9901030;
      END IF;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.f_hay_controles_manuales = ' || p_sseguro,
                     '** Codi Error = ' || SQLERRM);
         --
         RETURN 9901030;
   --
   END f_hay_controles_manuales;

   FUNCTION f_hay_controles_pendientes(p_sseguro IN NUMBER, p_tablas IN VARCHAR2)
      RETURN NUMBER IS
      vcontrol       NUMBER;
   BEGIN
      IF p_tablas = 'EST' THEN
         SELECT COUNT(1)
           INTO vcontrol
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro
            AND cautrec = 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpsucontrolseg
                            WHERE sseguro = p_sseguro)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM estpsucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpsucontrolseg
                                                 WHERE sseguro = p_sseguro))
            AND estpsucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                               FROM psu_controlpro
                                              WHERE psu_controlpro.ccontrol =
                                                                      estpsucontrolseg.ccontrol
                                                AND psu_controlpro.sproduc =
                                                         (SELECT estseguros.sproduc
                                                            FROM estseguros
                                                           WHERE estseguros.sseguro = p_sseguro));
      ELSE
         SELECT COUNT(1)
           INTO vcontrol
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND cautrec = 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM psucontrolseg
                            WHERE sseguro = p_sseguro)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM psucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM psucontrolseg
                                                 WHERE sseguro = p_sseguro))
            AND psucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                            FROM psu_controlpro
                                           WHERE psu_controlpro.ccontrol =
                                                                         psucontrolseg.ccontrol
                                             AND psu_controlpro.sproduc =
                                                            (SELECT seguros.sproduc
                                                               FROM seguros
                                                              WHERE seguros.sseguro = p_sseguro));
      END IF;

      IF vcontrol > 0 THEN
         RETURN 9901030;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.f_hay_controles_pendientes = ' || p_sseguro,
                     '** Codi Error = ' || SQLERRM);
         RETURN 9901030;
   END f_hay_controles_pendientes;

   FUNCTION f_inicia_psu_postcartera(
      psproces IN NUMBER,
      psseguro IN NUMBER,
      pnpoliza IN VARCHAR2,
      pncertif IN NUMBER,
      pcaccion IN NUMBER,
      pidioma IN NUMBER,
      pmes IN NUMBER,
      panyo IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_prod IS
         SELECT *
           FROM carteraaux
          WHERE sproces = psproces;

      CURSOR c_seg(wram NUMBER, wmod NUMBER, wtip NUMBER, wcol NUMBER) IS
         SELECT *
           FROM seguros
          WHERE cramo = wram
            AND cmodali = wmod
            AND ctipseg = wtip
            AND ccolect = wcol
            AND sseguro = NVL(psseguro, sseguro)   --AMC
            AND((csituac = 5)
                OR(creteni = 0
                   AND csituac NOT IN(7, 8, 9, 10)))
            AND fcarpro <(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')) + 1)
            --           AND (fvencim > (last_day(to_date(lpad(pmes,2,'0')||panyo,'mmyyyy'))) OR fvencim is null)
            AND(fvencim >(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')))
                OR(fvencim <=(LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo, 'mmyyyy')))
                   AND TO_CHAR(fvencim, 'mmyyyy') = LPAD(pmes, 2, '0') || panyo
                   AND fvencim > fcarpro
                   AND NVL(f_parproductos_v(sproduc, 'RECMESVENCI'), 1) = 1)
                OR fvencim IS NULL)
            AND(EXISTS(SELECT sseguro
                         FROM movseguro m
                        WHERE nmovimi = (SELECT MAX(nmovimi)
                                           FROM movseguro m3
                                          WHERE m3.sseguro = m.sseguro
                                            AND TRUNC(m3.fefecto) <=
                                                  LAST_DAY(TO_DATE(LPAD(pmes, 2, '0') || panyo,
                                                                   'mmyyyy'))
                                            AND m3.cmovseg <> 6)
                          AND cmovseg <> 3
                          AND femisio IS NOT NULL
                          AND sseguro = seguros.sseguro)
                OR(csituac = 5
                   AND ccartera = 1))
            -- BUG 17153 - 31/12/2010 - JMP - Permitir pasar la cartera a un colectivo entero o a un certificado
            AND npoliza = NVL(pnpoliza, npoliza)
            AND ncertif = NVL(pncertif, ncertif)
            -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
            -- NO seleccionar certificados 0 para RECUNIF = 3 (agrupac¿¿n de recibos en funi¿n de la forma pago del certif 0)
            AND((NVL(f_parproductos_v(f_sproduc_ret(cramo, cmodali, ctipseg, ccolect),
                                      'RECUNIF'),
                     0) = 3
                 AND ncertif <> 0)
                OR(NVL(f_parproductos_v(f_sproduc_ret(cramo, cmodali, ctipseg, ccolect),
                                        'RECUNIF'),
                       0) <> 3));

      vcreteni       NUMBER;
      vnumerr        NUMBER;
   BEGIN
      FOR v_prod IN c_prod LOOP
         FOR v_seg IN c_seg(v_prod.cramo, v_prod.cmodali, v_prod.ctipseg, v_prod.ccolect) LOOP
            vnumerr := pac_psu.f_inicia_psu('CAR', v_seg.sseguro, pcaccion, pidioma, vcreteni);

            --accion fer que sigui un altre valor ??? 3 és cartera, podria ser 4 pos-cartera ???
            --per poder definir només psu's per cartera i uns altres per post-cartera
            IF vnumerr != 0 THEN
               vcreteni := 1;
            END IF;

            IF vcreteni != 0 THEN
               UPDATE seguros
                  SET creteni = 2
                WHERE sseguro = v_seg.sseguro;
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.f_inicia_psu_postcartera psproces= ' || psproces,
                     '** Codi Error = ' || SQLERRM);
         --
         RETURN 9901030;
   --
   END f_inicia_psu_postcartera;

   -- Bug 30448/169258 - APD - 11/03/2014 - se añade cgarant a la funcion
   FUNCTION f_esta_control_pendiente(
      p_sseguro IN NUMBER,
      p_tablas IN VARCHAR2,
      pccontrol IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER DEFAULT 0)
      RETURN NUMBER IS
      vparam         VARCHAR2(1000)
         := 'p_sseguro = ' || p_sseguro || '; p_tablas = ' || p_tablas || '; pccontrol = '
            || pccontrol || '; pnriesgo = ' || pnriesgo || '; pcgarant = ' || pcgarant;
      vcontrol       NUMBER;
   BEGIN
      IF p_tablas = 'EST' THEN
         SELECT cautrec
           INTO vcontrol
           FROM estpsucontrolseg
          WHERE sseguro = p_sseguro
            AND ccontrol = pccontrol
            AND nriesgo = pnriesgo
            AND cnivelr <> 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM estpsucontrolseg
                            WHERE sseguro = p_sseguro
                              AND ccontrol = pccontrol
                              AND nriesgo = pnriesgo)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM estpsucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.ccontrol = pccontrol
                              AND pp.nriesgo = pnriesgo
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM estpsucontrolseg
                                                 WHERE sseguro = p_sseguro
                                                   AND ccontrol = pccontrol))
            AND estpsucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                               FROM psu_controlpro
                                              WHERE psu_controlpro.ccontrol =
                                                                      estpsucontrolseg.ccontrol
                                                AND psu_controlpro.sproduc =
                                                         (SELECT estseguros.sproduc
                                                            FROM estseguros
                                                           WHERE estseguros.sseguro = p_sseguro)
                                                AND psu_controlpro.cgarant =
                                                                       estpsucontrolseg.cgarant)
            AND estpsucontrolseg.cgarant = pcgarant;
      ELSE
         SELECT cautrec
           INTO vcontrol
           FROM psucontrolseg
          WHERE sseguro = p_sseguro
            AND ccontrol = pccontrol
            AND(nriesgo = pnriesgo
                OR pnriesgo IS NULL)
            AND cnivelr <> 0
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM psucontrolseg
                            WHERE sseguro = p_sseguro
                              AND ccontrol = pccontrol
                              AND nriesgo = pnriesgo)
            AND nocurre = (SELECT MAX(nocurre)
                             FROM psucontrolseg pp
                            WHERE pp.sseguro = p_sseguro
                              AND pp.ccontrol = pccontrol
                              AND pp.nriesgo = pnriesgo
                              AND pp.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM psucontrolseg
                                                 WHERE sseguro = p_sseguro))
            AND psucontrolseg.ccontrol IN(SELECT psu_controlpro.ccontrol
                                            FROM psu_controlpro
                                           WHERE psu_controlpro.ccontrol =
                                                                         psucontrolseg.ccontrol
                                             AND psu_controlpro.sproduc =
                                                            (SELECT seguros.sproduc
                                                               FROM seguros
                                                              WHERE seguros.sseguro = p_sseguro)
                                             AND psu_controlpro.cgarant = psucontrolseg.cgarant)
            AND psucontrolseg.cgarant = pcgarant;
      END IF;

      RETURN vcontrol;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL,
                     'PAC_PSU.f_esta_control_pendiente = ' || vparam,
                     '** Codi Error = ' || SQLERRM);
         RETURN 1;
   END F_ESTA_CONTROL_PENDIENTE;
/*--------------------------------------------------------------------------------
LEE HISTORIAL PSU RETENIDAS
--------------------------------------------------------------------------------*/
FUNCTION F_LEE_HIS_PSU_RETENIDAS(  --ramiro
    p_sseguro  IN NUMBER,
    p_nversion IN NUMBER,
    p_nriesgo  IN NUMBER,
    p_nmovimi  IN NUMBER,
    p_cidioma  IN NUMBER,
    p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
    mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER
IS
  vparam VARCHAR2(500) := p_sseguro || p_nversion ||p_nriesgo||p_nmovimi|| p_cidioma;
  vquery         VARCHAR2(2000);
  vquery2        VARCHAR2(2000);
  cursor_psu sys_refcursor;
  w_tpsus OB_IAX_PSU_RETENIDAS := OB_IAX_PSU_RETENIDAS();
  contador number;
  V_CDETMOTREC NUMBER;
  V_OBSERV VARCHAR2(2000);
  V_FFECAUT DATE;
  V_CUSUAUT VARCHAR2(200);
  V_FFECRET DATE;
  V_CUSURET VARCHAR2(200);
  V_CNIVELBPM NUMBER;
  V_CMOTRET NUMBER;
  V_FMOVIMI DATE;
  V_NMOVIMI NUMBER;
  V_NVERSION NUMBER;
  V_SSEGURO NUMBER;
  V_CSUBESTADO NUMBER;
  V_TSUBESTADO VARCHAR2(200);
  V_TESTADO VARCHAR2(200);
  V_CESTADO NUMBER;
  V_SEQ number := 0;
  V_VERSION varchar2(10);
  v_nmovimi2 varchar2(10);
BEGIN

  IF p_sseguro IS NULL
  --OR p_nriesgo IS NULL
  --OR p_nmovimi IS NULL
  THEN
     RETURN 1000005; --RAMIRO
  END IF;

if p_nversion is null then
  v_version := 'H.NVERSION';
else
  v_version := to_char(p_nversion);
end if;

if P_NMOVIMI is null then
  V_nmovimi2 := 'H.nmovimi';
else
  V_nmovimi2 := TO_CHAR(P_nmovimi);
end if;


  v_seq := 111;
 select count(1)
 into contador
 from HIS_PSU_RETENIDAS
  WHERE sseguro = p_sseguro
    AND nmovimi = NVL(p_nmovimi,nmovimi)
    AND nversion = NVL(p_nversion,nversion);
  v_seq := 112;

  vquery := 'SELECT
              H.CDETMOTREC CDETMOTREC,
              H.OBSERV OBSERV,
              H.FFECAUT FFECAUT,
              H.CUSUAUT CUSUAUT,
              H.FFECRET FFECRET,
              H.CUSURET CUSURET,
              H.CNIVELBPM CNIVELBPM,
              H.CMOTRET CMOTRET,
              H.FMOVIMI FMOVIMI,
              H.NMOVIMI NMOVIMI,
              H.NVERSION NVERSION,
              H.SSEGURO SSEGURO,
              H.CSUBESTADO CSUBESTADO,
              (SELECT D.TATRIBU
                 FROM DETVALORES D
                WHERE D.CVALOR = 8001103
                  AND D.CIDIOMA = 8
                  AND D.CATRIBU = H.CSUBESTADO) TSUBESTADO,
              S.CSITUAC CESTADO,
              (SELECT D.TATRIBU
                 FROM DETVALORES D
                WHERE D.CVALOR = 66
                  AND D.CIDIOMA = 8
                  AND D.CATRIBU = S.CRETENI) TESTADO
              FROM HIS_PSU_RETENIDAS h,PSU_RETENIDAS p,SEGUROS S
              WHERE H.SSEGURO = P.SSEGURO
              AND H.SSEGURO = S.SSEGURO
              AND H.NVERSION = '||v_version||' AND S.SSEGURO = '||p_sseguro||
              ' AND H.nmovimi = '||V_nmovimi2;

  vquery := vquery||' '||' order by NVERSION';
  v_seq := 113;



  P_CONTROL_ERROR('ID_RAMIRO','PAC_PSU',VQUERY);
  commit;
  v_seq := 11;

if contador > 0 then

  v_seq := 12;
  cursor_psu := pac_md_listvalores.f_opencursor(vquery, mensajes);
  v_seq := 13;

  p_this_psu_retenidas := T_IAX_PSU_RETENIDAS();

  LOOP --ob_iax_psu
    FETCH cursor_psu INTO
    V_CDETMOTREC,
    V_OBSERV,
    V_FFECAUT,
    V_CUSUAUT,
    V_FFECRET,
    V_CUSURET,
    V_CNIVELBPM,
    V_CMOTRET,
    V_FMOVIMI,
    V_NMOVIMI,
    V_NVERSION,
    V_SSEGURO,
    V_CSUBESTADO,
    V_TSUBESTADO,
    V_CESTADO,
    V_TESTADO;

    EXIT WHEN cursor_psu%NOTFOUND;

    V_SEQ := 1;
    w_tpsus.CDETMOTREC := V_CDETMOTREC;
    v_seq := 2;
    w_tpsus.OBSERV := V_OBSERV;
    V_SEQ := 3;
    w_tpsus.FFECAUT := V_FFECAUT;
    V_SEQ := 4;
    w_tpsus.CUSUAUT := V_CUSUAUT;
    V_SEQ := 5;
    w_tpsus.FFECRET := V_FFECRET;
    v_seq := 6;
    w_tpsus.CUSURET := V_CUSURET;
    V_SEQ := 7;
    w_tpsus.CNIVELBPM := V_CNIVELBPM;
    V_SEQ := 8;
    w_tpsus.CMOTRET := V_CMOTRET;
    v_seq := 9;
    w_tpsus.FMOVIMI := V_FMOVIMI;
    V_SEQ := 10;
    w_tpsus.NMOVIMI := V_NMOVIMI;
    V_SEQ := 11;
    w_tpsus.NVERSION := V_NVERSION;
    v_seq := 12;
    w_tpsus.SSEGURO := V_SSEGURO;
    V_SEQ := 13;
    w_tpsus.CSUBESTADO := V_CSUBESTADO;
    W_TPSUS.TSUBESTADO := V_TSUBESTADO;
    W_TPSUS.CESTPOL := V_CESTADO;
    w_tpsus.TESTPOL := V_TESTADO;


    p_this_psu_retenidas.EXTEND;
    p_this_psu_retenidas(p_this_psu_retenidas.LAST) := w_tpsus;
    w_tpsus                            := OB_IAX_PSU_RETENIDAS();
    END LOOP;
    IF cursor_psu%ISOPEN THEN
     CLOSE cursor_psu;
    END IF;

end if;

RETURN 0;

EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'Ramiro contreras', v_seq, 'PAC_PSU.F_LEE_HIS_PSU_RETENIDAS = ' || vparam, '** Codi Error = ' || SQLERRM);
  RETURN 1;
END F_LEE_HIS_PSU_RETENIDAS; --ramiro

/*------------------------------------------------------------------------------
Historial psu control seguros

-------------------------------------------------------------------------------*/
FUNCTION F_LEE_HIS_PSUCONTROLSEG( --ramiro
    p_sseguro  IN NUMBER,
    p_nversion IN NUMBER,
    p_nriesgo  IN NUMBER,
    p_nmovimi  IN NUMBER,
    p_ccontrol IN NUMBER,
    p_cidioma  IN NUMBER,
    p_this_psucontrolseg OUT T_IAX_PSU,
    mensajes IN OUT t_iax_mensajes )
  RETURN NUMBER
IS
  vparam  VARCHAR2(500) := p_sseguro || p_nversion ||p_nriesgo||p_nmovimi|| p_cidioma;
  vquery  VARCHAR2(2000);
  vquery2 VARCHAR2(2000);
  cursor_psu sys_refcursor;
  w_tpsus OB_IAX_PSU := OB_IAX_PSU();
  c_traza number;
  registro HIS_PSUCONTROLSEG%ROWTYPE;
  contador number;
  v_seq number;
  V_ISVISIBLE NUMBER;
  V_OBSERV VARCHAR2(2000);
  V_CUSUAUR VARCHAR(200);
  V_FAUTREC DATE;
  V_AUTMANUAL VARCHAR2(200);
  V_CAUTREC NUMBER;
  V_CNIVELU NUMBER;
  V_CUSUMOV VARCHAR2(200);
  V_NVALORTOPE NUMBER;
  V_NVALORSUPER NUMBER;
  V_NVALORINF NUMBER;
  V_NVALOR NUMBER;
  V_AUTORIPREV VARCHAR2(200);
  V_ORDENBLOQUEA NUMBER;
  V_ESTABLOQUEA VARCHAR2(200);
  V_CNIVELR VARCHAR2(200);
  V_CGARANT NUMBER;
  V_NOCURRE NUMBER;
  V_NRIESGO NUMBER;
  V_CCONTROL NUMBER;
  V_FMOVPSU DATE;
  V_NMOVIMI NUMBER;
  V_NVERSION NUMBER;
  V_SSEGURO NUMBER;
  V_TESTADO VARCHAR2(200);
  V_CESTADO NUMBER;
  V_VERSION VARCHAR2(10);
  V_NMOVIMIENTO VARCHAR2(20);
  V_TRIESGO VARCHAR2(200);
  V_TGARANT VARCHAR2(200);
  V_tdesniv VARCHAR2(200);
BEGIN


  if P_SSEGURO is null THEN
  --OR p_nriesgo IS NULL OR p_nmovimi IS NULL THEN
    RETURN 1000005; --RAMIRO
   END IF;

 IF p_nversion IS NULL THEN
   V_VERSION := 'H.NVERSION';
 else
  v_version := to_char(p_nversion);
 END IF;

 if p_nmovimi is null then

  v_nmovimiento := 'H.nmovimi';

 else

 v_nmovimiento := TO_CHAR(p_nmovimi);
 end if;

  select count(1)
  into contador
  from HIS_PSUCONTROLSEG
  WHERE sseguro = p_sseguro
   AND nmovimi = p_nmovimi
   AND nversion = NVL(p_nversion,nversion);

  vquery     := 'SELECT  H.ISVISIBLE ISVISIBLE,
                  H.OBSERV OBSERV,
                  H.CUSUAUR CUSUAUR,
                  H.FAUTREC FAUTREC,
                  H.AUTMANUAL AUTMANUAL,
                  H.CAUTREC CAUTREC,
                  H.CNIVELU CNIVELU,
                  pac_psu.f_detcontrol(H.ccontrol,S.sproduc,H.cnivelr ,8) tdesniv,
                  H.CUSUMOV CUSUMOV,
                  H.NVALORTOPE NVALORTOPE,
                  H.NVALORSUPER NVALORSUPER,
                  H.NVALORINF NVALORINF,
                  H.NVALOR NVALOR,
                  H.AUTORIPREV AUTORIPREV,
                  H.ORDENBLOQUEA ORDENBLOQUEA,
                  H.ESTABLOQUEA ESTABLOQUEA,
                  H.CNIVELR CNIVELR,
                  H.CGARANT CGARANT,
                  H.NOCURRE NOCURRE,
                  H.NRIESGO NRIESGO,
                  H.CCONTROL CCONTROL,
                  H.FMOVPSU FMOVPSU,
                  H.NMOVIMI NMOVIMI,
                  H.NVERSION NVERSION,
                  H.SSEGURO SSEGURO,
                  (SELECT R.TNATRIE
                     FROM RIESGOS R
                    WHERE R.SSEGURO = H.SSEGURO
                      AND R.NRIESGO = H.NRIESGO) TRIESGO,
                  (SELECT TGARANT FROM GARANGEN G
                    WHERE H.CGARANT = G.CGARANT
                      AND G.CIDIOMA = '||p_cidioma||' ) TGARANT
                  FROM HIS_PSUCONTROLSEG H, SEGUROS S
                                  WHERE H.NVERSION = '||v_version||
                                  ' AND H.SSEGURO = S.SSEGURO'||
                                  ' AND H.SSEGURO = '||p_sseguro||
                                  ' AND H.nmovimi = '||v_nmovimiento;


v_seq := 1;

 p_control_error('ramiro','pac_psu',vquery);

if contador > 0 then
    cursor_psu := pac_md_listvalores.f_opencursor(vquery, mensajes);
    p_this_psucontrolseg := t_iax_psu();

v_seq := 2;
    LOOP
    FETCH cursor_psu
     INTO V_ISVISIBLE,
          V_OBSERV,
          V_CUSUAUR,
          V_FAUTREC,
          V_AUTMANUAL,
          V_CAUTREC,
          V_CNIVELU,
          V_tdesniv,
          V_CUSUMOV,
          V_NVALORTOPE,
          V_NVALORSUPER,
          V_NVALORINF,
          V_NVALOR,
          V_AUTORIPREV,
          V_ORDENBLOQUEA,
          V_ESTABLOQUEA,
          V_CNIVELR,
          V_CGARANT,
          V_NOCURRE,
          V_NRIESGO,
          V_CCONTROL,
          V_FMOVPSU,
          V_NMOVIMI,
          V_NVERSION,
          V_SSEGURO,
          V_TRIESGO,
          V_TGARANT;

    EXIT WHEN cursor_psu%NOTFOUND;

v_seq := 3;
    --w_tpsus.ISVISIBLE := V_ISVISIBLE;
    w_tpsus.OBSERV := V_OBSERV;
    w_tpsus.CUSUAUR := V_CUSUAUR;
    w_tpsus.FAUTREC := V_FAUTREC;
    w_tpsus.AUTMANUAL := V_AUTMANUAL;
    W_TPSUS.CAUTREC := V_CAUTREC;
    W_TPSUS.CNIVELU := V_CNIVELU;
    --W_TPSUS.V_tdesniv := V_tdesniv;
    w_tpsus.CUSUMOV := V_CUSUMOV;
    w_tpsus.NVALORTOPE := V_NVALORTOPE;
    w_tpsus.NVALORSUPER := V_NVALORSUPER;
    w_tpsus.NVALORINF := V_NVALORINF;
    w_tpsus.NVALOR := V_NVALOR;
    w_tpsus.AUTORIPREV := V_AUTORIPREV;
    w_tpsus.ORDENBLOQUEA := V_ORDENBLOQUEA;
    w_tpsus.ESTABLOQUEA := V_ESTABLOQUEA;
    w_tpsus.CNIVELR := V_CNIVELR;
    w_tpsus.CGARANT := V_CGARANT;
    w_tpsus.NOCURRE := V_NOCURRE;
    w_tpsus.NRIESGO := V_NRIESGO;
    w_tpsus.CCONTROL := V_CCONTROL;
    --w_tpsus.FMOVPSU := V_FMOVPSU;
    w_tpsus.NMOVIMI := V_NMOVIMI;
    w_tpsus.NVERSION := V_NVERSION;
    W_TPSUS.SSEGURO := V_SSEGURO;
    W_TPSUS.TRIESGO := V_TRIESGO;
    W_TPSUS.TGARANT := V_TGARANT;

    p_this_psucontrolseg.EXTEND;
    p_this_psucontrolseg(p_this_psucontrolseg.LAST) := w_tpsus;
    w_tpsus := OB_IAX_PSU();

    END LOOP;
end if;

  RETURN 0;
EXCEPTION
WHEN OTHERS THEN

  p_tab_error(f_sysdate, f_user, 'PAC_PSUF_LEE_HIS_PSUCONTROLSEG', v_seq,  vparam, '** Codi Error = ' || vquery);
  RETURN 1;
END F_LEE_HIS_PSUCONTROLSEG; --ramiro

FUNCTION F_LEE_PSU_SUBESTADOSPROP(
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_tpsu_subestadosprop OUT T_IAX_PSU_SUBESTADOSPROP,
		p_mensajes IN OUT t_iax_mensajes

)
    RETURN NUMBER is
     vparam           VARCHAR2(200);
     v_parempresa     NUMBER;
     v_NVERSIONSUBEST NUMBER;
     vquery  VARCHAR2(2000);
     vquery2 VARCHAR2(2000);
     cursor_psu sys_refcursor;
     contador number;
     V_SSEGURO    NUMBER;
     V_NVERSION   NUMBER;
     --V_NVERSIONSUBEST  NUMBER;
     V_NMOVIMI    NUMBER;
     V_CSUBESTADO NUMBER;
     V_COBSERVACIONES  VARCHAR2(500);
     V_FALTA      DATE;
     V_CUSUALT    VARCHAR2(32);
     V_TSUBESTADO  VARCHAR2 (500);
     W_TPSUS OB_IAX_PSU_SUBESTADOSPROP := OB_IAX_PSU_SUBESTADOSPROP();
     v_nversionsubest2 VARCHAR2 (500);

BEGIN

 IF p_sseguro IS NULL OR p_nversion IS NULL OR p_nmovimi IS NULL THEN
    RETURN 99999; --RAMIRO
  END IF;


 select count(1)
  into contador
  from PSU_SUBESTADOSPROP
  WHERE sseguro = p_sseguro
 --   AND nmovimi = p_nmovimi
   AND nversion = NVL(p_nversion,nversion);


  IF P_NVERSIONSUBEST IS NULL THEN
    v_nversionsubest2 := 'NVERSIONSUBEST';
 ELSE
    v_nversionsubest2 := TO_CHAR(p_nversionsubest);
 end if;


 vquery := 'select COBSERVACIONES,CSUBESTADO,CUSUALT,FALTA,NMOVIMI,
         NVERSION,NVERSIONSUBEST,SSEGURO from PSU_SUBESTADOSPROP
         where sseguro = '||p_sseguro||' And nversion = '||p_nversion||
         ' And nmovimi = '||p_nmovimi||' And NVERSIONSUBEST = '||v_nversionsubest2;

 cursor_psu := pac_md_listvalores.f_opencursor(vquery, p_mensajes);

 p_control_error('ramiro quitar','pac_psu',vquery);

 if contador > 0 then
    cursor_psu := pac_md_listvalores.f_opencursor(vquery, p_mensajes);
    p_tpsu_subestadosprop := T_IAX_PSU_SUBESTADOSPROP();


    LOOP
    FETCH cursor_psu
     INTO V_COBSERVACIONES,
           V_CSUBESTADO,
          V_CUSUALT,
          V_FALTA,
          V_NMOVIMI,
          V_NVERSION,
          V_NVERSIONSUBEST,
          V_SSEGURO;

    EXIT WHEN cursor_psu%NOTFOUND;


    --w_tpsus.ISVISIBLE := V_ISVISIBLE;
    w_tpsus.COBSERVACIONES:= V_COBSERVACIONES;
    w_tpsus.CSUBESTADO:= V_CSUBESTADO;
    w_tpsus.CUSUALT := V_CUSUALT;
    w_tpsus.FALTA:= V_FALTA;
    w_tpsus.NMOVIMI:= V_NMOVIMI;
    w_tpsus.NVERSION:= V_NVERSION;
    w_tpsus.NVERSIONSUBEST:= V_NVERSIONSUBEST;
    w_tpsus.SSEGURO:= V_SSEGURO;

    p_tpsu_subestadosprop.EXTEND;
    p_tpsu_subestadosprop(p_tpsu_subestadosprop.LAST) := w_tpsus;
    w_tpsus := OB_IAX_PSU_SUBESTADOSPROP();

    END LOOP;
end if;
P_TAB_ERROR(F_SYSDATE, F_USER, 'PAC_PSU', NULL, 'PAC_PSU.F_LEE_HIS_PSUCONTROLSEG = ' || VPARAM, '** Codi Error = ' || SQLERRM);
return 0;

EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL, 'PAC_PSU.F_LEE_HIS_PSUCONTROLSEG = ' || vparam, '** Codi Error = ' || SQLERRM);
  RETURN 1;
END F_LEE_PSU_SUBESTADOSPROP;
-------------------------------------------------------------------------------------------------------------
FUNCTION F_INS_PSU_SUBESTADOSPROP(
    p_sseguro        IN NUMBER,
    p_nversion       IN NUMBER,
    p_nmovimi        IN NUMBER,
    p_csubestado     IN NUMBER,
    p_cobservaciones IN VARCHAR2 )
  RETURN NUMBER
IS
  vparam           VARCHAR2(200) := 'p_sseguro'||p_sseguro||'p_nversion'||p_nversion||'p_nmovimi' ||p_nmovimi||'p_csubestado'||p_csubestado||'p_cobservaciones'||p_cobservaciones;
  v_parempresa     NUMBER;
  v_NVERSIONSUBEST NUMBER;
  V_csituac        NUMBER;
  v_creteni        NUMBER;
  v_csubestado     NUMBER;
BEGIN
  SELECT MAX (NVERSIONSUBEST)+1
  INTO v_NVERSIONSUBEST
  FROM PSU_SUBESTADOSPROP
  WHERE SSEGURO = p_sseguro
  AND NVERSION  = p_nversion
  AND NMOVIMI   = p_nmovimi;
  v_csubestado := p_csubestado;
  BEGIN
  SELECT csituac,creteni
    INTO v_csituac,v_creteni
    FROM SEGUROS
   WHERE SSEGURO = p_sseguro;
  exception
    WHEN NO_DATA_FOUND THEN
      SELECT csituac,creteni
        INTO v_csituac,v_creteni
        FROM estSEGUROS
       WHERE SSEGURO = p_sseguro;
  END;

  v_parempresa  := pac_parametros.f_parempresa_n('24','SUBESTADOSPROP');

  IF v_csituac IN (4,5) AND v_creteni = 2 AND v_parempresa = 1 THEN
    v_csubestado := 9;
  END IF;
  INSERT INTO PSU_SUBESTADOSPROP
    (
      COBSERVACIONES,
      CSUBESTADO,
      CUSUALT,
      FALTA,
      NMOVIMI,
      NVERSION,
      NVERSIONSUBEST,
      SSEGURO
    )
    VALUES
    (
      p_cobservaciones,
      v_csubestado,
      f_user,
      f_sysdate,
      p_nmovimi,
      p_nversion,
      v_NVERSIONSUBEST,
      p_sseguro
    );


UPDATE PSU_RETENIDAS
SET csubestado = p_csubestado
WHERE sseguro = p_sseguro
and nmovimi = p_nmovimi;


return 0;


EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'PAC_PSU', NULL, 'PAC_PSU.F_LEE_HIS_PSUCONTROLSEG = ' || vparam, '** Codi Error = ' || SQLERRM);
  RETURN 1;
END F_INS_PSU_SUBESTADOSPROP;
-------------------------------------------------------------------------------------------------------------

FUNCTION f_get_subestadoprop(   --ramiro
    p_sseguro IN NUMBER,
    p_csubestadoprop OUT VARCHAR2)
  RETURN NUMBER
IS
  vparam           VARCHAR2(200) := 'p_sseguro'||p_sseguro;
  V_csituac        NUMBER;
  v_creteni        NUMBER;
  v_parempresa     NUMBER;
  v_csubestadoprop NUMBER;
BEGIN

  begin
  SELECT csituac,creteni
    INTO v_csituac,v_creteni
    FROM SEGUROS
   WHERE SSEGURO = P_SSEGURO;
  exception
    WHEN NO_DATA_FOUND THEN
      SELECT csituac,creteni
        INTO v_csituac,v_creteni
        FROM estSEGUROS
       WHERE SSEGURO = P_SSEGURO;
  end;


  v_parempresa                       := pac_parametros.f_parempresa_n('24','SUBESTADOSPROP');

  IF v_csituac IN (4,5) AND v_creteni = 2 AND v_parempresa = 1 THEN

  BEGIN
    SELECT NVL(MAX(CSUBESTADO),0)
    INTO v_csubestadoprop
    FROM PSU_SUBESTADOSPROP
    WHERE SSEGURO        = p_sseguro;
  exception
    WHEN NO_DATA_FOUND THEN
      v_csubestadoprop := 0;
  end;

    IF v_csubestadoprop != 0 THEN
      SELECT tatribu
      INTO p_csubestadoprop
      FROM detvalores
      WHERE cidioma = pac_md_common.f_get_cxtidioma
      AND cvalor    = 8001103
      AND CATRIBU = v_csubestadoprop;
    ELSE
      p_csubestadoprop := ' ';
    END IF;
  ELSE
    p_csubestadoprop := ' ';
  END IF;
  RETURN 0;
EXCEPTION
WHEN OTHERS THEN
  p_tab_error(f_sysdate, f_user, 'PAC_PSU.f_get_subestadoprop', NULL, 'PAC_PSU.f_get_subestadoprop = ' || vparam, '** Codi Error = ' || SQLERRM);
  RETURN 1;
END f_get_subestadoprop; --ramiro

--------------------------------------------------------------------------------

END pac_psu;

/

  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PSU" TO "PROGRAMADORESCSI";
