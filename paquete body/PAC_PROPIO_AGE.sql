--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_AGE" IS
/******************************************************************************
   NOMBRE:     PAC_PROPIO_AGE
   PROPÓSITO:  Package que contiene las funciones propias de cada instalación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/11/2012   AMC               1. Creación del package Bug 24514.
   2.0        28/01/2013   ICG               2. Bug 27598 Se crea función f_valida_regfiscal.

******************************************************************************/

   /******************************************************************************
       FUNCION: f_get_retencion
       Funcion que devielve el tipo de retención segun la letra del cif.
       Param in psperson
       Param in pcidioma
       Param out pcidioma
       Param out pcidioma
       Retorno 0- ok 1-ko

       Bug 24514/128686 - 15/11/2012 - AMC
   ******************************************************************************/
   FUNCTION f_get_retencion(
      psperson IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcretenc OUT NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER;
      v_propio       VARCHAR2(100);
      v_cempres      NUMBER;
      v_filas        NUMBER;
      v_ss           VARCHAR2(3000);
      v_retorno      NUMBER;
      v_pcretenc     NUMBER;
      v_pmensaje     VARCHAR2(2000);
      ex_nodeclared  EXCEPTION;
   BEGIN
      SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO_AGE')
        INTO v_propio
        FROM DUAL;

      v_ss := 'BEGIN ' || ' :v_retorno := ' || v_propio || '.' || 'f_get_retencion('
              || psperson || ',' || pcidioma || ', :v_pcretenc ' || ', :v_pmensaje)' || ';'
              || 'END;';

      EXECUTE IMMEDIATE v_ss
                  USING OUT v_retorno, OUT pcretenc, OUT pmensaje;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         --  Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
         --  a una función, procedimiento, etc. inexistente o no declarado.
         pcretenc := NULL;
         pmensaje := NULL;
   END f_get_retencion;

   /******************************************************************************
       FUNCION: f_valida_regfiscal
       Funcion que valida si el tipo de iva y regimen fiscal son introducidos correctamente.
       Param in pcempres
       Param in pcidioma
       Param in psperson
       Param in pctipage
       Param in pctipiva
       Param in pctipint
       Param out
       Retorno 0- ok 1-ko

       Bug 27598-135742 - 28/01/2013 - ICG
   ******************************************************************************/
   FUNCTION f_valida_regfiscal(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      psperson IN NUMBER,
      pctipage IN NUMBER,
      pctipiva IN NUMBER,
      pctipint IN NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER IS
      v_propio       VARCHAR2(100);
      v_ss           VARCHAR2(3000);
      v_retorno      NUMBER;
      v_pmensaje     VARCHAR2(2000);
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -06550);
   BEGIN
      SELECT pac_parametros.f_parempresa_t(pcempres, 'PAC_PROPIO_AGE')
        INTO v_propio
        FROM DUAL;

      IF v_propio IS NOT NULL THEN
         v_ss := 'BEGIN ' || ' :v_retorno := ' || v_propio || '.' || 'f_valida_regfiscal('
                 || pcidioma || ',' || psperson || ',' || NVL(pctipage, 0) || ','
                 || NVL(pctipiva, -1) || ',' || NVL(pctipint, 0) || ', :v_pmensaje)' || ';'
                 || 'END;';

         EXECUTE IMMEDIATE v_ss
                     USING OUT v_retorno, OUT pmensaje;
      ELSE
         -- Si no esta configurado en parempresa es que no se tiene que realizar la validacion.
         v_retorno := 0;
      END IF;

      RETURN v_retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         --  Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
         --  a una función, procedimiento, etc. inexistente o no declarado.
         v_retorno := 0;
         pmensaje := 'Validación no aplica:' || v_ss || '. v_retorno:' || v_retorno
                     || '. v_propio:' || v_propio || '.';
         p_tab_error(f_sysdate, f_user, 'pac_propio_age.f_valida_regfiscal:', NULL, pmensaje,
                     SQLERRM);
         RETURN v_retorno;
      WHEN OTHERS THEN
         v_retorno := 1;
         pmensaje := 'Error al validar:' || v_ss || '. v_retorno:' || v_retorno
                     || '. v_propio:' || v_propio || '.';
         p_tab_error(f_sysdate, f_user, 'pac_propio_age.f_valida_regfiscal:', NULL, pmensaje,
                     SQLERRM);
         RETURN v_retorno;
   END f_valida_regfiscal;
END pac_propio_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "AXIS00";
