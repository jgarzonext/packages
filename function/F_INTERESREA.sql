--------------------------------------------------------
--  DDL for Function F_INTERESREA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INTERESREA" (preserva IN NUMBER, pcintres IN NUMBER,
                                         pini IN DATE,pfin IN DATE, interes OUT NUMBER)
RETURN NUMBER AUTHID current_user IS
/*************************************************************
F_INTERESREA: Retorna el interés
**************************************************************/
valor  NUMBER;

CURSOR cur_interes (wcintres NUMBER, wini DATE, wfin DATE )IS
         SELECT pintres
           FROM INTERESREA
          WHERE cintres = wcintres
            AND fintres BETWEEN TO_DATE(wini,'dd/mm/yyyy') AND
                                 TO_DATE(wfin,'dd/mm/yyyy');

BEGIN
  valor := preserva;
  FOR i IN cur_interes (pcintres,pini,pfin)LOOP
    valor := valor * POWER((1 + i.pintres / 100), 3 / 12);
  END LOOP;
  interes := valor - preserva;

  RETURN 0;



END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_INTERESREA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INTERESREA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INTERESREA" TO "PROGRAMADORESCSI";
