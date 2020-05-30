--------------------------------------------------------
--  DDL for Function F_SG0CARG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SG0CARG" (U_login        IN VARCHAR2,
                                      p_Term         IN NUMBER,
                                      p_Prod         IN NUMBER,
                                      p_Emp          IN NUMBER,
                                      p_Lram         IN VARCHAR2,
                                      p_Import       IN NUMBER,
                                      p_Fval         IN DATE,
                                      p_CCCCARG      IN VARCHAR2,
                                      p_NIF          IN VARCHAR2,
                                      p_CCCABO       IN VARCHAR2,
                                      p_Tipop        IN NUMBER,
                                      p_Nomaseg      IN VARCHAR2,
                                      p_NPoliza      IN NUMBER,
                                      p_Observ       IN VARCHAR2,
                                      o_CODERROR     OUT NUMBER,
                                      o_MSGERROR     OUT VARCHAR2)
   RETURN BOOLEAN AUTHID CURRENT_USER IS
-- U_login : Codi d'Usuari que realitza l'operació
-- p_Term : Codi de Terminal
-- p_Prod : Codi de Producte
-- p_Emp : Codi d'Empresa
-- p_Lram : Literal del producte (Descripció Curta)
-- p_Import : Import del càrrec (ha de ser un valor sencer i les dues darreres posicions seràn tractades com a decimals al Host.
--            Per exemple, si l'import del càrrec és 30 eur el valor a passar serà 3000;
--                         si l'import és 23,56 el valor a passar serà 2356
-- p_Fval : Data de Valoració de l'operació
-- p_CCCCARG : CCC on es realitzarà el càrrec
-- p_NIF : NIF del titular del compte
-- p_CCCABO : CCC on es realitzarà l'abonament
-- p_Tipop : Tipus d'operació. Els valors possibles són: 1.Alta, 2.Aportació, 3.Rebut
-- p_Nomaseg : Nom del Prenedor/Assegurat
-- p_NPoliza : NPoliza del contracte (si es colectivo, el certificado)
-- p_Observ : Observaciones
-- o_CODERROR : Codi de l'error del Host
-- o_MSGERROR : Literal de l'error del Host


-- Els valors de RETORN de la función són:
-- . TRUE => El càrrec s'ha realitzat correctament
-- . FALSE => S'ha produit un error a l'operació de càrrec. El codi i el literal retornats pel Host es retornen als paràmetres de sortida o_CODERROR i o_MSGERROR respectivament

BEGIN

  -- p_Term = 0 (Mal); p_Term = 1 (Bien)

  IF p_Term = 0 THEN
     o_CODERROR := 151295;  -- No se ha podido cobrar el recibo en el Host
     o_MSGERROR := f_literal(o_CODERROR, F_IdiomaUser);
     Return False;
  ELSE
     Return True;
  END IF;

END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_SG0CARG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SG0CARG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SG0CARG" TO "PROGRAMADORESCSI";
