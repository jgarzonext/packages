--------------------------------------------------------
--  DDL for Package Body PK_BONUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_BONUS" IS

FUNCTION f_nbonus (zbonus IN NUMBER,fefecto IN DATE, fcuando IN DATE, pbonush OUT NUMBER)

    -- fefecto: Fecha a tener en cuenta para buscar la zona activa
    -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
  RETURN NUMBER IS

  error   NUMBER;

BEGIN
    SELECT distinct b.sbonush
    INTO pbonush
    FROM codbonus a,hisbonus b
    WHERE a.sbonus = zbonus
    AND a.sbonus = b.sbonus
    AND b.cbonuse = 1
    AND TRUNC(b.fbonusini) <= TRUNC(fefecto)
    AND (b.fbonusfin IS NULL OR TRUNC(b.fbonusfin) > TRUNC(fefecto) )
    AND b.fbonusact = (SELECT MAX(b.fbonusact)
                       FROM codbonus a, hisbonus b
                       WHERE a.sbonus =zbonus
                       AND a.sbonus = b.sbonus
                       AND b.cbonuse = 1
                       AND TRUNC(b.fbonusini)<= TRUNC(fefecto)
		       AND (b.fbonusfin IS NULL OR TRUNC(b.fbonusfin)>TRUNC(fefecto))
                       AND b.fbonusact <= fcuando);
    return 0;
EXCEPTION WHEN OTHERS then
error:=sqlcode;
return error;
END f_nbonus;
---------------------------------------------------------------------------------
function f_zbonus(psseguro in number, pzbonus out number)
RETURN NUMBER IS
cont NUMBER;
BEGIN
  SELECT c.sbonus
  into pzbonus
  FROM  codbonus c, seguros s, productos p
  WHERE c.CRAMO   = p.cramo
  AND c.SPRODUC = p.sproduc
  AND c.cactivi = s.cactivi
  AND p.ctipseg = s.ctipseg
  AND p.CCOLECT = s.ccolect
  AND p.CRAMO = s.cramo
  AND p.CMODALI = s.cmodali
  AND s.sseguro = psseguro;

return 0;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    BEGIN
	 SELECT c.sbonus
     into pzbonus
     FROM  codbonus c, estseguros s, productos p
     WHERE c.CRAMO   = p.cramo
     AND c.SPRODUC = p.sproduc
     AND c.cactivi = s.cactivi
     AND p.ctipseg = s.ctipseg
     AND p.CCOLECT = s.ccolect
     AND p.CRAMO = s.cramo
     AND p.CMODALI = s.cmodali
     AND s.sseguro = psseguro;
	 return 0;
	EXCEPTION WHEN NO_DATA_FOUND THEN RETURN 109862;--NO EXISTE ZONIFICACION
  WHEN OTHERS THEN RETURN NULL;--ERROR
END;
end f_zbonus;

-------------------------------------------------------------------------------------
function f_bonusdefecto (vsbonush in number, vczbonus out number) return number is
begin
  SELECT czbonus
  into vczbonus
  from nivellbonus
  where sbonush=vsbonush
  and nfaccor = 1;
  return 0;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 109862;--NO EXISTE ZONIFICACION
    WHEN OTHERS THEN RETURN NULL;--ERROR
end f_bonusdefecto;
-------------------------------------------------------------------------------------
end pk_bonus;

/

  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "PROGRAMADORESCSI";
