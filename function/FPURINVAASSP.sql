--------------------------------------------------------
--  DDL for Function FPURINVAASSP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FPURINVAASSP" (
   nsesion IN NUMBER,
   pperson IN NUMBER,
   pseguro IN NUMBER,
   ppinttec IN NUMBER,
   pfecven IN NUMBER,
   pcforamor IN NUMBER,
   pncaren IN NUMBER,
   pfefecto IN NUMBER,
   pfefmes IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE: FPURINVAASSP
   DESCRIPCION:  Prima Pura Invalidez del ASSP.
   INPUT: NSESION(number) --> Nro. de sesión del evaluador de fórmulas
   RETORNA VALUE:
          NUMBER------------>
******************************************************************************/
   valor          NUMBER;
   xfvencim       DATE;
   xfefmes        DATE;
   xfefecto       DATE;
   xxfnacimi      DATE;
   pfecha         DATE;
   pfecha1        DATE;
   xany           NUMBER;
   xyymm          NUMBER;
   xxn            NUMBER;
   wa             NUMBER;
   xxedad         NUMBER;
   xxsexo         NUMBER;
   xix            NUMBER;
   xtpx           NUMBER;
   xiy            NUMBER;
   xtpy           NUMBER;
   xxcap1         NUMBER;
   xxcap2         NUMBER;
   xxcapital      NUMBER;
   valor1         NUMBER;
   xcont          NUMBER;
   vagente_poliza seguros.cagente%TYPE;
   vcempres       seguros.cempres%TYPE;
BEGIN
   valor := NULL;
   xfvencim := TO_DATE(pfecven, 'yyyymmdd');
   xfefecto := TO_DATE(pfefecto, 'yyyymmdd');
   xfefmes := TO_DATE(pfefmes, 'yyyymmdd');
   wa := f_difdata(xfefmes, xfvencim, 2, 1, xxn);

   BEGIN
      -- Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      --Conseguimos el vagente_poliza y la empresa de la póliza a partir del psseguro
      SELECT p.fnacimi, p.csexper
        INTO xxfnacimi, xxsexo
        FROM per_personas p
       WHERE p.sperson = pperson;

      /*SELECT fnacimi, csexper
        INTO xxfnacimi, xxsexo
        FROM personas
       WHERE sperson = pperson;*/

      -- FI Bug10612 - 06/07/2009 - DCT (Canviar vista personas por tablas personas y añadir filtro de visión de agente)
      wa := f_difdata(xxfnacimi, xfefmes, 2, 1, xxedad);
      xxedad := xxedad + pncaren;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END;

   BEGIN
      valor := 0;
      xcont := 0;

      FOR i IN 1 .. xxn LOOP
         IF i = 1 THEN
            pfecha := xfefecto;
            pfecha1 := ADD_MONTHS(xfefecto, pcforamor);
         ELSE
            pfecha := ADD_MONTHS(pfecha1, 1);
            pfecha1 := ADD_MONTHS(pfecha,(pcforamor - 1));
         END IF;

         xxcap1 := pk_cuadro_amortizacion.capital_pendiente(pseguro, xfefecto, pfecha);
         xxcap2 := pk_cuadro_amortizacion.capital_pendiente(pseguro, xfefecto, pfecha1);
         xxcapital := (xxcap1 + xxcap2) / 2;

         BEGIN
            SELECT ix, iy, tpxa, tpya
              INTO xix, xiy, xtpx, xtpy
              FROM simbolconmu
             WHERE pinttec = ppinttec
               AND ctabla = 1
               AND nedad = xxedad;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 0;
         END;

         IF xxsexo = 1 THEN   -- Es hombre
            valor1 := (xix * xtpx * xxcapital) * POWER((1 + ppinttec),(xcont * -1));
            valor := valor + (xix * xtpx * xxcapital) * POWER((1 + ppinttec),(xcont * -1));
         ELSE   -- Es mujer
            valor1 := (xiy * xtpy * xxcapital) * POWER((1 + ppinttec),(xcont * -1));
            valor := valor + (xiy * xtpy * xxcapital) * POWER((1 + ppinttec),(xcont * -1));
         END IF;

         xxedad := xxedad + 1;
         xcont := xcont + 1;
      END LOOP;

      RETURN valor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 0;
   END;
END fpurinvaassp;
 
 

/

  GRANT EXECUTE ON "AXIS"."FPURINVAASSP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FPURINVAASSP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FPURINVAASSP" TO "PROGRAMADORESCSI";
