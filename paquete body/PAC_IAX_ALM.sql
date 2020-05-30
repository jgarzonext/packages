--------------------------------------------------------
--  DDL for Package Body PAC_IAX_ALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_ALM" AS
/******************************************************************************
   NOMBRE:    PAC_IAX_ALM
   PROPÓSITO: Contiene el módulo de ALM-Asset Liability Management de la capa IAX

   REVISIONES:
   Ver        Fecha       Autor            Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       14/09/2010  JMF              1. 0015956 CEM - ALM
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
       Función que consulta si existe detalle ALM para una fecha
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       retorno 0-No existe, 1-Si existe
   *************************************************************************/
   FUNCTION f_existe_detalle(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_EXISTE_DETALLE';
      v_tparam       VARCHAR2(100)
                             := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy');
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      --Comprovació pas de paràmetres
      IF p_fcalcul IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_ntraza := 2;
      RETURN pac_md_alm.f_existe_detalle(v_cempres, p_fcalcul, mensajes);
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_existe_detalle;

   /*************************************************************************
       Función que selecciona info sobre criterios alm.
       param p_cempres    in : empresa
       param p_rcriterio  OUT: cursor con informacion alm_criterio
       param in out MENSAJES : mensajes de error
       retorno 0-Correto, 1-Existen errores
   *************************************************************************/
   FUNCTION f_get_almcriterio(
      p_cempres IN NUMBER,
      p_rcriterio OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_GET_ALMCRITERIO';
      v_tparam       VARCHAR2(100) := 'e=' || p_cempres;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      v_ntraza := 2;
      --Crida a la capa MD
      v_nnumerr := pac_md_alm.f_get_almcriterio(v_cempres, p_rcriterio, mensajes);
      RETURN v_nnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_almcriterio;

   /*************************************************************************
       Función que selecciona info sobre detalle alm.
       param p_cempres    in : empresa
       param p_sproduc    in : producto
       param p_rcriterio  OUT: cursor con informacion alm_detalle
       param in out MENSAJES : mensajes de error
       retorno 0-Correto, 1-Existen errores
   *************************************************************************/
   FUNCTION f_get_almdetalle(
      p_cempres IN NUMBER,
      p_sproduc IN NUMBER,
      p_npoliza IN NUMBER,
      p_ncertif IN NUMBER,
      p_fvalora IN DATE,
      p_cramo IN NUMBER,
      p_rdetalle OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_GET_ALMDETALLE';
      v_tparam       VARCHAR2(100)
         := 'e=' || p_cempres || ' p=' || p_sproduc || ' o=' || p_npoliza || ' c='
            || p_ncertif || ' f=' || TO_CHAR(p_fvalora, 'dd-mm-yyyy') || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      --Comprovació pas de paràmetres
      v_ntraza := 2;

      IF p_fvalora IS NULL THEN
         RAISE e_param_error;
      END IF;

      --Crida a la capa MD
      v_ntraza := 3;
      v_nnumerr := pac_md_alm.f_get_almdetalle(v_cempres, p_sproduc, p_npoliza, p_ncertif,
                                               p_fvalora, p_cramo, p_rdetalle, mensajes);
      RETURN v_nnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_almdetalle;

   /*************************************************************************
       Función que genera el proceso ALM
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       param p_sproduc    in : producto
       param p_pintfutdef in : Interés futuro defecto
       param p_pcredibdef in : Porcentaje de credibilidad defecto
       param in out MENSAJES : mensajes de error
       retorno 0-Correcto, 1-Código Error
   *************************************************************************/
   FUNCTION f_genera_alm(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      p_sproduc IN NUMBER,
      p_pintfutdef IN NUMBER,
      p_pcredibdef IN NUMBER,
      p_cramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_GENERA_ALM';
      v_tparam       VARCHAR2(100)
         := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy') || ' p='
            || p_sproduc || ' i=' || p_pintfutdef || ' c=' || p_pcredibdef || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      --Comprovació pas de paràmetres
      IF p_fcalcul IS NULL
         OR p_pintfutdef IS NULL
         OR p_pcredibdef IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_ntraza := 2;
      v_nnumerr := pac_md_alm.f_genera_alm(v_cempres, p_fcalcul, p_sproduc, p_pintfutdef,
                                           p_pcredibdef, p_cramo, mensajes);

      IF v_nnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, v_nnumerr, v_ntraza, v_tparam);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_nnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_genera_alm;

   /*************************************************************************
       Función que crea registro nuevo en ALM_CRITERIO
       si el parametro ORDEN no esta informado. Resto casos actualiza registro.
       param p_cempres    in : empresa
       param p_TCRITERIO  IN : Criterio
       param p_NORDEN     IN : Orden
       param p_PCREDIBI   IN : Porcentaje credibilidad
       param p_PINTFUT    IN : Porcentaje interes
       param in out MENSAJES : mensajes de error
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_set_almcriterio(
      p_cempres IN NUMBER,
      p_tcriterio IN VARCHAR2,
      p_norden IN NUMBER,
      p_pcredibi IN NUMBER,
      p_pintfut IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_SET_ALMCRITERIO';
      v_tparam       VARCHAR2(200)
         := 'e=' || p_cempres || ' o=' || p_norden || ' c=' || p_pcredibi || ' i='
            || p_pintfut;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      v_ntraza := 2;
      v_nnumerr := pac_md_alm.f_set_almcriterio(v_cempres, p_tcriterio, p_norden, p_pcredibi,
                                                p_pintfut, mensajes);

      IF v_nnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, v_nnumerr, v_ntraza, v_tparam);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_nnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_almcriterio;

   /*************************************************************************
       Función que borra registro de ALM_CRITERIO
       param p_cempres    in : empresa
       param p_NORDEN     IN : Orden
       retorno 0-Correcto, 1-Código error.
   *************************************************************************/
   FUNCTION f_del_almcriterio(
      p_cempres IN NUMBER,
      p_norden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_DEL_ALMCRITERIO';
      v_tparam       VARCHAR2(100) := 'e=' || p_cempres || ' o=' || p_norden;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cempres      empresas.cempres%TYPE;
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      v_ntraza := 2;
      v_nnumerr := pac_md_alm.f_del_almcriterio(v_cempres, p_norden, mensajes);

      IF v_nnumerr <> 0 THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, v_nnumerr, v_ntraza, v_tparam);
         RAISE e_object_error;
      END IF;

      COMMIT;
      RETURN v_nnumerr;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         RETURN 0;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         RETURN 0;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 0;
   END f_del_almcriterio;

   /*************************************************************************
      Función que genera diferentes ficheros de informes ALM
      param p_tcartera IN : Texto cartera
      param p_sproduc  IN : Producto
      param p_nagrupa  IN : Agrupa (0=No agrupa;1=Agrupa)
      param p_ntipo    IN : Tipo (0:Excel; 1:Serfiex)
      param p_cempres  IN : Código empresa
      param p_nomfichero OUT : Nombre del fichero generado.
      param in out MENSAJES : mensajes de error
      retorno 0-Correcto, 1-Error.
   *************************************************************************/
   FUNCTION f_informe(
      p_tcartera IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_nagrupa IN NUMBER,
      p_ntipo IN NUMBER,
      p_cempres IN NUMBER,
      p_cramo IN NUMBER,
      p_nomfichero OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_IAX_ALM.F_INFORME';
      v_tparam       VARCHAR2(200)
         := 'c=' || p_tcartera || ' p=' || p_sproduc || ' a=' || p_nagrupa || ' t=' || p_ntipo
            || ' e=' || p_cempres || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_cmap         map_cabecera.cmapead%TYPE := '144';
      v_cempres      empresas.cempres%TYPE;
      v_nrep         NUMBER;
      v_ntipo        VARCHAR2(20);
   BEGIN
      v_ntraza := 1;

      IF p_cempres IS NULL THEN
         v_cempres := pac_md_common.f_get_cxtempresa;
      ELSE
         v_cempres := p_cempres;
      END IF;

      IF p_ntipo = 0 THEN
         v_ntipo := 'EXCEL';
      ELSE
         v_ntipo := 'SERFIEX';
      END IF;

      v_ntraza := 3;
      p_nomfichero := pac_iax_map.f_ejecuta(v_cmap,
                                            p_tcartera || '|' || p_sproduc || '|' || p_nagrupa
                                            || '|' || v_ntipo || '|' || v_cempres || '|'
                                            || p_cramo,
                                            v_nrep, mensajes);

      IF p_nomfichero IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 107914);
         RAISE e_object_error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_informe;
END pac_iax_alm;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_ALM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ALM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_ALM" TO "PROGRAMADORESCSI";
