--------------------------------------------------------
--  DDL for Package ISQLFOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."ISQLFOR" AS



    FUNCTION F_PERSONA( psseguro IN NUMBER DEFAULT NULL
	                  , pctipo   IN NUMBER DEFAULT NULL
                      , psperson IN NUMBER DEFAULT NULL	) RETURN VARCHAR2;


	FUNCTION F_DOMICILIO ( psperson IN NUMBER
	                     , pcdomici IN NUMBER ) RETURN VARCHAR2;

    FUNCTION F_CODPOSTAL ( psperson IN NUMBER
	                     , pcdomici IN NUMBER ) RETURN VARCHAR2;

    FUNCTION F_POBLACION ( psperson IN NUMBER
	                     , pcdomici IN NUMBER ) RETURN VARCHAR2;

    FUNCTION F_PROVINCIA ( psperson IN NUMBER
	                     , pcdomici IN NUMBER ) RETURN VARCHAR2;

    FUNCTION F_PROFESION ( psperson IN NUMBER
	                     , pcidioma IN NUMBER ) RETURN VARCHAR2;



END ISQLFOR;

 
 

/

  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."ISQLFOR" TO "PROGRAMADORESCSI";
