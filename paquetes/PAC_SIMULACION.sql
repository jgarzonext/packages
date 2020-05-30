--------------------------------------------------------
--  DDL for Package PAC_SIMULACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIMULACION" IS

  TYPE registro IS RECORD ( EJERCICIO VARCHAR2(50)
  												, VFINAL NUMBER
  												, FECHA DATE
  												, MENSUAL NUMBER
  												, PERIODICA NUMBER
  												, APORMES NUMBER
  												, TEXTO VARCHAR2(50)
  												, VALOR NUMBER) ;

  TYPE Actuarial IS RECORD ( t NUMBER
                            ,px NUMBER -- 1er titular
                            ,py NUMBER -- 2do titular
                            ,pxpy NUMBER
                            ,vt NUMBER
                            ,Rev NUMBER
                            ,ax NUMBER
                            ,ay NUMBER
                            ,axx NUMBER
                            );

  TYPE SimTabla  IS TABLE OF registro  INDEX BY BINARY_INTEGER;
  TYPE ActuTabla IS TABLE OF Actuarial INDEX BY BINARY_INTEGER;

  Tabla SimTabla;
  Actu ActuTabla;

  FUNCTION F_SIMULACION_APOR_PP ( PFNACIMI1 IN DATE,
                             PFNACIMI2 IN DATE,
                             PSEXO1 IN NUMBER,
                             PSEXO2 IN NUMBER,
							 PFJUBILA IN DATE,
							 PEDADJUBILA IN NUMBER,
							 PNOMBRE1 IN VARCHAR2,
							 PNOMBRE2 IN VARCHAR2,
                             PPERIODICA IN NUMBER DEFAULT 0,
                             PEXTRA IN NUMBER DEFAULT 0,
                             PINTERES IN NUMBER DEFAULT 0,
                             PREVALI IN NUMBER DEFAULT 0,
                             PINTERRENI IN NUMBER DEFAULT 0,
                             PREVALREN IN NUMBER DEFAULT 0,
                             PREVERSION IN NUMBER DEFAULT 0,
                             PPERCIERTO IN NUMBER DEFAULT 0,
                             PHASTA OUT NUMBER ) RETURN NUMBER;

  FUNCTION F_SIMULACION_PRESTA_PP (
                             PSSEGURO IN NUMBER,
							 PFNACIMI1 IN DATE,
                             PSEXO1 IN NUMBER,
							 PFJUBILA IN DATE,
							 PEDADJUBILA IN NUMBER,
							 PNOMBRE1 IN VARCHAR2,
                             PPERIODICA IN NUMBER DEFAULT 0,
                             PEXTRA IN NUMBER DEFAULT 0,
                             PINTERES IN NUMBER DEFAULT 0,
							 PFCONTIN IN DATE DEFAULT NULL,
							 PFINICIOFIS IN DATE DEFAULT NULL,
							 PCONTIN IN NUMBER DEFAULT NULL,
							 PFVALORA IN DATE DEFAULT NULL,
							 PDERECHOS IN NUMBER DEFAULT NULL,
                             PHASTA OUT NUMBER ) RETURN NUMBER;

  FUNCTION F_MAX_FVALORA ( PSPRODUC IN NUMBER ) RETURN DATE;

  FUNCTION F_MIN_FANTIGI ( PSSEGURO IN NUMBER ) RETURN DATE;

END;

 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIMULACION" TO "PROGRAMADORESCSI";
