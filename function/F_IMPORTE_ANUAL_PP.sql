--------------------------------------------------------
--  DDL for Function F_IMPORTE_ANUAL_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_IMPORTE_ANUAL_PP" (psseguro IN NUMBER, pano IN NUMBER)
   RETURN NUMBER IS
   impctaseguro   NUMBER(25, 10);
   impotramoneda  NUMBER(25, 10);
   importeanual   NUMBER(25, 10);
   importeanualotra NUMBER(25, 10);
   estado         NUMBER;
   persona        NUMBER;
BEGIN
   --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
   --*** BUscamos el estado de la persona.
   SELECT p.cestper, r.sperson
     INTO estado, persona
     FROM per_personas p, riesgos r, seguros s
    WHERE s.sseguro = psseguro
      AND s.sseguro = r.sseguro
      AND r.sperson = p.sperson
      AND r.fanulac IS NULL;

   /*--*** BUscamos el estado de la persona.
   SELECT cestado, riesgos.sperson
     INTO estado, persona
     FROM personas, riesgos, seguros
    WHERE seguros.sseguro = psseguro
      AND seguros.sseguro = riesgos.sseguro
      AND riesgos.sperson = personas.sperson
      AND riesgos.fanulac IS NULL;*/

   --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)

   --DBMS_OUTPUT.put_line('ENTRAMOS');

   -- *** Bucamos el total de los movimientos realizados este año
   SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi, 49, -imovimi, 51, -imovimi), 0))
     INTO impctaseguro
     FROM riesgos, ctaseguro, seguros, productos
    WHERE ctaseguro.sseguro = riesgos.sseguro
      AND riesgos.sperson = persona
      AND seguros.cramo = productos.cramo
      AND seguros.cmodali = productos.cmodali
      AND seguros.ctipseg = productos.ctipseg
      AND seguros.ccolect = productos.ccolect
      AND seguros.sseguro = riesgos.sseguro
      AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
      AND seguros.csituac = 0
      AND productos.cagrpro = 11
      AND riesgos.spermin IS NULL;

   -- *** Buscamos si también hicimos alguna entrada este año
   BEGIN
      SELECT SUM(NVL(iimpanu, 0))
        INTO importeanual
        FROM trasplainout, riesgos, ctaseguro, seguros, productos
       WHERE cinout = 1
         AND trasplainout.cestado IN(3, 4)
         AND ctaseguro.sseguro = trasplainout.sseguro
         AND ctaseguro.nnumlin = trasplainout.nnumlin
         AND seguros.sseguro = riesgos.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND productos.cagrpro = 11
         AND TO_DATE(TO_CHAR(pano, '0000'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND seguros.csituac = 0
         AND trasplainout.sseguro = riesgos.sseguro
         AND riesgos.sperson = persona;
   EXCEPTION
      WHEN OTHERS THEN
         importeanual := 0;
   END;

   RETURN(NVL(importeanual, 0) + NVL(impctaseguro, 0));
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_IMPORTE_ANUAL_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_IMPORTE_ANUAL_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_IMPORTE_ANUAL_PP" TO "PROGRAMADORESCSI";
