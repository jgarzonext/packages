--------------------------------------------------------
--  DDL for Function F_VALIDAR_DURACION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_VALIDAR_DURACION" (
   psproduc IN NUMBER,
   psseguro IN NUMBER,
   pfecnac IN DATE,
   pfefecto IN DATE,
   pfvencim IN DATE)
   RETURN NUMBER IS
   v_fvtomin      DATE;
   v_fvtomax      DATE;
   vcdurmin       NUMBER;
   vnvtomin       NUMBER;
   vcdurmax       NUMBER;
   vnvtomax       NUMBER;
   vcobjase       NUMBER;
BEGIN
   SELECT cdurmin, nvtomin, cdurmax, nvtomax, cobjase
     INTO vcdurmin, vnvtomin, vcdurmax, vnvtomax, vcobjase
     FROM productos
    WHERE sproduc = psproduc;

   -- Calculamos el vencimiento mínimo y vencimiento máximo según
   -- el producto
   IF vcdurmin IS NOT NULL THEN
      IF vcdurmin = 0 THEN   -- aÑOS
         v_fvtomin := ADD_MONTHS(pfefecto, vnvtomin * 12);
      ELSIF vcdurmin = 1 THEN   -- meses
         v_fvtomin := ADD_MONTHS(pfefecto, vnvtomin);
      ELSIF vcdurmin = 2 THEN   -- días
         v_fvtomin := pfefecto + vnvtomin;
      ELSIF vcdurmin = 3 THEN   -- mes y día
         v_fvtomin := ADD_MONTHS(pfefecto, vnvtomin) + 1;
/*      ELSIF vcdurmin = 4 THEN -- fecha del primer periodo
         BEGIN
            SELECT feimtec
              INTO v_fvtomin
              FROM seguros_aho
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
*/
      ELSIF vcdurmin = 5 THEN   --desde edat
         v_fvtomin := ADD_MONTHS(pfecnac,(vnvtomin * 12));
      END IF;
   ELSE
      v_fvtomin := pfvencim;
   END IF;

   IF vcdurmax IS NOT NULL THEN
      IF vcdurmax = 0 THEN   -- aÑOS
         v_fvtomax := ADD_MONTHS(pfefecto, vnvtomax * 12);
      ELSIF vcdurmax IN(1, 2) THEN   -- edad máxima o fija
         IF vcobjase = 1
            AND pfecnac IS NOT NULL THEN   -- PERSONAS
            v_fvtomax := ADD_MONTHS(pfecnac,(vnvtomax + 1) * 12);
         END IF;
      ELSIF vcdurmax = 3 THEN   -- Meses
         v_fvtomax := ADD_MONTHS(pfefecto, vnvtomax);
      ELSIF vcdurmin = 4 THEN   -- Días
         v_fvtomax := pfefecto + vnvtomax;
      ELSIF vcdurmin = 4 THEN   -- Mes y día
         v_fvtomax := ADD_MONTHS(pfefecto, vnvtomax) + 1;
      END IF;
   ELSE
      v_fvtomax := pfvencim;
   END IF;

   -- Bug 12279 - APD - 14/12/2009 - si el parproducto tiene por defecto
   -- una fecha de vencimiento, pfvencim será dicha fecha no pudiendo modificarla
   IF pac_parametros.f_parproducto_f(psproduc, 'DIA_VENCIMIENTO') IS NOT NULL THEN
      IF pfvencim <> pac_parametros.f_parproducto_f(psproduc, 'DIA_VENCIMIENTO') THEN
         RETURN 9900823;   -- Fecha de Vencimiento incorrecta.
      END IF;
   END IF;

   IF pfvencim < v_fvtomin THEN
      -- Bug 10040 - 08/05/2009 - RSC - Ajustes productos PPJ Dinámico y Pla Estudiant
      -- Antes: if psproduc=263 then --JRH IMP Temporal
      IF NVL(f_parproductos_v(psproduc, 'MODIFICA_FVENCIM'), 0) = 1 THEN
         RETURN 0;
      END IF;

      -- Fin Bug 10040
      RETURN 109732;
   ELSIF pfvencim > v_fvtomax THEN
      RETURN 109733;
   ELSE
      RETURN 0;
   END IF;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."F_VALIDAR_DURACION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_DURACION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_VALIDAR_DURACION" TO "PROGRAMADORESCSI";
