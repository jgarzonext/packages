--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CAMPANAS" IS
  /******************************************************************************
     NOMBRE:       PAC_IAX_CAMPANAS
     PROPÓSITO:    Funciones de la capa IAX para realizar acciones sobre la tabla CAMPANAS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/08/2011   FAL                1. Creación del package. 0019298: LCOL_C001 - Desarrollo de campañas
  ******************************************************************************/
  e_param_error  EXCEPTION;
  e_object_error EXCEPTION;

  /*************************************************************************
   Función que realiza la búsqueda de campañas a partir de los criterios de consulta entrados
   param in pccodigo     : codigo campaña
   param in pcestado     : estado campaña
   param in pfinicam     : fecha inicio campaña
   param in pffincam     : fecha fin campaña
   param out ptcampanas  : colección de objetos ob_iax_campana
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 busqueda correcta
                          <> 0 busqueda incorrecta
  *************************************************************************/
  FUNCTION f_buscar(pccodigo   IN NUMBER,
                    pcestado   IN VARCHAR2,
                    pfinicam   IN DATE,
                    pffincam   IN DATE,
                    ptcampanas OUT t_iax_campanas,
                    mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_buscar';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_buscar(pccodigo,
                                        pcestado,
                                        pfinicam,
                                        pffincam,
                                        ptcampanas,
                                        mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_buscar;

  /*************************************************************************
   Función que permite ver/editar el detalle de la campaña
   param in pccodigo     : codigo campaña
   param out pobcampana  : objeto ob_iax_campana
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 edición correcta
                          <> 0 edición incorrecta
  *************************************************************************/
  FUNCTION f_editar(pccodigo   IN NUMBER,
                    pobcampana OUT ob_iax_campanas,
                    mensajes   OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_editar';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - pccodigo = ' || pccodigo;
  BEGIN
    vnumerr := pac_md_campanas.f_editar(pccodigo, pobcampana, mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_editar;

  /*************************************************************************
   Función que permite guardar los cambios realizados en  el detalle de la campaña
   param in pccodigo     : codigo campaña
   param in ptdescrip    : descripciÃ³n de la campaÃ±a
   param in pcestado    : estado de la campaÃ±a. Por defecto 'PE'
   param in pfinicam    : fecha inicio de la campaÃ±a
   param in pffincam    : fecha fin de la campaÃ±a
   param in pivalini    : Coste de lanzamiento de la campaÃ±a
   param in pipremio    : Coste del premio de la campaÃ±a
   param in pivtaprv    : Importe Previsto de las ventas de la campaÃ±a
   param in pivtarea    : Importe Real de las ventas de la campaÃ±a
   param in pcmedios    : Medios de comunicaciÃ³n de la campaÃ±a (max.8 medios diferentes)
   param in pnagecam    : Num. de agentes  participantes en la campaÃ±a
   param in pnagegan    : Num. de agentes  ganadores en la campaÃ±a
   param in ptobserv    : Observaciones de la campaÃ±a
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 grabación correcta
                          <> 0 grabación incorrecta
  *************************************************************************/
  FUNCTION f_grabar(pccodigo  IN VARCHAR2,
                    ptdescrip IN VARCHAR2,
                    pcestado  IN VARCHAR2,
                    pfinicam  IN DATE,
                    pffincam  IN DATE,
                    pivalini  IN NUMBER,
                    pipremio  IN NUMBER,
                    pivtaprv  IN NUMBER,
                    pivtarea  IN NUMBER,
                    pcmedios  IN VARCHAR2,
                    pnagecam  IN NUMBER,
                    pnagegan  IN NUMBER,
                    ptobserv  IN VARCHAR2,
                    pcexccrr  IN NUMBER,
                    pcexcnewp IN NUMBER,
                    pfinirec  IN DATE,
                    pffinrec  IN DATE,
                    pcconven  IN VARCHAR2,
                    mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_grabar';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_grabar(pccodigo,
                                        ptdescrip,
                                        pcestado,
                                        pfinicam,
                                        pffincam,
                                        pivalini,
                                        pipremio,
                                        pivtaprv,
                                        pivtarea,
                                        pcmedios,
                                        pnagecam,
                                        pnagegan,
                                        ptobserv,
                                        pcexccrr,
                                        pcexcnewp,
                                        pfinirec,
                                        pffinrec,
                                        pcconven, /*ptobcampaprd,*/
                                        mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 180121); -- El registro se ha guardado correctamente
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_grabar;

  /*************************************************************************
   Función que permite generar las cartas de alta/anulación de la campaña a los agentes asociados
   param in pccodigo     : codigo campaña
   param out mensajes    : colección de objetos ob_iax_mensajes
        return             : 0 generación cartas correcta
                          <> 0 generación cartas incorrecta
  *************************************************************************/
  FUNCTION f_cartear(pctipocarta IN VARCHAR2, mensajes OUT t_iax_mensajes)
    RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_cartear';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_cartear(pctipocarta, mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_cartear;

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
  /*************************************************************************
   FUNCTION f_get_agentes_campa
   Funcion que permite buscar agentes que pueden participar en las campañas
   param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
   param in pccodigo   : código campaña
   param in pfinicam   : fecha inicio campaña
   param in pctipage   : tipo agente
   param in pcagente   : código agente
   param out plistage  : lista de agentes/campaña
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pfinicam IN DATE,
                               pctipage IN NUMBER,
                               pcagente IN NUMBER,
                               plistage OUT t_iax_campaage,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_get_agentes_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_get_agentes_campa(pcmodo,
                                                   pccodigo,
                                                   pfinicam,
                                                   pctipage,
                                                   pcagente,
                                                   plistage,
                                                   mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_agentes_campa;

  /*************************************************************************
   FUNCTION f_set_agentes_campa
   Funcion que permite asignar/eliminar agentes a las campaña
   param in plistage   : lista de agentes/campaña
   return              : number
  *************************************************************************/
  FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,
                               pccodigo IN NUMBER,
                               pcagente IN NUMBER,
                               pctipage IN NUMBER,
                               pfinicam IN DATE,
                               pffincam IN DATE,
                               pimeta   IN NUMBER,
                               mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_set_agentes_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_set_agentes_campa(pcmodo,
                                                   pccodigo,
                                                   pcagente,
                                                   pctipage,
                                                   pfinicam,
                                                   pffincam,
                                                   pimeta,
                                                   mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_set_agentes_campa;

  -- Fi Bug 0019298

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
  /*************************************************************************
   FUNCTION f_get_productos_campa
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pcramo     : codigo del ramo
   param in psproduc   : código del producto
   param in pcactivi   : codigo de la actividad
   param in pcgarant   : codigo de la garantia
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_productos_campa(pcramo    IN NUMBER,
                                 psproduc  IN NUMBER,
                                 pcactivi  IN NUMBER,
                                 pcgarant  IN NUMBER,
                                 plistprod OUT sys_refcursor,
                                 mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_get_productos_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_get_productos_campa(pcramo,
                                                     psproduc,
                                                     pcactivi,
                                                     pcgarant,
                                                     plistprod,
                                                     mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_productos_campa;

  /*************************************************************************
   FUNCTION f_set_productos_campa
   Funcion que permite asignar productos a las campaña
   param out plistage  : colección de objetos campaage
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_productos_campa(pccodigo IN NUMBER,
                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_set_productos_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_set_productos_campa(pccodigo,
                                                     psproduc,
                                                     pcactivi,
                                                     pcgarant,
                                                     mensajes);
    vnumerr := 0;

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      ROLLBACK;
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_set_productos_campa;

  -- 21/03/2013. JLV.
  /*************************************************************************
   FUNCTION f_get_campaprd
   Funcion que perminte buscar productos/actividades/garantias de una campaña
   param in pccodigo    : codigo del campaña
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campaprd(pccodigo  IN NUMBER,
                          plistprod OUT sys_refcursor,
                          mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_get_campaprd';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_get_campaprd(pccodigo, plistprod, mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_campaprd;

  /*************************************************************************
   FUNCTION f_get_campa
   Funcion que perminte buscar una campaña
   param in pccodigo    : codigo del campaña
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colección de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campa(pccodigo  IN NUMBER,
                       plistprod OUT sys_refcursor,
                       mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER(8) := 0;
    vobjectname VARCHAR2(500) := 'PAC_IAX_CAMPANAS.f_get_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
  BEGIN
    vnumerr := pac_md_campanas.f_get_campa(pccodigo, plistprod, mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_campa;

  /*************************************************************************
   FUNCTION f_get_estadocampana
   Funcion que permite recuperar los valores del estado de una campaña
   param out mensajes  : colección de objetos ob_iax_mensajes
   return    : ref cursor
  *************************************************************************/
  FUNCTION f_get_estadocampana(mensajes OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(1) := NULL;
    vobject  VARCHAR2(200) := 'PAC_IAX_CAMPANAS.f_get_estadocampana';
  BEGIN
    cur := pac_md_campanas.f_get_estadocampana(mensajes);
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN cur;
  END f_get_estadocampana;

  /***************************************************************************************
   FUNCTION f_get_medios
   Funcion que permite recuperar los valores de los medios de comunicación de una campaña
   param out mensajes  : colección de objetos ob_iax_mensajes
   return    : ref cursor
  ****************************************************************************************/
  FUNCTION f_get_medios(mensajes OUT t_iax_mensajes) RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(1) := NULL;
    vobject  VARCHAR2(200) := 'PAC_IAX_CAMPANAS.f_get_medios';
  BEGIN
    cur := pac_md_campanas.f_get_medios(mensajes);
    RETURN cur;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN cur;
  END f_get_medios;

  /*************************************************************************
   FUNCTION f_del_productos_campa
   Funcion que permite eliminar productos de una campaña
   param in pccodigo     : codigo campaña
   param in pcproduc  : código de producto
   return              : number
  *************************************************************************/
  FUNCTION f_del_productos_campa(pccodigo IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vlin     NUMBER;
    vobject  VARCHAR2(200) := 'pac_md_campanas.f_del_productos_campa';
    vparam   VARCHAR2(2000) := 'pccodigo: ' || pccodigo;
    vnumerr  NUMBER;
    vpasexec NUMBER := 1;
  BEGIN
    vnumerr := pac_md_campanas.f_del_productos_campa(pccodigo, mensajes);

    IF vnumerr = 0 THEN
      COMMIT;
      RETURN 0;
    ELSE
      RAISE e_object_error;
    END IF;
  EXCEPTION
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        vnumerr,
                                        vpasexec,
                                        vparam);
      ROLLBACK;
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        pccodigo,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);
      ROLLBACK;
      RETURN 1;
  END f_del_productos_campa;

  /*************************************************************************
   FUNCTION f_get_agentecampanyes
   Funcion que perminte buscar las campañas en las que está un agente
   param in pcagente    : codigo de agente
   param out pquery  : select de llas campañas
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentecampanyes(pcagente      IN NUMBER,
                                 plistagecampa OUT sys_refcursor,
                                 mensajes      OUT t_iax_mensajes)
    RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_get_agentecampanyes';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'parámetros - ';
    vcempres    NUMBER;
  BEGIN
    IF pcagente IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_md_campanas.f_get_agentecampanyes(pcagente,
                                                     plistagecampa,
                                                     mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_agentecampanyes;

  /*************************************************************************
   FUNCTION f_set_ageganador
   Funcion que permite asignar productos a las campaña
   param in pccodigo     : codigo campaña
   param in pcagente     : agente
   param in ptganador    : ganador (S/N)
   param out mensajes  : t_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_ageganador(pccodigo  IN NUMBER,
                            pcagente  IN NUMBER,
                            ptganador IN VARCHAR2,
                            mensajes  OUT t_iax_mensajes) RETURN NUMBER IS
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'pac_campanas.f_set_ageganador';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'pccodigo-pcagente-pcactivi-ptganador: ' ||
                                  pccodigo || '-' || pcagente || '-' ||
                                  ptganador;
  BEGIN
    vnumerr := pac_md_campanas.f_set_ageganador(pccodigo,
                                                pcagente,
                                                ptganador,
                                                mensajes);
    COMMIT;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      ROLLBACK;
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      ROLLBACK;
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      ROLLBACK;
      RETURN 1;
  END f_set_ageganador;

  /*************************************************************************
   FUNCTION f_get_documentos
   Funcion que perminte mostrar los deocumentos de una campañas
   param in pccodigo    : codigo de campaña
   param in plistdocumentos    : Lista de documentos de la campaña
   param out mensajes  : mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_documentos(pccodigo        IN NUMBER,
                            plistdocumentos OUT sys_refcursor,
                            mensajes        OUT t_iax_mensajes) RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'pac_campanas.f_get_documentos';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'pccodigo: ' || pccodigo;
  BEGIN
    vnumerr := pac_md_campanas.f_get_documentos(pccodigo,
                                                plistdocumentos,
                                                mensajes);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);
      RETURN 1;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN 1;
  END f_get_documentos;

  /*************************************************************************
   FUNCTION f_get_campa_cierre
   Funcion que perminte realizar cierre de Campañas
   param out mensajes  : mensajes
   return              : v_curso
  *************************************************************************/

  FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                              pcagente  IN NUMBER,
                              pccampana IN NUMBER,
                              pnmes     IN NUMBER,
                              pnano     IN NUMBER,
                              pcramo    IN NUMBER,
                              pcempres  IN NUMBER,
                              psproduc  IN NUMBER,
                              pcsucurs  IN NUMBER,
                              mensajes  OUT T_IAX_MENSAJES)

   RETURN SYS_REFCURSOR IS
    V_CURSO   SYS_REFCURSOR;
    v_pasexec VARCHAR2(100);
    v_object  VARCHAR2(100) := 'PAC_IAX_CAMPANAS.f_get_campa_cierre';
    v_param   VARCHAR2(1000) := 'pcagente=' || pcagente || 'pccampana=' ||
                                pccampana || ' pnmes=' || pnmes ||
                                'pnano= ' || pnano || 'pcramo= ' || pcramo ||
                                'pcempres= ' || pcempres || 'psproduc= ' ||
                                psproduc || 'pcsucurs= ' || pcsucurs;

  BEGIN
    RETURN pac_md_campanas.f_get_campa_cierre(pctipo,
                                              pcagente,
                                              pccampana,
                                              pnmes,
                                              pnano,
                                              pcramo,
                                              pcempres,
                                              psproduc,
                                              pcsucurs,
                                              mensajes);
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000005,
                                        v_pasexec,
                                        v_param);

      RETURN V_CURSO;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000006,
                                        v_pasexec,
                                        v_param);

      RETURN V_CURSO;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000001,
                                        v_pasexec,
                                        v_param,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);

      RETURN V_CURSO;

  END f_get_campa_cierre;

  /*************************************************************************
   FUNCTION F_GENERAR_CORREO
   Funcion que perminte enviar correo de Campañas
   param out mensajes  : mensajes
   return              : 0
  *************************************************************************/

  FUNCTION F_GENERAR_CORREO(pctipo    IN NUMBER,
                            pcagente  IN NUMBER,
                            pccampana IN NUMBER,
                            pnmes     IN NUMBER,
                            pnano     IN NUMBER,
                            pcramo    IN NUMBER,
                            pcempres  IN NUMBER,
                            psproduc  IN NUMBER,
                            pcsucurs  IN NUMBER,
                            mensajes  OUT T_IAX_MENSAJES)

   RETURN NUMBER IS
    V_CURSO   SYS_REFCURSOR;
    v_pasexec VARCHAR2(100);
    v_object  VARCHAR2(100) := 'PAC_IAX_CAMPANAS.F_GENERAR_CORREO';
    v_param   VARCHAR2(1000) := 'pcagente=' || pcagente || 'pccampana=' ||
                                pccampana || ' pnmes=' || pnmes ||
                                'pnano= ' || pnano || 'pcramo= ' || pcramo ||
                                'pcempres= ' || pcempres || 'psproduc= ' ||
                                psproduc || 'pcsucurs= ' || pcsucurs;

  BEGIN
    RETURN pac_md_campanas.F_GENERAR_CORREO(pctipo,
                                            pcagente,
                                            pccampana,
                                            pnmes,
                                            pnano,
                                            pcramo,
                                            pcempres,
                                            psproduc,
                                            pcsucurs,
                                            mensajes);
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000005,
                                        v_pasexec,
                                        v_param);

      RETURN 0;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000006,
                                        v_pasexec,
                                        v_param);

      RETURN 0;
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000001,
                                        v_pasexec,
                                        v_param,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);

      RETURN 0;

  END F_GENERAR_CORREO;

END pac_iax_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CAMPANAS" TO "PROGRAMADORESCSI";
