--------------------------------------------------------
--  DDL for Package Body PAC_IAX_DESCVALORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_DESCVALORES" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_DESCVALORES
   PROP¿¿¿¿¿SITO:   Funciones para recuperar descripciones de valores

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/05/2008   JAS                1. Creaci¿¿¿¿n del package.
   2.0        05/05/2010   AMC                2. Bug 14284. Se a¿¿¿¿aden nuevas funciones.
   3.0        24/01/2011   DRA                3. 0016576: AGA602 - Parametritzaci¿¿¿¿ de reemborsaments per veterinaris
   4.0        06/06/2012   ETM                4.0021404: MDP - PER - Validaci¿¿¿¿n de documentos en funci¿¿¿¿n del tipo de sociedad
   5.0        05/07/2013   FAL                5. 0026968: RSAG101 - Producto RC Argentina. Incidencias (14/5)
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera el nombre del pais
      param in pcpais       : codigo del pais
      param out mensajes    : mesajes de error
      return                : nombre del pais
   *************************************************************************/
   FUNCTION f_get_descpais(pcpais IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPAIS:' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_DescPais';
      vtpais         VARCHAR2(100);
   BEGIN
      vtpais := pac_md_descvalores.f_get_descpais(pcpais, mensajes);
      RETURN vtpais;
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
   END f_get_descpais;

/*************************************************************************
       Recupera el nombre de la provincia
       param in pcpais       : codigo del pais
       param in pcprovin     : codigo de la provincia
       param out mensajes    : mesajes de error
       return                : nombre de la provincia
    *************************************************************************/
   FUNCTION f_get_descprovincia(
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPAIS:' || pcpais || ' CPROVIN:' || pcprovin;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_DescProvincia';
      vtprovin       VARCHAR2(100);
   BEGIN
      vtprovin := pac_md_descvalores.f_get_descprovincia(pcprovin, pcpais, mensajes);
      RETURN vtprovin;
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
   END f_get_descprovincia;

/*************************************************************************
       Recupera el nombre de la poblaci¿¿¿¿n
       param in pcpoblac     : codigo de la poblaci¿¿¿¿n
       param in pcprovin     : codigo de la provincia
       param out mensajes    : mesajes de error
       return                : nombre de la poblaci¿¿¿¿n
    *************************************************************************/
   FUNCTION f_get_descproblacion(
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPROVIN:' || pcprovin || ' CPOBLAC:' || pcpoblac;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_DescProblacion';
      vtpobla        VARCHAR2(100);
   BEGIN
      vtpobla := pac_md_descvalores.f_get_descproblacion(pcprovin, pcpoblac, mensajes);
      RETURN vtpobla;
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
   END f_get_descproblacion;

   /*************************************************************************
        Recupera la descripci¿¿¿¿n del acto
        param in pcacto     : codigo del acto
        param in pcgarant   : codigo de la garantia
        param in pagr_salud : codigo de la agrupacion
        param out mensajes  : mesajes de error
        return              : descripci¿¿¿¿n del acto
     *************************************************************************/
   FUNCTION f_descreembactos(
      pcacto IN VARCHAR2,
      pcgarant IN NUMBER,   -- BUG16576:DRA:24/01/2011
      pagr_salud IN VARCHAR2,   -- BUG16576:DRA:24/01/2011
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcacto: ' || pcacto || ',  pcgarant: ' || pcgarant || ',  pagr_salud: '
            || pagr_salud;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_DescReembActos';
      vtacto         desactos.tacto%TYPE;
   BEGIN
      vtacto := pac_md_descvalores.f_descreembactos(pcacto, pcgarant, pagr_salud, mensajes);
      RETURN vtacto;
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
   END f_descreembactos;

   /*************************************************************************
        Recupera la descripci¿¿¿¿n del evento
        param in pcacto     : codigo del evento
        param out mensajes  : mesajes de error
        return              : descripci¿¿¿¿n del devento
     *************************************************************************/
   FUNCTION f_get_descevento(pcevento IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcevento: ' || pcevento;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_DescEvento';
      vtevento       sin_desevento.tevento%TYPE;
   BEGIN
      vtevento := pac_md_descvalores.f_get_descevento(pcevento, mensajes);
      RETURN vtevento;
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
   END f_get_descevento;

   /*******************************************************
      Funci¿¿¿¿n que devuelve la descripci¿¿¿¿n de una garant¿¿¿¿a
      PARAM IN pcgarant : codigo de la garant¿¿¿¿a
      PARAM IN pcidioma : c¿¿¿¿digo de idioma
      PARAM OUT ptgarant : descripci¿¿¿¿n de la garant¿¿¿¿a
      PARAM OUT mensajes : mensajes de error
      RETURN NUMBER

      Bug 14284 - 27/04/2010 - AMC
   *******************************************************/
   FUNCTION f_descgarant(
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ptgarant OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcgarant: ' || pcgarant || ' pcidioma:' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.f_descgarant';
      vnumerr        NUMBER;
   BEGIN
      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_md_descvalores.f_descgarant(pcgarant, pcidioma, ptgarant, mensajes);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN 0;
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
   END f_descgarant;

   /*************************************************************************
        Recupera la descripci¿¿¿¿n del idioma
        param in pcidioma     : codigo del idioma
        param out mensajes  : mesajes de error
        return              : descripci¿¿¿¿n del idioma
     *************************************************************************/
   FUNCTION f_get_descidioma(pcidioma IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_Descidioma';
      vtidioma       idiomas.tidioma%TYPE;
   BEGIN
      vtidioma := pac_md_descvalores.f_get_descidioma(pcidioma, mensajes);
      RETURN vtidioma;
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
   END f_get_descidioma;

     --bug 21404--ETM-- 06/06/2012
   /*************************************************************************
       Recupera la descripci¿¿¿¿n del tipo de sociedad
       param in pnnumide     : nubero de nif/cif
       param out mensajes  : mesajes de error
       return              : descripci¿¿¿¿n del tipo de sociedad
    *************************************************************************/
   FUNCTION f_get_descsociedad(pnnumide IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER := 1;
      v_descsoci     VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.f_get_descsociedad';
      vparam         VARCHAR2(250) := 'pnnumide= ' || pnnumide;
   BEGIN
      v_descsoci := pac_md_descvalores.f_get_descsociedad(pnnumide, mensajes);
      RETURN v_descsoci;
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
   END f_get_descsociedad;

--FIN bug 21404--ETM-- 06/06/2012

   -- BUG 26968 - FAL - 05/07/2013
   /*************************************************************************
      Recupera el nombre de la nacionalidad
      param in pcnacion       : codigo nacionalidad
      param out mensajes    : mesajes de error
      return                : nombre de la nacionalidad
   *************************************************************************/
   FUNCTION f_get_descnacion(pcnacion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CNACION:' || pcnacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_descnacion';
      vtpais         VARCHAR2(100);
   BEGIN
      vtpais := pac_md_descvalores.f_get_descnacion(pcnacion, mensajes);
      RETURN vtpais;
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
   END f_get_descnacion;

   /*************************************************************************
      Recupera el nombre de la poblacion
      param in pcpoblacion  : codigo poblacion
      param out mensajes    : mesajes de error
      return                : nombre de la poblacion
   *************************************************************************/
   FUNCTION f_get_descpoblacionsinprov(
      pcpoblacion IN NUMBER,
      pcprovin OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPOBLACION:' || pcpoblacion;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_DescProblacion';
      vtpobla        VARCHAR2(100);
   BEGIN
      vtpobla := pac_md_descvalores.f_get_descpoblacionsinprov(pcpoblacion, pcprovin,
                                                               mensajes);
      RETURN vtpobla;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_descpoblacionsinprov;
-- FI BUG 26968
 /*************************************************************************
      Recupera el nombre del ciiu
      param in ciiu       : codigo del ciiu
      param out mensajes    : mesajes de error
      return                : nombre del ciiu
   *************************************************************************/
   FUNCTION f_get_ciiu(ciiu IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPAIS:' || ciiu;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.f_get_ciiu';
      vtciiu         VARCHAR2(100);
   BEGIN
      vtciiu := pac_md_descvalores.f_get_ciiu(ciiu, mensajes);
      RETURN vtciiu;
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
   END f_get_ciiu;

    /*************************************************************************
      Recupera las siglas del tipo de via
      param in pcsiglas      : codigo de la sigla
      param out mensajes    : mesajes de error
      return                : siglas del tipo de via
   *************************************************************************/
   FUNCTION f_get_tipoVia(pcsiglas IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CSIGLA:' || pcsiglas;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.f_get_tipoVia';
      vtsiglas         VARCHAR2(100);
   BEGIN
      vtsiglas := pac_md_descvalores.f_get_tipoVia(pcsiglas, mensajes);
      RETURN vtsiglas;
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
   END f_get_tipoVia;


END pac_iax_descvalores;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_DESCVALORES" TO "PROGRAMADORESCSI";
