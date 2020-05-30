--------------------------------------------------------
--  DDL for Function F_PRIMA_MINIMA_EXTORN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_PRIMA_MINIMA_EXTORN" (
   psseguro IN NUMBER,
   pnrecibo IN NUMBER,
   pcestrec IN NUMBER,
   pfvalmov IN DATE,
   pccobban IN NUMBER,
   pcmotmov IN NUMBER,
   pcagente IN NUMBER,
   pfmovini DATE,
   sproduc NUMBER DEFAULT NULL,
   pmodo VARCHAR2 DEFAULT 'R')   --Bug 27057/0145439 - APD - 04/06/2013 - se añade el parametro
   RETURN NUMBER AUTHID CURRENT_USER IS
--*********************************************************************************
--*********************************************************************************
--***                                                                                                                                   ***
--***  Función :  F_PRIMA_MINIMA                                                                                ***
--***  Funcion de prima mínima d'extorn
--***                                                                 ***
--***  Parámetros:                                                                                              ***
--***              Psseguro  : Id de la póliza                                                          ***
--***     PnRecibo  : Id de recibo                                                                              ***
--***     PnCestRec : Estat del rebut                                                                           ***
--***     PFvalmov  : Data validació moviment                                                           ***
--***     PFmovimi  : Data moviment                                                                             ***
--***     PnCCobban :                                                                                                   ***
--***     PnDelega  : Codi delagació                                                                            ***
--***     Pcmotmov  : Codi motiu moviment                                                               ***
--***     PcAgente  : Codi de agente                                                                            ***
--***     Sproduc  : Codi de producte                                                                           ***
--***  Valor de retorno:                                                                                                ***
--***                                                                                                                   ***
--*********************************************************************************
--*********************************************************************************
   xsproduc       NUMBER;
   ximinext       NUMBER;
   xnum_err       NUMBER;
   xiprinet       NUMBER;
   xcdelega       NUMBER;
   dummy1         NUMBER;
   dummy2         NUMBER;
   dummy3         NUMBER;
   lctiprec       NUMBER;
   xcempres       recibos.cempres%TYPE;   -- Bug 27057/0145439 - APD - 04/06/2013
BEGIN
   BEGIN
      -- Bug 27057/0145439 - APD - 04/06/2013 - se añade cempres
      SELECT ctiprec, cempres
        INTO lctiprec, xcempres
        FROM recibos
       WHERE nrecibo = pnrecibo;

      -- fin Bug 27057/0145439 - APD - 04/06/2013

      -- Si no és un extorn, no te sentit mirar la prima mínima
      IF lctiprec <> 9 THEN
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 102367;
   END;

   IF sproduc IS NULL THEN
      --Trobem nosaltres el codi de producte
      BEGIN
         SELECT sproduc
           INTO xsproduc
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         --error numero de seguro no valido
         WHEN NO_DATA_FOUND THEN
            RETURN 101903;
      END;
   ELSE
      xsproduc := sproduc;
   END IF;

   BEGIN
      --trobem el import mínim del extorn
      SELECT NVL(iminext, 0)
        INTO ximinext
        FROM productos
       WHERE sproduc = xsproduc;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;
   END;

   BEGIN
      --trobem la prima neta del rebut
      --SELECT NVL(iprinet, 0)
      SELECT NVL(itotalr, 0) -- BUG 0041429 - FAL - 06/04/2016 - Recuperar el total del recibo para comparar con la prima minima de extorno
        INTO xiprinet
        FROM vdetrecibos
       WHERE nrecibo = pnrecibo;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 103936;
   END;

   IF xiprinet < ximinext THEN
      -- Bug 27057/0145439 - APD - 04/06/2013 -  si 'TRATAR_PRIMA_MIN_EXT' = 2 se borra el recibo
      -- de extorno
      IF NVL(pac_parametros.f_parempresa_n(xcempres, 'TRATAR_PRIMA_MIN_EXT'), 1) = 2 THEN
         xnum_err := pac_gestion_rec.f_borra_recibo(pnrecibo, pmodo);

         IF xnum_err <> 0 THEN
            RETURN xnum_err;
         END IF;
      ELSE
         -- fin Bug 27057/0145439 - APD - 04/06/2013
            --trobem la delegació
         xcdelega := f_delega(psseguro, pfmovini);
         --anul·lacio del rebut per que no arriba al mínim.
         dummy2 := 0;
         dummy1 := 0;
         dummy3 := 0;
         xnum_err := f_movrecibo(pnrecibo, pcestrec, pfvalmov, 0, dummy1, dummy2, dummy3,
                                 pfmovini, pccobban, xcdelega, 7, pcagente);

         IF xnum_err <> 0 THEN
            RETURN xnum_err;
         END IF;

         -- Retrocedir les cessions generades per l'anul.lació de rebut
         xnum_err := pac_cesionesrea.f_borra_cesdet_anu(pnrecibo);

         IF xnum_err <> 0 THEN
            RETURN xnum_err;
         END IF;
      END IF;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      RETURN 111097;
END;

/

  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA_EXTORN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA_EXTORN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_PRIMA_MINIMA_EXTORN" TO "PROGRAMADORESCSI";
