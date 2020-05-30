--------------------------------------------------------
--  DDL for Function FRESNUMFEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FRESNUMFEC" (nsesion  IN NUMBER,
                                         pffecha  IN NUMBER,
                                         ptipo    IN NUMBER,
                                         presto   IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FRESNUMFEC
   DESCRIPCION:  Resta un valor(según tipo) a una fecha.

   PARAMETROS:
   INPUT: NSESION(NUMBER) --> Nro. de sesión del evaluador de fórmulas
          PFFECHA(NUMBER) --> Fecha
          PTIPO(NUMBER)   --> 0 -> Dias, 1-> Meses, 2-> Años, 3-> otra fecha.
          PNUMERO(NUMBER) --> Según el tipo lo que se va a restar.
   RETORNA VALUE:
          VALOR(NUMBER)-----> Si el tipo es de 0 a 2 devuelve una Fecha.
                              Si el tipo es 3 devuelve dias.
******************************************************************************/
valor    number;
result   date;
pfecha   date;
pfecha1  date;

BEGIN

   valor := NULL;
   pfecha := to_date(pffecha,'yyyymmdd');
   IF ptipo = 0 THEN
      result := pfecha - presto;
      valor := to_number(to_char(result,'yyyymmdd'));
   ELSIF ptipo = 1 THEN
      result := add_months(pfecha,(presto * -1));
      valor := to_number(to_char(result,'yyyymmdd'));
   ELSIF ptipo = 2 THEN
      result := add_months(pfecha,(presto * -12));
      valor := to_number(to_char(result,'yyyymmdd'));
   ELSIF ptipo = 3 THEN
      pfecha1 := to_date(presto,'yyyymmdd');
      valor := pfecha - pfecha1;
   END IF;
   RETURN VALOR;
END FRESNUMFEC;
 
 

/

  GRANT EXECUTE ON "AXIS"."FRESNUMFEC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FRESNUMFEC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FRESNUMFEC" TO "PROGRAMADORESCSI";
