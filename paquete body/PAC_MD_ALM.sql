--------------------------------------------------------
--  DDL for Package Body PAC_MD_ALM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_ALM" AS
/******************************************************************************
   NOMBRE:    pac_md_alm
   PROPÓSITO: Contiene el módulo de ALM-Asset Liability Management de la capa MD

   REVISIONES:

   Ver        Fecha        Autor  Descripción
   ---------  ----------  ------  ------------------------------------
     1        14/09/2010   JMF    1. 0015956 CEM - ALM
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
       Función que consulta si existe detalle ALM para una fecha
       param p_cempres    in : empresa
       param p_fcalcul    in : fecha calculo
       param in out MENSAJES : mensajes de error
       retorno 0-No existe, 1-Si existe
   *************************************************************************/
   FUNCTION f_existe_detalle(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_EXISTE_DETALLE';
      v_tparam       VARCHAR2(100)
                             := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy');
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
   BEGIN
      v_ntraza := 1;
      RETURN pac_alm.f_existe_detalle(p_cempres, p_fcalcul);
   EXCEPTION
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_GET_ALMCRITERIO';
      v_tparam       VARCHAR2(100) := 'e=' || p_cempres;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_nmax         NUMBER;
      v_tquery       VARCHAR2(32000);
      cur            sys_refcursor;
      v_nquants      NUMBER;
   BEGIN
      v_ntraza := 1;
      v_nmax := f_parinstalacion_n('N_MAX_REG');
      v_ntraza := 2;
      v_tquery := 'select CEMPRES, TCRITERIO, NORDEN, PCREDIBI, PINTFUT'
                  || ' from alm_criterio' || ' where cempres=' || p_cempres;
      v_ntraza := 3;
      cur := pac_md_listvalores.f_opencursor(' SELECT COUNT(1) FROM (' || v_tquery || ')',
                                             mensajes);

      FETCH cur
       INTO v_nquants;

      CLOSE cur;

      v_ntraza := 5;

      IF v_nquants > v_nmax THEN
         pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 2, 9001372,
                                                  v_nquants || '#' || v_nmax, 1);
      END IF;

      v_ntraza := 7;
      v_tquery := v_tquery || ' order by NORDEN';
      v_ntraza := 9;
      p_rcriterio := pac_md_listvalores.f_opencursor(v_tquery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_almcriterio;

   /*************************************************************************
       Función que selecciona info sobre el detalle alm.
       param p_cempres    in : empresa
       param p_sproduc    in : producto
       param p_nPOLIZA    in : póliza
       param p_nCERTIF    in : certificado
       param p_FVALORA    in : fecha valoracion
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
      p_rcriterio OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_GET_ALMDETALLE';
      v_tparam       VARCHAR2(100)
         := 'e=' || p_cempres || ' p=' || p_sproduc || ' o=' || p_npoliza || ' c='
            || p_ncertif || ' f=' || TO_CHAR(p_fvalora, 'dd-mm-yyyy') || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
      v_nmax         NUMBER;
      v_tquery       VARCHAR2(32000);
      cur            sys_refcursor;
      v_nquants      NUMBER;
      v_cramo        productos.cramo%TYPE;
      v_cmodali      productos.cmodali%TYPE;
      v_ctipseg      productos.ctipseg%TYPE;
      v_ccolect      productos.ccolect%TYPE;
   BEGIN
      v_ntraza := 1;
      v_nmax := f_parinstalacion_n('N_MAX_REG');
      v_ntraza := 3;
      v_tquery :=
         'select CEMPRES, SSEGURO, CRAMO,    CMODALI, CTIPSEG, CCOLECT, SPRODUC, NPOLIZA,'
         || '       FVALORA, FVENCIM, NEDADASE, CSEXO,   CFORPAG, IPROMAT, ICAPGAR, PCREDIBI,'
         || '       PINTFUT, NDIAS,   FVENEST,  IPROYEC, FMODIF,  PINTTEC'
         || ' from  alm_detalle' || ' where cempres=' || p_cempres
         || ' and to_char(FVALORA,''yyyymmdd'')=' || CHR(39) || TO_CHAR(p_fvalora, 'yyyymmdd')
         || CHR(39);

      IF p_npoliza IS NOT NULL THEN
         v_tquery := v_tquery || ' and npoliza=' || p_npoliza;

         IF p_ncertif IS NOT NULL THEN
            v_tquery := v_tquery || ' and exists (select 1 from seguros s'
                        || '              where s.sseguro=alm_detalle.sseguro and s.ncertif='
                        || p_ncertif;
         END IF;
      END IF;

      IF p_cramo IS NOT NULL
         AND p_sproduc IS NULL THEN
         v_tquery := v_tquery || ' and cramo = ' || p_cramo;
      END IF;

      IF p_sproduc IS NOT NULL THEN
         v_ntraza := 5;

         SELECT cramo, cmodali, ctipseg, ccolect
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM productos
          WHERE sproduc = p_sproduc;

         v_ntraza := 7;
         v_tquery := v_tquery || ' and CRAMO=' || v_cramo || ' and CMODALI=' || v_cmodali
                     || ' and CTIPSEG=' || v_ctipseg || ' and CCOLECT=' || v_ccolect;
      END IF;

      v_ntraza := 9;
      cur := pac_md_listvalores.f_opencursor(' SELECT COUNT(1) FROM (' || v_tquery || ')',
                                             mensajes);

      FETCH cur
       INTO v_nquants;

      CLOSE cur;

      v_ntraza := 11;

      IF v_nquants > v_nmax THEN
         pac_iobj_mensajes.crea_nuevo_mensaje_var(mensajes, 2, 9001372,
                                                  v_nquants || '#' || v_nmax, 1);
      END IF;

      v_ntraza := 13;
      v_tquery := v_tquery || ' order by CRAMO, CMODALI, CTIPSEG, CCOLECT, NPOLIZA';
      v_ntraza := 15;
      p_rcriterio := pac_md_listvalores.f_opencursor(v_tquery, mensajes);
      RETURN 0;
   EXCEPTION
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
       retorno 0-Correcto, 1- Error
   *************************************************************************/
   FUNCTION f_genera_alm(
      p_cempres IN NUMBER,
      p_fcalcul IN DATE,
      p_sproduc IN NUMBER,
      p_pintfutdef IN NUMBER,
      p_pcredibdef IN NUMBER,
      p_cramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_GENERA_ALM';
      v_tparam       VARCHAR2(100)
         := 'e=' || p_cempres || ' f=' || TO_CHAR(p_fcalcul, 'dd-mm-yyyy') || ' p='
            || p_sproduc || ' i=' || p_pintfutdef || ' c=' || p_pcredibdef || ' r=' || p_cramo;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
   BEGIN
      v_ntraza := 1;
      v_nnumerr := pac_alm.f_genera_alm(p_cempres, p_fcalcul, p_sproduc, p_pintfutdef,
                                        p_pcredibdef, p_cramo);

      IF v_nnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_nnumerr);
         RAISE e_object_error;
      END IF;

      -- Proceso finalizado correctamente
      v_ntraza := 2;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 109904);
      RETURN 0;
   EXCEPTION
      --Se debe realizar el control de errores mediante  el PAC_IOBJ_MENSAJES.P_TRATARMENSAJE.
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000006, v_ntraza, v_tparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000005, v_ntraza, v_tparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_SET_ALMCRITERIO';
      v_tparam       VARCHAR2(200)
         := 'e=' || p_cempres || ' o=' || p_norden || ' c=' || p_pcredibi || ' i='
            || p_pintfut;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
   BEGIN
      v_ntraza := 1;
      RETURN pac_alm.f_set_almcriterio(p_cempres, p_tcriterio, p_norden, p_pcredibi,
                                       p_pintfut);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000455;
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_tobjeto      VARCHAR2(100) := 'PAC_MD_ALM.F_DEL_ALMCRITERIO';
      v_tparam       VARCHAR2(200) := 'e=' || p_cempres || ' o=' || p_norden;
      v_ntraza       NUMBER;
      v_nnumerr      NUMBER;
   BEGIN
      v_ntraza := 1;
      RETURN pac_alm.f_del_almcriterio(p_cempres, p_norden);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobjeto, 1000001, v_ntraza, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1000455;
   END f_del_almcriterio;
END pac_md_alm;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_ALM" TO "PROGRAMADORESCSI";
