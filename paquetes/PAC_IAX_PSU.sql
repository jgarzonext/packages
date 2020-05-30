--------------------------------------------------------
--  DDL for Package PAC_IAX_PSU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PSU" IS
   /******************************************************************************
       NOMBRE    : PAC_IAX_PSU
       ARCHIVO   : PAC_IAX_PSU.PKS
       PROP真SITO : Package con funciones propias de la funcionalidad de
                   Pol真tica de Subscripci真n, per gestionar els controls.

       REVISIONES:
       Ver    Fecha      Autor     Descripci真n
       ------ ---------- ------ ------------------------------------------------
       1.0    01/07/2009 NMM    Creaci真 del package.
       2.0    19/07/2010 PFA    15459: MDP003 - PSU-MDP Controls rebutjables i visibilitat
       3.0    12/02/2014 JDS    0029991: LCOL_T010-Revision incidencias qtracker (2014/02)
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   wg_t_psus      t_iax_psu;

   FUNCTION f_inicia_psu(
      p_tablas IN VARCHAR2,
      p_sseguro IN NUMBER,
      p_accion IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION f_get_consulta(
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_nsolici IN NUMBER,
      p_cautrec IN NUMBER,
      p_mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*****************************************************************************
     Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
     la capa intermitja PAC_MD_PSU.F_LEE_CONTROLES.

     param in      : P_SSEGURO  Codi asseguran真a.
     param in out  : P_MENSAJES Missatges de sortida.
    *****************************************************************************/
   FUNCTION f_lee_controles(p_sseguro IN NUMBER, p_mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*****************************************************************************
     Graba les observacions del control sel真leccionat, cridar真 la funci真 de
     la capa intermitja PAC_MD_PSU.F_GRABAOBSERVACIONES.

     param in      : P_SSEGURO  Codi asseguran真a.
     param in      : P_NRIESGO  Nombre risc.
     param in      : P_CGARANT  Codi de la garantia.
     param in      : P_CCONTROL Codi de control.
     param in      : P_TOBSERV  Observacions.
     param in      : P_TOBSERV  Missatges de sortida.

     Retorna 0 -> OK o b真 1 -> NOTOK.
    *****************************************************************************/
   FUNCTION f_grabaobservaciones(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tobserv IN VARCHAR2,
      p_mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_get_colec_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_tablas IN VARCHAR2 DEFAULT NULL,
      p_testpol OUT VARCHAR2,
      p_cestpol OUT NUMBER,
      p_cnivelbpm OUT NUMBER,
      p_tnivelbpm OUT VARCHAR2,
      pobpsu_retenidas OUT ob_iax_psu_retenidas,
      p_tpsus OUT t_iax_psu,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-----------------------------------------------------------------------------
   FUNCTION f_get_det_psu(
      p_sseguro IN seguros.sseguro%TYPE,
      p_nmovimi IN movseguro.nmovimi%TYPE,
      p_nriesgo IN riesgos.nriesgo%TYPE,
      p_cgarant IN NUMBER,
      p_ccontrol IN NUMBER,
      p_tablas IN VARCHAR2,
      p_tpsus OUT ob_iax_psu,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstniveles(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_nivel_usuario(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      p_nivel OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*Miraremos si hay controles manuales pendientes de autorizar,
   en caso de que hay devolveremos mensaje diciendo que no podemos autorizar/rechazar y se deberan
   tratar individualmente manualmente*/
   FUNCTION f_hay_controles_manuales(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/
   FUNCTION F_LEE_HIS_PSU_RETENIDAS ( -- ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_this_psu_retenidas OUT T_IAX_PSU_RETENIDAS,
		MENSAJES OUT T_IAX_MENSAJES)
    Return	NUMBER;      -- ramiro



/*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/


FUNCTION F_LEE_HIS_PSUCONTROLSEG( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nriesgo IN NUMBER,
		p_nmovimi IN NUMBER,
		p_ccontrol IN NUMBER,
		P_THIS_PSUCONTROLSEG OUT T_IAX_PSU,
		mensajes  OUT t_iax_mensajes --ramiro
)
    return number;


/*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/

FUNCTION F_LEE_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nversionsubest IN NUMBER,
		P_NMOVIMI IN NUMBER,
		P_TPSU_SUBESTADOSPROP OUT T_IAX_PSU_SUBESTADOSPROP,
    mensajes  OUT t_iax_mensajes

)
    return number; --ramiro


/*****************************************************************************
        Recupera la llista de p真lisses amb controls de PSU, cridar真 la funci真 de
        la capa intermitja PAC_MD_PSU.F_GET_CONSULTA.

        param in      : P_SPRODUC  Codi producte.
        param in      : P_NPOLIZA  Nombre de p真lissa.
        param in      : P_NSOLICI  Nombre de sol真licitud.
        param in      : P_CAUTREC  Codi estat del control.
        param in out  : P_MENSAJES Missatges de sortida.
   *****************************************************************************/


FUNCTION F_INS_PSU_SUBESTADOSPROP( --ramiro
    p_sseguro IN NUMBER,
		p_nversion IN NUMBER,
		p_nmovimi IN NUMBER,
		P_CSUBESTADO IN NUMBER,
		p_cobservaciones IN VARCHAR2,
		mensajes OUT t_iax_mensajes
)
    return number;        --ramiro

END pac_iax_psu;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PSU" TO "PROGRAMADORESCSI";
