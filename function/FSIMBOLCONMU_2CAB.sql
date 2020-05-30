--------------------------------------------------------
--  DDL for Function FSIMBOLCONMU_2CAB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FSIMBOLCONMU_2CAB" (nsesion  IN NUMBER,
                                             pctabla   IN NUMBER,
                                             ppinttec   IN NUMBER,
                                             pnedad1    IN NUMBER,
                                             pcsexo1    IN NUMBER,
                                             pnedad2    IN NUMBER,
                                             PCSEXO2    IN NUMBER,
                                             psimbol  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FSIMBOLCONMU_2CAB
   DESCRIPCION:  Retorna el valor del simbolo de conmutación (productos 2 cabezas)
   REVISIONES:
   PARAMETROS:
   INPUT: NSESION(NUMBER) --> Nro. de sesión del evaluador de fórmulas
          PCTABLA(NUMBER)  --> Codigo tabla mortalidad.
          PPINTTEC(NUMBER)  --> Interes tecnico.
          PNEDAD1(NUMBER)   --> Edad asegurado 1
          PCSEXO1(NUMBER)  --> Sexo asegurado 1
          PNEDAD2(NUMBER)  --> Edad asegurado 2
          PCSEXO2(NUMBER)   --> Sexo asegurado 2
          PSIMBOL(NUMBER) --> Simbolo codificado. 1.- NXY
   RETORNA VALUE:
          VALOR(NUMBER)-----> Fecha
******************************************************************************/
  VALOR   NUMBER;
BEGIN
 VALOR := 0;
 SELECT DECODE(PSIMBOL,1,NXY,0)
   INTO valor
   FROM SIMBOLCONMU_2cab
   WHERE CTABLA = PCTABLA  AND PINTTEC = PPINTTEC
     AND NEDAD1   = PNEDAD1 AND CSEXO1 = PCSEXO1
     AND NEDAD2 = PNEDAD2 AND CSEXO2 = PCSEXO2
     ;
 RETURN valor;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END FSIMBOLCONMU_2cab;
 
 

/

  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU_2CAB" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU_2CAB" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU_2CAB" TO "PROGRAMADORESCSI";
