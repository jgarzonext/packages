--------------------------------------------------------
--  DDL for Package Body PAC_ALBSGT_JGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_ALBSGT_JGR" 
IS
/***************************************************************
   PAC_ALBSGT: Cuerpo del paquete de las funciones
      de las interficies
***************************************************************/
   FUNCTION f_tprefor (
      ptprefor    IN       VARCHAR2,
      ptablas     IN       VARCHAR2,
      psseguro    IN       NUMBER,
      pnriesgo    IN       NUMBER,
      pfefecto    IN       DATE,
      pnmovimi    IN       NUMBER,
      pcgarant    IN       NUMBER,
      resultat    OUT      NUMBER,
      psproces    IN       NUMBER,
      pnmovima    IN       NUMBER DEFAULT 1,
      picapital   IN       NUMBER DEFAULT 0
   )
      RETURN NUMBER
   IS
      /***************************************************************
       F_TPREFOR: Evalua la funció de BBDD que se li pasa
          amb els parametres rebuts
      ***************************************************************/
      s         VARCHAR2 (200);
      ncursor   NUMBER;
      filas     NUMBER;
      i         NUMBER;


   BEGIN
      P_CONTROL_ERROR('PAC_ALBSGT','f_tprefor','ENTRA'); --> BORRAR JGR
      i          := 1;

      WHILE i < LENGTH (ptprefor)
       AND SUBSTR (ptprefor, i, 1) <> '('
      LOOP
         i    := i + 1;
      END LOOP;
      s          :=
            'select '
         || SUBSTR (ptprefor, 1, i)
         || ' '''
         || ptablas
         || ''', '
         || TO_CHAR (psseguro)
         || ', '
         || TO_CHAR (pnriesgo)
         || ', TO_DATE('''
         || TO_CHAR (pfefecto)
         || '''), '
         || TO_CHAR (pnmovimi)
         || ', '
         || TO_CHAR (pcgarant)
         || ','
         || TO_CHAR (psproces)
         || ','
         || TO_CHAR (pnmovima)
         || ','
         || TO_CHAR (0);


      IF SUBSTR (ptprefor, i + 1, 1) <> ')' THEN
         s    :=
              s || ', ' || SUBSTR (ptprefor, i + 1, LENGTH (ptprefor) - i - 1);
      END IF;

      s          := s || ' ) from dual';
          DBMS_OUTPUT.put_line ('*** ' || s);
      cerror     := 0;
      ncursor    := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (ncursor, s, DBMS_SQL.native);
      DBMS_SQL.define_column (ncursor, 1, resultat);
      filas      := DBMS_SQL.EXECUTE (ncursor);

      IF DBMS_SQL.fetch_rows (ncursor) > 0 THEN
         DBMS_SQL.column_value (ncursor, 1, resultat);
      END IF;

      DBMS_SQL.close_cursor (ncursor);
      RETURN cerror;
   EXCEPTION
      WHEN OTHERS THEN
         p_control_Error('PAC_ALBSGT','f_tprefor',SUBSTR('s='||s||' '||SQLERRM,1,2000)); --> BORRAR JGR
         DBMS_SQL.close_cursor (ncursor);
         resultat    := NULL;
         RETURN -1;
   END f_tprefor;
END pac_albsgt_JGR;

/

  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ALBSGT_JGR" TO "PROGRAMADORESCSI";
