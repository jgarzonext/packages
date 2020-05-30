--------------------------------------------------------
--  DDL for Function F_PERIODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PERIODE" (precibo IN NUMBER, ptsalida OUT VARCHAR2)
RETURN NUMBER authid current_user IS
/*****************************************************************
F_PERIODE: Retorna el periode que va del efecte al venciment
d'un rebut formatejat...
Darrera modificació = DRA (30-12-1998). Poso la data de venciment - 1,
perquè sempre tenim en compte fefecte -> fvencim - 1.
ALLIBADM.
******************************************************************/
CODI_ERROR NUMBER := 0;
w_fefecto  DATE;
w_fvencim  DATE;
BEGIN
SELECT fefecto,fvencim
INTO   w_fefecto,w_fvencim
FROM   recibos
WHERE  nrecibo = precibo;
if w_fvencim < w_fefecto OR w_fvencim = w_fefecto THEN
ptsalida := 'A la vista';
else
	   w_fvencim := w_fvencim - 1;
ptsalida := TO_CHAR(w_fefecto, 'DD-MM-YYYY')||
'/'||
TO_CHAR(w_fvencim, 'DD-MM-YYYY');
end if;
RETURN(0);
EXCEPTION
WHEN NO_DATA_FOUND THEN
ptsalida := null;
codi_error := 101902;
RETURN(codi_error);
WHEN OTHERS THEN
ptsalida := null;
codi_error := 102367;
RETURN(codi_error);
END;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_PERIODE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PERIODE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PERIODE" TO "PROGRAMADORESCSI";
