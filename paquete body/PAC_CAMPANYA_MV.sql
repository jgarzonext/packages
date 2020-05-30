--------------------------------------------------------
--  DDL for Package Body PAC_CAMPANYA_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CAMPANYA_MV" AS
/****************************************************************************

   NOMBRE:       PAC_CAMPANYA_MV
   PROPÓSITO:  Funciones para campanya

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0           -          -               Creació del package
   2.0        21/04/2009   APD              Bug 9685 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
****************************************************************************/
   FUNCTION f_campanya_mv(pcpromoc IN NUMBER, pfecha_par IN NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------------------
-- Funció per omplir les taules de les campanyes de MV
--  CPM 26/02/04
-----------------------------------------------------------------------------
      pfecha         DATE := TO_DATE(pfecha_par, 'yyyymmdd');
   BEGIN
      DELETE FROM campanya_mv
            WHERE cpromoc = pcpromoc
              AND fcalcul = pfecha;

      -- Bug 9685 - APD - 21/04/2009 - en lugar de coger la actividad de la tabla seguros, llamar a la función pac_seguros.ff_get_actividad
      INSERT INTO campanya_mv
                  (cpromoc, fcalcul, sseguro, npoliza, nempleado, coficina, sproduc, ptosprod,
                   importe, basico)
         SELECT   pcpromoc, pfecha, s.sseguro, s.npoliza, m.nempleado, m.coficin, s.sproduc,
                  p.npeso, SUM(DECODE(r.ctiprec, 9, 0 - v.itotalr, v.itotalr)), p.basico
             FROM vdetrecibos v, recibos r, pesos_campanya_mv p, movseguro m, seguros s
            WHERE v.nrecibo = r.nrecibo
              AND f_cestrec(r.nrecibo, pfecha) = 1
              AND r.sseguro = s.sseguro
              AND p.sproduc = s.sproduc
              AND f_completo(s.sseguro, 1, s.sproduc,
                             pac_seguros.ff_get_actividad(s.sseguro, 1)) = p.basico
              AND pfecha BETWEEN p.finiefe AND NVL(p.ffinefe, pfecha)
              AND m.nempleado IS NOT NULL
              AND m.sseguro = s.sseguro
              AND f_vigente(s.sseguro, NULL, pfecha) = 0
         GROUP BY s.sseguro, s.npoliza, m.nempleado, m.coficin, s.sproduc, p.npeso, p.basico;

      -- Bug 9685 - APD - 21/04/2009 - Fin
      UPDATE campanya_mv c
         SET c.factor = (SELECT f.factor
                           FROM factor_campanya_mv f,
                                (SELECT   SUM(c2.importe) impo, c2.nempleado
                                     FROM campanya_mv c2
                                    WHERE c2.cpromoc = pcpromoc
                                      AND c2.fcalcul = pfecha
                                 GROUP BY c2.nempleado) s
                          WHERE s.impo BETWEEN f.nvolinf
                                           AND DECODE(f.nvolsup, 0, s.impo, f.nvolsup)
                            AND s.nempleado = c.nempleado)
       WHERE c.cpromoc = pcpromoc
         AND c.fcalcul = pfecha;

      UPDATE campanya_mv
         SET ptostotal = factor * ptosprod
       WHERE cpromoc = pcpromoc
         AND fcalcul = pfecha;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         --DBMS_OUTPUT.put_line(SQLERRM);
         RETURN -1;
   END f_campanya_mv;

   FUNCTION f_campa_acumulada(pcpromoc IN NUMBER, pdata IN DATE)
      RETURN NUMBER IS
---------------------------------------------------------------------------------
-- En la campaña acumulada, la formula es para todos los productos de la campaña
-- pq las condiciones se cumplen acumulando los valores de todas las pólizas de
-- todos los productos de la campanya
-- A més hi pot haver alguna fórmula més per un conjunt de productes, que estarà informat
-- a promocionprod
---------------------------------------------------------------------------------
      CURSOR c_prom(wcpromoc NUMBER, wdata DATE) IS
         SELECT cpromoc, cformula, 0 prods
           FROM codipromociones
          WHERE (cpromoc = wcpromoc
                 OR wcpromoc IS NULL)
            AND finicio <= wdata
            AND(ffinal > wdata
                OR ffinal IS NULL)
            AND ctipges = 2
            AND cformula IS NOT NULL
         UNION
         SELECT DISTINCT p.cpromoc, p.cformula, 1 prods
                    FROM promocionprod p, codipromociones c
                   WHERE (c.cpromoc = wcpromoc
                          OR wcpromoc IS NULL)
                     AND c.cpromoc = p.cpromoc
                     AND c.finicio <= wdata
                     AND(c.ffinal > wdata
                         OR c.ffinal IS NULL)
                     AND c.ctipges = 2
                     AND p.cformula IS NOT NULL;

      lformula       VARCHAR2(2000);
      lsesion        NUMBER;
      num_err        NUMBER;
   BEGIN
      FOR v_prom IN c_prom(pcpromoc, pdata) LOOP
--         DBMS_OUTPUT.put_line(' PROMOCIO ' || pcpromoc || ' FORMULA ' || v_prom.cformula);

         -- Obte fórmula
         BEGIN
            SELECT LTRIM(RTRIM(formula))
              INTO lformula
              FROM sgt_formulas
             WHERE clave = v_prom.cformula;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               --dbms_output.PUT_LINE(' no troba la fórmula ');
               RETURN 108559;
            WHEN OTHERS THEN
               --dbms_output.PUT_LINE(' error  en la fórmula ');
               RETURN 120191;
         END;

         BEGIN
            SELECT sgt_sesiones.NEXTVAL
              INTO lsesion
              FROM DUAL;
         EXCEPTION
            WHEN OTHERS THEN
               --dbms_output.PUT_LINE(' Error seq. sesions '||SQLERRM);
               RETURN 120192;
         END;

         -- Grava paràmetres
         num_err := pac_parm_tarifas.graba_param(lsesion, 'FECHA', TO_CHAR(pdata, 'yyyymmdd'));

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := pac_parm_tarifas.graba_param(lsesion, 'PROMOCION', v_prom.cpromoc);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         IF v_prom.prods = 1 THEN
            num_err := pac_parm_tarifas.graba_param(lsesion, 'FORMULAPROD', v_prom.cformula);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

--         DBMS_OUTPUT.put_line(' FORMULA ' || lformula);
         -- Avaluem la fórmula
         num_err := pk_formulas.eval(lformula, lsesion);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         num_err := pac_parm_tarifas.borra_param_sesion(lsesion);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END LOOP;

      RETURN 0;
   END f_campa_acumulada;
END pac_campanya_mv;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANYA_MV" TO "PROGRAMADORESCSI";
