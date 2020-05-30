--------------------------------------------------------
--  DDL for Package Body PAC_IAX_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IAX_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
   1.1        05/02/2009   JGM                Cambio de commits de java a aqui.


******************************************************************************/

   /*F_GET_CIERRES
   -- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
   Nueva función que seleccionará información sobre cierres dependiendo de los parámetros de entrada.

   Parámetros

   1.    PCEMPRES:   Entrada y numérico.   Empresa.
   2.    PCTIPO:     Entrada y numérico.   Tipo de cierre.
   3.    PCESTADO:   Entrada y numérico.   Estado de cierre.
   4.    PFCIERRE:   Entrada y fecha.      Fecha del cierre.
   5.    MENSAJE: Salida y mensajes del tipo T_IAX_MENSAJES
   */
   FUNCTION f_get_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_cierres IS
      t_cie          t_iax_cierres := t_iax_cierres();
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pcestado=' || pcestado
            || ' pfcierre=' || TO_CHAR(pfcierre, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_Get_Cierres';
   BEGIN
      IF pcempres IS NULL THEN
         t_cie := NULL;
         RAISE e_param_error;
      END IF;

      t_cie := pac_md_cierres.f_get_cierres(pcempres, pctipo, pcestado, pfcierre, mensajes);
      RETURN t_cie;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN t_cie;
      WHEN OTHERS THEN
         t_cie := NULL;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN t_cie;
   END f_get_cierres;

   FUNCTION f_get_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cierres IS
      o_cie          ob_iax_cierres;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pfperini='
            || TO_CHAR(pfperini, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_Get_Cierre';
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfperini IS NULL THEN
         o_cie := NULL;
         RAISE e_param_error;
      END IF;

      o_cie := pac_md_cierres.f_get_cierre(pcempres, pctipo, pfperini, mensajes);
      RETURN o_cie;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN o_cie;
      WHEN OTHERS THEN
         o_cie := NULL;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN o_cie;
   END f_get_cierre;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
Función para grabar los datos de un cierre (programar/desprogramar o grabar nuevo registro).*/
   FUNCTION f_set_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      n_cie          NUMBER := 1;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pcestado=' || pcestado
            || ' pfperini=' || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' pfperfin='
            || TO_CHAR(pfperfin, 'DD/MM/YYYY') || ' pfpercierre='
            || TO_CHAR(pfcierre, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_set_Cierres';
      v_error        NUMBER := 0;
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfperini IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF (pfperini >= pfperfin) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101922);
         v_error := 1;
      END IF;

      -- BUG 0020701 - 02/01/2012 - JMF
      v_error := pac_md_cierres.f_val_fcierre(pcempres, pctipo, pcestado, pfperini, pfperfin,
                                              pfcierre, mensajes);

      IF v_error = 1 THEN
         RAISE e_param_error;
      ELSE
         n_cie := pac_md_cierres.f_set_cierres(pcempres, pctipo, pcestado, pfperini, pfperfin,
                                               pfcierre, mensajes);

         IF n_cie = 0 THEN
            COMMIT;
         END IF;

         RETURN n_cie;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN n_cie;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN n_cie;
   END f_set_cierres;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
Función para ejecutar on-line un cierre programado o un previo.*/
   FUNCTION f_ejecutar(mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER(2);
   BEGIN
      v_result := pac_md_cierres.f_ejecutar(mensajes);
      RETURN v_result;
   END f_ejecutar;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
Nueva función que nos dirá si un cierre es modificable o no lo es.*/
   FUNCTION f_get_modificable(pcestado IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_get_modificable';
      v_result       NUMBER;
   BEGIN
      IF pcestado IS NULL THEN
         RAISE e_param_error;
      END IF;

      /*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM)
      El valor del parámetro pcestado, sólo podrán modificarse los registros que su estado sea diferente de 1 (Cerrado).*/
      IF pcestado <> 1 THEN
         -- BUG 0007352 -  05/02/2009 - jgarciam (JGM) -- Es modificable
         RETURN 0;
      ELSE
         -- BUG 0007352 -  05/02/2009 - jgarciam (JGM) -- NO Es modificable
         -- BUG 0007352 -  05/02/2009 - jgarciam (JGM) -- en caso que el registro no se pueda modificar la función devolverá un 1
         -- BUG 0007352 -  05/02/2009 - jgarciam (JGM) -- y el objeto t_iax_mensajes devolverá el mensaje de 103182 (Este registro no se puede modificar).
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103182);
         RETURN 1;
      END IF;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_modificable;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM) --
Nueva función que hará validaciones del registro de alta y cargará el campo de Estado de cierre según valores correctos.*/
   FUNCTION f_get_validacion(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini OUT DATE,
      pfperfin OUT DATE,
      pfcierre OUT DATE,
      pmodif OUT NUMBER,
      pprevio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      t_cie          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres || ' pctipo=' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_Get_Validacion';
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      t_cie := pac_md_cierres.f_get_validacion(pcempres, pctipo, pfperini, pfperfin, pfcierre,
                                               pmodif, pprevio, mensajes);
      RETURN t_cie;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         t_cie := NULL;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_validacion;

/*F_BORRAR_CIERRE
-- BUG 0007352 -  05/02/2009 - jgarciam (JGM) -- Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1.    PCEMPRES: Entrada y numérico. Empresa.
2.    PCTIPO: Entrada y numérico. Tipo de cierre.
3.    PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4.    PCESTADO: Entrada y númerico. Estado del cierre.
5.    MENSAJE: Salida y mensajes del tipo t_iax_mensajes

*/
   FUNCTION f_borrar_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      pcestado IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_result       NUMBER := 0;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' fperini='
            || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' pctestado=' || pctipo;
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_BORRAR_CIERRE';
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfperini IS NULL
         OR pcestado IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_result := pac_md_cierres.f_borrar_cierre(pcempres, pctipo, pfperini, pcestado,
                                                 mensajes);

      IF v_result = 0 THEN
         COMMIT;
      END IF;

      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_borrar_cierre;

/*-- BUG 0007352 -  05/02/2009 - jgarciam (JGM) --
F_CONFIG_CIERRE Nueva función que nos devuelve la configuración del cierre (Si se pueden modificar las fechas y si se permite un previo).

Parámetros

CEMPRES: Entrada y numérico.
CTIPO: Entrada y numérico.
PFECMODIF: Salida y numérico.
PPREVIO: Salida y numérico.
MENSAJES:Salida y mensajes del tipo t_iax_mensajes*/
   FUNCTION f_config_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfecmodif OUT NUMBER,
      pprevio OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres || ' pctipo=' || pctipo;
      v_result       NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_IAX_CIERRES.F_CONFIG_CIERRE';
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_result := pac_md_cierres.f_config_cierre(pcempres, pctipo, pfecmodif, pprevio,
                                                 mensajes);
      RETURN v_result;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN v_result;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN v_result;
   END f_config_cierre;
END pac_iax_cierres;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "PROGRAMADORESCSI";
