--------------------------------------------------------
--  DDL for Package Body PAC_CONTROL_EMISION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CONTROL_EMISION" IS
   /******************************************************************************
      NOMBRE:     PAC_CONTROL_EMISION
      PROPÓSITO:  Package que contiene las funciones propias de cada instalación.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/09/2009   RSC              Creción del package
      2.0        16/03/2011   DRA              0018011: CRE998 - Canvi en sistema de retenció productes PIAM i CREDIT SALUT
   ******************************************************************************/

   /*************************************************************************
      FUNCTION que evalua si debe o no debe ejecutar el control de riesgo.
      param in psseguro  : Identificador de seguro.
      param in pnmovimi  : Numero de movimiento
      param in pfecha    : Fecha
      return             : NUMBER (1 --> Si que debe / 0 --> No debe)
   *************************************************************************/
   -- Bug 10828 - 09/09/2009 - RSC - CRE - Revisión de los productos PPJ dinámico y Pla Estudiant (ajustes)
   FUNCTION f_control_risc(psseguro IN NUMBER, pnmovimi IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      --
      ss             VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_cempres      seguros.cempres%TYPE;
      retorno        NUMBER;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END;

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_CONTROL_EMISION')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_control_risc(' || psseguro
            || ',' || pnmovimi || ',to_date(''' || TO_CHAR(pfecha, 'DD-MM-YYYY')
            || ''',''DD-MM-YYYY''))' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado. En este
           caso ejecuta siempre el control de riesgo.
         */
         RETURN 1;
   END f_control_risc;

-- Fin Bug 10828

   -- BUG18011:DRA:17/03/2011:Inici
   /*************************************************************************
      FUNCTION que Analiza si queda retenida por aumento de capital con preguntas afirmativas
      param in psseguro  : Identificador de seguro.
      param in pnmovimi  : Numero de movimiento
      param in pfecha    : Fecha
      return             : NUMBER (1 --> Si que debe / 0 --> No debe)
   *************************************************************************/
   FUNCTION f_control_capital_respuesta(psseguro IN NUMBER, pnmovimi IN NUMBER, pfecha IN DATE)
      RETURN NUMBER IS
      --
      ss             VARCHAR2(3000);
      v_cursor       NUMBER;
      v_filas        NUMBER;
      v_propio       VARCHAR2(50);
      v_cempres      seguros.cempres%TYPE;
      retorno        NUMBER;
      ex_nodeclared  EXCEPTION;
      PRAGMA EXCEPTION_INIT(ex_nodeclared, -6550);   -- Se debe declarar el componente
   BEGIN
      BEGIN
         SELECT cempres
           INTO v_cempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 1;
      END;

      SELECT pac_parametros.f_parempresa_t(v_cempres, 'PAC_CONTROL_EMISION')
        INTO v_propio
        FROM DUAL;

      ss := 'BEGIN ' || ' :RETORNO := ' || v_propio || '.' || 'f_control_capital_respuesta('
            || psseguro || ',' || pnmovimi || ',to_date(''' || TO_CHAR(pfecha, 'DD-MM-YYYY')
            || ''',''DD-MM-YYYY''))' || ';' || 'END;';

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      v_cursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(v_cursor, ss, DBMS_SQL.native);
      DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);
      v_filas := DBMS_SQL.EXECUTE(v_cursor);
      DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

      IF DBMS_SQL.is_open(v_cursor) THEN
         DBMS_SQL.close_cursor(v_cursor);
      END IF;

      RETURN retorno;
   EXCEPTION
      WHEN ex_nodeclared THEN
         /*
           Esta excepción (ORA-6550 saltará siempre que se realiza una llamada
           a una función, procedimiento, etc. inexistente o no declarado. En este
           caso ejecuta siempre el control de riesgo.
         */
         RETURN 1;
   END f_control_capital_respuesta;
-- BUG18011:DRA:17/03/2011:Fi
END pac_control_emision;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_EMISION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_EMISION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CONTROL_EMISION" TO "PROGRAMADORESCSI";
