--------------------------------------------------------
--  DDL for Package Body PAC_IAX_MARCAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_MARCAS" AS
  /******************************************************************************
        NOMBRE:       PAC_MD_MARCAS
        PROP¿SITO:  Funciones para gestionar las marcas

        REVISIONES:
        Ver        Fecha        Autor   Descripci¿n
       ---------  ----------  ------   ------------------------------------
        1.0        01/08/2016   HRE     1. Creaci¿n del package.
  ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
  /*************************************************************************
    FUNCTION f_get_marcas
    Permite obtener la informacion de las marcas
    param in pcempres  : codigo de la empresa
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas';
  BEGIN
    cur := pac_md_marcas.f_get_marcas(pcempres, mensajes);
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
  END f_get_marcas;


  FUNCTION f_obtiene_marcas(pcempres IN NUMBER, psperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
    RETURN t_iax_marcas IS
    t_marcas t_iax_marcas;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas';
  BEGIN

    t_marcas := pac_md_marcas.f_obtiene_marcas(pcempres, psperson, mensajes);
    RETURN t_marcas;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);


      RETURN t_marcas;
  END f_obtiene_marcas;

  /*************************************************************************
    FUNCTION f_get_marcas_per
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_per';
  BEGIN
       p_tab_error(f_sysdate, f_user, 'PAC_IAX_MARCAS. F_GET_MARCAS', 777, vparam,
                                             'PASO 1, pcempres:'||pcempres||' psperson:'||psperson);


    cur := pac_md_marcas.f_get_marcas_per(pcempres, psperson, mensajes);
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

   END f_get_marcas_per;
  /*************************************************************************
    FUNCTION f_get_marcas_perhistorico
    Permite obtener la informacion de todos los movimientos de una marca
    asociada a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_perhistorico(pcempres IN NUMBER,
                                     psperson IN NUMBER,
                                     pcmarca  IN VARCHAR2,
                                     mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_perhistorico';
  BEGIN
    cur := pac_md_marcas.f_get_marcas_perhistorico(pcempres, psperson, pcmarca, mensajes);
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

   END f_get_marcas_perhistorico;
  /*************************************************************************
    FUNCTION f_set_marcas_per
    Permite asociar marcas a la persona de forma manual
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_set_marcas_per(pcempres IN NUMBER,
                            psperson IN NUMBER,
                            t_marcas   IN T_IAX_MARCAS,
                            mensajes IN OUT t_iax_mensajes)

    RETURN NUMBER IS
    ob_marcas  ob_iax_marcas;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_set_marcas_per';
    vnumerr  NUMBER (8):=0;

    BEGIN

      vnumerr := pac_md_marcas.f_set_marcas_per(pcempres, psperson, t_marcas, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000005, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000006, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);
       ROLLBACK;
       RETURN 1;

    END f_set_marcas_per;


/*************************************************************************
    FUNCTION f_set_marca_automatica
    Permite asociar   marcas a la persona en procesos del Sistema
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_set_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER IS
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psperson='||psperson||' pcmarca:'||pcmarca;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_set_marca_automatica';
    vnumerr  NUMBER (8):=0;

    BEGIN

      vnumerr := pac_md_marcas.f_set_marca_automatica(pcempres, psperson, pcmarca, mensajes);

	    IF vnumerr<>0 THEN
	      RAISE e_object_error;
	    END IF;

	    COMMIT;
	    RETURN 0;
	EXCEPTION
	  WHEN e_param_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000005, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN e_object_error THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000006, vpasexec, vparam);
       ROLLBACK;
       RETURN 1;
    WHEN OTHERS THEN
       pac_iobj_mensajes.p_tratarmensaje (mensajes, vobject, 1000001, vpasexec, vparam, psqcode=>SQLCODE, psqerrm=>SQLERRM);
       ROLLBACK;
       RETURN 1;
  END f_set_marca_automatica;

/*************************************************************************
    FUNCTION f_del_marca_automatica
    Permite desactivar marcas a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_del_marca_automatica(pcempres IN NUMBER,
                                  psperson IN NUMBER,
                                  pcmarca  IN VARCHAR2,
                                  mensajes IN OUT t_iax_mensajes)
    RETURN NUMBER IS
  BEGIN
     RETURN 0;
  END f_del_marca_automatica;
--
  /*************************************************************************
    FUNCTION f_get_marcas_poliza
    Permite obtener la informacion de las marcas asociadas a una persona
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : ref cursor
  *************************************************************************/
  FUNCTION f_get_marcas_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
    RETURN sys_refcursor IS
    cur      sys_refcursor;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psseguro='||psseguro||' ptablas:'||ptablas;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_marcas_per';
  BEGIN
    cur := pac_md_marcas.f_get_marcas_poliza(pcempres, psseguro, ptablas, mensajes);
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

   END f_get_marcas_poliza;

 /*************************************************************************
    FUNCTION f_get_accion_poliza
    Permite obtener la maxima accion de las marcas asociadas a tomadores,
    asegurados o beneficiarios de una poliza
    param in pcempres  : codigo de la empresa
    param in psseguro  : codigo del seguro
    param in ptablas  : EST o POL
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
  FUNCTION f_get_accion_poliza(pcempres IN NUMBER,
                               psseguro IN NUMBER,
                               ptablas  IN VARCHAR2,
                               mensajes IN OUT t_iax_mensajes)
  RETURN NUMBER IS
    v_accion NUMBER;
    vpasexec NUMBER(8) := 1;
    vparam   VARCHAR2(2000) := 'pcempres=' || pcempres||' psseguro='||psseguro||' ptablas:'||ptablas;
    vobject  VARCHAR2(200) := 'pac_iax_marcas.f_get_accion_poliza';
  BEGIN
    v_accion := pac_md_marcas.f_get_accion_poliza(pcempres, psseguro, ptablas, mensajes);
    RETURN v_accion;
  EXCEPTION
    WHEN OTHERS THEN
      pac_iobj_mensajes.p_tratarmensaje(mensajes,
                                        vobject,
                                        1000001,
                                        vpasexec,
                                        vparam,
                                        psqcode  => SQLCODE,
                                        psqerrm  => SQLERRM);

      RETURN -1;

   END f_get_accion_poliza;

END pac_iax_marcas;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_MARCAS" TO "PROGRAMADORESCSI";
