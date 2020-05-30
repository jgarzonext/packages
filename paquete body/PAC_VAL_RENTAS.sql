--------------------------------------------------------
--  DDL for Package Body PAC_VAL_RENTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VAL_RENTAS" AS
/******************************************************************************
   NOMBRE:    PAC_VAL_RENTAS
   PROPÓSITO:

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????   ???                1. Creación del package.
   2.0        22/09/2009   DRA                2. 0011183: CRE - Suplemento de alta de asegurado ya existente
******************************************************************************/
   FUNCTION f_valida_prima_rentas(
      ptipo IN NUMBER,
      psproduc IN NUMBER,
      psperson IN NUMBER,
      ptipo_prima IN NUMBER,
      pprima IN NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE DEFAULT f_sysdate)
      RETURN NUMBER IS
      /*********************************************************************************************************************************
       Función que valida la prima periódica de una póliza de ahorro
       Parámetros de entrada: . ptipo := 1 - alta o simulación
                                         2 - suplemento o modificación
                              . psproduc = Identificador del producto
                              . psperson = Identificador de la persona
                              . ptipo_prima = Tipo de prima : 3.Prima Periódica
                                                              4.Prima inicial o extraordinaria
                              . pprima = Importe de la prima períodica
                              . pcforpag = Código de forma de pago
       *******************************************************************************************************************************/
      v_cgarant      NUMBER;
      v_ctipgar      NUMBER;
      v_capmin       NUMBER;
      v_capmax       NUMBER;
      num_err        NUMBER;
   BEGIN
      -- Se busca el código de la garantía
      v_cgarant := pac_calc_comu.f_cod_garantia(psproduc, ptipo_prima, NULL, v_ctipgar);
      -- Se valida el importe de la prima mínima y máxima JRH Esto igual
      num_err := pac_val_comu.f_valida_capital(ptipo, psproduc, 0, v_cgarant, pprima,
                                               pcforpag, v_capmin, v_capmax);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Se valida el importe de la prima según la persona: residente - no residente, cúmulos  --JRH  Creo que también vale esta
      num_err := pac_val_comu.f_valida_capital_persona(ptipo, psproduc, 0, v_cgarant, pprima,
                                                       psperson, NULL, pfefecto);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_prima_rentas', 1,
                     'parametros: ptipo = ' || ptipo || ' sproduc =' || psproduc
                     || ' psperson =' || psperson || ' ptipo_prima = ' || ptipo_prima
                     || ' pprima = ' || pprima || ' pcforpag = ' || pcforpag,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_prima_rentas;

   FUNCTION f_valida_cambreservcap(psseguro IN NUMBER, pcapital IN NUMBER)
      RETURN NUMBER IS
      num_err        NUMBER := 0;
      capfallant     NUMBER;
   BEGIN
      IF pcapital IS NOT NULL THEN
         SELECT pcapfall
           INTO capfallant
           FROM seguros_ren
          WHERE sseguro = psseguro;

         IF NVL(capfallant, 0) < pcapital THEN
            num_err := 180615;
         END IF;
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_cambreservcap', 1,
                     'parametros: psseguro = ' || psseguro || ' pfallec =' || pcapital,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END;

   /*FUNCTION f_valida_garantia_adicional(psproduc IN NUMBER, psperson IN NUMBER, pcobliga IN NUMBER, ptipo_garant IN NUMBER, ppropietario_garant IN NUMBER, pfefecto IN DATE)
     RETURN NUMBER IS

     v_garant     NUMBER;
     v_ctipgar    NUMBER;
     num_err      NUMBER;
   BEGIN

     IF psperson IS NOT NULL THEN
        IF nvl(pcobliga,0) <> 0 THEN -- la garantia adicional está contratada JRH De momento igual
           v_garant := pac_calc_comu.f_cod_garantia(psproduc, ptipo_garant, ppropietario_garant, v_ctipgar);
           IF v_garant IS NOT NULL THEN
              num_err := pac_val_comu.f_valida_edad_garant(psproduc, 0, v_garant, psperson, pfefecto);
              IF num_err <> 0 THEN
                 RETURN num_err;
              END IF;
           ELSE
             RETURN 180434;  -- Garantía no contratable
           END IF;
        END IF;
     END IF;

     RETURN 0;

   EXCEPTION
     WHEN OTHERS THEN
          p_tab_error (f_sysdate,  F_USER, 'Pac_Val_Rentas.f_valida_garantia_adicional', 1,  'parametros: psproduc = '||psproduc||
                       ' psperson ='||psperson||' pcobliga = '||pcobliga||' ptipo_garant = '||ptipo_garant||
                       ' ppropietario_garant = '||ppropietario_garant||' pfefecto = '||pfefecto, SQLERRM );
          RETURN 108190;  -- Error general
   END f_valida_garantia_adicional;*/
   FUNCTION f_valida_percreservcap(psproduc IN NUMBER, pfallec IN NUMBER)
      RETURN NUMBER IS
      -- Variables Producto
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;
   BEGIN
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

      IF xcramo <> 40 THEN
         IF NVL(pfallec, 0) <> 0 THEN
            RETURN 152500;
         END IF;
      ELSE
         IF pfallec IS NULL THEN
            RETURN 180591;
         END IF;

         IF pfallec < 0 THEN
            RETURN 111260;
         END IF;

         IF pfallec <> 105 THEN
            IF NOT(pfallec BETWEEN 0 AND 95) THEN
               RETURN 180592;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_percreservcap', 1,
                     'parametros: psproduc = ' || psproduc || ' pfallec =' || pfallec,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_percreservcap;

   FUNCTION f_valida_pct_revers(psproduc IN NUMBER, prevers IN NUMBER)
      RETURN NUMBER IS
      xcpctrev       producto_ren.cpctrev%TYPE;
      xnpctrev       producto_ren.npctrev%TYPE;
      xnpctrevmin    producto_ren.npctrevmin%TYPE;
      xnpctrevmax    producto_ren.npctrevmax%TYPE;
   BEGIN
      SELECT cpctrev, npctrev, npctrevmin, npctrevmax
        INTO xcpctrev, xnpctrev, xnpctrevmin, xnpctrevmax
        FROM producto_ren
       WHERE sproduc = psproduc;

      IF xcpctrev IS NULL THEN
         IF prevers IS NOT NULL THEN
            RETURN 180593;
         END IF;
      ELSE
         IF prevers IS NULL THEN
            RETURN 180587;
         END IF;
      END IF;

      IF xcpctrev = 1 THEN
         IF prevers <> xnpctrev THEN
            RETURN 180594;   --No debe tener pct revers. Crear mas mensajes.
         END IF;
      ELSIF xcpctrev = 2 THEN
         IF prevers NOT BETWEEN NVL(xnpctrevmin, 0) AND NVL(xnpctrevmax, 0) THEN
            RETURN 180595;   --No debe tener pct revers. Crear mas mensajes.
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_pct_fallec', 1,
                     'parametros: psproduc = ' || psproduc || ' prevers =' || prevers,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_pct_revers;

   FUNCTION f_valida_perctasacio(psproduc IN NUMBER, pcttasinmuebhi IN NUMBER)
      RETURN NUMBER IS
      CURSOR respuestas(valor VARCHAR2) IS
         SELECT 1
           FROM codirespuestas
          WHERE cpregun = 101
            AND crespue = valor;

      dummy          NUMBER;
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 1 THEN
         IF (pcttasinmuebhi IS NULL) THEN
            RETURN 180596;
         END IF;

         IF respuestas%ISOPEN THEN
            CLOSE respuestas;
         END IF;

         OPEN respuestas(TO_CHAR(pcttasinmuebhi));   --Validamos que el valor de la tasación es el que toca

         FETCH respuestas
          INTO dummy;

         IF respuestas%NOTFOUND THEN
            CLOSE respuestas;

            RETURN 180597;
         END IF;

         CLOSE respuestas;
      ELSE
         IF (NVL(pcttasinmuebhi, 0) <> 0) THEN
            RETURN 180598;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 04/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF respuestas%ISOPEN THEN
            CLOSE respuestas;
         END IF;

         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_perctasacio', 1,
                     'parametros: psproduc = ' || psproduc || ' pcttasinmuebHI ='
                     || pcttasinmuebhi,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_perctasacio;

   FUNCTION f_valida_capitaldisp(
      psproduc IN NUMBER,
      tasinmuebhi IN NUMBER,
      capitaldisphi IN NUMBER)
      RETURN NUMBER IS
   BEGIN
      IF NVL(f_parproductos_v(psproduc, 'HIPOTECA_INVERSA'), 0) = 1 THEN
         IF (tasinmuebhi IS NULL)
            OR(capitaldisphi IS NULL) THEN
            RETURN 180599;   -- JRH IMP Crear mensajes
         END IF;

         IF capitaldisphi >(tasinmuebhi / 5) THEN
            RETURN 180601;   -- JRH IMP Crear mensajes
         END IF;
      ELSE
         IF (NVL(tasinmuebhi, 0) <> 0)
            OR(NVL(capitaldisphi, 0) <> 0) THEN
            RETURN 180600;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_capitaldisp', 1,
                     'parametros: psproduc = ' || psproduc || ' f_valida_capitaldisp ='
                     || tasinmuebhi,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_capitaldisp;

   FUNCTION f_valida_forma_pago_renta(psproduc IN NUMBER, formapago IN NUMBER)
      RETURN NUMBER IS
      num            NUMBER;
   BEGIN
      IF formapago IS NULL THEN
         RETURN 180602;
      END IF;

      SELECT 1
        INTO num
        FROM forpagren f
       WHERE f.sproduc = psproduc
         AND f.cforpag = formapago;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 180602;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_forma_pago_renta', 1,
                     'parametros: psproduc = ' || psproduc || ' formaPago =' || formapago,
                     SQLERRM);
         RETURN 108190;   -- Error general
   END f_valida_forma_pago_renta;

   FUNCTION f_valida_gestion_rentas(
      psproduc IN NUMBER,
      pctipban IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pcidioma IN NUMBER,
      pcforpag IN NUMBER,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcbancar IN VARCHAR2,
      pcidioma_user IN NUMBER DEFAULT f_idiomauser,
      pformpagorenta IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      error          EXCEPTION;
      forpagorenta   NUMBER;   --JRH
   BEGIN
      num_err := pac_ref_contrata_comu.f_valida_gestion(psproduc, pctipban, pfefecto,
                                                        pfnacimi, pcidioma, pcforpag,
                                                        pnduraci, pfvencim, pcbancar,
                                                        pcidioma_user, ocoderror, omsgerror);

      IF num_err IS NULL THEN
         RAISE error;
      END IF;

      IF pformpagorenta IS NULL THEN
         SELECT cforpag
           INTO forpagorenta
           FROM forpagren
          WHERE sproduc = psproduc;
      ELSE
         forpagorenta := pformpagorenta;
      END IF;

      num_err := f_valida_forma_pago_renta(psproduc, forpagorenta);

      IF num_err <> 0 THEN
         ocoderror := num_err;
         omsgerror := f_axis_literales(num_err, pcidioma_user);
         RAISE error;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Rentas.f_valida_gestion_rentas', 1,
                     'parametros: psproduc = ' || psproduc || ' pformpagorenta ='
                     || pformpagorenta,
                     SQLERRM);
         RETURN NULL;   -- Error general
   END;

   --
   -- La funció retorna 0 si tot és correcte
   --                  codi error si no es compleix alguna validació
   --  Informar psPerson únicamente cuando se haya realizado la búsqueda por asegurado.
   --
   FUNCTION f_valida_permite_impr_libreta(psseguro seguros.sseguro%TYPE, psperson IN NUMBER)
      RETURN NUMBER IS
      v_error        NUMBER;
   BEGIN
      v_error := 0;

      FOR rseguros IN (SELECT csituac, cagrpro
                         FROM seguros
                        WHERE sseguro = psseguro) LOOP
         CASE
            WHEN rseguros.csituac NOT IN(0, 1, 2, 3, 5, 6, 11) THEN
               v_error := 180436;   -- La pòlissa no està en situació d'imprimir.
            WHEN rseguros.cagrpro <> 2 THEN
               v_error := 180437;   -- No és una pòlissa de Productes d'Estalvi
         END CASE;
      END LOOP;

      IF v_error = 0
         AND psperson IS NOT NULL THEN
         FOR rasegurados IN
            (SELECT ffecfin
               FROM asegurados
              WHERE sseguro = psseguro   -- BUG11183:DRA:08/10/2009: faltava esta comparacion
                AND sperson = psperson) LOOP
            IF rasegurados.ffecfin IS NOT NULL THEN
               v_error := 180438;   --L'assegurat ha estat donat de baixa de la pòlissa.
            END IF;
         END LOOP;
      END IF;

      RETURN v_error;
   END;
END pac_val_rentas;

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_RENTAS" TO "PROGRAMADORESCSI";
