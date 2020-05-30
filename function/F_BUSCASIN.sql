--------------------------------------------------------
--  DDL for Function F_BUSCASIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCASIN" (psseguro IN NUMBER, nsiniestros IN OUT NUMBER)
   RETURN NUMBER IS
/******************************************************************************
   NOMBRE:       F_BUSCASIN
   PROP¿SITO:    Busca el n¿ de siniestros correspondientes a una
               p¿liza.

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0                                     1. Creaci¿n de la funci¿n.
   1.1        28/10/2009  FAL              2. 0011595: CEM - Siniestros. Adaptaci¿n al nuevo m¿dulo de siniestros
******************************************************************************/

   /***********************************************************************
   F_BUSCASIN: Busca el n¿ de siniestros correspondientes a una
      p¿liza.
   ALLIBSIN - Funciones de siniestros
***********************************************************************/
   v_cempres      NUMBER;
BEGIN
-- BUG 0011595 - 28/10/2009 - FAL - Adaptaci¿n al nuevo m¿dulo de siniestros
    /*
         SELECT   count(*)
      INTO  nsiniestros
      FROM  SINIESTROS
      WHERE sseguro = psseguro
    AND CESTSIN = 0;
      RETURN 0;
    */
   SELECT cempres
     INTO v_cempres
     FROM seguros
    WHERE sseguro = psseguro;

   IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MODULO_SINI'), 0) = 0 THEN
      SELECT COUNT(*)
        INTO nsiniestros
        FROM siniestros
       WHERE sseguro = psseguro
         AND cestsin in( 0,4,5);

      RETURN 0;
   ELSE
      SELECT COUNT(*)
        INTO nsiniestros
        FROM sin_siniestro s, sin_movsiniestro m
       WHERE s.nsinies = m.nsinies
         AND s.sseguro = psseguro
         AND m.nmovsin = (SELECT MAX(nmovsin)
                            FROM sin_movsiniestro
                           WHERE nsinies = s.nsinies)
         AND m.cestsin in( 0,4,5);

      RETURN 0;
   END IF;
-- FI BUG 0011595 - 28/10/2009 - FAL
EXCEPTION
   WHEN OTHERS THEN
      RETURN 100505;   -- Sinistre inexistent
END;

/

  GRANT EXECUTE ON "AXIS"."F_BUSCASIN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCASIN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCASIN" TO "PROGRAMADORESCSI";
