--------------------------------------------------------
--  DDL for Function EVALSELECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."EVALSELECT" (formula  IN  VARCHAR2    )  RETURN NUMBER  IS
  s   VARCHAR2(2000):=UPPER(formula);
  ncursor INTEGER;
  filas   INTEGER;
  retorno NUMBER;
  e       NUMBER;
BEGIN
  BEGIN
    s := 'SELECT ' || S || ' FROM DUAL';
    ncursor := dbms_sql.open_cursor;
    dbms_sql.parse(ncursor, s, DBMS_SQL.NATIVE);
    dbms_sql.define_column(ncursor, 1, retorno);
    filas := dbms_sql.execute(ncursor);
    IF DBMS_SQL.FETCH_ROWS(ncursor)>0 THEN
      -- Obtiene el valor final de toda la epresión
       DBMS_SQL.COLUMN_VALUE(ncursor, 1, retorno);
    END IF;
    dbms_sql.close_cursor(ncursor);
  EXCEPTION
    WHEN OTHERS THEN
      dbms_sql.close_cursor(ncursor);
      dbms_output.put_line(sqlerrm);
  END;
  IF retorno IS NULL THEN
    dbms_output.put_line(s);
  END IF;
  RETURN retorno;
END evalselect;

 
 

/

  GRANT EXECUTE ON "AXIS"."EVALSELECT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."EVALSELECT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."EVALSELECT" TO "PROGRAMADORESCSI";
