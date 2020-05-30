--------------------------------------------------------
--  DDL for Function F_RECDTO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_RECDTO" (
   psobrep IN NUMBER,
   ppdtocom IN NUMBER,
   pirecarg IN OUT NUMBER,
   pidtocom IN OUT NUMBER,
   -- Ini Bug 21907 - MDS - 24/04/2012
   ppdtotec IN NUMBER,
   ppreccom IN NUMBER,
   pidtotec IN OUT NUMBER,
   pireccom IN OUT NUMBER,
   -- Fin Bug 21907 - MDS - 24/04/2012
   piextrap IN NUMBER,
   picapital IN NUMBER,
   piiextrap OUT NUMBER,
   piprima IN OUT NUMBER,
   moneda IN NUMBER,
   paplica_bonifica IN NUMBER DEFAULT 0,
   piprima_bonif IN NUMBER DEFAULT 0,
   pdtocomercial IN NUMBER DEFAULT 0,   -- Bug 24704 - RSC - 17/12/2013
   preccomercial IN NUMBER DEFAULT 0,   -- Bug 24704 - RSC - 17/12/2013
   psproduc IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/*************************************************************************
   F_RECDTO    Calcula la prima anual de una garantía aplicant-li
            els descomptes i recàrrecs corresponents
            Retorna 0 si todo va bien, 1 sino
   ALLIBCTR
   Modificacions: Afegim la moneda
   Modificacions: El descomptes són percentatges
        NP - Afegim el paràmetre prima mínima anterior per el càcul de
             la bonificació per no siniestralitat i si s'aplica o no
*************************************************************************/
   lprimadesc     NUMBER;   -- Prima a la que s'aplica el percentatge de descompte
   piprima2       NUMBER;   -- Bug 21907 - MDS - 24/04/2012
   v_aplica_dto_extr_sobr NUMBER;   --BUG POSITIVA 33494 - 01/12/2014 - DCT
   num_err        NUMBER;
BEGIN
   -- Si el producte té bonificació, s'ha de calcular el descompte a partir
   -- de la prima de l'anterior anualitat
   IF NVL(paplica_bonifica, 0) = 1 THEN
      lprimadesc := piprima_bonif;
   ELSE
      lprimadesc := piprima;
   END IF;

   -- Cal veure si el producte aplica descompte a les extraprima i sobreprima
   IF NVL(pac_parametros.f_parproducto_n(psproduc, 'APLICA_DTO_EXTR_SOBR'), 0) = 1 THEN
      piprima2 := piprima;
      -- Arrodonim a partir de la moneda
      pirecarg := f_round(piprima * NVL(psobrep, 0) / 100, moneda);
      piprima := piprima + pirecarg;
      lprimadesc := lprimadesc + pirecarg;
      piiextrap := f_round(picapital * NVL(piextrap, 0), moneda);
      piprima := piprima + NVL(piiextrap, 0);
      lprimadesc := lprimadesc + NVL(piiextrap, 0);
      pidtocom := f_round(0 -(lprimadesc * NVL(ppdtocom, 0) / 100), moneda);
      piprima := piprima + pidtocom;
      lprimadesc := lprimadesc + pidtocom;
      pireccom := f_round(piprima2 * NVL(ppreccom, 0) / 100, moneda);
      pidtotec := f_round(0 -(lprimadesc * NVL(ppdtotec, 0) / 100), moneda);
      piprima := piprima + pidtotec;
      piprima := piprima + pireccom;
      piprima := piprima *(1 -(NVL(pdtocomercial, 0) / 100) +(NVL(preccomercial, 0) / 100));
   ELSE
      -- Bug 21907 - MDS - 24/04/2012
      -- guardar el valor original de piprima
      piprima2 := piprima;
      -- Arrodonim a partir de la moneda
      pirecarg := f_round(piprima * NVL(psobrep, 0) / 100, moneda);
      pidtocom := f_round(0 -(lprimadesc * NVL(ppdtocom, 0) / 100), moneda);
      piprima := piprima + pirecarg;
      piprima := piprima + pidtocom;
      -- BUG19532:DRA:26/09/2011:Inici
      piiextrap := f_round(picapital * NVL(piextrap, 0), moneda);
      piprima := piprima + NVL(piiextrap, 0);
      -- BUG19532:DRA:26/09/2011:Fi

      -- Ini Bug 21907 - MDS - 24/04/2012
      -- Bug 26419 - APD .- 21/05/2013
      --pidtotec := f_round(piprima2 * NVL(pidtotec, 0) / 100, moneda);
      --pireccom := f_round(0 -(lprimadesc * NVL(pireccom, 0) / 100), moneda);
      pireccom := f_round(piprima2 * NVL(ppreccom, 0) / 100, moneda);
      pidtotec := f_round(0 -(lprimadesc * NVL(ppdtotec, 0) / 100), moneda);
      -- fin Bug 26419 - APD .- 21/05/2013
      piprima := piprima + pidtotec;
      piprima := piprima + pireccom;
      -- Fin Bug 21907 - MDS - 24/04/2012

      -- Bug 24704 - RSC - 17/12/2013
      -- Liberty necesita aplicar un descuento/recargo comercial sobre la prima anual y con los descuentos y recargos por fumador/examen médico,
      -- Extraprima y sobreprimas ya aplicados. Para no modificar toda la formulación de los productos de VI ya que aplicar lo que están pidiendo
      -- implicaría rehacer todas las fórmulas de VI y utilizar el detalle de primas se ha optado por esta solución sencilla aunque algo particular
      -- de Liberty. Esta solución no influye en ningún cliente/producto que no tenga la pregunta de descuento (4942) y recargo comercial (4945) y en su caso
      -- si algun producto las tuviese actuarian como sigue
      piprima := piprima *(1 -(NVL(pdtocomercial, 0) / 100) +(NVL(preccomercial, 0) / 100));
   -- Fin bug 24704
   END IF;

   RETURN 0;
END;

/

  GRANT EXECUTE ON "AXIS"."F_RECDTO" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."F_RECDTO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_RECDTO" TO "CONF_DWH";
