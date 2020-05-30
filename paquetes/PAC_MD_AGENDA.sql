--------------------------------------------------------
--  DDL for Package PAC_MD_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_AGENDA" AS
/******************************************************************************
   NOMBRE:      pac_md_agenda
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        19/11/2010   XPL               1. Creación del package.
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pobagenda OUT ob_iax_agenda,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstagdtareas(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      plstagenda OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
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
      MENSAJES IN OUT T_IAX_MENSAJES,
      PTRESP IN VARCHAR2 default null, --CONF-347-01/12/2016-RCS
      pntramit IN NUMBER default null)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*
 - BUG 17048
 - pctodos = 1 Muestra todos los grupos
 - pctodos=0 Muestra solo los grupos del usuario
*/
   FUNCTION f_get_valoresgrupo(
      pcgrupo IN VARCHAR2,
      pctodos IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
        Devuelve la lista de todas las observaciones por tipo de agenda y seg??a visibilidad
        del usuario, de su rol o del rol propietario de la agenda
        param in pctipagd     : Tipo de Agenda (p??a, recibo, siniestro...)
        param in pparams       : Parametros para filtrar y su valor
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lstagdobs(
      pctipagd IN NUMBER,
      pidobs IN NUMBER,
      pparams IN t_iax_info,
      plstagdobs OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
      Devuelve la lista de los conceptos seg??l tipo de agenda
      del usuario, de su rol o del rol propietario de la agenda
      param in pctipagd     : Tipo de Agenda (p??a, recibo, siniestro...)
      param out plstconceptos       : Cursor con los conceptos a mostrar
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pctipagd IN NUMBER,
      pcmodo IN VARCHAR2,
      plstconceptos OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Devuelve la lista de los tipos de agenda
      param out pquery       : query que devolveremos
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_lsttiposagenda(
      plsttiposagenda OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podr?estionar este rol, siempre ser?isible
          pctipagd IN NUMBER,
          plstroles OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pctipagd IN NUMBER,
      plstroles OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
      Guardarem la obs/apu i crearem un apunt.
      Passarem en un objecte els valors SSEGURO, NRECIBO...
      En el cas que s'afegis una nova entitat de l'axis a l'agenda nom?hauriem
      de modificar la capa de negoci i afegir el nou camp ja que vindria en aquest objecte desde java.
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
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pidobs_out OUT VARCHAR2
      return                : 0/1 OK/KO
   *************************************************************************/
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
      pttipagd t_iax_info,
      pvisionrol IN t_iax_agd_vision,
      pvisionusu IN t_iax_agd_vision,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2,
      ptfilename IN VARCHAR2,
      piddocgedox IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
          Devuelve la visi??e la observaci??          propietario ya que no se podr?estionar este rol, siempre ser?isible
          pidobs IN NUMBER,
          plstvision OUT sys_refcursor       : cursor que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_visionobs(
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      plstvisionrol OUT t_iax_agd_vision,
      plstvisionusu OUT t_iax_agd_vision,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
      devolvemos la entidad dependiendo de la parametrizaci??echa en la tabla
      agd_obs_config. Seg??l tipo de agenda nos devolver?POLIZA - NCERTIF, NRECIBO, Nombre del agente...
      param in pctipagd     : Tipo de Agenda (p??a, recibo, siniestro...)
      param in pparams       : Parametros para filtrar y su valor
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_get_entidad(
      pctipagd IN NUMBER,
      pparams IN t_iax_info,
      ptentidad OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Borramos un apunte/observacion
      pidobs IN NUMBER,
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_del_observacion(pidobs IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
          Devuelve la lista grupos
          return                : Cursor
       *************************************************************************/
   FUNCTION f_get_lstgrupos(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
       Devuelve los motivos de respuesta
       return                : Cursor
    *************************************************************************/
   FUNCTION f_get_lstmotrespuesta(pcclagd NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*Funci??e retorna el valor a mostrar per pantalla.
   Si es un apunt de p??sa, retornar?pol + ncertif, si ?de rebut nrecibo i si ?sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(
      pcclagd IN VARCHAR2,
      ptclagd IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_info;

    /*Funci?e crear tasca de la solicitud de projecte
   XPL#24102011#
   */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
	  
END pac_md_agenda;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AGENDA" TO "PROGRAMADORESCSI";
