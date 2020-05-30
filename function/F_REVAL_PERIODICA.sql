--------------------------------------------------------
--  DDL for Function F_REVAL_PERIODICA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_REVAL_PERIODICA" (psseguro IN  NUMBER, pcrevali IN NUMBER,
                                              pfcarpro IN DATE,    pfcaranu IN DATE ,
                                              pmes IN NUMBER,      pany IN NUMBER,
                                              prevalper OUT NUMBER)
       RETURN  NUMBER authid current_user IS
/************************************************************************************
Retorna
 0 - La pòlissa no ha de revaloritzar en la cartera fraccionada del pmes i pany
 1 - La pòlissa ha de revaloritzar en la cartera fraccionada  del pmes i pany
pcrevali = 6 Revalorització periodificada
*************************************************************************************/
   lerror    NUMBER := 0;
   lgar_reva NUMBER;
BEGIN
   prevalper := 0;
   IF pcrevali = 6 THEN
      -- Comprovem que no sigui renovació, només hem de mirar a les fraccionades
      IF pfcarpro <>  pfcaranu THEN
         -- Mirem si hi ha garanties que han de revaloritzar en aquesta cartera
         SELECT COUNT(*) INTO lgar_reva
         FROM garanseg
         WHERE sseguro = psseguro
           AND ffinefe IS NULL
           AND crevali <> 0
           AND fpprev  <= last_day(to_date(lpad(pmes,2,'0')||pany,'mmyyyy'));
         IF lgar_reva > 0 THEN
            prevalper := 1;
         END IF;
      END IF;
   END IF;
   RETURN lerror;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_REVAL_PERIODICA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_REVAL_PERIODICA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_REVAL_PERIODICA" TO "PROGRAMADORESCSI";
