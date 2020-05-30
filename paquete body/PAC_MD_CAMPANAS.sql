--------------------------------------------------------
--  DDL for Package Body PAC_MD_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CAMPANAS" IS
  /******************************************************************************
     NOMBRE:       PAC_MD_CAMPANAS
     PROP¿SITO:    Funciones de la capa MD para realizar acciones sobre la tabla CAMPANAS

     REVISIONES:
     Ver        Fecha        Autor             Descripci¿n
     ---------  ----------  ---------------  ------------------------------------
     1.0        30/08/2011   FAL                1. Creaci¿n del package.0019298: LCOL_C001 - Desarrollo de campa¿as
  ******************************************************************************/
  e_param_error  EXCEPTION;
  e_object_error EXCEPTION;

  /*************************************************************************
   Funci¿n que realiza la b¿squeda de campa¿as a partir de los criterios de consulta entrados
   param in pccodigo     : codigo campa¿a
   param in pcestado     : estado campa¿a
   param in pfinicam     : fecha inicio campa¿a
   param in pffincam     : fecha fin campa¿a
   param out ptcampanas  : colecci¿n de objetos ob_iax_campana
   param in out mensajes : colecci¿n de objetos ob_iax_mensajes
        return             : 0 busqueda correcta
                          <> 0 busqueda incorrecta
  *************************************************************************/
  FUNCTION f_buscar(pccodigo   IN NUMBER,

                    pcestado   IN VARCHAR2,
                    pfinicam   IN DATE,
                    pffincam   IN DATE,
                    ptcampanas OUT t_iax_campanas,
                    mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS

    pobcampana  ob_iax_campanas;
    vnumerr     NUMBER;
    vquery      VARCHAR2(3000);
    cur         SYS_REFCURSOR;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_buscar';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
  BEGIN
    vnumerr := pac_campanas.f_buscar(pccodigo,
                                     pcestado,
                                     pfinicam,
                                     pffincam,
                                     vquery);

    IF vnumerr != 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;

    pobcampana := ob_iax_campanas();
    ptcampanas := t_iax_campanas();
    cur        := pac_iax_listvalores.f_opencursor(vquery, mensajes);

    LOOP
      FETCH cur
        INTO pobcampana.ccodigo,
             pobcampana.tdescrip,
             pobcampana.cestado,
             pobcampana.finicam,
             pobcampana.ffincam,
             pobcampana.ivalini,
             pobcampana.ipremio,
             pobcampana.ivtaprv,
             pobcampana.ivtarea,
             pobcampana.cmedios,
             pobcampana.nagecam,
             pobcampana.nagegan,
             pobcampana.tobserv,
             pobcampana.cexccrr,
             pobcampana.cexcnewp,
             pobcampana.finirec,
             pobcampana.ffinrec,
             pobcampana.cconven;

      EXIT WHEN cur%NOTFOUND;
      ptcampanas.EXTEND;
      ptcampanas(ptcampanas.LAST) := pobcampana;
      pobcampana := ob_iax_campanas();
    END LOOP;

    CLOSE cur;

    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

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

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN 1;
  END f_buscar;

  /*************************************************************************
   Funci¿n que permite ver/editar el detalle de la campa¿a
   param in pccodigo     : codigo campa¿a
   param out pobcampana  : objeto ob_iax_campana
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 edici¿n correcta
                          <> 0 edici¿n incorrecta
  *************************************************************************/
  FUNCTION f_editar(pccodigo   IN NUMBER,

                    pobcampana OUT ob_iax_campanas,
                    mensajes   IN OUT t_iax_mensajes) RETURN NUMBER IS

    vnumerr             NUMBER;
    vquery              VARCHAR2(3000);
    vquery2             VARCHAR2(3000);
    vquery3             VARCHAR2(3000);
    vquery4             VARCHAR2(3000);
    cur                 SYS_REFCURSOR;
    vobjectname         VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_editar';
    vpasexec            NUMBER(5) := 1;
    vparam              VARCHAR2(1000) := 'par¿metros - pccodigo = ' ||
                                          pccodigo;
    vobcampana          ob_iax_campanas;
    vobcampaprd         ob_iax_campaprd;
    vtcampaprd          t_iax_campaprd;
    vobcampaage         ob_iax_campaage;
    vtcampaage          t_iax_campaage;
    vobcampaage_ganador ob_iax_campaage_ganador;
    vtcampaage_ganador  t_iax_campaage_ganador;
  BEGIN
    vobcampana := ob_iax_campanas();

    IF pccodigo IS NULL THEN
      pobcampana := vobcampana;
      RETURN 0;
    END IF;

    vnumerr := pac_campanas.f_editar(pccodigo,
                                     vquery,
                                     vquery2,
                                     vquery3,
                                     vquery4);

    IF vnumerr != 0 THEN
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
      RAISE e_object_error;
    END IF;

    --  informacion de campa¿as
    cur := pac_iax_listvalores.f_opencursor(vquery, mensajes);

    LOOP
      FETCH cur
        INTO vobcampana.ccodigo,
             vobcampana.tdescrip,
             vobcampana.cestado,
             vobcampana.finicam,
             vobcampana.ffincam,
             vobcampana.ivalini,
             vobcampana.ipremio,
             vobcampana.ivtaprv,
             vobcampana.ivtarea,
             vobcampana.cmedios,
             vobcampana.nagecam,
             vobcampana.nagegan,
             vobcampana.tobserv,
             vobcampana.cexccrr,
             vobcampana.cexcnewp,
             vobcampana.finirec,
             vobcampana.ffinrec,
             vobcampana.cconven;

      EXIT WHEN cur%NOTFOUND;
    END LOOP;

    CLOSE cur;

    ------------------------------------------------------
    -- recupera prod/activ/garant asociado a la campa¿a --
    ------------------------------------------------------
    cur := pac_iax_listvalores.f_opencursor(vquery2, mensajes);

    ----------------------------------------------------------------------------
    IF NOT cur%ISOPEN THEN
      -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
      RAISE e_object_error;
    ELSE
      vtcampaprd := t_iax_campaprd();

      LOOP
        vobcampaprd := ob_iax_campaprd();

        FETCH cur
          INTO vobcampaprd.ccodigo,
               vobcampaprd.sproduc,
               vobcampaprd.tproduc,
               vobcampaprd.cactivi,
               vobcampaprd.tactivi,
               vobcampaprd.cgarant,
               vobcampaprd.tgarant;

        IF cur%NOTFOUND THEN
          EXIT;
        END IF;

        vtcampaprd.EXTEND;
        vtcampaprd(vtcampaprd.LAST) := vobcampaprd;
      END LOOP;

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      vobcampana.campaprd := vtcampaprd;
    END IF;

    ---------------------------------------------
    -- recupera agentes asignados a la campa¿a --
    ---------------------------------------------
    cur := pac_iax_listvalores.f_opencursor(vquery3, mensajes);

    IF NOT cur%ISOPEN THEN
      -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
      RAISE e_object_error;
    ELSE
      vtcampaage := t_iax_campaage();

      LOOP
        vobcampaage := ob_iax_campaage();

        FETCH cur
          INTO vobcampaage.ccodigo,
               vobcampaage.cagente,
               vobcampaage.tagente,
               vobcampaage.finicam,
               vobcampaage.ffincam;

        IF cur%NOTFOUND THEN
          EXIT;
        END IF;

        vtcampaage.EXTEND;
        vtcampaage(vtcampaage.LAST) := vobcampaage;
      END LOOP;

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      vobcampana.campaage := vtcampaage;
    END IF;

    -------------------------------------------------------
    -- recupera agentes ganadores asignados a la campa¿a --
    -------------------------------------------------------
    cur := pac_iax_listvalores.f_opencursor(vquery4, mensajes);

    IF NOT cur%ISOPEN THEN
      -- Se ha producido un error en  PAC_IAX_LISTVALORES.F_Opencursor
      RAISE e_object_error;
    ELSE
      vtcampaage_ganador := t_iax_campaage_ganador();

      LOOP
        vobcampaage_ganador := ob_iax_campaage_ganador();

        FETCH cur
          INTO vobcampaage_ganador.ccodigo,
               vobcampaage_ganador.cagente,
               vobcampaage_ganador.tagente,
               vobcampaage_ganador.finicam,
               vobcampaage_ganador.ffincam;

        IF cur%NOTFOUND THEN
          EXIT;
        END IF;

        vtcampaage_ganador.EXTEND;
        vtcampaage_ganador(vtcampaage_ganador.LAST) := vobcampaage_ganador;
      END LOOP;

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      vobcampana.campaage_ganador := vtcampaage_ganador;
    END IF;

    ----------------------------------------------------------------------------
    /*
          LOOP
             FETCH cur
              INTO vobcampaprd.ccodigo, vobcampaprd.sproduc, vobcampaprd.cactivi,
                   vobcampaprd.cgarant;
             EXIT WHEN cur%NOTFOUND;
             vobcampaprd := ob_iax_campaprd();
             vtcampaprd.EXTEND;
             vtcampaprd(vtcampaprd.LAST) := vobcampaprd;
          END LOOP;

          CLOSE cur;

          vobcampana.campaprd := vtcampaprd;
          -- recupera agentes asignados a la campa¿a
          cur := pac_iax_listvalores.f_opencursor(vquery3, mensajes);

          LOOP
             FETCH cur
              INTO vobcampaage.ccodigo, vobcampaage.cagente, vobcampaage.tagente,
                   vobcampaage.finicam, vobcampaage.ffincam;

             EXIT WHEN cur%NOTFOUND;
             vtcampaage.EXTEND;
             vtcampaage(vtcampaage.LAST) := vobcampaage;
             vobcampaage := ob_iax_campaage();
          END LOOP;

          CLOSE cur;

          vobcampana.campaage := vtcampaage;
          -- recupera agentes ganadores asignados a la campa¿a
          cur := pac_iax_listvalores.f_opencursor(vquery4, mensajes);

          LOOP
             FETCH cur
              INTO vobcampaage_ganador.ccodigo, vobcampaage_ganador.cagente,
                   vobcampaage_ganador.tagente, vobcampaage_ganador.finicam,
                   vobcampaage_ganador.ffincam;

             EXIT WHEN cur%NOTFOUND;
             vtcampaage_ganador.EXTEND;
             vtcampaage_ganador(vtcampaage_ganador.LAST) := vobcampaage_ganador;
             vobcampaage_ganador := ob_iax_campaage_ganador();
          END LOOP;

          CLOSE cur;

          vobcampana.campaage_ganador := vtcampaage_ganador;
    */
    pobcampana := vobcampana;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
                                        vpasexec,
                                        vparam);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN 1;
    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000006,
                                        vpasexec,
                                        vparam);

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

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

      IF cur%ISOPEN THEN
        CLOSE cur;
      END IF;

      RETURN 1;
  END f_editar;

  /*************************************************************************
   Funci¿n que permite guardar los cambios realizados en  el detalle de la campa¿a
   param in pccodigo     : codigo campa¿a
   param in ptdescrip    : descripci¿¿n de la campa¿¿a
   param in pcestado    : estado de la campa¿¿a. Por defecto 'PE'
   param in pfinicam    : fecha inicio de la campa¿¿a
   param in pffincam    : fecha fin de la campa¿¿a
   param in pivalini    : Coste de lanzamiento de la campa¿¿a
   param in pipremio    : Coste del premio de la campa¿¿a
   param in pivtaprv    : Importe Previsto de las ventas de la campa¿¿a
   param in pivtarea    : Importe Real de las ventas de la campa¿¿a
   param in pcmedios    : Medios de comunicaci¿¿n de la campa¿¿a (max.8 medios diferentes)
   param in pnagecam    : Num. de agentes  participantes en la campa¿¿a
   param in pnagegan    : Num. de agentes  ganadores en la campa¿¿a
   param in ptobserv    : Observaciones de la campa¿¿a
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 grabaci¿n correcta
                          <> 0 grabaci¿n incorrecta
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
                    mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS

    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_grabar';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
  BEGIN

    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_grabar(pccodigo,
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
                                     pcconven);

    IF vnumerr <> 0 THEN
      RAISE e_object_error;
    END IF;

    /*
          IF ptobcampaprd IS NOT NULL THEN
             IF ptobcampaprd.COUNT > 0 THEN
                FOR c IN ptobcampaprd.FIRST .. ptobcampaprd.LAST LOOP
                   IF ptobcampaprd.EXISTS(c) THEN
                      vnumerr := pac_campanas.f_grabar_campaprd(ptobcampaprd(c).ccodigo,
                                                                ptobcampaprd(c).sproduc,
                                                                ptobcampaprd(c).cactivi,
                                                                ptobcampaprd(c).cgarant);
                   END IF;
                END LOOP;
             END IF;
          END IF;
    */
    RETURN vnumerr;
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
  END;

  /*************************************************************************
   Funci¿n que permite generar las cartas de alta/anulaci¿n de la campa¿a a los agentes asociados
   param in pccodigo     : codigo campa¿a
   param out mensajes    : colecci¿n de objetos ob_iax_mensajes
        return             : 0 generaci¿n cartas correcta
                          <> 0 generaci¿n cartas incorrecta
  *************************************************************************/
  FUNCTION f_cartear(pctipocarta IN VARCHAR2,
                     mensajes    IN OUT t_iax_mensajes) RETURN NUMBER IS
  BEGIN
    NULL;
  END;

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campa¿as
  /*************************************************************************
   FUNCTION f_get_agentes_campa
   Funcion que permite buscar agentes que pueden participar en las campa¿as
   param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
   param in pccodigo   : c¿digo campa¿a
   param in pfinicam   : fecha inicio campa¿a
   param in pctipage   : tipo agente
   param in pcagente   : c¿digo agente
   param out plistage  : colecci¿n de objetos campaage
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,

                               pccodigo IN NUMBER,
                               pfinicam IN DATE,
                               pctipage IN NUMBER,
                               pcagente IN NUMBER,
                               plistage OUT t_iax_campaage,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS

    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    cur         SYS_REFCURSOR;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_get_agentes_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - pcmodo =' || pcmodo ||
                                  ' pccodigo =' || pccodigo ||
                                  ' pfinicam =' || pfinicam ||
                                  ' pctipage =' || pctipage ||
                                  ' pcagente = ' || pcagente;
    vcempres    NUMBER;
  BEGIN
    IF pccodigo IS NULL OR pcmodo IS NULL THEN

      RAISE e_param_error;
    END IF;

    IF pcmodo = 'ASIGNAR' AND pfinicam IS NULL THEN

      RAISE e_param_error;
    END IF;

    vcempres := f_parinstalacion_n('EMPRESADEF');

    IF pcmodo = 'ASIGNAR' THEN
      vnumerr := pac_campanas.f_get_agentes_campa(pcmodo,
                                                  pccodigo,
                                                  pfinicam,
                                                  pctipage,
                                                  pcagente,
                                                  vcempres,
                                                  vquery);
    ELSIF pcmodo = 'DESASIGNAR' THEN
      vnumerr := pac_campanas.f_get_agentes_campa(pcmodo,
                                                  pccodigo,
                                                  pfinicam,
                                                  pctipage,
                                                  pcagente,
                                                  NULL,
                                                  vquery);
    ELSE
      RAISE e_param_error;
    END IF;

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    cur      := pac_iax_listvalores.f_opencursor(vquery, mensajes);
    plistage := t_iax_campaage();

    IF pcmodo = 'ASIGNAR' THEN
      LOOP
        vobcampaage := ob_iax_campaage();

        FETCH cur
          INTO vobcampaage.cagente,
               vobcampaage.ctipage,
               vobcampaage.tagente,
               vobcampaage.imeta;

        vobcampaage.ccodigo  := pccodigo;
        vobcampaage.finicam  := pfinicam;
        vobcampaage.ffincam  := NULL;
        vobcampaage.bganador := NULL;
        EXIT WHEN cur%NOTFOUND;
        plistage.extend;
        plistage(plistage.last) := vobcampaage;
      END LOOP;
    ELSIF pcmodo = 'DESASIGNAR' THEN
      LOOP
        vobcampaage := ob_iax_campaage();

        FETCH cur
          INTO vobcampaage.ccodigo,
               vobcampaage.cagente,
               vobcampaage.ctipage,
               vobcampaage.finicam,
               vobcampaage.ffincam,
               vobcampaage.bganador,
               vobcampaage.tagente,
               vobcampaage.imeta;

        EXIT WHEN cur%NOTFOUND;
        plistage.EXTEND;
        plistage(plistage.LAST) := vobcampaage;
      END LOOP;
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
   Funcion que permite asignar/eliminar agentes a las campa¿a
   param out plistage  : colecci¿n de objetos campaage
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,

                               pccodigo IN NUMBER,
                               pcagente IN NUMBER,
                               pctipage IN NUMBER,
                               pfinicam IN DATE,
                               pffincam IN DATE,
                               pimeta   IN NUMBER,
                               mensajes IN OUT t_iax_mensajes) RETURN NUMBER IS

    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_set_agentes_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
  BEGIN
    IF pcmodo IS NULL THEN
      RAISE e_param_error;
    END IF;

    --IF plistage IS NOT NULL THEN
    --  IF plistage.COUNT > 0 THEN
    --    FOR c IN plistage.FIRST .. plistage.LAST LOOP
    --      IF plistage.EXISTS(c) THEN
    vnumerr := pac_campanas.f_set_agentes_campa(pcmodo,
                                                pccodigo,
                                                pcagente,
                                                pctipage,
                                                pfinicam,
                                                pffincam,
                                                pimeta);
    --       END IF;
    --    END LOOP;
    --  END IF;
    -- END IF;
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
  END f_set_agentes_campa;

  -- Fi Bug 0019298

  -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campa¿as
  /*************************************************************************
   FUNCTION f_get_productos_campa
   Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
   param in pcramo     : codigo del ramo
   param in psproduc   : c¿digo del producto
   param in pcactivi   : codigo de la actividad
   param in pcgarant   : codigo de la garantia
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_productos_campa(pcramo    IN NUMBER,

                                 psproduc  IN NUMBER,
                                 pcactivi  IN NUMBER,
                                 pcgarant  IN NUMBER,
                                 plistprod OUT SYS_REFCURSOR,
                                 mensajes  IN OUT t_iax_mensajes)
    RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    cur         SYS_REFCURSOR;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_get_productos_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
    vcempres    NUMBER;
  BEGIN
   -- IF pcramo IS NULL THEN
   --   RAISE e_param_error;
   -- END IF;

    vnumerr := pac_campanas.f_get_productos_campa(pcramo,
                                                  psproduc,
                                                  pcactivi,
                                                  pcgarant,
                                                  pac_md_common.f_get_cxtidioma(),
                                                  vquery);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    plistprod := pac_iax_listvalores.f_opencursor(vquery, mensajes);
    /*
          IF pcmodo = 'ASIGNAR' THEN
             LOOP
                FETCH cur
                 INTO vobcampaage.cagente, vobcampaage.ctipage;

                vobcampaage.ccodigo := pccodigo;
                vobcampaage.finicam := pfinicam;
                vobcampaage.ffincam := NULL;
                vobcampaage.bganador := NULL;
                EXIT WHEN cur%NOTFOUND;
                plistage.EXTEND;
                plistage(plistage.LAST) := vobcampaage;
                vobcampaage := ob_iax_campaage();
             END LOOP;
          ELSIF pcmodo = 'DESASIGNAR' THEN
             LOOP
                FETCH cur
                 INTO vobcampaage.ccodigo, vobcampaage.cagente, vobcampaage.ctipage,
                      vobcampaage.finicam, vobcampaage.ffincam, vobcampaage.bganador;

                EXIT WHEN cur%NOTFOUND;
                plistage.EXTEND;
                plistage(plistage.LAST) := vobcampaage;
                vobcampaage := ob_iax_campaage();
             END LOOP;
          END IF;
    */
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
   Funcion que permite asignar productos a las campa¿a
   param in pccodigo     : codigo campa¿a
   param in plistprod  : lista de productos seleccionados
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_productos_campa(pccodigo IN NUMBER,

                                 psproduc IN NUMBER,
                                 pcactivi IN NUMBER,
                                 pcgarant IN NUMBER,
                                 mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER IS
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_set_productos_campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
  BEGIN
    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    --IF plistprod IS NOT NULL THEN
    --   IF plistprod.COUNT > 0 THEN
    --Borrar primero los datos
    --      FOR c IN plistprod.FIRST .. plistprod.LAST LOOP
    --         IF plistprod.EXISTS(c) THEN
    --            vnumerr := pac_campanas.f_del_productos_campa(plistprod(c).ccodigo,
    -- plistprod(c).sproduc);
    --         END IF;
    --     END LOOP;

    --     FOR c IN plistprod.FIRST .. plistprod.LAST LOOP
    --        IF plistprod.EXISTS(c) THEN
    vnumerr := pac_campanas.f_set_productos_campa(pccodigo,
                                                  psproduc,
                                                  pcactivi,
                                                  pcgarant);
    ---      END IF;
    -- --   END LOOP;
    --  END IF;
    -- END IF;
    RETURN 0;
  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobjectname,
                                        1000005,
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
  END f_set_productos_campa;

  /*************************************************************************
   FUNCTION f_get_campaprd
   Funcion que perminte buscar productos/actividades/garantias de una campa¿a
   param in pccodigo    : codigo de campa¿a
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campaprd(pccodigo  IN NUMBER,

                          plistprod OUT SYS_REFCURSOR,
                          mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS

    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    cur         SYS_REFCURSOR;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.campaprd';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
    vcempres    NUMBER;
  BEGIN
    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_get_campaprd(pccodigo, vquery);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    plistprod := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   Funcion que perminte buscar una campa¿a
   param in pccodigo    : codigo de campa¿a
   param out plistprod  : lista de productos (sys_refcursor)
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_campa(pccodigo  IN NUMBER,
                       plistprod OUT SYS_REFCURSOR,
                       mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    cur         SYS_REFCURSOR;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.campa';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
    vcempres    NUMBER;
  BEGIN
    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_get_campa(pccodigo, vquery);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    plistprod := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   Funcion que permite recuperar los valores del estado de una campa¿a
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return    : ref cursor
  *************************************************************************/
  FUNCTION f_get_estadocampana(mensajes OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR IS
    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(1) := NULL;
    vobject  VARCHAR2(200) := 'PAC_MD_CAMPANAS.f_get_estadocampana';
  BEGIN
    cur := pac_md_listvalores.f_detvalores(1052, mensajes);
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

  /*************************************************************************
   FUNCTION f_del_productos_campa
   Funcion que permite eliminar productos de una campa¿a
   param in pccodigo     : codigo campa¿a
   param in pcproduc  : c¿digo de producto
   return              : number
  *************************************************************************/
  FUNCTION f_del_productos_campa(pccodigo IN NUMBER,
                                 mensajes OUT t_iax_mensajes) RETURN NUMBER IS
    vlin     NUMBER;
    vobject  VARCHAR2(200) := 'pac_md_campanas.f_del_productos_campa';
    vpasexec VARCHAR2(2000) := 'pccodigo: ' || pccodigo;
    vnumerr  NUMBER;
  BEGIN
    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_del_productos_campa(pccodigo);
    RETURN vnumerr;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        pccodigo,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);
      RETURN 1;
  END f_del_productos_campa;

  /***************************************************************************************
   FUNCTION f_get_medios
   Funcion que permite recuperar los valores de los medios de comunicaci¿n de una campa¿a
   param out mensajes  : colecci¿n de objetos ob_iax_mensajes
   return    : ref cursor
  ****************************************************************************************/
  FUNCTION f_get_medios(mensajes OUT t_iax_mensajes) RETURN SYS_REFCURSOR IS

    cur      SYS_REFCURSOR;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(1) := NULL;
    vobject  VARCHAR2(200) := 'PAC_MD_CAMPANAS.f_get_medios';
  BEGIN
    cur := pac_md_listvalores.f_detvalores(1500, mensajes);
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
   FUNCTION f_get_agentecampanyes
   Funcion que perminte buscar las campa¿as en las que est¿ un agente
   param in pcagente    : codigo de agente
   param out pquery  : select de llas campa¿as
   return              : number
  *************************************************************************/
  FUNCTION f_get_agentecampanyes(pcagente      IN NUMBER,

                                 plistagecampa OUT SYS_REFCURSOR,
                                 mensajes      IN OUT t_iax_mensajes)
    RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vobcampaage ob_iax_campaage;
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'PAC_MD_CAMPANAS.f_get_agentecampanyes';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'par¿metros - ';
    vcempres    NUMBER;
  BEGIN
    IF pcagente IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_get_agentecampanyes(pcagente, vquery);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    plistagecampa := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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
   Funcion que permite asignar productos a las campa¿a
   param in pccodigo     : codigo campa¿a
   param in pcagente     : agente
   param in ptganador    : ganador (S/N)
   param in out mensajes  : t_iax_mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_set_ageganador(pccodigo  IN NUMBER,

                            pcagente  IN NUMBER,
                            ptganador IN VARCHAR2,
                            mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS

    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'pac_campanas.f_set_ageganador';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'pccodigo-pcagente-pcactivi-ptganador: ' ||
                                  pccodigo || '-' || pcagente || '-' ||
                                  ptganador;
  BEGIN
    IF pccodigo IS NULL OR pcagente IS NULL THEN

      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_set_ageganador(pccodigo, pcagente, ptganador);
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
  END f_set_ageganador;

  /*************************************************************************
   FUNCTION f_get_documentos
   Funcion que perminte mostrar los deocumentos de una campa¿as
   param in pccodigo    : codigo de campa¿a
   param in plistdocumentos    : Lista de documentos de la campa¿a
   param out mensajes  : mensajes
   return              : number
  *************************************************************************/
  FUNCTION f_get_documentos(pccodigo        IN NUMBER,

                            plistdocumentos OUT SYS_REFCURSOR,
                            mensajes        IN OUT t_iax_mensajes)
    RETURN NUMBER IS
    vquery      VARCHAR2(3000);
    vnumerr     NUMBER;
    vobjectname VARCHAR2(500) := 'pac_campanas.f_get_documentos';
    vpasexec    NUMBER(5) := 1;
    vparam      VARCHAR2(1000) := 'pccodigo: ' || pccodigo;
  BEGIN
    IF pccodigo IS NULL THEN
      RAISE e_param_error;
    END IF;

    vnumerr := pac_campanas.f_get_documentos(pccodigo, vquery);

    IF vnumerr != 0 THEN
      RAISE e_object_error;
    END IF;

    plistdocumentos := pac_iax_listvalores.f_opencursor(vquery, mensajes);
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

  /***********************************************************************
  ***********************************************************************/

  FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                              pcagente  IN NUMBER,
                              pccampana IN NUMBER,
                              pnmes     IN NUMBER,
                              pnano     IN NUMBER,
                              pcramo    IN NUMBER,
                              pcempres  IN NUMBER,
                              psproduc  IN NUMBER,
                              pcsucurs  IN NUMBER,
                              mensajes  IN OUT t_iax_mensajes)
    RETURN SYS_REFCURSOR IS

    v_cursor  SYS_REFCURSOR;
    v_object  VARCHAR2(100) := 'PAC_MD_CAMPANAS.F_GET_CAMPA_CIERRE';
    v_pasexec VARCHAR2(100);
    v_param   VARCHAR2(1000) := 'pctipo=' || pctipo || 'pcagente=' ||
                                pcagente || ' pccampana=' || pccampana ||
                                'pnmes= ' || pnmes || 'pnano= ' || pnano ||
                                'pcramo= ' || pcramo || 'pcempres= ' ||
                                pcempres || 'psproduc= ' || psproduc ||
                                ' pcsucurs=' || pcsucurs;

  BEGIN
    RETURN pac_campanas.f_get_campa_cierre(pctipo,
                                           pcagente,
                                           pccampana,
                                           pnmes,
                                           pnano,
                                           pcramo,
                                           pcempres,
                                           psproduc,
                                           pcsucurs);

  EXCEPTION
    WHEN e_param_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000005,
                                        v_pasexec,
                                        v_param);
      RETURN v_cursor;

    WHEN e_object_error THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000006,
                                        v_pasexec,
                                        v_param);
      RETURN v_cursor;

    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        v_object,
                                        1000001,
                                        v_pasexec,
                                        v_param,
                                        NULL,
                                        SQLCODE,
                                        SQLERRM);
      RETURN v_cursor;

  END f_get_campa_cierre;

  /***********************************************************************
  ***********************************************************************/

  FUNCTION f_generar_correo(pctipo    IN NUMBER,
                            pcagente  IN NUMBER,
                            pccampana IN NUMBER,
                            pnmes     IN NUMBER,
                            pnano     IN NUMBER,
                            pcramo    IN NUMBER,
                            pcempres  IN NUMBER,
                            psproduc  IN NUMBER,
                            pcsucurs  IN NUMBER,
                            mensajes  IN OUT t_iax_mensajes) RETURN NUMBER IS

    v_cursor  SYS_REFCURSOR;
    v_object  VARCHAR2(100) := 'PAC_MD_CAMPANAS.F_GENERAR_CORREO';
    v_pasexec VARCHAR2(100);
    v_param   VARCHAR2(1000) := 'pctipo=' || pctipo || 'pcagente=' ||
                                pcagente || ' pccampana=' || pccampana ||
                                'pnmes= ' || pnmes || 'pnano= ' || pnano ||
                                'pcramo= ' || pcramo || 'pcempres= ' ||
                                pcempres || 'psproduc= ' || psproduc ||
                                ' pcsucurs=' || pcsucurs;

  BEGIN
    RETURN pac_campanas.f_generar_correo(pctipo,
                                         pcagente,
                                         pccampana,
                                         pnmes,
                                         pnano,
                                         pcramo,
                                         pcempres,
                                         psproduc,
                                         pcsucurs);

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

  END f_generar_correo;

END pac_md_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CAMPANAS" TO "PROGRAMADORESCSI";
