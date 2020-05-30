--------------------------------------------------------
--  DDL for Package PK_ENV_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_ENV_COMU" AS
	PROCEDURE Traza(trazas IN UTL_FILE.FILE_TYPE, depurar IN NUMBER, msg IN VARCHAR2);
	PROCEDURE hora(trazas IN UTL_FILE.FILE_TYPE);
END pk_env_comu;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_ENV_COMU" TO "PROGRAMADORESCSI";
