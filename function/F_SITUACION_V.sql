--------------------------------------------------------
--  DDL for Function F_SITUACION_V
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_SITUACION_V" (
   psseguro IN NUMBER,
   pfefecto IN DATE,
   pskip IN NUMBER DEFAULT 0)   --bug 32081/181874:NSS;14/08/2014
   RETURN NUMBER IS
   error          NUMBER := 0;
   situacion      NUMBER;
   w_cuenta       NUMBER;
   aux_efecto     DATE;
   aux_vencim     DATE;
   psituacion     NUMBER;
   aux_csituac    seguros.csituac%TYPE;   -- Bug 26874 - APD - 15/05/2013

   -- Esta función NO devuelve CSITUAC
   -- devolverá 'inexistente' para una fecha anterior a la del primer movto (emisión)
   -- devolverá 'inexistente' para una fecha anterior a la del efecto (aunque esté emitida)
   --bug 32081/181874:NSS;14/08/2014: El caso controlado por pskip se utiliza para las pólizas retroactivas.
   CURSOR movs(csseguro IN NUMBER, cfefecto IN DATE) IS
      SELECT   *
          FROM movseguro
         WHERE sseguro = csseguro
           AND fefecto <= TRUNC(cfefecto)
           AND((femisio < cfefecto + 1
                AND pskip = 0)
               OR pskip <> 0)   --bug 32081/181874:NSS;14/08/2014
           AND cmovseg NOT IN
                 (6, 2, 52, 10, 11)   -- no se tienen en cuenta los movimientos anulados o rechazados ni los de retención/desretención
      ORDER BY nmovimi DESC;   -- no se ordena por fefecto porque los movimientos de anulación
                               -- pueden tener efecto anterior a otros movimientos y entonces
-- no se detecta que está anulada
BEGIN
   psituacion := 0;

   BEGIN
      -- Bug 26874 - APD - 15/05/2013 - se añade csituac
      SELECT fefecto, fvencim, csituac
        INTO aux_efecto, aux_vencim, aux_csituac
        FROM seguros
       WHERE sseguro = psseguro;
   -- fin Bug 26874 - APD - 15/05/2013 - se añade csituac
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 100500;
      WHEN OTHERS THEN
         RETURN SQLCODE;
   END;

   IF aux_efecto > pfefecto THEN
      RETURN 0;
   END IF;

   -- Mantis 12275.NMM.14/12/2009.Es canvia de lloc
   /*IF aux_vencim <= pfefecto THEN
      psituacion := 3;
      RETURN psituacion;
   END IF;*/
   w_cuenta := 0;   --Inicializamos variable

   FOR i IN movs(psseguro, pfefecto) LOOP
      w_cuenta := w_cuenta + 1;

      IF i.cmovseg = 0 THEN
         IF i.femisio IS NULL
            -- Bug 26874 - APD - 15/05/2013 - se añade la condicion
            OR aux_csituac = 4 THEN
            -- fin Bug 26874 - APD - 15/05/2013 - se añade csituac
            psituacion := 0;   -- Prop. alta (no vigente)
            RETURN psituacion;
         ELSE
            EXIT;
         END IF;
      ELSE
         IF i.cmovseg = 3 THEN
            psituacion := 2;   -- Anulada
            RETURN psituacion;
         --     elsif i.cmovseg = ??
         --        como distingimos las suspendidas de las vigentes?
         ELSE
            EXIT;
         END IF;
      END IF;
   END LOOP;

   -- Mantis 12275.NMM.14/12/2009.Es canvia de lloc
   IF aux_vencim <= pfefecto THEN
      psituacion := 3;
      RETURN psituacion;
   END IF;

   IF w_cuenta = 0 THEN   --Si no hay registros en movseguro no es vigente
      psituacion := 0;
   ELSE
      psituacion := 1;   -- Vigente
   END IF;

   RETURN psituacion;
END f_situacion_v;

/

  GRANT EXECUTE ON "AXIS"."F_SITUACION_V" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_V" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_SITUACION_V" TO "PROGRAMADORESCSI";
