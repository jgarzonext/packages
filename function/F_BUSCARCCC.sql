--------------------------------------------------------
--  DDL for Function F_BUSCARCCC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BUSCARCCC" (
   psperson IN NUMBER,
   pcbancar OUT VARCHAR2,
   pctipban OUT NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_buscarccc: Obtenir el ccc de la persona entrada com a paràmetre.
   ALLIBMFM.
   CPM: Creamos un cursor para elegir la cuenta de la pòliza
      más actual (con el rownum hemos tenido problemas).

****************************************************************************/-- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
 --Conseguimos el vagente_poliza y la empresa de la póliza de la tabla seguros
   CURSOR c_banc IS
      SELECT   s.cbancar, s.ctipban, s.cagente, s.cempres
          FROM seguros s, tomadores t
         WHERE s.sseguro = t.sseguro
           AND t.sperson = psperson
           AND t.nordtom = 1
      ORDER BY fefecto DESC;

   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
BEGIN
   OPEN c_banc;

   FETCH c_banc
    INTO pcbancar, pctipban, vagente_poliza, vcempres;

   CLOSE c_banc;

   IF pcbancar IS NULL THEN
      BEGIN
         SELECT c.cbancar, c.ctipban
           INTO pcbancar, pctipban
           FROM per_personas p, per_ccc c
          WHERE p.sperson = psperson
            AND p.sperson = c.sperson
            AND c.cagente = ff_agente_cpervisio(vagente_poliza, f_sysdate, vcempres);
      EXCEPTION
         WHEN OTHERS THEN
            pcbancar := NULL;
            pctipban := NULL;
      END;
   /*SELECT cbancar, ctipban
     INTO pcbancar, pctipban
     FROM personas
    WHERE sperson = psperson;*/

   -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
   END IF;

   RETURN(0);
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 100534;   --Persona inexistent
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_BUSCARCCC" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BUSCARCCC" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BUSCARCCC" TO "PROGRAMADORESCSI";
