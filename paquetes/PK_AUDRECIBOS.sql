--------------------------------------------------------
--  DDL for Package PK_AUDRECIBOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_AUDRECIBOS" IS
    FUNCTION generar ( mesaño IN DATE , ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION inicializar RETURN NUMBER;
    FUNCTION EMITIDOS ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION COBRADOS ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION EXTORNADOS_DE_COBRADOS ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION EXTORNADOS_DE_ANULADOS ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION PENDIENTES_DE_COBRO ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION ANULADOS_EMITIDOS_EJERCICIO ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
    FUNCTION ANULADOS_EMITIDOS_ANTERIORES ( pramo IN NUMBER   ,pmodali IN NUMBER
                      ,ptipseg IN NUMBER ,pcolect IN NUMBER
					  ,mesaño IN DATE
					  ,ptipo IN NUMBER) RETURN NUMBER;
END pk_audrecibos;

 
 

/

  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_AUDRECIBOS" TO "PROGRAMADORESCSI";
