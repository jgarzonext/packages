--------------------------------------------------------
--  DDL for Package Body PAC_FUSIONPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_FUSIONPERSONA" IS
    /*************************************************************************
      Función que actualiza el sperson de las tablas que contienen personas.
        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_actualiza_sperson(pspersonori IN NUMBER, pspersondes IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
   BEGIN
      INSERT INTO fusiontomadores
                  (spersonori, sseguroori, cdomiciori, spersondes, cdomicides, cusuari,
                   fmovimi)
         SELECT sperson, sseguro, cdomici, pspersondes, NULL, f_user, f_sysdate
           FROM tomadores
          WHERE sperson = pspersonori
            AND cdomici IS NULL;

      UPDATE tomadores
         SET sperson = pspersondes
       WHERE sperson = pspersonori
         AND cdomici IS NULL;

      INSERT INTO fusionasegurados
                  (spersonori, sseguroori, cdomiciori, spersondes, cdomicides, cusuari,
                   fmovimi)
         SELECT sperson, sseguro, cdomici, pspersondes, NULL, f_user, f_sysdate
           FROM asegurados
          WHERE sperson = pspersonori
            AND cdomici IS NULL;

      vtraza := 1;

      UPDATE asegurados
         SET sperson = pspersondes
       WHERE sperson = pspersonori
         AND cdomici IS NULL;

      vtraza := 2;

      INSERT INTO fusionriesgos
                  (nriesgoori, spersonori, sseguroori, cdomiciori, spersondes, cdomicides,
                   cusuari, fmovimi)
         SELECT nriesgo, sperson, sseguro, cdomici, pspersondes, NULL, f_user, f_sysdate
           FROM riesgos
          WHERE sperson = pspersonori
            AND cdomici IS NULL;

      UPDATE riesgos
         SET sperson = pspersondes
       WHERE sperson = pspersonori
         AND cdomici IS NULL;

-------------------------------------------------------------------------------
-------------------------- Conductores
-------------------------------------------------------------------------------
      vtraza := 3;

      INSERT INTO fusionautconductores
                  (spersonori, sseguroori, cdomiciori, spersondes, cdomicides, cusuari,
                   fmovimi)
         SELECT sperson, sseguro, cdomici, pspersondes, NULL, f_user, f_sysdate
           FROM autconductores
          WHERE sperson = pspersonori
            AND cdomici IS NULL;

      UPDATE autconductores
         SET sperson = pspersondes
       WHERE sperson = pspersonori
         AND cdomici IS NULL;

 -------------------------------------------------------------------------------
-------------------------- Beneficiarios especiales
-------------------------------------------------------------------------------
      vtraza := 4;

      INSERT INTO fusionbenespseg
                  (sseguroori, nriesgoori, cgarantori, nmovimiori, spersonori, sperson_titori,
                   spersondes, sperson_titdes, cusuari, fmovimi)
         SELECT sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit, pspersondes, NULL,
                f_user, f_sysdate
           FROM benespseg
          WHERE sperson = pspersonori;

      UPDATE benespseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 5;

      INSERT INTO fusionbenespseg
                  (sseguroori, nriesgoori, cgarantori, nmovimiori, spersonori, sperson_titori,
                   spersondes, sperson_titdes, cusuari, fmovimi)
         SELECT sseguro, nriesgo, cgarant, nmovimi, sperson, sperson_tit, NULL, pspersondes,
                f_user, f_sysdate
           FROM benespseg
          WHERE sperson = pspersonori;

      UPDATE benespseg
         SET sperson_tit = pspersondes
       WHERE sperson_tit = pspersonori;

 -------------------------------------------------------------------------------
-------------------------- pagadores y gestores del cobro
-------------------------------------------------------------------------------
      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'gescobros', sperson, pspersondes, f_user, f_sysdate
           FROM gescobros
          WHERE sperson = pspersonori;

      UPDATE gescobros
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 6;

-------------------------------------------------------------------------------
-------------------------- Inquilinos y avalistas
-------------------------------------------------------------------------------
      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'inquiaval', sperson, pspersondes, f_user, f_sysdate
           FROM inquiaval
          WHERE sperson = pspersonori;

      UPDATE inquiaval
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 7;

-------------------------------------------------------------------------------
-------------------------- Retorno
-------------------------------------------------------------------------------
      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'rtn_convenio', sperson, pspersondes, f_user, f_sysdate
           FROM rtn_convenio
          WHERE sperson = pspersonori;

      UPDATE rtn_convenio
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 8;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'agensini', sperson, pspersondes, f_user, f_sysdate
           FROM agensini
          WHERE sperson = pspersonori;

      UPDATE agensini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 9;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'agentes', sperson, pspersondes, f_user, f_sysdate
           FROM agentes
          WHERE sperson = pspersonori;

      UPDATE agentes
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 10;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'agentes_save', sperson, pspersondes, f_user, f_sysdate
           FROM agentes_save
          WHERE sperson = pspersonori;

      UPDATE agentes_save
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'agentes_sc', sperson, pspersondes, f_user, f_sysdate
           FROM agentes_sc
          WHERE sperson = pspersonori;

      UPDATE agentes_sc
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'anuasegurados', sperson, pspersondes, f_user, f_sysdate
           FROM anuasegurados
          WHERE sperson = pspersonori;

      UPDATE anuasegurados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'anuautconductores', sperson, pspersondes, f_user, f_sysdate
           FROM anuautconductores
          WHERE sperson = pspersonori;

      UPDATE anuautconductores
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'anubenespseg', sperson, pspersondes, f_user, f_sysdate
           FROM anubenespseg
          WHERE sperson = pspersonori
             OR sperson_tit = pspersonori;

      UPDATE anubenespseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE anubenespseg
         SET sperson_tit = pspersondes
       WHERE sperson_tit = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'anuinquiaval', sperson, pspersondes, f_user, f_sysdate
           FROM anuinquiaval
          WHERE sperson = pspersonori;

      UPDATE anuinquiaval
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'anuriesgos', sperson, pspersondes, f_user, f_sysdate
           FROM anuriesgos
          WHERE sperson = pspersonori;

      UPDATE anuriesgos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'aportaseg', sperson, pspersondes, f_user, f_sysdate
           FROM aportaseg
          WHERE sperson = pspersonori;

      UPDATE aportaseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'aseguradoras', sperson, pspersondes, f_user, f_sysdate
           FROM aseguradoras
          WHERE sperson = pspersonori;

      UPDATE aseguradoras
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE asigprotrami
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE ats_fonpensiones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE ats_gestoras
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE aux347
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 11;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'bajas', sperson, pspersondes, f_user, f_sysdate
           FROM bajas
          WHERE sperson = pspersonori;

      UPDATE bajas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'beneficiarios', sperson, pspersondes, f_user, f_sysdate
           FROM beneficiarios
          WHERE sperson = pspersonori;

      UPDATE beneficiarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE benefprestaplan
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cap_carrega_col
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cargosemp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE carrega_col
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cassdet_01
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cnvcompanias
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cnvdirecciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cnvhist
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cnvpersonas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cols_mod_personas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 12;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'companias', sperson, pspersondes, f_user, f_sysdate
           FROM companias
          WHERE sperson = pspersonori;

      UPDATE companias
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE contactos_correo
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE ctaempleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE cuestionarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'cumulos', sperson, pspersondes, f_user, f_sysdate
           FROM cumulos
          WHERE sperson = pspersonori;

      UPDATE cumulos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE depositarias
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'destinatarios', sperson, pspersondes, f_user, f_sysdate
           FROM destinatarios
          WHERE sperson = pspersonori;

      UPDATE destinatarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'destinatrami', sperson, pspersondes, f_user, f_sysdate
           FROM destinatrami
          WHERE sperson = pspersonori;

      UPDATE destinatrami
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE detctaempleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE detctaseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE diarioproftrami
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE diariotramitacion
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE dif_ci_axis
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      vtraza := 20;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'docrequerida_inqaval', sperson, pspersondes, f_user, f_sysdate
           FROM docrequerida_inqaval
          WHERE sperson = pspersonori;

      UPDATE docrequerida_inqaval
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'docrequerida_benespseg', sperson, pspersondes, f_user, f_sysdate
           FROM docrequerida_benespseg
          WHERE sperson = pspersonori;

      UPDATE docrequerida_benespseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE empleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE empleadosoficinas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'empresas', sperson, pspersondes, f_user, f_sysdate
           FROM empresas
          WHERE sperson = pspersonori;

      UPDATE empresas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE ensa_agentes
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE ensa_contactos
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE ensa_direcciones
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE ensa_personas
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      UPDATE entidades
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE envio_cobfall_dgs
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE extbscertif
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE extfedera01
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'facturas', sperson, pspersondes, f_user, f_sysdate
           FROM facturas
          WHERE sperson = pspersonori;

      UPDATE facturas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 30;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'fis_detcierrecobro', spersonp, pspersondes, f_user, f_sysdate
           FROM fis_detcierrecobro
          WHERE spersonp = pspersonori;

      UPDATE fis_detcierrecobro
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'fis_detcierrecobro_tmp', spersonp, pspersondes, f_user, f_sysdate
           FROM fis_detcierrecobro_tmp
          WHERE spersonp = pspersonori;

      UPDATE fis_detcierrecobro_tmp
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'fis_detcierrepago', spersonp, pspersondes, f_user, f_sysdate
           FROM fis_detcierrecobro
          WHERE spersonp = pspersonori;

      UPDATE fis_detcierrepago
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'fis_detcierrepago_tmp', spersonp, pspersondes, f_user, f_sysdate
           FROM fis_detcierrecobro_tmp
          WHERE spersonp = pspersonori;

      UPDATE fis_detcierrepago_tmp
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fis_detcierrepago_x
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fis_error_carga
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE fis_fse4500
         SET sperson1 = pspersondes
       WHERE sperson1 = pspersonori;

      UPDATE fis_fse4500
         SET sperson2 = pspersondes
       WHERE sperson2 = pspersonori;

      UPDATE fis_irpfpp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE fis_irpfpp_tmp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE fis_mod188
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fis_mod188_tmp
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fis_mod190
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fis_mod190_tmp
         SET spersonp = pspersondes
       WHERE spersonp = pspersonori;

      UPDATE fonpensiones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE gescartas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'gestoras', sperson, pspersondes, f_user, f_sysdate
           FROM gestoras
          WHERE sperson = pspersonori;

      UPDATE gestoras
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE his_agentes
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE his_cuestionarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE his_pagosini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE his_pagosrenta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE his_usuarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hisasegurados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 40;

      UPDATE hisctaempleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hisdetctaempleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hisdirecciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hisgescobros
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hisinquiaval
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hismedica
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE hispagosrenta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 50;

      /*  UPDATE hisper_ccc
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_contactos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_detper
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_direcciones
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_documentos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_documentos_lopd
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_identificador
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_irpf
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_irpfdescen
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_irpfmayores
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_lopd
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_lopd_cestado
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_nacionalidades
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_personas
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_personas_rel
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_sarlaft
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisper_vinculos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_ccc
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_contactos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_detper
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_direcciones
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_identificador
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisperlopd_personas
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hispersonas
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisprestaren
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisreembolsos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hissin_siniestro
           SET sperson2 = pspersondes
         WHERE sperson2 = pspersonori;

        UPDATE hissolicitudregalos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE histomadores
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE historicoriesgos
           SET sperson = pspersondes
         WHERE sperson = pspersonori;

        UPDATE hisvinculaciones
           SET sperson = pspersondes
         WHERE sperson = pspersonori;
         */
      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'inquiaval', sperson, pspersondes, f_user, f_sysdate
           FROM inquiaval
          WHERE sperson = pspersonori;

      UPDATE inquiaval
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE int_carga_ctrl_linea
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      UPDATE irpf_prestaciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE irpfdescendientes
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE irpfmayores
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE irpfpersonas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE localizatrami
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'lre_cartera', sperson, pspersondes, f_user, f_sysdate
           FROM lre_cartera
          WHERE sperson = pspersonori;

      UPDATE lre_cartera
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'lre_personas', sperson, pspersondes, f_user, f_sysdate
           FROM lre_personas
          WHERE sperson = pspersonori;

      UPDATE lre_personas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE medicos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE medpago
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

/*      UPDATE mig_asegurados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_benespseg
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_destinatarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_direcciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_gescartas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_pagosini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_pagosrenta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_riesgos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_seguros
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_sin_tramita_agenda
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_sin_tramita_dest
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_sin_tramita_pago
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE mig_tramitacionsini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE migcontactos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE migdirecciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE migpersonas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;
       */
      UPDATE mod_personas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'nacionalidad', sperson, pspersondes, f_user, f_sysdate
           FROM nacionalidad
          WHERE sperson = pspersonori;

      UPDATE nacionalidad
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE novisita
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 60;

      UPDATE oficinas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE pagos_tmp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'pagosini', sperson, pspersondes, f_user, f_sysdate
           FROM pagosini
          WHERE sperson = pspersonori;

      UPDATE pagosini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'pagosinitrami', sperson, pspersondes, f_user, f_sysdate
           FROM pagosinitrami
          WHERE sperson = pspersonori;

      UPDATE pagosinitrami
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'pagosrenta', sperson, pspersondes, f_user, f_sysdate
           FROM pagosrenta
          WHERE sperson = pspersonori;

      UPDATE pagosrenta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE perso_usu
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE personas_cl_agentes
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE personas_mv
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE personas_temp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE personas_ulk
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'personasdep', sperson, pspersondes, f_user, f_sysdate
           FROM personasdep
          WHERE sperson = pspersonori;

      UPDATE personasdep
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE personaslopd
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE pila_cumulos
         SET sperson1 = pspersondes
       WHERE sperson1 = pspersonori;

      UPDATE pila_cumulos
         SET sperson2 = pspersondes
       WHERE sperson2 = pspersonori;

      UPDATE pila_personas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'planbenefpresta', sperson, pspersondes, f_user, f_sysdate
           FROM planbenefpresta
          WHERE sperson = pspersonori;

      UPDATE planbenefpresta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE ppa_temp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'prestaplan', sperson, pspersondes, f_user, f_sysdate
           FROM prestaplan
          WHERE sperson = pspersonori;

      UPDATE prestaplan
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'prestaren', sperson, pspersondes, f_user, f_sysdate
           FROM prestaren
          WHERE sperson = pspersonori;

      UPDATE prestaren
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE procesext
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE productos_empleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'profesionales', sperson, pspersondes, f_user, f_sysdate
           FROM profesionales
          WHERE sperson = pspersonori;

      UPDATE profesionales
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE profeszona
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'promotores', sperson, pspersondes, f_user, f_sysdate
           FROM promotores
          WHERE sperson = pspersonori;

      UPDATE promotores
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'proveedores', sperson, pspersondes, f_user, f_sysdate
           FROM proveedores
          WHERE sperson = pspersonori;

      UPDATE proveedores
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE qcuestionarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE rea_aux
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE reaseguro_snv
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'recibos', sperson, pspersondes, f_user, f_sysdate
           FROM recibos
          WHERE sperson = pspersonori;

      UPDATE recibos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'reembolsos', sperson, pspersondes, f_user, f_sysdate
           FROM reembolsos
          WHERE sperson = pspersonori;

      UPDATE reembolsos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'remesas', sperson, pspersondes, f_user, f_sysdate
           FROM remesas
          WHERE sperson = pspersonori;

      UPDATE remesas
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE remesas_previo
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE remuneracion_canal
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'rentaspp', sperson, pspersondes, f_user, f_sysdate
           FROM rentaspp
          WHERE sperson = pspersonori;

      UPDATE rentaspp
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE rep_retribucion
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE representantes
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE riesgo_defecto
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'rtn_convenio', sperson, pspersondes, f_user, f_sysdate
           FROM rtn_convenio
          WHERE sperson = pspersonori;

      UPDATE rtn_convenio
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'rtn_mntbenefconvenio', sperson, pspersondes, f_user, f_sysdate
           FROM rtn_mntbenefconvenio
          WHERE sperson = pspersonori;

      UPDATE rtn_mntbenefconvenio
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE saldo_persona
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      UPDATE seg_aseccargo
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_defraudadores
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_prof_profesionales', sperson, pspersondes, f_user, f_sysdate
           FROM sin_prof_profesionales
          WHERE sperson = pspersonori;

      UPDATE sin_prof_profesionales
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_siniestro', sperson2, pspersondes, f_user, f_sysdate
           FROM sin_siniestro
          WHERE sperson2 = pspersonori
             OR dec_sperson = pspersonori;

      UPDATE sin_siniestro
         SET sperson2 = pspersondes
       WHERE sperson2 = pspersonori;

      UPDATE sin_siniestro
         SET dec_sperson = pspersondes
       WHERE dec_sperson = pspersonori;

      UPDATE sin_tramita_demand
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_tramita_demand
         SET sperson2 = pspersondes
       WHERE sperson2 = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_tramita_destinatario', sperson, pspersondes, f_user, f_sysdate
           FROM sin_tramita_destinatario
          WHERE sperson = pspersonori;

      UPDATE sin_tramita_destinatario
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_tramita_detdescripcion
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 70;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_tramita_detdireccion', sperson, pspersondes, f_user, f_sysdate
           FROM sin_tramita_detdireccion
          WHERE sperson = pspersonori;

      UPDATE sin_tramita_detdireccion
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_tramita_detpersona
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_tramita_localiza
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_tramita_pago', sperson, pspersondes, f_user, f_sysdate
           FROM sin_tramita_pago
          WHERE sperson = pspersonori;

      UPDATE sin_tramita_pago
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'sin_tramita_personasrel', sperson, pspersondes, f_user, f_sysdate
           FROM sin_tramita_personasrel
          WHERE sperson = pspersonori;

      UPDATE sin_tramita_personasrel
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE sin_tramita_profesional
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE solicitudregalos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE solriesgos
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE targresid
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE temp_fis_detcobro
--         SET spersonp = pspersondes
--       WHERE spersonp = pspersonori;

      --      UPDATE temp_fis_detcobro
--         SET sperson1 = pspersondes
--       WHERE sperson1 = pspersonori;

      --      UPDATE temp_infpolisses
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      UPDATE tipo_empleados
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

--      UPDATE tmp_agensegu
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_agentes
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_envio_host
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_fisper
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_hisper_ccc
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_hisper_contactos
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_hisper_direcciones
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_hisper_vinculos
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_host
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_journal_pers
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_oficinas
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_pagosrenta
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_per_ccc
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_per_contactos
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_per_direcciones
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_per_vinculos
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_persones_1
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_persones_2
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;

      --      UPDATE tmp_sin_tramita_pago
--         SET sperson = pspersondes
--       WHERE sperson = pspersonori;
      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'tramitacionsini', sperson, pspersondes, f_user, f_sysdate
           FROM tramitacionsini
          WHERE sperson = pspersonori;

      UPDATE tramitacionsini
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE trasaportant
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE trasplaapo
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      UPDATE trasplapresta
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      INSERT INTO fusiontablas
                  (ttabla, spersonori, spersondes, cusuari, fmovimi)
         SELECT 'usuarios', sperson, pspersondes, f_user, f_sysdate
           FROM usuarios
          WHERE sperson = pspersonori;

      UPDATE usuarios
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      vtraza := 80;

      UPDATE vinculaciones
         SET sperson = pspersondes
       WHERE sperson = pspersonori;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_actualiza_sperson', vtraza,
                     'Error general. pspersondes = ' || pspersondes || ' - pspersonori ='
                     || pspersonori,
                     SQLERRM);
         RETURN 9904451;   -- ha ocurregut un error al funsionar la persona.
   END f_actualiza_sperson;

   /******************************************************************************
       NOMBRE:       PAC_FUSIONPERSONA
       PROPÃ“SITO: Funciones para gestionar personas

       REVISIONES:
       Ver        Fecha        Autor             DescripciÃ³n
       ---------  ----------  ---------------  ------------------------------------
       1.0        20/02/2012  AMC               1. Creación del package.

    ******************************************************************************/

   /*************************************************************************
      Función que sirve para realizar fusionar des personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 20/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_fusion_per(
      pspersonori IN NUMBER,
      pcagenteori IN NUMBER,
      pspersondes IN NUMBER,
      pcagentedes IN NUMBER)
      RETURN NUMBER IS
      vnum_err       NUMBER := 0;
      vcont          NUMBER;
      vtraza         NUMBER := 0;
      vcagente_ant   agentes.cagente%TYPE;
      v_cod          NUMBER;
      vnumide        VARCHAR2(50);
      vcdomici       NUMBER;
      vcagentedes    NUMBER;
      vfantiguedad   DATE;
      vcagrupa       NUMBER;
      vsseguro_ini   NUMBER;
      vnmovimi_ini   NUMBER;
      vcount         NUMBER;
      vffin          DATE;
      vsseguro_fin   NUMBER;
      vnmovimi_fin   NUMBER;
      vcestado       NUMBER;
      vnorden        NUMBER;
   BEGIN
      vtraza := 1;
-------------------------- per_detper
-- Insertamos el nuevo de detalle, en el caso de existir un detalle ya para el agente fin lo que hacemos es fusionar, es decir
-- por defecto cogemos los campos del agente inicio, pero si no estan informados y en el agnete fin si dejamos esta información.
----------------------------------------------------------------------------------------------------------------------------
      vnum_err := f_actualiza_detper(pspersonori, pcagenteori, pspersondes, pcagentedes);
      vtraza := 4;

      IF vnum_err != 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_fusion_per', vtraza,
                     'Error general', vnum_err);
         RETURN vnum_err;
      END IF;

      SELECT per.nnumide
        INTO vnumide
        FROM per_personas per
       WHERE sperson = pspersondes;

      vtraza := 5;

-------------------------------------------------------------------------------
-------------------------- Cuentas bancarias
-- Traspasamos solo las cuentas que no existan ya para el nuevo agente
-------------------------------------------------------------------------------
      SELECT NVL(MAX(cnordban), 0)
        INTO v_cod
        FROM per_ccc
       WHERE sperson = pspersondes;

      vtraza := 6;

      FOR reggar IN (SELECT c.sperson, c.cagente, c.ctipban, c.cbancar, c.fbaja, c.cdefecto,
                            c.cusumov, c.fusumov, c.cnordban, c.cvalida, c.cpagsin, c.fvencim,
                            c.tseguri, c.falta, c.cusualta
                       FROM per_ccc c
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_ccc cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.ctipban = c.ctipban
                                          AND c.cbancar = cc.cbancar)) LOOP
         vtraza := 7;
         v_cod := v_cod + 1;

         -- Las nuevas cuentas con el por defecto a 0
         INSERT INTO per_ccc
                     (sperson, cagente, ctipban, cbancar, fbaja,
                      cdefecto, cusumov, fusumov, cnordban, cvalida,
                      cpagsin, fvencim, tseguri, falta,
                      cusualta)
              VALUES (pspersondes, pcagenteori, reggar.ctipban, reggar.cbancar, reggar.fbaja,
                      0, reggar.cusumov, reggar.fusumov, v_cod, reggar.cvalida,
                      reggar.cpagsin, reggar.fvencim, reggar.tseguri, reggar.falta,
                      reggar.cusualta);

         vtraza := 8;
      END LOOP;

-------------------------------------------------------------------------------
-------------------------- LOPD
-- Solo insertamos   si no tiene lopd
-------------------------------------------------------------------------------
      vtraza := 81;

      SELECT COUNT(1)
        INTO vcont
        FROM per_lopd
       WHERE sperson = pspersondes;

      vtraza := 82;

      IF vcont = 0 THEN
         FOR reggar IN (SELECT l.fmovimi, l.cusuari, l.cestado, l.ctipdoc, l.ftipdoc,
                               l.catendido, l.fatendido, l.norden, l.cesion, l.publicidad,
                               l.cancelacion
                          FROM per_lopd l
                         WHERE sperson = pspersonori
                           AND cagente = pcagenteori) LOOP
            INSERT INTO per_lopd
                        (sperson, cagente, fmovimi, cusuari,
                         cestado, ctipdoc, ftipdoc, catendido,
                         fatendido, norden, cesion, publicidad,
                         cancelacion)
                 VALUES (pspersondes, pcagenteori, reggar.fmovimi, reggar.cusuari,
                         reggar.cestado, reggar.ctipdoc, reggar.ftipdoc, reggar.catendido,
                         reggar.fatendido, reggar.norden, reggar.cesion, reggar.publicidad,
                         reggar.cancelacion);
         END LOOP;
      END IF;

-------------------------------------------------------------------------------
-------------------------- Contactos
-- Solo insertamos  los contactos que no existan en el nuevo agente.
-------------------------------------------------------------------------------
      SELECT NVL(MAX(cmodcon), 0)
        INTO v_cod
        FROM per_contactos
       WHERE sperson = pspersondes;

      vtraza := 9;

      -- Solo seleccionamos los contactos que no existan en el nuevo agente.
      FOR reggar IN (SELECT sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon, cobliga,
                            cdomici
                       FROM per_contactos c
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_contactos cc
                                        WHERE cc.sperson = pspersondes
                                          AND cagente = pcagentedes
                                          AND cc.tvalcon = c.tvalcon)) LOOP
         vtraza := 9;
         v_cod := v_cod + 1;

         INSERT INTO per_contactos
                     (sperson, cagente, cmodcon, ctipcon, tcomcon,
                      tvalcon, cobliga, cdomici, cusuari, fmovimi)
              VALUES (pspersondes, pcagenteori, v_cod, reggar.ctipcon, reggar.tcomcon,
                      reggar.tvalcon, reggar.cobliga, reggar.cdomici, f_user, f_sysdate);

         vtraza := 10;
      END LOOP;

      vtraza := 11;

-------------------------------------------------------------------------------
-------------------------- Direcciones
-- Insertamos todas las direcciones, mirmaos si ya existe con la función .
-------------------------------------------------------------------------------
      SELECT NVL(MAX(cdomici), 0)
        INTO v_cod
        FROM per_direcciones
       WHERE sperson = pspersondes;

      vtraza := 12;

      FOR reggar IN (SELECT cdomici, ctipdir, csiglas, tnomvia, nnumvia, tcomple, tdomici,
                            cpostal, cpoblac, cprovin, cviavp, clitvp, cbisvp, corvp, nviaadco,
                            clitco, corco, nplacaco, cor2co, cdet1ia, tnum1ia, cdet2ia,
                            tnum2ia, cdet3ia, tnum3ia, iddomici
                       FROM per_direcciones
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori) LOOP
         vtraza := 13;
         vcdomici := NULL;
         vcdomici := pac_persona.f_existe_direccion(pspersondes, pcagenteori, reggar.ctipdir,
                                                    reggar.csiglas, reggar.tnomvia,
                                                    reggar.nnumvia, reggar.tcomple,
                                                    reggar.tdomici, reggar.cpostal,
                                                    reggar.cpoblac, reggar.cprovin);
         vtraza := 131;

         IF vcdomici IS NULL THEN
            v_cod := v_cod + 1;
            vtraza := 132;

            INSERT INTO per_direcciones
                        (sperson, cagente, cdomici, ctipdir, csiglas,
                         tnomvia, nnumvia, tcomple, tdomici,
                         cpostal, cpoblac, cprovin, cusuari, fmovimi,
                         cviavp, clitvp, cbisvp, corvp,
                         nviaadco, clitco, corco, nplacaco,
                         cor2co, cdet1ia, tnum1ia, cdet2ia,
                         tnum2ia, cdet3ia, tnum3ia, iddomici)
                 VALUES (pspersondes, pcagenteori, v_cod, reggar.ctipdir, reggar.csiglas,
                         reggar.tnomvia, reggar.nnumvia, reggar.tcomple, reggar.tdomici,
                         reggar.cpostal, reggar.cpoblac, reggar.cprovin, f_user, f_sysdate,
                         reggar.cviavp, reggar.clitvp, reggar.cbisvp, reggar.corvp,
                         reggar.nviaadco, reggar.clitco, reggar.corco, reggar.nplacaco,
                         reggar.cor2co, reggar.cdet1ia, reggar.tnum1ia, reggar.cdet2ia,
                         reggar.tnum2ia, reggar.cdet3ia, reggar.tnum3ia, reggar.iddomici);
         END IF;

         vtraza := 141;

         INSERT INTO fusiondirecciones
                     (spersonori, cdomiciori, spersondes, cdomicides, cusuari,
                      fmovimi)
              VALUES (pspersonori, reggar.cdomici, pspersondes, NVL(vcdomici, v_cod), f_user,
                      f_sysdate);

         vtraza := 14;

         FOR reggar1 IN (SELECT sseguro
                           FROM tomadores
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE tomadores
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = pspersonori;

            --Bug 26569/166154 - 13/02/2014 - AMC
            INSERT INTO fusiontomadores
                        (spersonori, sseguroori, cdomiciori, spersondes,
                         cdomicides, cusuari, fmovimi)
                 VALUES (pspersonori, reggar1.sseguro, reggar.cdomici, pspersondes,
                         NVL(vcdomici, v_cod), f_user, f_sysdate);
         END LOOP;

         vtraza := 15;

         FOR reggar1 IN (SELECT sseguro, sperson, norden
                           FROM asegurados
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE asegurados
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND norden = reggar1.norden;

            --Bug 26569/166154 - 13/02/2014 - AMC
            INSERT INTO fusionasegurados
                        (spersonori, sseguroori, cdomiciori, spersondes,
                         cdomicides, cusuari, fmovimi)
                 VALUES (pspersonori, reggar1.sseguro, reggar.cdomici, pspersondes,
                         NVL(vcdomici, v_cod), f_user, f_sysdate);
         END LOOP;

         vtraza := 16;

         FOR reggar1 IN (SELECT sseguro, nriesgo, sperson
                           FROM riesgos
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE riesgos
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND nriesgo = reggar1.nriesgo;

            --Bug 26569/166154 - 13/02/2014 - AMC
            INSERT INTO fusionriesgos
                        (nriesgoori, spersonori, sseguroori, cdomiciori,
                         spersondes, cdomicides, cusuari, fmovimi)
                 VALUES (reggar1.nriesgo, pspersonori, reggar1.sseguro, reggar.cdomici,
                         pspersondes, NVL(vcdomici, v_cod), f_user, f_sysdate);
         END LOOP;

         FOR reggar1 IN (SELECT sseguro, cdomici, sperson
                           FROM autconductores
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE autconductores
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND cdomici = reggar1.cdomici;

            --Bug 26569/166154 - 13/02/2014 - AMC
            INSERT INTO fusionautconductores
                        (spersonori, sseguroori, cdomiciori, spersondes,
                         cdomicides, cusuari, fmovimi)
                 VALUES (pspersonori, reggar1.sseguro, reggar.cdomici, pspersondes,
                         NVL(vcdomici, v_cod), f_user, f_sysdate);
         END LOOP;

         vtraza := 17;

         -- Bug 26569/164358 - 27/01/2014 - AMC
         FOR reggar1 IN (SELECT cagente
                           FROM agentes
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE agentes
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE cagente = reggar1.cagente;

            --Bug 26569/166154 - 13/02/2014 - AMC
            INSERT INTO fusionagentes
                        (cagenteori, spersonori, cdomiciori, spersondes,
                         cdomicides, cusuari, fmovimi)
                 VALUES (reggar1.cagente, pspersonori, reggar.cdomici, pspersondes,
                         NVL(vcdomici, v_cod), f_user, f_sysdate);
         END LOOP;

         FOR reggar1 IN (SELECT sseguro, sperson, norden, nmovimi
                           FROM anuasegurados
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE anuasegurados
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND norden = reggar1.norden
               AND nmovimi = reggar1.nmovimi;
         END LOOP;

         FOR reggar1 IN (SELECT sseguro, sperson, nriesgo, nmovimi
                           FROM anuinquiaval
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE anuinquiaval
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND nriesgo = reggar1.nriesgo
               AND nmovimi = reggar1.nmovimi;
         END LOOP;

         FOR reggar1 IN (SELECT sseguro, sperson, nriesgo, nmovimi
                           FROM anuriesgos
                          WHERE sperson = pspersonori
                            AND cdomici = reggar.cdomici) LOOP
            UPDATE anuriesgos
               SET cdomici = NVL(vcdomici, v_cod),
                   sperson = pspersondes
             WHERE sseguro = reggar1.sseguro
               AND sperson = reggar1.sperson
               AND nriesgo = reggar1.nriesgo
               AND nmovimi = reggar1.nmovimi;
         END LOOP;
      -- Fi Bug 26569/164358 - 27/01/2014 - AMC
      END LOOP;

      vtraza := 19;
      vtraza := 25;

--------------------------------------------------------------------------------
-------------------------- ANTIGUEDAD
-- Traspasamos solo los identificadores que no existan ya para el nuevo agente.
--------------------------------------------------------------------------------

      --------------------------------------------------------------------------------
-------------------------- Identificadores
-- Traspasamos solo los identificadores que no existan ya para el nuevo agente.
--------------------------------------------------------------------------------
      FOR reggar IN (SELECT sperson, pcagentedes, ctipide, nnumide, swidepri, femisio, fcaduca,
                            i.cpaisexp, i.cdepartexp, i.cciudadexp, i.fechadexp
                       FROM per_identificador i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_identificador cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.ctipide = i.ctipide
                                          AND cc.nnumide = i.nnumide)) LOOP
         BEGIN
            -- Si es el identificador principal ponemso un 1 en el campo swidepri
            INSERT INTO per_identificador
                        (sperson, cagente, ctipide, nnumide,
                         swidepri, femisio,
                         fcaduca, cpaisexp, cdepartexp,
                         cciudadexp, fechadexp)
                 VALUES (pspersondes, pcagenteori, reggar.ctipide, reggar.nnumide,
                         DECODE(reggar.nnumide, vnumide, 1, 0), reggar.femisio,
                         reggar.fcaduca, reggar.cpaisexp, reggar.cdepartexp,
                         reggar.cciudadexp, reggar.fechadexp);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               NULL;
         END;
      END LOOP;

      vtraza := 23;

-------------------------------------------------------------------------------
-------------------------- Irpf
-- Si existe información para el nuevo agnete de irpf no traspasamos
-- Si No existe informadión de IRPF para el nuevo agente la traspasamos
-------------------------------------------------------------------------------

      -- si ya existe datos para el nuevo agente no volcamos la información.
      SELECT COUNT(1)
        INTO vcont
        FROM per_irpf
       WHERE sperson = pspersondes
         AND cagente = pcagenteori;

      IF vcont = 0 THEN
         FOR reggar IN (SELECT sperson, csitfam, cnifcon, cgrado, cayuda, ipension, ianuhijos,
                               prolon, rmovgeo, nano
                          FROM per_irpf i
                         WHERE sperson = pspersonori
                           AND cagente = pcagenteori) LOOP
            BEGIN
               INSERT INTO per_irpf
                           (sperson, csitfam, cnifcon, cgrado,
                            cayuda, ipension, ianuhijos, prolon,
                            rmovgeo, nano, cagente)
                    VALUES (pspersondes, reggar.csitfam, reggar.cnifcon, reggar.cgrado,
                            reggar.cayuda, reggar.ipension, reggar.ianuhijos, reggar.prolon,
                            reggar.rmovgeo, reggar.nano, pcagenteori);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;

      vtraza := 24;

-------------------------------------------------------------------------------
-------------------------- Irpf descendicnetes
-- Si existe información para el nuevo agnete de irpf no traspasamos
-- Si No existe informadión de IRPF para el nuevo agente la traspasamos
-------------------------------------------------------------------------------

      -- si ya existe datos para el nuevo agente no volcamos la información.
      SELECT COUNT(1)
        INTO vcont
        FROM per_irpfdescen
       WHERE sperson = pspersondes
         AND cagente = pcagenteori;

      IF vcont = 0 THEN
         FOR reggar IN (SELECT sperson, fnacimi, cgrado, center, cusuari, fmovimi, norden,
                               nano, cagente
                          FROM per_irpfdescen i
                         WHERE sperson = pspersonori
                           AND cagente = pcagenteori) LOOP
            BEGIN
               INSERT INTO per_irpfdescen
                           (sperson, fnacimi, cgrado, center,
                            norden, nano, cagente)
                    VALUES (pspersondes, reggar.fnacimi, reggar.cgrado, reggar.center,
                            reggar.norden, reggar.nano, pcagenteori);
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX THEN
                  NULL;
            END;
         END LOOP;
      END IF;

-------------------------------------------------------------------------------
-------------------------- Irpf Mayores
-- Si existe información para el nuevo agnete de irpf no traspasamos
-- Si No existe informadión de IRPF para el nuevo agente la traspasamos
-------------------------------------------------------------------------------

      -- si ya existe datos para el nuevo agente no volcamos la información.
      vtraza := 25;

      SELECT COUNT(1)
        INTO vcont
        FROM per_irpfmayores
       WHERE sperson = pspersondes
         AND cagente = pcagenteori;

      IF vcont = 0 THEN
         FOR reggar IN (SELECT sperson, fnacimi, cgrado, crenta, nviven, cusuari, fmovimi,
                               norden, nano, cagente
                          FROM per_irpfmayores
                         WHERE sperson = pspersonori
                           AND cagente = pcagenteori) LOOP
            BEGIN
               INSERT INTO per_irpfmayores
                           (sperson, fnacimi, cgrado, crenta,
                            nviven, norden, nano, cagente)
                    VALUES (pspersondes, reggar.fnacimi, reggar.cgrado, reggar.crenta,
                            reggar.nviven, reggar.norden, reggar.nano, pcagenteori);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END LOOP;
      END IF;

-----------------------------------------------------------------------------------------
-------------------------- Nacionalidades
-- Traspasamos solo las nacionalidades que no tiene el nuevo agente.(petaría por pk)
-----------------------------------------------------------------------------------------
      vtraza := 26;

      FOR reggar IN (SELECT sperson, cpais, cdefecto
                       FROM per_nacionalidades n
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_nacionalidades cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.cpais = n.cpais)) LOOP
         BEGIN
            INSERT INTO per_nacionalidades
                        (sperson, cagente, cpais, cdefecto)
                 VALUES (pspersondes, pcagenteori, reggar.cpais, 0);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

------------------------------------------------------------------------------------------------------
-------------------------- Parametros personas
-- Traspasamos los parametros que no tiene y si existe en el nuevo agente este parametro lo dejamos
------------------------------------------------------------------------------------------------------
      vtraza := 27;

      FOR reggar IN (SELECT cparam, sperson, nvalpar, tvalpar, fvalpar
                       FROM per_parpersonas i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_parpersonas cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.cparam = i.cparam)) LOOP
         BEGIN
            INSERT INTO per_parpersonas
                        (cparam, cagente, sperson, nvalpar,
                         tvalpar, fvalpar)
                 VALUES (reggar.cparam, pcagenteori, pspersondes, reggar.nvalpar,
                         reggar.tvalpar, reggar.fvalpar);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
--               UPDATE per_parpersonas
--                  SET nvalpar = reggar.nvalpar,
--                      tvalpar = reggar.tvalpar,
--                      fvalpar = reggar.fvalpar
--                WHERE sperson = pcagentedes
--                  AND cagente = pspersondes
--                  AND cparam = reggar.cparam;
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      -------------------------------------------------------------------------------
-------------------------- Documentos
-- Traspasamos los documentos, solo si no tiene el mismo idegedox
-------------------------------------------------------------------------------
      vtraza := 28;

      FOR reggar IN (SELECT iddocgedox, fcaduca, tobserva
                       FROM per_documentos i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_documentos cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.iddocgedox = i.iddocgedox)) LOOP
         BEGIN
            INSERT INTO per_documentos
                        (sperson, cagente, iddocgedox, fcaduca,
                         tobserva)
                 VALUES (pspersondes, pcagenteori, reggar.iddocgedox, reggar.fcaduca,
                         reggar.tobserva);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
--               UPDATE per_documentos
--                  SET fcaduca = reggar.fcaduca,
--                      tobserva = reggar.tobserva
--                WHERE sperson = pcagentedes
--                  AND cagente = pspersondes
--                  AND iddocgedox = reggar.iddocgedox;
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

-------------------------------------------------------------------------------
-------------------------- Personas relacionadas
-- Traspasamos las personas relacionadas
-------------------------------------------------------------------------------
      vtraza := 29;

      FOR reggar IN (SELECT sperson_rel, ctipper_rel, pparticipacion
                       FROM per_personas_rel i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_personas_rel cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.sperson_rel = i.sperson_rel)) LOOP
         BEGIN
            INSERT INTO per_personas_rel
                        (sperson, cagente, sperson_rel, ctipper_rel,
                         pparticipacion)
                 VALUES (pspersondes, pcagenteori, reggar.sperson_rel, reggar.ctipper_rel,
                         reggar.pparticipacion);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
--               UPDATE per_personas_rel
--                  SET ctipper_rel = reggar.ctipper_rel
--                WHERE sperson = pcagentedes
--                  AND cagente = pspersondes
--                  AND sperson_rel = reggar.sperson_rel;
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      UPDATE per_personas_rel
         SET sperson_rel = pspersondes
       WHERE sperson_rel = pspersonori;

      vtraza := 40;
   -------------------------------------------------------------------------------
-------------------------- Regimen fiscal
-- Traspasamos los regimenes fiscales
-------------------------------------------------------------------------------
      vtraza := 30;

      FOR reggar IN (SELECT anualidad, fefecto, cregfiscal
                       FROM per_regimenfiscal i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_regimenfiscal cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.fefecto = i.fefecto)) LOOP
         BEGIN
            INSERT INTO per_regimenfiscal
                        (sperson, cagente, anualidad, fefecto,
                         cregfiscal)
                 VALUES (pspersondes, pcagenteori, reggar.anualidad, reggar.fefecto,
                         reggar.cregfiscal);
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
--               UPDATE per_regimenfiscal
--                  SET anualidad = reggar.anualidad,
--                      cregfiscal = reggar.cregfiscal
--                WHERE sperson = pcagentedes
--                  AND cagente = pspersondes
--                  AND fefecto = reggar.fefecto;
               NULL;
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      vtraza := 50;
-------------------------------------------------------------------------------
-------------------------- Sarlaft
-- Traspasamos Sarlaft
--------------------------------------------------------------------------------
      vtraza := 31;

      FOR reggar IN (SELECT fefecto
                       FROM per_sarlaft i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_sarlaft cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.fefecto = i.fefecto)) LOOP
         BEGIN
            INSERT INTO per_sarlaft
                        (sperson, cagente, fefecto)
                 VALUES (pspersondes, pcagenteori, reggar.fefecto);
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      END LOOP;

      vtraza := 60;

-------------------------------------------------------------------------------
-------------------------- tIPOS DE CARNE
-- Traspasamos carnets
--------------------------------------------------------------------------------
      FOR reggar IN (SELECT ctipcar, fcarnet, cdefecto
                       FROM per_autcarnet i
                      WHERE sperson = pspersonori
                        AND cagente = pcagenteori
                        AND NOT EXISTS(SELECT 1
                                         FROM per_autcarnet cc
                                        WHERE cc.sperson = pspersondes
                                          AND cc.cagente = pcagentedes
                                          AND cc.ctipcar = i.ctipcar)) LOOP
         INSERT INTO per_autcarnet
                     (sperson, cagente, ctipcar, fcarnet,
                      cdefecto)
              VALUES (pspersondes, pcagenteori, reggar.ctipcar, reggar.fcarnet,
                      reggar.cdefecto);
      END LOOP;

      vtraza := 70;
-------------------------------------------------------------------------------
-------------------------- Vinculos--> obsoleta
-- Traspasamos Vinculos
--------------------------------------------------------------------------------
--      FOR reggar IN (SELECT cvinclo
--                       FROM per_vinculos v
--                      WHERE sperson = pspersonori
--                        AND cagente = pcagenteori
--                        AND NOT EXISTS(SELECT 1
--                                         FROM per_sarlaft cc
--                                        WHERE cc.sperson = pspersondes
--                                          AND cc.cagente = pcagentedes
--                                          AND cc.cvinclo = v.cvinclo)) LOOP
--         BEGIN
--            INSERT INTO per_vinculos
--                        (sperson, cagente, cvinclo)
--                 VALUES (pspersondes, pcagentedes, reggar.cvinclo);
--         EXCEPTION
--            WHEN OTHERS THEN
--               NULL;
--         END;
--      END LOOP;

      -------------------------------------------------------------------------------
-------------------------- Potencial : obsoleta
-- Traspasamos Potencial
--------------------------------------------------------------------------------
--      FOR reggar IN (SELECT *
--                       FROM per_potencial
--                      WHERE sperson = pspersonori) LOOP
--         BEGIN
--            INSERT INTO per_potencial
--                        (sperson, fmovimi, cusuari, tentidad,
--                         isalario, tbienes, tinversiones, tobserv)
--                 VALUES (pspersondes, reggar.fmovimi, reggar.cusuari, reggar.tentidad,
--                         reggar.isalario, reggar.tbienes, reggar.tinversiones, reggar.tobserv);
--         EXCEPTION
--            WHEN OTHERS THEN
--               NULL;
--         END;
--      END LOOP;

      -------------------------------------------------------------------------------
-------------------------- Identifica
-- Traspasamos Identifica esta obsoltea la tabla que se utilia es per_identificador
--------------------------------------------------------------------------------

      --      FOR reggar IN (SELECT *
--                       FROM per_identifica
--                      WHERE sperson = pspersonori) LOOP
--         BEGIN
--            INSERT INTO per_identifica
--                        (sperson, ctipide, nnumide, swidepri,
--                         femisio, fcaduca)
--                 VALUES (pspersondes, reggar.ctipide, reggar.nnumide, reggar.swidepri,
--                         reggar.femisio, reggar.fcaduca);
--         EXCEPTION
--            WHEN OTHERS THEN
--               NULL;
--         END;
--      END LOOP;
      vtraza := 80;

      --Bug 26569/166154 - 13/02/2014 - AMC
      SELECT COUNT(1)
        INTO vcount
        FROM per_antiguedad
       WHERE sperson IN(pspersondes, pspersonori);

      IF vcount > 0 THEN
         FOR reg IN (SELECT DISTINCT cagrupa
                                FROM per_antiguedad
                               WHERE sperson IN(pspersondes, pspersonori)) LOOP
            SELECT MIN(fantiguedad)
              INTO vfantiguedad
              FROM per_antiguedad
             WHERE sperson IN(pspersondes, pspersonori)
               AND cagrupa = reg.cagrupa;

            SELECT MIN(sseguro_ini)
              INTO vsseguro_ini
              FROM per_antiguedad
             WHERE sperson IN(pspersondes, pspersonori)
               AND fantiguedad = vfantiguedad
               AND cagrupa = reg.cagrupa;

            SELECT MIN(nmovimi_ini)
              INTO vnmovimi_ini
              FROM per_antiguedad
             WHERE sperson IN(pspersondes, pspersonori)
               AND fantiguedad = vfantiguedad
               AND cagrupa = reg.cagrupa;

            SELECT MIN(norden)
              INTO vnorden
              FROM per_antiguedad
             WHERE sperson IN(pspersondes, pspersonori)
               AND fantiguedad = vfantiguedad
               AND cagrupa = reg.cagrupa;

            SELECT COUNT(1)
              INTO vcount
              FROM per_antiguedad
             WHERE sperson IN(pspersondes, pspersonori)
               AND ffin IS NULL
               AND cagrupa = reg.cagrupa;

            IF vcount = 0 THEN
               SELECT MAX(ffin)
                 INTO vffin
                 FROM per_antiguedad
                WHERE sperson IN(pspersondes, pspersonori)
                  AND cagrupa = reg.cagrupa;

               SELECT MAX(sseguro_fin)
                 INTO vsseguro_fin
                 FROM per_antiguedad
                WHERE sperson IN(pspersondes, pspersonori)
                  AND ffin = vffin
                  AND cagrupa = reg.cagrupa;

               SELECT MAX(nmovimi_fin)
                 INTO vnmovimi_fin
                 FROM per_antiguedad
                WHERE sperson IN(pspersondes, pspersonori)
                  AND ffin = vffin
                  AND cagrupa = reg.cagrupa;

               IF (vffin + 365) > f_sysdate THEN
                  vcestado := 0;
               ELSE
                  vcestado := 1;
               END IF;
            ELSE
               vffin := NULL;
               vsseguro_fin := NULL;
               vnmovimi_fin := NULL;
               vcestado := 0;
            END IF;

            DELETE      per_antiguedad
                  WHERE sperson = pspersondes
                    AND cagrupa = reg.cagrupa;

            INSERT INTO per_antiguedad
                        (sperson, cagrupa, norden, fantiguedad, cestado,
                         sseguro_ini, nmovimi_ini, ffin, sseguro_fin, nmovimi_fin)
                 VALUES (pspersondes, reg.cagrupa, vnorden, vfantiguedad, vcestado,
                         vsseguro_ini, vnmovimi_ini, vffin, vsseguro_fin, vnmovimi_fin);

            INSERT INTO fusionantiguedad
                        (spersonori, spersondes, fantiguedad, cestado, sseguro_ini,
                         nmovimi_ini, cusuari, fmovimi)
                 VALUES (pspersonori, pspersondes, vfantiguedad, vcestado, vsseguro_ini,
                         vnmovimi_ini, f_user, f_sysdate);
         END LOOP;

         vtraza := 81;
      END IF;

      --Fi Bug 26569/166154 - 13/02/2014 - AMC
      vnum_err := f_actualiza_sperson(pspersonori, pspersondes);

      IF vnum_err != 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_fusion_per', vtraza,
                     'Error general', vnum_err);
         RETURN vnum_err;
      END IF;

      vtraza := 90;

      -- Si todo va bien insetamos en fusionpersonas para mantener un historico
      INSERT INTO fusionpersonas
                  (spersonori, cagenteori, spersondes, cagentedes, cusuari, fmovimi)
           VALUES (pspersonori, pcagenteori, pspersondes, pcagentedes, f_user, f_sysdate);

      --Borramos la persona
      vtraza := 91;
      vnum_err := f_del_persona(pspersonori, pcagenteori);

      IF vnum_err != 0 THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_fusion_per', vtraza,
                     'f_del_persona', vnum_err);
         RETURN vnum_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_fusion_per', vtraza,
                     'Error general. pspersondes = ' || pspersondes || ' - pspersonori ='
                     || pspersonori,
                     SQLERRM);
         -- Bug 0013392 - 12/04/2010 - JMF: ROLLBACK;
         RETURN 9904451;
   END f_fusion_per;

    /*************************************************************************
      Función que sirve para actualizar personas publicas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_actualiza_per(pspersonori IN NUMBER, pspersondes IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vsquery        VARCHAR2(1000);
      dummy          NUMBER;
      v_cursor       NUMBER;
      v_filas        NUMBER;
   BEGIN
      vtraza := 1;
/*
      FOR cur IN (SELECT col.table_name tabla
                    FROM all_tab_columns col, all_tables tab
                   WHERE col.owner = pac_parametros.f_parinstalacion_t('USER_OWNER')
                     AND column_name = 'SPERSON'
                     AND col.table_name = tab.table_name
                     AND(col.table_name NOT LIKE 'EST%'
                         AND col.table_name NOT LIKE 'HIS%'
                         AND col.table_name NOT LIKE 'MIG%'
                         AND col.table_name NOT LIKE 'TMP%'
                         AND SUBSTR(col.table_name, 1, 4) != 'PER_')) LOOP
         vsquery := 'BEGIN update ' || cur.tabla || ' set sperson=' || pspersondes
                    || ' WHERE sperson =' || pspersonori || '; END;';

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(v_cursor, vsquery, DBMS_SQL.native);
         --DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno, 10);
         v_filas := DBMS_SQL.EXECUTE(v_cursor);

         --DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);
         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;
      END LOOP;
*/
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_actualiza_per', vtraza,
                     'Error general. pspersondes = ' || pspersondes || ' - pspersonori ='
                     || pspersonori,
                     SQLERRM);
         RETURN 9904451;
   END f_actualiza_per;

     /*************************************************************************
      Función que sirve para actualizar el detalle personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_actualiza_detper(
      pspersonori IN NUMBER,
      pcagenteori IN NUMBER,
      pspersondes IN NUMBER,
      pcagentedes IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER := 0;
      vswpubli       per_personas.swpubli%TYPE;
      vcempres       empresas.cempres%TYPE;
      vcidioma       per_detper.cidioma%TYPE;
      vtapelli1      per_detper.tapelli1%TYPE;
      vtapelli2      per_detper.tapelli2%TYPE;
      vtnombre       per_detper.tnombre%TYPE;
      vtnombre1      per_detper.tnombre1%TYPE;
      vtnombre2      per_detper.tnombre2%TYPE;
      vtsiglas       per_detper.tsiglas%TYPE;
      vcprofes       per_detper.cprofes%TYPE;
      vtbuscar       per_detper.tbuscar%TYPE;
      vcestciv       per_detper.cestciv%TYPE;
      vcpais         per_detper.cpais%TYPE;
   BEGIN
      vtraza := 1;

      SELECT swpubli
        INTO vswpubli
        FROM per_personas
       WHERE sperson = pspersondes;

      vtraza := 2;

      IF vswpubli = 0 THEN   -- solo generamos un detalla nuevo si es privada, si no cogemos el que tiene ya.
         -- Si existe ya detalle para el nuevo agente
         BEGIN
            vtraza := 3;

            -- Bug 25456/133727 - 16/01/2013 - AMC
            INSERT INTO per_detper
                        (sperson, cagente, cidioma, tapelli1, tapelli2, tnombre, tsiglas,
                         cprofes, tbuscar, cestciv, cpais, cusuari, fmovimi, tnombre1,
                         tnombre2, cocupacion)
               SELECT pspersondes, pcagenteori, cidioma, tapelli1, tapelli2, tnombre, tsiglas,
                      cprofes, tbuscar, cestciv, cpais, f_user, f_sysdate, tnombre1, tnombre2,
                      cocupacion
                 FROM per_detper
                WHERE sperson = pspersonori
                  AND cagente = pcagenteori;
         -- Fi Bug 25456/133727 - 16/01/2013 - AMC
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               vtraza := 4;
               NULL;
--               SELECT cidioma, tapelli1, tapelli2, tnombre, tsiglas, cprofes, tbuscar,
--                      cestciv, cpais, tnombre1, tnombre2
--                 INTO vcidioma, vtapelli1, vtapelli2, vtnombre, vtsiglas, vcprofes, vtbuscar,
--                      vcestciv, vcpais, vtnombre1, vtnombre2
--                 FROM per_detper
--                WHERE sperson = pspersonori
--                  AND cagente = pcagenteori;

         --               UPDATE per_detper
--                  SET cidioma = NVL(cidioma, vcidioma),
--                      tapelli1 = NVL(tapelli1, vtapelli1),
--                      tapelli2 = NVL(tapelli2, vtapelli2),
--                      tnombre = NVL(tnombre, vtnombre),
--                      tnombre1 = NVL(tnombre1, vtnombre1),
--                      tnombre2 = NVL(tnombre2, vtnombre2),
--                      tsiglas = NVL(tsiglas, vtsiglas),
--                      cprofes = NVL(cprofes, vcprofes),
--                      tbuscar = NVL(tbuscar, vtbuscar),
--                      cestciv = NVL(cestciv, vcestciv),
--                      cpais = NVL(cpais, vcpais)
--                WHERE sperson = pspersondes
--                  AND cagente = pcagentedes;
         END;
      END IF;

      vtraza := 5;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_actualiza_detper', vtraza,
                     'Error general. pspersondes = ' || pspersondes || ' - pspersonori ='
                     || pspersonori,
                     SQLERRM);
         RETURN 9904451;
   END f_actualiza_detper;

    /*************************************************************************
      Función que devuelve el sperson de la segunda persona con el mismo nif

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_get_perduplicada(psperson IN NUMBER, pcagente IN NUMBER, psperson2 IN OUT NUMBER)
      RETURN NUMBER IS
      vnumerr        NUMBER;
      vduplicada     NUMBER;
      vnnumide       VARCHAR2(50);
      vtraza         NUMBER;
      vctipide       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT p.nnumide, ctipide
        INTO vnnumide, vctipide
        FROM per_personas p, per_detper pd
       WHERE p.sperson = psperson
         AND p.sperson = pd.sperson
         AND pd.cagente = pcagente;

      vtraza := 2;
      vnumerr := pac_persona.f_persona_duplicada(psperson, vnnumide, NULL, NULL, NULL,
                                                 pcagente, NULL, vctipide, vduplicada);
      vtraza := 3;

      IF vduplicada = 2 THEN
         SELECT sperson
           INTO psperson2
           FROM per_personas
          WHERE nnumide = vnnumide
            AND sperson <> psperson
            AND ROWNUM = 1;
      ELSE
         psperson2 := NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_get_perduplicada', vtraza,
                     'Error general. psperson = ' || psperson || ' - pcagente =' || pcagente
                     || ' - psperson2 =' || psperson2,
                     SQLERRM);
         RETURN 1;
   END f_get_perduplicada;

    /*************************************************************************
      Función que borra un persona

        retorno : 0 ok
                  1 error
     Bug 20945/1109228 - 07/03/2012 -  AMC
   *************************************************************************/
   FUNCTION f_del_persona(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER IS
      vtraza         NUMBER;
      vcount         NUMBER;
   BEGIN
      SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(f_empres, 'USER_BBDD'))
        INTO vcount
        FROM DUAL;

      INSERT INTO delper_antiguedad
                  (cusuaridel, fdel, sperson, cagrupa, norden, fantiguedad, cestado,
                   sseguro_ini, nmovimi_ini, ffin, sseguro_fin, nmovimi_fin, falta, cusualt,
                   fmodifi, cusumod)
         (SELECT f_user, f_sysdate, sperson, cagrupa, norden, fantiguedad, cestado,
                 sseguro_ini, nmovimi_ini, ffin, sseguro_fin, nmovimi_fin, falta, cusualt,
                 fmodifi, cusumod
            FROM per_antiguedad
           WHERE sperson = psperson);

      INSERT INTO delper_autcarnet
                  (cusuaridel, fdel, sperson, cagente, ctipcar, fcarnet, cdefecto)
         (SELECT f_user, f_sysdate, sperson, cagente, ctipcar, fcarnet, cdefecto
            FROM per_autcarnet
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_ccc
                  (cusuaridel, fdel, sperson, cagente, ctipban, cbancar, fbaja, cdefecto,
                   cusumov, fusumov, cnordban, cvalida, cpagsin, fvencim, tseguri, falta,
                   cusualta)
         (SELECT f_user, f_sysdate, sperson, cagente, ctipban, cbancar, fbaja, cdefecto,
                 cusumov, fusumov, cnordban, cvalida, cpagsin, fvencim, tseguri, falta,
                 cusualta
            FROM per_ccc
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_contactos
                  (cusuaridel, fdel, sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon,
                   cusuari, fmovimi, cobliga, cdomici)
         (SELECT f_user, f_sysdate, sperson, cagente, cmodcon, ctipcon, tcomcon, tvalcon,
                 cusuari, fmovimi, cobliga, cdomici
            FROM per_contactos
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_contactos_aut
                  (cusuaridel, fdel, sperson, cagente, cmodcon, norden, ctipcon, tcomcon,
                   tvalcon, cobliga, cusumod, fusumod, fbaja, cusuaut, fautoriz, cestado,
                   tobserva, cdomici)
         (SELECT f_user, f_sysdate, sperson, cagente, cmodcon, norden, ctipcon, tcomcon,
                 tvalcon, cobliga, cusumod, fusumod, fbaja, cusuaut, fautoriz, cestado,
                 tobserva, cdomici
            FROM per_contactos_aut
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_direcciones
                  (cusuaridel, fdel, sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                   nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi,
                   cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                   cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, iddomici, localidad)
         (SELECT f_user, f_sysdate, sperson, cagente, cdomici, ctipdir, csiglas, tnomvia,
                 nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, cusuari, fmovimi,
                 cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co,
                 cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, iddomici, localidad
            FROM per_direcciones
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_direcciones_aut
                  (cusuaridel, fdel, sperson, cagente, cdomici, norden, ctipdir, csiglas,
                   tnomvia, nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, cusumod,
                   fusumod, cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco,
                   cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, fbaja,
                   cusuaut, fautoriz, cestado, tobserva, localidad)
         (SELECT f_user, f_sysdate, sperson, cagente, cdomici, norden, ctipdir, csiglas,
                 tnomvia, nnumvia, tcomple, tdomici, cpostal, cpoblac, cprovin, cusumod,
                 fusumod, cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco,
                 cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, fbaja, cusuaut,
                 fautoriz, cestado, tobserva, localidad
            FROM per_direcciones_aut
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_documentos
                  (cusuaridel, fdel, sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt,
                   falta, cusuari, fmovimi)
         (SELECT f_user, f_sysdate, sperson, cagente, iddocgedox, fcaduca, tobserva, cusualt,
                 falta, cusuari, fmovimi
            FROM per_documentos
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_identificador
                  (cusuaridel, fdel, sperson, cagente, ctipide, nnumide, swidepri, femisio,
                   fcaduca, cpaisexp, cdepartexp, cciudadexp, fechadexp)
         (SELECT f_user, f_sysdate, sperson, cagente, ctipide, nnumide, swidepri, femisio,
                 fcaduca, cpaisexp, cdepartexp, cciudadexp, fechadexp
            FROM per_identificador
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_nacionalidades
                  (cusuaridel, fdel, sperson, cagente, cpais, cdefecto)
         (SELECT f_user, f_sysdate, sperson, cagente, cpais, cdefecto
            FROM per_nacionalidades
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_parpersonas
                  (cusuaridel, fdel, cparam, sperson, cagente, nvalpar, tvalpar, fvalpar,
                   cusuari, fmovimi)
         (SELECT f_user, f_sysdate, cparam, sperson, cagente, nvalpar, tvalpar, fvalpar,
                 cusuari, fmovimi
            FROM per_parpersonas
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_personas_rel
                  (cusuaridel, fdel, sperson, cagente, sperson_rel, ctipper_rel, cusuari,
                   fmovimi, pparticipacion)
         (SELECT f_user, f_sysdate, sperson, cagente, sperson_rel, ctipper_rel, cusuari,
                 fmovimi, pparticipacion
            FROM per_personas_rel
           WHERE sperson = psperson);

      INSERT INTO delper_regimenfiscal
                  (cusuaridel, fdel, sperson, cagente, anualidad, fefecto, cregfiscal, cusualt,
                   falta)
         (SELECT f_user, f_sysdate, sperson, cagente, anualidad, fefecto, cregfiscal, cusualt,
                 falta
            FROM per_regimenfiscal
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_sarlaft
                  (cusuaridel, fdel, sperson, cagente, fefecto, cusualt, falta, cusuari,
                   fmovimi)
         (SELECT f_user, f_sysdate, sperson, cagente, fefecto, cusualt, falta, cusuari,
                 fmovimi
            FROM per_sarlaft
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_detper
                  (cusuaridel, fdel, sperson, cagente, cidioma, tapelli1, tapelli2, tnombre,
                   tsiglas, cprofes, tbuscar, cestciv, cpais, cusuari, fmovimi, tnombre1,
                   tnombre2, cocupacion)
         (SELECT f_user, f_sysdate, sperson, cagente, cidioma, tapelli1, tapelli2, tnombre,
                 tsiglas, cprofes, tbuscar, cestciv, cpais, cusuari, fmovimi, tnombre1,
                 tnombre2, cocupacion
            FROM per_detper
           WHERE sperson = psperson
             AND cagente = pcagente);

      INSERT INTO delper_personas
                  (cusuaridel, fdel, sperson, nnumide, nordide, ctipide, csexper, fnacimi,
                   cestper, fjubila, cusuari, fmovimi, cmutualista, fdefunc, snip, swpubli,
                   ctipper, tdigitoide, cpreaviso, cagente)
         (SELECT f_user, f_sysdate, sperson, nnumide, nordide, ctipide, csexper, fnacimi,
                 cestper, fjubila, cusuari, fmovimi, cmutualista, fdefunc, snip, swpubli,
                 ctipper, tdigitoide, cpreaviso, cagente
            FROM per_personas
           WHERE sperson = psperson);

      vtraza := 1;

      DELETE FROM per_direcciones_aut
            WHERE sperson = psperson
              AND cagente = pcagente;

      DELETE FROM per_contactos_aut
            WHERE sperson = psperson
              AND cagente = pcagente;

      DELETE      per_documentos
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 2;

      DELETE      per_sarlaft
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 3;

      DELETE      per_regimenfiscal
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 4;

      DELETE      per_personas_rel
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 5;

      DELETE      per_vinculos
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 6;

      DELETE      per_parpersonas
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 8;

      DELETE      per_nacionalidades
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 9;

      DELETE      per_irpfmayores
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 10;

      DELETE      per_irpfdescen
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 11;

      DELETE      per_irpf
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 12;

      DELETE      per_identificador
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 13;

      DELETE      per_direcciones
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 15;

      DELETE      per_contactos
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 16;

      DELETE      per_ccc
            WHERE sperson = psperson
              AND cagente = pcagente;

      DELETE      per_lopd
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 17;

      DELETE      per_antiguedad
            WHERE sperson = psperson;   -- Bug 26569/168948 - 10/03/2014 - AMC

      vtraza := 18;

      DELETE      per_detper
            WHERE sperson = psperson
              AND cagente = pcagente;

      vtraza := 19;

      SELECT COUNT(1)
        INTO vcount
        FROM per_detper
       WHERE sperson = psperson;

      IF vcount = 0 THEN
         DELETE      per_personas
               WHERE sperson = psperson;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_fusionpersona.f_del_persona', vtraza,
                     'Error general psperson= ' || psperson || ' pcagetne = ' || pcagente,
                     SQLERRM);
         RETURN 1;
   END f_del_persona;
END pac_fusionpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "PROGRAMADORESCSI";
