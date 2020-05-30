--------------------------------------------------------
--  DDL for Function F_CREA_IBAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CREA_IBAN" 
       (pcodigo    IN OUT VARCHAR2, pctipban    IN OUT NUMBER)
        --pcodigoout IN OUT VARCHAR2, pctipbanout IN OUT NUMBER) 
RETURN VARCHAR2 AUTHID current_user IS
/***********************************************************************
    10/2007  JGR
    F_CREA_IBAN: Genera código IBAN. F_VALIDA_IBAN
    
    JGR 20/10/2007 Inicialment solo se convertiran tipos de cuentas andorranas 
    PCTIPBAN :
      1 CCC - Espanya
      2 IBAN
      3 CCC - Andorra
***********************************************************************/
    vcodigo varchar2(100) := pcodigo;
    v1      varchar2(100);

BEGIN
    
   IF PCTIPBAN = 3               AND 
      SUBSTR(PCODIGO,1,1) >= '0' AND
      SUBSTR(PCODIGO,1,1) <= '9' THEN
     -- Crear un IBAN artificial composat pel número de compte seguit codi de país (AD) i "00". 
     -- Per exemple partin del número de compte 00030005000000A12345
     vcodigo := vcodigo||'AD00'; 
     -- S'hauran de convertir les lletres en números partint de la taula de conversió 
     vcodigo := REPLACE(vcodigo,'A','10');
     vcodigo := REPLACE(vcodigo,'B','11');          
     vcodigo := REPLACE(vcodigo,'C','12');
     vcodigo := REPLACE(vcodigo,'D','13');          
     vcodigo := REPLACE(vcodigo,'E','14');          
     vcodigo := REPLACE(vcodigo,'F','15');
     vcodigo := REPLACE(vcodigo,'G','16');          
     vcodigo := REPLACE(vcodigo,'H','17');           
     vcodigo := REPLACE(vcodigo,'I','18');
     vcodigo := REPLACE(vcodigo,'J','19');          
     vcodigo := REPLACE(vcodigo,'K','20');          
     vcodigo := REPLACE(vcodigo,'L','21');
     vcodigo := REPLACE(vcodigo,'M','22');           
     vcodigo := REPLACE(vcodigo,'N','23');           
     vcodigo := REPLACE(vcodigo,'O','24');
     vcodigo := REPLACE(vcodigo,'P','25');          
     vcodigo := REPLACE(vcodigo,'Q','26');           
     vcodigo := REPLACE(vcodigo,'R','27');
     vcodigo := REPLACE(vcodigo,'S','28');           
     vcodigo := REPLACE(vcodigo,'T','29');           
     vcodigo := REPLACE(vcodigo,'U','30');
     vcodigo := REPLACE(vcodigo,'V','31');           
     vcodigo := REPLACE(vcodigo,'W','32');           
     vcodigo := REPLACE(vcodigo,'X','33');
     vcodigo := REPLACE(vcodigo,'Y','34');           
     vcodigo := REPLACE(vcodigo,'Z','35');
     -- S'aplicarà el MOD 97-10 (Annex 2). 
     -- Es calcula el mòdul 97 i es resta el romanent de 98. Si el resultat és un sol dígit, llavors s'afegeix un zero per l'esquerra.
     -- El  romanent  de la divisió de 000300050000001012345101300 per 97  =  67
     -- 98 - 67 = 31 així doncs, l'IBAN = AD3100030005000000A12345
     BEGIN
         v1 := 98-MOD(TO_NUMBER(vcodigo),97);
         pcodigo  := 'AD'||LPAD(v1,2,'0')||pcodigo;
         pctipban := 2;
         RETURN 0;
     EXCEPTION
       WHEN VALUE_ERROR THEN
          RETURN 102494; -- El código de cuenta es erróneo
     END;
   ELSE
     RETURN 0;
   END IF;    


EXCEPTION
    WHEN others THEN
        RETURN 102494; -- El código de cuenta es erróneo
END; 
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CREA_IBAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CREA_IBAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CREA_IBAN" TO "PROGRAMADORESCSI";
