--------------------------------------------------------
--  DDL for Function F_ZONA_OFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ZONA_OFI" ( pcempres IN NUMBER, pcoficin IN NUMBER)
         RETURN NUMBER authid current_user IS

l_tipo NUMBER;
l_data DATE;
num_err NUMBER;
wczona  NUMBER;
BEGIN
   l_tipo := 2;
   l_data := f_sysdate;

   wczona := NULL;
   num_err :=  F_BUSCAPADRE (pcempres ,pcoficin , l_tipo,
                             l_data , wczona);
   RETURN wczona;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END ;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_ZONA_OFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ZONA_OFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ZONA_OFI" TO "PROGRAMADORESCSI";
