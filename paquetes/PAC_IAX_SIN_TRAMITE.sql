--------------------------------------------------------
--  DDL for Package PAC_IAX_SIN_TRAMITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_SIN_TRAMITE" AS
   /******************************************************************************
      NOMBRE:       PAC_IAX_SIN_TRAMITE
      PROPÓSITO: Funciones para el alta de trámites

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        27/04/2011   JMP      1. Creación del package.
      2.0        16/05/2012   JMF      0022099: MDP_S001-SIN - Trámite de asistencia
   ******************************************************************************/

   /*************************************************************************
         F_SET_OBJ_SINTRAMITE
      Traspasa los valores de los parámetros a los atributos del objeto global
      PAC_IAX_SINIESTROS.VGOBSINIESTRO.TRAMITES.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pctramte                : código de trámite
      param out t_iax_mensajes         : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_sintramite(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pctramte IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         F_GET_CODTRAMITE
      Obtiene un cursor con los diferentes códigos de trámites definidos.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param out t_iax_mensajes         : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_codtramite(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         F_GET_OBJ_TRAMITE
      Dado un número de trámite, obtiene la información correspondiente a ese
      trámite del objeto global PAC_IAX_SINIESTROS.VGOBSINIESTRO y la devuelve
      en un objeto OB_IAX_SIN_TRAMITE.
      Además, obtiene todas las tramitaciones correspondientes al trámite y las
      devuelve en un objeto T_IAX_SIN_TRAMITACION.
      param in pntramte                : número de trámite
      param out t_iax_sin_tramitacion  : colección de tramitaciones
      param out t_iax_mensajes         : mensajes de error
      return                           : el objeto OB_IAX_SIN_TRAMITE
   *************************************************************************/
   FUNCTION f_get_obj_tramite(
      pntramte IN NUMBER,
      ptramitaciones OUT t_iax_sin_tramitacion,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_sin_tramite;

/*************************************************************************
         F_SET_OBJ_IAX_SIN_TRAMITE_RECOBRO
      Traspasa los valores de los parámetros a los atributos del objeto global

                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_iax_sin_recobro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pfprescrip IN DATE,
      pireclamt IN NUMBER,
      pirecobt IN NUMBER,
      piconcurr IN NUMBER,
      pircivil IN NUMBER,
      piassegur IN NUMBER,
      pcresrecob IN NUMBER,
      pcdestim IN NUMBER,
      pnrefges IN NUMBER,
      pctiprec IN NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_obj_iax_sin_lesiones(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pnlesiones NUMBER,
      pnmuertos NUMBER,
      pagravantes VARCHAR2,
      pcgradoresp NUMBER,
      pctiplesiones NUMBER,
      pctiphos NUMBER,
      pmensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_hay_tramites(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      phay_tramites OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCION
      Traspasa los valores de sin_tramite_asistencia
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in trefext                 : Referencia Externa
      param in cciaasis                : Compañía de asistencia VF=XXX
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_asist(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptrefext IN VARCHAR2,
      pcciaasis IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      FUNCTION f_estado_tramite:
       Cambia el estado de un tramite
       param in pnsinies : Número siniestro
       param in pntramit : Número tramitación
       param in pcesttra : Código estado
       param  out  mensajes : Mensajes de error
       return            : 0 -> Tot correcte
                           1 -> S'ha produit un error
       -- Bug 0022108 - 19/06/2012 - JMF
    ***********************************************************************/
   FUNCTION f_estado_tramite(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies  : codi del sinistre
         param out pntramit  : Numero de tramitaci
         param out t_iax_mensajes      : mensajes de error
         return              : Error (0 -> Tot correcte, codi error)

      Bug 22325/115249- 07/06/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_tramite9999(
      pnsinies IN NUMBER,
      pntramit OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera los datos de un determinado personas relacionadas
      param in  pnsinies  : número de siniestro
      param in  pntramit  : número de tramitación
      param in  pnpersrel  : número de linea de spersrel
      param out  ob_iax_sin_trami_personarel :  ob_iax_sin_trami_personarel
      param out mensajes  : mensajes de error
      return              : 0 OK
                            1 Error

   ***********************************************************************/
   FUNCTION f_get_lista_personasrel(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plistapersrel OUT t_iax_sin_trami_personarel,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_ini_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden  IN NUMBER,
      proceso  OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_get_procesos_judiciales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

  FUNCTION f_get_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objudicial OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_judicial(
      PNSINIES IN VARCHAR2,
      PNTRAMIT IN NUMBER,
      PNORDEN IN NUMBER,
      PCPROCESO IN NUMBER,
      PTPROCESO IN NUMBER,
      PCPOSTAL IN VARCHAR2,
      PCPOBLAC IN NUMBER,
      PCPROVIN IN NUMBER,
      PTIEXTERNO IN VARCHAR2,
      PSPROFES IN NUMBER,
      PFRECEP IN DATE,
      PFNOTIFI IN DATE,
      PFVENCIMI IN DATE,
      PFRESPUES IN DATE,
      PFCONCIL IN DATE,
      PFDESVIN IN DATE,
      PTPRETEN IN VARCHAR2,
      PTEXCEP1 IN VARCHAR2,
      PTEXCEP2 IN VARCHAR2,
      PCCONTI IN NUMBER,
      PCDESPA IN NUMBER,
      PCDESCF IN VARCHAR2,
      PCPROVINF IN NUMBER,
      PCPOBLACF IN NUMBER,
      PCDESPAO IN NUMBER,
      PCDESCO IN VARCHAR2,
      PCPROVINO IN NUMBER,
      PCPOBLACO IN NUMBER,
      PCPOSICI IN NUMBER,
      PCDEMAND IN NUMBER,
      PSAPODERA IN NUMBER,
      PIDEMAND IN NUMBER,
      PFTDEMAN IN DATE,
      PICONDEN IN NUMBER,
      PCSENTEN IN NUMBER,
      PFSENTE1 IN DATE,
      PCSENTEN2 IN NUMBER,
      PFSENTE2 IN DATE,
      PCASACION IN NUMBER,
      PFCASACI IN DATE,
      PCTSENTE IN NUMBER,
      PFTSENTE IN DATE,
      PVTSENTE IN VARCHAR2,
      PTFALLO IN VARCHAR2
    ,pcoralproc IN NUMBER
    ,punicainst IN NUMBER
    ,pfunicainst IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_judicial_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_judicial_detper(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnrol IN NUMBER,
      pnpersona IN NUMBER,
      pntipper IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      piimporte IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_traspasar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_validar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_elimina_dato_judicial(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

 FUNCTION f_get_tramite_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      audiencia OUT OB_IAX_SIN_T_JUDICIAL_AUDIEN,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      pfaudien IN DATE,
      phaudien IN VARCHAR2,
      ptaudien IN VARCHAR2,
      pcdespa IN NUMBER,
      ptlaudie IN VARCHAR2,
      pcaudien IN VARCHAR2,
      pcdespao IN NUMBER,
      ptlaudieo IN VARCHAR2,
      pcaudieno IN VARCHAR2,
      psabogau IN NUMBER,
      pcoral IN NUMBER,
      pcestado IN NUMBER,
      pcresolu IN NUMBER,
      pfinsta1 IN DATE,
      pfinsta2 IN DATE,
      pfnueva IN DATE,
      ptresult IN VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

 FUNCTION f_get_procesos_fiscales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

  FUNCTION f_get_obj_fiscal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objfiscal OUT OB_IAX_SIN_TRAMITA_FISCAL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_set_obj_fiscal(
      PNSINIES  IN   VARCHAR2,
      PNTRAMIT  IN   NUMBER,
      PNORDEN   IN   NUMBER,
      PFAPERTU  IN	DATE,
      PFIMPUTA  IN	DATE,
      PFNOTIFI  IN	DATE,
      PFAUDIEN  IN	DATE,
      PHAUDIEN  IN	VARCHAR2,
      PCAUDIEN  IN	NUMBER,
      PSPROFES  IN	NUMBER,
      PCOTERRI  IN	NUMBER,
      PCPROVIN  IN	NUMBER,
      PCCONTRA  IN	NUMBER,
      PCUESPEC  IN	NUMBER,
      PTCONTRA  IN	VARCHAR2,
      PCTIPTRA  IN	NUMBER,
      PTESTADO  IN	VARCHAR2,
      PCMEDIO   IN	NUMBER,
      PFDESCAR  IN	DATE,
      PFFALLO   IN   DATE,
      PCFALLO   IN   NUMBER,
      PTFALLO   IN   VARCHAR2,
      PCRECURSO IN   NUMBER,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_fiscal_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_elimina_dato_fiscal(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

END pac_iax_sin_tramite;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_SIN_TRAMITE" TO "PROGRAMADORESCSI";
