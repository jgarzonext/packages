--------------------------------------------------------
--  DDL for Function F_FULTCAR_REN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FULTCAR_REN" (pfiniapo IN DATE,
                                          pfinipre IN DATE,
										  pcforpag IN NUMBER)
  RETURN NUMBER  authid current_user IS
/******************************************************************************
   NOMBRE:       F_FULTCAR_REN
   DESCRIPCION:  A través de las fecha Inicio de aportaciones, Primer pago de
                 Renta y la forma de pago averigüa la fecha de última cartera.
   REVISIONES:

   PARAMETROS:
   INPUT: pfiniapo(date)   --> Fecha de Inicio de aportaciones
          pfinipre(date)   --> Fecha Inicio Prestación
          pcforpag(number) --> Forma de Pago
   RETORNA VALUE:
          VALOR(NUMBER)-----> Fecha de última cartera FORMATO (YYYYMMDD)
******************************************************************************/
valor    NUMBER;
xfultima DATE;
xfulapor DATE;
xperio   NUMBER;
BEGIN
   valor := NULL;
   IF pcforpag = 0 THEN       RETURN NULL;
   ELSIF pcforpag = 1  THEN   xperio := 12;
   ELSIF pcforpag = 2  THEN   xperio := 6;
   ELSIF pcforpag = 3  THEN   xperio := 4;
   ELSIF pcforpag = 4  THEN   xperio := 3;
   ELSIF pcforpag = 6  THEN   xperio := 2;
   ELSIF pcforpag = 12 THEN   xperio := 1;
   END IF;
   xfulapor := pfiniapo;
   xfultima := pfiniapo;
   WHILE xfulapor < pfinipre LOOP
         xfultima := xfulapor;
 	     xfulapor := ADD_MONTHS(xfulapor,xperio);
   END LOOP;
--   VALOR := to_char(xfultima,'yyyymmdd');
   VALOR := to_char(xfultima,'yyyymm');
   VALOR := VALOR || '01';
   return valor;
END F_FULTCAR_REN;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_FULTCAR_REN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FULTCAR_REN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FULTCAR_REN" TO "PROGRAMADORESCSI";
