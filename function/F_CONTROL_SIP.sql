--------------------------------------------------------
--  DDL for Function F_CONTROL_SIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CONTROL_SIP" (psip NUMBER) RETURN NUMBER IS
/******************************************************************************

******************************************************************************/
type registro is varray(9) of number ;
tablas registro := registro(0,0,0,0,0,0,0,0,0);
vsip VARCHAR2(9);
s1   NUMBER:=0;
s2   NUMBER:=0;
dc   NUMBER:=0;
BEGIN

   /* trasnformamos el numero que nos pasan a varchar2 añadiendo 0 por la izquierda*/
   vsip:= to_char(psip);
   vsip:=lpad(vsip,9,'0');
   /* multipolicamos cada posición por su peso */
   tablas(1):=to_number(substr(vsip,8,1))*1;
   tablas(2):=to_number(substr(vsip,7,1))*2;
   tablas(3):=to_number(substr(vsip,6,1))*31;
   tablas(4):=to_number(substr(vsip,5,1))*1;
   tablas(5):=to_number(substr(vsip,4,1))*2;
   tablas(6):=to_number(substr(vsip,3,1))*31;
   tablas(7):=to_number(substr(vsip,2,1))*1;
   tablas(8):=to_number(substr(vsip,1,1))*2;
   /* guardamos el digito de control que nos pasan por parametro*/
   tablas(9):=to_number(substr(vsip,9,1));
   /* calculamos s1 : la suma de las unidades de todos los resultados*/
   for  i in 1..8 loop
    S1:= S1+to_number(substr(tablas(i),length(tablas(i)),1));
   end loop;
   /* calculamos s2: la suma de todos los dígitos sin contar las unidades*/
   for  i in 1..8 loop
    S2:= S2+NVL(to_number(substr(tablas(i),1,length(tablas(i))-1)),0);
   end loop;
   DC:= S1+S2;
   /* si las unidades del dc resultante es igual a dc pasado -> correcto
      sino inocorrecto */
   IF tablas(9)<> to_number((substr(to_char(dc),length(dc),1)))THEN
     --digito incorrecto
     RETURN 1;
   ELSE
     --digito correcto
     RETURN 0;
   END IF;
EXCEPTION
 WHEN OTHERS THEN
   RETURN 140999;--error no controlado
END f_control_sip;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CONTROL_SIP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CONTROL_SIP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CONTROL_SIP" TO "PROGRAMADORESCSI";
