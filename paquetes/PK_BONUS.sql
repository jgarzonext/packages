--------------------------------------------------------
--  DDL for Package PK_BONUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_BONUS" authid current_user IS
/***************************************************************
	PK_BONUS: Package per a funcions de bonus
             (función de bonificación por defecto)
***************************************************************/
FUNCTION f_nbonus (zbonus IN NUMBER,
                   fefecto in date,
		   fcuando IN DATE,
                   pbonush OUT NUMBER)
  RETURN NUMBER;
  -- Retorna el nivell de bonus donat una data
  -- fefecto: Fecha a tener en cuenta para buscar la zona activa
  -- fcuando: Fecha para simular que la búsqueda se está haciendo un dia en concreto
--------------------------------------------------------------------
function f_zbonus ( psseguro in number, pzbonus out number)
  RETURN NUMBER;
  -- Retorna la bonificació que li pertany donat una polissa

---------------------------------------------------------------------
function f_bonusdefecto (vsbonush in number, vczbonus out number) return number;
 -- Retorna el bonus corresponen per defecte

END pk_bonus;
 
 

/

  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_BONUS" TO "PROGRAMADORESCSI";
