--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_INT" IS
   /******************************************************************************
       NOMBRE:     pac_propio_int
       PROPÓSITO:  Funciones propias

       REVISIONES:
       Ver        Fecha        Autor             Descripción
       ---------  ----------  ---------------  ------------------------------------
       1.0        09/10/2009   DRA               1. 0010381: AGA001 - Creación entorno AGA
       2.0        22/02/2010   DRA               2. 0013318: ENSA001 - Creació de l'empresa ENSA a tots els entorns + Neteja de l'entorn de Validació
       3.0        23/02/2011   DRA               3. 0017696: CCAT001 - Creació de l'entorn de VAL de CTV
       4.0        08/03/2011   DRA               4. 0017656: MSGV001 - Creació de la nova empresa
       5.0        09/06/2011   DRA               5. 0018773: CIV800-Cambio Concepto en Cobro Online
       6.0        01/03/2012   DRA               6. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_busca_agente_persona(psnip IN VARCHAR2, psinterf IN NUMBER, ocagente OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_propio_int.f_busca_agente_persona';
      vparam         VARCHAR2(500)
                             := 'parámetros - psnip: ' || psnip || ' - psinterf: ' || psinterf;
      vpasexec       NUMBER(5) := 1;
      v_propio       VARCHAR2(100);
      ss             VARCHAR2(2000);
      vcempres       empresas.cempres%TYPE;
      num_err        NUMBER := 0;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      ocagente := NULL;
      vcempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                        'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO_INT')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN :num_err := ' || v_propio || '.' || 'f_busca_agente_persona('
            || ':psnip, :psinterf, :ocagente); END;';

      EXECUTE IMMEDIATE ss
                  USING OUT num_err, IN psnip, IN psinterf, OUT ocagente;

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado.
         */
         RETURN 0;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000586;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - num_err: ' || num_err);
         RETURN 9000503;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000503;   --Error al recuperar los datos del agente.
   END f_busca_agente_persona;

   FUNCTION f_busca_agente_poliza(psperson IN NUMBER, ocagente OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_propio_int.f_busca_agente_poliza';
      vparam         VARCHAR2(500) := 'parámetros - psperson: ' || psperson;
      vpasexec       NUMBER(5) := 1;
      v_propio       VARCHAR2(100);
      ss             VARCHAR2(2000);
      vcempres       empresas.cempres%TYPE;
      num_err        NUMBER := 0;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      ocagente := NULL;
      vcempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                        'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO_INT')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN :num_err := ' || v_propio || '.' || 'f_busca_agente_poliza('
            || ':psperson, :ocagente); END;';

      EXECUTE IMMEDIATE ss
                  USING OUT num_err, IN psperson, OUT ocagente;

      IF num_err <> 0 THEN
         RAISE e_object_error;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado.
         */
         RETURN 0;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN 9000586;   --Error al gravar la variable de contexto agente de producción.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - num_err: ' || num_err);
         RETURN 9000503;   --Error al gravar la variable de contexto agente de producción.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9000503;   --Error al gravar la variable de contexto agente de producción.
   END f_busca_agente_poliza;

   FUNCTION f_obtener_concepto_cargo(psseguro IN NUMBER, pnrecibo IN NUMBER)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_propio_int.f_obtener_concepto_cargo';
      vparam         VARCHAR2(500)
                       := 'parámetros - psseguro: ' || psseguro || ' - pnrecibo: ' || pnrecibo;
      vpasexec       NUMBER(5) := 1;
      v_propio       VARCHAR2(100);
      ss             VARCHAR2(2000);
      vcempres       empresas.cempres%TYPE;
      v_retorno      VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      vcempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                        'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO_INT')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN :v_retorno := ' || v_propio || '.' || 'f_obtener_concepto_cargo('
            || ':psseguro, :pnrecibo); END;';

      EXECUTE IMMEDIATE ss
                  USING OUT v_retorno, IN psseguro, IN pnrecibo;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado.
         */
         RETURN NULL;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN f_axis_literales(9001835, f_usu_idioma);   --Error al obtener concepto de cargo.
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - v_retorno: ' || v_retorno);
         RETURN f_axis_literales(9000503, f_usu_idioma);   --Error al obtener concepto de cargo.
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN f_axis_literales(9000503, f_usu_idioma);   --Error al obtener concepto de cargo.
   END f_obtener_concepto_cargo;

   -- BUG21467:DRA:01/03/2012:Inici
   FUNCTION f_pre_int_datos_host(
      datpol IN ob_int_datos_poliza,
      pregpol IN t_int_preg_poliza,
      pcmapead OUT VARCHAR2)
      RETURN VARCHAR2 IS
      vobjectname    VARCHAR2(500) := 'pac_propio_int.f_pre_int';
      vparam         VARCHAR2(500) := 'parámetros - ';
      vpasexec       NUMBER(5) := 1;
      v_propio       VARCHAR2(100);
      ss             VARCHAR2(2000);
      vcempres       empresas.cempres%TYPE;
      v_retorno      VARCHAR2(200);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      vcempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                        'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO_INT')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN :v_retorno := ' || v_propio || '.f_pre_int_datos_host('
            || ':datpol, :pregpol, :pcmapead); END;';

      EXECUTE IMMEDIATE ss
                  USING OUT v_retorno, IN datpol, IN pregpol, OUT pcmapead;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado.
         */
         pcmapead := NULL;
         RETURN NULL;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN NULL;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - v_retorno: ' || v_retorno);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_pre_int_datos_host;

   FUNCTION f_post_int(
      psinterf IN NUMBER,
      datpol IN ob_int_datos_poliza,
      pregpol IN t_int_preg_poliza,
      pcmapead IN VARCHAR2)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_propio_int.f_post_int';
      vparam         VARCHAR2(500)
                     := 'parámetros - psinterf = ' || psinterf || ' - pcmapead = ' || psinterf;
      vpasexec       NUMBER(5) := 1;
      v_propio       VARCHAR2(100);
      ss             VARCHAR2(2000);
      vcempres       empresas.cempres%TYPE;
      v_retorno      NUMBER;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      vcempres := pac_contexto.f_contextovalorparametro(f_parinstalacion_t('CONTEXT_USER'),
                                                        'IAX_EMPRESA');

      SELECT pac_parametros.f_parempresa_t(vcempres, 'PAC_PROPIO_INT')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN :v_retorno := ' || v_propio || '.f_post_int('
            || ':psinterf, :datpol, :pregpol, :pcmapead); END;';

      EXECUTE IMMEDIATE ss
                  USING OUT v_retorno, IN psinterf, IN datpol, IN pregpol, IN pcmapead;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado.
         */
         RETURN NULL;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN NULL;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al ejecutar procedimiento o funció - v_retorno: ' || v_retorno);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_post_int;
-- BUG21467:DRA:01/03/2012:Inici
END pac_propio_int;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "PROGRAMADORESCSI";
