--------------------------------------------------------
--  DDL for Package Body PAC_CALC_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CALC_ULK" 
AS
    /******************************************************************************
        RSC 12-07-2007
        Obtener los perfiles o modelos de inversión a partir del producto.
    ******************************************************************************/
    FUNCTION f_get_perfil (psproduc IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE IS
        v_cursor cursor_TYPE;
    BEGIN
        open v_cursor for
            SELECT cmodinv, tmodinv, DECODE(cmodinv,F_PARPRODUCTOS_V(psproduc,'PERFIL_LIBRE'),'S','N') as editable
    	    FROM CODIMODELOSINVERSION
    	    WHERE (cramo, cmodali, ctipseg, ccolect) = (SELECT cramo, cmodali, ctipseg, ccolect
    	                                                FROM productos
    		  					WHERE sproduc = psproduc)
              AND cidioma = pcidioma;

        RETURN v_cursor;

    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180561;  -- Error General
            omsgerror := f_literal(ocoderror, pcidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_perfil',NULL, 'parametros: psproduc='||psproduc||
                        ' pcidioma='||pcidioma,
                          SQLERRM);
            close v_cursor;
            RETURN v_cursor;
    END f_get_perfil;

    /****************************************************************************************
        RSC 12-07-2007
        Obtener el detalle de los perfiles o modelos de inversión a partir del
        producto i el modelo de inversion.

        RSC 15-10-2007 Modificación del nombre y tipo de retorno. Debe ser un REF_CURSOR.
    ****************************************************************************************/
    FUNCTION f_get_detall_perfil (psproduc IN NUMBER, pcmodinv IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE IS
        v_det_modinv     cursor_TYPE;
    BEGIN
        open v_det_modinv for
          SELECT mv.ccodfon, f.tfonabv, mv.pinvers
    	    FROM MODINVFONDO mv, FONDOS f
    	    WHERE (mv.cramo, mv.cmodali, mv.ctipseg, mv.ccolect) = (SELECT cramo, cmodali, ctipseg, ccolect
    	                                                            FROM productos
                                                                    WHERE sproduc = psproduc)
                  AND mv.cmodinv = pcmodinv
                  AND mv.ccodfon=f.ccodfon;
        RETURN v_det_modinv;

    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180561;  -- Error General
            omsgerror := f_literal(ocoderror, cidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_detall_perfil',NULL, 'parametros: psproduc='||psproduc||
                        ' pcmodinv='||pcmodinv,
                          SQLERRM);
            close v_det_modinv;
            RETURN v_det_modinv;
    END f_get_detall_perfil;

    /******************************************************************************
        RSC 15-10-2007
        Obtiene el perfil de cartera de la póliza
    ******************************************************************************/
    FUNCTION f_get_perfil_poliza (psseguro IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN NUMBER IS
      cperfil NUMBER;
    BEGIN
        SELECT CMODINV INTO cperfil
        FROM seguros_ulk
        WHERE sseguro = psseguro;

        RETURN cperfil;

    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180561;  -- Error al leer los modelos de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_perfil_poliza',NULL, 'parametros: psseguro='||psseguro||' pcidioma='||pcidioma,
                                              SQLERRM);
            RETURN NULL;
    END f_get_perfil_poliza;

    /******************************************************************************
        RSC 15-10-2007
        Retorna la distribución de cartera asociada a una póliza.
    ******************************************************************************/
    FUNCTION f_get_cartera_poliza (psseguro IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE IS
      v_modinv_pol     cursor_TYPE;
    BEGIN
      open v_modinv_pol for
        SELECT s.CCESTA, f.tfonabv, s.PDISTREC, t.iuniact, sum(c.nunidad)
        FROM segdisin2 s, fondos f, ctaseguro c, tabvalces t
        WHERE s.sseguro = psseguro
          AND s.ffin is null
          AND s.nmovimi = (SELECT MAX(nmovimi)
                           FROM segdisin2
                           WHERE sseguro = psseguro
                             AND ffin is null)
          AND s.ccesta = f.ccodfon
          AND c.sseguro = s.sseguro
          AND c.cesta = f.ccodfon
          AND t.ccesta = c.cesta
          AND t.fvalor = (select max(t2.fvalor)
                          from tabvalces t2
                          where t2.ccesta = t.ccesta)
        GROUP BY s.CCESTA, f.tfonabv, s.PDISTREC, t.iuniact;
        RETURN v_modinv_pol;
    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180561;  -- Error al leer los modelos de inversión
            omsgerror := f_literal(ocoderror, pcidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_cartera_poliza',NULL, 'parametros: psseguro='||psseguro||' pcidioma='||pcidioma,
                                              SQLERRM);
            close v_modinv_pol;
            RETURN v_modinv_pol;
    END f_get_cartera_poliza;

    /******************************************************************************
        RSC 15-10-2007
        Retorna el literal de un fondo
    ******************************************************************************/
    FUNCTION f_get_fons_desc (pcfons IN NUMBER, pcidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2) RETURN VARCHAR2 IS
      fonliteral VARCHAR2(25);

    BEGIN
        SELECT tfonabv into fonliteral
        FROM FONDOS
        WHERE ccodfon = pcfons;

        RETURN fonliteral;
    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180563;  -- Error al leer la tabla FONDOS
            omsgerror := f_literal(ocoderror, pcidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_fons_desc',NULL, 'parametros: pcfons='||pcfons||' pcidioma='||pcidioma,
                                              SQLERRM);
            RETURN NULL;
    END f_get_fons_desc;

    /****************************************************************************************
        RSC 23-10-2007
        Obtener el detalle de los fondos relacionados con un producto.
    ****************************************************************************************/
    FUNCTION f_get_llistafons (psproduc IN NUMBER, cidioma IN NUMBER, ocoderror OUT NUMBER, omsgerror OUT VARCHAR2)
    RETURN cursor_TYPE IS
        v_det_fondos     cursor_TYPE;
    BEGIN
        open v_det_fondos for
          SELECT distinct mv.ccodfon, f.tfonabv
          FROM MODINVFONDO mv, FONDOS f
          WHERE (mv.cramo, mv.cmodali, mv.ctipseg, mv.ccolect) = (SELECT cramo, cmodali, ctipseg, ccolect
                                                                  FROM productos
                                                                     WHERE sproduc = psproduc)
                   AND mv.ccodfon=f.ccodfon
          ORDER BY CCODFON;
        RETURN v_det_fondos;

    EXCEPTION
         WHEN OTHERS THEN
            ocoderror := 180561;  -- Error General
            omsgerror := f_literal(ocoderror, cidioma);
    	    p_tab_error(f_sysdate,  F_USER,  'Pac_Calc_Ulk.f_get_llistafons',NULL, 'parametros: psproduc='||psproduc,
                          SQLERRM);
            close v_det_fondos;
            RETURN v_det_fondos;
    END f_get_llistafons;

 END Pac_Calc_Ulk;

/

  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CALC_ULK" TO "PROGRAMADORESCSI";
