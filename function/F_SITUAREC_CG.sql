--------------------------------------------------------
--  DDL for Function F_SITUAREC_CG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUAREC_CG" (pnrecibo IN NUMBER, pfestrec IN DATE)
RETURN NUMBER IS
/***********************************************************************
	F_SITUAREC: Obtener la situación de un recibo en una fecha
		determinada.
	ALLIBADM - Sección correspondiente al módulo de recibos
	Modificació: Cambio del select por un cursor para poder seleccionar
	             la última situación del recibo en el caso de una selección
	             múltiple
   Modificació: Si es un coaseguro aceptado el estado depende si esta
                pendiente o no de verificar.
             Esta funcion debe ser igual f_cestaux
   Modificació: debido a una modificación en la función f_movrecibo que
                graba las fechas de inicio y fin truncadas podemos
                optimizar este proceso ya que para varios movimientos en el
                mismo día nos devolverá directamente el último.
***********************************************************************/
err_num   NUMBER := 0;
xcestaux  NUMBER;
pcestrec number;
BEGIN
  SELECT NVL(cestaux,0)
    INTO xcestaux
    FROM recibos
   WHERE nrecibo = pnrecibo;
  IF xcestaux = 0 THEN		-- Vàlid (en vigor)
    SELECT cestrec
      INTO pcestrec
      FROM MOVRECIBO
     WHERE nrecibo = pnrecibo
       AND TRUNC(pfestrec) >= fmovini
       AND (TRUNC(pfestrec) < fmovfin OR fmovfin is null);
  ELSE
    pcestrec := NULL;
    err_num := 105591;  -- Recibo de coaseguro aceptado pendiente de validar
  END IF;
  RETURN pcestrec;
EXCEPTION
  WHEN others THEN
    pcestrec := NULL;
    RETURN -1;     -- Error al leer de RECIBOS
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SITUAREC_CG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUAREC_CG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUAREC_CG" TO "PROGRAMADORESCSI";
