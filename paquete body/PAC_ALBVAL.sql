--------------------------------------------------------
--  DDL for Package Body PAC_ALBVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBVAL" IS
/******************************************************************************
   NOMBRE:    PAC_ALBVAL
   PROPÓSITO: Funciones de validación

   REVISIONES:
   Ver        Fecha       Autor  Descripción
   ---------  ----------  -----  ------------------------------------
   1.0                           Creació del package.
   2.0        04/05/2009  SBG    Eliminació funció F_Valida_Altura (Bug 5388)
******************************************************************************/
   FUNCTION f_tprefor(
      ptprefor IN VARCHAR2,
      pvalor IN NUMBER,
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      resultat OUT NUMBER)
      RETURN NUMBER IS
      s              VARCHAR2(2000);
      ncursor        NUMBER;
      filas          NUMBER;
      i              NUMBER;
   BEGIN
      i := 1;

      WHILE i < LENGTH(ptprefor)
       AND SUBSTR(ptprefor, i, 1) <> '(' LOOP
         i := i + 1;
      END LOOP;

      s := 'select ' || SUBSTR(ptprefor, 1, i) || pvalor || ', ''' || ptablas || ''', '
           || TO_CHAR(psseguro) || ', ' || TO_CHAR(pnriesgo) || ', TO_DATE('''
           || TO_CHAR(pfefecto, 'DD/MM/YYYY') || ''',''DD/MM/YYYY' || '''), '
           || TO_CHAR(pnmovimi) || ', ' || TO_CHAR(pcgarant);

      IF SUBSTR(ptprefor, i + 1, 1) <> ')' THEN
         s := s || ', ' || SUBSTR(ptprefor, i + 1, LENGTH(ptprefor) - i - 1);
      END IF;

      s := s || ' ) from dual';
      cerror := 0;
      ncursor := DBMS_SQL.open_cursor;
      DBMS_SQL.parse(ncursor, s, DBMS_SQL.native);
      DBMS_SQL.define_column(ncursor, 1, resultat);
      filas := DBMS_SQL.EXECUTE(ncursor);

      IF DBMS_SQL.fetch_rows(ncursor) > 0 THEN
         DBMS_SQL.COLUMN_VALUE(ncursor, 1, resultat);
      END IF;

      DBMS_SQL.close_cursor(ncursor);
      RETURN cerror;
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_SQL.close_cursor(ncursor);
         resultat := NULL;
         RETURN -1;
   END f_tprefor;
END pac_albval;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBVAL" TO "PROGRAMADORESCSI";
