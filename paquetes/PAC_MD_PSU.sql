--------------------------------------------------------
--  DDL for Package PAC_MD_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PSU" IS
    /******************************************************************************
       NOMBRE    : PAC_IAX_PSU
       ARCHIVO   : PAC_IAX_PSU.PKS
       PROPÓSITO : Package con funciones propias de la funcionalidad de
                   Política de Subscripción, per gestionar els controls.

       REVISIONES:
       Ver    Fecha      Autor     Descripción
       ------ ---------- ------ ------------------------------------------------
       1.0    01/07/2009 NMM    Creació del package.
       2.0    19/07/2010 PFA    15459: MDP003 - PSU-MDP Controls rebutjables i visibilitat
       3.0    14/08/2013 RCL    3. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
   ******************************************************************************/
   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*****************************************************************************
        Recupera la llista de pòlisses amb controls de PSU, cridarà la funció de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de pòlissa.
        param in      : P_NSOLICI  Nombre de sol·licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_consulta(
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_nsolici IN NUMBER,
      p_cautrec IN NUMBER,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*****************************************************************************
     Recupera la llista de pòlisses amb controls de PSU, cridarà la funció de
     la capa intermitja PAC_MD_PSU.F_LEE_CONTROLES.

     param in      : P_SSEGURO  Codi assegurança.
     param in out  : P_MENSAJES Missatges de sortida.
    *****************************************************************************/
   FUNCTION f_lee_controles(p_sseguro IN NUMBER, p_mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*****************************************************************************
     Graba les observacions del control sel·leccionat, cridarà la funció de
     la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

     param in      : P_SSEGURO  Codi assegurança.
     param in      : P_NRIESGO  Nombre risc.
     param in      : P_CGARANT  Codi de la garantia.
     param in      : P_CCONTROL Codi de control.
     param in      : P_TOBSERV  Observacions.
     param in      : P_TOBSERV  Missatges de sortida.

     Retorna 0 -> OK o bé 1 -> NOTOK.
    *****************************************************************************/
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_idioma IN idiomas.cidioma%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2,
      pobpsu_retenidas OUT ob_iax_psu_retenidas,
      p_tpsus OUT t_iax_psu,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-----------------------------------------------------------------------------

   --
   /*****************************************************************************
      Gestiona el control sel·leccionat, cridarà la funció de
      la capa intermitja PAC_MD_PSU.F_AUTORIZA.

      param in      : P_SSEGURO  Codi assegurança.
      param in      : P_NRIESGO  Nombre risc.
      param in      : P_CGARANT  Codi de la garantia.
      param in      : P_CCONTROL Codi de control.
      param in      : P_TOBSERV  Observacions.
      param in      : P_TOBSERV  Missatges de sortida.

      Retorna 0 -> OK o bé 1 -> NOTOK.
     *****************************************************************************/
   FUNCTION f_gestion_control(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_cautrec IN NUMBER,
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstniveles(p_refcursor OUT sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_nivel_usuario(
      p_sseguro IN NUMBER,
      p_tablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

          /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_hay_controles_pendientes(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
   FUNCTION F_LEE_HIS_PSU_RETENIDAS( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
		MENSAJES IN OUT T_IAX_MENSAJES)
    return number;      --ramiro

/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
FUNCTION F_LEE_HIS_PSUCONTROLSEG( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_ccontrol IN NUMBER,
		p_cidioma IN NUMBER,
		p_this_psucontrolseg OUT T_IAX_PSU,
		mensajes IN OUT t_iax_mensajes
)
    return number; --ramiro


/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
   FUNCTION F_LEE_PSU_SUBESTADOSPROP( --ramiro
   p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		p_nmovimi IN NUMBER,
		p_cidioma IN NUMBER,
		p_tpsu_subestadosprop OUT T_IAX_PSU_SUBESTADOSPROP,
		mensajes IN OUT t_iax_mensajes
)
    return number;  --ramiro

/*****************************************************************************
 Graba les observacions del control sel·leccionat, cridarà la funció de
 la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

*****************************************************************************/
   FUNCTION F_INS_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nmovimi IN NUMBER,
		P_CSUBESTADO IN NUMBER,
		P_COBSERVACIONES IN VARCHAR2,
     mensajes IN OUT t_iax_mensajes
)
    return number;      --ramiro
END pac_md_psu;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PSU" TO "PROGRAMADORESCSI";
