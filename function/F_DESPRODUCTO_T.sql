--------------------------------------------------------
--  DDL for Function F_DESPRODUCTO_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_DESPRODUCTO_T" (
   pccodram IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pntexto IN NUMBER,
   pcidioma IN NUMBER)
   RETURN VARCHAR2 IS
   /******************************************************************************
         NOM:  f_desproducto_t
         DESC: Recupera la descripció d'un producte

         REVISIONES:
         Ver        Fecha        Autor             Descripción
         ---------  ----------  ---------------  ------------------------------------
         1.0
         2.0        01/06/2009   NMM             2. 9648: IAX - Mantenim. Impostos.
   ******************************************************************************/
   num_err        NUMBER;
   w_texto        VARCHAR2(40);
BEGIN
   num_err := 0;
   w_texto := NULL;

   SELECT DECODE(pntexto, 1, ttitulo, 2, trotulo)
     INTO w_texto
     FROM titulopro
    WHERE ctipseg = pctipseg
      AND cramo = pccodram
      AND cmodali = pcmodali
      AND ccolect = pccolect
      AND cidioma = pcidioma;

   RETURN(w_texto);
--
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -- Mantis 9648.NMM.IAX - Mantenim. Impostos.i.
      RETURN(NULL);   -- .f.
   WHEN OTHERS THEN
      RETURN('Error : ' || TO_CHAR(SQLCODE));
END f_desproducto_t;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO_T" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO_T" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_DESPRODUCTO_T" TO "PROGRAMADORESCSI";
