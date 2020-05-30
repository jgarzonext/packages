CREATE OR REPLACE PACKAGE PAC_CARGAS_CONF AS
   /*******************************************************************************
   NOMBRE:       PAC_CARGAS_CONF
   PROPSITO: Fichero carga agentes masiva a campaa
   REVISIONES:
   Ver        Fecha        Autor             Descripcin
   ---------  ----------  ----------  ------------------------------------
   1.0        17/06/2016   AP         1. Creacin del package.
   2.0        07/02/2019   CJMR       2. TCS-343: Lista restringida por Ley de insolvencia
   3.0        28/02/2019   DFR        3. IAXIS-2418: Carga de archivo de campaas de agentes
   4.0        11/03/2019   DFR        4. IAXIS-2016: Scoring
   5.0        17/04/2019   SGM        5. IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
   6.0        19/04/2019   Swapnil    6. Cambios de IAXIS-3562 
   7.0        19/04/2019   SGM        7. IAXIS-3641 CARGUE DE ARCHIVO DE PROVEEDORES
   8.0        20/05/2019   SGM        8. IAXIS-3482 ACUERDOS DE PAGO     
   9.0        05/09/2019   SGM        9. IAXIS-4511 CONCILIACION DE CARTERA 
  10.0        09/09/2019   JLTS       10. IAXIS-5154. Ajute a la funcin f_finleco y f_carga_finleco y se comentarizan
                                          las dems que no se utilizan
  11.0        06/11/2019   CJMR       11. IAXIS-4834. Cargue masivo marcas de Grupos Económicos
  12.0        28/10/2019   CJMR       12. IAXIS-5422. Nota Beneficiario adicional
   ******************************************************************************/
   /* TODO enter PACKAGE declarations (types, exceptions, methods etc) here */
   e_param_error  EXCEPTION;
   e_object_error EXCEPTION;
   e_rename_error EXCEPTION;
   e_format_error EXCEPTION;
   e_errdatos     EXCEPTION;
   k_empresaaxis CONSTANT empresas.cempres%TYPE
                      := NVL(pac_md_common.f_get_cxtempresa, f_parinstalacion_n('EMPRESADEF'));
   k_idiomaaaxis CONSTANT per_detper.cidioma%TYPE
              := pac_parametros.f_parempresa_n(f_parinstalacion_n('EMPRESADEF'), 'IDIOMA_DEF');
   k_paisdefaxis CONSTANT provincias.cpais%TYPE := f_parinstalacion_n('PAIS_DEF');
   k_para_carga   cfg_files.cpara_error%TYPE;
   kidiomaaaxis   NUMBER := pac_md_common.f_get_cxtidioma;
   kempresa       NUMBER := pac_md_common.f_get_cxtempresa;

/*************************************************************************
FUNCTION f_campana_ejecutarcarga
*************************************************************************/
   FUNCTION f_campana_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_campana_ejecutarcargafichero
   *************************************************************************/
   FUNCTION f_campana_ejecutarcargafichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;
   --
   -- Inicio IAXIS-2418 28/02/2019
   --
   /*************************************************************************
   FUNCTION f_campana_ejecutarproceso
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_campana_ejecutarproceso(p_sproces IN NUMBER)
      RETURN NUMBER;
   --
   -- Fin IAXIS-2418 28/02/2019
   --
   /*************************************************************************
   FUNCTION f_carga_informa_colombia
   *************************************************************************/
   /* --INI -IAXIS-51545 - JLTS - 04/09/2019
     FUNCTION f_carga_informa_colombia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
      --FIN -IAXIS-51545 - JLTS - 04/09/2019*/

/*************************************************************************
FUNCTION f_informa_colombia
*************************************************************************/
   /* --INI -IAXIS-51545 - JLTS - 04/09/2019
     FUNCTION f_informa_colombia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
    --FIN -IAXIS-51545 - JLTS - 04/09/2019  
      */

  /*************************************************************************
   FUNCTION f_carga_supersociedades
   *************************************************************************/
   /* --INI -IAXIS-51545 - JLTS - 04/09/2019
    FUNCTION f_carga_supersociedades(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;
     --FIN -IAXIS-51545 - JLTS - 04/09/2019
      */

  /*************************************************************************
    FUNCTION supersociedades
    *************************************************************************/
   /* --INI -IAXIS-51545 - JLTS - 04/09/2019
    FUNCTION f_supersociedades(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
      --FIN -IAXIS-51545 - JLTS - 04/09/2019
      */


   /*************************************************************************
   FUNCTION f_carga_finleco
   *************************************************************************/
   FUNCTION f_carga_finleco(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

  /*************************************************************************
    FUNCTION f_finleco
    *************************************************************************/
   FUNCTION f_finleco(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN VARCHAR2,
      psproces IN OUT NUMBER)
      RETURN NUMBER;


--AAC_INI-CONF_OUTSOURCING-20160906
   FUNCTION f_carga_gescar(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_carga_gescar_agen(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      p_sproces IN OUT NUMBER)
      RETURN NUMBER;

   --AAC_FI-CONF_OUTSOURCING-20160906

   --AAC_INI-CONF_379-20160927
   FUNCTION f_modi_tabla_corte_fac(p_nombre VARCHAR2, p_path IN VARCHAR2, p_cproceso VARCHAR2)
      RETURN NUMBER;

   PROCEDURE p_trasp_tabla_corte_fac(
      p_sproces IN VARCHAR2,
      p_cproceso IN VARCHAR2,
      p_deserror IN OUT VARCHAR2);

   FUNCTION f_liquidar_carga_corte_fac(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ejecutar_carga_corte_fac(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_personas_a_sap(psperson IN NUMBER, psseguro IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_nliqmen(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pfecliq IN DATE,
      psproces IN NUMBER,
      pmodo IN NUMBER,
      pcliquido IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_liquidar_carga_cortepro_fac(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER;

   --AAC_FI-CONF_379-20160927

   --CONF 239 JAVENDANO
   /*************************************************************************
   FUNCTION f_lre_ejecutarcarga
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_lre_ejecutarfichero
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_lre_ejecutarfichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_lre_ejecutarproceso
   Ejecurta la carga del archivo de listas restrictivas
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_lre_ejecutarproceso(p_sproces IN NUMBER)
      RETURN NUMBER;

   --CONF 239 JAVENDANO

   --CONF 247 OSUAREZ
/*************************************************************************
FUNCTION F_MODI_CIFIN_EXT
*************************************************************************/
   FUNCTION f_modi_cifin_ext(p_nombre VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_ejecutar_carga_fichero_cifin
   Ejecurta la carga del archivo de CIFIN
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_ejecutar_carga_fichero_cifin(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_cifin_ejecutarcarga
   Ejecurta la carga del archivo de CIFIN
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_cifin_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

 /*************************************************************************
FUNCTION F_PROCESO_CIFIN
*************************************************************************/
   FUNCTION f_proceso_cifin(psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER;

   -- CONF-247 OSUAREZ
   -- Inicio IAXIS-2016 11/03/2019
   /*************************************************************************
   FUNCTION f_eje_carga_score_canales
   *************************************************************************/
   FUNCTION f_eje_carga_score_canales(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
   -- Fin IAXIS-2016 11/03/2019
   /*************************************************************************
   FUNCTION f_eje_carga_score_tipo_per
   *************************************************************************/
   FUNCTION f_eje_carga_score_tipo_per(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
   -- Inicio IAXIS-2016 11/03/2019
   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_cana
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_cana(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;
   -- Fin IAXIS-2016 11/03/2019
   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_tp
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_tp(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_score_act_economic
    *************************************************************************/
   FUNCTION f_eje_carga_score_act_economic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_tp
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_ac(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_score_producto
    *************************************************************************/
   FUNCTION f_eje_carga_score_producto(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_prod
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_prod(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_score_corrupcion
    *************************************************************************/
   FUNCTION f_eje_carga_score_corrupcion(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_corr
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_corr(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_score_paises
    *************************************************************************/
   FUNCTION f_eje_carga_score_paises(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_pais
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_pais(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_score_poblaciones
    *************************************************************************/
   FUNCTION f_eje_carga_score_poblaciones(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION f_eje_carga_fichero_score_pobl
    *************************************************************************/
   FUNCTION f_eje_carga_fichero_score_pobl(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

FUNCTION f_conccar_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ejecutar_carga_fichero(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_modi_tabla_ext(p_nombre VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_modi_tabla_extsap(p_nombre VARCHAR2, p_path IN VARCHAR2)
      RETURN NUMBER;      

   FUNCTION f_trasp_tabla(pdeserror OUT VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_carga_ctrl_cabecera(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_carga_generica(psproces IN NUMBER, p_nombre IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_conciliacion(
      ptiporeturn IN VARCHAR2,
      pnpoliza IN VARCHAR2,--IAXIS 4060 SGM SE VALIDA POLIZA
      precibo IN VARCHAR2,
      psaldo IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_conccar_ejecutarcargasap(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ejecutar_carga_ficherosap(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER,
      pjob IN NUMBER DEFAULT 0,
      pcusuari IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_trasp_tablasap(pdeserror OUT VARCHAR2, psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_carga_genericasap(psproces IN NUMBER, p_nombre IN VARCHAR2,  p_path IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_conciliacionsap(
      ptiporeturn IN VARCHAR2,
      pseguro IN VARCHAR2,
      precibo IN VARCHAR2,
      psaldo IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_set_carga_ctrl_cabecerasap(
      psproces IN NUMBER,
      ptfichero IN VARCHAR2,
      pfini IN DATE,
      pffin IN DATE,
      pcestado IN NUMBER,
      pcproceso IN NUMBER,
      pcerror IN NUMBER,
      pterror IN VARCHAR2,
      pcbloqueo IN NUMBER DEFAULT 0)
      RETURN NUMBER;
   FUNCTION f_get_datos_recibo_t(ptipo IN NUMBER, pnrecibo IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION f_get_datos_recibo_n(ptipo IN NUMBER, pnrecibo IN VARCHAR2)
      RETURN NUMBER;
   FUNCTION f_validar_registro_repetido( pnrecibo IN VARCHAR2, pnpoliza IN VARCHAR2, pitotalr IN VARCHAR2, psproces NUMBER, pnlinea NUMBER)
      RETURN NUMBER;      
--INI 05/09/2019   SGM IAXIS-4511 CONCILIACION DE CARTERA
--SE AGREGAN ESTAS FUNCIONES PARA CARGAR LA INFO POR POLIZA EN EL DETALLE DE CONCILIACION
   FUNCTION f_get_datos_poliza_t(ptipo IN NUMBER, pnpoliza IN VARCHAR2)
      RETURN VARCHAR2;
   FUNCTION f_get_datos_poliza_n(ptipo IN NUMBER, pnpoliza IN VARCHAR2)
      RETURN NUMBER;      
--INI 05/09/2019   SGM IAXIS-4511 CONCILIACION DE CARTERA
   -- TCS-343 CJMR INI
   /*************************************************************************
   FUNCTION f_lre_carga_insolvencia
   Ejecurta la carga del archivo de listas restrictivas por ley de insolvencia
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_carga_insolvencia(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_lre_insolv_ejecutaproceso
   Ejecurta la carga del archivo de listas restrictivas por ley de insolvencia
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_lre_insolv_ejecutaproceso(p_sproces IN NUMBER)
      RETURN NUMBER;
   -- TCS-343 CJMR FIN

  /******************************************************************************
    NOMBRE:     p_setPersona_Cargar_CIFIN
    PROPOSITO:  Este funcion crear y actaulizar persona en iAxis caundo cargar archivo de CIFIN.
    PARAMETROS:
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
  *****************************************************************************/

   PROCEDURE p_setPersona_Cargar_CIFIN(pRuta in varchar2,
                                       p_nombre in varchar2,
                                       p_cproces in number,
                                       p_sproces in number,
                                       pCountFail out number,
                                       pCountSuccess out number,
                                       perror  out number
                                      );
-- SGM 17/04/2019  IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR
/*************************************************************************
FUNCTION f_leearchivos_acuerdo
Funcion para cargar masivamente los acuerdos de pago
*************************************************************************/
   FUNCTION f_leearchivos_acuerdo
      RETURN NUMBER;
/*************************************************************************
FUNCTION f_anota_acuerdopag_carga
    PROPOSITO:  Funcion para cargar anotaciones de acuerdos de pago masivamente
    PARAMETROS:
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
*************************************************************************/
   FUNCTION f_anota_acuerdopag_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_anota_acuerdopag_cargafic
   *************************************************************************/
   FUNCTION f_anota_acuerdopag_cargafic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_anota_acuerdopag_ejecproc
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_anota_acuerdopag_ejecproc(p_sproces IN NUMBER)
      RETURN NUMBER;      
-- FIN SGM 17/04/2019  IAXIS 3482 PODER INGRESAR ACUERDOS DE PAGO, MASIVAMENTE Y TRAZAR


/* Cambios de IAXIS-3562 : Start*/

  FUNCTION F_PROCESO_DATSARLAF(PSPROCES IN NUMBER, P_CPROCES IN NUMBER)
    RETURN NUMBER;

  FUNCTION F_CARGA_DATSARLAF_J(P_NOMBRE  IN VARCHAR2,
                               P_PATH    IN VARCHAR2,
                               P_CPROCES IN NUMBER,
                               PSPROCES  IN OUT NUMBER)
                               RETURN NUMBER;    

  FUNCTION F_MODI_DATSARLAF_J_EXT(P_NOMBRE VARCHAR2) 
                                  RETURN NUMBER;

  PROCEDURE P_TRASP_TABLA_DS_J(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER);

  FUNCTION F_EJECUTAR_CARGA_DATASARLAF_J(P_NOMBRE  IN VARCHAR2,
                                         P_PATH    IN VARCHAR2,
                                         P_CPROCES IN NUMBER,
                                         PSPROCES  OUT NUMBER)
                                         RETURN NUMBER;

  PROCEDURE P_CARGA_DATSARLAF_J(PRUTA         IN VARCHAR2,
                                P_NOMBRE      IN VARCHAR2,
                                P_CPROCES     IN NUMBER,
                                P_SPROCES     IN NUMBER,
                                PCOUNTFAIL    OUT NUMBER,
                                PCOUNTSUCCESS OUT NUMBER,
                                PERROR        OUT NUMBER);

  FUNCTION F_CARGA_DATSARLAF_N(P_NOMBRE  IN VARCHAR2,
                               P_PATH    IN VARCHAR2,
                               P_CPROCES IN NUMBER,
                               PSPROCES  IN OUT NUMBER)
                               RETURN NUMBER;

  FUNCTION F_MODI_DATSARLAF_N_EXT(P_NOMBRE VARCHAR2) 
                                  RETURN NUMBER;

  PROCEDURE P_TRASP_TABLA_DS_N(PDESERROR OUT VARCHAR2, PSPROCES IN NUMBER);

  FUNCTION F_EJECUTAR_CARGA_DATASARLAF_N(P_NOMBRE  IN VARCHAR2,
                                         P_PATH    IN VARCHAR2,
                                         P_CPROCES IN NUMBER,
                                         PSPROCES  OUT NUMBER)
                                         RETURN NUMBER;

  PROCEDURE P_CARGA_DATSARLAF_N(PRUTA         IN VARCHAR2,
                                P_NOMBRE      IN VARCHAR2,
                                P_CPROCES     IN NUMBER,
                                P_SPROCES     IN NUMBER,
                                PCOUNTFAIL    OUT NUMBER,
                                PCOUNTSUCCESS OUT NUMBER,
                                PERROR        OUT NUMBER);                                                                           
 /* Cambios de IAXIS-3562 : End */    
--INI SGM IAXIS 3641 CARGUE DE ARCHIVO DE PROVEEDORES
/*************************************************************************
FUNCTION f_anota_gescartera_carga
Funcion para cargar la gestion de los outsourcing
*************************************************************************/
   FUNCTION f_anota_leearchivos_carga
      RETURN NUMBER;
/*************************************************************************
FUNCTION f_anota_gescartera_carga
Funcion para cargar la gestion de los outsourcing
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
*************************************************************************/
   FUNCTION f_anota_gescartera_carga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER; 

   /*************************************************************************
   FUNCTION f_anota_gescartera_cargafic
   *************************************************************************/
   FUNCTION f_anota_gescartera_cargafic(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_anota_gescartera_ejecproc
   Ejecuta la carga del archivo de campaas de agentes
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_anota_gescartera_ejecproc(p_sproces IN NUMBER)
      RETURN NUMBER;          
--FIN SGM IAXIS 3641 CARGUE DE ARCHIVO DE PROVEEDORES
   -- INI IAXIS-4834 CJMR 06/11/2019
   /*************************************************************************
   FUNCTION f_lre_carga_gruposeconomicos
   Ejecurta la carga del archivo de Grupos Ecónomicos
   Retorna 0 Ok <> 0 Error
   *************************************************************************/
   FUNCTION f_lre_carga_gruposeconomicos(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
   
   /*************************************************************************
   FUNCTION f_lre_grpeco_ejecutaproceso
   Ejecurta la carga del archivo de listas restrictivas para grupos económicos
   Retorna 1- Error, 2- correcto
   *************************************************************************/
   FUNCTION f_lre_grpeco_ejecutaproceso(p_sproces IN NUMBER)
      RETURN NUMBER;
   -- FIN IAXIS-4834 CJMR 06/11/2019
   
   -- INI IAXIS-5422 CJMR 28/10/2019
   /*************************************************************************
   -- INI IAXIS-7629 JRVG 07/02/2020
   FUNCTION f_vidagrupo_ejecutarcarga
   Ejecurta la carga del archivo de CIFIN
   Retorna 1- Error, 2- correcto , 3- pendiente, 4- con avisos
   *************************************************************************/
   FUNCTION f_vidagrupo_ejecutarcarga(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,
      psproces IN OUT NUMBER)
      RETURN NUMBER;
     
  /*************************************************************************/
   FUNCTION f_modi_vidagrupo_ext(p_nombre VARCHAR2)
      RETURN NUMBER;
      
   FUNCTION f_ejecutar_carga_fichero_vg(
      p_nombre IN VARCHAR2,
      p_path IN VARCHAR2,
      p_cproces IN NUMBER,   
      psproces OUT NUMBER)
      RETURN NUMBER;
      
    FUNCTION f_proceso_vidagrupo(psproces IN NUMBER, p_cproces IN NUMBER)RETURN NUMBER;
   
   /******************************************************************************
    NOMBRE:     p_setPersona_Cargar_Vg
    PROPOSITO:  Esta función crea y actualiza una persona en iAxis cuando carga archivo de VIDAGRUPO.
    PARAMETROS:
         return            : 0 -> Todo correcto
                             1 -> Se ha producido un error
  *****************************************************************************/

   PROCEDURE p_setPersona_Cargar_Vg(pRuta in varchar2,
                                       p_nombre in varchar2,
                                       p_cproces in number,
                                       p_sproces in number,
                                       pCountFail out number,
                                       pCountSuccess out number,
                                       perror  out number
                                      );

  -- FIN IAXIS-7629 JRVG 07/02/2020
  /*************************************************************************/
  
  -- IAXIS-13317 JRVG 31/03/2020
    FUNCTION f_proceso_cargasap(psproces IN NUMBER, p_cproces IN NUMBER)RETURN NUMBER;
  
  -- IAXIS-5241 JRVG 14/04/2020
    procedure  p_update_cgescar(psproces in number);

END pac_cargas_conf;
/
