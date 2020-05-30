--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_TRAMITE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_TRAMITE" AS
   /******************************************************************************
      NOMBRE:       PAC_MD_SIN_TRAMITE
      PROPÓSITO: Funciones para el alta de trámites

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  --------  ------------------------------------
      1.0        27/04/2011   JMP      1. Creación del package.
      2.0        16/05/2012   JMF      0022099: MDP_S001-SIN - Trámite de asistencia
      3.0        14/06/2012   JMF      0022108 MDP_S001-SIN - Movimiento de trámites
   ******************************************************************************/

   /*************************************************************************
         F_SET_OBJ_SINTRAMITE
      Traspasa los valores de los parámetros a los atributos del objeto OB_IAX_SIN_TRAMITE.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pctramte                : código de trámite
      param in out ptramite            : objeto ob_iax_sin_tramite
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_set_obj_sintramite(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pctramte IN NUMBER,
      ptramite IN OUT ob_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         F_SET_OBJ_SINTRAMITE_MOV
      Traspasa los valores de los parámetros a los atributos del objeto OB_IAX_SIN_TRAMITE_MOV.
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in pnmovtte                : número de movimiento trámite
      param in pcesttte                : código de estado trámite (VF.6)
      param in CCAUEST                 :  Causa cambio de estado
      param in CUNITRA                 : Código de unidad de tramitación
      param in CTRAMITAD               : Código de tramitador
      param in FESTTRA                 : Fecha estado trámite
      param in CUSUALT                 : Usuario de alta
      param in FALTA                   : Fecha de alta
      param in out ptmovstramite       : objeto ob_iax_sin_tramite_mov
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
      -- Bug 0022108 - 14/06/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_mov(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      pnmovtte IN NUMBER,
      pcesttte IN NUMBER,
      pccauest IN NUMBER,
      pcunitra IN VARCHAR2,
      pctramitad IN VARCHAR2,
      pfesttra IN DATE,
      pcusualt IN VARCHAR2,
      pfalta IN DATE,
      ptmovstramite IN OUT ob_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         F_INICIALIZA_TRAMITES
      Inicializa el objeto T_IAX_SIN_TRAMITES.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param in pnsinies                : número sde iniestro
      param in pctramte                : tramite especifico a crear (si esta informado)
      param in out pttramites          : objeto t_iax_sin_tramites
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
   *************************************************************************/
   FUNCTION f_inicializa_tramites(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnsinies IN VARCHAR2,
      pctramte IN NUMBER,
      pttramites IN OUT t_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         F_GET_CODTRAMITE
      Obtiene un cursor con los diferentes códigos de trámites definidos.
      param in psproduc                : código de producto
      param in pcactivi                : código de actividad
      param in out t_iax_mensajes      : mensajes de error
      return                           : el cursor
   *************************************************************************/
   FUNCTION f_get_codtramite(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       FUNCTION f_get_tramite
          Asigna valores a los atributos de un objeto OB_IAX_SIN_TRAMITE
          param in pnsinies       : numero del sinistre
          param in pntramte       : número de trámite
          param out ptramite      : ob_iax_sin_tramite
          param in out mensajes   : mensajes de error
          return                  : 0 -> Tot correcte
                                    1 -> S'ha produit un error
    *************************************************************************/
   FUNCTION f_get_tramite(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      ptramite OUT ob_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION f_get_tramites
          Devuelve una colección de objetos OB_IAX_SIN_TRAMITE de un siniestro
          determinado
          param in pnsinies         : numero del sinistre
          param out pttramites      : t_iax_sin_tramite
          param in out mensajes     : mensajes de error
          return                    : 0 -> Tot correcte
                                      1 -> S'ha produit un error
    *************************************************************************/
   FUNCTION f_get_tramites(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramites OUT t_iax_sin_tramite,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_get_tramite_mov
         Asigna valores a los atributos de un objeto OB_IAX_SIN_TRAMITE_MOV
         param in pnsinies       : numero del sinistre
         param in pntramte       : número de trámite
         param in pnmovtte       : número movimiento trámite
         param out ptramitemov   : ob_iax_sin_tramite_mov
         param in out mensajes   : mensajes de error
         return                  : 0 -> Tot correcte
                                   1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_get_tramite_mov(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      pnmovtte IN NUMBER,
      ptramitemov OUT ob_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION f_get_tramite_movs
          Devuelve una colección de objetos OB_IAX_SIN_TRAMITE_MOV de un trámite
          determinado
          param in pnsinies         : numero del sinistre
          param in pntramte         : número de trámite
          param out ptramitemovs   : t_iax_sin_tramite_mov
          param in out mensajes     : mensajes de error
          return                    : 0 -> Tot correcte
                                      1 -> S'ha produit un error
    *************************************************************************/
   FUNCTION f_get_tramite_movs(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramte IN NUMBER,
      ptramitemovs OUT t_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION f_set_tramite_mov
         Función puente para grabar los movimientos de los trámites.
         param in ptramitemov   : objeto movimiento trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite_mov(
      ptramitemov IN ob_iax_sin_tramite_mov,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_tramite_movs
         Función que por cada movimiento de un objeto trámite llama la función que grabe estos movimientos.
         param in pnsinies   : numero del sinistre
         param in ptramitemov   : coleccion de objeto movimiento trámite
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite_movs(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramitemov IN t_iax_sin_tramite_mov,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_tramite
         Función puente para grabar un trámite y lanza la funcion puente para
         grabar los movimientos de éste.
         param in ptramite   : objeto trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramite(
      ptramite IN ob_iax_sin_tramite,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_set_tramites
         Función que por cada objeto trámite de la colección trámites lanza
         la función puente para grabar estos trámites.
         param in ptramites   : colección objetos trámite
         param in pnsinies   : numero del sinistre
         param in out mensajes   : mensajes de error
         return              : 0 -> Tot correcte
                               1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_set_tramites(
      ptramites IN t_iax_sin_tramite,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_obj_sintramite_recobro(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptrecstramite IN OUT ob_iax_sin_tramite_recobro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_ins_tramite_recobro(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramiterec IN ob_iax_sin_tramite_recobro,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_obj_sintramite_lesiones(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptlestramite IN OUT ob_iax_sin_tramite_lesiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_ins_tramite_lesiones(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      ptramiteles IN ob_iax_sin_tramite_lesiones,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_hay_tramites
         Comprueba si se han parametrizado los tramites para el producto del siniestro
         param in pnsinies       : numero del siniestro
         param out phay_tramites : 0 --> No
                                   1 --> Si
         param in out mensajes   : mensajes de error
         return                  : 0 -> correcto
                                   1 -> error
   *************************************************************************/
   FUNCTION f_hay_tramites(
      pnsinies IN sin_siniestro.nsinies%TYPE,
      phay_tramites OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCION
      Traspasa los valores de la BBDD al objeto
      param in pnsinies                : número de siniestro
      param in pntramte                : número de trámite
      param in ptasitramite            : objeto
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_set_obj_sintramite_asist(
      pnsinies IN VARCHAR2,
      pntramte IN NUMBER,
      ptasitramite IN OUT ob_iax_sin_tramite_asistencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      FUNCION
      Traspasa los valores del objeto a la bbdd
      param in pnsinies                : número de siniestro
      param in ptramiteasi             : objeto
      param in out t_iax_mensajes      : mensajes de error
      return                           : 0 todo correcto
                                         1 ha habido un error
    -- Bug 0022099 - 16/05/2012 - JMF
   *************************************************************************/
   FUNCTION f_ins_tramite_asist(
      pnsinies IN VARCHAR2,
      ptramiteasi IN ob_iax_sin_tramite_asistencia,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Cambia el estado de una tramite
      param in pnsinies : Número siniestro
      param in pntramit : Número tramitación
      param in pcesttra : Código estado
      return            : 0 -> Tot correcte
                          1 -> S'ha produit un error
   ***********************************************************************/
   FUNCTION f_estado_tramite(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pcesttra IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION
         Crea o actualiza en bbdd, información del tramite asistencia.
         param in  pnsinies  : codi del sinistre
         param out pntramit  : Numero de tramitaci
         param in out t_iax_mensajes      : mensajes de error
         return              : Error (0 -> Tot correcte, codi error)

      Bug 22325/115249- 07/06/2012 - AMC
   *************************************************************************/
   FUNCTION f_get_tramite9999(
      pnsinies IN NUMBER,
      pntramit OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_ini_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden  IN NUMBER,
      proceso  OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_get_procesos_judiciales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

  FUNCTION f_get_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objudicial OUT OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_set_obj_judicial(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcproceso IN NUMBER,
      ptproceso IN NUMBER,
      pcpostal IN VARCHAR2,
      pcpoblac IN NUMBER,
      pcprovin IN NUMBER,
      ptiexterno IN VARCHAR2,
      psprofes IN NUMBER,
      pfrecep IN DATE,
      pfnotifi IN DATE,
      pfvencimi IN DATE,
      pfrespues IN DATE,
      pfconcil IN DATE,
      pfdesvin IN DATE,
      ptpreten IN VARCHAR2,
      ptexcep1 IN VARCHAR2,
      ptexcep2 IN VARCHAR2,
      pcconti IN NUMBER,
      pcdespa IN NUMBER,
      pcdescf IN VARCHAR2,
      pcprovinf IN NUMBER,
      pcpoblacf IN NUMBER,
      pcdespao IN NUMBER,
      pcdesco IN VARCHAR2,
      pcprovino IN NUMBER,
      pcpoblaco IN NUMBER,
      pcposici IN NUMBER,
      pcdemand IN NUMBER,
      psapodera IN NUMBER,
      pidemand IN NUMBER,
      pftdeman IN DATE,
      piconden IN NUMBER,
      pcsenten IN NUMBER,
      pfsente1 IN DATE,
      pcsenten2 IN NUMBER,
      pfsente2 IN DATE,
      pcasacion IN NUMBER,
      pfcasaci IN DATE,
      pctsente IN NUMBER,
      pftsente IN DATE,
      pvtsente IN VARCHAR2,
      ptfallo IN VARCHAR2
    ,pcoralproc IN NUMBER
    ,punicainst IN NUMBER
    ,pfunicainst IN DATE,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_judicial_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;


  FUNCTION f_traspasar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_validar_judicial(
      proceso  IN OB_IAX_SIN_TRAMITA_JUDICIAL,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_elimina_dato_judicial(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
 FUNCTION f_get_procesos_fiscales(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN SYS_REFCURSOR;

  FUNCTION f_get_obj_fiscal(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      objfiscal OUT OB_IAX_SIN_TRAMITA_FISCAL,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN   OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_set_obj_fiscal_valpret(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pcgarant IN NUMBER,
      pipreten IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_elimina_dato_fiscal(
      pctipo IN NUMBER,
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnvalor IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_get_tramite_judicial_audien(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pnaudien IN NUMBER,
      audiencia OUT OB_IAX_SIN_T_JUDICIAL_AUDIEN,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

  FUNCTION f_procesar_agenda_audiencia(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pnorden IN NUMBER,
      pctipo IN NUMBER,
      PCAUDIEN IN NUMBER,
      PFAUDIEN  IN	DATE,
      PHAUDIEN  IN	VARCHAR2,
      pctramitad IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_valida_proceso_fiscal(
      pproceso ob_iax_sin_tramita_fiscal,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
  FUNCTION f_valida_proceso_judicial(
      pproceso ob_iax_sin_tramita_judicial,
      paudiencia ob_iax_sin_t_judicial_audien,
      pctramitad IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_sin_tramite;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_TRAMITE" TO "PROGRAMADORESCSI";
