--------------------------------------------------------
--  DDL for Function FSIMBOLCONMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FSIMBOLCONMU" (nsesion  IN NUMBER,
                                        ptabla   IN NUMBER,
             	  		                inttec   IN NUMBER,
										pedad    IN NUMBER,
										psexo    IN NUMBER,
										psimbol  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FSIMBOLCONMU
   DESCRIPCION:  Retorna el valor del simbolo.

   PARAMETROS:
   INPUT: NSESION(NUMBER) --> Nro. de sesión del evaluador de fórmulas
          PTABLA(NUMBER)  --> Codigo tabla mortalidad.
          INTTEC(NUMBER)  --> Interes tecnico.
		  PEDAD(NUMBER)   --> Edad
		  PSIMBOL(NUMBER) --> Simbolo codificado.
   RETORNA VALUE:
          VALOR(NUMBER)-----> Fecha
******************************************************************************/
val   number;
QXY   number;
LXY   number;
LXYA  number;
DXY   number;
DXYA  number;
NXY   number;
NXYA  number;
SXY   number;
MXY   number;
RXY   number;
CXY   number;
CXYA  number;
IXY   number;
TPXYA number;
BEGIN
 VAL := 0;
 SELECT DECODE(psexo,1,QX,2,QY),   DECODE(psexo,1,LX,2,LY),   DECODE(psexo,1,LXA,2,LYA),
        DECODE(psexo,1,DX,2,DY),   DECODE(psexo,1,DXA,2,DYA), DECODE(psexo,1,NX,2,NY),
        DECODE(psexo,1,NXA,2,NYA), DECODE(psexo,1,SX,2,SY),   DECODE(psexo,1,MX,2,MY),
        DECODE(psexo,1,RX,2,RY),   DECODE(psexo,1,CX,2,CY),   DECODE(psexo,1,CXA,2,CYA),
        DECODE(psexo,1,IX,2,IY),   DECODE(psexo,1,TPXA,2,TPYA)
   INTO QXY,LXY,LXYA,DXY,DXYA,NXY,NXYA,SXY,MXY,RXY,CXY,CXYA,IXY,TPXYA
   FROM SIMBOLCONMU
   WHERE CTABLA = PTABLA
     AND PINTTEC = INTTEC
	 AND NEDAD   = PEDAD;
 IF PSIMBOL = 1 THEN
 	VAL := QXY;
 ELSIF PSIMBOL = 2 THEN
 	VAL := LXY;
 ELSIF PSIMBOL = 3 THEN
    VAL := LXYA;
 ELSIF PSIMBOL = 4 THEN
    VAL := DXY;
 ELSIF PSIMBOL = 5 THEN
    VAL := DXYA;
 ELSIF PSIMBOL = 6 THEN
    VAL := NXY;
 ELSIF PSIMBOL = 7 THEN
    VAL := NXYA;
 ELSIF PSIMBOL = 8 THEN
    VAL := SXY;
 ELSIF PSIMBOL = 9 THEN
    VAL := MXY;
 ELSIF PSIMBOL = 10 THEN
    VAL := RXY;
 ELSIF PSIMBOL = 11 THEN
    VAL := CXY;
 ELSIF PSIMBOL = 12 THEN
    VAL := CXYA;
 ELSIF PSIMBOL = 13 THEN
    VAL := IXY;
 ELSIF PSIMBOL = 14 THEN
    VAL := TPXYA;
 ELSE
    VAL := 0;
 END IF;
 RETURN val;
 EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;
END FSIMBOLCONMU;
 
 

/

  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FSIMBOLCONMU" TO "PROGRAMADORESCSI";
