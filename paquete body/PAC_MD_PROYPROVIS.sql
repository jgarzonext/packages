--------------------------------------------------------
--  DDL for Package Body PAC_MD_PROYPROVIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PROYPROVIS" IS
/******************************************************************************
 NOMBRE:     PAC_PROYPROVIS_POS
 PROPÓSITO:  Funciones para ejecutará el proceso de cálculo de las proyecciones.

 REVISIONES:
 Ver        Fecha        Autor             Descripción
 ---------  ----------  ---------------  ------------------------------------
 1.0        02/12/2015   ACL                1. Creación del package.
 2.0        18/02/2016   JCP                2.  Modificacion de llamado de funcion por las ''

******************************************************************************/

   /*************************************************************************
      Function f_calculo_proyprovis
      ptablas in number: Código idioma
      psseguro: sseguro
   *************************************************************************/
   FUNCTION f_calculo_proyprovis(
      psproces IN NUMBER,
      pperiodicidad IN NUMBER,
      pfechaini IN DATE,
      pfechafin IN DATE,
      psproduc IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pmodo IN VARCHAR2 DEFAULT 'R',
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_MD_PROYPROVIS.F_CALCULO_PROYPROVIS';
      v_titulo       VARCHAR2(200);
      vnumerr        NUMBER;
      pnnumlin       NUMBER;
      pcerror        NUMBER;
      conta_err      NUMBER;
      vtexto         VARCHAR2(2000);
      pfperini       DATE;
      v_propio       VARCHAR2(1000);
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_cempres      NUMBER;
      v_count        NUMBER;
   BEGIN
      v_cempres := pac_md_common.f_get_cxtempresa;
      vpasexec := 2;

      SELECT 'PAC_PROYPROVIS_' || pac_parametros.f_parempresa_t(v_cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM DUAL;

      p_tab_error(f_sysdate, f_user, 'f_calculo_proyprovis', 1, v_propio, SQLERRM);
      vpasexec := 3;
      v_ss := 'BEGIN ' || '  ' || v_propio || '.' || 'p_calculo_proyprovis(' || psproces
              || ', ' || pperiodicidad || ', ' || 'TO_DATE('''
              || TO_CHAR(pfechaini, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY''), ' || 'TO_DATE('''
              || TO_CHAR(pfechafin, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY''),''' || psproduc
              || ''', ''' || pnpoliza || ''',''' || pncertif || ''', ''' || pmodo || ''' )'
              || ';' || 'END;';
      vpasexec := 4;
      p_tab_error(f_sysdate, f_user, 'f_calculo_proyprovis', 1, v_ss, SQLERRM);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vpasexec := 5;
      v_cursor := DBMS_SQL.open_cursor;
      vpasexec := 6;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      vpasexec := 7;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      vpasexec := 9;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      /* validacion proceso correcto*/
      v_ss := ' SELECT COUNT(1)
        FROM proy_provis_proceso_pos
       WHERE sproces = '||psproces;

     EXECUTE IMMEDIATE v_ss into v_count;

      IF v_count > 0 THEN
         RETURN 111313;
      ELSE
         RETURN 9904575;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_calculo_proyprovis;

---- IVAN GIL

   /*******************************************************************************
                                                                                                                                                                                                                                                   FUNCION F_INICIALIZA_CARTERA
    Esta función devuelve el sproces con el que se realizará el proceso de cartera,
    para ello llamará a la función de f_procesini.
   Parámetros
    Entrada :
       Pfperini  DATE     : Fecha
       Pcempres  NUMBER   : Empresa
       Ptexto    VARCHAR2 :
    Salida :
       Psproces  NUMBER  : Numero proceso .
   Retorna :NUMBER con el estado
   *********************************************************************************/
   FUNCTION f_inicializa_proceso(
      pmes IN NUMBER,
      panyo IN NUMBER,
      pcempres IN NUMBER,
      pfinicio IN DATE,
      pnproceso OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_MD_PROYPROVIS.F_INICIALIZA_PROCESO';
      v_titulo       VARCHAR2(200);
      vnumerr        NUMBER;
      pnnumlin       NUMBER;
      pcerror        NUMBER;
      conta_err      NUMBER;
      vtexto         VARCHAR2(2000);
      pfperini       DATE;
      v_propio       VARCHAR2(1000);
      v_retorno      NUMBER;
      v_nproceso     NUMBER;
      v_ss           VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_cempres      NUMBER;
   BEGIN
      v_cempres := pac_md_common.f_get_cxtempresa;
      pfperini := TO_DATE('01/' || TO_CHAR(pmes) || '/' || TO_CHAR(panyo), 'dd/mm/yyyy');
      vpasexec := 2;

      SELECT 'PAC_PROYPROVIS_' || pac_parametros.f_parempresa_t(v_cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM DUAL;

      vpasexec := 3;
      v_ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_inicializa_proceso('
              || 'TO_DATE(''' || TO_CHAR(pfperini, 'DD/MM/YYYY') || ''', ''DD/MM/YYYY''),'
              || v_cempres || ', ''PROY_RESERVAS'', ' || pac_md_common.f_get_cxtidioma
              || ', :PNPROCESO )' || ';' || 'END;';
      vpasexec := 4;
      p_tab_error(f_sysdate, f_user, vobject, 1, v_ss, SQLERRM);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vpasexec := 5;
      v_cursor := DBMS_SQL.open_cursor;
      vpasexec := 6;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      vpasexec := 7;
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      DBMS_SQL.bind_variable(v_cursor, ':PNPROCESO', v_nproceso);
      vpasexec := 8;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      vpasexec := 9;
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      DBMS_SQL.variable_value(v_cursor, 'PNPROCESO', v_nproceso);
      vpasexec := 10;
      pnproceso := v_nproceso;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_inicializa_proceso;

   ---- Juan Carlos Pacheco

   /*******************************************************************************
                                                                                                                                                                                                                                                   FUNCION F_INICIALIZA_CARTERA
    Esta función devuelve la consulta d ela tabla  PROY_PARAMETROS_MTO_POS
   Parámetros
    Entrada :
       psproduc  DATE     : Fecha

    Salida :
       pslstpry  SYSREFCURSOR  : Cursor consulta.

   *********************************************************************************/
   FUNCTION f_consul_param_mto_pos(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc: ' || psproduc;
      vsquery        VARCHAR2(1000);
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma();
      vobject        VARCHAR2(200) := 'PAC_MD_PROYPROVIS.F_CONSUL_PARAM_MTO_POS';
   BEGIN
      vpasexec := 2;
      vsquery :=
         'SELECT pp.sproduc, dv.tatribu TPARAM, pp.nanyo, pp.nmes, pp.ivalor
  FROM proy_parametros_mto_pos pp, detvalores dv
 WHERE pp.cparam = dv.catribu
   AND dv.cvalor = 8001032
   AND dv.cidioma ='
         || vidioma || '
   AND sproduc = ' || psproduc;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);

      IF pac_md_log.f_log_consultas(vsquery, 'PAC_MD_PROYPROVIS.F_CONSUL_PARAM_MTO_POS', 1, 2,
                                    mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      END IF;

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
   END f_consul_param_mto_pos;
END pac_md_proyprovis;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PROYPROVIS" TO "PROGRAMADORESCSI";
