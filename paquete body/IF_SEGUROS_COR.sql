--------------------------------------------------------
--  DDL for Package Body IF_SEGUROS_COR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."IF_SEGUROS_COR" AS
   PROCEDURE lee AS
      leido          BOOLEAN := FALSE;
      wfanulac       DATE;
   BEGIN
      IF NOT seg_cv%ISOPEN THEN
         OPEN seg_cv;
      END IF;

      sortir := FALSE;

      FETCH seg_cv
       INTO regseg;

      SELECT DECODE(regseg.fanulac, NULL, TO_DATE('0001-01-01', 'yyyy-mm-dd'), regseg.fanulac)
        INTO regseg.fanulac
        FROM DUAL;

      IF seg_cv%NOTFOUND THEN
         leido := FALSE;
         sortir := TRUE;

         CLOSE seg_cv;
      ELSE
         leido := TRUE;
      END IF;

-- Inicializar variables
      IF leido THEN
         num_certificado := NULL;
         num_certif := 0;
         moneda := '???';
         subproducto := 0;
         cod_oficina := 0;
         total_recibo_pagado := 0;
         capital_1 := 0;
         capital_2 := 0;
         capital_3 := 0;
         capital_4 := 0;
         capital_5 := 0;
         capital_obra := 0;
         capital_constr := 0;
         capital_maq1 := 0;
         capital_rcprom := 0;
         capital_rccons := 0;
         capital_maq2 := 0;
         capital_maq3 := 0;
         capital_maq4 := 0;
         capital_maq5 := 0;
         capital_cte := 0;
         capital_ctdo := 0;
         capital_cfc := 0;
         capital_cdc := 0;
         capital_rc := 0;
         capital_invalidez := 0;
         capital_muerte := 0;
         capital_cteb := 0;
         capital_ctega := 0;
         capital_ctegb := 0;
         capital_ctegc1 := 0;
         capital_ctet := 0;
         capital_ctdot := 0;
         capital_averiamaq := 0;
         capital_detalim := 0;
         capital_estetico := 0;
         capital_protjur := 0;
         capital_asistencia := 0;
         capital_subsidi := 0;
         cta_prestamo := NULL;
         ent_benef := NULL;
         wfanulac := NULL;
         numpol := NULL;
         t_cperhos1 := NULL;
         t_cperhos2 := NULL;
         p_sclagen := 0;
         p_tidenti := 0;
         p_nnumnif := NULL;
         ---
         persona.sperson := 0;
         persona.tapelli := NULL;
         persona.tnombre := NULL;
         persona.csexper := NULL;
         persona.fnacimi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         persona.fjubila := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         ---
         persona2.sperson := 0;
         persona2.tapelli := NULL;
         persona2.tnombre := NULL;
         persona2.csexper := NULL;
         persona2.fnacimi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         persona2.fjubila := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         ---
         personaulk.sperson := 0;
         personaulk.cperhos := 0;
         personaulk.cnifhos := NULL;
         ----
         personaulk2.sperson := 0;
         personaulk2.cperhos := 0;
         personaulk2.cnifhos := NULL;

         ---
         IF regseg.fvencim IS NULL THEN
            regseg.fvencim := ADD_MONTHS(regseg.fefecto, 12);
         END IF;

         -- Estado
         r := f_estado_poliza(regseg.sseguro, NULL, f_sysdate, regseg.estado, wfanulac);

         ----JR
         IF regseg.estado = 'V' THEN
            regseg.fanulac := TO_DATE('0001-01-01', 'yyyy-mm-dd');
         END IF;

         ----
         -- Determinar tipo de producto
         BEGIN
            SELECT tipo_producto
              INTO t_producto
              FROM tipos_producto
             WHERE cramo = regseg.cramo
               AND cmodali = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN OTHERS THEN
               t_producto := NULL;
         END;

         IF t_producto IN('CSALUT', 'CSALUTI', 'ISFAS', 'MUFACE', 'MUGEJU', 'PRE_INc',
                          'PRE_INe', 'PRE_PRc', 'PRE_PRe') THEN
            regseg.fvencim := regseg.fcaranu;
         END IF;

         -- Lectura del numero de certificado
         BEGIN
            SELECT LPAD(polissa_ini, 13, '0')
              INTO num_certificado
              FROM cnvpolizas
             WHERE npoliza = regseg.npoliza;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               num_certificado := '0000000000000';
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Lee', 1, 'Error no controlado',
                           '(CnvPolizas) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         -- Determinar código de subproducto
         BEGIN
            SELECT producte_mu, DECODE(cmoneda, 2, 'PTA', 3, 'EUR', '???'), NVL(numpol, '0'),
                   cia
              INTO subproducto, moneda, numpol,
                   cia
              FROM cnvproductos
             WHERE TO_NUMBER(num_certificado) BETWEEN NVL(npolini, 0) AND NVL(npolfin,
                                                                              99999999)
               AND cramo = regseg.cramo
               AND cmodal = regseg.cmodali
               AND ctipseg = regseg.ctipseg
               AND ccolect = regseg.ccolect;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               subproducto := 0;
               moneda := '???';
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Lee', 2, 'Error no controlado',
                           '(CnvProductos 1) sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         -- Datos de Movseguro
         BEGIN
            SELECT fefecto
              INTO regmovseg.fmodifi
              FROM movseguro
             WHERE sseguro = regseg.sseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM movseguro
                               WHERE sseguro = regseg.sseguro
                                 AND cmovseg = 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               regmovseg.fmodifi := TO_DATE('0001-01-01', 'yyyy-mm-dd');
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Lee', 3, 'Error no controlado',
                           '(MovSeguro) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         -- Total recibo pagado
         BEGIN
            SELECT itotalr
              INTO total_recibo_pagado
              FROM vdetrecibos
             WHERE nrecibo = (SELECT nrecibo
                                FROM recibos
                               WHERE sseguro = regseg.sseguro
                                 AND ctiprec IN(0, 3)
                                 AND fefecto = (SELECT MAX(fefecto)
                                                  FROM recibos
                                                 WHERE sseguro = regseg.sseguro
                                                   AND ctiprec IN(0, 3)));
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               total_recibo_pagado := 0;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Lee', 4, 'Error no controlado',
                           '(VdetRecibos) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                           || SQLERRM);
         END;

         -- Capitales
         BEGIN
            pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, TO_CHAR(regseg.sseguro));

            SELECT NVL(MAX(DECODE(cgarant, 100, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 101, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 102, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 103, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 104, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 105, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 106, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 107, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 108, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 110, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 111, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 112, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 113, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 116, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 127, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 125, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 130, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 175, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 176, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 177, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 178, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 185, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 198, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 199, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 200, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 201, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 203, icapital)), 0),
                   NVL(MAX(DECODE(cgarant, 204, icapital)), 0)
              INTO capital_obra,
                   capital_constr,
                   capital_maq1,
                   capital_rcprom,
                   capital_rccons,
                   capital_maq2,
                   capital_maq3,
                   capital_maq4,
                   capital_maq5,
                   capital_cte,
                   capital_ctdo,
                   capital_cfc,
                   capital_cdc,
                   capital_rc,
                   capital_invalidez,
                   capital_muerte,
                   capital_subsidi,
                   capital_cteb,
                   capital_ctega,
                   capital_ctegb,
                   capital_ctegc1,
                   capital_ctet,
                   capital_ctdot,
                   capital_averiamaq,
                   capital_detalim,
                   capital_estetico,
                   capital_protjur,
                   capital_asistencia
              FROM garanseg
             WHERE sseguro = regseg.sseguro
               AND cgarant IN(100, 101, 102, 103, 104, 105, 106, 107, 108, 110, 111, 112, 113,
                              116, 127, 125, 130, 175, 176, 177, 178, 185, 198, 199, 200, 201,
                              203, 204)
               AND finiefe <= f_sysdate
               AND(ffinefe IS NULL
                   OR ffinefe > f_sysdate);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, 'ndf');
               capital_obra := 0;
               capital_constr := 0;
               capital_maq1 := 0;
               capital_rcprom := 0;
               capital_rccons := 0;
               capital_maq2 := 0;
               capital_maq3 := 0;
               capital_maq4 := 0;
               capital_maq5 := 0;
               capital_cte := 0;
               capital_ctdo := 0;
               capital_cfc := 0;
               capital_cdc := 0;
               capital_rc := 0;
               capital_invalidez := 0;
               capital_muerte := 0;
               capital_subsidi := 0;
               capital_cteb := 0;
               capital_ctega := 0;
               capital_ctegb := 0;
               capital_ctegc1 := 0;
               capital_ctet := 0;
               capital_ctdot := 0;
               capital_averiamaq := 0;
               capital_detalim := 0;
               capital_estetico := 0;
               capital_protjur := 0;
               capital_asistencia := 0;
            WHEN OTHERS THEN
               pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar,
                                 '(Garanseg) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                                 || SQLERRM);
---------DBMS_OUTPUT.PUT_LINE('(Garanseg) 1sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
         END;

         IF t_producto = 'MAHc'
            OR t_producto = 'MAHe' THEN
            capital_1 := capital_cte;
            capital_2 := capital_ctdo;
            capital_3 := capital_rc;
            capital_4 := capital_cfc;
            capital_5 := capital_cdc;
         ELSIF t_producto = 'TRC' THEN
            capital_1 := capital_obra;
            capital_2 := capital_constr;

            IF capital_rcprom <> 0 THEN
               capital_3 := capital_rcprom;
            ELSE
               capital_3 := capital_rccons;
            END IF;

            capital_4 := capital_maq1 + capital_maq2 + capital_maq3 + capital_maq4
                         + capital_maq5;
         ELSIF t_producto = 'ACCc'
               OR t_producto = 'ACCe' THEN
            capital_1 := capital_muerte;
            capital_2 := capital_invalidez;
         ELSIF t_producto = 'COM_SGA' THEN
            capital_1 := capital_cte;
            capital_2 := capital_ctdo;
            capital_3 := capital_estetico;
            capital_4 := capital_asistencia;
            capital_5 := capital_protjur;
         ELSIF t_producto = 'COM_CASER' THEN
            capital_1 := capital_cteb + capital_ctega + capital_ctegb + capital_ctegc1
                         + capital_ctet;
            capital_2 := capital_ctdot;
         ELSIF t_producto = 'LOC' THEN
            capital_1 := capital_cte;
         ELSIF t_producto = 'EDC' THEN
            capital_1 := capital_cte;
         ELSIF t_producto = 'COMER' THEN
            capital_1 := capital_cte;
            capital_2 := capital_ctdo;
            capital_3 := capital_averiamaq;
            capital_4 := capital_detalim;
         ELSIF t_producto = 'IT' THEN
            capital_1 := capital_subsidi;
         END IF;

         -- Cuenta de préstamo
         IF t_producto = 'COMER'
            OR t_producto = 'COM_SGA'
            OR t_producto = 'MAHc'
            OR t_producto = 'MAHe' THEN
            IF t_producto = 'COMER' THEN
               p_sclagen := 4751;
            ELSIF t_producto = 'COM_SGA' THEN
               p_sclagen := 4765;
            ELSIF t_producto = 'MAHc'
                  OR t_producto = 'MAHe' THEN
               p_sclagen := 4051;
            ELSE
               p_sclagen := 0;
            END IF;

            BEGIN
               SELECT tvalor
                 INTO cta_prestamo
                 FROM clauparseg
                WHERE sseguro = regseg.sseguro
                  AND sclagen = p_sclagen
                  AND nparame = 1;
            EXCEPTION
               WHEN OTHERS THEN
                  cta_prestamo := NULL;
                  ent_benef := '0000';
            END;

            ent_benef := SUBSTR(cta_prestamo, 1, 4);
         ELSE
            cta_prestamo := NULL;
            ent_benef := '0000';
         END IF;

         -- Oficina
         /* BEGIN
           SELECT coficin
            INTO cod_oficina
            FROM historicooficinas
           WHERE sseguro = RegSeg.sseguro
             AND finicio = (SELECT MAX(finicio)
                                   FROM historicooficinas
                         WHERE sseguro = RegSeg.sseguro
                           AND finicio <= RegSeg.fefecto);
         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             cod_oficina := 0;
         WHEN OTHERS THEN
            --DBMS_OUTPUT.PUT_LINE('(HistOficinas) 1sseguro = '|| TO_CHAR(RegSeg.sseguro)||' - '||sqlerrm);
         END; */
         -- Datos de Personas_ulk
         BEGIN
            SELECT sperson,
                   cperhos,
                   cnifhos
              INTO personaulk
              FROM personas_ulk
             WHERE sperson = (SELECT sperson
                                FROM asegurados
                               WHERE sseguro = regseg.sseguro
                                 AND norden = 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               personaulk.sperson := 0;
               personaulk.cperhos := 0;
               personaulk.cnifhos := NULL;
         END;

         BEGIN
            SELECT tidenti, LPAD(nnumnif, 10, '0')
              INTO p_tidenti, p_nnumnif
              FROM personas
             WHERE sperson = (SELECT sperson
                                FROM asegurados
                               WHERE sseguro = regseg.sseguro
                                 AND norden = 1);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tidenti := 0;
               p_nnumnif := NULL;
         END;

         IF p_tidenti = 1 THEN   -- Tipo D
            personaulk.cnifhos := 'D' || p_nnumnif || '00';
         END IF;

         t_cperhos1 := LPAD(TO_CHAR(personaulk.cperhos), 7, 0);

         -- Datos de Personas_ulk 2
         IF t_producto = 'MAHc'
            OR t_producto = 'MAHe' THEN
            BEGIN
               SELECT sperson,
                      cperhos,
                      cnifhos
                 INTO personaulk2
                 FROM personas_ulk
                WHERE sperson = (SELECT sperson
                                   FROM asegurados
                                  WHERE sseguro = regseg.sseguro
                                    AND norden = 2);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  personaulk2.sperson := 0;
                  personaulk2.cperhos := NULL;
                  personaulk2.cnifhos := NULL;
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Lee', 5,
                              'Error no controlado',
                              '(PersonaULK2) 1sseguro = ' || TO_CHAR(regseg.sseguro) || ' - '
                              || SQLERRM);
            END;

            IF personaulk2.cperhos IS NOT NULL THEN
               t_cperhos2 := LPAD(TO_CHAR(personaulk2.cperhos), 7, 0);
            ELSE
               t_cperhos2 := NULL;
            END IF;

            p_tidenti := 0;
            p_nnumnif := NULL;

            BEGIN
               SELECT tidenti, LPAD(nnumnif, 10, '0')
                 INTO p_tidenti, p_nnumnif
                 FROM personas
                WHERE sperson = (SELECT sperson
                                   FROM asegurados
                                  WHERE sseguro = regseg.sseguro
                                    AND norden = 2);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  p_tidenti := 0;
                  p_nnumnif := NULL;
            END;

            IF p_tidenti = 1 THEN   -- Tipo D
               personaulk2.cnifhos := 'D' || p_nnumnif || '00';
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF seg_cv%ISOPEN THEN
            CLOSE seg_cv;
         END IF;

         pk_env_comu.traza(pk_autom.trazas, pk_autom.depurar, 'CAPITALS');
--DBMS_OUTPUT.PUT_LINE('sseguro = '|| TO_CHAR(Regseg.sseguro)||' - '||sqlerrm);
   END lee;

   FUNCTION fin
      RETURN BOOLEAN IS
      fins           BOOLEAN := FALSE;
   BEGIN
      IF sortir THEN
         fins := TRUE;
      END IF;

      RETURN fins;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'If_Seguros_Cor.Marca_Pila', 1, 'Error no controlado',
                     'sseguro = ' || TO_CHAR(regseg.sseguro) || ' - ' || SQLERRM);
   END fin;

   PROCEDURE marcar_pila IS
   BEGIN
      UPDATE pila_ifases
         SET fecha_envio = f_sysdate
       WHERE fecha_envio IS NULL;

      COMMIT;
   END marcar_pila;
END if_seguros_cor;

/

  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."IF_SEGUROS_COR" TO "PROGRAMADORESCSI";
