--------------------------------------------------------
--  DDL for Package Body PAC_MD_SUP_FINAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_SUP_FINAN" 
AS
/*****************************************************************************
   NAME:       PAC_MD_SUP_FINAN
   PURPOSE:    Funciones de rescates para productos financieros

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   JRH             1. Creación del package.
   2.0        11/11/2009   JRB             2. Se añade ctipban a la aportación
   3.0        25/05/2010   JMF             3. 0014185 ENSA101 - Proceso de carga del fichero (beneficio definido)
   4.0        24/11/2010   JTS             4. 0016692: CRE802 - Pantalla Aportacions Extraordinàries
   5.0        28/03/2011   RSC             5. 0018062: AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
   6.0        07/06/2011   ICV             6. 0018632: ENSA102-Aportaciones a nivel diferente de tomador
   7.0        21/10/2011   DRA             7. 0019863: CIV903 - Desconnexi񟣥 les crides a Eclipse pels productes PPA i PIES
******************************************************************************/
   e_object_error   EXCEPTION;
   e_param_error    EXCEPTION;
   mensajes         t_iax_mensajes := NULL;
   gidioma          NUMBER         := pac_md_common.f_get_cxtidioma;
   tarif            BOOLEAN        := TRUE;
   ------- Funciones internes
   v_nmovimi        NUMBER;
   v_est_sseguro    NUMBER;

   FUNCTION iniciarsuple
      RETURN NUMBER
   IS
   BEGIN
      v_nmovimi := NULL;
      v_est_sseguro := NULL;
      RETURN 0;
   END;

   --JRH 03/2008
      /*************************************************************************
         Valida y realiza una aportación extraordinaria
         param in psseguro  : póliza
         param in pnriesgo  : riesgo
         param in fecha     : fecha de la aportación
         pimporte           : Importe de la aportación
         capitalGaran      out number     : Capital garantizado en el suplemento.
         param out mensajes : mensajes de error
         return             : 0 todo correcto
                            1 ha habido un error
      *************************************************************************/
   FUNCTION f_tarif_aport_extraordinaria(
      psseguro       IN       NUMBER,
      pnriesgo       IN       NUMBER,
      fecha          IN       DATE,
      pimporte       IN       NUMBER,
      pcgarant       IN       NUMBER,
      capitalgaran   OUT      NUMBER,
      mensajes       OUT      t_iax_mensajes
   )
      RETURN NUMBER
   IS
      numerr           NUMBER         := 0;
      vpasexec         NUMBER (8)     := 1;
      vparam           VARCHAR2 (400)
         :=    'psproduc= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || ' pcgarant= '
            || pcgarant
            || ' fecha= '
            || fecha
            || ' pimporte= '
            || pimporte;
      vobject          VARCHAR2 (200) := 'PAC_MD_SUP_FINAN.f_Valor_Simulacion';
      num_err          NUMBER;
      v_cgarant        NUMBER;
      v_sproduc        NUMBER;
      v_cactivi        NUMBER;
      v_npoliza        NUMBER;
      v_ncertif        NUMBER;
      v_nrecibo        NUMBER;
      v_nsolici        NUMBER;
      v_norden         NUMBER;
      v_ctarifa        NUMBER;
      v_cformul        NUMBER;
      ximport          NUMBER;
      mostrar_datos    NUMBER;
      cavis            NUMBER;
      salida           EXCEPTION;
      error_fin_supl   EXCEPTION;
      onpoliza         NUMBER;
      osseguro         NUMBER;
      v_cforpag        NUMBER;
      v_sperson        NUMBER;
      v_cont           NUMBER;
      --v_CACTIVI NUMBER;
      garantiaprov     NUMBER;
      v_clave          NUMBER;
      v_numrec         NUMBER;
      v_tipo           NUMBER;
      v_tipomov        NUMBER;
      v_cempres        seguros.cempres%TYPE;
      v_cidioma        seguros.cidioma%TYPE;
   BEGIN
      IF    psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR pimporte IS NULL
         OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
  /*
  numerr := f_buscapoliza (psseguro, v_npoliza, v_ncertif);

  IF numerr <> 0
  THEN
     PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr);
     RAISE error_fin_supl;
  END IF;

  numerr :=
     pac_md_suplementos.f_valida_poliza_permite_supl  (v_npoliza, v_ncertif,
                                    trunc(fecha), 500,
                                    mensajes );

  IF numerr <> 0
  THEN
     PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr);
     RAISE error_fin_supl;
  END IF;*/
--------------------------------------------------------------------------
-- Validar que la cuenta está permitida
----------------------------------------------------------------------------Se ha hecho desde la pantalla
--numerr := f_valida_ccc(pcbancar,mensajes);
--IF numerr <> 0 THEN
--   PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr);
--     RAISE Salida;
--END IF;

      --------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT sproduc, cforpag, cactivi, ncertif, cempres, cidioma
        INTO v_sproduc, v_cforpag, v_cactivi, v_ncertif, v_cempres, v_cidioma
        FROM seguros
       WHERE sseguro = psseguro;

      --Bug.: 18632 - ICV - 07/06/2011
      IF     NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                  0
                 ) = 1
         AND v_ncertif = 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 9902072);
         RAISE error_fin_supl;
      END IF;

      --Fi Bug.:18632
      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro AND norden = 1;

      vpasexec := 4;

      BEGIN
         SELECT g.cgarant, g.norden, g.ctarifa, g.cformul,
                f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                )
           INTO v_cgarant, v_norden, v_ctarifa, v_cformul,
                v_tipo
           FROM garanpro g, seguros s
          WHERE g.sproduc = s.sproduc
            AND g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ctipseg = s.ctipseg
            AND g.ccolect = s.ccolect
            AND g.cactivi = s.cactivi
            AND g.cgarant = pcgarant        --JRH Ahora escogemos la garantía
            AND f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                ) IN (4, 12)
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101959);
            RAISE salida;
      END;

      IF v_tipo = 4
      THEN
         v_tipomov := 500;                       -- Aportación Extaordinaria
      ELSE
         v_tipomov := 556;                                              -- PB
      END IF;

      -- Bug 38745/219383
      FOR reg IN (SELECT sperson
                    FROM tomadores
                   WHERE sseguro = psseguro)
      LOOP
         numerr :=
            pac_listarestringida.f_valida_accion_lre (v_cempres,
                                                      v_cidioma,
                                                      psseguro,
                                                      reg.sperson,
                                                      v_tipomov
                                                     );

         IF numerr <> 0
         THEN
            EXIT;
         END IF;
      END LOOP;

      IF numerr <> 0
      THEN
         RETURN numerr;
      END IF;
-------------------------------------------------------------------------------------------
-- Se traspasan los datos a las tablas EST y se dejan preparadas para hacer el suplemento
-------------------------------------------------------------------------------------------
-- Todas las funciones a partir de esta deben tener RAISE error_fin_supl
      IF v_est_sseguro IS NULL
      THEN     --Si ya tenemos el suplemento en las EST no lo creamos de nuevo
         -- DBMS_OUTPUT.put_line ('000:' || v_est_sseguro);
         numerr :=
            pac_md_suplementos.f_editarsuplemento (psseguro,
                                                   v_tipomov,
                                                   TRUNC (fecha),
                                                   v_nmovimi,
                                                   v_est_sseguro,
                                                   mensajes
                                                  );

         IF numerr <> 0
         THEN
            --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
            RAISE error_fin_supl;
         END IF;

         pac_iax_produccion.issuplem := TRUE;
         pac_iax_produccion.isaltacol := FALSE;
         pac_iax_produccion.vsseguro := psseguro;
         pac_iax_produccion.vnmovimi := v_nmovimi;
         pac_iax_produccion.vsolicit := v_est_sseguro;
      END IF;

      vpasexec := 7;
      /*
      BEGIN
         SELECT g.cgarant, g.norden, g.ctarifa, g.cformul
           INTO v_cgarant, v_norden, v_ctarifa, v_cformul
           FROM garanpro g, estseguros s
          WHERE g.sproduc = s.sproduc
            AND g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ctipseg = s.ctipseg
            AND g.ccolect = s.ccolect
            AND g.cactivi = s.cactivi
            AND g.cgarant = pcgarant --JRH Ahora escogemos la garantía
            AND f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                ) = 4
            AND s.sseguro = v_est_sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101959);
            RAISE salida;
      END;*/
      vpasexec := 5;

-------------------------------------------------------------------------------------------
-- Se registra la aportación extraordinaria en las tablas EST
-------------------------------------------------------------------------------------------
      BEGIN
         --  dbms_output.put_line('1:'||1);
         INSERT INTO estgaranseg
                     (cgarant, sseguro, nriesgo, finiefe,
                      norden, crevali, ctarifa, icapital, precarg, iprianu,
                      iextrap, ffinefe, cformul, ctipfra, ifranqu, irecarg,
                      ipritar, pdtocom, idtocom, prevali, irevali, itarifa,
                      nmovimi, itarrea, ipritot, icaptot, nmovima, cobliga
                     )
              VALUES (v_cgarant, v_est_sseguro, pnriesgo, TRUNC (fecha),
                      v_norden, 0, v_ctarifa, pimporte, NULL, 0,
                      NULL, NULL, v_cformul, NULL, NULL, 0,
                      0, NULL, 0, NULL, NULL, NULL,
                      v_nmovimi, NULL, 0, pimporte, v_nmovimi, 1
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            vpasexec := 7;

--dbms_output.put_line('2:'||2);
            BEGIN
               UPDATE estgaranseg
                  SET icapital = pimporte,
                      icaptot = pimporte,
                      nmovima = v_nmovimi,
                      cobliga = 1
                WHERE cgarant = v_cgarant
                  AND nriesgo = pnriesgo
                  AND nmovimi = v_nmovimi
                  AND sseguro = v_est_sseguro
                  AND finiefe = TRUNC (fecha);
            EXCEPTION
               WHEN OTHERS
               THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101959);
                  RAISE error_fin_supl;
            END;
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101959);
            RAISE error_fin_supl;
      END;

      vpasexec := 9;
      numerr :=
         pac_md_validaciones.f_validacion_capital (v_est_sseguro,
                                                   pnriesgo,
                                                   v_nmovimi,
                                                   v_cgarant,
                                                   v_sproduc,
                                                   v_cactivi,
                                                   v_nmovimi,
                                                   'SEL',
                                                   mensajes
                                                  );

      IF numerr <> 0
      THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE salida;
      END IF;

      vpasexec := 11;
      numerr :=
         pac_md_validaciones_aho.f_valida_capitales_gar (v_sproduc,
                                                         v_cgarant,
                                                         pimporte,
                                                         2,
                                                         TRUNC (fecha),
                                                         2,
                                                         mensajes
                                                        );

      IF numerr <> 0
      THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE salida;
      END IF;

      vpasexec := 13;
      numerr :=
         pac_md_produccion.f_tarifar_riesgo_tot ('EST',
                                                 v_est_sseguro,
                                                 pnriesgo,
                                                 v_nmovimi,
                                                 TRUNC (fecha),
                                                 mensajes
                                                );

      IF numerr <> 0
      THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 9;
      numerr :=
         pac_md_suplementos.f_validar_cambios (v_est_sseguro,
                                               v_nmovimi,
                                               v_sproduc,
                                               mensajes,
                                               v_tipomov
                                              );
     -- Bug 20672 - RSC - 14/02/2012 - LCOL_T001-LCOL - UAT - TEC: Suplementos

      IF numerr <> 0
      THEN
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 10;

      -- dramon 08-10-2008: bug mantis 7417
      -- Validamos si tiene algun recibo pendiente de cobro y mostramos mensaje de ello
      SELECT COUNT (1)
        INTO v_numrec
        FROM recibos r
       WHERE r.sseguro = psseguro
         AND r.ctiprec = 4
         AND EXISTS (
                SELECT '1'
                  FROM movrecibo m
                 WHERE m.nrecibo = r.nrecibo
                   AND m.smovrec = f_movrecibo_ult (m.nrecibo)
                   AND m.cestrec = 0);

      IF v_numrec > 0
      THEN
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 2, 9000516);
      END IF;

      vpasexec := 12;

      --Calculamos el capital garantizado
      --capitalGaran:=Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(v_est_sseguro, F_SYSDATE, 'ICAPGAR');

      /*SELECT DISTINCT g.cgarant,garan.clave
      into garantiaProv,v_CLAVE
      FROM estgaranseg g, estseguros s,garanformula garan
      WHERE g.sseguro = s.sseguro
        AND F_Pargaranpro_V(s.cramo, s.cmodali, s.ctipseg, s.ccolect,s.cactivi, g.cgarant, 'CALCULA_PROVI') = 1
        AND s.sseguro = v_est_sseguro
        AND garan.cramo =  s.cramo
        AND garan.cmodali = s.cmodali
        AND garan.ctipseg = s.ctipseg
        AND garan.ccolect = s.ccolect
        AND garan.cgarant = g.cgarant
        AND garan.ccampo = 'ICGARAC';*/
      SELECT SUM (g.icapital)  --Obtenemos directamente el capital garantizado
        INTO capitalgaran
        FROM estgaranseg g, estseguros s
       WHERE s.sseguro = v_est_sseguro
         AND g.sseguro = s.sseguro
         AND f_pargaranpro_v (s.cramo,
                              s.cmodali,
                              s.ctipseg,
                              s.ccolect,
                              s.cactivi,
                              g.cgarant,
                              'TIPO'
                             ) = 5;

      /*num_err := Pac_Calculo_Formulas.CALC_FORMUL ( F_SYSDATE, v_sproduc, v_CACTIVI, garantiaProv,
                    1, v_est_sseguro, v_CLAVE, capitalGaran, NULL, NULL, 1, F_SYSDATE, 'R' );*/
      -- capitalgaran := ROUND (capitalgaran, 2);
      capitalgaran :=
             f_round (capitalgaran
                                  -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                      , pac_monedas.f_moneda_producto (v_sproduc)
                                                                 -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
             );

      --COMMIT;
      IF tarif
      THEN                                              --Si sólo tarificamos
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN error_fin_supl
      THEN
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN salida
      THEN
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_tarif_aport_extraordinaria;

   --JRH 03/2008

   --JRH 03/2008
      /*************************************************************************
         Valida y realiza una aportación extraordinaria
         param in psseguro  : póliza
         param in pnriesgo  : riesgo
         param in fecha     : fecha de la aportación
         pimporte           : Importe de la aportación
         pctipban           : Tipo de cuenta.
         pcbancar           : Cuenta bancaria.
         param out mensajes : mensajes de error
         pcommit            : (1) Guardar (valor por defecto), (0) No guardar.
         pctipapor in       : Tipo de aportación
         psperapor in       : Persona aportante
         ptipoaportante in  : Tipo de aportante
         return             : 0 todo correcto
                            1 ha habido un error
      *************************************************************************/
   FUNCTION f_aportacion_extraordinaria(
      psseguro         IN       NUMBER,
      pnriesgo         IN       NUMBER,
      fecha            IN       DATE,
      pimporte         IN       NUMBER,
      pctipban         IN       NUMBER,
      pcbancar         IN       VARCHAR2,
      pcgarant         IN       NUMBER,
      pnmovimi         OUT      NUMBER,
      mensajes         OUT      t_iax_mensajes,
      pcommit          IN       NUMBER DEFAULT 1,
      pctipapor        IN       NUMBER DEFAULT NULL,
      psperapor        IN       NUMBER DEFAULT NULL,
      pcobrorec        IN       NUMBER DEFAULT 1,
      pccobban         IN       NUMBER DEFAULT NULL,
      ptipoaportante   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      -- Bug 0014185 - JMF - 25/05/2010: Añadir parametro pcommit
      numerr           NUMBER                   := 0;
      vpasexec         NUMBER (8)               := 1;
      vparam           VARCHAR2 (400)
         :=    'psproduc= '
            || psseguro
            || ' pnriesgo= '
            || pnriesgo
            || ' pcgarant= '
            || pcgarant
            || ' fecha= '
            || fecha
            || ' pimporte= '
            || pimporte
            || ' pctipban= '
            || pctipban
            || ' pcbancar= '
            || pcbancar
            || ' pcommit='
            || pcommit
            || ' pctipapor='
            || pctipapor
            || ' psperapor= '
            || psperapor;
      vobject          VARCHAR2 (200)
                             := 'PAC_MD_SUP_FINAN.f_aportacion_extraordinaria';
      num_err          NUMBER;
      v_cgarant        NUMBER;
      v_sproduc        NUMBER;
      v_cactivi        NUMBER;
      v_npoliza        NUMBER;
      v_ncertif        NUMBER;
      v_nrecibo        NUMBER;
      v_nsolici        NUMBER;
      v_norden         NUMBER;
      v_ctarifa        NUMBER;
      v_cformul        NUMBER;
      ximport          NUMBER;
      mostrar_datos    NUMBER;
      cavis            NUMBER;
      salida           EXCEPTION;
      error_fin_supl   EXCEPTION;
      onpoliza         NUMBER;
      osseguro         NUMBER;
      v_cforpag        NUMBER;
      v_sperson        NUMBER;
      v_cont           NUMBER;
      capitalgaran     NUMBER;
      vnmovimi         NUMBER;
      vsinterf         NUMBER;
      verror           VARCHAR2 (2000);
      vctipcob         NUMBER;
      vctipban         NUMBER;
      vnrecibo         NUMBER;
      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      v_tipo           NUMBER;
      v_tipomov        motmovseg.cmotmov%TYPE;
      -- Fin Bug 18062
      v_cagrpro        seguros.cagrpro%TYPE;
      v_cempres        NUMBER;
   BEGIN
      IF    psseguro IS NULL
         OR pnriesgo IS NULL
         OR fecha IS NULL
         OR pimporte IS NULL
         --OR pctipban IS NULL
         --OR pcbancar IS NULL
         OR pcgarant IS NULL
      THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
--------------------------------------------------------------------------
-- Validar que la cuenta está permitida
--Se hace desde la pantalla
--------------------------------------------------------------------------
--numerr := f_valida_ccc(pcbancar,mensajes);
--IF numerr <> 0 THEN
--   PAC_IOBJ_MENSAJES.CREA_NUEVO_MENSAJE(mensajes,1,numerr);
--     RAISE Salida;
--END IF;

      --------------------------------------------------------------------------
-- Validar el importe de la prima (si pprima <> 0)
--------------------------------------------------------------------------
      vpasexec := 2;

      SELECT sproduc, cforpag, ctipcob, ctipban, cagrpro
        INTO v_sproduc, v_cforpag, vctipcob, vctipban, v_cagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 3;

      SELECT sperson
        INTO v_sperson
        FROM asegurados
       WHERE sseguro = psseguro AND norden = 1;

      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      BEGIN
         SELECT g.cgarant, g.norden, g.ctarifa, g.cformul,
                f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                )
           INTO v_cgarant, v_norden, v_ctarifa, v_cformul,
                v_tipo
           FROM garanpro g, seguros s
          WHERE g.sproduc = s.sproduc
            AND g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ctipseg = s.ctipseg
            AND g.ccolect = s.ccolect
            AND g.cactivi = s.cactivi
            AND g.cgarant = pcgarant
            AND f_pargaranpro_v (g.cramo,
                                 g.cmodali,
                                 g.ctipseg,
                                 g.ccolect,
                                 g.cactivi,
                                 g.cgarant,
                                 'TIPO'
                                ) IN (4, 12)
            AND s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, 101959);
            RAISE error_fin_supl;
      END;

      IF v_tipo = 4
      THEN
         v_tipomov := 500;                       -- Aportación Extaordinaria
      ELSE
         v_tipomov := 556;                                              -- PB
      END IF;

      -- Fin bug 18062
      vpasexec := 4;
      --Tarificamos el suplemento nuevamente.
      tarif := FALSE;                              --Completamos el suplemento
      numerr :=
         f_tarif_aport_extraordinaria (psseguro,
                                       pnriesgo,
                                       TRUNC (fecha),
                                       pimporte,
                                       pcgarant,
                                       capitalgaran,
                                       mensajes
                                      );

      IF numerr <> 0
      THEN
         vpasexec := 5;
         pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, numerr);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 6;
-------------------------------------------------------------------------------------------
-- Se graba el suplemento en las tablas reales
-------------------------------------------------------------------------------------------

      --numerr := pk_suplementos.f_grabar_suplemento_poliza(v_est_sseguro, v_nmovimi);
      numerr :=
            pac_md_suplementos.f_traspasarsuplemento (v_est_sseguro, mensajes);

      IF numerr <> 0
      THEN
         vpasexec := 7;
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE error_fin_supl;
      END IF;

      vpasexec := 8;
-------------------------------------------------------------------------------------------
-- Se emite el suplemento
-------------------------------------------------------------------------------------------
      numerr :=
         pac_md_produccion.f_emitir_propuesta (v_est_sseguro,
                                               onpoliza,
                                               osseguro,
                                               vnmovimi,
                                               mensajes
                                              );
      pnmovimi := vnmovimi;

      IF numerr <> 0
      THEN
         vpasexec := 9;
         --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, numerr);
         RAISE error_fin_supl;
      END IF;

      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      IF v_tipomov = 500
      THEN
         -- Fin Bug 18062

         --BUG16992 - JTS - 18/11/2010
         SELECT nrecibo
           INTO vnrecibo
           FROM recibos
          WHERE sseguro = psseguro AND nmovimi = pnmovimi;

         --IF pcbancar IS NOT NULL THEN
         numerr :=
               pac_gestion_rec.f_set_reccbancar (vnrecibo, pcbancar, pctipban);

         --END IF;
         IF numerr <> 0
         THEN
            vpasexec := 91;
            RAISE e_object_error;
         END IF;

         --Fi BUG16992

         --Bug.: 18632 - ICV - 07/06/2011
         IF pccobban IS NOT NULL
         THEN
            UPDATE recibos
               SET ccobban = pccobban
             WHERE nrecibo = vnrecibo;
         END IF;

         IF v_cagrpro = 11
         THEN
            IF pctipapor IS NOT NULL
            THEN
               numerr :=
                  pac_gestion_rec.f_set_aportante (vnrecibo,
                                                   pctipapor,
                                                   psperapor,
                                                   NVL (ptipoaportante,
                                                        pctipapor
                                                       )
                                                  );
--De momento hasta que se incluya por pantalla el tipo aportante se deja el nvl ya que coinciden las dos listas (PROVISIONAL)
            END IF;
         END IF;

         IF numerr <> 0
         THEN
            vpasexec := 92;
            RAISE e_object_error;
         END IF;

         IF vnrecibo IS NOT NULL
         THEN
            SELECT cempres
              INTO v_cempres
              FROM recibos r
             WHERE r.nrecibo = vnrecibo;
         END IF;

         --Bug.: 20923 - 14/01/2012 - ICV
         IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                    'GESTIONA_COBPAG'
                                                   ),
                     0
                    ) = 1
            AND pcobrorec = 1
         THEN
            num_err :=
               pac_ctrl_env_recibos.f_proc_recpag_mov (v_cempres,
                                                       psseguro,
                                                       pnmovimi,
                                                       4,
                                                       NULL,
                                                       1
                                                      );
         --comentado de momento
         --Si ha dado error
         /*  IF numerr <> 0 THEN
              vpasexec := 921;
              RAISE e_object_error;
           END IF;*/
         END IF;
      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      END IF;

      -- Fin Bug 18062
      vpasexec := 10;

      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      --IF v_tipomov = 500 THEN
         -- Fin Bug 18062
      IF     (pac_mdpar_productos.f_get_parproducto ('COBRO_AUTOMATICO',
                                                     v_sproduc
                                                    ) = 1
             )
         AND numerr = 0
      THEN
         numerr :=
            pac_md_produccion.f_cobro_recibos (psseguro,
                                               vnmovimi,
                                               vctipcob,
                                               pctipban,
                                               pcbancar,
                                               mensajes
                                              );

         IF numerr <> 0
         THEN
            vpasexec := 11;
            -- pac_iobj_mensajes.crea_nuevo_mensaje (mensajes, 1, numerr);
            RAISE error_fin_supl;
         END IF;
      END IF;

      -- Bug 18062 - RSC - 28/03/2011 - AGA800 - ERROR en el calculo del valor de rescate póliza 35000056
      --END IF;

      -- Fin Bug 18062
      tarif := TRUE;
      v_est_sseguro := NULL;
      vpasexec := 14;

      -- Bug 0014185 - JMF - 25/05/2010
      IF pcommit = 1
      THEN
         COMMIT;
      END IF;

      -- BUG19863:DRA:21/10/2011: Se pasa el parametro a productos
      IF NVL (pac_parametros.f_parproducto_n (v_sproduc, 'INT_SINCRON_POLIZA'),
              0
             ) = 1
      THEN
         numerr :=
            pac_md_con.f_proceso_alta
                                   (pac_md_common.f_get_cxtempresa, -- empresa
                                    osseguro,                         --seguro
                                    vnmovimi,                       -- nmovimi
                                    'M',         -- A (alta ) 'M' (suplemento)
                                    f_user,                           -- fuser
                                    vsinterf,                       -- ni caso
                                    verror                          -- ni caso
                                   );

         -- Bug 0014185 - JMF - 25/05/2010
         IF pcommit = 1
         THEN
            COMMIT;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         tarif := TRUE;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         tarif := TRUE;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN error_fin_supl
      THEN
         tarif := TRUE;
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         RETURN 1;
      WHEN salida
      THEN
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         tarif := TRUE;
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS
      THEN
         tarif := TRUE;
         ROLLBACK;
         numerr :=
            pk_suplementos.f_final_suplemento (v_est_sseguro,
                                               v_nmovimi,
                                               psseguro
                                              );
         COMMIT;
         v_est_sseguro := NULL;
         v_nmovimi := NULL;
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_aportacion_extraordinaria;

   --Acción post suple para la participación en beneficios.
   FUNCTION f_insert_ctaseg(psseguro IN NUMBER)
      RETURN NUMBER
   IS
      CURSOR nmov
      IS
         SELECT   movseguro.nmovimi, movseguro.fefecto, movseguro.fmovimi
             FROM movseguro, detmovseguro
            WHERE movseguro.sseguro = psseguro
              AND detmovseguro.sseguro = movseguro.sseguro
              AND detmovseguro.nmovimi = movseguro.nmovimi
              AND detmovseguro.cmotmov = 556
         ORDER BY nmovimi DESC;

      v_nomvimi   NUMBER;
      xnnumlin    NUMBER;
      vcapital    NUMBER;
      vfefecto    DATE;
      vfmovimi    DATE;
      num_err     NUMBER;
   BEGIN
      OPEN nmov;

      FETCH nmov
       INTO v_nomvimi, vfefecto, vfmovimi;

      CLOSE nmov;

      SELECT icapital
        INTO vcapital
        FROM garanseg g, seguros s
       WHERE g.sseguro = s.sseguro
         AND g.nmovimi = v_nomvimi
         AND g.nriesgo = 1                             --JRH IMP De momento!!!
         AND f_pargaranpro_v (s.cramo,
                              s.cmodali,
                              s.ctipseg,
                              s.ccolect,
                              s.cactivi,
                              g.cgarant,
                              'TIPO'
                             ) = 12
         AND s.sseguro = psseguro;

      BEGIN
         SELECT MAX (nnumlin)
           INTO xnnumlin
           FROM ctaseguro
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 103066;    -- Assegurança no trobada a la taula CTASEGURO
         WHEN OTHERS
         THEN
            RETURN 104882;                    -- Error al llegir de CTASEGURO
      END;

      num_err :=
         pac_ctaseguro.f_insctaseguro (psseguro,
                                       f_sysdate,
                                       NVL (xnnumlin, 0) + 1,
                                       vfefecto,
                                       vfefecto,
                                       9,         --pcmovimi, Part. Beneficios
                                       vcapital,
                                       vcapital,
                                       NULL,
                                       0,
                                       0,
                                       NULL,
                                       NULL,
                                       NULL,
                                       'R',
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL
                                      );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      IF pac_ctaseguro.f_tiene_ctashadow (psseguro, NULL) = 1
      THEN
         num_err :=
            pac_ctaseguro.f_insctaseguro_shw (psseguro,
                                              f_sysdate,
                                              NVL (xnnumlin, 0) + 1,
                                              vfefecto,
                                              vfefecto,
                                              9,  --pcmovimi, Part. Beneficios
                                              vcapital,
                                              vcapital,
                                              NULL,
                                              0,
                                              0,
                                              NULL,
                                              NULL,
                                              NULL,
                                              'R',
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL
                                             );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;
      END IF;

      RETURN 0;
   END f_insert_ctaseg;

   --Bug.: 18632 - ICV - 06/06/2011

   /*************************************************************************
   param in psseguro  : póliza
   param out mensajes : mensajes de error
   return             : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_aportantes(
      psseguro   IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN sys_refcursor
   IS
      cur         sys_refcursor;
      vpasexec    NUMBER (8)             := 1;
      vparam      VARCHAR2 (1)           := NULL;
      vobject     VARCHAR2 (200)   := 'PAC_IAX_MD_SUP_FINAN.f_get_aportantes';
      squery      VARCHAR2 (4000);
      v_sproduc   seguros.sproduc%TYPE;
      v_ncertif   seguros.ncertif%TYPE;
      v_cagrpro   seguros.cagrpro%TYPE;
   BEGIN
      vpasexec := 1;

      SELECT sproduc, ncertif, cagrpro
        INTO v_sproduc, v_ncertif, v_cagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;

      IF v_cagrpro <> 11
      THEN
         RETURN NULL;
      END IF;

      IF     NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                  0
                 ) = 1
         AND v_ncertif = 0
      THEN
         squery :=
               'select catribu, tatribu, 1 cdefecto from detvalores where cvalor = 680
                   and cidioma = '
            || pac_md_common.f_get_cxtidioma ()
            || ' and catribu = 4';
      ELSIF     NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                     'ADMITE_CERTIFICADOS'
                                                    ),
                     0
                    ) = 1
            AND v_ncertif <> 0
      THEN
         squery :=
               'select catribu, tatribu, decode(catribu,5,1,0) cdefecto
                       from detvalores where cvalor = 680
                       and cidioma = '
            || pac_md_common.f_get_cxtidioma ()
            || ' and catribu in (4,5)';
      ELSIF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 0
      THEN
         squery :=
               'select catribu, tatribu, decode(catribu,1,1,0) cdefecto
                       from detvalores where cvalor = 680
                       and cidioma = '
            || pac_md_common.f_get_cxtidioma ()
            || ' and catribu in (1,5)';
      END IF;

      vpasexec := 3;
      cur := pac_iax_listvalores.f_opencursor (squery, mensajes);
      vpasexec := 4;

      IF pac_md_log.f_log_consultas (squery, vobject, 2, 4, mensajes) <> 0
      THEN
         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_aportantes;

   /*************************************************************************
   param in pctipapor  : Tipo Aportante
   param in sseguro : Identificador del seguro
   param out psperapor  : Sperson del aportante
   param out pcagente  : Cagente del aportante
   param out mensajes : mensajes de error
   return             : 0 correcto 1 error
   *************************************************************************/
   FUNCTION f_get_infoaportante(
      pctipapor   IN       NUMBER,
      psseguro    IN       NUMBER,
      psperapor   OUT      NUMBER,
      pcagente    OUT      NUMBER,
      mensajes    IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      num_err     NUMBER                 := 0;
      vpasexec    NUMBER (8)             := 1;
      vparam      VARCHAR2 (400)         := 'pctipapor= ' || pctipapor;
      vobject     VARCHAR2 (200)    := 'PAC_MD_SUP_FINAN.f_get_infoaportante';
      v_sproduc   seguros.sproduc%TYPE;
      v_ncertif   seguros.ncertif%TYPE;
      v_npoliza   seguros.npoliza%TYPE;
      v_cagrpro   seguros.cagrpro%TYPE;
   BEGIN
      vpasexec := 1;

      SELECT sproduc, ncertif, npoliza, cagrpro
        INTO v_sproduc, v_ncertif, v_npoliza, v_cagrpro
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      pcagente := ff_agente_cpervisio (pac_md_common.f_get_cxtagente ());

      --Funcionamiento normal sin aportante
      IF pctipapor IS NULL OR v_cagrpro <> 11
      THEN
         BEGIN
            SELECT sperson
              INTO psperapor
              FROM tomadores t
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               SELECT sperson
                 INTO psperapor
                 FROM tomadores t
                WHERE sseguro = psseguro AND nordtom = 1;
         END;
      END IF;

      IF     NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                  'ADMITE_CERTIFICADOS'
                                                 ),
                  0
                 ) = 1
         AND v_ncertif = 0
      THEN
         BEGIN
            SELECT sperson
              INTO psperapor
              FROM tomadores t
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN TOO_MANY_ROWS
            THEN
               SELECT sperson
                 INTO psperapor
                 FROM tomadores t
                WHERE sseguro = psseguro AND nordtom = 1;
         END;
      ELSIF     NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                     'ADMITE_CERTIFICADOS'
                                                    ),
                     0
                    ) = 1
            AND v_ncertif <> 0
      THEN
         IF pctipapor = 4
         THEN
            BEGIN
               SELECT t.sperson
                 INTO psperapor
                 FROM seguros s, tomadores t
                WHERE s.sseguro = t.sseguro
                  AND s.ncertif = 0
                  AND s.npoliza = v_npoliza;
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  SELECT t.sperson
                    INTO psperapor
                    FROM seguros s, tomadores t
                   WHERE s.sseguro = t.sseguro
                     AND s.ncertif = 0
                     AND t.nordtom = 1
                     AND s.npoliza = v_npoliza;
            END;
         ELSIF pctipapor = 5
         THEN
            BEGIN
               SELECT sperson
                 INTO psperapor
                 FROM tomadores t
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  SELECT sperson
                    INTO psperapor
                    FROM tomadores t
                   WHERE sseguro = psseguro AND nordtom = 1;
            END;
         END IF;
      ELSIF NVL (pac_parametros.f_parproducto_n (v_sproduc,
                                                 'ADMITE_CERTIFICADOS'
                                                ),
                 0
                ) = 0
      THEN
         IF pctipapor = 1
         THEN
            BEGIN
               SELECT sperson
                 INTO psperapor
                 FROM tomadores t
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN TOO_MANY_ROWS
               THEN
                  SELECT sperson
                    INTO psperapor
                    FROM tomadores t
                   WHERE sseguro = psseguro AND nordtom = 1;
            END;
         ELSIF pctipapor = 5
         THEN
            SELECT a.sperson
              INTO psperapor
              FROM asegurados a
             WHERE a.sseguro = psseguro AND a.norden = 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000005,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN e_object_error
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000006,
                                            vpasexec,
                                            vparam
                                           );
         RETURN 1;
      WHEN OTHERS
      THEN
         pac_iobj_mensajes.p_tratarmensaje (mensajes,
                                            vobject,
                                            1000001,
                                            vpasexec,
                                            vparam,
                                            psqcode      => SQLCODE,
                                            psqerrm      => SQLERRM
                                           );
         RETURN 1;
   END f_get_infoaportante;
--Fi Bug.: 18632
END pac_md_sup_finan;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SUP_FINAN" TO "PROGRAMADORESCSI";
