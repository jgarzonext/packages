--------------------------------------------------------
--  DDL for Function F_INSCTACTESCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INSCTACTESCIA" (psidepag IN NUMBER, psseguro IN NUMBER)
RETURN NUMBER authid current_user IS
/***********************************************************************
	F_INSCTACTESCIA: Inserta en ctactescia para un siniestro.
***********************************************************************/
 xcempres NUMBER(2);
 xccompani NUMBER(3);
 xnnumlin NUMBER(6);
BEGIN
 -- Recupera la empresa y la compañía.
 BEGIN
  SELECT a.cempres, NVL(a.ccompani, b.ccompani)
  INTO xcempres, xccompani
  FROM seguros a, productos b
  WHERE a.cramo = b.cramo
  AND   a.ctipseg = b.ctipseg
  AND   a.cmodali = b.cmodali
  AND   a.ccolect = b.ccolect
  AND   a.sseguro = psseguro;
 EXCEPTION
  WHEN OTHERS THEN
   RETURN 101919;	-- Error al llegir dades de la taula SEGUROS
 END;
 -- Recuperar el siguiente número de línea.
 BEGIN
  SELECT NVL(MAX(NNUMLIN),0) + 1
  INTO xnnumlin
  FROM CTACTESCIA
  WHERE CCOMPANI = xccompani
  AND CEMPRES = xcempres;
 EXCEPTION
  WHEN OTHERS THEN
    RETURN 110185; -- Error al llegir de la taula CTACTESCIA
 END;
 -- Se inserta en ctactescia.
 -- cdebhab -> 1: debe.
 -- cconta --> 5: pago siniestros
 -- cestado --> 1: pendiente
 -- cmanual --> 0: automático
 INSERT INTO ctactescia
  (CCOMPANI, NNUMLIN, CDEBHAB, CCONCTA, CESTADO, FFECMOV,
  IIMPORT, CMANUAL, CEMPRES, NSINIES, SIDEPAG)
 (SELECT xccompani, xnnumlin, 1, 5, 1, fordpag, isinret, 0,
  xcempres, nsinies, sidepag
  FROM pagosini
  WHERE sidepag = psidepag);
 RETURN 0;
EXCEPTION
 WHEN OTHERS THEN
  RETURN 110187; -- Error a l' inserir a la taula CTACTESCIA
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_INSCTACTESCIA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INSCTACTESCIA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INSCTACTESCIA" TO "PROGRAMADORESCSI";
