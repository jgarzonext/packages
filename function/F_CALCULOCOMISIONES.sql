--------------------------------------------------------
--  DDL for Function F_CALCULOCOMISIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_CALCULOCOMISIONES" (
   pnproces IN NUMBER,
   pnrecibo IN NUMBER,
   pploccoa IN NUMBER,
   pcgarant IN NUMBER,
   pnriesgo IN NUMBER,
   pctipcoa IN NUMBER,
   psseguro IN NUMBER,
   pmodo IN VARCHAR2,
   pcmodcom IN NUMBER,
   porcoagent IN NUMBER,
   porrtagent IN NUMBER)
   RETURN NUMBER IS
--
-- FUNCION DE CALCULO AUTOMÁTICO DE COMISIONES ASOCIADAS A UN RECIBO Y/O A UNA POLIZA
--
-- Esta funcion realiza la siguiente operativa:
--
-- 1.- Grabacion en la tabla de CALCOMISION_AUX de los datos necesarios para el calculo de los importes de comisiones
--
-- 2.- Mientras quede algun importe que calcular
--    Obtener conceptos a calcular
--    Ver si el concepto de cuyo calculo dependen ya ha sido calculado
--    Si ya esta calculado, realizar el calculo aplicando el porcentaje correspondiente
--    Si no, seguir con siguiente concepto no calculado
--
-- 3.- Bucle sobre la tabla CALCOMISION_AUX y grabación de dichos datos en la tabla de DETRECIBOS
--
-- 4.- Fin del programa
--
--
--
-- Cursor de obtencion del padre del agente cuyo recibo estamos tratando
--
   CURSOR cur_datgestor(e_nrecibo NUMBER) IS
      SELECT b.cpadre
        FROM recibos a, redcomercial b
       WHERE a.nrecibo = e_nrecibo
         AND b.cagente = a.cagente
         AND b.cempres = a.cempres
         AND b.ccomindt = 1
         AND b.fmovfin IS NULL;

--
-- Cursor de obtención de datos previos necesarios para el calculo de las comisiones
--
   CURSOR cur_calprev(e_nrecibo NUMBER, e_cgarant NUMBER, e_nriesgo NUMBER) IS
      SELECT cageven, nmovima, icalcom, pcalcom, icomcob, nmesagt, cgencom, cgendev
        FROM calcomisprev
       WHERE nrecibo = e_nrecibo
         AND cgarant = e_cgarant
         AND nriesgo = e_nriesgo;

   CURSOR cur_datgestor_car(e_nrecibo NUMBER) IS
      SELECT b.cpadre
        FROM reciboscar a, redcomercial b
       WHERE a.nrecibo = e_nrecibo
         AND b.cagente = a.cagente
         AND b.cempres = a.cempres
         AND b.ccomindt = 1
         AND b.fmovfin IS NULL;

   CURSOR cur_datcobrador(e_nrecibo NUMBER) IS
      SELECT a.cagecob, b.ccomisi
        FROM agentescob a, agentes b
       WHERE a.nrecibo = e_nrecibo
         AND b.cagente = a.cagecob
         AND a.ccomcob = 1;

   CURSOR cur_datcobrador_car(e_nrecibo NUMBER) IS
      SELECT a.cagecob, b.ccomisi
        FROM agentescobcar a, agentes b
       WHERE a.nrecibo = e_nrecibo
         AND b.cagente = a.cagecob
         AND a.ccomcob = 1;

--
-- Cursor de obtención de conceptos de comisiones y retenciones
--
   CURSOR cur_calcomis(e_nrecibo NUMBER, e_ccomindt NUMBER, e_ccomdevn NUMBER) IS
      SELECT   a.cconcept, a.ccomindt, a.ccomdevn, a.ctipcomi, a.ccondept, a.cagtecob,
               a.copnmese
          FROM calcomision a, recibos b, agentes c
         WHERE b.nrecibo = e_nrecibo
           AND c.cagente = b.cagente
           AND a.ccomisi = c.ccomisi
           AND(e_ccomindt IS NULL
               OR(a.ccomindt = e_ccomindt))
           AND(e_ccomdevn IS NULL
               OR(a.ccomdevn = e_ccomdevn))
           AND a.cagtecob = 0
      ORDER BY cconcept;

   CURSOR cur_calcomis_car(e_nrecibo NUMBER, e_ccomindt NUMBER, e_ccomdevn NUMBER) IS
      SELECT   a.cconcept, a.ccomindt, a.ccomdevn, a.ctipcomi, a.ccondept, a.cagtecob,
               a.copnmese
          FROM calcomision a, reciboscar b, agentes c
         WHERE b.nrecibo = e_nrecibo
           AND c.cagente = b.cagente
           AND a.ccomisi = c.ccomisi
           AND(e_ccomindt IS NULL
               OR(a.ccomindt = e_ccomindt))
           AND(e_ccomdevn IS NULL
               OR(a.ccomdevn = e_ccomdevn))
           AND a.cagtecob = 0
      ORDER BY cconcept;

--
-- Cursor de obtencion de conceptos de comisiones y retenciones para el Agente Cobrador
--
   CURSOR cur_calcomis_cob(e_ccomisi NUMBER, e_ccomindt NUMBER, e_ccomdevn NUMBER) IS
      SELECT   a.cconcept, a.ccomindt, a.ccomdevn, a.ctipcomi, a.ccondept, a.cagtecob,
               a.copnmese
          FROM calcomision a
         WHERE a.cagtecob = 1
           AND a.ccomisi = e_ccomisi
           AND(e_ccomindt IS NULL
               OR(a.ccomindt = e_ccomindt))
           AND(e_ccomdevn IS NULL
               OR(a.ccomdevn = e_ccomdevn))
      ORDER BY cconcept;

   CURSOR cur_calcomis_aux(e_nrecibo NUMBER) IS
      SELECT     cconcept, ccomindt, ccomdevn, ctipcomi, ccondept, cagtecob, cagente, ppercent,
                 importe, copnmese
            FROM calcomision_aux
           WHERE nrecibo = e_nrecibo
             AND importe IS NULL
        ORDER BY cconcept
      FOR UPDATE;

   CURSOR cur_insercion(e_nrecibo NUMBER) IS
      SELECT   cconcept, ccomindt, ccomdevn, ctipcomi, ccondept, cagtecob, cagente, ppercent,
               importe
          FROM calcomision_aux
         WHERE nrecibo = e_nrecibo
           AND NVL(importe, 0) <> 0
      ORDER BY cconcept;

   error          NUMBER := 0;
   error_proceso  EXCEPTION;
   r_calprev      cur_calprev%ROWTYPE;
   r_calcomis     cur_calcomis%ROWTYPE;
   r_calcomis_aux cur_calcomis_aux%ROWTYPE;
   r_insercion    cur_insercion%ROWTYPE;
   w_factor       NUMBER(2);
   w_nmeses_cliente seguros.cforpag%TYPE;
   w_nmeses_agente seguros.nmescob%TYPE;
   w_importe_primas detrecibos.iconcep%TYPE;
   w_importe_devengos detrecibos.iconcep%TYPE;
   w_importe_aux  calcomision_aux.importe%TYPE;
   w_importe_calculo calcomision_aux.importe%TYPE;
   w_importe      calcomision_aux.importe%TYPE;
   w_pct          comisionacti.pcomisi%TYPE;
   w_pct_comis    comisionacti.pcomisi%TYPE;
   w_pct_reten    comisionacti.pcomisi%TYPE;
   w_num_agente   agentes.cagente%TYPE;
   w_agte_prpal   agentes.cagente%TYPE;
   w_ccomisi_cob  calcomision.ccomisi%TYPE;
   w_cmodcom_aux  detvalores.catribu%TYPE;
   sw_fin_bucle   BOOLEAN := FALSE;
   w_num_aux      NUMBER(15);
   w_num_aux1     NUMBER(15);
   w_char_aux     VARCHAR2(2000);
BEGIN
--
-- Función para el cálculo de las comisiones vinculadas a un recibo.
--
--
-- Inicialmente obtendremos un factor que valdrá 1 si las comisiones se calculan sobre la Prima, 0 si se calculan
--   sobre el interés (en este ultimo caso, todos los registros que se generen en DETRECIBOS tendrán un importe 0).
--
   BEGIN
      SELECT DECODE(b.ccalcom, 1, 1, 0)
        INTO w_factor
        FROM seguros a, productos b
       WHERE a.sseguro = psseguro
         AND b.cramo = a.cramo
         AND b.cmodali = a.cmodali
         AND b.ctipseg = a.ctipseg
         AND b.ccolect = a.ccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         w_factor := 0;
      WHEN OTHERS THEN
         w_factor := 0;
   END;

--
-- Obtención de los datos previos necesarios para el calculo de la comision
--
   OPEN cur_calprev(pnrecibo, pcgarant, pnriesgo);

   FETCH cur_calprev
    INTO r_calprev;

   IF cur_calprev%NOTFOUND THEN
--    ERROR := 111927;
      error := 0;
      RAISE error_proceso;
   END IF;

   CLOSE cur_calprev;

--
-- Grabacion de registros en la tabla CALCOMISION_AUX para el agente original
--
   w_agte_prpal := r_calprev.cageven;
   w_num_agente := r_calprev.cageven;

--
-- Solo grabaremos registros si deben calcularse comisiones
--
   IF r_calprev.cgencom = 1
      OR r_calprev.cgendev = 1 THEN
      IF pmodo = 'R' THEN   -- (MODE REAL PRODUCCIÓ I CARTERA)
         IF r_calprev.cgendev = 1 THEN
            w_num_aux1 := NULL;
         ELSE
            w_num_aux1 := 0;
         END IF;

         OPEN cur_calcomis(pnrecibo, 0, w_num_aux1);

         FETCH cur_calcomis
          INTO r_calcomis;

         WHILE NOT(cur_calcomis%NOTFOUND) LOOP
            BEGIN
               INSERT INTO calcomision_aux
                           (nrecibo, cconcept, ccomindt,
                            ccomdevn, ctipcomi, cagtecob,
                            ccondept, cagente, ppercent, importe, copnmese)
                    VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                            r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                            r_calcomis.ccondept, w_num_agente, NULL, NULL, r_calcomis.copnmese);
            EXCEPTION
               WHEN OTHERS THEN
                  error := 110821;
                  RAISE error_proceso;
            END;

            FETCH cur_calcomis
             INTO r_calcomis;
         END LOOP;

         CLOSE cur_calcomis;
      ELSE
         IF r_calprev.cgendev = 1 THEN
            w_num_aux1 := NULL;
         ELSE
            w_num_aux1 := 0;
         END IF;

         OPEN cur_calcomis_car(pnrecibo, 0, w_num_aux1);

         FETCH cur_calcomis_car
          INTO r_calcomis;

         WHILE NOT(cur_calcomis_car%NOTFOUND) LOOP
            BEGIN
               INSERT INTO calcomision_aux
                           (nrecibo, cconcept, ccomindt,
                            ccomdevn, ctipcomi, cagtecob,
                            ccondept, cagente, ppercent, importe, copnmese)
                    VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                            r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                            r_calcomis.ccondept, w_num_agente, NULL, NULL, r_calcomis.copnmese);
            EXCEPTION
               WHEN OTHERS THEN
                  error := 110821;
                  RAISE error_proceso;
            END;

            FETCH cur_calcomis_car
             INTO r_calcomis;
         END LOOP;

         CLOSE cur_calcomis_car;
      END IF;
   END IF;

--
-- Si dicho agente tiene un gestor al que aplicar comisiones indirectas, grabamos
--  los conceptos de comisiones indirectas en la tabla auxiliar
--
   IF r_calprev.cgencom = 1
      OR r_calprev.cgendev = 1 THEN
      IF pmodo = 'R' THEN   -- (MODE REAL PRODUCCIÓ I CARTERA)
         OPEN cur_datgestor(pnrecibo);

         FETCH cur_datgestor
          INTO w_num_agente;

         IF cur_datgestor%NOTFOUND THEN
            NULL;   -- No hacemos nada
         ELSE
            IF r_calprev.cgendev = 1 THEN
               w_num_aux1 := NULL;
            ELSE
               w_num_aux1 := 0;
            END IF;

            OPEN cur_calcomis(pnrecibo, 1, w_num_aux1);

            FETCH cur_calcomis
             INTO r_calcomis;

            WHILE NOT(cur_calcomis%NOTFOUND) LOOP
               BEGIN
                  INSERT INTO calcomision_aux
                              (nrecibo, cconcept, ccomindt,
                               ccomdevn, ctipcomi, cagtecob,
                               ccondept, cagente, ppercent, importe,
                               copnmese)
                       VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                               r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                               r_calcomis.ccondept, w_num_agente, NULL, NULL,
                               r_calcomis.copnmese);
               EXCEPTION
                  WHEN OTHERS THEN
                     error := 110822;
                     RAISE error_proceso;
               END;

               FETCH cur_calcomis
                INTO r_calcomis;
            END LOOP;

            CLOSE cur_calcomis;
         END IF;

         CLOSE cur_datgestor;
      ELSE
         OPEN cur_datgestor_car(pnrecibo);

         FETCH cur_datgestor_car
          INTO w_num_agente;

         IF cur_datgestor_car%NOTFOUND THEN
            NULL;   -- No hacemos nada
         ELSE
            IF r_calprev.cgendev = 1 THEN
               w_num_aux1 := NULL;
            ELSE
               w_num_aux1 := 0;
            END IF;

            OPEN cur_calcomis_car(pnrecibo, 1, w_num_aux1);

            FETCH cur_calcomis_car
             INTO r_calcomis;

            WHILE NOT(cur_calcomis_car%NOTFOUND) LOOP
               BEGIN
                  INSERT INTO calcomision_aux
                              (nrecibo, cconcept, ccomindt,
                               ccomdevn, ctipcomi, cagtecob,
                               ccondept, cagente, ppercent, importe,
                               copnmese)
                       VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                               r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                               r_calcomis.ccondept, w_num_agente, NULL, NULL,
                               r_calcomis.copnmese);
               EXCEPTION
                  WHEN OTHERS THEN
                     error := 110822;
                     RAISE error_proceso;
               END;

               FETCH cur_calcomis_car
                INTO r_calcomis;
            END LOOP;

            CLOSE cur_calcomis_car;
         END IF;

         CLOSE cur_datgestor_car;
      END IF;
   END IF;

--
-- Miramos si dicho recibo tiene, ademas, un cobrador, en cuyo caso debemos grabar los conceptos
--   asociados a las comisiones de dicho cobrador
--
   IF pmodo = 'R' THEN
      OPEN cur_datcobrador(pnrecibo);

      FETCH cur_datcobrador
       INTO w_num_agente, w_ccomisi_cob;

      IF cur_datcobrador%NOTFOUND THEN
         NULL;   -- No hacemos nada
      ELSE
         IF r_calprev.cgendev = 1 THEN
            w_num_aux1 := NULL;
         ELSE
            w_num_aux1 := 0;
         END IF;

         OPEN cur_calcomis_cob(w_ccomisi_cob, 0, w_num_aux1);

         FETCH cur_calcomis_cob
          INTO r_calcomis;

         WHILE NOT(cur_calcomis_cob%NOTFOUND) LOOP
            BEGIN
               INSERT INTO calcomision_aux
                           (nrecibo, cconcept, ccomindt,
                            ccomdevn, ctipcomi, cagtecob,
                            ccondept, cagente, ppercent, importe, copnmese)
                    VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                            r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                            r_calcomis.ccondept, w_num_agente, NULL, NULL, r_calcomis.copnmese);
            EXCEPTION
               WHEN OTHERS THEN
                  error := 110822;
                  RAISE error_proceso;
            END;

            FETCH cur_calcomis_cob
             INTO r_calcomis;
         END LOOP;

         CLOSE cur_calcomis_cob;
      END IF;

      CLOSE cur_datcobrador;
   ELSE
      OPEN cur_datcobrador_car(pnrecibo);

      FETCH cur_datcobrador_car
       INTO w_num_agente, w_ccomisi_cob;

      IF cur_datcobrador_car%NOTFOUND THEN
         NULL;   -- No hacemos nada
      ELSE
         IF r_calprev.cgendev = 1 THEN
            w_num_aux1 := NULL;
         ELSE
            w_num_aux1 := 0;
         END IF;

         OPEN cur_calcomis_cob(w_ccomisi_cob, 0, w_num_aux1);

         FETCH cur_calcomis_cob
          INTO r_calcomis;

         WHILE NOT(cur_calcomis_cob%NOTFOUND) LOOP
            BEGIN
               INSERT INTO calcomision_aux
                           (nrecibo, cconcept, ccomindt,
                            ccomdevn, ctipcomi, cagtecob,
                            ccondept, cagente, ppercent, importe, copnmese)
                    VALUES (pnrecibo, r_calcomis.cconcept, r_calcomis.ccomindt,
                            r_calcomis.ccomdevn, r_calcomis.ctipcomi, r_calcomis.cagtecob,
                            r_calcomis.ccondept, w_num_agente, NULL, NULL, r_calcomis.copnmese);
            EXCEPTION
               WHEN OTHERS THEN
                  error := 110822;
                  RAISE error_proceso;
            END;

            FETCH cur_calcomis_cob
             INTO r_calcomis;
         END LOOP;

         CLOSE cur_calcomis_cob;
      END IF;

      CLOSE cur_datcobrador_car;
   END IF;

--
-- Inicio del bucle de tratamiento de los importes de comisiones
--
   WHILE NOT sw_fin_bucle LOOP
      OPEN cur_calcomis_aux(pnrecibo);

      FETCH cur_calcomis_aux
       INTO r_calcomis_aux;

      IF cur_calcomis_aux%NOTFOUND THEN
--
-- No quedan importes por tratar y salimos del bucle
--
         sw_fin_bucle := TRUE;
      ELSE
--
-- Tratamiento de las comisiones
--
         WHILE NOT(cur_calcomis_aux%NOTFOUND) LOOP
--
-- Obtenemos el importe acumulado para ese concepto en la tabla de DETRECIBOS
--
/*      IF PMODO = 'R' THEN -- (MODE REAL PRODUCCIÓ I CARTERA)
        W_CMODCOM_AUX := 1 + 2*R_CALCOMIS_AUX.CCOMINDT;
      ELSE
        W_CMODCOM_AUX := 2 + 2*R_CALCOMIS_AUX.CCOMINDT;
      END IF;
*/
            w_cmodcom_aux := pcmodcom;

            IF w_factor = 1 THEN
               IF (r_calcomis_aux.cagente = w_agte_prpal
                   AND r_calcomis_aux.cagtecob = 0) THEN
                  error := f_pcomisi(psseguro, w_cmodcom_aux, F_SYSDATE, w_pct_comis,
                                     w_pct_reten, NULL, NULL, NULL, NULL, NULL, NULL,
                                     pcgarant);

                  IF error <> 0 THEN
                     w_pct_comis := 0;
                     w_pct_reten := 0;
                  END IF;
               ELSE
                  error := f_pcomisi_agente(psseguro, r_calcomis_aux.cagente, w_cmodcom_aux,
                                            F_SYSDATE, w_pct_comis, w_pct_reten, NULL, NULL,
                                            NULL, NULL, NULL, pcgarant);

                  IF error <> 0 THEN
                     w_pct_comis := 0;
                     w_pct_reten := 0;
                  END IF;
               END IF;
            ELSE
               w_pct_comis := 0;
               w_pct_reten := 0;
            END IF;   -- del IF W_FACTOR = 1 THEN ...

--
-- Si el importe no depende para su calculo de ningun otro, lo calculamos ya y lo grabamos en la tabla CALCOMISION_AUX.
--   Si no, obtenemos el importe del concepto del que depende. Si ya está calculado, podemos obtener la comsision
--
            IF r_calcomis_aux.ccondept IS NULL THEN
               IF r_calcomis_aux.ctipcomi = 1 THEN
                  w_pct := w_pct_comis;
               ELSIF r_calcomis_aux.ctipcomi = 2 THEN
                  w_pct := w_pct_reten;
               ELSE
                  w_pct := 0;
               END IF;

               IF r_calcomis_aux.cagtecob = 0 THEN
                  w_importe := r_calprev.icalcom;

                  IF r_calcomis_aux.ccomindt = 0 THEN
--
-- Si es el agte prpal, aplicamos la forma de pago que pudiera tener
--
                     w_importe_calculo := NVL((r_calprev.pcalcom * w_factor * w_pct * w_importe)
                                              /(r_calprev.nmesagt * 100),
                                              0);
                  ELSE
                     w_importe_calculo := NVL((w_factor * w_pct * w_importe) / 100, 0);
                  END IF;
               ELSE
                  w_importe := r_calprev.icomcob;
                  w_importe_calculo := NVL((w_pct * w_importe) / 100, 0);
               END IF;

               UPDATE calcomision_aux
                  SET ppercent = NVL(w_pct, 0),
                      importe = w_importe_calculo
                WHERE CURRENT OF cur_calcomis_aux;
            ELSE
--
-- Obtencion del importe del concepto del que depende
--
               SELECT importe
                 INTO w_importe_aux
                 FROM calcomision_aux
                WHERE nrecibo = pnrecibo
                  AND cconcept = r_calcomis_aux.ccondept;

               IF w_importe_aux IS NULL THEN
                  NULL;
               ELSE
                  IF r_calcomis_aux.ctipcomi = 1 THEN
                     w_pct := w_pct_comis;
                  ELSIF r_calcomis_aux.ctipcomi = 2 THEN
                     w_pct := w_pct_reten;
                  ELSE
                     w_pct := 0;
                  END IF;

                  w_importe := w_importe_aux;

                  IF r_calcomis_aux.cagtecob = 0 THEN
--
-- Si no es el agte cobrador, aplicamos la forma de pago que pudiera tener
--
                     w_importe_calculo := NVL((w_factor * w_pct * w_importe) / 100, 0);
                  ELSE
                     w_importe_calculo := NVL((w_factor * w_pct * w_importe) / 100, 0);
                  END IF;

                  UPDATE calcomision_aux
                     SET ppercent = NVL(w_pct, 0),
                         importe = w_importe_calculo
                   WHERE CURRENT OF cur_calcomis_aux;
               END IF;
            END IF;   -- del IF R_CALCOMIS_AUX.CCONDEPT IS NULL THEN

            FETCH cur_calcomis_aux
             INTO r_calcomis_aux;
         END LOOP;   -- del WHILE NOT (CUR_CALCOMIS_AUX%NOTFOUND) LOOP

         CLOSE cur_calcomis_aux;
      END IF;   -- del IF CUR_CALCOMIS_AUX%NOTFOUND THEN
   END LOOP;   -- del WHILE NOT SW_FIN_BUCLE LOOP

--
-- Finalmente, nos recorremos la tabla de CALCOMISION_AUX y vamos insertando los registros en el detalle de recibos
--
   OPEN cur_insercion(pnrecibo);

   FETCH cur_insercion
    INTO r_insercion;

   WHILE NOT(cur_insercion%NOTFOUND) LOOP
--
-- Inserción de un registro en DETRECIBOS o en DETRECIBOSCAR, segun toque
--
      IF r_calcomis_aux.ctipcomi = 1 THEN
         w_pct := porcoagent;
      ELSIF r_calcomis_aux.ctipcomi = 2 THEN
         w_pct := porrtagent;
      ELSE
         w_pct := 0;
      END IF;

      IF pmodo = 'R' THEN   -- (MODE REAL PRODUCCIÓ I CARTERA)
         error := f_insdetrec(pnrecibo, r_insercion.cconcept, r_insercion.importe, pploccoa,
                              pcgarant, NVL(pnriesgo, 0), pctipcoa, r_calprev.cageven,
                              r_calprev.nmovima, 100, psseguro, pcmodcom);
      ELSE
         error := f_insdetreccar(pnproces, pnrecibo, r_insercion.cconcept,
                                 r_insercion.importe, pploccoa, pcgarant, NVL(pnriesgo, 0),
                                 pctipcoa, r_calprev.cageven, r_calprev.nmovima, 100,
                                 psseguro);
      END IF;

      IF error <> 0 THEN
         RAISE error_proceso;
      END IF;

      FETCH cur_insercion
       INTO r_insercion;
   END LOOP;

   CLOSE cur_insercion;

--
-- Por ultimo, borramos los datos de la tabla auxiliar
--
   DELETE FROM calcomision_aux
         WHERE nrecibo = pnrecibo;

   RETURN 0;
EXCEPTION
   WHEN error_proceso THEN
      IF cur_calprev%ISOPEN THEN
         CLOSE cur_calprev;
      END IF;

      IF cur_calcomis%ISOPEN THEN
         CLOSE cur_calcomis;
      END IF;

      IF cur_calcomis_cob%ISOPEN THEN
         CLOSE cur_calcomis_cob;
      END IF;

      -- BUG 21546_108724 - 04/02/2012 - JLTS - Se cierra el cursor
      IF cur_calcomis_car%ISOPEN THEN
         CLOSE cur_calcomis_car;
      END IF;

      IF cur_datcobrador%ISOPEN THEN
         CLOSE cur_datcobrador;
      END IF;

      IF cur_datcobrador_car%ISOPEN THEN
         CLOSE cur_datcobrador_car;
      END IF;

      IF cur_calcomis_aux%ISOPEN THEN
         CLOSE cur_calcomis_aux;
      END IF;

      IF cur_datgestor%ISOPEN THEN
         CLOSE cur_datgestor;
      END IF;

      IF cur_datgestor_car%ISOPEN THEN
         CLOSE cur_datgestor_car;
      END IF;

      IF cur_insercion%ISOPEN THEN
         CLOSE cur_insercion;
      END IF;

      DELETE FROM calcomision_aux
            WHERE nrecibo = pnrecibo;

      RETURN error;
   WHEN OTHERS THEN
      IF cur_calprev%ISOPEN THEN
         CLOSE cur_calprev;
      END IF;

      IF cur_calcomis%ISOPEN THEN
         CLOSE cur_calcomis;
      END IF;

      -- BUG 21546_108724 - JLTS - Se cierra el cursor
      IF cur_calcomis_car%ISOPEN THEN
         CLOSE cur_calcomis_car;
      END IF;

      IF cur_calcomis_cob%ISOPEN THEN
         CLOSE cur_calcomis_cob;
      END IF;

      IF cur_datcobrador%ISOPEN THEN
         CLOSE cur_datcobrador;
      END IF;

      IF cur_datcobrador_car%ISOPEN THEN
         CLOSE cur_datcobrador_car;
      END IF;

      IF cur_calcomis_aux%ISOPEN THEN
         CLOSE cur_calcomis_aux;
      END IF;

      IF cur_datgestor%ISOPEN THEN
         CLOSE cur_datgestor;
      END IF;

      IF cur_datgestor_car%ISOPEN THEN
         CLOSE cur_datgestor_car;
      END IF;

      IF cur_insercion%ISOPEN THEN
         CLOSE cur_insercion;
      END IF;

      DELETE FROM calcomision_aux
            WHERE nrecibo = pnrecibo;

      RETURN 88;
END f_calculocomisiones;

/

  GRANT EXECUTE ON "AXIS"."F_CALCULOCOMISIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_CALCULOCOMISIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_CALCULOCOMISIONES" TO "PROGRAMADORESCSI";
