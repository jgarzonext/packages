--------------------------------------------------------
--  DDL for Function F_SITUACION_POLIZA_2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUACION_POLIZA_2" (psseguro IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
  /****************************************************************************
    Retorna l'estat de la pòlissa: CVALOR= 251
	  1.- Vigente
	  2.- Retenida
	  3.- Prop. Alta
	  4.- Prop. Pdte. Autor.
	  5.- Prop. Anulada
	  6.- Prop. No aceptada
	  7.- Prop. Retenida
	  8.- Anulada
	  9.- Vencida
	  10.- Prop. Suplem.
	  11.- Prop. Suplem. Retenida
	  12.- Prop. Suplem. Pdte. Autor.

  *****************************************************************************/
  vestat NUMBER;
  vcsituac NUMBER;
  vcreteni NUMBER;

BEGIN
  SELECT csituac, creteni
    INTO vcsituac, vcreteni
    FROM seguros
    WHERE sseguro = psseguro;

  IF vcsituac = 0 THEN
     IF  vcreteni = 0 THEN
        --està vigent
	    vestat := 1;
     ELSIF vcreteni = 1 THEN
        --està Retenida
        vestat := 2;
	 end if;
  ELSIF vcsituac = 2 THEN
     vestat := 8; -- Anulada
  ELSIF vcsituac = 3 then
     vestat := 9; -- Vencida
  ELSIF vcsituac = 4 THEN
    IF vcreteni = 0 THEN
	    vestat := 3; -- Prop. Alta
    ELSIF vcreteni = 2 then
        vestat := 4;  -- Prop. Pdte. Autor.
	ELSIF vcreteni = 4 then
	    vestat := 5; -- Prop. Anulada
	ELSIF vcreteni = 3 then
	    vestat := 6; -- Prop. No Aceptada
	ELSIF vcreteni = 1 then
	    vestat := 7; -- Prop. Retenida
	END IF;
  ELSIF vcsituac = 5 then
    IF vcreteni = 0 then
	   vestat := 10; --Prop. Suplem.
	ELSIF vcreteni = 1 then
	   vestat := 11; -- Prop. Suplem. Ret.
	ELSIF vcreteni = 2 then
	   vestat := 12; -- Prop. Suplem. Pdte. Autor.
	END IF;

  END IF;

  RETURN vestat;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA_2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA_2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_POLIZA_2" TO "PROGRAMADORESCSI";
