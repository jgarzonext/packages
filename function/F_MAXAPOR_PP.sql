--------------------------------------------------------
--  DDL for Function F_MAXAPOR_PP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_MAXAPOR_PP" (
   psperson IN NUMBER,
   panyo IN NUMBER,
   psseguro IN NUMBER DEFAULT NULL,
   ptipmin IN NUMBER DEFAULT NULL,
   pspermin IN NUMBER DEFAULT NULL)
   RETURN NUMBER IS
/***********************************************************************************************************************************
  -- Devuelve el importe maximo que puede realizar de aportaciones durante el año.

  -- Parametro PTIPMIN se utliza para el terminal financiero , ya que antes de hacer el alta
  --                                        de contratos no sabemos el sseguro y necesitamos saber si el
  --                                  partícipe es normal ( 1 o nulo ) , minusválido ( 2 ) o aportante ( 3 )
  -- Parámetro PSPERMIN se utiliza unicamente si el PTIPMIN = 3 y contiene el sperson
  --                                                 de la persona minusvalida que se va a dar de alta.

    18-7-2006. Se tienen en cuenta también las pólizas anuladas con aprotaciones en el año
                        Se cambia cagrpro = 11 por parproducto 'APORTMAXIMAS'
                   En el tipo aportante = 1 se suman también las aportaciones del promotor (ctaseguro.spermin )
  ********************************************************************************************************************************/
   estado         NUMBER;
   impctaseguro   NUMBER;
   importe_anual  NUMBER;
   importe_maximo NUMBER;
   edad           NUMBER;
   error          NUMBER;
   nacimiento     DATE;
   permin         NUMBER;
   persona        NUMBER;
   fin_anyo       DATE;
BEGIN
   -- Si nos informa el seguro vamos a mirar si es de minusvalidos
   IF psseguro IS NOT NULL THEN
      --Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      SELECT p.fnacimi, spermin, p.sperson
        INTO nacimiento, permin, persona
        FROM seguros, riesgos, per_personas p
       WHERE seguros.sseguro = riesgos.sseguro
         AND seguros.sseguro = psseguro
         AND p.sperson = riesgos.sperson;

      /*SELECT personas.fnacimi, spermin, personas.sperson
        INTO nacimiento, permin, persona
        FROM seguros, riesgos, personas
       WHERE seguros.sseguro = riesgos.sseguro
         AND seguros.sseguro = psseguro
         AND personas.sperson = riesgos.sperson;*/

      --FI Bug10612 - 07/07/2009 - DCT (canviar vista personas)
      IF permin IS NULL THEN   ---> Es un contrato normal
         estado := 1;
      ELSIF permin IS NOT NULL
            AND permin = persona THEN   --> El partícipe es el minusvalido.
         estado := 2;
      ELSIF permin IS NOT NULL
            AND permin <> persona THEN   --> Es una aportante al minusválido.
         estado := 3;
      END IF;
   ELSE
      SELECT fnacimi, 1
        INTO nacimiento, estado
        FROM personas
       WHERE personas.sperson = psperson;
   -- NACIMIENTO := TO_DATE('01/01/' || TO_CHAR(NACIMIENTO,'YYYY'),'DD/MM/YYYY');
   END IF;

   IF ptipmin IS NOT NULL THEN
      estado := ptipmin;

      IF ptipmin = 2 THEN   --> Si en alta de TF es el minusvalido le decimos que el permin es el minusvalido.
         permin := psperson;
      ELSIF ptipmin = 3 THEN   --> En el alta de TF el minusvalido es el campo PSPERMIN
         permin := pspermin;
      END IF;
   END IF;

   -- edad de la persona a final de año
   fin_anyo := TO_DATE('3112' || panyo, 'ddmmyyyy');
   error := f_difdata(nacimiento, fin_anyo, 1, 1, edad);

   --DBMS_OUTPUT.put_line('EDAD f_maxapor: ' || edad);
   IF error <> 0 THEN
      RETURN -1;   --> Fallo en el calculo de la edad;
   END IF;

   -- Maximo a aportar anualmente en función de la edad y el tipo ( 2-Inválido )
   SELECT iimporte
     INTO importe_maximo
     FROM planedades
    WHERE ntipo = estado
      AND nano = panyo
      AND edad BETWEEN nedadini AND nedadfin;

   IF estado = 1 THEN   -- Aportante normal
      -- Aportaciones realizadas durante el año por el partícipe
      SELECT SUM(NVL(imovimi, 0))
        INTO impctaseguro
        FROM ctaseguro, seguros, riesgos
       WHERE cmovimi IN(1, 2)
         AND seguros.sseguro = ctaseguro.sseguro
         --  AND SEGUROS.CSITUAC = 0 --también las anuladas si tienen movimientos en este año
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo)
         --AND SEGUROS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
--               AND ( CTASEGURO.SPERMIN IS NULL OR CTASEGURO.CTIPAPOR = 'V' )
--                      AND (CTASEGURO.CTIPAPOR <> 'SP' OR CTASEGURO.CTIPAPOR IS NULL)
         AND(NVL(ctaseguro.ctipapor, 'X') <> 'SP')
         AND seguros.sseguro = riesgos.sseguro
         AND riesgos.fanulac IS NULL
         AND riesgos.sperson = psperson
         AND riesgos.spermin IS NULL
         AND cmovanu <> 1;

      -- Aportaciones realizadas por el participe en otro plan durante al año.
      SELECT SUM(NVL(trasplainout.iimpanu, 0))
        INTO importe_anual
        FROM ctaseguro, trasplainout, riesgos
       WHERE cinout = 1
         AND trasplainout.cestado IN(3, 4)
         AND trasplainout.sseguro = riesgos.sseguro
         AND riesgos.sperson = psperson
         AND riesgos.fanulac IS NULL
         AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
         AND trasplainout.sseguro = ctaseguro.sseguro
         AND trasplainout.nnumlin = ctaseguro.nnumlin
         AND riesgos.spermin IS NULL
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo);

      importe_anual := NVL(importe_anual, 0) + NVL(impctaseguro, 0);

      -- Maximo a aportar anualmente en función de la edad y el tipo ( 1-Normal )
      SELECT iimporte
        INTO importe_maximo
        FROM planedades
       WHERE ntipo = 1
         AND nano = panyo
         AND edad BETWEEN nedadini AND nedadfin;

      -- Devuelve el importe que le queda por aportar maximo.
      RETURN(NVL(importe_maximo, 0) - NVL(importe_anual, 0));
   ELSIF estado IN(2) THEN   -----------------> El partícipe es el mINUSVALIDO**********
      -- Aportaciones realizadas durante el año por el partícipe minusválido
      SELECT SUM(NVL(imovimi, 0))
        INTO impctaseguro
        FROM ctaseguro, seguros, riesgos
       WHERE cmovimi IN(1, 2)
         AND seguros.sseguro = ctaseguro.sseguro
         -- AND SEGUROS.CSITUAC = 0
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo)
         --AND SEGUROS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         AND(ctaseguro.ctipapor <> 'SP'
             OR ctaseguro.ctipapor IS NULL)
         --  AND CTASEGURO.SPERMIN IS NULL
         AND seguros.sseguro = riesgos.sseguro
         AND riesgos.fanulac IS NULL
         AND riesgos.spermin = permin
         --   AND RIESGOS.SPERSON = PSPERSON
         AND cmovanu <> 1;

      -- Aportaciones realizadas por el participe en otro plan durante al año.
      SELECT SUM(NVL(trasplainout.iimpanu, 0))
        INTO importe_anual
        FROM ctaseguro, trasplainout, riesgos
       WHERE cinout = 1
         AND trasplainout.cestado IN(3, 4)
         AND trasplainout.sseguro = riesgos.sseguro
         -- AND RIESGOS.SPERSON = PSPERSON
         AND riesgos.spermin = permin
         AND riesgos.fanulac IS NULL
         AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
         AND trasplainout.sseguro = ctaseguro.sseguro
         AND trasplainout.nnumlin = ctaseguro.nnumlin
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo);

      importe_anual := NVL(importe_anual, 0) + NVL(impctaseguro, 0);
      -- Devuelve el importe que le queda por aportar maximo.
      RETURN(NVL(importe_maximo, 0) - NVL(importe_anual, 0));
   ELSIF estado IN(3) THEN   -----------------> El partícipe es aportante al minusvalido **********
      -- Aportaciones realizadas durante el año por el partícipe minusválido
      SELECT SUM(NVL(imovimi, 0))
        INTO impctaseguro
        FROM ctaseguro, seguros, riesgos
       WHERE cmovimi IN(1, 2)
         AND seguros.sseguro = ctaseguro.sseguro
         --  AND SEGUROS.CSITUAC = 0
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo)
         -- AND SEGUROS.CAGRPRO = 11
         AND NVL(f_parproductos_v(seguros.sproduc, 'APORTMAXIMAS'), 0) = 1
         AND(ctaseguro.ctipapor <> 'SP'
             OR ctaseguro.ctipapor IS NULL)
         -- AND CTASEGURO.SPERMIN IS NULL
         AND seguros.sseguro = riesgos.sseguro
         AND riesgos.fanulac IS NULL
         AND riesgos.spermin = permin
         AND riesgos.sperson = psperson
         AND cmovanu <> 1;

      -- Aportaciones realizadas por el participe en otro plan durante al año.
      SELECT SUM(NVL(trasplainout.iimpanu, 0))
        INTO importe_anual
        FROM ctaseguro, riesgos, trasplainout
       WHERE cinout = 1
         AND trasplainout.cestado IN(3, 4)
         AND trasplainout.sseguro = riesgos.sseguro
         AND riesgos.sperson = psperson
         AND riesgos.spermin = permin
         AND riesgos.fanulac IS NULL
         AND trasplainout.cexterno = 1   -- jgm - BUG 10124 - PONÍA 'E'
         AND trasplainout.sseguro = ctaseguro.sseguro
         AND trasplainout.nnumlin = ctaseguro.nnumlin
         AND TO_CHAR(fvalmov, 'YYYY') = TO_CHAR(panyo);

      importe_anual := NVL(importe_anual, 0) + NVL(impctaseguro, 0);
      -- Devuelve el importe que le queda por aportar maximo.
      RETURN(NVL(importe_maximo, 0) - NVL(importe_anual, 0));
   END IF;

   RETURN -2;   --> fALTA DESARROLLAR OTROS TIPO DE APROTANTES.
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('fallo desconocido' || SQLERRM);
      RETURN -99;   --> Fallo desconocido;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_MAXAPOR_PP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_MAXAPOR_PP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_MAXAPOR_PP" TO "PROGRAMADORESCSI";
