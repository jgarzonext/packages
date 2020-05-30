--------------------------------------------------------
--  DDL for Package Body PAC_IAX_LISTADO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_LISTADO" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_LISTADO
   PROPÓSITO:    Contiene las funciones para el lanzamiento de listados a través de AXISCONNECT.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   JGM              1. Creación del package.
   2.0        06/05/2010   ICV              2. 0012746: APRB95 - lista de movimientos de saldo por cliente
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/******************************************************************************
F_GENERAR_LISTADO - Lanza el listado de comisiones de APRA
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      mensajes OUT t_iax_mensajes)
Retorna 0 si OK 1 si KO
********************************************************************************/
   FUNCTION f_generar_listado(
      p_cempres IN NUMBER,
      p_sproces IN NUMBER,
      p_cagente IN NUMBER,
      p_fitxer1 OUT VARCHAR2,
      p_fitxer2 OUT VARCHAR2,
      p_fitxer3 OUT VARCHAR2,
      p_fitxer4 OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200)
         := 'P_cempres = ' || p_cempres || ', P_sproces = ' || p_sproces || ',p_cagente = '
            || p_cagente;
      v_object       VARCHAR2(200) := 'PAC_IAX_LISTADO.f_generar_listado';
      v_error        NUMBER(8) := 0;
   BEGIN
      v_error := pac_md_listado.f_generar_listado(p_cempres, p_sproces, p_cagente, p_fitxer1,
                                                  p_fitxer2, p_fitxer3, p_fitxer4, mensajes);
      v_pasexec := 2;
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000006, v_pasexec, v_param);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           NULL, SQLCODE, SQLERRM);
         RETURN NULL;
   END f_generar_listado;

     /*************************************************************************
      Impresió
      param in out  psinterf
      param in      pcempres:  codi d'empresa
      param in      pdatasource
      param in      pcidioma
      param in      pcmapead
      param out     perror
      param out     mensajes    missatges d'error

      return                    0/1 -> Tot OK/error

      Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_genera_report(
      psinterf IN NUMBER,
      pcempres IN NUMBER,
      pdatasource IN VARCHAR2,
      pcidioma IN NUMBER,
      pcmapead IN VARCHAR2,   --Bug.: 12746 - 06/05/2010 - ICV
      perror OUT VARCHAR2,
      preport OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'pac_iax_con.f_genera_report';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psinterf=' || psinterf || ' pcempres=' || pcempres || ' pdatasource='
            || pdatasource || ' pcidioma=' || pcidioma || ' pcmapead=' || pcmapead;
      v_error        NUMBER;
      terror         VARCHAR2(200);
      vcterminal     usuarios.cterminal%TYPE;
      v_id           VARCHAR2(30);
      vplantillaorigen VARCHAR2(200);
      vsinterf       NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR pdatasource IS NULL
         OR pcidioma IS NULL
         OR pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_error := pac_md_listado.f_genera_report(psinterf, pcempres, pdatasource, pcidioma,
                                                pcmapead, perror, preport, mensajes);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000001, terror);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_error;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_genera_report;
END pac_iax_listado;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_LISTADO" TO "PROGRAMADORESCSI";
