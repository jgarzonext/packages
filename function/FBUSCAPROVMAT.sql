--------------------------------------------------------
--  DDL for Function FBUSCAPROVMAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FBUSCAPROVMAT" (nsesion  IN NUMBER,
                                            pssegur  IN NUMBER,
                                            pffecha  IN NUMBER,
                                            pbuscar  IN NUMBER,
                                            presult  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FBUSCAPROVMAT
   DESCRIPCION:  .

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
          PSSEGUR(number) --> Clave del seguro
          PFECHA(date)    --> Fecha
          PBUSCAR(number) --> 1 --> PROVISIÓ MATEMÀTICA.
	                      0 --> PROVISIÓ MATEMATICA - PENALITZACIÓ.
			      2 --> PER RVI SERÀ EL RESCAT DEL RVI.
          		      4 --> PPP, PIP, PJP) Import Brut de la Renda.
			      3 --> COMISSIÓ RVI PER GASTOS EXT EXT.
			      5 --> COMISSIÓ RVI PER GASTOS EXT INT.
     			      6 --> COMISSIÓ RVI PER GASTOS INT.
          PRESULT(number) --> Import del Rescat per tots els productes d'estalvi
   RETORNA VALUE:
          VALOR(NUMBER)-----> Importe
******************************************************************************/
valor    NUMBER;
pfecha   DATE;
BEGIN
   valor := NULL;
   pfecha := TO_DATE(pffecha,'yyyymmdd');
   VALOR := Pk_Provmatematicas.F_PROVMAT(nsesion,pssegur,pfecha,pbuscar,presult);
   IF VALOR >= 0 THEN
      RETURN VALOR;
   ELSE
      RETURN 0;
   END IF;
END Fbuscaprovmat;
 
 

/

  GRANT EXECUTE ON "AXIS"."FBUSCAPROVMAT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FBUSCAPROVMAT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FBUSCAPROVMAT" TO "PROGRAMADORESCSI";
