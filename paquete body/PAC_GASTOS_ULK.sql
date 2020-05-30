--------------------------------------------------------
--  DDL for Package Body PAC_GASTOS_ULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_GASTOS_ULK" AS


    FUNCTION FF_MOD_CDEFECT_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE) return NUMBER IS
        contdefectos NUMBER;
    BEGIN
        UPDATE DETGASTOS_ULK
        SET cdefect = 0
        WHERE cgasto <> p_cgasto
          AND ctipo=p_ctipo
          AND ffinvig is null;

        RETURN (0);
    EXCEPTION
     WHEN OTHERS THEN
          RETURN (NULL);
    END FF_MOD_CDEFECT_DETGASTOS_ULK;

    FUNCTION FF_NUM_DEFECT_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE) return NUMBER IS
        contdefectos NUMBER;
    BEGIN
        SELECT count(*)
        INTO contdefectos
        FROM DETGASTOS_ULK
        WHERE cgasto<>p_cgasto
              AND ctipo=p_ctipo
              AND ffinvig is null
              AND cdefect=1;

        RETURN (contdefectos);
    EXCEPTION
     WHEN OTHERS THEN
          RETURN (NULL);
    END FF_NUM_DEFECT_DETGASTOS_ULK;

    PROCEDURE P_MANTENIMIENTO_DETGASTOS_ULK (rt_detgastos_ulk IN DETGASTOS_ULK%ROWTYPE,
                                 rt_newdetgastos_ulk IN DETGASTOS_ULK%ROWTYPE)
    IS
        ctipos NUMBER;
    BEGIN
        IF rt_detgastos_ulk.FINIVIG IS NULL OR (rt_newdetgastos_ulk.FINIVIG <> rt_detgastos_ulk.FINIVIG) THEN
              --añadir un registro (ya existe un registro previo)
              IF rt_detgastos_ulk.FINIVIG IS NOT NULL THEN
                  UPDATE DETGASTOS_ULK
                  SET ffinvig=rt_newdetgastos_ulk.FINIVIG
                  WHERE cgasto=rt_detgastos_ulk.CGASTO
                              AND finivig=rt_detgastos_ulk.FINIVIG
                              AND ctipo=rt_detgastos_ulk.CTIPO;
              END IF;

              IF rt_detgastos_ulk.CTIPO is NULL THEN
                  ctipos := rt_newdetgastos_ulk.CTIPO;
              ELSE
                  ctipos := rt_detgastos_ulk.CTIPO;
              END IF;

              INSERT INTO DETGASTOS_ULK (cgasto,
                                         finivig,
                                         ctipo,
                                         ffinvig,
                                         pgasto,
                                         imaximo,
                                         iminimo,
                                         cdefect)
                          values (rt_detgastos_ulk.CGASTO,
                                  rt_newdetgastos_ulk.FINIVIG,
                                  ctipos,
                                  NULL,
                                  rt_newdetgastos_ulk.PGASTO/100,
                                  rt_newdetgastos_ulk.IMAXIMO,
                                  rt_newdetgastos_ulk.IMINIMO,
                                  rt_newdetgastos_ulk.CDEFECT);
        ELSE
            UPDATE DETGASTOS_ULK
            SET pgasto = rt_newdetgastos_ulk.PGASTO/100,
                imaximo = rt_newdetgastos_ulk.IMAXIMO,
                  iminimo = rt_newdetgastos_ulk.IMINIMO,
                  cdefect = rt_newdetgastos_ulk.CDEFECT
              WHERE cgasto = rt_detgastos_ulk.CGASTO
                    AND finivig = rt_newdetgastos_ulk.FINIVIG
                    AND ctipo = rt_detgastos_ulk.CTIPO;
        END IF;
    END P_MANTENIMIENTO_DETGASTOS_ULK;

    FUNCTION FF_DEL_DETGASTOS_ULK (p_cgasto DETGASTOS_ULK.CGASTO%TYPE,p_finivig DETGASTOS_ULK.FINIVIG%TYPE,p_ctipo DETGASTOS_ULK.CTIPO%TYPE,p_ffinvig DETGASTOS_ULK.FINIVIG%TYPE) return NUMBER IS
        contaReg NUMBER;
        anteriorDefect NUMBER;
        curDefect NUMBER;
    BEGIN
        IF p_ffinvig IS NULL THEN
            SELECT count(*) INTO contaReg
            FROM DETGASTOS_ULK
            WHERE cgasto = p_cgasto AND ctipo = p_ctipo;

            SELECT cdefect INTO curDefect
            FROM DETGASTOS_ULK
            WHERE cgasto = p_cgasto AND ctipo = p_ctipo AND finivig = p_finivig;

            IF contaReg > 1 THEN
                SELECT cdefect INTO anteriorDefect
                FROM DETGASTOS_ULK
                WHERE cgasto = p_cgasto AND ctipo = p_ctipo AND ffinvig = p_finivig;

                IF anteriorDefect = curDefect THEN -- el anterior tiene el mismo defect que el que queremos borrar
                    DELETE FROM DETGASTOS_ULK
                        WHERE cgasto = p_cgasto AND finivig = p_finivig AND ctipo = p_ctipo AND ffinvig is NULL;

                    -- modificamos el ultimo gasto anterior al pasado por parametro y le ponemos fecha fin de vigencia a NULL
                    UPDATE DETGASTOS_ULK
                    SET ffinvig = NULL
                    WHERE cgasto = p_cgasto
                          AND ctipo = p_ctipo
                          AND ffinvig = p_finivig;
                ELSE -- el anterior NO tiene el mismo defect que el que queremos borrar
                    -- borramos el gasto pasado por parametros
                    DELETE FROM DETGASTOS_ULK
                        WHERE cgasto = p_cgasto AND finivig = p_finivig AND ctipo = p_ctipo AND ffinvig is NULL;

                    -- modificamos el ultimo gasto anterior al pasado por parametro y le ponemos fecha fin de vigencia a NULL
                    UPDATE DETGASTOS_ULK
                    SET ffinvig = NULL, cdefect = curDefect
                    WHERE cgasto = p_cgasto
                          AND ctipo = p_ctipo
                          AND ffinvig = p_finivig;
                END IF;

            ELSIF contaReg = 1 THEN    -- un solo registro
                IF curDefect = 0 THEN  -- no es gasto por defecto
                    DELETE FROM DETGASTOS_ULK
                        WHERE cgasto = p_cgasto AND finivig = p_finivig AND ctipo = p_ctipo AND ffinvig is NULL;
                ELSE                   -- si es gasto por defecto
                    --No se ha encontrado un codigo de gasto por defecto (no podemos borrar si solo existe este por gasto por defecto)
                    RETURN (180428);
                END IF;
            END IF;
        END IF;

       RETURN (0);
    EXCEPTION
     WHEN OTHERS THEN
          RETURN (NULL);
    END FF_DEL_DETGASTOS_ULK;

    FUNCTION f_particion_hisseg (v1 IN NUMBER, v2 IN NUMBER) RETURN NUMBER IS
        y NUMBER := x;
        BEGIN
        CASE
          WHEN v2 IS NULL THEN
            x := 0;
          WHEN v1 != v2 THEN
            x := x + 1;
          ELSE
            NULL;
        END CASE;
        RETURN y;
    END;

    FUNCTION ff_detgastos_gestion_hisseg (psseguro IN NUMBER) RETURN cur_detgastos_hisseg IS
        v_cursor cur_detgastos_hisseg;
    BEGIN
        open v_cursor for
            SELECT *
            FROM
            (
                SELECT DISTINCT sseguro, f, cgasges, fmovimi_inicial, fmovimi_final
                --FIRST_VALUE(fmovimi_inicial) OVER ( PARTITION BY f ORDER BY fmovimi_inicial RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) fmovimi_inicial,
                --LAST_VALUE (fmovimi_final)   OVER ( PARTITION BY f ORDER BY fmovimi_final RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) fmovimi_final
                FROM
                (
                    -- Creem la partició
                    SELECT PAC_GASTOS_ULK.f_particion_hisseg (cgasges, cgasges_posterior) f,
                           sseguro, fmovimi_inicial, fmovimi_final, cgasges
                     FROM
                     (
                        -- Obtenim les dades que volem tractar amb l'ordre que necessitem
                        SELECT sseguro, nmovimi, trunc(fmovimi) fmovimi_inicial, cgasges,
                               LEAD ( cgasges, 1) OVER ( PARTITION BY sseguro ORDER BY sseguro, nmovimi, fmovimi ) cgasges_posterior,
                               LEAD ( trunc(fmovimi), 1, null ) OVER ( PARTITION BY sseguro ORDER BY sseguro, nmovimi, fmovimi ) fmovimi_final
                        FROM historicoseguros h
                        WHERE sseguro = psseguro
                        ORDER BY sseguro, nmovimi, fmovimi
                     )
                )
            ) z
            JOIN detgastos_ulk d ON (d.cgasto = z.cgasges )
            WHERE    (d.finivig >= z.fmovimi_inicial AND NVL(d.finivig,TRUNC(SYSDATE)) <= NVL(z.fmovimi_final,TRUNC(SYSDATE)))
                  OR (d.ffinvig >= z.fmovimi_inicial AND NVL(d.finivig,TRUNC(SYSDATE)) < NVL(z.fmovimi_final,TRUNC(SYSDATE)))
                  OR (d.finivig <= z.fmovimi_inicial AND NVL(d.ffinvig,TRUNC(SYSDATE)) >= NVL(z.fmovimi_final,TRUNC(SYSDATE)));

        RETURN v_cursor;

    EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,  F_USER,  'PAC_GASTOS_ULK.ff_detgastos_gestion_hisseg',NULL, 'parametros: psseguro='||psseguro,
                          SQLERRM);
            close v_cursor;
            RETURN v_cursor;
    END ff_detgastos_gestion_hisseg;


    FUNCTION ff_detgastos_redis_hisseg (psseguro IN NUMBER) RETURN cur_detgastos_hisseg IS
        v_cursor cur_detgastos_hisseg;
    BEGIN
        open v_cursor for
            SELECT *
            FROM
            (
                SELECT DISTINCT sseguro, f, cgasred, fmovimi_inicial, fmovimi_final
                    --FIRST_VALUE(fmovimi_inicial) OVER ( PARTITION BY f ORDER BY fmovimi_inicial RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) fmovimi_inicial,
                    --LAST_VALUE (fmovimi_final)   OVER ( PARTITION BY f ORDER BY fmovimi_final RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) fmovimi_final
                FROM
                (
                    -- Creem la partició
                    SELECT PAC_GASTOS_ULK.f_particion_hisseg (cgasred, cgasred_posterior) f,
                           sseguro, fmovimi_inicial, fmovimi_final, cgasred
                     FROM
                     (
                        -- Obtenim les dades que volem tractar amb l'ordre que necessitem
                        SELECT sseguro, nmovimi, trunc(fmovimi) fmovimi_inicial, cgasred,
                               LEAD ( cgasred, 1) OVER ( PARTITION BY sseguro ORDER BY sseguro, nmovimi, fmovimi ) cgasred_posterior,
                               LEAD ( trunc(fmovimi), 1, null ) OVER ( PARTITION BY sseguro ORDER BY sseguro, nmovimi, fmovimi ) fmovimi_final
                        FROM historicoseguros h
                        WHERE sseguro = psseguro
                        ORDER BY sseguro, nmovimi, fmovimi
                     )
                )
            ) z JOIN detgastos_ulk d ON (d.cgasto = z.cgasred)
            WHERE    (d.finivig >= z.fmovimi_inicial AND NVL(d.finivig,TRUNC(SYSDATE)) <= NVL(z.fmovimi_final,TRUNC(SYSDATE)))
                  OR (d.ffinvig >= z.fmovimi_inicial AND NVL(d.finivig,TRUNC(SYSDATE)) < NVL(z.fmovimi_final,TRUNC(SYSDATE)))
                  OR (d.finivig <= z.fmovimi_inicial AND NVL(d.ffinvig,TRUNC(SYSDATE)) >= NVL(z.fmovimi_final,TRUNC(SYSDATE)));

        RETURN v_cursor;

    EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,  F_USER,  'PAC_GASTOS_ULK.ff_detgastos_redis_hisseg',NULL, 'parametros: psseguro='||psseguro,
                          SQLERRM);
            close v_cursor;
            RETURN v_cursor;
    END ff_detgastos_redis_hisseg;
END PAC_GASTOS_ULK;

/

  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GASTOS_ULK" TO "PROGRAMADORESCSI";
