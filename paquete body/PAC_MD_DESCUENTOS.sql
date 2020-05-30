--------------------------------------------------------
--  DDL for Package Body PAC_MD_DESCUENTOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DESCUENTOS" IS
   /******************************************************************************
      NOMBRE:     PAC_MD_DESCUENTOS
      PROPÓSITO:  Funciones de cuadros de descuento

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
      vsquery        VARCHAR2(1000);
      verror         NUMBER;
      cur            sys_refcursor;
      vcdesc         NUMBER;
      vtdesc         VARCHAR2(500);
      vctipo         NUMBER;
      vttipo         VARCHAR2(500);
      vfinivig       DATE;
      vffinvig       DATE;
      vcestado       NUMBER;
   BEGIN
      verror := pac_descuentos.f_get_cuadrosdescuento(pcdesc, ptdesc, pctipo, pcestado,
                                                      pffechaini, pffechafin,
                                                      pac_md_common.f_get_cxtidioma, vsquery);

      IF verror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, verror);
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pcuadros IS NULL THEN
         pcuadros := t_iax_cuadrodescuento();
      END IF;

      LOOP
         FETCH cur
          INTO vcdesc, vtdesc, vctipo, vfinivig, vffinvig, vcestado;

         EXIT WHEN cur%NOTFOUND;
         pcuadros.EXTEND;
         pcuadros(pcuadros.LAST) := ob_iax_cuadrodescuento();
         pcuadros(pcuadros.LAST).cdesc := vcdesc;
         pcuadros(pcuadros.LAST).tdesc := vtdesc;
         pcuadros(pcuadros.LAST).ctipo := vctipo;
         pcuadros(pcuadros.LAST).finivig := vfinivig;
         pcuadros(pcuadros.LAST).ffinvig := vffinvig;
         pcuadros(pcuadros.LAST).cestado := vcestado;
         --CAMBIAR VALORES FIJOS
         pcuadros(pcuadros.LAST).ttipo := ff_desvalorfijo(1015, pac_md_common.f_get_cxtidioma,
                                                          vctipo);
         pcuadros(pcuadros.LAST).testado := ff_desvalorfijo(1016,
                                                            pac_md_common.f_get_cxtidioma,
                                                            vcestado);
         verror :=
            pac_md_descuentos.f_get_descdescuentos(pcdesc,
                                                   pcuadros(pcuadros.LAST).descripciones,
                                                   mensajes);
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_cuadrosdescuento;

   /*************************************************************************
       Recupera las descripciones de los descuentos
       param in pcdesc   : codigo de descuento
       param out pcuadros  : objeto con las descripciones
       param out mensajes  : mesajes de error
       return              : descripción del valor
    *************************************************************************/
   FUNCTION f_get_descdescuentos(
      pcdesc IN NUMBER,
      pcuadros OUT t_iax_desccuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'PCDESC:' || pcdesc;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_descdescuentos';
   BEGIN
      IF pcuadros IS NULL THEN
         pcuadros := t_iax_desccuadrodescuento();
      END IF;

      FOR cur IN (SELECT   NVL(d.cidioma, i.cidioma) cidioma, d.cdesc, d.tdesc, i.tidioma
                      FROM desdesc d, idiomas i
                     WHERE d.cdesc(+) = pcdesc
                       AND d.cidioma(+) = i.cidioma
                  ORDER BY i.cidioma) LOOP
         pcuadros.EXTEND;
         pcuadros(pcuadros.LAST) := ob_iax_desccuadrodescuento();
         pcuadros(pcuadros.LAST).cidioma := cur.cidioma;
         pcuadros(pcuadros.LAST).tidioma := cur.tidioma;
         pcuadros(pcuadros.LAST).cdesc := NVL(cur.cdesc, pcdesc);
         pcuadros(pcuadros.LAST).tdesc := cur.tdesc;
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
   END f_get_descdescuentos;

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
      pdescripciones IN OUT ob_iax_desccuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_set_obj_desccuadro';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      pdescripciones.cidioma := pcidioma;
      pdescripciones.tidioma := '';   --select tidioma;
      pdescripciones.cdesc := pcdesc;
      pdescripciones.tdesc := ptdesc;
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
      pdescuento IN OUT ob_iax_cuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_set_obj_cuadrodescuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      pdescuento.cestado := pcestado;
      pdescuento.testado := '';   --desvalorfijo(testado,xx);
      pdescuento.cdesc := pcdesc;
      pdescuento.tdesc := '';
      pdescuento.finivig := pfinivig;
      pdescuento.ctipo := pctipo;
      pdescuento.ttipo := '';   --desvalorfijo(ctipo,xx);
      pdescuento.ffinvig := pffinvig;
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
   END f_set_obj_cuadrodescuento;

    /*************************************************************************
      Devuel un cuadro de descuento
      param in out pdescuento   : cuadro de descuento
      param out mensajes      : mesajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_set_traspaso_obj_bd(
      pdescuento IN OUT ob_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_set_traspaso_obj_bd';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_descuentos.f_set_cab_descuento(pdescuento.cdesc, pdescuento.ctipo,
                                                    pdescuento.cestado, pdescuento.finivig,
                                                    pdescuento.ffinvig);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      FOR i IN pdescuento.descripciones.FIRST .. pdescuento.descripciones.LAST LOOP
         IF pdescuento.descripciones(i).tdesc IS NOT NULL THEN
            vnumerr := pac_descuentos.f_set_descdescuento(pdescuento.cdesc,
                                                          pdescuento.descripciones(i).cidioma,
                                                          pdescuento.descripciones(i).tdesc);

            IF vnumerr <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
               RAISE e_object_error;
            END IF;
         END IF;
      END LOOP;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_duplicar_cuadro';
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

      vnumerr := pac_descuentos.f_duplicar_cuadro(pcdesc_ori, pcdesc_nuevo, ptdesc_nuevo,
                                                  pac_md_common.f_get_cxtidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
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
   END f_duplicar_cuadro;

    /*************************************************************************
      Inicializa un cuadro de descuentos
      param out pcuadros  : cuadros de descuento
      param out mensajes  : mensajes de error
      return              : codigo de error
   *************************************************************************/
   FUNCTION f_get_cuadrodescuento(
      pcuadros OUT t_iax_cuadrodescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_cuadrodescuento';
      verror         NUMBER;
   BEGIN
      pcuadros := t_iax_cuadrodescuento();
      pcuadros.EXTEND;
      pcuadros(pcuadros.LAST) := ob_iax_cuadrodescuento();
      pcuadros(pcuadros.LAST).cestado := 1;
      --CAMBIAR VALOR FIJO
      pcuadros(pcuadros.LAST).testado := ff_desvalorfijo(1016, pac_md_common.f_get_cxtidioma,
                                                         1);
      verror := pac_md_descuentos.f_get_descdescuentos(pcuadros(pcuadros.LAST).cdesc,
                                                       pcuadros(pcuadros.LAST).descripciones,
                                                       mensajes);
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
   END f_get_cuadrodescuento;

   FUNCTION f_get_detalle_descuento(
      pcdesc IN NUMBER,
      pcagrprod IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      ptodos IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE DEFAULT NULL,
      pffinvig IN DATE DEFAULT NULL,
      porderby IN NUMBER,
      pt_descuento IN OUT t_iax_detdescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_get_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      verror         NUMBER(8) := 0;
      vsproduc       NUMBER(6);
      vttitulo       VARCHAR2(500);
      vtrotulo       VARCHAR2(500);
      vcactivi       NUMBER(4);
      vtactivi       VARCHAR2(500);
      vcgarant       NUMBER(4);
      vtgarant       VARCHAR2(500);
      vnivel         NUMBER(1);   -- 1 productos, 2 actividad, 3 garantia
      vfinivig       DATE;
      vffinvig       DATE;
      vcmoddesc      NUMBER(1);   -- Código de modalidad del descuento
      vtmoddesc      VARCHAR2(500);
      vcdesc         NUMBER(2);
      vtdesc         VARCHAR2(500);
      vpdesc         FLOAT;   -- Porcentaje de descuento
      vquery         VARCHAR2(32000);
      vninialt       NUMBER;
      vnfinalt       NUMBER;
      cur            sys_refcursor;
      vobjdescuento  ob_iax_detdescuento;
   BEGIN
      verror := pac_descuentos.f_get_detalle_descuento(pcdesc, pcagrprod, pcramo, psproduc,
                                                       pcactivi, pcgarant, ptodos, pfinivig,
                                                       pffinvig, porderby,
                                                       pac_md_common.f_get_cxtidioma,
                                                       pcmoddesc, vquery);
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);

      IF pt_descuento IS NULL THEN
         pt_descuento := t_iax_detdescuento();
      END IF;

      LOOP
         FETCH cur
          INTO vsproduc, vttitulo, vtrotulo, vcactivi, vtactivi, vcgarant, vtgarant, vnivel,
               vcdesc, vfinivig, vcmoddesc, vtmoddesc, vpdesc, vninialt, vnfinalt, vffinvig;

         EXIT WHEN cur%NOTFOUND;
         pt_descuento.EXTEND;
         pt_descuento(pt_descuento.LAST) := ob_iax_detdescuento();
         pt_descuento(pt_descuento.LAST).nindice := pt_descuento.LAST;

         IF vcdesc IS NOT NULL THEN
            pt_descuento(pt_descuento.LAST).cdesc := vcdesc;
         ELSE
            pt_descuento(pt_descuento.LAST).cdesc := pcdesc;
         END IF;

         BEGIN
            SELECT tdesc
              INTO pt_descuento(pt_descuento.LAST).tdesc
              FROM desdesc
             WHERE cdesc = NVL(vcdesc, pcdesc)
               AND cidioma = pac_md_common.f_get_cxtidioma;
         EXCEPTION
            WHEN OTHERS THEN
               pt_descuento(pt_descuento.LAST).tdesc := NULL;
         END;

         pt_descuento(pt_descuento.LAST).sproduc := vsproduc;
         pt_descuento(pt_descuento.LAST).ttitulo := vttitulo;
         pt_descuento(pt_descuento.LAST).cactivi := vcactivi;
         pt_descuento(pt_descuento.LAST).tactivi := vtactivi;
         pt_descuento(pt_descuento.LAST).cgarant := vcgarant;
         pt_descuento(pt_descuento.LAST).tgarant := vtgarant;
         pt_descuento(pt_descuento.LAST).nivel := vnivel;
         --p_tab_error(f_sysdate, f_user, 'MD_f_get_detalle_comision', 1, vfinivig, '');
         pt_descuento(pt_descuento.LAST).finivig := vfinivig;
         pt_descuento(pt_descuento.LAST).ffinvig := vffinvig;
         pt_descuento(pt_descuento.LAST).cmoddesc := vcmoddesc;
         pt_descuento(pt_descuento.LAST).tmoddesc := vtmoddesc;
         pt_descuento(pt_descuento.LAST).pdesc := vpdesc;
         pt_descuento(pt_descuento.LAST).ninialt := vninialt;
         pt_descuento(pt_descuento.LAST).nfinalt := vnfinalt;
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           verror);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

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
      obdescuento IN OUT ob_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_md_descuentos.f_set_detalle_descuento';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      verror         NUMBER(8) := 0;
      vsproduc       NUMBER(6);
      vttitulo       VARCHAR2(500);
      vtrotulo       VARCHAR2(500);
      vcactivi       NUMBER(4);
      vtactivi       VARCHAR2(500);
      vcgarant       NUMBER(4);
      vtgarant       VARCHAR2(500);
      vnivel         NUMBER(1);   -- 1 productos, 2 actividad, 3 garantia
      vfinivig       DATE;
      vffinvig       DATE;
      vcmoddesc      NUMBER(1);   -- Código de modalidad del descuento
      vtmoddesc      VARCHAR2(500);
      vcmodali       NUMBER;
      vtdesc         VARCHAR2(500);
      vpdesc         FLOAT;   -- Porcentaje de descuento
      vquery         VARCHAR2(4000);
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcramo         NUMBER;
      cur            sys_refcursor;
      vninialt       NUMBER;
      vnfinalt       NUMBER;
   BEGIN
      obdescuento.cdesc := pcdesc;

      SELECT tdesc
        INTO obdescuento.tdesc
        FROM desdesc
       WHERE cdesc = pcdesc
         AND cidioma = pac_md_common.f_get_cxtidioma;

      vpasexec := 2;
      obdescuento.sproduc := psproduc;

      SELECT cramo, cmodali, ctipseg, ccolect
        INTO vcramo, vcmodali, vctipseg, vccolect
        FROM productos
       WHERE sproduc = psproduc;

      vpasexec := 3;
      obdescuento.ttitulo := f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 1,
                                             pac_md_common.f_get_cxtidioma);
      vpasexec := 4;
      obdescuento.trotulo := f_desproducto_t(vcramo, vcmodali, vctipseg, vccolect, 2,
                                             pac_md_common.f_get_cxtidioma);
      vpasexec := 5;
      obdescuento.cactivi := pcactivi;

      IF pcactivi IS NOT NULL THEN
         SELECT tactivi
           INTO obdescuento.tactivi
           FROM activisegu
          WHERE cidioma = pac_md_common.f_get_cxtidioma
            AND cramo = vcramo
            AND cactivi = pcactivi;

         vpasexec := 6;
      END IF;

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

      vpasexec := 7;
      obdescuento.cgarant := pcgarant;
      obdescuento.tgarant := ff_desgarantia(pcgarant, pac_md_common.f_get_cxtidioma);
      vpasexec := 8;
      obdescuento.nivel := pnivel;
      obdescuento.finivig := pfinivig;
      obdescuento.cmoddesc := pcmoddesc;
      --CAMBIAR EL VALOR FIJO
      obdescuento.tmoddesc := ff_desvalorfijo(67, pac_md_common.f_get_cxtidioma, pcmoddesc);
      vpasexec := 9;
      obdescuento.pdesc := ppdesc;
      obdescuento.ninialt := vninialt;
      obdescuento.nfinalt := vnfinalt;
      --p_tab_error(f_sysdate, f_user, 'MD_SETDETALLE', 1, 'Fi', '');
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           verror);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_detalle_descuento;

   FUNCTION f_set_traspaso_detalle_obj_bd(
      t_detdescuento IN t_iax_detdescuento,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      CURSOR c_detdescclve IS
         SELECT t.sproduc, t.cactivi, t.cgarant, t.cmoddesc, t.pdesc, t.cdesc
           FROM TABLE(t_detdescuento) t
          WHERE t.modificado = 1
            AND ROWNUM = 1;

      CURSOR c_detdesc(
         w_sproduc descprod.sproduc%TYPE,
         w_cactivi descacti.cactivi%TYPE,
         w_cgarant descgar.cgarant%TYPE,
         w_cmoddesc descprod.cmoddesc%TYPE,
         w_cdesc descprod.cdesc%TYPE,
         w_insert NUMBER) IS
         SELECT   ninialt, nfinalt
             FROM TABLE(t_detdescuento) t
            WHERE t.sproduc = w_sproduc
              AND NVL(t.cactivi, -99) = NVL(w_cactivi, -99)
              AND NVL(t.cgarant, -99) = NVL(w_cgarant, -99)
              --AND NVL(t.cmodcom, -99) = NVL(w_cmodcom, -99)
              AND t.cdesc = w_cdesc
         UNION ALL
         SELECT   ninialt, nfinalt
             FROM descacti t
            WHERE t.sproduc = w_sproduc
              AND w_cactivi IS NOT NULL
              AND NVL(t.cactivi, -99) = NVL(w_cactivi, -99)
              AND w_cgarant IS NULL
              AND t.cdesc = w_cdesc
              AND w_insert = 1
         UNION ALL
         SELECT   ninialt, nfinalt
             FROM descgar t
            WHERE t.sproduc = w_sproduc
              AND w_cgarant IS NOT NULL
              AND NVL(t.cgarant, -99) = NVL(w_cgarant, -99)
              AND NVL(t.cactivi, -99) = NVL(w_cactivi, -99)
              AND t.cdesc = w_cdesc
              AND w_insert = 1
         UNION ALL
         SELECT   ninialt, nfinalt
             FROM descprod t
            WHERE t.sproduc = w_sproduc
              AND w_cgarant IS NULL
              AND w_cactivi IS NULL
              AND t.cdesc = w_cdesc
              AND w_insert = 1
         ORDER BY ninialt, nfinalt;

      /*SELECT *
        FROM (SELECT t.ninialt inicial_actual,
                     LAG(t.nfinalt) OVER(ORDER BY t.ninialt) anterior_final,
                     COUNT(*) OVER() contador
                FROM TABLE(t_detdescuento) t
               WHERE t.sproduc = w_sproduc
                 AND NVL(t.cactivi, -99) = NVL(w_cactivi, -99)
                 AND NVL(t.cgarant, -99) = NVL(w_cgarant, -99)
                 AND NVL(t.cmoddesc, -99) = NVL(w_cmoddesc, -99))
       WHERE anterior_final IS NOT NULL;*/
      c_detdescclve_r c_detdescclve%ROWTYPE;
      vobjectname    VARCHAR2(500) := 'pac_iax_descuentos.f_set_traspaso_detalle_obj_bd';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_cont         NUMBER := 0;
      e_salir        EXCEPTION;
      vninialt       NUMBER := 0;
      vinsert        NUMBER := 0;
   BEGIN
      --p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 0, 'INI', '');
      IF t_detdescuento IS NOT NULL
         AND t_detdescuento.COUNT > 0 THEN
         OPEN c_detdescclve;

         FETCH c_detdescclve
          INTO c_detdescclve_r;

         CLOSE c_detdescclve;

         BEGIN
            FOR c IN c_detdesc(c_detdescclve_r.sproduc, c_detdescclve_r.cactivi,
                               c_detdescclve_r.cgarant, c_detdescclve_r.cmoddesc,
                               c_detdescclve_r.cdesc, vinsert) LOOP
               IF vninialt = 0 THEN
                  vninialt := c.ninialt - 1;
               END IF;

               IF NOT(vninialt + 1) = c.ninialt THEN
                  vnumerr := 1;
                  RAISE e_salir;
               ELSE
                  vninialt := c.nfinalt;
               END IF;
            END LOOP;
         EXCEPTION
            WHEN e_salir THEN
               NULL;
         END;

         IF vnumerr = 1 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903120);
            RETURN 1;
         END IF;

         FOR i IN t_detdescuento.FIRST .. t_detdescuento.LAST LOOP
            IF t_detdescuento.EXISTS(i) THEN
               IF t_detdescuento(i).modificado = 1 THEN
                  v_cont := 1;
                  vnumerr :=
                     pac_descuentos.f_set_detalle_descuento(t_detdescuento(i).sproduc,
                                                            t_detdescuento(i).cactivi,
                                                            t_detdescuento(i).cgarant,
                                                            t_detdescuento(i).nivel,
                                                            t_detdescuento(i).finivig,
                                                            t_detdescuento(i).cmoddesc,
                                                            t_detdescuento(i).cdesc,
                                                            t_detdescuento(i).pdesc,
                                                            t_detdescuento(i).ninialt,
                                                            t_detdescuento(i).nfinalt);

                  IF vnumerr <> 0 THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
                     RAISE e_object_error;
                  END IF;
               END IF;
            END IF;
         END LOOP;
      END IF;

      IF v_cont = 0 THEN
         --p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 2, 'SENSE CANVIS', '');
         RETURN -1;   --Comprobar que no se ha hecho ningún cambio
      END IF;

      --p_tab_error(f_sysdate, f_user, 'MD_SETDET_OBJ_BD', 3, 'Fi', vnumerr);
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
         IF c_detdescclve%ISOPEN THEN
            CLOSE c_detdescclve;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_set_traspaso_detalle_obj_bd;

   FUNCTION f_get_hist_cuadrodescuento(
      pcdesc IN NUMBER,
      pdetdescuento OUT t_iax_cuadrodescuento,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'PCDESC:' || pcdesc;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_hist_cuadrodescuento';
      vsquery        VARCHAR2(1000);
      verror         NUMBER;
      cur            sys_refcursor;
      vcdesc         NUMBER;
      vtdesc         VARCHAR2(500);
      vctipo         NUMBER;
      vttipo         VARCHAR2(500);
      vfinivig       DATE;
      vffinvig       DATE;
      vcestado       NUMBER;
   BEGIN
      verror := pac_descuentos.f_get_hist_cuadrodescuento(pcdesc,
                                                          pac_md_common.f_get_cxtidioma,
                                                          vsquery);
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pdetdescuento IS NULL THEN
         pdetdescuento := t_iax_cuadrodescuento();
      END IF;

      LOOP
         FETCH cur
          INTO vcdesc, vtdesc, vctipo, vfinivig, vffinvig, vcestado;

         EXIT WHEN cur%NOTFOUND;
         pdetdescuento.EXTEND;
         pdetdescuento(pdetdescuento.LAST) := ob_iax_cuadrodescuento();
         pdetdescuento(pdetdescuento.LAST).cdesc := vcdesc;
         pdetdescuento(pdetdescuento.LAST).tdesc := vtdesc;
         pdetdescuento(pdetdescuento.LAST).ctipo := vctipo;
         pdetdescuento(pdetdescuento.LAST).finivig := vfinivig;
         pdetdescuento(pdetdescuento.LAST).ffinvig := vffinvig;
         pdetdescuento(pdetdescuento.LAST).cestado := vcestado;
         --CAMBIAR VALOR FIJO
         pdetdescuento(pdetdescuento.LAST).ttipo :=
                                  ff_desvalorfijo(1015, pac_md_common.f_get_cxtidioma, vctipo);
         pdetdescuento(pdetdescuento.LAST).testado :=
                                ff_desvalorfijo(1016, pac_md_common.f_get_cxtidioma, vcestado);
         verror :=
            pac_md_descuentos.f_get_descdescuentos
                                             (pcdesc,
                                              pdetdescuento(pdetdescuento.LAST).descripciones,
                                              mensajes);
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_hist_cuadrodescuento;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
         := 'psproduc:' || psproduc || ' pcactivi:' || pcactivi || ' pcgarant:' || pcgarant
            || ' pcnivel:' || pcnivel;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_porproducto';
      vsquery        VARCHAR2(1000);
      verror         NUMBER;
      cur            sys_refcursor;
      vcdesc         NUMBER;
      vtdesc         VARCHAR2(500);
      vpdesc         NUMBER;
      vcmoddesc      NUMBER;
      vtmoddesc      VARCHAR2(500);
      vninialt       NUMBER;
      vnfinalt       NUMBER;
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

      verror := pac_descuentos.f_get_porproducto(psproduc, pcactivi, pcgarant, pcnivel,
                                                 pcfinivig, pac_md_common.f_get_cxtidioma,
                                                 vsquery);
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pt_descuento IS NULL THEN
         pt_descuento := t_iax_detdescuento();
      END IF;

      LOOP
         FETCH cur
          INTO vtdesc, vcdesc, vpdesc, vninialt, vnfinalt, vcmoddesc, vtmoddesc;

         EXIT WHEN cur%NOTFOUND;
         pt_descuento.EXTEND;
         pt_descuento(pt_descuento.LAST) := ob_iax_detdescuento();
         pt_descuento(pt_descuento.LAST).cdesc := vcdesc;
         pt_descuento(pt_descuento.LAST).tdesc := vtdesc;
         pt_descuento(pt_descuento.LAST).pdesc := vpdesc;
         pt_descuento(pt_descuento.LAST).cmoddesc := vcmoddesc;
         pt_descuento(pt_descuento.LAST).tmoddesc := vtmoddesc;
         pt_descuento(pt_descuento.LAST).sproduc := psproduc;
         pt_descuento(pt_descuento.LAST).cactivi := pcactivi;
         pt_descuento(pt_descuento.LAST).cgarant := pcgarant;
         pt_descuento(pt_descuento.LAST).nivel := pcnivel;
         pt_descuento(pt_descuento.LAST).ninialt := vninialt;
         pt_descuento(pt_descuento.LAST).nfinalt := vnfinalt;
      END LOOP;

      CLOSE cur;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, ' ', 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN 1;
   END f_get_porproducto;

      /****************************************************************
      Duplica el detalle de descuento a partir de un cdesc y una fecha
      param in pcdesc   : codigo de descuento
      param in pfinivi   : Fecha de inicio de vigencia
      param out mensajes   : mensajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_dup_det_descuento(
      pcdesc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000) := 'Param.: pcdesc:' || pcdesc || ' pfinivi:' || pfinivig;
      vobjectname    VARCHAR2(200) := 'PAC_MD_DESCUENTO.f_dup_det_descuento';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcdesc IS NULL
         OR pfinivig IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_descuentos.f_dup_det_descuento(pcdesc, pfinivig);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
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
   END f_dup_det_descuento;

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
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                            := 'paràmetres - psproduc: ' || psproduc || ' - pctipo:' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_lsfechasvigencia';
      vquery         VARCHAR2(2000);
   BEGIN
      IF psproduc IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Productos
      IF pctipo = 1 THEN
         vquery := 'select distinct finivig from descprod'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')'
                   || ' order by finivig';
      ELSIF pctipo = 2 THEN
         -- ACTIVIDAD
         vquery := 'select distinct finivig from descacti'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')'
                   || ' order by finivig';
      ELSIF pctipo = 3 THEN
         -- ACTIVIDAD
         vquery := 'select distinct finivig from descgar'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')'
                   || ' order by finivig';
      ELSIF pctipo = 4 THEN
         vquery := 'select distinct finivig from descprod'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')' || ' UNION';
         -- ACTIVIDAD
         vquery := vquery || ' select distinct finivig from descacti'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')' || ' UNION ';
         vquery := vquery || ' select distinct finivig from descgar'
                   || ' where (cramo, cmodali, ctipseg, ccolect) in'
                   || ' (select cramo, cmodali, ctipseg, ccolect'
                   || ' from productos where  sproduc = ' || psproduc || ')'
                   || ' order by finivig desc';
      END IF;

      -- Bug 0012822 - 09/02/2010 - JMF: Evitar que es puguin seleccionar les causes (3,4,5,8)
      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsfechasvigencia;

/****************************************************************
      Duplica el cuadro de prod
      param in pcsproduc   : codigo de producto
      param in pfinivi   : Fecha de inicio de vigencia
      param out mensajes   : mensajes de error

      return : codigo de error
   *************************************************************************/
   FUNCTION f_duplicar_cuadro_prod(
      pcsproduc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(4000)
                              := 'Param.: pcsproduc:' || pcsproduc || ' pfinivig:' || pfinivig;
      vobjectname    VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_duplicar_cuadro_prod';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcsproduc IS NULL
         OR pfinivig IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_descuentos.f_duplicar_cuadro_prod(pcsproduc, pfinivig);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
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
   END f_duplicar_cuadro_prod;

   FUNCTION f_get_alturas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi;
      vobjectname    VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_get_alturas';
      vquery         VARCHAR2(2000);
      vnumerr        NUMBER;
   BEGIN
      IF pcgarant IS NULL
         AND pcactivi IS NULL THEN
         vquery :=
            'SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.cdesc,
       dc.tdesc, ff_desvalorfijo(67, t.cidioma, '
            --CAMBIAR VALOR FIJO
            || pcmoddesc
            || ') tmoddesc, c.pdesc, c.ninialt, c.nfinalt
  FROM productos p, titulopro t, activisegu a, garangen g, desdesc dc, descprod c
 WHERE p.sproduc = '
            || psproduc
            || ' AND p.cramo = t.cramo
   AND p.cmodali = t.cmodali
   AND p.ctipseg = t.ctipseg
   AND p.ccolect = t.ctipseg
   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
   AND p.cramo = a.cramo(+)
   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
   AND a.cactivi(+) = '
            || NVL(pcactivi, 'NULL') || ' AND g.cgarant(+) = ' || NVL(pcgarant, 'NULL')
            || ' AND g.cidioma(+) = t.cidioma
   AND dc.cdesc = ' || pcdesc || ' AND dc.cidioma = t.cidioma
   and c.CDESC(+) = ' || pcdesc
            || ' and c.SPRODUC(+) = p.sproduc
   and c.FINIVIG(+) = to_date(''' || TO_CHAR(pfinivig, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      ELSIF pcgarant IS NULL THEN
         vquery :=
            'SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.cdesc,
       dc.tdesc, ff_desvalorfijo(67, t.cidioma, '
            --CAMBIAR VALOR FIJO
            || pcmoddesc
            || ') tmoddesc, c.pdesc, c.ninialt, c.nfinalt
  FROM productos p, titulopro t, activisegu a, garangen g, desdesc dc, descacti c
 WHERE p.sproduc = '
            || psproduc
            || ' AND p.cramo = t.cramo
   AND p.cmodali = t.cmodali
   AND p.ctipseg = t.ctipseg
   AND p.ccolect = t.ctipseg
   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
   AND p.cramo = a.cramo(+)
   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
   AND a.cactivi(+) = '
            || NVL(pcactivi, 'NULL') || ' AND g.cgarant(+) = ' || NVL(pcgarant, 'NULL')
            || ' AND g.cidioma(+) = t.cidioma
   AND dc.cdesc = ' || pcdesc || ' AND dc.cidioma = t.cidioma
   and c.CDESC(+) = ' || pcdesc
            || ' and c.SPRODUC(+) = p.sproduc
            and c.cactivi(+) = ' || pcactivi || ' and c.FINIVIG(+) = to_date('''
            || TO_CHAR(pfinivig, 'dd/mm/yyyy') || ''',''dd/mm/yyyy'')';
      ELSE
         vquery :=
            'SELECT p.sproduc, t.ttitulo tproduc, a.cactivi, a.tactivi, g.cgarant, g.tgarant, dc.cdesc,
       dc.tdesc, ff_desvalorfijo(67, t.cidioma, '
            --CAMBIAR VALOR FIJO
            || pcmoddesc
            || ') tmoddesc, c.pdesc, c.ninialt, c.nfinalt
  FROM productos p, titulopro t, activisegu a, garangen g, desdesc dc, descgar c
 WHERE p.sproduc = '
            || psproduc
            || ' AND p.cramo = t.cramo
   AND p.cmodali = t.cmodali
   AND p.ctipseg = t.ctipseg
   AND p.ccolect = t.ctipseg
   AND t.cidioma = pac_md_common.F_GET_CXTIDIOMA()
   AND p.cramo = a.cramo(+)
   AND a.cidioma(+) = pac_md_common.F_GET_CXTIDIOMA()
   AND a.cactivi(+) = '
            || NVL(pcactivi, 'NULL') || ' AND g.cgarant(+) = ' || NVL(pcgarant, 'NULL')
            || ' AND g.cidioma(+) = t.cidioma
   AND dc.cdesc = ' || pcdesc || ' AND dc.cidioma = t.cidioma
   and c.CDESC(+) = ' || pcdesc
            || ' and c.SPRODUC(+) = p.sproduc
            and c.cactivi(+) = ' || pcactivi || ' and c.cgarant(+) = ' || pcgarant
            || ' and c.FINIVIG(+) = to_date(''' || TO_CHAR(pfinivig, 'dd/mm/yyyy')
            || ''',''dd/mm/yyyy'')';
      END IF;

      cur := pac_md_listvalores.f_opencursor(vquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam,
                                           vnumerr);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_get_alturas;

   FUNCTION f_del_altura(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcdesc IN NUMBER,
      pcmoddesc IN NUMBER,
      pfinivig IN DATE,
      pninialt IN NUMBER,
      pnivel IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi;
      vobjectname    VARCHAR2(200) := 'PAC_MD_DESCUENTOS.f_del_altura';
      vquery         VARCHAR2(2000);
      vnumerr        NUMBER;
      vcount         NUMBER;
   BEGIN
      IF pnivel = 1 THEN
         DELETE      descprod
               WHERE sproduc = psproduc
                 AND cdesc = pcdesc
                 AND cmoddesc = pcmoddesc
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
      ELSIF pnivel = 2 THEN
         DELETE      descacti
               WHERE sproduc = psproduc
                 AND cactivi = pcactivi
                 AND cdesc = pcdesc
                 AND cmoddesc = pcmoddesc
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
      ELSE
         DELETE      descgar
               WHERE sproduc = psproduc
                 AND cactivi = pcactivi
                 AND cgarant = pcgarant
                 AND cdesc = pcdesc
                 AND cmoddesc = pcmoddesc
                 AND finivig = pfinivig
                 AND ninialt = pninialt;
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
   END f_del_altura;
END pac_md_descuentos;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCUENTOS" TO "PROGRAMADORESCSI";
