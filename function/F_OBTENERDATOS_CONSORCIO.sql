--------------------------------------------------------
--  DDL for Function F_OBTENERDATOS_CONSORCIO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_OBTENERDATOS_CONSORCIO" (
   pmode              IN       VARCHAR2,
   psseguro           IN       NUMBER,
   pnmovimi           IN       NUMBER,
   pfefecto           IN       DATE,
   pcforpag           IN       NUMBER,
   pcmotmov           IN       NUMBER,
   pcprorra           IN       NUMBER,
   vffinrec           OUT      DATE,
   vtipo_movimiento   OUT      NUMBER,
   valtarisc          OUT      BOOLEAN,
   vcapieve           OUT      NUMBER,
   vfacconsor         OUT      NUMBER
)
   RETURN NUMBER
IS

   xnpoliza      SEGUROS.NPOLIZA%TYPE;
   xndurcob      SEGUROS.NDURCOB%TYPE;
   xfvencim      DATE;
   xfcaranu      DATE;
   xffinrec      DATE;
   xffinany      DATE;
   fanyoprox     DATE;
   xnmeses       NUMBER;
   xcmodulo      NUMBER;
   difdias       NUMBER;
   difdiasanu    NUMBER;
   difdias2      NUMBER;
   difdiasanu2   NUMBER;
   divisor       NUMBER;
   divisor2      NUMBER;
   facnet        NUMBER;
   facdev        NUMBER;
   facnetsup     NUMBER;
   facdevsup     NUMBER;
   xsproduc      NUMBER;
   xnrenova      NUMBER;
   xpro_np_360   VARCHAR2(200);
   error         NUMBER;
BEGIN

-- Nota LPS (06/10/2008), se ha hecho esta función para calcular el consorcio para la tarificación del
-- nuevo módulo de impuestos. Por ahora no se tiene en cuenta el cmotmov (no se le pasa a la función),
-- para el calculo del capital eventual o regularizaciones. Esto quedaría pendiente para cuando haya
-- productos con estos conceptos.


   IF pmode = 'EST'
   THEN
      SELECT e.fvencim, e.fcaranu, e.npoliza, e.ndurcob, e.nrenova, p.sproduc
        INTO xfvencim, xfcaranu, xnpoliza, xndurcob, xnrenova, xsproduc
        FROM estseguros e, productos p
       WHERE e.cramo = p.cramo
            AND e.cmodali = p.cmodali
            AND e.ctipseg = p.ctipseg
            AND e.ccolect = p.ccolect
            AND e.sseguro = psseguro;
   ELSE
      SELECT s.fvencim,  s.fcaranu, s.npoliza, s.ndurcob, s.nrenova, p.sproduc
        INTO xfvencim, xfcaranu, xnpoliza, xndurcob, xnrenova, xsproduc
        FROM seguros s, productos p
       WHERE s.cramo = p.cramo
            AND s.cmodali = p.cmodali
            AND s.ctipseg = p.ctipseg
            AND s.ccolect = p.ccolect
            AND s.sseguro = psseguro;
   END IF;

   -- Se asigna valor a valtarisc.
   IF pcmotmov = 243
   THEN
      valtarisc := TRUE;
   ELSE
      valtarisc := FALSE;
   END IF;

   -- Se asigna valor a vtipo_movimiento.
   IF pnmovimi = 1
   THEN
      vtipo_movimiento := 0;                             -- Nueva producción.
   ELSIF pnmovimi > 1
   THEN
      vtipo_movimiento := 1;                                   -- Suplemento.
   END IF;

   -- Se asigna valor a vcapieve.
   IF vtipo_movimiento = 6 AND pcmotmov = 604
   THEN
      vcapieve := 1;
   END IF;

   -- Calculamos la fcaranu, si no está calculada (al tarifar no la calcula).
   IF xfcaranu IS NULL THEN
      error := PAC_CALC_COMU.F_CALCULA_FCARANU (xsproduc, pcforpag, pfefecto, xnrenova, xfcaranu);
   END IF;

   /******** Cálculo de los factores a aplicar para el prorrateo ********/

   -- Modificar valores según p_emitir_propuesta.
   xffinrec := NVL(xfvencim, xfcaranu);
   xffinany := xfcaranu;
   fanyoprox := ADD_MONTHS (pfefecto, 12);

   -- Para calcular el divisor del modulo 365 (365 o 366)
   IF pcforpag <> 0
   THEN
      IF xffinany IS NULL
      THEN
         IF xndurcob IS NULL
         THEN
            RETURN 104515;
         -- El camp ndurcob de SEGUROS ha de estar informat
         END IF;

         xnmeses := (xndurcob + 1) * 12;
         xffinany := ADD_MONTHS (pfefecto, xnmeses);

         IF xffinrec IS NULL
         THEN
            xffinrec := xffinany;
         END IF;
      END IF;
   ELSE
      xffinany := xffinrec;
   END IF;

   -- Cálculo de días
   IF pcprorra = 2
   THEN                                                            -- Mod. 360
      xcmodulo := 3;
   ELSE                                                            -- Mod. 365
      xcmodulo := 1;
   END IF;

   error := f_difdata (pfefecto, xffinrec, 3, 3, difdias);

   IF error <> 0
   THEN
      RETURN error;
   END IF;

   error := f_difdata (pfefecto, xffinany, 3, 3, difdiasanu);

   IF error <> 0
   THEN
      RETURN error;
   END IF;

   error := f_difdata (pfefecto, xffinrec, xcmodulo, 3, difdias2);

   -- dias recibo
   IF error <> 0
   THEN
      RETURN error;
   END IF;

   error := f_difdata (pfefecto, xffinany, xcmodulo, 3, difdiasanu2);

   -- dias venta
   IF error <> 0
   THEN
      RETURN error;
   END IF;

   error := f_difdata (pfefecto, fanyoprox, xcmodulo, 3, divisor2);

   -- divisor del módulo de suplementos para pagos anuales
   IF error <> 0
   THEN
      RETURN error;
   END IF;

   error := f_difdata (pfefecto, xffinrec, xcmodulo, 3, divisor);

   -- divisor del periodo para pago único
   IF error <> 0
   THEN
      RETURN error;
   END IF;

   -- Calculem els factors a aplicar per prorratejar
   -- També el factor per la reassegurança = diesrebut/dies cessio
   IF pcprorra IN (1, 2)
   THEN                                                            -- Per dies
      IF pcforpag <> 0
      THEN
         -- El càlcul del factor a la nova producció si s'ha de prorratejar, es fará modul 360 o
         -- mòdul 365 segon un paràmetre d'instal.lació
         xpro_np_360 := f_parinstalacion_n ('PRO_NP_360');

         IF NVL (xpro_np_360, 1) = 1
         THEN
            facnet := difdias / 360;
            facdev := difdiasanu / 360;
         ELSE
            IF MOD (difdias, 30) = 0
            THEN
               -- No hi ha prorrata
               facnet := difdias / 360;
               facdev := difdiasanu / 360;

               IF difdiasanu = 0
               THEN
                  difdiasanu := 360;
               END IF;
            --facces      :=  difdias / difdiasanu;
            ELSE
               -- Hi ha prorrata, prorratejem mòdul 365
               facnet := difdias2 / divisor2;
               facdev := difdiasanu2 / divisor2;
            END IF;
         END IF;

         facnetsup := difdias2 / divisor2;
         facdevsup := difdiasanu2 / divisor2;
      ELSE
         facnet := 1;
         facdev := 1;
         facnetsup := difdias2 / divisor;
         facdevsup := difdiasanu2 / divisor;
      END IF;
   ELSIF pcprorra = 3
   THEN
      BEGIN
         SELECT f1.npercen / 100
           INTO facnet
           FROM federaprimas f1
          WHERE f1.npoliza = xnpoliza
            AND f1.diames =
                   (SELECT MAX (f2.diames)
                      FROM federaprimas f2
                     WHERE f1.npoliza = f2.npoliza
                       AND f2.diames <= TO_CHAR (pfefecto, 'mm/dd'));
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 109086;
      -- Porcentajes de prorrateo no dados de alta para la póliza
      END;

      IF pcforpag <> 0
      THEN
         RETURN 109087;
      -- Tipo de prorrateo incompatible con la forma de pago
      ELSE
         facdev := facnet;
         facnetsup := facnet;
         facdevsup := facnet;
      END IF;
   ELSE
      RETURN 109085;                         -- Codi de prorrateig inexistent
   END IF;

   IF NVL (f_parinstalacion_n ('PRO_SP_360'), 0) = 1
   THEN
      facnetsup := facnet;
      facdevsup := facdev;
   END IF;

   -- nunu Factor de prorrateig de reassegurança
   /*IF ptipomovimiento IN (0, 6, 21, 22) THEN
      facces := facnet;
   ELSE
      facces := facnetsup;
   END IF;*/
   IF vtipo_movimiento  = 11
   THEN
      facnetsup := 1;
      facdevsup := 1;
   END IF;

   IF vtipo_movimiento IN (1, 11)
   THEN
      vfacconsor := facdevsup;
   ELSE
      vfacconsor := facdev;
   END IF;

   vffinrec := xffinrec;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
        RETURN sqlcode;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_OBTENERDATOS_CONSORCIO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_OBTENERDATOS_CONSORCIO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_OBTENERDATOS_CONSORCIO" TO "PROGRAMADORESCSI";
