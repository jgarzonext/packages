--------------------------------------------------------
--  DDL for Package PK_DBA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_DBA_UTIL" 
AS

PROCEDURE rename_CK_NN;
PROCEDURE drop_pk;
PROCEDURE drop_fk;
PROCEDURE drop_uk;
PROCEDURE add_pk;
PROCEDURE add_fk;
PROCEDURE add_uk;

PROCEDURE add_pk_table(p_table_name VARCHAR2);
PROCEDURE add_fk_table(p_table_name VARCHAR2);
PROCEDURE add_uk_table(p_table_name VARCHAR2);
PROCEDURE rename_CK_NN_table (nom_tabla VARCHAR2);

END pk_dba_util;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_DBA_UTIL" TO "PROGRAMADORESCSI";
