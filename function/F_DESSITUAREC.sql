--------------------------------------------------------
--  DDL for Function F_DESSITUAREC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESSITUAREC" (pnrecibo IN NUMBER, pfecha IN DATE,
   pidioma IN NUMBER, pcestaux IN NUMBER,
   pcodeout OUT NUMBER, ptextout OUT VARCHAR2)
RETURN NUMBER IS
/*************************************************************************
	F_DESSITUAREC: Retorna la descripción de la situacion de un recibo
*************************************************************************/
  w_num_aux		NUMBER(10);
  w_cestrec		NUMBER(10);
  w_destrec		VARCHAR2(2000);
  TYPE			t_cursor IS REF CURSOR;
  c_rec			t_cursor;
  w_selec		VARCHAR2(2000);
BEGIN
--
-- Actuamos distinto en el caso de estar en Alliança o en otro cliente
--
  pcodeout := NULL;
  ptextout := NULL;
  w_cestrec := f_cestrec(pnrecibo, pfecha);
  IF w_cestrec is NOT NULL THEN
    w_num_aux := f_desvalorfijo(1, pidioma, w_cestrec, w_destrec);
    IF w_num_aux = 0 THEN
      ptextout := w_destrec;
    ELSE
      RETURN w_num_aux;
    END IF;
  ELSE
    IF pcestaux = 1 THEN  --  coaseguro aceptado no validado
      pcodeout := 105760;
    END IF;
  END IF;
  RETURN 0;
EXCEPTION
  WHEN others THEN
    RETURN 111898;	-- Error al recuperar descripció de la situació d'un rebut
END f_dessituarec;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESSITUAREC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESSITUAREC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESSITUAREC" TO "PROGRAMADORESCSI";
