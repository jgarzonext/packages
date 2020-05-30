--------------------------------------------------------
--  DDL for Function FFINFPAGO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FFINFPAGO" (nsesion  IN NUMBER,
                                       pfpago   IN NUMBER,
       	  		               pffecha  IN NUMBER)
  RETURN NUMBER authid current_user IS
/******************************************************************************
   NOMBRE:       FFINFPAGO
   DESCRIPCION:  Retorna una fecha en función de la fecha de entrada y la forma
                 de pago.
   PARAMETROS:
   INPUT: NSESION(NUMBER) --> Nro. de sesión del evaluador de fórmulas
          PFPAGO(NUMBER)  --> Forma de pago.
          PFFECHA(NUMBER) --> Fecha
   RETORNA VALUE:
          VALOR(NUMBER)-----> Fecha
******************************************************************************/
val      number;
xfecini  date;
pfecha   date;
xdia     number;
xmes     number;
xany     number;
xdiv     number;
BEGIN
xdia := to_number(substr(to_char(pffecha),7,2));
xmes := to_number(substr(to_char(pffecha),5,2));
xany := to_number(substr(to_char(pffecha),1,4));
xdiv := (xmes/pfpago);
if pfpago = 4 then
  if xdiv < 1 then
     xdiv := 3;
  elsif xdiv >= 1 and xdiv <= 1.5 then
     xdiv := 6;
  elsif xdiv > 1.5 and xdiv <= 2.25 then
     xdiv :=9;
  else
     xdiv :=12;
  end if;
elsif pfpago = 3 then
  if xdiv < 1.5 then
     xdiv := 4;
  elsif xdiv > 1.5 and xdiv < 2.7 then
     xdiv := 8;
  else
     xdiv :=12;
  end if;
elsif pfpago = 6 then
  if xdiv < 0.5 then
     xdiv := 2;
  elsif xdiv >= 0.5 and xdiv < 0.7 then
     xdiv := 4;
  elsif xdiv > 0.7 and xdiv <= 1 then
     xdiv := 6;
  elsif xdiv > 1 and xdiv < 1.4 then
     xdiv := 8;
  elsif xdiv >= 1.5 and xdiv <= 1.7 then
     xdiv := 10;
  else
     xdiv :=12;
  end if;
end if;
SELECT DECODE(pfpago,
12,(last_day(to_date(pffecha,'yyyymmdd'))),
6,(decode(xdiv,2,(last_day(to_date(xany||'0201','yyyymmdd')))
              ,4,(last_day(to_date(xany||'0401','yyyymmdd')))
              ,6,(last_day(to_date(xany||'0601','yyyymmdd')))
              ,8,(last_day(to_date(xany||'0801','yyyymmdd')))
              ,10,(last_day(to_date(xany||'1001','yyyymmdd')))
              ,12,(last_day(to_date(xany||'1201','yyyymmdd'))))),
4,(decode(xdiv,3,(last_day(to_date(xany||'0301','yyyymmdd')))
              ,6,(last_day(to_date(xany||'0601','yyyymmdd')))
              ,9,(last_day(to_date(xany||'0901','yyyymmdd')))
              ,12,(last_day(to_date(xany||'1201','yyyymmdd'))))),
3,(decode(xdiv,4,(last_day(to_date(xany||'0401','yyyymmdd')))
              ,8,(last_day(to_date(xany||'0801','yyyymmdd')))
              ,12,(last_day(to_date(xany||'1201','yyyymmdd'))))),
2,(decode(greatest(xmes,06),06,(last_day(to_date(xany||'0601','yyyymmdd'))),
                               (last_day(to_date(xany||'1201','yyyymmdd'))))),
1,to_date((xany ||'1231'),'yyyymmdd'))
     INTO xfecini
      FROM DUAL;
val := to_number(to_char(xfecini,'yyyymmdd'),'999999999');
return val;
END FFINFPAGO;
 
 

/

  GRANT EXECUTE ON "AXIS"."FFINFPAGO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FFINFPAGO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FFINFPAGO" TO "PROGRAMADORESCSI";
