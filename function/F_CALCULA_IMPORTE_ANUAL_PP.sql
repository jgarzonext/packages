--------------------------------------------------------
--  DDL for Function F_CALCULA_IMPORTE_ANUAL_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALCULA_IMPORTE_ANUAL_PP" (
   psperson IN NUMBER,
   pano IN NUMBER,
   psseguro IN NUMBER,
   ptipapor IN VARCHAR2 DEFAULT NULL)
   RETURN NUMBER IS
   -- El campo ptipapor: 'P' -- Indicia que es que calculemos las aportaciones del promotor
   -- enviando también el psseguro
   impctaseguro   NUMBER(25, 10);
   impotramoneda  NUMBER(25, 10);
   importeanual   NUMBER(25, 10);
   importeanualotra NUMBER(25, 10);
   estado         NUMBER;
   nacimiento     DATE;
   permin         NUMBER;
   persona        NUMBER;
BEGIN
   -- Si nos informa el seguro vamos a mirar si es de minusvalidos
   IF psseguro IS NOT NULL THEN
      --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      SELECT p.fnacimi, spermin, p.sperson
        INTO nacimiento, permin, persona
        FROM seguros, riesgos, per_personas p, per_detper d
       WHERE seguros.sseguro = riesgos.sseguro
         AND seguros.sseguro = psseguro
         AND p.sperson = riesgos.sperson
         AND d.sperson = p.sperson
         AND d.cagente = ff_agente_cpervisio(seguros.cagente, f_sysdate, seguros.cempres);

      /*SELECT personas.fnacimi, spermin, personas.sperson
        INTO nacimiento, permin, persona
        FROM seguros, riesgos, personas
       WHERE seguros.sseguro = riesgos.sseguro
         AND seguros.sseguro = psseguro
         AND personas.sperson = riesgos.sperson;*/

      --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      IF permin IS NULL
         AND ptipapor IS NULL THEN   ---> Es un contrato normal
         estado := 1;
      ELSIF permin IS NOT NULL
            AND permin = persona THEN   --> El partícipe es el minusvalido.
         estado := 2;
      ELSIF permin IS NOT NULL
            AND permin <> persona THEN   --> Es una aportante al minusválido.
         estado := 3;
      ELSIF permin IS NULL
            AND ptipapor = 'P' THEN   --> Es el promotor
         estado := 4;
      END IF;
   END IF;

   IF estado = 1 THEN   -- Aportante normal
      -- *** Bucamos el total de los movimientos realizados este año
      SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi), 0))
        INTO impctaseguro
        FROM riesgos, ctaseguro, seguros, productos
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND seguros.sseguro = riesgos.sseguro
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND ctaseguro.cmovanu = 0
         --AND PRODUCTOS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         AND riesgos.sperson = persona
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
            --AND PRODUCTOS.CAGRPRO = 11
            AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
            AND TO_DATE(TO_CHAR(pano, '0000'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
            AND seguros.csituac = 0
            AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
            AND trasplainout.sseguro = riesgos.sseguro
            AND riesgos.sperson = psperson
            AND riesgos.spermin IS NULL;
      EXCEPTION
         WHEN OTHERS THEN
            importeanual := 0;
      END;

      RETURN(NVL(importeanual, 0) + NVL(impctaseguro, 0));
   ELSIF estado IN(2) THEN   --> El partícipe es el minusvalido
      -- *** Bucamos el total de los movimientos realizados este año
      SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi), 0))
        INTO impctaseguro
        FROM riesgos, ctaseguro, seguros, productos
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND seguros.sseguro = riesgos.sseguro
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND ctaseguro.cmovanu = 0
         --AND PRODUCTOS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         --  AND riesgos.sperson = psperson
         AND riesgos.spermin = permin;

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
            --AND PRODUCTOS.CAGRPRO = 11
            AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
            AND TO_DATE(TO_CHAR(pano, '0000'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
            AND seguros.csituac = 0
            AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
            AND trasplainout.sseguro = riesgos.sseguro
            -- AND riesgos.sperson = psperson
            AND riesgos.spermin = permin;
      EXCEPTION
         WHEN OTHERS THEN
            importeanual := 0;
      END;

      RETURN(NVL(importeanual, 0) + NVL(impctaseguro, 0));
   ELSIF estado IN(3) THEN   --> El participe es el aportante al minusvalido
      -- *** Bucamos el total de los movimientos realizados este año
      SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi), 0))
        INTO impctaseguro
        FROM riesgos, ctaseguro, seguros, productos
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND seguros.sseguro = riesgos.sseguro
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND ctaseguro.cmovanu = 0
         --AND PRODUCTOS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         AND riesgos.sperson = psperson
         AND riesgos.spermin = permin;

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
            --AND PRODUCTOS.CAGRPRO = 11
            AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
            AND TO_DATE(TO_CHAR(pano, '0000'), 'YYYY') =
                                                      TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
            AND seguros.csituac = 0
            AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
            AND trasplainout.sseguro = riesgos.sseguro
            AND riesgos.sperson = psperson
            AND riesgos.spermin = permin;
      EXCEPTION
         WHEN OTHERS THEN
            importeanual := 0;
      END;

      RETURN(NVL(importeanual, 0) + NVL(impctaseguro, 0));
   ELSIF estado = 4 THEN   --> Aportaciones del promotor.
      SELECT SUM(NVL(DECODE(cmovimi, 1, imovimi, 2, imovimi), 0))
        INTO impctaseguro
        FROM riesgos, ctaseguro, seguros, productos
       WHERE ctaseguro.sseguro = riesgos.sseguro
         AND ctaseguro.spermin IS NOT NULL
         AND seguros.cramo = productos.cramo
         AND seguros.cmodali = productos.cmodali
         AND seguros.ctipseg = productos.ctipseg
         AND seguros.ccolect = productos.ccolect
         AND seguros.sseguro = riesgos.sseguro
         AND TO_DATE(TO_CHAR(pano, '9999'), 'YYYY') = TO_DATE(TO_CHAR(fvalmov, 'yyyy'), 'YYYY')
         AND ctaseguro.cmovanu = 0
         --AND PRODUCTOS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         AND seguros.sseguro = psseguro;

      RETURN NVL(impctaseguro, 0);
   END IF;

   RETURN -2;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_CALCULA_IMPORTE_ANUAL_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALCULA_IMPORTE_ANUAL_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALCULA_IMPORTE_ANUAL_PP" TO "PROGRAMADORESCSI";
