--------------------------------------------------------
--  DDL for Function F_ASIGN_UNIDADES_SHW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ASIGN_UNIDADES_SHW" 
   RETURN NUMBER AUTHID CURRENT_USER IS
/****************************************************************************
   F_ASIGN_UNIDADES

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/12/2011  JMP              1. 0018423: LCOL000 - Multimoneda
*****************************************************************************/
   CURSOR cctaseguro IS
      SELECT /*+ rule */
             *
        FROM ctaseguro_shadow
       WHERE sseguro IN(SELECT sseguro
                          FROM seguros
                         WHERE cagrpro = 21)
         AND(cestado IN('1', '9')
             OR cestado IS NULL)
         AND cmovanu = 0
         AND cesta IS NOT NULL
         AND(nunidad <= 0
             OR nunidad IS NULL
             OR imovimi = 0)
         AND TRUNC(fvalmov) <= TRUNC(f_sysdate);

   importe        NUMBER;
   unidades       NUMBER;
   preciounidad   NUMBER;
   numunidades    NUMBER;
   impmovimi      NUMBER;
   fondocuenta    NUMBER;
   pestado        VARCHAR2(1);
   v_cempres      seguros.cempres%TYPE;
   num_err        axis_literales.slitera%TYPE;
BEGIN
   FOR valor IN cctaseguro LOOP
      BEGIN
         SELECT p.ccodfon, s.cempres
           INTO fondocuenta, v_cempres
           FROM productos_ulk p, seguros s
          WHERE p.cramo = s.cramo
            AND p.cmodali = s.cmodali
            AND p.ctipseg = s.ctipseg
            AND p.ccolect = s.ccolect
            AND s.sseguro = valor.sseguro;
      EXCEPTION
         WHEN OTHERS THEN
            fondocuenta := NULL;
      END;

      IF valor.cmovimi < 10 THEN
         importe := valor.imovimi * -1;
      ELSE
         importe := valor.imovimi;
      END IF;

      unidades := valor.nunidad;

      --SI UNIDADES = 0"
      IF unidades = 0
         OR unidades IS NULL THEN
         BEGIN
            SELECT iuniactcmpshw
              INTO preciounidad
              FROM tabvalces
             WHERE ccesta = valor.cesta
               AND TRUNC(fvalor) = TRUNC(valor.fvalmov);

            --ACTUALITZAR CTASEGURO"
            numunidades := importe / preciounidad;

            --SI SON MOVIMIENTOS DE GASTOS, PRIMAS DE RIESGO, ETC LAS UNIDADES SON NEGATIVAS"
            IF fondocuenta IS NOT NULL
               AND valor.cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39) THEN
               numunidades := numunidades * -1;
            END IF;

            IF fondocuenta IS NULL
               AND valor.cmovimi < 10 THEN
               numunidades := numunidades * -1;
            END IF;

            IF valor.cestado = '9' THEN
               pestado := '9';
            ELSE
               pestado := '2';
            END IF;

            UPDATE ctaseguro_shadow
               SET nunidad = numunidades,
                   cestado = pestado,
                   fasign = f_sysdate
             WHERE sseguro = valor.sseguro
               AND TRUNC(fcontab) = TRUNC(valor.fcontab)
               AND nnumlin = valor.nnumlin;

            --ACTUALIZAR CESTA"
            UPDATE fondos
               SET fondos.nparasi = fondos.nparasi +(importe / preciounidad)
             WHERE fondos.ccodfon = valor.cesta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               ROLLBACK;
               RETURN 107223;
         END;
      END IF;

      --SI UNIDADES < 0 E IMPORTE = 0"
      IF unidades < 0
         AND importe = 0 THEN
         BEGIN
            SELECT iuniactcmpshw
              INTO preciounidad
              FROM tabvalces
             WHERE ccesta = valor.cesta
               AND TRUNC(fvalor) = TRUNC(valor.fvalmov);

            --ACTUALIZAR CTASEGURO"
            impmovimi := f_round(unidades * preciounidad * -1);

            IF valor.cestado = '9' THEN
               pestado := '9';
            ELSE
               pestado := '2';
            END IF;

            UPDATE ctaseguro_shadow
               SET imovimi = impmovimi,
                   cestado = pestado,
                   fasign = f_sysdate
             WHERE sseguro = valor.sseguro
               AND TRUNC(fcontab) = TRUNC(valor.fcontab)
               AND nnumlin = valor.nnumlin;

            -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
               FOR reg IN (SELECT sseguro, fcontab, nnumlin, fvalmov
                             FROM ctaseguro_shadow
                            WHERE sseguro = valor.sseguro
                              AND TRUNC(fcontab) = TRUNC(valor.fcontab)
                              AND nnumlin = valor.nnumlin) LOOP
                  num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(reg.sseguro,
                                                                            reg.fcontab,
                                                                            reg.nnumlin,
                                                                            reg.fvalmov);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;

            -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda

            --ACTUALIZAR CESTA"
            UPDATE fondos
               SET fondos.nparasi = fondos.nparasi + unidades
             WHERE fondos.ccodfon = valor.cesta;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               NULL;
            WHEN OTHERS THEN
               ROLLBACK;
               RETURN 107223;
         END;
      END IF;
   END LOOP;

   UPDATE /*+ rule */ctaseguro_shadow
      SET nunidad = -1 * nunidad
    WHERE sseguro IN(SELECT sseguro
                       FROM seguros
                      WHERE cagrpro = 21)
      AND cmovimi IN(5, 6, 7, 21, 22, 23, 24, 26, 27, 28, 29, 39)
      AND nunidad > 0;

   UPDATE /*+ rule */ctaseguro_shadow
      SET fasign = f_sysdate
    WHERE sseguro IN(SELECT sseguro
                       FROM seguros
                      WHERE cagrpro = 21)
      AND cestado = '2'
      AND fasign IS NULL;

   RETURN 0;
END f_asign_unidades_shw;

/

  GRANT EXECUTE ON "AXIS"."F_ASIGN_UNIDADES_SHW" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ASIGN_UNIDADES_SHW" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ASIGN_UNIDADES_SHW" TO "PROGRAMADORESCSI";
