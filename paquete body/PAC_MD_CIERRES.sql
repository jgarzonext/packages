--------------------------------------------------------
--  DDL for Package Body PAC_MD_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
   2.0        16/04/2009   DCT                2. Modificación f_ejecutar
   3.0        13/12/2012   AMJ                3. 0025022: LCOL_A001-QT 478: FIN_ID1_ Cierres Mensaje de Error Claro al Eliminar un Cierre
******************************************************************************/

   /*F_GET_CIERRES
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
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_cierres IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pcestado=' || pcestado
            || ' pfcierre=' || TO_CHAR(pfcierre, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_Get_Cierres';
      list_cierres   t_iax_cierres := t_iax_cierres();
      vtwhere        VARCHAR2(500);

      CURSOR cur_cierres IS
         SELECT   cie.cempres, emp.tempres, cie.ctipo,
                  ff_desvalorfijo(167, pac_md_common.f_get_cxtidioma(), cie.ctipo) tctipo,
                  pds.norden, cie.fperini, cie.fperfin, cie.fcierre, cie.cestado,
                  ff_desvalorfijo(168, pac_md_common.f_get_cxtidioma(), cie.cestado) tcestado,
                  cie.sproces, cie.fproces
             FROM cierres cie, pds_program_cierres pds, empresas emp
            WHERE cie.cempres = pcempres
              AND cie.ctipo = NVL(pctipo, cie.ctipo)
              AND cie.fcierre = NVL(pfcierre, cie.fcierre)
              AND cie.cestado = NVL(pcestado, cie.cestado)
              AND cie.cempres = emp.cempres
              AND cie.cempres = pds.cempres
              AND cie.ctipo = pds.ctipo
              AND pds.cactivo = 1
         ORDER BY cie.fcierre DESC;
   BEGIN
      IF pcempres IS NULL THEN
         list_cierres := NULL;
         RAISE e_param_error;
      END IF;

      FOR v_cierres IN cur_cierres LOOP
         list_cierres.EXTEND;
         list_cierres(list_cierres.LAST) := ob_iax_cierres();
         list_cierres(list_cierres.LAST).cempres := v_cierres.cempres;
         list_cierres(list_cierres.LAST).tempres := v_cierres.tempres;
         list_cierres(list_cierres.LAST).ctipo := v_cierres.ctipo;
         list_cierres(list_cierres.LAST).ttipo := v_cierres.tctipo;
         list_cierres(list_cierres.LAST).fperini := v_cierres.fperini;
         list_cierres(list_cierres.LAST).fperfin := v_cierres.fperfin;
         list_cierres(list_cierres.LAST).fcierre := v_cierres.fcierre;
         list_cierres(list_cierres.LAST).cestado := v_cierres.cestado;
         list_cierres(list_cierres.LAST).testado := v_cierres.tcestado;
         list_cierres(list_cierres.LAST).sproces := v_cierres.sproces;
         list_cierres(list_cierres.LAST).fproces := v_cierres.fproces;
      END LOOP;

      RETURN list_cierres;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur_cierres%ISOPEN THEN
            CLOSE cur_cierres;
         END IF;

         RETURN list_cierres;
      WHEN OTHERS THEN
         list_cierres := NULL;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur_cierres%ISOPEN THEN
            CLOSE cur_cierres;
         END IF;

         RETURN list_cierres;
   END f_get_cierres;

   FUNCTION f_get_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_cierres IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pfperini='
            || TO_CHAR(pfperini, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_Get_Cierre';
      obj_cierres    ob_iax_cierres := ob_iax_cierres();

      CURSOR cur_cierre IS
         SELECT cie.cempres, cie.ctipo, emp.tempres,
                ff_desvalorfijo(167, pac_md_common.f_get_cxtidioma(), cie.ctipo) tctipo,
                cie.cestado,
                ff_desvalorfijo(168, pac_md_common.f_get_cxtidioma(), cie.cestado) tcestado,
                cie.fperini, cie.fperfin, cie.fcierre, cie.sproces, cie.fproces
           FROM cierres cie, empresas emp
          WHERE cie.cempres = pcempres
            AND cie.cempres = emp.cempres
            AND cie.ctipo = pctipo
            AND cie.fperini = pfperini;
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfperini IS NULL THEN
         obj_cierres := NULL;
         RAISE e_param_error;
      END IF;

      obj_cierres := NULL;

      FOR v_cierres IN cur_cierre LOOP
         obj_cierres := ob_iax_cierres();
         obj_cierres.cempres := v_cierres.cempres;
         obj_cierres.tempres := v_cierres.tempres;
         obj_cierres.ctipo := v_cierres.ctipo;
         obj_cierres.ttipo := v_cierres.tctipo;
         obj_cierres.fperini := v_cierres.fperini;
         obj_cierres.fperfin := v_cierres.fperfin;
         obj_cierres.fcierre := v_cierres.fcierre;
         obj_cierres.cestado := v_cierres.cestado;
         obj_cierres.testado := v_cierres.tcestado;
         obj_cierres.sproces := v_cierres.sproces;
         obj_cierres.fproces := v_cierres.fproces;
      END LOOP;

      IF obj_cierres IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 120135);
         RAISE e_object_error;
      END IF;

      RETURN obj_cierres;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur_cierre%ISOPEN THEN
            CLOSE cur_cierre;
         END IF;

         RETURN obj_cierres;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur_cierre%ISOPEN THEN
            CLOSE cur_cierre;
         END IF;

         RETURN obj_cierres;
      WHEN OTHERS THEN
         obj_cierres := NULL;
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur_cierre%ISOPEN THEN
            CLOSE cur_cierre;
         END IF;

         RETURN obj_cierres;
   END f_get_cierre;

   FUNCTION f_set_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pcestado=' || pcestado
            || ' pfperini=' || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' pfperfin='
            || TO_CHAR(pfperfin, 'DD/MM/YYYY') || ' pfpercierre='
            || TO_CHAR(pfcierre, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_Set_Cierres';
      n_cierres      NUMBER := 1;
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
      v_error := pac_cierres.f_val_fcierre(pcempres, pctipo, pcestado, pfperini, pfperfin,
                                           pfcierre);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         v_error := 1;
      END IF;

      IF v_error = 1 THEN
         RAISE e_param_error;
      ELSE
         n_cierres := pac_cierres.f_set_cierres(pcempres, pctipo, pcestado, pfperini,
                                                pfperfin, pfcierre);
      END IF;

      IF n_cierres <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, n_cierres);
         RAISE e_object_error;
      END IF;

      RETURN n_cierres;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN n_cierres;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN n_cierres;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN n_cierres;
   END f_set_cierres;

   /*Función para ejecutar on-line un cierre programado o un previo.*/
   FUNCTION f_ejecutar(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_ejecutar';
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);
      v_result       NUMBER;
      vidioma        NUMBER;
      vjob           NUMBER;
      vmensaje       NUMBER;
   BEGIN
      -- bug 0022185
      vpasexec := 10;
      --BUG 7352 - 10/06/2009 - DCT
      vidioma := pac_md_common.f_get_cxtidioma();
      vparam := vidioma;
      --vJob := pac_jobs.f_ejecuta_job(null,'Ejecutar_Cierres(' || vidioma || ');',null,  mensajes);
      -- BUG 21546_108727- 01/03/2012 - JLTS - Se elimina la utilización de mensajes en pac_jobs.f_ejecuta_job
      vpasexec := 20;
      vmensaje := pac_jobs.f_ejecuta_job(NULL, 'Ejecutar_Cierres(' || vidioma || ');', NULL);

      IF vmensaje > 0 THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || vmensaje);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, vmensaje);
         RETURN 1;
      END IF;

      --Ejecutar_Cierres(pac_md_common.f_get_CXTIdioma());
      --FI BUG 7352 - 10/06/2009 - DCT
      vpasexec := 30;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam || ' men=' || vmensaje,
                     SQLCODE || ' ' || SQLERRM);
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_ejecutar;

/*Nueva función que hará validaciones del registro de alta y cargará el campo de Estado de cierre según valores correctos.*/
   FUNCTION f_get_validacion(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini OUT DATE,
      pfperfin OUT DATE,
      pfcierre OUT DATE,
      pmodif OUT NUMBER,
      pprevio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pfperini='
            || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' pfperfin='
            || TO_CHAR(pfperfin, 'DD/MM/YYYY') || ' pfcierre='
            || TO_CHAR(pfcierre, 'DD/MM/YYYY');
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_get_Validacion';
      v_cuenta       NUMBER;
      v_result       NUMBER;
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Se ha de comprobar que el tipo de cierre exista en la tabla pds_program_cierres
      -- para la empresa y para el tipo de cierre sino existe no debe seguir,
      -- ha de devolver mensaje de no poder dar de alta el registro.
      SELECT COUNT(*)
        INTO v_cuenta
        FROM pds_program_cierres
       WHERE cempres = pcempres
         AND ctipo = pctipo;

      IF v_cuenta = 0 THEN
         --no existe el tipo de cierre para esa empresa en pds_program cierres.
         -- NOS SE HAN PODIDO GRABAR LOS DATOS
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 101283);
         RAISE e_object_error;
      END IF;

      --cuento cuantos cierres del tipo y empresa dada estan sin cerrar.
      SELECT COUNT(*)
        INTO v_cuenta
        FROM cierres cie
       WHERE cie.cempres = pcempres
         AND cie.ctipo = pctipo
         AND cie.cestado <> 1;

      IF v_cuenta > 0 THEN
         --no todos estan cerrados
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 108034);
         RAISE e_object_error;
      ELSE
         -- TODOS CERRADOS
         -- miro si al menos hay algun cierre para poder calcular fechas siguientes
         SELECT COUNT(*)
           INTO v_cuenta
           FROM cierres cie
          WHERE cie.cempres = pcempres
            AND cie.ctipo = pctipo;

         IF v_cuenta > 0 THEN
            /*VALE! Ha de mirar las fechas del último cierre del mismo tipo que entra por parámetro, para proponer las del siguiente que serán:
            Esto lo hará la función:*/
            v_result := pac_cierres.f_fechas_nuevo_cierre(pcempres, pctipo, pfperini,
                                                          pfperfin, pfcierre);

            IF v_result <> 0 THEN
               RAISE e_object_error;
            END IF;

            --Se han de saber cómo configurar el cierre. Esto lo hará la función:
            v_result := pac_cierres.f_config_cierre(pcempres, pctipo, pmodif, pprevio);

            IF v_result <> 0 THEN
               RAISE e_object_error;
            END IF;
         ELSE
            -- OJO! es el primer cierre de este tipo; excepcionalmente dejo que PMODIF sea 1
             --Se han de saber cómo configurar el cierre. Esto lo hará la función:
            v_result := pac_cierres.f_config_cierre(pcempres, pctipo, pmodif, pprevio);
            pmodif := 1;

            IF v_result <> 0 THEN
               RAISE e_object_error;
            END IF;
         END IF;
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
   END f_get_validacion;

/*F_BORRAR_CIERRE
Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1. PCEMPRES: Entrada y numérico. Empresa.
2. PCTIPO: Entrada y numérico. Tipo de cierre.
3. PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4. PCESTADO: Entrada y númerico. Estado del cierre.
5. MENSAJE: Entrada y Salida.  mensajes del tipo t_iax_mensajes

*/
   FUNCTION f_borrar_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      pcestado IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcempres=' || pcempres || ' pctipo=' || pctipo || ' pfperini='
            || TO_CHAR(pfperini, 'DD/MM/YYYY') || ' pcestado=' || pcestado;
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_BORRAR_CIERRE';
      v_result       NUMBER := 0;
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL
         OR pfperini IS NULL
         OR pcestado IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF pcestado <> 0 THEN
         --BUG:25022 13-12-2012 0025022: LCOL_A001-QT 478: FIN_ID1_ Cierres Mensaje de Error Claro al Eliminar un Cierre
         -- pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000402);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904634);
         RAISE e_object_error;
      END IF;

      v_result := pac_cierres.f_borrar_cierre(pcempres, pctipo, pfperini, pcestado);
      RETURN v_result;
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
   END f_borrar_cierre;

/*
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres || ' pctipo=' || pctipo;
      v_result       NUMBER := 0;
      vobject        VARCHAR2(200) := 'PAC_MD_CIERRES.F_CONFIG_CIERRE';
   BEGIN
      IF pcempres IS NULL
         OR pctipo IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_result := pac_cierres.f_config_cierre(pcempres, pctipo, pfecmodif, pprevio);

      DECLARE
         v_cuenta       NUMBER;
      BEGIN
         SELECT COUNT(*)
           INTO v_cuenta
           FROM cierres cie
          WHERE cie.cempres = pcempres
            AND cie.ctipo = pctipo;

         IF v_cuenta = 0 THEN
            pfecmodif := 1;
         END IF;
      END;

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

   -- BUG 0020701 - 02/01/2012 - JMF
   -- Realiza validaciones sobre la fecha de cierre (0=Correcto, 1=Error).
   FUNCTION f_val_fcierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      v_error        NUMBER;
   BEGIN
      v_error := 0;
      v_error := pac_cierres.f_val_fcierre(pcempres, pctipo, pcestado, pfperini, pfperfin,
                                           pfcierre);

      IF v_error <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, v_error);
         v_error := 1;
      END IF;

      RETURN v_error;
   END f_val_fcierre;
END pac_md_cierres;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "PROGRAMADORESCSI";
