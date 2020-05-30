--------------------------------------------------------
--  DDL for Function F_CCC_BEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CCC_BEL" (pncuenta IN VARCHAR2, pnsalida IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
   codigo         VARCHAR2(30);
   cuent          VARCHAR2(10);
   contr          VARCHAR2(2);
   longi          NUMBER;
   RESULT         NUMBER;
BEGIN
   longi := LENGTH(pncuenta);

   --BUG 5553-12/02/2009-JTS-Se canvia el >12 por !=12
   IF longi != 12 THEN
      pnsalida := NULL;   -- Longitud incorrecta
      RETURN 800513;
   ELSE
      codigo := LPAD(pncuenta, 12, '0');   -- Rellena de 0's hasta 12
      cuent := SUBSTR(codigo, 1, 10);
      contr := SUBSTR(codigo, 11, 2);
      RESULT := TRUNC(TO_NUMBER(cuent) / 97) * 97;
      RESULT := TO_NUMBER(cuent) - RESULT;

      --BUG11234-XVM-22092009 Inici
      IF RESULT = 0 THEN
         RESULT := 97;
      END IF;
      --BUG11234-XVM-22092009 Fi

      IF RESULT <> contr THEN
         pnsalida := NULL;
         RETURN 102494;
      END IF;

      pnsalida := 0;
      RETURN 0;
   END IF;
END f_ccc_bel;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CCC_BEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CCC_BEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CCC_BEL" TO "PROGRAMADORESCSI";
