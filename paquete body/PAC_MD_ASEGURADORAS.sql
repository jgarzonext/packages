--------------------------------------------------------
--  DDL for Package Body PAC_MD_ASEGURADORAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ASEGURADORAS" AS
/*************************************************************************
   FUNCTION F_GET_TRASPASO
   Funci�n que sirve para recuperar los datos de una/varias aseguradoras
        1.  PCEMPRES: Tipo num�rico. Par�metro de entrada. C�digo de traspaso
        2.  PCODASEG: Tipo num�rico. Par�metro de entrada. C�digo de traspaso
        3.  PCODDIGO: Tipo num�rico. Par�metro de entrada. C�digo del plan
        4.  PCODDEP: Tipo num�rico. Par�metro de entrada. C�digo de la depositaria
        5.  PCODDGS: Tipo num�rico. Par�metro de entrada. C�digo DGS de la aseguradora
        6.  pfdatos: Tipo num�rico. Par�metro de Salida. Cursor con la/las aseguradoras planes requeridas.

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
      aseguradoras IN OUT t_iax_aseguradoras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vcur           sys_refcursor;
      aseg           ob_iax_aseguradoras := ob_iax_aseguradoras();
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'par�metros - pcempres= ' || pcempres || ' pccodaseg=' || pccodaseg
            ||   -- solo obligatorios
              ' pccodigo= ' || pccodigo || ' pccoddep=' || pccoddep || ' pccoddgs= '
            || pccoddgs;
      vobject        VARCHAR2(200) := 'PAC_IAX_ASEGURADORAS.f_get_aseguradoras';
      v_ctrasp       NUMBER(1);
   BEGIN
      vpasexec := 1;
      v_result := pac_aseguradoras.f_get_aseguradoras(pcempres, pccodaseg, pccodigo, pccoddep,
                                                      pccoddgs, pnombre, pctrasp, vcur);

      IF v_result <> 0 THEN
         RAISE e_object_error;
      END IF;

      aseguradoras := t_iax_aseguradoras();

      LOOP
         FETCH vcur
          INTO aseg.ccodaseg, aseg.sperson, aseg.descripcio,
                                                            --aseg.ccodban, aseg.cbancar, aseg.ccoddep, aseg.ctipban,
                                                            aseg.cempres, aseg.coddgs,
               aseg.ccodigo, aseg.tnombre, aseg.clistblanc, v_ctrasp;

         IF aseg.ccodaseg IS NOT NULL THEN
            v_result := pac_md_pensiones.f_get_pdepositarias(NULL, aseg.ccodaseg, NULL, NULL,
                                                             NULL, NULL, aseg.l_depositarias,
                                                             mensajes);
         END IF;

         EXIT WHEN vcur%NOTFOUND;
         aseguradoras.EXTEND;
         aseguradoras(aseguradoras.LAST) := aseg;
         aseg := ob_iax_aseguradoras();
      END LOOP;

      CLOSE vcur;

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
      ob_aseg IN OUT ob_iax_aseguradoras,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_MD_ASEGURADORAS.f_get_ob_aseguradoras';
      vparam         VARCHAR2(2000)
                              := 'par�metros -  ccodaseg: ' || ccodaseg || 'coddgs:' || coddgs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER;
      aseg           t_iax_aseguradoras;
   BEGIN
      vnumerr := pac_md_aseguradoras.f_get_aseguradoras(NULL, ccodaseg, NULL, NULL, coddgs,
                                                        NULL, NULL, aseg, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      IF aseg.COUNT = 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 9900958);
         RETURN 1;
      END IF;

      ob_aseg := aseg(1);
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
   Funci�n que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo num�rico. Par�metro de entrada. C�digo de la aseguradora
        2.  PCODDGS: Tipo num�rico. Par�metro de entrada. C�digo DGS de la aseguradora
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras(
      pccodaseg IN NUMBER,
      pccoddgs IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                        := 'par�metros - pccodaseg= ' || pccodaseg || ' pccoddgs=' || pccoddgs;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_ASEGURADORAS.f_del_aseguradoras';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodaseg IS NULL
         AND pccoddgs IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_aseguradoras.f_del_aseguradoras(pccodaseg, pccoddgs);
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
   Funci�n que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo num�rico. Par�metro de entrada. C�digo de la aseguradora
        2.  PCCODIGO: Tipo num�rico. Par�metro de entrada. C�digo del plan
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras_planes(
      pccodaseg IN NUMBER,
      pccodigo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                       := 'par�metros - pccodaseg= ' || pccodaseg || ' pccodaseg=' || pccodigo;   -- solo obligatorios
      vobject        VARCHAR2(200) := 'PAC_MD_ASEGURADORAS.f_del_aseguradoras_planes';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF pccodaseg IS NULL
         OR pccodigo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_aseguradoras.f_del_aseguradoras_planes(pccodaseg, pccodigo);
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
Funci�n que sirve para insertar o actualizar datos del aseguradoras.
Par�metros

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vnumerr        NUMBER(1) := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par�metros - vccodaseg:' || vccodaseg;
      vobject        VARCHAR2(200) := 'PAC_MD_aseguradoras.F_SET_ASEGURADORAS';
      v_fich         VARCHAR2(400);
   BEGIN
      vnumerr := pac_aseguradoras.f_set_aseguradoras(vccodaseg, vsperson, vccodban, vcbancar,
                                                     vcempres, vccoddep, vccoddgs, vctipban,
                                                     vclistblanc);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
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
Funci�n que sirve para recuperar el nommbre de la aseguradora
Par�metros

      vsperson in NUMBER
Retorna el VARCHAR con su nombre (null si va mal)
*************************************************************************/
   FUNCTION f_get_nomaseg(vsperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      v_result       VARCHAR2(500);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'par�metros - vsperson= ' || vsperson;
      vobject        VARCHAR2(200) := 'PAC_MD_ASEGURADORAS.f_get_nomaseg';
   BEGIN
      vpasexec := 1;

      --Comprovem els parametres d'entrada.
      IF vsperson IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      v_result := pac_aseguradoras.f_get_nomaseg(vsperson);
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
END pac_md_aseguradoras;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ASEGURADORAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ASEGURADORAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ASEGURADORAS" TO "PROGRAMADORESCSI";
