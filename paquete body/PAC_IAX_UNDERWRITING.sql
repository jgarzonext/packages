--------------------------------------------------------
--  DDL for Package Body PAC_IAX_UNDERWRITING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_UNDERWRITING" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_UNDERWRITING
      PROPÃ“SITO: Recupera la informaciÃ³n de la poliza guardada en la base de datos
                     a un nivel independiente.

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        10/06/2015   RSC             1. Creación del package.
      1.2        29/07/2015   IGIL            2. Creacion funcion f_get_evidences
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_activo_undw_if01(
      psproduc IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc=' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_UNDERWRITING.f_connect_undw_if01';
      vres           NUMBER;
   BEGIN
      vres := pac_md_underwriting.f_activo_undw_if01(psproduc, ptablas, mensajes);
      RETURN vres;
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
   END f_activo_undw_if01;

   /*************************************************************************
     funcion que retorna la lista de enfermedades relacionadas de Allfinanz
   *************************************************************************/
   FUNCTION f_get_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      --
      vpasexec       NUMBER := 1;
      vparam         VARCHAR2(100)
                       := 'parametros - psseguro = ' || psseguro || ' pnmovimi = ' || pnmovimi;
      vobject        VARCHAR2(50) := 'PAC_IAX_UNDERWRITING.f_get_icd10codes';
      v_cur          sys_refcursor;
   --
   BEGIN
      --
      v_cur := pac_md_underwriting.f_get_icd10codes(psseguro, pnmovimi, mensajes);
      --
      vpasexec := 2;
      --
      RETURN v_cur;
   EXCEPTION
      --
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_icd10codes;

   /*************************************************************************
     funcion que convierte un texto con comodin
   *************************************************************************/
   FUNCTION f_convertir_varchar_coleccion(pparams IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_info IS
      --
      vobjectname    VARCHAR2(500) := 'PAC_IAX_UNDERWRITING.f_convertir_varchar_coleccion';
      vparam         VARCHAR2(1000) := 'parámetros - pparams : ' || pparams;
      vpasexec       NUMBER(5) := 1;
      vtinfo         t_iax_info := t_iax_info();
      valor_columna  VARCHAR2(100);
      vinfo          ob_iax_info;
      pos            NUMBER;
      valorparam     VARCHAR2(4000);
   --
   BEGIN
      --
      vtinfo := t_iax_info();
      valorparam := pparams;

      --
      WHILE NVL(LENGTH(valorparam), 0) > 0 LOOP
         --
         pos := INSTR(valorparam, ',');

         IF pos > 0 THEN
            --
            valor_columna := SUBSTR(valorparam, 1, pos - 1);
            valorparam := SUBSTR(valorparam, pos + 1, LENGTH(valorparam));
         --
         ELSE
            --
            valor_columna := valorparam;
            valorparam := NULL;
         --
         END IF;

         --
         IF valor_columna IS NOT NULL THEN
            --
            vinfo := ob_iax_info();
            vtinfo.EXTEND;
            vinfo.nombre_columna := 'CINDEX';
            vinfo.valor_columna := valor_columna;
            vtinfo(vtinfo.LAST) := vinfo;
         --
         END IF;
      --
      END LOOP;

      --
      RETURN vtinfo;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_convertir_varchar_coleccion;

   /*************************************************************************
     funcion que guarda las enfermedades relacionadas al rechazar un seguro
   *************************************************************************/
   FUNCTION f_setrechazo_icd10codes(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE,
      pcindex IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vparams        t_iax_info;
      vpasexec       NUMBER(5) := 1;
      vobjectname    VARCHAR2(500) := 'PAC_IAX_UNDERWRITING.f_setrechazo_icd10codes';
      vparam         VARCHAR2(1000)
         := 'parámetros - psseguro : ' || psseguro || ' pnmovimi ' || pnmovimi || ' pcindex '
            || pcindex;
      verror         NUMBER := 0;
   --
   BEGIN
      --
      IF pcindex IS NOT NULL THEN
         --
         vparams := f_convertir_varchar_coleccion(pcindex, mensajes);
         --
         vpasexec := 2;
         --
         verror := pac_md_underwriting.f_setrechazo_icd10codes(psseguro, pnmovimi, vparams,
                                                               mensajes);

         --
         IF verror <> 0 THEN
            RAISE e_object_error;
         END IF;

         --
         COMMIT;
      --
      END IF;

      --
      RETURN verror;
   EXCEPTION
      WHEN e_object_error THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         ROLLBACK;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobjectname, 1000001, vpasexec, vparam,
                                           NULL, SQLCODE, SQLERRM);
         RETURN 1;
   END f_setrechazo_icd10codes;

   /*************************************************************************
       Recupera la lista de evidencias medicas
       param out mensajes  : mensajes de error
       return              : cursor
    *************************************************************************/
   FUNCTION f_get_evidences(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := ' ';
      vobject        VARCHAR2(200) := 'PAC_UNDERWRITING.f_get_evidences';
      vquery         VARCHAR2(2000);
   BEGIN
      RETURN pac_md_underwriting.f_get_evidences(mensajes);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN cur;
   END f_get_evidences;
END pac_iax_underwriting;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_UNDERWRITING" TO "PROGRAMADORESCSI";
