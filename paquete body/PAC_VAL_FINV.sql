--------------------------------------------------------
--  DDL for Package Body PAC_VAL_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VAL_FINV" AS
    /******************************************************************************
      NOMBRE:       Pac_Val_Finv
      PROP�SITO:
      REVISIONES:

      Ver        Fecha        Autor             Descripci�n
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1. Creaci�n de package
       2.0       17/03/2009  RSC              2. An�lisis adaptaci�n productos indexados
       3.0       12/05/2009  RSC              3. Ajustes productos PPJ Din�mico y Pla Estudiant
   ******************************************************************************/

   /******************************************************************************
       RSC 12-07-2007
       Valida que el modelo de inversi�n configurado por el usuario �s valido.
       Si Pmodinv es diferente de NULL nos indica que el usuario ha escogido el
       modelo de inversi�n Libre, y que por tanto debemos verificar su validez.

       La funci�n retorna:
        0.- Si todo es correcto
        codigo error: - Si hay error o no cumple alguna validaci�n
   ******************************************************************************/
   FUNCTION f_valida_cartera(
      psproduc IN NUMBER,
      pcperfil IN NUMBER,
      pcartera IN pac_ref_contrata_ulk.cartera,
      pcidioma IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
      v_ob_det_simula_pu ob_det_simula_pu;
      acum           NUMBER := 0;
      num_err        NUMBER;
      xcramo         NUMBER;
      xcmodali       NUMBER;
      xctipseg       NUMBER;
      xccolect       NUMBER;

      CURSOR cur_perfiles(ramo NUMBER, modalidad NUMBER, tipseg NUMBER, colect NUMBER) IS
         SELECT cmodinv
           FROM modelosinversion
          WHERE cramo = ramo
            AND cmodali = modalidad
            AND ctipseg = tipseg
            AND ccolect = colect
            AND ffin IS NULL;

      trobat         NUMBER := 0;
   BEGIN
      --iteramos sobre el objeto cartera para sumar la distribuci�n de cestas
      FOR i IN 1 .. pcartera.LAST LOOP
         acum := acum + TO_NUMBER(pac_util.splitt(pcartera(i), 2, '|'));
      END LOOP;

      IF acum > 100 THEN
         ocoderror := 104808;   -- Error al validar el perfil de inversi�n
         omsgerror := f_literal(ocoderror, pcidioma);
         RETURN(NULL);   -- La suma de porcentajes no puede ser superior al 100%
      ELSIF acum < 100 THEN
         ocoderror := 109420;   -- Error al validar el perfil de inversi�n
         omsgerror := f_literal(ocoderror, pcidioma);
         RETURN(NULL);
      END IF;

      -- Validamos que el perfil escogido sea seleccionable para el producto
      SELECT cramo, cmodali, ctipseg, ccolect
        INTO xcramo, xcmodali, xctipseg, xccolect
        FROM productos
       WHERE sproduc = psproduc;

      -- RSC 23/11/2007 ------------------------------------------------------
      -- Iteramos sobre los perfiles parametrizados para el producto.
      -- Si este perfil no esta para el producto entonces error.
      FOR regs IN cur_perfiles(xcramo, xcmodali, xctipseg, xccolect) LOOP
         IF regs.cmodinv = pcperfil THEN
            trobat := 1;
         END IF;
      END LOOP;

      IF trobat = 0 THEN
         ocoderror := 180663;   -- Error al validar el perfil de inversi�n
         omsgerror := f_literal(ocoderror, pcidioma);
         RETURN(NULL);
      ELSE
         RETURN 0;
      END IF;
------------------------------------------------------------------------
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Ulk.f_valida_cartera', NULL,
                     'parametros: psproduc=' || psproduc || ' pcmodinv=' || pcperfil
                     || ' pcidioma=' || pcidioma,
                     SQLERRM);
         ocoderror := 108190;   -- Error al validar el perfil de inversi�n
         omsgerror := f_literal(ocoderror, pcidioma);
         RETURN(NULL);   -- Error general
   END f_valida_cartera;

   /******************************************************************************
        RSC 15-10-2007
        Valida si el perfil pasado por par�metro es editable o no.

        La funci�n retorna:
         0.- Si todo es correcto
         codigo error: - Si hay error o no cumple alguna validaci�n
    ******************************************************************************/
   FUNCTION f_valida_perfil_editable(
      psproduc IN NUMBER,
      pcperfil IN NUMBER,
      pcidioma IN NUMBER,
      ocoderror OUT NUMBER,
      omsgerror OUT VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pcperfil = f_parproductos_v(psproduc, 'PERFIL_LIBRE') THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         ocoderror := 180562;   -- Error al validar el perfil de inversi�n
         omsgerror := f_literal(ocoderror, pcidioma);
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Ulk.f_valida_perfil_editable', NULL,
                     'parametros: psproduc=' || psproduc || ' pcmodinv=' || pcperfil
                     || ' pcidioma=' || pcidioma,
                     SQLERRM);
         RETURN NULL;
   END f_valida_perfil_editable;

   /*******************************************************************************************
       Para un cesta dada almacena en "estado" el estado de la cesta consultando
       el estado que tienen los fondos asociados a la cesta. (Cerrado, Semicerrado y Abierto)
       Esta funci�n es de uso interno del Package. (f_Pac_Val_Ulk_abierto)

       La funci�n retorna:
        0.- Si todo bien.
        codigo error: - Si hay error general
   *******************************************************************************************/
   FUNCTION f_valida_estado_cesta(cesta IN NUMBER, v_fefecto IN DATE, estado OUT VARCHAR2)
      RETURN NUMBER IS
      ccesta         NUMBER;
      num_err        NUMBER;
      in_estado      VARCHAR2(1);
      hi_hac         NUMBER := 0;   -- indica si existen fondos en estado cerrado
      hi_has         NUMBER := 0;   -- indica si existen fondos en estado semicerrado
      v_empresa      NUMBER;
   BEGIN
      -- Query a FONESTADO para ver el estado del fondo a esta fecha
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,'FONESTADO_MAXFVALORA'),0) = 1 THEN
         SELECT cestado
           INTO in_estado
           FROM fonestado
          WHERE ccodfon = cesta
            AND TRUNC(fvalora) = (SELECT MAX(TRUNC(fvalora))
                                    FROM fonestado
                                   WHERE ccodfon = cesta
                                     AND TRUNC(fvalora) <= TRUNC(v_fefecto));
      ELSE
         SELECT cestado
           INTO in_estado
           FROM fonestado
          WHERE ccodfon = cesta
            AND TRUNC(fvalora) = TRUNC(v_fefecto);
      END IF;

      IF in_estado = 'C' THEN   -- Un fondo de la cesta tiene estado Cerrado --> No podemos dar de alta la p�liza.
         hi_hac := hi_hac + 1;
      END IF;

      -- si <> 'A' --> Estado semicerrado (seguro que no es 'C' por que si no ya habriamos salido)
      IF in_estado = 'S' THEN
         hi_has := hi_has + 1;
      END IF;

      IF hi_hac > 0 THEN
         estado := 'C';
      ELSIF hi_has > 0 THEN
         estado := 'S';
      ELSE
         estado := 'A';
      END IF;

      RETURN(0);
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Finv.f_valida_estado_cesta', NULL,
                     'parametros: cesta=' || cesta || ' v_fefecto=' || v_fefecto, SQLERRM);
         RETURN(180442);   -- Fondos cerrados  o sin estado
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Finv.f_valida_estado_cesta', NULL,
                     'parametros: cesta=' || cesta || ' v_fefecto=' || v_fefecto, SQLERRM);
         RETURN(108190);   -- Error general
   END f_valida_estado_cesta;

   /******************************************************************************
       Valida si existen fondos de inversi�n con fecha la de efecto pasada por par�metro
       que est�n en estado CERRADO.

       La funci�n retorna:
        0.- Si no existen fondos en estado CERRADO.
        codigo error: - Si hay error o no cumple alguna validaci�n
   ******************************************************************************/
   FUNCTION f_valida_ulk_abierto(
      psseguro IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pfecha IN DATE)
      RETURN NUMBER IS
      estado         VARCHAR2(1);
      v_cramo        NUMBER;
      v_cmodali      NUMBER;
      v_ctipseg      NUMBER;
      v_ccolect      NUMBER;

      CURSOR cur_modinv(
         vcramo IN NUMBER,
         vcmodali IN NUMBER,
         vctipseg IN NUMBER,
         vccolect IN NUMBER,
         vcmodinv IN NUMBER) IS
         SELECT ccodfon
           FROM modinvfondo
          WHERE cramo = vcramo
            AND cmodali = vcmodali
            AND ctipseg = vctipseg
            AND ccolect = vccolect
            AND cmodinv = vcmodinv;

      CURSOR cur_modelos(
         vcramo IN NUMBER,
         vcmodali IN NUMBER,
         vctipseg IN NUMBER,
         vccolect IN NUMBER) IS
         SELECT cmodinv
           FROM modelosinversion
          WHERE cramo = vcramo
            AND cmodali = vcmodali
            AND ctipseg = vctipseg
            AND ccolect = vccolect;

      num_err        NUMBER;
   BEGIN
      -- Obtenemos el producto, ya sea por sseguro o por sproduc
      IF psproduc IS NOT NULL THEN
         SELECT cramo, cmodali, ctipseg, ccolect
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM productos
          WHERE sproduc = psproduc;
      ELSE
         SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
           INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
           FROM productos p, seguros s
          WHERE s.sseguro = psseguro
            AND s.sproduc = p.sproduc;
      END IF;

      FOR mods IN cur_modelos(v_cramo, v_cmodali, v_ctipseg, v_ccolect) LOOP
         FOR regs IN cur_modinv(v_cramo, v_cmodali, v_ctipseg, v_ccolect, mods.cmodinv) LOOP
            num_err := f_valida_estado_cesta(regs.ccodfon, pfecha, estado);

            IF num_err <> 0 THEN
               RETURN(num_err);
            END IF;

            IF estado = 'C' THEN
               RETURN(180442);   --No se puede realizar la operaci�n al existir fondos de inversi�n cerrados
            END IF;
         END LOOP;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'Pac_Val_Finv.f_valida_ulk_abierto', NULL,
                     'parametros: psseguro=' || psseguro || ' psproduc=' || psproduc
                     || ' pfecha=' || pfecha,
                     SQLERRM);
         RETURN(108190);
   END f_valida_ulk_abierto;
END pac_val_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_FINV" TO "PROGRAMADORESCSI";
