--------------------------------------------------------
--  DDL for Function F_INSAGENSINI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSAGENSINI" (pnsinies IN NUMBER, pfapunte IN DATE, pctipreg IN NUMBER,
	pfagenda IN DATE, pffinali IN DATE, pcestado IN NUMBER, ptagenda IN VARCHAR2,
	pcusuari IN VARCHAR2, pfmovimi IN DATE, psproces IN NUMBER DEFAULT NULL)
 RETURN NUMBER authid current_user IS
   error     NUMBER :=0;
   secuencia NUMBER;
   cod_apunt NUMBER;
BEGIN
--   Se cambia el sorden por nmovage (n. movimiento agenda para el siniestro)
--  SELECT sorden.NEXTVAL INTO secuencia FROM DUAL;
   SELECT max(nmovage) + 1 INTO secuencia
   FROM agensini
   WHERE nsinies = pnsinies;
   IF secuencia IS NULL THEN
      secuencia := 1;
   END IF;
--  Se añade un campo a la tabla capunte para codificación del apunte automatico
   IF pctipreg = 5 then
      cod_apunt := substr(ptagenda,1,2);
   ELSE
      cod_apunt := null;
   END IF;
   INSERT INTO agensini (nmovage, nsinies, fapunte, ctipreg, fagenda, ffinali,
	cestado, tagenda, cusuari, fmovimi, capunte, sproces)
   VALUES (secuencia, pnsinies, pfapunte, pctipreg, pfagenda, pffinali,
	pcestado, ptagenda, pcusuari, pfmovimi, cod_apunt, psproces);
   RETURN (0);
EXCEPTION
   WHEN dup_val_on_index THEN
	RETURN 107728;		-- Registre duplicat a AGENSINI
   WHEN others THEN
	RETURN 107727;		-- Error a l' inserir a AGENSINI
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_INSAGENSINI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSAGENSINI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSAGENSINI" TO "PROGRAMADORESCSI";
