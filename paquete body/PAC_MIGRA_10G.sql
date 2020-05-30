--------------------------------------------------------
--  DDL for Package Body PAC_MIGRA_10G
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MIGRA_10G" 
IS
  -----------------------------------------------------------------------------
PROCEDURE
   p_migra_10g
   (ps_user IN VARCHAR2, ps_repserver IN VARCHAR2)
IS
   vs_sql   VARCHAR2(100);
BEGIN
   -- Asignamos el report server
   UPDATE
         usuarios
   SET   repserver=ps_repserver
   WHERE cusuari  = UPPER( ps_user )
         ;
   COMMIT;
   -- Asignamos el sinonimo privado
   BEGIN
      vs_sql   := 'DROP SYNONYM '||ps_user||'.parinstalacion';
      DBMS_OUTPUT.PUT_LINE( vs_sql||';' );
      EXECUTE IMMEDIATE vs_sql;
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;
   vs_sql   := 'CREATE SYNONYM '||ps_user||'.parinstalacion FOR '||F_USER||'.parinstalacion_10g';
   DBMS_OUTPUT.PUT_LINE( vs_sql||';' );
   EXECUTE IMMEDIATE vs_sql;
END p_migra_10g;
  -----------------------------------------------------------------------------
PROCEDURE
   p_deshaz_10g
   (ps_user IN VARCHAR2, ps_repserver IN VARCHAR2)
IS
   vs_sql   VARCHAR2(100);
BEGIN
   -- Asignamos el report server
   UPDATE
         usuarios
   SET   repserver=ps_repserver
   WHERE cusuari  = UPPER( ps_user )
         ;
   COMMIT;
   -- Asignamos el sinonimo privado
   BEGIN
      vs_sql   := 'DROP SYNONYM '||ps_user||'.parinstalacion';
      DBMS_OUTPUT.PUT_LINE( vs_sql||';' );
      EXECUTE IMMEDIATE vs_sql;
   EXCEPTION
   WHEN OTHERS THEN
      NULL;
   END;
   vs_sql   := 'CREATE SYNONYM '||ps_user||'.parinstalacion FOR '||F_USER||'.parinstalacion';
   DBMS_OUTPUT.PUT_LINE( vs_sql||';' );
   EXECUTE IMMEDIATE vs_sql;
END p_deshaz_10g;
  -----------------------------------------------------------------------------
PROCEDURE
   p_show_users
IS
   vs_out			VARCHAR2(255);
   vs_repserver	VARCHAR2(15);
   CURSOR   cc IS
      SELECT
            owner       ,
            table_name  ,
            repserver
      FROM  usuarios    ,
            all_synonyms
      WHERE cusuari(+)     = owner
      AND   synonym_name   = 'PARINSTALACION'
      ORDER BY
            table_name  ,
            repserver   ,
            owner
            ;
BEGIN
   vs_out	:= '';
   vs_out	:= vs_out||RPAD('TABLA REFERED'  ,30,'.')	||'|';
   vs_out	:= vs_out||RPAD('REPORT SERVER'  ,15,'.')	||'|';
   vs_out	:= vs_out||RPAD('USUARIO SYNPRIV',30,'.');
   DBMS_OUTPUT.PUT_LINE( vs_out );
   FOR reg IN cc LOOP
      vs_repserver	:= NVL(reg.repserver,'NULL');
      vs_out	:= '';
      vs_out	:= vs_out||RPAD(reg.table_name,30,' ')	||'|';
      vs_out	:= vs_out||RPAD(vs_repserver  ,15,' ')	||'|';
      vs_out	:= vs_out||RPAD(reg.owner     ,30,' ');
      DBMS_OUTPUT.PUT_LINE( vs_out );
   END LOOP;
END p_show_users;
  -----------------------------------------------------------------------------
END pac_migra_10g;

/

  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MIGRA_10G" TO "PROGRAMADORESCSI";
