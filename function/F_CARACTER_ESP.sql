--------------------------------------------------------
--  DDL for Function F_CARACTER_ESP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CARACTER_ESP" (ptextin IN VARCHAR2, ptextout OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/***********************************************************************
	f_caracter_esp: Elimina caracteres especiales
	09-01-05 GMM5513 (SA NOSTRA ASSEGURANCES)
***********************************************************************/

BEGIN
	ptextout:=ptextin;

---- MINUSCULAS

	ptextout:=REPLACE(ptextout,'à','a');
	ptextout:=REPLACE(ptextout,'è','e');
	ptextout:=REPLACE(ptextout,'ì','i');
	ptextout:=REPLACE(ptextout,'ò','o');
	ptextout:=REPLACE(ptextout,'ù','u');
	ptextout:=REPLACE(ptextout,'á','a');
	ptextout:=REPLACE(ptextout,'é','e');
	ptextout:=REPLACE(ptextout,'í','i');
	ptextout:=REPLACE(ptextout,'ó','o');
	ptextout:=REPLACE(ptextout,'ú','u');
	ptextout:=REPLACE(ptextout,'ä','a');
	ptextout:=REPLACE(ptextout,'ë','e');
	ptextout:=REPLACE(ptextout,'ï','i');
	ptextout:=REPLACE(ptextout,'ö','o');
	ptextout:=REPLACE(ptextout,'ü','u');
	ptextout:=REPLACE(ptextout,'â','a');
	ptextout:=REPLACE(ptextout,'ê','e');
	ptextout:=REPLACE(ptextout,'î','i');
	ptextout:=REPLACE(ptextout,'ô','o');
	ptextout:=REPLACE(ptextout,'û','u');
	ptextout:=REPLACE(ptextout,'ç','c');
	ptextout:=REPLACE(ptextout,'ñ','n');

---- MAYUSCULAS

    ptextout:=REPLACE(ptextout,'À','A');
	ptextout:=REPLACE(ptextout,'È','E');
	ptextout:=REPLACE(ptextout,'Ì','I');
	ptextout:=REPLACE(ptextout,'Ò','O');
	ptextout:=REPLACE(ptextout,'Ù','U');
	ptextout:=REPLACE(ptextout,'Á','A');
	ptextout:=REPLACE(ptextout,'É','E');
	ptextout:=REPLACE(ptextout,'Í','I');
	ptextout:=REPLACE(ptextout,'Ó','O');
	ptextout:=REPLACE(ptextout,'Ú','U');
	ptextout:=REPLACE(ptextout,'Ä','A');
	ptextout:=REPLACE(ptextout,'Ë','E');
	ptextout:=REPLACE(ptextout,'Ï','I');
	ptextout:=REPLACE(ptextout,'Ö','O');
	ptextout:=REPLACE(ptextout,'Ü','U');
	ptextout:=REPLACE(ptextout,'Â','A');
	ptextout:=REPLACE(ptextout,'Ê','E');
	ptextout:=REPLACE(ptextout,'Î','I');
	ptextout:=REPLACE(ptextout,'Ô','O');
	ptextout:=REPLACE(ptextout,'Û','U');
	ptextout:=REPLACE(ptextout,'Ç','C');
	ptextout:=REPLACE(ptextout,'Ñ','N');


	RETURN 0;
EXCEPTION
	WHEN others THEN
		RETURN 1;
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_CARACTER_ESP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CARACTER_ESP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CARACTER_ESP" TO "PROGRAMADORESCSI";
