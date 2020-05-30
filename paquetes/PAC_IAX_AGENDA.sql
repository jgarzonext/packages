--------------------------------------------------------
--  DDL for Package PAC_IAX_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_AGENDA" AS
/******************************************************************************
   NOMBRE:      pac_iax_agenda
   PROPÃ“SITO:

   REVISIONES:
   Ver        Fecha        Autor             DescripciÃ³n
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/11/2010   XPL               1. CreaciÃ³n del package.
   2.0        25/02/2011   JMF              0017744: CRT - Mejoras en agenda
   3.0        25/07/2011   ICV              0018845: CRT901 - Modificacionas tareas usuario: boton responder, grupos, envio de mail al crear tarea,etc
******************************************************************************/
   FUNCTION f_get_lstapuntes(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pfapunte IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari IN VARCHAR2,
      pcapuage IN VARCHAR2,
      pntramit IN NUMBER DEFAULT NULL,
      plstagenda OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pobagenda OUT ob_iax_agenda,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstagdtareas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plstagenda OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      ptapunte IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcusuari IN VARCHAR2,
      pfapunte IN DATE,
      pfestapu IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari_ori IN VARCHAR2 DEFAULT NULL,
      pcgrupo_ori IN VARCHAR2 DEFAULT NULL,
      ptgrupo_ori IN VARCHAR2 DEFAULT NULL,
      pidapunte_out OUT VARCHAR2,
      MENSAJES OUT T_IAX_MENSAJES,
      PTRESP IN VARCHAR2 default null, --CONF-347-01/12/2016-RCS
      pntramit IN NUMBER default NULL)
      RETURN NUMBER;

   FUNCTION f_set_chat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pctipres IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*
 - BUG 17048
 - pctodos = 1 Muestra todos los grupos
 - pctodos=0 Muestra solo los grupos del usuario
*/
   FUNCTION f_get_valoresgrupo(
      pcgrupo IN VARCHAR2,
      pctodos IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Devuelve la lista de todas las observaciones por tipo de agenda y según la visibilidad
      del usuario, de su rol o del rol propietario de la agenda
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param in pparams       : Parametros para filtrar y su valor
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstagdobs(
      pctipagd IN NUMBER,
      pidobs IN NUMBER,
      pparams IN VARCHAR2,
      plstagdobs OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      devolvemos la entidad dependiendo de la parametrización hecha en la tabla
      agd_obs_config. Según el tipo de agenda nos devolverá NPOLIZA - NCERTIF, NRECIBO, Nombre del agente...
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param in pparams       : Parametros para filtrar y su valor
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_entidad(
      pctipagd IN NUMBER,
      pparams IN VARCHAR2,
      ptentidad OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Devuelve la lista de los conceptos según el tipo de agenda
      del usuario, de su rol o del rol propietario de la agenda
      param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
      param out plstconceptos       : Cursor con los conceptos a mostrar
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pctipagd IN NUMBER,
      pcmodo IN VARCHAR2,
      plstconceptos OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Devuelve la lista de los tipos de agenda
      param out pquery       : query que devolveremos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lsttiposagenda(
      plsttiposagenda OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podrá gestionar este rol, siempre será visible
          pctipagd IN NUMBER,
          plstroles OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pctipagd IN NUMBER,
      plstroles OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_obs(
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pttipagd IN VARCHAR2,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
          Devuelve la visión de la observación
          propietario ya que no se podrá gestionar este rol, siempre será visible
          pidobs IN NUMBER,
          plstvision OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_visionobs(
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Grabamos al objeto la vision del apunte si es publico marcamos todos
      propietario ya que no se podrá gestionar este rol, siempre será visible
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER,
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_set_visionobs_ob(
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
      Devuelve la visión de la observación que tenemos en la persistencia
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_visionobs_ob(
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_visionobs_ob(
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Actualizamos el objeto segun sea privado o publico
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pcprivobs IN NUMBER,
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_actualizar_vision_ob(
      pidobs IN NUMBER,
      ppublico IN NUMBER,
      pcprivobs IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
            Borramos un apunte/observacion
            pidobs IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_observacion(pidobs IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Devuelve la lista grupos
          return                : Cursor
       *************************************************************************/
   FUNCTION f_get_lstgrupos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
         Devuelve los motivos de respuesta
         return                : Cursor
      *************************************************************************/
   FUNCTION f_get_lstmotrespuesta(pcclagd NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Funció que retorna el valor a mostrar per pantalla.
   Si es un apunt de pòlissa, retornarà npol + ncertif, si és de rebut nrecibo i si és sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(
      pcclagd IN VARCHAR2,
      ptclagd IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_info;

   /*Funci?e crear tasca de la solicitud de projecte
    XPL#24102011#
    */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
	  
	   /*ABJ bug 4961 validar si existe conclusiones y si no traer descripcion de riesgo
      FECHA: 01/08/2019 
      FUNCION: F_VALCONCLUSIONES
      */
      FUNCTION f_valconclusiones(
      PIDOBS IN NUMBER,
      PNSINIES IN NUMBER,
      TDESCRIE OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
	  
END pac_iax_agenda;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_AGENDA" TO "PROGRAMADORESCSI";
