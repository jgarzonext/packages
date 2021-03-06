CREATE OR REPLACE PACKAGE pac_migracion_uni IS
  /******************************************************************************
     NOMBRE:      pac_migracion
     PROPÃ“SITO: Funciones para realizar la migracion de osiris a iAxis

     REVISIONES:
     Ver        Fecha        Autor             DescripciÃ³n
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/07/2019   OAS             1. CreaciÃ³n del package.

  ******************************************************************************/
  e_object_error EXCEPTION;
  e_param_error  EXCEPTION;
  num_err        NUMBER;
  --
  FUNCTION f_consulta( pnpoliza IN VARCHAR2, 
                       psucursal IN NUMBER, 
                       pnnumide IN VARCHAR2,
                       pnsinies IN VARCHAR2) RETURN NUMBER;
  FUNCTION f_migra( pnpoliza IN VARCHAR2, 
                    psucursal IN NUMBER, 
                    pnnumide IN VARCHAR2,
                    pnsinies IN VARCHAR2,
                    nvalret OUT VARCHAR2) RETURN NUMBER;
  FUNCTION p_borra_tablas( nProc IN NUMBER DEFAULT NULL) RETURN NUMBER;
  FUNCTION p_copia_ter RETURN NUMBER;
  FUNCTION p_copia_pol RETURN NUMBER;
  FUNCTION p_copia_sin RETURN NUMBER;
  FUNCTION f_migra_mig_personas RETURN NUMBER;
  FUNCTION f_migra_mig_direcciones RETURN NUMBER;
  FUNCTION f_migra_mig_personas_rel RETURN NUMBER;
  FUNCTION f_migra_mig_regimenfiscal RETURN NUMBER;
  FUNCTION f_migra_mig_parpersonas RETURN NUMBER;
  --FUNCTION f_migra_mig_agentes RETURN NUMBER;
  FUNCTION f_migra_mig_per_agr_marcas RETURN NUMBER;
  FUNCTION f_carga_mig_personas RETURN NUMBER;
  /*FUNCTION f_migra_mig_companias RETURN NUMBER;
  FUNCTION f_carga_mig_companias RETURN NUMBER;
  FUNCTION f_migra_mig_codicontratos RETURN NUMBER;
  FUNCTION f_carga_mig_codicontratos RETURN NUMBER;
  FUNCTION f_migra_mig_agr_contratos RETURN NUMBER;
  FUNCTION f_migra_mig_contratos RETURN NUMBER;
  FUNCTION f_carga_mig_contratos RETURN NUMBER;
  FUNCTION f_migra_mig_tramos RETURN NUMBER;
  FUNCTION f_carga_mig_tramos RETURN NUMBER;
  FUNCTION f_migra_mig_cuadroces RETURN NUMBER;
  FUNCTION f_carga_mig_cuadroces RETURN NUMBER;
  FUNCTION f_migra_mig_tipos_indicadores RETURN NUMBER;
  FUNCTION f_carga_mig_tipos_indicadores RETURN NUMBER;*/
  FUNCTION f_mig_ctgar_contragarantia RETURN NUMBER;
  FUNCTION f_migra_mig_ctgar_det RETURN NUMBER;
  FUNCTION f_migra_mig_ctgar_inmueble RETURN NUMBER;
  FUNCTION f_migra_mig_ctgar_vehiculo RETURN NUMBER;
  FUNCTION f_migra_mig_ctgar_codeudor RETURN NUMBER;
  FUNCTION f_carga_mig_ctgar_contragar RETURN NUMBER;
  FUNCTION f_migra_mig_bureau RETURN NUMBER;
  FUNCTION f_carga_mig_bureau RETURN NUMBER;
  FUNCTION f_migra_mig_seguros RETURN NUMBER;
  FUNCTION f_migra_mig_historicoseguros RETURN NUMBER;
  FUNCTION f_migra_mig_asegurados RETURN NUMBER;
  FUNCTION f_carga_mig_asegurados RETURN NUMBER;
  FUNCTION f_migra_mig_movseguro RETURN NUMBER;
  FUNCTION f_carga_mig_movseguro RETURN NUMBER;
  FUNCTION f_carga_mig_seguros RETURN NUMBER;
  FUNCTION f_migra_mig_riesgos RETURN NUMBER;
  FUNCTION f_carga_mig_riesgos RETURN NUMBER;
  FUNCTION f_migra_mig_sitriesgo RETURN NUMBER;
  FUNCTION f_carga_mig_sitriesgo RETURN NUMBER;
  FUNCTION f_migra_mig_garanseg RETURN NUMBER;
  FUNCTION f_carga_mig_garanseg RETURN NUMBER;
  FUNCTION f_migra_mig_clausuesp RETURN NUMBER;
  FUNCTION f_carga_mig_clausuesp RETURN NUMBER;
  FUNCTION f_migra_mig_benespseg RETURN NUMBER;
  FUNCTION f_carga_mig_benespseg RETURN NUMBER;
  FUNCTION f_migra_mig_pregunseg RETURN NUMBER;
  FUNCTION f_carga_mig_pregunseg RETURN NUMBER;
  FUNCTION f_migra_mig_comisionsegu RETURN NUMBER;
  FUNCTION f_carga_mig_comisionsegu RETURN NUMBER;
  FUNCTION f_migra_mig_ctaseguro RETURN NUMBER;
  FUNCTION f_carga_mig_ctaseguro RETURN NUMBER;
  FUNCTION f_migra_mig_agensegu RETURN NUMBER;
  FUNCTION f_carga_mig_agensegu RETURN NUMBER;
  FUNCTION f_migra_mig_pregungaranseg RETURN NUMBER;
  FUNCTION f_carga_mig_pregungaranseg RETURN NUMBER;
  FUNCTION f_migra_mig_ctgar_seguro RETURN NUMBER;
  FUNCTION f_carga_mig_ctgar_seguro RETURN NUMBER;
  FUNCTION f_migra_mig_age_corretaje RETURN NUMBER;
  FUNCTION f_carga_mig_age_corretaje RETURN NUMBER;
  FUNCTION f_migra_mig_psu_retenidas RETURN NUMBER;
  FUNCTION f_carga_mig_psu_retenidas RETURN NUMBER;
  FUNCTION f_migra_mig_psucontrolseg RETURN NUMBER;
  FUNCTION f_carga_mig_psucontrolseg RETURN NUMBER;
  FUNCTION f_migra_mig_bf_bonfranseg RETURN NUMBER;
  FUNCTION f_carga_mig_bf_bonfranseg RETURN NUMBER;
  /*FUNCTION f_migra_mig_sin_prof_profesion RETURN NUMBER;
  FUNCTION f_carga_mig_sin_prof_profesion RETURN NUMBER;
  FUNCTION f_migra_mig_sin_prof_indica RETURN NUMBER;
  FUNCTION f_carga_mig_sin_prof_indica RETURN NUMBER;
  FUNCTION f_migra_mig_sin_siniestro RETURN NUMBER;
  FUNCTION f_carga_mig_sin_siniestro RETURN NUMBER;
  FUNCTION f_migra_mig_sin_movsiniestro RETURN NUMBER;
  FUNCTION f_carga_mig_sin_movsiniestro RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tramitacion RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tramitacion RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tramita_mov RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tramita_mov RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tramita_res RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tramita_res RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tramita_pago RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tramita_pago RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_movpago RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_movpago RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_pag_gar RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_pag_gar RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_judicial RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_judicial RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_judi_det RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_judi_det RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_valpret RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_valpret RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_fiscal RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_fiscal RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_vpretfis RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_vpretfis RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_cita RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_cita RETURN NUMBER;
  FUNCTION f_migra_mig_agd_observa RETURN NUMBER;
  FUNCTION f_carga_mig_agd_observa RETURN NUMBER;
  FUNCTION f_migra_mig_sin_tram_apoyo RETURN NUMBER;
  FUNCTION f_carga_mig_sin_tram_apoyo RETURN NUMBER;*/
  FUNCTION f_migra_mig_recibos RETURN NUMBER;
  FUNCTION f_carga_mig_recibos RETURN NUMBER;
  FUNCTION f_migra_mig_movrecibo RETURN NUMBER;
  FUNCTION f_carga_mig_movrecibo RETURN NUMBER;
  FUNCTION f_migra_mig_detrecibo RETURN NUMBER;
  FUNCTION f_carga_mig_detrecibo RETURN NUMBER;
  FUNCTION f_migra_mig_detmovrecibo RETURN NUMBER;
  FUNCTION f_carga_mig_detmovrecibo RETURN NUMBER;
  FUNCTION f_migra_mig_detmovrecibopar RETURN NUMBER;
  FUNCTION f_carga_mig_detmovrecibopar RETURN NUMBER;
  FUNCTION f_migra_mig_comrecibo RETURN NUMBER;
  FUNCTION f_carga_mig_comrecibo RETURN NUMBER;
  /*FUNCTION f_migra_mig_liquidacab RETURN NUMBER;
  FUNCTION f_carga_mig_liquidacab RETURN NUMBER;
  FUNCTION f_migra_mig_liquidalin RETURN NUMBER;
  FUNCTION f_carga_mig_liquidalin RETURN NUMBER;
  FUNCTION f_migra_mig_ctactes RETURN NUMBER;
  FUNCTION f_carga_mig_ctactes RETURN NUMBER;*/
  FUNCTION f_migra_mig_ptpplp RETURN NUMBER;
  FUNCTION f_carga_mig_ptpplp RETURN NUMBER;
  FUNCTION f_migra_mig_clausulasreas RETURN NUMBER;
  FUNCTION f_carga_mig_clausulasreas RETURN NUMBER;
  /*FUNCTION f_migra_mig_ctatecnica RETURN NUMBER;
  FUNCTION f_carga_mig_ctatecnica RETURN NUMBER;*/
  FUNCTION f_migra_mig_cesionesrea RETURN NUMBER;
  FUNCTION f_carga_mig_cesionesrea RETURN NUMBER;
  FUNCTION f_migra_mig_det_cesiones RETURN NUMBER;
  FUNCTION f_carga_mig_det_cesiones RETURN NUMBER;
  FUNCTION f_migra_mig_cuafacul RETURN NUMBER;
  FUNCTION f_carga_mig_cuafacul RETURN NUMBER;
  FUNCTION f_migra_mig_cuacesfac RETURN NUMBER;
  FUNCTION f_carga_mig_cuacesfac RETURN NUMBER;
  /*FUNCTION f_migra_mig_eco_tipocambio RETURN NUMBER;
  FUNCTION f_carga_mig_eco_tipocambio RETURN NUMBER;
  FUNCTION f_migra_mig_ctapb RETURN NUMBER;
  FUNCTION f_carga_mig_ctapb RETURN NUMBER;
  FUNCTION f_migra_mig_planillas RETURN NUMBER;
  FUNCTION f_carga_mig_planillas RETURN NUMBER;*/
  FUNCTION f_migra_mig_fin_gen RETURN NUMBER;
  FUNCTION f_migra_mig_fin_gen_det RETURN NUMBER;
  FUNCTION f_carga_mig_fin_gen RETURN NUMBER;
  FUNCTION f_migra_mig_fin_d_renta RETURN NUMBER;
  FUNCTION f_carga_mig_fin_d_renta RETURN NUMBER;
  FUNCTION f_migra_mig_fin_deuda RETURN NUMBER;
  FUNCTION f_carga_mig_fin_deuda RETURN NUMBER;
  FUNCTION f_migra_mig_fin_indi RETURN NUMBER;
  FUNCTION f_carga_mig_fin_indi RETURN NUMBER;
  FUNCTION f_migra_mig_fin_parindi RETURN NUMBER;
  FUNCTION f_carga_mig_fin_parindi RETURN NUMBER;
  FUNCTION f_migra_mig_coacuadro RETURN NUMBER;
  FUNCTION f_migra_mig_coacedido RETURN NUMBER;
  FUNCTION f_migra_mig_ctacoaseguro RETURN NUMBER;
  FUNCTION f_carga_mig_ctacoaseguro RETURN NUMBER;
  FUNCTION f_migra_mig_datsarlaft RETURN NUMBER;
  FUNCTION f_carga_mig_datsarlaft RETURN NUMBER;
  FUNCTION f_valida_errores(vncarga IN mig_cargas.ncarga%TYPE) RETURN NUMBER;
  /*FUNCTION f_valida_migrapol RETURN NUMBER;
  FUNCTION f_valida_migrater(pnnumide IN MIG_PERSONAS_UAT.NNUMIDE%TYPE) RETURN NUMBER;
  FUNCTION f_valida_migrasin RETURN NUMBER;*/
  FUNCTION f_valida(cPolcia VARCHAR2, nNumide VARCHAR2, nSinies VARCHAR2) RETURN NUMBER;
END pac_migracion_uni;
/