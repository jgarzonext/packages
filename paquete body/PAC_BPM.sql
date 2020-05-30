--------------------------------------------------------
--  DDL for Package Body PAC_BPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_BPM" IS
/******************************************************************************
   NOMBRE:       PAC_MD_BPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/06/2009   JLB                1. Creación del package.
   2.0        12/12/2012   FPG                0024240: LCOL899 - Piloto Vida Grupo
   3.0        03/10/2013   FPG                0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
-- BUG 24240 - FPG - 12/12/2012 - Inicio
   e_condiciones_error EXCEPTION;
   e_cal_param_error EXCEPTION;
   e_actualizar_caso_error EXCEPTION;
   e_crear_proceso_error EXCEPTION;

-- BUG 24240 - FPG - 12/12/2012 - Final
   PROCEDURE p_recupera_error(
      psinterf IN int_resultado.sinterf%TYPE,
      presultado OUT int_resultado.cresultado%TYPE,
      perror OUT int_resultado.terror%TYPE,
      pnerror OUT int_resultado.nerror%TYPE) IS
   BEGIN
      -- Recupero el error
      SELECT r1.cresultado, r1.tcampoerror || ' ' || r1.terror, r1.nerror
        INTO presultado, perror, pnerror
        FROM int_resultado r1
       WHERE r1.sinterf = psinterf
         AND r1.smapead = (SELECT MAX(r2.smapead)
                             FROM int_resultado r2
                            WHERE r2.sinterf = psinterf);
   EXCEPTION
      WHEN OTHERS THEN
         presultado := NULL;
         perror := NULL;
         pnerror := NULL;
   END;

/************************************************************************************************************************
*
* Funciones para lanzar el proceso BPM
*
************************************************************************************************************************/
   /*********************************************************************************************************************
   * Funcion f_crear_proceso
   * Funcion que crea un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_crear_proceso(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vservicio      VARCHAR2(100) := 'crearProceso';
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || pusuario || '|' || ppassword || '|' || vservicio || '|'
                   || pproceso || '|' || NULL;

      FOR i IN 1 .. num_parametros LOOP
         vlineaini := vlineaini || '|' || pparametros(i);
      END LOOP;

      vresultado := pac_int_online.f_int(vccompani, psinterf, 'B001', vlineaini);

      IF vresultado <> 0 THEN
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
         perror := f_axis_literales(151304);
         -- BUG 24240 - FPG - 12/12/2012 - Final
         RETURN vresultado;   --error de interfaz
      END IF;

-- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      RETURN 0;   -- ok
   END;

   /*********************************************************************************************************************
   * Funcion f_envio_evento
   * Funcion que envia un evento (pevento) a un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_envio_evento(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pevento IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vlineaini      VARCHAR2(200);
      vresultado     NUMBER;
      vnerror        NUMBER(10);
      vccompani      NUMBER := pempresa;
      vservicio      VARCHAR2(100) := 'envioEvento';
   BEGIN
      IF psinterf IS NULL THEN
         pac_int_online.p_inicializar_sinterf;
         psinterf := pac_int_online.f_obtener_sinterf;
      END IF;

      vlineaini := pempresa || '|' || pusuario || '|' || ppassword || '|' || vservicio || '|'
                   || pproceso || '|' || pevento;

      FOR i IN 1 .. num_parametros LOOP
         vlineaini := vlineaini || '|' || pparametros(i);
      END LOOP;

      vresultado := pac_int_online.f_int(vccompani, psinterf, 'B001', vlineaini);

      IF vresultado <> 0 THEN
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
         perror := f_axis_literales(151304);
-- BUG 24240 - FPG - 12/12/2012 - Final
         RETURN vresultado;   --error de interfaz
      END IF;

-- Recupero el error
      p_recupera_error(psinterf, vresultado, perror, vnerror);

      IF vresultado <> 0 THEN
         RETURN vresultado;   --error
      END IF;

      IF vnerror <> 0 THEN
         RETURN vnerror;   -- error de la interficie
      END IF;

      RETURN 0;   -- ok
   END;

   /*********************************************************************************************************************
   * Funcion f_calcular_parametros
   * Funcion que recupera los parametros necesarios para lanzar un proceso BPM
   * Parametros: pcempres  : empresa
   *             pcidparam : identificar de parametros
   *             psseguro  : seguro
   *             pnmovimi  : número de movimiento
   *             pnsinies  : número de siniestro
   *             ppparametros out: array con la lista de parametros
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_calcular_parametros(
      pcempres IN NUMBER,
      pcidparam IN NUMBER,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      pparametros OUT tparametros)
      RETURN NUMBER IS
      vparam         VARCHAR2(200);
      -- BUG 24240 - FPG - 12/12/2012 - Inicio
      v_object       VARCHAR2(500) := 'PAC_BPM.f_calcular_parametros';
      v_param        VARCHAR2(500)
         := 'parámetros - pcempres:' || pcempres || ' - pcidparam; ' || pcidparam
            || ' - psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pnsinies:'
            || pnsinies;
      v_pasexec      NUMBER(5) := 1;
      v_numerr       NUMBER(8) := 0;
      v_cramo        seguros.cramo%TYPE;
      v_estado       VARCHAR2(1);
      v_npoliza      seguros.npoliza%TYPE;
      v_ncertif      seguros.ncertif%TYPE;
      v_nsolici      seguros.nsolici%TYPE;
      v_nsuplem      movseguro.nsuplem%TYPE;
      v_crespue250   pregunpolseg.crespue%TYPE;
   -- BUG 24240 - FPG - 12/12/2012 - Fin
   BEGIN
      pparametros := rparametros();
      pparametros.DELETE;
      pparametros.EXTEND(num_parametros);
      -- BUG 24240 - FPG - 12/12/2012 - Inicio
      v_pasexec := 10;

      IF psseguro IS NOT NULL THEN
         SELECT cramo, DECODE(creteni, 0, 'E', 'R') AS estado, npoliza, ncertif, nsolici
           INTO v_cramo, v_estado, v_npoliza, v_ncertif, v_nsolici
           FROM seguros
          WHERE sseguro = psseguro;

         v_pasexec := 11;

         IF pnmovimi IS NOT NULL THEN
            SELECT nsuplem
              INTO v_nsuplem
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            v_pasexec := 12;

            BEGIN
               SELECT NVL(crespue, 0)
                 INTO v_crespue250
                 FROM pregunpolseg
                WHERE sseguro = psseguro
                  AND nmovimi = pnmovimi
                  AND cpregun = 250;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_crespue250 := 0;
            END;
         END IF;
      END IF;

      v_pasexec := 20;

      -- BUG 24240 - FPG - 12/12/2012 - Fin
      FOR reg IN (SELECT   cordparam, tparam
                      FROM cfg_parametros_det_bpm
                     WHERE cempres = pcempres
                       AND cidparam = pcidparam
                  ORDER BY cordparam) LOOP
         vparam := NULL;
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
--         IF reg.tparam = 'sseguro' THEN
--            vparam := psseguro;
--         ELSIF reg.tparam = 'nmovimiento' THEN
--            vparam := pnmovimi;
--         ELSIF reg.tparam = 'nsiniestro' THEN
--            vparam := pnsinies;
--         ELSIF reg.tparam = 'npoliza' THEN
--            SELECT npoliza
--              INTO vparam
--              FROM seguros
--             WHERE sseguro = psseguro;
--         ELSIF reg.tparam = 'nsolicitud' THEN
--            SELECT nsolici
--              INTO vparam
--              FROM seguros
--             WHERE sseguro = psseguro;
--         ELSE
--            RETURN 1;   -- error parametro no definido
--         END IF;
         v_pasexec := 21;

         IF reg.tparam = 'sseguro' THEN
            vparam := psseguro;
         ELSIF reg.tparam = 'nmovimiento' THEN
            vparam := pnmovimi;
         ELSIF reg.tparam = 'nsiniestro' THEN
            vparam := pnsinies;
         ELSIF reg.tparam = 'npoliza' THEN
            vparam := v_npoliza;
         ELSIF reg.tparam = 'nsolicitud' THEN
            vparam := v_nsolici;
         ELSIF reg.tparam = 'cramo' THEN
            vparam := v_cramo;
         ELSIF reg.tparam = 'estado' THEN
            vparam := v_estado;
         ELSIF reg.tparam = 'ncertif' THEN
            vparam := v_ncertif;
         ELSIF reg.tparam = 'nsuplem' THEN
            vparam := v_nsuplem;
         ELSIF reg.tparam = 'nnumcaso' THEN
            vparam := v_crespue250;
         ELSE
            p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                        'reg.tparam = ' || reg.tparam);
            RETURN 1;   -- error parametro no definido
         END IF;

         -- BUG 24240 - FPG - 12/12/2012 - Fin
         pparametros(reg.cordparam) := vparam;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
         p_tab_error(f_sysdate, f_user, v_object, v_pasexec, v_param,
                     'ERROR=' || SQLCODE || ' -' || SQLERRM);
         -- BUG 24240 - FPG - 12/12/2012 - Final
         RETURN 1;
   END;

   /*********************************************************************************************************************
   * Funcion f_evaluar_condicion
   * Funcion que evalua una condición para saber si se debe lanzar el proceso BPM
   * Parametros: pcondicion: condición a evaluar
   *             psseguro  : seguro
   *             pnmovimi  : número de movimiento
   *             pnsinies  : número de siniestro
   *             presult out: resultado de la condicion (TRUE/FALSE)
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_evaluar_condicion(
      pcondicion IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      presult OUT BOOLEAN)
      RETURN NUMBER IS
      -- BUG 24240 - FPG - 12/12/2012 - Inicio
--      vobject        VARCHAR2(500) := 'PAC_BPM.f_evaluar_condicion';
--      vparam         VARCHAR2(500) := 'parámetros - pcondicion:' || pcondicion;
      vobject        VARCHAR2(500) := 'PAC_BPM.f_evaluar_condicion';
      vparam         VARCHAR2(500)
         := 'parámetros - pcondicion:' || pcondicion || ' - psseguro:' || psseguro
            || ' - pnmovimi:' || pnmovimi || ' - pnsinies:' || pnsinies;
      -- BUG 24240 - FPG - 12/12/2012 - Final
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      --
      vselect        VARCHAR2(4000);
      vresult        NUMBER := 0;
      vcursor        INTEGER;
      vresexec       INTEGER;
   BEGIN
      -- BUG 24240 - FPG - 12/12/2012 - Inicio
--         vselect := pcondicion;

      --      IF DBMS_SQL.is_open(vcursor) THEN
--         DBMS_SQL.close_cursor(vcursor);
--      END IF;

      --      vcursor := DBMS_SQL.open_cursor;
--      --ejecuto la select
--      DBMS_SQL.parse(vcursor, vselect, DBMS_SQL.native);

      ----entrada
--      BEGIN
--         DBMS_SQL.bind_variable(vcursor, 'sseguro', psseguro);
--      EXCEPTION
--         WHEN OTHERS THEN
--            NULL;
--      END;

      --      BEGIN
--         DBMS_SQL.bind_variable(vcursor, 'nmovimi', pnmovimi);
--      EXCEPTION
--         WHEN OTHERS THEN
--            NULL;
--      END;

      --      BEGIN
--         DBMS_SQL.bind_variable(vcursor, 'nsinies', pnsinies);
--      EXCEPTION
--         WHEN OTHERS THEN
--            NULL;
--      END;

      ----salida
--      BEGIN
--         DBMS_SQL.bind_variable(vcursor, 'resultado', 1);
--      EXCEPTION
--         WHEN OTHERS THEN
--            NULL;
--      END;

      --      vresexec := DBMS_SQL.EXECUTE(vcursor);
--      DBMS_SQL.variable_value(vcursor, 'resultado', vresult);
--      DBMS_SQL.close_cursor(vcursor);

      --      IF vresult = 1 THEN
--         presult := TRUE;
--      ELSIF vresult = 0 THEN
--         presult := FALSE;
--      ELSE
--         RETURN -1;
--      END IF;

      --      RETURN 0;
--   EXCEPTION
--      WHEN OTHERS THEN
--         IF DBMS_SQL.is_open(vcursor) THEN
--            DBMS_SQL.close_cursor(vcursor);
--         END IF;

      --         RETURN 1;
         -- BUG 24240 - FPG - 12/12/2012 - Final
      --
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
      vselect := pcondicion;
      vpasexec := 10;

      IF DBMS_SQL.is_open(vcursor) THEN
         DBMS_SQL.close_cursor(vcursor);
      END IF;

      vpasexec := 20;
      vcursor := DBMS_SQL.open_cursor;
      --ejecuto la select
      DBMS_SQL.parse(vcursor, vselect, DBMS_SQL.native);
--entrada
      vpasexec := 21;

      BEGIN
         DBMS_SQL.bind_variable(vcursor, ':psseguro', psseguro);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 22;

      BEGIN
         DBMS_SQL.bind_variable(vcursor, ':pnmovimi', pnmovimi);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 23;

      BEGIN
         DBMS_SQL.bind_variable(vcursor, ':pnsinies', pnsinies);
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      vpasexec := 30;
      DBMS_SQL.define_column(vcursor, 1, vresult);
      vpasexec := 40;
      vresexec := DBMS_SQL.EXECUTE(vcursor);
      vpasexec := 50;

      LOOP
         IF DBMS_SQL.fetch_rows(vcursor) > 0 THEN
-- get column values of the row
            DBMS_SQL.COLUMN_VALUE(vcursor, 1, vresult);
         ELSE
            EXIT;
         END IF;
      END LOOP;

      vpasexec := 60;
      DBMS_SQL.close_cursor(vcursor);
      vpasexec := 70;

      IF vresult = 1 THEN
         presult := TRUE;
      ELSIF vresult = 0 THEN
         presult := FALSE;
      ELSE
         RETURN -1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(vcursor) THEN
            DBMS_SQL.close_cursor(vcursor);
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     'vresult = ' || vresult || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1;
   -- BUG 24240 - FPG - 12/12/2012 - Final
   END;

      /*********************************************************************************************************************
      * Funcion f_lanzar_proceso
      * Funcion que dado un sseguro, nmovimi y/o nsinies, perfil del usuario y modo  mira si se tiene que lanzar un proceso
      * BPM.
      * Parametros: psseguro: sseguro de la poliza
      *             pnmovimi: número de movimiento de la poliza
      *             pnsinies: número de siniestro
      *             pcperfil: perfil del usuario
      *             pcmodo  : operación que se está realizando (EMISION,SUPLEMENTO,SINIESTRO,etc)
      *             mensajes out: mensajes de error
      * Return: 0 OK, otro valor error.
      **********************************************************************************************************************/
      -- BUG 28263 - FPG - 03/10/2013 - Inicio - Rehacer la función
      /*
         FUNCTION f_lanzar_proceso(
         psseguro IN NUMBER,
         pnmovimi IN NUMBER,
         pnsinies IN VARCHAR2,
         pcperfil IN VARCHAR2,
         pcmodo IN VARCHAR2,
         perror OUT VARCHAR2)
         RETURN NUMBER IS
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
   --      vobject        VARCHAR2(500) := 'PAC_IAX_BPM.f_lanzar_proceso';
   --      vparam         VARCHAR2(500)
   --         := 'parámetros - psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi
   --            || ' - pnsinies' || pnsinies;
         vobject        VARCHAR2(500) := 'PAC_BPM.f_lanzar_proceso';
         vparam         VARCHAR2(500)
            := 'parámetros - psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi
               || ' - pnsinies:' || pnsinies || ' - pcperfil: ' || pcperfil || ' - pcmodo: '
               || pcmodo;
         -- BUG 24240 - FPG - 12/12/2012 - Final
         vpasexec       NUMBER(5) := 1;
         vnumerr        NUMBER(8) := 0;
         -- vterror        VARCHAR2(4000);
         vsproduc       seguros.sproduc%TYPE;
         vcempres       seguros.cempres%TYPE;
         vtcondicion    cfg_condiciones_bpm.tcondicion%TYPE;
         vcidparam      cfg_proceso_bpm.cidparam%TYPE;
         vcproceso      cfg_proceso_bpm.cproceso%TYPE;
         vcevento       cfg_proceso_bpm.cevento%TYPE;
         vcusuario      cfg_proceso_bpm.cusuario%TYPE;
         vcpassword     cfg_proceso_bpm.cpassword%TYPE;
         vcondicion     BOOLEAN;
         vparametros    tparametros;
         vsinterf       int_mensajes.sinterf%TYPE;
         -- BUG 24240 - FPG - 12/12/2012 - Inicio
         v_nnumcaso     casos_bpm.nnumcaso%TYPE;
         v_cestado      casos_bpm.cestado%TYPE;
         v_cestadoenvio casos_bpm.cestadoenvio%TYPE;
         v_numerr2      NUMBER;
      -- BUG 24240 - FPG - 12/12/2012 - Final
      BEGIN
         SELECT sproduc, cempres
           INTO vsproduc, vcempres
           FROM seguros
          WHERE sseguro = psseguro;

   -- BUG 24240 - FPG - 12/12/2012 - Inicio
         vpasexec := 10;

   -- BUG 24240 - FPG - 12/12/2012 - Final
         IF NVL(pac_parametros.f_parempresa_n(vcempres, 'BPM'), 0) = 1 THEN
            BEGIN
               SELECT pr.cproceso, pr.cevento, pr.cidparam, co.tcondicion, pr.cusuario,
                      pr.cpassword
                 INTO vcproceso, vcevento, vcidparam, vtcondicion, vcusuario,
                      vcpassword
                 FROM cfg_proceso_bpm pr, cfg_condiciones_bpm co
                WHERE pr.cempres = vcempres
                  AND pr.sproduc = vsproduc
                  AND pr.cperfil = pcperfil
                  AND pr.cactivo = 1   -- que este activo el proceso
                  AND pr.cmodo = pcmodo
                  AND pr.cempres = co.cempres(+)
                  AND pr.cidcond = co.cidcond(+);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- BUG 24240 - FPG - 12/12/2012 - Inicio
                  vpasexec := 11;

   -- BUG 24240 - FPG - 12/12/2012 - Final
                  BEGIN
                     SELECT pr.cproceso, pr.cevento, pr.cidparam, co.tcondicion, pr.cusuario,
                            pr.cpassword
                       INTO vcproceso, vcevento, vcidparam, vtcondicion, vcusuario,
                            vcpassword
                       FROM cfg_proceso_bpm pr, cfg_condiciones_bpm co
                      WHERE pr.cempres = vcempres
                        AND pr.sproduc = vsproduc
                        AND pr.cperfil = '*'   -- si no tiene miro si tiene el general
                        AND pr.cactivo = 1   -- que este activo el proceso
                        AND pr.cmodo = pcmodo
                        AND pr.cempres = co.cempres(+)
                        AND pr.cidcond = co.cidcond(+);
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 0;   -- ok no hay proceso bpm definido , salimos
                  END;
            END;

   -- BUG 24240 - FPG - 12/12/2012 - Inicio
            vpasexec := 20;

   -- BUG 24240 - FPG - 12/12/2012 - Final
            IF vtcondicion IS NOT NULL THEN
               vnumerr := f_evaluar_condicion(vtcondicion, psseguro, pnmovimi, pnsinies,
                                              vcondicion);

               IF vnumerr <> 0 THEN
                  -- BUG 24240 - FPG - 12/12/2012 - Inicio
                  --   RETURN 10;   --error calculando condiciones
                  vpasexec := 21;
                  RAISE e_condiciones_error;
               -- BUG 24240 - FPG - 12/12/2012 - Final
               END IF;
            ELSE
               vcondicion := TRUE;
            END IF;

   -- BUG 24240 - FPG - 12/12/2012 - Inicio
            vpasexec := 30;

   -- BUG 24240 - FPG - 12/12/2012 - Final
            IF vcidparam IS NOT NULL THEN
               vnumerr := f_calcular_parametros(vcempres, vcidparam, psseguro, pnmovimi,
                                                pnsinies, vparametros);

               IF vnumerr <> 0 THEN
                  -- BUG 24240 - FPG - 12/12/2012 - Inicio
                  --   RETURN 20;   -- ha habido error al calcular parametros
                  vpasexec := 31;
                  RAISE e_cal_param_error;
               -- BUG 24240 - FPG - 12/12/2012 - Final
               END IF;
            ELSE
               vparametros := rparametros();
               vparametros.DELETE;
               vparametros.EXTEND(num_parametros);
            END IF;

   -- BUG 24240 - FPG - 12/12/2012 - Inicio
            vpasexec := 40;

   -- BUG 24240 - FPG - 12/12/2012 - Final
            IF vcondicion THEN
               -- BUG 24240 - FPG - 12/12/2012 - Inicio
               vpasexec := 41;

               IF pcmodo IN('EMITIDA', 'RETENIDA') THEN
                  IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'BPM_EMISION'), 0) = 1 THEN
                     vpasexec := 42;
                     v_nnumcaso := NULL;

                     IF pcmodo = 'EMITIDA' THEN
                        v_cestado := 3;
                     ELSE
                        v_cestado := 2;
                     END IF;

                     v_cestadoenvio := 1;
                     v_numerr2 := pac_gestionbpm.f_actualizar_estado_caso(psseguro, pnmovimi,
                                                                          v_nnumcaso, v_cestado,
                                                                          v_cestadoenvio);
                     vpasexec := 43;

                     IF v_numerr2 <> 0 THEN
                        vpasexec := 44;
                        RAISE e_actualizar_caso_error;
                     END IF;
                  END IF;
               END IF;

               vpasexec := 50;

               -- BUG 24240 - FPG - 12/12/2012 - Final
               IF vcevento IS NOT NULL THEN
                  vnumerr := f_envio_evento(vcempres, vcusuario,   -- pusuario    IN VARCHAR2,
                                            vcpassword,   --ppassword   IN VARCHAR2,
                                            vcproceso, vcevento, vparametros, vsinterf, perror);

                  IF vnumerr <> 0 THEN
                     -- BUG 24240 - FPG - 12/12/2012 - Inicio
                     --RETURN vnumerr;
                     vpasexec := 51;

                     IF pcmodo IN('EMITIDA', 'RETENIDA') THEN
                        IF NVL(pac_parametros.f_parproducto_n(vsproduc, 'BPM_EMISION'), 0) = 1 THEN
                           vpasexec := 52;
                           v_nnumcaso := NULL;

                           IF pcmodo = 'EMITIDA' THEN
                              v_cestado := 3;
                           ELSE
                              v_cestado := 2;
                           END IF;

                           v_cestadoenvio := 2;
                           v_numerr2 := pac_gestionbpm.f_actualizar_estado_caso(psseguro,
                                                                                pnmovimi,
                                                                                v_nnumcaso,
                                                                                v_cestado,
                                                                                v_cestadoenvio);
                           vpasexec := 53;

                           IF v_numerr2 <> 0 THEN
                              vpasexec := 54;
                              RAISE e_actualizar_caso_error;
                           END IF;
                        END IF;
                     END IF;

                     vpasexec := 55;
                     RAISE e_crear_proceso_error;
                  -- BUG 24240 - FPG - 12/12/2012 - Final
                  END IF;
               ELSE
   -- BUG 24240 - FPG - 12/12/2012 - Inicio
                  vpasexec := 60;
   -- BUG 24240 - FPG - 12/12/2012 - Final
                  vnumerr := f_crear_proceso(vcempres, vcusuario,   -- pusuario    IN VARCHAR2,
                                             vcpassword,   --ppassword   IN VARCHAR2,
                                             vcproceso, vparametros, vsinterf, perror);

                  IF vnumerr <> 0 THEN
                     -- BUG 24240 - FPG - 12/12/2012 - Inicio
                        --RETURN vnumerr;
                     RAISE e_crear_proceso_error;
                  -- BUG 24240 - FPG - 12/12/2012 - Final
                  END IF;
               END IF;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN e_param_error THEN
            perror := f_axis_literales(1000005);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
            RETURN 1000005;
         WHEN e_condiciones_error THEN
            perror := f_axis_literales(9904625);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
            RETURN 9904625;
         WHEN e_cal_param_error THEN
            perror := f_axis_literales(9904626);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
            RETURN 9904626;
         WHEN e_actualizar_caso_error THEN
            perror := f_axis_literales(v_numerr2);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
            RETURN v_numerr2;
         WHEN e_crear_proceso_error THEN
            perror := 'vnumerr=' || vnumerr || ' - Error: ' || f_axis_literales(9002012);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
            RETURN vnumerr;
         WHEN OTHERS THEN
            perror := f_axis_literales(1000001);
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                        f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
            RETURN 1000001;
      END;


      */
   FUNCTION f_lanzar_proceso(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      pcperfil IN VARCHAR2,
      pcmodo IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_BPM.f_lanzar_proceso';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi
            || ' - pnsinies:' || pnsinies || ' - pcperfil: ' || pcperfil || ' - pcmodo: '
            || pcmodo;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      -- vterror        VARCHAR2(4000);
      vsproduc       seguros.sproduc%TYPE;
      vcempres       seguros.cempres%TYPE;
      vtcondicion    cfg_condiciones_bpm.tcondicion%TYPE;
      vcidparam      cfg_proceso_bpm.cidparam%TYPE;
      vcproceso      cfg_proceso_bpm.cproceso%TYPE;
      vcevento       cfg_proceso_bpm.cevento%TYPE;
      vcusuario      cfg_proceso_bpm.cusuario%TYPE;
      vcpassword     cfg_proceso_bpm.cpassword%TYPE;
      vcondicion     BOOLEAN;
      vparametros    tparametros;
      vsinterf       int_mensajes.sinterf%TYPE;
      v_nnumcaso     casos_bpm.nnumcaso%TYPE;
      v_cestado      casos_bpm.cestado%TYPE;
      v_cestadoenvio casos_bpm.cestadoenvio%TYPE;
      v_numerr2      NUMBER;
      v_ttratarfun   cfg_proceso_bpm.ttratarfun%TYPE;
      v_sentencia    VARCHAR2(2000);
   BEGIN
      SELECT sproduc, cempres
        INTO vsproduc, vcempres
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 10;

      IF NVL(pac_parametros.f_parempresa_n(vcempres, 'BPM'), 0) = 1 THEN
         BEGIN
            SELECT pr.cproceso, pr.cevento, pr.cidparam, co.tcondicion, pr.cusuario,
                   pr.cpassword, pr.ttratarfun
              INTO vcproceso, vcevento, vcidparam, vtcondicion, vcusuario,
                   vcpassword, v_ttratarfun
              FROM cfg_proceso_bpm pr, cfg_condiciones_bpm co
             WHERE pr.cempres = vcempres
               AND pr.sproduc = vsproduc
               AND pr.cperfil = pcperfil
               AND pr.cactivo = 1   -- que este activo el proceso
               AND pr.cmodo = pcmodo
               AND pr.cempres = co.cempres(+)
               AND pr.cidcond = co.cidcond(+);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vpasexec := 11;

               BEGIN
                  SELECT pr.cproceso, pr.cevento, pr.cidparam, co.tcondicion, pr.cusuario,
                         pr.cpassword, pr.ttratarfun
                    INTO vcproceso, vcevento, vcidparam, vtcondicion, vcusuario,
                         vcpassword, v_ttratarfun
                    FROM cfg_proceso_bpm pr, cfg_condiciones_bpm co
                   WHERE pr.cempres = vcempres
                     AND pr.sproduc = vsproduc
                     AND pr.cperfil = '*'   -- si no tiene miro si tiene el general
                     AND pr.cactivo = 1   -- que este activo el proceso
                     AND pr.cmodo = pcmodo
                     AND pr.cempres = co.cempres(+)
                     AND pr.cidcond = co.cidcond(+);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 0;   -- ok no hay proceso bpm definido , salimos
               END;
         END;

         vpasexec := 20;

         IF vtcondicion IS NOT NULL THEN
            vnumerr := f_evaluar_condicion(vtcondicion, psseguro, pnmovimi, pnsinies,
                                           vcondicion);

            IF vnumerr <> 0 THEN
               vpasexec := 21;
               RAISE e_condiciones_error;
            END IF;
         ELSE
            vcondicion := TRUE;
         END IF;

         vpasexec := 30;

         IF vcidparam IS NOT NULL THEN
            vnumerr := f_calcular_parametros(vcempres, vcidparam, psseguro, pnmovimi,
                                             pnsinies, vparametros);

            IF vnumerr <> 0 THEN
               vpasexec := 31;
               RAISE e_cal_param_error;
            END IF;
         ELSE
            vparametros := rparametros();
            vparametros.DELETE;
            vparametros.EXTEND(num_parametros);
         END IF;

         vpasexec := 40;

         IF vcondicion THEN
            vpasexec := 41;

            IF v_ttratarfun IS NOT NULL THEN
               vpasexec := 42;
               v_sentencia := 'begin  :v_ret := ' || v_ttratarfun
                              || '(:psseguro, :pnmovimi, :pnsinies, :perror); end;';

               BEGIN
                  EXECUTE IMMEDIATE v_sentencia
                              USING OUT vnumerr, psseguro, pnmovimi, pnsinies, OUT perror;
               EXCEPTION
                  WHEN OTHERS THEN
                     perror := SUBSTR(SQLERRM, 1, 100);
                     p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
                     RAISE e_crear_proceso_error;
               END;

               vpasexec := 43;

               IF vnumerr <> 0 THEN
                  RAISE e_crear_proceso_error;
               END IF;
            --Modelo antiguo por map
            ELSE
               IF vcevento IS NOT NULL THEN
                  vpasexec := 50;
                  vnumerr := f_envio_evento(vcempres, vcusuario,   -- pusuario    IN VARCHAR2,
                                            vcpassword,   --ppassword   IN VARCHAR2,
                                            vcproceso, vcevento, vparametros, vsinterf,
                                            perror);

                  IF vnumerr <> 0 THEN
                     vpasexec := 51;
                     RAISE e_crear_proceso_error;
                  END IF;
               ELSE
                  vpasexec := 60;
                  vnumerr := f_crear_proceso(vcempres, vcusuario,   -- pusuario    IN VARCHAR2,
                                             vcpassword,   --ppassword   IN VARCHAR2,
                                             vcproceso, vparametros, vsinterf, perror);

                  IF vnumerr <> 0 THEN
                     RAISE e_crear_proceso_error;
                  END IF;
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         perror := f_axis_literales(1000005);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
         RETURN 1000005;
      WHEN e_condiciones_error THEN
         perror := f_axis_literales(9904625);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
         RETURN 9904625;
      WHEN e_cal_param_error THEN
         perror := f_axis_literales(9904626);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
         RETURN 9904626;
      WHEN e_crear_proceso_error THEN
         perror := 'vnumerr=' || vnumerr || ' - Error: ' || f_axis_literales(9002012);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, perror);
         RETURN vnumerr;
      WHEN OTHERS THEN
         perror := f_axis_literales(1000001);
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                     f_axis_literales(1000001) || ' - ' || SQLCODE || ' -' || SQLERRM);
         RETURN 1000001;
   END;

/*********************************************************************************************************************
--
-- Funciones propias del piloto y demos.
--
--
**********************************************************************************************************************/
   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      pcmodo IN VARCHAR2,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      oestsseguro OUT NUMBER,
      onmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pcmodo:' || pcmodo || ' - pcform:' || pcform
            || ' - pccampo:' || pccampo;
      vobject        VARCHAR2(200) := 'pac_bpel.F_Inicializar_Modificacion';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pcmodo IS NULL
         OR pcform IS NULL
         OR pccampo IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pk_nueva_produccion.f_inicializar_modificacion(psseguro, oestsseguro, onmovimi,
                                                               pcmodo, pcform, pccampo);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
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
   END f_inicializar_modificacion;

   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'pac_bpel.F_GRABAR_ALTA_POLIZA';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pk_nueva_produccion.f_grabar_alta_poliza(psseguro);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
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
   END f_grabar_alta_poliza;

   /*************************************************************************
      Acepta la propuesta retenida
      param in     psseguro  : Código seguro
      param in     pnmovimi  : Número de movimiento
      param in     pfefecto  : Fecha efecto
      param in out mensajes  : mesajes de error
      return                 : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pnriesgo:'
            || pnriesgo || ' - pfefecto:' || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_BPEL.F_ACEPTARPROPUESTA';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_gestion_retenidas.f_aceptar_propuesta(psseguro, pnmovimi, pnriesgo,
                                                          pfefecto);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151984);   -- Solicitud aceptada
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
   END f_aceptarpropuesta;

   FUNCTION f_emitirpropuesta(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN NUMBER,
      ppoliza OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_BPEL.F_EMITIRPROPUESTA';
      vparam         VARCHAR2(500)
                         := 'parámetros - psseguro:' || psseguro || ' - pnmovimi:' || pnmovimi;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      vnumerr := pac_iax_produccion.f_set_consultapoliza(psseguro, mensajes);

      IF vnumerr != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      ELSE
         vnumerr := pac_md_produccion.f_emitirpropuesta(psseguro, pnmovimi, ppoliza, mensajes);

         IF vnumerr != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
            RAISE e_object_error;
         END IF;

         -- poruqe la funcion no devuelve nada !!!!en el campo ppoliza
         SELECT npoliza
           INTO ppoliza
           FROM seguros
          WHERE sseguro = psseguro;
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
   END f_emitirpropuesta;

   /*************************************************************************
      Rechaza la propuesta retenida
      param in     psseguro  : Código seguro
      param in     pnmovimi  : Número de movimiento
      param in     pcmotmov  : Código motivo rechazo
      param in     pnsuplem  : Código suplemento
      param in     ptobserva : Observaciones
      param in out mensajes  : mesajes de error
      return                 : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pnriesgo:'
            || pnriesgo || ' - pcmotmov:' || pcmotmov || ' - pnsuplem:' || pnsuplem
            || ' - ptobserva:' || ptobserva;
      vobject        VARCHAR2(200) := 'PAC_BPEL.F_RECHAZARPROPUESTA';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pnriesgo IS NULL
         OR pcmotmov IS NULL
         OR pnsuplem IS NULL
         OR ptobserva IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_gestion_retenidas.f_rechazar_propuesta(psseguro, pnmovimi, pnriesgo,
                                                           pcmotmov, pnsuplem, NULL, NULL,
                                                           ptobserva);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 700341);   -- Solicitud Anulada
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
   END f_rechazarpropuesta;

   /*************************************************************************
      Acepta con sobreprima la propuesta retenida
      param in     psseguro  : Código seguro
      param in     pnmovimi  : Número de movimiento
      param in     pfefecto  : Fecha efecto
      param in     pcrecarg  : Recargo aplicado para establecer la sobreprima
      param in out mensajes  : mesajes de error
      return                 : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarsobreprima(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pprecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pnriesgo:'
            || pnriesgo || ' - pfefecto:' || pfefecto || ' - pprecarg:' || pprecarg;
      vobject        VARCHAR2(200) := 'PAC_BPEL.F_ACEPTARSOBREPRIMA';
      nerror         NUMBER;
      v_estsseguro   NUMBER;
      v_nmovimi      NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pnriesgo IS NULL
         OR pfefecto IS NULL
         OR pprecarg IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := f_inicializar_modificacion(psseguro, 'SUPLEMENTO', 'BBDD', '*', v_estsseguro,
                                           v_nmovimi, mensajes);

      IF nerror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      ELSE
         UPDATE estgaranseg
            SET precarg = pprecarg
          WHERE sseguro = v_estsseguro
            AND nmovimi = v_nmovimi
            AND nriesgo = pnriesgo
            AND(finiefe <= pfefecto
                AND(ffinefe IS NULL
                    OR ffinefe >= pfefecto));

         UPDATE motreten_rev
            SET tobserva = tobserva || ' Se ha aceptado la propuesta con una sobreprima.'
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = 1;

         nerror := f_grabar_alta_poliza(v_estsseguro, mensajes);

         IF nerror != 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
            RAISE e_object_error;
         ELSE
            nerror := pac_gestion_retenidas.f_cambio_sobreprima(v_estsseguro, v_nmovimi,
                                                                pnriesgo);

            IF nerror <> 0 THEN
               pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
               RAISE e_object_error;
            ELSE
               nerror := f_aceptarpropuesta(psseguro, v_nmovimi, pnriesgo, pfefecto, mensajes);

               IF nerror <> 0 THEN
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
                  RAISE e_object_error;
               END IF;
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
   END f_aceptarsobreprima;

   FUNCTION f_set_citamedica(
      psseguro IN seguros.sseguro%TYPE,
      p_fecha_hora_visita IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vobject        VARCHAR2(500) := 'PAC_BPM.F_SET_CITAMEDICA';
      vparam         VARCHAR2(500)
         := 'parámetros - psseguro:' || psseguro || ' - p_fecha_hora_visita:'
            || TO_CHAR(p_fecha_hora_visita, 'dd/mm/yyyy hh24:mi');
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
   BEGIN
      IF psseguro IS NULL
         OR p_fecha_hora_visita IS NULL THEN
         RAISE e_param_error;
      ELSE
         UPDATE motreten_rev
            SET tobserva = tobserva
                           || DECODE(NVL(INSTR(tobserva, 'visita'), 0),
                                     0, 'Se ha concertado visita médica para el día ',
                                     CHR(10) || 'Cambio de visita médica para el día ')
                           || TO_CHAR(p_fecha_hora_visita, 'dd/mm/yyyy') || ' a las '
                           || TO_CHAR(p_fecha_hora_visita, 'hh24:mi') || '.'
          WHERE sseguro = psseguro
            AND nriesgo = 1
            AND nmovimi = 1;
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
   END f_set_citamedica;
END pac_bpm;

/

  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "PROGRAMADORESCSI";
