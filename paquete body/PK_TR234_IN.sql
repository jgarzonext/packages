--------------------------------------------------------
--  DDL for Package Body PK_TR234_IN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PK_TR234_IN" AS
   v_contador     NUMBER(4) := 2;

   /*****************************************************************************
      NOMBRE:     PK_TR234_IN
      PROPÓSITO:

      REVISIONES:
      Ver        Fecha        Autor            Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        dd/mm/yyyy   XXX                1. Creación del package
      2.0        28/05/2010   PFA                2. 14750: ENSA101 - Reproceso de procesos ya existentes
      3.0        12/07/2010   SRA                3. 15372: CEM210 - Errores en grabación y gestión de traspasos de salida
      4.0        04/08/2010   RSC                4. CEM - traspassos de salida ppa
      5.0        06/08/2010   RSC                5. Q234 TRASPASOS ENTRADA TRANFERENCIAS
      6.0        06/08/2010   RSC                6. 0015676: CARGA DE Q234 CECA
      7.0        02/08/2010   SRA                4. 15606: CEM - Cuaderno 234 - Identificación del nº de póliza en traspasos de salida
      8.0        16/09/2010   RSC                8. 0015883: CEM - Càrrega transferències norma234
      9.0        01/10/2010   RSC                9. 0016184: Traspasos de salida externos PPA (Añadimos 'TDC234_IN')
      10.0       07/10/2010   RSC               10. 0016259: HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
      11.0       29/06/2010   DRA               11. 0016130: CRT - Error informando el codigo de proceso en carga
      12.0       19/10/2010   SRA               12. 0016342: Q234 TRANSFERENCIA SALIDA DE PPA A PPI
      13.0       19/10/2010   SRA               14. 0016470: Càrrega trasnferència rebudes no carga
      14.0       12/11/2010   RSC               14. 0016667: Traspasos: No carga la compañia destino correctamente
      15.0       13/12/2010   RSC               15. 0016983: càrrega fitxer CECA PPA no funciona
      16.0       10/01/2011   LCF               16. 0017225: Fichero CECA traspasos no se carga en AXIS
      17.0       12/01/2011   JMP               17. 0017245: Habilitar proceso rechazar solicitudes
      18.0       23/02/2011   RSC               18. 0017767: ERROR CARREGA FITXER Q234
      19.0       17/03/2011   RSC               19. 0018021: URGENTE FICHEROS RECHAZADOS POR CECA
   ******************************************************************************/
   FUNCTION insertar_registro(pregistro IN tdc234_in_det%ROWTYPE, psproces IN NUMBER)
      RETURN NUMBER IS
      vnerror        NUMBER(10);
      vnnumlin       NUMBER;
   BEGIN
      INSERT INTO tdc234_in_det
                  (sproces, sref234, codreg, cndato,
                   nlinea, campo_a, campo_b, campo_c,
                   campo_c1, campo_c2, campo_d,
                   campo_d1, campo_d2, campo_e,
                   campo_f1, campo_f2, campo_f3,
                   campo_f4, campo_f5, campo_f6,
                   campo_f7, campo_f8, campo_f9,
                   campo_f10, campo_f11, campo_f12,
                   campo_f13, campo_g, campo_g1,
                   campo_g2)
           VALUES (pregistro.sproces, pregistro.sref234, pregistro.codreg, pregistro.cndato,
                   pregistro.nlinea, pregistro.campo_a, pregistro.campo_b, pregistro.campo_c,
                   pregistro.campo_c1, pregistro.campo_c2, pregistro.campo_d,
                   pregistro.campo_d1, pregistro.campo_d2, pregistro.campo_e,
                   pregistro.campo_f1, pregistro.campo_f2, pregistro.campo_f3,
                   pregistro.campo_f4, pregistro.campo_f5, pregistro.campo_f6,
                   pregistro.campo_f7, pregistro.campo_f8, pregistro.campo_f9,
                   pregistro.campo_f10, pregistro.campo_f11, pregistro.campo_f12,
                   pregistro.campo_f13, pregistro.campo_g, pregistro.campo_g1,
                   pregistro.campo_g2);

      RETURN 0;
   -- exception when others then .--falta control de errores
   EXCEPTION
      WHEN OTHERS THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(9901084, f_idiomauser);
            vnerror := f_proceslin(psproces, ttexto || SQLERRM, 1, vnnumlin, 1);
         END;

         RETURN -1;
   END insertar_registro;

   FUNCTION f_carga_fichero(pfichero IN VARCHAR2, ppath IN VARCHAR2, psproces IN OUT NUMBER)
      RETURN NUMBER IS
      linea          VARCHAR2(300);
      fitxer         UTL_FILE.file_type;
      vpath          VARCHAR2(200);
      vregistro      tdc234_in_det%ROWTYPE;
      nerror         NUMBER(5);
      vsref234       tdc234_in_det.sref234%TYPE;
      nsnce          NUMBER(6) := 0;
      vnumoper       NUMBER(5) := 0;
      vtotoper       NUMBER(5) := 0;
      vnumreg        NUMBER(6) := 0;
      vtotreg        NUMBER(6) := 0;
      vnnumlin       NUMBER;
      --
      ABORT          EXCEPTION;
   --
   BEGIN
      IF psproces IS NULL THEN
         DECLARE
            ttexto         VARCHAR2(100);
         BEGIN
            ttexto := f_axis_literales(151759, f_idiomauser);
            nerror := f_procesini(f_user, pac_md_common.f_get_cxtempresa, 'N234IN',
                                  SUBSTR(ttexto || pfichero, 1, 120), psproces);
         END;
      END IF;

      IF ppath IS NULL THEN
         vpath := f_parinstalacion_t('PATH_CARGA');
      ELSE
         vpath := ppath;
      END IF;

      IF vpath IS NULL THEN
         RAISE ABORT;
      END IF;

      fitxer := UTL_FILE.fopen(vpath, pfichero, 'r');

      -- pendiente la carga en la tabla TDC234_IN, y el chequeo del pie.
      LOOP
         BEGIN
            UTL_FILE.get_line(fitxer, linea);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 0;   -- fin de fichero
         END;

--********************************* Crea el vregistro en funció del tipus de línia llegit
 --************* 000 ************** El fitxer es carrega amb fopen i d'aqui LOOP per cada linia
 --******************************** Un cop creada la insertem a TDC234_IN_DET
         IF SUBSTR(linea, 27, 3) = '000' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := 0;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 4);
            vregistro.campo_f3 := SUBSTR(linea, 43, 5);
            vregistro.campo_f4 := SUBSTR(linea, 48, 6);
            vregistro.campo_f5 := SUBSTR(linea, 54, 12);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 201 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '201' THEN
            vnumoper := vnumoper + 1;
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vsref234 := NULL;
            vregistro.sproces := psproces;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 32, 2);
            vregistro.campo_f3 := SUBSTR(linea, 34, 1);
            vregistro.campo_f4 := SUBSTR(linea, 35, 6);
            vregistro.campo_f5 := SUBSTR(linea, 41, 2);
            vregistro.campo_f6 := SUBSTR(linea, 43, 13);

            IF TRIM(vregistro.campo_f6) IS NOT NULL THEN
               vsref234 := vregistro.campo_f6;
            ELSE
               nsnce := nsnce + 1;
               vsref234 := 'SNCE' || LPAD(nsnce, 9, 0);
            END IF;

            vregistro.sref234 := vsref234;
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;

/************ CREO A tdc234_in LA CAPÇALERA DEL FITXER nomes si es una linea 201 (farem tants inserts com linies 201) *********************/
            DECLARE
               v_stras        trasplainout.stras%TYPE;
               v_sseguro      trasplainout.sseguro%TYPE;
            BEGIN
               BEGIN
                  SELECT stras, sseguro
                    INTO v_stras, v_sseguro
                    FROM trasplainout
                   WHERE srefc234 = vsref234;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_stras := NULL;
                     v_sseguro := NULL;
               END;

               INSERT INTO tdc234_in
                           (stdc234in, fcarga, sproces, tfichero, stras,
                            sseguro, cestado, sref234, caccion, cestacc, cerror)
                    VALUES (seq_stdc234in.NEXTVAL, f_sysdate, psproces, pfichero, v_stras,
                            v_sseguro, 1, vsref234, TO_NUMBER(vregistro.campo_f1), 0, NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  DECLARE
                     v_dummy        VARCHAR2(100);
                     ttexto         VARCHAR2(100);
                  BEGIN
                     v_dummy := SQLERRM;
                     ttexto := f_axis_literales(9901084, f_idiomauser);
                     nerror := f_proceslin(psproces, ttexto || SQLERRM, 1, vnnumlin, 1);
                  END;
            END;
--*********************************
--************* 202 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '202' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            vregistro.campo_f2 := SUBSTR(linea, 31, 1);
            vregistro.campo_f3 := SUBSTR(linea, 32, 12);
            vregistro.campo_f4 := SUBSTR(linea, 44, 5);
            vregistro.campo_f5 := SUBSTR(linea, 49, 14);
            --vregistro.campo_f6 := substr(linea,63,1);
            --vregistro.campo_f7 := substr(linea,64,1);
            --vregistro.campo_f8 := substr(linea,65,1);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 203 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '203' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 20);
            vregistro.campo_f2 := SUBSTR(linea, 50, 4);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 204 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '204' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 10);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 205 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '205' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 10);
            vregistro.campo_f2 := SUBSTR(linea, 40, 26);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 206 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '206' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 10);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 207 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '207' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 10);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 208 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '208' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 10);
            vregistro.campo_f2 := SUBSTR(linea, 40, 26);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 209 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '209' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 10);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 210 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '210' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            -- Alberto - nuevos valores
            vregistro.campo_f2 := SUBSTR(linea, 31, 6);
            vregistro.campo_f3 := SUBSTR(linea, 37, 9);
            vregistro.campo_f4 := SUBSTR(linea, 46, 2);
            vregistro.campo_f5 := SUBSTR(linea, 48, 1);
            vregistro.campo_f6 := SUBSTR(linea, 49, 5);
            vregistro.campo_f7 := SUBSTR(linea, 54, 5);
            vregistro.campo_f8 := SUBSTR(linea, 59, 1);
            -- valores anteriores a la inclusion del nuevo f2
            /*
            vregistro.campo_f2 := SUBSTR(linea, 31, 9);
            vregistro.campo_f3 := SUBSTR(linea, 40, 2);
            vregistro.campo_f4 := SUBSTR(linea, 42, 1);
            vregistro.campo_f5 := SUBSTR(linea, 43, 5);
            vregistro.campo_f6 := SUBSTR(linea, 48, 5);
            vregistro.campo_f7 := SUBSTR(linea, 53, 1);
            */
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 211 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '211' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 36);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 215 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '215' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 6);
            vregistro.campo_f2 := SUBSTR(linea, 36, 4);
            vregistro.campo_f3 := SUBSTR(linea, 40, 4);
            vregistro.campo_f4 := SUBSTR(linea, 44, 20);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 216 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '216' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 12);
            vregistro.campo_f2 := SUBSTR(linea, 42, 4);
            vregistro.campo_f2 := SUBSTR(linea, 46, 4);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 225 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '225' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            vregistro.campo_f2 := SUBSTR(linea, 31, 2);
            vregistro.campo_f3 := SUBSTR(linea, 33, 6);
            vregistro.campo_f4 := SUBSTR(linea, 39, 1);
            vregistro.campo_f5 := SUBSTR(linea, 40, 6);
            vregistro.campo_f6 := SUBSTR(linea, 46, 1);
            vregistro.campo_f7 := SUBSTR(linea, 47, 4);
            vregistro.campo_f8 := SUBSTR(linea, 51, 1);
            vregistro.campo_f9 := SUBSTR(linea, 52, 1);
            vregistro.campo_f10 := SUBSTR(linea, 53, 10);
            vregistro.campo_f11 := SUBSTR(linea, 63, 1);
            vregistro.campo_f12 := SUBSTR(linea, 64, 1);
            vregistro.campo_f13 := SUBSTR(linea, 65, 1);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 226 Modificado por alberto ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '226' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 7);
            vregistro.campo_f2 := SUBSTR(linea, 37, 7);
            vregistro.campo_f3 := SUBSTR(linea, 44, 10);
            vregistro.campo_f4 := SUBSTR(linea, 54, 10);
            vregistro.campo_f5 := SUBSTR(linea, 64, 2);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* alberto 227 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '227' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 5);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_f1 := SUBSTR(linea, 30, 5);
            vregistro.campo_f2 := SUBSTR(linea, 35, 8);
            vregistro.campo_f3 := SUBSTR(linea, 43, 1);
            vregistro.campo_f4 := SUBSTR(linea, 44, 1);
            vregistro.campo_f5 := SUBSTR(linea, 45, 10);
            vregistro.campo_f6 := SUBSTR(linea, 55, 10);
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* alberto 228 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '228' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            vregistro.campo_f2 := SUBSTR(linea, 31, 4);
            vregistro.campo_f3 := SUBSTR(linea, 35, 1);
            vregistro.campo_f4 := SUBSTR(linea, 36, 4);
            vregistro.campo_f5 := SUBSTR(linea, 40, 10);
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 230  ***********
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '230' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 2);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 32, 9);
            vregistro.campo_f3 := SUBSTR(linea, 41, 12);
            vregistro.campo_f4 := SUBSTR(linea, 53, 1);
            vregistro.campo_f5 := SUBSTR(linea, 54, 12);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 231 ***********
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '231' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 2);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 38, 34);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
 --*********************************
--************* 240 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '240' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 32, 1);
            vregistro.campo_f3 := SUBSTR(linea, 33, 1);
            vregistro.campo_f4 := SUBSTR(linea, 34, 4);
            vregistro.campo_f5 := SUBSTR(linea, 38, 2);
            vregistro.campo_f6 := SUBSTR(linea, 40, 8);
            vregistro.campo_f7 := SUBSTR(linea, 48, 1);
            vregistro.campo_f8 := SUBSTR(linea, 49, 6);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 245 246 ***********
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '245' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 1);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            vregistro.campo_f2 := SUBSTR(linea, 31, 35);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
         ELSIF SUBSTR(linea, 27, 3) = '246' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 1);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 1);
            vregistro.campo_f2 := SUBSTR(linea, 31, 8);
            vregistro.campo_f3 := SUBSTR(linea, 39, 27);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 251************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '250' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 2);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 32, 1);
            vregistro.campo_f3 := SUBSTR(linea, 33, 1);
            vregistro.campo_f4 := SUBSTR(linea, 34, 10);
            vregistro.campo_f5 := SUBSTR(linea, 44, 9);
            vregistro.campo_f6 := SUBSTR(linea, 53, 6);
            vregistro.campo_f7 := SUBSTR(linea, 59, 1);
            vregistro.campo_f8 := SUBSTR(linea, 60, 1);
            vregistro.campo_f9 := SUBSTR(linea, 61, 5);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 251************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '251' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := vsref234;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := SUBSTR(linea, 30, 2);
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_c1 := SUBSTR(linea, 5, 9);
            vregistro.campo_d1 := SUBSTR(linea, 15, 9);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_g2 := SUBSTR(linea, 69, 2);
            vregistro.campo_f1 := SUBSTR(linea, 30, 2);
            vregistro.campo_f2 := SUBSTR(linea, 32, 6);
            vregistro.campo_f3 := SUBSTR(linea, 38, 6);
            vregistro.campo_f4 := SUBSTR(linea, 44, 6);
            vregistro.campo_f5 := SUBSTR(linea, 50, 2);
            vregistro.campo_f6 := SUBSTR(linea, 52, 1);
            vregistro.campo_f7 := SUBSTR(linea, 53, 10);
            vregistro.campo_f8 := SUBSTR(linea, 63, 2);
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
--*********************************
--************* 000 ***************
--*********************************
         ELSIF SUBSTR(linea, 27, 3) = '999' THEN
            vnumreg := vnumreg + 1;
            vregistro := NULL;
            vregistro.sproces := psproces;
            vregistro.sref234 := 0;
            vregistro.codreg := SUBSTR(linea, 1, 2);
            vregistro.cndato := SUBSTR(linea, 27, 3);
            vregistro.nlinea := 1;
            vregistro.campo_a := vregistro.codreg;
            vregistro.campo_b := SUBSTR(linea, 3, 2);
            vregistro.campo_e := vregistro.cndato;
            vregistro.campo_f1 := SUBSTR(linea, 30, 9);
            vregistro.campo_f2 := SUBSTR(linea, 39, 4);
            vregistro.campo_f3 := SUBSTR(linea, 43, 5);
            vregistro.campo_f4 := SUBSTR(linea, 48, 6);
            vregistro.campo_f5 := SUBSTR(linea, 54, 12);
            vtotoper := vregistro.campo_f3;
            vtotreg := vregistro.campo_f4;
            nerror := insertar_registro(vregistro, psproces);

            IF nerror <> 0 THEN
               RAISE ABORT;
            END IF;
         --exit; -- fin de fichero -- no?
         END IF;   -- FIN lineas
      END LOOP;

      -- JGM update a 31 las cacciones que son COMPLEMENTOS y que hasta ahora tenian 3.
      UPDATE tdc234_in
         SET caccion = 31
       WHERE sproces = psproces
         AND sref234 IN(SELECT sref234
                          FROM tdc234_in_det
                         WHERE TO_NUMBER(cndato) = 225
                           AND TRIM(campo_f13) <> '1');

      IF vtotoper <> vnumoper THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(9000464, f_idiomauser);
            nerror := f_proceslin(psproces, ttexto, 1, vnnumlin, 1);
         END;

         RETURN 10;
      END IF;

      IF vtotreg <> vnumreg THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(9000464, f_idiomauser);
            nerror := f_proceslin(psproces, ttexto, 1, vnnumlin, 1);
         END;

         RETURN 20;
      END IF;

      nerror := f_procesfin(psproces, 0);
      RETURN 0;
   EXCEPTION
      WHEN UTL_FILE.invalid_path THEN
         RETURN -1;
      WHEN UTL_FILE.invalid_mode THEN
         RETURN -2;
      WHEN UTL_FILE.invalid_operation THEN
         RETURN -3;
      WHEN UTL_FILE.invalid_filehandle THEN
         RETURN -4;
      WHEN UTL_FILE.write_error THEN
         RETURN -5;
      WHEN UTL_FILE.read_error THEN
         RETURN -6;
      WHEN ABORT THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(9000464, f_idiomauser) || '-'
                      || f_axis_literales(9000464, f_idiomauser) || ' ' || vnumreg || ' '
                      || f_axis_literales(9002038, f_idiomauser) || ' ' || vnumoper;
            nerror := f_proceslin(psproces, ttexto || SQLERRM, 1, vnnumlin, 1);
         END;

         RETURN 100;
      WHEN OTHERS THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(1000455, f_idiomauser);
            nerror := f_proceslin(psproces, ttexto || SQLERRM, 1, vnnumlin, 1);
         END;

         RETURN -10;
   END f_carga_fichero;

   FUNCTION f_recuperar_reg(
      psproces IN NUMBER,
      psref234 IN VARCHAR2,
      preg IN VARCHAR2,
      pnlinea IN NUMBER,
      preg234 OUT tdc234_in_det%ROWTYPE)
      RETURN NUMBER IS
      vnnumlin       NUMBER;
      nerror         NUMBER;
   BEGIN
      SELECT *   -- claveoper
        INTO preg234
        FROM tdc234_in_det
       WHERE sproces = psproces
         AND sref234 = psref234
         AND cndato = preg
         AND nlinea = pnlinea;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         DECLARE
            v_dummy        VARCHAR2(100);
            ttexto         VARCHAR2(100);
         BEGIN
            v_dummy := SQLERRM;
            ttexto := f_axis_literales(1000455, f_idiomauser);
            nerror := f_proceslin(psproces, ttexto || SQLERRM, 1, vnnumlin, 1);
         END;

         RETURN 1;
   END;

   FUNCTION f_ejecutar_acciones(psproces IN NUMBER)
      RETURN NUMBER IS
      CURSOR c_traspasos IS
         SELECT sref234, stras, sseguro
           FROM tdc234_in
          WHERE sproces = psproces;   -- no deberia haber duplicados

      vclaveoper     NUMBER(2);
--
      vsref234       tdc234_in_det.sref234%TYPE;
      vnnumlin       NUMBER;
--
      vspersonase    per_personas.sperson%TYPE;
      rtraspaso      trasplainout%ROWTYPE;
      rembargo       trasplabloq%ROWTYPE;
      raportante     trasplaapo%ROWTYPE;
      rprestacion    trasplapresta%ROWTYPE;
      --
      vreg201        tdc234_in_det%ROWTYPE;
      vreg202        tdc234_in_det%ROWTYPE;
      -- Ini Bug 16342 - SRA - 19/10/2010
      vreg203        tdc234_in_det%ROWTYPE;
      -- Fin Bug 16342 - SRA - 19/10/201
      vreg205        tdc234_in_det%ROWTYPE;
      vreg206        tdc234_in_det%ROWTYPE;
      vreg208        tdc234_in_det%ROWTYPE;
      vreg209        tdc234_in_det%ROWTYPE;
      vreg210        tdc234_in_det%ROWTYPE;
      -- BUG 17245 - 12/01/2011 - JMP
      vreg204        tdc234_in_det%ROWTYPE;
      vreg211        tdc234_in_det%ROWTYPE;
      -- FIN BUG 17245 - 12/01/2011 - JMP
      vreg215        tdc234_in_det%ROWTYPE;
      vreg216        tdc234_in_det%ROWTYPE;
      vreg225        tdc234_in_det%ROWTYPE;
      vreg207        tdc234_in_det%ROWTYPE;
      -- información económica del plan traspasado relativa a las aportaciones o primas
      vreg226        tdc234_in_det%ROWTYPE;
      -- aportaciones
      vreg227        tdc234_in_det%ROWTYPE;
      vreg228        tdc234_in_det%ROWTYPE;
      -- aportantes
      vreg230        tdc234_in_det%ROWTYPE;
      vreg231        tdc234_in_det%ROWTYPE;
      --  derechos economicos o con provesion matemática por contingencia acaecida
      vreg240        tdc234_in_det%ROWTYPE;
      -- embargos
      vreg245        tdc234_in_det%ROWTYPE;
      vreg246        tdc234_in_det%ROWTYPE;
      --  Prestaciones
      vreg250        tdc234_in_det%ROWTYPE;
      vreg251        tdc234_in_det%ROWTYPE;
      --
      nerror         NUMBER;
      v_traza        NUMBER := 0;
      v_poliza       NUMBER;
      --
      -- EXCEPTION
      ABORT          EXCEPTION;
      e_leyendo_datos_fichero EXCEPTION;
      e_obteniendo_datosbd EXCEPTION;
   BEGIN
      FOR trasp IN c_traspasos LOOP
         -- Voy obteniendo los diferentes valores
         vsref234 := trasp.sref234;

         BEGIN
            nerror := f_recuperar_reg(psproces, trasp.sref234, '201', 1, vreg201);

            IF nerror <> 0 THEN
               RAISE e_leyendo_datos_fichero;   --9901082
            END IF;

            -- De momento solo solicitud de traspaso
/************************(1) solicitut traspas de sortida****************************/
            IF TO_NUMBER(vreg201.campo_f1) = 1 THEN
               -----ei nomes arriben registres 23-24
               -----ei nomes arriben les linies 201-211
               nerror := f_recuperar_reg(psproces, trasp.sref234, '202', 1, vreg202);

               IF nerror <> 0 THEN
                  RAISE e_leyendo_datos_fichero;   --9901082
               END IF;

               -- Ini Bug 16342 - SRA - 19/10/2010:
               nerror := f_recuperar_reg(psproces, trasp.sref234, '203', 1, vreg203);   -- cuenta bancaria

               IF nerror <> 0 THEN
                  RAISE e_leyendo_datos_fichero;   --9901082
               END IF;

               -- Fin Bug 16342 - SRA - 19/10/201
               nerror := f_recuperar_reg(psproces, trasp.sref234, '205', 1, vreg205);   -- plan i poliza

               IF nerror <> 0 THEN
                  RAISE e_leyendo_datos_fichero;   --9901082
               END IF;

               nerror := f_recuperar_reg(psproces, trasp.sref234, '210', 1, vreg210);   --tipo derecho, NIF,forma cobro, etc

               IF nerror <> 0 THEN
                  RAISE e_leyendo_datos_fichero;   --9901082
               END IF;

               rtraspaso := NULL;

               -- Bug 17225 LCF Formatear campo_f2 para eliminar espacios y otros carácteres
               BEGIN
                  v_poliza := vreg205.campo_f2;
               EXCEPTION
                  WHEN OTHERS THEN
                     BEGIN
                        v_poliza := REPLACE(vreg205.campo_f2, ' ', '');
                     EXCEPTION
                        WHEN OTHERS THEN
                           v_poliza := 0;
                     END;
               END;

               -- Obtención de datos para el TRANSPLAINOUT
               BEGIN
                  -- Bug 16184 - RSC - 01/10/2010 - Traspasos de salida externos PPA (Añadimos 'TDC234_IN')
                  SELECT seg.sseguro,   -- busco el sseguro, solo puede existir uno
                                     per.sperson
                    INTO rtraspaso.sseguro, vspersonase
                    FROM asegurados ase, per_personas per, seguros seg
                   WHERE ase.sperson = per.sperson
                     AND ase.sseguro = seg.sseguro
                     AND seg.csituac = 0
                     AND NVL(f_parproductos_v(seg.sproduc, 'TDC234_IN'), 0) = 1
                     AND per.nnumide = TRIM(vreg210.campo_f3)
                     AND seg.npoliza = TRIM(v_poliza);   -- LCF antes campo: vreg205.campo_f2
/* BUG 15606 - 15/07/2010 - SRA - Sucede que en algunas ocasiones el nº de póliza indicado por la entidad origen es erróneo, por lo que ampliaremos la búsqueda únicamente por nif del asegurado */
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     BEGIN
                        -- Bug 16184 - RSC - 01/10/2010 - Traspasos de salida externos PPA (Añadimos 'TDC234_IN')
                        SELECT seg.sseguro,   -- busco el sseguro, solo puede existir uno
                                           per.sperson
                          INTO rtraspaso.sseguro, vspersonase
                          FROM asegurados ase, per_personas per, seguros seg
                         WHERE ase.sperson = per.sperson
                           AND ase.sseguro = seg.sseguro
                           AND seg.csituac = 0
                           AND NVL(f_parproductos_v(seg.sproduc, 'TDC234_IN'), 0) = 1
                           AND per.nnumide = TRIM(vreg210.campo_f3);
                     EXCEPTION
                        WHEN OTHERS THEN
                           rtraspaso.sseguro := NULL;
                     END;
                  WHEN OTHERS THEN
                     rtraspaso.sseguro := NULL;
               END;

               SELECT stras.NEXTVAL
                 INTO rtraspaso.stras   -- cojo el stras de la secuencia
                 FROM DUAL;

--           rtraspaso.ccodpla     :=   -----> s'ha de recupurar amb les dades de gestora/pla/fons ORIGEN(linia 204/205/206   )
                                        -----> o companyia/aseguradora que arriben (linia 206)
               nerror := f_recuperar_reg(psproces, trasp.sref234, '206', 1, vreg206);

               IF nerror <> 0 THEN
                  RAISE e_leyendo_datos_fichero;   --9901082
               END IF;

               BEGIN
                  -- Bug 15883 - RSC - 15/09/2010 - CEM - Càrrega transferències norma234
                  --IF TRIM(vreg205.campo_f2) = '' THEN   --Plan

                  -- Bug 16983 - RSC - 13/12/2010 - càrrega fitxer CECA PPA no funciona
                  /*
                  IF TRIM(vreg205.campo_f2) IS NULL THEN   --Plan
                     -- Fin Bug 15883

                     -- Plan de Pensiones
                     SELECT ccodpla
                       INTO rtraspaso.ccodpla
                       FROM planpensiones
                      WHERE coddgs = TRIM(vreg206.campo_f2);   --el pla DGS
                  --JGM ARREGLA-HO ----------------- Cercar descripcions, gestora i fons i comprova OK amb fitxer
                  ELSE
                     rtraspaso.ccodaseg := TRIM(vreg206.campo_f2);   --la companyia (coddgs pero normalment es null

                     SELECT SUBSTR(f_nombre(sperson, 1), 1, 40), ccodaseg, ctipban,
                            cbancar
                       INTO rtraspaso.tcompani, rtraspaso.ccompani, rtraspaso.ctipban,
                            rtraspaso.cbancar
                       FROM aseguradoras
                      WHERE coddgs = rtraspaso.ccodaseg;
                  END IF;
                  */
                  -- Fin Bug 16983
                  nerror := f_recuperar_reg(psproces, trasp.sref234, '208', 1, vreg208);   --tipo derecho, NIF,forma cobro, etc

                  IF nerror <> 0 THEN
                     RAISE e_obteniendo_datosbd;   --108520
                  END IF;

                  -- Bug 15883 - RSC - 16/09/2010 - 0015883: CEM - Càrrega transferències norma234
                  IF TRIM(vreg208.campo_f1) IS NOT NULL THEN   -- Entrara siempre
                     BEGIN
                        SELECT ccodpla, tnompla
                          INTO rtraspaso.ccodpla, rtraspaso.tcodpla
                          FROM planpensiones
                         WHERE coddgs = TRIM(vreg208.campo_f1);   --> El Destí es un Pla de Pensions
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           -- Bug 16667 - RSC - 12/11/2010 - Traspasos: No carga la compañia destino correctamente
                           nerror := f_recuperar_reg(psproces, trasp.sref234, '207', 1,
                                                     vreg207);

                           IF nerror <> 0 THEN
                              RAISE e_obteniendo_datosbd;   --108520
                           END IF;

                           --> El destí NO es una Pla de pensions, es un PPA o un PIAS.
                           rtraspaso.ccodaseg := TRIM(vreg207.campo_f2);

                           SELECT SUBSTR(f_nombre(sperson, 1), 1, 40), ccodaseg, ctipban,
                                  cbancar
                             INTO rtraspaso.tcompani, rtraspaso.ccompani, rtraspaso.ctipban,
                                  rtraspaso.cbancar
                             FROM aseguradoras
                            WHERE coddgs = rtraspaso.ccodaseg;
                     END;
                  END IF;

                  -- Fin Bug 15883

                  -- Bug 15883 - RSC - 16/09/2010 - 0015883: CEM - Càrrega transferències norma234
                  -- En el numero de póliza externo grabamos el numero de poliza
                  -- externo que puede venir informado en el texto libre del registro
                  -- 208.
                  -- Fin Bug 15883
                  rtraspaso.tpolext := TRIM(vreg208.campo_f2);
               END;

--
--           rtraspaso.NREF        := ??
--           rtraspaso.NPARPOS2006 := ??
--           rtraspaso.NPARANT2007 := ??
--           rtraspaso.PORCANT2007 := ??
--           rtraspaso.CTIPCOM     := ??
--
               IF rtraspaso.sseguro IS NULL THEN
                  rtraspaso.cenvio := 0;   --pdte envio
                  rtraspaso.cestado := 6;   ------> cestado = REBUTJAT pq no tinc sseguro
                  -- Bug 18021 - RSC - 17/03/2011 - URGENTE FICHEROS RECHAZADOS POR CECA
                  rtraspaso.cmotrod := '03';
               -- Fin Bug 18021
               ELSE
                  rtraspaso.cenvio := 1;   --enviat
                  rtraspaso.cestado := 1;   ------> cestado = Sense Confirmar
                  -- Bug 18021 - RSC - 17/03/2011 - URGENTE FICHEROS RECHAZADOS POR CECA
                  rtraspaso.cmotrod := TRIM(vreg201.campo_f2);
               -- Fin Bug 18021
               END IF;

               rtraspaso.cexterno := 1;
----------------------------------------------
            /* BUG 15372 - 12/07/2010 - SRA - se corrige el valor de cinout para traspasos de salida, que ha de ser 2 (antes 1) */
               rtraspaso.cinout := 2;
               rtraspaso.fsolici := f_sysdate;
               -- Bug 15883 - RSC - 16/09/2010 - 0015883: CEM - Càrrega transferències norma234
               --rtraspaso.tpolext := TRIM(vreg205.campo_f2);
               -- Fin Bug 15883

               --Bug 25376-XVM-09/05/2013.Inicio
               rtraspaso.admitcap := TRIM(vreg202.campo_f6);
               rtraspaso.admitren := TRIM(vreg202.campo_f7);
               rtraspaso.admitrencap := TRIM(vreg202.campo_f8);
               --Bug 25376-XVM-09/05/2013.Fin
               rtraspaso.ctiptras := TRIM(vreg202.campo_f1);
               rtraspaso.iimptemp := TRUNC(TRIM(vreg202.campo_f3) / 100, 2);
               rtraspaso.nporcen := TRUNC(TRIM(vreg202.campo_f4) / 100, 2);
               rtraspaso.nparpla := TRUNC(TRIM(vreg202.campo_f5) / 100, 2);
               rtraspaso.ctipder := TRIM(vreg210.campo_f1);
               rtraspaso.cusualta := f_user;
               -- Bug 15658 - 04/08/2010 - RSC - CEM - traspassos de salida ppa
               --rtraspaso.porcpos2006 := TRUNC(TRIM(vreg210.campo_f6) / 100, 2);
               -- Fin Bug 15658
               rtraspaso.ctiptrassol := TRIM(vreg202.campo_f2);
               rtraspaso.festado := f_sysdate;
               rtraspaso.srefc234 := TRIM(vreg201.campo_f6);
               -- Bug 18021 - RSC - 17/03/2011 - URGENTE FICHEROS RECHAZADOS POR CECA
               --rtraspaso.cmotrod := TRIM(vreg201.campo_f2);
               -- Fin Bug 18021

               -- Ini Bug 16342 - SRA - 19/10/2010: grabamos la cuenta bancaria
               rtraspaso.cbancar := TRIM(vreg203.campo_f1);
               -- Fin Bug 16342 - SRA - 19/10/201
               -- BUG 17245 - 12/01/2011 - JMP - Guardamos los datos que necesitaremos en caso de rechazo
               rtraspaso.numidsol := vreg210.campo_f3;
               nerror := f_recuperar_reg(psproces, trasp.sref234, '211', 1, vreg211);

               IF nerror <> 0 THEN
                  RAISE e_obteniendo_datosbd;   --108520
               END IF;

               nerror := f_recuperar_reg(psproces, trasp.sref234, '204', 1, vreg204);

               IF nerror <> 0 THEN
                  RAISE e_obteniendo_datosbd;   --108520
               END IF;

               rtraspaso.tnomsol := vreg211.campo_f1;
               rtraspaso.nifgori := vreg204.campo_f1;
               rtraspaso.cdgsgori := vreg204.campo_f2;
               rtraspaso.cdgsppori := vreg205.campo_f1;
               rtraspaso.niffpori := vreg206.campo_f1;
               rtraspaso.cdgsfpori := vreg206.campo_f2;
               rtraspaso.nrbe := vreg203.campo_f2;

               -- FIN BUG 17245 - 12/01/2011 - JMP

               /*******************inserto EN TRANSPLAINOUT ******************/
               --Bug 25376-XVM-09/05/2013.Añadimos los campos admitcap, admitren, admitrencap
               INSERT INTO trasplainout
                           (stras, cinout, sseguro,
                            fsolici, ccodpla, tpolext,
                            cbancar, cestado, ctiptras,
                            tmemo, iimporte, iimptemp,
                            iimpanu, fantigi, nnumlin,
                            ncertext, nporcen, nparpla,
                            nparret, cexterno, ctipder,
                            nref, tcodpla, fvalor,
                            cusualta, nparpos2006, porcpos2006,
                            nparant2007, porcant2007, ctipban,
                            ctiptrassol, ccodaseg, ctipcom,
                            sentext, fcontab, festado,
                            ccompani, tcompani, iimpret,
                            cenvio, srefc234, cmotrod,
                            nsinies, cmotivo, initransf,
                            femtror, formacobr, indemb,
                            napomin, indesmin, fminusv,
                            indapanmin, imapanmin, indotcont,
                            indensco, indapenano, indprenano,
                            indcomptras, imappaano, imapprano,
                            imdctrasp, imdetrasp, nfcprest,
                            indmodano, indhccap, anoprpago,
                            ctipcont, fconting, indhcpre,
                            fprprest, numidsol, tnomsol,
                            nifgori, cdgsgori, cdgsppori,
                            niffpori, cdgsfpori, nrbe,
                            admitcap, admitren, admitrencap)
                    VALUES (rtraspaso.stras, rtraspaso.cinout, rtraspaso.sseguro,
                            rtraspaso.fsolici, rtraspaso.ccodpla, rtraspaso.tpolext,
                            rtraspaso.cbancar, rtraspaso.cestado, rtraspaso.ctiptras,
                            rtraspaso.tmemo, rtraspaso.iimporte, rtraspaso.iimptemp,
                            rtraspaso.iimpanu, rtraspaso.fantigi, rtraspaso.nnumlin,
                            rtraspaso.ncertext, rtraspaso.nporcen, rtraspaso.nparpla,
                            rtraspaso.nparret, rtraspaso.cexterno, rtraspaso.ctipder,
                            rtraspaso.nref, rtraspaso.tcodpla, rtraspaso.fvalor,
                            rtraspaso.cusualta, rtraspaso.nparpos2006, rtraspaso.porcpos2006,
                            rtraspaso.nparant2007, rtraspaso.porcant2007, rtraspaso.ctipban,
                            rtraspaso.ctiptrassol, rtraspaso.ccodaseg, rtraspaso.ctipcom,
                            rtraspaso.sentext, rtraspaso.fcontab, rtraspaso.festado,
                            rtraspaso.ccompani, rtraspaso.tcompani, rtraspaso.iimpret,
                            rtraspaso.cenvio, rtraspaso.srefc234, rtraspaso.cmotrod,
                            rtraspaso.nsinies, rtraspaso.cmotivo, rtraspaso.initransf,
                            rtraspaso.femtror, rtraspaso.formacobr, rtraspaso.indemb,
                            rtraspaso.napomin, rtraspaso.indesmin, rtraspaso.fminusv,
                            rtraspaso.indapanmin, rtraspaso.imapanmin, rtraspaso.indotcont,
                            rtraspaso.indensco, rtraspaso.indapenano, rtraspaso.indprenano,
                            rtraspaso.indcomptras, rtraspaso.imappaano, rtraspaso.imapprano,
                            rtraspaso.imdctrasp, rtraspaso.imdetrasp, rtraspaso.nfcprest,
                            rtraspaso.indmodano, rtraspaso.indhccap, rtraspaso.anoprpago,
                            rtraspaso.ctipcont, rtraspaso.fconting, rtraspaso.indhcpre,
                            rtraspaso.fprprest, rtraspaso.numidsol, rtraspaso.tnomsol,
                            rtraspaso.nifgori, rtraspaso.cdgsgori, rtraspaso.cdgsppori,
                            rtraspaso.niffpori, rtraspaso.cdgsfpori, rtraspaso.nrbe,
                            rtraspaso.admitcap, rtraspaso.admitren, rtraspaso.admitrencap);

               -- si llego aqui todo OK
               UPDATE tdc234_in
                  SET cestacc = 2,
                      cerror = NULL
                WHERE sproces = psproces
                  AND sref234 = trasp.sref234;
/************************(2) REBUIG / DEMORA SOLICITUT DE TRASPAS D'ENTRADA****************************/
            ELSIF TO_NUMBER(vreg201.campo_f1) = 2 THEN
               IF trasp.stras IS NULL THEN
                  UPDATE tdc234_in
                     SET cestacc = 1,
                         cerror = 9000480
                   WHERE sproces = psproces
                     AND sref234 = vsref234;
               ELSE
                  nerror := pac_traspasos.f_actest_traspaso(trasp.stras, 6, 1, 1,
                                                            TRIM(vreg201.campo_f2));

                  IF nerror <> 0 THEN
                     RAISE ABORT;
                  ELSE
                     UPDATE tdc234_in
                        SET cestacc = 2,
                            cerror = NULL
                      WHERE sproces = psproces
                        AND sref234 = trasp.sref234;

                     COMMIT;
                  END IF;
               END IF;
            /*pstras codi intern del traspas.
            pcestado 6)rebutjat 8)demorat
            pinout sempre entrada (pero ho recuperem en la funció anterior ¿¿??)
            pextern sempre extern (pero ho recuperem en la funció anterior ¿¿??)
            cmotivo camp f2 del registre */

            /************************(3) transferència d'un traspas d'entrada.****************************/
            ELSIF TO_NUMBER(vreg201.campo_f1) = 3 THEN
               IF trasp.stras IS NOT NULL THEN
                  v_traza := 1;
                  nerror := f_recuperar_reg(psproces, trasp.sref234, '225', 1, vreg225);

                  IF nerror <> 0 THEN
                     RAISE e_leyendo_datos_fichero;   --9901082
                  END IF;

                  -- Bug 16259 - RSC - 07/10/2010- HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
                  -- Obtención de datos para el TRANSPLAINOUT
                  BEGIN
                     SELECT seg.sseguro, per.sperson
                       INTO rtraspaso.sseguro, vspersonase
                       FROM asegurados ase, per_personas per, seguros seg
                      WHERE ase.sperson = per.sperson
                        AND ase.sseguro = seg.sseguro
                        AND seg.sseguro = (SELECT sseguro
                                             FROM trasplainout
                                            WHERE stras = trasp.stras);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        rtraspaso.sseguro := NULL;
                        vspersonase := NULL;
                  END;

                  -- alberto - Recuperamos 228
                  nerror := f_recuperar_reg(psproces, trasp.sref234, '228', 1, vreg228);

                  IF nerror <> 0 THEN
                     RAISE e_leyendo_datos_fichero;   --9901082
                  END IF;

                  -- Fin Bug 16259
                  IF TO_NUMBER(vreg225.campo_f13) = 1 THEN   --> No es complement, per tant SABEM fer-ho
                     ----recuperació de dades
                     ----i actualització de trasplainout i taules associades
                     nerror := f_recuperar_reg(psproces, trasp.sref234, '215', 1, vreg215);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     nerror := f_recuperar_reg(psproces, trasp.sref234, '216', 1, vreg216);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     nerror := f_recuperar_reg(psproces, trasp.sref234, '226', 1, vreg226);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     nerror := f_recuperar_reg(psproces, trasp.sref234, '210', 1, vreg210);   --tipo derecho, NIF,forma cobro, etc

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     -- reg 240 Derechos económicos o con provisión matemática...
                     IF TRIM(vreg210.campo_f1) IN('2', '3') THEN
                        nerror := f_recuperar_reg(psproces, trasp.sref234, '240', 1, vreg240);

                        IF nerror <> 0
                           AND TRIM(vreg210.campo_f1) = '2' THEN   --si es '3' OK
                           RAISE e_leyendo_datos_fichero;   --9901082
                        END IF;
                     END IF;

                     v_traza := 2;
------------------------------------------Plans o PPAs
                    --recuperar la 208 i 209
                     nerror := f_recuperar_reg(psproces, trasp.sref234, '208', 1, vreg208);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     nerror := f_recuperar_reg(psproces, trasp.sref234, '209', 1, vreg209);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     -- Bug 15674 - RSC - 12/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                     nerror := f_recuperar_reg(psproces, trasp.sref234, '206', 1, vreg206);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     -- Fin Bug 15674

                     -- Bug 15883 - RSC - 15/09/2010 - CEM - Càrrega transferències norma234
                     nerror := f_recuperar_reg(psproces, trasp.sref234, '205', 1, vreg205);

                     IF nerror <> 0 THEN
                        RAISE e_leyendo_datos_fichero;   --9901082
                     END IF;

                     -- Fin Bug 15883
                     v_traza := 3;

                     BEGIN
                        -- Bug 17767 - RSC - 23/02/2011 - ERROR CARREGA FITXER Q234
                        BEGIN
----------------------
-- Plan de Pensiones
----------------------

                           -- Bug 15674 - RSC - 12/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                           --SELECT ccodpla
                           --INTO rtraspaso.ccodpla
                           --FROM planpensiones
                           --WHERE coddgs = TRIM(vreg209.campo_f2);   --el pla DGS
                           SELECT ccodpla
                             INTO rtraspaso.ccodpla
                             FROM planpensiones
                            WHERE coddgs = TRIM(vreg205.campo_f1);   --el pla DGS
                        -- Fin Bug 15674
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
-------------------------------------------------
--la companyia (coddgs pero normalment es null)
-------------------------------------------------

                              -- Bug 15674 - RSC - 12/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                              --rtraspaso.ccodaseg := TRIM(vreg209.campo_f2);
                              rtraspaso.ccodaseg := TRIM(vreg206.campo_f2);

                              -- Fin Bug 15674
                              SELECT SUBSTR(f_nombre(sperson, 1), 1, 40), ccodaseg,
                                     ctipban, cbancar
                                INTO rtraspaso.tcompani, rtraspaso.ccompani,
                                     rtraspaso.ctipban, rtraspaso.cbancar
                                FROM aseguradoras
                               WHERE coddgs = rtraspaso.ccodaseg;
                        END;
                     -- Fin bug 17767

                     /*
                     -- Bug 15883 - RSC - 15/09/2010 - CEM - Càrrega transferències norma234
                     IF TRIM(vreg205.campo_f2) IS NULL THEN   --plan P
                        -- Fin Bug 15883

                        ----------------------
                        -- Plan de Pensiones
                        ----------------------

                        -- Bug 15674 - RSC - 12/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                        --SELECT ccodpla
                        --INTO rtraspaso.ccodpla
                        --FROM planpensiones
                        --WHERE coddgs = TRIM(vreg209.campo_f2);   --el pla DGS
                        SELECT ccodpla
                        INTO rtraspaso.ccodpla
                        FROM planpensiones
                        WHERE coddgs = TRIM(vreg205.campo_f1);   --el pla DGS
                         -- Fin Bug 15674

                     -------------------------------------------------
                     --la companyia (coddgs pero normalment es null)
                     -------------------------------------------------
                     ELSE   --PPA
                        -- Bug 15674 - RSC - 12/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                        --rtraspaso.ccodaseg := TRIM(vreg209.campo_f2);
                        rtraspaso.ccodaseg := TRIM(vreg206.campo_f2);

                        -- Fin Bug 15674
                        SELECT SUBSTR(f_nombre(sperson, 1), 1, 40), ccodaseg, ctipban,
                               cbancar
                          INTO rtraspaso.tcompani, rtraspaso.ccompani, rtraspaso.ctipban,
                               rtraspaso.cbancar
                          FROM aseguradoras
                         WHERE coddgs = rtraspaso.ccodaseg;
                     END IF;
                     */
                     EXCEPTION
                        WHEN OTHERS THEN
                           RAISE e_obteniendo_datosbd;   --108520
                     END;

                     v_traza := 4;
                     rtraspaso.cestado := 1;   -----> cestado = sense confirmar
                     rtraspaso.cexterno := 1;   --sempre son externs
                     rtraspaso.cenvio := 1;   -- enviat
---------------JGM ARREGLA-HO ----------------
--           rtraspaso.iimporte    :=  no s'informa d'entrada
--           rtraspaso.iimpanu     :=

                     --           rtraspaso.tmemo       :=
--           rtraspaso.iimporte    :=  no s'informa d'entrada
--           rtraspaso.iimpanu     :=
--           rtraspaso.nnumlin     :=  no s'informa d'entrada
--           rtraspaso.ncertext    :=  no s'informa d'entrada
--           rtraspaso.NPARRET     :=

                     --           rtraspaso.NREF        :=
--           rtraspaso.FVALOR      :=  no s'informa d'entrada
--           rtraspaso.NPARPOS2006 :=
--           rtraspaso.NPARANT2007 :=
--           rtraspaso.PORCANT2007 :=
--           rtraspaso.CTIPBAN     :=  sempre espanyol????
--           rtraspaso.CTIPCOM     :=
--           rtraspaso.SENTEXT     :=
--           rtraspaso.FCONTAB     :=
--           rtraspaso.IIMPRET     :=

                     --           rtraspaso.NSINIES     := no s'informa
--           rtraspaso.CMOTIVO     :=
--           rtraspaso.INITRANSF   := no s'informa
--           rtraspaso.FEMTROR     := no s'informa
--           rtraspaso.FORMACOBR   := no s'informa
--           rtraspaso.IMAPANMIN   :=
--           rtraspaso.INDOTCONT   :=
--           rtraspaso.INDENSCO    := ;
--           rtraspaso.INDCOMPTRAS :=
--           rtraspaso.INDMODANO   :=

                     -- ACTUALIZAR TRASPLAINOUT -- les dades que ja existeixin es suplanten per les noves.

                     ------------------------------------------------------

                     -- Bug 15644 - RSC - 06/08/2010 - Q234 TRASPASOS ENTRADA TRANFERENCIAS
                     rtraspaso.fvalor := TO_DATE(TRIM(vreg215.campo_f1), 'DDMMYY');
                     -- Fin Bug 15644
                     rtraspaso.iimptemp := TRUNC(TRIM(vreg202.campo_f3) / 100, 2);
                     rtraspaso.cinout := 1;
                     rtraspaso.fsolici := f_sysdate;
                     rtraspaso.tpolext := TRIM(vreg205.campo_f2);
                     rtraspaso.cbancar := TRIM(vreg215.campo_f4);
                     rtraspaso.ctiptras := TRIM(vreg202.campo_f1);
                     rtraspaso.iimporte := TRUNC(TRIM(vreg216.campo_f1) / 100, 2);
                     rtraspaso.fantigi := TO_DATE(TRIM(vreg225.campo_f3), 'DDMMYY');

                     -- Bug 15689 - RSC - 06/08/2010 - 0015676: CARGA DE Q234 CECA
                     IF rtraspaso.fantigi > TRUNC(f_sysdate) THEN
                        rtraspaso.fantigi := ADD_MONTHS(rtraspaso.fantigi, -1 * 100 * 12);
                     END IF;

                     -- Fin Bug 15689
                     rtraspaso.nporcen := TRUNC(TRIM(vreg202.campo_f4) / 100, 2);
                     rtraspaso.nparpla := TRUNC(TRIM(vreg202.campo_f5) / 100, 2);
                     rtraspaso.ctipder := TRIM(vreg210.campo_f1);
                     rtraspaso.cusualta := f_user;
                     -- Alberto - Añadimos campo f2 a numaport y el porcpos2006 pasa a ser f6
                     -- y recuperamos los datos del 228
                     rtraspaso.numaport := TRIM(vreg210.campo_f2);
                     rtraspaso.porcpos2006 := TRUNC(TRIM(vreg210.campo_f6) / 100, 2);
                     rtraspaso.ccobroreduc := TRIM(vreg228.campo_f1);
                     rtraspaso.anyoreduc := TRIM(vreg228.campo_f2);
                     rtraspaso.ccobroactual := TRIM(vreg228.campo_f3);
                     rtraspaso.anyoactual := TRIM(vreg228.campo_f4);
                     rtraspaso.importeacumact := TRUNC(TRIM(vreg228.campo_f5) / 100, 2);
                     rtraspaso.ctiptrassol := TRIM(vreg202.campo_f2);
                     rtraspaso.festado := f_sysdate;
                     rtraspaso.srefc234 := TRIM(vreg201.campo_f6);
                     rtraspaso.cmotrod := TRIM(vreg201.campo_f2);
                     rtraspaso.indemb := TRIM(vreg225.campo_f1);
                     rtraspaso.napomin := TRIM(vreg225.campo_f2);
                     rtraspaso.indesmin := TRIM(vreg225.campo_f4);
                     rtraspaso.indapanmin := TRIM(vreg225.campo_f9);
                     rtraspaso.indapenano := TRIM(vreg225.campo_f11);
                     rtraspaso.indprenano := TRIM(vreg225.campo_f12);
                     rtraspaso.imappaano := TRIM(vreg226.campo_f1) / 100;
                     rtraspaso.imapprano := TRIM(vreg226.campo_f2) / 100;
                     rtraspaso.imdctrasp := TRIM(vreg226.campo_f3) / 100;
                     rtraspaso.imdetrasp := TRIM(vreg226.campo_f4) / 100;
                     -- alberto - añadimos nuevo fcampo del 226/f5
                     rtraspaso.anyoaport := TRIM(vreg226.campo_f5);

                     -- Ini Bug 16470 - SRA - 26/10/2010
                     IF TRIM(TRIM(vreg240.campo_f1)) <> 0 THEN
                        -- Fin Bug 16470 - SRA - 26/10/2010
                        rtraspaso.nfcprest := TRIM(vreg240.campo_f1);
                        rtraspaso.indhccap := TRIM(vreg240.campo_f3);
                        rtraspaso.anoprpago := TRIM(vreg240.campo_f4);
                        rtraspaso.ctipcont := TRIM(vreg240.campo_f5);
                        rtraspaso.fconting := TO_DATE(TRIM(vreg240.campo_f6), 'DDMMYYYY');
                        rtraspaso.indhcpre := TRIM(vreg240.campo_f7);
                        rtraspaso.fprprest := TRIM(vreg240.campo_f8);
                     -- Ini Bug 16470 - SRA - 26/10/2010
                     END IF;

                     -- Fin Bug 16470 - SRA - 26/10/2010
                     IF rtraspaso.indesmin = 2 THEN
                        rtraspaso.fminusv := TO_DATE(vreg225.campo_f5, 'DDMMYY');
                     END IF;

                     v_traza := 5;

                     ----------------- Actualizamos TRASPLAINOUT---------------
                     UPDATE trasplainout
                        SET nparpla = NVL(rtraspaso.nparpla, nparpla),
                            nparret = NVL(rtraspaso.nparret, nparret),
                            fantigi = NVL(rtraspaso.fantigi, fantigi),
                            iimpanu = NVL(rtraspaso.imappaano, imappaano),
                            iimporte = NVL(rtraspaso.iimporte, iimporte),
                            iimptemp = NVL(rtraspaso.iimptemp, iimptemp),
                            cexterno = NVL(rtraspaso.cexterno, cexterno),
                            ctipder = NVL(rtraspaso.ctipder, ctipder),
                            nref = NVL(rtraspaso.nref, nref),
                            tcodpla = NVL(rtraspaso.tcodpla, tcodpla),
                            fvalor = NVL(rtraspaso.fvalor, fvalor),
                            fefecto = NVL(fefecto, TRUNC(f_sysdate)),   -- Bug 13979 - RSC - 15/09/2010 - Llistat traspassos
                            cusualta = NVL(rtraspaso.cusualta, cusualta),
                            nparpos2006 = NVL(rtraspaso.nparpos2006, nparpos2006),
                            porcpos2006 = NVL(rtraspaso.porcpos2006, porcpos2006),
                            nparant2007 = NVL(rtraspaso.nparant2007, nparant2007),
                            porcant2007 = NVL(rtraspaso.porcant2007, porcant2007),
                            ctipban = NVL(rtraspaso.ctipban, ctipban),
                            ctiptrassol = NVL(rtraspaso.ctiptrassol, ctiptrassol),
                            ccodaseg = NVL(rtraspaso.ccodaseg, ccodaseg),
                            ctipcom = NVL(rtraspaso.ctipcom, ctipcom),
                            sentext = NVL(rtraspaso.sentext, sentext),
                            fcontab = NVL(rtraspaso.fcontab, fcontab),
                            festado = NVL(rtraspaso.festado, festado),
                            ccompani = NVL(rtraspaso.ccompani, ccompani),
                            tcompani = NVL(rtraspaso.tcompani, tcompani),
                            iimpret = NVL(rtraspaso.iimpret, iimpret),
                            cenvio = NVL(rtraspaso.cenvio, cenvio),
                            srefc234 = NVL(rtraspaso.srefc234, srefc234),
                            cmotrod = NVL(rtraspaso.cmotrod, cmotrod),
                            nsinies = NVL(rtraspaso.nsinies, nsinies),
                            cmotivo = NVL(rtraspaso.cmotivo, cmotivo),
                            initransf = NVL(rtraspaso.initransf, initransf),
                            femtror = NVL(rtraspaso.femtror, femtror),
                            formacobr = NVL(rtraspaso.formacobr, formacobr),
                            indemb = NVL(rtraspaso.indemb, indemb),
                            napomin = NVL(rtraspaso.napomin, napomin),
                            indesmin = NVL(rtraspaso.indesmin, indesmin),
                            fminusv = NVL(rtraspaso.fminusv, fminusv),
                            indapanmin = NVL(rtraspaso.indapanmin, indapanmin),
                            imapanmin = NVL(rtraspaso.imapanmin, imapanmin),
                            indotcont = NVL(rtraspaso.indotcont, indotcont),
                            indensco = NVL(rtraspaso.indensco, indensco),
                            indapenano = NVL(rtraspaso.indapenano, indapenano),
                            indprenano = NVL(rtraspaso.indprenano, indprenano),
                            indcomptras = NVL(rtraspaso.indcomptras, indcomptras),
                            imappaano = NVL(rtraspaso.imappaano, imappaano),
                            imapprano = NVL(rtraspaso.imapprano, imapprano),
                            imdctrasp = NVL(rtraspaso.imdctrasp, imdctrasp),
                            imdetrasp = NVL(rtraspaso.imdetrasp, imdetrasp),
                            nfcprest = NVL(rtraspaso.nfcprest, nfcprest),
                            indmodano = NVL(rtraspaso.indmodano, indmodano),
                            indhccap = NVL(rtraspaso.indhccap, indhccap),
                            anoprpago = NVL(rtraspaso.anoprpago, anoprpago),
                            ctipcont = NVL(rtraspaso.ctipcont, ctipcont),
                            fconting = NVL(rtraspaso.fconting, fconting),
                            indhcpre = NVL(rtraspaso.indhcpre, indhcpre),
                            fprprest = NVL(rtraspaso.fprprest, fprprest),
                            cinout = NVL(rtraspaso.cinout, cinout),
                            fsolici = NVL(rtraspaso.fsolici, fsolici),
                            tpolext = NVL(rtraspaso.tpolext, tpolext),
                            cbancar = NVL(rtraspaso.cbancar, cbancar),
                            ctiptras = NVL(rtraspaso.ctiptras, ctiptras),
                            nporcen = NVL(rtraspaso.nporcen, nporcen),
                            -- alberto añadimos nuevos campo
                            numaport = NVL(rtraspaso.numaport, numaport),
                            ccobroreduc = NVL(rtraspaso.ccobroreduc, ccobroreduc),
                            anyoreduc = NVL(rtraspaso.anyoreduc, anyoreduc),
                            ccobroactual = NVL(rtraspaso.ccobroactual, ccobroactual),
                            anyoactual = NVL(rtraspaso.anyoactual, anyoactual),
                            importeacumact = NVL(rtraspaso.importeacumact, importeacumact),
                            anyoaport = NVL(rtraspaso.anyoaport, anyoaport)
                      WHERE stras = trasp.stras;

                     v_traza := 6;

----------------------------------------------------------
                     -- alberto - Insertamos las aportaciones 227
                     IF TRIM(TRIM(vreg210.campo_f2)) > 0 THEN
                        FOR i IN 1 .. TO_NUMBER(TRIM(vreg210.campo_f2)) LOOP
                           nerror := f_recuperar_reg(psproces, trasp.sref234, '227', i,
                                                     vreg227);

                           IF nerror <> 0 THEN
                              RAISE e_leyendo_datos_fichero;   --9901082
                           END IF;

                           rembargo.stras := trasp.stras;
                           rembargo.nbloq := TRIM(vreg245.campo_f1);
                           rembargo.tautorit := TRIM(vreg245.campo_f2);
                           rembargo.tdemanda := TRIM(vreg246.campo_f3);
                           rembargo.fcomunic := TO_DATE(TRIM(vreg246.campo_f2), 'DDMMYYYY');
                           rembargo.sseguro := NULL;
                           rembargo.finicio := NULL;
                           rembargo.cmotmov := NULL;

                           INSERT INTO trasplaaportaciones
                                       (stras, naporta,
                                        faporta,
                                        cprocedencia, ctipoderecho,
                                        importe_post,
                                        importe_ant)
                                VALUES (trasp.stras, TRIM(vreg227.campo_f1),
                                        TO_DATE(TRIM(vreg227.campo_f2), 'DDMMYYYY'),
                                        TRIM(vreg227.campo_f3), TRIM(vreg227.campo_f4),
                                        TRIM(vreg227.campo_f5) / 100,
                                        TRIM(vreg227.campo_f6) / 100);
                        END LOOP;
                     END IF;

                     -- Insertamos los embargos 245,246, registros embargos
                     FOR i IN 1 .. TO_NUMBER(TRIM(vreg225.campo_f1)) LOOP
                        rembargo := NULL;
                        nerror := f_recuperar_reg(psproces, trasp.sref234, '245', i, vreg245);

                        IF nerror <> 0 THEN
                           RAISE e_leyendo_datos_fichero;   --9901082
                        END IF;

                        nerror := f_recuperar_reg(psproces, trasp.sref234, '246', i, vreg246);

                        IF nerror <> 0 THEN
                           RAISE e_leyendo_datos_fichero;   --9901082
                        END IF;

                        rembargo.stras := trasp.stras;
                        rembargo.nbloq := TRIM(vreg245.campo_f1);
                        rembargo.tautorit := TRIM(vreg245.campo_f2);
                        rembargo.tdemanda := TRIM(vreg246.campo_f3);
                        rembargo.fcomunic := TO_DATE(TRIM(vreg246.campo_f2), 'DDMMYYYY');
                        rembargo.sseguro := NULL;
                        rembargo.finicio := NULL;
                        rembargo.cmotmov := NULL;

                        DECLARE
                           v_count        NUMBER;
                        BEGIN
                           SELECT COUNT(*)
                             INTO v_count
                             FROM trasplabloq;
                        END;

                        INSERT INTO trasplabloq
                                    (stras, nbloq, tautorit,
                                     tdemanda, fcomunic, sseguro,
                                     finicio, cmotmov)
                             VALUES (rembargo.stras, rembargo.nbloq, rembargo.tautorit,
                                     rembargo.tdemanda, rembargo.fcomunic, rembargo.sseguro,
                                     rembargo.finicio, rembargo.cmotmov);
                     END LOOP;

                     v_traza := 7;

                     -- reg 250 y 251 Informacion de las prestaciones del beneficiario
                     IF TRIM(TRIM(vreg240.campo_f1)) <> 0 THEN
                        FOR i IN 1 ..(TO_NUMBER(TRIM(vreg240.campo_f1))) LOOP
                           rprestacion := NULL;
                           nerror := f_recuperar_reg(psproces, trasp.sref234, '250', i,
                                                     vreg250);

                           IF nerror <> 0 THEN
                              RAISE e_leyendo_datos_fichero;   --9901082
                           END IF;

                           nerror := f_recuperar_reg(psproces, trasp.sref234, '251', i,
                                                     vreg251);

                           IF nerror <> 0 THEN
                              RAISE e_leyendo_datos_fichero;   --9901082
                           END IF;

                           -- Bug 16259 - RSC - 07/10/2010- HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
                           --rprestacion.stras := rtraspaso.stras;
                           rprestacion.stras := trasp.stras;
                           -- Fin Bug 16259
                           rprestacion.npresta := TRIM(vreg250.campo_f1);
                           rprestacion.sperson := vspersonase;
                           rprestacion.ctipcap := TRIM(vreg250.campo_f2);
                           rprestacion.ctipimp := TRIM(vreg250.campo_f3);
                           rprestacion.importe := TRIM(vreg250.campo_f4) / 100;
                           rprestacion.npartot := NULL;
                           rprestacion.impultab := TRIM(vreg250.campo_f5) / 100;
                           rprestacion.impminrf := TRIM(vreg250.campo_f6) / 100;
                           rprestacion.indbenef := TRIM(vreg250.campo_f7);
                           rprestacion.indpos06 := TRIM(vreg250.campo_f8);
                           rprestacion.porpos06 := TRIM(vreg250.campo_f9) / 100;

                           IF TRIM(vreg250.campo_f2) = 1 THEN
                              rprestacion.fpropag := TO_DATE(TRIM(vreg251.campo_f2), 'DDMMYY');
                           ELSE
                              rprestacion.fpropag := TO_DATE(TRIM(vreg251.campo_f3), 'DDMMYY');
                           END IF;

                           rprestacion.fultpag := TO_DATE(TRIM(vreg251.campo_f4), 'DDMMYY');
                           rprestacion.cperiod := TRIM(vreg251.campo_f5);

                           -- revaloriza?
                           IF TRIM(vreg250.campo_f2) = 2 THEN
                              rprestacion.creval := 1;
                              rprestacion.ctiprev := TRIM(vreg251.campo_f6);
                           ELSE
                              rprestacion.creval := 0;
                           END IF;

                           rprestacion.fprorev := NULL;

                           IF rprestacion.ctiprev IN(2, 3, 4) THEN
                              IF rprestacion.ctiprev = 2 THEN
                                 rprestacion.prevalo := TRIM(vreg251.campo_f7) / 1000;
                              ELSIF rprestacion.ctiprev = 3 THEN
                                 rprestacion.prevalo := TRIM(vreg251.campo_f7) / 100;
                              END IF;
                           END IF;

                           rprestacion.irevalo := NULL;

                           --
                           IF TRIM(vreg251.campo_f6) IN(2, 3, 4) THEN
                              rprestacion.nrevanu := TRIM(vreg251.campo_f8);   --??
                           END IF;

                           --
                           rprestacion.cbancar := NULL;
                           rprestacion.ctipban := NULL;
                           rprestacion.nsinies := NULL;

                           INSERT INTO trasplapresta
                                       (stras, npresta,
                                        sperson, ctipcap,
                                        ctipimp, importe,
                                        npartot, impultab,
                                        impminrf, indbenef,
                                        indpos06, porpos06,
                                        fpropag, fultpag,
                                        cperiod, creval,
                                        ctiprev, fprorev,
                                        prevalo, irevalo,
                                        nrevanu, cbancar,
                                        ctipban, nsinies)
                                VALUES (rprestacion.stras, rprestacion.npresta,
                                        rprestacion.sperson, rprestacion.ctipcap,
                                        rprestacion.ctipimp, rprestacion.importe,
                                        rprestacion.npartot, rprestacion.impultab,
                                        rprestacion.impminrf, rprestacion.indbenef,
                                        rprestacion.indpos06, rprestacion.porpos06,
                                        rprestacion.fpropag, rprestacion.fultpag,
                                        rprestacion.cperiod, rprestacion.creval,
                                        rprestacion.ctiprev, rprestacion.fprorev,
                                        rprestacion.prevalo, rprestacion.irevalo,
                                        rprestacion.nrevanu, rprestacion.cbancar,
                                        rprestacion.ctipban, rprestacion.nsinies);
                        END LOOP;
                     END IF;

                     v_traza := 8;

                     -- insertamos 230 y 231, aportantes plan de minusvalidos
                     FOR i IN 1 .. TO_NUMBER(TRIM(vreg225.campo_f2)) LOOP
                        raportante := NULL;
                        nerror := f_recuperar_reg(psproces, trasp.sref234, '230', i, vreg230);

                        IF nerror <> 0 THEN
                           RAISE e_leyendo_datos_fichero;   --9901082
                        END IF;

                        nerror := f_recuperar_reg(psproces, trasp.sref234, '231', i, vreg231);

                        IF nerror <> 0 THEN
                           RAISE e_leyendo_datos_fichero;   --9901082
                        END IF;

                        raportante.stras := trasp.stras;
                        raportante.naporta := TRIM(vreg230.campo_f1);

                        BEGIN
                           SELECT sperson
                             INTO raportante.sperson
                             FROM per_personas
                            WHERE nnumide = TRIM(vreg230.campo_f2);
                        EXCEPTION
                           WHEN OTHERS THEN
                              raportante.sperson := NULL;
                        END;

                        raportante.impapor := TRUNC(vreg230.campo_f3 / 100, 2);
                        raportante.indapmin := TRIM(vreg230.campo_f4);
                        raportante.impapmnano := TRUNC(TRIM(vreg230.campo_f5) / 100, 2);

                        INSERT INTO trasplaapo
                                    (stras, naporta, sperson,
                                     impapor, indapmin,
                                     impapmnano)
                             VALUES (raportante.stras, raportante.naporta, raportante.sperson,
                                     raportante.impapor, raportante.indapmin,
                                     raportante.impapmnano);
                     END LOOP;

                     v_traza := 9;

                     -- Com he actualizat el traspas, el recupero amb PAC_TRASPASOS
                     DECLARE
                        v_cursor       sys_refcursor;
                        traspaso       ob_iax_traspasos := ob_iax_traspasos();
                     BEGIN
                        v_cursor := pac_traspasos.f_get_traspaso(trasp.stras, nerror);

                        IF v_cursor IS NULL THEN
                           RAISE e_obteniendo_datosbd;
                        END IF;

                        LOOP
                           FETCH v_cursor
                            INTO traspaso.cbancar, traspaso.ccodpla_dgs, traspaso.tccodpla,
                                 traspaso.ccompani, traspaso.tcompani, traspaso.cestado,
                                 traspaso.cextern, traspaso.cinout, traspaso.ctipban,
                                 traspaso.ctipder, traspaso.ctiptras, traspaso.ctiptrassol,
                                 traspaso.fantigi, traspaso.fsolici, traspaso.fvalor,
                                 traspaso.iimpanu, traspaso.iimporte, traspaso.iimpret,
                                 traspaso.iimptemp, traspaso.ncertext, traspaso.nnumlin,
                                 traspaso.nparant2007, traspaso.nparpla, traspaso.nparpos2006,
                                 traspaso.nparret, traspaso.nporcen, traspaso.porcant2007,
                                 traspaso.porcpos2006, traspaso.nsinies, traspaso.sseguro,
                                 traspaso.stras, traspaso.tccodpla, traspaso.tmemo,
                                 traspaso.tpolext, traspaso.cagrpro, traspaso.sproduc,
                                 traspaso.srefc234, traspaso.cenvio, traspaso.ccodpla,
                                 traspaso.cmotivo, traspaso.fefecto
                                                                   -- Ini Bug 16259 - SRA - 27/10/2010
                                 , traspaso.ctipcont, traspaso.fconting;

                           -- Fin Bug 16259 - SRA - 27/10/2010
                           EXIT WHEN v_cursor%NOTFOUND;
                        END LOOP;

                        v_traza := 10;
------------
                        nerror :=
                           pac_traspasos.f_in_partic
                              (trasp.stras, traspaso.ctiptras,   ----recuperat en la funció anterior
                               trasp.sseguro,   ----recuperat en la funció anterior
                               traspaso.cagrpro,   ----recuperat en la funció anterior
                               traspaso.fvalor,   ----camp f del registre
                               traspaso.fefecto,   ----camp f del registre
                               traspaso.iimporte,   ----camp f del registre
                               traspaso.nparpla,   ----a null
                               traspaso.nporcen,   ----a null
                               traspaso.ctiptrassol,   ----indicat tipus d'import: doncs tipus = import
                               traspaso.cextern,   ----sempre extenr
                               NULL,   ----traspaso.sseguro_or (no el sabem)
                               0,   ----no es automaci
                               NULL,   --traspaso.pordcons no s'usa a f_in_partic
                               NULL,   --traspaso.pordecon no s'usa a f_in_partic
                               NULL,   --traspaso.sproces,
                               traspaso.ctipder);   ----camp f del registre

                        -- JGM!!!! capturar error
                        IF nerror <> 0 THEN
                           DECLARE
                              ttexto         VARCHAR2(100);
                           BEGIN
                              -- si llego aqui todo ok
                              UPDATE tdc234_in
                                 SET cestacc = 1,
                                     cerror = nerror
                               WHERE sproces = psproces
                                 AND sref234 = trasp.sref234;

                              ttexto := f_axis_literales(nerror, f_idiomauser);
                              nerror := f_proceslin(psproces, ttexto || '-' || vsref234,
                                                    v_traza, vnnumlin, 1);
                           END;
                        ELSE
                           -- si llego aqui todo ok
                           UPDATE tdc234_in
                              SET cestacc = 2,
                                  cerror = NULL
                            WHERE sproces = psproces
                              AND sref234 = trasp.sref234;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'PK_TR234_IN', v_traza, SQLERRM,
                                       SQLCODE);
                           RAISE ABORT;
                     END;
                  ELSE   -- IF  to_number(vreg225.campo_f13) = 2 --> ES  COMPLEMENT I NO SABEM COM FER-HO
                     NULL;   --JGM - PENDENT!!!
                  END IF;
               ELSE   -- stras es null ho poso a la taula com error
                  UPDATE tdc234_in
                     SET cestacc = 1,
                         cerror = 9000480
                   WHERE sproces = psproces
                     AND sref234 = vsref234;
               END IF;
            ELSIF TO_NUMBER(vreg201.campo_f1) = 4 THEN   -----rebuig d'una transferència d'un traspàs de sortida
               NULL;   --JGM - PENDENT!!!
            ELSE
               -- no es un registro de entrada?
               NULL;   --JGM - PENDENT!!!
            END IF;

            COMMIT;
         EXCEPTION
            WHEN ABORT THEN
               DECLARE
                  v_dummy        VARCHAR2(100);
                  ttexto         VARCHAR2(100);
               BEGIN
                  v_dummy := SQLERRM;
                  ttexto := f_axis_literales(9000464, f_idiomauser);
                  nerror := f_proceslin(psproces, ttexto || '-' || vsref234, v_traza,
                                        vnnumlin, 1);
               END;

               ROLLBACK;

               UPDATE tdc234_in
                  SET cestacc = 1,
                      cerror = -1
                WHERE sproces = psproces
                  AND sref234 = vsref234;

               COMMIT;
            WHEN e_leyendo_datos_fichero THEN
               DECLARE
                  v_dummy        VARCHAR2(100);
                  ttexto         VARCHAR2(100);
               BEGIN
                  v_dummy := SQLERRM;
                  ttexto := f_axis_literales(103187, f_idiomauser);
                  nerror := f_proceslin(psproces, ttexto || '-' || vsref234, v_traza,
                                        vnnumlin, 1);
               END;

               ROLLBACK;

               UPDATE tdc234_in
                  SET cestacc = 1,
                      cerror = 103187
                WHERE sproces = psproces
                  AND sref234 = vsref234;

               COMMIT;
            WHEN e_obteniendo_datosbd THEN
               DECLARE
                  v_dummy        VARCHAR2(100);
                  ttexto         VARCHAR2(100);
               BEGIN
                  v_dummy := SQLERRM;
                  ttexto := f_axis_literales(9901082, f_idiomauser);
                  nerror := f_proceslin(psproces, ttexto || '-' || vsref234, v_traza,
                                        vnnumlin, 1);
               END;

               ROLLBACK;

               UPDATE tdc234_in
                  SET cestacc = 1,
                      cerror = 9901082
                WHERE sproces = psproces
                  AND sref234 = vsref234;

               COMMIT;
            WHEN OTHERS THEN
               DECLARE
                  v_dummy        VARCHAR2(100);
                  ttexto         VARCHAR2(100);
               BEGIN
                  v_dummy := SQLERRM;
                  ttexto := f_axis_literales(1000455, f_idiomauser);
                  nerror := f_proceslin(psproces, ttexto || SQLERRM, v_traza, vnnumlin, 1);
               END;

               ROLLBACK;

               UPDATE tdc234_in
                  SET cestacc = 1,
                      cerror = 1000455
                WHERE sproces = psproces
                  AND sref234 = vsref234;

               COMMIT;
         END;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;   -- no debería pasar nunca
   END f_ejecutar_acciones;

   FUNCTION f_ejecutar_fichero(
      pfichero IN VARCHAR2,
      ppath IN VARCHAR2,
      p_cproces IN NUMBER,   -- BUG16130:DRA:15/10/2010
      psproces IN OUT NUMBER)   --Bug 14750-PFA-31/05/2010- psproces IN OUT
      RETURN NUMBER IS
      nerror         NUMBER;
      vsmapead       NUMBER;
      ttexto         VARCHAR2(200);
   -- pcproceso      NUMBER;   -- BUG16130:DRA:15/10/2010
   BEGIN
      COMMIT;
      /*SELECT sproces.NEXTVAL
        INTO psproces
        FROM DUAL;*/
      ttexto := f_axis_literales(151759, f_idiomauser);

      IF psproces IS NULL THEN   --Bug 14750-PFA-31/05/2010- psproces IN OUT
         nerror := f_carga_fichero(pfichero, ppath, psproces);
      END IF;

      -- BUG16130:DRA:15/10/2010:Inici
      -- SELECT cproceso
      --   INTO pcproceso
      --   FROM cfg_files
      --  WHERE cempres = pac_md_common.f_get_cxtempresa
      --    AND tproceso = 'PK_TR234_IN.f_ejecutar_fichero';
      -- BUG16130:DRA:15/10/2010:Fi
      IF nerror <> 0 THEN
         ROLLBACK;

         INSERT INTO int_carga_ctrl
                     (sproces, tfichero, fini, ffin, cestado, cerror,
                      terror, cusuario, fmovimi, cproceso)
              VALUES (psproces, pfichero, f_sysdate, NULL, 1, 151541,
                      f_axis_literales(151541, f_idiomauser), f_user, f_sysdate, p_cproces);   --Bug 14750-PFA-28/05/2010- Añadir campo identificador de proceso(cproceso)

         COMMIT;
         RETURN -1;
      ELSE
         INSERT INTO int_carga_ctrl
                     (sproces, tfichero, fini, ffin, cestado, cerror, terror, cusuario,
                      fmovimi, cproceso)
              VALUES (psproces, pfichero, f_sysdate, f_sysdate, 4, NULL, NULL, f_user,
                      f_sysdate, p_cproces);   --Bug 14750-PFA-28/05/2010- Añadir campo identificador de proceso(cproceso)

         COMMIT;
      END IF;

      nerror := f_ejecutar_acciones(psproces);

      IF nerror <> 0 THEN
         UPDATE int_carga_ctrl
            SET cerror = 1,
                terror = f_axis_literales(1000455, f_idiomauser)
          WHERE sproces = psproces;

         COMMIT;
         RETURN -1;
      ELSE
         DECLARE
            CURSOR c1 IS
               SELECT   *
                   FROM tdc234_in
                  WHERE sproces = psproces
               ORDER BY stdc234in;

            v_contador     NUMBER(5) := 1;
         BEGIN
            FOR v_c1 IN c1 LOOP
               INSERT INTO int_carga_ctrl_linea
                           (sproces, nlinea, ctipo, idint, idext,
                            cestado, cvalidado, sseguro, nsinies,
                            ntramit, sperson, nrecibo, cusuario, fmovimi)
                    VALUES (psproces, v_contador, 4, v_c1.stdc234in, v_c1.sref234,
                            DECODE(v_c1.cestacc, 0, 3, 1, 1, 2, 4), 1, v_c1.sseguro, NULL,
                            NULL, NULL, NULL, f_user, v_c1.fcarga);

               IF v_c1.cerror IS NOT NULL THEN
                  INSERT INTO int_carga_ctrl_linea_errs
                              (sproces, nlinea, nerror, ctipo, cerror,
                               tmensaje, cusuario, fmovimi)
                       VALUES (psproces, v_contador, 1, 1, v_c1.cerror,
                               f_axis_literales(v_c1.cerror, f_idiomauser), f_user, f_sysdate);
               END IF;

               v_contador := v_contador + 1;
            END LOOP;

            COMMIT;
         END;
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -1;
   END f_ejecutar_fichero;
END;

/

  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_TR234_IN" TO "PROGRAMADORESCSI";
