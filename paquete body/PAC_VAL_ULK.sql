--------------------------------------------------------
--  DDL for Package Body PAC_VAL_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_VAL_ULK" 
AS
    /******************************************************************************
        RSC 12-07-2007
        Valida que el modelo de inversión configurado por el usuario és valido.
        Si Pmodinv es diferente de NULL nos indica que el usuario ha escogido el
        modelo de inversión Libre, y que por tanto debemos verificar su validez.

        La función retorna:
         0.- Si todo es correcto
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
    FUNCTION f_valida_cartera (psproduc IN NUMBER, pcperfil IN NUMBER, pcartera IN PAC_REF_CONTRATA_ULK.cartera, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER IS
        v_ob_det_simula_pu  ob_det_simula_pu;
        acum                NUMBER := 0;
        num_err                NUMBER;

        xcramo              NUMBER;
        xcmodali            NUMBER;
        xctipseg            NUMBER;
        xccolect            NUMBER;

        CURSOR cur_perfiles (ramo NUMBER, modalidad NUMBER, tipseg NUMBER, colect NUMBER) IS
          SELECT cmodinv
          FROM modelosinversion
          WHERE cramo = ramo
            AND cmodali = modalidad
            AND ctipseg = tipseg
            AND ccolect = colect
            AND ffin is null;
        trobat            NUMBER := 0;
    BEGIN
        --iteramos sobre el objeto cartera para sumar la distribución de cestas
        FOR i IN 1..pcartera.last LOOP
            acum := acum + to_number(PAC_UTIL.Splitt(pcartera(i),2,'|'));
        END LOOP;

        IF acum > 100 THEN
            ocoderror := 104808;  -- Error al validar el perfil de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
            RETURN (NULL); -- La suma de porcentajes no puede ser superior al 100%
         ELSIF acum < 100 THEN
            ocoderror := 109420;  -- Error al validar el perfil de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
            RETURN (NULL);
        END IF;

        -- Validamos que el perfil escogido sea seleccionable para el producto
        SELECT cramo, cmodali, ctipseg, ccolect INTO xcramo, xcmodali, xctipseg, xccolect
        FROM PRODUCTOS
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
          ocoderror := 180663;  -- Error al validar el perfil de inversión
          omsgerror := f_literal(ocoderror, pcidioma);
          RETURN (NULL);
        ELSE
          RETURN 0;
        END IF;
        ------------------------------------------------------------------------
    EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,  F_USER,  'Pac_Val_Ulk.f_valida_cartera',NULL, 'parametros: psproduc='||psproduc||
                        ' pcmodinv='||pcperfil||' pcidioma='||pcidioma,SQLERRM);
            ocoderror := 108190;  -- Error al validar el perfil de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
            RETURN (NULL);  -- Error general
    END f_valida_cartera;

   /******************************************************************************
        RSC 15-10-2007
        Valida si el perfil pasado por parámetro es editable o no.

        La función retorna:
         0.- Si todo es correcto
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
    FUNCTION f_valida_perfil_editable (psproduc IN NUMBER, pcperfil IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER IS
    BEGIN
        IF pcperfil = F_PARPRODUCTOS_V(psproduc,'PERFIL_LIBRE') THEN
          RETURN 1;
        ELSE
          RETURN 0;
        END IF;
    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180562;  -- Error al validar el perfil de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
            p_tab_error(f_sysdate,  F_USER,  'Pac_Val_Ulk.f_valida_perfil_editable',NULL, 'parametros: psproduc='||psproduc||
                        ' pcmodinv='||pcperfil||' pcidioma='||pcidioma,SQLERRM);
            RETURN NULL;
    END f_valida_perfil_editable;

    /*******************************************************************************************
        RSC 01-08-2007
        Para un cesta dada almacena en "estado" el estado de la cesta consultando
        el estado que tienen los fondos asociados a la cesta. (Cerrado, Semicerrado y Abierto)
        Esta función es de uso interno del Package. (f_Pac_Val_Ulk_abierto)

        La función retorna:
         0.- Si todo bien.
         codigo error: - Si hay error general
    *******************************************************************************************/
    FUNCTION f_valida_estado_cesta (cesta  IN NUMBER, v_fefecto IN DATE, estado OUT VARCHAR2) RETURN NUMBER IS
        ccesta              NUMBER;
        num_err                NUMBER;
        in_estado           varchar2(1);
        hi_haC              NUMBER := 0; -- indica si existen fondos en estado cerrado
        hi_haS              NUMBER := 0; -- indica si existen fondos en estado semicerrado

        CURSOR cestas (in_cesta NUMBER) IS
             SELECT distinct CCODFON
             FROM PARPGCF
             WHERE CCESTA = in_cesta
                and ccodfon is not null
                AND FFIN IS NULL;
    BEGIN
        FOR regs IN cestas(cesta) LOOP -- en sa nostra solo tendremos un fondo por cesta
            -- Query a FONESTADO para ver el estado del fondo a esta fecha
            SELECT cestado INTO in_estado
            FROM FONESTADO
            WHERE ccodfon=regs.ccodfon
              AND trunc(fvalora) = trunc(v_fefecto);

            IF in_estado = 'C' THEN -- Un fondo de la cesta tiene estado Cerrado --> No podemos dar de alta la póliza.
                hi_haC := hi_haC + 1;
            END IF;

            -- si <> 'A' --> Estado semicerrado (seguro que no es 'C' por que si no ya habriamos salido)
            IF in_estado = 'S' THEN
                hi_haS := hi_haS + 1;
            END IF;
        END LOOP;

        IF hi_haC > 0 THEN
            estado := 'C';
        ELSIF hi_haS > 0 THEN
            estado := 'S';
        ELSE
            estado := 'A';
        END IF;
        RETURN(0);

    EXCEPTION
         WHEN NO_DATA_FOUND THEN
            p_tab_error(f_sysdate,  F_USER,  'Pac_Val_Ulk.f_valida_estado_cesta',NULL, 'parametros: cesta='||cesta||
                                              ' v_fefecto='||v_fefecto,SQLERRM);
            RETURN (180442);  -- Fondos cerrados  o sin estado
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,  F_USER,  'Pac_Val_Ulk.f_valida_estado_cesta',NULL, 'parametros: cesta='||cesta||
                                              ' v_fefecto='||v_fefecto,SQLERRM);
            RETURN (108190);  -- Error general
    END f_valida_estado_cesta;

    /******************************************************************************
        RSC 17-09-2007
        Valida si existen fondos de inversión con fecha la de efecto pasada por parámetro
        que estén en estado CERRADO.

        La función retorna:
         0.- Si no existen fondos en estado CERRADO.
         codigo error: - Si hay error o no cumple alguna validación
    ******************************************************************************/
    FUNCTION f_valida_ulk_abierto (psseguro IN NUMBER DEFAULT NULL, psproduc IN NUMBER DEFAULT NULL, pfecha IN DATE, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER IS
     Estado VARCHAR2(1);
     v_cramo NUMBER;
     v_cmodali NUMBER;
     v_ctipseg NUMBER;
     v_ccolect NUMBER;

     CURSOR cur_modinv (vcramo IN NUMBER, vcmodali IN NUMBER, vctipseg IN NUMBER, vccolect IN NUMBER, vcmodinv IN NUMBER)IS
        SELECT ccodfon
        FROM modinvfondo
        where cramo = vcramo
          and cmodali = vcmodali
          and ctipseg = vctipseg
          and ccolect = vccolect
          and cmodinv = vcmodinv;

     CURSOR cur_modelos (vcramo IN NUMBER, vcmodali IN NUMBER, vctipseg IN NUMBER, vccolect IN NUMBER) IS
        SELECT cmodinv
        FROM MODELOSINVERSION
        WHERE cramo = vcramo
          and cmodali = vcmodali
          and ctipseg = vctipseg
          and ccolect = vccolect;

      num_err NUMBER;
    BEGIN
        -- Obtenemos el producto, ya sea por sseguro o por sproduc
        IF psproduc IS NOT NULL THEN
            SELECT cramo, cmodali, ctipseg, ccolect
            INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
            FROM PRODUCTOS
            WHERE sproduc = psproduc;
        ELSE
            SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect
            INTO v_cramo, v_cmodali, v_ctipseg, v_ccolect
            FROM PRODUCTOS p, seguros s
            where s.sseguro = psseguro
                and s.sproduc = p.sproduc;
        END IF;

        FOR mods IN cur_modelos (v_cramo, v_cmodali, v_ctipseg, v_ccolect) LOOP
            FOR regs IN cur_modinv (v_cramo, v_cmodali, v_ctipseg, v_ccolect, mods.cmodinv) LOOP

                num_err := f_valida_estado_cesta (regs.ccodfon, pfecha, Estado);
                IF num_err <> 0 THEN
                    ocoderror := num_err;  -- Error al validar el perfil de inversión
                    omsgerror := f_literal(ocoderror, pcidioma);
                    RETURN (NULL);
                END IF;

                IF Estado = 'C' THEN
                    ocoderror := 180442;  -- Error al validar el perfil de inversión
                    omsgerror := f_literal(ocoderror, pcidioma);
                    RETURN (NULL); --No se puede realizar la operación al existir fondos de inversión cerrados
                END IF;
            END LOOP;
        END LOOP;
        RETURN 0;
    EXCEPTION
     WHEN OTHERS THEN
        p_tab_error(f_sysdate, F_USER, 'Pac_Val_Ulk.f_valida_ulk_abierto',NULL, 'parametros: psseguro='||psseguro||
                                        ' psproduc='||psproduc||' pfecha='||pfecha,SQLERRM);
        ocoderror := 108190;  -- Error general
        omsgerror := f_literal(ocoderror, pcidioma);
        RETURN (NULL);
    END f_valida_ulk_abierto;

END Pac_Val_Ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_VAL_ULK" TO "PROGRAMADORESCSI";
