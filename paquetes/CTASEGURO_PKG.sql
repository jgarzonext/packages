--------------------------------------------------------
--  DDL for Package CTASEGURO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."CTASEGURO_PKG" 
AS

-- Este package se utiliza para la mutación de la tabla CTASEGURO
-- que no permite consultar el mismo registro de la tabla que se ejecuta el disparador.

      TYPE      CTASEGURO_TYPE
	   IS TABLE OF ROWID INDEX BY BINARY_INTEGER;

	   CTASEGURO_TEMP ctaseguro_type;

	   INDICE BINARY_INTEGER;

END Ctaseguro_Pkg;

 
 

/

  GRANT EXECUTE ON "AXIS"."CTASEGURO_PKG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."CTASEGURO_PKG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."CTASEGURO_PKG" TO "PROGRAMADORESCSI";
