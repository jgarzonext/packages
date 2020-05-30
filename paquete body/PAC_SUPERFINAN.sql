--------------------------------------------------------
--  DDL for Package Body PAC_SUPERFINAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SUPERFINAN" IS
/******************************************************************************
   NOMBRE:     PAC_SUPERFINAN
   PROPÓSITO:  Package que contiene las funciones propias de la interfaz con SUPERFINANCIERA

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/02/2012   JRH/ET          1.0 Creación del package.
   2.0        07/02/2012   JRH/ET          2.0 0020107: LCOL898 - Interfaces - Regulatorio - Reporte Reservas Superfinanciera
******************************************************************************/
   errorproc      EXCEPTION;

-- Bug 20107 - 07/02/2012 - JRH  - Gastos en fichero Superfinanciera (Inicio)
-- Fi Bug 20107 - 07/02/2012 - JRH
   /*************************************************************************
       FUNCTION ff_gastos_adquis
         Calcula los gastos de adquisición a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_adquis(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_gastos_adquis(' || psseguro || ',' || pnriesgo || ',' || pcgarant || ','
              || '' || ':pfecha)' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      DBMS_SQL.bind_variable(v_cursor, ':pfecha', pfecha);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_adquis', vtraza,
                     'psseguro = ' || psseguro || ';pfecha = ' || pfecha || ';pcgarant = '
                     || pcgarant,
                     vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_adquis', vtraza,
                     'psseguro = ' || psseguro || ';pcgarant = ' || pcgarant || ';pfecha = '
                     || pfecha,
                     SQLERRM);
         RETURN NULL;
   END ff_gastos_adquis;

   /*************************************************************************
       FUNCTION ff_gastos_admin
         Calcula los gastos de adiminstración a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_admin(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_gastos_admin(' || psseguro || ',' || pnriesgo || ',' || pcgarant || ','
              || '' || ':pfecha)' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      DBMS_SQL.bind_variable(v_cursor, ':pfecha', pfecha);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_admin', vtraza,
                     'psseguro = ' || psseguro || ';pfecha = ' || pfecha || ';pcgarant = '
                     || pcgarant,
                     vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_admin', vtraza,
                     'psseguro = ' || psseguro || 'pcgarant = ' || pcgarant || 'pfecha = '
                     || pfecha,
                     SQLERRM);
         RETURN NULL;
   END ff_gastos_admin;

   /*************************************************************************
       FUNCTION ff_gastos_admin_tot
         Calcula los gastos de adqusi´ción totales (más comisón) a una fecha
         param in psseguro  : Identificador de seguro.
         param in pnriesgo  : Identificador del riesgo.
         param in pcgarant    : Garantía
         param in pfecha    : fecha
         return             : t_gastos
    *************************************************************************/
   FUNCTION ff_gastos_admin_tot(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_gastos_admin_tot(' || psseguro || ',' || pnriesgo || ',' || pcgarant
              || ',' || '' || ':pfecha)' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      DBMS_SQL.bind_variable(v_cursor, ':pfecha', pfecha);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_admin_tot', vtraza,
                     'psseguro = ' || psseguro || ';pfecha = ' || pfecha || ';pcgarant = '
                     || pcgarant,
                     vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_gastos_admin_tot', vtraza,
                     'psseguro = ' || psseguro || ';pcgarant = ' || pcgarant || ';pfecha = '
                     || pfecha,
                     SQLERRM);
         RETURN NULL;
   END ff_gastos_admin_tot;

--******************etm
  /*************************************************************************
       FUNCTION  ff_codigo_compania
         Obtiene el codigo de compañia
         param in psseguro  : Identificador de seguro.
         return             : codigo de compañia
    *************************************************************************/
   FUNCTION ff_codigo_compania(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(4000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_codigo_compania(' || psseguro || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_codigo_compania', vtraza,
                     'psseguro = ' || psseguro, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_codigo_compania', vtraza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_codigo_compania;

   /*************************************************************************
       FUNCTION  ff_titulo_prod
         Obtiene el titulo del producto
        param in psseguro  : Identificador de seguro.
        return             : titulo del producto
    *************************************************************************/
   FUNCTION ff_titulo_prod(psseguro IN NUMBER)
      RETURN VARCHAR2 IS
      v_retorno      VARCHAR2(4000) := NULL;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(4000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_titulo_prod(' || psseguro || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno, 4000);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_titulo_prod', vtraza,
                     'psseguro = ' || psseguro, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_titulo_prod', vtraza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_titulo_prod;

   /*************************************************************************
      FUNCTION  ff_estado_plan
        Obtiene el codigo para saber si se comercializa o no
        param in psseguro  : Identificador de seguro.
        return             : codigo 1 se comercializa, 2 no se comercializa
   *************************************************************************/
   FUNCTION ff_estado_plan(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_estado_plan(' || psseguro || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_estado_plan', vtraza,
                     'psseguro = ' || psseguro, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_estado_plan', vtraza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_estado_plan;

   /*************************************************************************
       FUNCTION  ff_clase_seguro
         Obtiene el codigo  del tipo de seguro al que corresponde el palan
         param in psseguro  : Identificador de seguro.
         param in psproduc : Id de producto
         return             : codigos de clase de seguro
    *************************************************************************/
   FUNCTION ff_clase_seguro(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_duraci       NUMBER;
      vcrespue       NUMBER;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_clase_seguro(' || psseguro || ', ' || psproduc || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
      vtraza := 8;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_clase_seguro', vtraza,
                     'psseguro = ' || psseguro || ' psproduc= ' || psproduc, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_clase_seguro', vtraza,
                     'psseguro = ' || psseguro || ' psproduc= ' || psproduc, SQLERRM);
         RETURN NULL;
   END ff_clase_seguro;

/*************************************************************************
       FUNCTION   ff_tabla_mortalidad
         Obtiene el codigo  Primas y reservas del amparo
         param in psseguro  : Identificador de seguro.
         param in pcgarant : Id de producto
        return             : rimas y reservas del amparo
    *************************************************************************/
   FUNCTION ff_tabla_mortalidad(psseguro IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_tabla_mortalidad(' || psseguro || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_tabla_mortalidad', vtraza,
                     'psseguro = ' || psseguro, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_tabla_mortalidad', vtraza,
                     'psseguro = ' || psseguro, SQLERRM);
         RETURN NULL;
   END ff_tabla_mortalidad;

   /*************************************************************************
         FUNCTION   ff_estado
           Obtiene el codigo de estado de la poliza
           param in psproduc  : Identificador de psproduc.
           return             : devuelve el estado de la poliza 1--1, Vigente ,2.. Prorrogada,3. Saldada
      *************************************************************************/
   FUNCTION ff_estado_poliza(psproduc IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      v_retornodos   NUMBER;
      vtraza         NUMBER := 0;
      v_duraci       NUMBER;
      vcrespue       NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;
      v_retorno := pac_parametros.f_parproducto_n(psproduc, 'ES_SEGURO_SALDADO');
      v_retornodos := pac_parametros.f_parproducto_n(psproduc, 'ES_SEGURO_PRORROGADO');
      vtraza := 2;

      IF v_retorno = 1 THEN
         RETURN 3;
      ELSIF v_retornodos = 1 THEN
         RETURN 2;
      ELSE
         RETURN 1;
      END IF;

      vtraza := 3;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_estado_poliza', vtraza,
                     'psproduc = ' || psproduc, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_estado_poliza', vtraza,
                     'psproduc = ' || psproduc, SQLERRM);
         RETURN NULL;
   END ff_estado_poliza;

   /*************************************************************************
      FUNCTION    ff_fecha_pago_prima
        Obtiene  la fecha máxima de pago de primas
        param in psseguro  : Identificador de psseguro.
        parm in pfecha:  fecha
        return             : devuelve fecha max de pago de primas
   *************************************************************************/
   FUNCTION ff_fecha_pago_prima(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN VARCHAR2 IS
      v_retorno      DATE;
      vtraza         NUMBER := 0;
      v_ndurcob      NUMBER;
      vcrespue       NUMBER;
      vnum_err       NUMBER;
      v_cforpag      NUMBER;
      v_fvencim      DATE;
      -- Bug 21808 - RSC - 03/04/2012 - LCOL - UAT - Revisión de Listados Producción
      v_cduraci      productos.cduraci%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
   -- Fin Bug 21808
   BEGIN
      vtraza := 1;

      BEGIN
         SELECT ndurcob, cforpag, fvencim, cduraci, fcaranu
           INTO v_ndurcob, v_cforpag, v_fvencim, v_cduraci, v_fcaranu
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            v_ndurcob := 0;
            v_cforpag := NULL;
      END;

      IF v_ndurcob IS NOT NULL
         AND v_ndurcob <> 0 THEN
         v_retorno := (ADD_MONTHS(pfefecto, 12 * v_ndurcob + 1)) - 1;   --+1 año y - 1 dia
         RETURN TO_CHAR(v_retorno, 'DD/MM/YYYY');
      END IF;

      IF v_cforpag = 0 THEN
         RETURN TO_CHAR(pfefecto, 'DD/MM/YYYY');
      END IF;

      BEGIN
         SELECT p.crespue
           INTO vcrespue
           FROM pregunpolseg p
          WHERE p.sseguro = psseguro
            AND p.cpregun = 4778
            AND p.nmovimi = (SELECT MAX(m.nmovimi)
                               FROM movseguro m
                              WHERE m.sseguro = psseguro
                                AND m.fefecto = pfefecto);

         IF vcrespue IS NOT NULL THEN
            RETURN TO_CHAR(TO_DATE(vcrespue, 'YYYYMMDD') - 1, 'DD/MM/YYYY');
         ELSE
            SELECT DISTINCT (TO_CHAR(GREATEST(TO_DATE(crespue, 'YYYYMMDD')), 'YYYYMMDD'))
                       INTO vcrespue
                       FROM pregungaranseg
                      WHERE cpregun = 1043
                        AND sseguro = psseguro
                        AND nmovimi = (SELECT MAX(m.nmovimi)
                                         FROM movseguro m
                                        WHERE m.sseguro = psseguro
                                          AND m.fefecto = pfefecto);

            IF vcrespue IS NOT NULL THEN
               RETURN TO_CHAR(TO_DATE(vcrespue, 'YYYYMMDD') - 1, 'DD/MM/YYYY');
            ELSE
               -- Bug 21808 - RSC - 03/04/2012 - LCOL - UAT - Revisión de Listados Producción
               IF v_cduraci = 4 THEN
                  RETURN TO_CHAR(v_fcaranu - 1, 'DD/MM/YYYY');
               ELSE
                  -- Fin bug 21808
                  RETURN TO_CHAR(v_fvencim - 1, 'DD/MM/YYYY');
               END IF;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vnum_err := pac_preguntas.f_get_pregunpolseg(psseguro, 4778, 'POL', vcrespue);

            IF vcrespue IS NOT NULL THEN
               RETURN TO_CHAR(TO_DATE(vcrespue, 'YYYYMMDD') - 1, 'DD/MM/YYYY');
            ELSE
               -- Bug 21808 - RSC - 03/04/2012 - LCOL - UAT - Revisión de Listados Producción
               IF v_cduraci = 4 THEN
                  RETURN TO_CHAR(v_fcaranu - 1, 'DD/MM/YYYY');
               ELSE
                  -- Fin bug 21808
                  RETURN TO_CHAR(v_fvencim - 1, 'DD/MM/YYYY');
               END IF;
            END IF;
      END;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecha_pago_prima', vtraza,
                     'psseguro = ' || psseguro || ' pfefecto = ' || pfefecto, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecha_pago_prima', vtraza,
                     'psseguro = ' || psseguro || ' pfefecto = ' || pfefecto, SQLERRM);
         RETURN NULL;
   END ff_fecha_pago_prima;

   /*************************************************************************
      FUNCTION   ff_crecvalor_aseg
        Obtiene el codigo  Primas y reservas del amparo
        param in psseguro  : Identificador de seguro.
        param in ptipo :     Numerico si 1-->Tipo de Crecimiento  si 2-->Periodicidad
       return             : Corresponde al Tipo o Periodicidad  de crecimiento del valor asegurado del.amparo básico.
   *************************************************************************/
   FUNCTION ff_crecvalor_aseg(psseguro IN NUMBER, ptipo IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_crecvalor_aseg(' || psseguro || ',' || ptipo || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_crecvalor_aseg', vtraza,
                     'psseguro = ' || psseguro || ' ptipo = ' || ptipo, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_crecvalor_aseg', vtraza,
                     'psseguro = ' || psseguro || ' ptipo = ' || ptipo, SQLERRM);
         RETURN NULL;
   END ff_crecvalor_aseg;

   /*************************************************************************
      FUNCTION   ff_codigo_cobertura
        Obtiene el codigo cobertura saldado o prrogado
        param in psproduc  : Identificador de psproduc.
        return             : Codigo cobertura saldado o prrogado
   *************************************************************************/
   FUNCTION ff_codigo_cobertura(psproduc IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      v_retornodos   NUMBER;
      vtraza         NUMBER := 0;
      v_duraci       NUMBER;
      vcrespue       NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;
      v_retorno := pac_parametros.f_parproducto_n(psproduc, 'ES_SEGURO_SALDADO');
      v_retornodos := pac_parametros.f_parproducto_n(psproduc, 'ES_SEGURO_PRORROGADO');
      vtraza := 2;

      IF v_retorno = 1 THEN
         RETURN 2;
      ELSIF v_retornodos = 1 THEN
         RETURN 1;
      ELSE
         RETURN NULL;
      END IF;

      vtraza := 3;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_codigo_cobertura', vtraza,
                     'psproduc = ' || psproduc, vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_codigo_cobertura', vtraza,
                     'psproduc = ' || psproduc, SQLERRM);
         RETURN NULL;
   END ff_codigo_cobertura;

   /*************************************************************************
       FUNCTION   ff_prima_unica
         Obtiene el Valor de la prima única del seguro prorrogado o seguro saldado,
          param in psseguro  : Identificador de seguro.
          param in pcgarant : id de garantia
         return             : Valor de la prima única del seguro prorrogado o seguro saldado,
    *************************************************************************/
   FUNCTION ff_prima_unica(psseguro IN NUMBER, pcgarant IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_prima_unica(' || psseguro || ',' || pcgarant || ',' || psproduc || ')'
              || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_prima_unica', vtraza,
                     'psseguro = ' || psseguro || ' pcgarant = ' || pcgarant || ' psproduc = '
                     || psproduc,
                     vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_prima_unica', vtraza,
                     'psseguro = ' || psseguro || ' pcgarant = ' || pcgarant || ' psproduc = '
                     || psproduc,
                     SQLERRM);
         RETURN NULL;
   END ff_prima_unica;

   FUNCTION ff_garantia_basica(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT MAX(g.cgarant)
        INTO v_ret
        FROM garanpro g, seguros s
       WHERE s.sseguro = p_seg
         AND g.cmodali = s.cmodali
         AND g.ccolect = s.ccolect
         AND g.ctipseg = s.ctipseg
         AND g.cactivi = s.cactivi
         AND g.cramo = s.cramo
         AND NVL(g.cbasica, 0) = 1;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_garantia_basica', 1, '', SQLERRM);
         RETURN NULL;
   END ff_garantia_basica;

   FUNCTION ff_gar_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;

      CURSOR c1 IS
         SELECT   x.cgarant
             FROM garanseg x, provmat pv
            WHERE x.cgarant IN(SELECT g.cgarant
                                 FROM garanpro g, seguros s
                                WHERE s.sseguro = p_seg
                                  AND g.cramo = s.cramo
                                  AND g.cmodali = s.cmodali
                                  AND g.ctipseg = s.ctipseg
                                  AND g.ccolect = s.ccolect
                                  AND g.cactivi = s.cactivi
                                  AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                                      s.cactivi, g.cgarant, 'CALCULA_PROVI') =
                                                                                              1
                                  AND f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                                                      s.cactivi, g.cgarant, 'TIPO') NOT IN
                                                                                         (3, 4)
                                  AND NVL(g.cbasica, 0) = 0)
              AND x.sseguro = p_seg
              AND x.nriesgo = p_rie
              AND x.nmovimi = (SELECT MAX(x1.nmovimi)
                                 FROM garanseg x1
                                WHERE x1.sseguro = p_seg
                                  AND x1.nriesgo = p_rie
                                  AND x1.finiefe <= p_fec)
              AND pv.sseguro = x.sseguro
              AND pv.nriesgo = x.nriesgo
              AND pv.fcalcul = p_fec
              AND pv.cgarant = x.cgarant
         ORDER BY pv.ipromat DESC, norden;
   BEGIN
      v_ret := 0;

      OPEN c1;

      FETCH c1
       INTO v_ret;

      IF c1%NOTFOUND THEN
         v_ret := 0;
      END IF;

      CLOSE c1;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_garantia_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_gar_adicional;

   FUNCTION ff_saldado_prorrogado(p_pro IN NUMBER)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      v_retornodos   NUMBER;
   BEGIN
      -- devuelve 1 prorr, 2 saldado, 0 sino
      v_retorno := pac_parametros.f_parproducto_n(p_pro, 'ES_SEGURO_SALDADO');
      v_retornodos := pac_parametros.f_parproducto_n(p_pro, 'ES_SEGURO_PRORROGADO');

      IF v_retorno = 1 THEN
         RETURN 2;
      ELSIF v_retornodos = 1 THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_saldado_prorrogado', 1, '',
                     SQLERRM);
         RETURN NULL;
   END;

   -- Obtener respuesta a pregunt a de garantia en una fecha
   FUNCTION ff_pregungaranseg(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_fec IN DATE,
      p_gar IN NUMBER,
      p_pre IN NUMBER)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(MAX(p.crespue), 0)
        INTO v_ret
        FROM pregungaranseg p
       WHERE p.sseguro = p_seg
         AND p.nriesgo = p_rie
         AND p.cgarant = p_gar
         AND p.nmovimi = (SELECT MAX(p1.nmovimi)
                            FROM pregungaranseg p1
                           WHERE p1.sseguro = p_seg
                             AND p1.nriesgo = p_rie
                             AND p1.cgarant = p.cgarant
                             AND p1.finiefe <= p_fec
                             AND p1.cpregun = p.cpregun)
         AND p.cpregun = p_pre;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_pregungaranseg', 1,
                     'psproduc = ' || NULL, SQLERRM);
         RETURN NULL;
   END ff_pregungaranseg;

   -- Fecha Crecimiento de una garantia
   FUNCTION ff_fecha_crecimiento(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_fec IN DATE,
      p_gar IN NUMBER,
      pmodo IN NUMBER DEFAULT NULL)
      RETURN DATE IS
      v_crevali      garanseg.crevali%TYPE;
      d_fvencim      seguros.fvencim%TYPE;
      n_sproduc      seguros.sproduc%TYPE;
      d_fefecto      seguros.fefecto%TYPE;
      n_aux          NUMBER;
      v_ret          DATE;
   BEGIN
      v_ret := NULL;

      DECLARE
         v_retorno      DATE;
         v_propio       VARCHAR2(200);
         v_ss           VARCHAR2(2000);
         v_cursor       NUMBER;
         v_filas        NUMBER;
         ex_nodeclared  EXCEPTION;
         PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
      BEGIN
         SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
           INTO v_propio
           FROM seguros
          WHERE sseguro = p_seg;

         -- ff_crecimiento ( p_seg in number, p_rie in number, p_fec in date, p_gar in number)
         v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
                 || 'ff_crecimiento(' || p_seg || ',' || p_rie || ',' || '' || ':pfecha' || ''
                 || ',' || p_gar || ',' || pmodo || ');' || 'END;';

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
         DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
         DBMS_SQL.bind_variable(v_cursor, ':pfecha', p_fec);
         v_filas := DBMS_SQL.EXECUTE(v_cursor);
         DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_ret := v_retorno;
      EXCEPTION
         WHEN ex_nodeclared THEN
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            -- CASO NORMAL
            -- Buscar las garantías vigentes a la fecha.
            SELECT MAX(a.crevali), MAX(s.fvencim), MAX(s.sproduc), MAX(s.fefecto)
              INTO v_crevali, d_fvencim, n_sproduc, d_fefecto
              FROM garanseg a, seguros s
             WHERE s.sseguro = p_seg
               AND a.sseguro = s.sseguro
               AND a.nriesgo = p_rie
               AND a.cgarant = p_gar
               AND a.nmovimi = (SELECT MAX(b.nmovimi)
                                  FROM garanseg b
                                 WHERE b.sseguro = p_seg
                                   AND b.nriesgo = p_rie
                                   AND b.cgarant = p_gar
                                   AND p_fec BETWEEN finiefe AND NVL(ffinefe, p_fec + 1));

            IF NVL(v_crevali, 0) = 0 THEN
               v_ret := NULL;
            ELSE
               n_aux := pac_superfinan.ff_pregungaranseg(p_seg, p_rie, p_fec, p_gar, 1043);

               IF LENGTH(n_aux) = 8 THEN
                  v_ret := TO_DATE(n_aux, 'yyyymmdd');
               ELSE
                  v_ret := d_fvencim;
               END IF;
            END IF;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecha_crecimiento', 1,
                        's = ' || p_seg || ' r=' || p_rie || ' ;g = ' || p_gar || ';f = '
                        || p_fec,
                        SQLERRM);
            v_ret := NULL;
      END;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecha_crecimiento', 1, '', SQLERRM);
         RETURN NULL;
   END ff_fecha_crecimiento;

   FUNCTION ff_periodo_crecimiento(
      p_seg IN NUMBER,
      p_rie IN NUMBER,
      p_fec IN DATE,
      p_gar IN NUMBER)
      RETURN DATE IS
      v_ret          DATE;
   BEGIN
      v_ret := NULL;

      DECLARE
         v_retorno      DATE;
         v_propio       VARCHAR2(200);
         v_ss           VARCHAR2(2000);
         v_cursor       NUMBER;
         v_filas        NUMBER;
         ex_nodeclared  EXCEPTION;
         PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);
      BEGIN
         SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
           INTO v_propio
           FROM seguros
          WHERE sseguro = p_seg;

         v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
                 || 'ff_periodo_crecimiento(' || p_seg || ',' || p_rie || ',' || ''
                 || ':pfecha' || '' || ',' || p_gar || ');' || 'END;';

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_cursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
         DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
         DBMS_SQL.bind_variable(v_cursor, ':pfecha', p_fec);
         v_filas := DBMS_SQL.EXECUTE(v_cursor);
         DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);

         IF DBMS_SQL.is_open(v_cursor) THEN
            DBMS_SQL.close_cursor(v_cursor);
         END IF;

         v_ret := v_retorno;
      EXCEPTION
         WHEN ex_nodeclared THEN
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            -- CASO NORMAL
            v_ret := NULL;
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecha_crecimiento', 1,
                        's = ' || p_seg || ' r=' || p_rie || ' ;g = ' || p_gar || ';f = '
                        || p_fec,
                        SQLERRM);
            v_ret := NULL;
      END;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_periodo_crecimiento', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_periodo_crecimiento;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------

   -- 110 - Tipo de Crecimiento (Cobertura Adicional)
   FUNCTION ff_tipocrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_gar          NUMBER;
      v_crevali      NUMBER;
      v_ret          NUMBER;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      SELECT MAX(crevali)
        INTO v_ret
        FROM garanseg x
       WHERE x.cgarant = v_gar
         AND x.sseguro = p_seg
         AND x.nriesgo = p_rie
         AND nmovimi = (SELECT MAX(x1.nmovimi)
                          FROM garanseg x1
                         WHERE x1.sseguro = p_seg
                           AND x1.nriesgo = p_rie
                           AND x1.finiefe <= p_fec);

      IF v_crevali = 0 THEN
         RETURN 9;
      ELSIF v_crevali = 2 THEN
         RETURN 3;
      ELSIF v_crevali = 10 THEN
         RETURN 4;
      ELSIF v_crevali = 11 THEN
         RETURN 1;
      ELSE
         RETURN NULL;
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_Tipocrecim_adicional', 1,
                     'p_seg = ' || p_seg, SQLERRM);
         RETURN NULL;
   END ff_tipocrecim_adicional;

   -- 111 - Porcentaje Crecimiento (Cobertura Adicional)
   FUNCTION ff_porcrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_gar          NUMBER;
      v_ret          NUMBER;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      SELECT MAX(prevali)
        INTO v_ret
        FROM garanseg x
       WHERE x.cgarant = v_gar
         AND x.sseguro = p_seg
         AND x.nriesgo = p_rie
         AND nmovimi = (SELECT MAX(x1.nmovimi)
                          FROM garanseg x1
                         WHERE x1.sseguro = p_seg
                           AND x1.nriesgo = p_rie
                           AND x1.finiefe <= p_fec);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_porcrecim_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_porcrecim_adicional;

   -- 112 - PERIODO_CRECIMIENTO adicional
   FUNCTION ff_periodocrecim_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE IS
      v_gar          NUMBER;
      v_ret          DATE;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      IF v_gar IS NOT NULL THEN
         v_ret := pac_superfinan.ff_periodo_crecimiento(p_seg, p_rie, p_fec, v_gar);
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_periodocrecim_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_periodocrecim_adicional;

   -- 113 - Crecimiento Hasta (Cobertura Adicional)
   FUNCTION ff_crecimhasta_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE IS
      v_gar          NUMBER;
      v_ret          DATE;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      IF v_gar IS NOT NULL THEN
         v_ret := pac_superfinan.ff_fecha_crecimiento(p_seg, p_rie, p_fec, v_gar);
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_crecimhasta_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_crecimhasta_adicional;

   -- 116 - Fecha Inicio Vigencia (Cobertura Adicional)
   FUNCTION ff_fecinivig_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN DATE IS
      v_gar          NUMBER;
      v_ret          DATE;
      vmigra         NUMBER;
      vnumerr        NUMBER;
      vtrespue       pregunpolseg.trespue%TYPE;
   BEGIN
      -- bug 28713/157181 - 21/11/2013 - AMC
      vnumerr := pac_seguros.f_es_migracion(p_seg, 'POL', vmigra);

      IF vmigra = 0 THEN
         v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

         SELECT MIN(finiefe)
           INTO v_ret
           FROM garanseg
          WHERE sseguro = p_seg
            AND nriesgo = p_rie
            AND cgarant = v_gar;
      ELSE
         vnumerr := pac_preguntas.f_get_pregunpolseg_t(p_seg, 4044, 'POL', vtrespue);
         v_ret := TO_DATE(vtrespue, 'DD/MM/YYYY');
      END IF;

      -- Fi bug 28713/157181 - 21/11/2013 - AMC
      RETURN TRUNC(v_ret);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecinivig_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_fecinivig_adicional;

   -- 117 - Cobertura Hasta (Cobertura Adicional)
   FUNCTION ff_coberturahasta_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_gar          NUMBER;
      v_ret          NUMBER;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);
      v_ret := ff_pregungaranseg(p_seg, p_rie, p_fec, v_gar, 1043);
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_fecinivig_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_coberturahasta_adicional;

   -- 118 - Edad Inicial (Cobertura Adicional)
   FUNCTION ff_edadinicial_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      d_gar          DATE;
      d_nac          DATE;
      v_ret          NUMBER;
   BEGIN
      d_gar := pac_superfinan.ff_fecinivig_adicional(p_seg, p_rie, p_fec);

      IF d_gar IS NULL THEN
         v_ret := NULL;
      ELSE
         SELECT MAX(b.fnacimi)
           INTO d_nac
           FROM riesgos a, per_personas b
          WHERE a.sseguro = p_seg
            AND a.nriesgo = p_rie
            AND b.sperson = a.sperson;

         IF d_nac IS NULL THEN
            v_ret := NULL;
         ELSE
            SELECT TRUNC(MONTHS_BETWEEN(d_gar, d_nac) / 12)
              INTO v_ret
              FROM DUAL;
         END IF;
      END IF;

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan. ff_edadinicial_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_edadinicial_adicional;

   -- 125 - Valor Asegurado lnicial
   FUNCTION ff_valase_inicial_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_gar          NUMBER;
      v_ret          NUMBER;
   BEGIN
      v_gar := pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);
      -- Bug 20725 - RSC - 16/02/2012 - LCOL_T001-LCOL - UAT - TEC - Simulacion (Modificamos 4071 --> 4074)
      v_ret := ff_pregungaranseg(p_seg, p_rie, p_fec, v_gar, 4074);
      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan. ff_valase_inicial_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_valase_inicial_adicional;

   -- 126 - Valor Asegurado Alcanzado (Cobertura Adicional)
   FUNCTION ff_valase_alcanzado_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(SUM(ivalact), 0)
        INTO v_ret
        FROM provmat
       WHERE sseguro = p_seg
         AND fcalcul = p_fec
         AND cgarant = pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan. ff_valase_alcanzado_adicional', 1,
                     '', SQLERRM);
         RETURN NULL;
   END ff_valase_alcanzado_adicional;

   -- 127-Prima Riesgo C.Adicional
   FUNCTION ff_prima_riesgo_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = p_seg;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_prima_riesgo_adicional(' || p_seg || ',''' || p_rie || ''','''
              || TO_CHAR(p_fec, 'YYYYMMDD') || ''')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_prima_riesgo_adicional', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_prima_riesgo_adicional;

   -- 128-Reserva Cob.Adicional
   FUNCTION ff_reserva_adicional(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(SUM(ipromat), 0)
        INTO v_ret
        FROM provmat
       WHERE sseguro = p_seg
         AND fcalcul = p_fec
         AND cgarant = pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_reserva_adicional', 1, '', SQLERRM);
         RETURN NULL;
   END ff_reserva_adicional;

   -- 129-Reserva Demas.Adicionales
   FUNCTION ff_reserva_demasadicionales(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(SUM(p.ipromat), 0)
        INTO v_ret
        FROM provmat p, seguros s
       WHERE p.sseguro = p_seg
         AND p.fcalcul = p_fec
         AND p.cgarant <> pac_superfinan.ff_gar_adicional(p_seg, p_rie, p_fec)
         AND p.cgarant <> pac_superfinan.ff_garantia_basica(p_seg, p_rie, p_fec)
         AND p.sseguro = s.sseguro
         AND NVL(f_pargaranpro_v(s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cactivi,
                                 p.cgarant, 'TIPO'),
                 0) NOT IN(3, 4);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_reserva_demasadicionales', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_reserva_demasadicionales;

   -- 132-Reserva Total
   FUNCTION ff_reserva_total(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(SUM(p.ipromat), 0)
        INTO v_ret
        FROM provmat p, seguros s
       WHERE p.sseguro = p_seg
         AND p.fcalcul = p_fec
         AND p.sseguro = s.sseguro
         AND f_pargaranpro_v(p.cramo, p.cmodali, p.ctipseg, p.ccolect, s.cactivi, p.cgarant,
                             'TIPO') NOT IN(3, 4);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_reserva_total', 1, '', SQLERRM);
         RETURN NULL;
   END ff_reserva_total;

   -- 133-Reserva Total Pesos
   FUNCTION ff_reserva_totalpesos(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_ret          NUMBER;
   BEGIN
      SELECT NVL(SUM(p.ipromat_moncon), 0)
        INTO v_ret
        FROM provmat p, seguros s
       WHERE p.sseguro = p_seg
         AND p.fcalcul = p_fec
         AND p.sseguro = s.sseguro
         AND f_pargaranpro_v(p.cramo, p.cmodali, p.ctipseg, p.ccolect, s.cactivi, p.cgarant,
                             'TIPO') NOT IN(3, 4);

      RETURN v_ret;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_reserva_totalpesos', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_reserva_totalpesos;

   FUNCTION ff_altura_mes(p_fecha1 IN DATE, p_fecha2 IN DATE)
      RETURN NUMBER IS
      v_meses        NUMBER;
   BEGIN
      IF TO_NUMBER(TO_CHAR(p_fecha2, 'MM')) >= TO_NUMBER(TO_CHAR(p_fecha1, 'MM')) THEN
         SELECT (TO_NUMBER(TO_CHAR(p_fecha2, 'MM')) - TO_NUMBER(TO_CHAR(p_fecha1, 'MM'))) + 1
           INTO v_meses
           FROM DUAL;
      ELSE
         SELECT 12 +(TO_NUMBER(TO_CHAR(p_fecha2, 'MM')) - TO_NUMBER(TO_CHAR(p_fecha1, 'MM')))
                + 1
           INTO v_meses
           FROM DUAL;
      END IF;

      RETURN v_meses;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_altura_mes', 1, ' ', SQLERRM);
         RETURN NULL;
   END ff_altura_mes;

   FUNCTION ff_buscasaldo(p_seg IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      vprov          NUMBER;
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      vprov := pac_provmat_formul.f_calcul_formulas_provi(p_seg, p_fec, 'IPROVAC');
      RETURN vprov;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_buscasaldo', 1, '', SQLERRM);
         RETURN NULL;
   END ff_buscasaldo;

   FUNCTION ff_altura(p_seg IN NUMBER, p_fecha1 IN DATE, p_fecha2 IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = p_seg;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.' || 'ff_altura('
              || p_seg || ',''' || TO_CHAR(p_fecha1, 'YYYYMMDD') || ''','''
              || TO_CHAR(p_fecha2, 'YYYYMMDD') || ''')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN errorproc THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_altura', vtraza,
                     'psseguro = ' || p_seg || ' p_fecha1 = ' || p_fecha1 || ' p_fecha2 = '
                     || p_fecha2,
                     vnum_err);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_prima_unica', vtraza,
                     'psseguro = ' || p_seg || ' p_fecha1 = ' || p_fecha1 || ' p_fecha2 = '
                     || p_fecha2,
                     SQLERRM);
         RETURN NULL;
   END ff_altura;

   FUNCTION ff_prima_riesgo_basico(p_seg IN NUMBER, p_rie IN NUMBER, p_fec IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = p_seg;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_prima_riesgo_basico(' || p_seg || ',''' || p_rie || ''','''
              || TO_CHAR(p_fec, 'YYYYMMDD') || ''')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_prima_riesgo_basico', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_prima_riesgo_basico;

   -- Bug 28713/157181 - 21/11/2013 - AMC
   FUNCTION ff_edad_ingaseg_principal(p_seg IN NUMBER, p_fnacimi IN DATE, p_fec IN DATE)
      RETURN NUMBER IS
      v_retorno      NUMBER;
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = p_seg;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'ff_edad_ingaseg_principal(' || p_seg || ',''' || p_fnacimi || ''','''
              || p_fec || ''')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.ff_edad_ingaseg_principal', 1, '',
                     SQLERRM);
         RETURN NULL;
   END ff_edad_ingaseg_principal;

   --Bug 28713/157181 - 21/11/2013 - AMC
   FUNCTION f_get_fexpedicion(p_seg IN NUMBER)
      RETURN VARCHAR2 IS
      v_retorno      VARCHAR2(20);
      vtraza         NUMBER := 0;
      v_propio       VARCHAR2(200);
      v_ss           VARCHAR2(2000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      vnum_err       NUMBER;
   BEGIN
      vtraza := 1;

      SELECT pac_parametros.f_parempresa_t(seguros.cempres, 'SUFIJO_EMP')
        INTO v_propio
        FROM seguros
       WHERE sseguro = p_seg;

      vtraza := 2;
      v_ss := 'BEGIN ' || ' :RETORNO := pac_superfinan_' || v_propio || '.'
              || 'f_get_fexpedicion(' || p_seg || ')' || ';' || 'END;';
      vtraza := 3;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 4;
      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, v_ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', v_retorno, 20);
      vtraza := 5;
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', v_retorno);
      vtraza := 6;

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      vtraza := 7;
      RETURN v_retorno;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_superfinan.f_get_fexpedicion', 1, '', SQLERRM);
         RETURN NULL;
   END f_get_fexpedicion;
END pac_superfinan;

/

  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SUPERFINAN" TO "PROGRAMADORESCSI";
