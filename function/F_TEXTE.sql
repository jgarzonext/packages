--------------------------------------------------------
--  DDL for Function F_TEXTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_TEXTE" (plinia IN VARCHAR2, pseparador IN VARCHAR2, pordre IN NUMBER)
            RETURN VARCHAR2 IS
      ldesde NUMBER;
      lhasta NUMBER;
      ltexte VARCHAR2(300);
   BEGIN
      IF pordre > 1 THEN
         ldesde := INSTR(plinia,pseparador, 1, pordre-1) + 1;
      ELSE
         ldesde := 1;
      END IF;
      lhasta := INSTR(plinia,pseparador, 1, pordre);
      IF lhasta = 0 THEN
         lhasta := LENGTH(plinia) + 1;
      END IF;
      ltexte := SUBSTR(plinia, ldesde, lhasta-ldesde);
      RETURN ltexte;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_TEXTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_TEXTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_TEXTE" TO "PROGRAMADORESCSI";
