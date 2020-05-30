--------------------------------------------------------
--  DDL for Function F_ANULASEG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_ANULASEG" (
/******************************************************************************
   NOMBRE:       F_ANULASEG
   PROPÓSITO: Función para anular una póliza

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/01/2008    XXX              1. Creación del package.
   2.0        26/02/2010    ICV              2. 0013068: CRE - Grabar el motivo de la anulación al anular la póliza
   3.         28/05/2010    AVT              3. 0014536: CRE200 - Reaseguro: Se requiere que un contrato se pueda
                                                utilizar en varias agrupaciones de producto
   4.0        16/08/2010    JRH              4. 0015751: ENSA800 - Error en F_ANULASEG al anular una póliza sin movimientos en ctaseguro
   5.0        15/03/2010    JMF              5. BUG 0013477: ENSA101 - Nueva pantalla de Gestión Pagos Rentas
   6.0        06/07/2010    SRA              6. 0018990: CCAT800-La anul.lació de la pòlissa està anul.lant pagaments de rendes pagades
   7.0        14/12/2011    JMP              7. 0018423: LCOL705 - Multimoneda
   8.0        17/02/2014    JDS              7. 0027421: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 96 - Recibos remesados en anulaciones
   9.0        20/03/2014    DRA              8. 0027421: POSAN600-(POSDE600)-Desarrollo-GAPS Tecnico-Id 96 - Recibos remesados en anulaciones
******************************************************************************/
   psseguro IN NUMBER,
   pcanuext IN NUMBER,
   pfanulac IN DATE,
   pcmotmov IN NUMBER,
   pnrecibo IN NUMBER,
   pcsituac IN NUMBER,
   pnmovimi OUT NUMBER,
   pcnotibaja IN NUMBER DEFAULT NULL,
   pmoneda IN NUMBER DEFAULT 1,
   psproces IN NUMBER DEFAULT NULL,
   pccauanul IN NUMBER DEFAULT NULL)
   RETURN NUMBER AUTHID CURRENT_USER IS
/************************************************************************
 F_ANULASEG  Anula un seguro, devuelve 0 si todo ha ido bien
    sino devuelve 1
 ALLIBCTR

  Se le añade un parámetro de entrada pcsituac
  Afegim el SMOVSEG
  Suprimimos el campo SMOVSEG
  Retornem el Nmovimi
  Se cambia la función f_mesconta por f_fcontab
  Se utiliza la función f_movseguro
  Crea un movimiento en ctaseguro para plan.pensiones
  Se modifica la tabla SEGUROS_REN para inf. fecha anulacion Renta
  Se graba en la tabla historicoseguros.
  Anulació dels pagosrentas->movpagren
  Notificion de baja y cambio de numero de error.
  Notificació de l'anul·lació a CARTAAVIS (CSC)
*************************************************************************/
   mov            NUMBER;
   secuencia      NUMBER;
   num_err        NUMBER;
   tipo_seguro    NUMBER(8);
   linea          NUMBER;
   lineashw       NUMBER;
   --SMF :pagosrenta amb pagos pendents
   v_smovpag      NUMBER;
   v_movfin       DATE;

   CURSOR ries IS
      SELECT nriesgo
        FROM riesgos
       WHERE sseguro = psseguro
         AND fanulac IS NULL;

   CURSOR c IS
      SELECT srecren
        FROM pagosrenta
       WHERE ffecpag >= pfanulac
         AND sseguro = psseguro;

   CURSOR riesgos IS
      SELECT nriesgo, sseguro
        FROM riesgos
       WHERE sseguro = psseguro
         AND fanulac IS NULL;

   CURSOR garantias IS
      SELECT cgarant, nriesgo, nmovimi, sseguro, finiefe   --, nmovima
        FROM garanseg
       WHERE sseguro = psseguro
         AND ffinefe IS NULL;

   carta          NUMBER;   --IPS
   xnrecibo       NUMBER;   --IPS
   ncesta         NUMBER;
   nunidades      NUMBER :=0;
   provmat      NUMBER:=0;
   iuniact        NUMBER:=0;
   marca          NUMBER := 0;   --IPS
   lcempres       NUMBER;
   proceso        NUMBER;
   cumulo         NUMBER;
   v_sproduc      NUMBER;
   v_sysdate      DATE;
   v_cvalpar      NUMBER;
   v_cont_recibos NUMBER;
   v_tieneshw     NUMBER;
BEGIN
   v_tieneshw := pac_ctaseguro.f_tiene_ctashadow(psseguro, NULL);

   -- Dades de seguros
   BEGIN
      SELECT cagrpro, cempres, sproduc
        INTO tipo_seguro, lcempres, v_sproduc
        FROM seguros
       WHERE seguros.sseguro = psseguro;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 101919;
   END;

   num_err := f_parproductos(v_sproduc, 'PERMITE_ANUL_REM', v_cvalpar);

   IF num_err <> 0 THEN
      RETURN num_err;
   END IF;

   IF (v_cvalpar = 0) THEN
      num_err := pac_adm.f_recibos_remesados(psseguro);

      IF (num_err > 0) THEN
         RETURN 9906501;   --No se puede anular la póliza porque hay recibos remesados.
      END IF;
   END IF;

   -- Primer de tot farem la retrocessió de la cessió de la Reassegurança
   IF psproces IS NULL THEN
      num_err := f_procesini(f_user, lcempres, 'F_ANULASEG', 'Baixa reassegurança', proceso);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;
   ELSE
      proceso := psproces;
   END IF;

   --AAC Abans de res cal calcular la provisio, si ho fem despres la polissa ja estara anulada i no en tindra
   IF NVL(f_parproductos_v(v_sproduc, 'ANUL_POL_BAJA_PARTIC'), 0) = 1 THEN
                    P_CONTROL_ERROR('AAC', 'f_anulaseg: ANUL_POL_BAJA_PARTIC = 1','debug');

            SELECT ccesta
              INTO ncesta
              FROM segdisin2
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2 s2
                               WHERE s2.sseguro = psseguro);

P_CONTROL_ERROR('AAC', 'f_anulaseg: ncesta = ' || ncesta,'debug');
            --Buscamos cuantas ups le quedan en base a la provision de la poliza
            SELECT iuniact
              INTO iuniact
              FROM tabvalces
             WHERE ccesta = ncesta
               AND TRUNC(fvalor) = TRUNC(f_sysdate);

               P_CONTROL_ERROR('AAC', 'f_anulaseg: iuniact = ' || iuniact,'debug');

              FOR regs in (SELECT ccesta, pdistrec
           FROM segdisin2
          WHERE sseguro = psseguro
            AND ffin IS NULL
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM segdisin2
                            WHERE sseguro = psseguro
                              AND ffin IS NULL))
                              loop

              SELECT NVL(SUM(nunidad), 0)
                 INTO provmat
                 FROM ctaseguro
                WHERE sseguro = psseguro
                  --and cmovimi <> 0
                  --AND cmovimi NOT IN(0, 91, 93, 94, 97)   -- Bug 10846 - RSC - 13/10/2009 - CRE - Operaciones con Fondos
                  AND cesta = regs.ccesta
                  -- bug 2312 - MDS - truncar las dos fechas
                  AND TRUNC(fvalmov) <= TRUNC(f_sysdate)
                  AND((cestado <> '9')
                      OR(cestado = '9'
                         AND imovimi <> 0
                         AND imovimi IS NOT NULL));
                        nunidades:=nunidades + provmat;
                                       P_CONTROL_ERROR('AAC', 'f_anulaseg: provmat = ' || provmat,'debug');

                              end loop;
              -- provmat := NVL(pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,'IPROVAC'),0);

               P_CONTROL_ERROR('AAC', 'f_anulaseg: provmat = ' || provmat,'debug');

               nunidades:= nunidades * -1;
               P_CONTROL_ERROR('AAC', 'debug','f_anulaseg: nunidades = ' || nunidades);

               END IF;

   --DBMS_OUTPUT.put_line(' VA A F_ATRAS ');
   --  SE TIRAN ATRÁS LAS CESIONES DE LA PÓLIZA ANULADA...
   -- BUG: 14536 AVT 28-05-2010 la gestió del reasseguro esta repetida al pac_anulacion.f_baja_rea
   --   num_err := f_atras(proceso, psseguro, pfanulac, 6, pmoneda, NULL);
   IF num_err = 0 THEN
      /* -- BUG: 14536 AVT 28-05-2010 la gestió del reasseguro esta repetida al pac_anulacion.f_baja_rea
         FOR i IN ries LOOP
            --DBMS_OUTPUT.put_line(' BUSCA CUMUL ');
            BEGIN
               SELECT MAX(scumulo)
                 INTO cumulo
                 FROM reariesgos
                WHERE sseguro = psseguro
                  AND nriesgo = i.nriesgo
                  AND freafin IS NULL;

               IF cumulo IS NOT NULL THEN
                  --DBMS_OUTPUT.put_line(' BAJA CUMULO ');
                  num_err := f_bajacu(psseguro, pfanulac);

                  IF num_err = 0 THEN
                     --DBMS_OUTPUT.put_line(' F_CUMULO ');
                     num_err := f_cumulo(proceso, cumulo, pfanulac, 1, pmoneda);

                     IF num_err <> 0 THEN
                        EXIT;
                     END IF;
                  ELSE
                     EXIT;
                  END IF;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
            END;
         END LOOP;
        IF num_err = 0 THEN */ -- BUG: 14536 AVT 28-05-2010 fi
            --Ini Bug.: 13068 - 26/02/2010 - ICV - Se añade el paso del parametro PCCAUANUL
            --Se utiliza f_movseguro.
      num_err := f_movseguro(psseguro, NULL, pcmotmov, 3, pfanulac, pcanuext, NULL, 0, NULL,
                             pnmovimi, NULL, NULL, pccauanul);

      --Fin Bug.: 13068
      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Se llama a f_act_hisseg para guardar la situación anterior a la anulación.
      -- El nmovimi es el anterior al de la anulación, por eso se le resta uno al
      -- recién creado.
      num_err := f_act_hisseg(psseguro, pnmovimi - 1);

      IF num_err <> 0 THEN
         RETURN num_err;
      END IF;

      -- Se actualiza la tabla seguros
      BEGIN
         UPDATE seguros
            SET fanulac = pfanulac,
                csituac = pcsituac
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 102361;
      END;

      -- BUG: 0013477 JMF 15/03/2010: Afegir prestaren
      DECLARE
         v_agr          productos.cagrpro%TYPE;
      BEGIN
         SELECT MAX(cagrpro)
           INTO v_agr
           FROM productos
          WHERE sproduc = v_sproduc;

         IF v_agr = 10 THEN
            --  Voy a mirar si este seguro es de Rentas. Accediendo a la tabla
            --  SEGUROS_REN si existe modifico la fecha fin de la renta.
            UPDATE seguros_ren
               SET ffinren = pfanulac,
                   cmotivo = pcmotmov
             WHERE sseguro = psseguro;
         ELSIF v_agr = 11 THEN
            UPDATE prestaren
               SET cestado = 2,
                   ffinren = pfanulac
             WHERE sseguro = psseguro
               AND cestado IN(0, 1);
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 111281;
      END;

      --genero el moviment d'anulació per cada un dels pagos que
      --estan pendents.
      FOR cur IN c LOOP
         -- Ini bug 18990 - 06/07/2011 - SRA: controlem que l'anul.lació de pagaments només es realitza per aquells
         -- que estàn en estat pendent de pagament
         DECLARE
            vcestrec       movpagren.cestrec%TYPE;
         BEGIN
            --miro el darrer moviment per el rebut de rendes.
            BEGIN
               SELECT   MAX(smovpag), fmovini
                   INTO v_smovpag, v_movfin
                   FROM movpagren
                  WHERE srecren = cur.srecren
                    AND fmovini = (SELECT MAX(fmovini)
                                     FROM movpagren
                                    WHERE srecren = cur.srecren)
               GROUP BY fmovini;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  v_smovpag := 0;
                  v_movfin := f_sysdate;
            END;

            -- bug 18990: busquem l'estat del pagament per a no anul.lar-lo en cas de que estigue
            -- en un estat diferent de pendent de pagament.
            BEGIN
               SELECT cestrec
                 INTO vcestrec
                 FROM movpagren
                WHERE srecren = cur.srecren
                  AND smovpag = v_smovpag;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  vcestrec := NULL;
            END;

            -- bug 18990:  només si el pagament està pendent, s'anul.la el moviment
            IF vcestrec = 0 THEN
               -- Fin bug 18990 - 06/07/2011 - SRA
               IF (v_smovpag IS NULL) THEN
                  --si el moviment de pagament es null fem el matiex que quan no troba res
                  v_smovpag := 0;
                  v_movfin := f_sysdate;
               END IF;

               --Actualitzem el darrer moviment del pagament--fecha fin
               UPDATE movpagren
                  SET fmovfin = v_movfin
                WHERE smovpag = v_smovpag
                  AND srecren = cur.srecren;

               --Generem el nou moviment (mov d'anul·lació)
               v_smovpag := v_smovpag + 1;

               INSERT INTO movpagren
                           (srecren, smovpag, cestrec, fmovini, fmovfin, fefecto)
                    VALUES (cur.srecren, v_smovpag, 2, v_movfin, NULL, pfanulac);
            END IF;
         END;
      END LOOP;

      --            Voy a mirar si el seguro es de planes de pensiones
      --                  para que me cree un movimiento de anulación de póliza
      --                  en el ctaseguro.
      IF tipo_seguro = 11 THEN
         -- BUG 0015751 - 08/2010 - JRH  -  Error en slect max, falta nvl
         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO linea
           FROM ctaseguro
          WHERE ctaseguro.sseguro = psseguro;

         IF NVL(f_parproductos_v(v_sproduc, 'ANUL_POL_BAJA_PARTIC'), 0) = 1 THEN

			P_CONTROL_ERROR('AAC', 'f_anulaseg: ANUL_POL_BAJA_PARTIC = 1','debug');
            P_CONTROL_ERROR('AAC', 'f_anulaseg: nunidades = ' || nunidades,'debug');


			SELECT ccesta
              INTO ncesta
              FROM segdisin2
             WHERE sseguro = psseguro
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM segdisin2 s2
                               WHERE s2.sseguro = psseguro);

            --Buscamos cuantas ups le quedan en base a la provision de la poliza
            SELECT NVL(pac_provmat_formul.f_calcul_formulas_provi(psseguro, f_sysdate,
                                                                  'IPROVAC'),
                       0)
                   / iuniact * -1
              INTO nunidades
              FROM tabvalces
             WHERE ccesta = ncesta
               AND TRUNC(fvalor) = TRUNC(f_sysdate);

            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         ccalint, nparpla, cestpar, cmovanu, cesta, nunidad, cestado, fasign)
                 VALUES (psseguro, pfanulac, linea, pfanulac, pfanulac, 54, 0,
                         0, 0, 1, 0, ncesta, nunidades, 2, f_sysdate);

            UPDATE fondos
               SET nparasi = nparasi + nunidades
             WHERE ccodfon = ncesta;
         ELSE
            -- Fi BUG 0015751 - 08/2010 - JRH
						P_CONTROL_ERROR('AAC', 'f_anulaseg: ANUL_POL_BAJA_PARTIC = 0','debug');
            INSERT INTO ctaseguro
                        (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi,
                         ccalint, nparpla, cestpar, cmovanu)
                 VALUES (psseguro, pfanulac, linea, pfanulac, pfanulac, 54, 0,
                         0, 0, 1, 0);
         END IF;

         IF num_err <> 0 THEN
            RETURN 111914;
         END IF;

         -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(lcempres, 'MULTIMONEDA'), 0) = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_monpol(psseguro, pfanulac, linea,
                                                                  pfanulac);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      -- FIN BUG 18423 - 14/12/2011 - JMP - Multimoneda
      END IF;

      IF NVL(f_parproductos_v(v_sproduc, 'REGSALDO_ANU'), 0) = 1
         AND pac_anulacion.f_anulada_al_emitir(psseguro) = 0 THEN
         -- Si se tiene que insertar un registro de actualización en ctaseguro
         v_sysdate := f_sysdate;
         num_err := pac_ctaseguro.f_insctaseguro(psseguro, v_sysdate, NULL, TRUNC(v_sysdate),
                                                 TRUNC(v_sysdate), 0, 0, 0, 0, 0, 0, 0, NULL,
                                                 '2', 'R', NULL, pnmovimi, 0, 0);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      IF v_tieneshw = 1 THEN
         SELECT NVL(MAX(nnumlin), 0) + 1
           INTO lineashw
           FROM ctaseguro_shadow
          WHERE sseguro = psseguro;

         INSERT INTO ctaseguro_shadow
                     (sseguro, fcontab, nnumlin, ffecmov, fvalmov, cmovimi, imovimi, ccalint,
                      nparpla, cestpar, cmovanu)
              VALUES (psseguro, pfanulac, lineashw, pfanulac, pfanulac, 54, 0, 0,
                      0, 1, 0);

         IF num_err <> 0 THEN
            RETURN 111914;
         END IF;

         -- BUG 18423 - 14/12/2011 - JMP - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(lcempres, 'MULTIMONEDA'), 0) = 1 THEN
            num_err := pac_oper_monedas.f_update_ctaseguro_shw_monpol(psseguro, pfanulac,
                                                                      lineashw, pfanulac);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;

         IF NVL(f_parproductos_v(v_sproduc, 'REGSALDO_ANU'), 0) = 1
            AND pac_anulacion.f_anulada_al_emitir(psseguro) = 0 THEN
            -- Si se tiene que insertar un registro de actualización en ctaseguro
            v_sysdate := f_sysdate;
            num_err := pac_ctaseguro.f_insctaseguro_shw(psseguro, v_sysdate, NULL,
                                                        TRUNC(v_sysdate), TRUNC(v_sysdate), 0,
                                                        0, 0, 0, 0, 0, 0, NULL, '2', 'R',
                                                        NULL, pnmovimi, 0, 0);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      END IF;

      /*
         -- notificación de baja
         IF f_parinstalacion_n('NOTIFIBAJA') = 1 THEN
            BEGIN
               UPDATE seguros
                  SET cnotibaja = pcnotibaja
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 111112;
            END;

            BEGIN
               FOR risc IN riesgos
               LOOP
                  BEGIN
                     INSERT INTO notibajaseg
                                 (sseguro, nmovimi, nriesgo, cnotibaja,
                                  cmotmov,crehab)
                          VALUES (psseguro, pnmovimi, risc.nriesgo, pcnotibaja,
                                  pcmotmov,0);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        UPDATE notibajaseg
                           SET cnotibaja = pcnotibaja,
                               cmotmov = pcmotmov,
                         crehab  = 0
                         WHERE sseguro = psseguro
                           AND nriesgo = risc.nriesgo;
                     WHEN OTHERS THEN
                        RETURN 112282;
                  END;
               END LOOP;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 112282;
            END;

            BEGIN
               FOR gar IN garantias
               LOOP
                  BEGIN
                     INSERT INTO notibajagar
                                 (sseguro, nriesgo, cgarant, nmovimi,
                                  finiefe, nmovima, nmovimb, cnotibaja,
                                  cmotmov, fanulac, crehab)
                          VALUES (psseguro, gar.nriesgo, gar.cgarant, gar.nmovimi,
                                  gar.finiefe, gar.nmovima, pnmovimi, pcnotibaja,
                                  pcmotmov, pfanulac, 0);
                  EXCEPTION
                     WHEN DUP_VAL_ON_INDEX THEN
                        BEGIN
                           UPDATE notibajagar
                              SET nmovimb = pnmovimi,
                                  cnotibaja = pcnotibaja,
                                  cmotmov = pcmotmov,
                                  fanulac = pfanulac
                           crehab  = 0
                            WHERE sseguro = psseguro
                              AND nriesgo = gar.nriesgo
                              AND cgarant = gar.cgarant
                              AND nmovimi = gar.nmovimi
                              AND finiefe = gar.finiefe
                              AND nmovima = gar.nmovima;
                        EXCEPTION
                           WHEN OTHERS THEN
                              RETURN 111915;
                        END;
                     WHEN OTHERS THEN
                        RETURN 111915;
                  END;
               END LOOP;
            EXCEPTION
               WHEN OTHERS THEN
                  RETURN 111915;
            END;
         END IF;

         --  gestion de tarjetas sanitarias ALN
         IF f_parinstalacion_t('TARJET_ALN') = 'SI' THEN
      --      num_err     := pac_tarjetcard.f_genera_alta(psseguro, f_user, pfanulac);

            IF num_err <> 0 THEN
               RETURN num_err;
            END IF;
         END IF;
      */

      --   Notificació de l'anul·lació a CARTAAVIS (CSC)
      BEGIN   -- IPS
         -- Anul·lacions sense extorn
         IF pcmotmov IN(301) THEN
            marca := 1;

            SELECT MAX(nrecibo)
              INTO xnrecibo
              FROM recibos
             WHERE sseguro = psseguro;

            marca := 2;
            carta := f_parinstalacion_n('CARANUCLI');
            marca := 3;

            IF carta IS NOT NULL
               AND xnrecibo IS NOT NULL THEN
               INSERT INTO cartaavis
                           (nrecibo, ctipcar)
                    VALUES (xnrecibo, carta);
            END IF;
         -- Anul·lacions amb extorn
         ELSIF pcmotmov IN(303, 306) THEN
            marca := 1;

            SELECT MAX(nrecibo)
              INTO xnrecibo
              FROM recibos
             WHERE sseguro = psseguro
               AND ctiprec = 9;

            marca := 2;
            carta := f_parinstalacion_n('CARANUCLIE');
            marca := 3;

            IF carta IS NOT NULL
               AND xnrecibo IS NOT NULL THEN
               INSERT INTO cartaavis
                           (nrecibo, ctipcar)
                    VALUES (xnrecibo, carta);
            END IF;
         -- Anul·lacions per alta sinistralitat
         ELSIF pcmotmov = 312 THEN
            marca := 1;

            SELECT MAX(nrecibo)
              INTO xnrecibo
              FROM recibos
             WHERE sseguro = psseguro;

            marca := 2;
            carta := f_parinstalacion_n('CARANUASIN');
            marca := 3;

            IF carta IS NOT NULL
               AND xnrecibo IS NOT NULL THEN
               INSERT INTO cartaavis
                           (nrecibo, ctipcar)
                    VALUES (xnrecibo, carta);
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            IF marca = 1 THEN
               RETURN 112280;
            ELSIF marca = 2 THEN
               RETURN 112281;
            ELSIF marca = 3 THEN
               RETURN 107720;
            END IF;
      END;   -- IPS
   --ELSE
   --   RETURN num_err;
   --END IF;  -- BUG: 14536 AVT 28-05-2010 fi
   ELSE
      RETURN num_err;
   END IF;

   RETURN 0;
EXCEPTION
   WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line(SQLERRM);
      p_tab_error(f_sysdate, f_user, 'F_ANULASEG', 1, 'OTHERS', SQLERRM);
END;

/

  GRANT EXECUTE ON "AXIS"."F_ANULASEG" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_ANULASEG" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_ANULASEG" TO "PROGRAMADORESCSI";
