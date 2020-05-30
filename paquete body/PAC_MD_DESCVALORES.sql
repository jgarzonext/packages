--------------------------------------------------------
--  DDL for Package Body PAC_MD_DESCVALORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_DESCVALORES" AS
/******************************************************************************
   NOMBRE:      PAC_MD_DESCVALORES
   PROP¿¿¿¿¿SITO:   Funciones para recuperar descripciones de valores

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿¿¿¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/05/2008   JAS                1. Creaci¿¿¿¿n del package.
   2.0        27/04/2010   AMC                2. Bug 14284 Se a¿¿¿¿ade la funci¿¿¿¿n f_descgarant.
   3.0        24/01/2011   DRA                3. 0016576: AGA602 - Parametritzaci¿¿¿¿ de reemborsaments per veterinaris
   4.0        06/06/2012   ETM                4. 0021404: MDP - PER - Validaci¿¿¿¿n de documentos en funci¿¿¿¿n del tipo de sociedad
   5.0        05/07/2013   FAL                5. 0026968: RSAG101 - Producto RC Argentina. Incidencias (14/5)
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

    /*************************************************************************
      Recupera el nombre del pais
      param in pcpais       : codigo del pais
      param in out mensajes : mesajes de error
      return                : nombre del pais
   *************************************************************************/
   FUNCTION f_get_descpais(pcpais IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPAIS:' || pcpais;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_Get_DescPais';
      vtpais         VARCHAR2(100);
      vnumerr        NUMBER;
   BEGIN
      IF pcpais IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vnumerr := f_despais(pcpais, vtpais, pac_md_common.f_get_cxtidioma());

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

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
         param in pcprovin     : codigo de la provincia
         param in pcpais       : codigo del pais
         param in out mensajes : mesajes de error
         return                : nombre de la provincia
      *************************************************************************/
   FUNCTION f_get_descprovincia(
      pcprovin IN NUMBER,
      pcpais IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPAIS:' || pcpais || ' CPROVIN:' || pcprovin;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_Get_DescProvincia';
      vnumerr        NUMBER;
      vtpais         VARCHAR2(100);
      vcpais         NUMBER := pcpais;
      vtprovin       VARCHAR2(100);
   BEGIN
      IF pcprovin IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := f_desprovin(pcprovin, vtprovin, vcpais, vtpais);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

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
         param in pcprovin     : codigo de la provincia
         param in pcpoblac     : codigo de la poblaci¿¿¿¿n
         param in out mensajes : mesajes de error
         return                : nombre de la poblaci¿¿¿¿n
      *************************************************************************/
   FUNCTION f_get_descproblacion(
      pcprovin IN NUMBER,
      pcpoblac IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CPROVIN:' || pcprovin || ' PCPOBLAC:' || pcpoblac;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_Get_DescProblacion';
      vtpoblac       VARCHAR2(100);
      vnumerr        NUMBER;
   BEGIN
      IF pcpoblac IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      IF pcprovin IS NULL THEN
         RETURN NULL;
      END IF;

      vnumerr := f_despoblac(pcpoblac, pcprovin, vtpoblac);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vtpoblac;
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
        param in pcacto        : codigo del acto
        param in pcgarant   : codigo de la garantia
        param in pagr_salud : codigo de la agrupacion
        param in out mensajes  : mesajes de error
        return                 : descripci¿¿¿¿n del acto
     *************************************************************************/
   FUNCTION f_descreembactos(
      pcacto IN VARCHAR2,
      pcgarant IN NUMBER,   -- BUG16576:DRA:24/01/2011
      pagr_salud IN VARCHAR2,   -- BUG16576:DRA:24/01/2011
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcacto: ' || pcacto || ',  pcgarant: ' || pcgarant || ',  pagr_salud: '
            || pagr_salud;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_DescReembActos';
      vtacto         desactos.tacto%TYPE;
   BEGIN
      IF pcacto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      -- BUG16576:DRA:24/01/2011:Inici
      vtacto := pac_descvalores.ff_desacto(pcacto, pcgarant, pagr_salud,
                                           pac_md_common.f_get_cxtidioma);

      -- BUG16576:DRA:24/01/2011:Fi
      IF vtacto IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000661);
         RAISE e_object_error;
      END IF;

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
   FUNCTION f_get_descevento(pcevento IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' cevento: ' || pcevento;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_DescEvento';
      vtevento       sin_desevento.tevento%TYPE;
   BEGIN
      IF pcevento IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      BEGIN
         SELECT tevento
           INTO vtevento
           FROM sin_desevento sd, sin_codevento sc
          WHERE sd.cevento = sc.cevento
            AND sd.cevento = pcevento
            AND sd.cidioma = pac_md_common.f_get_cxtidioma;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001070);
            RAISE e_object_error;
      END;

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcgarant: ' || pcgarant || ' pcidioma:' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.f_descgarant';
      vnumerr        NUMBER;
   BEGIN
      IF pcgarant IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_descvalores.f_descgarant(pcgarant,
                                              NVL(pcidioma, pac_md_common.f_get_cxtidioma),
                                              ptgarant);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9901157);
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
   FUNCTION f_get_descidioma(pcidioma IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' pcidioma: ' || pcidioma;
      vobject        VARCHAR2(200) := 'PAC_IAX_DESCVALORES.F_Get_Descidioma';
      vtidioma       idiomas.tidioma%TYPE;
      vnumerr        NUMBER;
   BEGIN
      IF pcidioma IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := f_desidioma(pcidioma, vtidioma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

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
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.f_get_descsociedad';
      vparam         VARCHAR2(250) := 'pnnumide= ' || pnnumide;
   BEGIN
      IF pnnumide IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_descsoci := pac_descvalores.f_get_descsociedad(pnnumide);
      /* IF v_descsoci is null THEN
          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9903768);
          RAISE e_object_error;
       END IF;*/
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
      param in pcnacion      : codigo nacionalidad
      param out mensajes    : mesajes de error
      return                : nombre de la nacionalidad
   *************************************************************************/
   FUNCTION f_get_descnacion(pcnacion IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CNACION:' || pcnacion;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.F_Get_descnacion';
      vtnacion       VARCHAR2(100);
      vnumerr        NUMBER;
   BEGIN
      IF pcnacion IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT tnacion
           INTO vtnacion
           FROM despaises
          WHERE cpais = pcnacion
            AND cidioma = pac_md_common.f_get_cxtidioma();
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151941);
            RAISE e_object_error;
      END;

      RETURN vtnacion;
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

-- FI BUG 26968
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
      SELECT tpoblac, cprovin
        INTO vtpobla, pcprovin
        FROM poblaciones
       WHERE cpoblac = pcpoblacion;

      RETURN vtpobla;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_descpoblacionsinprov;

   /*************************************************************************
      Recupera el nombre del ciiu
      param in ciiu       : codigo del ciiu
      param out mensajes    : mesajes de error
      return                : nombre del ciiu
   *************************************************************************/
   FUNCTION f_get_ciiu(pciiu IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' ciiu:' || pciiu;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.f_get_ciiu';
      vtciiu         VARCHAR2(500);
      vnumerr        NUMBER;

      CURSOR c_per_ciiu IS
        SELECT TCIIU FROM PER_CIIU
          WHERE CCIIU = pciiu
            AND CIDIOMA = pac_md_common.f_get_cxtidioma;
   BEGIN
      IF pciiu IS NULL THEN
         RAISE e_param_error;
      END IF;

      OPEN c_per_ciiu;
        FETCH c_per_ciiu INTO vtciiu;
      CLOSE c_per_ciiu;
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


      -- BUG 338
   /*************************************************************************
      Recupera las siglas del tipo de via
      param in pcsiglas      : codigo de la sigla
      param out mensajes    : mesajes de error
      return                : siglas del tipo de via
   *************************************************************************/
   FUNCTION f_get_tipoVia(pcsiglas IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := ' CSIGLA:' || pcsiglas;
      vobject        VARCHAR2(200) := 'PAC_MD_DESCVALORES.f_get_tipoVia';
      vtsiglas       VARCHAR2(100);
      vnumerr        NUMBER;
   BEGIN
      IF pcsiglas IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      BEGIN
         SELECT tsiglas
           INTO vtsiglas
           FROM tipos_via
          WHERE Csiglas = pcsiglas;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151941);
            RAISE e_object_error;
      END;

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

-- FI BUG 338

END pac_md_descvalores;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCVALORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCVALORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCVALORES" TO "PROGRAMADORESCSI";
