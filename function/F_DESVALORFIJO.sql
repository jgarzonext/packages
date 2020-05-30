--------------------------------------------------------
--  DDL for Function F_DESVALORFIJO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESVALORFIJO" (
   pcvalor IN NUMBER,
   pcidioma IN NUMBER,
   pcatribu IN NUMBER,
   pttexto IN OUT VARCHAR2)
   RETURN NUMBER AUTHID CURRENT_USER IS
/***********************************************************************
   F_DESVALORFIJO: Obtener la descripción de un Valor Fijo en
      función del idioma del usuario.
   ALLIBMFM
***********************************************************************/
BEGIN
   SELECT tatribu
     INTO pttexto
     FROM detvalores
    WHERE catribu = pcatribu
      AND cidioma = pcidioma
      AND cvalor = pcvalor;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, 'f_desvalorfijo', 1, 'error no controlado',
                  'pcatribu:' || pcatribu || ' pcidioma:' || pcidioma || ' pcvalor:'
                  || pcvalor);
      RETURN 100538;   -- Valor fixe inexistent
END;

/

  GRANT EXECUTE ON "AXIS"."F_DESVALORFIJO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESVALORFIJO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESVALORFIJO" TO "PROGRAMADORESCSI";
