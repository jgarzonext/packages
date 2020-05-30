--------------------------------------------------------
--  DDL for Function FULTCAPMEDASSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FULTCAPMEDASSP" (nsesion  IN NUMBER,
                                        pseguro  IN NUMBER,
                                        pfecven  IN NUMBER,
                                        pcforamor IN NUMBER,
                                        pncaren  IN NUMBER,
                                        pfefecto IN NUMBER,
                                        pfefmes  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:
   DESCRIPCION:  Capital medio de un periodo ASSP.

   PARAMETROS:
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
   RETORNA VALUE:
          NUMBER------------>
******************************************************************************/
valor     number;
xfvencim  date;
xfefmes   date;
xfefecto  date;
pfecha    date;
pfecha1   date;
xxn       number;
wa        number;
xxcap1    number;
xxcap2    number;
xxcapital number;

BEGIN
   valor := NULL;
   xfvencim := to_date(pfecven, 'yyyymmdd');
   xfefecto := to_date(pfefecto, 'yyyymmdd');
   xfefmes  := to_date(pfefmes, 'yyyymmdd');

   WA := F_DIFDATA(xfefmes,xfvencim,2,1,xxn);

   BEGIN
     valor := 0;

     FOR I IN 1..xxn  LOOP
         IF I = 1 THEN
            PFECHA := xfefecto;
            pfecha1 := add_months(xfefecto,pcforamor);
         ELSE
            pfecha := add_months(pfecha1,1);
            pfecha1:= add_months(pfecha,(pcforamor-1));
         END IF;
     END LOOP;

     XXCAP1 := PK_CUADRO_AMORTIZACION.CAPITAL_PENDIENTE(PSEGURO,xfefecto,PFECHA);
     XXCAP2 := PK_CUADRO_AMORTIZACION.CAPITAL_PENDIENTE(PSEGURO,xfefecto,PFECHA1);
     XXCAPITAL := (XXCAP1+XXCAP2) / 2;
     valor := xxcapital;

     RETURN VALOR;

   EXCEPTION
    WHEN OTHERS THEN RETURN 0;
   END;
END FULTCAPMEDASSP;
 
 

/

  GRANT EXECUTE ON "AXIS"."FULTCAPMEDASSP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FULTCAPMEDASSP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FULTCAPMEDASSP" TO "PROGRAMADORESCSI";
