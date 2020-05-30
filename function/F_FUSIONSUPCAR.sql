--------------------------------------------------------
--  DDL for Function F_FUSIONSUPCAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_FUSIONSUPCAR" (
   psseguro IN NUMBER,
   pnreccar IN NUMBER,
   pfefecar IN DATE,
   pfemicar IN DATE,
   pmodo IN VARCHAR2,
   psproces IN NUMBER)
   RETURN NUMBER AUTHID CURRENT_USER IS
   /******************************************************************************
   NOMBRE:       F_FUSIONSUPCAR
   PROPÓSITO:    Fusiona un recibo de suplemento
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???              Creación del package.
   2.0        24/04/2012  JMF              0022027 CRE800 Previ de cartera
   ******************************************************************************/

   --
-- Librería ALLIBADM
--    Fusiona un recibo de suplemento pendiente y no imprimmible
--            con el de la cartera que está efectuando (para los recibos
--            que solo tienen prima devengada y/o consorcio y que al no
--            tener prima neta no se gestionó en su momento).
--

   -- ini Bug 0022027 - JMF - 24/04/2012
   vobj           VARCHAR2(500) := 'F_FUSIONSUPCAR';
   vpar           VARCHAR2(900)
      := 's=' || psseguro || ' r=' || pnreccar || ' f=' || pfefecar || ' e=' || pfemicar
         || ' m=' || pmodo || ' s=' || psproces;
   vpas           NUMBER(5) := 0;
   -- fin Bug 0022027 - JMF - 24/04/2012
   xctiprec       NUMBER;
   xcestrec       NUMBER;
   xcestant       NUMBER;
   ximporte       NUMBER;
   xtotrcar       NUMBER;
   xnumconc       NUMBER;
   error          NUMBER;
   xsmovagr       NUMBER := 0;
   xnliqmen       NUMBER;
   xnliqlin       NUMBER;
   xfmovimi       DATE;

   CURSOR c_detrecibos(recibo IN NUMBER) IS
      SELECT *
        FROM detrecibos
       WHERE nrecibo = recibo
         AND cconcep NOT IN(15, 16, 21, 65, 66, 71);   -- Conceptos que no sean de ventas

   CURSOR c_recibos IS
      SELECT r.nrecibo rec, v.itotalr tot, r.ctiprec tip, r.cdelega
        FROM movrecibo m, vdetrecibos v, recibos r
       WHERE r.sseguro = psseguro
         AND v.nrecibo = r.nrecibo
         AND m.nrecibo = r.nrecibo
         AND m.fmovfin IS NULL   -- Está pendiente
         AND m.cestrec = 0
         AND v.itotpri = 0   -- Su prima era 0 pero
         AND v.itotalr <> 0   -- su totalr no
         AND r.cestimp = 0   -- no imprimible
         AND r.ctiprec IN(1, 9);   -- suplemento (o extorno)
BEGIN
   vpas := 1000;

   -- Buscamos el total del recibo de cartera
   IF pmodo = 'R' THEN
      BEGIN
         vpas := 1010;

         SELECT itotalr
           INTO xtotrcar
           FROM vdetrecibos
          WHERE nrecibo = pnreccar;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 103920;   -- error al leer de vdetrecibos
      END;
   ELSE
      BEGIN
         -- Bug 0022027 - JMF - 24/04/2012: psproces
         vpas := 1020;

         SELECT itotalr
           INTO xtotrcar
           FROM vdetreciboscar
          WHERE nrecibo = pnreccar
            AND sproces = psproces;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 104441;   -- error al leer de vdetreciboscar
      END;
   END IF;

   -- Si el total recibo no es 0
   IF xtotrcar <> 0 THEN
      -- Iniciamos la fusión de los recibos
      vpas := 1030;

      FOR re IN c_recibos LOOP
         -- Validamos que el total del recibo fusionado no sea 0
         IF re.tip = 9
            AND xtotrcar < re.tot THEN   -- El extorno es superior al total
            -- del recibo de cartera
            IF pmodo = 'R' THEN
               -- Dejamos el extorno pendiente de imprimir y no lo fusionamos
               BEGIN
                  vpas := 1040;

                  UPDATE recibos
                     SET ctiprec = 1
                   WHERE nrecibo = re.rec;
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 102358;   -- Error al actualizar la tabla recibos
               END;
            END IF;
         ELSE
            -- Verificamos que no se haya hecho ningún movimiento de recibo.
            BEGIN
               vpas := 1050;

               SELECT cestrec, cestant
                 INTO xcestrec, xcestant
                 FROM movrecibo
                WHERE nrecibo = re.rec;

               IF xcestrec <> 0
                  OR xcestant <> 0 THEN
                  RETURN 101947;   -- Error de consistencia en la B.D.
               END IF;
            EXCEPTION
               WHEN TOO_MANY_ROWS THEN
                  RETURN 105886;
               WHEN OTHERS THEN
                  RETURN 104043;
            END;

            -- Hemos localizado recibos de suplemento con fecha de efecto coincidente con
            -- la del que estamos generando y que hay que fusionar.
            vpas := 1060;

            FOR d IN c_detrecibos(re.rec) LOOP
               IF re.tip = 9 THEN   -- El suplemento era un extorno
                  ximporte := 0 - d.iconcep;
               ELSE
                  ximporte := d.iconcep;
               END IF;

               IF pmodo = 'R' THEN
                  BEGIN
                     vpas := 1070;

                     INSERT INTO detrecibos
                                 (nrecibo, cconcep, iconcep, cgarant, nriesgo)
                          VALUES (pnreccar, d.cconcep, ximporte, d.cgarant, d.nriesgo);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        BEGIN   -- Registro ya existe. Le sumamos el nuevo importe.
                           vpas := 1080;

                           UPDATE detrecibos
                              SET iconcep = iconcep + ximporte
                            WHERE nrecibo = pnreccar
                              AND cconcep = d.cconcep
                              AND cgarant = d.cgarant
                              AND nriesgo = d.nriesgo;
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN 104377;   -- Error al actualizar DETRECIBOS
                        END;
                     WHEN OTHERS THEN
                        RETURN 103513;   -- Error a l' inserir a DETRECIBOS
                  END;
               ELSE
                  BEGIN
                     vpas := 1090;

                     INSERT INTO detreciboscar
                                 (sproces, nrecibo, cconcep, iconcep, cgarant,
                                  nriesgo)
                          VALUES (psproces, pnreccar, d.cconcep, ximporte, d.cgarant,
                                  d.nriesgo);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        BEGIN   -- Registro ya existe. Le sumamos el nuevo importe.
                           vpas := 1100;

                           UPDATE detreciboscar
                              SET iconcep = iconcep + ximporte
                            WHERE nrecibo = pnreccar
                              AND cconcep = d.cconcep
                              AND cgarant = d.cgarant
                              AND nriesgo = d.nriesgo
                              AND sproces = psproces;
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN 104378;   -- Error al actualizar DETRECIBOS
                        END;
                     WHEN OTHERS THEN
                        RETURN 103517;   -- Error a l' inserir a DETRECIBOS
                  END;
               END IF;
            END LOOP;

            -- Borramos vdetrecibos del recibo de cartera para recalcularlo.
            BEGIN
               IF pmodo = 'R' THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 1110;

                  DELETE FROM vdetrecibos_monpol
                        WHERE nrecibo = pnreccar;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 1120;

                  DELETE FROM vdetrecibos
                        WHERE nrecibo = pnreccar;
               ELSE
                  -- BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 1130;

                  DELETE FROM vdetreciboscar_monpol
                        WHERE nrecibo = pnreccar
                          AND sproces = psproces;

                  -- FIN BUG 18423 - 30/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 1140;

                  DELETE      vdetreciboscar
                        WHERE nrecibo = pnreccar
                          AND sproces = psproces;
               END IF;

               vpas := 1150;
               error := f_vdetrecibos(pmodo, pnreccar, psproces);

               IF error <> 0 THEN
                  RETURN error;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 105157;   -- Fallo al borrar el recibo absorvido
            END;

            IF pmodo = 'R' THEN
               -- Borramos el recibo de suplemento.
               BEGIN
                  vpas := 1160;

                  SELECT COUNT('x')
                    INTO xnumconc
                    FROM detrecibos
                   WHERE nrecibo = re.rec
                     AND cconcep IN(15, 16, 21, 65, 66, 71);
               EXCEPTION
                  WHEN OTHERS THEN
                     RETURN 103512;   -- error al leer de detrecibos
               END;

               IF xnumconc = 0 THEN
                  -- Podemos borrar el recibo porque se han fusionado todos sus conceptos
                  BEGIN
                     vpas := 1170;

                     INSERT INTO borraproces
                        (SELECT re.rec, f_sysdate, sseguro, f_user, 'FUSIONADO A ' || pnreccar  -- BUG 0041482 - FAL - 08/04/2016
                           FROM recibos
                          WHERE nrecibo = re.rec);

                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1180;

                     DELETE FROM vdetrecibos_monpol
                           WHERE nrecibo = re.rec;

                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1190;

                     DELETE FROM vdetrecibos
                           WHERE nrecibo = re.rec;

                     vpas := 1200;

                     DELETE      recibosredcom
                           WHERE nrecibo = re.rec;

                     vpas := 1210;

                     DELETE      movrecibo
                           WHERE nrecibo = re.rec;

                     vpas := 1230;

                     DELETE      detrecibos
                           WHERE nrecibo = re.rec;

                     vpas := 1240;

                     DELETE      recibos
                           WHERE nrecibo = re.rec;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 105115;   -- Fallo al borrar el recibo absorvido
                  END;
               ELSE
                  -- Borramos los conceptos que no sean de ventas y dejamos el recibo cobrado
                  BEGIN
                     vpas := 1250;

                     DELETE      detrecibos
                           WHERE nrecibo = re.rec
                             AND cconcep NOT IN(15, 16, 21, 65, 66, 71);

                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1260;

                     DELETE FROM vdetrecibos_monpol
                           WHERE nrecibo = re.rec;

                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1270;

                     DELETE FROM vdetrecibos
                           WHERE nrecibo = re.rec;

                     vpas := 1280;
                     error := f_vdetrecibos(pmodo, re.rec, psproces);

                     IF error <> 0 THEN
                        RETURN error;
                     END IF;

                     vpas := 1290;

                     IF pfefecar > pfemicar THEN
                        xfmovimi := pfefecar;
                     ELSE
                        xfmovimi := pfemicar;
                     END IF;

                     vpas := 1300;
                     error := f_movrecibo(re.rec, 1, NULL, NULL, xsmovagr, xnliqmen, xnliqlin,
                                          xfmovimi, NULL, re.cdelega, NULL, NULL);

                     IF error <> 0 THEN
                        RETURN error;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        RETURN 105885;   -- error al leer la informacion del recibo
                  END;
               END IF;
            END IF;
         END IF;
      END LOOP;
   END IF;

   RETURN 0;
-- ini Bug 0022027 - JMF - 24/04/2012
EXCEPTION
   WHEN OTHERS THEN
      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                  error || '-' || SQLCODE || ' ' || SQLERRM);
      RETURN 140999;
-- fin Bug 0022027 - JMF - 24/04/2012
END;

/

  GRANT EXECUTE ON "AXIS"."F_FUSIONSUPCAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_FUSIONSUPCAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_FUSIONSUPCAR" TO "PROGRAMADORESCSI";
