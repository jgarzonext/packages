--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DESCUENTOS" IS
   /******************************************************************************
      NOMBRE:     PAC_IAX_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuentos

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        01/03/2012   JRB               1. Creación del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

    /*************************************************************************
      Recupera un cuadro de descuentos
      param in pcdesc   : codigo de descuento
      param in ptdesc   : descripcion del cuadro
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pffechaini : fecha inicio
      param in pffechafin : fecha fin
      param out pcuadros  : cuadros de descuento
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrosdescuento(
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pffechaini IN DATE,
      pffechafin IN DATE,
      pcuadros OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'PCDESC:' || pcdesc || ' PTDESC:' || ptdesc || ' PCTIPO:' || pctipo
            || ' PCESTADO:' || pcestado || ' PFFECHAINI:' || pffechaini || ' PFFECHAFIN:'
            || pffechafin;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_cuadrosdescuento';
      verror         NUMBER;
   BEGIN
      verror := pac_md_descuentos.f_get_cuadrosdescuento(pcdesc, ptdesc, pctipo, pcestado,
                                                         pffechaini, pffechafin, pcuadros,
                                                         mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cuadrosdescuento;

   /*************************************************************************

      param in pcdesc   : codigo de descuento
      param in pcidioma     : codigo de idioma
      param in ptdesc   : descripcion del cuadro
      param out mensajes  : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_obj_desccuadro(
      pcidioma IN NUMBER,
      pcdesc IN NUMBER,
      ptdesc IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_obj_desccuadro';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
   BEGIN
      IF obdescuento IS NOT NULL THEN
         IF obdescuento.descripciones IS NOT NULL
            AND obdescuento.descripciones.COUNT > 0 THEN
            FOR i IN obdescuento.descripciones.FIRST .. obdescuento.descripciones.LAST LOOP
               IF obdescuento.descripciones(i).cdesc = pcdesc
                  AND obdescuento.descripciones(i).cidioma = pcidioma THEN
                  obdescuento.descripciones(i).tdesc := ptdesc;
                  trobat := TRUE;
               END IF;
            END LOOP;

            IF trobat = FALSE THEN
               obdescuento.descripciones.EXTEND;
               obdescuento.descripciones(obdescuento.descripciones.LAST) :=
                                                                  ob_iax_desccuadrodescuento
                                                                                            ();
               vnumerr :=
                  pac_md_descuentos.f_set_obj_desccuadro
                                   (pcdesc, pcidioma, ptdesc,
                                    obdescuento.descripciones(obdescuento.descripciones.LAST),
                                    mensajes);

               IF vnumerr <> 0 THEN
                  RAISE e_object_error;
               END IF;
            END IF;
         END IF;
      ELSE
         obdescuento := ob_iax_cuadrodescuento();
         obdescuento.cdesc := 1;   --nextval cdesc seq;
         obdescuento.tdesc := ptdesc;
         obdescuento.descripciones := t_iax_desccuadrodescuento();
         obdescuento.descripciones(0) := ob_iax_desccuadrodescuento();
         vnumerr := pac_md_descuentos.f_set_obj_desccuadro(pcdesc, pcidioma, ptdesc,
                                                           obdescuento.descripciones(0),
                                                           mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_obj_desccuadro;

/*************************************************************************

      param in pccomisi   : codigo de comision
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pfinivig   : fecha inicio vigencia
      param in pffinvig   : fecha fin vigencia
      param in pmodo      : codigo de modo
      param out mensajes  : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_cuadrodescuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pdescripciones IN t_iax_info,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_comisiones.f_set_cuadrodescuento';
      vparam         VARCHAR2(500) := 'par�metros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
      vcestado       NUMBER;
   BEGIN
      IF pcdesc IS NULL
         OR pdescripciones IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pfinivig <= f_sysdate THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904213);
         RAISE e_object_error;
      END IF;

      --validaciones
/*
Al dar de alta el cuadro, el estado es 1 - Pendiente validar
Cuando se trata de un alta de vigencia, s�lo se pueden informar las fechas de inicio y final de vigencia.
El estado est� asociado a la vigencia, de forma que cada vigencia tiene su estado y al dar de alta una vigencia
el estado ser� 1 - Pendiente validar
En modificaciones:
"  Si estado = 1 - Pendiente Validar, puede modificarse la lista de descripciones por idioma, el tipo y el
estado a:
o  2 - Validado
o  3 - Anulado
"  Si  estado =  2 - Validado, s�lo puede modificarse el estado a 3 - Anulado
o  Se validar� que no exista ning�n agente que tenga ese cuadro de comisi�n antes de permitir este cambio.

*/
      --fi validaciones

      --Nueva vigencia el estado es 1
      IF pmodo = 'NVIGEN' THEN
         vcestado := 1;
      ELSE
         vcestado := pcestado;
      END IF;

      obdescuento := ob_iax_cuadrodescuento();
      vnumerr := pac_md_descuentos.f_set_obj_cuadrodescuento(pcdesc, pctipo, vcestado,
                                                             pfinivig, pffinvig, obdescuento,
                                                             mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      obdescuento.descripciones := t_iax_desccuadrodescuento();

      FOR i IN pdescripciones.FIRST .. pdescripciones.LAST LOOP
         obdescuento.descripciones.EXTEND;
         obdescuento.descripciones(obdescuento.descripciones.LAST) :=
                                                                  ob_iax_desccuadrodescuento
                                                                                            ();
         vpasexec := 5;
         vnumerr :=
            pac_md_descuentos.f_set_obj_desccuadro
                                   (TO_NUMBER(pdescripciones(i).nombre_columna), pcdesc,
                                    pdescripciones(i).valor_columna,
                                    obdescuento.descripciones(obdescuento.descripciones.LAST),
                                    mensajes);
      END LOOP;

      vnumerr := pac_md_descuentos.f_set_traspaso_obj_bd(obdescuento, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF pmodo = 'NVIGEN' THEN
--En caso de nueva vigencia duplicamos las tablas comisionprod, comisionacti, comisiongar
         vnumerr := pac_md_descuentos.f_dup_det_descuento(pcdesc, pfinivig, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_cuadrodescuento;

   /*************************************************************************

      param in pcdesc   : codigo de descuento
      param in pctipo     : codigo de tipo
      param in pcestado   : codigo de estado
      param in pfinivig   : fecha inicio vigencia
      param in pffinvig   : fecha fin vigencia
      param in pmodo      : codigo de modo
      param out mensajes  : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_obj_cuadrodescuento(
      pcdesc IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_obj_cuadrodescuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
      vcestado       NUMBER;
   BEGIN
      IF obdescuento IS NULL
         OR obdescuento.descripciones IS NULL THEN
         RETURN 1;
      END IF;

      --validaciones
/*
Al dar de alta el cuadro, el estado es 1 - Pendiente validar
Cuando se trata de un alta de vigencia, sólo se pueden informar las fechas de inicio y final de vigencia.
El estado está asociado a la vigencia, de forma que cada vigencia tiene su estado y al dar de alta una vigencia
el estado será 1 - Pendiente validar
En modificaciones:
"  Si estado = 1 - Pendiente Validar, puede modificarse la lista de descripciones por idioma, el tipo y el
estado a:
o  2 - Validado
o  3 - Anulado
"  Si  estado =  2 - Validado, sólo puede modificarse el estado a 3 - Anulado
o  Se validará que no exista ningún agente que tenga ese cuadro de comisión antes de permitir este cambio.

*/
      --fi validaciones

      --Nueva vigencia el estado es 1
      IF pmodo = 'NVIGEN' THEN
         vcestado := 1;
      ELSE
         vcestado := pcestado;
      END IF;

      vnumerr := pac_md_descuentos.f_set_obj_cuadrodescuento(pcdesc, pctipo, vcestado,
                                                             pfinivig, pffinvig, obdescuento,
                                                             mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vnumerr := pac_md_descuentos.f_set_traspaso_obj_bd(obdescuento, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF pmodo = 'NVIGEN' THEN
--En caso de nueva vigencia duplicamos las tablas comisionprod, comisionacti, comisiongar
         vnumerr := pac_md_descuentos.f_dup_det_descuento(pcdesc, pfinivig, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_obj_cuadrodescuento;

   /*************************************************************************
      Devuel el cuadro de descuento cargado en memoria
      param in pcdesc   : codigo de descuento
      param in pcuadrodescuento : cuadro de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_obj_cuadrodescuento(
      pcdesc IN NUMBER,
      pcuadrodescuento OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_obj_cuadrodescuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      pcuadros       t_iax_cuadrodescuento;
   BEGIN
      IF obdescuento IS NOT NULL THEN
         pcuadrodescuento := obdescuento;
      ELSE
         vnumerr := f_get_cuadrodescuento(pcdesc, NULL, NULL, pcuadrodescuento, mensajes);

         IF pcuadrodescuento IS NOT NULL THEN
            obdescuento := pcuadrodescuento;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_obj_cuadrodescuento;

   /*************************************************************************
      Traspasa a la BD el objeto descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_traspaso_obj_bd(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_traspaso_obj_bd';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
   BEGIN
      vnumerr := pac_md_descuentos.f_set_traspaso_obj_bd(obdescuento, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      obdescuento := NULL;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_traspaso_obj_bd;

   /*************************************************************************
      Duplica un cuadro de descuentos
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro(
      pcdesc_ori IN NUMBER,
      pcdesc_nuevo IN NUMBER,
      ptdesc_nuevo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_duplicar_cuadro';
      vparam         VARCHAR2(500)
         := 'parámetros - pcdesc_ori:' || pcdesc_ori || ' pcdesc_nuevo:' || pcdesc_nuevo
            || ' ptdesc_nuevo:' || ptdesc_nuevo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF pcdesc_ori IS NULL
         OR pcdesc_nuevo IS NULL
         OR ptdesc_nuevo IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcdesc_nuevo > 99 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001891);
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_descuentos.f_duplicar_cuadro(pcdesc_ori, pcdesc_nuevo, ptdesc_nuevo,
                                                     mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_duplicar_cuadro;

   /*************************************************************************
      Devuel un cuadro de descuento
      param in pcdesc   : codigo de descuento
      param in pcuadrodescuento : cuadro de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrodescuento(
      pcdesc IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      pcuadrodescuento OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_cuadrodescuento';
      vparam         VARCHAR2(500) := 'parámetros - pcdesc: ' || pcdesc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
      pcuadros       t_iax_cuadrodescuento;
   BEGIN
      IF pcdesc IS NOT NULL THEN
         vnumerr := f_get_cuadrosdescuento(pcdesc, NULL, NULL, NULL, pfinivig, pffinvig,
                                           pcuadros, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      ELSE
         vpasexec := 2;
         vnumerr := pac_md_descuentos.f_get_cuadrodescuento(pcuadros, mensajes);

         IF vnumerr <> 0 THEN
            RAISE e_object_error;
         END IF;
      END IF;

      vpasexec := 3;

      IF obdescuento IS NULL THEN
         t_descuento := NULL;
      END IF;

      IF pcuadros IS NOT NULL THEN
         FOR n IN pcuadros.FIRST .. pcuadros.LAST LOOP
            IF pcuadros(n).ffinvig IS NULL THEN
               obdescuento := pcuadros(n);
               pcuadrodescuento := pcuadros(n);
               RETURN 0;
            END IF;
         END LOOP;

         pcuadrodescuento := pcuadros(1);
         obdescuento := pcuadros(1);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_cuadrodescuento;

   /*************************************************************************
      Actualiza el cdesc de un cuadro de descuento
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : nuevo codigo de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_act_cdesc(pcdesc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_comisiones.f_act_cdesc';
      vparam         VARCHAR2(500) := 'parámetros - pcdesc:' || pcdesc;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      pcuadros       t_iax_cuadrodescuento;
   BEGIN
      IF pcdesc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcdesc > 99 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001891);
         RAISE e_param_error;
      END IF;

      vnumerr := f_get_cuadrosdescuento(pcdesc, NULL, NULL, NULL, NULL, NULL, pcuadros,
                                        mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF pcuadros IS NOT NULL
         AND pcuadros.COUNT > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903901);
         RAISE e_object_error;
      END IF;

      IF obdescuento IS NOT NULL THEN
         obdescuento.cdesc := pcdesc;

         IF obdescuento.descripciones IS NOT NULL
            AND obdescuento.descripciones.COUNT > 0 THEN
            FOR i IN obdescuento.descripciones.FIRST .. obdescuento.descripciones.LAST LOOP
               obdescuento.descripciones(i).cdesc := pcdesc;
            END LOOP;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_act_cdesc;

   FUNCTION f_get_detalle_descuento(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      ptodos IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_descuentos.f_get_detalle_descuento(pcdesc, pcagrprod, pcramo,
                                                           psproduc, pcactivi, pcgarant,
                                                           ptodos, NULL, pfinivig, pffinvig,
                                                           1, pt_descuento, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      t_descuento := pt_descuento;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_detalle_descuento;

   FUNCTION f_set_detalle_descuento(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      ppdesc IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER,
      pnindice IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnivel         NUMBER := 1;
      trobat         BOOLEAN := FALSE;
      vninialt       NUMBER;
      vnfinalt       NUMBER;
   BEGIN
      IF pninialt IS NULL THEN
         IF pcmoddesc IN(2, 4) THEN
            vninialt := 2;
         ELSE
            vninialt := 1;
         END IF;
      ELSE
         vninialt := pninialt;
      END IF;

      IF pnfinalt IS NULL THEN
         IF pcmoddesc IN(2, 4) THEN
            vnfinalt := 99;
         ELSE
            vnfinalt := 1;
         END IF;
      ELSE
         vnfinalt := pnfinalt;
      END IF;

      vnivel := pnivel;

      IF pnivel IS NULL THEN
         IF pcgarant IS NOT NULL THEN
            vnivel := 3;
         ELSIF pcactivi IS NOT NULL THEN
            vnivel := 2;
         ELSE
            vnivel := 1;
         END IF;
      END IF;

      IF vninialt < 0
         OR vnfinalt < 0
         OR ppdesc < 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902884);
         RAISE e_object_error;
      END IF;

      IF vninialt > vnfinalt THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902887);
         RAISE e_object_error;
      END IF;

      -- BUG 20826 - 103319 - GAG - LCOL_C001: Incidencias de Cuadros de comisión
      IF (ppdesc < 0
          OR ppdesc > 100) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000390);
         RAISE e_object_error;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               --
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  IF vninialt BETWEEN t_descuento(i).ninialt AND t_descuento(i).nfinalt
                     OR vnfinalt BETWEEN t_descuento(i).ninialt AND t_descuento(i).nfinalt
                     OR(vninialt <= t_descuento(i).ninialt
                        AND vnfinalt >= t_descuento(i).nfinalt) THEN
                     /* BUG 20826_0103306-20120111-JLTS-Se adiciona la siguiente condicion
                        para validar el que no se tome el mismo dato del objeto t_descuento */
                     IF NVL(pnindice, -99) != t_descuento(i).nindice THEN
                        pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902885);
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END IF;

                --
               /* IF t_descuento(i).cdesc = pcdesc
                   AND t_descuento(i).sproduc = psproduc
                   AND t_descuento(i).ninialt = vninialt
                   AND t_descuento(i).nivel = vnivel
                   AND((vnivel = 2
                        AND t_descuento(i).cactivi = pcactivi
                        AND t_descuento(i).cgarant IS NULL)
                       OR(vnivel = 3
                          AND t_descuento(i).cactivi = pcactivi
                          AND t_descuento(i).cgarant = pcgarant)
                       OR(vnivel = 1
                          AND t_descuento(i).cactivi IS NULL
                          AND t_descuento(i).cgarant IS NULL))
                   AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                   AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                   t_descuento(i).pdesc := ppdesc;
                   t_descuento(i).nfinalt := vnfinalt;
                   t_descuento(i).modificado := 1;
                   trobat := TRUE;
                --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1, 'TROBAT', '');
                END IF; */
                /* BUG 20826_0103306-20120111-JLTS-Se adiciona el IF para validar que sea modificado
                   el dato según el nindice */
               IF pnindice = t_descuento(i).nindice THEN
                  t_descuento(i).pdesc := ppdesc;
                  t_descuento(i).ninialt := vninialt;
                  t_descuento(i).nfinalt := vnfinalt;
                  t_descuento(i).modificado := 1;
                  trobat := TRUE;
               END IF;
            END IF;
         END LOOP;

         IF trobat = FALSE THEN
            t_descuento.EXTEND;
            t_descuento(t_descuento.LAST) := ob_iax_detdescuento();
            vnumerr :=
               pac_md_descuentos.f_set_detalle_descuento(pcdesc, psproduc, pcactivi, pcgarant,
                                                         vnivel, pcmoddesc, pfinivig, ppdesc,
                                                         vninialt, vnfinalt,
                                                         t_descuento(t_descuento.LAST),
                                                         mensajes);
            t_descuento(t_descuento.LAST).modificado := 1;
            /* BUG 20826_0103306-20120111-JLTS-Se adiciona el campo pnindice
               para validar el que no se tome el mismo dato del objeto t_descuento */
            t_descuento(t_descuento.LAST).nindice := t_descuento.LAST;

            --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 3, 'EXTENDED', '');
            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         t_descuento := t_iax_detdescuento();
         t_descuento.EXTEND;
         t_descuento(t_descuento.LAST) := ob_iax_detdescuento();
         vnumerr := pac_md_descuentos.f_set_detalle_descuento(pcdesc, psproduc, pcactivi,
                                                              pcgarant, vnivel, pcmoddesc,
                                                              pfinivig, ppdesc, vninialt,
                                                              vnfinalt,
                                                              t_descuento(t_descuento.LAST),
                                                              mensajes);
         t_descuento(t_descuento.LAST).modificado := 1;
         /* BUG 20826_0103306-20120111-JLTS-Se adiciona el campo pnindice
            para validar el que no se tome el mismo dato del objeto t_comision */
         t_descuento(t_descuento.LAST).nindice := t_descuento.LAST;
      --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1, 'NEW AND EXTENDED', '');
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detalle_descuento;

   FUNCTION f_get_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_detdesc_alt';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vnivel         NUMBER := 1;
      trobat         BOOLEAN := FALSE;
   BEGIN
      pt_descuento := t_iax_detdescuento();
      vnivel := pnivel;

      IF pnivel IS NULL THEN
         IF pcgarant IS NOT NULL THEN
            vnivel := 3;
         ELSIF pcactivi IS NOT NULL THEN
            vnivel := 2;
         ELSE
            vnivel := 1;
         END IF;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  pt_descuento.EXTEND;
                  pt_descuento(pt_descuento.LAST) := t_descuento(i);
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_detdesc_alt;

   FUNCTION f_canc_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_canc_detdesc_alt';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vnivel         NUMBER := 1;
   BEGIN
      vnivel := pnivel;

      IF pnivel IS NULL THEN
         IF pcgarant IS NOT NULL THEN
            vnivel := 3;
         ELSIF pcactivi IS NOT NULL THEN
            vnivel := 2;
         ELSE
            vnivel := 1;
         END IF;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  t_descuento(i).modificado := 0;
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_canc_detdesc_alt;

   FUNCTION f_del_detdesc_alt(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      pelimina IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_del_detdesc_alt';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vnivel         NUMBER := 1;
   BEGIN
      vnivel := pnivel;

      IF pnivel IS NULL THEN
         IF pcgarant IS NOT NULL THEN
            vnivel := 3;
         ELSIF pcactivi IS NOT NULL THEN
            vnivel := 2;
         ELSE
            vnivel := 1;
         END IF;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).ninialt = pninialt
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  t_descuento(i).modificado := 0;
                  t_descuento.DELETE(i);
               END IF;
            END IF;
         END LOOP;
      END IF;

      IF pelimina = 1 THEN
         vnumerr := pac_md_descuentos.f_del_altura(psproduc, pcactivi, pcgarant, pcdesc,
                                                   pcmoddesc, pfinivig, pninialt, vnivel,
                                                   mensajes);
      END IF;

      IF vnumerr != 0 THEN
         ROLLBACK;
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_del_detdesc_alt;

   FUNCTION f_set_traspaso_detalle_obj_bd(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_traspaso_detalle_obj_bd';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      trobat         BOOLEAN := FALSE;
   BEGIN
      vnumerr := pac_md_descuentos.f_set_traspaso_detalle_obj_bd(t_descuento, mensajes);

      IF vnumerr = -1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120466);
         RETURN -1;
      ELSIF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      t_descuento := NULL;
      COMMIT;
      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_traspaso_detalle_obj_bd;

   FUNCTION f_get_obj_detalle_descuento(
      pdetalledescuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_obj_cuadrodescuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      pdetalledescuento := t_descuento;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_obj_detalle_descuento;

    /*************************************************************************
    BUG 20826_0103318-20120119 - JLTS- Se adiciona esta nueva funcion para retornar unicamente los datos necesarios

      Devuelve los el detalle de comisiones del objeto t_comision según los parámetros
      param in pcdesc   : codigo de descuento
      param in psproduc   : codigo de producto
      param in pcactivi   : codigo de la actividad
      param in pcgarant   : codigo de la garantia
      param in pcmoddesc   : codigo la modalidad del descuento

      param out mensajes   : mensajes de error

      return : objeto
   *************************************************************************/
   FUNCTION f_get_detalle_descuento_obj(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcmoddesc IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_detdescuento IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_detalle_descuento_obj';
      vparam         VARCHAR2(500)
         := 'parámetros - pcdesc=' || pcdesc || ' psproduc=' || psproduc || ' pcactivi='
            || pcactivi || ' pcgarant=' || pcgarant || ' pcmoddesc=' || pcmoddesc;
      vnivel         NUMBER := 1;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      pdetalledescuento t_iax_detdescuento;
   BEGIN
      pdetalledescuento := t_iax_detdescuento();

      IF pcgarant IS NOT NULL THEN
         vnivel := 3;
      ELSIF pcactivi IS NOT NULL THEN
         vnivel := 2;
      ELSE
         vnivel := 1;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc) THEN
                  pdetalledescuento.EXTEND;
                  pdetalledescuento(pdetalledescuento.LAST) := t_descuento(i);
               END IF;
            END IF;
         END LOOP;
      END IF;

      RETURN pdetalledescuento;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN pdetalledescuento;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN pdetalledescuento;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN pdetalledescuento;
   END f_get_detalle_descuento_obj;

   FUNCTION f_set_detalle_descuento(
      pcdesc IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnivel IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      ppdesc IN NUMBER,
      pninialt IN NUMBER,
      pnfinalt IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vnivel         NUMBER := 1;
      trobat         BOOLEAN := FALSE;
      vninialt       NUMBER;
      vnfinalt       NUMBER;
   BEGIN
      IF pninialt IS NULL THEN
         IF pcmoddesc IN(2, 4) THEN
            vninialt := 2;
         ELSE
            vninialt := 1;
         END IF;
      ELSE
         vninialt := pninialt;
      END IF;

      IF pnfinalt IS NULL THEN
         IF pcmoddesc IN(2, 4) THEN
            vnfinalt := 99;
         ELSE
            vnfinalt := 1;
         END IF;
      ELSE
         vnfinalt := pnfinalt;
      END IF;

      vnivel := pnivel;

      IF pnivel IS NULL THEN
         IF pcgarant IS NOT NULL THEN
            vnivel := 3;
         ELSIF pcactivi IS NOT NULL THEN
            vnivel := 2;
         ELSE
            vnivel := 1;
         END IF;
      END IF;

      IF vninialt < 0
         OR vnfinalt < 0
         OR ppdesc < 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902884);
         RAISE e_object_error;
      END IF;

      IF vninialt > vnfinalt THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902887);
         RAISE e_object_error;
      END IF;

      IF t_descuento IS NOT NULL
         AND t_descuento.COUNT > 0 THEN
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF t_descuento.EXISTS(i) THEN
               --
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  IF vninialt BETWEEN t_descuento(i).ninialt AND t_descuento(i).nfinalt
                     OR vnfinalt BETWEEN t_descuento(i).ninialt AND t_descuento(i).nfinalt
                     OR(vninialt <= t_descuento(i).ninialt
                        AND vnfinalt >= t_descuento(i).nfinalt) THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9902885);
                     RAISE e_object_error;
                  END IF;
               END IF;

               --
               IF t_descuento(i).cdesc = pcdesc
                  AND t_descuento(i).sproduc = psproduc
                  AND t_descuento(i).ninialt = vninialt
                  AND t_descuento(i).nivel = vnivel
                  AND((vnivel = 2
                       AND t_descuento(i).cactivi = pcactivi
                       AND t_descuento(i).cgarant IS NULL)
                      OR(vnivel = 3
                         AND t_descuento(i).cactivi = pcactivi
                         AND t_descuento(i).cgarant = pcgarant)
                      OR(vnivel = 1
                         AND t_descuento(i).cactivi IS NULL
                         AND t_descuento(i).cgarant IS NULL))
                  AND t_descuento(i).cmoddesc = NVL(pcmoddesc, t_descuento(i).cmoddesc)
                  AND t_descuento(i).finivig = NVL(pfinivig, t_descuento(i).finivig) THEN
                  t_descuento(i).pdesc := ppdesc;
                  t_descuento(i).nfinalt := vnfinalt;
                  t_descuento(i).modificado := 1;
                  trobat := TRUE;
               END IF;
            END IF;
         END LOOP;

         IF trobat = FALSE THEN
            t_descuento.EXTEND;
            t_descuento(t_descuento.LAST) := ob_iax_detdescuento();
            vnumerr :=
               pac_md_descuentos.f_set_detalle_descuento(pcdesc, psproduc, pcactivi, pcgarant,
                                                         vnivel, pcmoddesc, pfinivig, ppdesc,
                                                         vninialt, vnfinalt,
                                                         t_descuento(t_descuento.LAST),
                                                         mensajes);
            t_descuento(t_descuento.LAST).modificado := 1;

            --p_tab_error(f_sysdate, f_user, 'IAX_SETDETALLE', 1, 'EXTENDED', '');
            IF vnumerr <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
      ELSE
         t_descuento := t_iax_detdescuento();
         t_descuento.EXTEND;
         t_descuento(t_descuento.LAST) := ob_iax_detdescuento();
         vnumerr := pac_md_descuentos.f_set_detalle_descuento(pcdesc, psproduc, pcactivi,
                                                              pcgarant, vnivel, pcmoddesc,
                                                              pfinivig, ppdesc, vninialt,
                                                              vnfinalt,
                                                              t_descuento(t_descuento.LAST),
                                                              mensajes);
         t_descuento(t_descuento.LAST).modificado := 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detalle_descuento;

   FUNCTION f_get_hist_cuadrodescuento(
      pcdesc IN NUMBER,
      pdetdescuento OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'PCDESC:' || pcdesc;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_hist_cuadrodescuento';
      verror         NUMBER;
   BEGIN
      verror := pac_md_descuentos.f_get_hist_cuadrodescuento(pcdesc, pdetdescuento, mensajes);

      IF verror <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_hist_cuadrodescuento;

   FUNCTION f_get_detalle_descuento_prod(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_md_descuentos.f_get_detalle_descuento(pcdesc, pcagrprod, pcramo,
                                                           psproduc, pcactivi, pcgarant, 0,
                                                           NULL, pfinivig, NULL, 2,
                                                           pt_descuento, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      t_descuento := pt_descuento;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_detalle_descuento_prod;

   /*************************************************************************
       Devuelve el detalle de un cuadro de descuento al nivel indicado
       param in psproduc   : codigo de producto
       param in pcactivi   : codigo de la actividad
       param in pcgarant   : codigo de la garantia
       param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)
       param out pt_descuento  :detalles
       param out mensajes      : mesajes de error

       return : codigo de error
    *************************************************************************/
   FUNCTION f_get_detalle_nivel(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcdesc IN NUMBER,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_get_detalle_nivel';
      vparam         VARCHAR2(500)
         := 'parámetros - psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:'
            || pcgarant || ' pcnivel:' || pcnivel;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vt_descuento   t_iax_detdescuento;
   BEGIN
      IF pcnivel IS NULL THEN
         RAISE e_param_error;
      END IF;

      vt_descuento := t_iax_detdescuento();

      IF pcnivel = 1 THEN
         IF t_descuento IS NOT NULL
            AND t_descuento.COUNT > 0 THEN
            FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
               IF ((pcdesc IS NOT NULL
                    AND t_descuento(i).cdesc = pcdesc)
                   OR pcdesc IS NULL)
                  AND((psproduc IS NOT NULL
                       AND t_descuento(i).sproduc = psproduc)
                      OR psproduc IS NULL)
                  AND t_descuento(i).cactivi IS NULL
                  AND t_descuento(i).cgarant IS NULL
                  AND t_descuento(i).nivel = pcnivel THEN
                  vt_descuento.EXTEND;
                  vt_descuento(vt_descuento.LAST) := t_descuento(i);
               END IF;
            END LOOP;
         END IF;
      ELSIF pcnivel = 2 THEN
         IF psproduc IS NULL
            OR(pcactivi IS NULL
               AND pcdesc IS NULL) THEN
            RAISE e_param_error;
         END IF;

         IF t_descuento IS NOT NULL
            AND t_descuento.COUNT > 0 THEN
            FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
               IF ((pcdesc IS NOT NULL
                    AND t_descuento(i).cdesc = pcdesc)
                   OR pcdesc IS NULL)
                  AND((psproduc IS NOT NULL
                       AND t_descuento(i).sproduc = psproduc)
                      OR psproduc IS NULL)
                  AND((pcactivi IS NOT NULL
                       AND t_descuento(i).cactivi = pcactivi)
                      OR pcactivi IS NULL)
                  AND t_descuento(i).cgarant IS NULL
                  AND t_descuento(i).nivel = pcnivel THEN
                  vt_descuento.EXTEND;
                  vt_descuento(vt_descuento.LAST) := t_descuento(i);
               END IF;
            END LOOP;
         END IF;
      ELSIF pcnivel = 3 THEN
         IF psproduc IS NULL
            OR pcactivi IS NULL
            OR(pcgarant IS NULL
               AND pcdesc IS NULL) THEN
            RETURN 0;
            RAISE e_param_error;
         END IF;

         IF t_descuento IS NOT NULL
            AND t_descuento.COUNT > 0 THEN
            FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
               IF ((pcdesc IS NOT NULL
                    AND t_descuento(i).cdesc = pcdesc)
                   OR pcdesc IS NULL)
                  AND((psproduc IS NOT NULL
                       AND t_descuento(i).sproduc = psproduc)
                      OR psproduc IS NULL)
                  AND((pcactivi IS NOT NULL
                       AND t_descuento(i).cactivi = pcactivi)
                      OR pcactivi IS NULL)
                  AND((pcgarant IS NOT NULL
                       AND t_descuento(i).cgarant = pcgarant)
                      OR pcgarant IS NULL)
                  AND t_descuento(i).nivel = pcnivel THEN
                  vt_descuento.EXTEND;
                  vt_descuento(vt_descuento.LAST) := t_descuento(i);
               END IF;
            END LOOP;
         END IF;
      END IF;

      --end if;
      pt_descuento := vt_descuento;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_detalle_nivel;

   /*************************************************************************
      Devuelve los cuadros de descuento con su % si lo tiene asignado
      param in psproduc   : codigo de producto
      param in pcactivi   : codigo de la actividad
      param in pcgarant   : codigo de la garantia
      param in pnivel     : codigo de nivel (1-Producto,2-Actividad,3-Garantia)

      param out pt_descuento   : detalle cuadros descuento
      param out mensajes   : mensajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_get_porproducto(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcnivel IN NUMBER,
      pcfinivig IN DATE,
      pt_descuento OUT t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant
            || ' pcnivel:' || pcnivel;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCUENTOS.f_get_porproducto';
      verror         NUMBER;
   BEGIN
      IF pcnivel IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcnivel = 1
         AND psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcnivel = 2
         AND psproduc IS NULL
         AND pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcnivel = 3
         AND psproduc IS NULL
         AND pcactivi IS NULL
         AND pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      verror := pac_md_descuentos.f_get_porproducto(psproduc, pcactivi, pcgarant, pcnivel,
                                                    pcfinivig, pt_descuento, mensajes);

      -- Cargamos en el objeto los porcentajes de comision que se haigan modificado en el t_comision
      FOR n IN pt_descuento.FIRST .. pt_descuento.LAST LOOP
         FOR i IN t_descuento.FIRST .. t_descuento.LAST LOOP
            IF pt_descuento(n).cdesc = t_descuento(i).cdesc
               AND pt_descuento(n).sproduc = t_descuento(i).sproduc
               AND NVL(pt_descuento(n).cactivi, -1) = NVL(t_descuento(i).cactivi, -1)
               AND NVL(pt_descuento(n).cgarant, -1) = NVL(t_descuento(i).cgarant, -1)
               AND pt_descuento(n).cmoddesc = t_descuento(i).cmoddesc
               AND NVL(pt_descuento(n).ninialt, -1) = NVL(t_descuento(i).ninialt, -1) THEN
               pt_descuento(n).pdesc := t_descuento(i).pdesc;
               pt_descuento(n).ninialt := t_descuento(i).ninialt;
               pt_descuento(n).nfinalt := t_descuento(i).nfinalt;
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_porproducto;

   /*************************************************************************
      Recupera las fechas de vigencias de los cuadros
      param in pcdesc   : codigo de descuento
      param in pctipo     : codigo de tipo de consulta
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_lsfechasvigencia(
      psproduc IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := ' psproduc = ' || psproduc || ' pctipo:' || pctipo;
      v_object       VARCHAR2(200) := 'PAC_IAX_DESCUENTOS.f_get_lsfechasvigencia';
      vobdetpoliza   ob_iax_detpoliza;
   BEGIN
      cur := pac_md_descuentos.f_get_lsfechasvigencia(psproduc, pctipo, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsfechasvigencia;

   /*************************************************************************
      Duplica un cuadro de descuentos de un producto
      param in pcdesc_ori   : codigo de descuento original
      param in pcdesc_nuevo : codigo de descuento nuevo
      param in ptdesc_nuevo : texto cuadro descuento
      param in pidioma        : codigo de idioma

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro_prod(
      pcsproduc IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_duplicar_cuadro_prod';
      vparam         VARCHAR2(500)
                        := 'parámetros - pcsproduc:' || pcsproduc || ' pfinivig:' || pfinivig;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcount         NUMBER;
   BEGIN
      IF pcsproduc IS NULL
         OR pfinivig IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT COUNT(1)
        INTO vcount
        FROM descprod p, productos prod
       WHERE p.cramo = prod.cramo
         AND p.cmodali = prod.cmodali
         AND p.ctipseg = prod.ctipseg
         AND p.ccolect = prod.ccolect
         AND prod.sproduc = pcsproduc
         AND p.finivig = pfinivig;

      IF vcount > 0 THEN
         vnumerr := 101490;
      END IF;

      vnumerr := pac_md_descuentos.f_duplicar_cuadro_prod(pcsproduc, pfinivig, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_duplicar_cuadro_prod;

   FUNCTION f_get_alturas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vparam         VARCHAR2(500)
                       := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi;
      vobjectname    VARCHAR2(200) := 'PAC_IAX_COMISIONES.f_get_alturas';
      vnumerr        NUMBER;
   BEGIN
      RETURN pac_md_descuentos.f_get_alturas(psproduc, pcactivi, pcgarant, pcdesc, pcmoddesc,
                                             pfinivig, mensajes);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, 1, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, 1, vparam, vnumerr);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, 1, vparam, NULL,
                                           SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_alturas;
END pac_iax_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCUENTOS" TO "PROGRAMADORESCSI";
