--------------------------------------------------------
--  DDL for Function FF_USU_CPERNIVEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_USU_CPERNIVEL" (
   Pcusuari   IN   usuarios.cusuari%TYPE,
   Pfecha     IN   DATE DEFAULT f_sysdate
)
   RETURN NUMBER AUTHID CURRENT_USER
IS
   xcpernivel   redcomercial.cpernivel%TYPE;
BEGIN
   SELECT cpernivel
     INTO xcpernivel
     FROM usuarios u, redcomercial a
    WHERE u.cusuari = pcusuari
      AND u.cdelega = a.cagente
      AND a.fmovini <= pfecha
      and ( a.fmovfin >= pfecha or a.fmovfin is null) ;


   RETURN xcpernivel;
EXCEPTION
   WHEN OTHERS
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   'F_USU_CPERNIVEL',
                   1,
                   '-- Pcusuari =' || pcusuari||' --  Pfecha '||Pfecha,
                   SQLERRM
                  );
      RETURN NULL;      -- error al leer el campo cpervisio de la redcomercial
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."FF_USU_CPERNIVEL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_USU_CPERNIVEL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_USU_CPERNIVEL" TO "PROGRAMADORESCSI";
