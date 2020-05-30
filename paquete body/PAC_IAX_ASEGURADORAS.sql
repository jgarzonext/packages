--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ASEGURADORAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_ASEGURADORAS" AS
/*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar los datos de una/varias aseguradoras
        1.  PCEMPRES: Tipo numérico. Parámetro de entrada. Código de traspaso
        2.  PCODASEG: Tipo numérico. Parámetro de entrada. Código de traspaso
        3.  PCODDIGO: Tipo numérico. Parámetro de entrada. Código del plan
        4.  PCODDEP: Tipo numérico. Parámetro de entrada. Código de la depositaria
        5.  PCODDGS: Tipo VARCHAR2. Parámetro de entrada. Código DGS de la aseguradora
        6.  pfdatos: Tipo numérico. Parámetro de Salida. Cursor con la/las aseguradoras planes requeridas.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_get_aseguradoras(
      pcempres IN NUMBER,
      pccodaseg IN NUMBER,
      pccodigo IN NUMBER,
      pccoddep IN NUMBER,
      pccoddgs IN VARCHAR2,
      pnombre IN VARCHAR2,
      pctrasp IN NUMBER,   --indica si solo consultamos las de ctrasp = 1 o todas
      aseguradoras OUT t_iax_aseguradoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'parámetros - pcempres= ' || pcempres || ' pccodaseg=' || pccodaseg
            ||   -- solo obligatorios
              ' pccodigo= ' || pccodigo || ' pccoddep=' || pccoddep || ' pccoddgs= '
            || pccoddgs;
      vobject        VARCHAR2(200) := 'PAC_IAX_ASEGURADORAS.f_get_aseguradoras';
   BEGIN
      vpasexec := 1;
      v_result := pac_md_aseguradoras.f_get_aseguradoras(pcempres, pccodaseg, pccodigo,
                                                         pccoddep, pccoddgs, pnombre, pctrasp,
                                                         aseguradoras, mensajes);

      IF v_result <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_aseguradoras;

   FUNCTION f_get_ob_aseguradoras(
      ccodaseg IN VARCHAR2,
      coddgs IN VARCHAR2,
      ob_aseg OUT ob_iax_aseguradoras,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ASEGURADORAS.f_get_ob_aseguradoras';
      vparam         VARCHAR2(2000)
                              := 'parámetros -  ccodaseg: ' || ccodaseg || 'coddgs:' || coddgs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      aseg           t_iax_aseguradoras;
   BEGIN
      vnumerr := pac_md_aseguradoras.f_get_ob_aseguradoras(ccodaseg, coddgs, ob_aseg,
                                                           mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_get_ob_aseguradoras;

/*************************************************************************
   FUNCTION f_del_aseguradoras
   Función que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo numérico. Parámetro de entrada. Código de la aseguradora
        2.  PCODDGS: Tipo VARCHAR2. Parámetro de entrada. Código DGS de la aseguradora
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras(
      pccodaseg IN NUMBER,
      pccoddgs IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                        := 'parámetros - pccodaseg= ' || pccodaseg || ' pccoddgs=' || pccoddgs;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_ASEGURADORAS.f_del_aseguradoras';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodaseg IS NULL
         AND pccoddgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_aseguradoras.f_del_aseguradoras(pccodaseg, pccoddgs, mensajes);

      IF v_result <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_result);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_aseguradoras;

/*************************************************************************
   FUNCTION f_del_aseguradoras_planes
   Función que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo numérico. Parámetro de entrada. Código de la aseguradora
        2.  PCCODIGO: Tipo numérico. Parámetro de entrada. Código del plan
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras_planes(
      pccodaseg IN NUMBER,
      pccodigo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                       := 'parámetros - pccodaseg= ' || pccodaseg || ' pccodaseg=' || pccodigo;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_IAX_ASEGURADORAS.f_del_aseguradoras_planes';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodaseg IS NULL
         OR pccodigo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_aseguradoras.f_del_aseguradoras_planes(pccodaseg, pccodigo, mensajes);

      IF v_result <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_result);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_aseguradoras_planes;

/*************************************************************************
       F_SET_ASEGURADORAS
Función que sirve para insertar o actualizar datos del aseguradoras.
Parámetros

      vccodaseg in VARCHAR2,
      vsperson in NUMBER,
      vccodban in NUMBER,
      vcbancar in VARCHAR2,
      vcempres in NUMBER,
      vccoddep in NUMBER,
      vccoddgs in VARCHAR2,
      vctipban in NUMBER)

Retorna 0 ok/ 1 KO
*************/
   FUNCTION f_set_aseguradoras(
      vccodaseg VARCHAR2,
      vsperson NUMBER,
      vccodban NUMBER,
      vcbancar VARCHAR2,
      vcempres NUMBER,
      vccoddep NUMBER,
      vccoddgs VARCHAR2,
      vctipban NUMBER,
      vclistblanc NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - vccodaseg:' || vccodaseg;
      vobject        VARCHAR2(200) := 'PAC_IAX_aseguradoras.F_SET_ASEGURADORAS';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_md_aseguradoras.f_set_aseguradoras(vccodaseg, vsperson, vccodban,
                                                        vcbancar, vcempres, vccoddep,
                                                        vccoddgs, vctipban, vclistblanc,
                                                        mensajes);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 109904);
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_aseguradoras;

/*************************************************************************
       F_GET_NOMASEG
Función que sirve para recuperar el nommbre de la aseguradora
Parámetros

      vsperson in NUMBER
Retorna el VARCHAR con su nombre (null si va mal)
*************************************************************************/
   FUNCTION f_get_nomaseg(vsperson IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - vsperson= ' || vsperson;
      vobject        VARCHAR2(200) := 'PAC_IAX_ASEGURADORAS.f_get_nomaseg';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF vsperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_md_aseguradoras.f_get_nomaseg(vsperson, mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_nomaseg;
END pac_iax_aseguradoras;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ASEGURADORAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ASEGURADORAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ASEGURADORAS" TO "PROGRAMADORESCSI";
