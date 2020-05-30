/* Formatted on 2019/08/28 11:20 (Formatter Plus v4.8.8) */
--------------------------------------------------------
--  DDL for Package Body PAC_DEVOLU
--------------------------------------------------------

CREATE OR REPLACE PACKAGE BODY pac_devolu
IS
   /******************************************************************************
      NOMBRE:       PAC_DEVOLU
      PROP¿SITO:
      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
       1.0       -            -               1.  Creaci¿n de package
       2.0       05/03/2009   RSC             2.  Unificaci¿n de recibos
       3.0       18/05/2009   XPL             3.  Prepara funciones para Java
       4.0       17/11/2010   ICV             4.  0016383: AGA003 - recargo por devoluci¿n de recibo (renegociaci¿n de recibos)
       5.0       19/07/2011   JMP             5.  0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
       6.0       25/11/2011   JGR             6.  0020037: Parametrizaci¿n de Devoluciones
       7.0       27/01/2012   JGR             7.  0021026: LCOL-Repasar todo el circuito de anulaci¿n por convenio - Nota: 105180
       8.0       30/01/2012   JGR             8.  0021026: LCOL_A001-Convenio: parametrizar todos los productos; Programaci¿n
       9.0       30/01/2012   JGR             9.  0021026: LCOL_A001-Convenio: parametrizar todos los productos; Programaci¿n
      10.0       01/02/2012   JGR            10.  0021115: LCOL_A001-Rebuts no pagats i anticips
      11.0       10/02/2012   JGR            11.  0021115: LCOL_A001-Rebuts no pagats i anticips II
      12.0       16/02/2012   JGR            12.
      13.0       27/02/2012   JGR            13.  0021480: LCOL898-Temar pendientes de DOMICILIACIONES - Al final lo haremos en par_recua
      14.0       02/03/2012   JGR            14.  0021570: LCOL_A001-Temas pendientes de la terminacion por no pago - Convenio - 108961
      15.0       19/03/2012   JGR            15.  0021570: LCOL_A001-Temas pendientes de la terminacion por no pago - Convenio - 110567
      16.0       27/03/2012   JGR            16.  0021570: LCOL_A001-Temas pendientes de la terminacion por no pago - Convenio - 111635
      17.0       16/04/2012   JGR            17.  0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
                 20/04/2012   JGR            17.1 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135
      18.0       23/04/2012   JMF            18.  0022030: MDP_A001-Devoluciones: impresion y gestion de cartas
      19.0       10/05/2012   JGR            19.  0022241: Devoluciones - Acci¿n 7 - Anular p¿lizas con prestamos de menos de 1 a¿o.
      20.0       16/05/2012   JGR            20.  0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 y 0114943
      21.0       16/05/2012   JGR            21.  0022497: LCOL_A001-Prestamos en terminacion por no pago - 0116515
      22.0       02/07/2012   JGR            22.  0022686: LCOL_A004-Cumulos anulados anteriormente a la alta de polizas - 0117742
      23.0       28/06/2012   JGR            23.  0022738: No se cancel¿ la p¿liza 1541 despues de tres intetos de cobro no exitosos. - 0118685
      24.0       21/06/2012   APD            24.  0022084: LCOL_A003-Consulta de recibos - Fase 2
      25.0       26/07/2012   JGR            25.  0022086: LCOL_A003-Devoluciones - Fase 2 - 0117715
      26.0       30/07/2012   JGR            26.  0022762: MDP_A001-Impago de recibos (impago masivo) - 0119021
      27.0       02/08/2012   JGR            27.  0022738: LCOL_A001- 0120453 - Es l'¿ltima versi¿
      28.0       26/06/2012   APD            28.  0022342: MDP_A001-Devoluciones
      29.0       19/09/2012   MDS            29.  0023749: LCOL_T001-Autoritzaci? de prestecs
      30.0       02/10/2012   JGR            30.  0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752
      31.0       26/09/2012   JGR            31.  0022346: LCOL_A003-Cobro parcial de los recibos Fase 2
      32.0       22/02/2012   JGR            32.  0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818
      33.0       06/03/2013   JGR            33.  0025151: LCOL999-Redefinir el circuito de prenotificaciones
      34.0       08/07/2013   MMM            34.  0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto"
      35.0       31/07/2013   MMM            35.  0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189
      36.0       14/08/2013   JGR            36.  0027940: Modificar mensajes para PROESOSLIN en PAC_DEVOLU - QT-8414
      37.0       18/09/2013   JGR            37.  0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package
      38.0       16/10/2013   MMM            38.  0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago
      39.0       02/12/2013   MMM            39.  0029225: LCOL_MILL-0010290 Error al incluir apuntes de agenda para recibos rechazados agrupados en proceso del cobrador VISA
      40.0       24/12/2013   MMM            40.  0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar toda la informacion q venia en la poliza inicial, sin actual
      41.0       21/01/2014   MMM            41.  0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda
      42.0       10/03/2014   JGR            42.  0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago
      43.0       13/03/2014   JGR            43.  0029175: POSND100-POSADM - D?as de Gracia - 169601
      44.0       02/06/2014   MMM            44.  0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
      45.0       13/06/2014   JGR            45.  0029175: POSND100-POSADM - D?as de Gracia - 177345
      46.0       18/07/2014   dlF            46.  0031930: Errores en la carta de impago (AGM)
      47.0       01/10/2014   MMS            47.  0032673: COLM004-Para PAC tendremos 3 intentos y PAT dos reintentos de cobro
      48.0       16/03/2015   MSV            48.  0032765: Se almacena en las devoluciones el recibo que se impaga - 199698
      49.0       16/03/2015   MMS            49.  0035645: Se almacena en las devoluciones el recibo que se impaga - 199698
      50.0       15/05/2019   ECP            50.  IAXIS - 3592 Proceso de terminación por no pago
      51.0       05/05/2020   ECP            51.  IAXIS-13167.Permite cancelar pólizas que tienen siniestros abiertos
   ******************************************************************************/

   ------------------------------------------------------------------------------
--  Carga_Fichero_Devo:
--    C¿rrega del fitxer de devolucions. Anteriorment es feia a nivell de
--   formulari, per¿ es passa a B.D. per poder llan¿ar-ho autom¿ticament
--   via batch.
------------------------------------------------------------------------------
   FUNCTION f_carga_fichero_devo (
      pnom_fitxer   VARCHAR2,
      pidioma       VARCHAR2 DEFAULT '2',
      pproceso      NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      --  A¿ado el pproceso para que no me inicialice con un nuevo psproces
      -- ya que al ser llamado desde BATCH yo ya tengo el n¿mero de proceso.

      -----------
--VARIABLES
-----------
      in_file          UTL_FILE.file_type;
      --out_file          Text_IO.File_Type;
      linebuf          VARCHAR2 (400);
      texto            VARCHAR2 (100);
      --TEXTO2             VARCHAR2(100);
      directory_name   VARCHAR2 (100);
      error            NUMBER;
      --file_name         VARCHAR2(100);
      nprolin          NUMBER             := NULL;
      num_err          NUMBER;
      num_err_proces   NUMBER;
      linea            NUMBER;
      num_lin          NUMBER;
   BEGIN
      IF pnom_fitxer IS NULL
      THEN
         RETURN (112223);
      END IF;

      pac_devolu.nombre_fichero := pnom_fitxer;

      ----------
      --INICICIALITZEM EL PROCES
      ---------
      -- Se graba en Procesoscab (no en Procesos)
      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      IF pproceso IS NULL
      THEN
         num_err_proces :=
            f_procesini (f_user,
                         f_parinstalacion_n ('EMPRESADEF'),
                         'Pac_devolu',
                            f_axis_literales (9904139, pidioma)
                         || ': '
                         || TO_CHAR (f_sysdate, 'MM-DD-YYYY  HH:MI'),
                         psproces
                        );
      ELSE
         error :=
            f_proceslin (pproceso,
                            f_axis_literales (9904139, pidioma)
                         || ': '
                         || TO_CHAR (f_sysdate, 'MM-DD-YYYY  HH:MI'),
                         1,
                         num_lin
                        );
         psproces := pproceso;
      END IF;

      IF num_err_proces != 0
      THEN
         RETURN num_err_proces;
      END IF;

      COMMIT;
-----------------------
--OBTENIM EL FITXER
-----------------------
      directory_name := f_parinstalacion_t ('R_DEVOLUC');
      primera_vegada := TRUE;
      --      DBMS_OUTPUT.put_line ('Directori ' || directory_name);
      --      DBMS_OUTPUT.put_line ('Fitxer ' || pnom_fitxer);
      in_file := UTL_FILE.fopen (directory_name, pnom_fitxer, 'r');
      --      DBMS_OUTPUT.put_line ('obrim ');
      --INICILITZACIONS
      n_total_ind_ok_llegit := 0;
      n_total_ind_ok_teoric := 0;
      n_total_ind_ko := 0;
      s_total_imp_llegit := 0;
      s_total_imp_teoric := 0;
      --  nprolin               :=NULL;
      ncartes := 0;
      --Guardem el nom del fitxer
      pk_autom_fichero := pnom_fitxer;
-----------------------
--MAIN LOOP
-----------------------
      linea := 1;

      LOOP
         --         DBMS_OUTPUT.put_line ('LEE LINEA');
         UTL_FILE.get_line (in_file, linebuf);
         --         DBMS_OUTPUT.put_line ('devbanrecibos ' || linebuf);
         num_err := caso_fichero (linebuf, pidioma);

         --Inserta a DEVBANRECIBOS
         --         DBMS_OUTPUT.put_line ('despues de lcasofichero:' || num_err);
         IF num_err != 0
         THEN
            --Si ¿s un altre tipus d'error continuem
            --102554;   --No hi ha cap empresa amb aquest NIF
            --102543;   --rEGISTRE DUPLICAT A DEVBANPRESENTADORES
            --103942    --Error a l' inserir a la taula DEVBANPRESENTADORES
            --103943;   --Error a l' inserir a la taula DEVBANORDENANTES
            --102374;  --Cobrador bancari no trobat a COBBANCARIO
            --105245   -- Fitxer ja carregat previament
            IF num_err IN
                  (102543, 103942, 102554, 103943, 103944, 102543, 102374,
                   105245)
            THEN
               --               DBMS_OUTPUT.put_line ('************ rollback 1 ****************');
               ROLLBACK;
               texto := f_axis_literales (num_err, pidioma);
               num_err_proces :=
                   f_proceslin (psproces, SUBSTR (texto, 1, 120), 1, nprolin);
               texto := f_axis_literales (111968, pidioma);
               num_err_proces :=
                  f_proceslin (psproces,
                               SUBSTR (   texto
                                       || '.Linea n¿ '
                                       || linea
                                       || ',Valor: '
                                       || linebuf,
                                       1,
                                       120
                                      ),
                               1,
                               nprolin
                              );
               UTL_FILE.fclose (in_file);
               COMMIT;
               RETURN num_err;
            ELSE
               texto := f_axis_literales (num_err, pidioma);
               num_err_proces :=
                  f_proceslin (psproces,
                               SUBSTR (   texto
                                       || '.Linea n¿ '
                                       || linea
                                       || ',Valor: '
                                       || linebuf,
                                       1,
                                       120
                                      ),
                               1,
                               nprolin
                              );
            END IF;
         END IF;

         linea := linea + 1;
      END LOOP;

      --Aqui surto perque hi ha hagut un error.
      --Si el fitxer est¿ obert, el tanco
      --      DBMS_OUTPUT.put_line ('************ rollback 2 ****************');
      ROLLBACK;

      IF UTL_FILE.is_open (in_file)
      THEN
         UTL_FILE.fclose (in_file);
      END IF;

      RETURN num_err;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         UTL_FILE.fclose (in_file);

         --         DBMS_OUTPUT.put_line (   'Acabamos por no data found con sdevolu  '
         --                               || vsdevolu
         --                              );

         --  Comprobem que s'hagin carregat registres
         SELECT COUNT ('A')
           INTO linea
           FROM devbanrecibos
          WHERE sdevolu = vsdevolu;

         IF linea = 0
         THEN
            texto := f_axis_literales (102903, pidioma);
            num_err_proces :=
                   f_proceslin (psproces, SUBSTR (texto, 1, 120), 1, nprolin);
            num_err := 102903;                   -- No s'han trobat registres
         ELSE
            num_err := tratar_devoluciones (pidioma);

            -- Llegeix a DEVBANRECIBOS i els posa a TMP_IMPAGADOS
            --            DBMS_OUTPUT.put_line ('despues de tratar devoluciones' || num_err);
            IF num_err != 0
            THEN
               --               DBMS_OUTPUT.put_line('************ rollback 3 ****************');
               ROLLBACK;
               texto := f_axis_literales (num_err, pidioma);
               num_err_proces := f_proceslin (psproces, texto, 1, nprolin);
            ELSE
---------------------------
--TRACTAMENT DELS REBUTS
---------------------------
               texto := f_axis_literales (101815, pidioma);
               num_err_proces := f_proceslin (psproces, texto, 1, nprolin);
               num_err_proces := f_procesfin (psproces, 0);
            END IF;

            COMMIT;
         END IF;

         RETURN num_err;
      WHEN OTHERS
      THEN
         --         DBMS_OUTPUT.put_line ('************ rollback 4 ****************');
         --         DBMS_OUTPUT.put_line (SQLERRM);
         ROLLBACK;
         num_err_proces :=
            f_proceslin (psproces,
                         SUBSTR (   'Error: '
                                 || SQLERRM
                                 || ' LINEA: '
                                 || SUBSTR (linebuf, 20, 35),
                                 1,
                                 120
                                ),
                         1,
                         nprolin
                        );
         COMMIT;

         IF UTL_FILE.is_open (in_file)
         THEN
            UTL_FILE.fclose (in_file);
         END IF;

         RETURN 9001896;
   END f_carga_fichero_devo;

   ----------
   ----CASO FICHERO
   ----------
   FUNCTION caso_fichero (linea VARCHAR2, pidioma VARCHAR2)
      RETURN NUMBER
   IS
      num_error_pro_ini   NUMBER;
      num_error           NUMBER;
      nprolin             NUMBER := NULL;
   BEGIN
      num_error := 0;
      lin := SUBSTR (linea, 1, 162);
      codreg := SUBSTR (lin, 1, 2);

--      DBMS_OUTPUT.put_line ('caso fichero codreg ' || codreg);

      -- Cabecera presentador
      IF codreg = 1 OR codreg = 51
      THEN
--         DBMS_OUTPUT.put_line ('antes de tratar cpresentador');
         num_error := tratar_cpresentador (lin);
--         DBMS_OUTPUT.put_line ('depsues de tratar cpresentador' || num_error);
      -- Cabecera ordenante
      ELSIF codreg = 3 OR codreg = 53
      THEN
--         DBMS_OUTPUT.put_line ('Tratar ordenante');
         num_error := tratar_cordenante (lin);
--         DBMS_OUTPUT.put_line (   'Despues de tratar ordenantes con errror '
--                               || num_error
--                              );
         n_total_ind_ok_llegit := 0;
      -- Registros
      ELSIF codreg = 6 OR codreg = 56
      THEN
--         DBMS_OUTPUT.put_line ('tratamos el registro del recibo impagado');
         reg := reg + 1;
         num_error := tratar_registros (lin);

--         DBMS_OUTPUT.put_line ('Despues de tratar el registro');
         IF num_error = 0
         THEN
            n_total_ind_ok_llegit := n_total_ind_ok_llegit + 1;
            n_total_presentador := NVL (n_total_presentador, 0) + 1;
         ELSE
            n_total_ind_ko := n_total_ind_ko + 1;
         END IF;
      -- total ordenante
      ELSIF codreg = 8 OR codreg = 58
      THEN
         num_error := tratar_tordenante (lin);
         v_regorden := 0;
      -- Total general
      ELSIF codreg = 9 OR codreg = 59
      THEN
         num_error := tratar_tgeneral (lin);
      END IF;

      IF num_error != 0
      THEN
         num_error_pro_ini :=
            f_proceslin (psproces,
                         SUBSTR (   'Error='
                                 || num_error
                                 || ' LINEA: '
                                 || SUBSTR (linea, 20, 35),
                                 1,
                                 120
                                ),
                         2,
                         nprolin
                        );
      END IF;

      RETURN num_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         num_error :=
            f_proceslin (psproces,
                         SUBSTR (   'Error='
                                 || SQLERRM
                                 || ' LINEA: '
                                 || SUBSTR (linea, 20, 35),
                                 1,
                                 120
                                ),
                         2,
                         nprolin
                        );
         RETURN 105133;
   END caso_fichero;

   ----------
   ---- Tratar_cpresentador
   ----------
   FUNCTION tratar_cpresentador (lin1 VARCHAR2)
      RETURN NUMBER
   IS
      sdevolu_antic   NUMBER;
      num_error       NUMBER;
      coddato         NUMBER (2);
      nombre          VARCHAR2 (40);
      entidad         VARCHAR2 (4);
      oficina         VARCHAR2 (4);
      tentidad        VARCHAR2 (40);
      fecha_pres1     DATE;
      v_cempresa      NUMBER;
      nprolin         NUMBER        := NULL;
   BEGIN
      --      DBMS_OUTPUT.put_line ('entramos a tratar_cpresentador');
      --INICIALITZACIONS
      num_error := 0;
      s_total_imp_teoric := 0;
      s_total_imp_llegit := 0;
      n_total_ind_ok_llegit := 0;
      n_total_presentador := 0;
      n_total_ind_ko := 0;
      n_total_ind_ok_teoric := 0;

      BEGIN
         -- tractem la linea del fitxer
         codreg := SUBSTR (lin1, 1, 2);
         coddato := SUBSTR (lin1, 3, 2);
         nif_pres1 := SUBSTR (lin1, 5, 9);
         ttsufijo_pres1 := SUBSTR (lin1, 14, 3);
         fecha_pres1 := TO_DATE (SUBSTR (lin1, 17, 6), 'DDMMYY');
         nombre := NVL (SUBSTR (lin1, 29, 40), '????');
         entidad := SUBSTR (lin1, 89, 4);
         oficina := SUBSTR (lin1, 93, 4);
         tentidad := SUBSTR (lin1, 109, 40);
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            3,
                            nprolin
                           );
            RETURN SQLCODE;
      --      message('cpresentador:1 excpetio de when others'||sqlerrm);
      END;

      IF nombre IS NULL OR nombre LIKE ' %'
      THEN
         nombre := '???????';
      END IF;

      --      DBMS_OUTPUT.put_line ('empresa: ' || nif_pres1);
      BEGIN
         -- Seleccionem el codi d'empresa
         SELECT cempres
           INTO v_cempresa
           FROM empresas
          WHERE nnumnif = nif_pres1;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            3,
                            nprolin
                           );
            --print_MESSAGE('STOP', 102554, ' ('|| nif_pres1||')');
            RETURN (102554);             --No hi ha cap empresa amb aquest NIF
      END;

      ------
      --Identificaci¿ de la devoluci¿
      ------
      BEGIN
         --Mirem si ja existeix
         -- Seleccionem el maxim de la devolucio
         SELECT sdevolu
           INTO sdevolu_antic
           FROM devbanpresentadores
          WHERE cdoment = entidad
            AND cdomsuc = oficina
            AND TRUNC (fsoport) = TRUNC (fecha_pres1)
            AND tficher = pac_devolu.nombre_fichero;
      EXCEPTION
         WHEN OTHERS
         THEN
            sdevolu_antic := NULL;
      END;

      ------
      -- PEr comprobar si ¿s multiregistre
      ------
      IF primera_vegada = TRUE
      THEN
         primera_vegada := FALSE;

         IF sdevolu_antic IS NOT NULL
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR ('Sdevolu_antic =' || sdevolu_antic, 1,
                                    120),
                            3,
                            nprolin
                           );
            RETURN (105245);
         END IF;
      END IF;

      IF sdevolu_antic IS NULL
      THEN
         --ES NOU
         BEGIN
            -- Seleccionem el maxim de la devolucio
            SELECT NVL (MAX (sdevolu), 0) + 1
              INTO vsdevolu
              FROM devbanpresentadores;
         --messagE('com es nou agafo el maxim.v_sdevolu: '||v_sdevolu);pause;
         EXCEPTION
            WHEN OTHERS
            THEN
               --       MESSAGE('Tratar_cpresentador.sqlerrm:'||sqlerrm||' de max_dev_presntadores:' );PAUSE;
               NULL;
         END;
      ELSE
         vsdevolu := sdevolu_antic;
      END IF;

      ------
      --Inserto a devbanpresentadores
      ------
      BEGIN
         INSERT INTO devbanpresentadores
                     (sdevolu, cempres, cdoment, cdomsuc, fsoport,
                      nnumnif, tsufijo, tprenom, fcarga, cusuari,
                      tficher
                     )
              VALUES (vsdevolu, v_cempresa, entidad, oficina, fecha_pres1,
                      nif_pres1, ttsufijo_pres1, nombre, f_sysdate, f_user,
                      pk_autom_fichero
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            num_error := 0;
         WHEN OTHERS
         THEN
            --     print_message('NOTE', 103942, sqlerrm);
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            3,
                            nprolin
                           );
            RETURN (103942);
      --Error a l' inserir a la taula DEVBANPRESENTADORES
      END;

      RETURN (num_error);
   END tratar_cpresentador;

   ----------
   ----TRATAR _CORDENANTE
   ----------
   FUNCTION tratar_cordenante (lin1 VARCHAR2)
      RETURN NUMBER
   IS
      v_ccobban    NUMBER (3);
      v_ordccc     NUMBER (20);
      data_repe    NUMBER;
      num_error    NUMBER;
      coddato      NUMBER (2);
      nombre       VARCHAR2 (40);
      entidad      VARCHAR2 (4);
      oficina      VARCHAR2 (4);
      tentidad     VARCHAR2 (40);
      fecha_ord1   DATE;
      dc           VARCHAR2 (2);        -- D¿gitos de control, sino dado (**)
      ccc          VARCHAR2 (10);                                -- n¿ cuenta
      nprolin      NUMBER;
      v_iordtot    NUMBER (12, 2);
      v_nordtot    NUMBER (10);
      v_nordreg    NUMBER (10);
      cuenta       VARCHAR2 (20);
   BEGIN
      num_error := 0;

      BEGIN
         -- tractem la linea del fitxer
         codreg := SUBSTR (lin1, 1, 2);
         coddato := SUBSTR (lin1, 3, 2);
         nif_ord1 := SUBSTR (lin1, 5, 9);
         ttsufijo_ord1 := SUBSTR (lin1, 14, 3);
         fecha_ord1 := TO_DATE (SUBSTR (lin1, 23, 6), 'DDMMYY');
         nombre := SUBSTR (lin1, 29, 40);
         entidad := SUBSTR (lin1, 69, 4);
         oficina := SUBSTR (lin1, 73, 4);
         dc := SUBSTR (lin1, 77, 2);
         ccc := SUBSTR (lin1, 79, 10);
         cuenta := SUBSTR (lin1, 69, 20);
         fecha_rem := fecha_ord1;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            4,
                            nprolin
                           );
            RETURN SQLCODE;
      --message('Tratar_cordenante:'||sqlerrm);pause;
      END;

      -- Seleccionem el cobrador bancari en funci¿ del sufix
      BEGIN
         SELECT ccobban
           INTO v_ccobban
           FROM cobbancario
          WHERE tsufijo = ttsufijo_ord1
            AND entidad = cdoment
            AND oficina = cdomsuc
            AND TO_NUMBER (cuenta) = ncuenta;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            -- Buscamos un cobrador para esa entidad
            -- si no existe, cogemos el 1
            BEGIN
               SELECT NVL (MIN (ccobban), 1)
                 INTO v_ccobban
                 FROM cobbancario
                WHERE entidad = cdoment AND oficina = cdomsuc;
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_error :=
                     f_proceslin (psproces,
                                  SUBSTR (   'Error='
                                          || SQLERRM
                                          || ' LINEA: '
                                          || SUBSTR (lin1, 20, 35),
                                          1,
                                          120
                                         ),
                                  4,
                                  nprolin
                                 );
                  num_error := 102374;
                  --Cobrador bancari no trobat a COBBANCARIO
                  RETURN (num_error);
            END;
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            4,
                            nprolin
                           );
            num_error := 102374;    --Cobrador bancari no trobat a COBBANCARIO
            RETURN (num_error);
      END;

      IF dc <> '**'
      THEN
         v_ordccc :=
            TO_NUMBER (entidad || oficina || dc || ccc, 99999999999999999999);
      ELSE
         v_ordccc :=
            TO_NUMBER (entidad || oficina || '00' || ccc,
                       99999999999999999999
                      );
      END IF;

      BEGIN
         INSERT INTO devbanordenantes
                     (sdevolu, nnumnif, tsufijo, fremesa,
                      ccobban, tordnom, nordccc
                     )
              VALUES (vsdevolu, nif_ord1, ttsufijo_ord1, fecha_ord1,
                      v_ccobban, nombre, v_ordccc
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            SELECT MAX (fremesa) + (1 / 24 / 3600)
              INTO fecha_ord1
              FROM devbanordenantes
             WHERE sdevolu = vsdevolu;

            fecha_rem := fecha_ord1;

            --            DBMS_OUTPUT.put_line ('insertamos en devbanordenanes');
            INSERT INTO devbanordenantes
                        (sdevolu, nnumnif, tsufijo, fremesa,
                         ccobban, tordnom, nordccc
                        )
                 VALUES (vsdevolu, nif_ord1, ttsufijo_ord1, fecha_ord1,
                         v_ccobban, nombre, v_ordccc
                        );
         WHEN OTHERS
         THEN
            -- Mirem si tenem la mateixa data de remesa
            --       DBMS_OUTPUT.put_line (   SQLERRM
            --                                  || 'El cobrador bancario es '
            --                                  || v_ccobban
            --                                 );
            SELECT COUNT (fremesa)
              INTO data_repe
              FROM devbanordenantes
             WHERE fremesa = fecha_rem
               AND sdevolu = vsdevolu
               AND ccobban = v_ccobban;

            IF data_repe != 0
            THEN
               v_regorden := 1;

               BEGIN
                  SELECT iordtot_t, nordtot_t, nordreg + 2
                    INTO v_iordtot, v_nordtot, v_nordreg
                    FROM devbanordenantes
                   WHERE fremesa = fecha_rem AND sdevolu = vsdevolu;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     num_error :=
                        f_proceslin
                           (psproces,
                            SUBSTR
                               (   'DUPLICADOS EN DEVBANORDENANTES F.REMESA:'
                                || fecha_rem
                                || ' S.DEVOLU.:'
                                || vsdevolu
                                || ' LINEA: '
                                || SUBSTR (lin1, 20, 35),
                                1,
                                120
                               ),
                            4,
                            nprolin
                           );
               END;
            ELSE
               num_error := 103943;
            --Error a l' inserir a la taula DEVBANORDENANTES
            END IF;

            RETURN (num_error);
      END;

      g_ccobban := v_ccobban;
      RETURN (num_error);
   EXCEPTION
      WHEN OTHERS
      THEN
         num_error :=
            f_proceslin (psproces,
                         SUBSTR (   'Error2='
                                 || SQLERRM
                                 || ' LINEA: '
                                 || SUBSTR (lin1, 20, 35),
                                 1,
                                 120
                                ),
                         4,
                         nprolin
                        );
         RETURN SQLCODE;
   END tratar_cordenante;

   ----------
   ----TRATAR_REGISTROS
   ----------
   FUNCTION tratar_registros (lin1 IN OUT VARCHAR2)
      RETURN NUMBER
   IS
      v_nrecibo        recibos.nrecibo%TYPE;
      v_ordccc         NUMBER (20);
      v_estat          NUMBER (1);
      cadena_origen    VARCHAR2 (31);
      cadena_destino   VARCHAR2 (31);
      num_error        NUMBER;
      nprolin          NUMBER                 := NULL;
      coddato          NUMBER (2);
      nif              VARCHAR2 (9);
      tsufijo          VARCHAR2 (3);
      fecha            DATE;                                -- formato ddmmaa
      nombre           VARCHAR2 (40);
      entidad          VARCHAR2 (4);
      oficina          VARCHAR2 (4);
      tentidad         VARCHAR2 (40);
      dc               VARCHAR2 (2);    -- D¿gitos de control, sino dado (**)
      ccc              VARCHAR2 (10);                            -- n¿ cuenta
      importe          VARCHAR2 (10);
      coddev           VARCHAR2 (6);                   -- c¿digo devoluciones
      codrefint        VARCHAR2 (10);            -- c¿digo referencia interna
      codref           VARCHAR2 (12);                 -- c¿digo de referencia
      concepto         VARCHAR2 (40);
      motdev           NUMBER (1);                    -- motivo de devoluci¿n
      -- 17. JGR 16/04/2012 - 0021718 / 0111176 - Inicio
      num_error2       NUMBER;
      vidioma          NUMBER               := pac_md_common.f_get_cxtempresa;
   -- 17. JGR 16/04/2012 - 0021718 / 0111176 - Fin
   BEGIN
      -- tractem la linea del fitxer
      num_error := 0;

      BEGIN
         cadena_origen :=
               CHR (128)
            || CHR (135)
            || CHR (164)
            || CHR (165)
            || CHR (166)
            || CHR (167)
            || CHR (168)
            || CHR (NULL);
         cadena_destino :=
               CHR (199)
            || CHR (231)
            || CHR (241)
            || CHR (209)
            || CHR (170)
            || CHR (186)
            || CHR (191)
            || CHR (88);
         --CAMBIO EL CARACTER NULL PER UNA X (aSCII 88)
         lin1 := TRANSLATE (lin1, cadena_origen, cadena_destino);
         codreg := SUBSTR (lin1, 1, 2);
         coddato := SUBSTR (lin1, 3, 2);
         nif := SUBSTR (lin1, 5, 9);
         tsufijo := SUBSTR (lin1, 14, 3);
         codref := SUBSTR (lin1, 17, 12);
         nombre := NVL (SUBSTR (lin1, 29, 40), '??????');
         entidad := SUBSTR (lin1, 69, 4);
         oficina := SUBSTR (lin1, 73, 4);
         dc := SUBSTR (lin1, 77, 2);
         ccc := SUBSTR (lin1, 79, 10);
         importe := SUBSTR (lin1, 89, 10);
         coddev := SUBSTR (lin1, 99, 6);
         codrefint := SUBSTR (lin1, 105, 10);

         IF SUBSTR (lin1, 108, 1) >= '0' AND SUBSTR (lin1, 108, 1) <= '9'
         THEN
            --> FORMATO LARGO (NPROCESO+RECIBO = 15 CARACTERES)
            --            DBMS_OUTPUT.put_line (   'antes de lerr linea'
            --                                || SUBSTR (lin1, 105, 9)
            --                                 );
            v_nrecibo := TO_NUMBER (SUBSTR (lin1, 105, 9));
         ELSE                                                --> FORMATO CORTO
            v_nrecibo := TO_NUMBER (SUBSTR (lin1, 99, 9));
         END IF;

         -- ESTOS ESTAN SIEMPRE EN LA MISMA POSICION
         concepto := SUBSTR (lin1, 115, 40);
         motdev := SUBSTR (lin1, 155, 1);
      EXCEPTION
         WHEN OTHERS
         THEN
            --            DBMS_OUTPUT.put_line ('when ohters tratar_registros: ' || SQLERRM);
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            5,
                            nprolin
                           );
            error := error + 1;
            num_error := 103945;
            --Error al leer una linea del fichero de devoluciones
            RETURN (num_error);
      END;

      --Si comen¿a amb un 0 li poso un 1 (Aix¿ es v¿lid per la Alian¿a)
      --IF v_nrecibo < 100000000 THEN
      --    v_nrecibo:=v_nrecibo+100000000;
      --END IF;
      IF dc <> '**'
      THEN
         v_ordccc :=
            TO_NUMBER (entidad || oficina || dc || ccc, 99999999999999999999);
      ELSE
         v_ordccc :=
            TO_NUMBER (entidad || oficina || '00' || ccc,
                       99999999999999999999
                      );
      END IF;

      IF nombre IS NULL OR nombre LIKE ' %'
      THEN
         nombre := '???????';
      END IF;

      s_total_imp_llegit := s_total_imp_llegit + NVL (importe, 0);

--------------
---Insertem a devbanrecibos
--------------
      BEGIN
         INSERT INTO devbanrecibos
                     (sdevolu, nnumnif, tsufijo, fremesa, crefere, nrecibo,
                      trecnom, nrecccc,
                      irecdev, cdevrec, crefint, cdevmot,
                      cdevsit, tprilin, ccobban
                     )
              VALUES (vsdevolu, nif, tsufijo, fecha_rem, codref, v_nrecibo,
                      nombre, TO_NUMBER (v_ordccc),
                      TO_NUMBER (importe / 100), coddev, codrefint, motdev,
                      1, concepto, g_ccobban
                     );

         bonus := bonus + 1;

         -- BUG 18825 - 19/07/2011 - JMP
         IF bonus = 1       -- 17. JGR 16/04/2012 - 0021718 / 0111176 - Inicio
         THEN
            /*
                                  AND NVL(f_parinstalacion_n('DOMDEV'), 0) = 1 THEN
            BEGIN
               INSERT INTO domici_devolu
                           (sproces, sdevolu)
                    VALUES (coddev, vsdevolu);
               UPDATE domici
                  SET cestado = 2,
                      festado = f_sysdate
                WHERE sproces = coddev;
            EXCEPTION
               WHEN OTHERS THEN
                  num_error := f_proceslin(psproces,
                                           SUBSTR('INSERT INTO DOMICI_DEVOLU (' || coddev
                                                  || ',' || vsdevolu || ') Error=' || SQLERRM
                                                  || ' LINEA: ' || SUBSTR(lin1, 20, 35),
                                                  1, 120),
                                           4, nprolin);
            END;
            */
            num_error :=
               pac_domiciliaciones.f_set_domiciliacion_cab
                                             (pac_md_common.f_get_cxtempresa,
                                              coddev,              -- sproces,
                                              g_ccobban,
                                              fecha_rem,
                                              NULL,
                                              NULL,
                                              1,                    -- Abierto
                                              NULL,
                                              vsdevolu,
                                              vidioma
                                             );

            IF num_error <> 0
            THEN
               num_error2 :=
                  f_proceslin (psproces,
                               SUBSTR (f_axis_literales (num_error, vidioma),
                                       1,
                                       120
                                      ),
                               v_nrecibo,
                               nprolin
                              );
            END IF;
         -- 17. JGR 16/04/2012 - 0021718 / 0111176 - Fin
         END IF;
      -- FIN BUG 18825 - 19/07/2011 - JMP
      EXCEPTION
         WHEN OTHERS
         THEN
            error := error + 1;
            --quan no s'ha trobat el rebut inserto a procesoscab el rebut no trobat
            num_error :=
               f_proceslin (psproces,
                            'Carrega Dev.Recibo: ' || v_nrecibo || ' '
                            || SQLERRM,
                            5,
                            nprolin
                           );
            num_error := 103944;
            --Error al insertar en la tabla DEVBANRECIBOS
            RETURN (num_error);
      END;

      RETURN (num_error);
   EXCEPTION
      WHEN OTHERS
      THEN
         num_error :=
            f_proceslin (psproces,
                         SUBSTR (   'Error='
                                 || SQLERRM
                                 || ' LINEA: '
                                 || SUBSTR (lin1, 20, 35),
                                 1,
                                 120
                                ),
                         4,
                         nprolin
                        );
         num_error := 200;
         RETURN (num_error);
   END tratar_registros;

   ----------
   ----TRATAR_TORDENANTE
   ----------
   FUNCTION tratar_tordenante (lin1 VARCHAR2)
      RETURN NUMBER
   IS
      coddato     NUMBER (2);
      nif         VARCHAR2 (9);
      suma_ord    NUMBER (12, 2);
      numdev      NUMBER (10);
      numreg      NUMBER (10);
      num_error   NUMBER;
      nprolin     NUMBER         := NULL;
   BEGIN
      --Inicialitzaci¿ de variables
      codreg := NULL;
      coddato := NULL;
      nif := NULL;
      suma_ord := NULL;
      numdev := NULL;
      numreg := NULL;
      num_error := 0;

      BEGIN
         -- tractem la linea del fitxer
         codreg := SUBSTR (lin1, 1, 2);
         coddato := SUBSTR (lin1, 3, 2);
         nif_ord2 := SUBSTR (lin1, 5, 9);
         ttsufijo_ord2 := SUBSTR (lin1, 14, 3);
         suma_ord := SUBSTR (lin1, 89, 10);
         numdev := SUBSTR (lin1, 105, 10);
         numreg := SUBSTR (lin1, 115, 10);
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            6,
                            nprolin
                           );
            RETURN (103945);
      --   Error al leer una linea del fichero de devoluciones
      END;

      ------
      --Comprobacions NIF, data i sufix
      ------
      IF nif_ord1 != nif_ord2
      THEN
         error := error + 1;
      --RETURN  102597; --El NIF del ordenante le¿do en el registro inicial no coincide con el del final.
      END IF;

      IF ttsufijo_ord1 != ttsufijo_ord2
      THEN
         error := error + 1;
      END IF;

      ------
      --Comprobem que el total sigui el que hem llegit de forma efectiva
      ------
      IF n_total_ind_ok_llegit != numdev
      THEN
         error := error + 1;
      END IF;

      IF s_total_imp_llegit != suma_ord
      THEN
         error := error + 1;
      END IF;

      ------
      -- Tractem la taula a la que afecta
      ------
      BEGIN
         UPDATE devbanordenantes
            SET iordtot_t = NVL (iordtot_t, 0) + NVL (suma_ord / 100, 0),
                nordtot_t = NVL (nordtot_t, 0) + NVL (numdev, 0),
                iordtot_r =
                         NVL (iordtot_r, 0)
                         + NVL (s_total_imp_llegit / 100, 0),
                nordtot_r = NVL (nordtot_r, 0)
                            + NVL (n_total_ind_ok_llegit, 0),
                nordreg = NVL (nordreg, 0) + numreg
          WHERE sdevolu = vsdevolu AND fremesa = fecha_rem;
      EXCEPTION
         WHEN OTHERS
         THEN
            --MESSAGE('Tratar_tordenante.Error en la Actualizaci¿n de devbanordenantes: '||sqlerrm);
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error2='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            6,
                            nprolin
                           );
            num_error := 102547;
      --Error al modificar la taula DEVBANORDENANTES;
      END;

      RETURN (num_error);
   END tratar_tordenante;

   ----------
   ----TRATAR_TGENERAL
   ----------
   FUNCTION tratar_tgeneral (lin1 VARCHAR2)
      RETURN NUMBER
   IS
      num_error     NUMBER;
      nprolin       NUMBER         := NULL;
      coddato       NUMBER (2);
      sumatotal     NUMBER (12, 2);
      numtotaldev   NUMBER (10);
      numtotreg     NUMBER (10);
   BEGIN
      num_error := 0;

      BEGIN
         -- tractem la linea del fitxer
         codreg := SUBSTR (lin1, 1, 2);
         coddato := SUBSTR (lin1, 3, 2);
         nif_pres2 := SUBSTR (lin1, 5, 9);
         ttsufijo_pres2 := SUBSTR (lin1, 14, 3);
         sumatotal := SUBSTR (lin1, 89, 10);
         numtotaldev := SUBSTR (lin1, 105, 10);
         numtotreg := SUBSTR (lin1, 115, 10);
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            7,
                            nprolin
                           );
            RETURN (103945);
      --   Error al leer una linea del fichero de devoluciones
      END;

      ------
      --Comprobacions NIF, data i sufix
      ------
      IF nif_pres1 != nif_pres2
      THEN
         error := error + 1;
      --RETURN  102602; --El NIF del presentador le¿do inicialmente no coincide con el le¿do al final.
      END IF;

      IF ttsufijo_pres1 != ttsufijo_pres2
      THEN
         error := error + 1;
      --RETURN  102603; --El sufixe del presentador llegit inicialment no coincideix amb el llegit al final.
      END IF;

      --Comprobem que el total sigui el que hem llegit de forma efectiva
      IF n_total_ind_ok_llegit != numtotaldev
      THEN
         error := error + 1;
      --RETURN 102605;--El nombre total de devolucions acumulat pel presentador no coincideix amb el llegit.
      END IF;

      IF s_total_imp_llegit != sumatotal
      THEN
         error := error + 1;
      --RETURN 102604; --El importe acumulado del presentador no coincide con el le¿do.
      END IF;

      ------
      -- Tractem la taula a la que afecta
      ------
      BEGIN
         UPDATE devbanpresentadores
            SET ipretot_t = NVL (ipretot_t, 0) + NVL (sumatotal / 100, 0),
                npretot_t = NVL (npretot_t, 0) + NVL (numtotaldev, 0),
                ipretot_r =
                         NVL (ipretot_r, 0)
                         + NVL (s_total_imp_llegit / 100, 0),
                npretot_r = NVL (npretot_r, 0) + NVL (n_total_presentador, 0),
                nprereg = NVL (nprereg, 0) + NVL (numtotreg, 0),
                sproces = psproces
          WHERE sdevolu = vsdevolu;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_error :=
               f_proceslin (psproces,
                            SUBSTR (   'Error2='
                                    || SQLERRM
                                    || ' LINEA: '
                                    || SUBSTR (lin1, 20, 35),
                                    1,
                                    120
                                   ),
                            7,
                            nprolin
                           );
            num_error := 102546;
            --Error al modificar la taula DEVBANPRESENTADORES
            RETURN (num_error);
      END;

      RETURN (num_error);
   END tratar_tgeneral;

   FUNCTION f_ndev (pnrecibo IN NUMBER, pfecha IN DATE, pctipoimp IN NUMBER)
      RETURN NUMBER
   IS
      v_ndev       NUMBER := 0;
      v_ctipnimp   NUMBER;
      v_sseguro    NUMBER;
   BEGIN
      -- BUSCAMOS EL N¿MERO DE IMPAGADOS
      BEGIN
         -- Bug 22342 - APD - 12/06/2012 - se a¿ade la condicion OR p.cagente = r.cagente
         SELECT DISTINCT ctipnimp, r.sseguro
                    INTO v_ctipnimp, v_sseguro
                    FROM prodreprec p, recibos r, seguros s
                   WHERE s.sseguro = r.sseguro
                     AND r.nrecibo = pnrecibo
                     AND (   p.sproduc = s.sproduc
                          OR p.cagente = r.cagente
                          OR p.ccobban = r.ccobban
                         )
                     AND p.ffinefe IS NULL
                     AND p.ctipoimp =
                            (SELECT MAX (pp.ctipoimp)
                               FROM prodreprec pp
                              WHERE (   pp.sproduc = p.sproduc
                                     OR pp.cagente = p.cagente
                                    )                -- Bug 32673 MMS 20141001
                                AND pp.ffinefe IS NULL
                                AND pp.ctipoimp <= pctipoimp);
      -- fin Bug 22342 - APD - 12/06/2012
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_ctipnimp := 0;            -- n¿mero de impagod del mismo recibo
         WHEN OTHERS
         THEN
            RETURN 999999;
      END;

      IF v_ctipnimp = 0
      THEN                             -- n¿mero de impagados del mismo recibo
         SELECT   COUNT (*)
             INTO v_ndev
             FROM movrecibo
            WHERE (cestrec = 0
                              -- AND cestant = 1) -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones
                   AND cestant IN (1, 3))
                                         -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones
                  AND nrecibo = pnrecibo
         ORDER BY nrecibo, cestrec, cestant;
      ELSIF v_ctipnimp = 1
      THEN                                           -- Impagados consecutivos
         --Contem el n¿mero de rebuts anulats consecutius
         SELECT COUNT (DISTINCT m.nrecibo)
           INTO v_ndev
           FROM movrecibo m, tmp_impagados t
          WHERE fmovfin IS NULL
            AND cestrec = 2
            AND fmovini >=               -- Mirem si existeix algun intercalat
                   (SELECT NVL (MAX (fmovini),
                                TO_DATE ('01/01/1900', 'dd/mm/yyyy')
                               )
                      FROM movrecibo m2
                     WHERE m2.nrecibo IN (SELECT nrecibo
                                            FROM recibos
                                           WHERE sseguro = v_sseguro)
                       AND m2.fmovfin IS NULL
                       AND m2.cestrec <> 2
                       AND m2.fmovini < pfecha)
            AND m.nrecibo = t.nrecibo
            AND t.ctractat = 2
            AND t.cactimp IN (1, 3)
            AND t.sseguro = v_sseguro;                        -- anular recibo
      ELSIF v_ctipnimp = 2
      THEN                                     -- Impagados en la misma p¿liza
         --Contem el n¿mero de rebuts pendientes
         SELECT COUNT (DISTINCT nrecibo)
           INTO v_ndev
           FROM movrecibo
          WHERE nrecibo IN (SELECT nrecibo
                              FROM recibos
                             WHERE sseguro = v_sseguro)
            AND fmovfin IS NULL
            AND cestrec = 0
            -- AND cestant = 1; -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones
            AND cestant IN (1, 3);
      -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones
      END IF;

      RETURN v_ndev;
   END f_ndev;

   ----------
   ----   TRATAR_DEVOLUCIONES
   ----------
   -- Bug 0020038 - 09/11/2011 - JMF
   FUNCTION tratar_devoluciones (
      pidioma            VARCHAR2,
      par_sdevolu   IN   NUMBER DEFAULT NULL,
      par_sproces   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      -- Bug 0020038 - 09/11/2011 - JMF
      v_loc_sdevolu    devbanrecibos.sdevolu%TYPE;
      -- devoluci¿n para esta funcion local.
      v_loc_sproces    procesoscab.sproces%TYPE;

      -- proceso para esta funcion local.

      -----
      ---
      -----
      CURSOR dev
      IS
         SELECT   *
             FROM devbanrecibos
            WHERE sdevolu = v_loc_sdevolu
         ORDER BY nrecibo;

      -----
      ---
      -----
      pscaragr         NUMBER;
      v_sseguro        NUMBER;
      v_fefecto        DATE;
      v_fanulac_seg    DATE;
      v_nriesgo        NUMBER;
      --   v_fanulac_rie    DATE;
      v_ndev           NUMBER                              := 0;
      --  v_sagenda        NUMBER;
      --v_tatribu        VARCHAR2 (30);
      v_sproduc        NUMBER;
      -- Taula DETPRODREPREC
      pndiaavis        NUMBER;
      pcmodelo         NUMBER;
      pcactimp         NUMBER;
      pcmodimm         NUMBER;
      --  pctipoextra      detprodreprec.ctipoextra%TYPE;
      num_error        NUMBER;
      nprolin          NUMBER                              := NULL;
      v_ccobban        NUMBER;
      secuencia        NUMBER;
      pctipnimp        NUMBER;
      pcactimm         NUMBER;
      v_fefepol        DATE;
      v_ctipoimp       NUMBER;
      anys             NUMBER;
      error            NUMBER;
      pcdiaavis        NUMBER;
      v_fejecuta       DATE;
      v_smovrec        movrecibo.smovrec%TYPE;
      v_ultmovrec      movrecibo.smovrec%TYPE;
      num_err_proces   NUMBER (15);
      num_err          NUMBER (15);
      ntraza           NUMBER                              := 0;
      v_cagente        recibos.cagente%TYPE;  -- Bug 22342 - APD - 12/06/2012
      pcaccpre         recibos_comp.caccpre%TYPE;
      -- Bug 22342 - APD - 12/06/2012
      pcaccret         recibos_comp.caccret%TYPE;
      -- Bug 22342 - APD - 12/06/2012
      -- 33.  0025151: LCOL999-Redefinir el circuito de prenotificaciones - Inicio
      vtextobs         axis_literales.tlitera%TYPE;
      vcestimp         recibos.cestimp%TYPE;
      vtrechazo        detrechazo_banco.trechazo%TYPE;
      vtiprechazo      detvalores.tatribu%TYPE;
      vctiprechazo     codrechazo_banco.ctiprechazo%TYPE;
      vcempres         empresas.cempres%TYPE
                                            := pac_md_common.f_get_cxtempresa;
      salir            EXCEPTION;
      -- 35.  MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Inicio
      v_cbancar        recibos.cbancar%TYPE;
      v_cbancar_aux    VARCHAR2 (100);
      v_ctipban        recibos.ctipban%TYPE;
      -- 35.  MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Fin
      -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Inicio
      vtextobs2        VARCHAR2 (10000);
      v_ndev_agrup     NUMBER                              := 0;

      -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Fin

      /*******************************************************************************
       FUNCION f_agd_observaciones
       Graba apuntes en la agenda del recibo, para los movimiento de domiciliaciones.
       Par¿metros:
        Entrada :
           pcempres IN NUMBER
           pnrecibo IN NUMBER
           ptextobs IN VARCHAR2

        Retorna: un NUMBER con el id del error.
       ********************************************************************************/
      FUNCTION f_agd_observaciones (
         pcempres   IN   NUMBER,
         pnrecibo   IN   NUMBER,
         ptextobs   IN   VARCHAR2
      )
         RETURN NUMBER
      IS
         vidobs        agd_observaciones.idobs%TYPE;
         num_err       NUMBER;
         vpasexec      NUMBER;
         vobjectname   VARCHAR2 (500)     := 'PAC_DEVOLU.f_agd_observaciones';
         vparam        VARCHAR2 (1000)
            :=    'par¿metros - pcempres: '
               || pcempres
               || ' pnrecibo:'
               || pnrecibo
               || ' ptextobs:'
               || ptextobs;
      BEGIN
         vpasexec := 10;

         BEGIN
            SELECT NVL (MAX (idobs), 0) + 1
              INTO vidobs
              FROM agd_observaciones
             WHERE cempres = pcempres;
         EXCEPTION
            WHEN OTHERS
            THEN
               vidobs := 1;
         END;

         vpasexec := 20;
         num_err :=
            pac_agenda.f_set_obs
                             (pcempres,
                              vidobs,
                              5,
                              0,
                              f_axis_literales (9903799,
                                                pac_md_common.f_get_cxtidioma
                                               ),
                              ptextobs,
                              f_sysdate,
                              NULL,
                              2,
                              NULL,
                              NULL,
                              NULL,
                              1,
                              1,
                              f_sysdate,
                              vidobs
                             );

         IF num_err <> 0
         THEN
            RETURN num_err;
         END IF;

         vpasexec := 30;

         UPDATE agd_observaciones
            SET nrecibo = pnrecibo
          WHERE cempres = pcempres AND idobs = vidobs;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         vpasexec,
                         vparam,
                         'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                        );
            RETURN 806310;
      END f_agd_observaciones;
   -- 33.  0025151: LCOL999-Redefinir el circuito de prenotificaciones - Final
   BEGIN
      --      --dbms_output.put_line ('entramos a tratar devoluciones ');
      num_error := 0;
      ntraza := 100;

      -- ini Bug 0020038 - 09/11/2011 - JMF
      IF par_sdevolu IS NOT NULL
      THEN
         -- Trabajar con variable del parametro.
         v_loc_sdevolu := par_sdevolu;
      ELSE
         -- Trabajar con variable generica de la package
         v_loc_sdevolu := vsdevolu;
      END IF;

      IF par_sproces IS NOT NULL
      THEN
         -- Trabajar con variable del parametro.
         v_loc_sproces := par_sproces;
      ELSE
         -- Trabajar con variable generica de la package
         v_loc_sproces := psproces;
      END IF;

      -- fin Bug 0020038 - 09/11/2011 - JMF
      ntraza := 105;

      -- Seq¿¿ncia per agrupar totes les cartes
      SELECT scaragr.NEXTVAL
        INTO pscaragr
        FROM DUAL;

      ntraza := 110;

      FOR reg IN dev
      LOOP
         BEGIN
            ntraza := 115;

            -- Bug 22342 - APD - 12/06/2012 - se recupera el cagente
            -- Bug 32673 MMS 20141001 agregamos ccobban
            SELECT fefecto, sseguro, nriesgo, cagente,
                   ccobban                                          --CTIPREC,
              INTO v_fefecto, v_sseguro, v_nriesgo, v_cagente,
                   v_ccobban                                      --v_ctiprec,
              FROM recibos
             WHERE nrecibo = reg.nrecibo;

            -- fin Bug 22342 - APD - 12/06/2012
            num_err := 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               num_error :=
                  f_proceslin (v_loc_sproces,
                                  reg.nrecibo
                               || ': t='
                               || ntraza
                               || ': '
                               || f_axis_literales (101731, pidioma),
                               v_sseguro,
                               nprolin
                              );
               num_err := 101731;
         END;

         IF num_err = 0
         THEN
            --         --dbms_output.put_line ('From RECIBOS');
            ntraza := 120;

            SELECT fanulac, sproduc, fefecto                        --NCERTIF,
              INTO v_fanulac_seg, v_sproduc, v_fefepol             --v_certif,
              FROM seguros
             WHERE sseguro = v_sseguro;

            --         --dbms_output.put_line ('From SEGUROS');
            --         --dbms_output.put_line ('v_fefepol =' || v_fefepol);
            --         --dbms_output.put_line ('v_fefecto =' || v_fefecto);
            -- Buscamos el tipo de impagado (anualidad)
            ntraza := 125;
            error := f_difdata (v_fefepol, v_fefecto, 1, 1, anys);
            --         --dbms_output.put_line ('error =' || error);
            v_ctipoimp := anys + 1;
            --         --dbms_output.put_line ('c_ctipoimp =' || v_ctipoimp);
            -- Buscamos el n¿mero de impagados
            ntraza := 130;
            v_ndev := f_ndev (reg.nrecibo, reg.fremesa, v_ctipoimp);

            --         --dbms_output.put_line ('v_ndev =' || v_ndev);

            --Bug 9204-MCC-03/03/2009- Gesti¿n impagados
            BEGIN
               ntraza := 135;

               SELECT smovrec
                 INTO v_smovrec
                 FROM movrecibo
                WHERE fmovfin IS NULL AND nrecibo = reg.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_err_proces :=
                     f_proceslin (v_loc_sproces,
                                     reg.nrecibo
                                  || ': t='
                                  || ntraza
                                  || ': '
                                  || SQLERRM,
                                  1,
                                  nprolin
                                 );
                  num_err := 102903;              -- No s'han trobat registres
            END;

--FIN Bug 9204-MCC-03/03/2009- Gesti¿n impagados
--------------------------------
-- Busquem la parametritzaci¿
            pcmodelo := NULL;
            pndiaavis := NULL;
            pcactimp := NULL;
            pcmodimm := NULL;
            pcactimm := NULL;
            pcdiaavis := NULL;
            ntraza := 3;

            BEGIN
               ntraza := 140;

               -- Busco el model de carta que li toca segons la parametritzaci¿
               -- Bug 22342 - APD - 12/06/2012 - se a¿ade la condicion OR p.cagente = v_cagente
               SELECT d.cmodelo, d.cdiaavis, d.ndiaavis, d.cactimp,
                      d.cmodimm, d.cactimm
                 INTO pcmodelo, pcdiaavis, pndiaavis, pcactimp,
                      pcmodimm, pcactimm
                 FROM detprodreprec d, prodreprec p
                WHERE (   p.sproduc = v_sproduc
                       OR p.cagente = v_cagente
                       OR p.ccobban = v_ccobban
                      )                              -- Bug 32673 MMS 20141001
                  AND d.sidprodp = p.sidprodp
                  AND d.nimpagad =
                         (SELECT MAX (d.nimpagad)
                            FROM detprodreprec d, prodreprec p
                           WHERE (   p.sproduc = v_sproduc
                                  OR p.cagente = v_cagente
                                  OR p.ccobban = v_ccobban
                                 )                   -- Bug 32673 MMS 20141001
                             AND d.sidprodp = p.sidprodp
                             AND d.cmotivo = reg.cdevmot
                             AND p.ffinefe IS NULL
                             AND p.ctipoimp =
                                    (SELECT MAX (pp.ctipoimp)
                                       FROM prodreprec pp
                                      WHERE (   pp.sproduc = v_sproduc
                                             OR pp.cagente = v_cagente
                                             OR p.ccobban = v_ccobban
                                            )        -- Bug 32673 MMS 20141001
                                        AND pp.ffinefe IS NULL
                                        AND pp.ctipoimp <= v_ctipoimp)
                             AND d.nimpagad <= v_ndev + 1)
                  -- porque as¿ contamos con el impago del recibo que vamos a tratar
                  AND d.cmotivo = reg.cdevmot
                  AND p.ffinefe IS NULL
                  AND p.ctipoimp =
                         (SELECT MAX (pp.ctipoimp)
                            FROM prodreprec pp
                           WHERE (   pp.sproduc = v_sproduc
                                  OR pp.cagente = v_cagente
                                  OR p.ccobban = v_ccobban
                                 )                   -- Bug 32673 MMS 20141001
                             AND pp.ffinefe IS NULL
                             AND pp.ctipoimp <= v_ctipoimp);
            -- fin Bug 22342 - APD - 12/06/2012
            -- 1 = Cartera; de moment ¿s l'¿nic que es fa servir;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  --               DBMS_OUTPUT.put_line ('when no_data_found');
                  pcmodelo := 0;
                  pndiaavis := 0;
                  pcactimp := 4;                                -- Sin acci¿n
                  pcmodimm := NULL;
                  pcdiaavis := 1;
               WHEN OTHERS
               THEN
                  num_error := 110448;
                  RETURN num_error;
            END;

            -- Bug 22342 - APD - 12/06/2012 - tener en cuenta si el recibo tiene una
            -- acci¿n preconocida o retenida que manda por encima de las acciones
            -- predeterminadas del agente o del producto
            BEGIN
               ntraza := 145;

               SELECT caccpre, caccret
                 INTO pcaccpre, pcaccret
                 FROM recibos_comp r
                WHERE r.nrecibo = reg.nrecibo;

               -- Si el recibo tiene una acci¿n PRECONOCIDA
               IF pcaccpre IS NOT NULL
               THEN
                  IF pcaccpre IN (1, 5, 7)
                  THEN                             -- anular, Cobrar, reenvio
                     -- se ha de cambiar la variable PCACTIMP ya que la acci¿n autom¿tica
                     -- que ha de realizar es Sin acci¿n.
                     pcactimp := 4;                             -- Sin acci¿n
                  END IF;
               END IF;

               IF pcaccret IS NOT NULL
               THEN
                  IF pcaccret = 4
                  THEN                                             -- Remesar
                     pcactimp := 4;                             -- Sin acci¿n
                  END IF;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  num_error := 110448;
                  RETURN num_error;
            END;

            -- fin Bug 22342 - APD - 12/06/2012

            -------------------------------------
--         DBMS_OUTPUT.put_line (   reg.sdevolu
--                               || 'aNTES DE devbanordenantes nnumnif:'
--                               || reg.nnumnif
--                               || ' SUFIJO  '
--                               || reg.tsufijo
--                               || ' REG.FREMESA '
--                               || reg.fremesa
--                              );

            /*   SELECT ccobban
                                               INTO v_ccobban
                       FROM devbanordenantes
                      WHERE sdevolu = reg.sdevolu
                        AND nnumnif = reg.nnumnif
                        AND tsufijo = reg.tsufijo
                        AND TO_CHAR (fremesa, 'DDMMYYYY') =
                                                         TO_CHAR (reg.fremesa, 'DDMMYYYY');
            */
                        --         DBMS_OUTPUT.put_line (   'despues devban. vamos a impagar recibo  '
                        --                               || reg.nrecibo
                        --                              );
                        -- Marquem els rebuts com IMPAGATS
                        /*        num_error :=
                                                            f_impaga_rebut (reg.nrecibo, reg.fremesa, v_ccobban, reg.cdevmot);*/

            -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones - Inicio
            -- No se deber¿ ejecutar el impago de recibos para los convenios
            -- por fechas porque los recibos no est¿n remesados, ni pagados.
            -- num_error := f_impaga_rebut(reg.nrecibo, reg.fremesa, reg.ccobban, reg.cdevmot);
            IF reg.cdevmot <> 9
            THEN
               ntraza := 150;
               num_error :=
                  f_impaga_rebut (reg.nrecibo,
                                  reg.fremesa,
                                  reg.ccobban,
                                  reg.cdevmot,
                                  NULL,
                                  v_loc_sproces
                                 );
               --BUG 36911-209890 10/07/2015 KJSC Nuevo parametro de psproces)
            END IF;

            -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones - Fin

            --         DBMS_OUTPUT.put_line (   'despues de f_impaga_rebut  con num_error '
            --                               || num_error
            --                              );
            ntraza := 155;

            IF pcdiaavis = 2
            THEN
               -- v_fejecuta := LAST_DAY (reg.fremesa)+ 1;  -- SE LE SUMA 1 PARA QUE SEA AL FINAL DEL D¿A DEL ¿LTIMO MES
               v_fejecuta := LAST_DAY (reg.fremesa);
            ELSE
               v_fejecuta := reg.fremesa + NVL (pndiaavis, 0);
            END IF;

            IF num_error <> 0
            THEN
               -----
               -- Insertem a TMP_IMPAGADOS
               -----
               BEGIN
                  ntraza := 160;

                  INSERT INTO tmp_impagados
                              (sseguro, nrecibo, ffejecu,
                               ffecalt, cactimp, ctractat,
                               cmotivo,
                               terror,
                               ccarta,
                               nimpagad,
                               sdevolu, smovrec
                              )
                       --Bug 9204-MCC-03/03/2009-Nueva columna smovrec
                  VALUES      (v_sseguro, reg.nrecibo, v_fejecuta,
                               reg.fremesa, NVL (pcactimp, 4), 0,
                               reg.cdevmot,
                                  'No s''ha pogut descobrar: '
                               || f_axis_literales (num_error, pidioma),
                               pcmodelo,
                               -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones - Inicio
                               -- v_ndev + 1,
                               DECODE (reg.cdevmot, 9, 0, v_ndev + 1),
                               -- 6.0 25/11/2011 JGR 20037: Parametrizaci¿n de Devoluciones - Fin
                               reg.sdevolu, v_smovrec
                              );

                  --Bug 9204-MCC-03/03/2009-Nueva columna smovrec
                  num_error := 0;                         --Per a que segueixi
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     num_error :=
                        f_proceslin (v_loc_sproces,
                                        reg.nrecibo
                                     || ': t='
                                     || ntraza
                                     || ': '
                                     || SQLERRM,
                                     v_sseguro,
                                     nprolin
                                    );
                     num_error := 110068;
                  WHEN OTHERS
                  THEN
                     num_error :=
                        f_proceslin (v_loc_sproces,
                                        reg.nrecibo
                                     || ': t='
                                     || ntraza
                                     || ': '
                                     || SQLERRM,
                                     v_sseguro,
                                     nprolin
                                    );
                     num_error := 110069;
               END;
            ELSE
               -----
               -- Insertem a TMP_IMPAGADOS
               -----
               BEGIN
                  ntraza := 165;

                                    -- 22. 0022686 / 0117742 - Inicio
                                    /*
                                                                        IF NOT(NVL(pcactimp, 4) = 4
                                           AND(NVL(pcactimm, 4) <> 4
                                               OR pcmodimm IS NOT NULL)) THEN
                                       INSERT INTO tmp_impagados
                                                   (sseguro, nrecibo, ffejecu, ffecalt,
                                                    cactimp, ctractat,
                                                    cmotivo, ttexto, ccarta,
                                                    nimpagad, sdevolu)
                                            VALUES (v_sseguro, reg.nrecibo, v_fejecuta, reg.fremesa,
                                                    NVL(pcactimp, 4), DECODE(NVL(pcactimp, 4), 4, 0, 1),
                                                    reg.cdevmot, 'N¿ Devol: ' || TO_CHAR(v_ndev + 1), pcmodelo,
                                                    -- v_ndev + 1                     --(-JGR)
                                                    DECODE(reg.cdevmot, 9, 0, v_ndev + 1)   --(+JGR)
                                                                                         , reg.sdevolu);
                  --               DBMS_OUTPUT.put_line ('hemos hecho el primer insert');
                                    ELSIF NVL(pcactimm, 4) <> 4
                                          OR pcmodimm IS NOT NULL THEN   -- si hay accion immediata
                  --                  DBMS_OUTPUT.put_line ('hemos hecho el segundo insert');
                                       INSERT INTO tmp_impagados
                                                   (sseguro, nrecibo, ffejecu, ffecalt, cactimp,
                                                    ctractat, cmotivo, ttexto,
                                                    ccarta, nimpagad,
                                                    sdevolu)
                                            VALUES (v_sseguro, reg.nrecibo, reg.fremesa, reg.fremesa, pcactimm,
                                                    1, reg.cdevmot, 'N¿ Devol: ' || TO_CHAR(v_ndev + 1),
                                                    pcmodimm,
                                                             -- v_ndev + 1                     --(-JGR)
                                                             DECODE(reg.cdevmot, 9, 0, v_ndev + 1)   --(+JGR)
                                                                                                  ,
                                                    reg.sdevolu);
                                    END IF;
                                    */
                  BEGIN
                     SELECT MAX (smovrec)
                       INTO v_ultmovrec
                       FROM movrecibo
                      WHERE nrecibo = reg.nrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        v_ultmovrec := NULL;
                  END;

                  IF NOT (    NVL (pcactimp, 4) = 4
                          AND (NVL (pcactimm, 4) <> 4 OR pcmodimm IS NOT NULL
                              )
                         )
                  THEN
                     BEGIN
                        ntraza := 170;

                        INSERT INTO tmp_impagados
                                    (sseguro, nrecibo, ffejecu,
                                     ffecalt, cactimp,
                                     ctractat,
                                     cmotivo,
                                     ttexto,
                                     ccarta,
                                     nimpagad,
                                     sdevolu, smovrec
                                    )
                             VALUES (v_sseguro, reg.nrecibo, v_fejecuta,
                                     reg.fremesa, NVL (pcactimp, 4),
                                     DECODE (NVL (pcactimp, 4), 4, 0, 1),
                                     reg.cdevmot,
                                     'N¿ Devol: ' || TO_CHAR (v_ndev + 1),
                                     pcmodelo,
                                     DECODE (reg.cdevmot, 9, 0, v_ndev + 1),
                                     reg.sdevolu, v_ultmovrec
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           ntraza := 175;

                           UPDATE tmp_impagados
                              SET smovrec = v_ultmovrec
                            WHERE sseguro = v_sseguro
                              AND nrecibo = reg.nrecibo
                              AND ffejecu = reg.fremesa
                              AND cactimp = NVL (pcactimp, 4);
                     END;
                  END IF;

                  IF    NVL (pcactimm, 4) <> NVL (pcactimp, 4)
                     OR reg.fremesa <> v_fejecuta
                  THEN
                     IF NVL (pcactimm, 4) <> 4 OR pcmodimm IS NOT NULL
                     THEN                          -- si hay accion immediata
                        BEGIN
                           ntraza := 180;

                           INSERT INTO tmp_impagados
                                       (sseguro, nrecibo, ffejecu,
                                        ffecalt, cactimp, ctractat,
                                        cmotivo,
                                        ttexto,
                                        ccarta,
                                        nimpagad,
                                        sdevolu, smovrec
                                       )
                                VALUES (v_sseguro, reg.nrecibo, reg.fremesa,
                                        reg.fremesa, pcactimm, 1,
                                        reg.cdevmot,
                                        'N¿ Devol: ' || TO_CHAR (v_ndev + 1),
                                        pcmodimm,
                                        DECODE (reg.cdevmot,
                                                9, 0,
                                                v_ndev + 1
                                               ),
                                        reg.sdevolu, v_ultmovrec
                                       );
                        EXCEPTION
                           WHEN DUP_VAL_ON_INDEX
                           THEN
                              ntraza := 185;

                              UPDATE tmp_impagados
                                 SET smovrec = v_ultmovrec
                               WHERE sseguro = v_sseguro
                                 AND nrecibo = reg.nrecibo
                                 AND ffejecu = reg.fremesa
                                 AND cactimp = NVL (pcactimp, 4);
                        END;
                     END IF;
                  END IF;

                  -- 22. 0022686 / 0117742 - Fin

                  -- Si no tenim que realitzar cap acci¿, actualitzem la taula DEVRECIBOS
                  IF     NVL (pcactimp, 4) = 4
                     AND NVL (pcactimm, 4) = 4
                     AND pcmodimm IS NULL
                  THEN
                     --                  DBMS_OUTPUT.put_line ('entramos en el if');

                     -- Actualitzem els rebuts a la taula de DEVRECIBOS
                     ntraza := 190;

                     UPDATE devbanrecibos
                        SET cdevsit = 3              -- Revisat automaticament
                      WHERE nrecibo = reg.nrecibo AND fremesa = reg.fremesa;
                  END IF;
               EXCEPTION
                  /*WHEN DUP_VAL_ON_INDEX THEN
                     num_error := f_proceslin(v_loc_sproces, reg.nrecibo || ': ' || SQLERRM,
                                              v_sseguro, nprolin);
                     num_error := 110068;*/
                  WHEN OTHERS
                  THEN
                     --                  DBMS_OUTPUT.put_line ('error sqlerrm =' || SQLERRM);
                     num_error :=
                        f_proceslin (v_loc_sproces,
                                        reg.nrecibo
                                     || ': t='
                                     || ntraza
                                     || ': '
                                     || SQLERRM,
                                     v_sseguro,
                                     nprolin
                                    );
                     num_error := 110069;
               END;
            -- Las cartas se insertar¿n siempre en f_devol_automatico
            END IF;

            ntraza := 200;

            -- Inicio Bug 36545 MMS 20150422
            /* insertamaos los recibos agrupados tambi¿n para que haga las acciones de la devoluci¿n autom¿tica tambi¿n a estos
                 Se debe mantener el numero de impago propio del recibo y no el del recibo agrupador */
            FOR reg2 IN (SELECT nrecibo
                           FROM adm_recunif_his a
                          WHERE a.nrecunif = reg.nrecibo
                            AND nrecibo <> reg.nrecibo
                            AND a.sdomunif =
                                   (SELECT MAX (sdomunif)
                                      FROM adm_recunif_his b
                                     WHERE b.nrecunif = a.nrecunif
                                       AND b.nrecibo <> reg.nrecibo))
            LOOP
               BEGIN
                  ntraza := 210;

                  FOR reg3 IN (SELECT sseguro, nrecibo, ffejecu, ffecalt,
                                      cactimp, ctractat, ttexto, cmotivo,
                                      terror, ccarta, nimpagad, sdevolu,
                                      smovrec
                                 FROM tmp_impagados
                                WHERE sseguro = v_sseguro
                                  AND nrecibo = reg.nrecibo
                                  AND sdevolu = reg.sdevolu)
                  LOOP
                     v_ndev_agrup :=
                               f_ndev (reg2.nrecibo, reg.fremesa, v_ctipoimp);

                     BEGIN
                        INSERT INTO tmp_impagados
                                    (sseguro, nrecibo,
                                     ffejecu, ffecalt,
                                     cactimp, ctractat,
                                     cmotivo,
                                     ttexto,
                                     ccarta,
                                     nimpagad,
                                     sdevolu, smovrec
                                    )
                             VALUES (reg3.sseguro, reg2.nrecibo,
                                     reg3.ffejecu, reg3.ffecalt,
                                     reg3.cactimp, reg3.ctractat,
                                     reg3.cmotivo,
                                     'N¿ Devol: '
                                     || TO_CHAR (v_ndev_agrup + 1),
                                     reg3.ccarta,
                                     DECODE (reg.cdevmot,
                                             9, 0,
                                             v_ndev_agrup + 1
                                            ),
                                     reg3.sdevolu, reg3.smovrec
                                    );
                     EXCEPTION
                        WHEN DUP_VAL_ON_INDEX
                        THEN
                           UPDATE tmp_impagados
                              SET smovrec = reg3.smovrec
                            WHERE sseguro = reg3.sseguro
                              AND nrecibo = reg2.nrecibo
                              AND ffejecu = reg3.ffejecu
                              AND cactimp = reg3.cactimp;
                     END;
                  END LOOP;

                  num_error := 0;
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     num_error :=
                        f_proceslin (v_loc_sproces,
                                        reg.nrecibo
                                     || ': t='
                                     || ntraza
                                     || ': '
                                     || SQLERRM,
                                     v_sseguro,
                                     nprolin
                                    );
                     num_error := 110068;
                  WHEN OTHERS
                  THEN
                     num_error :=
                        f_proceslin (v_loc_sproces,
                                        reg.nrecibo
                                     || ': t='
                                     || ntraza
                                     || ': '
                                     || SQLERRM,
                                     v_sseguro,
                                     nprolin
                                    );
                     num_error := 110069;
               END;
            END LOOP;

            -- Fin Bug 36545 MMS 20150422
            ntraza := 220;

            -- 33.  0025151: LCOL999-Redefinir el circuito de prenotificaciones -- Inicio
            -- Apunte en la agenda para las devoluciones (no convenios de proceso nocturno)
            IF     NVL
                      (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'AGENDA_DEVOLU'
                                              ),
                       0
                      ) = 1
               -- 37.  0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Inicio
               AND reg.cdevmot <> 9
                                   -- No se deber¿ ejecutar para los convenios
            -- 37.  0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Final
            THEN
               -- Domiciliacaci¿n respuesta #1# de recibo #2# para cuenta o tarjeta #3# - #4#. #5# (#6#).
               BEGIN
                  ntraza := 230;

                  SELECT cestimp
                    INTO vcestimp
                    FROM recibos
                   WHERE nrecibo = reg.nrecibo;

                  ntraza := 240;
                  vtextobs :=
                     f_axis_literales (9905086, pac_md_common.f_get_cxtidioma);
                  vtextobs := REPLACE (vtextobs, '#1#', v_loc_sproces);
                  vtextobs := REPLACE (vtextobs, '#2#', reg.nrecibo);

                  -- 35.  MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 Inicio
                  BEGIN
                     ntraza := 250;

                     SELECT ctipban, cbancar
                       INTO v_ctipban, v_cbancar
                       FROM recibos
                      WHERE nrecibo = reg.nrecibo;

                     -- 38. - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
                     IF v_ctipban IS NOT NULL AND v_cbancar IS NOT NULL
                     THEN
                        ntraza := 260;
                        num_err :=
                           f_formatoccc (v_cbancar, v_cbancar_aux, v_ctipban);
                     ELSE
                        v_cbancar_aux := NULL;
                     END IF;
                  -- 38. - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_cbancar_aux := NULL;
                  END;

                  -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
                  -- Se modifica para que solo informe la parte de la CCC si existe la info en v_cbancar_aux
                  --vtextobs := REPLACE(vtextobs, '#3#', '***' || SUBSTR(reg.nrecccc, -4));
                  --vtextobs := REPLACE(vtextobs, '#3#', '***' || SUBSTR(v_cbancar_aux, -4));
                  ntraza := 270;

                  IF v_cbancar_aux IS NULL
                  THEN
                     vtextobs := REPLACE (vtextobs, '#3#', '');
                  ELSE
                     vtextobs :=
                        REPLACE (vtextobs,
                                 '#3#',
                                    f_axis_literales (100965, 8)
                                 || ' o '
                                 || f_axis_literales (104207, 8)
                                 || ' ***'
                                 || SUBSTR (v_cbancar_aux, -4)
                                );
                  END IF;

                  -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin

                  -- 35.  MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 Fin
                  ntraza := 280;
                  vtextobs :=
                     REPLACE (vtextobs,
                              '#4#',
                                 -- 17. 0025151 - Inicio
                                 -- f1.cestimp || ' '
                                 vcestimp
                              || ' '
                              -- 17. 0025151 - Fin
                              || ff_desvalorfijo
                                               (75,
                                                pac_md_common.f_get_cxtidioma,
                                                -- 17. 0025151 - Inicio
                                                                   -- f1.cestimp
                                                vcestimp
                                               -- 17. 0025151 - Fin
                                               )
                             );
                  -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Inicio
                  ntraza := 290;

                  -- Descripci¿n de los motivos de rechazos bancarios y tipos de rechazo
                  BEGIN
                     SELECT DISTINCT d.trechazo, c.ctiprechazo
                                INTO vtrechazo, vctiprechazo
                                FROM codrechazo_banco c,
                                     detrechazo_banco d,
                                     domiciliaciones a,
                                     domiciliaciones_cab b
                               WHERE d.cempres = c.cempres
                                 AND d.ccobban = c.ccobban
                                 AND d.crechazo = c.crechazo
                                 AND d.cidioma = pac_md_common.f_get_cxtidioma
                                 AND c.cempres = vcempres
                                 AND c.ccobban = reg.ccobban
                                 AND c.crechazo =
                                                 LTRIM (TRIM (a.cdomerr), '0')
                                 AND a.sproces = b.sproces
                                 AND a.nrecibo = reg.nrecibo
                                 -- 37.  0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Inicial
                                 AND b.sdevolu = v_loc_sdevolu;
                  -- AND b.sdevolu = par_sdevolu;
                  -- 37.  0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Final
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        -- 35. MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Inicio
                        BEGIN
                           ntraza := 300;

                           SELECT trechazo, ctiprechazo
                             INTO vtrechazo, vctiprechazo
                             FROM codrechazo_banco a, detrechazo_banco b
                            WHERE a.cempres = vcempres
                              AND a.ccobban = reg.ccobban
                              AND a.crechazo = LTRIM (TRIM (reg.cdevrec), '0')
                              AND a.cempres = b.cempres
                              AND a.ccobban = b.ccobban
                              AND a.crechazo = b.crechazo
                              AND b.cidioma = pac_md_common.f_get_cxtidioma;
                        EXCEPTION
                           WHEN OTHERS
                           THEN
                              vtrechazo := NULL;
                              vctiprechazo := NULL;
                        END;
                  -- 35. MMM - 0027750 LCOL_A003-Error en cargue de archivo de respuesta debito automatico (VISA) - QT-6189 - Fin
                  END;

                  ntraza := 310;
                  vtiprechazo :=
                     ff_desvalorfijo (1122,
                                      pac_md_common.f_get_cxtidioma,
                                      NVL (vctiprechazo, reg.cdevmot)
                                     );
                  ntraza := 320;
                  vtextobs := REPLACE (vtextobs, '#5#', vtrechazo);
                  ntraza := 330;
                  vtextobs := REPLACE (vtextobs, '#6#', vtiprechazo);
                  ntraza := 340;
                  -- 17. 0025151: LCOL999-Redefinir el circuito de prenotificaciones - Final
                  num_error :=
                         f_agd_observaciones (vcempres, reg.nrecibo, vtextobs);

                  IF num_error <> 0
                  THEN
                     RAISE salir;
                  END IF;

                  ntraza := 350;

                  -- 39.0 - 02/12/2013 - MMM - 0029225: LCOL_MILL-0010290 Error al incluir apuntes de agenda para recibos rechazados agrupados en proceso del cobrador VISA - Inicio
                  FOR reg2 IN (SELECT nrecibo
                                 FROM adm_recunif_his a
                                WHERE a.nrecunif = reg.nrecibo
                                  AND nrecibo <> reg.nrecibo
                                  AND a.sdomunif =
                                         (SELECT MAX (sdomunif)
                                            FROM adm_recunif_his b
                                           WHERE b.nrecunif = a.nrecunif
                                             AND b.nrecibo <> reg.nrecibo))
                  LOOP
                     ntraza := 360;
                     -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Inicio
                     --vtextobs := REPLACE(vtextobs, reg.nrecibo,
                     --                    reg2.nrecibo || ' (' || reg.nrecibo || ') ');
                     --num_error := f_agd_observaciones(vcempres, reg2.nrecibo, vtextobs);
                     vtextobs2 :=
                        REPLACE (vtextobs,
                                 reg.nrecibo,
                                 reg2.nrecibo || ' (' || reg.nrecibo || ') '
                                );
                     ntraza := 370;
                     num_error :=
                        f_agd_observaciones (vcempres, reg2.nrecibo,
                                             vtextobs2);

                     -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Fin
                     IF num_error <> 0
                     THEN
                        RAISE salir;
                     END IF;
                  END LOOP;
               -- 39.0 - 02/12/2013 - MMM - 0029225: LCOL_MILL-0010290 Error al incluir apuntes de agenda para recibos rechazados agrupados en proceso del cobrador VISA - Fin
               END;
            END IF;
         -- 33.  0025151: LCOL999-Redefinir el circuito de prenotificaciones -- Fin
         END IF;
      END LOOP;

      RETURN num_error;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_devolu.tratar_devoluciones',
                      ntraza,
                      'When SALIR',
                      SQLERRM
                     );
         RETURN num_error;
      WHEN OTHERS
      THEN
         --         DBMS_OUTPUT.put_line ('ERROR ' || SQLERRM);
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_devolu.tratar_devoluciones',
                      ntraza,
                      'When others',
                      SQLERRM
                     );
         num_error := 140039;
         RETURN num_error;
   END tratar_devoluciones;

   -- 26.  0022762: MDP_A001-Impago de recibos (impago masivo) - Inicio
   FUNCTION f_impaga_rebut (
      pnrecibo   IN   NUMBER,
      pfecha     IN   DATE,
      pccobban   IN   NUMBER,
      pcmotivo   IN   NUMBER,
      pcrecimp   IN   NUMBER DEFAULT 0,       --Bug.: 16383 - ICV - 17/11/2010
      psproces   IN   NUMBER DEFAULT NULL,
                --BUG 36911-209890 10/07/2015 KJSC Nuevo parametro de psproces
      pnpoliza   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      error      NUMBER := 0;
      vsmovagr   NUMBER := 0;
   BEGIN
      error :=
         f_impaga_rebut_2 (pnrecibo,
                           pfecha,
                           pccobban,
                           pcmotivo,
                           pcrecimp,
                           vsmovagr,
                           psproces,
                           pnpoliza
                          );                                      --pnpoliza);
      RETURN error;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_impaga_rebut;

   /*************************************************************************
            Funci¿n que que genera impago de recibos (2 parte)
    param in pnrecibo     : N¿ Recibo
    param in pfecha       : Fecha del impago
    param in pccobban     : Cobrador bancario
    param in pcmotivo     : Motivo
    param in pcrecimp     : Recibos impreso
    param in out psmovagr : C¿digo agrupador de movimientos
    return                : NUMBER (posible error)(0 OK)
   -- Se crea esta funci¿n con el cuerpo de la anterior f_impaga_rebut, para poder
   -- a¿adirle un par¿metro OUT sin que esto afecte a todas las llamadas existentes.
   -- "f_impaga_recibo" se deja para las llamadas antiguas, las que requieran
   -- que se les devuelva el SMOVAGR deber¿n llamar a esta "f_impaga_rebut_2"
   *************************************************************************/
   FUNCTION f_impaga_rebut_2 (
      pnrecibo   IN       NUMBER,
      pfecha     IN       DATE,
      pccobban   IN       NUMBER,
      pcmotivo   IN       NUMBER,
      pcrecimp   IN       NUMBER DEFAULT 0,   --Bug.: 16383 - ICV - 17/11/2010
      psmovagr   IN OUT   NUMBER,
      psproces   IN       NUMBER DEFAULT NULL,
                --BUG 36911-209890 10/07/2015 KJSC Nuevo parametro de psproces
      pnpoliza   IN       NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      -- 26.  0022762: MDP_A001-Impago de recibos (impago masivo) - Fin
      error             NUMBER                   := 0;
      xcestrec          NUMBER;
      xsmovagr          NUMBER;
      xnliqmen          NUMBER;
      dummy             NUMBER;
      -- Bug 9383 - 05/03/2009 - RSC - CRE: Unificaci¿n de recibos
      vcramo            seguros.cramo%TYPE;
      vcmodali          seguros.cmodali%TYPE;
      vctipseg          seguros.ctipseg%TYPE;
      vccolect          seguros.ccolect%TYPE;
      vcountagrp        NUMBER;
      -- Fin Bug 9383
      v_cobra_recdom    NUMBER;
      vcempres          empresas.cempres%TYPE;
      vsproduc          seguros.sproduc%TYPE;
      vsseguro          seguros.sseguro%TYPE;
      vsseguro_d        seguros.sseguro%TYPE;
      vnmovimi          recibos.nmovimi%TYPE;
      vsperson          tomadores.sperson%TYPE;
      v_importe         NUMBER;
      v_seqcaja         NUMBER;
      vnnumlin          NUMBER;
      -- JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES
      vobject           VARCHAR2 (100)       := 'pac_devolu.f_impaga_rebut_2';
      -- 32. 0026169 - 0138818
      vpasexec          NUMBER                   := 1;
                                                     -- 32. 0026169 - 0138818
      -- INI 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
      vnpolizaantiguo   NUMBER;
      -- FIN 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
      vparam            VARCHAR2 (2000)
         :=    'pnrecibo:'
            || pnrecibo
            || ' pfecha:'
            || pfecha
            || ' pccobban:'
            || pccobban
            || ' pcmotivo:'
            || pcmotivo
            || ' pcrecimp:'
            || pcrecimp
            || ' psmovagr:'
            || psmovagr
            || ' psproces:'
            || psproces
            || ' pnpoliza:'
            || pnpoliza;
   BEGIN
      --
      -- Inicialmente, se marcan los recibos devueltos como 'pendientes'
      --
      -- xsmovagr := 0;            -- 26. 0022762 / 0119021 (-)
      vpasexec := 10;
      psmovagr := NVL (psmovagr, 0);             -- 26. 0022762 / 0119021 (+)
      error := 0;
      --      DBMS_OUTPUT.put_line (   'f_impaga_rebut '
      --                            || pnrecibo
      --                            || ' con pfecha '
      --                            || pfecha
      --                           );
      vpasexec := 20;
      error := f_situarec (pnrecibo,
                           -- 34. MMM - 0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - INICIO
                           --f_sysdate,
                           pfecha,
                           -- 34.  0027596: 0008438: Cuando se realiza un devuelto de un cheque IAXIS no cambia el estado del recibo a "Devuelto" - FIN
                           xcestrec);
      -- 27/02/2012 JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES - Inicio
      -- Control para que se compruebe que los fondos est¿n abiertos antes de tratar
      -- los cobros que puedan venir por respuesta del banco.
      -- Esto nos pasar¿ en los recibos que al enviar al banco quedaron REMESADOS.
      vpasexec := 30;
      v_cobra_recdom :=
         NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'COBRA_RECDOM'
                                            ),
              1
             );
      -- 17.1 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135
      -- Cambio de planes, ahora es necesario que que se dejen pendientes (impagen) tanto los
      -- recibos cobrados, como los remesados desde la pantalla de impago de recibos
      vpasexec := 40;

      IF xcestrec NOT IN (1, 3)
      THEN
         -- Mensaje de aviso en procesoslin
         DECLARE
            --BUG 36911-209890 10/07/2015 KJSC guarde en procesoslin un aviso de que el recibo (pnrecibo) a la fecha (pfecha) no esta cobrado.
            v_texto     VARCHAR2 (120);
            v_num_lin   NUMBER;
            v_err_pro   NUMBER;
         BEGIN
            v_texto := f_axis_literales (9908327, f_idiomauser);
            v_texto :=
                  'El Recibo '
               || pnrecibo
               || ' a la fecha '
               || pfecha
               || ' '
               || v_texto;
            v_num_lin := NULL;
            vpasexec := 45;
            v_err_pro := f_proceslin (psproces, v_texto, pnrecibo, v_num_lin);
         END;
      END IF;

      IF error = 0
                  -- AND xcestrec IN(1, 3) THEN  -- JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES
                  -- AND xcestrec = v_cobra_recdom THEN   -- JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES -- 17.1 (-)
                  -- Bug 9383 - 05/03/2009 - RSC - CRE: Unificaci¿n de recibos
         AND xcestrec IN (1, 3)
      THEN                                                         -- 17.1 (+)
         -- Descobrar un recibo que es una agrupaci¿n de recibos descobra
         -- los recibos peque¿itos.
         vpasexec := 50;

           -- INI 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
         --SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, r.cempres, s.sproduc, s.sseguro, r.nmovimi
         --  INTO vcramo, vcmodali, vctipseg, vccolect, vcempres, vsproduc, vsseguro, vnmovimi
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, r.cempres,
                s.sproduc, s.sseguro, r.nmovimi, s.npoliza
           INTO vcramo, vcmodali, vctipseg, vccolect, vcempres,
                vsproduc, vsseguro, vnmovimi, vnpolizaantiguo
           -- FIN 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
         FROM   recibos r, seguros s
          WHERE r.sseguro = s.sseguro AND r.nrecibo = pnrecibo;

         IF     NVL (f_parproductos_v (vsproduc, 'HAYCTACLIENTE'), 0) = 2
            AND pnpoliza IS NOT NULL
         THEN
            vpasexec := 51;

            -- INI 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
            IF pnpoliza = vnpolizaantiguo
            THEN
               RETURN 9909141;
            END IF;

            -- FIN 06/07/2016 MSV-97 Poner una validaci¿n en el impago de recibos para que no se pueda indicar el mismo n¿mero de p¿liza origen y destino
            SELECT SUM (NVL (vm.itotalr, v.itotalr))
              INTO v_importe
              FROM vdetrecibos v, vdetrecibos_monpol vm
             WHERE v.nrecibo = pnrecibo AND vm.nrecibo(+) = v.nrecibo;

            vpasexec := 52;
            error :=
               pac_ctacliente.f_apunte_spl (vcempres,
                                            vsseguro,
                                            vnmovimi,
                                            pnrecibo
                                           );

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam || '-' || vnmovimi || '-' || v_importe,
                            f_axis_literales (error,
                                              pac_md_common.f_get_cxtidioma
                                             )
                           );
               RETURN error;
            END IF;

            vpasexec := 521;

            SELECT MAX (nnumlin)
              INTO vnnumlin
              FROM ctacliente
             WHERE cempres = vcempres AND sseguro = vsseguro;

            vpasexec := 522;

            UPDATE ctacliente
               SET cmovimi = 3
             WHERE cempres = vcempres
               AND sseguro = vsseguro
               AND nnumlin = vnnumlin;

            vpasexec := 53;

            SELECT sseguro
              INTO vsseguro_d
              FROM seguros
             WHERE npoliza = pnpoliza;

            vpasexec := 54;

            SELECT t.sperson
              INTO vsperson
              FROM tomadores t
             WHERE t.sseguro = vsseguro
               AND t.nordtom = (SELECT MIN (t1.nordtom)
                                  FROM tomadores t1
                                 WHERE t1.sseguro = t.sseguro);

            vpasexec := 55;
            error :=
               pac_caja.f_insmovcaja_spl (vcempres,
                                          vsseguro,
                                          v_importe,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          7,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          1,
                                          vsseguro_d,
                                          21,
                                          NULL,
                                          vsperson,
                                          0
                                         );

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                               vparam
                            || '-'
                            || vsseguro
                            || '-'
                            || vsperson
                            || '-'
                            || v_importe
                            || '-'
                            || vsseguro_d,
                            f_axis_literales (error,
                                              pac_md_common.f_get_cxtidioma
                                             )
                           );
               RETURN error;
            END IF;

            vpasexec := 56;
            error := pac_caja.f_insmovcaja_apply (vsseguro, vsperson);

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                               vparam
                            || '-'
                            || vsseguro
                            || '-'
                            || vsperson
                            || '-'
                            || v_importe
                            || '-'
                            || vsseguro_d,
                            f_axis_literales (error,
                                              pac_md_common.f_get_cxtidioma
                                             )
                           );
               RETURN error;
            END IF;

            vpasexec := 57;

            SELECT MAX (seqcaja)
              INTO v_seqcaja
              FROM caja_datmedio
             WHERE sseguro = vsseguro
               AND cmedmov = 7
               AND cestado = 2
               AND sseguro_d = vsseguro_d;

            vpasexec := 58;
            error :=
                pac_caja.f_aprueba_caja_spl (vsseguro, vsperson, v_seqcaja, 1);

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                               vparam
                            || '-'
                            || vsseguro
                            || '-'
                            || v_seqcaja
                            || '-'
                            || v_importe
                            || '-'
                            || vsseguro_d,
                            f_axis_literales (error,
                                              pac_md_common.f_get_cxtidioma
                                             )
                           );
               RETURN error;
            END IF;
         END IF;

         -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818
         -- 32. Este IF no se ha de ver afectado por los cambios del punto 32
         vpasexec := 60;

         IF NVL (f_parproductos_v (f_sproduc_ret (vcramo,
                                                  vcmodali,
                                                  vctipseg,
                                                  vccolect
                                                 ),
                                   'RECUNIF'
                                  ),
                 0
                ) = 1
         THEN
            /******************************************
                              No se puede devolver un recibo peque¿ito que
            pertenezca a una agrupaci¿n de recibos.
            *******************************************/
            vpasexec := 70;

            SELECT COUNT (*)
              INTO vcountagrp
              FROM adm_recunif
             WHERE nrecibo = pnrecibo AND sdomunif IS NULL;
                                                     -- Bug 35645 MMS 20150422

            vpasexec := 80;

            IF vcountagrp > 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'pac_devolu.f_impaga_rebut',
                            2,
                            f_axis_literales (9001161, f_idiomauser),
                            SQLERRM
                           );
               RETURN 9001161;
            END IF;
         END IF;

         -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
         --IF NVL(f_parproductos_v(f_sproduc_ret(vcramo, vcmodali, vctipseg, vccolect),
         --                        'RECUNIF'),
         --       0) IN(1, 2) THEN
         vpasexec := 90;

         IF pac_domis.f_agrupa_rec_tipo (pccobban,
                                         vcempres,
                                         f_sproduc_ret (vcramo,
                                                        vcmodali,
                                                        vctipseg,
                                                        vccolect
                                                       )
                                        ) IN (1, 2, 4)
         THEN
            -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin
               -- Si se devuelve un recibo agrupado entrar¿ en LOOP
            vpasexec := 100;

            FOR v_recind IN (SELECT nrecibo
                               FROM adm_recunif a
                              WHERE (   nrecunif IN (
                                                     SELECT nrecibo
                                                       FROM adm_recunif
                                                      WHERE nrecunif =
                                                                      pnrecibo)
                                     OR nrecunif = pnrecibo
                                    )
                                AND nrecibo != pnrecibo
                                                       -- 13. 0021480: LCOL898 (para que no lo haga 2 veces)
                           )
            LOOP
               --Deixa el rebut a pendent
               vpasexec := 110;
               error :=
                  f_movrecibo (v_recind.nrecibo,
                               0,
                               pfecha,
                               NULL, -- xsmovagr, -- 26. 0022762 / 0119021 (-)
                               psmovagr,          -- 26. 0022762 / 0119021 (+)
                               xnliqmen,
                               dummy,
                               pfecha,
                               pccobban,
                               NULL,
                               pcmotivo,
                               NULL
                              );
               vpasexec := 120;

               IF error = 0
               THEN
                  BEGIN
                     vpasexec := 130;

                     UPDATE recibos
                        -- SET cestimp = 1   --Pendent d'imprimir
                        -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Inicio
                        -- SET cestimp = 6   --Domiciliaci¿ retinguda
                     SET cestimp =
                            DECODE (cestimp,
                                    7, 9,
                                    DECODE (cbancar, NULL, 3, 6)
                                   )
                      -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Final
                     WHERE  nrecibo = v_recind.nrecibo;
                                                  -- Bug 0035645: MMS 20150421
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        error := 102358;
                        -- Error al modificar la taula RECIBOS
                        RETURN error;
                  END;
               END IF;
            END LOOP;

            -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
            -- 32. Debemos desagrupar los recibos tratados, aqu¿ los devueltos. En pac_domis.f_estado_domiciliaci¿n los cobrados.
            error := pac_domis.f_desagrupa_rec (pnrecibo);

            IF error <> 0
            THEN
               RETURN error;
            END IF;
         -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin
         END IF;

         -- Fin Bug 9383

         --Deixa el rebut a pendent
         vpasexec := 140;
         error :=
            f_movrecibo (pnrecibo,
                         0,
                         pfecha,
                         NULL,       -- xsmovagr, -- 26. 0022762 / 0119021 (-)
                         psmovagr,                -- 26. 0022762 / 0119021 (+)
                         xnliqmen,
                         dummy,
                         pfecha,
                         pccobban,
                         NULL,
                         pcmotivo,
                         NULL
                        );
         --         DBMS_OUTPUT.put_line ('Despues de f_movrecibo con error : ' || error);
         vpasexec := 150;

         IF error = 0
         THEN
            BEGIN
               vpasexec := 160;

               UPDATE recibos
                  --       SET cestimp = 1   --Pendent d'imprimir
                  -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Inicio
                  -- SET cestimp = 6   --Domiciliaci¿ retinguda
               SET cestimp =
                          DECODE (cestimp,
                                  7, 9,
                                  DECODE (cbancar, NULL, 3, 6)
                                 )
                -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Final
               WHERE  nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  error := 102358;     -- Error al modificar la taula RECIBOS
                  RETURN error;
            END;
         END IF;

         --Ini. Bug.: 16383 - ICV - 17/11/2010
         --Si el recibo ha ido bien y hay que generar recibo por recargo de impago lo generamos
         IF pcrecimp = 1
         THEN
            vpasexec := 170;
            error :=
                  pac_devolu.f_set_recargoimpago (pnrecibo, pfecha, pccobban);

            IF error <> 0
            THEN
               RETURN error;
            END IF;
         END IF;
      --Fi Bug.: 16383
      END IF;

      -- 17.1 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135 - Inicio
      -- Cambio de planes, ahora es necesario que que se dejen pendientes (impagen) tanto los
      -- recibos cobrados, como los remesados desde la pantalla de impago de recibos
      /*
                  -- JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES - Inicio
      -- IF xcestrec NOT IN(1, 3) THEN
         -- error := 110633;   -- El rebut no esta cobrat o ...
      IF xcestrec != v_cobra_recdom THEN
         -- El recibo no est¿ cobrado ni remesado
         error := 9903341;
         -- JGR 13. 0021480: LCOL898-Tomar pendientes de DOMICILIACIONES - Fin
         RETURN error;
      END IF;
      */
      vpasexec := 220;

      -- 17.1 0022047: LCOL_A001-Activar la pantalla de impagados para recibos cobrados - 0113135 - Fin
      IF error <> 0
      THEN
         RETURN error;
      END IF;

      vpasexec := 230;
      RETURN error;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_impaga_rebut_2;

   -- 30.  0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752 - Inicio
   -- Se han declarado en la especificaci¿n la funci¿n "anula_poliza" para que puedan ser llamada desde el
   -- PAC_PROPIO.F_DEVOLU_ACCION_7. Anteriormente estaban dentro del "F_DEVOL_AUTOMATICO"
   PROCEDURE anula_poliza (
      psseguro   IN   NUMBER,
      pffejecu   IN   DATE,
      pcmotivo   IN   NUMBER
   )
   IS
      -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Inicio
      /*
      pcmotmov       NUMBER;
      vrec_pend      pac_anulacion.recibos_pend;
      vrec_cob       pac_anulacion.recibos_cob;
      i              NUMBER;
      vcmoneda       monedas.cmoneda%TYPE;
      */
      -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Final
      vnum_err   NUMBER;
   BEGIN
      vnum_err := f_anula_poliza (psseguro, pffejecu, pcmotivo);
    -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Inicio
    /*

    -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
    BEGIN
       SELECT pac_monedas.f_moneda_producto(sproduc)
         INTO vcmoneda
         FROM seguros
        WHERE sseguro = psseguro;
    EXCEPTION
       WHEN OTHERS THEN
          vcmoneda := pac_parametros.f_parinstalacion_n('MONEDAINST');
    END;

    -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda

    --  Distingim el moviment d'anul¿laci¿ segons el motiu de devoluci¿.
    IF pcmotivo IN(5, 6) THEN
       pcmotmov := 370;   -- decisi¿ del client sense extorn
    ELSE
       pcmotmov := 321;   -- an.per impagament
    END IF;

    --Busquem els rebuts pendents per anul¿lar-los
    i := 0;

    -- Bug 22084 - APD - 25/06/2012 - se a¿ade la condicion r.ctiprec <> 14
    -- para que no anule los recibos de tipo Tiempo Transcurrido (v.f.8)
    FOR rrec IN (SELECT r.nrecibo, m.fmovini, r.fefecto, r.fvencim
                   FROM movrecibo m, recibos r, vdetrecibos v
                  WHERE m.nrecibo = r.nrecibo
                    AND m.nrecibo = v.nrecibo
                    AND m.fmovfin IS NULL
                    AND m.cestrec = 0
                    AND r.sseguro = psseguro
                    -- 31.  0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
                    AND r.fefecto >= pffejecu
                    -- 40.0 - 24/12/2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Inicio
                    --AND r.ctiprec NOT IN(9, 14)) LOOP
                    -- Dejamos que no trate los recibos de tipo 14 ni los de tipo 9 que tengan motivo 339
                    AND r.ctiprec NOT IN(14)
                    AND NOT(r.ctiprec = 9
                            AND NVL(m.cmotmov, -1) = 339)) LOOP
                    -- 40.0 - 24/12/2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Fin
       --                AND r.ctiprec <> 14) LOOP
       -- 31.  0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
       -- fin Bug 22084 - APD - 25/06/2012
       vrec_pend(i) := rrec;
       i := i + 1;
    END LOOP;

    -- fanupol := pffejecu; -- 30.  0023864 - 0124752 (-)

    --         DBMS_OUTPUT.put_line ('llamamos a f_anula_poliza');
    -- No realitzem el extorn pq ja agafem la data d'anulaci¿
    --  per no fer extorn
    vnum_err :=
       pac_anulacion.f_anula_poliza
          (psseguro, pcmotmov,   -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                 --1,
           vcmoneda,   -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                       -- fanupol, 0, 1, NULL, vrec_pend, vrec_cob); -- 22. 0022686 - 0117742 (-)
                       -- fanupol, -- 30.  0023864 - 0124752 (-)
           pffejecu,   -- 30.  0023864 - 0124752 (+)
           1, 1, NULL, vrec_pend, vrec_cob);   -- 22. 0022686 - 0117742 (+)
   */
    -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Final
   END anula_poliza;

   -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Inicio
   FUNCTION f_anula_poliza (
      psseguro   IN   NUMBER,
      pffejecu   IN   DATE,
      pcmotivo   IN   NUMBER
   )
      RETURN NUMBER
   IS
      pcmotmov    NUMBER;
      vrec_pend   pac_anulacion.recibos_pend;
      vrec_cob    pac_anulacion.recibos_cob;
      i           NUMBER;
      vcmoneda    monedas.cmoneda%TYPE;
      vnum_err    NUMBER;
   BEGIN
      -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vcmoneda
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            vcmoneda := pac_parametros.f_parinstalacion_n ('MONEDAINST');
      END;

      -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda

      --  Distingim el moviment d'anul¿laci¿ segons el motiu de devoluci¿.
      IF pcmotivo IN (5, 6)
      THEN
         pcmotmov := 370;                  -- decisi¿ del client sense extorn
      ELSE
         pcmotmov := 321;                                -- an.per impagament
      END IF;

      --Busquem els rebuts pendents per anul¿lar-los
      i := 0;

      -- Bug 22084 - APD - 25/06/2012 - se a¿ade la condicion r.ctiprec <> 14
      -- para que no anule los recibos de tipo Tiempo Transcurrido (v.f.8)
      FOR rrec IN (SELECT r.nrecibo, m.fmovini, r.fefecto, r.fvencim
                     FROM movrecibo m, recibos r, vdetrecibos v
                    WHERE m.nrecibo = r.nrecibo
                      AND m.nrecibo = v.nrecibo
                      AND m.fmovfin IS NULL
                      AND m.cestrec = 0
                      AND r.sseguro = psseguro
                      -- 31.  0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
                      AND r.fefecto >= pffejecu
                      -- 40.0 - 24/12/2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Inicio
                      --AND r.ctiprec NOT IN(9, 14)) LOOP
                      -- Dejamos que no trate los recibos de tipo 14 ni los de tipo 9 que tengan motivo 339
                      -- INI IAXIS - 3592 -- ECP -- 15/05/2019
                      AND r.ctiprec NOT IN (0, 14)
                      -- FIN IAXIS - 3592 -- ECP -- 15/05/2019
                      AND NOT (r.ctiprec = 9 AND NVL (m.cmotmov, -1) = 339))
      LOOP
                      -- 40.0 - 24/12/2013 - MMM - 0029431: LCOL_MILL-10603: Al reactivar una poliza, el sistema debe conservar... Fin
         --                AND r.ctiprec <> 14) LOOP
         -- 31.  0022346: LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
         -- fin Bug 22084 - APD - 25/06/2012
         vrec_pend (i) := rrec;
         i := i + 1;
      END LOOP;

      -- fanupol := pffejecu; -- 30.  0023864 - 0124752 (-)

      --         DBMS_OUTPUT.put_line ('llamamos a f_anula_poliza');
      -- No realitzem el extorn pq ja agafem la data d'anulaci¿
      --  per no fer extorn
      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'VAL_ANUL_POL'
                                            ),
              0
             ) = 1
      THEN
--parametro que valida si la empresa decide tomar la cantidad de siniestros abiertos o comunicados para poder anular la poliza--
         vnum_err :=
            pac_anulacion.f_valida_permite_anular_poliza (psseguro,
                                                          f_sysdate,
                                                          0,
                                                          0
                                                         );

         IF vnum_err <> 0
         THEN
            RETURN vnum_err;
         END IF;
      END IF;

      vnum_err :=
         pac_anulacion.f_anula_poliza (psseguro,
                                       pcmotmov,
                                       -- BUG 18423 - F - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                       --1,
                                       vcmoneda,
                                       -- BUG 18423 - I - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                       -- fanupol, 0, 1, NULL, vrec_pend, vrec_cob); -- 22. 0022686 - 0117742 (-)
                                       -- fanupol, -- 30.  0023864 - 0124752 (-)
                                       pffejecu, -- 30.  0023864 - 0124752 (+)
                                       1,
                                       1,
                                       NULL,
                                       vrec_pend,
                                       vrec_cob
                                      );          -- 22. 0022686 - 0117742 (+)
                                      
                                      p_tab_error (f_sysdate,
                            f_user,
                            'psc_devolu.f_anula_poliza',
                            2,
                            f_axis_literales (vnum_err, f_idiomauser),
                            ' psseguro-->'
                   || psseguro
                   || ' pffejecu-->'
                   || pffejecu
                   || ' pcmotmov-->'
                   || pcmotmov
                   || ' vcmoneda-->'
                   || vcmoneda
                   || ' vnum_err-->'
                   || vnum_err
                  );
      RETURN vnum_err;
   END f_anula_poliza;

   -- 42. 0030545: 10429 - No se est¿ anulando p¿liza 61018125 desde la terminaci¿n por no pago - Final

   -- 30.  0023864: LCOL_A003-Terminacion por convenios - descuadre entre rescate y recibo - 0124752 - Fin
   FUNCTION f_devol_automatico (
      xcactimp1   NUMBER,
      xcactimp2   NUMBER,
      pidioma     VARCHAR2 DEFAULT '2',
      pproceso    NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      --  IPS: si XCACTIMP1=0 i XCACTIMP2=0 nom¿s far¿ anul¿lacions.
      -- per fer la resta posar els valors adients (es far¿ un between).
      -- IPS: Distingim el moviment d'anul¿laci¿ segons el motiu de devoluci¿.

      /***************************************************************************
                     Este proceso mirar en la tabla TMP_IMPAGADOS si hay alg¿n registro cuya fecha
         es igual a la de la fecha de ejecuci¿n. Si es as¿, realizar¿ la acci¿n que
         tenga informada en el campo CACTIMP(DET_VALORES=204). Estas acciones pueden ser:
              0- Anular P¿liza.
              1- Suspender Pago. + Anular Recibo
              2- Reenviar recibo.
              3- Anular Recibo
              4- Sin acci¿n.
           5- Reducci¿n
           6 - Retener p¿liza
      ****************************************************************************/
      PRAGMA AUTONOMOUS_TRANSACTION;

      CURSOR c_impagado
      IS
         SELECT   sseguro, nrecibo, ffejecu, ffecalt, cactimp, ccarta,
                  ctractat, cmotivo, nimpagad, sdevolu,
                  smovrec     --Bug 9204-MCC-03/03/2009-Nueva columna smovrec
             FROM tmp_impagados
            WHERE ffejecu <= f_sysdate
              AND ctractat = 1
              AND cactimp BETWEEN xcactimp1 AND xcactimp2
         -- nom¿s anul¿lacions
         ORDER BY sseguro, nrecibo, ffejecu DESC;

      num_err      NUMBER;
      sig_mov      NUMBER;
      suplemento   NUMBER;
      missatge     VARCHAR2 (1000);
      cad_reb      VARCHAR2 (100);
      xctractat    NUMBER;
      xterror      VARCHAR2 (1000);
      -- Variables pels processos
      psproces     NUMBER          := 0;                     --REBUTS TRACTATS
      --   c_num           NUMBER          := 0;       --Quantitat de rebuts tractats.
      c_err        NUMBER          := 0;
      --Contador dels rebuts que no es poden processar correctament.
      --   c_pos           NUMBER          := 0;
      --P¿lisses anul¿lades amb rebuts posteriors no-pendents.
      accio        VARCHAR2 (120);
      -- Dades del rebut
      xfmovini     DATE;
      xfefecto     DATE;
      xcestrec     NUMBER;
      -- Variables per anul¿lar rebuts
      xmotanul     NUMBER;
      xcdelega     NUMBER;
      xcempres     NUMBER;
      nliqmen      NUMBER;
      dummy        NUMBER;
      par_fecha    DATE;
      psmovrec     NUMBER;
      avui         DATE            := f_sysdate;
      pscaragr     NUMBER;
      v_sseguro    NUMBER;
      v_pcagrpro   NUMBER;
      secuencia    NUMBER;
      vnmovimi     NUMBER;
      fanupol      DATE;    -- Per guardar la data d'anul¿laci¿ de la p¿lissa.
      v_fefepol    DATE;
      anys         NUMBER;
      v_ctipoimp   NUMBER;
      cont_rec     NUMBER;

      -- fin Bug 22084 - APD - 20/07/2012
      PROCEDURE anula_rec (pnrecibo IN NUMBER, pffejecu IN DATE)
      IS
      BEGIN
----------------------
-- La fecha de efecto de anulaci¿n del recibo, para que sea coherente con las ventas, ser¿:
--    - la de la anulaci¿n de la p¿liza si se anula en futuro.
--    - la del d¿a si no estamos en el tiempo a¿adido de un mes no cerrado.
--    - la del ¿ltimo d¿a del mes de ventas abierto si estamos en el tiempo a¿adido de un mes no cerrado.
-- Siempre se tendr¿ en cuenta que no puede ser anterior al ¿ltimo movimiento del recibo.
         IF pffejecu >= avui
         THEN
            par_fecha := pffejecu;
         ELSE
            BEGIN
               SELECT LAST_DAY (ADD_MONTHS (MAX (fperini), 1))
                 INTO par_fecha
                 FROM cierres
                WHERE ctipo = 1 AND cestado = 1 AND cempres = xcempres;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  num_err := 108091;
               WHEN OTHERS
               THEN
                  num_err := 105511;
            END;

            IF avui < par_fecha OR par_fecha IS NULL
            THEN
               par_fecha := avui;
            END IF;
         END IF;

         IF par_fecha < xfmovini
         THEN
            par_fecha := xfmovini;
         END IF;

         xmotanul := 0;                  -- Nuevo funcionamiento de las ventas
         --         DBMS_OUTPUT.put_line (   'MovRecibo '
         --                               || pnrecibo
         --                               || '-'
         --                               || pffejecu
         --                               || '-'
         --                               || psmovrec
         --                               || '-'
         --                               || nliqmen
         --                               || '-'
         --                               || par_fecha
         --                               || '-'
         --                               || xcdelega
         --                               || '-'
         --                               || xmotanul
         --                              );
         num_err :=
            f_movrecibo (pnrecibo,
                         2,
                         pffejecu,
                         2,
                         psmovrec,
                         nliqmen,
                         dummy,
                         par_fecha,
                         NULL,
                         xcdelega,
                         xmotanul,
                         NULL
                        );
      END anula_rec;

      -- 30.  0023864 / 0124752 - 02/10/2012 - Fin
      PROCEDURE p_get_lre_personas (psperson IN NUMBER, pffejecu IN DATE)
      IS
         -- Alta de persona en personas restringidas LRE_PERSONAS cuando es un motivo 9 - convenios por d¿as.
         r_per      lre_personas%ROWTYPE;
         vpasexec   NUMBER                 := 0;
         vexiste    NUMBER;
      BEGIN
         IF psperson IS NOT NULL
         THEN
            -- No existe, es alta en la lista. Buscamos la persona
            vpasexec := 10;

            BEGIN
               SELECT DISTINCT 1
                          INTO vexiste
                          FROM lre_personas l
                         WHERE l.sperson = psperson AND l.ctiplis = 2;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  vpasexec := 20;
                  r_per.sperson := psperson;
                  vpasexec := 30;

                  SELECT nnumide, ctipide, ctipper,
                         sperlre.NEXTVAL
                    -- , nordide -- 10. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips
                  INTO   r_per.nnumide, r_per.ctipide, r_per.ctipper,
                         r_per.sperlre
                    -- ,r_per.nordide -- 10. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips
                  FROM   per_personas
                   WHERE sperson = r_per.sperson;

                  vpasexec := 40;

                  SELECT tnombre1, tnombre2, tapelli1,
                         tapelli2
                    INTO r_per.tnombre1, r_per.tnombre2, r_per.tapelli1,
                         r_per.tapelli2
                    FROM per_detper
                   WHERE sperson = r_per.sperson AND ROWNUM = 1;

                  -- 10. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips - Inicio
                  SELECT NVL (MAX (nordide), 0) + 1
                    INTO r_per.nordide
                    FROM lre_personas
                   WHERE nnumide = r_per.nnumide AND ctipide = r_per.ctipide;

                  -- 10. JGR 0021115: LCOL_A001-Rebuts no pagats i anticips - Fin
                  vpasexec := 50;
                  -- 9 JGR 21026 LCOL_A001-Convenio: parametrizar todos los productos - Inicio

                  --r_per.tnomape := UPPER(r_per.tapelli1 || ' ' || r_per.tapelli2 || ' '
                  --               || r_per.tnombre1 || ' ' || r_per.tnombre2);
                  r_per.tnomape :=
                     SUBSTR (UPPER (   r_per.tapelli1
                                    || ' '
                                    || r_per.tapelli2
                                    || ' '
                                    || r_per.tnombre1
                                    || ' '
                                    || r_per.tnombre2
                                   ),
                             1,
                             400
                            );
                  -- 9 JGR 21026 LCOL_A001-Convenio: parametrizar todos los productos - Fin
                  r_per.cnovedad := 1;
                  r_per.cnotifi := NULL;
                  r_per.cclalis := 2;
                  r_per.ctiplis := 2;
                  vpasexec := 60;
                  r_per.finclus := pffejecu;
                  r_per.cusumod := f_user;
                  r_per.fmodifi := f_sysdate;
                  vpasexec := 70;

                  BEGIN
                     INSERT INTO lre_personas
                                 (sperlre, nnumide,
                                  nordide, ctipide,
                                  ctipper, tnomape,
                                  tnombre1, tnombre2,
                                  tapelli1, tapelli2,
                                  sperson, cnovedad,
                                  cnotifi, cclalis,
                                  ctiplis, finclus,
                                  fexclus, cinclus,
                                  cexclus, cusumod, fmodifi
                                 )
                          VALUES (r_per.sperlre, r_per.nnumide,
                                  r_per.nordide, r_per.ctipide,
                                  r_per.ctipper, r_per.tnomape,
                                  r_per.tnombre1, r_per.tnombre2,
                                  r_per.tapelli1, r_per.tapelli2,
                                  r_per.sperson, r_per.cnovedad,
                                  r_per.cnotifi, r_per.cclalis,
                                  r_per.ctiplis, r_per.finclus,
                                  r_per.fexclus, r_per.cinclus,
                                  r_per.cexclus, r_per.cusumod, r_per.fmodifi
                                 );
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        num_err := 9902876;
                        -- Error al insertar en la tabla LRE_PERSONAS
                        p_tab_error (f_sysdate,
                                     f_user,
                                     'pac_devolu.p_get_lre_personas',
                                     vpasexec,
                                     'sperlre:' || r_per.sperlre,
                                     SQLERRM
                                    );
                  END;
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_devolu.p_get_lre_personas',
                               vpasexec,
                               SQLCODE,
                               SQLERRM
                              );
            END;
         ELSE
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_devolu.p_get_lre_personas',
                         vpasexec,
                         'Par¿metro SPERSON nulo - Error',
                         NULL
                        );
         END IF;
      END p_get_lre_personas;

      -- AXIS3304 20037 Parametrizaci¿n de Devoluciones - Fi
      -- Bug 22342 - APD - 11/06/2012 - se a¿ade el parametro psdevolu
      PROCEDURE realiza_accion (
         pcactimp   IN   NUMBER,
         pnrecibo   IN   NUMBER,
         pffejecu   IN   DATE,
         psseguro   IN   NUMBER,
         pcmotivo   IN   NUMBER,
         pffecalt   IN   DATE,
         psdevolu   IN   NUMBER
      )
      IS
         vveces          NUMBER                             := 0;
         vmaxfmov        DATE;
         vminfmov        DATE;
         v_csituac       NUMBER;
         viprovis        NUMBER;
         v_texto         VARCHAR2 (10000);    -- Bug 22342 - APD - 11/06/2012
         v_cremban       domiciliaciones_cab.cremban%TYPE;
         -- Bug 22342 - APD - 11/06/2012
         v_cbancar       recibos.cbancar%TYPE;
         -- Bug 22342 - APD - 11/06/2012
         v_cbancar_aux   VARCHAR2 (100);      -- Bug 22342 - APD - 11/06/2012
         v_ctipban       recibos.ctipban%TYPE;
         -- Bug 22342 - APD - 11/06/2012
         v_num_err       NUMBER;              -- Bug 22342 - APD - 11/06/2012
         v_idobs         NUMBER;              -- Bug 22342 - APD - 11/06/2012
         -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Incio
         v_texto2        VARCHAR2 (10000);
         -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Fin
         v_cmotmov       movseguro.cmotmov%TYPE;
         -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345
         v_fefecto       recibos.fefecto%TYPE;
         genrectt        NUMBER                             := 0;
         v_poliza        NUMBER;
--VARIABLE PARA CONTROLAR QUE INGRESE A FUNCION DE GENERACION DE RECIBO PRORRATA PARA RECIBOS MARCADOS IMPAGOS
      BEGIN
         BEGIN
            SELECT csituac, npoliza
              INTO v_csituac, v_poliza
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS
            THEN
               num_err := 101903; -- seguro no encontrado en la tabla SEGUROS
         END;

         BEGIN
            SELECT fefecto
              INTO v_fefecto
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS
            THEN
               num_err := 101903; -- seguro no encontrado en la tabla SEGUROS
         END;
    
-- Ini IAXIS-3592 -- 05/05/2020
        BEGIN
           SELECT 89905784
             INTO num_err
             FROM sin_siniestro SIN, sin_movsiniestro ms
            WHERE SIN.nsinies = ms.nsinies
              AND SIN.sseguro = psseguro
              AND ms.nmovsin = (SELECT MAX (nmovsin)
                                  FROM sin_movsiniestro
                                 WHERE nsinies = SIN.nsinies)
              AND ms.cestsin IN (0, 4, 5);
        EXCEPTION
           WHEN NO_DATA_FOUND
           THEN
              BEGIN
                 SELECT 89905784
                   INTO num_err
                   FROM sin_siniestro
                  WHERE sseguro = psseguro;
              EXCEPTION
                 WHEN NO_DATA_FOUND
                 THEN
                    num_err := 0;
              END;
              -- Fin IAXIS-3592 -- 05/05/2020
        END; 
        IF num_err = 0
         THEN
            IF pcactimp = 0
            THEN
               IF v_csituac = 0
               THEN
                  --GENERACION DE RECIBO PRORRATA CUANDO SE MARCAN COMO IMPAGOS INICIO
                  -- Ini IAXIS-3592--28/05/2019
                  IF NVL
                        (pac_parametros.f_parempresa_n
                                            (f_parinstalacion_n ('EMPRESADEF'),
                                             'RECIBO_TTRANSC'
                                            ),
                         0
                        ) = 1
                  -- Ini IAXIS-3592--28/05/2019
                  THEN
                     viprovis := NULL;
                     num_err :=
                        pac_propio.f_devolu_accion_7 (pcactimp,
                                                      pnrecibo,
                                                      pffejecu,
                                                      psseguro,
                                                      pcmotivo,
                                                      pffecalt,
                                                      viprovis,
                                                      NULL,
                                                      psproces
                                                     );
--INI IAXIS-3592 -- ECP -- 15/05/2019     --1
                     genrectt := 1;
--INI IAXIS-3592 -- ECP -- 15/05/2019
                  END IF;

                  IF genrectt = 0
                  THEN
                     anula_poliza (psseguro, v_fefecto, pcmotivo);
                  -- Anula P¿liza
                  END IF;
               --GENERACION DE RECIBO PRORRATA CUANDO SE MARCAN COMO IMPAGOS FIN
               ELSE
                  -- la p¿liza no est¿ en situaci¿n de anularse
                  p_proceslin
                     (psproces,
                      'No se anula la p¿liza porque la p¿liza ya est¿ anulada. Póliza'||v_poliza,
                      psseguro,
                      2
                     );                       -- la p¿liza no se puede anular;
               END IF;
            ELSIF pcactimp = 1
            THEN                             -- Suspender Pago + Anular Recibo
               -- Borro Fecha proxima cartera para que no me genere m¿s carteras.
               UPDATE seguros
                  SET fcarpro = NULL
                WHERE sseguro = psseguro;

               UPDATE seguros_aho
                  SET fsusapo = xfefecto
                WHERE sseguro = psseguro;

               -- Busco el Nro de suplemento.
               BEGIN
                  SELECT nsuplem
                    INTO suplemento
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi = (SELECT MAX (nmovimi)
                                      FROM movseguro
                                     WHERE sseguro = psseguro);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     num_err := 110062;   -- Suplement no trobat a MOVSEGURO.
                  WHEN OTHERS
                  THEN
                     num_err := 104349;        -- Problemes llegint MOVSEGURO
               END;

               -- Genero Movimiento.
               num_err :=
                  f_movseguro (psseguro,
                               NULL,
                               266,
                               1,
                               xfefecto,
                               NULL,
                               suplemento,
                               0,
                               NULL,
                               sig_mov,
                               avui,
                               NULL
                              );
               num_err := f_act_hisseg (psseguro, sig_mov - 1);

               FOR rrec IN (SELECT r.nrecibo, m.fmovini, r.fefecto, r.fvencim
                              FROM movrecibo m, recibos r, vdetrecibos v
                             WHERE m.nrecibo = r.nrecibo
                               AND m.nrecibo = v.nrecibo
                               AND m.fmovfin IS NULL
                               AND m.cestrec = 0
                               AND r.sseguro = psseguro)
               LOOP
                  -- Anular recibos
                  p_proceslin (psproces,
                               
                               -- 36.  0027940 - QT-8414 - Inicio
                               -- '01.Anula recibo ' || rrec.nrecibo || ' por pcactimp = '|| pcactimp,
                               '01.Anula recibo ' || rrec.nrecibo,
                               -- 36.  0027940 - QT-8414 - Final
                               psseguro,
                               2
                              );                                        -- 21.
                  anula_rec (rrec.nrecibo, pffejecu);
               END LOOP;
            ELSIF pcactimp = 2
            THEN                                            -- Reenviar Recibo
               IF v_csituac = 2
               THEN        -- SI LA P¿LIZA YA EST¿ ANULADA ANULAMOS EL RECIBO
                  p_proceslin (psproces,
                               
                               -- 36.  0027940 - QT-8414 - Inicio
                               -- '02.Anula recibo ' || pnrecibo || ' por pcactimp = ' || pcactimp,
                               '02.Anula recibo ' || pnrecibo,
                               -- 36.  0027940 - QT-8414 - Final
                               psseguro,
                               2
                              );                                        -- 21.
                  anula_rec (pnrecibo, pffejecu);
               ELSE
                  p_proceslin (psproces,
                               
                               -- 36.  0027940 - QT-8414 - Inicio
                               -- '03.Pdte.domiciliaci¿n recibo ' || pnrecibo || ' por pcactimp = ' || pcactimp,
                               '03.Pdte.domiciliaci¿n recibo ' || pnrecibo,
                               -- 36.  0027940 - QT-8414 - Final
                               psseguro,
                               2
                              );                                        -- 21.

                  UPDATE recibos
                     SET cestimp = 4                   -- pendent domiciliaci¿
                   WHERE nrecibo = pnrecibo;
               END IF;
            ELSIF pcactimp = 3
            THEN                                               -- Anula Recibo
               p_proceslin (psproces,
                            
                            -- 36.  0027940 - QT-8414 - Inicio
                            -- '04.Anula recibo ' || pnrecibo || ' por pcactimp = ' || pcactimp,
                            '04.Anula recibo ' || pnrecibo,
                            -- 36.  0027940 - QT-8414 - Final
                            psseguro,
                            2
                           );                                           -- 21.
               anula_rec (pnrecibo, pffejecu);
            -- Afegim noves accions
            ELSIF pcactimp = 5
            THEN                                                  -- Reducci¿n
               num_err := pac_ctaseguro.f_reduccion_total (psseguro);
            ELSIF pcactimp = 6
            THEN                                             -- Retener p¿liza
               -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Inicio
               BEGIN
                  SELECT cmotmov
                    INTO v_cmotmov
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi IN (SELECT MAX (nmovimi)
                                       FROM movseguro
                                      WHERE sseguro = psseguro);
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     num_err := 104348;
                  -- N¿mero de movimiento no encontrado en la tabla MOVSEGURO
                  WHEN OTHERS
                  THEN
                     num_err := 104349;
               -- Error al leer de la tabla MOVSEGURO
               END;

               IF num_err != 0
               THEN
                  v_texto :=
                        v_texto
                     || ' '
                     || ff_desvalorfijo (204, pidioma, pcactimp)
                     || ':'
                     || f_axis_literales (num_err, pidioma);
               ELSIF v_cmotmov != 115
               THEN                                --> P¿liza no est¿ retenida
                  -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Final
                  IF v_csituac <> 2
                  THEN              -- SI LA P¿LIZA EST¿ ANULADA NO RETENEMOS
                     num_err :=
                        f_movseguro (psseguro,
                                     NULL,
                                     115,
                                     10,
                                     pffejecu,
                                     NULL,
                                     NULL,
                                     0,
                                     NULL,
                                     vnmovimi,
                                     f_sysdate
                                    );

                     FOR rrec IN (SELECT r.nrecibo, m.fmovini, r.fefecto,
                                         r.fvencim
                                    FROM movrecibo m, recibos r,
                                         vdetrecibos v
                                   WHERE m.nrecibo = r.nrecibo
                                     AND m.nrecibo = v.nrecibo
                                     AND m.fmovfin IS NULL
                                     AND m.cestrec = 0
                                     AND r.sseguro = psseguro)
                     LOOP
                        UPDATE recibos
                           -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Inicio
                           -- SET cestimp = 6   --Domiciliaci¿ retinguda
                        SET cestimp =
                               DECODE (cestimp,
                                       7, 9,
                                       DECODE (cbancar, NULL, 3, 6)
                                      )
                         -- 45.  0029175: POSND100-POSADM - D?as de Gracia - 177345 - Final
                        WHERE  nrecibo = rrec.nrecibo;
                     END LOOP;
                  ELSE
                     p_proceslin
                        (psproces,
                         'No se retiene la p¿liza porque la p¿liza ya est¿ anulada',
                         psseguro,
                         2
                        );                           -- la p¿liza est¿ anulada
                  END IF;
               -- AXIS3304 20037 Parametrizaci¿n de Devoluciones - Inici
               END IF;
            ELSIF pcactimp = 7
            THEN                               -- Acci¿n 7 - PAGOS PERMANENTES
               viprovis := NULL;
               -- 30.  0023864 / 0124752 - 02/10/2012 - Inicio
               num_err :=
                  pac_propio.f_devolu_accion_7 (pcactimp,
                                                pnrecibo,
                                                pffejecu,
                                                psseguro,
                                                pcmotivo,
                                                pffecalt,
                                                viprovis,
                                                NULL,
                                                psproces
                                               );

               --p_realiza_accion_7(pcactimp, pnrecibo, pffejecu, psseguro, pcmotivo, pffecalt,
               --                   viprovis);
               -- 30.  0023864 / 0124752 - 02/10/2012 - Fin

               -- Alta de persona en personas restringidas LRE_PERSONAS en convenios por d¿as (motivo 9)
               -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
               --IF pcmotivo = 9 THEN
               IF pcmotivo = 9 AND num_err = 0
               THEN
                  -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin
                  BEGIN
                     -- JLB - I - Se cambia por la nueva configuraci¿n de LRE
                     --
                     /*
                                                                                    p_get_lre_personas(
                     -- psseguro,             -- 8 JGR 21026 LCOL_A001-Convenio: parametrizar todos los productos
                                                             ff_sperson_tomador(psseguro),
                                                             -- 8 JGR 21026 LCOL_A001-Convenio: parametrizar todos los productos
                                                             pffejecu);
                     */
                     num_err :=
                        pac_listarestringida.f_valida_listarestringida
                              (psseguro,
                               sig_mov,
                               NULL,
                               3,
                               pnrecibo,
                               NULL,
                               psdevolu -- Bug 31411/175020 - 16/05/2014 - AMC
                              );
                  -- JLB - F -  Se cambia por la nueva configuraci¿n de LRE
                  END;
               END IF;
            -- 30.  0023864 / 0124752 - 02/10/2012 - Inicio
            -- Se descarta el uso de la acci¿n 8 (se integr¿ en la 7)
            /*
                                    ELSIF pcactimp = 8 THEN   -- Acci¿n 8 - PROCESO PAGOS LIMITADOS
               viprovis := NULL;
               -- La primera parte de la acci¿n 8 coincide con la 7
               num_err := pac_propio.f_devolu_accion_7(pcactimp, pnrecibo, pffejecu, psseguro,
                                                       pcmotivo, pffecalt, viprovis, NULL,
                                                       psproces);
               --p_realiza_accion_7(pcactimp, pnrecibo, pffejecu, psseguro, pcmotivo, pffecalt,
               --                   viprovis);
               --IF NVL(viprovis, 0) > 0 THEN
               --   p_realiza_accion_8(pcactimp, pnrecibo, pffejecu, psseguro, pcmotivo,
               --                      pffecalt, viprovis);
               --END IF;
            */
            -- 30.  0023864 / 0124752 - 02/10/2012 - Fin

            -- AXIS3304 20037 Parametrizaci¿n de Devoluciones - Fi
            END IF;                                             -- DE PCTIPIMP

            -- Bug 22342 - APD - 11/06/2012 -- se ha de insertar en pac_agenda.f_set_obs
            -- seg¿n el parametro PAREMPRESA
            IF NVL
                  (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'AGENDA_DEVOLU'
                                              ),
                   0
                  ) = 1
            THEN
               BEGIN
                  SELECT cremban
                    INTO v_cremban
                    FROM domiciliaciones_cab
                   WHERE sdevolu = psdevolu;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_cremban := NULL;
               END;

               BEGIN
                  SELECT ctipban, cbancar
                    INTO v_ctipban, v_cbancar
                    FROM recibos
                   WHERE nrecibo = pnrecibo;

                  -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
                  IF v_ctipban IS NOT NULL AND v_cbancar IS NOT NULL
                  THEN
                     v_num_err :=
                           f_formatoccc (v_cbancar, v_cbancar_aux, v_ctipban);
                  ELSE
                     v_cbancar_aux := NULL;
                  END IF;
               -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     v_cbancar_aux := NULL;
               END;

               v_texto :=
                     f_axis_literales (108527, pidioma)
                  || ' '
                  || v_cremban
                  || ' '
                  || f_axis_literales (100562, pidioma)
                  || ' '
                  || TO_CHAR (pffejecu, 'DD/MM/YYYY')
                  || ' ';

               -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Inicio
               -- Se modifica para que solo informe la parte de la CCC si existe la info en v_cbancar_aux
               IF v_cbancar_aux IS NOT NULL
               THEN
                  v_texto :=
                        v_texto
                     || f_axis_literales (100965, pidioma)
                     || ' '
                     || '***'
                     || SUBSTR (v_cbancar_aux, -4)
                     || ' ';
               END IF;

               -- 38.0 - 16/10/2013 - MMM - 0028546: LCOL_A005-Mejorar el rendimiento de terminacion por no pago - Fin
               v_texto :=
                     v_texto
                  || CHR (39)
                  || ff_desvalorfijo (73, pidioma, pcmotivo)
                  || CHR (39)
                  || ' - '
                  || f_axis_literales (103958, pidioma)
                  || ' '
                  || CHR (39)
                  || ff_desvalorfijo (204, pidioma, pcactimp)
                  || CHR (39)
                  || ' - ';

               IF num_err = 0
               THEN
                  -- Ejem.: Remesa 9999 Fecha 9999 Cta.Bancaria 9999.9999.99.9999999999 "desc. motivo anulaci¿n" - Acci¿n: "Acci¿n autom¿tica" - realizada
                  v_texto := v_texto || f_axis_literales (9903797, pidioma);
               ELSE
                  -- Ejem.: Remesa 9999 Fecha 9999 Cta.Bancaria 9999.9999.99.9999999999 "desc. motivo anulaci¿n" - Acci¿n: "Acci¿n autom¿tica" - no realizada: "Causa que impidi¿ la acci¿n"
                  v_texto :=
                        v_texto
                     || f_axis_literales (9903798, pidioma)
                     || ': '
                     || CHR (39)
                     || f_axis_literales (num_err, pidioma)
                     || CHR (39);
               END IF;

               -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Inicio
               v_num_err :=
                  pac_agenda.f_set_obs (pac_md_common.f_get_cxtempresa,
                                        NULL,
                                        5                       /*Automatico*/
                                         ,
                                        0                       /*Automatico*/
                                         ,
                                        f_axis_literales (9903799, pidioma),
                                        v_texto,
                                        pffejecu,
                                        NULL,
                                        2,
                                        NULL,
                                        NULL,
                                        NULL,
                                        NULL,
                                        1,
                                        pffejecu,
                                        v_idobs,
                                        NULL,
                                        pnrecibo,
                                        NULL,
                                        NULL,
                                        NULL
                                       );

               FOR reg2 IN (SELECT nrecibo
                              FROM adm_recunif_his a
                             WHERE a.nrecunif = pnrecibo
                               AND nrecibo <> pnrecibo
                               AND a.sdomunif =
                                      (SELECT MAX (sdomunif)
                                         FROM adm_recunif_his b
                                        WHERE b.nrecunif = a.nrecunif
                                          AND b.nrecibo <> pnrecibo))
               LOOP
                  v_texto2 :=
                     REPLACE (v_texto,
                              pnrecibo,
                              reg2.nrecibo || ' (' || pnrecibo || ') '
                             );
                  v_num_err :=
                     pac_agenda.f_set_obs (pac_md_common.f_get_cxtempresa,
                                           NULL,
                                           5                    /*Automatico*/
                                            ,
                                           0                    /*Automatico*/
                                            ,
                                           f_axis_literales (9903799, pidioma),
                                           v_texto2,
                                           pffejecu,
                                           NULL,
                                           2,
                                           NULL,
                                           NULL,
                                           NULL,
                                           NULL,
                                           1,
                                           pffejecu,
                                           v_idobs,
                                           NULL,
                                           reg2.nrecibo,
                                           NULL,
                                           NULL,
                                           NULL
                                          );
               END LOOP;

               -- 41.0 - 21/01/2014 - MMM - 0029225: NOTA_0163734_LCOL_MILL-0010290 Error al incluir apuntes de agenda - Fin
               IF v_num_err <> 0
               THEN
                  p_proceslin (psproces,
                                  f_axis_literales (9903800, pidioma)
                               || ' '
                               || f_axis_literales (100864, pidioma)
                               || pnrecibo,
                               psseguro,
                               1
                              );
               END IF;
            END IF;
         -- fin Bug 22342 - APD - 11/06/2012
         END IF;                                            -- DE  NUM_ERR = 0
      END realiza_accion;

      PROCEDURE enviar_carta (
         pnrecibo   IN   NUMBER,
         pcmodimm   IN   NUMBER,
         psdevolu   IN   NUMBER,
         psmovrec   IN   NUMBER
      )
      IS                    --Bug 9204-MCC-03/03/2009-Nuevo par¿metro psmovrec
         c_recanudevban   NUMBER;
         v_fefecto        DATE;
         v_sseguro        NUMBER;
         v_nriesgo        NUMBER;
         v_fanulac_seg    DATE;
         v_sproduc        NUMBER;
         v_fefepol        DATE;
         v_fanulac_rie    DATE;
         num_error        NUMBER;
         secuencia        NUMBER;
         v_sagenda        NUMBER;
         v_tatribu        VARCHAR2 (50);
      BEGIN
         ----------
         --INSERT EN GESCARTAS para poder enviar las cartas a los clientes
         ----------
         --Mirem si existeix a RECANUDEVBAN (ALIANZA)
         SELECT COUNT (*)
           INTO c_recanudevban
           FROM recanudevban
          WHERE nrecibo = pnrecibo AND sprocfin IS NULL;

         SELECT fefecto, sseguro, nriesgo                           --CTIPREC,
           INTO v_fefecto, v_sseguro, v_nriesgo                   --v_ctiprec,
           FROM recibos
          WHERE nrecibo = pnrecibo;

         --         DBMS_OUTPUT.put_line ('From RECIBOS');
         SELECT fanulac, sproduc, fefecto                           --NCERTIF,
           INTO v_fanulac_seg, v_sproduc, v_fefepol                --v_certif,
           FROM seguros
          WHERE sseguro = v_sseguro;

         -- 2003-10-21 No se han de enviar cartas de los riesgos anulados
         IF v_nriesgo IS NOT NULL
         THEN
            SELECT fanulac
              INTO v_fanulac_rie
              FROM riesgos g
             WHERE g.sseguro = v_sseguro AND g.nriesgo = v_nriesgo;
         ELSE
            v_fanulac_rie := NULL;
         END IF;

         --Si la p¿lissa est¿ vigent insertem
         IF     f_vigente (v_sseguro, NULL, f_sysdate) != 0
            AND               --> No se env¿a carta para los recibos devueltos
                -- Bug 0039975 - 19/01/2016 - MDS - substituido el >= por >
                v_fefecto > v_fanulac_seg
         THEN
                            --> que tengan efecto posterior a la anulaci¿n.
            --        P_LITERAL(f_vigente(v_sseguro,NULL,F_Sysdate), :GLOBAL.USU_IDIOMA, TEXTO);
            p_proceslin (psproces,
                         pnrecibo || ': Poliza no vigente',
                         v_sseguro
                        );
         ELSIF c_recanudevban > 0
         THEN
            --        P_LITERAL(112617, :GLOBAL.USU_IDIOMA, TEXTO); --Aquesta p¿lissa t¿
            p_proceslin (psproces,
                         pnrecibo || ', c_recanudevban= ' || c_recanudevban,
                         v_sseguro
                        );
         ELSIF v_fanulac_rie IS NOT NULL AND
                                               --> No se env¿a carta para los recibos devueltos
                                            -- Bug 0039975 - 19/01/2016 - MDS - substituido el >= por >
                                            v_fefecto > v_fanulac_rie
         THEN
                            --> que tengan efecto posterior a la anulaci¿n.
            --        P_LITERAL(103192, :GLOBAL.USU_IDIOMA, TEXTO); -- Riesgo anulado
            p_proceslin (psproces,
                         pnrecibo || ', v_fanulac_rie= ' || v_fanulac_rie,
                         v_sseguro
                        );
         ELSE
---------------------
-- CARTAS DE AVISO --
---------------------
            BEGIN
               --message('CARTA: '||reg.nrecibo||', '||pcmodimm||', '||PSCARAGR);
                  --    INSERT INTO cartaavis (NRECIBO, CTIPCAR, FEMICAR, CRETENI, SCARAGR)
                  --    VALUES  (reg.nrecibo,pcmodimm,NULL,0,PSCARAGR);--,pk_dev_distribucio.sdevolu);

               -- Insertem en GESTCARTAS en comptes de en CARTAAVIS
               SELECT sgescarta.NEXTVAL
                 INTO secuencia
                 FROM DUAL;

               INSERT INTO gescartas
                           (sgescarta, ctipcar, sseguro, sperson, cgarant,
                            nrecibo, fsolici, ususol, fimpres, usuimp,
                            cestado, nimpres, cimprimir, scaragr, sdevolu,
                            smovrec
                           )     --Bug 9204-MCC-03/03/2009-Nuevo campo smovrec
                    VALUES (secuencia, pcmodimm, v_sseguro, NULL, NULL,
                            pnrecibo, f_sysdate, f_user, NULL, NULL,
                            1, 0, NULL, pscaragr, psdevolu,
                            psmovrec
                           );    --Bug 9204-MCC-03/03/2009-Nuevo campo smovrec

               ncartes := ncartes + 1;

               IF NVL
                     (pac_parametros.f_parempresa_n
                                           (pac_md_common.f_get_cxtempresa (),
                                            'IMPREC_DEVOLU'
                                           ),
                      0
                     ) = 1
               THEN
                  --Insertamos la carta asociada al recibo fisico, en el caso de que se imprima el recibo.
                  SELECT sgescarta.NEXTVAL
                    INTO secuencia
                    FROM DUAL;

                  INSERT INTO gescartas
                              (sgescarta,
                               ctipcar,
                               sseguro, sperson, cgarant, nrecibo, fsolici,
                               ususol, fimpres, usuimp, cestado, nimpres,
                               cimprimir, scaragr, sdevolu, smovrec
                              )
                       VALUES (secuencia,
                               13 /*carta asociada al recibo por defecto 13 en iAXIS*/,
                               v_sseguro, NULL, NULL, pnrecibo, f_sysdate,
                               f_user, NULL, NULL, 1, 0,
                               NULL, pscaragr, psdevolu, psmovrec
                              );

                  ncartes := ncartes + 1;
               END IF;

-------------------
-- APUNTE AGENDA --
-------------------
               BEGIN
                  SELECT sagenda.NEXTVAL
                    INTO v_sagenda
                    FROM DUAL;

                  num_err := f_desvalorfijo (21, pidioma, 22, v_tatribu);
                  --BUG9208-28052009-XVM
                  -- Bug 22342 - APD - 11/06/2012 - se sustituyen los literales
                  -- por los codigos de literal
                  num_err :=
                     pac_agensegu.f_set_datosapunte
                                                (NULL,
                                                 v_sseguro,
                                                 NULL,
                                                 v_tatribu,
                                                    f_axis_literales (9903790,
                                                                      pidioma
                                                                     )
                                                 || ' '
                                                 || f_sysdate
                                                 || ' '
                                                 || f_axis_literales (9903791,
                                                                      pidioma
                                                                     )
                                                 || ' '
                                                 || pnrecibo,
                                                 22,
                                                 0,
                                                 f_sysdate,
                                                 NULL,
                                                 0,
                                                 0
                                                );
               -- fin Bug 22342 - APD - 11/06/2012
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     --             P_LITERAL(103358, :GLOBAL.USU_IDIOMA, TEXTO);  --> Error al insertar en la tabla AGENSEGU
                     p_proceslin (psproces,
                                     pnrecibo
                                  || ': '
                                  || SQLERRM
                                  || '( Agenda: '
                                  || v_sagenda
                                  || ')',
                                  v_sseguro
                                 );
               END;
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  --         P_LITERAL(107720, :GLOBAL.USU_IDIOMA, TEXTO);
                  p_proceslin (psproces,
                               pnrecibo || ': ' || SQLERRM,
                               v_sseguro
                              );
                  num_error := 107720;
            END;
         END IF;
      END enviar_carta;
   BEGIN
      -- Seq¿¿ncia per agrupar totes les cartes
      SELECT scaragr.NEXTVAL
        INTO pscaragr
        FROM DUAL;

      --      DBMS_OUTPUT.put_line ('entro f_devol_automatico');
      IF pproceso IS NULL
      THEN
         p_procesini (f_user,                        --Usuario de la ejecuci¿n
                      f_parinstalacion_n ('EMPRESADEF'),
                      
                      -- Empresa asociada. Suposem que tots s¿n de la mateixa empresa
                      'F_DEVOL_AUTOMATICO',               -- C¿digo de proceso
                         f_axis_literales (110059, pidioma)
                      || ': '
                      || TO_CHAR (f_sysdate, 'dd-mm-yyyy  HH24:MI')
                      || ' Acciones DESDE: '
                      || xcactimp1
                      || ' HASTA: '
                      || xcactimp2,                       -- Texto del proceso
                      psproces
                     );
      ELSE
         p_proceslin (pproceso,
                         f_axis_literales (110059, pidioma)
                      || ': '
                      || TO_CHAR (f_sysdate, 'dd-mm-yyyy  HH24:MI')
                      || ' Acciones DESDE: '
                      || xcactimp1
                      || ' HASTA: '
                      || xcactimp2,
                      1
                     );
         psproces := pproceso;
      END IF;

      cont_rec := 0;

      FOR reg IN c_impagado
      LOOP                                                  -- ** PRINCIPAL **
         cont_rec := cont_rec + 1;

         -- Dades de la p¿lissa
         BEGIN
            -- Buscamos el tipo de impagado (anualidad)
            BEGIN
               SELECT cdelega, r.cempres, r.fefecto, s.sseguro, s.fefecto
                 INTO xcdelega, xcempres, xfefecto, v_sseguro, v_fefepol
                 FROM recibos r, seguros s
                WHERE nrecibo = reg.nrecibo AND r.sseguro = s.sseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  num_err := 101731;                       --Rebut no trobat.
               WHEN OTHERS
               THEN
                  num_err := 102367;               --Problemes amb els rebuts
            END;

            SELECT cagrpro
              INTO v_pcagrpro
              FROM productos
             WHERE sproduc = (SELECT sproduc
                                FROM seguros
                               WHERE sseguro = v_sseguro);

            -- Dades de l'¿ltim moviment del rebut
            SELECT m.fmovini, m.cestrec
              INTO xfmovini, xcestrec
              FROM movrecibo m
             WHERE m.nrecibo = reg.nrecibo AND m.fmovfin IS NULL;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               num_err := 104939;              --Rebut no trobat a MOVRECIBO.
               xcestrec := 0;
               xfmovini := reg.ffecalt;
            -- Entrem en el tractament per grabar l'error
            WHEN OTHERS
            THEN
               num_err := 104043;             --Problemes al llegir MOVRECIBO
               xcestrec := 0;
               xfmovini := reg.ffecalt;
               p_proceslin (psproces,
                            SUBSTR (   f_axis_literales (104043, pidioma)
                                    || ' '
                                    || SQLERRM,
                                    1,
                                    120
                                   ),
                            reg.sseguro,
                            2
                           );                                   -- Es un error
         -- Entrem en el tractament per grabar l'error
         END;

         --if num_err = 0 then
         -- miramos si se sigue cumpliendo la misma condici¿n que cuando se inserto el
         -- registro
         error := f_difdata (v_fefepol, xfefecto, 1, 1, anys);
         v_ctipoimp := anys + 1;

         IF     (   reg.nimpagad =
                                 f_ndev (reg.nrecibo, reg.ffejecu, v_ctipoimp)
                 OR NVL (reg.nimpagad, 0) = 0
                )                                            --and num_err = 0
            AND xcestrec = 0                 -- BUG 0041051 - FAL - 09/03/2016
         THEN
            --IF     xcestrec = 0                                   -- est¿ pendent
            -- AND TRUNC (xfmovini) =
            --             TRUNC (reg.ffecalt)
            -- es el mateix que es va impagar

            -- per si algun rebut ha estat anulat a mig proc¿s per un altre
            missatge := NULL;
            num_err := 0;
            xterror := NULL;
            xctractat := 3;                          -- Per defecte (3=Error)
            psmovrec := 0;

            BEGIN
               SELECT tatribu
                 INTO accio       -- Busquem l'acci¿ que s'ha fet amb el rebut
                 FROM detvalores
                WHERE catribu = reg.cactimp
                  AND cidioma = pidioma
                  --Bug 9204-MCC-03/03/2009-cambio de valor idioma 1 a parametro
                  AND cvalor = 204;
            EXCEPTION
               WHEN OTHERS
               THEN
                  accio := 'ERROR A DETVALORES:' || SQLERRM;
            END;

            missatge :=
                  f_axis_literales (100895, pidioma)
               || ': '
               || reg.nrecibo
               || ': '
               || accio;
            p_proceslin (psproces, missatge, reg.sseguro, 2);

            IF num_err = 0
            THEN
               -- Bug 22342 - APD - 11/06/2012 - se a¿ade el parametro psdevolu
               realiza_accion (reg.cactimp,
                               reg.nrecibo,
                               reg.ffejecu,
                               reg.sseguro,
                               reg.cmotivo,
                               reg.ffecalt,
                               reg.sdevolu
                              );
            -- fin Bug 22342 - APD - 11/06/2012
            END IF;

            -- Muntar i INSERIR el missatge a PROCESOS
            IF num_err <> 0
            THEN
               ROLLBACK;
               xctractat := 3;        -- Per la taula TMP_IMPAGADOS (3=Error)
               missatge :=
                     'ERROR '
                  || num_err
                  || ' ('
                  || f_axis_literales (num_err, pidioma)
                  || ') EN ACCION: '
                  || reg.cactimp
                  || '. '
                  || missatge
                  || '. '
                  || SQLERRM;
               -- MESSAGE (MISSATGE);PAUSE;
               xterror := xterror || ' # ' || missatge;
               p_proceslin (psproces,
                            SUBSTR (missatge, 1, 120),
                            reg.sseguro,
                            2
                           );                                   -- Es un error
               c_err := c_err + 1;
            ELSE
               -- Guardo la carta si l'acci¿ ha anat b¿ (2)
               BEGIN
                  IF reg.ccarta IS NOT NULL
                  THEN
                     enviar_carta (reg.nrecibo,
                                   reg.ccarta,
                                   reg.sdevolu,
                                   reg.smovrec
                                  );
                  --Bug 9204-MCC-03/03/2009-Nuevo par¿metro psmovrec
                  END IF;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     error := 107720;
               END;

               xctractat := 2;
            END IF;

            -- Si s'ha hagut d'anul¿lar la p¿lissa s'ha d'avisar d'altres rebuts posteriors cobrats.
            IF reg.cactimp = 0
            THEN
               cad_reb := NULL;

               -- 30.  0023864 - 0124752 - Inicio
               SELECT fanulac
                 INTO fanupol
                 FROM seguros
                WHERE sseguro = v_sseguro;

               -- 30.  0023864 - 0124752 - Fin
               FOR re IN (SELECT r.nrecibo
                            FROM movrecibo m, recibos r
                           WHERE m.nrecibo = r.nrecibo
                             AND m.fmovfin IS NULL
                             AND m.cestrec = 1
                             AND r.sseguro = reg.sseguro
                             AND r.fefecto > TRUNC (fanupol))
               LOOP
                  cad_reb := cad_reb || TO_CHAR (re.nrecibo) || ',';
               END LOOP;

               IF cad_reb IS NOT NULL
               THEN
                  missatge :=
                        reg.nrecibo
                     || '. '
                     || f_axis_literales (110063, pidioma)
                     || reg.ffejecu
                     || ' ('
                     || cad_reb
                     || ')';
                  xterror := xterror || ' # ' || missatge;
                  p_proceslin (psproces, missatge, reg.sseguro, 2);
               END IF;
            END IF;

            UPDATE tmp_impagados
               SET ctractat = xctractat,
                   terror = xterror
             WHERE sseguro = reg.sseguro
               AND nrecibo = reg.nrecibo
               AND ffejecu = reg.ffejecu;

            --  Actualitzem tamb¿ els rebuts a la taula de DEVRECIBOS
            UPDATE devbanrecibos
               SET cdevsit = 3                       -- Revisat autom¿ticament
             WHERE nrecibo = reg.nrecibo AND fremesa = reg.ffecalt;

            COMMIT;

            IF xctractat = 2 AND reg.cactimp = 0
            THEN
               -- Bug 22342 - APD - 11/06/2012 - se sustituyen los literales
               -- por los codigos de literal
               UPDATE tmp_impagados
                  SET ctractat = 2,
                      terror =
                            terror
                         || ' '
                         || f_axis_literales (9903792, pidioma)
                         || ' '
                         || reg.nrecibo
                WHERE sseguro = reg.sseguro
                  AND ctractat <> 2
                  AND nrecibo <> reg.nrecibo;
            -- fin Bug 22342 - APD - 11/06/2012
            END IF;

            COMMIT;
------------------------------------------
         ELSE              -- Si ha hagut algun moviment posterior, no fem res
            -- Bug 22342 - APD - 11/06/2012 - se sustituyen los literales
            -- por los codigos de literal
            UPDATE tmp_impagados
               SET ctractat = 2,
                   terror = f_axis_literales (9903793, pidioma)
             --'No se cumplen las mismas condiciones para ejecutar la acci¿n'
            WHERE  sseguro = reg.sseguro
               AND nrecibo = reg.nrecibo
               AND ffejecu = reg.ffejecu;

            -- fin Bug 22342 - APD - 11/06/2012

            -- Actualitzem tamb¿ els rebuts a la taula de DEVRECIBOS
            UPDATE devbanrecibos
               SET cdevsit = 3                       -- Revisat autom¿ticament
             WHERE nrecibo = reg.nrecibo AND fremesa = reg.ffecalt;

            COMMIT;
         END IF;
      -- end if; -- del num_err
      END LOOP;                                             -- ** PRINCIPAL **

      --   IF c_err <> 0 THEN
      --      MESSAGE
      --            ('Finalitzat el proc¿s nocturn amb errors. Visualitzar Processos');
      --      PAUSE;
      --   END IF;
      --      DBMS_OUTPUT.put_line ('proces: ' || psproces || ', n errors =' || c_err);
      -- Grabamos cuanto srecibos se han tratado
      -- p_proceslin(pproceso, f_axis_literales(140391, pidioma) || ': ' || cont_rec, 1); -- 23.  0022738 / 0118685 (-)
      p_proceslin (psproces,
                   f_axis_literales (140391, pidioma) || ': ' || cont_rec,
                   1
                  );                             -- 23.  0022738 / 0118685 (+)

      -- Nom¿s tanquem el nou proc¿s si hem trobat algun rebut
      IF psproces IS NOT NULL
      THEN
         p_procesfin (psproces, c_err);
      END IF;

      COMMIT;
      --      DBMS_OUTPUT.put_line ('RETORNO =' || c_err);
      RETURN c_err;
   --FEINES PENDENTS ( Isaac )
   --Fer algun proc¿s que si troba dues anul¿lacions de p¿lissa que s'han de tractar a la vegada faci el seg¿ent:
   --- Nom¿s anul¿lar els rebuts exepte l'¿ltim el qual anul¿lar¿ la p¿lissa
   --- Si no es fa aix¿ el primer rebut es tracta b¿ per¿ tots els altres donen errors i es fan m¿s
   --extorns del compte.
   END f_devol_automatico;

   FUNCTION f_garan_suspendidas (psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER
   IS
----------------------------------------------------------
--  Funci¿ que indica si tenim o no las garanties suspeses.
--  Estaran suspeses si existeix un rebut impagat amb la carta de suspensi¿,
-- i retornarem un 1
-- Si no est¿ suspes retornarem un 0
----------------------------------------------------------
      vresul   NUMBER := 0;
   BEGIN
      SELECT COUNT (t.nrecibo)
        INTO vresul
        FROM tmp_impagados t, movrecibo m
       WHERE m.cestrec = 0
         AND m.cestant = 1
         AND m.fmovfin IS NULL
         AND m.nrecibo = t.nrecibo
         AND t.sseguro = psseguro
         AND t.ctractat = 2
         AND t.ccarta = 1;                                        -- suspensi¿

      RETURN vresul;
   END f_garan_suspendidas;

   /*************************************************************************
                                                                        Funci¿n que seleccionar¿ informaci¿n sobre los procesos de devoluci¿
        param in pcempres     : codigo empresa
        param in psedevolu    : n¿ proceso de devoluci¿n
        param in pfsoport     : fecha confecci¿n del soporte
        param in pfcarga      : fecha carga del soporte
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_consulta_devol (
      pcempres     IN       NUMBER,
      psdevolu     IN       NUMBER,
      pfsoport     IN       DATE,
      pfcarga      IN       DATE,
      pccobban     IN       NUMBER,                  -- 25.  0022086 / 0117715
      psperson     IN       NUMBER,                  -- 25.  0022086 / 0117715
      ptipo        IN       NUMBER,                  -- 25.  0022086 / 0117715
      pfcargaini   IN       DATE,
      pfcargafin   IN       DATE,
      psquery      OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_devoluciones.f_get_consulta_Devol';
      vparam        VARCHAR2 (500)
         :=    'par¿metros - pcempres : '
            || pcempres
            || ', psdevolu : '
            || psdevolu
            || ', pfsoport : '
            || pfsoport
            || ' ,pfcarga : '
            || pfcarga;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
      param         VARCHAR2 (500);
   BEGIN
      IF psdevolu IS NOT NULL
      THEN
         param := ' and p.sdevolu = NVL(' || psdevolu || ',p.sdevolu)';
      END IF;

      IF pcempres IS NOT NULL
      THEN
         param :=
                param || ' and p.cempres = NVL(' || pcempres || ',p.cempres)';
      END IF;

      IF pfsoport IS NOT NULL
      THEN
         param :=
               param
            || ' and trunc(p.fsoport) = '
            || CHR (39)
            || pfsoport
            || CHR (39);
      END IF;

      IF pfcarga IS NOT NULL
      THEN
         param :=
            param || ' and trunc(p.fcarga) = ' || CHR (39) || pfcarga
            || CHR (39);
      END IF;

      IF pfcargaini IS NOT NULL
      THEN
         param :=
               param
            || ' and trunc(p.fcarga) >= '
            || CHR (39)
            || pfcargaini
            || CHR (39);
      END IF;

      IF pfcargafin IS NOT NULL
      THEN
         param :=
               param
            || ' and trunc(p.fcarga) <= '
            || CHR (39)
            || pfcargafin
            || CHR (39);
      END IF;

      -- 25.  0022086 / 0117715 - Inicio
      IF pccobban IS NOT NULL
      THEN
         param := param || ' and d.ccobban = ' || pccobban;
      END IF;

      IF psperson IS NOT NULL AND ptipo IN (1, 2, 3)
      THEN
         param :=
               param
            || ' and p.sdevolu IN (SELECT x.sdevolu '
            || ' FROM devbanrecibos x, recibos y '
            || ' WHERE x.nrecibo = y.nrecibo ';

         IF ptipo = 1
         THEN
            param :=
                  param
               || ' and y.sseguro IN (select t.sseguro from tomadores t where t.sperson = '
               || psperson
               || ')';
         END IF;

         IF ptipo = 2
         THEN
            param :=
                  param
               || ' and x.nrecibo in
            (select d.nrecibo
               from detrecibos d, riesgos ri
              where d.nrecibo = y.nrecibo
                and d.nriesgo = ri.nriesgo
                and ri.sseguro= y.sseguro
                and ri.sperson = '
               || psperson
               || ')';
         END IF;

         IF ptipo = 3
         THEN
            param :=
                  param
               || ' and y.nrecibo IN (select r.nrecibo from tomadores t, recibos r '
               || ' where r.sseguro = t.sseguro '
               || '   and ((r.sperson is not null and r.sperson = '
               || psperson
               || ') '
               || ' or (r.sperson is null and t.sperson = '
               || psperson
               || ')))';
         END IF;

         param := param || ') ';
      END IF;

      -- 25.  0022086 / 0117715 - Fin
      param := param || ' order by 1';
      psquery :=
            'SELECT distinct p.sdevolu, e.tempres, p.tprenom,
         p.cdoment||decode(o.tbanco,null,null,''-''||o.tbanco) cdoment,
       p.cdomsuc||decode(o.toficin,null,null,''- ''||o.toficin) cdomsuc, p.fsoport, p.fcarga, p.cusuari,
       (select c.tcobban from cobbancario c where c.ccobban = d.ccobban) tcobban
    FROM devbanpresentadores p, devbanordenantes d, empresas e, oficinas o
   WHERE p.sdevolu = d.sdevolu
     AND p.cempres = e.cempres
     AND p.cdoment = o.cbanco(+)
     AND p.cdomsuc = o.coficin(+) '
         || param;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001648;
   END f_get_consulta_devol;

   /*************************************************************************
                    Funci¿n que se encargar¿ de recuperar la informaci¿n de un procseo de
        devoluci¿n.
        param in psedevolu    : n¿ proceso de devoluci¿n
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_datos_devolucion (psdevolu IN NUMBER, psquery OUT VARCHAR2)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                 := 'PAC_devoluciones.f_get_Datos_devolucion';
      vparam        VARCHAR2 (500)  := 'par¿metros - psdevolu :' || psdevolu;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vsquery       VARCHAR2 (4000);
   BEGIN
      psquery :=
            'SELECT distinct e.tempres, p.sdevolu, p.tprenom, p.fsoport, p.cdoment cdoment,
          decode(b.tbanco,null,to_char(p.cdoment),b.tbanco) tdoment,
               p.cdomsuc cdomsuc,
         decode(o.toficin,null,to_char(p.cdomsuc),o.toficin) tdomsuc, p.fcarga, p.cusuari
            FROM devbanpresentadores p, empresas e, oficinas o, bancos b
           WHERE p.cempres = e.cempres
             AND p.cdoment = o.cbanco(+)
             AND p.cdomsuc = o.coficin(+)
             and p.cdoment = b.cbanco(+)
             and p.sdevolu = '
         || psdevolu;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001650;
   END f_get_datos_devolucion;

   /*************************************************************************
              Funci¿n que se encargar¿ de devolver los recibos de una devoluci¿n
        param in psedevolu     : n¿ proceso de devoluci¿n
        param in pidioma
        param out psquery
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_datos_recibos_devol (
      psdevolu   IN       NUMBER,
      pidioma    IN       NUMBER,
      psquery    OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                              := 'PAC_devoluciones.f_get_datos_recibos_devol';
      vparam        VARCHAR2 (500) := 'par¿metros - psdevolu : ' || psdevolu;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
   BEGIN
      psquery :=
            'SELECT DISTINCT r.nrecibo, ff_desvalorfijo(73, '
         || pidioma
         || ', r.cdevmot) tdevmot, r.nrecccc, r.sdevolu,
                r.ccobban || '' - '' || c.descripcion || ''
         - '' || c.tcobban tcobban,
                c.ncuenta ccobban, r.irecdev, ff_desvalorfijo(87, '
         || pidioma
         || ', r.cdevsit) tdevsit,
                r.cdevsit,
                re.cagente, f_desagente_t(re.cagente) tagente,
                pac_redcomercial.f_busca_padre(re.cempres, re.cagente, null,
                                               re.fefecto)
                || ''
         - ''
                || f_desagente_t(pac_redcomercial.f_busca_padre(re.cempres,
                                                                re.cagente, null,
                                                                re.fefecto)) tsucursal,
                DECODE
                      (pac_iaxpar_productos.f_get_parproducto(''ADMITE_CERTIFICADOS'', s.sproduc),
                       0, TO_CHAR(s.npoliza),
                       TO_CHAR(s.npoliza) || ''
         - '' || s.ncertif) npoliza,
                re.nfracci, dc.cremban, rc.caccpre,
                ff_desvalorfijo(800086, '
         || pidioma
         || ', rc.caccpre) taccpre, rc.caccret,
                ff_desvalorfijo(800089, '
         || pidioma
         || ', rc.caccret) taccret,
                DECODE(NVL((SELECT cestado
                              FROM gescartas g
                             WHERE g.sdevolu = r.sdevolu
                               AND g.nrecibo = r.nrecibo
                               AND g.ctipcar = 13),
                           0),
                       3, 1,
                       0) no_imp, m.cestant cestant,
                ff_desvalorfijo(1, '
         || pidioma
         || ', m.cestant) testrec,
                dc.fefecto fremesa,
                f_desproducto_t(s.cramo, s.cmodali, s.ctipseg, s.ccolect, 1,
                                s.cidioma) tproducto,
                ra.tramo, pac_devolu.f_numdias_periodo_gracia(s.sseguro) ndiagra,'
         || ' ff_desvalorfijo(383,'
         || pidioma
         || ', f_cestrec(r.nrecibo, f_sysdate)) testimp, '
         -- Bug 31930-Errores en la carta de impago (AGM) - 17-VII-2014 - dlF
         || ' (select ti.nimpagad from tmp_impagados ti where ti.sdevolu = r.sdevolu and ti.nrecibo = r.nrecibo and ffejecu = (SELECT MAX( ffejecu) FROM tmp_impagados t WHERE t.sdevolu = ti.sdevolu AND t.nrecibo = ti.nrecibo) and ROWNUM =1 ) nimpagad, '
         -- end 31930-Errores en la carta de impago (AGM) - 17-VII-2014 - dlF
         || ' (SELECT x.fdebito FROM domiciliaciones x WHERE x.sproces = dc.sproces AND x.nrecibo = r.nrecibo AND CDOMEST = 0) frecaudo, '
         || ' (SELECT x.fdebito FROM domiciliaciones x WHERE x.sproces = dc.sproces AND x.nrecibo = r.nrecibo AND CDOMEST = 1) frechazo, '
         || ' dc.sproces, '
         || ' pac_devolu.f_fecha_periodo_gracia(0, re.nrecibo) fconvenio '
         || ' FROM devbanrecibos r, cobbancario c, recibos re, seguros s, domiciliaciones_cab dc,
                recibos_comp rc, ramos ra, movrecibo m
          WHERE r.ccobban = c.ccobban
            AND re.nrecibo = r.nrecibo
            AND re.sseguro = s.sseguro
            AND dc.sdevolu(+) = r.sdevolu
            AND rc.nrecibo(+) = r.nrecibo
            AND ra.cramo = s.cramo
            AND m.nrecibo = r.nrecibo
            AND m.fmovfin is null
            AND ra.cidioma = '
         || pidioma
         || ' AND r.sdevolu ='
         || psdevolu;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001651;
   END f_get_datos_recibos_devol;

   /*************************************************************************
                     Funci¿n que actualiza el estado de un proceso de recibos devuelto
         pnrecibo IN NUMBER,
         psdevolu IN NUMBER,
         pcdevsit IN NUMBER
         return                : NUMBER 0 / error
      *************************************************************************/
   FUNCTION f_set_rec_revis (
      pnrecibo   IN   NUMBER,
      psdevolu   IN   NUMBER,
      pcdevsit   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_devoluciones.f_set_Rec_Revis';
      vparam        VARCHAR2 (500)
         :=    'par¿metros - pnrecibo :'
            || pnrecibo
            || ',psdevolu : '
            || psdevolu
            || ', pcdevsit : '
            || pcdevsit;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
   BEGIN
      --Comprovaci¿ dels par¿metres d'entrada
      IF pnrecibo IS NULL OR psdevolu IS NULL
      THEN
         RETURN 9000505;
      END IF;

      UPDATE devbanrecibos
         SET cdevsit = pcdevsit
       WHERE nrecibo = pnrecibo AND sdevolu = psdevolu;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001652;
   END f_set_rec_revis;

   /*************************************************************************
                    Funci¿n que se encargar¿ gde generar el listado de recibos devueltos para un proceso
        de devoluci¿n en concreto
        param in psedevolu     : n¿ proceso de devoluci¿n
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_listado_devol (
      psdevolu      IN       NUMBER,
      pidioma       IN       NUMBER,
      pnomfichero   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'PAC_devoluciones.f_get_listado_devol';
      vparam        VARCHAR2 (500)
         := 'par¿metros - psdevolu : ' || psdevolu || ' , idioma : '
            || pidioma;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      vsmapead      NUMBER;
      vtparpath     VARCHAR2 (1000);
      vpath         VARCHAR2 (1000);
      vfichero      VARCHAR2 (1000);
   BEGIN
      SELECT tdesmap, tparpath || '_C'
        INTO vfichero, vtparpath
        FROM map_cabecera
       WHERE cmapead = '329';

      vpath := f_parinstalacion_t (vtparpath);
      pac_map.p_genera_parametros_fichero ('329',
                                           psdevolu || '|' || pidioma,
                                           vfichero,
                                           0
                                          );
      vnumerr := pac_map.genera_map ('329', vsmapead);
      pnomfichero := vpath || '\' || vfichero;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001653;
   END f_get_listado_devol;

   /*************************************************************************
              Funci¿n que se encargar¿ gde generar las cartas de devoluciones de recibos de un proceso de devoluci¿n
        de devoluci¿n en concreto
        param in psedevolu     : n¿ proceso de devoluci¿n
        param pidioma IN NUMBER
        return                : NUMBER 0 / error
     *************************************************************************/
   FUNCTION f_get_cartas_devol (
      psdevolu      IN       NUMBER,
      pidioma       IN       NUMBER,
      pplantilla    OUT      NUMBER,
      pnomfichero   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'PAC_devoluciones.f_get_cartas_devol';
      vparam        VARCHAR2 (500)
         := 'par¿metros - psdevolu : ' || psdevolu || ' pidioma: ' || pidioma;
      vpasexec      NUMBER (5)      := 1;
      vsmapead      NUMBER;
      vnumerr       NUMBER          := 0;
      vtparpath     VARCHAR2 (1000);
      vpath         VARCHAR2 (1000);
      vfichero      VARCHAR2 (1000);

      CURSOR c1
      IS
         SELECT DISTINCT gc.sdevolu, tc.cmapead
                    FROM gescartas gc, tiposcarta tc
                   WHERE gc.sdevolu = psdevolu
                     AND gc.ctipcar = tc.ctipcar
                     AND tc.cmapead IS NOT NULL;
   BEGIN
      -- Bug 0022030 - 23/04/2012 - JMF
      SELECT DECODE (COUNT (1), 0, 0, 1)
        INTO pplantilla
        FROM gescartas gc, tiposcarta tc
       WHERE gc.sdevolu = psdevolu
         AND gc.ctipcar = tc.ctipcar
         AND tc.ccodplan IS NOT NULL;

      FOR f1 IN c1
      LOOP
         SELECT tdesmap, tparpath
           INTO vfichero, vtparpath
           FROM map_cabecera
          WHERE cmapead = f1.cmapead;

         vpath := f_parinstalacion_t (vtparpath);
         pac_map.p_carga_parametros_fichero (f1.cmapead,
                                             psdevolu || '|' || pidioma || '|',
                                             vfichero,
                                             0
                                            );
         vnumerr := pac_map.carga_map (f1.cmapead, vsmapead);

         IF vnumerr <> 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         vobjectname,
                         vpasexec,
                         psdevolu || '|' || pidioma,
                         'cmapead=' || f1.cmapead || ' vnumerr=' || vnumerr
                        );
         END IF;

         pnomfichero := vpath || '\' || vfichero;
      END LOOP;

      IF pplantilla IS NULL AND vfichero IS NULL
      THEN
         RETURN 500031;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001654;
   END f_get_cartas_devol;

   /*************************************************************************
                    Funci¿n que se encargar¿ de cargar los recibos especificados en el fichero de devoluciones informado por param.
        de devoluci¿n en concreto
        param in pnomfitxer   : nombre del fichero de devoluci¿n
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_get_carga_fichero (
      pcempres     IN       NUMBER,
      pnomfitxer   IN       VARCHAR2,
      pidioma      IN       NUMBER,
      psproces     OUT      NUMBER,
      p_fich_out   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_devoluciones.f_get_carga_fichero';
      vparam        VARCHAR2 (500)
         :=    'par¿metros - pnomfitxer : '
            || pnomfitxer
            || ' pidioma'
            || pidioma
            || '  psproces'
            || psproces;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
      smapead       NUMBER;
   BEGIN
      vnumerr :=
         f_procesini (f_user,
                      pcempres,
                      'pac_devolu',
                         'Inici C¿rrega Fitxer Devolucions : '
                      || TO_CHAR (f_sysdate, 'MM-DD-YYYY HH:MI'),
                      psproces
                     );

      IF vnumerr = 0
      THEN
         vnumerr :=
              pac_devolu.f_carga_fichero_devo (pnomfitxer, pidioma, psproces);

         IF vnumerr = 0
         THEN
            vnumerr :=
                     pac_devolu.f_devol_automatico (2, 10, pidioma, psproces);
            -- Bug 22342 - APD - 28/06/2012 - se modifica la llamada del map
            -- ya que se quiere recuperar la ruta y nombre del map generado
            -- para poder devolverlo y mostrarlo por pantalla
            /*
                                    pac_map.p_genera_parametros_fichero('328', psproces || '|' || pidioma, NULL, 0);
            vnumerr := pac_map.genera_map('328', smapead);
            */
            vnumerr :=
               pac_map.f_extraccion ('328',
                                     psproces || '|' || pidioma || '|'
                                     || vsdevolu,
                                     NULL,
                                     p_fich_out
                                    );
         -- fin Bug 22342 - APD - 28/06/2012
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001655;
   END f_get_carga_fichero;

   /*************************************************************************
                          Funci¿n que realizar¿ las devoluciones de los recibos especificados en el fichero y cargados en las
        tablas de devoluci¿n de recibos al hacer la carga previa del fichero.
        de devoluci¿n en concreto
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1
     *************************************************************************/
   FUNCTION f_exec_devolu (pidioma IN NUMBER)
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_devoluciones.f_exec_devolu';
      vparam        VARCHAR2 (500) := 'par¿metros - ';
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
      psproces      NUMBER;
      smapead       NUMBER;
   BEGIN
      vnumerr :=
         f_procesini (f_user,
                      f_parinstalacion_n ('EMPRESADEF'),
                      'F_DEVOL_AUTOMATICO',
                         f_axis_literales (110059, pidioma)
                      || ':'
                      || TO_CHAR (f_sysdate, 'MM-DD-YYYY HH:MI'),
                      psproces
                     );

      IF vnumerr = 0
      THEN
         vnumerr := pac_devolu.f_devol_automatico (0, 0, pidioma, psproces);

         IF vnumerr = 0
         THEN
            vnumerr :=
                     pac_devolu.f_devol_automatico (1, 10, pidioma, psproces);

            IF psproces IS NOT NULL
            THEN
               pac_map.p_genera_parametros_fichero ('328',
                                                       psproces
                                                    || '|'
                                                    || pidioma
                                                    || '|',
                                                    NULL,
                                                    0
                                                   );
               vnumerr := pac_map.genera_map ('328', smapead);
            END IF;
         END IF;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001656;
   END f_exec_devolu;

   /*************************************************************************
                Funci¿n que seleccionar¿ informaci¿n sobre las cartas de devoluci¿n
          param in psgescarta     : Id. carta
          param in pnpoliza     : n¿ poliza
          param in pnrecibo     : n¿ recibo
          param in pcestimp     : estado de impresi¿n de carta
          param in pfini        : fecha inicio solicitud impresi¿n
          param in pffin        : fecha fin solicitud impresi¿n
          param in pidioma      : codigo del idioma
          param in pcempres      : codigo de la empresa
          param in pcramo      : codigo del ramo
          param in psproduc      : codigo del producto
          param in pcagente      : codigo del agente
          param in pcremban      : N¿mero de remesa interna de la entidad bancaria
          param out vsquery
          return                : NUMBER 0 / error
       *************************************************************************/
   -- Bug 22342 - APD - 11/06/2012 - se a¿aden los parametros pcempres, pcramo,
   -- psproduc, pcagente, pcremban
   FUNCTION f_get_consulta_cartas (
      psgescarta   IN       NUMBER,
      pnpoliza     IN       NUMBER,
      pnrecibo     IN       NUMBER,
      pcestimp     IN       NUMBER,
      pfini        IN       DATE,
      pffin        IN       DATE,
      pidioma      IN       NUMBER,
      pcempres     IN       NUMBER,
      pcramo       IN       NUMBER,
      psproduc     IN       NUMBER,
      pcagente     IN       NUMBER,
      pcremban     IN       NUMBER,
      psquery      OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)
                                  := 'PAC_devoluciones.f_get_Consulta_Cartas';
      vparam        VARCHAR2 (500)
         :=    'par¿metros - psgescarta : '
            || psgescarta
            || ', pnpoliza : '
            || pnpoliza
            || ', pnrecibo : '
            || pnrecibo
            || ' ,pcestimp : '
            || pcestimp
            || ' ,pfini : '
            || pfini
            || ', pffin'
            || pffin;
      vpasexec      NUMBER (5)      := 1;
      vnumerr       NUMBER (8)      := 0;
      v_index       NUMBER;
      param         VARCHAR2 (2000);
   BEGIN
      IF psgescarta IS NOT NULL
      THEN
         param :=
            ' and
      G.sgescarta = NVL(' || psgescarta || ', G.sgescarta)';
      END IF;

      IF pnpoliza IS NOT NULL
      THEN
         param :=
               param
            || ' and
      S.npoliza = NVL('
            || pnpoliza
            || ', S.npoliza)';
      END IF;

      IF pnrecibo IS NOT NULL
      THEN
         param :=
               param
            || ' and
      G.nrecibo = NVL('
            || pnrecibo
            || ', G.nrecibo)';
      END IF;

      IF pcestimp IS NOT NULL
      THEN
         param :=
               param
            || '  and
      G.cestado = NVL('
            || pcestimp
            || ', G.cestado)';
      END IF;

      IF pfini IS NOT NULL
      THEN
         param :=
               param
            || ' and trunc(G.fsolici) between '
            || CHR (39)
            || pfini
            || CHR (39);

         IF pffin IS NULL
         THEN
            param := param || ' and ' || CHR (39) || f_sysdate || CHR (39);
         END IF;
      END IF;

      IF pffin IS NOT NULL AND pffin IS NOT NULL
      THEN
         param := param || ' and ' || CHR (39) || pffin || CHR (39);
      END IF;

      -- Bug 22342 - APD - 11/06/2012
      IF pcempres IS NOT NULL
      THEN
         param :=
               param
            || '  and
      s.cempres = NVL('
            || pcempres
            || ', s.cempres)';
      END IF;

      -- Bug 22342 - APD - 11/06/2012
      IF pcramo IS NOT NULL
      THEN
         param :=
             param || '  and
      s.cramo = NVL(' || pcramo || ', s.cramo)';
      END IF;

      -- Bug 22342 - APD - 11/06/2012
      IF psproduc IS NOT NULL
      THEN
         param :=
               param
            || '  and
      s.sproduc = NVL('
            || psproduc
            || ', s.sproduc)';
      END IF;

         -- Bug 22342 - APD - 11/06/2012
      /*   IF pcagente IS NOT NULL THEN
            param := param || '  and
         r.cagente = NVL(' || pcagente || ', r.cagente)';
         END IF;*/
         --Bug 35609/207694 KJSC 16/06/2015
      IF pcagente IS NOT NULL
      THEN
         param :=
               param
            || '  and
      exists (SELECT 1
                FROM agentes a1
               WHERE r.cagente=a1.cagente
                 AND pac_agentes.f_es_descendiente(r.cempres,NVL('
            || pcagente
            || ', r.cagente),a1.cagente) = 1)';
      END IF;

      -- Bug 22342 - APD - 11/06/2012
      IF pcremban IS NOT NULL
      THEN
         param := param || '  and
      dc.cremban(+)= ' || pcremban;
      END IF;

      -- Bug 0022030 - 23/04/2012 - JMF
      -- Bug 22342 - APD - 11/06/2012 - se a¿ade en la SELECT los campos
      -- dc.cremban, r.cagente, s.sproduc, s.cramo
      -- se a¿ade en el FROM las tablas domiciliaciones_cab y recibos
      psquery :=
            'SELECT G.sgescarta, d.ttipcar, S.npoliza,
                 G.nrecibo, G.fsolici, G.ususol, G.fimpres, G.usuimp, g.sdevolu,
                 ff_desvalorfijo(904,'
         || pidioma
         || ',G.cestado) testimp, g.cestado cestimp, dc.cremban, r.cagente, f_desagente_t(r.cagente) tagente, s.sproduc, s.cramo
            FROM gescartas G, seguros S, tiposcarta T, destiposcarta d, domiciliaciones_cab dc, recibos r
           WHERE G.sseguro = S.sseguro and
                 G.ctipcar = T.ctipcar
             and t.ctipcar = d.ctipcar
             and d.cidioma =  '
         || pidioma
         || ' and dc.sdevolu(+) = g.sdevolu
             and r.nrecibo = g.nrecibo '
         || param;
      -- fin Bug 22342 - APD - 11/06/2012
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001657;
   END f_get_consulta_cartas;

   /*************************************************************************
                      Funci¿n que modificar¿ el estado de impresi¿n de una carta
          param in psgescarta     : Id. carta
          param in pcestimp     : estado de impresi¿n de carta
          param out mensajes    : mensajes de error
          return                : NUMBER 0 / 1
       *************************************************************************/
   FUNCTION f_set_estimp_carta (
      psdevolu   IN   NUMBER,
      pnrecibo   IN   NUMBER,
      pcestimp   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500) := 'PAC_devoluciones.f_set_estimp_carta';
      vparam        VARCHAR2 (500)
         :=    'par¿metros - psgescarta : '
            || psdevolu
            || ' ,pcestimp : '
            || pcestimp;
      vpasexec      NUMBER (5)     := 1;
      vnumerr       NUMBER (8)     := 0;
      v_index       NUMBER;
   BEGIN
      UPDATE gescartas
         SET cestado = pcestimp
       WHERE nrecibo = pnrecibo AND sdevolu = psdevolu AND ctipcar = 13;

      --Carta del recibo por defecto de iaxis;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'error no controlat',
                      SQLERRM
                     );
         RETURN 9001658;
   END f_set_estimp_carta;

   --Ini Bug.: 16383 - ICV - 17/11/2010
   /*************************************************************************
                Funci¿n que crear¿ el recibo por recargo de impago
          param in pnrecibo     : N¿ Recibo
          return                : NUMBER 0 / error
       *************************************************************************/
   FUNCTION f_set_recargoimpago (
      pnrecibo   IN   NUMBER,
      pfecha     IN   DATE,
      pccobban   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobjectname   VARCHAR2 (500)  := 'PAC_devoluciones.f_set_recargoimpago';
      vparam        VARCHAR2 (500)  := 'par¿metros - pnrecibo : ' || pnrecibo;
      vpasexec      NUMBER (5)              := 1;
      vnumerr       NUMBER (8)              := 0;
      v_index       NUMBER;
      param         VARCHAR2 (2000);
      /*CURSOR c1 IS
               SELECT cconcep, cgarant, nriesgo, iconcep
           FROM detrecibos
          WHERE nrecibo = pnrecibo
            AND cconcep = 0;*/
      v_imprec      NUMBER;
      v_precimp     NUMBER;
      num_err       NUMBER                  := 0;
      vsseguro      recibos.sseguro%TYPE;
      vcagente      recibos.cagente%TYPE;
      vctiprec      recibos.ctiprec%TYPE;
      vnanuali      recibos.nanuali%TYPE;
      vnriesgo      recibos.nriesgo%TYPE;
      vnmovimi      recibos.nmovimi%TYPE;
      vfemisio      DATE;
      vfefecto      DATE;
      vfvencim      DATE;
      v_nrecibo     recibos.nrecibo%TYPE;
      v_cgarant     garanseg.cgarant%TYPE;
      v_cempres     NUMBER;
   BEGIN
      --Buscamos el porcentaje de recargo
      BEGIN
         SELECT c.precimp
           INTO v_precimp
           FROM cobbancario c
          WHERE c.ccobban = pccobban;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_precimp := NULL;
      END;

      IF v_precimp IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'No se ha encontrado el recargo ' || vparam,
                      SQLERRM
                     );
         RETURN 9901652;
      END IF;

      SELECT r.sseguro, r.cagente, r.ctiprec, r.nanuali, r.nriesgo,
             r.nmovimi, r.fefecto, r.fvencim, r.cempres
        INTO vsseguro, vcagente, vctiprec, vnanuali, vnriesgo,
             vnmovimi, vfefecto, vfvencim, v_cempres
        FROM recibos r
       WHERE r.nrecibo = pnrecibo;

      vfemisio := TRUNC (f_sysdate);
      --Creamos la cabecera del recibo de recargo
      num_err :=
         f_insrecibo (vsseguro,
                      vcagente,
                      vfemisio,
                      vfefecto,
                      vfvencim,
                      vctiprec,
                      vnanuali,
                      NULL,
                      pccobban,
                      6,
                      vnriesgo,
                      v_nrecibo,
                      'R',
                      NULL,
                      NULL,
                      vnmovimi,
                      TRUNC (f_sysdate),
                      'RECIMPAGO'
                     );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      --El recargo se aplica a la imn garant¿a y al primer riesgo
      SELECT MIN (cgarant)
        INTO v_cgarant
        FROM detrecibos
       WHERE nrecibo = pnrecibo;

      --FOR rc IN c1 LOOP
      INSERT INTO detrecibos
                  (nrecibo, cconcep, cgarant, nriesgo, iconcep, nmovima
                  )
           VALUES (v_nrecibo, 8, v_cgarant, 1, v_precimp, 1
                  );

      --  ROUND(((rc.iconcep * v_precimp) /100), 2), 1);
      --END LOOP;
      num_err := f_vdetrecibos ('R', v_nrecibo);

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      --Se env¿a la emisi¿n del recibo a la ERP
      --Bug.: 20923 - 14/01/2012 - ICV
      IF     NVL (pac_parametros.f_parempresa_n (v_cempres, 'GESTIONA_COBPAG'),
                  0
                 ) = 1
         AND num_err = 0
      THEN
         num_err :=
            pac_ctrl_env_recibos.f_proc_recpag_mov (v_cempres,
                                                    vsseguro,
                                                    vnmovimi,
                                                    4,
                                                    NULL
                                                   );
         num_err := 0;                          --No marcamos error de momento
      /*--Si ha dado error
                                                  --De momento comentado
       IF num_err != 0 THEN
          RAISE accion_error;
       END IF;*/
      END IF;

      --Insertamos en las tablas de recibo unificado
      INSERT INTO adm_recunif
                  (nrecibo, nrecunif
                  )
           VALUES (v_nrecibo, pnrecibo
                  );

      RETURN num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vpasexec,
                      'Error no controlat. Vparam.: ' || vparam,
                      SQLERRM
                     );
         RETURN 103847;
   END f_set_recargoimpago;

   --Fin Bug.

   -- 17. 0022268: LCOL_A001-Revision circuito domiciliaciones - Inicio

   /*************************************************************************
                Funci¿n que devuelve la fecha final del periodo de gracia de un recibo
          param in p_sseguro    : N¿ Seguro
          return                : NUMBER
       *************************************************************************/
   FUNCTION f_numdias_periodo_gracia (p_sseguro IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec           NUMBER := 0;
      v_periodo_gracia   NUMBER;
   BEGIN
      v_periodo_gracia := 0;
      -- Primero miramos si esta a nivel de p¿liza
      vpasexec := 1;

      BEGIN
         SELECT NVL (MAX (crespue), 0)
           INTO v_periodo_gracia
           FROM pregunpolseg a
          WHERE sseguro = p_sseguro
            AND cpregun = 9015
            AND nmovimi =
                    (SELECT MAX (nmovimi)
                       FROM pregunpolseg a1
                      WHERE a1.sseguro = a.sseguro AND a1.cpregun = a.cpregun);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_periodo_gracia := 0;
      END;

      vpasexec := 2;

      -- 44.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio
      -- Miramos si est¿ definido por agente/producto que tenga definido el seguro.
      -- Agarraremos el registro que est¿ vigente en el momento actual, seg¿n el f_sysdate
      IF v_periodo_gracia = 0
      THEN
         vpasexec := 3;

         BEGIN
            SELECT ndias_gracia
              INTO v_periodo_gracia
              FROM agentes_convenio_prod a, seguros s
             WHERE a.cagente = s.cagente
               AND a.sproduc = s.sproduc
               AND s.sseguro = p_sseguro
               --AND fmovfin IS NULL;
               AND a.fmovini =
                      (SELECT MIN (fmovini)
                         FROM agentes_convenio_prod b
                        WHERE TRUNC (f_sysdate) >= fmovini
                          AND (TRUNC (f_sysdate) < fmovfin OR fmovfin IS NULL
                              )
                          AND a.cagente = b.cagente
                          AND a.sproduc = b.sproduc)
               AND ROWNUM <= 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_periodo_gracia := 0;
         END;
      END IF;

      -- 44.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Fin
      vpasexec := 4;

      IF v_periodo_gracia = 0
      THEN
         -- miramos si esta a nivel de producto
         vpasexec := 3;

         BEGIN
            SELECT NVL (MAX (a.cvalpar), 0)
              INTO v_periodo_gracia
              FROM parproductos a
             WHERE a.cparpro = 'DIAS_CONVENIO_RNODOM'
               AND a.sproduc = (SELECT sproduc
                                  FROM seguros
                                 WHERE sseguro = p_sseguro);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_periodo_gracia := 0;
         END;
      END IF;

      vpasexec := 5;
      RETURN v_periodo_gracia;
   END f_numdias_periodo_gracia;

   /*************************************************************************
          Funci¿n que devuelve la fecha final del periodo de gracia de un recibo
          param in psproces     : N¿ de proceso
          param in pnrecibo     : N¿ Recibo
          return                : DATE
       *************************************************************************/
   FUNCTION f_fecha_periodo_gracia (psproces IN NUMBER, pnrecibo IN NUMBER)
      RETURN DATE
   IS
      vperiodogracia   NUMBER;
      v_ntraza         NUMBER;
      vsproduc         seguros.sproduc%TYPE;
      vfgreat          DATE;
      v_tobjeto        VARCHAR2 (100)
                               := 'PAC_RECAUDOS_LCOL.f_fecha_perdiodo_gracia';
      v_tparam         VARCHAR2 (1000)
                       := 'psproces=' || psproces || ' pnrecibo=' || pnrecibo;
   BEGIN
      v_ntraza := 10;

      --43.  0029175: POSND100-POSADM - D?as de Gracia - 169601 - Inicio
      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'PERIODOGRACIA_EFECTO'
                                            ),
              0
             ) = 1
      THEN
         SELECT r.fefecto + pac_devolu.f_numdias_periodo_gracia (r.sseguro)
           INTO vfgreat
           FROM recibos r
          WHERE r.nrecibo = pnrecibo;
      ELSE
         --43.  0029175: POSND100-POSADM - D?as de Gracia - 169601 - Final
         SELECT   GREATEST (r.fefecto, r.femisio)
                + pac_devolu.f_numdias_periodo_gracia (r.sseguro)
           INTO vfgreat
           FROM recibos r
          WHERE r.nrecibo = pnrecibo;
      --43.  0029175: POSND100-POSADM - D?as de Gracia - 169601 - Inicio
      END IF;

      vfgreat := TRUNC (vfgreat);
      --43.  0029175: POSND100-POSADM - D?as de Gracia - 169601 - Final
      v_ntraza := 20;
      RETURN vfgreat;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             v_tobjeto,
             v_ntraza,
                v_tparam
             || ': Error Calculando GREATEST(r.fefecto, r.femisio)--> recibo='
             || pnrecibo,
             SQLERRM
            );
         RETURN vfgreat;
   END f_fecha_periodo_gracia;
-- 17. 0022268: LCOL_A001-Revision circuito domiciliaciones - Fin
END pac_devolu;
/