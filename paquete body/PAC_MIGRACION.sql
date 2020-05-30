CREATE OR REPLACE PACKAGE BODY pac_migracion AS
  /******************************************************************************
     NOMBRE:      pac_migracion
     PROPÓSITO: Funciones para realizar la migracion de osiris a iAxis

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        16/07/2019   OAS             1. Creación del package.
*/  
  /*************************************************************************
     Consulta si la poliza existe en osiris
     param in pnpoliza    : Número de poliza
     param in psucursal   : codigo de la sucursal 3 digitos formato osiris
     param out mensajes   : mensajes de error
     return               : Respuesta para validar si existe la poliza 0 no existe, <> 0 existe
  *************************************************************************/
  FUNCTION f_consulta_poliza(pnpoliza IN VARCHAR2, psucursal IN NUMBER)
    RETURN NUMBER IS

    vnumerr  NUMBER(8) := 0;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pnpoliza= ' || pnpoliza || ' psucursal= ' ||
                               psucursal;
    vobject  VARCHAR2(200) := 'pac_migracion_uni.f_consulta_poliza';
  BEGIN
    -- Verificación de los parámetros
    IF pnpoliza IS NULL OR psucursal IS NULL THEN
      RAISE e_param_error;
    END IF;

    select count(*)
      into vnumerr
      from S03020@PRODUCCION s
     where s.poliza = pnpoliza
       and s.sucur = psucursal;

    RETURN vnumerr;
  EXCEPTION
    WHEN e_param_error THEN
      RETURN 1000456;
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  end f_consulta_poliza;
  
  PROCEDURE p_migra_datos IS
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'MIGRACION';
    vobject  VARCHAR2(200) := 'pac_migracion.p_migra_poliza';
    resultado  number := 0;
  BEGIN
    --EJECUCION DEL BORRADO DE LAS TABLAS APROBADAS
    pac_migracion.p_borra_tablas;
    --EJECUCION DE LA ETL PARA POBLAR TABLAS, SE CAMBIARA EL RELEASE POSTERIORMENTE
    --ETL_UNITARIO@PRODUCCION(SYSDATE,'1',TRUE,psucursal,pnpoliza,NULL,NULL);
    --SE COPIAN LOS DATOS DE LAS TABLAS DE TMS A TALLER
    pac_migracion.p_copia_datos;
    --SE PROCEDE A EJECUTAR LOS SCRIPTS DE CARGA EN EL ORDEN INDICADO
    --------------------------------------------------------
    --PERSONAS_Y_RED_COMERCIAL
    --------------------------------------------------------
    --1. MIG_PERSONAS
    resultado := pac_migracion.f_migra_mig_personas;
    --2. MIG_DIRECCIONES
    resultado := pac_migracion.f_migra_mig_direcciones;
    --3. MIG_PARPERSONAS
    resultado := pac_migracion.f_migra_mig_parpersonas;
    --4. MIG_PERSONAS_REL
    resultado := pac_migracion.f_migra_mig_personas_rel;
    --4.1 MIG_PERSONAS_REL
    resultado := pac_migracion.f_migra_mig_pagador_alt;
    --5. MIG_REGIMENFISCAL
    resultado := pac_migracion.f_migra_mig_regimenfiscal;
    --6. MIG_AGENTES
    resultado := pac_migracion.f_migra_mig_agentes;
    --7. MIG_PER_AGR_MARCAS
    resultado := pac_migracion.f_migra_mig_per_agr_marcas;
    --8. CARGA MIG_PERSONAS
    resultado := pac_migracion.f_carga_mig_personas;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_personas, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --REASEGURO
    --------------------------------------------------------
    --10. MIG_COMPANIAS
    resultado := pac_migracion.f_migra_mig_companias;
    --12. MIG_CODICONTRATOS
    resultado := pac_migracion.f_migra_mig_codicontratos;
    --14. MIG_AGR_CONTRATOS AUNQUE AGR SE CARGA DESDE CODICONTRATOS SE LLENA ESTA TABLA ANTES POR SI ACASO
    resultado := pac_migracion.f_migra_mig_agr_contratos;
    --11. CARGA MIG_COMPANIAS  TAMBIEN REALIZA LA CARGA DE CODICONTRATOS
    resultado := pac_migracion.f_carga_mig_companias;
    --15. MIG_CONTRATOS
    resultado := pac_migracion.f_migra_mig_contratos;
    --16. CARGA MIG_CONTRATOS
    resultado := pac_migracion.f_carga_mig_contratos;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_contratos, se encontraron '||resultado||' errores.');
    END IF;
    --17. MIG_TRAMOS
    resultado := pac_migracion.f_migra_mig_tramos;
    --18. CARGA MIG_TRAMOS
    resultado := pac_migracion.f_carga_mig_tramos;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_tramos, se encontraron '||resultado||' errores.');
    END IF;
    --19. MIG_CUADROCES
    resultado := pac_migracion.f_migra_mig_cuadroces;
    --20. CARGA MIG_CUADROCES
    resultado := pac_migracion.f_carga_mig_cuadroces;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_cuadroces, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --CATEGORIAS TRIBUTARIAS 
    --------------------------------------------------------
    --20-A. MIG_TIPOS_INDICADORES
    resultado := pac_migracion.f_migra_mig_tipos_indicadores;
    --21. CARGA MIG_TIPOS_INDICADORES
    resultado := pac_migracion.f_carga_mig_tipos_indicadores;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_tipos_indicadores, se encontraron '||resultado||' errores.');
    END IF;
    --21.A MIG_PER_INDICADORES
    resultado := pac_migracion.f_migra_mig_per_indicadores;
    --21.B CARGA MIG_PER_INDICADORES
    resultado := pac_migracion.f_carga_mig_per_indicadores;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_per_indicadores, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --CONTRAGARANTIAS
    --------------------------------------------------------
    --22. MIG_CTGAR_CONTRAGARANTIA
    resultado := pac_migracion.f_mig_ctgar_contragarantia;
    --23. MIG_CTGAR_DET
    resultado := pac_migracion.f_migra_mig_ctgar_det;
    --23. MIG_CTGAR_INMUEBLE
    resultado := pac_migracion.f_migra_mig_ctgar_inmueble;
    --24. MIG_CTGAR_VEHICULO
    resultado := pac_migracion.f_migra_mig_ctgar_vehiculo;
    --25. MIG_CTGAR_CODEUDOR
    resultado := pac_migracion.f_migra_mig_ctgar_codeudor;
    --26. CARGA MIG_CTGAR_CONTRAGARANTIA
    resultado := pac_migracion.f_carga_mig_ctgar_contragar;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_personas, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --FICHA BUREAU
    --------------------------------------------------------
    --27. MIG_BUREAU
    resultado := pac_migracion.f_migra_mig_bureau;
    --28. CARGA MIG_BUREAU
    resultado := pac_migracion.f_carga_mig_bureau;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_bureau, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --PRODUCCION
    --------------------------------------------------------
    --29. MIG_SEGUROS
    resultado := pac_migracion.f_migra_mig_seguros;
    --30. CARGA MIG_SEGUROS
    resultado := pac_migracion.f_carga_mig_seguros;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_seguros, se encontraron '||resultado||' errores.');
    END IF;
    --31. MIG_ASEGURADOS
    resultado := pac_migracion.f_migra_mig_asegurados;
    --32. CARGA MIG_ASEGURADOS
    resultado := pac_migracion.f_carga_mig_asegurados;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_asegurados, se encontraron '||resultado||' errores.');
    END IF;
    --33-A. MIG_MOVSEGURO
    resultado := pac_migracion.f_migra_mig_movseguro;
    --33. MIG_HISTORICOSEGUROS
    resultado := pac_migracion.f_migra_mig_historicoseguros;
    --33-B. CARGA MIG_MOVSEGURO incluye la carga de MIG_HISTORICOSEGUROS
    resultado := pac_migracion.f_carga_mig_movseguro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_movseguro, se encontraron '||resultado||' errores.');
    END IF;
    --34. MIG_RIESGOS
    resultado := pac_migracion.f_migra_mig_riesgos;
    --35. CARGA MIG_RIESGOS
    resultado := pac_migracion.f_carga_mig_riesgos;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_riesgos, se encontraron '||resultado||' errores.');
    END IF;
    --36. MIG_SITRIESGO
    resultado := pac_migracion.f_migra_mig_sitriesgo;
    --37. CARGA MIG_SITRIESGO
    resultado := pac_migracion.f_carga_mig_sitriesgo;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sitriesgo, se encontraron '||resultado||' errores.');
    END IF;
    --38. MIG_GARANSEG
    resultado := pac_migracion.f_migra_mig_garanseg;
    --39. CARGA MIG_GARANSEG
    resultado := pac_migracion.f_carga_mig_garanseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_garanseg, se encontraron '||resultado||' errores.');
    END IF;
    --40. MIG_CLAUSUESP
    resultado := pac_migracion.f_migra_mig_clausuesp;
    --41. CARGA MIG_CLAUSUESP
    resultado := pac_migracion.f_carga_mig_clausuesp;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_clausuesp, se encontraron '||resultado||' errores.');
    END IF;
    --42. MIG_BENESPSEG
    resultado := pac_migracion.f_migra_mig_benespseg;
    --43. CARGA MIG_BENESPSEG
    resultado := pac_migracion.f_carga_mig_benespseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_benespseg, se encontraron '||resultado||' errores.');
    END IF;
    --44. MIG_PREGUNSEG
    resultado := pac_migracion.f_migra_mig_pregunseg;
    --45. CARGA MIG_PREGUNSEG
    resultado := pac_migracion.f_carga_mig_pregunseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_pregunseg, se encontraron '||resultado||' errores.');
    END IF;
    --46. MIG_COMISIONSEGU
    resultado := pac_migracion.f_migra_mig_comisionsegu;
    --47. CARGA MIG_COMISIONSEGU
    resultado := pac_migracion.f_carga_mig_comisionsegu;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_comisionsegu, se encontraron '||resultado||' errores.');
    END IF;
    --48. MIG_CTASEGURO
    resultado := pac_migracion.f_migra_mig_ctaseguro;
    --48. CARGA MIG_CTASEGURO
    resultado := pac_migracion.f_carga_mig_ctaseguro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctaseguro, se encontraron '||resultado||' errores.');
    END IF;
    --49. MIG_AGENSEGU
    resultado := pac_migracion.f_migra_mig_agensegu;
    --50. CARGA MIG_AGENSEGU
    resultado := pac_migracion.f_carga_mig_agensegu;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_agensegu, se encontraron '||resultado||' errores.');
    END IF;
    --51. MIG_PREGUNGARANSEG
    resultado := pac_migracion.f_migra_mig_pregungaranseg;
    --52. CARGA MIG_PREGUNGARANSEG
    resultado := pac_migracion.f_carga_mig_pregungaranseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_pregungaranseg, se encontraron '||resultado||' errores.');
    END IF;
    --53. MIG_CTGAR_SEGURO
    resultado := pac_migracion.f_migra_mig_ctgar_seguro;
    --54. CARGA MIG_CTGAR_SEGURO
    resultado := pac_migracion.f_carga_mig_ctgar_seguro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctgar_seguro, se encontraron '||resultado||' errores.');
    END IF;
    --55. MIG_AGE_CORRETAJE
    resultado := pac_migracion.f_migra_mig_age_corretaje;
    --56. CARGA MIG_AGE_CORRETAJE
    resultado := pac_migracion.f_carga_mig_age_corretaje;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_age_corretaje, se encontraron '||resultado||' errores.');
    END IF;
    --57. MIG_PSU_RETENIDAS
    resultado := pac_migracion.f_migra_mig_psu_retenidas;
    --58. CARGA MIG_PSU_RETENIDAS
    resultado := pac_migracion.f_carga_mig_psu_retenidas;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_psu_retenidas, se encontraron '||resultado||' errores.');
    END IF;
    --58a. MIG_PSUCONTROLSEG
    resultado := pac_migracion.f_migra_mig_psucontrolseg;
    --58b. CARGA MIG_PSUCONTROLSEG
    resultado := pac_migracion.f_carga_mig_psucontrolseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_psucontrolseg, se encontraron '||resultado||' errores.');
    END IF;
    --59-A. MIG_BF_BONFRANSEG
    resultado := pac_migracion.f_migra_mig_bf_bonfranseg;
    --59-B. CARGA MIG_BF_BONFRANSEG
    resultado := pac_migracion.f_carga_mig_bf_bonfranseg;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_bf_bonfranseg, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --SINIESTROS
    --------------------------------------------------------
    resultado := pac_migracion.f_migra_mig_sin_prof_profesion;
    resultado := pac_migracion.f_carga_mig_sin_prof_profesion;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_prof_profesion, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_prof_indica;
    resultado := pac_migracion.f_carga_mig_sin_prof_indica;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_prof_indica, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_siniestro;
    resultado := pac_migracion.f_carga_mig_sin_siniestro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_siniestro, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_movsiniestro;
    resultado := pac_migracion.f_carga_mig_sin_movsiniestro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_movsiniestro, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tramitacion;
    resultado := pac_migracion.f_carga_mig_sin_tramitacion;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tramitacion, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tramita_mov;
    resultado := pac_migracion.f_carga_mig_sin_tramita_mov;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tramita_mov, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tramita_res;
    resultado := pac_migracion.f_carga_mig_sin_tramita_res;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tramita_res, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tramita_pago;
    resultado := pac_migracion.f_carga_mig_sin_tramita_pago;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tramita_pago, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_movpago;
    resultado := pac_migracion.f_carga_mig_sin_tram_movpago;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_movpago, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_pag_gar;
    resultado := pac_migracion.f_carga_mig_sin_tram_pag_gar;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_pag_gar, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_judicial;
    resultado := pac_migracion.f_carga_mig_sin_tram_judicial;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_judicial, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_judi_det;
    resultado := pac_migracion.f_carga_mig_sin_tram_judi_det;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_judi_det, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_valpret;
    resultado := pac_migracion.f_carga_mig_sin_tram_valpret;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_valpret, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_fiscal;
    resultado := pac_migracion.f_carga_mig_sin_tram_fiscal;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_fiscal, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_vpretfis;
    resultado := pac_migracion.f_carga_mig_sin_tram_vpretfis;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_vpretfis, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_cita;
    resultado := pac_migracion.f_carga_mig_sin_tram_cita;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_cita, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_agd_observa;
    resultado := pac_migracion.f_carga_mig_agd_observa;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_agd_observa, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_sin_tram_apoyo;
    resultado := pac_migracion.f_carga_mig_sin_tram_apoyo;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_apoyo, se encontraron '||resultado||' errores.');
    END IF;
    --7782-24
    resultado := pac_migracion.f_migra_mig_sin_tram_estsin;
    resultado := pac_migracion.f_carga_mig_sin_tram_estsin;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_estsin, se encontraron '||resultado||' errores.');
    END IF;
    resultado := pac_migracion.f_migra_mig_pregunsini;
    resultado := pac_migracion.f_carga_mig_pregunsini;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_sin_tram_estsin, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --ADMINISTRACION
    --------------------------------------------------------
    --92. MIG_RECIBOS
    resultado := pac_migracion.f_migra_mig_recibos;
    --93. CARGA MIG_RECIBOS
    resultado := pac_migracion.f_carga_mig_recibos;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_recibos, se encontraron '||resultado||' errores.');
    END IF;
    --94. MIG_MOVRECIBOS
    resultado := pac_migracion.f_migra_mig_movrecibo;
    --95. CARGA MIG_MOVRECIBOS
    resultado := pac_migracion.f_carga_mig_movrecibo;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_movrecibo, se encontraron '||resultado||' errores.');
    END IF;
    --96. MIG_DETRECIBOS
    resultado := pac_migracion.f_migra_mig_detrecibo;
    --96. CARGA MIG_DETRECIBOS
    resultado := pac_migracion.f_carga_mig_detrecibo;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_detrecibo, se encontraron '||resultado||' errores.');
    END IF;
    --97. MIG_DETMOVRECIBO
    resultado := pac_migracion.f_migra_mig_detmovrecibo;
    --98. CARGA MIG_DETMOVRECIBO
    resultado := pac_migracion.f_carga_mig_detmovrecibo;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_detmovrecibo, se encontraron '||resultado||' errores.');
    END IF;
    --99. MIG_DETMOVRECIBOPAR
    resultado := pac_migracion.f_migra_mig_detmovrecibopar;
    --99. MIG_COMRECIBO
    resultado := pac_migracion.f_migra_mig_comrecibo;
    --100. CARGA MIG_DETMOVRECIBOPAR
    resultado := pac_migracion.f_carga_mig_detmovrecibopar;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_detmovrecibopar, se encontraron '||resultado||' errores.');
    END IF;
    --MIGRA LIQUIDACAB
    resultado := pac_migracion.f_migra_mig_liquidacab;
    --102. CARGA LIQUIDACAB
    resultado := pac_migracion.f_carga_mig_liquidacab;
    --101. MIG_LIQUIDALIN
    resultado := pac_migracion.f_migra_mig_liquidalin;
    --102. CARGA MIG_LIQUIDALIN
    resultado := pac_migracion.f_carga_mig_liquidalin;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_liquidalin, se encontraron '||resultado||' errores.');
    END IF;
    --103. MIG_CTACTES
    resultado := pac_migracion.f_migra_mig_ctactes;
    --104. CARGA MIG_CTACTES
    resultado := pac_migracion.f_carga_mig_ctactes;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctactes, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --PROVISIONES
    --------------------------------------------------------
    --103. MIG_PTPPLP
    resultado := pac_migracion.f_migra_mig_ptpplp;
    --104. CARGA MIG_PTPPLP
    resultado := pac_migracion.f_carga_mig_ptpplp;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ptpplp, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --REASEGURO II
    --------------------------------------------------------
    --105. MIG_CLAUSULASREAS
    resultado := pac_migracion.f_migra_mig_clausulasreas;
    --106. CARGA MIG_CLAUSULASREAS
    resultado := pac_migracion.f_carga_mig_clausulasreas;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_clausulasreas, se encontraron '||resultado||' errores.');
    END IF;
    --107. MIG_CTATECNICA
    resultado := pac_migracion.f_migra_mig_ctatecnica;
    --108. CARGA MIG_CTATECNICA
    resultado := pac_migracion.f_carga_mig_ctatecnica;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctatecnica, se encontraron '||resultado||' errores.');
    END IF;
    --109. MIG_CESIONESREA
    resultado := pac_migracion.f_migra_mig_cesionesrea;
    --110. CARGA MIG_CESIONESREA
    resultado := pac_migracion.f_carga_mig_cesionesrea;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_cesionesrea, se encontraron '||resultado||' errores.');
    END IF;
    --111. MIG_DET_CESIONES
    resultado := pac_migracion.f_migra_mig_det_cesiones;
    --112. CARGA MIG_DET_CESIONES
    resultado := pac_migracion.f_carga_mig_det_cesiones;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_det_cesiones, se encontraron '||resultado||' errores.');
    END IF;
    --113. MIG_CUAFACUL
    resultado := pac_migracion.f_migra_mig_cuafacul;
    --114. CARGA MIG_CUAFACUL
    resultado := pac_migracion.f_carga_mig_cuafacul;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_cuafacul, se encontraron '||resultado||' errores.');
    END IF;
    --115. MIG_CUACESFAC
    resultado := pac_migracion.f_migra_mig_cuacesfac;
    --116. CARGA MIG_CUACESFAC
    resultado := pac_migracion.f_carga_mig_cuacesfac;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_cuacesfac, se encontraron '||resultado||' errores.');
    END IF;
    --116-A. MIG_ECO_TIPOCAMBIO
    resultado := pac_migracion.f_migra_mig_eco_tipocambio;
    --116-B. CARGA MIG_ECO_TIPOCAMBIO
    resultado := pac_migracion.f_carga_mig_eco_tipocambio;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_eco_tipocambio, se encontraron '||resultado||' errores.');
    END IF;
    --116-C. MIG_CTAPB
    resultado := pac_migracion.f_migra_mig_ctapb;
    --116-D. CARGA MIG_CTAPB
    resultado := pac_migracion.f_carga_mig_ctapb;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctapb, se encontraron '||resultado||' errores.');
    END IF;
    --116-E. MIG_PLANILLAS
    resultado := pac_migracion.f_migra_mig_planillas;
    --116-F. CARGA MIG_PLANILLAS
    resultado := pac_migracion.f_carga_mig_planillas;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_planillas, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --FICHA FINANCIERA
    --------------------------------------------------------
    --117. MIG_FIN_GENERAL
    resultado := pac_migracion.f_migra_mig_fin_gen;
    --117A. MIG_FIN_GENERAL_DET
    resultado := pac_migracion.f_migra_mig_fin_gen_det;
    --118. CARGA MIG_FIN_GENERAL
    resultado := pac_migracion.f_carga_mig_fin_gen;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_fin_gen, se encontraron '||resultado||' errores.');
    END IF;
    --119. MIG_FIN_PARINDICADORES
    resultado := pac_migracion.f_migra_mig_fin_parindi;
    --120. CARGA MIG_FIN_PARINDICADORES
    resultado := pac_migracion.f_carga_mig_fin_parindi;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_fin_parindi, se encontraron '||resultado||' errores.');
    END IF;
    --121. MIG_FIN_D_RENTA
    resultado := pac_migracion.f_migra_mig_fin_d_renta;
    --122. CARGA MIG_FIN_D_RENTA
    resultado := pac_migracion.f_carga_mig_fin_d_renta;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_fin_d_renta, se encontraron '||resultado||' errores.');
    END IF;
    --123. MIG_FIN_ENDEUDAMIENTO
    resultado := pac_migracion.f_migra_mig_fin_deuda;
    --124. CARGA MIG_FIN_ENDEUDAMIENTO
    resultado := pac_migracion.f_carga_mig_fin_deuda;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_fin_deuda, se encontraron '||resultado||' errores.');
    END IF;
    --125. MIG_FIN_INDICADORES
    resultado := pac_migracion.f_migra_mig_fin_indi;
    --126. CARGA MIG_FIN_INDICADORES
    resultado := pac_migracion.f_carga_mig_fin_indi;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_fin_indi, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --COASEGURO
    --------------------------------------------------------
    --127. MIG_COACUADRO
    resultado := pac_migracion.f_migra_mig_coacuadro;
    --129. MIG_COACEDIDO
    resultado := pac_migracion.f_migra_mig_coacedido;
    --130. MIG_CTACOASEGURO
    resultado := pac_migracion.f_migra_mig_ctacoaseguro;
    --131. CARGA MIG_CTACOASEGURO
    resultado := pac_migracion.f_carga_mig_ctacoaseguro;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_ctacoaseguro, se encontraron '||resultado||' errores.');
    END IF;
    --------------------------------------------------------
    --FORMULARIO SARLAFT
    --------------------------------------------------------
    --132. MIG_DATSARLAFT
    resultado := pac_migracion.f_migra_mig_datsarlaft;
    --133. CARGA MIG_DATSARLAFT
    resultado := pac_migracion.f_carga_mig_datsarlaft;
    IF resultado != 0 THEN
      num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','E','Error al ejecutar f_carga_mig_datsarlaft, se encontraron '||resultado||' errores.');
    END IF;
    ----------------------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------------------
  /*EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  20100,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20100,'Error al migrar la poliza: '||pnpoliza||' sucursal: '||psucursal||' '||SQLERRM);*/
  END p_migra_datos;
  ----------------------------------------------------------------------------------------------------------------
  ----------------------------------------------------------------------------------------------------------------
  PROCEDURE p_borra_tablas IS
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'borra_tablas';
    vobject  VARCHAR2(200) := 'pac_migracion_uni.p_borra_tablas';
    resultado  number := 0;
  BEGIN
    --TABLAS DE AXIS UAT
    DELETE MIG_PERSONAS_UAT;
    DELETE MIG_DIRECCIONES_UAT;
    DELETE MIG_PERSONAS_REL_UAT;
    DELETE MIG_REGIMENFISCAL_UAT;
    DELETE MIG_PARPERSONAS_UAT;
    DELETE MIG_PER_AGR_MARCAS_UAT;
    DELETE MIG_CTGAR_CONTRAGARANTIA_UAT;
    DELETE MIG_CTGAR_DET_UAT;
    DELETE MIG_CTGAR_INMUEBLE_UAT;
    DELETE MIG_CTGAR_VEHICULO_UAT;
    DELETE MIG_CTGAR_CODEUDOR_UAT;
    DELETE MIG_BUREAU_UAT;
    DELETE MIG_SEGUROS_UAT;
    DELETE MIG_HISTORICOSEGUROS_UAT;
    DELETE MIG_ASEGURADOS_UAT;
    DELETE MIG_MOVSEGURO_UAT;
    DELETE MIG_RIESGOS_UAT;
    DELETE MIG_SITRIESGO_UAT;
    DELETE MIG_GARANSEG_UAT;
    DELETE MIG_CLAUSUESP_UAT;
    DELETE MIG_BENESPSEG_UAT;
    DELETE MIG_PREGUNSEG_UAT;
    DELETE MIG_COMISIONSEGU_UAT;
    DELETE MIG_CTASEGURO_UAT;
    DELETE MIG_AGENSEGU_UAT;
    DELETE MIG_PREGUNGARANSEG_UAT;
    DELETE MIG_CTGAR_SEGURO_UAT;
    DELETE MIG_AGE_CORRETAJE_UAT;
    DELETE MIG_PSU_RETENIDAS_UAT;
    DELETE MIG_BF_BONFRANSEG_UAT;
    DELETE MIG_RECIBOS_UAT;
    DELETE MIG_MOVRECIBO_UAT;
    DELETE MIG_DETRECIBOS_UAT;
    DELETE MIG_DETMOVRECIBO_UAT;
    DELETE MIG_DETMOVRECIBO_PARCIAL_UAT;
    DELETE MIG_PTPPLP_UAT;
    DELETE MIG_CLAUSULAS_REAS_UAT;
    DELETE MIG_CESIONESREA_UAT;
    DELETE MIG_DET_CESIONESREA_UAT;
    DELETE MIG_CUAFACUL_UAT;
    DELETE MIG_CUACESFAC_UAT;
    DELETE MIG_FIN_GENERAL_UAT;
    DELETE MIG_FIN_D_RENTA_UAT;
    DELETE MIG_FIN_ENDEUDAMIENTO_UAT;
    DELETE MIG_FIN_INDICADORES_UAT;
    DELETE MIG_FIN_PARAINDICADORES_UAT;
    DELETE MIG_COACUADRO_UAT;
    DELETE MIG_COACEDIDO_UAT;
    DELETE MIG_CTACOASEGURO_UAT;
    DELETE MIG_DATSARLAFT_UAT;
    --DELETE MIG_AGENTES_UAT;
    --DELETE MIG_COMPANIAS_UAT;
    DELETE MIG_CODICONTRATOS_UAT;
    DELETE MIG_AGR_CONTRATOS_UAT;
    DELETE MIG_CONTRATOS_UAT;
    DELETE MIG_TRAMOS_UAT;
    DELETE MIG_CUADROCES_UAT;
    DELETE MIG_TIPOS_INDICADORES_UAT;
    DELETE MIG_LIQUIDACAB_UAT;
    DELETE MIG_LIQUIDALIN_UAT;
    DELETE MIG_CTACTES_UAT;
    DELETE MIG_CTATECNICA_UAT;
    DELETE MIG_ECO_TIPOCAMBIO_UAT;
    DELETE MIG_CTAPB_UAT;
    DELETE MIG_PLANILLAS_UAT;
    DELETE MIG_COMRECIBO_UAT;
    DELETE MIG_PER_INDICADORES_UAT;
    --INSERT INTO MIG_COMPANIAS_UAT
    --7183 EZ SE AGREGAN LAS TABLAS DE SINIESTROS
    DELETE MIG_SIN_SINIESTRO_UAT;
    DELETE MIG_SIN_MOVSINIESTRO_UAT;
    DELETE MIG_SIN_TRAMITACION_UAT;
    DELETE MIG_SIN_TRAMITA_MOVIMIENTO_UAT;
    DELETE MIG_SIN_TRAMITA_RESERVA_UAT;
    DELETE MIG_SIN_TRAMITA_PAGO_UAT;
    DELETE MIG_SIN_TRAMITA_MOVPAGO_UAT;
    DELETE MIG_SIN_TRAMITA_PAGO_GAR_UAT;
    DELETE MIG_SIN_TRAMITA_JUDICIAL_UAT;
    DELETE MIG_SIN_TRAM_JUDI_DETPER_UAT;
    DELETE MIG_SIN_TRAM_VALPRET_UAT;
    DELETE MIG_SIN_TRAMITA_FISCAL_UAT;
    DELETE MIG_SIN_TRAM_VPRETFIS_UAT;
    DELETE MIG_SIN_TRAMITA_CITACIONES_UAT;
    DELETE MIG_AGD_OBSERVACIONES_UAT;
    DELETE MIG_SIN_TRAMITA_APOYO_UAT;
    DELETE MIG_FIN_GENERAL_DET_UAT;
    DELETE MIG_PAGADOR_ALT_UAT;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
  END p_borra_tablas;
  --------------------------------------------------------------------------------------------------------
  PROCEDURE p_copia_datos IS
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'p_copia_datos';
    vobject  VARCHAR2(200) := 'pac_migracion_uni.p_migra_poliza';
    resultado  number := 0;
  BEGIN
    INSERT INTO MIG_PERSONAS_UAT 
    SELECT mig_pk, snip, ctipide, nnumide, cestper, cpertip, fultmod, swpubli, csexper, fnacimi, cagente, 
           tapelli1, tapelli2, tnombre, tnombre2, cestciv, cpais, cprofes, cnacio, ctipban, cbancar, cidioma, 
           tdigitoide, fdefunc, sucrea, fechaing, modulo, aux_nnumide, nnumide_deud, nnumide_acre 
    FROM MIG_PERSONAS@PRODUCCION;
    --
    INSERT INTO MIG_DIRECCIONES_UAT 
    SELECT mig_pk, mig_fk, sperson, cagente, cdomici, cpostal, cprovin, cpoblac, tnomvia, ctipdir, cviavp, 
           clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, 
           cdet3ia, tnum3ia, localidad, tnumtel, tnumfax, tnummov, temail, sucrea, fechaing, modulo, talias
    FROM MIG_DIRECCIONES@PRODUCCION;
    --
    INSERT INTO MIG_PERSONAS_REL_UAT--EZ 17/01/2020 SE CAMBIA EL CAMPO A NULL POR QUE NO ES UN CAMPO DE MIGRACION
    SELECT mig_pk, mig_fk, fkrel, ctiprel, pparticipacion, islider, cagrupa, fagrupa, NULL mig_valida FROM MIG_PERSONAS_REL@PRODUCCION;
    --
    INSERT INTO MIG_PAGADOR_ALT_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, cestado FROM MIG_PAGADOR_ALT@PRODUCCION;
    --
    INSERT INTO MIG_REGIMENFISCAL_UAT 
    SELECT mig_pk, mig_fk, nanuali, fefecto, cregfis FROM MIG_REGIMENFISCAL@PRODUCCION;
    --
    INSERT INTO MIG_PARPERSONAS_UAT 
    SELECT mig_pk, mig_fk, cparam, tipval, valval FROM MIG_PARPERSONAS@PRODUCCION;
    --
    INSERT INTO MIG_PER_AGR_MARCAS_UAT 
    SELECT mig_pk, mig_fk, cmarca, nmovimi, ctipo, ctomador, cconsorcio, casegurado, ccodeudor, cbenef, caccionista, cintermed, 
           crepresen, capoderado, cpagador, tobseva, cuser, falta, cproveedor
    FROM MIG_PER_AGR_MARCAS@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_CONTRAGARANTIA_UAT 
    SELECT mig_pk, mig_fk, scontgar, nmovimi, tdescripcion, ctipo, cclase, cmoneda, ivalor, fvencimi, nempresa, nradica, fcrea, 
           documento, ctenedor, tobsten, cestado, corigen, tcausa, tauxilia, cimpreso, cusualt, falta
    FROM MIG_CTGAR_CONTRAGARANTIA@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_DET_UAT 
    SELECT mig_pk, mig_fk, cpais, fexpedic, cbanco, sperfide, tsucursal, iinteres, fvencimi, fvencimi1, fvencimi2, nplazo, iasegura, 
           iintcap, texpagare, texiden
    FROM MIG_CTGAR_DET@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_INMUEBLE_UAT 
    SELECT mig_pk, mig_fk, nnumescr, fescritura, tdescripcion, tdireccion, cpais, cprovin, cpoblac, fcertlib
    FROM MIG_CTGAR_INMUEBLE@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_VEHICULO_UAT 
    SELECT mig_pk, mig_fk, cpais, cprovin, cpoblac, cmarca, ctipo, nmotor, nplaca, ncolor, nserie, casegura
    FROM MIG_CTGAR_VEHICULO@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_CODEUDOR_UAT 
    SELECT mig_pk, mig_fk, mif_fk2
    FROM MIG_CTGAR_CODEUDOR@PRODUCCION;
    --
    INSERT INTO MIG_BUREAU_UAT 
    SELECT mig_pk, sbureau, nmovimi, canulada, ctipo, nsuplem, cusualt, falta, cusumod, fmodif
    FROM MIG_BUREAU@PRODUCCION;
    --
    INSERT INTO MIG_SEGUROS_UAT 
    SELECT mig_pk, mig_fk, mig_fkdir, cagente, npoliza, ncertif, fefecto, cactivi, ccobban, ctiprea, creafac, ctipcom, csituac, fvencim, 
           femisio, fanulac, iprianu, cidioma, cforpag, creteni, ctipcoa, sciacoa, pparcoa, npolcoa, nsupcoa, ncuacoa, pdtocom, cempres, 
           sproduc, ccompani, ctipcob, crevali, prevali, irevali, ctipban, cbancar, casegur, nsuplem, cdomici, npolini, fcarant, fcarpro, 
           crecfra, ndurcob, fcaranu, nduraci, nedamar, fefeplazo, fvencplazo, mig_fk2, sucrea, fechaing, modulo
    FROM MIG_SEGUROS@PRODUCCION;
    --
    INSERT INTO MIG_HISTORICOSEGUROS_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, mig_fkdir, cagente, ncertif, fefecto, cactivi, ccobban, ctiprea, creafac, ctipcom, csituac, fvencim, 
           femisio, fanulac, iprianu, cidioma, cforpag, creteni, ctipcoa, sciacoa, pparcoa, npolcoa, nsupcoa, ncuacoa, pdtocom, cempres, 
           sproduc, ccompani, ctipcob, crevali, prevali, irevali, ctipban, cbancar, casegur, nsuplem, cdomici, npolini, fcarant, fcarpro, 
           crecfra, ndurcob, fcaranu, nduraci, nedamar, fefeplazo, fvencplazo, mig_fk3, sucrea, fechaing, modulo
    FROM MIG_HISTORICOSEGUROS@PRODUCCION;
    --
    INSERT INTO MIG_ASEGURADOS_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, cdomici, ffecini, ffecfin, ffecmue, fecretroact, sucrea, fechaing, modulo
    FROM MIG_ASEGURADOS@PRODUCCION;
    --
    INSERT INTO MIG_MOVSEGURO_UAT 
    SELECT mig_pk, mig_fk, nmovimi, cmotven, fmovimi, cmovseg, fefecto, cusumov, cmotmov, nmovimi_ant, sucrea, fechaing, modulo
    FROM MIG_MOVSEGURO@PRODUCCION;
    --
    INSERT INTO MIG_RIESGOS_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, nriesgo, nmovima, fefecto, nmovimb, fanulac, tnatrie, pdtocom, precarg, pdtotec, preccom, sucrea, 
           fechaing, modulo, tdescrie
    FROM MIG_RIESGOS@PRODUCCION;
    --
    INSERT INTO MIG_SITRIESGO_UAT 
    SELECT mig_pk, mig_fk, nriesgo, cprovin, cpostal, cpoblac, csiglas, tnomvia, nnumvia, tcomple, fgisx, fgisy, fgisz, cvalida, cviavp, 
           clitvp, cbisvp, corvp, nviaadco, clitco, corco, nplacaco, cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, iddomici, 
           localidad, fdefecto, sucrea, fechaing, modulo
    FROM MIG_SITRIESGO@PRODUCCION;
    --
    INSERT INTO MIG_GARANSEG_UAT 
    SELECT mig_pk, mig_fk, cgarant, nriesgo, nmovimi, finiefe, ffinefe, icapital, precarg, iextrap, iprianu, irecarg, ipritar, falta, crevali, 
           prevali, irevali, nmovima, pdtocom, idtocom, totanu, pdotec, preccom, idtotec, ireccom, finivig, ffinvig, sucrea, fechaing, modulo
    FROM MIG_GARANSEG@PRODUCCION;
    --
    INSERT INTO MIG_CLAUSUESP_UAT 
    SELECT mig_pk, mig_fk, nriesgo, nmovimi, cclaesp, nordcla, finiclau, ffinclau, sclagen, tclaesp, sucrea, fechaing, modulo
    FROM MIG_CLAUSUESP@PRODUCCION;
    --
    INSERT INTO MIG_BENESPSEG_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, nbenef, nriesgo, nmovimi, cgarant, cusuari, fmovimi, cestado, tipo_de_beneficiario, parentesco, porcentaje, 
           sucrea, fechaing, modulo
    FROM MIG_BENESPSEG@PRODUCCION;
    --
    INSERT INTO MIG_PREGUNSEG_UAT 
    SELECT mig_pk, mig_fk, nriesgo, nmovimi, cpregun, crespue, sucrea, fechaing, modulo
    FROM MIG_PREGUNSEG@PRODUCCION;
    --
    INSERT INTO MIG_COMISIONSEGU_UAT 
    SELECT mig_pk, mig_fk, cmodcom, pcomisi, ninialt, nfinalt, nmovimi, sucrea, fechaing, modulo
    FROM MIG_COMISIONSEGU@PRODUCCION;
    --
    INSERT INTO MIG_CTASEGURO_UAT 
    SELECT mig_pk, mig_fk, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, ccalint, imovim2, nrecibo, nsinies, cmovanu, smovrec, 
           cesta, nunidad, cestado, fasign, nparpla, cestpar, iexceso, spermin, sidepag, ctipapor, srecren, sucrea, fechaing, modulo
    FROM MIG_CTASEGURO@PRODUCCION;
    --
    INSERT INTO MIG_AGENSEGU_UAT 
    SELECT mig_pk, mig_fk, falta, ctipreg, cestado, ttitulo, ffinali, ttextos, cmanual, sucrea, fechaing, modulo
    FROM MIG_AGENSEGU@PRODUCCION;
    --
    INSERT INTO MIG_PREGUNGARANSEG_UAT 
    SELECT mig_pk, mig_fk, nriesgo, cgarant, cpregun, crespue, sucrea, fechaing, modulo
    FROM MIG_PREGUNGARANSEG@PRODUCCION;
    --
    INSERT INTO MIG_CTGAR_SEGURO_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, sucrea, fechaing, modulo
    FROM MIG_CTGAR_SEGURO@PRODUCCION;
    --
    INSERT INTO MIG_AGE_CORRETAJE_UAT 
    SELECT mig_pk, mig_fk, sseguro, nmovimi, nordage, cagente, pcomisi, ppartici, islider, sucrea, fechaing, modulo
    FROM MIG_AGE_CORRETAJE@PRODUCCION;
    --
    INSERT INTO MIG_PSU_RETENIDAS_UAT 
    SELECT mig_pk, mig_fk, sseguro, fmovimi, cmotret, cusuret, ffecret, cusuaut, ffecaut, cdetmotrec, postpper, perpost, sucrea, 
           fechaing, modulo, observ
    FROM MIG_PSU_RETENIDAS@PRODUCCION;
    --
    INSERT INTO MIG_PSUCONTROLSEG_UAT 
    SELECT mig_pk, mig_fk, sseguro, nmovimi, fmovimi, ccontrol, nriesgo, nocurre, cgarant, cnivelr, cmotret, cusuret, ffecret, 
           cusuaut, ffecaut, observ, cdetmotrec, postpper, perpost
    FROM MIG_PSUCONTROLSEG@PRODUCCION;
    --
    INSERT INTO MIG_BF_BONFRANSEG_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, sseguro, nmovimi, nriesgo, cgaran, cgrup, csubgrup, cnivel, cversion, finiefe, ctipgrup, cvalor1, 
           impvalor1, cvalor2, impvalor2, cimpmin, impmin, cimpmax, impmax, ffinefe, cusuaut, falta, cusumod, fmodifi, cniveldefecto
    FROM MIG_BF_BONFRANSEG@PRODUCCION;
    --
    INSERT INTO MIG_RECIBOS_UAT 
    SELECT mig_pk, mig_fk, nmovimi, femisio, fefecto, fvencim, ctiprec, nriesgo, nrecibo, cestrec, freccob, cestimp, esccero, creccia, 
           nrecaux, sucrea, fechaing, modulo
    FROM MIG_RECIBOS@PRODUCCION;
    --
    INSERT INTO MIG_MOVRECIBO_UAT 
    SELECT mig_pk, mig_fk, cestrec, fmovini, fmovfin, fefeadm, fmovdia, cmotmov, sucrea, fechaing, modulo, cmreca, nreccaj, cindicaf, 
           csucursal, ndocsap
    FROM MIG_MOVRECIBO@PRODUCCION;
    --
    INSERT INTO MIG_DETRECIBOS_UAT 
    SELECT mig_pk, mig_fk, cconcep, cgarant, nriesgo, iconcep, iconcep_monpol, fcambio, nmovima, sucrea, fechaing, modulo
    FROM MIG_DETRECIBOS@PRODUCCION;
    --
    INSERT INTO MIG_DETMOVRECIBO_UAT 
    SELECT mig_pk, mig_fk, norden, iimporte, fmovimi, fefeadm, cusuari, tdescrip, fcontab, iimporte_moncon, fcambio, cmreca, nreccaj
    FROM MIG_DETMOVRECIBO@PRODUCCION;
    --
    INSERT INTO MIG_DETMOVRECIBO_PARCIAL_UAT 
    SELECT mig_pk, mig_fk, cconcep, cgarant, nriesgo, fmovimi, iconcep, iconcep_monpol, nmovima, fcambio
    FROM MIG_DETMOVRECIBO_PARCIAL@PRODUCCION;
    --
    INSERT INTO MIG_PTPPLP_UAT 
    SELECT producto, póliza, sinestro, fcalculo, ipplpsd, ipplprc, ivalbruto, ivalpago, ippl, ippp, mig_pk
    FROM MIG_PTPPLP@PRODUCCION;
    --
    INSERT INTO MIG_CLAUSULAS_REAS_UAT 
    SELECT mig_pk, ccodigo, tdescripcion, ctramo, ilim_inf, ilim_sup, pctpart, pctmin, pctmax
    FROM MIG_CLAUSULAS_REAS@PRODUCCION;
    --
    INSERT INTO MIG_CESIONESREA_UAT 
    SELECT mig_pk, mig_fk, scesrea, ncesion, icesion, icapces, mig_fkseg, nversio, scontra, ctramo, sfacult, nriesgo, cgarant, mif_fksini, 
           fefecto, fvencim, fcontab, pcesion, cgenera, fgenera, fregula, fanulac, nmovimi, ipritarrea, idtosel, psobreprima, cdetces, 
           ipleno, icapaci, nmovigen, ctrampa, ctipomov, ccutoff
    FROM MIG_CESIONESREA@PRODUCCION;
    --
    INSERT INTO MIG_DET_CESIONESREA_UAT 
    SELECT mig_pk, mig_fk, scesrea, sdetcesrea, sseguro, nmovimi, ptramo, cgarant, icesion, icapces, pcesion, psobreprima, iextrap, iextrea, 
           ipritarrea, itarifrea, icomext, ccompani, falta, cusualt, fmodifi, cusumod, cdepura, fefecdema, nmovdep, sperson, mig_pkaseg
    FROM MIG_DET_CESIONESREA@PRODUCCION;
    --
    INSERT INTO MIG_CUAFACUL_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, sfacult, cestado, finicuf, cfrebor, scontra, nversio, sseguro, cgarant, ccalif1, ccalif2, spleno, 
           nmovimi, scumulo, nriesgo, ffincuf, plocal, fultbor, pfacced, ifacced, ncesion, ctipfac, ptasaxl, cnotaces
    FROM MIG_CUAFACUL@PRODUCCION;
    --
    INSERT INTO MIG_CUACESFAC_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, sfacult, ccompani, ccomrea, pcesion, icesfij, icomfij, isconta, preserv, pintres, pcomisi, cintres, 
           ccorred, cfreres, cresrea, cconrec, fgarpri, fgardep, pimpint, ctramocomision, tidfcom, NULL presrea
    FROM MIG_CUACESFAC@PRODUCCION;
    --
    INSERT INTO MIG_FIN_GENERAL_UAT 
    SELECT mig_pk, mig_fk, sfinanci, tdescrip, fccomer, cfotorut, frut, ttitulo, cfotoced, fexpiced, cpais, cprovin, cpoblac, tinfoad, 
           cciiu, ctipsoci, cestsoc, tobjsoc, texperi, fconsti, tvigenc, sucrea, fechaing, modulo
    FROM MIG_FIN_GENERAL@PRODUCCION;
    --
    INSERT INTO MIG_FIN_D_RENTA_UAT 
    SELECT mig_pk, mig_fk, fcorte, cesvalor, ipatriliq, irenta, sucrea, fechaing, modulo
    FROM MIG_FIN_D_RENTA@PRODUCCION;
    --
    INSERT INTO MIG_FIN_ENDEUDAMIENTO_UAT 
    SELECT mig_pk, mig_fk, fconsulta, cfuente, iminimo, icappag, icapend, iendtot, ncalifa, ncalifb, ncalifc, ncalifd, ncalife, nconsul, 
           nscore, nmora, icupog, icupos, fcupo, tcupor, crestric, tconcepc, tconceps, tcburea, tcotros, sucrea, fechaing, modulo, 
           nincump
    FROM MIG_FIN_ENDEUDAMIENTO@PRODUCCION;
    --
    INSERT INTO MIG_FIN_INDICADORES_UAT 
    SELECT mig_pk, mig_fk, nmovimi, findicad, imargen, icaptrab, trazcor, tprbaci, ienduada, ndiacar, nrotpro, nrotinv, ndiacicl, irentab, 
           ioblcp, iobllp, igastfin, ivalpt, cesvalor, cmoneda, fcupo, icupog, icupos, fcupos, tcupor, tconcepc, tconceps, tcburea, tcotros, 
           cmoncam, sucrea, fechaing, modulo, ncapfin, ncontpol, naniosvinc
    FROM MIG_FIN_INDICADORES@PRODUCCION;
    --
    INSERT INTO MIG_FIN_PARAINDICADORES_UAT 
    SELECT mig_pk, mig_fk, fecha_est_fin, vt_per_ant, ventas, costo_vt, gasto_adm, util_operac, gasto_fin, res_ant_imp, util_neta, invent, 
           carte_clie, act_corr, prop_plnt_eqp, tot_act_no_corr, act_total, o_fin_corto_plazo, provee_corto_plazo, atc_corto_plazo, pas_corr, 
           o_fin_largo_plazo, atc_largo_plazo, pas_no_corr, pas_total, patri_peri_ant, patri_ano_actual, resv_legal, cap_social, res_ejer_ant, 
           prima_accion, resv_ocasi, valoriza, asignado, sucrea, fechaing, modulo, fuente_informacion
    FROM MIG_FIN_PARAINDICADORES@PRODUCCION;
    --
    INSERT INTO MIG_COACUADRO_UAT 
    SELECT mig_pk, mig_fk, ncuacoa, finicoa, ffincoa, ploccoa, fcuacoa, mig_fk2, npoliza
    FROM MIG_COACUADRO@PRODUCCION;
    --
    INSERT INTO MIG_COACEDIDO_UAT 
    SELECT mig_pk, mig_fk, ncuacoa, mig_fk2, pcescoa, pcomcoa, pcomcon, pcomgas, pcesion
    FROM MIG_COACEDIDO@PRODUCCION;
    --
    INSERT INTO MIG_CTACOASEGURO_UAT 
    SELECT mig_pk, smovcoa, mig_fk2, cimport, ctipcoa, cmovimi, imovimi, fmovimi, fcontab, cdebhab, fliqcia, pcescoa, sidepag, nrecibo, 
           smovrec, cempres, sseguro, sproduc, cestado, ctipmov, tdescri, tdocume, imovimi_moncon, fcambio, nsinies, ccompapr, cmoneda, 
           spagcoa, ctipgas, fcierre, ntramit, nmovres, cgarant, mig_fk3, mig_fk4, mig_fk5
    FROM MIG_CTACOASEGURO@PRODUCCION;
    --
    INSERT INTO MIG_DATSARLAFT_UAT 
    SELECT mig_pk, mig_fk, fradica, sperson, fdiligencia, cauttradat, crutfcc, cestconf, fconfir, cvinculacion, cvintomase, tvintomase, 
           cvintomben, tvintombem, cvinaseben, tvinasebem, tactippal, nciiuppal, tocupacion, tcargo, tempresa, tdirempresa, ttelempresa, 
           tactisec, nciiusec, tdirsec, ttelsec, tprodservcom, iingresos, iactivos, ipatrimonio, iegresos, ipasivos, iotroingreso, tconcotring, 
           cmanrecpub, cpodpub, crecpub, cvinperpub, tvinperpub, cdectribext, tdectribext, torigfond, ctraxmodext, ttraxmodext, cprodfinext, 
           cctamodext, totrasoper, creclindseg, tciudadsuc, tpaisuc, tciudad, tpais, tlugarexpedidoc, resociedad, tnacionali2, ngradopod, 
           ngozrec, nparticipa, nvinculo, ntipdoc, fexpedicdoc, fnacimiento, nrazonso, tnit, tdv, toficinapri, ttelefono, tfax, tsucursal, 
           ttelefonosuc, tfaxsuc, ctipoemp, tcualtemp, tsector, tciiu, tactiaca, trepresentanle, tsegape, tnombres, tnumdoc, tlugnaci, 
           tnacionali1, tindiquevin, per_papellido, per_sapellido, per_nombres, per_tipdocument, per_document, per_fexpedicion, 
           per_lugexpedicion, per_fnacimi, per_lugnacimi, per_nacion1, per_direreci, per_pais, per_ciudad, per_departament, per_email, 
           per_telefono, per_celular, nrecpub, tpresetreclamaci, per_tlugexpedicion, per_tlugnacimi, per_tnacion1, per_tnacion2, per_tpais, 
           per_tdepartament, per_tciudad, emptpais, emptdepatamento, emptciudad, emptpaisuc, emptdepatamentosuc, emptciudadsuc, emptlugnaci, 
           emptnacionali1, emptnacionali2, csujetooblifacion, cusualt, falta
    FROM MIG_DATSARLAFT@PRODUCCION;
    --
    /*INSERT INTO MIG_AGENTES_UAT 
    SELECT mig_pk, mig_fk, cagente, ctipage, cactivo, cretenc, ctipiva, ccomisi, cpadre, cpervisio, cpernivel, cpolvisio, cpolnivel, 
           fmovini, fmovfin, claveinter, cdomici, cdescriiva, descricretenc, descrifuente, cdescriica
    FROM MIG_AGENTES@PRODUCCION;*/
    --
    --INSERT INTO MIG_COMPANIAS_UAT SELECT mig_pk, mig_fk, ccompani, tcompani, ctipcom, ctiprea FROM MIG_COMPANIAS@PRODUCCION;
    --
    INSERT INTO MIG_CODICONTRATOS_UAT 
    SELECT mig_pk, mig_fk, nversion, scontra, spleno, cempres, ctiprea, finictr, ffinctr, nconrel, sconagr, cvidaga, cvidair, ctipcum, 
           cvalid, cretira, cmoneda, tdescripcion, cdevento
    FROM MIG_CODICONTRATOS@PRODUCCION;
    --
    INSERT INTO MIG_AGR_CONTRATOS_UAT 
    SELECT mig_pk, mig_fk, scontra, cramo, cmodali, ccolect, ctipseg, cactivi, cgarant, nversio, ilimsub
    FROM MIG_AGR_CONTRATOS@PRODUCCION;
    --
    INSERT INTO MIG_CONTRATOS_UAT SELECT mig_pk, mig_fk, nversion, scontra, nversio, npriori, fconini, 
                                         nconrel, fconfin, iautori, iretenc, iminces, icapaci, iprioxl, 
                                         ppriosl, tcontra, tobserv, pcedido, priesgos, pdescuento, pgastos, 
                                         ppartbene, creafac, pcesext, cgarrel, cfrecul, sconqp, nverqp, iagrega, 
                                         imaxagr, pdeposito, cdetces, clavecbr, cercartera, nanyosloss, cbasexl, 
                                         closscorridor, ccappedratio, scontraprot, cestado, nversioprot, iprimaesperadas, 
                                         ctpreest, pcomext, fconfinaux, NULL nretpol, NULL nretcul  FROM MIG_CONTRATOS@PRODUCCION;
    --
    INSERT INTO MIG_TRAMOS_UAT SELECT mig_pk, mig_fk, nversio, scontra, ctramo, itottra, nplenos, cfrebor, plocal, 
                                      ixlprio, ixlexce, pslprio, pslexce, ncesion, fultbor, imaxplo, norden, nsegcon, 
                                      nsegver, iminxl, idepxl, nctrxl, nverxl, ptasaxl, ipmd, cfrepmd, caplixl, plimgas, 
                                      pliminx, idaa, ilaa, ctprimaxl, iprimafijaxl, iprimaestimada, caplictasaxl, ctiptasaxl, 
                                      ctramotasaxl, pctpdxl, cforpagpdxl, pctminxl, pctpb, nanyosloss, closscorridor, ccappedratio, 
                                      crepos, ibonorec, impaviso, impcontado, pctcontado, pctgastos, ptasaajuste, icapcoaseg, 
                                      preest, icostofijo, pcomisinterm, narrastrecont, piprio, NULL PTRAMO FROM MIG_TRAMOS@PRODUCCION;
    --
    INSERT INTO MIG_CUADROCES_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, nversio, scontra, ctramo, ccomrea, pcesion, nplenos, icesfij, icomfij, isconta, preserv, pintres, iliacde, 
           ppagosl, ccorred, cintres, cintref, cresref, ireserv, ptasaj, fultliq, iagrega, imaxagr, ctipcomis, pctcomis, ctramocomision, 
           cfreres, pctgastos, anopaquete, numpaquete, nivel, contrato, nit
    FROM MIG_CUADROCES@PRODUCCION;
    --
    INSERT INTO MIG_TIPOS_INDICADORES_UAT 
    SELECT mig_pk, tindica, carea, ctipreg, cimpret, ccindid, cindsap, porcent, cclaing, ibasmin, cprovin, cpoblac, fvigor
    FROM MIG_TIPOS_INDICADORES@PRODUCCION;
    --
    INSERT INTO MIG_LIQUIDACAB_UAT 
    SELECT mig_pk, cagente, nliqmen, fliquid, fmovimi, ctipoliq, cestado, cusuari, fcobro
    FROM MIG_LIQUIDACAB@PRODUCCION;
    --
    INSERT INTO MIG_LIQUIDALIN_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, itotimp, itotalr, iprinet, icomisi, iretenccom, isobrecomision, iretencsobrecom, iconvoleducto, 
           iretencoleoducto, ctipoliq, itotimp_moncia, itotalr_moncia, iprinet_moncia, icomisi_moncia, iretenccom_moncia, 
           isobrecom_moncia, iretencscom_moncia, iconvoleod_moncia, iretoleod_moncia, fcambio
    FROM MIG_LIQUIDALIN@PRODUCCION;
    --
    INSERT INTO MIG_CTACTES_UAT 
    SELECT mig_pk, cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov, iimport, tdescrip, cmanual, mig_fk, mig_fk2, 
           mig_fk3, fvalor, cfiscal, sproduc, ccompani, ctipoliq
    FROM MIG_CTACTES@PRODUCCION;
    --
    INSERT INTO MIG_CTATECNICA_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, nversion, scontra, tramo, nnumlin, fmovimi, fefecto, cconcep, cdedhab, iimport, cestado, iimport_moncon, 
           fcambio, ctipmov, sproduc, npoliza, nsiniestro, tdescri, tdocume, fliquid, cevento, fcontab, sidepag, cusucre, fcreac, 
           cramo, ccorred
    FROM MIG_CTATECNICA@PRODUCCION;
    --
    INSERT INTO MIG_ECO_TIPOCAMBIO_UAT 
    SELECT cmonori, cmondes, fcambio, itasa, mig_pk
    FROM MIG_ECO_TIPOCAMBIO@PRODUCCION;
    --
    INSERT INTO MIG_CTAPB_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, fcierre, cconceppb, tipo, iimport, cempres, ctramo, mig_ctapb, sproduc
    FROM MIG_CTAPB@PRODUCCION;
    --
    INSERT INTO MIG_PLANILLAS_UAT 
    SELECT cmap, cramo, sproduc, fplanilla, ccompani, cobservaciones, consecutivo, cmoneda
    FROM MIG_PLANILLAS@PRODUCCION;
    --
    INSERT INTO MIG_SIN_PROF_PROFESIONALES_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, nregmer, fregmer, nlimite
    FROM MIG_SIN_PROF_PROFESIONALES@PRODUCCION;
    --
    INSERT INTO MIG_SIN_PROF_INDICADORES_UAT 
    SELECT mig_pk, mig_fk, ctipind
    FROM MIG_SIN_PROF_INDICADORES@PRODUCCION;
    --
    INSERT INTO MIG_SIN_SINIESTRO_UAT 
    SELECT mig_pk, mig_fk, nsinies, nriesgo, nmovimi, fsinies, fnotifi, ccausin, cmotsin, cevento, cculpab, creclama, nasegur, cmeddec, 
           ctipdec, ctipide, nnumide, tnom1dec, tnom2dec, tape1dec, tape2dec, tteldec, tsinies, temaildec, ncuacoa, nsincoa, csincia, 
           cusualt, falta, cusumod, fmodifi, sucrea, fechaing, modulo, tdetpreten
    FROM MIG_SIN_SINIESTRO@PRODUCCION;
    --
    INSERT INTO MIG_SIN_MOVSINIESTRO_UAT 
    SELECT mig_pk, mig_fk, nmovsin, cestsin, festsin, ccauest, cunitra, ctramitad, cusualt, falta, sucrea, fechaing, modulo
    FROM MIG_SIN_MOVSINIESTRO@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITACION_UAT 
    SELECT mig_pk, mig_fk, ntramit, ctramit, ctcausin, cinform, nradica, cusualt, falta, cusumod, fmodifi
    FROM MIG_SIN_TRAMITACION@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_MOVIMIENTO_UAT 
    SELECT mig_pk, mig_fk, ntramit, nmovtra, cunitra, ctramitad, cesttra, csubtra, festtra, ccauest, cusualt, falta, sucrea, 
           fechaing, modulo
    FROM MIG_SIN_TRAMITA_MOVIMIENTO@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_RESERVA_UAT 
    SELECT mig_pk, mig_fk, ntramit, ctipres, nmovres, cgarant, ccalres, fmovres, cmonres, ireserva, ipago, iingreso, irecobro, icaprie, 
           ipenali, fresini, fresfin, fultpag, fcontab, iprerec, ctipgas, ifranq, cusualt, falta, cusumod, fmodifi, sucrea, fechaing, 
           modulo, cmovres, MIG_PKPAG--7782-13 EZ SE AGREGA EL CAMPO CMOVRES, 7782-18 SE AGREGA PARA ASOCIAR PAGOS A MOVS. DE RESERVA
    FROM MIG_SIN_TRAMITA_RESERVA@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_PAGO_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, ntramit, ctipdes, ctippag, cconpag, ccauind, cforpag, fordpag, ctipban, cbancar, cmonres, isinret, 
           iretenc, iiva, isuplid, ifranq, iresrcm, iresred, cmonpag, isinretpag, iretencpag, iivapag, isuplidpag, ifranqpag, iresrcmpag, 
           iresredpag, fcambio, nfacref, ffacref, ctransfer, cultpag, ireteiva, ireteica, cusualt, falta, cusumod, fmodifi, sucrea, 
           fechaing, modulo, tobserva--7782-47
    FROM MIG_SIN_TRAMITA_PAGO@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_MOVPAGO_UAT 
    SELECT mig_pk, mig_fk, nmovpag, cestpag, fefepag, cestval, fcontab, csubpag, cusualt, falta, sucrea, fechaing, modulo
    FROM MIG_SIN_TRAMITA_MOVPAGO@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_PAGO_GAR_UAT 
    SELECT mig_pk, mig_fk, ctipres, nmovres, cgarant, fperini, fperfin, cmonres, isinret, iretenc, iiva, isuplid, ifranq, iresrcm, 
           iresred, cmonpag, isinretpag, iivapag, isuplidpag, iretencpag, ifranqpag, iresrcmpag, iresredpag, fcambio, pretenc, piva, 
           ireteiva, preteiva, caplfra, cusualt, falta, cusumod, fmodifi, sucrea, fechaing, modulo
    FROM MIG_SIN_TRAMITA_PAGO_GAR@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_JUDICIAL_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, cproceso, tproceso, cpostal, cpoblac, cprovin, tiexterno, sprofes, frecep, fnotifi, 
           fvencimi, frespues, fconcil, fdesvin, tpreten, texcep1, texcep2, faudien, haudien, taudien, cconti, cdespa, tlaudie, 
           caudien, cdespao, tlaudieo, caudieno, sabogau, coral, cestado, cresolu, finsta1, finsta2, fnueva, tresult, cposici, 
           cdemand, sapodera, idemand, ftdeman, iconden, csenten, fsente1, fsente2, ctsente, tfallo, fmodifi, cusualt, CORALPROC,
           UNICAINST, FUNICAINST
    FROM MIG_SIN_TRAMITA_JUDICIAL@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAM_JUDI_DETPER_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, nrol, npersona, ntipper, nnumide, tnombre, iimporte, fbaja, fmodifi, cusualt
    FROM MIG_SIN_TRAMITA_JUDI_DETPER@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAM_VALPRET_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, cgarant, ipreten, fbaja, fmodifi, cusualt
    FROM MIG_SIN_TRAMITA_VALPRETENSION@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_FISCAL_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, fapertu, fimputa, fnotifi, faudien, haudien, caudien, sprofes, coterri, ccontra, cuespec, 
           tcontra, ctiptra, testado, cmedio, fdescar, ffallo, cfallo, tfallo, crecurso, fmodifi, cusualt
    FROM MIG_SIN_TRAMITA_FISCAL@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAM_VPRETFIS_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, norden, cgarant, ipreten, fbaja, fmodifi, cusualt
    FROM MIG_SIN_TRAMITA_VALPRETFISCAL@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_CITACIONES_UAT 
    SELECT mig_pk, mig_fk, ncitacion, fcitacion, hcitacion, sperson, cpais, cprovin, cpoblac, tlugar, falta, taudien, coral, cestado, 
           cresolu, fnueva, tresult, cmedio
    FROM MIG_SIN_TRAMITA_CITACIONES@PRODUCCION;
    --
    INSERT INTO MIG_AGD_OBSERVACIONES_UAT 
    SELECT mig_pk, mig_fk, ctipobs, ttitobs, tobs, ctipagd, ntramit, publico, cconobs, falta
    FROM MIG_AGD_OBSERVACIONES@PRODUCCION;
    --
    INSERT INTO MIG_SIN_TRAMITA_APOYO_UAT 
    SELECT mig_pk, mig_fk, mig_fk2, sintapo, nsinies, ntramit, napoyo, cunitra, ctramitad, fingreso, ftermino, fsalida, tobserva, tlocali, 
           csiglas, tnomvia, nnumvia, tcomple, cpais, cprovin, cpoblac, cpostal, cviavp, clitvp, cbisvp, corvp, nviaadco, clitco, corco, 
           nplacaco, cor2co, cdet1ia, tnum1ia, cdet2ia, tnum2ia, cdet3ia, tnum3ia, localidad, falta, cusualt, fmodifi, cusumod, tobserva2, 
           cagente, sperson
    FROM MIG_SIN_TRAMITA_APOYO@PRODUCCION;
    --
    INSERT INTO MIG_COMRECIBO_UAT 
    SELECT mig_pk, mig_fk, nrecibo, nnumcom, cagente, cestrec, fmovdia, fcontab, icombru, icomret, icomdev, iretdev, nmovimi, icombru_moncia, 
           icomret_moncia, icomdev_moncia, iretdev_moncia, fcambio, cgarant, icomcedida, icomcedida_moncia, ccompan, ivacomisi, mig_fk2, 
           creccia
    FROM MIG_COMRECIBO@PRODUCCION;
    --
    INSERT INTO MIG_FIN_GENERAL_DET_UAT 
    SELECT mig_pk, mig_fk, sfinanci, nmovimi, tdescrip, cfotorut, frut, ttitulo, cfotoced, fexpiced, cpais, cprovin, cpoblac, tinfoad, cciiu, 
           ctipsoci, cestsoc, tobjsoc, texperi, fconsti, tvigenc, fccomer
    FROM MIG_FIN_GENERAL_DET@PRODUCCION;
    --
    INSERT INTO MIG_PER_INDICADORES_UAT 
    SELECT mig_pk, mig_fk, cod_vinculo, ctipind
    FROM MIG_PER_INDICADORES@PRODUCCION;
    --7782-24
    INSERT INTO MIG_SIN_TRAM_ESTSINIESTRO_UAT 
    SELECT MIG_PK, MIG_FK, nsinies, ntramit, nmovimi, cusualt, falta, nclasepro, ninstproc, nfallocp, ncalmot, fcontingen, tobsfallo
    FROM MIG_SIN_TRAM_ESTSINIESTRO@PRODUCCION;
    --
    INSERT INTO MIG_PREGUNSINI_UAT 
    SELECT mig_pk, mig_fk, nsinies, cpregun, crespue, trespue
    FROM MIG_PREGUNSINI@PRODUCCION;
    --
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RAISE_APPLICATION_ERROR(-20100,SQLERRM);
  END p_copia_datos;
  -------------------------------------------------------------
  --f_migra_mig_personas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_personas
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_personas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_personas';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_personas IS TABLE OF mig_personas%ROWTYPE;
    l_reg_mig_mcc t_mig_personas;
    --
    CURSOR lc_mig_personas IS
     SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK,  0 IDPERSON, a.SNIP, a.CTIPIDE,  a.NNUMIDE,  a.CESTPER,  a.CPERTIP,  a.FULTMOD,  a.SWPUBLI,  DECODE(LENGTH(CSEXPER), 1, CSEXPER, 0) CSEXPER,
            a.FNACIMI,  a.CAGENTE,  a.TAPELLI1, a.TAPELLI2, a.TNOMBRE,  a.CESTCIV,  a.CPAIS,  a.CPROFES,  a.CNACIO, NULL CTIPDIR, 
            NULL CTIPVIA, NULL TNOMVIA, NULL NNUMVIA, NULL TCOMPLE, NULL CPOSTAL, NULL CPOBLAC, NULL CPROVIN, NULL CTIPDIR2,  
            NULL CTIPVIA2,  NULL TNOMVIA2,  NULL NNUMVIA2,  NULL TCOMPLE2,  NULL CPOSTAL2,  NULL CPOBLAC2,  NULL CPROVIN2,  NULL TNUMTEL, 
            NULL TNUMFAX, NULL TNUMMOV, NULL TEMAIL,  a.CTIPBAN,  a.CBANCAR,  a.CIDIOMA,  NULL CTIPIDE2,  NULL NNUMIDE2,  
            NULL FJUBILA, a.TNOMBRE2, a.TDIGITOIDE, NULL PROCESO, NULL FVENCIM, NULL COCUPACION,  NULL FANTIGUEDAD, a.FDEFUNC, a.NNUMIDE_DEUD ,a.NNUMIDE_ACRE
       FROM mig_personas_uat a
      -- WHERE a.ctipide = 0 --37.293 tipo = 0, se pasarían 37.207       AND a.mig_pk NOT IN (SELECT p.mig_pk FROM mig_personas p WHERE p.ncarga = 17411 AND p.ctipide = 38 AND p.idperson <> 0)
      --select * from mig_personas_conf      
    /*ORDER BY CTIPIDE, NNUMIDE*/;
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO   vdummy
    FROM   dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    --SEGUROS
    OPEN lc_mig_personas;
      LOOP
      FETCH lc_mig_personas BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      b_hay_dato := TRUE;
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_personas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        --
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_personas VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_mig_personas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION PERSONAS','I','Error insert: '||l_msg);
            END LOOP;
        END;
        EXIT WHEN lc_mig_personas%NOTFOUND;
      END LOOP;--fin del forall
    CLOSE lc_mig_personas;
    COMMIT;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_personas;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_personas.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_personas;
  -------------------------------------------------------------
  --f_migra_mig_direcciones
  -------------------------------------------------------------
  FUNCTION f_migra_mig_direcciones
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_direcciones';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_direcciones';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_direcciones IS TABLE OF mig_direcciones%ROWTYPE;
    l_reg_mig_mcc t_mig_direcciones;
    --
    CURSOR lc_mig_direcciones IS
      SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SPERSON,  a.CAGENTE,  a.CDOMICI,  a.CPOSTAL,  a.CPROVIN,  a.CPOBLAC,  
            NULL CSIGLAS, a.TNOMVIA,  NULL NNUMVIA, NULL TCOMPLE, a.CTIPDIR,  a.CVIAVP, a.CLITVP, a.CBISVP, a.CORVP,  a.NVIAADCO, a.CLITCO, 
            a.CORCO,  a.NPLACACO, a.COR2CO, a.CDET1IA,  a.TNUM1IA,  a.CDET2IA,  a.TNUM2IA,  a.CDET3IA,  a.TNUM3IA,  a.LOCALIDAD,  
            NULL PROCESO, a.TNUMTEL,  a.TNUMFAX,  a.TNUMMOV,  a.TEMAIL, a.TALIAS
          --  SELECT COUNT(*)
      FROM mig_direcciones_UAT a, mig_personas p
      WHERE a.mig_fk = p.mig_pk;         
        
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_direcciones;
    LOOP
    FETCH lc_mig_direcciones BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
    --dbms_output.put_line('I - paso bullk');
    --dbms_output.put_line('...');
    b_hay_dato := TRUE;
    --
    FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_direcciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
        INSERT INTO mig_direcciones VALUES l_reg_mig_mcc(i);
      EXCEPTION
        WHEN DML_ERRORS THEN
        l_errors := SQL%bulk_exceptions.count;
        --dbms_output.put_line('l_errors:'||l_errors);
        FOR i IN 1 .. l_errors
          LOOP
          l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
          l_msg   := SQLERRM(-l_errno);
          l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
          p_control_error('CXHGOME','02_mig_direcciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
        END LOOP;
      END;
      --dbms_output.put_line('F - paso bullk');
      EXIT WHEN lc_mig_direcciones%NOTFOUND;
    END LOOP;
    CLOSE lc_mig_direcciones;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_direcciones;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_direcciones.');
    --COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_direcciones;
  -------------------------------------------------------------
  --f_migra_mig_personas_rel
  -------------------------------------------------------------
  FUNCTION f_migra_mig_personas_rel
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_personas_rel';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_personas_rel';
    resultado  number := 0;
    --
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_personas_rel IS TABLE OF mig_personas_rel%ROWTYPE;
    l_reg_mig_mcc t_mig_personas_rel;
    --
    CURSOR lc_mig_personas_rel IS
      SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.FKREL, a.CTIPREL, a.PPARTICIPACION, a.ISLIDER, a.CAGRUPA, a.FAGRUPA
      FROM mig_personas_rel_UAT a, mig_personas p
      WHERE a.mig_fk = p.mig_pk
       --ORDER BY a.mig_pk
        ;         
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    --
    OPEN lc_mig_personas_rel;
      LOOP
      --
      FETCH lc_mig_personas_rel BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      --dbms_output.put_line('I - paso bullk');
      --dbms_output.put_line('...');
      b_hay_dato := TRUE;
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_personas_rel WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        --
        BEGIN
          --      
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_personas_rel VALUES l_reg_mig_mcc(i);
          --
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','03_mig_personas_rel','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_personas_rel%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_personas_rel;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_personas_rel;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_personas_rel.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_personas_rel;
  -------------------------------------------------------------
  --f_migra_mig_pagador_alt
  -------------------------------------------------------------
  FUNCTION f_migra_mig_pagador_alt
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_pagador_alt';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_pagador_alt';
    resultado  number := 0;
    --
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_pagador_alt IS TABLE OF mig_pagador_alt%ROWTYPE;
    l_reg_mig_mcc t_mig_pagador_alt;
    --
    CURSOR lc_mig_pagador_alt IS
      SELECT 17413 NCARGA, 1 CESTMIG, a.mig_pk, a.mig_fk, a.mig_fk2, a.cestado
      FROM mig_pagador_alt_uat a, mig_personas p
      WHERE a.mig_fk = p.mig_pk
       --ORDER BY a.mig_pk
        ;         
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    --
    OPEN lc_mig_pagador_alt;
      LOOP
      --
      FETCH lc_mig_pagador_alt BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      b_hay_dato := TRUE;
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_pagador_alt WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        --
        BEGIN
          --      
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_pagador_alt VALUES l_reg_mig_mcc(i);
          --
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','03_mig_personas_rel','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        EXIT WHEN lc_mig_pagador_alt%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_pagador_alt;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_pagador_alt;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_pagador_alt.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_pagador_alt;
  -------------------------------------------------------------
  --f_migra_mig_regimenfiscal
  -------------------------------------------------------------
  FUNCTION f_migra_mig_regimenfiscal
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_regimenfiscal';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_regimenfiscal';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_regimenfiscal IS TABLE OF mig_regimenfiscal%ROWTYPE;
    l_reg_mig_mcc t_mig_regimenfiscal;
    --
    CURSOR lc_mig_regimenfiscal IS
      SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NANUALI, NVL(a.FEFECTO,TRUNC(SYSDATE)), a.CREGFIS
      FROM mig_regimenfiscal_uat a, mig_personas p
      WHERE a.mig_fk = p.mig_pk
      AND   a.NANUALI IS NOT NULL
      AND   a.NANUALI NOT IN(0,1)--7782-44
     --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_regimenfiscal;
      LOOP
      FETCH lc_mig_regimenfiscal BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      --dbms_output.put_line('I - paso bullk');
      --dbms_output.put_line('...');
      b_hay_dato := TRUE;
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_regimenfiscal WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_regimenfiscal VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','03_mig_regimenfiscal','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_regimenfiscal%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_regimenfiscal;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_regimenfiscal;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_regimenfiscal.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_regimenfiscal;
  -------------------------------------------------------------
  --f_migra_mig_parpersonas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_parpersonas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_parpersonas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_parpersonas';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_parpersonas IS TABLE OF mig_parpersonas%ROWTYPE;
    l_reg_mig_mcc t_mig_parpersonas;
    --
    CURSOR lc_mig_parpersonas IS
      SELECT 17413 NCARGA,
           1 CESTMIG,
           a.mig_pk,
           a.mig_fk,
           a.cparam,
           a.tipval,
           a.valval
      FROM mig_parpersonas_uat a, mig_personas p
      WHERE a.mig_fk = p.mig_pk
      --ORDER BY CTIPIDE, NNUMIDE
      ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_parpersonas;
      LOOP
      FETCH lc_mig_parpersonas BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_parpersonas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_parpersonas VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_mig_parpersonas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION PARPERSONAS','I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_parpersonas%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_parpersonas;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_parpersonas;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_parpersonas.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_parpersonas;
  -------------------------------------------------------------
  --f_migra_mig_agentes
  -------------------------------------------------------------
  FUNCTION f_migra_mig_agentes
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_agentes';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_agentes';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    b_hay_personas    BOOLEAN;
    vncarga           mig_cargas.ncarga%TYPE := 17413;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    FOR l_per IN ( SELECT a.*
                   FROM   mig_personas mpc, mig_agentes_uat a
                   WHERE  mpc.mig_pk = a.mig_fk
                   AND  ( ctipide  IS NOT NULL
                          AND cestper  IS NOT NULL
                          AND cpertip  IS NOT NULL
                          AND swpubli  IS NOT NULL
                          AND tapelli1 IS NOT NULL)
                   AND    mpc.mig_pk NOT IN ( SELECT DISTINCT mp.mig_pk
                                              FROM   mig_personas mp, per_personas p, agentes a
                                              WHERE a.sperson  = p.sperson
                                              AND   mp.nnumide = p.nnumide
                                              AND   mp.ctipide = p.ctipide
                                              AND  ( mp.ctipide  IS NOT NULL
                                                     AND mp.cestper  IS NOT NULL
                                                     AND mp.cpertip  IS NOT NULL
                                                     AND mp.swpubli  IS NOT NULL
                                                     AND mp.tapelli1 IS NOT NULL)
                                              AND ( SELECT COUNT(pp.sperson)
                                                    FROM   per_personas pp, agentes ag
                                                    WHERE  pp.nnumide = mp.nnumide
                                                    AND    pp.ctipide = mp.ctipide
                                                    AND    pp.sperson = ag.sperson) > 0)
                  ORDER BY mpc.CTIPIDE, mpc.NNUMIDE) LOOP
      b_hay_personas := TRUE;
      b_hay_dato     := TRUE;
      BEGIN
        BEGIN
           INSERT INTO mig_agentes(ncarga, cestmig, mig_pk, mig_fk, cagente, idperson, ctipage, cactivo,
                           cretenc, ctipiva, ccomisi, cpadre, fmovini, fmovfin, cpervisio,
                           cpernivel, cpolvisio, cpolnivel, finivig)
           VALUES(vncarga,
                 1,
                 l_per.mig_pk,
                 l_per.mig_fk,
                 f_set_agente(24, l_per.ctipage) ,
                 0 , --idperson
                 l_per.ctipage, -- nvl(ctipage,5),
                 --ojo con esto la aspecifiación es incorrecta 0 activo 1- inactivo, cuando es al reves
                 l_per.cactivo,
                 l_per.cretenc,
                 l_per.ctipiva,
                 to_number(REPLACE(REPLACE(REPLACE(l_per.ccomisi, 'GC', ''),
                                           '#N/A',
                                           1),
                                   'GR',
                                   '')) ,
                 l_per.cpadre,
                 NVL(l_per.fmovini, f_sysdate),
                 l_per.fmovfin,
                 v_agente_pervisio,
                 DECODE(l_per.cpernivel, 0, 1, l_per.cpernivel),
                 v_agente_pervisio,
                 DECODE(l_per.cpolnivel, 0, 1, l_per.cpolnivel) , --cpolnivel
                 l_per.fmovini);
           --dbms_output.put_line('- Inserta  - '||SQL%ROWCOUNT);
        EXCEPTION
          WHEN OTHERS THEN
            p_control_error('CXHGOME','05_Mig_Agentes', 'l_per.mig_pk: '||l_per.mig_pk||' ERR:'||SQLERRM);
            --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_per.mig_pk,'I','Error insert: '||SQLERRM);
            --dbms_output.put_line('l_per.mig_pk: '||l_per.mig_pk||' ERR:'||SQLERRM);
            b_error := TRUE;
            --
        END;
      EXCEPTION
        WHEN OTHERS THEN
          --dbms_output.put_line('LOOP PERSONAS [' ||l_per.MIG_PK||', '|| l_per.MIG_FK ||'] - ERR:'||SQLERRM);
          b_error := TRUE;
      END;
    END LOOP;
    --
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_agentes;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_agentes.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_agentes;
  -------------------------------------------------------------
  --f_migra_mig_per_agr_marcas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_per_agr_marcas
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_per_agr_marcas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_per_agr_marcas';
    resultado  number := 0;
  --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_per_agr_marcas IS TABLE OF mig_per_agr_marcas%ROWTYPE;
    l_reg_mig_mcc t_mig_per_agr_marcas;
    --
    CURSOR lc_mig_per_agr_marcas IS
      SELECT 17413 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CMARCA, a.CTIPO, a.CTOMADOR, a.CCONSORCIO, a.CASEGURADO, a.CCODEUDOR, a.CBENEF, a.CACCIONISTA, a.CINTERMED,
        a.CREPRESEN, a.CAPODERADO, a.CPAGADOR, a.TOBSEVA, a.NMOVIMI, a.CPROVEEDOR
       FROM mig_per_agr_marcas_uat a, mig_personas p
       WHERE p.mig_pk = a.mig_fk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
  --l_timestart := dbms_utility.get_time(); 
  SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
  INTO vdummy
  FROM dual;
  --
  b_error    := FALSE;
  b_hay_dato := FALSE;
  --
  OPEN lc_mig_per_agr_marcas;
    LOOP
    --
    FETCH lc_mig_per_agr_marcas BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
    --dbms_output.put_line('I - paso bullk');
    --dbms_output.put_line('...');
    b_hay_dato := TRUE;
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
      DELETE FROM mig_per_agr_marcas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
      --
      BEGIN
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
        INSERT INTO mig_per_agr_marcas VALUES l_reg_mig_mcc(i);
      EXCEPTION
        WHEN DML_ERRORS THEN
        l_errors := SQL%bulk_exceptions.count;
        --dbms_output.put_line('l_errors:'||l_errors);
        FOR i IN 1 .. l_errors LOOP
        l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
        l_msg   := SQLERRM(-l_errno);
        l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
        p_control_error('CXHGOME','06_mig_per_agr_marcas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
        --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
        END LOOP;
      END;
      --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_per_agr_marcas%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_per_agr_marcas;
  
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_per_agr_marcas;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_per_agr_marcas.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_per_agr_marcas;
  -------------------------------------------------------------
  --f_carga_mig_personas
  -------------------------------------------------------------
  FUNCTION f_carga_mig_personas
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_personas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_personas';
    resultado  number := 0;
  --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17413;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;-- AND TAB_DES = 'MIG_PERSONAS';
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE mig_logs_axis WHERE NCARGA = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PERSONAS_TXT',
                                         ptipo   => 'C',
                                         pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_personas;
  -------------------------------------------------------------
  --f_carga_mig_per_agr_marcas
  -------------------------------------------------------------
  /*FUNCTION f_carga_mig_per_agr_marcas
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_per_agr_marcas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_per_agr_marcas';
    resultado  number := 0;
  --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17413;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PER_AGR_MARCAS_TXT',
                                         ptipo   => 'C',
                                         pncarga => vncarga);
    --
    --SELECT COUNT(*) INTO v_cant FROM mig_logs_axis s WHERE s.ncarga = vncarga AND s.seqlog > NVL(v_seqlog, 0);
    --dbms_output.put_line('SELECT * FROM mig_logs_axis s WHERE s.ncarga = ' || vncarga || ' AND s.seqlog > ' || NVL(v_seqlog, 0) || ';');
    --SELECT COUNT(*) INTO v_cant FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('v_cant errores [mig_logs_axis] log: '||v_cant);
    --l_timeend := dbms_utility.get_time(); 
    --l_time    := (l_timeend - l_timestart) / 100;
    --dbms_output.put_line('Tiempo de Ejecución: ' || l_time ||' [s]'); 
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END;*/
  -------------------------------------------------------------
  --f_migra_mig_companias
  -------------------------------------------------------------
  FUNCTION f_migra_mig_companias
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_companias';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_companias';
    resultado  number := 0;
  --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_companias IS TABLE OF mig_companias%ROWTYPE;
    l_reg_mig_mcc t_mig_companias;
    --
    CURSOR lc_mig_companias IS
      SELECT 17415 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 CCOMPANI, a.TCOMPANI, a.CTIPCOM, a.CTIPREA
      FROM mig_companias_UAT a
        ;
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    l_timestart := dbms_utility.get_time(); 
    
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_companias;
      LOOP
      FETCH lc_mig_companias BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
      --dbms_output.put_line('I - paso bullk');  
      --dbms_output.put_line('...');  
      b_hay_dato := TRUE;
      --
      FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_companias WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_companias VALUES l_reg_mig_mcc(i);
            --NULL;
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_Mig_Companias','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_companias%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_companias;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_companias;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_companias.');
    RETURN 0;
  END f_migra_mig_companias;
  -------------------------------------------------------------
  --f_carga_mig_companias
  -------------------------------------------------------------
  FUNCTION f_carga_mig_companias
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_companias';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_companias';
    resultado  number := 0;
  --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17415;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --
    l_timestart := dbms_utility.get_time(); 
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COMPANIAS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_companias;
  -------------------------------------------------------------
  --f_migra_mig_codicontratos
  -------------------------------------------------------------
  FUNCTION f_migra_mig_codicontratos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_codicontratos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_companias';
    resultado  number := 0;
  --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;

    TYPE t_mig_CodiContratos IS TABLE OF mig_CodiContratos%ROWTYPE;
    l_reg_mig_mcc t_mig_CodiContratos;

    CURSOR lc_mig_CodiContratos IS
      SELECT 17415 ncarga,1 CESTMIG, a.MIG_PK, NVL(a.MIG_FK, 0) mig_fk, a.NVERSION, 0 SCONTRA, a.SPLENO, a.CEMPRES, a.CTIPREA,
            a.FINICTR, a.FFINCTR, a.NCONREL, a.SCONAGR, a.CVIDAGA, a.CVIDAIR, a.CTIPCUM, a.CVALID, a.CRETIRA, 
            a.CMONEDA, a.TDESCRIPCION, a.CDEVENTO
       FROM mig_CodiContratos_uat a
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    --
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_CodiContratos;
      LOOP
      FETCH lc_mig_CodiContratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
      --dbms_output.put_line('I - paso bullk');  
      --dbms_output.put_line('...');  
      --b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_CodiContratos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','03_Mig_CodiContratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_CodiContratos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_CodiContratos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_CodiContratos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_CodiContratos.');
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_migra_mig_codicontratos;
  -------------------------------------------------------------
  --f_carga_mig_codicontratos
  -------------------------------------------------------------
  /*FUNCTION f_carga_mig_codicontratos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_codicontratos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_companias';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17415;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga AND s.tab_des IN ('MIG_CODICONTRATOS');
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COMPANIAS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    \*SELECT COUNT(*) INTO v_cant FROM mig_logs_axis s WHERE s.ncarga = vncarga AND s.seqlog > NVL(v_seqlog, 0);
    dbms_output.put_line('SELECT * FROM mig_logs_axis s WHERE s.ncarga = ' || vncarga || ' AND s.seqlog > ' || NVL(v_seqlog, 0) || ';');
    SELECT COUNT(*) INTO v_cant FROM mig_logs_axis s WHERE s.ncarga = vncarga AND s.seqlog > NVL(v_seqlog, 0);
    dbms_output.put_line('v_cant errores [mig_logs_axis] log: '||v_cant);
    l_timeend := dbms_utility.get_time(); 
    l_time    := (l_timeend - l_timestart) / 100;
    dbms_output.put_line('Tiempo de Ejecución: ' || l_time ||' [s]'); *\
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_codicontratos;*/
  -------------------------------------------------------------
  --f_carga_mig_codicontratos
  -------------------------------------------------------------
  FUNCTION f_migra_mig_agr_contratos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_agr_contratos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_agr_contratos';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;

    TYPE t_mig_Agr_contratos IS TABLE OF mig_Agr_contratos%ROWTYPE;
    l_reg_mig_mcc t_mig_Agr_contratos;

    CURSOR lc_mig_Agr_contratos IS
     SELECT 17415 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SCONTRA, a.CRAMO, a.CMODALI, 
            a.CCOLECT, a.CTIPSEG, a.CACTIVI, a.CGARANT, a.NVERSIO, a.ILIMSUB
       FROM mig_Agr_contratos_uat a, mig_codicontratos c
      WHERE 1 = 1
        AND a.mig_fk = c.mig_pk
        ; 
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_Agr_contratos;
      LOOP
      FETCH lc_mig_Agr_contratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_Agr_contratos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
          l_errors := SQL%bulk_exceptions.count;
          --dbms_output.put_line('l_errors:'||l_errors);   
          FOR i IN 1 .. l_errors LOOP
            l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
            l_msg   := SQLERRM(-l_errno);
            l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
            p_control_error('CXHGOME','04_mig_Agr_contratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
          END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_Agr_contratos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_Agr_contratos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_Agr_contratos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_Agr_contratos.');
    RETURN 0;
  END f_migra_mig_agr_contratos;
  -------------------------------------------------------------
  --f_migra_mig_contratos
  -------------------------------------------------------------
  FUNCTION f_migra_mig_contratos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_contratos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_contratos';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17416;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;

    TYPE t_mig_contratos IS TABLE OF mig_contratos%ROWTYPE;
    l_reg_mig_mcc t_mig_contratos;
    CURSOR lc_mig_contratos IS
     SELECT 17416 ncarga,1 CESTMIG, mcc.MIG_PK, mcc.MIG_FK,  NVERSIO, '0' SCONTRA,NVERSIO, '0' NPRIORI,FCONINI,mcc.NCONREL,FCONFIN,IAUTORI,
          IRETENC,IMINCES,ICAPACI,IPRIOXL,PPRIOSL,TCONTRA,TOBSERV,PCEDIDO,PRIESGOS,PDESCUENTO,
          PGASTOS,PPARTBENE,CREAFAC,PCESEXT,CGARREL,CFRECUL,SCONQP,NVERQP,IAGREGA,IMAXAGR,
          PDEPOSITO,CDETCES,CLAVECBR,CERCARTERA,NANYOSLOSS,CBASEXL,CLOSSCORRIDOR,CCAPPEDRATIO,
          SCONTRAPROT,CESTADO,NVERSIOPROT,IPRIMAESPERADAS,CTPREEST,PCOMEXT, FCONFINAUX, NRETPOL, NRETCUL
       FROM mig_contratos_uat mcc, mig_codicontratos mc
       WHERE mcc.mig_fk = mc.mig_pk
       --ORDER BY MIG_PK
        ;
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_contratos;
      LOOP
      FETCH lc_mig_contratos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;

        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_contratos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
          l_errors := SQL%bulk_exceptions.count;
          --dbms_output.put_line('l_errors:'||l_errors);   
          FOR i IN 1 .. l_errors LOOP
            l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
            l_msg   := SQLERRM(-l_errno);
            l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
            p_control_error('CXHGOME','06_Mig_Contratos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_contratos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_contratos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_companias;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_contratos.');
    RETURN 0;
  END f_migra_mig_contratos;
  -------------------------------------------------------------
  --f_carga_mig_contratos
  -------------------------------------------------------------
  FUNCTION f_carga_mig_contratos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_contratos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_contratos';
    resultado  number := 0;
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17416;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    l_timestart := dbms_utility.get_time(); 
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CONTRATOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_contratos;
  -------------------------------------------------------------
  --f_migra_mig_tramos
  -------------------------------------------------------------
  FUNCTION f_migra_mig_tramos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_tramos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_tramos';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17417;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_tramos IS TABLE OF mig_tramos%ROWTYPE;
    l_reg_mig_mcc t_mig_tramos;
    --
    CURSOR lc_mig_tramos IS
     SELECT DISTINCT 17417 ncarga,1 CESTMIG, mcc.MIG_PK, mcc.MIG_FK, mcc.NVERSIO, 0 SCONTRA, TO_NUMBER(SUBSTR(mcc.CTRAMO,1 , 2)) CTRAMO, mcc.ITOTTRA, mcc.NPLENOS, mcc.CFREBOR, mcc.PLOCAL,
                  mcc.IXLPRIO, mcc.IXLEXCE, mcc.PSLPRIO, mcc.PSLEXCE, mcc.NCESION, mcc.FULTBOR, mcc.IMAXPLO, TO_NUMBER(SUBSTR(NORDEN, 1, 2)) NORDEN, NSEGCON, NSEGVER, IMINXL, IDEPXL, NCTRXL,
                  NVERXL, PTASAXL, IPMD, CFREPMD, CAPLIXL, PLIMGAS, PLIMINX, IDAA, ILAA, CTPRIMAXL, IPRIMAFIJAXL, IPRIMAESTIMADA,
                  CAPLICTASAXL, CTIPTASAXL, CTRAMOTASAXL, PCTPDXL, CFORPAGPDXL, PCTMINXL, PCTPB, mcc.NANYOSLOSS, mcc.CLOSSCORRIDOR, mcc.CCAPPEDRATIO,
                  CREPOS, IBONOREC, IMPAVISO, IMPCONTADO, PCTCONTADO, PCTGASTOS, PTASAAJUSTE, ICAPCOASEG, PREEST, ICOSTOFIJO, PCOMISINTERM,
                  NARRASTRECONT,PTRAMO,PIPRIO
       FROM mig_tramos_uat mcc, mig_contratos mc
       WHERE mcc.mig_fk = mc.mig_pk
        ; 
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_tramos;
      LOOP
      FETCH lc_mig_tramos BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        /*dbms_output.put_line('I - paso bullk');  
        dbms_output.put_line('...');  */
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_tramos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
          l_errors := SQL%bulk_exceptions.count;
          --dbms_output.put_line('l_errors:'||l_errors);   
          FOR i IN 1 .. l_errors LOOP
            l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
            l_msg   := SQLERRM(-l_errno);
            l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
            p_control_error('CXHGOME','09_Mig_Tramos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
          END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_tramos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_tramos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_tramos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_tramos.');
    RETURN 0;
  END f_migra_mig_tramos;
  -------------------------------------------------------------
  --f_carga_mig_tramos
  -------------------------------------------------------------
  FUNCTION f_carga_mig_tramos
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_tramos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_tramos';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17417;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga; --AND s.tab_des IN ('MIG_CODICONTRATOS');
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_TRAMOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_tramos;
  -------------------------------------------------------------
  --f_migra_mig_cuadroces
  -------------------------------------------------------------
  FUNCTION f_migra_mig_cuadroces
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_cuadroces';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_cuadroces';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    
    TYPE t_mig_cuadroces IS TABLE OF mig_cuadroces%ROWTYPE;
    l_reg_mig_mcc t_mig_cuadroces;

    CURSOR lc_mig_cuadroces IS
     SELECT 17418 ncarga,1 CESTMIG,  a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NVERSIO, 0 SCONTRA, a.CTRAMO, a.CCOMREA, a.PCESION,
            a.NPLENOS, a.ICESFIJ, a.ICOMFIJ, a.ISCONTA, a.PRESERV, a.PINTRES, a.ILIACDE, a.PPAGOSL, a.CCORRED, a.CINTRES, a.CINTREF, a.CRESREF,
            a.IRESERV, a.PTASAJ, a.FULTLIQ, a.IAGREGA, a.IMAXAGR, a.CTIPCOMIS, a.PCTCOMIS, a.CTRAMOCOMISION, a.CFRERES, a.pctgastos
       FROM mig_cuadroces_uat a, mig_contratos mc, mig_companias m
       WHERE a.mig_fk = mc.mig_pk
       AND   a.mig_fk2 = m.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_cuadroces;
      LOOP
      FETCH lc_mig_cuadroces BULK COLLECT INTO l_reg_mig_mcc LIMIT 500000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_cuadroces VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','11_mig_cuadroces','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_cuadroces%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_cuadroces;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_cuadroces;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_cuadroces.');
    RETURN 0;
  END f_migra_mig_cuadroces;
  -------------------------------------------------------------
  --f_carga_mig_cuadroces
  -------------------------------------------------------------
  FUNCTION f_carga_mig_cuadroces
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_cuadroces';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_cuadroces';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17418;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    --SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CUADROCES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_cuadroces;
  -------------------------------------------------------------
  --f_migra_mig_tipos_indicadores
  -------------------------------------------------------------
  FUNCTION f_migra_mig_tipos_indicadores RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_tipos_indicadores';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_tipos_indicadores';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    
    TYPE t_mig_fin_indicadores IS TABLE OF mig_tipos_indicadores%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_indicadores;
    --
    CURSOR lc_mig_fin_indicadores IS
      SELECT 17414 NCARGA,1 CESTMIG, mig_pk, tindica, carea, ctipreg, cimpret, ccindid, cindsap, porcent, cclaing, 
             ibasmin, cprovin, cpoblac, fvigor
      FROM mig_tipos_indicadores_uat a
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_indicadores;
      LOOP
      FETCH lc_mig_fin_indicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_tipos_indicadores VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','11_mig_fin_indicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_indicadores%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_indicadores;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_tipos_indicadores;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_tipos_indicadores.');
    RETURN 0;
  END f_migra_mig_tipos_indicadores;
  -------------------------------------------------------------
  --f_carga_mig_tipos_indicadores
  -------------------------------------------------------------
  FUNCTION f_carga_mig_tipos_indicadores
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_tipos_indicadores';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_tipos_indicadores';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17414;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    --SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_TIPOS_INDICADORES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_tipos_indicadores;
  -------------------------------------------------------------
  --f_migra_mig_per_indicadores
  -------------------------------------------------------------
  FUNCTION f_migra_mig_per_indicadores RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_per_indicadores';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_per_indicadores';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000;
    v_agente_pervisio NUMBER := 19000;
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    
    TYPE t_mig_fin_perindicadores IS TABLE OF mig_per_indicadores%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_perindicadores;
    --
    CURSOR lc_mig_per_indicadores IS
      SELECT 17491 NCARGA,1 CESTMIG, mig_pk, mig_fk, codvinculo, ctipind
      FROM mig_per_indicadores_uat a
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_per_indicadores;
      LOOP
      FETCH lc_mig_per_indicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_per_indicadores VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','mig_per_indicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        EXIT WHEN lc_mig_per_indicadores%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_per_indicadores;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_per_indicadores;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_per_indicadores.');
    RETURN 0;
  END f_migra_mig_per_indicadores;
  -------------------------------------------------------------
  --f_carga_mig_per_indicadores
  -------------------------------------------------------------
  FUNCTION f_carga_mig_per_indicadores
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_per_indicadores';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_per_indicadores';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17491;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PER_INDICADORES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_per_indicadores;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_contragarantia
  -------------------------------------------------------------
  FUNCTION f_mig_ctgar_contragarantia
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_mig_ctgar_contragarantia';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_mig_ctgar_contragarantia';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    vlinea            VARCHAR2(2000);
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;

    TYPE t_mig_ctgar_contragarantia IS TABLE OF mig_ctgar_contragarantia%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_contragarantia;

    CURSOR lc_mig_ctgar_contragarantia IS
      SELECT 17434 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SCONTGAR, a.NMOVIMI, a.TDESCRIPCION, a.CTIPO, a.CCLASE, a.CMONEDA, a.IVALOR,
            a.FVENCIMI, a.NEMPRESA, a.NRADICA, a.FCREA, a.DOCUMENTO, a.CTENEDOR, a.TOBSTEN,
            a.CESTADO, a.CORIGEN, a.TCAUSA, a.TAUXILIA, a.CIMPRESO, a.CUSUALT, a.FALTA
      FROM mig_ctgar_contragarantia_uat a
      --WHERE 1 = 1
      --ORDER BY a.mig_pk
       ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ctgar_contragarantia;
      LOOP
      FETCH lc_mig_ctgar_contragarantia BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_ctgar_contragarantia WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_contragarantia VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
          FOR i IN 1 .. l_errors LOOP
            l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
            l_msg   := SQLERRM(-l_errno);
            l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
            p_control_error('ALUNA','07_mig_ctgar_contragarantia','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_contragarantia%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_contragarantia;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_contragarantia;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_contragarantia.');
    RETURN 0;
  END f_mig_ctgar_contragarantia;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_det
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctgar_det
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctgar_det';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctgar_det';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctgar_det IS TABLE OF mig_ctgar_det%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_det;
    --
    CURSOR lc_mig_ctgar_det IS
      SELECT 17434 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 mig_fk2, a.CPAIS, a.FEXPEDIC,
          a.CBANCO, NULL SPERFIDE, a.TSUCURSAL, a.IINTERES, a.FVENCIMI, a.FVENCIMI1, a.FVENCIMI2,
          a.NPLAZO, a.IASEGURA, a.IINTCAP
      FROM MIG_CTGAR_DET_uat a, mig_ctgar_contragarantia c
      WHERE 1 = 1
      AND a.mig_fk = c.mig_pk
      --ORDER BY a.mig_pk        
        ; 
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_ctgar_det;
      LOOP
      FETCH lc_mig_ctgar_det BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        --FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        --DELETE FROM mig_ctgar_det WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_det VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','41_mig_ctgar_det','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_det%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_det;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_det;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_det.');
    RETURN 0;
  END f_migra_mig_ctgar_det;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_inmueble
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctgar_inmueble
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctgar_inmueble';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctgar_inmueble';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctgar_inmueble IS TABLE OF mig_ctgar_inmueble%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_inmueble;
    --
    CURSOR lc_mig_ctgar_inmueble IS
      SELECT 17434 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NNUMESCR, a.FESCRITURA,
           a.TDESCRIPCION, a.TDIRECCION, a.CPAIS, a.CPROVIN, a.CPOBLAC, a.FCERTLIB
      FROM mig_ctgar_inmueble_uat a, Mig_Ctgar_Det d
       WHERE 1 = 1     
       AND a.mig_fk = d.mig_pk
       --ORDER BY a.mig_pk
        ; 
    --
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_ctgar_inmueble;
      LOOP
      FETCH lc_mig_ctgar_inmueble BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_ctgar_inmueble WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;

        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_inmueble VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','42_mig_ctgar_inmueble','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_inmueble%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_inmueble;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_inmueble;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_inmueble.');
    RETURN 0;
  END f_migra_mig_ctgar_inmueble;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_vehiculo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctgar_vehiculo
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctgar_vehiculo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctgar_vehiculo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctgar_vehiculo IS TABLE OF mig_ctgar_vehiculo%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_vehiculo;
    --
    CURSOR lc_mig_ctgar_vehiculo IS
      SELECT 17434 NCARGA,1 CESTMIG, a.*
      FROM mig_ctgar_vehiculo_uat a, mig_ctgar_det d
      WHERE 1 = 1
      AND a.mig_fk = d.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_ctgar_vehiculo;
      LOOP
      FETCH lc_mig_ctgar_vehiculo BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;

        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_vehiculo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','43_mig_ctgar_vehiculo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_vehiculo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_vehiculo;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_vehiculo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_vehiculo.');
    RETURN 0;
  END f_migra_mig_ctgar_vehiculo;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_codeudor
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctgar_codeudor
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctgar_codeudor';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctgar_codeudor';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctgar_codeudor IS TABLE OF MIG_CTGAR_CODEUDOR%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_codeudor;
    --
    CURSOR lc_mig_ctgar_codeudor IS
      SELECT 17434 NCARGA,1 CESTMIG, a.mig_pk, a.mig_fk, a.mif_fk2 mig_fk2
      FROM mig_ctgar_codeudor_uat a, mig_ctgar_contragarantia c
      WHERE 1 = 1
      AND a.mig_fk = c.mig_pk
      AND a.mig_pk  IS NOT NULL
      AND a.mig_fk  IS NOT NULL
      AND a.mif_fk2 IS NOT NULL
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_ctgar_codeudor;
      LOOP
      FETCH lc_mig_ctgar_codeudor BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_codeudor VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','44_mig_ctgar_codeudor','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_codeudor%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_codeudor;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_codeudor;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_codeudor.');
    RETURN 0;
  END f_migra_mig_ctgar_codeudor;
  -------------------------------------------------------------
  --f_carga_mig_ctgar_contragar
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctgar_contragar
    RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctgar_contragar';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctgar_contragar';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17434;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE mig_logs_axis WHERE NCARGA = vncarga;

    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTGAR_CONTRAGARANTIA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctgar_contragar;
  -------------------------------------------------------------
  --f_migra_mig_bureau
  -------------------------------------------------------------
  FUNCTION f_migra_mig_bureau RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_bureau';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_bureau';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_bureau IS TABLE OF mig_bureau%ROWTYPE;
    l_reg_mig_mcc t_mig_bureau;
    --
    CURSOR lc_mig_bureau IS
      SELECT 17419 NCARGA, 1 CESTMIG, a.MIG_PK, a.SBUREAU, a.NMOVIMI, a.CANULADA, a.CTIPO, a.NSUPLEM, a.CUSUALT, 
            a.FALTA, a.CUSUMOD, a.FMODIF --, NULL CINTERMED, NULL CREPRESEN, NULL CAPODERADO, NULL CPAGADOR, NULL TOBSEVA            
      FROM mig_bureau_uat a
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_bureau;
      LOOP
      FETCH lc_mig_bureau BULK COLLECT INTO l_reg_mig_mcc ;--LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_bureau VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_mig_bureau','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_bureau%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_bureau;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_bureau;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_bureau.');
    RETURN 0;
  END f_migra_mig_bureau;
  -------------------------------------------------------------
  --f_carga_mig_bureau
  -------------------------------------------------------------
  FUNCTION f_carga_mig_bureau RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_bureau';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_bureau';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17419;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    DELETE mig_logs_axis WHERE NCARGA = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_BUREAU_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_bureau;
  -------------------------------------------------------------
  --f_migra_mig_seguros
  -------------------------------------------------------------
  FUNCTION f_migra_mig_seguros RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_seguros';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_seguros';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_seguros IS TABLE OF mig_seguros%ROWTYPE;
    l_reg_mig_mcc t_mig_seguros;
    --
    CURSOR lc_mig_seguros IS
      SELECT 17420 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, s.MIG_FKDIR, a.CAGENTE, s.NPOLIZA,  s.NCERTIF,  s.FEFECTO,  s.CREAFAC,  s.CACTIVI,  
             DECODE(s.CCOBBAN, 0, NULL, s.CCOBBAN) CCOBBAN, s.CTIPCOA,  s.CTIPREA,  s.CTIPCOM,  s.FVENCIM,  s.FEMISIO,  s.FANULAC,  NULL FCANCEL,
             s.CSITUAC,  s.IPRIANU,  s.CIDIOMA,  
             s.CFORPAG, s.CRETENI,  s.SCIACOA,  s.PPARCOA,  s.NPOLCOA,  s.NSUPCOA,  s.PDTOCOM,  s.NCUACOA,  s.CEMPRES,  s.SPRODUC,  s.CCOMPANI, 
             s.CTIPCOB, s.CREVALI,  s.PREVALI,  s.IREVALI,  s.CTIPBAN,  s.CBANCAR,  s.CASEGUR,  s.NSUPLEM,  0 SSEGURO,  0 SPERSON,  s.CDOMICI,  
             s.NPOLINI, NULL CTIPBAN2,  NULL CBANCOB, s.FCARANT,  s.FCARPRO,  s.CRECFRA,  s.NDURCOB,  s.FCARANU,  NULL CTIPRETR,  NULL CINDREVFRAN, 
      NULL PRECARG,  NULL PDTOTEC, NULL PRECCOM, NULL FRENOVA, s.NPOLINI CPOLCIA,  s.NEDAMAR,  17417 PROCESO,  s.NDURACI,  s.MIG_FK2
      FROM mig_seguros_uat s, agentes a
      WHERE s.cagente = a.cagente
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_seguros;
      LOOP
      FETCH lc_mig_seguros BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_seguros WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_seguros VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_mig_seguros','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_seguros%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_seguros;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_seguros;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_seguros.');
    RETURN 0;
  END f_migra_mig_seguros;
  -------------------------------------------------------------
  --f_migra_mig_historicoseguros
  -------------------------------------------------------------
  FUNCTION f_migra_mig_historicoseguros RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_historicoseguros';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_historicoseguros';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_MIG_HISTORICOSEGUROS IS TABLE OF MIG_HISTORICOSEGUROS%ROWTYPE;
    l_reg_mig_mcc t_MIG_HISTORICOSEGUROS;
    --
    CURSOR lc_MIG_HISTORICOSEGUROS IS
      SELECT 17420 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.MIG_FKDIR, a.CAGENTE, a.NCERTIF, a.FEFECTO, a.CACTIVI,
            a.CCOBBAN, a.CTIPREA, a.CREAFAC, a.CTIPCOM, a.CSITUAC, a.FVENCIM, a.FEMISIO, a.FANULAC, a.IPRIANU, a.CIDIOMA, a.CFORPAG,
            a.CRETENI, a.CTIPCOA, a.SCIACOA, a.PPARCOA, a.NPOLCOA, a.NSUPCOA, a.NCUACOA, a.PDTOCOM, a.CEMPRES, a.SPRODUC, a.CCOMPANI,
            a.CTIPCOB, a.CREVALI, a.PREVALI, a.IREVALI, a.CTIPBAN, a.CBANCAR, a.CASEGUR, a.NSUPLEM, a.CDOMICI, a.NPOLINI, a.FCARANT, 
            a.FCARPRO, a.CRECFRA, a.NDURCOB, a.FCARANU, a.NDURACI, a.NEDAMAR, a.FEFEPLAZO, a.FVENCPLAZO, a.MIG_FK3
      FROM MIG_HISTORICOSEGUROS_UAT a, mig_movseguro s      
      WHERE 1 = 1
      AND a.mig_fk2 = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_MIG_HISTORICOSEGUROS;
      LOOP
      FETCH lc_MIG_HISTORICOSEGUROS BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO MIG_HISTORICOSEGUROS VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','04_MIG_HISTORICOSEGUROS','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_MIG_HISTORICOSEGUROS%NOTFOUND;
      END LOOP;
    CLOSE lc_MIG_HISTORICOSEGUROS;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   MIG_HISTORICOSEGUROS;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en MIG_HISTORICOSEGUROS.');
    RETURN 0;
  END f_migra_mig_historicoseguros;
  -------------------------------------------------------------
  --f_migra_mig_asegurados
  -------------------------------------------------------------
  FUNCTION f_migra_mig_asegurados RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_asegurados';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_asegurados';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_asegurados IS TABLE OF mig_asegurados%ROWTYPE;
    l_reg_mig_mcc t_mig_asegurados;
    --
    CURSOR lc_mig_asegurados IS
      SELECT 17422 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, s.MIG_FK2, 0 SSEGURO, 
             0 SPERSON, s.NORDEN, s.CDOMICI, s.FFECINI, s.FFECFIN, s.FFECMUE, s.FECRETROACT, NULL CPAREN
      FROM mig_asegurados_UAT s, mig_personas p, mig_seguros e
      WHERE 1 = 1
      AND s.mig_fk  = p.mig_pk
      AND s.mig_fk2 = e.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_asegurados;
      LOOP
      FETCH lc_mig_asegurados BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_asegurados WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_asegurados VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','06_mig_asegurados','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_asegurados%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_asegurados;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_asegurados;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_asegurados.');
    RETURN 0;
  END f_migra_mig_asegurados;
  -------------------------------------------------------------
  --f_carga_mig_asegurados
  -------------------------------------------------------------
  FUNCTION f_carga_mig_asegurados RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_asegurados';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_asegurados';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17422;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog,0));
    DELETE mig_logs_axis WHERE NCARGA = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_ASEGURADOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_asegurados;
  -------------------------------------------------------------
  --f_migra_mig_movseguro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_movseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_movseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_movseguro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_movseguro IS TABLE OF mig_movseguro%ROWTYPE;
    l_reg_mig_mcc t_mig_movseguro;
    --
    CURSOR lc_mig_movseguro IS
      SELECT 17423 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, 0 SSEGURO, s.NMOVIMI, s.CMOTMOV,  s.FMOVIMI,  s.FEFECTO,  s.CUSUMOV,  s.CMOTVEN,  
             s.CMOVSEG,  s.NMOVIMI_ANT
      FROM mig_movseguro_UAT s, mig_seguros a
      WHERE 1 = 1
      AND a.mig_pk  = s.mig_fk
      AND a.sseguro <> 0
      --ORDER BY s.mig_fk
       ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_movseguro;
      LOOP
      FETCH lc_mig_movseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_movseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_movseguro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('aluna','01_mig_movseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_movseguro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_movseguro;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_movseguro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_movseguro.');
    RETURN 0;
  END f_migra_mig_movseguro;
  -------------------------------------------------------------
  --f_carga_mig_movseguro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_movseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_movseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_movseguro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17423;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog,0));
    DELETE mig_logs_axis WHERE NCARGA = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_MOVSEGURO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_movseguro;
  -------------------------------------------------------------
  --f_carga_mig_seguros
  -------------------------------------------------------------
  FUNCTION f_carga_mig_seguros RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_seguros';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_seguros';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17420;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    --
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog,0));
    DELETE mig_logs_axis WHERE NCARGA = vncarga;
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SEGUROS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_seguros;
  -------------------------------------------------------------
  --f_migra_mig_riesgos
  -------------------------------------------------------------
  FUNCTION f_migra_mig_riesgos RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_riesgos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_riesgos';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    --vlinea            VARCHAR2(2000);
    --v_agente_padre    NUMBER := 19000; -- agente raiz 
    --v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    --v_cant            NUMBER := 0;
    --
    TYPE t_mig_riesgos IS TABLE OF mig_riesgos%ROWTYPE;
    l_reg_mig_mcc t_mig_riesgos;
    --
    CURSOR lc_mig_riesgos IS
      SELECT 17424 ncarga,1 CESTMIG, s.MIG_PK, s.MIG_FK, s.MIG_FK2, s.NRIESGO, 0 SSEGURO, s.NMOVIMA, s.FEFECTO, 0 SPERSON, s.NMOVIMB, s.FANULAC,
             s.TNATRIE, s.PDTOCOM, s.PRECARG, s.PDTOTEC, s.PRECCOM, s.TDESCRIE
      FROM mig_riesgos_UAT s, mig_personas p, mig_seguros e
      WHERE 1 = 1
      AND s.mig_fk  = p.mig_pk
      AND s.mig_fk2 = e.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_riesgos;
      LOOP
      FETCH lc_mig_riesgos BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_riesgos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_riesgos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','06_mig_riesgos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_riesgos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_riesgos;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_riesgos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_riesgos.');
    RETURN 0;
  END f_migra_mig_riesgos;
  -------------------------------------------------------------
  --f_carga_mig_riesgos
  -------------------------------------------------------------
  FUNCTION f_carga_mig_riesgos RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_riesgos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_riesgos';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17424;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_RIESGOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    --
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_riesgos;
  -------------------------------------------------------------
  --f_migra_mig_sitriesgo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sitriesgo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sitriesgo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sitriesgo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sitriesgo IS TABLE OF mig_sitriesgo%ROWTYPE;
    l_reg_mig_mcc t_mig_sitriesgo;
    --
    CURSOR lc_mig_sitriesgo IS
      SELECT 17425 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NRIESGO,  0 SSEGURO,  NVL(a.iddomici, '0') TDOMICI, a.CPROVIN,  a.CPOSTAL,  
             a.CPOBLAC, a.CSIGLAS,  a.TNOMVIA,  a.NNUMVIA,  a.TCOMPLE,  NULL CCIUDAD, 
             a.FGISX, a.FGISY,  a.FGISZ,  a.CVALIDA 
      FROM mig_sitriesgo_UAT a, mig_riesgos r
      WHERE r.mig_pk  = a.mig_fk
      AND a.cprovin IS NOT NULL
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sitriesgo;
      LOOP
      FETCH lc_mig_sitriesgo BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sitriesgo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sitriesgo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','37_mig_sitriesgo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);

            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sitriesgo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sitriesgo;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sitriesgo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sitriesgo.');
    RETURN 0;
  END f_migra_mig_sitriesgo;
  -------------------------------------------------------------
  --f_carga_mig_sitriesgo
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sitriesgo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sitriesgo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sitriesgo';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17425;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SITRIESGO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sitriesgo;
  -------------------------------------------------------------
  --f_migra_mig_garanseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_garanseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_garanseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_garanseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_garanseg IS TABLE OF mig_garanseg%ROWTYPE;
    l_reg_mig_mcc t_mig_garanseg;
    --
    CURSOR lc_mig_garanseg IS
      SELECT 17426 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CGARANT, a.NRIESGO, a.NMOVIMI, 0 SSEGURO,
             a.FINIEFE, a.ICAPITAL, a.PRECARG, a.IEXTRAP, a.IPRIANU, a.FFINEFE, a.IRECARG, a.IPRITAR, a.FALTA,
             a.CREVALI, a.PREVALI, a.IREVALI, a.NMOVIMA, a.PDTOCOM, a.IDTOCOM, a.TOTANU, 0 PDTOTEC, a.PRECCOM,
             a.IDTOTEC, a.IRECCOM, a.FINIVIG, a.FFINVIG, 1 CCOBPRIMA, 0 IPRIDEV--7782-30 ccobprima no se envia desde el origen por lo cual se deja en 1
      FROM mig_garanseg_UAT a, mig_seguros s, mig_movseguro m
      WHERE m.mig_pk = a.mig_fk
      AND s.mig_pk = m.mig_fk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_garanseg;
      LOOP
      FETCH lc_mig_garanseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_garanseg VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','13_mig_garanseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_garanseg%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_garanseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_garanseg;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_garanseg.');
    RETURN 0;
  END f_migra_mig_garanseg;
  -------------------------------------------------------------
  --f_carga_mig_garanseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_garanseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_garanseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_garanseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17426;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_GARANSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_garanseg;
  -------------------------------------------------------------
  --f_migra_mig_clausuesp
  -------------------------------------------------------------
  FUNCTION f_migra_mig_clausuesp RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_clausuesp';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_clausuesp';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_clausuesp IS TABLE OF mig_clausuesp%ROWTYPE;
    l_reg_mig_mcc t_mig_clausuesp;
    --
    CURSOR lc_mig_clausuesp IS
      SELECT 17427 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NMOVIMI, 0 SSEGURO, a.CCLAESP,
            a.NORDCLA, a.NRIESGO, a.FINICLAU, a.SCLAGEN, a.TCLAESP, a.FFINCLAU
      FROM mig_clausuesp_UAT a, mig_movseguro m
      WHERE m.mig_pk = a.mig_fk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_mig_clausuesp;
      LOOP
      FETCH lc_mig_clausuesp BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_clausuesp WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_clausuesp VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','16_mig_clausuesp','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_clausuesp%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_clausuesp;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_clausuesp;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_clausuesp.');
    RETURN 0;
  END f_migra_mig_clausuesp;
  -------------------------------------------------------------
  --f_carga_mig_clausuesp
  -------------------------------------------------------------
  FUNCTION f_carga_mig_clausuesp RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_clausuesp';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_clausuesp';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17427;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CLAUSUESP_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_clausuesp;
  -------------------------------------------------------------
  --f_migra_mig_benespseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_benespseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_benespseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_benespseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_benespseg IS TABLE OF mig_benespseg%ROWTYPE;
    l_reg_mig_mcc t_mig_benespseg;
    --
    CURSOR lc_mig_benespseg IS
      SELECT 17428 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NBENEF NBENEFIC, 0 SSEGURO, a.NRIESGO, a.CGARANT,
            a.NMOVIMI, 0 SPERSON, NULL CTIPIDE_CONT, NULL NNUMIDE_CONT, NULL TAPELLI1_CONT, NULL TAPELLI2_CONT, NULL TNOMBRE1_CONT,
            NULL TNOMBRE2_CONT, NULL FINIBEN, NULL FFINBEN, a.TIPO_DE_BENEFICIARIO CTIPBEN, a.PARENTESCO CPAREN, a.PORCENTAJE PPARTICIP, 
            a.CUSUARI, a.FMOVIMI, a.CESTADO, NULL CTIPOCON           
      FROM mig_benespseg_UAT a , mig_movseguro m
      WHERE m.mig_pk = a.mig_fk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_benespseg;
      LOOP
      FETCH lc_mig_benespseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_benespseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_benespseg VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','19_mig_benespseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_benespseg%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_benespseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_benespseg;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_benespseg.');
    RETURN 0;
  END f_migra_mig_benespseg;
  -------------------------------------------------------------
  --f_carga_mig_benespseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_benespseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_benespseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_benespseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17428;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_BENESPSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_benespseg;
  -------------------------------------------------------------
  --f_migra_mig_pregunseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_pregunseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_pregunseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_pregunseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    TYPE t_mig_pregunseg IS TABLE OF mig_pregunseg%ROWTYPE;
    l_reg_mig_mcc t_mig_pregunseg;
    --
    CURSOR lc_mig_pregunseg IS
      SELECT 17429 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 
            a.NRIESGO, 0 SSEGURO, a.CPREGUN, a.CRESPUE, a.NMOVIMI
      FROM mig_pregunseg_UAT a, mig_seguros s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_pregunseg;
      LOOP
      FETCH lc_mig_pregunseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_pregunseg VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','61_mig_pregunseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_pregunseg%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_pregunseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_pregunseg;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_pregunseg.');
    RETURN 0;
  END f_migra_mig_pregunseg;
  -------------------------------------------------------------
  --f_carga_mig_pregunseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_pregunseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_pregunseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_pregunseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17429;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PREGUNSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_pregunseg;
  -------------------------------------------------------------
  --f_migra_mig_comisionsegu
  -------------------------------------------------------------
  FUNCTION f_migra_mig_comisionsegu RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_comisionsegu';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_comisionsegu';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_comisionsegu IS TABLE OF mig_comisionsegu%ROWTYPE;
    l_reg_mig_mcc t_mig_comisionsegu;
    --
    CURSOR lc_mig_comisionsegu IS
      SELECT 17430 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 
            a.CMODCOM, a.PCOMISI, a.NINIALT, a.NFINALT, a.NMOVIMI
      FROM mig_comisionsegu_UAT a, mig_seguros s
      WHERE 1 = 1
      AND a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_comisionsegu;
      LOOP
      FETCH lc_mig_comisionsegu BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_comisionsegu VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','53_mig_comisionsegu','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_comisionsegu%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_comisionsegu;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_comisionsegu;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_comisionsegu.');
    RETURN 0;
  END f_migra_mig_comisionsegu;
  -------------------------------------------------------------
  --f_carga_mig_pregunseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_comisionsegu RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_comisionsegu';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_comisionsegu';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17430;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COMISIONSEGU_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_comisionsegu;
  -------------------------------------------------------------
  --f_migra_mig_ctaseguro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctaseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctaseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctaseguro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctaseguro IS TABLE OF mig_ctaseguro%ROWTYPE;
    l_reg_mig_mcc t_mig_ctaseguro;
    --
    CURSOR lc_mig_ctaseguro IS
      SELECT /*20061 NCARGA,1 CESTMIG, 0 SSEGURO,  a.MIG_PK, a.MIG_FK, a.FCONTAB,  
             a.NNUMLIN, a.FFECMOV,  a.FVALMOV,  a.CMOVIMI,  a.IMOVIMI,  a.CCALINT,  a.IMOVIM2,  
             a.NRECIBO, a.NSINIES,  a.CMOVANU,  a.SMOVREC,  a.CESTA,  a.NUNIDAD,  a.CESTADO,  
             a.FASIGN,  a.NPARPLA,  a.CESTPAR,  a.IEXCESO,  a.SPERMIN,  a.SIDEPAG,  a.CTIPAPOR, a.SRECREN*/
             0 SSEGURO,A.FCONTAB,A.NNUMLIN,A.FFECMOV,A.FVALMOV,A.CMOVIMI,A.IMOVIMI,A.CCALINT,A.IMOVIM2,A.NRECIBO,A.NSINIES
             ,A.CMOVANU,A.SMOVREC,A.CESTA,A.NUNIDAD,A.CESTADO,A.FASIGN,A.NPARPLA,A.CESTPAR,A.IEXCESO,A.SPERMIN,A.SIDEPAG
             ,A.CTIPAPOR,A.SRECREN,A.MIG_PK,A.MIG_FK,17431 NCARGA,1 CESTMIG
      FROM mig_ctaseguro_UAT a, mig_seguros s
      WHERE s.mig_pk = a.mig_fk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_ctaseguro;
      LOOP
      FETCH lc_mig_ctaseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_ctaseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctaseguro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','25_mig_ctaseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctaseguro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctaseguro;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctaseguro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctaseguro.');
    RETURN 0;
  END f_migra_mig_ctaseguro;
  -------------------------------------------------------------
  --f_carga_mig_ctaseguro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctaseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctaseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctaseguro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17431;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTASEGURO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctaseguro;
  -------------------------------------------------------------
  --f_migra_mig_agensegu
  -------------------------------------------------------------
  FUNCTION f_migra_mig_agensegu RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_agensegu';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_agensegu';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_agensegu IS TABLE OF mig_agensegu%ROWTYPE;
    l_reg_mig_mcc t_mig_agensegu;

    CURSOR lc_mig_agensegu IS
      SELECT 17432 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SSEGURO,
            a.FALTA, a.CTIPREG, a.CESTADO, a.TTITULO, a.FFINALI, a.TTEXTOS, a.CMANUAL     
      FROM mig_agensegu_UAT a, mig_seguros s
      WHERE s.mig_pk = a.mig_fk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_agensegu;
      LOOP
      FETCH lc_mig_agensegu BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_agensegu WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_agensegu VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','31_mig_agensegu','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_agensegu%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_agensegu;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_agensegu;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_agensegu.');
    RETURN 0;
  END f_migra_mig_agensegu;
  -------------------------------------------------------------
  --f_carga_mig_agensegu
  -------------------------------------------------------------
  FUNCTION f_carga_mig_agensegu RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_agensegu';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_agensegu';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17432;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_AGENSEGU_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_agensegu;
  -------------------------------------------------------------
  --f_migra_mig_pregungaranseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_pregungaranseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_pregungaranseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_pregungaranseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_pregungaranseg IS TABLE OF mig_pregungaranseg%ROWTYPE;
    l_reg_mig_mcc t_mig_pregungaranseg;
    --
    CURSOR lc_mig_pregungaranseg IS
      SELECT 17433 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK,
            0 SSEGURO, a.NRIESGO, a.CGARANT, a.CPREGUN, to_number(a.CRESPUE)
      FROM mig_pregungaranseg_UAT a, mig_movseguro s
      WHERE s.mig_pk = a.mig_fk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_pregungaranseg;
      LOOP
      FETCH lc_mig_pregungaranseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_pregungaranseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_pregungaranseg VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','34_mig_pregungaranseg','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_pregungaranseg%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_pregungaranseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_pregungaranseg;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_pregungaranseg.');
    RETURN 0;
  END f_migra_mig_pregungaranseg;
  -------------------------------------------------------------
  --f_carga_mig_pregungaranseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_pregungaranseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_pregungaranseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_pregungaranseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17433;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PREGUNGARANSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_pregungaranseg;
  -------------------------------------------------------------
  --f_migra_mig_ctgar_seguro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctgar_seguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctgar_seguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctgar_seguro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctgar_seguro IS TABLE OF mig_ctgar_seguro%ROWTYPE;
    l_reg_mig_mcc t_mig_ctgar_seguro;
    --
    CURSOR lc_mig_ctgar_seguro IS
      SELECT 17435 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, c.scontgar
      FROM mig_ctgar_seguro_UAT a, mig_ctgar_contragarantia c
      WHERE a.mig_fk2 = c.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_ctgar_seguro;
      LOOP
      FETCH lc_mig_ctgar_seguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_ctgar_seguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctgar_seguro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
          l_errors := SQL%bulk_exceptions.count;
          --dbms_output.put_line('l_errors:'||l_errors);
          FOR i IN 1 .. l_errors LOOP
            l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
            l_msg   := SQLERRM(-l_errno);
            l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
            p_control_error('CXHGOME','47_mig_ctgar_seguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
          END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctgar_seguro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctgar_seguro;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctgar_seguro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctgar_seguro.');
    RETURN 0;
  END f_migra_mig_ctgar_seguro;
  -------------------------------------------------------------
  --f_carga_mig_ctgar_seguro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctgar_seguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctgar_seguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctgar_seguro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17435;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTGAR_SEGURO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctgar_seguro;
  -------------------------------------------------------------
  --f_migra_mig_age_corretaje
  -------------------------------------------------------------
  FUNCTION f_migra_mig_age_corretaje RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_age_corretaje';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_age_corretaje';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_age_corretaje IS TABLE OF mig_age_corretaje%ROWTYPE;
    l_reg_mig_mcc t_mig_age_corretaje;
    --
    CURSOR lc_mig_age_corretaje IS
      SELECT 17436 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 
            0 SSEGURO, a.NMOVIMI, a.NORDAGE, a.CAGENTE, a.PCOMISI, a.PPARTICI, a.ISLIDER
      FROM mig_age_corretaje_uat a, mig_seguros s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_age_corretaje;
      LOOP
      FETCH lc_mig_age_corretaje BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_age_corretaje WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_age_corretaje VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','50_mig_age_corretaje','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_age_corretaje%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_age_corretaje;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_age_corretaje;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_age_corretaje.');
    RETURN 0;
  END f_migra_mig_age_corretaje;
  -------------------------------------------------------------
  --f_carga_mig_age_corretaje
  -------------------------------------------------------------
  FUNCTION f_carga_mig_age_corretaje RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_age_corretaje';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_age_corretaje';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17436;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_AGE_CORRETAJE_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_age_corretaje;
  -------------------------------------------------------------
  --f_migra_mig_psu_retenidas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_psu_retenidas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_psu_retenidas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_psu_retenidas';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_psu_retenidas IS TABLE OF mig_psu_retenidas%ROWTYPE;
    l_reg_mig_mcc t_mig_psu_retenidas;
    --
    CURSOR lc_mig_psu_retenidas IS
      SELECT 17437 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.SSEGURO, a.FMOVIMI, a.CMOTRET, a.CUSURET, a.FFECRET, 
            a.CUSUAUT, a.FFECAUT, a.CDETMOTREC, a.POSTPPER, a.PERPOST, NVL(a.OBSERV,'Migracion')--7782-47 SE AJUSTA EL ORDEN PARA QUE NO GENERE ERRORES
      FROM mig_psu_retenidas_UAT a, mig_movseguro s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_psu_retenidas;
      LOOP
      FETCH lc_mig_psu_retenidas BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_psu_retenidas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_psu_retenidas VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','50_mig_age_corretaje','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_psu_retenidas%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_psu_retenidas;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_psu_retenidas;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_psu_retenidas.');
    RETURN 0;
  END f_migra_mig_psu_retenidas;
  -------------------------------------------------------------
  --f_carga_mig_psu_retenidas
  -------------------------------------------------------------
  FUNCTION f_carga_mig_psu_retenidas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_psu_retenidas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_psu_retenidas';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17437;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PSU_RETENIDAS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_psu_retenidas;
  -------------------------------------------------------------
  --f_migra_mig_psucontrolseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_psucontrolseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_psucontrolseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_psucontrolseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_psu_retenidas IS TABLE OF mig_psucontrolseg%ROWTYPE;
    l_reg_mig_mcc t_mig_psu_retenidas;
    --
    CURSOR lc_mig_psucontrolseg IS
      SELECT 17492 NCARGA,1 CESTMIG, a.mig_pk, a.mig_fk, a.sseguro, a.nmovimi, a.fmovimi, a.ccontrol, a.nriesgo, a.nocurre, a.cgarant, 
             a.cnivelr, a.cmotret, a.cusuret, a.ffecret, a.cusuaut, a.ffecaut, a.observ, a.cdetmotrec, a.postpper, a.perpost
      FROM mig_psucontrolseg_UAT a, mig_movseguro s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_psucontrolseg;
      LOOP
      FETCH lc_mig_psucontrolseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_psucontrolseg WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_psucontrolseg VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','50_mig_age_corretaje','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_psucontrolseg%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_psucontrolseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_psucontrolseg;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en f_migra_mig_psucontrolseg.');
    RETURN 0;
  END f_migra_mig_psucontrolseg;
  -------------------------------------------------------------
  --f_carga_mig_psucontrolseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_psucontrolseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_psucontrolseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_psucontrolseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17492;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PSU_CONTROLSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_psucontrolseg;
  -------------------------------------------------------------
  --f_migra_mig_bf_bonfranseg
  -------------------------------------------------------------
  FUNCTION f_migra_mig_bf_bonfranseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_bf_bonfranseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_bf_bonfranseg';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_bf_bonfranseg IS TABLE OF mig_bf_bonfranseg%ROWTYPE;
    l_reg_mig_mcc t_bf_bonfranseg;
    --
    CURSOR lc_bf_bonfranseg IS
      SELECT 17488 NCARGA,1 CESTMIG, a.MIG_PK,a.MIG_FK,a.MIG_FK2,a.SSEGURO,a.NMOVIMI,a.NRIESGO,a.CGARAN,NVL(a.CGRUP,1),NVL(a.CSUBGRUP,1),NVL(a.CNIVEL,1),
          a.CVERSION,a.FINIEFE,a.CTIPGRUP,a.CVALOR1,a.IMPVALOR1,a.CVALOR2,a.IMPVALOR2,a.CIMPMIN,
          a.IMPMIN,a.CIMPMAX,a.IMPMAX,a.FFINEFE,a.CUSUAUT,a.FALTA,a.CUSUMOD,a.FMODIFI,a.CNIVELDEFECTO
      FROM MIG_BF_BONFRANSEG_uat a, MIG_MOVSEGURO b,MIG_RIESGOS c
      WHERE a.mig_fk  = b.mig_pk
      and a.mig_fk2 = c.mig_pk
    --ORDER BY a.mig_pk
    ;
    
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    
    OPEN lc_bf_bonfranseg;
      LOOP
      FETCH lc_bf_bonfranseg BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM MIG_BF_BONFRANSEG WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO MIG_BF_BONFRANSEG VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','01_MIG_BF_BONFRANSEG','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_bf_bonfranseg%NOTFOUND;
      END LOOP;
    CLOSE lc_bf_bonfranseg;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   MIG_BF_BONFRANSEG;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en MIG_BF_BONFRANSEG.');
    RETURN 0;
  END f_migra_mig_bf_bonfranseg;
  -------------------------------------------------------------
  --f_carga_mig_bf_bonfranseg
  -------------------------------------------------------------
  FUNCTION f_carga_mig_bf_bonfranseg RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_bf_bonfranseg';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_bf_bonfranseg';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17488;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_BF_BONFRANSEG_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_bf_bonfranseg;
  -------------------------------------------------------------
  --f_migra_mig_sin_prof_profesion
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_prof_profesion RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_prof_profesion';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_prof_profesion';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);   v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_prof_profesionales IS TABLE OF mig_sin_prof_profesionales%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_prof_profesionales;
    --
    CURSOR lc_mig_sin_prof_profesionales IS
      SELECT   17438 NCARGA, 1 CESTMIG, a.MIG_PK, 0 SPROFES, 0 IDPERSON, 0 CTIPIDE, 0 NNUMIDE, 0 TDIGITOIDE,
            a.NREGMER, a.FREGMER, 0 CDOMICI, 0 CMODCON, a.NLIMITE, 0 CNOASIS, 0 PROCESO
      FROM mig_sin_prof_profesionales_uat a, mig_personas p
      WHERE a.mig_fk = p.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_prof_profesionales;
      LOOP
      FETCH lc_mig_sin_prof_profesionales BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_prof_profesionales WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_prof_profesionales VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','02_mig_sin_prof_profesionales','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_prof_profesionales%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_prof_profesionales;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_prof_profesionales;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_prof_profesionales.');
    RETURN 0;
  END f_migra_mig_sin_prof_profesion;
  -------------------------------------------------------------
  --f_carga_mig_sin_prof_profesion
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_prof_profesion RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_prof_profesion';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_prof_profesion';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17438;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_PROF_PROFESIONALES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_prof_profesion;
  -------------------------------------------------------------
  --f_migra_mig_sin_prof_indica
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_prof_indica RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_prof_indica';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_prof_indica';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_prof_indicadores IS TABLE OF mig_sin_prof_indicadores%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_prof_indicadores;
    --
    CURSOR lc_mig_sin_prof_indicadores IS
      SELECT 17439 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 PROCESO, 0 SPROFES,a.CTIPIND
      FROM mig_sin_prof_indicadores_UAT a, mig_sin_prof_profesionales p
      WHERE p.mig_pk = a.mig_fk
      AND p.sprofes <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_prof_indicadores;
      LOOP
      FETCH lc_mig_sin_prof_indicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_prof_indicadores WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_prof_indicadores VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','05_mig_sin_prof_indicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_prof_indicadores%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_prof_indicadores;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_prof_indicadores;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_prof_indicadores.');
    RETURN 0;
  END f_migra_mig_sin_prof_indica;
  -------------------------------------------------------------
  --f_carga_mig_sin_prof_indica
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_prof_indica RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_prof_indica';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_prof_indica';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17439;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_PROF_INDICADORES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_prof_indica;
  -------------------------------------------------------------
  --f_migra_mig_sin_siniestro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_siniestro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_siniestro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_siniestro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_siniestro IS TABLE OF mig_sin_siniestro%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_siniestro;
    --
    CURSOR lc_mig_sin_siniestro IS
      SELECT 17440 NCARGA, 1 CESTMIG, a.MIG_PK,  a.MIG_FK, a.NSINIES, 0 SSEGURO, a.NRIESGO,  a.NMOVIMI,  
            a.FSINIES, a.FNOTIFI,  a.CCAUSIN,  a.CMOTSIN,  a.CEVENTO,  a.CCULPAB,  a.CRECLAMA, a.NASEGUR,  a.CMEDDEC,  
            a.CTIPDEC, a.TNOM1DEC TNOMDEC, a.TAPE1DEC, a.TAPE2DEC, a.TTELDEC,  a.TSINIES,  NVL(a.CUSUALT, 'CONF_MIG'), NVL(a.FALTA, F_SYSDATE),  NVL(a.CUSUMOD, 'CONF_MIG'), 
            a.FMODIFI, a.NCUACOA,  a.NSINCOA,  a.CSINCIA, a.TEMAILDEC, a.CTIPIDE, a.NNUMIDE, a.TNOM2DEC, a.TNOM1DEC, NULL CAGENTE, NULL CCARPETA, a.tdetpreten
      FROM mig_sin_siniestro_UAT a, mig_seguros s
      WHERE a.mig_fk = s.mig_pk
      AND s.sseguro <> 0
        ; 
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_siniestro;
      LOOP
      FETCH lc_mig_sin_siniestro BULK COLLECT INTO l_reg_mig_mcc LIMIT 100000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_siniestro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_siniestro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','08_mig_sin_siniestro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_siniestro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_siniestro;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_siniestro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_siniestro.');
    RETURN 0;
  END f_migra_mig_sin_siniestro;
  -------------------------------------------------------------
  --f_carga_mig_sin_siniestro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_siniestro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_siniestro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_siniestro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17440;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_SINIESTRO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_siniestro;
  -------------------------------------------------------------
  --f_migra_mig_sin_movsiniestro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_movsiniestro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_movsiniestro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_movsiniestro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_movsiniestro IS TABLE OF mig_sin_movsiniestro%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_movsiniestro;
    --
    CURSOR lc_mig_sin_movsiniestro IS
      SELECT 17441 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NMOVSIN,
            a.CESTSIN, NVL(a.FESTSIN, s.falta) FESTSIN, a.CCAUEST, a.CUNITRA, a.CTRAMITAD, NVL(a.CUSUALT, 'CONF_MIGRA'), NVL(a.FALTA, s.falta)
      FROM mig_sin_movsiniestro_UAT a, mig_sin_siniestro s
      WHERE a.mig_fk = s.mig_pk
      AND s.sseguro <> 0
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_movsiniestro;
      LOOP
      FETCH lc_mig_sin_movsiniestro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_movsiniestro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_movsiniestro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','11_mig_sin_movsiniestro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_movsiniestro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_movsiniestro;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_movsiniestro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_movsiniestro.');
    RETURN 0;
  END f_migra_mig_sin_movsiniestro;
  -------------------------------------------------------------
  --f_carga_mig_sin_movsiniestro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_movsiniestro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_movsiniestro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_movsiniestro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17441;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_MOVSINIESTRO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_movsiniestro;
  -------------------------------------------------------------
  --f_migra_mig_sin_tramitacion
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tramitacion RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tramitacion';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tramitacion';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramitacion IS TABLE OF mig_sin_tramitacion%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramitacion;
    --
    CURSOR lc_mig_sin_tramitacion IS
      SELECT 17442 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.CTRAMIT,
            a.CTCAUSIN, a.CINFORM, NVL(a.CUSUALT, 'CONF_MIGRA'), NVL(a.FALTA, s.falta), a.CUSUMOD, a.FMODIFI, NULL FFORMALIZACION , a.NRADICA /* hag: Add este campo, parche*/
      FROM mig_sin_tramitacion_UAT a, mig_sin_siniestro s
      WHERE a.mig_fk = s.mig_pk
      AND s.sseguro <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_tramitacion;
      LOOP
      FETCH lc_mig_sin_tramitacion BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_sin_tramitacion VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','14_mig_sin_tramitacion','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramitacion%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramitacion;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramitacion;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramitacion.');
    RETURN 0;
  END f_migra_mig_sin_tramitacion;
  -------------------------------------------------------------
  --f_carga_mig_sin_tramitacion
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tramitacion RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tramitacion';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tramitacion';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17442;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITACION_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tramitacion;
  -------------------------------------------------------------
  --f_migra_mig_sin_tramita_mov
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tramita_mov RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tramita_mov';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tramita_mov';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_movimiento IS TABLE OF mig_sin_tramita_movimiento%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_movimiento;
    --
    CURSOR lc_mig_sin_tramita_movimiento IS
      SELECT 17443 NCARGA, 1 CESTMIG,  a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.NMOVTRA,
            a.CUNITRA, a.CTRAMITAD, a.CESTTRA, a.CSUBTRA, a.FESTTRA, a.CUSUALT, a.FALTA, a.CCAUEST     
      FROM MIG_SIN_TRAMITA_MOVIMIENTO_UAT a, mig_sin_tramitacion s
      WHERE a.mig_fk = s.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
      ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;
    OPEN lc_mig_sin_tramita_movimiento;
      LOOP
      FETCH lc_mig_sin_tramita_movimiento BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_tramita_movimiento WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO mig_sin_tramita_movimiento VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','14_mig_sin_tramitacion','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_movimiento%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_movimiento;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_movimiento;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_movimiento.');
    RETURN 0;
  END f_migra_mig_sin_tramita_mov;
  -------------------------------------------------------------
  --f_carga_mig_sin_tramita_mov
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tramita_mov RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tramita_mov';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tramita_mov';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17443;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_MOVIMIENTO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tramita_mov;
  -------------------------------------------------------------
  --f_migra_mig_sin_tramita_res
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tramita_res RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tramita_res';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tramita_res';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_reserva IS TABLE OF mig_sin_tramita_reserva%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_reserva;
    --
    CURSOR lc_mig_sin_tramita_reserva IS
      SELECT 17444 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, a.NTRAMIT, a.CTIPRES, a.NMOVRES, a.CGARANT, a.CCALRES, a.FMOVRES,
          a.CMONRES, a.IRESERVA, a.IPAGO, a.IINGRESO, a.IRECOBRO, a.ICAPRIE, a.IPENALI, a.FRESINI, a.FRESFIN, a.FULTPAG, 0 SPROCES, a.FCONTAB,
          NVL(a.CUSUALT, 'MIGRA_CONF'), a.FALTA, a.CUSUMOD, a.FMODIFI, a.IPREREC, a.CTIPGAS, NULL IRESERVA_MONCIA, NULL IPAGO_MONCIA, NULL IINGRESO_MONCIA,
          NULL IRECOBRO_MONCIA, NULL ICAPRIE_MONCIA, NULL IPENALI_MONCIA, NULL IPREREC_MONCIA, NULL FCAMBIO, a.IFRANQ, NULL IFRANQ_MONCIA,
          NULL IDRES, CMOVRES, NULL SIDEPAG, MIG_PKPAG--7782-13 ez el valor de cmovres viene de la tabla uat, 7782-18 SE AGREGA PARA ASOCIAR PAGOS A MOVS. DE RESERVA
      FROM mig_sin_tramita_reserva_UAT a, mig_sin_tramitacion s
      WHERE a.mig_fk = s.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_reserva;
      LOOP
      FETCH lc_mig_sin_tramita_reserva BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_tramita_reserva WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_reserva VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','20_mig_sin_tramita_reserva','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_reserva%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_reserva;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_reserva;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_reserva.');
    RETURN 0;
  END f_migra_mig_sin_tramita_res;
  -------------------------------------------------------------
  --f_carga_mig_sin_tramita_res
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tramita_res RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tramita_res';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tramita_res';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17444;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_RESERVA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tramita_res;
  -------------------------------------------------------------
  --f_migra_mig_sin_tramita_pago
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tramita_pago RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tramita_pago';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tramita_pago';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_pago IS TABLE OF mig_sin_tramita_pago%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_pago;
    --
    CURSOR lc_mig_sin_tramita_pago IS
      SELECT 17445 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SIDEPAG, 0 NSINIES, a.NTRAMIT, 0 SPERSON, a.CTIPDES, a.CTIPPAG, NVL(a.CCONPAG, 0), a.CCAUIND, 
        NVL(a.CFORPAG, 0), a.FORDPAG, a.CTIPBAN, a.CBANCAR, a.CMONRES, a.ISINRET, a.IRETENC, a.IIVA, a.ISUPLID, a.IFRANQ, a.IRESRCM, a.IRESRED, a.CMONPAG,
         a.ISINRETPAG, a.IRETENCPAG, a.IIVAPAG, a.ISUPLIDPAG, a.IFRANQPAG, a.IRESRCMPAG, a.IRESREDPAG, a.FCAMBIO, a.NFACREF, a.FFACREF,NVL(a.CUSUALT, 'CONF_MIG'), NVL(a.FALTA, F_SYSDATE),  NVL(a.CUSUMOD, 'CONF_MIG'),
         a.FMODIFI, a.CTRANSFER, a.CULTPAG, a.IRETEIVA, a.IRETEICA, 0 IICA, 0 IRETEIVAPAG, 0 IRETEICAPAG, 0 IICAPAG, 0 CTRIBUTA, 0 SPERSON_PRESENTADOR,
         a.TOBSERVA, 0 IOTROSGAS, 0 IOTROSGASPAG, 0 IBASEIPOC, 0 IBASEIPOCPAG, 0 IIPOCONSUMO, 0 IIPOCONSUMOPAG--7782-47 se agrega el campo tobserva
      FROM mig_sin_tramita_pago_UAT a, mig_sin_tramitacion s, mig_personas p
      WHERE s.mig_pk = a.mig_fk2
      AND p.mig_pk = a.mig_fk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
      ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_pago;
      LOOP
      FETCH lc_mig_sin_tramita_pago BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_tramita_pago WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_pago VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','23_mig_sin_tramita_pago','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_pago%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_pago;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_pago;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_pago.');
    RETURN 0;
  END f_migra_mig_sin_tramita_pago;
  -------------------------------------------------------------
  --f_carga_mig_sin_tramita_pago
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tramita_pago RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tramita_pago';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tramita_pago';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17445;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_PAGO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tramita_pago;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_movpago
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_movpago RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_movpago';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_movpago';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_movpago IS TABLE OF mig_sin_tramita_movpago%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_movpago;
    --
    CURSOR lc_mig_sin_tramita_movpago IS
      SELECT 17446 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SIDEPAG, a.NMOVPAG, a.CESTPAG, a.FEFEPAG,
            a.CESTVAL, a.FCONTAB, 0 SPROCES, a.CUSUALT, a.FALTA, a.CSUBPAG
      FROM MIG_SIN_TRAMITA_MOVPAGO_UAT a, mig_sin_tramita_pago s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_movpago;
      LOOP
      FETCH lc_mig_sin_tramita_movpago BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_sin_tramita_movpago WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_movpago VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','26_mig_sin_tramita_movpago','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_movpago%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_movpago;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_movpago;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_movpago.');
    RETURN 0;
  END f_migra_mig_sin_tram_movpago;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_movpago
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_movpago RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_movpago';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_movpago';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17446;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_MOVPAGO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_movpago;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_pag_gar
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_pag_gar RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_pag_gar';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_pag_gar';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_pago_gar IS TABLE OF mig_sin_tramita_pago_gar%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_pago_gar;
    --
    CURSOR lc_mig_sin_tramita_pago_gar IS
      SELECT 17447 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SIDEPAG, a.CTIPRES, a.NMOVRES, a.CGARANT, a.FPERINI, a.FPERFIN, a.CMONRES, a.ISINRET, a.IRETENC,
             a.IIVA, a.ISUPLID, a.IFRANQ, a.IRESRCM, a.IRESRED, a.CMONPAG, a.ISINRETPAG, a.IIVAPAG, a.ISUPLIDPAG, a.IRETENCPAG, a.IFRANQPAG, a.IRESRCMPAG, a.IRESREDPAG,
             a.FCAMBIO, a.PRETENC, a.PIVA, a.CUSUALT, a.FALTA, a.CUSUMOD, a.FMODIFI, 0 CCONPAG, 0 NORDEN, 0 IICA, a.IRETEIVA, 0 IRETEICA, 0 PICA, a.PRETEIVA, 0 PRETEICA,
             a.CAPLFRA, 0 IICAPAG, 0 IRETEIVAPAG, 0 IRETEICAPAG, 0 IDRES, 0 CRESTARESERVA, 0 IOTROSGAS, 0 IOTROSGASPAG, 0 IBASEIPOC, 0 IBASEIPOCPAG, 0 PIPOCONSUMO,
             0 IIPOCONSUMO, 0 IIPOCONSUMOPAG
      FROM mig_sin_tramita_pago_gar_UAT a, mig_sin_tramita_pago s
      WHERE a.mig_fk = s.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_pago_gar;
      LOOP
      FETCH lc_mig_sin_tramita_pago_gar BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_pago_gar WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_pago_gar VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','23_mig_sin_tramita_pago_gar','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_pago_gar%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_pago_gar;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_pago_gar;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_pago_gar.');
    RETURN 0;
  END f_migra_mig_sin_tram_pag_gar;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_pag_gar
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_pag_gar RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_pag_gar';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_pag_gar';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17447;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_PAGO_GAR_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_pag_gar;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_judicial
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_judicial RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_judicial';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_judicial';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_judicial IS TABLE OF mig_sin_tramita_judicial%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_judicial;
    --
    CURSOR lc_mig_sin_tramita_judicial IS
      SELECT 17448 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,  a.MIG_FK, a.MIG_FK2,  a.NORDEN, a.CPROCESO, a.TPROCESO, a.CPOSTAL,  
             a.CPOBLAC, a.CPROVIN,  a.TIEXTERNO,  a.SPROFES,  a.FRECEP, a.FNOTIFI,  a.FVENCIMI, a.FRESPUES, a.FCONCIL,  a.FDESVIN,  
             a.TPRETEN, a.TEXCEP1,  a.TEXCEP2,  a.FAUDIEN,  a.HAUDIEN,  a.TAUDIEN,  a.CCONTI, a.CDESPA, a.TLAUDIE,  a.CAUDIEN,  
             a.CDESPAO, a.TLAUDIEO, a.CAUDIENO, a.SABOGAU,  a.CORAL,  a.CESTADO,  a.CRESOLU,  a.FINSTA1,  a.FINSTA2, a.FNUEVA, a.TRESULT, 
             a.CPOSICI, a.CDEMAND,  a.SAPODERA, a.IDEMAND,  a.FTDEMAN,  a.ICONDEN, a.CSENTEN, a.FSENTE1, a.FSENTE2, a.CTSENTE, a.TFALLO, a.FMODIFI, a.CUSUALT
             ,NULL CASACION, NULL FCASACI, NULL CSENTEN2,  NULL FTSENTE /*Ojo habilitar para la version 25. Ya deberían estar inf estos campos*/
             ,coralproc, unicainst, funicainst
      FROM MIG_SIN_TRAMITA_JUDICIAL_uat a, mig_sin_siniestro s, mig_sin_tramitacion t
      WHERE a.mig_fk = s.mig_pk
      AND a.mig_fk2 = t.mig_pk
      AND s.nsinies <> 0
      AND t.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_judicial;
      LOOP
      FETCH lc_mig_sin_tramita_judicial BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_judicial WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_judicial VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','32_mig_sin_tramita_judicial','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_judicial%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_judicial;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_judicial;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_judicial.');
    RETURN 0;
  END f_migra_mig_sin_tram_judicial;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_judicial
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_judicial RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_judicial';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_judicial';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17448;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_JUDICIAL_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_judicial;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_judi_det
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_judi_det RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_judi_det';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_judi_det';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tram_judi_detper IS TABLE OF mig_sin_tram_judi_detper%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tram_judi_detper;
    --
    CURSOR lc_mig_sin_tram_judi_detper IS
      SELECT 17449 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,  a.MIG_FK, a.MIG_FK2,  a.NORDEN, a.NROL, a.NPERSONA, a.NTIPPER,  
            a.NNUMIDE,  a.TNOMBRE,  a.IIMPORTE, a.FBAJA,  a.FMODIFI,  a.CUSUALT
      FROM MIG_SIN_TRAM_JUDI_DETPER_UAT a, mig_sin_siniestro s, mig_sin_tramita_judicial t
      WHERE a.mig_fk = s.mig_pk
      AND a.mig_fk2 = t.mig_pk
      AND s.nsinies <> 0
      AND t.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tram_judi_detper;
      LOOP
      FETCH lc_mig_sin_tram_judi_detper BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tram_judi_detper WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tram_judi_detper VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','35_mig_sin_tram_judi_detper','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
          END;
          --dbms_output.put_line('F - paso bullk');
          EXIT WHEN lc_mig_sin_tram_judi_detper%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tram_judi_detper;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tram_judi_detper;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tram_judi_detper.');
    RETURN 0;
  END f_migra_mig_sin_tram_judi_det;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_judi_det
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_judi_det RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_judi_det';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_judi_det';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17449;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAM_JUDI_DETPER_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_judi_det;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_valpret
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_valpret RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_valpret';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_valpret';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tram_valpret IS TABLE OF mig_sin_tram_valpret%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tram_valpret;
    --
    CURSOR lc_mig_sin_tram_valpret IS
      SELECT 17450 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NORDEN, a.CGARANT,
            a.IPRETEN, a.FBAJA, a.FMODIFI, a.CUSUALT
      FROM mig_sin_tram_valpret_UAT a, mig_sin_siniestro s, mig_sin_tramita_judicial t
      WHERE a.mig_fk = s.mig_pk
      AND a.mig_fk2 = t.mig_pk
      AND s.nsinies <> 0
      AND t.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tram_valpret;
      LOOP
      FETCH lc_mig_sin_tram_valpret BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tram_valpret WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tram_valpret VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','38_mig_sin_tram_valpret','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tram_valpret%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tram_valpret;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tram_valpret;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tram_valpret.');
    RETURN 0;
  END f_migra_mig_sin_tram_valpret;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_valpret
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_valpret RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_valpret';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_valpret';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17450;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAM_VALPRET_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_valpret;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_fiscal
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_fiscal RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_fiscal';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_fiscal';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_fiscal IS TABLE OF mig_sin_tramita_fiscal%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_fiscal;
    --
    CURSOR lc_mig_sin_tramita_fiscal IS
      SELECT 17451 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK,  a.MIG_FK, a.MIG_FK2,  a.NORDEN, a.FAPERTU,  a.FIMPUTA,  a.FNOTIFI,  
             a.FAUDIEN, a.HAUDIEN,  a.CAUDIEN,  a.SPROFES,  a.COTERRI,  a.CCONTRA,  a.CUESPEC,  a.TCONTRA,  a.CTIPTRA,  a.TESTADO,  a.CMEDIO, a.FDESCAR,  
             a.FFALLO,  a.CFALLO, NULL TFALLO /*Ojo deben crear*/, a.CRECURSO, a.FMODIFI, a.CUSUALT
      FROM mig_sin_tramita_fiscal_uat a, mig_sin_siniestro s, mig_sin_tramitacion t
      WHERE a.mig_fk  = s.mig_pk
      AND a.mig_fk2 = t.mig_pk
      AND s.nsinies <> 0
      AND t.nsinies <> 0
      --ORDER BY a.mig_pk
      ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_fiscal;
      LOOP
      FETCH lc_mig_sin_tramita_fiscal BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_fiscal WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_fiscal VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','41_mig_sin_tramita_fiscal','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_fiscal%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_fiscal;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_fiscal;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_fiscal.');
    RETURN 0;
  END f_migra_mig_sin_tram_fiscal;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_fiscal
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_fiscal RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_fiscal';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_fiscal';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17451;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_FISCAL_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_fiscal;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_vpretfis
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_vpretfis RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_vpretfis';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_vpretfis';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tram_vpretfis IS TABLE OF mig_sin_tram_vpretfis%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tram_vpretfis;
    --
    CURSOR lc_mig_sin_tram_vpretfis IS
      SELECT 17452 NCARGA, 1 CESTMIG, 0 nsinies, 0 ntramit, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.NORDEN, a.CGARANT, a.IPRETEN, a.FBAJA, a.FMODIFI, a.CUSUALT
      FROM mig_sin_tram_vpretfis_UAT a, mig_sin_siniestro s, mig_sin_tramita_fiscal t
      WHERE a.mig_fk  = s.mig_pk
      AND a.mig_fk2 = t.mig_pk
      AND s.nsinies <> 0
      AND t.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tram_vpretfis;
      LOOP
      FETCH lc_mig_sin_tram_vpretfis BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tram_vpretfis WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tram_vpretfis VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','44_mig_sin_tram_vpretfis','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tram_vpretfis%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tram_vpretfis;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tram_vpretfis;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tram_vpretfis.');
    RETURN 0;
  END f_migra_mig_sin_tram_vpretfis;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_vpretfis
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_vpretfis RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_vpretfis';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_vpretfis';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17452;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAM_VPRETFIS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_vpretfis;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_cita
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_cita RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_cita';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_cita';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_citaciones IS TABLE OF mig_sin_tramita_citaciones%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_citaciones;
    --
    CURSOR lc_mig_sin_tramita_citaciones IS
      SELECT 17453 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NSINIES, 0 NTRAMIT, a.NCITACION, a.FCITACION, a.HCITACION, a.SPERSON,
            a.CPAIS, a.CPROVIN, a.CPOBLAC, a.TLUGAR, a.FALTA, a.TAUDIEN, a.CORAL, a.CESTADO, a.CRESOLU, a.FNUEVA, a.TRESULT, a.CMEDIO 
      FROM mig_sin_tramita_citaciones_uat a, mig_sin_tramitacion t
      WHERE a.mig_fk  = t.mig_pk
      AND t.nsinies <> 0
      AND t.ntramit <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_citaciones;
      LOOP
      FETCH lc_mig_sin_tramita_citaciones BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_citaciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_citaciones VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','47_mig_sin_tramita_citaciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_citaciones%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_citaciones;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_citaciones;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_citaciones.');
    RETURN 0;
  END f_migra_mig_sin_tram_cita;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_cita
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_cita RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_cita';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_cita';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17453;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_CITACIONES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_cita;
  -------------------------------------------------------------
  --f_migra_mig_agd_observa
  -------------------------------------------------------------
  FUNCTION f_migra_mig_agd_observa RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_agd_observa';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_agd_observa';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_agd_observaciones IS TABLE OF mig_agd_observaciones%ROWTYPE;
    l_reg_mig_mcc t_mig_agd_observaciones;
    --
    CURSOR lc_mig_agd_observaciones IS
      SELECT 17454 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CTIPOBS, a.TTITOBS, a.TOBS, a.CTIPAGD,
            a.NTRAMIT, a.PUBLICO, a.CCONOBS, a.FALTA
      FROM mig_agd_observaciones_uat a, mig_sin_siniestro s
      WHERE a.mig_fk  = s.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_agd_observaciones;
      LOOP
      FETCH lc_mig_agd_observaciones BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
      --dbms_output.put_line('I - paso bullk');
      --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_agd_observaciones WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_agd_observaciones VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','50_mig_agd_observaciones','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_agd_observaciones%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_agd_observaciones;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_agd_observaciones;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_agd_observaciones.');
    RETURN 0;
  END f_migra_mig_agd_observa;
  -------------------------------------------------------------
  --f_carga_mig_agd_observa
  -------------------------------------------------------------
  FUNCTION f_carga_mig_agd_observa RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_agd_observa';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_agd_observa';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17454;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_AGD_OBSERVACIONES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_agd_observa;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_apoyo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_apoyo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_apoyo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_apoyo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_apoyo IS TABLE OF mig_sin_tramita_apoyo%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_apoyo;
    --
    CURSOR lc_mig_sin_tramita_apoyo IS
      SELECT 17455 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.SINTAPO, 0 NSINIES, 0 NTRAMIT, a.NAPOYO, a.CUNITRA,
            a.CTRAMITAD, a.FINGRESO, a.FTERMINO, a.FSALIDA, a.TOBSERVA, a.TLOCALI, a.CSIGLAS, a.TNOMVIA, a.NNUMVIA, a.TCOMPLE,
            a.CPAIS, a.CPROVIN, a.CPOBLAC, a.CPOSTAL, a.CVIAVP, a.CLITVP, a.CBISVP, a.CORVP, a.NVIAADCO, a.CLITCO, a.CORCO,
            a.NPLACACO, a.COR2CO, a.CDET1IA, a.TNUM1IA, a.CDET2IA, a.TNUM2IA, a.CDET3IA, a.TNUM3IA, a.LOCALIDAD, a.FALTA,
            a.CUSUALT, a.FMODIFI, a.CUSUMOD, a.TOBSERVA2, a.CAGENTE, a.SPERSON
      FROM mig_sin_tramita_apoyo_uat a, mig_sin_siniestro s, mig_personas b
      WHERE a.mig_fk  = s.mig_pk
      and a.mig_fk2 = b.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tramita_apoyo;
      LOOP
      FETCH lc_mig_sin_tramita_apoyo BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_apoyo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_apoyo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','50_mig_sin_tramita_apoyo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tramita_apoyo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tramita_apoyo;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_apoyo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_apoyo.');
    RETURN 0;
  END f_migra_mig_sin_tram_apoyo;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_apoyo
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_apoyo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_apoyo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_apoyo';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17455;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAMITA_APOYO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_apoyo;
  -------------------------------------------------------------
  --f_migra_mig_sin_tram_estsin 7782-24
  -------------------------------------------------------------
  FUNCTION f_migra_mig_sin_tram_estsin RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_sin_tram_estsin';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_sin_tram_estsin';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_tramita_estsiniestro IS TABLE OF mig_sin_tramita_estsiniestro%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_tramita_estsiniestro;
    --
    CURSOR lc_mig_sin_tram_estsin IS
      SELECT 17493 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.nsinies, a.ntramit, a.nmovimi, a.cusualt, a.falta
             ,a.nclasepro, a.ninstproc, a.nfallocp, a.ncalmot, a.fcontingen, a.tobsfallo
      FROM MIG_SIN_TRAM_ESTSINIESTRO_UAT a, mig_sin_siniestro s
      WHERE a.mig_fk  = s.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tram_estsin;
      LOOP
      FETCH lc_mig_sin_tram_estsin BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_sin_tramita_estsiniestro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_sin_tramita_estsiniestro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','mig_sin_tramita_estsiniestro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tram_estsin%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tram_estsin;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_sin_tramita_estsiniestro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_sin_tramita_estsiniestro.');
    RETURN 0;
  END f_migra_mig_sin_tram_estsin;
  -------------------------------------------------------------
  --f_carga_mig_sin_tram_estsin
  -------------------------------------------------------------
  FUNCTION f_carga_mig_sin_tram_estsin RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_sin_tram_estsin';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_sin_tram_estsin';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17493;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_SIN_TRAM_ESTSIN_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_sin_tram_estsin;
  -------------------------------------------------------------
  --f_migra_mig_pregunsini 7782-24
  -------------------------------------------------------------
  FUNCTION f_migra_mig_pregunsini RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_pregunsini';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_pregunsini';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_sin_pregunsini IS TABLE OF mig_pregunsini%ROWTYPE;
    l_reg_mig_mcc t_mig_sin_pregunsini;
    --
    CURSOR lc_mig_sin_tram_estsin IS
      SELECT 17494 NCARGA, 1 CESTMIG, a.mig_pk, a.mig_fk, a.nsinies, a.cpregun, a.crespue, a.trespue
      FROM mig_pregunsini_uat a, mig_sin_siniestro s
      WHERE a.mig_fk  = s.mig_pk
      AND s.nsinies <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_sin_tram_estsin;
      LOOP
      FETCH lc_mig_sin_tram_estsin BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_pregunsini WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_pregunsini VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','mig_pregunsini','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_sin_tram_estsin%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_sin_tram_estsin;
 
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_pregunsini;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_pregunsini.');
    RETURN 0;
  END f_migra_mig_pregunsini;
  -------------------------------------------------------------
  --f_carga_mig_pregunsini
  -------------------------------------------------------------
  FUNCTION f_carga_mig_pregunsini RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_pregunsini';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_pregunsini';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17494;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    --   
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PREGUNSINI_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_pregunsini;
  -------------------------------------------------------------
  --f_migra_mig_recibos
  -------------------------------------------------------------
  
  
  FUNCTION f_migra_mig_recibos RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_recibos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_recibos';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_recibos IS TABLE OF mig_recibos%ROWTYPE;
    l_reg_mig_mcc t_mig_recibos;
    --
    CURSOR lc_mig_recibos IS
      SELECT 17456 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.NMOVIMI, a.FEMISIO, a.FEFECTO, a.FVENCIM, a.CTIPREC, 0 SSEGURO, a.NRIESGO, a.NRECIBO, a.CESTREC, a.FRECCOB, 
             a.CESTIMP, a.ESCCERO, a.CRECCIA, a.NRECAUX
      FROM mig_recibos_UAT a, mig_seguros s
      WHERE a.mig_fk  = s.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_recibos;
      LOOP
      FETCH lc_mig_recibos BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_recibos WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_recibos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','02_mig_recibos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_recibos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_recibos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_recibos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_recibos.');
    RETURN 0;
  END f_migra_mig_recibos;
  -------------------------------------------------------------
  --f_carga_mig_recibos
  -------------------------------------------------------------
  FUNCTION f_carga_mig_recibos RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_recibos';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_recibos';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17456;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_RECIBOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_recibos;
  -------------------------------------------------------------
  --f_migra_mig_movrecibo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_movrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_movrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_movrecibo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_movrecibo IS TABLE OF mig_movrecibo%ROWTYPE;
    l_reg_mig_mcc t_mig_movrecibo;
    --
    CURSOR lc_mig_movrecibo IS
      SELECT 17457 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NRECIBOS, 0 SMOVREC, a.CESTREC, a.FMOVINI, a.FMOVFIN, a.FEFEADM, a.FMOVDIA, a.CMOTMOV
      FROM mig_movrecibo_uat a, mig_recibos s
      WHERE 1 = 1
      AND a.mig_fk  = s.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_movrecibo;
      LOOP
      FETCH lc_mig_movrecibo BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_movrecibo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_movrecibo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','05_mig_movrecibo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_movrecibo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_movrecibo;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_movrecibo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_movrecibo.');
    RETURN 0;
  END f_migra_mig_movrecibo;
  -------------------------------------------------------------
  --f_carga_mig_movrecibo
  -------------------------------------------------------------
  FUNCTION f_carga_mig_movrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_movrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_movrecibo';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17457;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_MOVRECIBO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_movrecibo;
  -------------------------------------------------------------
  --f_migra_mig_detrecibo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_detrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_detrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_detrecibo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_detrecibos IS TABLE OF mig_detrecibos%ROWTYPE;
    l_reg_mig_mcc t_mig_detrecibos;
    --
    CURSOR lc_mig_detrecibos IS
      SELECT 17458 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.CCONCEP, a.CGARANT, a.NRIESGO, a.ICONCEP, a.NMOVIMA, a.FCAMBIO, a.ICONCEP_MONPOL
      FROM mig_detrecibos_uat a, mig_recibos s
      WHERE a.mig_fk  = s.mig_pk
      AND s.nrecibo <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_detrecibos;
      LOOP
      FETCH lc_mig_detrecibos BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_detrecibos VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','08_mig_Detrecibos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_detrecibos%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_detrecibos;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_detrecibos;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_detrecibos.');
    RETURN 0;
  END f_migra_mig_detrecibo;
  -------------------------------------------------------------
  --f_carga_mig_detrecibo
  -------------------------------------------------------------
  FUNCTION f_carga_mig_detrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_detrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_detrecibo';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17458;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_DETRECIBOS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_detrecibo;
  -------------------------------------------------------------
  --f_migra_mig_detmovrecibo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_detmovrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_detmovrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_detmovrecibo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_detmovrecibo IS TABLE OF mig_detmovrecibo%ROWTYPE;
    l_reg_mig_mcc t_mig_detmovrecibo;
    --
    CURSOR lc_mig_detmovrecibo IS
      SELECT 17459 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 NRECIBO, 0 SMOVREC, a.NORDEN, a.IIMPORTE,
            a.FMOVIMI, a.FEFEADM, a.CUSUARI, a.TDESCRIP, a.FCONTAB, a.IIMPORTE_MONCON, a.FCAMBIO, a.Cmreca, a.Nreccaj--7782-31
      FROM mig_detmovrecibo_uat a, mig_movrecibo s
      WHERE 1 = 1
      AND a.mig_fk  = s.mig_pk
      AND s.nrecibo <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_detmovrecibo;
      LOOP
      FETCH lc_mig_detmovrecibo BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_detmovrecibo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','08_mig_Detrecibos','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_detmovrecibo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_detmovrecibo;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_detmovrecibo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_detmovrecibo.');
    RETURN 0;
  END f_migra_mig_detmovrecibo;
  -------------------------------------------------------------
  --f_carga_mig_detmovrecibo
  -------------------------------------------------------------
  FUNCTION f_carga_mig_detmovrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_detmovrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_detmovrecibo';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17459;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_DETMOVRECIBO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_detmovrecibo;
  -------------------------------------------------------------
  --f_migra_mig_detmovrecibopar
  -------------------------------------------------------------
  FUNCTION f_migra_mig_detmovrecibopar RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_detmovrecibopar';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_detmovrecibopar';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_detmovrecibo_parcial IS TABLE OF mig_detmovrecibo_parcial%ROWTYPE;
    l_reg_mig_mcc t_mig_detmovrecibo_parcial;
    --
    CURSOR lc_mig_detmovrecibo_parcial IS
      SELECT 17460 NCARGA, 1 CESTMIG,a.MIG_PK, a.MIG_FK, 0 NRECIBO, 0 SMOVREC, 0 NORDEN, a.CCONCEP, a.CGARANT, a.NRIESGO, 
            a.FMOVIMI, a.ICONCEP, a.ICONCEP_MONPOL, a.NMOVIMA, a.FCAMBIO
      FROM mig_detmovrecibo_parcial_uat a, mig_recibos s
      WHERE a.mig_fk  = s.mig_pk
      --AND s.nrecibo <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_detmovrecibo_parcial;
      LOOP
      FETCH lc_mig_detmovrecibo_parcial BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_detmovrecibo_parcial VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','10_05_mig_detmovrecibo_parcial','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_detmovrecibo_parcial%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_detmovrecibo_parcial;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_detmovrecibo_parcial;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_detmovrecibo_parcial.');
    RETURN 0;
  END f_migra_mig_detmovrecibopar;
  -------------------------------------------------------------
  --f_migra_mig_comrecibo
  -------------------------------------------------------------
  FUNCTION f_migra_mig_comrecibo RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion_uni.f_migra_mig_comrecibo';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_comrecibo';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_comrecibo IS TABLE OF mig_comrecibo%ROWTYPE;
    l_reg_mig_mcc t_mig_comrecibo;
    --
    CURSOR lc_mig_comrecibo IS
      SELECT 17490 ncarga, 1 cestmig, a.mig_pk, a.mig_fk, 0 nrecibo, a.nnumcom, a.cagente, a.cestrec, a.fmovdia, a.fcontab, 
             a.icombru, a.icomret, a.icomdev, a.iretdev, a.nmovimi, a.icombru_moncia, a.icomret_moncia, a.icomdev_moncia, 
             a.iretdev_moncia, a.fcambio, a.cgarant, a.icomcedida, a.icomcedida_moncia, a.ccompan, a.ivacomisi, a.mig_fk2,
             a.creccia--EZ 7652
      FROM  mig_comrecibo_uat a, mig_recibos r--, mig_seguros s
      WHERE a.mig_fk  = r.mig_pk
      AND   r.nrecibo != 0
      --AND   a.mig_fk1 = s.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_comrecibo;
      LOOP
      FETCH lc_mig_comrecibo BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_comrecibo WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_comrecibo VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','10_05_mig_comrecibo','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        EXIT WHEN lc_mig_comrecibo%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_comrecibo;

    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_comrecibo;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_comrecibo.');
    RETURN 0;
  END f_migra_mig_comrecibo;
  -------------------------------------------------------------
  --f_carga_mig_detmovrecibopar
  -------------------------------------------------------------
  FUNCTION f_carga_mig_detmovrecibopar RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_detmovrecibopar';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_detmovrecibopar';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17460;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_DETMOVRECIBO_PARCIAL_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    
    vncarga := 17490;
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COMRECIBO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := nresult + PAC_MIGRACION.f_valida_errores(vncarga);
    
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_detmovrecibopar;
  -------------------------------------------------------------
  --f_migra_mig_liquidacab
  -------------------------------------------------------------
  FUNCTION f_migra_mig_liquidacab RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_liquidacab';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_liquidacab';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_liquidacab IS TABLE OF mig_liquidacab%ROWTYPE;
    l_reg_mig_mcc t_mig_liquidacab;
    --
    CURSOR lc_mig_liquidacab IS
      SELECT 17461 NCARGA, 1 CESTMIG, a.MIG_PK, a.CAGENTE, a.NLIQMEN, a.FLIQUID, a.FMOVIMI, a.CTIPOLIQ, a.CESTADO, a.CUSUARI, a.FCOBRO
      FROM mig_liquidacab_uat a, agentes g
      WHERE a.cagente = g.cagente
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_liquidacab;
      LOOP
      FETCH lc_mig_liquidacab BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_liquidacab VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','11_mig_liquidacab','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_liquidacab%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_liquidacab;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_liquidacab;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_liquidacab.');
    RETURN 0;
  END f_migra_mig_liquidacab;
  -------------------------------------------------------------
  --f_carga_mig_liquidacab
  -------------------------------------------------------------
  FUNCTION f_carga_mig_liquidacab RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_liquidacab';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_liquidacab';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17461;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_LIQUIDACAB_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_liquidacab;
  -------------------------------------------------------------
  --f_migra_mig_liquidalin
  -------------------------------------------------------------
  FUNCTION f_migra_mig_liquidalin RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_liquidalin';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_liquidalin';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_liquidalin IS TABLE OF mig_liquidalin%ROWTYPE;
    l_reg_mig_mcc t_mig_liquidalin;
    --
    CURSOR lc_mig_liquidalin IS
      SELECT 17462 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.ITOTIMP, a.ITOTALR, a.IPRINET, a.ICOMISI, a.IRETENCCOM, a.ISOBRECOMISION, a.IRETENCSOBRECOM, a.ICONVOLEDUCTO,
             a.IRETENCOLEODUCTO, a.CTIPOLIQ, a.ITOTIMP_MONCIA, a.ITOTALR_MONCIA, a.IPRINET_MONCIA, a.ICOMISI_MONCIA, a.IRETENCCOM_MONCIA, a.ISOBRECOM_MONCIA, a.IRETENCSCOM_MONCIA, a.ICONVOLEOD_MONCIA,
             a.IRETOLEOD_MONCIA, a.FCAMBIO
      FROM mig_liquidalin_uat a,MIG_LIQUIDACAB b,MIG_MOVRECIBO c
      WHERE 1 = 1
      and a.MIG_FK  = b.MIG_PK
      and a.MIG_FK2 = c.MIG_PK
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_liquidalin;
      LOOP
      FETCH lc_mig_liquidalin BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_liquidalin VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','11_mig_liquidalin','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_liquidalin%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_liquidalin;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_liquidalin;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_liquidalin.');
    RETURN 0;
  END f_migra_mig_liquidalin;
  -------------------------------------------------------------
  --f_carga_mig_liquidalin
  -------------------------------------------------------------
  FUNCTION f_carga_mig_liquidalin RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_liquidalin';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_liquidalin';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17462;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_LIQUIDALIN_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_liquidalin;
  -------------------------------------------------------------
  --f_migra_mig_ctactes
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctactes RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctactes';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctactes';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctactes IS TABLE OF mig_ctactes%ROWTYPE;
    l_reg_mig_mcc t_mig_ctactes;
    --
    CURSOR lc_mig_ctactes IS
      SELECT 17463 NCARGA, 1 CESTMIG, a.* --, r.nrecibo, s.sseguro, sn.nsinies
      FROM mig_ctactes_uat a , mig_recibos r, mig_seguros s--, mig_siniestros sn
      WHERE a.MIG_FK  = r.MIG_PK
      --and a.MIG_FK2 = sn.MIG_PK
      and a.MIG_FK3 = s.MIG_PK
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ctactes;
      LOOP
      FETCH lc_mig_ctactes BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctactes VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','17_mig_ctactes','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctactes%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctactes;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctactes;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctactes.');
    RETURN 0;
  END f_migra_mig_ctactes;
  -------------------------------------------------------------
  --f_carga_mig_ctactes
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctactes RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctactes';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctactes';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17463;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTACTES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctactes;
  -------------------------------------------------------------
  --f_migra_mig_ptpplp
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ptpplp RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ptpplp';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ptpplp';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ptpplp IS TABLE OF mig_ptpplp%ROWTYPE;
    l_reg_mig_mcc t_mig_ptpplp;
    --
    CURSOR lc_mig_ptpplp IS
      SELECT 17464 NCARGA, 1 CESTMIG, a.producto, a.póliza, 0 sseguro, a.sinestro, 0 nsiniestro, a.fcalculo, 
            a.ipplpsd, a.ipplprc, a.ivalbruto, a.ivalpago, a.ippl, a.ippp, a.mig_pk
      FROM mig_ptpplp_uat a, MIG_SEGUROS c, MIG_SIN_SINIESTRO s--7183 EZ LA TABLA DE SINIESTROS ERA INCORRECTA
      WHERE 1 = 1
      AND a.PóLIZA  = c.mig_pk
      AND a.sinestro = s.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ptpplp;
      LOOP
      FETCH lc_mig_ptpplp BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ptpplp VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','23_mig_ptpplp','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '/*||l_reg_mig_mcc(l_idx).mig_pk*/);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ptpplp%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ptpplp;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ptpplp;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ptpplp.');
    RETURN 0;
  END f_migra_mig_ptpplp;
  -------------------------------------------------------------
  --f_carga_mig_ptpplp
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ptpplp RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ptpplp';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ptpplp';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17464;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PTPPLP_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ptpplp;
  -------------------------------------------------------------
  --f_migra_mig_clausulasreas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_clausulasreas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_clausulasreas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_clausulasreas';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_clausulas_reas IS TABLE OF mig_clausulas_reas%ROWTYPE;
    l_reg_mig_mcc t_mig_clausulas_reas;
    --
    CURSOR lc_mig_clausulas_reas IS
      SELECT 17467 NCARGA, 1 CESTMIG, a.mig_pk, a.ccodigo, a.tdescripcion
      FROM mig_clausulas_reas_uat a --, mig_recibos r, mig_seguros s, mig_siniestros sn
      WHERE 1 = 1        
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_clausulas_reas;
      LOOP
      FETCH lc_mig_clausulas_reas BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_clausulas_reas WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_clausulas_reas VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','14_mig_clausulas_reas','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_clausulas_reas%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_clausulas_reas;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_clausulas_reas;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_clausulas_reas.');
    RETURN 0;
  END f_migra_mig_clausulasreas;
  -------------------------------------------------------------
  --f_carga_mig_clausulasreas
  -------------------------------------------------------------
  FUNCTION f_carga_mig_clausulasreas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_clausulasreas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_clausulasreas';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17467;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CLAUSULAS_REAS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_clausulasreas;
  -------------------------------------------------------------
  --f_migra_mig_ctatecnica
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctatecnica RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctatecnica';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctatecnica';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctatecnica IS TABLE OF mig_ctatecnica%ROWTYPE;
    l_reg_mig_mcc t_mig_ctatecnica;
    --
    CURSOR lc_mig_ctatecnica IS
      SELECT 17468 NCARGA, 1 CESTMIG, a.MIG_PK,  a.MIG_FK,a.MIG_FK2, a.NVERSION, a.SCONTRA,  a.TRAMO,  a.NNUMLIN,  a.FMOVIMI,  a.FEFECTO,  a.CCONCEP,  
             a.CDEDHAB, a.IIMPORT,  a.CESTADO,  a.IIMPORT_MONCON, a.FCAMBIO,  a.CTIPMOV,  a.SPRODUC,  a.NPOLIZA,  a.NSINIESTRO, a.TDESCRI,  a.TDOCUME,  
             a.FLIQUID, a.CEVENTO,  a.FCONTAB,  a.SIDEPAG,  a.CUSUCRE,  a.FCREAC, a.CRAMO,  a.CCORRED
      FROM mig_ctatecnica_uat a , mig_companias mc, mig_contratos mct
      WHERE a.mig_fk = mc.mig_pk
      AND   a.mig_fk2 = mct.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ctatecnica;
      LOOP
      FETCH lc_mig_ctatecnica BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_ctatecnica WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctatecnica VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','17_mig_ctatecnica','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctatecnica%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctatecnica;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctatecnica;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctatecnica.');
    RETURN 0;
  END f_migra_mig_ctatecnica;
  -------------------------------------------------------------
  --f_carga_mig_ctatecnica
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctatecnica RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctatecnica';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctatecnica';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17468;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTATECNICA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctatecnica;
  -------------------------------------------------------------
  --f_migra_mig_cesionesrea
  -------------------------------------------------------------
  FUNCTION f_migra_mig_cesionesrea RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_cesionesrea';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_cesionesrea';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_cesionesrea IS TABLE OF mig_cesionesrea%ROWTYPE;
    l_reg_mig_mcc t_mig_cesionesrea;
    --
    CURSOR lc_mig_cesionesrea IS
      SELECT 17469 NCARGA, 1 CESTMIG, a.MIG_PK, NVL(a.SCESREA, 0) SCESREA, a.NCESION, a.ICESION, a.ICAPCES, s.sseguro MIG_FKSEG, 
          a.NVERSIO, a.SCONTRA, /*Ojo estos datos los deben actualizar con la data cargada de Contratos*/
          a.CTRAMO, a.SFACULT, a.NRIESGO, a.CGARANT, NVL(NULL, 0) MIF_FKSINI, a.FEFECTO, a.FVENCIM, a.FCONTAB, a.PCESION, a.CGENERA,
          a.FGENERA, a.FREGULA, a.FANULAC, a.NMOVIMI, a.IPRITARREA, a.IDTOSEL, a.PSOBREPRIMA, a.CDETCES, a.IPLENO, a.ICAPACI, a.NMOVIGEN, 
          a.CTRAMPA, null CTIPOMOV, null CCUTOFF, a.mig_fk
      FROM mig_cesionesrea_uat a, mig_contratos c, mig_seguros s
      WHERE 1 = 1
      AND a.mig_fkseg = s.mig_pk (+)
      and a.mig_fk = c.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_cesionesrea;
      LOOP
      FETCH lc_mig_cesionesrea BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_cesionesrea WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_cesionesrea VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','17_mig_cesionesrea','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_cesionesrea%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_cesionesrea;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_cesionesrea;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_cesionesrea.');
    RETURN 0;
  END f_migra_mig_cesionesrea;
  -------------------------------------------------------------
  --f_carga_mig_cesionesrea
  -------------------------------------------------------------
  FUNCTION f_carga_mig_cesionesrea RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_cesionesrea';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_cesionesrea';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17469;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CESIONESREA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_cesionesrea;
  -------------------------------------------------------------
  --f_migra_mig_det_cesiones
  -------------------------------------------------------------
  FUNCTION f_migra_mig_det_cesiones RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_det_cesiones';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_det_cesiones';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_det_cesionesrea IS TABLE OF mig_det_cesionesrea%ROWTYPE;
    l_reg_mig_mcc t_mig_det_cesionesrea;
    --
    cursor LC_MIG_DET_CESIONESREA is
      SELECT 17470 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, c.scesrea SCESREA, NVL(a.SDETCESREA, 0) SDETCESREA, nvl(a.SSEGURO, 0) sseguro, a.NMOVIMI,
            a.PTRAMO, a.CGARANT, a.ICESION, a.ICAPCES, a.PCESION, a.PSOBREPRIMA, a.IEXTRAP, a.IEXTREA, a.IPRITARREA, a.ITARIFREA, a.ICOMEXT,
            a.CCOMPANI, a.FALTA, a.CUSUALT, a.FMODIFI, a.CUSUMOD, null CDEPURA, null FEFECDEMA, null NMOVDEP, null SPERSON
      FROM mig_det_cesionesrea_uat a, mig_cesionesrea c
      WHERE 1 = 1
      and a.MIG_FK = C.MIG_PK
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_det_cesionesrea;
      LOOP
      FETCH lc_mig_det_cesionesrea BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_det_cesionesrea VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','23_mig_det_cesionesrea','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_det_cesionesrea%NOTFOUND;
        --COMMIT;
      END LOOP;
    CLOSE lc_mig_det_cesionesrea;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_det_cesionesrea;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_det_cesionesrea.');
    RETURN 0;
  END f_migra_mig_det_cesiones;
  -------------------------------------------------------------
  --f_carga_mig_det_cesiones
  -------------------------------------------------------------
  FUNCTION f_carga_mig_det_cesiones RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_det_cesiones';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_det_cesiones';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17470;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_DET_CESIONESREA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_det_cesiones;
  -------------------------------------------------------------
  --f_migra_mig_cuafacul
  -------------------------------------------------------------
  FUNCTION f_migra_mig_cuafacul RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_cuafacul';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_cuafacul';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_cuafacul IS TABLE OF mig_cuafacul%ROWTYPE;
    l_reg_mig_mcc t_mig_cuafacul;
    --
    CURSOR lc_mig_cuafacul IS
      SELECT 17471 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SFACULT, a.CESTADO, a.FINICUF, a.CFREBOR, 0 SCONTRA,
            0 NVERSIO, 0 SSEGURO, a.CCALIF1, a.CCALIF2, a.SPLENO, a.NMOVIMI, a.SCUMULO, a.NRIESGO, a.FFINCUF, a.PLOCAL,
            a.FULTBOR, a.PFACCED, a.IFACCED, a.NCESION, a.CTIPFAC, a.PTASAXL, null CNOTACES, a.CGARANT
      FROM mig_cuafacul_uat a, mig_contratos c, mig_seguros s
      WHERE 1 = 1
      AND a.mig_fk  = c.mig_pk
      AND a.mig_fk2 = s.mig_pk
      AND s.sseguro <> 0
      AND c.scontra <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_cuafacul;
      LOOP
      FETCH lc_mig_cuafacul BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_cuafacul WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_cuafacul VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','26_mig_cuafacul','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_cuafacul%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_cuafacul;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_cuafacul;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_cuafacul.');
    RETURN 0;
  END f_migra_mig_cuafacul;
  -------------------------------------------------------------
  --f_carga_mig_cuafacul
  -------------------------------------------------------------
  FUNCTION f_carga_mig_cuafacul RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_cuafacul';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_cuafacul';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17471;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CUAFACUL_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_cuafacul;
  -------------------------------------------------------------
  --f_migra_mig_cuacesfac
  -------------------------------------------------------------
  FUNCTION f_migra_mig_cuacesfac RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_cuacesfac';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_cuacesfac';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_cuacesfac IS TABLE OF mig_cuacesfac%ROWTYPE;
    l_reg_mig_mcc t_mig_cuacesfac;
    --
    CURSOR lc_mig_cuacesfac IS
      SELECT 17472 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, 0 SFACULT, 0 CCOMPANI, 0 CCOMREA,
            a.PCESION, a.ICESFIJ, a.ICOMFIJ, a.ISCONTA, a.PRESERV, a.PINTRES, a.PCOMISI, a.CINTRES, a.CCORRED,
            a.CFRERES, a.CRESREA, a.CCONREC, a.FGARPRI, a.FGARDEP, a.PIMPINT, a.CTRAMOCOMISION, a.TIDFCOM, a.PRESREA, NULL IRESERV, NULL IRESREA--7782-42
      FROM mig_cuacesfac_uat a, MIG_CUAFACUL c, MIG_COMPANIAS s
      WHERE 1 = 1
      AND a.mig_fk  = c.mig_pk
      AND a.mig_fk2 = s.mig_pk
      AND s.ccompani <> 0
      AND c.sfacult <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_cuacesfac;
      LOOP
      FETCH lc_mig_cuacesfac BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_cuacesfac WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_cuacesfac VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','26_mig_cuacesfac','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_cuacesfac%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_cuacesfac;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_cuacesfac;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_cuacesfac.');
    RETURN 0;
  END f_migra_mig_cuacesfac;
  -------------------------------------------------------------
  --f_carga_mig_cuacesfac
  -------------------------------------------------------------
  FUNCTION f_carga_mig_cuacesfac RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_cuacesfac';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_cuacesfac';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17472;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CUACESFAC_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_cuacesfac;
  -------------------------------------------------------------
  --f_migra_mig_eco_tipocambio
  -------------------------------------------------------------
  FUNCTION f_migra_mig_eco_tipocambio RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_eco_tipocambio';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_eco_tipocambio';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_eco_tipocambio IS TABLE OF MIG_ECO_TIPOCAMBIO%ROWTYPE;
    l_reg_mig_mcc t_mig_eco_tipocambio;
    --
    CURSOR lc_mig_eco_tipocambio IS
      SELECT 17473 NCARGA, 1 CESTMIG,a.CMONORI,a.CMONDES,a.FCAMBIO,a.ITASA,a.MIG_PK
      FROM MIG_ECO_TIPOCAMBIO_uat a 
      --ORDER BY a.mig_pk
      ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_eco_tipocambio;
      LOOP
      FETCH lc_mig_eco_tipocambio BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM MIG_ECO_TIPOCAMBIO WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;

        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO MIG_ECO_TIPOCAMBIO VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_MIG_ECO_TIPOCAMBIO','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_eco_tipocambio%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_eco_tipocambio;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   MIG_ECO_TIPOCAMBIO;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en MIG_ECO_TIPOCAMBIO.');
    RETURN 0;
  END f_migra_mig_eco_tipocambio;
  -------------------------------------------------------------
  --f_carga_mig_eco_tipocambio
  -------------------------------------------------------------
  FUNCTION f_carga_mig_eco_tipocambio RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_eco_tipocambio';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_eco_tipocambio';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17473;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_ECO_TIPOCAMBIO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_eco_tipocambio;
  -------------------------------------------------------------
  --f_migra_mig_ctapb
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctapb RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctapb';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctapb';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctapb IS TABLE OF mig_ctapb%ROWTYPE;
    l_reg_mig_mcc t_mig_ctapb;
    --
    CURSOR lc_mig_ctapb IS
      SELECT 17474 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, a.MIG_FK2, a.FCIERRE, a.CCONCEPPB, a.TIPO, a.IIMPORT, a.CEMPRES, a.CTRAMO, 0 SPRODUC
      FROM   MIG_ctapb_uat a, mig_codicontratos b, mig_companias c
      WHERE a.mig_fk = b.mig_pk
      and   a.mig_fk2 = c.mig_pk
     ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ctapb;
      LOOP
      FETCH lc_mig_ctapb BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        b_hay_dato := TRUE;
        --
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_ctapb WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctapb VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;

            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_Mig_Ctapb','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctapb%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctapb;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctapb;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctapb.');
    RETURN 0;
  END f_migra_mig_ctapb;
  -------------------------------------------------------------
  --f_carga_mig_ctapb
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctapb RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctapb';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctapb';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17474;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTAPB_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctapb;
  -------------------------------------------------------------
  --f_migra_mig_planillas
  -------------------------------------------------------------
  FUNCTION f_migra_mig_planillas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_planillas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_planillas';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_planillas IS TABLE OF MIG_PLANILLAS%ROWTYPE;
    l_reg_mig_mcc t_mig_planillas;
    --
    CURSOR lc_mig_planillas IS
      SELECT 17475 NCARGA, 1 CESTMIG, CMAP||CRAMO||SPRODUC||CCOMPANI MIG_PK--llave basada en la tabla def
             ,a.CMAP,a.CRAMO,a.SPRODUC,a.FPLANILLA,a.CCOMPANI,a.COBSERVACIONES,a.CONSECUTIVO,a.CMONEDA
      FROM MIG_PLANILLAS_uat a 
      --ORDER BY a.mig_pk
     ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_planillas;
      LOOP
      FETCH lc_mig_planillas BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM MIG_PLANILLAS WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;

        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
          INSERT INTO MIG_PLANILLAS VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_MIG_PLANILLAS','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(i).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_planillas%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_planillas;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   MIG_PLANILLAS;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en MIG_PLANILLAS.');
    RETURN 0;
  END f_migra_mig_planillas;
  -------------------------------------------------------------
  --f_carga_mig_planillas
  -------------------------------------------------------------
  FUNCTION f_carga_mig_planillas RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_planillas';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_planillas';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17475;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_PLANILLAS_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_planillas;
  -------------------------------------------------------------
  --f_migra_mig_fin_gen
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_gen RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_fin_gen';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_gen';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_general IS TABLE OF mig_fin_general%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_general;
    --
    CURSOR lc_mig_fin_general IS
      SELECT 17476 NCARGA, 1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SFINANCI, a.TDESCRIP, a.FCCOMER, a.CFOTORUT, a.FRUT,
            a.TTITULO, a.CFOTOCED, a.FEXPICED, a.CPAIS, a.CPROVIN, a.CPOBLAC, a.TINFOAD, a.CCIIU, a.CTIPSOCI, a.CESTSOC, a.TOBJSOC,
            a.TEXPERI, a.FCONSTI, a.TVIGENC
      FROM mig_fin_general_UAT a, MIG_personas p
      WHERE a.mig_fk  = p.mig_pk  --Sacar consulta de los excluidos
      AND p.idperson <> 0 --Sacar consulta de los excluidos
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_general;
      LOOP
      FETCH lc_mig_fin_general BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_general VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','02_mig_fin_general','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '/*||l_reg_mig_mcc(l_idx).mig_pk*/);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_general%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_general;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_fin_general;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_fin_general.');
    RETURN 0;
  END f_migra_mig_fin_gen;
  -------------------------------------------------------------
  --f_migra_mig_fin_gen_det
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_gen_det RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion_uni.f_migra_mig_fin_gen_det';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_gen_det';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_general_det IS TABLE OF mig_fin_general_det%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_general_det;
    --
    CURSOR lc_mig_fin_general_det IS
      SELECT 17489 NCARGA, 1 CESTMIG, a.mig_pk, a.mig_fk, 0 sfinanci, a.nmovimi, a.tdescrip, a.cfotorut, a.frut, a.ttitulo, a.cfotoced, 
             a.fexpiced, a.cpais, a.cprovin, a.cpoblac, a.tinfoad, a.cciiu, a.ctipsoci, a.cestsoc, a.tobjsoc, a.texperi, a.fconsti, a.tvigenc, 
             a.fccomer
      FROM MIG_FIN_GENERAL_DET_UAT a, mig_fin_general p
      WHERE a.mig_fk  = p.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_general_det;
      LOOP
      FETCH lc_mig_fin_general_det BULK COLLECT INTO l_reg_mig_mcc LIMIT v_limit_records;
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_fin_general_det WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_general_det VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','02_mig_fin_general','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '/*||l_reg_mig_mcc(l_idx).mig_pk*/);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_general_det%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_general_det;

    IF NOT b_error AND b_hay_dato THEN
      COMMIT;
      RETURN 0;
      --dbms_output.put_line('- Ini pac_mig_axis.p_migra_cargas -');
    ELSE
      ROLLBACK;
      RETURN 1000455;
      --dbms_output.put_line('- ROLLBACK -');
    END IF;
  END f_migra_mig_fin_gen_det;
  -------------------------------------------------------------
  --f_carga_mig_fin_gen
  -------------------------------------------------------------
  FUNCTION f_carga_mig_fin_gen RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_fin_gen';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_fin_gen';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17476;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_GENERAL_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);

    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    
    vncarga := 17489;
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_GENERAL_DET_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
      
    nresult := nresult + pac_migracion_uni.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_fin_gen;
  -------------------------------------------------------------
  --f_migra_mig_fin_d_renta
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_d_renta RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_fin_d_renta';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_d_renta';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_d_renta IS TABLE OF mig_fin_d_renta%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_d_renta;
    --
    CURSOR lc_mig_fin_d_renta IS
      SELECT 17477 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, p.SFINANCI, a.FCORTE, a.CESVALOR, a.IPATRILIQ, a.IRENTA
      FROM mig_fin_d_renta_uat a, mig_fin_general p
      WHERE 1 = 1
      AND a.mig_fk  = p.mig_pk
      AND p.sfinanci <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_d_renta;
      LOOP
      FETCH lc_mig_fin_d_renta BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_d_renta VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','05_mig_fin_d_renta','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
              --num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100,l_reg_mig_mcc(l_idx).mig_pk,'I','Error insert: '||l_msg);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_d_renta%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_d_renta;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_fin_d_renta;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_fin_d_renta.');
    RETURN 0;
  END f_migra_mig_fin_d_renta;
  -------------------------------------------------------------
  --f_carga_mig_fin_d_renta
  -------------------------------------------------------------
  FUNCTION f_carga_mig_fin_d_renta RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_fin_d_renta';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_fin_d_renta';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17477;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_D_RENTA_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_fin_d_renta;
  -------------------------------------------------------------
  --f_migra_mig_fin_deuda
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_deuda RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_fin_deuda';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_deuda';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_endeudamiento IS TABLE OF mig_fin_endeudamiento%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_endeudamiento;
    --
    CURSOR lc_mig_fin_endeudamiento IS
      SELECT 17478 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, 0 SFINANCI, NVL(a.FCONSULTA,SYSDATE),a.CFUENTE,a.IMINIMO,a.ICAPPAG,
            a.ICAPEND,a.IENDTOT,a.NCALIFA,a.NCALIFB,a.NCALIFC,a.NCALIFD,a.NCALIFE,
            a.NCONSUL,a.NSCORE ,a.NMORA  ,a.ICUPOG ,a.ICUPOS ,a.FCUPO  ,a.TCUPOR ,a.CRESTRIC,a.TCONCEPC,a.TCONCEPS,a.TCBUREA ,
            a.TCOTROS --,a.SUCREA  ,a.FECHAING,a.MODULO  ,a.NINCUMP
      FROM mig_fin_endeudamiento_uat a, mig_fin_general p
      WHERE 1 = 1
      AND a.mig_fk  = p.mig_pk
      AND p.sfinanci <> 0
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_endeudamiento;
      LOOP
      FETCH lc_mig_fin_endeudamiento BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_endeudamiento VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','08_mig_fin_endeudamiento','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_endeudamiento%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_endeudamiento;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_fin_endeudamiento;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_fin_endeudamiento.');
    RETURN 0;
  END f_migra_mig_fin_deuda;
  -------------------------------------------------------------
  --f_carga_mig_fin_deuda
  -------------------------------------------------------------
  FUNCTION f_carga_mig_fin_deuda RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_fin_deuda';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_fin_deuda';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17478;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_ENDEUDAMIENTO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_fin_deuda;
  -------------------------------------------------------------
  --f_migra_mig_fin_indi
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_indi RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_fin_indi';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_indi';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_indicadores IS TABLE OF mig_fin_indicadores%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_indicadores;
    --
    CURSOR lc_mig_fin_indicadores IS
      SELECT 17479 NCARGA,1 CESTMIG, a.MIG_PK, a.MIG_FK, NVL(SFINANCI,0), a.NMOVIMI, a.FINDICAD, a.IMARGEN, a.ICAPTRAB, a.TRAZCOR, a.TPRBACI, a.IENDUADA,
            a.NDIACAR, a.NROTPRO, a.NROTINV, a.NDIACICL, a.IRENTAB, a.IOBLCP, a.IOBLLP, a.IGASTFIN, a.IVALPT, a.CESVALOR, a.CMONEDA, a.FCUPO, a.ICUPOG, a.ICUPOS,
            a.FCUPOS, a.TCUPOR, a.TCONCEPC, a.TCONCEPS, a.TCBUREA, a.TCOTROS, a.CMONCAM, a.NCAPFIN
      FROM mig_fin_indicadores_uat a, mig_fin_general p
      WHERE 1 = 1
      AND a.mig_fk  = p.mig_pk
      --ORDER BY a.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_indicadores;
      LOOP
      FETCH lc_mig_fin_indicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_tipos_indicadores WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_indicadores VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('ALUNA','11_mig_fin_indicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_indicadores%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_indicadores;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_fin_indicadores;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_fin_indicadores.');
    RETURN 0;
  END f_migra_mig_fin_indi;
  -------------------------------------------------------------
  --f_carga_mig_fin_indi
  -------------------------------------------------------------
  FUNCTION f_carga_mig_fin_indi RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_fin_indi';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_fin_indi';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17479;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_INDICADORES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_fin_indi;
  -------------------------------------------------------------
  --f_migra_mig_fin_parindi
  -------------------------------------------------------------
  FUNCTION f_migra_mig_fin_parindi RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_fin_parindi';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_fin_parindi';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_fin_parindicadores IS TABLE OF mig_fin_parindicadores%ROWTYPE;
    l_reg_mig_mcc t_mig_fin_parindicadores;

    CURSOR lc_mig_fin_parindicadores IS
      SELECT  17480 NCARGA,1 CESTMIG, p.MIG_PK, p.MIG_FK, p.FECHA_EST_FIN, p.VT_PER_ANT, p.VENTAS, p.COSTO_VT, p.GASTO_ADM, p.UTIL_OPERAC, p.GASTO_FIN,
              p.RES_ANT_IMP, p.UTIL_NETA, p.INVENT, p.CARTE_CLIE, p.ACT_CORR, p.PROP_PLNT_EQP, p.TOT_ACT_NO_CORR, p.ACT_TOTAL, p.O_FIN_CORTO_PLAZO, p.PROVEE_CORTO_PLAZO,
              p.ATC_CORTO_PLAZO, p.PAS_CORR, p.O_FIN_LARGO_PLAZO, p.ATC_LARGO_PLAZO, p.PAS_NO_CORR, p.PAS_TOTAL, p.PATRI_PERI_ANT, p.PATRI_ANO_ACTUAL, 
              p.RESV_LEGAL, p.CAP_SOCIAL, p.RES_EJER_ANT, p.PRIMA_ACCION, p.RESV_OCASI, p.VALORIZA, p.ASIGNADO, p.FUENTE_INFORMACION
      FROM MIG_FIN_PARAINDICADORES_UAT p, mig_fin_general g
      WHERE p.mig_fk  = g.mig_pk
      AND g.sfinanci <> 0
      --ORDER BY p.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_fin_parindicadores;
      LOOP
      FETCH lc_mig_fin_parindicadores BULK COLLECT INTO l_reg_mig_mcc LIMIT 1000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
          DELETE FROM mig_fin_parindicadores WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_fin_parindicadores VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              --p_control_error('ALUNA','14_mig_fin_parindicadores','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_fin_parindicadores%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_fin_parindicadores;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_fin_parindicadores;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_fin_parindicadores.');
    RETURN 0;
  END f_migra_mig_fin_parindi;
  -------------------------------------------------------------
  --f_carga_mig_fin_parindi
  -------------------------------------------------------------
  FUNCTION f_carga_mig_fin_parindi RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_fin_parindi';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_fin_parindi';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17480;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_FIN_PARINDICADORES_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_fin_parindi;
  -------------------------------------------------------------
  --f_migra_mig_coacuadro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_coacuadro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_coacuadro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_coacuadro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_coacuadro IS TABLE OF mig_coacuadro%ROWTYPE;
    l_reg_mig_mcc t_mig_coacuadro;
    --
    CURSOR LC_MIG_COACUADRO is
      SELECT 17481 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, NVL(a.NCUACOA,0), a.finicoa, a.ffincoa,a.PLOCCOA,a.FCUACOA, c.ccompani, a.npoliza, 0 sseguro
      FROM mig_coacuadro_uat a, mig_seguros s, mig_companias c
      WHERE 1 = 1
      and a.MIG_FK = S.MIG_PK
      AND a.mig_fk2 = c.mig_pk --(+)  7782-34 esto no debe ser opcional  la compania siempre tiene que existir
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_coacuadro;
      LOOP
      FETCH lc_mig_coacuadro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_coacuadro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_coacuadro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','04_mig_coacuadro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_coacuadro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_coacuadro;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_coacuadro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_coacuadro.');
    RETURN 0;
  END f_migra_mig_coacuadro;
  -------------------------------------------------------------
  --f_migra_mig_coacedido
  -------------------------------------------------------------
  FUNCTION f_migra_mig_coacedido RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_coacedido';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_coacedido';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_coacedido IS TABLE OF mig_coacedido%ROWTYPE;
    l_reg_mig_mcc t_mig_coacedido;
    --
    CURSOR lc_mig_coacedido IS--7782-34 EL CCOMPAN VINE DE COMPANIAS
      SELECT 17482 ncarga,1 CESTMIG, a.MIG_PK, a.MIG_FK, NVL(a.NCUACOA,0), c.ccompani, a.PCESCOA, a.PCOMCOA, a.PCOMCON, a.PCOMGAS, a.PCESION
      FROM mig_coacedido_uat a, mig_coacuadro s, mig_companias c
      WHERE 1 = 1
      AND a.mig_fk = s.mig_pk
      AND a.mig_fk2 = c.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_coacedido;
      LOOP
      FETCH lc_mig_coacedido BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_coacedido WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_coacedido VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','04_mig_coacedido','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_coacedido%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_coacedido;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_coacedido;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_coacedido.');
    RETURN 0;
  END f_migra_mig_coacedido;
  -------------------------------------------------------------
  --f_migra_mig_ctacoaseguro
  -------------------------------------------------------------
  FUNCTION f_migra_mig_ctacoaseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_ctacoaseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_ctacoaseguro';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_ctacoaseguro IS TABLE OF mig_ctacoaseguro%ROWTYPE;
    l_reg_mig_mcc t_mig_ctacoaseguro;
    --
    CURSOR lc_mig_ctacoaseguro IS
      SELECT 17483 ncarga,1 CESTMIG, a.MIG_PK, a.SMOVCOA, a.MIG_FK2, a.CIMPORT, a.CTIPCOA, a.CMOVIMI, a.IMOVIMI, a.FMOVIMI,
            a.FCONTAB, a.CDEBHAB, a.FLIQCIA, a.PCESCOA, a.SIDEPAG, 0 NRECIBO, 0 SMOVREC, a.CEMPRES, 0 SSEGURO, a.SPRODUC, a.CESTADO,
            a.CTIPMOV, a.TDESCRI, a.TDOCUME, a.IMOVIMI_MONCON, a.FCAMBIO, a.NSINIES, a.CCOMPAPR, a.CMONEDA, a.SPAGCOA, a.CTIPGAS,
            a.FCIERRE, a.NTRAMIT, a.NMOVRES, a.CGARANT, a.MIG_FK3, a.MIG_FK4, a.MIG_FK5
      FROM mig_ctacoaseguro_uat a, mig_companias c, mig_seguros s, mig_recibos r, mig_siniestros sn
      WHERE 1 = 1
      AND a.mig_fk2 = c.mig_pk
      AND a.mig_fk3 = s.mig_pk (+)
      AND a.mig_fk4 = r.mig_pk (+)
      AND a.mig_fk5 = sn.mig_pk (+)
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_ctacoaseguro;
      LOOP
      FETCH lc_mig_ctacoaseguro BULK COLLECT INTO l_reg_mig_mcc LIMIT 10000;  -- limit to 10k to avoid out of memory
        --dbms_output.put_line('I - paso bullk');  
        --dbms_output.put_line('...');  
        b_hay_dato := TRUE;
        FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS
        DELETE FROM mig_ctacoaseguro WHERE mig_pk = l_reg_mig_mcc(i).mig_pk;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_ctacoaseguro VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);   
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','07_mig_ctacoaseguro','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_ctacoaseguro%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_ctacoaseguro;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_ctacoaseguro;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_ctacoaseguro.');
    RETURN 0;
  END f_migra_mig_ctacoaseguro;
  -------------------------------------------------------------
  --f_carga_mig_ctacoaseguro
  -------------------------------------------------------------
  FUNCTION f_carga_mig_ctacoaseguro RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_ctacoaseguro';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_ctacoaseguro';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17481;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;

    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COACUADRO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    
    vncarga := 17482;
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_COACEDIDO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga) + nresult;
    COMMIT;
    
    vncarga := 17483;
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_CTACOASEGURO_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga) + nresult;
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_ctacoaseguro;
  -------------------------------------------------------------
  --f_migra_mig_datsarlaft
  -------------------------------------------------------------
  FUNCTION f_migra_mig_datsarlaft RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_migra_mig_datsarlaft';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_migra_mig_datsarlaft';
    resultado  number := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
    vdummy            NUMBER;
    v_limit_records   NUMBER := 10000; -- limit to 10k to avoid out of memory
    --
    vlinea            VARCHAR2(2000);
    v_agente_padre    NUMBER := 19000; -- agente raiz 
    v_agente_pervisio NUMBER := 19000; -- agente vision personas por defecto si no viene informado
    b_error           BOOLEAN;
    b_hay_dato        BOOLEAN;
    v_cant            NUMBER := 0;
    --
    TYPE t_mig_datsarlaft IS TABLE OF mig_datsarlaft%ROWTYPE;
    l_reg_mig_mcc t_mig_datsarlaft;
    --
    CURSOR lc_mig_datsarlaft IS
    SELECT  17484 ncarga, 1 cestmig, s.mig_pk, s.mig_fk, 0 ssarlaft,
         s.fradica, p.idperson sperson, s.fdiligencia, s.cauttradat,
         s.crutfcc, s.cestconf, s.fconfir, s.cvinculacion, s.cvintomase,
         s.tvintomase, s.cvintomben, s.tvintombem, s.cvinaseben, s.tvinasebem,
         s.tactippal, s.nciiuppal, s.tocupacion, s.tcargo, s.tempresa,
         s.tdirempresa, s.ttelempresa, s.tactisec, s.nciiusec, s.tdirsec,
         s.ttelsec, s.tprodservcom, s.iingresos, s.iactivos, s.ipatrimonio,
         s.iegresos, s.ipasivos, s.iotroingreso, s.tconcotring, s.cmanrecpub,
         s.cpodpub, s.crecpub, s.cvinperpub, s.tvinperpub, s.cdectribext,
         s.tdectribext, s.torigfond, s.ctraxmodext, s.ttraxmodext,
         s.cprodfinext, s.cctamodext, s.totrasoper, s.creclindseg,
         s.tciudadsuc, s.tpaisuc, s.tciudad, s.tpais, s.tlugarexpedidoc,
         s.resociedad, s.tnacionali2, s.ngradopod, s.ngozrec, s.nparticipa,
         s.nvinculo, s.ntipdoc, s.fexpedicdoc, s.fnacimiento, s.nrazonso,
         s.tnit, s.tdv, s.toficinapri, s.ttelefono, s.tfax, s.tsucursal,
         s.ttelefonosuc, s.tfaxsuc, s.ctipoemp, s.tcualtemp, s.tsector,
         s.tciiu, s.tactiaca, s.trepresentanle, s.tsegape, s.tnombres,
         s.tnumdoc, s.tlugnaci, s.tnacionali1, s.tindiquevin, s.per_papellido,
         s.per_sapellido, s.per_nombres, s.per_tipdocument, s.per_document,
         s.per_fexpedicion, s.per_lugexpedicion, s.per_fnacimi,
         s.per_lugnacimi, s.per_nacion1, s.per_direreci, s.per_pais,
         s.per_ciudad, s.per_departament, s.per_email, s.per_telefono,
         s.per_celular, s.nrecpub, s.tpresetreclamaci, s.per_tlugexpedicion,
         s.per_tlugnacimi, s.per_tnacion1, s.per_tnacion2, s.per_tpais,
         s.per_tdepartament, s.per_tciudad, s.emptpais, s.emptdepatamento,
         s.emptciudad, s.emptpaisuc, s.emptdepatamentosuc, s.emptciudadsuc,
         s.emptlugnaci, s.emptnacionali1, s.emptnacionali2,
         s.csujetooblifacion, s.falta, s.cusualt
    FROM mig_datsarlaft_uat s, mig_personas p
    WHERE s.mig_fk = p.mig_pk 
    AND p.idperson <> 0
    --ORDER BY s.mig_pk
        ;
    dml_errors EXCEPTION;
    PRAGMA EXCEPTION_INIT(dml_errors, -24381);
    l_errors  NUMBER;
    l_errno   NUMBER;
    l_msg     VARCHAR2(4000);
    l_idx     NUMBER;
    --
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    b_error    := FALSE;
    b_hay_dato := FALSE;

    OPEN lc_mig_datsarlaft;
      LOOP
      FETCH lc_mig_datsarlaft BULK COLLECT INTO l_reg_mig_mcc ;--LIMIT v_limit_records;
        --dbms_output.put_line('I - paso bullk');
        --dbms_output.put_line('...');
        b_hay_dato := TRUE;
        BEGIN
          FORALL i IN 1..l_reg_mig_mcc.COUNT SAVE EXCEPTIONS    
            INSERT INTO mig_datsarlaft VALUES l_reg_mig_mcc(i);
        EXCEPTION
          WHEN DML_ERRORS THEN
            l_errors := SQL%bulk_exceptions.count;
            --dbms_output.put_line('l_errors:'||l_errors);
            FOR i IN 1 .. l_errors LOOP
              l_errno := SQL%BULK_EXCEPTIONS(i).error_code;
              l_msg   := SQLERRM(-l_errno);
              l_idx   := SQL%BULK_EXCEPTIONS(i).error_index;
              p_control_error('CXHGOME','01_mig_datsarlaft','['||l_idx||']: '||l_errno||' - '||l_msg||'. PK: '||l_reg_mig_mcc(l_idx).mig_pk);
            END LOOP;
        END;
        --dbms_output.put_line('F - paso bullk');
        EXIT WHEN lc_mig_datsarlaft%NOTFOUND;
      END LOOP;
    CLOSE lc_mig_datsarlaft;
    
    SELECT COUNT(*)
    INTO   num_reg
    FROM   mig_datsarlaft;
    
    num_err := PAC_MIG_AXIS_CONF.f_ins_mig_logs_axis(20100, 'MIGRACION','I','Se insertaron '||num_reg||' registros en mig_datsarlaft.');
    RETURN 0;
  END f_migra_mig_datsarlaft;
  -------------------------------------------------------------
  --f_carga_mig_datsarlaft
  -------------------------------------------------------------
  FUNCTION f_carga_mig_datsarlaft RETURN NUMBER IS
    vobject           VARCHAR2(200) := 'pac_migracion.f_carga_mig_datsarlaft';
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'f_carga_mig_datsarlaft';
    resultado  number := 0;
    --
    vdummy            NUMBER;
    vncarga           mig_cargas.ncarga%TYPE := 17484;
    v_nerr            NUMBER;
    v_cant            NUMBER;
    v_seqlog          NUMBER := 0;
    --
    l_timestart       NUMBER;
    l_timeend         NUMBER;
    l_time            NUMBER;
  BEGIN
    --l_timestart := dbms_utility.get_time(); 
    DELETE FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    DELETE FROM mig_cargas_tab_axis s WHERE s.ncarga = vncarga;
    UPDATE mig_cargas_tab_mig s SET finides = NULL WHERE s.ncarga = vncarga;
    SELECT MAX(s.seqlog) INTO v_seqlog FROM mig_logs_axis s WHERE s.ncarga = vncarga;
    --dbms_output.put_line('- v_seqlog:'||NVL(v_seqlog, 0));
    SELECT pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(24, 'USER_BBDD'))
    INTO vdummy
    FROM dual;
    pac_mig_axis_conf.p_migra_cargas_def(pid     => 'MIG_DATSARLAFT_TXT',
                                     ptipo   => 'C',
                                     pncarga => vncarga);
    nresult := PAC_MIGRACION.f_valida_errores(vncarga);
    COMMIT;
    RETURN nresult;
  EXCEPTION
    WHEN OTHERS THEN
      p_tab_error(f_sysdate,
                  f_user,
                  vobject,
                  vpasexec,
                  vparam,
                  'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1000455; --Error no controlado.
  END f_carga_mig_datsarlaft;
  
  FUNCTION f_valida_errores(vncarga IN mig_cargas.ncarga%TYPE) RETURN NUMBER IS
    nresult    NUMBER;
  BEGIN
    SELECT COUNT(*)
    INTO   nresult
    FROM   MIG_LOGS_AXIS
    WHERE  ncarga = vncarga
    AND    tipo = 'E';
    
    RETURN nresult;
  END f_valida_errores;
END pac_migracion;
/