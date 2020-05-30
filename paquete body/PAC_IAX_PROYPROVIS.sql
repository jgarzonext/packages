--------------------------------------------------------
--  DDL for Package Body PAC_IAX_PROYPROVIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_PROYPROVIS" IS
/******************************************************************************
 NOMBRE:     PAC_PROYPROVIS_POS
 PROPÓSITO:  Funciones para ejecutará el proceso de cálculo de las proyecciones.

 REVISIONES:
 Ver        Fecha        Autor             Descripción
 ---------  ----------  ---------------  ------------------------------------
 1.0        02/12/2015   ACL                1. Creación del package.
 2.0        18/02/2016   JCP                2. Validacion de la fecha fin para invocacion paquete

******************************************************************************/

   /*************************************************************************
      Function f_calculo_proyprovis
      ptablas in number: Código idioma
      psseguro: sseguro
      RETURN varchar2 lista de sperson que desempeña el Rol Persona indicado
   *************************************************************************/
   FUNCTION f_calculo_proyprovis(
      psproces IN NUMBER,
      pperiodicidad IN NUMBER,
      pnmes IN NUMBER,
      pnayo IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL,
      pncertif IN NUMBER DEFAULT NULL,
      pmodo IN VARCHAR2 DEFAULT 'R',
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_traza        NUMBER;
      num_err        NUMBER;
      pfecha         DATE;
      v_fecha        VARCHAR2(10);
      vpasexec       NUMBER;
      vparam         VARCHAR2(1000);
      vobject        VARCHAR2(200) := 'PAC_MD_PROYPROVIS.F_CALCULO_PROYPROVIS';
   BEGIN
      IF pnmes < 10 THEN
         v_fecha := CONCAT(CONCAT(CONCAT('01/0', pnmes), '/'), pnayo);
      ELSE
         v_fecha := CONCAT(CONCAT(CONCAT('01/', pnmes), '/'), pnayo);
      END IF;

      pfecha := LAST_DAY(TO_DATE(v_fecha, 'DD/MM/YYYY'));
      num_err := pac_md_proyprovis.f_calculo_proyprovis(psproces, pperiodicidad,
                                                        LAST_DAY(f_sysdate), pfecha, psproduc,
                                                        pnpoliza, pncertif, pmodo, mensajes);
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, num_err);
      RETURN num_err;
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      vobject        VARCHAR2(200) := 'PAC_MD_PROYPROVIS.F_INICIALIZA_PROCESO';
      v_titulo       VARCHAR2(200);
      num_err        NUMBER;
      pnnumlin       NUMBER;
      pcerror        NUMBER;
      conta_err      NUMBER;
      vtexto         VARCHAR2(2000);
   BEGIN
      num_err := pac_md_proyprovis.f_inicializa_proceso(pmes, panyo, pcempres, pfinicio,
                                                        pnproceso, mensajes);
      RETURN num_err;
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
      v_cursor       sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'pac_iax_proyprovis.f_consul_param_mto_pos';
   BEGIN
      vpasexec := 1;
      v_cursor := pac_md_proyprovis.f_consul_param_mto_pos(psproduc, mensajes);
      RETURN v_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_cursor;
   END f_consul_param_mto_pos;
END pac_iax_proyprovis;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROYPROVIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROYPROVIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PROYPROVIS" TO "PROGRAMADORESCSI";
