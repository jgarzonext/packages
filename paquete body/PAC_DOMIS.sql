--------------------------------------------------------
--  DDL for Package Body PAC_DOMIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_DOMIS" 
IS
/******************************************************************************
   NOMBRE:       PAC_DOMIS
   PROPÓSITO:
   REVISIONES:

   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
    1.0       -            -               1. Creación de package
    2.0       06/03/2009   RSC             2. Adaptación iAxis a productos colectivos con certificados
    3.0       09/03/2009   RSC             3. CRE: Unificación de recibos
    3.1       27/03/2009   APD             4. Bug 9446 (precisiones var numericas)
    3.2       02/08/2009   ASN             5. BUG 10838 - Acceso a mensarecibos en fichero IBAN
    4.0       13/11/2009   APD             6. BUG 11835: El proceso de domiciliaciones anula recibos
    5.0       02/02/2010   ICV             7. 0012858: CRE200 - Domiciliaciones de recibos con más de un cobrador bancario
    6.0       04/03/2010   JGR             8. 13498: CRE200 - Domiciliaciones - Fecha valor se ha de informar con la fecha de cobro
    7.0       18/03/2010   FAL             9. 0013153: CEM - Nombres de ficheros generados por AXIS
    8.0       25/05/2010   JMC            10. 0014574: Se elimina p_tab_error de f_creafitxer
    9.0       08/07/2010   FAL            11. 0015325: AGA - Renombrado final de los ficheros de domiciliaciones
    10.0      14/07/2010   ETM            12. 0015376: AGA - Ficheros de domiciliaciones no se cargan
    11.0      27/08/2010   FAL            13. 0015750: CRE998 - Modificacions mòdul domiciliacions
    12.0      17/11/2010   ICV            14. 0016383: AGA003 - recargo por devolución de recibo (renegociación de recibos)
    13.0      27/01/2011   ICV            15. 0017422: AGA800: Domiciliacions , manca informació en el fitxer
    14.0      19/07/2011   JMP            16. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
    15.0      04/11/2011   APD            17. 0019986: LCOL_A001-Referencias agrupadas o consecutivas
    16.0      07/11/2011   APD            18. 0019999: LCOL_A001-Domis - Generacion de los diferentes formatos de fichero
    17.0      14/11/2011   JMF            19. 0019999: LCOL_A001-Domis - Generacion de los diferentes formatos de fichero
    18.0      14/11/2011   FAL            20. 0019627: GIP102 - Reunificación de recibos
    19.0      18/11/2011   APD            21. 0018946: LCOL_P001 - PER - Visibilidad en personas
    20.0      25/11/2011   JGR            22. 0020037: Parametrización de Devoluciones
    21.0      29/12/2011   JGR            23. 0020735: Introduccion de cuenta bancaria, indicando tipo de cuenta y banco Nota:102170
    22.0      27/01/2011   APD            24. 0021116: LCOL_A001-Controlar domiciliaciones y prenotificaciones por cobrador bancario
    23.0      13/02/2012   MDS            25. 0021318: LCOL897-LCOL_A001-A?adir nuevos campos en el previo de domiciliaciones
    24.0      27/02/2012   JMF/MDS        26. 0021480: LCOL898-Temar pendientes de DOMICILIACIONES
    25.0      08/03/2012   JGR            27. 0021120: LCOL897-LCOL_A001-Resumen y detalle de las...Nota: 0109527 - Cambiar control domis cerrada
    26.0      12/03/2012   JGR            28. 0021663: Incidencias con la carga de domiciliaciones y la interfaz de recaudo - 0109768
    27.0      03/04/2012   JGR            29. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
    28.0      16/05/2012   JGR            30. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943
    29.0      06/07/2012   DCG            31. 0022149: CALI003-Fitxers de domiciliacions i transferencies
    30.0      24/10/2012   ECP            32. 0020277: LCOL898 - Interface - Recaudos - Débito Automático - Carga resultado cobros MasterCard
    31.0      05/12/2012   JGR            33. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871
    32.0      14/12/2012   JGR            34. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0132667
    33.0      10/12/2012   ECP            35. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666
    34.0      22/02/2012   JGR            36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818
    37.0      05/06/2013   JGR            37. 0027103: No es posible generar el previo de domiciliación para el cobrador Visa (42)Life - QT-4872
    38.0      10/06/2013   JGR            38. 0027264: Errores en la carga de archivos VISA - QT-6189
    39.0      26/06/2013   JDS            39. 0027150: LCOL_A003-Corregir lista de incidencia reportadas en QT-6200
    40.0      03/07/2013   MMM            40. 0027568: Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
    41.0      09/07/2013   MMM            41. 0027598: LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390
    42.0      26/08/2013   MMM            42. 0027973: LCOL_A003- QT 0009013: Error al enviar notificacion de cobro de poliza a JDE
    43.0      17/09/2013   JGR            43. 0028200: Error en la domiciliación de recibos de retorno - QT-9324 y QT-9326
    44.0      14/11/2013   JGR            44. 0028931: LCOL_MILL-0009968: Error en informacion archivo previo de cobro VISA - 158635
    45.0      24/12/2013   MMM            45. 0028910: LCOL_MILL-9971 + 9985 + 9969- Problemas con las cargas de devoluciones bancarias
    46.0      09/01/2014   AGG            46. 0028661: IAX998-Implementar SEPA en iAxis
    47.0      26/05/2014   RSA            47. 0027500: Nueva operativa de mandatos
    48.0      05/08/2014   dlF            48. 0029371: POSAN100-POSADM Domicliación - Inconsistencia Proceso de Prenotificación
    49.0      05/12/2014   RDD            49. 0032765: MSV0003-Verificacion de SEPA
    50.0      16/10/2014   MMS            50. 0032676: COLM004-Fecha fin de vigencia de mandato. Campo no obligatorio a informar en la pantallas que se informa la fecha de firma
    51.0      16/03/2015   MSV            51. 0032765: Se modifica la generación valor 'FRST' si es la primera vez que esta póliza
******************************************************************************/
------------------------------------------------------------------------------- bug 8416
   fefecto_dom              DATE;
   nlinerr                  NUMBER (8);
   error                    NUMBER (8);
   xnrecibo                 domiciliaciones.nrecibo%TYPE;
   k_error_linea   CONSTANT NUMBER                         := -1;
   gbdomiciliacion          BOOLEAN                        DEFAULT TRUE;

   -- bug 8416
--BUG9708-03042009-XVM
   -----------------------------------------------------------------------------
   FUNCTION f_domiciliar (
      psproces    IN       NUMBER,
      pcempres    IN       NUMBER,
      pfefecto    IN       DATE,
      pfcobro     IN       DATE,
      pcramo      IN       NUMBER,
      pcmodali    IN       NUMBER,
      pctipseg    IN       NUMBER,
      pccolect    IN       NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban    IN       NUMBER,
      pcbanco     IN       NUMBER,
      pctipcta    IN       NUMBER,
      pfvtotar    IN       VARCHAR2,
      pcreferen   IN       VARCHAR2,
      pdfefecto   IN       DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente    IN       NUMBER,
      ptagente    IN       VARCHAR2,
      pnnumide    IN       VARCHAR2,
      pttomador   IN       VARCHAR2,
      pnrecibo    IN       NUMBER,
      --FI BUG 23645
      pcidioma    IN       NUMBER,
      pfitxer     OUT      VARCHAR2,
      pnum_ok     OUT      NUMBER,
      pnum_ko     OUT      NUMBER
   )
      RETURN NUMBER
   IS
      lwhere       VARCHAR2 (1000);
      lctipemp     empresas.ctipemp%TYPE;                       --NUMBER(10);
      lmincobdom   DATE;
      num_err      NUMBER                  := 0;
      num_err2     NUMBER;
      vpasexec     NUMBER                  := 0;
   -- 29. 0021718 / 0111176 - Inicio
   BEGIN
      -- bug 8416
      vpasexec := 10;
      fefecto_dom := pfefecto;
      -- bug 8416

      -- Dades de empresa, n¿ de d¿ de carencia para el cobro desde la generaci¿n del soporte,
      -- i si ¿corredoria
      vpasexec := 20;

      BEGIN
         SELECT ctipemp, TRUNC (f_sysdate) + NVL (ncardom, 0)
           INTO lctipemp, lmincobdom
           FROM empresas
          WHERE cempres = pcempres;
      EXCEPTION
         WHEN OTHERS
         THEN
            lmincobdom := TRUNC (f_sysdate);
            lctipemp := 0;
      END;

      -- Llamamos al proceso de domiciliaci¿n
      -- Bug 11835 - APD - 13/11/2009 - se comentar la llamada a pac_propio.p_predomiciliacion para que
      -- no se anulen recibos en el proceso de domiciliación
      --pac_propio.p_predomiciliacion(psproces, pcempres, pcidioma, pcramo, pcmodali, pctipseg,
--                                    pccolect);
      -- Bug 11835 - APD - 13/11/2009 - Fin
      -- Obtenir els rebuts candidats i guardar-los a domiciliaciones
      vpasexec := 40;
      num_err :=
         f_cobrament (psproces,
                      pcempres,
                      lmincobdom,
                      pfefecto,
                      pfcobro,
                      pcidioma,
                      pcramo,
                      pcmodali,
                      pctipseg,
                      pccolect,
                      pccobban,
                      pcbanco,
                      pctipcta,
                      pfvtotar,
                      pcreferen,
                      pdfefecto,
                      pcagente,
                      ptagente,
                      pnnumide,
                      pttomador,
                      pnrecibo,
                      pnum_ok,
                      pnum_ko
                     );
      vpasexec := 50;

      IF num_err = 0
      THEN
         vpasexec := 60;
         num_err :=
                f_domrecibos (lctipemp, pcidioma, psproces, pfitxer, pfcobro);
      --> -- Bug.: 13498 - JGR - 04/03/2010
      ELSIF num_err = 102903
      THEN                                              -- Si no hi han rebuts
         -- Bug 11835 - MCA - 01/12/2009 - se incluye la empresa para saber el path
         vpasexec := 80;
         num_err := f_fitxer_buit (psproces, pcempres);
      END IF;

      RETURN num_err;
   -- 29. 0021718 / 0111176 - Inicio
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMIS.f_domiciliar',
                      vpasexec,
                      'Error generic OTHERS',
                      SQLERRM || ' ' || SQLCODE
                     );
         RETURN -1;
   -- 29. 0021718 / 0111176 - Fin
   END f_domiciliar;

--------------------------------------------------------------------------------

   -- bug 8416 - 12/12/2008 - Jorteg.a - JTS
/*

Se debe modificar la rutina de creación de fichero de domiciliaciones para que no cobre los recibos , y se ajuste al
formato DOM'80 .

1.- Crear parametro por empresa que indique si se deben cobrar los recibos en la domiciliación.
2.- Modificar el pac_domis:
Según el parámetro por empresa creado,se deberá cobrar el recibo al generar el fichero o no, por defecto Si.
Se deben marcar los recibos con estado de impresión =domiciliación generada (cestimp = 5)
3.- Creación de la función dentro del pac_domis , para la generación del fichero con el formato Belga DOM'80.
4.- Se debe modificar la función f_domrecibos del pac_domis, en el caso de que el cipban del cobrador bancario sea 4,
se debera llamar a la función implementada en el punto 3.

----------------------- Información complementaria ---------------------------
En el caso de que la empresa tenga el parametro del punto 1 informado, los recibos se cobraran al procesar el fichero
de respuesta del banco.
 Los recibos se envian al banco y es el banco el que nos dice lo que ha podido cobrar y lo que no se ha podido cobrar.
 Hasta que no se tiene  respuesta del banco todos los recibos deben quedar con estado pendiente

*/
   FUNCTION f_creafitxer_dom80 (
      p_sproces           IN   NUMBER,
      p_tsufpresentador   IN   VARCHAR2,
      p_cempres           IN   NUMBER,
      p_cdoment           IN   NUMBER,
      p_cdomsuc           IN   NUMBER,
      p_tfitxer           IN   VARCHAR2,
      p_cidioma           IN   NUMBER,
      p_ctipemp           IN   NUMBER,
      p_path              IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      v_fitxer         UTL_FILE.file_type;
      v_num_err        NUMBER;
      v_vcidioma       NUMBER;
      v_pinstalacion   VARCHAR2 (100);
      -- Registre de capçalera
      v_vcap           VARCHAR2 (180);               -- Registre de capçalera
      v_virc           VARCHAR2 (1)               := 0;
      -- Identification of the record : 0
      v_vz4            VARCHAR2 (4)               := '0000';         -- Zeros
      v_vz6            VARCHAR2 (6)               := '000000';       -- Zeros
      v_vdata          VARCHAR2 (6);                       -- Data de creació
      v_vcti           VARCHAR2 (3);
      -- Code of the financial institution (centralising institution).
      v_vapc           VARCHAR2 (2)               := '02';
      -- Application code : 02.
      v_vrtf           VARCHAR2 (34);                -- Reference of the file
      v_vins           VARCHAR2 (11);
-- Identification number of the sender : - company number (0-10N) or - VAT-number (00-9N) or - national registration number (11N).
      v_vinc           VARCHAR2 (11);
-- Identification number of the creditor : - company number (0-10N) or - VAT-number (00-9N) or - national registration number (11N).
      v_vanc           VARCHAR2 (12);      -- Account number of the creditor.
      v_vvvc           VARCHAR2 (1);                 -- Version code : 2 or 5
      v_vdup           VARCHAR2 (1);      -- If duplicate : D, if not, blank.
      v_vrcd           VARCHAR2 (6);             -- Requested collection date
      v_vspc60         VARCHAR2 (60);                               -- blancs
      v_vspc110        VARCHAR2 (110);                              -- blancs
      -- Registre de dades
      v_vreg           VARCHAR2 (180);                   -- Registre de Dades
      v_vird           VARCHAR2 (1)               := '1';
      -- Identification of the record : 1
      v_vnum           NUMBER;
-- Serial number of the record : starts at 000001 and is increased by one unit per operation.
      v_vddn           VARCHAR2 (12);                 -- Direct debit number.
      v_vtpc           VARCHAR2 (1)               := '0';
      -- Type code : 0 : collection; 1 : reversal instruction.
      v_vatcn          vdetrecibos.itotalr%TYPE;
--NUMBER(10, 2);   -- Amount of the collection (the last two positions are to be interpreted as cent).
      v_vatc           VARCHAR2 (12);
-- Amount of the collection (the last two positions are to be interpreted as cent).
      v_vntc           VARCHAR2 (26);                -- Name of the creditor.
      v_vmtp1          VARCHAR2 (15);        -- Message to the payer, part 1.
      v_vmtp2          VARCHAR2 (15);        -- Message to the payer, part 2.
      v_vrcz           VARCHAR2 (12);
-- Reference of the creditor or zeros.The last two figures of this reference constitute the check digits for the first ten figures.
      v_vspc30         VARCHAR2 (30);                               -- blancs
      v_vspc80         VARCHAR2 (80);                               -- blancs
      v_vspc65         VARCHAR2 (65);                               -- blancs
      -- Registre final
      v_vrfi           VARCHAR2 (180);
      v_virf           VARCHAR2 (1)               := '9';
      -- Identification of the record : 9
      v_vnci           VARCHAR2 (7);    -- Number of collection instructions.
      v_vtacin         NUMBER;
      -- Total amount of the collection instructions.
      v_vtaci          VARCHAR2 (12);
      -- Total amount of the collection instructions.
      v_vtddn          VARCHAR2 (15);
      -- Total of the direct debit numbers for the collection instructions.
      v_vnri           VARCHAR2 (7);      -- Number of reversal instructions.
      v_vtari          VARCHAR2 (12);
      -- Total amount of the reversal instructions.
      v_vtri           VARCHAR2 (15);
         --  Total of the direct debit numbers for the reversal instructions.
      --
      v_vobject        VARCHAR2 (50)              := 'f_creafitxer_dom80';
      v_vparam         VARCHAR2 (200)
         :=    'psproces='
            || p_sproces
            || ' ptsufpresentador='
            || p_tsufpresentador
            || ' pcempres='
            || p_cempres
            || ' pcdoment='
            || p_cdoment
            || ' pcdomsuc='
            || p_cdomsuc
            || ' ptfitxer='
            || p_tfitxer
            || ' pcidioma='
            || p_cidioma
            || ' pctipemp='
            || p_ctipemp
            || ' ppath='
            || p_path;
      v_ntraza         NUMBER                     := 0;
      v_ccobban        VARCHAR2 (3);
      v_ncuenta        VARCHAR2 (34);

      CURSOR cur_dom80
      IS
         SELECT DISTINCT sseguro, nrecibo
                    FROM domiciliaciones
                   WHERE sproces = p_sproces
                     AND cempres = p_cempres
                     AND cdoment = p_cdoment
                     AND cdomsuc = p_cdomsuc
                     AND cerror = 0;
   BEGIN
      v_num_err := 0;

-- Control parametres entrada
      IF    p_sproces IS NULL
         OR p_path IS NULL
         OR p_tfitxer IS NULL
         OR p_cempres IS NULL
         OR p_cidioma IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_vobject,
                      v_ntraza,
                      v_vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametres per informar
      END IF;

      v_fitxer := UTL_FILE.fopen (p_path, p_tfitxer, 'w');
      v_vspc60 := LPAD (' ', 60, ' ');
      v_vspc30 := LPAD (' ', 30, ' ');
      v_vspc80 := LPAD (' ', 80, ' ');
      v_vspc110 := LPAD (' ', 110, ' ');
      v_vdata := TO_CHAR (NVL (fefecto_dom, f_sysdate), 'ddmmyy');

      -- Registre de capçalera
      BEGIN
         SELECT DISTINCT LPAD (ccobban, 3, '0')
                    INTO v_ccobban
                    FROM domiciliaciones
                   WHERE sproces = p_sproces
                     AND cempres = p_cempres
                     AND cdoment = p_cdoment
                     AND cdomsuc = p_cdomsuc
                     AND cerror = 0;

         SELECT LPAD (ncuenta, 12, '0')
           INTO v_ncuenta
           FROM cobbancario
          WHERE ccobban = TO_NUMBER (v_ccobban);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_ccobban := '000';
            v_ncuenta := '00000000000';
      END;

      v_vcti := v_ccobban;
      v_vrtf := v_ncuenta;
      --
      v_vins := '00000474013';
      v_vinc := '00000474013';
      --
      --v_vanc := '320083362577';
      v_vvvc := '5';
      v_vdup := ' ';
      v_vrcd := TO_CHAR (f_sysdate, 'ddmmyy');
      v_vcap :=
            v_virc
         || v_vz4
         || v_vdata
         || v_vcti
         || v_vapc
         || '          '
         || v_vins
         || v_vinc
         || v_vrtf
         || v_vvvc
         || v_vdup
         || v_vz6
         || v_vspc60;
      UTL_FILE.put_line (v_fitxer, v_vcap);
      v_ntraza := 1;
      -- Registre de dades
      -- num. registres
      v_vnum := 0;
      v_vtacin := 0;
      v_vtddn := 0;
      v_vrcz := LPAD ('0', 12, '0');

      FOR cur IN cur_dom80
      LOOP
         v_ntraza := 2;

         BEGIN
            BEGIN
               SELECT SUBSTR (cbancar, -12, 12)       -- 12 ultimes posicions.
                 INTO v_vddn
                 FROM recibos
                WHERE nrecibo = cur.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_vddn := LPAD ('0', 12, '0');
            --p_tab_error (f_sysdate,f_user,'f_crea_fitxer_dom80',1,'vddn='||vddn,sqlerrm);
            END;

            v_vtddn := v_vtddn + 1;

            BEGIN
               SELECT itotalr
                 INTO v_vatcn
                 FROM vdetrecibos
                WHERE nrecibo = cur.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_vatcn := 0;
            END;

            v_ntraza := 3;
            v_vtacin := v_vtacin + v_vatcn;
            v_vatc := v_vatcn * 100;
            v_vatc := REPLACE (v_vatc, ',');
            v_vatc := NVL (LPAD (v_vatc, 12, '0'), LPAD ('0', 12, '0'));
            v_ntraza := 4;

            BEGIN
               IF cur.sseguro IS NOT NULL
               THEN
                  -- Nom del prenedor i npoliza
                  SELECT s.npoliza
                    INTO v_vmtp1
                    FROM seguros s
                   WHERE s.sseguro = cur.sseguro;

                  SELECT SUBSTR (   NVL (p.tnombre, ' ')
                                 || ' '
                                 || NVL (p.tapelli1, ' ')
                                 || ' '
                                 || NVL (p.tapelli2, ' '),
                                 1,
                                 26
                                )
                    INTO v_vntc
                    FROM tomadores t, personas p
                   WHERE t.sseguro = cur.sseguro
                     AND t.sperson = p.sperson
                     AND t.nordtom = 1
                     AND ROWNUM = 1;
               ELSE
                  SELECT s.npoliza
                    INTO v_vmtp1
                    FROM recibos r, seguros s
                   WHERE r.nrecibo = cur.nrecibo AND r.sseguro = s.sseguro;

                  SELECT SUBSTR (   NVL (p.tnombre, ' ')
                                 || ' '
                                 || NVL (p.tapelli1, ' ')
                                 || ' '
                                 || NVL (p.tapelli2, ' '),
                                 1,
                                 26
                                )
                    INTO v_vntc
                    FROM recibos r, seguros s, tomadores t, personas p
                   WHERE r.nrecibo = cur.nrecibo
                     AND r.sseguro = t.sseguro
                     AND t.sperson = p.sperson
                     AND t.nordtom = 1
                     AND ROWNUM = 1;
               END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  --p_Tab_error (f_sysdate,f_user,vobject,ntraza,'Nombre NDF nrecibo='||cur.nrecibo,SQLERRM);
                  v_vntc := ' ';
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               v_vobject,
                               v_ntraza,
                                  'Error sseguro='
                               || cur.sseguro
                               || ' nrecibo='
                               || cur.nrecibo
                               || ' sqlcode='
                               || SQLCODE,
                               SQLERRM
                              );
                  v_vntc := ' ';
            END;

            v_ntraza := 5;
            v_vmtp2 := LPAD (cur.nrecibo, 15, '0');
            v_vmtp1 := LPAD (NVL (v_vmtp1, '0'), 15, '0');
            v_vnum := v_vnum + 1;
            v_vddn := LPAD (NVL (v_vddn, '0'), 12, '0');
            v_vntc := NVL (LPAD (v_vntc, 26, ' '), LPAD (' ', 26, ' '));
            -- Registre de Dades
            v_vreg :=
                  v_vird
               || LPAD (v_vnum, 4, '0')
               || v_vddn
               || v_vtpc
               || v_vatc
               || v_vntc
               || LPAD (v_vmtp1 || v_vmtp2, 30, ' ')
               || v_vrcz
               || v_vspc30;
            UTL_FILE.put_line (v_fitxer, v_vreg);
            v_ntraza := 6;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            v_vobject,
                            v_ntraza,
                            'Error sqlcode=' || SQLCODE,
                            SQLERRM
                           );
         END;
      END LOOP;

      v_ntraza := 7;
      -- Registre final
      --vnci  := nvl(LPAD(SUBSTR(TO_CHAR(vnum),-4,4),4,'0'),lpad(' ',4,' '));
      v_vnci := NVL (LPAD (v_vnum, 4, '0'), LPAD ('0', 4, '0'));
      v_vnri := '0000';
      v_vtari := LPAD ('0', 12, '0');
      v_vtri := LPAD ('0', 15, '0');
      v_vspc65 := LPAD (' ', 65, ' ');
      v_vtddn := NVL (LPAD (v_vtddn, 15, '0'), LPAD ('0', 15, '0'));
      v_vtaci := v_vtacin;
      v_vtaci := REPLACE (v_vtaci, ',');
      v_vtaci := NVL (LPAD (v_vtaci, 12, '0'), LPAD ('0', 12, '0'));
      v_vrfi :=
            v_virf
         || v_vnci
         || v_vtaci
         || v_vtddn
         || v_vnri
         || v_vtari
         || v_vtri
         || v_vspc65;
      UTL_FILE.put_line (v_fitxer, v_vrfi);
      UTL_FILE.fclose (v_fitxer);
      v_ntraza := 8;
      -- Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.
      UTL_FILE.frename (p_path, p_tfitxer, p_path, LTRIM (p_tfitxer, '_'));
      -- Fi Bug 0013153
      RETURN v_num_err;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_vobject,
                      v_ntraza,
                      'Error sqlcode=' || SQLCODE,
                      SQLERRM
                     );

         IF UTL_FILE.is_open (v_fitxer)
         THEN
            UTL_FILE.fclose (v_fitxer);
         END IF;

         RETURN SQLCODE;
   END f_creafitxer_dom80;

   FUNCTION f_creafitxer (
      psproces           IN   NUMBER,
      ptsufpresentador   IN   VARCHAR2,
      pcempres           IN   NUMBER,
      pcdoment           IN   NUMBER,
      pcdomsuc           IN   NUMBER,
      ptfitxer           IN   VARCHAR2,
      pcidioma           IN   NUMBER,
      pctipemp           IN   NUMBER,
      ppath              IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      --BUG8956:  12/03/2009 XCG IAX - Domiciliaciones para Base de datos  (MODIFIQUEM LES VARIABLES PER TYPES)
      xncuenta              cobbancario.ncuenta%TYPE;
      xtsufijo              cobbancario.tsufijo%TYPE;
      xcempres              cobbancario.cempres%TYPE;
      xcdoment              cobbancario.cdoment%TYPE;
      xcdomsuc              cobbancario.cdomsuc%TYPE;
      xnifcob               cobbancario.nnumnif%TYPE;
      xnnumnif              cobbancario.nnumnif%TYPE;
      xccobban              cobbancario.ccobban%TYPE;
--xncuenta       NUMBER(10);
--xtsufijo       VARCHAR2(3);
--xcempres       NUMBER(10);
--xcdoment       NUMBER(10);
--xcdomsuc       NUMBER(10);
--xnifcob        VARCHAR2(14);
--xnnumnif       VARCHAR2(10);
--xccobban       NUMBER(10);
--FI BUG8956-----------------------------------------------------
      xnrecibo              domiciliaciones.nrecibo%TYPE;       --NUMBER(10);
      xcramo                domiciliaciones.cramo%TYPE;         --NUMBER(10);
      xfefecto              DATE;
      xtnumnif              VARCHAR2 (20);
--xtsufijof      VARCHAR2(3); -- 30. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 (-)
      xtsufijof             cobbancario.tsufijo%TYPE;
-- 30. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 (+)
      xtcobban              VARCHAR2 (40);
      --Bug 13472 - 18/03/2010 - AMC - Se amplia el campo a 40
      xtempres              VARCHAR2 (40);
      vegada                NUMBER                         := 1;
      error                 NUMBER;
      xsseguro              seguros.sseguro%TYPE;               --NUMBER(10);
      xsperson              NUMBER;
      xcdomici              NUMBER;
      xcidioma              NUMBER;
      xtnombre              VARCHAR2 (100);
      xitotalr              vdetrecibos.itotalr%TYPE;           --NUMBER(10);
      xcbancar              seguros.cbancar%TYPE;
      xnpoliza              seguros.npoliza%TYPE;               --NUMBER(10);
      xncertif              seguros.ncertif%TYPE;               --NUMBER(10);
      fitxer                UTL_FILE.file_type;
      tot_imp_remesa        NUMBER                         := 0;
      tot_num_rebuts        NUMBER                         := 0;
      tot_registres_ord     NUMBER                         := 0;
      tot_remeses_pres      NUMBER                         := 0;
      tot_imp_presentador   NUMBER                         := 0;
      tot_num_rebuts_pres   NUMBER                         := 0;
      tot_registres_pres    NUMBER                         := 0;
      linia                 VARCHAR2 (162);
      poliscert             VARCHAR2 (12);
      espais2               VARCHAR (2)                 := LPAD (' ', 2, ' ');
      espais6               VARCHAR (6)                 := LPAD (' ', 6, ' ');
      espais8               VARCHAR (8)                 := LPAD (' ', 8, ' ');
      espais14              VARCHAR (14)               := LPAD (' ', 14, ' ');
      espais16              VARCHAR (16)               := LPAD (' ', 16, ' ');
      espais20              VARCHAR (20)               := LPAD (' ', 20, ' ');
      espais38              VARCHAR (38)               := LPAD (' ', 38, ' ');
      espais52              VARCHAR (52)               := LPAD (' ', 52, ' ');
      espais66              VARCHAR (66)               := LPAD (' ', 66, ' ');
      espais72              VARCHAR (72)               := LPAD (' ', 72, ' ');
      espais64              VARCHAR (64)               := LPAD (' ', 64, ' ');
      espais80              VARCHAR (80)               := LPAD (' ', 80, ' ');
      lin1                  VARCHAR2 (80);
      lin2                  VARCHAR2 (80);
      lin3                  VARCHAR2 (80);
      lin4                  VARCHAR2 (80);
      lin5                  VARCHAR2 (80);
      lin6                  VARCHAR2 (80);
      lin7                  VARCHAR2 (80);
      lin8                  VARCHAR2 (80);
      p0180                 VARCHAR2 (4)                   := '0180';
      p0380                 VARCHAR2 (4)                   := '0380';
      p0680                 VARCHAR2 (4)                   := '0680';
      p0681                 VARCHAR2 (4)                   := '0681';
      p0682                 VARCHAR2 (4)                   := '0682';
      p0683                 VARCHAR2 (4)                   := '0683';
      p0684                 VARCHAR2 (4)                   := '0684';
      p0685                 VARCHAR2 (4)                   := '0685';
      p0880                 VARCHAR2 (4)                   := '0880';
      p0980                 VARCHAR2 (4)                   := '0980';
      pcdivisa              productos.cdivisa%TYPE;             --NUMBER(10);
      xxitotalr             VARCHAR2 (20);
      xcsb54                parinstalacion.nvalpar%TYPE;        --NUMBER(10);
      xtnifpresentador      VARCHAR2 (12)                  := '';
      v_ntraza              NUMBER                         := 0;
      v_vobject             VARCHAR2 (500)        := 'pac_domis.f_creafitxer';

      CURSOR cur_remesa
      IS
         SELECT   ccobban, GREATEST (fefecrec, fefecto) fefecto, cdoment,
                  cdomsuc, cramo
             FROM domiciliaciones
            WHERE sproces = psproces
              --AND tsufijo = ptsufijo
              AND cempres = pcempres
              AND cdoment = pcdoment
              AND cdomsuc = pcdomsuc
              AND cerror = 0
         GROUP BY ccobban,
                  GREATEST (fefecrec, fefecto),
                  cdoment,
                  cdomsuc,
                  cramo
         ORDER BY cramo, fefecto;

      CURSOR cur_domiciliac
      IS
         SELECT   nrecibo, LPAD (tsufijo, 3, '0') tsufijo, fefecto, cempres,
                  cdoment, cdomsuc
             FROM domiciliaciones d
            WHERE sproces = psproces
              AND ccobban = xccobban
              AND GREATEST (fefecto, fefecrec) = xfefecto
              AND cerror = 0
              AND cramo = xcramo
         ORDER BY fefecto;

--********* CONTROLAMOS LA INSTALACION PARA GRABAR UNA REFERENCIA DIFERENTE
--********* EN SGA SE GRABA NPOLIZA + NCERTIF
--********* EN CAIXA SE GRABAN xx + CSEGHOS
      pinstalacion          VARCHAR2 (100);
      cuenta                NUMBER;
      lccompani             NUMBER;
      xcsubpro              NUMBER;
      -- Bug 8745 - 06/03/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
      vsproduc              NUMBER;
   -- Fin 8745
   BEGIN
      --BUSCAMOS LA INSTALACION
      BEGIN
         SELECT UPPER (tvalpar)
           INTO pinstalacion
           FROM parinstalacion
          WHERE UPPER (cparame) = 'GRUPO';
      EXCEPTION
         WHEN OTHERS
         THEN
            pinstalacion := '';
      END;

      --BUSCAMOS SI CSB19 (1) o CSB54 (2)
      BEGIN
         SELECT nvalpar
           INTO xcsb54
           FROM parinstalacion
          WHERE UPPER (cparame) = 'DOMICI';
      EXCEPTION
         WHEN OTHERS
         THEN
            xcsb54 := 1;
      END;

      v_ntraza := 1;
---Alberto
      error := 0;

      IF error = 0
      THEN
         xcempres := pcempres;
         error := f_nifempresa (xcempres, xtnifpresentador);
         v_ntraza := 2;

         IF error = 0
         THEN
            -- error := F_Desempresa (xcempres, NULL, xtempres);
            NULL;

            IF error = 0
            THEN
               fitxer := UTL_FILE.fopen (ppath, ptfitxer, 'w');
               v_ntraza := 3;

               OPEN cur_remesa;

               FETCH cur_remesa
                INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;

               WHILE cur_remesa%FOUND
               LOOP
                  error :=
                     f_cobrador (xccobban,
                                 xnnumnif,
                                 xtsufijo,
                                 xcdoment,
                                 xcempres,
                                 xcdomsuc,
                                 xncuenta,
                                 xnifcob
                                );
                  v_ntraza := 4;

--                  p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 1, xccobban,
--                              xccobban); -- Bug:14574 - 25/05/2010 - JMC
                  SELECT tcobban
                    INTO xtcobban
                    FROM cobbancario
                   WHERE ccobban = xccobban;

                  IF error = 0
                  THEN
                     error := f_nifempresa (xcempres, xtnumnif);
                  ELSE
                     UTL_FILE.fclose (fitxer);
                     RETURN error;
                  END IF;

                  v_ntraza := 5;

                  IF xnifcob IS NOT NULL
                  THEN
                     xtnumnif := xnifcob;
                  END IF;

                  error := f_desempresa (xcempres, NULL, xtempres);

                  IF error <> 0
                  THEN
                     UTL_FILE.fclose (fitxer);
                     RETURN error;
                  END IF;

                  xtnumnif := NVL (xtnumnif, '0');
                  xtsufijo := NVL (xtsufijo, '0');
                  xtempres := NVL (xtempres, '0');
                  xcdoment := NVL (xcdoment, '0');
                  xcdomsuc := NVL (xcdomsuc, '0');
                  xncuenta := NVL (xncuenta, '0');

                  --En caso de la correduria el presentador y el ordenante
                  --son la compa¿¿(CASER, WINTERTHUR, SGA, ...)
                  IF NVL (pctipemp, 0) = 1
                  THEN                                 --estamos en correduria
                     --Contaremos las diferentes cias. del cobrador bancario
                     --Si tiene mas de una haremos el fichero como si fuera cia. y no como correduria
                     cuenta := 0;
                     v_ntraza := 6;

                     BEGIN
--                        p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 2, xccobban,
--                                    xccobban);   -- Bug:14574 - 25/05/2010 - JMC
                        SELECT DISTINCT ccompani
                                   INTO lccompani
                                   FROM productos
                                  WHERE (cramo, cmodali, ctipseg, ccolect) IN (
                                           SELECT cramo, cmodali, ctipseg,
                                                  ccolect
                                             FROM cobbancariosel
                                            WHERE ccobban = xccobban);

--                        p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 3, lccompani,
--                                    lccompani);  -- Bug:14574 - 25/05/2010 - JMC

                        -- Si va be la query ¿que nom¿hi ha una
                        SELECT tapelli, nnumnif
                          INTO xtempres, xtnumnif
                          FROM personas
                         WHERE sperson = (SELECT sperson
                                            FROM companias
                                           WHERE ccompani = lccompani);
                     EXCEPTION
                        WHEN TOO_MANY_ROWS
                        THEN
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'PAC_DOMIS.CREAFITXER',
                                        4,
                                        '*',
                                        '*'
                                       );
                           NULL;
                     END;
                  END IF;

                  v_ntraza := 7;

                  IF vegada = 1
                  THEN
                     v_ntraza := 8;
                     xtsufijof := xtsufijo;

                     --Buscar la moneda del producto
                     --Un mismo cobrador bancario no tendr¿¿de una moneda
                     --Buscamos el sproduc
                     BEGIN
                        SELECT NVL (cdivisa, 2)
                          INTO pcdivisa
                          FROM productos
                         WHERE (cramo, cmodali, ctipseg, ccolect) IN (
                                  SELECT cramo, cmodali, ctipseg, ccolect
                                    FROM seguros
                                   WHERE sseguro IN (
                                            SELECT sseguro
                                              FROM recibos
                                             WHERE nrecibo IN (
                                                      SELECT MIN (nrecibo)
                                                        FROM domiciliaciones
                                                       WHERE sproces =
                                                                      psproces
                                                         AND ccobban =
                                                                      xccobban)));
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           pcdivisa := f_parinstalacion_n ('MONEDAINST');
                     END;

                     v_ntraza := 9;

                     IF pcdivisa != 2 AND xcsb54 = 2
                     THEN                                      --Euros + CSB54
                        v_ntraza := 10;
                        p0180 := '5170';
                        p0380 := '5370';
                        p0680 := '5670';
                        p0681 := '5671';
                        p0682 := '5672';
                        p0683 := '5673';
                        p0684 := '5674';
                        p0685 := '5675';
                        p0880 := '5870';
                        p0980 := '5970';
                     ELSIF pcdivisa = 2 AND xcsb54 = 1
                     THEN                                        --Pts + CSB19
                        v_ntraza := 11;
                        p0180 := '0180';
                        p0380 := '0380';
                        p0680 := '0680';
                        p0681 := '0681';
                        p0682 := '0682';
                        p0683 := '0683';
                        p0684 := '0684';
                        p0685 := '0685';
                        p0880 := '0880';
                        p0980 := '0980';
                     ELSIF pcdivisa != 2 AND xcsb54 = 1
                     THEN                                        --EUR + CSB19
                        v_ntraza := 12;
                        p0180 := '5180';
                        p0380 := '5380';
                        p0680 := '5680';
                        p0681 := '5681';
                        p0682 := '5682';
                        p0683 := '5683';
                        p0684 := '5684';
                        p0685 := '5685';
                        p0880 := '5880';
                        p0980 := '5980';
                     ELSIF pcdivisa = 2 AND xcsb54 = 2
                     THEN                                        --Pts + CSB54
                        v_ntraza := 13;
                        p0180 := '0170';
                        p0380 := '0370';
                        p0680 := '0670';
                        p0681 := '0671';
                        p0682 := '0672';
                        p0683 := '0673';
                        p0684 := '0674';
                        p0685 := '0675';
                        p0880 := '0870';
                        p0980 := '0970';
                     END IF;

                     v_ntraza := 14;

                     -- Grabem el registre del presentador (nom¿la primera vegada)

                     --Bug 26792-XVM-26/04/2013
                     IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                            'AJUST_DOMTRANS'
                                                           ),
                             0
                            ) = 0
                     THEN
                        linia :=
                              p0180
                           || LPAD (xtnifpresentador, 9, '0')
                           || LPAD (ptsufpresentador, 3, '0')
                           -- || LPAD (xtsufijo, 3, '0')
                           || TO_CHAR (f_sysdate, 'ddmmyy')
                           || espais6
                           || RPAD (xtempres, 40, ' ')
                           || espais20
                           || LPAD (xcdoment, 4, '0')
                           || LPAD (xcdomsuc, 4, '0')
                           || SUBSTR (espais66, 1, 65)
                           || 'D';
                     ELSE
                        linia :=
                              p0180
                           || LPAD (xtnifpresentador, 9, '0')
                           || LPAD (ptsufpresentador, 3, '0')
                           -- || LPAD (xtsufijo, 3, '0')
                           || TO_CHAR (f_sysdate, 'ddmmyy')
                           || espais6
                           || RPAD (xtempres, 40, ' ')
                           || espais20
                           || LPAD (xcdoment, 4, '0')
                           || LPAD (xcdomsuc, 4, '0')
                           || SUBSTR (espais66, 1, 65)
                           || ' ';
                     END IF;

                     UTL_FILE.put_line (fitxer, linia);
                     vegada := 2;
                  END IF;

                  v_ntraza := 15;

                  -- Grabem el registre de l' ordenant
                  -- xtsufijo:= LPAD(xcramo,3,'0');
                  IF xcsb54 = 1
                  THEN                                                 --CSB19
                     linia :=
                           p0380
                        || LPAD (xtnumnif, 9, '0')
                        || LPAD (xtsufijo, 3, '0')
                        || TO_CHAR (f_sysdate, 'ddmmyy')
                        || TO_CHAR (xfefecto, 'ddmmyy')
-- || RPAD (xtempres, 40, ' ')
                        || RPAD (xtcobban, 40, ' ')
                        || LPAD (xncuenta, 20, '0')
                        || espais8
                        || '01'
                        || espais64;
                  ELSE
                     linia :=
                           p0380
                        || LPAD (xtnumnif, 9, '0')
                        || LPAD (xtsufijo, 3, '0')
                        || TO_CHAR (f_sysdate, 'ddmmyy')
                        || TO_CHAR (xfefecto, 'ddmmyy')
                        || RPAD (xtempres, 40, ' ')
                        || LPAD (xncuenta, 20, '0')
                        || espais8
                        || '06'
                        || espais64;
                  END IF;

                  v_ntraza := 16;
                  UTL_FILE.put_line (fitxer, linia);
                  tot_imp_remesa := 0;
                  tot_num_rebuts := 0;

                  OPEN cur_domiciliac;

                  FETCH cur_domiciliac
                   INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment,
                        xcdomsuc;

                  v_ntraza := 17;

--                  p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 5,
--                              'xnrecibo||xtsufijo||xfefecto||xcempres||xcdoment||xcdomsuc',
--                              xnrecibo || xtsufijo || xfefecto || xcempres || xcdoment
--                              || xcdomsuc);  -- Bug:14574 - 25/05/2010 - JMC
                  WHILE cur_domiciliac%FOUND
                  LOOP
                     BEGIN
                        SELECT s.sseguro, s.npoliza, s.ncertif, r.cbancar,
                               p.csubpro
                          INTO xsseguro, xnpoliza, xncertif, xcbancar,
                               xcsubpro
                          FROM recibos r, seguros s, productos p
                         WHERE r.nrecibo = xnrecibo
                           AND r.sseguro = s.sseguro
                           AND s.sproduc = p.sproduc;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           RETURN 101947;            -- Inconsist¿ia de la BD
                        WHEN OTHERS
                        THEN
                           RETURN 101916;                   -- Error en la BD
                     END;

                     v_ntraza := 18;
                     xsperson := NULL;
                     xcdomici := NULL;
                     xcidioma := pcidioma;
                     error :=
                        f_nomrecibo (xsseguro,
                                     xtnombre,
                                     xcidioma,
                                     xsperson,
                                     xcdomici
                                    );

                     IF error = 0
                     THEN
                        v_ntraza := 19;
                        error :=
                           pac_propio.f_trecibo (xnrecibo,
                                                 xcidioma,
                                                 lin1,
                                                 lin2,
                                                 lin3,
                                                 lin4,
                                                 lin5,
                                                 lin6,
                                                 lin7,
                                                 lin8
                                                );

/*
                           f_trecibo_sn (xnrecibo,
                                         xcidioma,
                                         lin1,
                                         lin2,
                                         lin3,
                                         lin4,
                                         lin5,
                                         lin6,
                                         lin7,
                                         lin8
                                        );
*/
                        IF error = 0
                        THEN
                           BEGIN
                              SELECT NVL (itotalr, 0)
                                INTO xitotalr
                                FROM vdetrecibos
                               WHERE nrecibo = xnrecibo;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 --message('recibos ' || xnrecibo);pause;
                                 RETURN 101947;      -- Inconsist¿ia de la BD
                              WHEN OTHERS
                              THEN
                                 RETURN 101916;             -- Error en la BD
                           END;

                           IF xitotalr < 0
                           THEN
                              RETURN 102276;
                           -- Total del rebut no pot ser negatiu
                           ELSE
                                       -- ARA INSERTAREM 6 REGISTRES EN EL FITXER
                                       -- poliscert := LPAD (xnpoliza, 12, '0');
                                       --poliscert := lpad(xnpoliza, 8, ' ') || lpad(xncertif, 4, ' ');
                                       -- Bug 8745 - 06/03/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
                              -- 'ADMITE_CERTIFICADOS'
                              SELECT sproduc
                                INTO vsproduc
                                FROM seguros
                               WHERE sseguro = xsseguro;

                              IF    xcsubpro = 3
                                 OR NVL
                                       (f_parproductos_v
                                                        (vsproduc,
                                                         'ADMITE_CERTIFICADOS'
                                                        ),
                                        0
                                       ) = 1
                              THEN
                                 --colectivo individualizado o colectivo multiple
                                 poliscert :=
                                       LPAD (   SUBSTR (LPAD (xnpoliza, 8,
                                                              '0'),
                                                        1,
                                                        2
                                                       )
                                             || SUBSTR (LPAD (xnpoliza, 8,
                                                              ' '),
                                                        5,
                                                        8
                                                       ),
                                             6,
                                             '0'
                                            )
                                    || LPAD (xncertif, 6, '0');
                              ELSE
                                 poliscert := LPAD (xnpoliza, 12, '0');
                              END IF;

                              -- Fin Bug 8745
                              xtnombre := NVL (xtnombre, ' ');
                              xcbancar := NVL (xcbancar, '0');
                              xitotalr := NVL (xitotalr, '0');
                              lin1 := NVL (lin1, ' ');
                              lin2 := NVL (lin2, ' ');
                              lin3 := NVL (lin3, ' ');
                              lin4 := NVL (lin4, ' ');
                              lin5 := NVL (lin5, ' ');
                              lin6 := NVL (lin6, ' ');
                              lin7 := NVL (lin7, ' ');
                              lin8 := NVL (lin8, ' ');

                              IF pcdivisa = 3
                              THEN                                     --Euros
                                 SELECT TO_NUMBER
                                           (REPLACE
                                               (REPLACE (TO_CHAR ((  xitotalr
                                                                   * 100
                                                                  )
                                                                 ),
                                                         '.',
                                                         ''
                                                        ),
                                                ',',
                                                ''
                                               )
                                           )
                                   INTO xitotalr
                                   FROM DUAL;
                              END IF;

                              -- Aquest ¿el primer
                              IF xcsb54 = 1
                              THEN                                     --CSB19
                                 linia :=
                                       p0680
                                    || LPAD (xtnumnif, 9, '0')
                                    || LPAD (xtsufijo, 3, '0')
                                    || poliscert
                                    || RPAD (xtnombre, 40, ' ')
                                    || LPAD (xcbancar, 20, '0')
                                    || LPAD (xitotalr, 10, '0')
                                    || LPAD (psproces, 6, '0')
                                    || RPAD (LPAD (xnrecibo, 9, '0'), 10, ' ')
                                    || RPAD (NVL (SUBSTR (lin1, 1, 40), ' '),
                                             40,
                                             ' '
                                            )
                                    || espais8;
                              ELSE
                                 linia :=
                                       p0680
                                    || LPAD (xtnumnif, 9, '0')
                                    || LPAD (xtsufijo, 3, '0')
                                    || poliscert
                                    || RPAD (xtnombre, 40, ' ')
                                    || LPAD (xcbancar, 20, '0')
                                    || LPAD (xitotalr, 10, '0')
                                    || LPAD (psproces, 6, '0')
                                    || RPAD (LPAD (xnrecibo, 9, '0'), 10, ' ')
                                    || RPAD (NVL (SUBSTR (lin1, 1, 40), ' '),
                                             40,
                                             ' '
                                            )
                                    || TO_CHAR (xfefecto, 'ddmmyy')
                                    || espais2;
                              END IF;

                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el segon
                              linia :=
                                    p0681
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin1, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin2, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin2, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el tercer
                              linia :=
                                    p0682
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin3, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin3, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin4, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el quart
                              linia :=
                                    p0683
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin4, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin5, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin5, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el cinqu¿
                              linia :=
                                    p0684
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin6, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin6, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin7, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el sis¿
                              linia :=
                                    p0685
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin7, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin8, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin8, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              tot_imp_remesa :=
                                            tot_imp_remesa + NVL (xitotalr, 0);
                              tot_num_rebuts := tot_num_rebuts + 1;
                           END IF;
                        ELSE
                           RETURN error;
                        END IF;
                     ELSE
                        v_ntraza := 20;
                        RETURN error;
                     END IF;

                     FETCH cur_domiciliac
                      INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment,
                           xcdomsuc;
                  END LOOP;

                  CLOSE cur_domiciliac;

                  v_ntraza := 21;
                  -- insertem un registre de FINAL DE ORDENANT
                  tot_registres_ord := 2 + 6 * tot_num_rebuts;
                  linia :=
                        p0880
                     || LPAD (xtnumnif, 9, '0')
                     || LPAD (xtsufijo, 3, '0')
                     || espais72
                     || LPAD (tot_imp_remesa, 10, '0')
                     || espais6
                     || LPAD (tot_num_rebuts, 10, '0')
                     || LPAD (tot_registres_ord, 10, '0')
                     || espais38;
                  UTL_FILE.put_line (fitxer, linia);
                  tot_remeses_pres := tot_remeses_pres + 1;
                  tot_imp_presentador := tot_imp_presentador + tot_imp_remesa;
                  tot_num_rebuts_pres := tot_num_rebuts_pres + tot_num_rebuts;

                  FETCH cur_remesa
                   INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;
               END LOOP;

               CLOSE cur_remesa;

               v_ntraza := 22;
               -- Insertem un registre de final del Presentador
               tot_registres_pres :=
                           2
                         + (2 * tot_remeses_pres)
                         + (6 * tot_num_rebuts_pres);
               linia :=
                     p0980
                  || LPAD (xtnifpresentador, 9, '0')
                  || LPAD (ptsufpresentador, 3, '0')               --xtsufijof
                  || espais52
                  || LPAD (tot_remeses_pres, 4, '0')
                  || espais16
                  || LPAD (tot_imp_presentador, 10, '0')
                  || espais6
                  || LPAD (tot_num_rebuts_pres, 10, '0')
                  || LPAD (tot_registres_pres, 10, '0')
                  || espais38;
               UTL_FILE.put_line (fitxer, linia);
               UTL_FILE.fclose (fitxer);
               -- Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.
               UTL_FILE.frename (ppath, ptfitxer, ppath,
                                 LTRIM (ptfitxer, '_'));
               -- Fi Bug 0013153

               -- utl_file.fcopy(ppath, ptfitxer,ppath,'mvdom'||TO_CHAR(F_Sysdate,'YYYYMMDD')||'.txt');
               RETURN 0;
            ELSE
               RETURN error;
            END IF;
         ELSE
            RETURN error;
         END IF;
      ELSE
         RETURN error;
      END IF;
   EXCEPTION
--      WHEN OTHERS THEN
--         RETURN 102927;   -- Error de I/O (Interacci¿ amb el fitxer)
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_vobject,
                      v_ntraza,
                      ppath || ' ' || ptfitxer,
                      SQLERRM
                     );

         IF UTL_FILE.is_open (fitxer)
         THEN
            UTL_FILE.fclose (fitxer);
         END IF;

         RETURN SQLCODE;
   END f_creafitxer;

      --AGG MODIFICACIONES SEPA
    /*************************************************************************
       FUNCTION f_set_domiciliaciones_sepa
       Función que guarda los datos en las tablas de domi_sepa

       param in psproces
       param in pcempres
       param in pcdoment
       param in pcdomsuc
       param in pfcobro
       return             : Devuelve 0 si no ha habido ningún error, por lo contrario devuelve el número de error
   *************************************************************************/
   FUNCTION f_set_domiciliaciones_sepa (
      psproces   IN   NUMBER,
      pcempres   IN   NUMBER,
      pcdoment   IN   NUMBER,
      pcdomsuc   IN   NUMBER,
      pfcobro    IN   DATE
   )
      RETURN NUMBER
   IS
      --
      vparini                  VARCHAR2 (100)
         :=    'p='
            || psproces
            || ' e='
            || pcempres
            || ' e='
            || pcdoment
            || ' s='
            || pcdomsuc
            || ' c='
            || TO_CHAR (pfcobro, 'yyyymmddmisshh24miss');
      vpar                     VARCHAR2 (200);
      --
      xfefecto                 DATE;
      xcramo                   domiciliaciones.cramo%TYPE;       --NUMBER(10);
      xccobban                 cobbancario.ccobban%TYPE;

      -- xcnrecibo      domiciliaciones.nrecibo%TYPE;
      CURSOR cur_remesa
      IS
         SELECT   ccobban, MAX (GREATEST (fefecrec, fefecto)) fefecto,
                  cdoment, cdomsuc, MAX (cramo) cramo
             FROM domiciliaciones
            WHERE sproces = psproces
              --AND tsufijo = ptsufijo
              AND cempres = pcempres
              AND cdoment = pcdoment
              AND cdomsuc = pcdomsuc
              AND cerror = 0
         GROUP BY ccobban,
                          --GREATEST(fefecrec, fefecto),
                          cdoment, cdomsuc                           --, cramo
         ORDER BY cramo, fefecto;

        --Jesus y Claudio :  La relacion de las tablas son 1 - 1 - n.
      --por un probleam de la version de la DD.BB. ( upgrade to 11.2.0.3 )
      CURSOR cur_domiciliac
      IS
         SELECT   nrecibo, LPAD (tsufijo, 3, '0') tsufijo, fefecto, cempres,
                  cdoment, cdomsuc, smovrec, idnotif2, fidenotif2, sseguro,
                  cbancar, ctipban
             FROM domiciliaciones d
            WHERE sproces = psproces AND ccobban = xccobban AND cerror = 0
         --  AND GREATEST(fefecto, fefecrec) = xfefecto
         --  AND cramo = xcramo
         ORDER BY fefecto;

      --Jesus y Claudio :  La relacion de las tablas son 1 - 1 - n.
      --por un probleam de la version de la DD.BB. ( upgrade to 11.2.0.3 )
      CURSOR cur_rec_domi
      IS
         SELECT nrecibo
           FROM domiciliaciones d
          WHERE sproces = psproces AND ccobban = xccobban AND cerror = 0;

          --AND GREATEST(fefecto, fefecrec) = xfefecto
          --AND cramo = xcramo;
      --Jesus y Claudio :  La relacion de las tablas son 1 - 1 - n.
      --por un probleam de la version de la DD.BB. ( upgrade to 11.2.0.3 )

      --AGG  MODIFICACIONES SEPA
      vidnotif2                VARCHAR2 (100)                  := NULL;
      vfidenotif2              DATE                            := NULL;
      viddomisepa              NUMBER (8);
      vnumori                  NUMBER (8)                      := 0;
      v_vatcn                  NUMBER (15, 2);
      v_totalr                 NUMBER (15, 2)                  := 0;
      v_inigptynm              VARCHAR2 (70);
      v_cempres                NUMBER;
      v_numnif                 VARCHAR2 (50);
      v_sufijo                 VARCHAR2 (4);
      v_inigtpty_id            VARCHAR2 (35);
      aux_v_inigtpty_id        VARCHAR2 (35);
      v_fecha                  DATE;
      v_fefecto                DATE;
      viddomisepapago          NUMBER (8);
      viddomisepapagodetalle   NUMBER (8);
      v_pais                   VARCHAR2 (2);
      v_iban                   VARCHAR2 (34);
      xcdoment                 domiciliaciones.cdoment%TYPE;
      xcdomsuc                 domiciliaciones.cdomsuc%TYPE;
      xcbancar                 domiciliaciones.cbancar%TYPE;
      v_cbic                   VARCHAR2 (11);
      error                    NUMBER;
      xcempres                 NUMBER;
      m_fmovini                DATE;
      xfmovim                  DATE;
      xtsufijo                 VARCHAR2 (3);
      vsmovrec                 NUMBER (8);
      xvidnotfi2               VARCHAR2 (100)                  := NULL;
      xvfidnotif2              DATE                            := NULL;
      vsseguro                 NUMBER (6);
      v_idioma                 NUMBER;
      v_nombre                 VARCHAR2 (200); -- Bug 41102/229802 - 05/04/2016
      v_sperson                NUMBER;
      v_domici                 VARCHAR2 (100);
      vlin1                    VARCHAR2 (400);
      vlin2                    VARCHAR2 (400);
      vlin3                    VARCHAR2 (400);
      vlin4                    VARCHAR2 (400);
      vlin5                    VARCHAR2 (400);
      vlin6                    VARCHAR2 (400);
      vlin7                    VARCHAR2 (400);
      vlin8                    VARCHAR2 (400);
      v_ustrd                  VARCHAR2 (4000);
      vpasexec                 NUMBER (8);
      xnrecibo                 domiciliaciones.nrecibo%TYPE;
      -- NUMBER(9); -- BUG 0036641 JMF 23-06-2015
      v_cd_seqtp_3             VARCHAR2 (4)                    := 'RCUR';
      vrecactual               recibos.nrecibo%TYPE;
      v_totalrecibo            vdetrecibos.itotalr%TYPE;
      v_irecibo                vdetrecibos.itotalr%TYPE;
      v_smovrecibo             movrecibo.smovrec%TYPE;
      v_cbancario              domiciliaciones.cbancar%TYPE;
      v_ctipban                domiciliaciones.ctipban%TYPE;
      xvctipbandomi            domiciliaciones.ctipban%TYPE;
      v_iban_det               VARCHAR2 (34);
      v_numdomi                NUMBER                          := 0;
      v_numrcob                NUMBER                          := 0;
      v_totaldomi              NUMBER                          := 0;
      v_totalnumdomi           NUMBER                          := 0;
      v_numide                 VARCHAR2 (50)                   := '';
      v_spersonrec             NUMBER;
      v_amdmntind              VARCHAR2 (10);
      v_orgnlmndtid            VARCHAR2 (35);
      v_numdomis               NUMBER;
      v_numdomismisma          NUMBER;
      v_orgnlmntid             domiciliaciones.idnotif2%TYPE;
      v_codisoiban             paises.codisoiban%TYPE;
      v_ctipo                  NUMBER;
      v_tdescrip               VARCHAR2 (300);
      v_es_renovacion          NUMBER;
      v_fefecto_noti           DATE;
      v_diasnoti               NUMBER;
      v_conta_noti             NUMBER;
      v_spersonrec1            NUMBER;
      v_per_notif_prefe        NUMBER;
      v_email                  VARCHAR2 (100);
      v_asunto                 VARCHAR (200);
   BEGIN
      vpasexec := 10;
      v_idioma := pac_md_common.f_get_cxtidioma;                        --rdd
      vpasexec := 15;

      SELECT seq_domi_sepa.NEXTVAL
        INTO viddomisepa
        FROM DUAL;

      vpasexec := 20;
      vpar := vparini;

      /* BEGIN
          SELECT COUNT(1)
            INTO vnumori
            FROM domiciliaciones d
           WHERE sproces = psproces
             AND ccobban = xccobban
             AND GREATEST(fefecto, fefecrec) = xfefecto
             AND cerror = 0
             AND cramo = xcramo;
       EXCEPTION
          WHEN NO_DATA_FOUND THEN
             vnumori := 0;
       END;*/

      /* FOR cur IN cur_domiciliac LOOP
           vnumori := vnumori + 1;

           SELECT itotalr
             INTO v_vatcn
             FROM vdetrecibos
            WHERE nrecibo = cur.nrecibo;

           v_totalr := v_totalr + v_vatcn;
           vpasexec := xcempres;
        END LOOP;*/
      /* FOR curi IN cur_rec_domi LOOP
          p_tab_error(f_sysdate, f_user, 'f_set_domi_sepa_pago', 4,
                      'curi.nrecibo: ' || curi.nrecibo, NULL);

          SELECT itotalr
            INTO v_irecibo
            FROM vdetrecibos
           WHERE nrecibo = curi.nrecibo;

          v_totalr := v_totalr + v_irecibo;
       END LOOP;*/
      BEGIN
         error := f_desempresa (pcempres, NULL, v_inigptynm);
         vpasexec := 40;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_inigptynm := 1;
            vpasexec := 50;
      END;

      BEGIN
         SELECT fefecto
           INTO v_fefecto
           FROM domiciliaciones_cab
          WHERE sproces = psproces;

         vpasexec := 70;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_fefecto := NULL;
      END;

      --domiciliaciones_sepa

      --error := f_cobrador(xccobban, xnnumnif, xtsufijo, xcdoment, xcempres,
        --                     xcdomsuc, xncuenta, xnifcob);
      BEGIN
         xcempres := pcempres;
         error := f_nifempresa (xcempres, v_numnif);
         vpasexec := 80;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_numnif := -1;
      END;

      vpasexec := 81;

      OPEN cur_remesa;

      vpasexec := 82;

      FETCH cur_remesa
       INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;

      BEGIN
         vpasexec := 83;

         SELECT cb.tsufijo, cb.ctipban, cb.ncuenta
           INTO v_sufijo, v_ctipban, v_cbancario   --rdd v_ctipban,ncuenta new
           FROM cobbancario cb
          WHERE cb.ccobban = xccobban;

         vpasexec := 90;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_sufijo := -1;
      END;

      IF v_ctipban IN (1)
      THEN
         vpasexec := 91;

         SELECT DISTINCT NVL (MAX (codisoiban), 'ES')
                    --rdd ctipban = 1 = españa (ccc)
         INTO            v_codisoiban
                    FROM paises
                   WHERE cpais = NVL (f_parinstalacion_n ('PAIS_DEF'), 42);
      ELSE
         vpasexec := 92;
         v_codisoiban := SUBSTR (v_cbancario, 1, 2);
      END IF;

      vpasexec := 93;
      error :=
          f_get_ident_interv (v_numnif, v_sufijo, v_codisoiban, v_inigtpty_id);
      vpasexec := 100;

      INSERT INTO domi_sepa
                  (iddomisepa, credttm, nboftxs, ctrlsum,
                   initgpty_nm_3, othr_id_6, msgid
                  )
           VALUES (viddomisepa, v_fefecto, 0, 0 /* vnumori, v_totalr*/,
                   v_inigptynm,
                               /*v_numnif*/
                               v_inigtpty_id, psproces
                  );

      vpasexec := 110;
      v_totaldomi := 0;
      v_totalnumdomi := 0;

      BEGIN
         SELECT ctipo, tdescrip
           INTO v_ctipo, v_tdescrip
           FROM cfg_plantillas_tipos
          WHERE ttipo = 'RENOVACION';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;

      WHILE cur_remesa%FOUND
      LOOP
         v_numdomi := v_numdomi + 1;

         BEGIN
            vpasexec := 111;

            SELECT   COUNT (1)
                INTO vnumori
                FROM domiciliaciones d
               WHERE sproces = psproces AND ccobban = xccobban
                                                               --AND GREATEST(fefecto, fefecrec) = xfefecto
                                                              --AND cramo = xcramo
                     AND cerror = 0
            ORDER BY fefecto;
          --Jesus y Claudio :  La relacion de las tablas son 1 - 1 - n.
         --por un problema de la version de la DD.BB. ( upgrade to 11.2.0.3 )
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               vnumori := 0;
         END;

         BEGIN
            vpasexec := 112;

            SELECT seq_domi_sepa_pago.NEXTVAL
              INTO viddomisepapago
              FROM DUAL;
         END;

         vpasexec := 120;

         /*BEGIN
            SELECT DISTINCT codisoiban
                       INTO v_pais
                       FROM paises
                      WHERE cpais = NVL(f_parinstalacion_n('PAIS_DEF'), 42);
         --WHERE tpais = 'ESPAÑA';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               v_pais := NULL;
         END;*/
         BEGIN
            vpasexec := 121;

            SELECT ncuenta, ctipban
              INTO v_cbancario, v_ctipban
              FROM cobbancario
             WHERE ccobban = xccobban;

            IF v_ctipban IN (1)
            THEN
               vpasexec := 122;

               SELECT DISTINCT NVL (MAX (codisoiban), 'ES')
                          --rdd ctipban = 1 = españa (ccc)
               INTO            v_pais
                          FROM paises
                         WHERE cpais =
                                     NVL (f_parinstalacion_n ('PAIS_DEF'), 42);
            ELSE
               v_pais := SUBSTR (v_cbancario, 1, 2);
            END IF;

            vpasexec := 123;

            IF v_ctipban = 1
            THEN
               v_iban := f_convertir_ccc_iban (v_cbancario, v_pais);
            ELSE
               v_iban := v_cbancario;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_cbancario := NULL;
               v_ctipban := -1;
            WHEN OTHERS
            THEN
               v_cbancario := NULL;
               v_ctipban := -1;
         END;

         v_totalr := 0;
         vpasexec := 124;

         FOR curi IN cur_rec_domi
         LOOP
            vpasexec := 125;

            SELECT itotalr
              INTO v_irecibo
              FROM vdetrecibos
             WHERE nrecibo = curi.nrecibo;

            vpasexec := 126;
            v_totalr := v_totalr + v_irecibo;
         END LOOP;

         BEGIN
            vpasexec := 127;

            SELECT cbic
              INTO v_cbic
              FROM bancos
             WHERE cbanco = xcdoment;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               v_cbic := NULL;
         END;

         vpasexec := 140;
         --Para diferenciar de algun modo los pagos añadimos un contador
         aux_v_inigtpty_id := v_inigtpty_id || '-' || v_numdomi;

         -- Se verifica si es el primer recibo domiciliado = 'FRST'
         IF NVL (pac_parametros.f_parempresa_t (19, 'FRST_SEPA'), 0) = 1
         THEN
--SI TENEMOS CONFIGURADO EN UN PARAMETRO DE EMPRESA QUE SERA EL PRIMER SEPA QUE ENVIEMOS
            v_cd_seqtp_3 := 'FRST';
         END IF;

         vpasexec := 141;

         INSERT INTO domi_sepa_pago
                     (iddomisepa, idpago, pmtinfid, pmtmtd,
                      btchbookg, nboftxs, ctrlsum, svclvl_cd_4,
                      lclinstrm_cd_4, pmttpinf_seqtp_3, reqdcolltndt,
                      cdtr_nm_3, pstladr_ctry_4, id_iban_4, fininstnid_bic_4,
                      othr_id_6, schmenm_prtry_7
                     )
              VALUES (viddomisepa, viddomisepapago, viddomisepapago,
                                                                     -- aux_v_inigtpty_id,
                      'DD',
                      'true', vnumori, v_totalr, 'SEPA',
                      'COR1', v_cd_seqtp_3, xfefecto,
                      v_inigptynm, v_pais, v_iban, v_cbic,
                      v_inigtpty_id, 'SEPA'
                     );

         vpasexec := 142;
         v_totalnumdomi := v_totalnumdomi + vnumori;
         v_totaldomi := v_totaldomi + v_totalr;
         --3ª Parte
         vpasexec := 143;

         OPEN cur_domiciliac;

         vpasexec := 144;

         FETCH cur_domiciliac
          INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment, xcdomsuc,
               vsmovrec, xvidnotfi2, xvfidnotif2, vsseguro, xcbancar,
               xvctipbandomi;

         vpasexec := 145;

         WHILE cur_domiciliac%FOUND
         LOOP
            vpasexec := 150;
            vpar := vparini || ' rec=' || xnrecibo;

            BEGIN
               SELECT seq_domi_sepa_pago_detalle.NEXTVAL
                 INTO viddomisepapagodetalle
                 FROM DUAL;
            END;

            vpasexec := 151;

            IF xvctipbandomi = 1
            THEN
               v_iban_det := f_convertir_ccc_iban (xcbancar, 'ES');
            ELSE
               v_iban_det := xcbancar;
            END IF;

--dlf - Jesus - IBAN de la cuenta del Tomador ---------------------
--2014.III.18.-----------------------------------------------------
            BEGIN
               vpasexec := 152;

               --la configuración es diferente para Malta
               SELECT cbic                                               --rdd
                 INTO v_cbic
                 FROM bancos b, tipos_cuenta tc
                WHERE tc.ctipban = xvctipbandomi
                  AND b.cbanco =
                         SUBSTR (DECODE (tc.ctipban, 1, xcbancar, v_iban_det),
                                 tc.pos_entidad,
                                 tc.long_entidad
                                )
                  AND b.cbanco = NVL (tc.cbanco, b.cbanco);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_cbic := NULL;
               WHEN OTHERS
               THEN
                  v_cbic := NULL;
            END;

            BEGIN
               vpasexec := 153;

               SELECT itotalr
                 INTO v_totalrecibo
                 FROM vdetrecibos
                WHERE nrecibo = xnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_totalrecibo := 0;
            END;

            BEGIN
               vpasexec := 154;

               SELECT smovrec
                 INTO v_smovrecibo
                 FROM movrecibo
                WHERE nrecibo = xnrecibo AND fmovfin IS NULL;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_smovrecibo := 0;
            END;

            vpasexec := 155;
            pac_domis.p_recibo_nombre (psproces,
                                       vsseguro,
                                       v_idioma,
                                       v_nombre,
                                       v_sperson,
                                       v_domici
                                      );
            vpasexec := 160;
            error :=
               pac_propio.f_trecibo (xnrecibo,
                                     v_idioma,
                                     vlin1,
                                     vlin2,
                                     vlin3,
                                     vlin4,
                                     vlin5,        --rdd agregando el v_idioma
                                     vlin6,
                                     vlin7,
                                     vlin8
                                    );
            vpasexec := 170;
            /*
            v_ustrd :=
               CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(CONCAT(TRIM(vlin1), TRIM(vlin2)),
                                                         TRIM(vlin3)),
                                                  TRIM(vlin4)),
                                           TRIM(vlin5)),
                                    TRIM(vlin6)),
                             TRIM(vlin7)),
                      TRIM(vlin8));
            */
            v_ustrd :=
               REPLACE (   TRIM (vlin1)
                        || ' '
                        || TRIM (vlin2)
                        || ' '
                        || TRIM (vlin3)
                        || ' '
                        || TRIM (vlin4)
                        || ' '
                        || TRIM (vlin5)
                        || ' '
                        || TRIM (vlin6)
                        || ' '
                        || TRIM (vlin7)
                        || ' '
                        || TRIM (vlin8),
                        '  ',
                        ' '
                       );
            vpasexec := 171;

            IF (LENGTH (v_ustrd) > 140)
            THEN
               v_ustrd := SUBSTR (REPLACE (v_ustrd, '  ', ' '), 1, 140);
            END IF;

            vpasexec := 180;

            --Buscamos el sperson en recibos, si no lo encontramos lo cogemos del tomador
            BEGIN
               vpasexec := 181;

               SELECT NVL (sperson, -1)
                 INTO v_spersonrec
                 FROM recibos
                WHERE nrecibo = xnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_spersonrec := -1;
               WHEN OTHERS
               THEN
                  v_spersonrec := -1;
            END;

            vpasexec := 182;

            IF v_spersonrec = -1
            THEN
               v_spersonrec := ff_sperson_tomador (vsseguro);
            END IF;

            IF v_spersonrec != -1
            THEN
               BEGIN
                  vpasexec := 182;

                  SELECT nnumide
                    INTO v_numide
                    FROM per_personas
                   WHERE sperson = v_spersonrec;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_numide := '-1';
               END;
            END IF;

            --Ha habido alguna domiciliación con un idnotif diferente
            BEGIN
               vpasexec := 183;

               SELECT COUNT (1)
                 INTO v_numdomis
                 FROM domiciliaciones
                WHERE idnotif2 != xvidnotfi2 AND sseguro = vsseguro;

               IF v_numdomis > 0
               THEN
                  -- ¿Ësta domiciliación ya se ha enviado con anterioridad?
                  vpasexec := 184;

                  SELECT COUNT (1)
                    INTO v_numdomismisma
                    FROM domiciliaciones
                   WHERE idnotif2 = xvidnotfi2 AND sseguro = vsseguro;

                  vpasexec := 185;

                  IF v_numdomismisma > 1
                  THEN
                     --Se ha enviado con anterioridad el mismo
                     v_amdmntind := 'false';
                  ELSE
                     -- Se ha enviado con anterioridad uno diferente
                     v_amdmntind := 'true';
                  END IF;
               ELSE
                  --No se ha enviado con anterioridad
                  v_amdmntind := 'false';
               END IF;
            END;

            IF v_amdmntind = 'true'
            THEN
               vpasexec := 186;

               SELECT idnotif2
                 INTO v_orgnlmntid
                 FROM domiciliaciones
                WHERE idnotif2 != xvidnotfi2
                  AND sseguro = vsseguro
                  AND ROWNUM = 1;                 --Si hay más de uno fallaría
            END IF;

            vpasexec := 187;

            INSERT INTO domi_sepa_pago_detalle
                        (iddomisepa, idpago,
                         iddetalle, pmtid_instrid_4, pmtid_endtoendid_4,
                         drctdbttxinf_instdamt_3, mndtritdinf_mndtid_5,
                         mndtritdinf_dtofsgntr_5, mndtritdinf_amdmntind_5,
                         amdmntind_orgnlmndtid_6, fininstnid_bic_5,
                         dbtr_nm_4, othr_id_7, id_iban_5, rmtinf_ustrd_4
                        )
                 VALUES (viddomisepa, viddomisepapago,
                         viddomisepapagodetalle, v_smovrecibo, xnrecibo,
                         v_totalrecibo, xvidnotfi2,
                         xvfidnotif2, v_amdmntind,
                         v_orgnlmntid, v_cbic,
                         v_nombre, v_numide, v_iban_det, v_ustrd
                        );

            vpasexec := 188;

            FETCH cur_domiciliac
             INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment, xcdomsuc,
                  vsmovrec, xvidnotfi2, xvfidnotif2, vsseguro, xcbancar,
                  xvctipbandomi;
         END LOOP;

         vpasexec := 189;

         CLOSE cur_domiciliac;

         vpasexec := 190;

         UPDATE domi_sepa
            SET nboftxs = vnumori,
                ctrlsum = v_totalr
          WHERE iddomisepa = viddomisepa;

         vpasexec := 191;

         IF v_ctipo IS NOT NULL
         THEN
            BEGIN
               SELECT NVL (m.diasnoti, 0)
                 INTO v_diasnoti
                 FROM medcobpro m, recibos r, seguros s
                WHERE r.nrecibo = xnrecibo
                  AND s.sseguro = r.sseguro
                  AND m.cramo = s.cramo
                  AND m.cmodali = s.cmodali
                  AND m.ctipseg = s.ctipseg
                  AND m.ccolect = s.ccolect
                  AND m.ctipcob = 2;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  v_diasnoti := 0;
            END;

            vpasexec := 1910;

            SELECT r.ctiprec
              INTO v_es_renovacion
              FROM recibos r
             WHERE r.nrecibo = xnrecibo;

            vpasexec := 1911;

            IF v_es_renovacion = 3
            THEN
               vpasexec := 1912;

               SELECT fefecto
                 INTO v_fefecto_noti
                 FROM recibos
                WHERE nrecibo = xnrecibo;

               IF v_diasnoti <> 0
               THEN
                  IF     (v_fefecto_noti <= f_sysdate + v_diasnoti)
                     AND (v_fefecto_noti > f_sysdate)
                  THEN
                     -- 1.5.1.- Miramos si ya hemos notificado o no para esa póliza y fecha
                     vpasexec := 1913;

                     SELECT COUNT (1)
                       INTO v_conta_noti
                       FROM notificaseg
                      WHERE sseguro = vsseguro
                        AND ctipo = v_ctipo
                        AND fecha = v_fefecto_noti;

                     -- 1.5.2.- Si no hemos notificado
                     IF v_conta_noti = 0
                     THEN
                        vpasexec := 1914;

                        SELECT t.sperson
                          INTO v_spersonrec1
                          FROM tomadores t
                         WHERE t.sseguro = vsseguro
                           AND t.nordtom = (SELECT MIN (t1.nordtom)
                                              FROM tomadores t1
                                             WHERE t1.sseguro = vsseguro);

                        vpasexec := 1915;

                        -- 1.5.3.- Obtener el método de notificación por defecto. Si es correo postal o email, entonces se deberá llamar a pac_isql.p_docs_renovacion
                        BEGIN
                           SELECT nvalpar
                             INTO v_per_notif_prefe
                             FROM per_parpersonas
                            WHERE cparam = 'PER_NOTIF_PREFE'
                              AND sperson = v_spersonrec1;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              v_per_notif_prefe := 0;
                        END;

                        vpasexec := 1916;

                        -- v_per_notif_prefe = 0 --> Por correo postal
                        -- v_per_notif_prefe = 1 --> Por email
                        IF v_per_notif_prefe IN (0, 1)
                        THEN                -- Postal o Por correo electronico
                           -- 1.- Recuperar el email de la persona:
                           SELECT MAX (p1.tvalcon)
                             INTO v_email
                             FROM per_contactos p1
                            WHERE p1.sperson = v_spersonrec1
                              AND p1.ctipcon = 3
                              AND p1.cmodcon IN (
                                     SELECT MIN (cmodcon)
                                       FROM per_contactos p2
                                      WHERE p2.sperson = p1.sperson
                                        AND p2.ctipcon = p1.ctipcon);

                           vpasexec := 1917;

                           IF v_email IS NOT NULL
                           THEN
                              vpasexec := 1918;
                              v_asunto := v_tdescrip;
                              pac_isql.p_docs_renovacion (psproces,
                                                          vsseguro,
                                                          v_email,
                                                          v_asunto
                                                         );
                           ELSE
                              pac_isql.p_docs_renovacion (psproces,
                                                          vsseguro,
                                                          NULL,
                                                          NULL
                                                         );
                           END IF;
                        END IF;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         FETCH cur_remesa
          INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;
      END LOOP;

      vpasexec := 192;

      UPDATE domi_sepa
         SET nboftxs = v_totalnumdomi,
             ctrlsum = v_totaldomi
       WHERE iddomisepa = viddomisepa;

      vpasexec := 193;

      CLOSE cur_remesa;

--            CLOSE cur_domiciliac;
      --COMMIT;
      vpasexec := 194;
      RETURN viddomisepa;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMIS.f_set_domiciliaciones_sepa',
                      vpasexec,
                      vpar,
                      SQLCODE || ' ' || SQLERRM
                     );
         -- BUG 0036641 JMF 23-06-2015
         -- la funcion devuelve el identificador, asi que si hay error
         -- devuelvo error en negativo para diferenciar.
         RETURN -107914;
         ROLLBACK;
   END f_set_domiciliaciones_sepa;

   --
-----------------------------------------------------------------------------
   FUNCTION f_cobrament (
      psproces        IN       NUMBER,
      pcempres        IN       NUMBER,
      pmincobdom               DATE,
      pfefecto        IN       DATE,
      pfcobro         IN       DATE,
      pcidioma        IN       NUMBER,
      pcramo          IN       NUMBER,
      pcmodali        IN       NUMBER,
      pctipseg        IN       NUMBER,
      pccolect        IN       NUMBER,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban        IN       NUMBER,
      pcbanco         IN       NUMBER,
      pctipcta        IN       NUMBER,
      pfvtotar        IN       VARCHAR2,
      pcreferen       IN       VARCHAR2,
      pdfefecto       IN       DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente        IN       NUMBER,
      ptagente        IN       VARCHAR2,
      pnnumide        IN       VARCHAR2,
      pttomador       IN       VARCHAR2,
      pnrecibo        IN       NUMBER,
      --FI BUG 23645
      pnum_ok         OUT      NUMBER,
      pnum_ko         OUT      NUMBER,
      pdomisibanxml   IN       NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
-------------------------------------------------------------------------------------
-- S'omple la taula domiciliaciones amb els rebuts que volem domiciliar ,
-- els cobra i guarda l'estat, si ha anat be o no
      estat            NUMBER;
      xcontad          NUMBER                         := 0;
      xfsituac         DATE;
      xfmovim          DATE;

      TYPE t_cursor IS REF CURSOR;

      c_rebuts         t_cursor;
      v_sel            VARCHAR2 (4000);
      lcfeccob         productos.cfeccob%TYPE;                  --NUMBER(10);
      lpgasint         productos.pgasint%TYPE;                  --NUMBER(10);
      lpgasext         productos.pgasext%TYPE;                  --NUMBER(10);
      lsproduc         productos.sproduc%TYPE;                  --NUMBER(10);
      lefecto          VARCHAR2 (10);
      lnliqlin         NUMBER;
      lnliqmen         NUMBER;
      lsmovagr         NUMBER;
      num_err          NUMBER;
      num_err2         NUMBER;
      xnprolin         NUMBER;
      texto            VARCHAR2 (400);
      lprodusu         NUMBER;
      lcerror          NUMBER;
      -- bug 8416
      vtvalpar         parempresas.tvalpar%TYPE;

      -- bug 8416
      TYPE registre IS RECORD (
         sseguro         seguros.sseguro%TYPE,
         empresa         VARCHAR2 (200),
         producto        VARCHAR2 (100),
         codbancar       VARCHAR2 (200),
         cobrador        VARCHAR2 (100),
         nrecibo         NUMBER,                                       --(9);
         npoliza         VARCHAR2 (20),                                --(8);
         tipo_recibo     VARCHAR2 (100),
         tomador         VARCHAR2 (200),
         fefecto         DATE,
         fvencim         DATE,
         cbancar         seguros.cbancar%TYPE,
         itotalr         NUMBER,                                    --(15,2);
         ctipban_cobra   seguros.ctipban%TYPE,
         ctipban_cban    seguros.ctipban%TYPE,                         --(1);
         proceso         NUMBER,                                     --(100);
         fichero         VARCHAR2 (500),
         -- BUG 18825 - 19/07/2011 - JMP
         estado          detvalores.tatribu%TYPE,
         testimp         VARCHAR2 (500),
         estdomi         detvalores.tatribu%TYPE,
         festado         DATE             -- FIN BUG 18825 - 19/07/2011 - JMP
                             -- 29. 0021718 / 0111176 - Inicio
         ,
         cagente         recibos.cagente%TYPE,
         tagente         VARCHAR2 (500),
         nanuali         recibos.nanuali%TYPE,
         nfracci         recibos.nfracci%TYPE,
         frecaudo        DATE,                                        --22080
         frechazo        DATE,                                        --22080
         cdevrec         devbanrecibos.cdevrec%TYPE                   --22080
      -- 29. 0021718 / 0111176 - Fin
      );

      r_nrecibo        recibos.nrecibo%TYPE;
      r_ccobban        cobbancario.ccobban%TYPE;
      c_tsufijo        cobbancario.tsufijo%TYPE;
      c_cdoment        cobbancario.cdoment%TYPE;
      c_cdomsuc        cobbancario.cdomsuc%TYPE;
      s_sproduc        productos.sproduc%TYPE;
      s_cramo          productos.cramo%TYPE;
      s_cmodali        productos.cmodali%TYPE;
      s_ctipseg        productos.ctipseg%TYPE;
      s_ccolect        productos.ccolect%TYPE;
      m_fmovini        movrecibo.fmovini%TYPE;
      r_cagente        recibos.cagente%TYPE;
      s_cagrpro        productos.cagrpro%TYPE;
      s_ccompani       productos.ccompani%TYPE;
      r_cempres        empresas.cempres%TYPE;
      e_ctipemp        empresas.ctipemp%TYPE;
      r_sseguro        seguros.sseguro%TYPE;
      r_ctiprec        recibos.ctiprec%TYPE;
      r_cbancar        recibos.cbancar%TYPE;
      r_nmovimi        recibos.nmovimi%TYPE;
      r_fefecto        recibos.fefecto%TYPE;
      r_ctipban        recibos.ctipban%TYPE;
      rec              registre;
      rec_mandatos     mandatos%ROWTYPE;
      -- BUG 0019999 - 14/11/2011 - JMF
      v_cobra_recdom   parempresas.nvalpar%TYPE;
      vsperson         NUMBER (10);
      vcnordban        NUMBER (2);

      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      CURSOR c_prod
      IS
         SELECT *
           FROM domisaux
          WHERE sproces = psproces;

      -- FI Bug 15750 - FAL - 27/08/2010
      v_num_err        NUMBER;                 -- Bug 21116 - APD - 27/01/2012
      vtdescrip        cobbancario.descripcion%TYPE;
      -- Bug 21116 - APD - 27/01/2012
      vtcobban         cobbancario.tcobban%TYPE;
      --AGG MODIFICACIONES SEPA
      vidnotif2        VARCHAR2 (100)                 := NULL;
      vfidenotif2      DATE                           := NULL;
      -- Bug 21116 - APD - 27/01/2012
      --Bug  34789
      vreg             NUMBER;
   BEGIN
      lefecto := TO_CHAR (pfefecto + 1, 'dd/mm/yyyy');

      IF     pcramo IS NOT NULL
         AND pcmodali IS NOT NULL
         AND pctipseg IS NOT NULL
         AND pccolect IS NOT NULL
      THEN
         BEGIN
            SELECT sproduc
              INTO lprodusu
              FROM productos
             WHERE cramo = pcramo
               AND cmodali = pcmodali
               AND ctipseg = pctipseg
               AND ccolect = pccolect;
         EXCEPTION
            WHEN OTHERS
            THEN
               lprodusu := NULL;
         END;
      ELSE
         lprodusu := NULL;
      END IF;

      -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
      -- Añadimos 'RECUNIF' y tratamiento cestaux = 2
      --MCC/ 06/04/2009 / BUG 0009730: CEM - Recibos reunificados y domiciliaciones

      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
      FOR reg IN c_prod
      LOOP
         SELECT sproduc
           INTO lprodusu
           FROM productos
          WHERE cramo = reg.cramo
            AND cmodali = reg.cmodali
            AND ctipseg = reg.ctipseg
            AND ccolect = reg.ccolect;

         -- pcramo := reg.cramo;
         -- JGM - bug 11339 - 08/10/2009
         v_sel :=
            pac_domis.f_retorna_query (TO_CHAR (pfefecto, 'ddmmyyyy'),
                                       reg.cramo,
                                       lprodusu,
                                       pcempres,
                                       NULL,
                                       FALSE,
                                       pccobban,
                                       pcbanco,
                                       pctipcta,
                                       pfvtotar,
                                       pcreferen,
                                       TO_CHAR (pdfefecto, 'ddmmyyyy'),
                                       pcagente,
                                       ptagente,
                                       pnnumide,
                                       pttomador,
                                       pnrecibo
                                      );
         -- Fi Bug 15750 - FAL - 27/08/2010
         lsproduc := -1;
         lprodusu := 0;

         INSERT INTO informes_err
              VALUES (v_sel);

         OPEN c_rebuts FOR v_sel;

         LOOP
            FETCH c_rebuts
             INTO rec;

            EXIT WHEN c_rebuts%NOTFOUND;

            BEGIN
               SELECT r.nrecibo, r.ccobban, r.cagente, r.cempres, r.sseguro,
                      r.ctiprec, r.cbancar, r.nmovimi, r.fefecto, r.ctipban
                 INTO r_nrecibo, r_ccobban, r_cagente, r_cempres, r_sseguro,
                      r_ctiprec, r_cbancar, r_nmovimi, r_fefecto, r_ctipban
                 FROM recibos r
                WHERE nrecibo = rec.nrecibo;

               SELECT c.tsufijo, c.cdoment, c.cdomsuc
                 INTO c_tsufijo, c_cdoment, c_cdomsuc
                 FROM cobbancario c
                WHERE c.ccobban = r_ccobban;

               --|| '-' || c.descripcion = rec.codbancar;
               SELECT s.sproduc, s.cramo, s.cmodali, s.ctipseg, s.ccolect,
                      s.cagrpro, s.ccompani
                 INTO s_sproduc, s_cramo, s_cmodali, s_ctipseg, s_ccolect,
                      s_cagrpro, s_ccompani
                 FROM seguros s
                WHERE s.sseguro = r_sseguro;

               --s.npoliza || '-' || s.ncertif = rec.npoliza;
               SELECT m.fmovini
                 INTO m_fmovini
                 FROM movrecibo m
                WHERE m.nrecibo = rec.nrecibo
                  AND m.cestrec = 0
                  AND m.fmovfin IS NULL;

               SELECT e.ctipemp
                 INTO e_ctipemp
                 FROM empresas e, seguros s
                WHERE s.sseguro = r_sseguro
                                           --s.npoliza || '-' || s.ncertif = rec.npoliza;
                      AND s.cempres = e.cempres;
            END;

            IF lsproduc <> s_sproduc
            THEN
               -- Es mira si l'usuari te restringit el producte (1-Pot cobrar 0 - no pot)
               lprodusu :=
                      f_produsu (s_cramo, s_cmodali, s_ctipseg, s_ccolect, 5);

               -- Canviem la data d'efecte per la de cobrament en cas de que ho
               -- digui el producte (cfeccob = 1 s'ha de canviar)
               SELECT cfeccob, pgasint, pgasext
                 INTO lcfeccob, lpgasint, lpgasext
                 FROM productos
                WHERE sproduc = s_sproduc;

               lsproduc := s_sproduc;
            END IF;

            --AGG 10/12/2013 MODIFICACIONES SEPA
            --Obtenemos los datos correspondientes al mandato
            IF NVL (pac_parametros.f_parempresa_n (pcempres, 'DOMIS_IBAN_XML'),
                    0
                   ) = 1
            THEN
               rec_mandatos :=
                  pac_sepa.f_get_mandatos (rec.sseguro,
                                           r_ccobban,
                                           rec.cbancar,
                                           r_ctipban
                                          );
               vidnotif2 := rec_mandatos.cmandato;
               vfidenotif2 := rec_mandatos.ffirma;
            END IF;

            --fin AGG
            IF lprodusu = 1
            THEN
               IF NVL (lcfeccob, 0) = 1
               THEN
                  xfmovim := NVL (pfcobro, m_fmovini);
               ELSE
                  IF m_fmovini < pmincobdom
                  THEN
                     xfmovim := pmincobdom;
                  ELSE
                     xfmovim := m_fmovini;
                  END IF;
               END IF;

               -- Guardem a domiciliaciones
               BEGIN
                  INSERT INTO domiciliaciones
                              (sproces, nrecibo, ccobban, cempres,
                               fefecto, cdoment, cdomsuc, tsufijo,
                               cagente, cagrpro, ccompani, ctipemp,
                               sseguro, ctiprec, cbancar, nmovimi,
                               cramo, cmodali, ctipseg, ccolect,
                               pgasint, pgasext, cfeccob, fefecrec,
                               ctipban, idnotif2, fidenotif2
                              )
                       VALUES (psproces, r_nrecibo, r_ccobban, pcempres,
                               xfmovim, c_cdoment, c_cdomsuc, c_tsufijo,
                               r_cagente, s_cagrpro, s_ccompani, e_ctipemp,
                               r_sseguro, r_ctiprec, rec.cbancar, r_nmovimi,
                               s_cramo, s_cmodali, s_ctipseg, s_ccolect,
                               lpgasint, lpgasext, lcfeccob, rec.fefecto,
                               r_ctipban, vidnotif2, vfidenotif2
                              );

                  xcontad := xcontad + 1;

                  -- BUG 18825 - 19/07/2011 - JMP
                  IF xcontad = 1
                  -- 29. JGR 03/04/2012 - 0021718 / 0111176 - Inicio
                  THEN
                     num_err :=
                        pac_domiciliaciones.f_set_domiciliacion_cab
                                                                  (pcempres,
                                                                   psproces,
                                                                   r_ccobban,
                                                                   f_sysdate,
                                                                   --jds 03/07/2013, 0027150 (4º param se cambia por f_sysdate)
                                                                   NULL,
                                                                   NULL,
                                                                   1,
                                                                   NULL,
                                                                   NULL,
                                                                   pcidioma
                                                                  );

                     IF num_err <> 0
                     THEN
                        texto :=
                           SUBSTR (f_axis_literales (num_err, pcidioma),
                                   1,
                                   120
                                  );
                        num_err2 :=
                           f_proceslin (psproces, texto, rec.nrecibo,
                                        xnprolin);
                        COMMIT;
                        RETURN num_err;
                     END IF;
                  -- 29. JGR 03/04/2012 - 0021718 / 0111176 - Fin
                  END IF;
               -- FIN BUG 18825 - 19/07/2011 - JMP
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     ROLLBACK;
                     xnprolin := NULL;
                     texto := f_axis_literales (102920, pcidioma);
                     texto := SUBSTR (texto || SQLERRM, 1, 120);
                     num_err :=
                         f_proceslin (psproces, texto, rec.nrecibo, xnprolin);
                     COMMIT;
                     RETURN 102920;     -- Registre repetit a DOMICILIACIONES
                  WHEN OTHERS
                  THEN
                     ROLLBACK;
                     xnprolin := NULL;
                     texto := f_axis_literales (105058, pcidioma);
                     texto := SUBSTR (texto || SQLERRM, 1, 120);
                     num_err :=
                         f_proceslin (psproces, texto, rec.nrecibo, xnprolin);
                     COMMIT;
                     RETURN 105058;   -- Error a l' inserir a DOMICILIACIONES
               END;
            END IF;
         END LOOP;
      END LOOP;

      COMMIT;

      IF xcontad = 0
      THEN
         RETURN 102903;                       -- No s' ha trobat cap registre
      END IF;

      -- Bug 19986 - APD - 04/11/2011 - agrupa recibos domiciliados
      num_err := pac_domis.f_agrupa_recibos_domiciliados (psproces);

      IF num_err <> 0
      THEN
         xnprolin := NULL;
         texto := f_axis_literales (9901207, pcidioma);
         -- Error unificando los recibos
         num_err := f_proceslin (psproces, texto, 0, xnprolin);
         COMMIT;
      END IF;

      -- Fin Bug 19986 - APD - 04/11/2011
      ----

      -- BUG 0019999 - 14/11/2011 - JMF
      v_cobra_recdom :=
             NVL (pac_parametros.f_parempresa_n (pcempres, 'COBRA_RECDOM'), 1);
      -- Bug 19999 - APD - 07/11/2011 - el cobro de los recibos se pasa a la nueva funcion f_estado_domiciliacion
      num_err :=
         pac_domis.f_estado_domiciliacion (pcempres,
                                           psproces,
                                           NULL,
                                           v_cobra_recdom,
                                           pnum_ok,
                                           pnum_ko
                                          );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      -- fin Bug 19999 - APD - 07/11/2011

      ----
      BEGIN
         DELETE FROM domiciliaciones
               WHERE sproces = psproces AND NVL (cerror, 1) <> 0;

         --Bug 34789  Si no existen lineas de domiciliaciones, se borra también la cabecera
         SELECT COUNT ('x')
           INTO vreg
           FROM domiciliaciones
          WHERE sproces = psproces;

         IF vreg = 0
         THEN
            DELETE FROM domiciliaciones_cab
                  WHERE sproces = psproces;
         END IF;
      --  Fin Bug 34789
      EXCEPTION
         WHEN OTHERS
         THEN
            xnprolin := NULL;
            texto := f_axis_literales (112491, pcidioma);
            texto := SUBSTR (texto || ' ' || SQLERRM, 1, 120);
            num_err := f_proceslin (psproces, texto, 0, xnprolin);
            COMMIT;
            RETURN 112491;
      END;

      RETURN 0;
   END f_cobrament;

-----------------------------------------------------------------------------
   FUNCTION f_domrecibos (
      pctipemp   IN       NUMBER,
      pcidioma   IN       NUMBER,
      psproces   IN       NUMBER,
      pruta      OUT      VARCHAR2,
      pfcobro    IN       DATE
            DEFAULT NULL                 --> -- Bug.: 13498 - JGR - 04/03/2010
   )
      RETURN NUMBER
   IS
      v_pas              NUMBER                         := 0;
      v_obj              VARCHAR2 (500)           := 'pac_domis.f_domrecibos';
      v_par              VARCHAR2 (3000)
         :=    't='
            || pctipemp
            || ' i='
            || pcidioma
            || ' s='
            || psproces
            || ' f='
            || pfcobro;
--      xtsufijo       VARCHAR2(3); -- 30. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 (-)
      xtsufijo           cobbancario.tsufijo%TYPE;
-- 30. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 (+)
      xtsufpresentador   VARCHAR2 (3);
      xctipban           cobbancario.ctipban%TYPE;
      xccobban           cobbancario.ccobban%TYPE;
      -- Bug 20735/102170 - 29/12/2011 - JGR
      xcempres           domiciliaciones.cempres%TYPE;           --NUMBER(10);
      xcdoment           domiciliaciones.cdoment%TYPE;           --NUMBER(10);
      xcdomsuc           domiciliaciones.cdomsuc%TYPE;           --NUMBER(10);
      xnprolin           NUMBER;
      nom_fitxer         VARCHAR2 (100);
      error              NUMBER;
      xpath              VARCHAR2 (100);
      xtitulopro         VARCHAR2 (100);
--Ini AAC_0039113
      sfexists           BOOLEAN;
      sfile_length       NUMBER;
      sblocksize         BINARY_INTEGER;
--Fi AAC_0039113
      fitxer             UTL_FILE.file_type;
-- FAL. 08/07/2010. Bug 0015325: AGA - Renombrado final de los ficheros de domiciliaciones
--Ini BUG 22149 - 06/07/2012 - DCG
      nom_fitxer_ant     VARCHAR2 (200);
      v_auxparam         cobbancario.tfunc%TYPE;
      v_nompack          cobbancario.tfunc%TYPE;

--Fi BUG 22149 - 06/07/2012 - DCG
      CURSOR cur_domicxccobban
      IS
         SELECT   b.ctipban, a.cempres, a.cdoment, a.cdomsuc, b.tfunc,
                  b.ccobban
             -- Bug 20735/102170 - 29/12/2011 - JGR
         FROM     domiciliaciones a, cobbancario b
            WHERE b.ccobban = a.ccobban
              AND a.sproces = psproces
              AND a.cerror = 0
         --agg para hacer pruebas con este taller hay que comentar esta linea
         GROUP BY b.ctipban,
                  a.cempres,
                  a.cdoment,
                  a.cdomsuc,
                  b.tfunc,
                  b.ccobban
         -- Bug 20735/102170 - 29/12/2011 - JGR
         ORDER BY b.ctipban,
                  a.cempres,
                  a.cdoment,
                  a.cdomsuc,
                  b.tfunc,
                  b.ccobban
                           -- Bug 20735/102170 - 29/12/2011 - JGR
      ;

      CURSOR domici
      IS
         SELECT nrecibo, fefecto
           FROM domiciliaciones
          WHERE sproces = psproces AND cerror = 0
                                                 --agg para hacer pruebas con este taller hay que comentar esta linea
      ;

      pmarca             NUMBER;
      pfechacobro        DATE;
      -- v_tfunc        tipos_cuenta.tfunc%TYPE; -- Bug 20735/102170 - 29/12/2011 - JGR
      v_tfunc            cobbancario.tfunc%TYPE;
      -- Bug 20735/102170 - 29/12/2011 - JGR
      viddomisepa        NUMBER (8);
   BEGIN
      v_pas := 1000;
      error := 0;
      xtsufpresentador := '000';
      p_tab_error (f_sysdate,
                   f_user,
                   v_obj,
                   v_pas,
                   v_par,
                   'Entrando a f_domrecibos'
                  );
      -- Obtenim el path del servidor on es deixen els fitxers.
      /*  Bug 11835 - MCA - 01/12/2009 - Se comenta pq el path es a nivel de empresa
      xpath := f_parempresa_t('PATH_DOMIS');
      IF xpath IS NULL THEN
         RETURN 112443;
      END IF;*/
      v_pas := 1010;

      OPEN cur_domicxccobban;

      v_pas := 1020;

      FETCH cur_domicxccobban
       INTO xctipban, xcempres, xcdoment, xcdomsuc, v_tfunc, xccobban;

      -- Bug 20735/102170 - 29/12/2011 - JGR
      v_pas := 1030;

      WHILE cur_domicxccobban%FOUND
      LOOP
         --  Bug 11835 - MCA - 01/12/2009 - Se incluye aqui la recuperación del path
         v_pas := 1040;
         xpath := pac_parametros.f_parempresa_t (xcempres, 'PATH_DOMIS');

         IF xpath IS NULL
         THEN
            RETURN 112443;
         END IF;

         -- fin 11835
         v_pas := 1050;
         nom_fitxer := f_parinstalacion_t ('NOM_DOMIC');

         IF nom_fitxer IS NULL
         THEN
            v_pas := 1060;
            nom_fitxer :=
                  'DR'
               || LPAD (psproces, 6, '0')
               || '.'
               || LPAD (xcempres, 2, '0')
               || '.'
               || LPAD (xcdoment, 4, '0')
               || '.'
               || LPAD (xcdomsuc, 4, '0');
         END IF;

         -- Bug 0013153 - FAL - 18/03/2010 - Recuperar nombre fichero especifico si existe. Ó el standard de iAXIS si no definido.
         -- BUG 0019999 - 14/11/2011 - JMF: Afegir xctipban
         v_pas := 1070;
         nom_fitxer :=
            pac_nombres_ficheros.f_nom_domici (psproces,
                                               xcempres,
                                               xcdoment,
                                               xcdomsuc,
                                               -- Bug 20735/102170 - 29/12/2011 - JGR - Inicio
                                               -- xctipban
                                               xccobban
                                              -- Bug 20735/102170 - 29/12/2011 - JGR - Fin
                                              );

         IF nom_fitxer = '-1'
         THEN
            RETURN 9901092;
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      v_obj,
                      v_pas,
                      v_par,
                      'Nombre del Archivo ' || nom_fitxer
                     );

         --Ini BUG 22149 - 06/07/2012 - DCG
         IF NVL (nom_fitxer_ant, -1) <> nom_fitxer
         THEN
            --Fi BUG 22149 - 06/07/2012 - DCG
            --Ini Bug.: 12858 - ICV - 02/02/2010
            IF pruta IS NULL
            THEN
               v_pas := 1080;

               IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                      'DOMIS_IBAN_XML'
                                                     ),
                       0
                      ) = 1
               THEN
                  pruta :=
                        pac_parametros.f_parempresa_t (xcempres,
                                                       'PATH_DOMIS_C'
                                                      )
                     || '\'
                     || nom_fitxer
                     || '.xml';
               ELSE
                  pruta :=
                        pac_parametros.f_parempresa_t (xcempres,
                                                       'PATH_DOMIS_C'
                                                      )
                     || '\'
                     || nom_fitxer;
               END IF;
            ELSE
               v_pas := 1090;

               IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                      'DOMIS_IBAN_XML'
                                                     ),
                       0
                      ) = 1
               THEN
                  pruta :=
                        pruta
                     || '||'
                     || pac_parametros.f_parempresa_t (xcempres,
                                                       'PATH_DOMIS_C'
                                                      )
                     || '\'
                     || nom_fitxer
                     || '.xml';
               ELSE
                  pruta :=
                        pruta
                     || '||'
                     || pac_parametros.f_parempresa_t (xcempres,
                                                       'PATH_DOMIS_C'
                                                      )
                     || '\'
                     || nom_fitxer;
               END IF;
            END IF;
         --Ini BUG 22149 - 06/07/2012 - DCG
         END IF;

         p_tab_error (f_sysdate,
                      f_user,
                      v_obj,
                      v_pas,
                      v_par,
                      'Pruba ' || pruta
                     );

         --Fi BUG 22149 - 06/07/2012 - DCG

         -- FAL. 8/7/2010. Ini Bug 0015325. Comprobar si fichero a crear ya existe. En ese caso borrarlo
--Ini AAC_0039113
         BEGIN
            v_pas := 1100;
            UTL_FILE.fgetattr (xpath,
                               nom_fitxer,
                               sfexists,
                               sfile_length,
                               sblocksize
                              );

            IF sfexists
            THEN
               UTL_FILE.fremove (xpath, nom_fitxer);
            END IF;
         EXCEPTION
            WHEN OTHERS
            THEN                   -- si no existe fichero a crear -> correcto
               p_tab_error (f_sysdate,
                            f_user,
                            v_obj,
                            v_pas,
                            v_par,
                               'When others remover '
                            || TO_CHAR (SQLCODE)
                            || ' '
                            || SQLERRM
                           );
               NULL;
         END;

--Fi AAC_0039113
--Ini BUG 22149 - 06/07/2012 - DCG
         nom_fitxer_ant := nom_fitxer;
--Fi BUG 22149 - 06/07/2012 - DCG
         -- FAL. 8/7/2010. Fin Bug 0015325
         v_pas := 1110;
         nom_fitxer := '_' || nom_fitxer;
         -- ini BUG 0019999 - 14/11/2011 - JMF
         v_pas := 1120;

         -- Bug 20735/102170 - 29/12/2011 - JGR - Inicio
         --SELECT MAX(tfunc)
         --  INTO v_tfunc
         --  FROM tipos_cuenta
         -- WHERE ctipban = xctipban;
         -- Bug 20735/102170 - 29/12/2011 - JGR - Fin

         -- fin BUG 0019999 - 14/11/2011 - JMF

         -- Fi Bug 0013153
         --Fin Bug.: 12858
         --AGG modificaciones SEPA
         IF NVL (pac_parametros.f_parempresa_n (xcempres, 'DOMIS_IBAN_XML'),
                 0) = 1
         THEN
            v_pas := 1125;
            viddomisepa :=
               f_set_domiciliaciones_sepa (psproces,
                                           xcempres,
                                           xcdoment,
                                           xcdomsuc,
                                           pfcobro
                                          );

            -- BUG 0036641 JMF 23-06-2015
            -- la funcion devuelve el identificador, asi que si hay error
            -- devuelvo error en negativo para diferenciar.
            IF NVL (viddomisepa, 0) < 0
            THEN
               error := viddomisepa * (-1);
            ELSE
               error := 0;
            END IF;

            IF error = 0
            THEN
               error := pac_sepa.f_genera_xml_domis (xcempres, viddomisepa);
            END IF;

            IF error = 0
            THEN
               --Quitamos '_' del nombre del fichero
               error :=
                  pac_sepa.f_genera_fichero_dom_trans ('D',
                                                       viddomisepa,
                                                       SUBSTR (nom_fitxer, 2)
                                                      );
            END IF;
         ELSIF xctipban IN (2, 3)                           -- Iban o Andorra.
         THEN
            -- mantis_3873
            v_pas := 1130;
            error :=
               f_creafitxer_iban (psproces,
                                  xtsufpresentador,
                                  xcempres,
                                  xcdoment,
                                  xcdomsuc,
                                  nom_fitxer,
                                  pcidioma,
                                  pctipemp,
                                  xpath,
                                  pfcobro
                                 );      --> -- Bug.: 13498 - JGR - 04/03/2010
         -- bug 8416
         ELSIF xctipban = 4
         THEN                                                        -- DOM'80
            v_pas := 1140;
            error :=
               f_creafitxer_dom80 (psproces,
                                   xtsufpresentador,
                                   xcempres,
                                   xcdoment,
                                   xcdomsuc,
                                   nom_fitxer,
                                   pcidioma,
                                   pctipemp,
                                   xpath
                                  );
         -- bug 8416

         -- ini BUG 0019999 - 14/11/2011 - JMF
         ELSIF v_tfunc IS NOT NULL
         THEN                                                     -- Banco ACH
            v_pas := 1150;

            DECLARE
               nom_fitxer_old   VARCHAR2 (200);
               v_sent           VARCHAR2 (3000);
            BEGIN
               v_pas := 1050;
               nom_fitxer_old := nom_fitxer;
               nom_fitxer := NULL;
               v_sent :=
                     'begin :nom_fitxer := PAC_NOMBRES_FICHEROS.f_nom_domici('
                  || psproces
                  || ', '
                  || xcempres
                  || ', '
                  || xcdoment
                  || ', '
                  || xcdomsuc
                  || ', '
                  || xccobban
                  || '); end;';
               v_pas := 1055;

               EXECUTE IMMEDIATE v_sent
                           USING OUT nom_fitxer;

               IF nom_fitxer IS NULL
               THEN
                  v_pas := 1060;
               ELSE
                  nom_fitxer := '_' || nom_fitxer;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               v_obj,
                               v_pas,
                               SQLCODE,
                               v_sent
                              );
                  nom_fitxer := nom_fitxer_old;
            END;

            DECLARE
               v_sent   VARCHAR2 (3000);
            BEGIN
               v_sent := v_tfunc;

               IF INSTR (v_sent, ':psproces') > 0
               THEN
                  v_pas := 1160;
                  v_sent := REPLACE (v_sent, ':psproces', psproces);
               END IF;

               IF INSTR (v_sent, ':pbnotificaciones') > 0
               THEN
                  v_pas := 1165;
                  v_sent := REPLACE (v_sent, ':pbnotificaciones', 'FALSE');
               END IF;

               IF INSTR (v_sent, ':xtsufpresentador') > 0
               THEN
                  v_pas := 1170;
                  v_sent :=
                     REPLACE (v_sent,
                              ':xtsufpresentador',
                              CHR (39) || xtsufpresentador || CHR (39)
                             );
               END IF;

               IF INSTR (v_sent, ':xcempres') > 0
               THEN
                  v_pas := 1180;
                  v_sent := REPLACE (v_sent, ':xcempres', xcempres);
               END IF;

               IF INSTR (v_sent, ':xcdoment') > 0
               THEN
                  v_pas := 1190;
                  v_sent := REPLACE (v_sent, ':xcdoment', xcdoment);
               END IF;

               IF INSTR (v_sent, ':xcdomsuc') > 0
               THEN
                  v_pas := 1200;
                  v_sent := REPLACE (v_sent, ':xcdomsuc', xcdomsuc);
               END IF;

               IF INSTR (v_sent, ':nom_fitxer') > 0
               THEN
                  v_pas := 1210;
                  v_sent :=
                     REPLACE (v_sent,
                              ':nom_fitxer',
                              CHR (39) || nom_fitxer || CHR (39)
                             );
               END IF;

               IF INSTR (v_sent, ':pcidioma') > 0
               THEN
                  v_pas := 1220;
                  v_sent := REPLACE (v_sent, ':pcidioma', pcidioma);
               END IF;

               IF INSTR (v_sent, ':pctipemp') > 0
               THEN
                  v_pas := 1230;
                  v_sent := REPLACE (v_sent, ':pctipemp', pctipemp);
               END IF;

               IF INSTR (v_sent, ':xpath') > 0
               THEN
                  v_pas := 1240;
                  v_sent :=
                     REPLACE (v_sent, ':xpath', CHR (39) || xpath || CHR (39));
               END IF;

               v_pas := 1250;
               v_sent := 'begin :error := ' || v_sent || ' end;';
               v_pas := 1260;

               EXECUTE IMMEDIATE v_sent
                           USING OUT error;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               v_obj,
                               v_pas,
                               SQLCODE || ' ' || v_par || ' xctipban='
                               || xctipban,
                               v_sent
                              );
            END;
         -- fin BUG 0019999 - 14/11/2011 - JMF
         -- 33. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Inicio
         ELSIF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                   'DOMIS_AGR_ACUERDO'
                                                  ),
                    0
                   ) = 1
         THEN
            v_pas := 1270;
            error :=
               f_creafitxer_acuerdo (psproces,
                                     xtsufpresentador,
                                     xcempres,
                                     xcdoment,
                                     xcdomsuc,
                                     nom_fitxer,
                                     pcidioma,
                                     pctipemp,
                                     xpath
                                    );
         -- 33. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Fin
         ELSE
            v_pas := 1280;
            error :=
               f_creafitxer (psproces,
                             xtsufpresentador,
                             xcempres,
                             xcdoment,
                             xcdomsuc,
                             nom_fitxer,
                             pcidioma,
                             pctipemp,
                             xpath
                            );
         END IF;

         IF error = 0
         THEN
            v_pas := 1290;
            xnprolin := NULL;
            error :=
               f_proceslin (psproces, nom_fitxer, xtsufpresentador, xnprolin);

            IF error = 0
            THEN
               v_pas := 1300;

               FETCH cur_domicxccobban
                INTO xctipban, xcempres, xcdoment, xcdomsuc, v_tfunc,
                     xccobban;         -- Bug 20735/102170 - 29/12/2011 - JGR
            ELSE
               EXIT;
            END IF;
         ELSE
            EXIT;
         END IF;
      END LOOP;

      v_pas := 1350;

      CLOSE cur_domicxccobban;

      v_pas := 1360;
      RETURN error;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_obj,
                      v_pas,
                      v_par || ' xctipban=' || xctipban,
                      SQLCODE || ' ' || SQLERRM
                     );
         RETURN 112318;
   END f_domrecibos;

-----------------------------------------------------------------------------
   FUNCTION f_fitxer_buit (psproces IN NUMBER, pcempres IN NUMBER)
      RETURN NUMBER
   IS
      nom_fitxer   VARCHAR2 (50);
      fitxer       UTL_FILE.file_type;
      xpath        VARCHAR2 (100);
   BEGIN
      -- Bug 11835 - APD - 01/12/2009 - se sustituye f_parinstalacion_t('PATH_DOMIS') por f_parempresa_t('PATH_DOMIS')
      xpath := pac_parametros.f_parempresa_t (pcempres, 'PATH_DOMIS');

      IF xpath IS NULL
      THEN
         RETURN 112443;
      END IF;

      nom_fitxer := f_parinstalacion_t ('NOM_DOMIC');

      IF nom_fitxer IS NULL
      THEN
         nom_fitxer := 'DR' || LPAD (psproces, 6, '0');
      END IF;

      fitxer := UTL_FILE.fopen (xpath, nom_fitxer, 'w');
      UTL_FILE.fclose (fitxer);
      UTL_FILE.fcopy (xpath,
                      nom_fitxer,
                      xpath,
                      'mvdom' || TO_CHAR (f_sysdate, 'YYYYMMDD') || '.txt'
                     );
      RETURN 0;
   END f_fitxer_buit;

-----------------------------------------------------------------------------
   FUNCTION f_creafitxer_iban (
      psproces           IN   NUMBER,
      ptsufpresentador   IN   VARCHAR2,
      pcempres           IN   NUMBER,
      pcdoment           IN   NUMBER,
      pcdomsuc           IN   NUMBER,
      ptfitxer           IN   VARCHAR2,
      pcidioma           IN   NUMBER,
      pctipemp           IN   NUMBER,
      ppath              IN   VARCHAR2,
      pfcobro            IN   DATE
            DEFAULT NULL                 --> -- Bug.: 13498 - JGR - 04/03/2010
   )
      RETURN NUMBER
   IS
      xnrecibo              domiciliaciones.nrecibo%TYPE;       --NUMBER(10);
      xcramo                domiciliaciones.cramo%TYPE;         --NUMBER(10);
      xccobban              domiciliaciones.ccobban%TYPE;       --NUMBER(10);
      xfefecto              DATE;
      xcempres              NUMBER;
      xnnumnif              cobbancario.nnumnif%TYPE;
      xtnumnif              cobbancario.nnumnif%TYPE;
      xtsufijo              cobbancario.tsufijo%TYPE;
      xcdoment              domiciliaciones.cdoment%TYPE;       --NUMBER(10);
      xnifcob               VARCHAR2 (14);
      xtempres              VARCHAR2 (40);
      vegada                NUMBER                         := 1;
      error                 NUMBER;
      xcdomsuc              domiciliaciones.cdomsuc%TYPE;       --NUMBER(10);
      xsseguro              seguros.sseguro%TYPE;               --NUMBER(10);
      xsperson              NUMBER;
      xcdomici              NUMBER;
      xcidioma              NUMBER;
      xtnombre              VARCHAR2 (100);
      xitotalr              vdetrecibos.itotalr%TYPE;           --NUMBER(10);
      xitotalr2             vdetrecibos.itotalr%TYPE;           --NUMBER(10);
      xitotalr_unif         vdetrecibos.itotalr%TYPE;
      xitotalr2_unif        vdetrecibos.itotalr%TYPE;
      xcbancar              VARCHAR2 (34);
      xnpoliza              seguros.npoliza%TYPE;               --NUMBER(10);
      xncertif              seguros.ncertif%TYPE;               --NUMBER(10);
      xncuenta              cobbancario.ncuenta%TYPE;
      fitxer                UTL_FILE.file_type;
      tot_imp_remesa        NUMBER                         := 0;
      tot_num_rebuts        NUMBER                         := 0;
      tot_registres_ord     NUMBER                         := 0;
      tot_remeses_pres      NUMBER                         := 0;
      tot_imp_presentador   NUMBER                         := 0;
      tot_num_rebuts_pres   NUMBER                         := 0;
      tot_registres_pres    NUMBER                         := 0;
      linia                 VARCHAR2 (162);
      poliscert             VARCHAR2 (14);
      espais2               VARCHAR (2)                 := LPAD (' ', 2, ' ');
      espais6               VARCHAR (6)                 := LPAD (' ', 6, ' ');
      espais8               VARCHAR (8)                 := LPAD (' ', 8, ' ');
      espais14              VARCHAR (14)               := LPAD (' ', 14, ' ');
      espais16              VARCHAR (16)               := LPAD (' ', 16, ' ');
      espais20              VARCHAR (20)               := LPAD (' ', 20, ' ');
      espais38              VARCHAR (38)               := LPAD (' ', 38, ' ');
      espais52              VARCHAR (52)               := LPAD (' ', 52, ' ');
      espais66              VARCHAR (66)               := LPAD (' ', 66, ' ');
      espais72              VARCHAR (72)               := LPAD (' ', 72, ' ');
      espais64              VARCHAR (64)               := LPAD (' ', 64, ' ');
      espais80              VARCHAR (80)               := LPAD (' ', 80, ' ');
      lin1                  VARCHAR2 (80);
      lin2                  VARCHAR2 (80);
      lin3                  VARCHAR2 (80);
      lin4                  VARCHAR2 (80);
      lin5                  VARCHAR2 (80);
      lin6                  VARCHAR2 (80);
      lin7                  VARCHAR2 (80);
      lin8                  VARCHAR2 (80);
      p0180                 VARCHAR2 (4)                   := '0180';
      p0380                 VARCHAR2 (4)                   := '0380';
      p0680                 VARCHAR2 (4)                   := '0680';
      p0681                 VARCHAR2 (4)                   := '0681';
      p0682                 VARCHAR2 (4)                   := '0682';
      p0683                 VARCHAR2 (4)                   := '0683';
      p0684                 VARCHAR2 (4)                   := '0684';
      p0685                 VARCHAR2 (4)                   := '0685';
      p0880                 VARCHAR2 (4)                   := '0880';
      p0980                 VARCHAR2 (4)                   := '0980';
      pcdivisa              parproductos.cvalpar%TYPE
                                         := f_parinstalacion_n ('MONEDAINST');
      xdecima               monedas.ndecima%TYPE;
      isomonedainst         monedas.ciso4217n%TYPE;
      xfvencim_rec          recibos.fvencim%TYPE;
      xfefecto_rec          recibos.fefecto%TYPE;
      xcagente              recibos.cagente%TYPE;
      wcramo                seguros.cramo%TYPE;
      wcmodali              seguros.cmodali%TYPE;
      wctipseg              seguros.ctipseg%TYPE;
      wccolect              seguros.ccolect%TYPE;
      wnriesgo              recibos.nriesgo%TYPE;
      wfefecto              recibos.fefecto%TYPE;
      vcobjase              seguros.cobjase%TYPE;
      xctiprec              recibos.ctiprec%TYPE;
      wptlin1               VARCHAR2 (200);
      wptlin2               VARCHAR2 (200);
      wptlin3               VARCHAR2 (200);
      ptlin1                VARCHAR2 (30);
      ptlin2                VARCHAR2 (20);
      v_auxdetvalor         detvalores.tatribu%TYPE;
      w_text_ramo           VARCHAR2 (40);
      w_desramo             ramos.tramo%TYPE;
      ptriesgo1             VARCHAR2 (200);
      ptriesgo2             VARCHAR2 (200);
      ptriesgo3             VARCHAR2 (200);
      wmatric               VARCHAR2 (100);
      w_lit_matric          VARCHAR2 (12);
      w_imp_faga            NUMBER;
      w_imp_isi             NUMBER;
      xxitotalr             VARCHAR2 (20);
      xtnifpresentador      VARCHAR2 (12)                  := '';
      n_linerr              NUMBER;
      d_avui                DATE;
      e_salida              EXCEPTION;
      wtraza                NUMBER                         := 0;
      w_mensaje             VARCHAR2 (78);
      v_fillerln3           VARCHAR2 (1);
      xiprinet              NUMBER;
      xiprinet2             NUMBER;
      xiprinet_unif         NUMBER;
      xiprinet2_unif        NUMBER;
      w_tcagente            VARCHAR2 (78);
      xsproduc              productos.sproduc%TYPE;

      -- 36. 0026169 - 0138818 - Inicio
      CURSOR cur_remesa
      IS
         SELECT   ccobban, GREATEST (fefecrec, fefecto) fefecto, cdoment,
                  cdomsuc, cramo
             FROM domiciliaciones
            WHERE sproces = psproces
              AND cempres = pcempres
              AND cdoment = pcdoment
              AND cdomsuc = pcdomsuc
              AND cerror = 0
         GROUP BY ccobban,
                  GREATEST (fefecrec, fefecto),
                  cdoment,
                  cdomsuc,
                  cramo
         ORDER BY cramo, fefecto;

      CURSOR cur_domiciliac
      IS
         SELECT   nrecibo, LPAD (tsufijo, 4, '0') tsufijo, fefecto, cempres,
                  cdoment, cdomsuc
             FROM domiciliaciones d
            WHERE sproces = psproces
              AND ccobban = xccobban
              AND GREATEST (fefecto, fefecrec) = xfefecto
              AND cerror = 0
              AND cramo = xcramo
         ORDER BY fefecto;

--********* CONTROLAMOS LA INSTALACION PARA GRABAR UNA REFERENCIA DIFERENTE
--********* EN SGA SE GRABA NPOLIZA + NCERTIF
--********* EN CAIXA SE GRABAN xx + CSEGHOS
      cuenta                NUMBER;
      lccompani             NUMBER;

      FUNCTION formatea_numero (p_num IN NUMBER)
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN TO_CHAR (p_num, '9g999g999g990d90');
      END;

      PROCEDURE prolinea_nova (p_num IN NUMBER, p_texto IN VARCHAR2)
      IS
         xnprolin   procesoslin.nprolin%TYPE;
         n_vacio    NUMBER;
      BEGIN
         xnprolin := NULL;
         n_vacio :=
            f_proceslin (psproces,
                         SUBSTR (p_texto, 1, 120),
                         NVL (p_num, -9999),
                         xnprolin
                        );
      END;

      PROCEDURE fitxer_obrir
      IS
      BEGIN
         fitxer := UTL_FILE.fopen (ppath, ptfitxer, 'w');
      END;

      PROCEDURE fitxer_linia (p_linia VARCHAR2)
      IS
      BEGIN
         UTL_FILE.put_line (fitxer, p_linia);
      END;

      PROCEDURE fitxer_tancar
      IS
      BEGIN
         IF UTL_FILE.is_open (fitxer)
         THEN
            UTL_FILE.fclose (fitxer);
         END IF;
      END;

      -- Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.
      PROCEDURE fitxer_renombrar
      IS
      BEGIN
         IF NOT UTL_FILE.is_open (fitxer)
         THEN
            UTL_FILE.frename (ppath, ptfitxer, ppath, LTRIM (ptfitxer, '_'));
         END IF;
      END;
   -- FI bug 0013153
   BEGIN
      error := 0;
      n_linerr := 1000;
      d_avui := f_sysdate;

      BEGIN
         n_linerr := 1010;

         SELECT ndecima, ciso4217n
           INTO xdecima, isomonedainst
           FROM monedas
          WHERE cmoneda = pcdivisa AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS
         THEN
            error := 101916;          -- Error en la BD (MONEDA NO PERMITIDA)
            prolinea_nova (error,
                              'cmoneda = '
                           || pcdivisa
                           || ' idioma='
                           || pcidioma
                           || ' '
                           || SQLERRM
                          );
            wtraza := 1;
            RAISE e_salida;
      END;

      n_linerr := 1020;
      xcempres := pcempres;
      error := f_nifempresa (xcempres, xtnifpresentador);

      IF error = 0
      THEN
         NULL;
      ELSE
         prolinea_nova (error,
                           'xcempres='
                        || xcempres
                        || ' xtnifpresentador='
                        || xtnifpresentador
                       );
         wtraza := 2;
         RAISE e_salida;
      END IF;

      n_linerr := 1030;
      fitxer_obrir;
      tot_imp_remesa := 0;
      tot_num_rebuts := 0;
      n_linerr := 1040;

      OPEN cur_remesa;

      n_linerr := 1050;

      FETCH cur_remesa
       INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;

      WHILE cur_remesa%FOUND
      LOOP
         n_linerr := 1060;
         error :=
            f_cobrador (xccobban,
                        xnnumnif,
                        xtsufijo,
                        xcdoment,
                        xcempres,
                        xcdomsuc,
                        xncuenta,
                        xnifcob
                       );

         IF error = 0
         THEN
            NULL;
         ELSE
            prolinea_nova (error, 'xccobban = ' || xccobban);
            wtraza := 3;
            RAISE e_salida;
         END IF;

         --Buscamos el filler para las lineas 3
         SELECT dom_filler_ln3
           INTO v_fillerln3
           FROM cobbancario
          WHERE ccobban = xccobban AND cempres = xcempres;

         n_linerr := 1070;
         error := f_nifempresa (xcempres, xtnumnif);

         IF error = 0
         THEN
            NULL;
         ELSE
            prolinea_nova (error,
                           'xcempres=' || xcempres || ' xtnumnif=' || xtnumnif
                          );
            wtraza := 4;
            RAISE e_salida;
         END IF;

         IF xnifcob IS NOT NULL
         THEN
            xtnumnif := xnifcob;
         END IF;

         n_linerr := 1080;
         error := f_desempresa (xcempres, NULL, xtempres);

         IF error = 0
         THEN
            NULL;
         ELSE
            prolinea_nova (error, 'xcempres=' || xcempres);
            wtraza := 5;
            RAISE e_salida;
         END IF;

         n_linerr := 1090;
         xtnumnif := NVL (xtnumnif, '0');
         xtsufijo := NVL (xtsufijo, '0');
         xtempres := NVL (xtempres, '0');
         xcdoment := NVL (xcdoment, '0');
         xcdomsuc := NVL (xcdomsuc, '0');
         xncuenta := NVL (xncuenta, '0');

         IF vegada = 1
         THEN
            n_linerr := 1100;
            --> Ini -- Bug.: 13498 - JGR - 04/03/2010
            -- Grabem el registre del presentador (només la primera vegada)
            linia :=
                  '1'                                                -- 00-01
               || LPAD (xtsufijo, 4, '0')                             -- 02-05
               || LPAD (xcdoment, 2, '0')                             -- 06-07
               || TO_CHAR (d_avui, 'ddmmrr')                          -- 08-13
               || RPAD (xtempres, 30, ' ')                            -- 14-43
               || 'C'                                                    -- 44
               || isomonedainst                                       -- 45-47
               || TO_CHAR (NVL (pfcobro, d_avui), 'ddmmrr')           -- 48-53
               --|| TO_CHAR(d_avui, 'ddmmrr')
               || 'D'                                                    -- 54
               --> Fin -- Bug.: 13498 - JGR - 04/03/2010
               || RPAD (SUBSTR (xncuenta, 1, 24), 24, ' ')
               || ' '
               || LPAD (' ', 38, ' ')
               || TO_CHAR (d_avui, 'rr')
               || LPAD (TO_CHAR (psproces), 5, '0')
               || 'A010';
            fitxer_linia (linia);
            vegada := 2;
         END IF;

         n_linerr := 1110;

         OPEN cur_domiciliac;

         n_linerr := 1120;

         FETCH cur_domiciliac
          INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment, xcdomsuc;

         n_linerr := 1130;

         WHILE cur_domiciliac%FOUND
         LOOP
            BEGIN
               n_linerr := 1140;

               SELECT s.sseguro, s.npoliza, s.ncertif, NVL (r.cbancar, ' '),
                      r.fvencim, r.fefecto, r.cagente, s.cramo,
                      s.cmodali, s.ctipseg, s.ccolect, r.nriesgo, r.fefecto,
                      s.cobjase, r.ctiprec, s.sproduc -- 36. 0026169 - 0138818
                 INTO xsseguro, xnpoliza, xncertif, xcbancar,
                      xfvencim_rec, xfefecto_rec, xcagente, wcramo,
                      wcmodali, wctipseg, wccolect, wnriesgo, wfefecto,
                      vcobjase, xctiprec, xsproduc    -- 36. 0026169 - 0138818
                 FROM recibos r, seguros s
                WHERE r.nrecibo = xnrecibo AND r.sseguro = s.sseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  error := 101947;                 -- Inconsistència de la BD
                  prolinea_nova (error,
                                 '(1) xnrecibo=' || xnrecibo || ' ' || SQLERRM
                                );
                  wtraza := 6;
                  RAISE e_salida;
               WHEN OTHERS
               THEN
                  error := 101916;                          -- Error en la BD
                  prolinea_nova (error,
                                 '(2) xnrecibo=' || xnrecibo || ' ' || SQLERRM
                                );
                  wtraza := 7;
                  RAISE e_salida;
            END;

            n_linerr := 1150;
            xsperson := NULL;
            xcdomici := NULL;
            xcidioma := pcidioma;
            n_linerr := 1160;
            error :=
                f_nomrecibo (xsseguro, xtnombre, xcidioma, xsperson, xcdomici);

            IF error = 0
            THEN
               IF xsperson IS NULL
               THEN
                  error := 180210;
                  prolinea_nova (error, '(3.1) xsseguro=' || xsseguro);
                  wtraza := 8;
                  p_tab_error
                        (f_sysdate,
                         f_user,
                         'PAC_DOMIS',
                         wtraza,
                            'f_nomrecibo() no devuelve nombre para seguro :'
                         || xsseguro,
                         NULL
                        );
                  RAISE e_salida;
               END IF;
            ELSE
               prolinea_nova (error, '(3) xsseguro=' || xsseguro);
               wtraza := 9;
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_DOMIS',
                            wtraza,
                               'Error en f_nomrecibo() para seguro :'
                            || xsseguro
                            || ' error:'
                            || error,
                            NULL
                           );
               RAISE e_salida;
            END IF;

            n_linerr := 1170;
            error :=
               f_direccion (1,
                            xsperson,
                            xcdomici,
                            1,
                            wptlin1,
                            wptlin2,
                            wptlin3
                           );

            IF error = 0
            THEN
               n_linerr := 1180;
               ptlin1 := RPAD (SUBSTR (wptlin1, 1, 30), 30, ' ');
               ptlin2 := RPAD (SUBSTR (wptlin2, 1, 20), 20, ' ');
            ELSE
               p_tab_error (f_sysdate,
                            f_user,
                            'PAC_DOMIS',
                            NULL,
                               'F_DIRECCION (1,'
                            || xsperson
                            || ','
                            || xcdomici
                            || ',1,'
                            || wptlin1
                            || ','
                            || wptlin2
                            || ','
                            || wptlin3
                            || ')',
                            error
                           );
               prolinea_nova (error, '(4) xsperson=' || xsperson);
               wtraza := 10;
               RAISE e_salida;
            END IF;

            BEGIN
               n_linerr := 1190;

               SELECT NVL (NVL (itotalr, 0) * POWER (10, xdecima), 0),
                      NVL (itotalr, 0),
                      NVL (NVL (iprinet, 0) * POWER (10, xdecima), 0),
                      NVL (iprinet, 0)
                 INTO xitotalr,
                      xitotalr2,
                      xiprinet,
                      xiprinet2
                 FROM vdetrecibos
                WHERE nrecibo = xnrecibo;

               --Bug.: 16383 - ICV - 2010
                --Si tiene parametrizada unificación de tipo 2

               -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
               -- 36. Aquí optamos por no controlar si requiere agrupación, si la hay suma sino será 0 - Comentamos el IF

               --IF NVL(f_parproductos_v(f_sproduc_ret(wcramo, wcmodali, wctipseg, wccolect),
               --                        'RECUNIF'),
               --       0) = 2 THEN
               IF pac_domis.f_agrupa_rec_tipo (xccobban, xcempres, xsproduc) =
                                                                             2
               THEN
                  -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin
                  SELECT NVL (NVL (SUM (itotalr), 0) * POWER (10, xdecima), 0),
                         NVL (SUM (itotalr), 0),
                         NVL (NVL (SUM (iprinet), 0) * POWER (10, xdecima), 0),
                         NVL (SUM (iprinet), 0)
                    INTO xitotalr_unif,
                         xitotalr2_unif,
                         xiprinet_unif,
                         xiprinet2_unif
                    FROM adm_recunif ar, vdetrecibos v
                   WHERE ar.nrecunif = xnrecibo
                     AND ar.nrecibo = v.nrecibo
                     AND ar.sdomunif IS NOT NULL;

                  xitotalr := xitotalr + xitotalr_unif;
                  xitotalr2 := xitotalr2 + xitotalr2_unif;
                  xiprinet := xiprinet + xiprinet_unif;
                  xiprinet2 := xiprinet2 + xiprinet2_unif;
               END IF;
            --Fin Bug.: 16383
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  error := 101947;                 -- Inconsistència de la BD
                  prolinea_nova (error,
                                 '(6) xnrecibo=' || xnrecibo || ' ' || SQLERRM
                                );
                  wtraza := 11;
                  RAISE e_salida;
               WHEN OTHERS
               THEN
                  error := 101916;                          -- Error en la BD
                  prolinea_nova (error,
                                 '(7) xnrecibo=' || xnrecibo || ' ' || SQLERRM
                                );
                  wtraza := 12;
                  RAISE e_salida;
            END;

            IF xitotalr < 0
            THEN
               error := 102276;         -- Total del rebut no pot ser negatiu
               prolinea_nova (error,
                                 '(8) xnrecibo='
                              || xnrecibo
                              || ' xitotalr='
                              || xitotalr
                             );
               wtraza := 14;
               RAISE e_salida;
            END IF;

            n_linerr := 1200;
            poliscert := RPAD (xnpoliza || '-' || xncertif, 14, ' ');

            --ini Bug.: 17422
            IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                   'FICH_DOMI_NCERTIF'
                                                  ),
                    0
                   ) = 1
            THEN
               poliscert := RPAD (xnpoliza || '-' || xncertif, 14, ' ');
            ELSE
               poliscert := RPAD (xnpoliza, 14, ' ');
            END IF;

            --Fi Bug.: 17422
            xtnombre := NVL (xtnombre, ' ');
            xcbancar := NVL (xcbancar, '0');
            xitotalr := NVL (xitotalr, '0');
            xiprinet := NVL (xiprinet, '0');
            -- INSERTEM LA PRIMERA LINIA DE CAPÇALERA DEL DOCUMENT. TIPUS REGISTRE 2
            n_linerr := 1210;
            linia :=
                  '2'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || RPAD (SUBSTR (NVL (xtnombre, ' '), 1, 30), 30, ' ')
               || RPAD (SUBSTR (NVL (ptlin1, ' '), 1, 30), 30, ' ')
               || RPAD (SUBSTR (NVL (ptlin2, ' '), 1, 20), 20, ' ')
               || '  '
               || ' '
               || LPAD (TO_CHAR (xitotalr), 12, '0')
               -- Cambio solicitado por Lídia (Crédit) 04/09/2008
               --|| LPAD (xcdoment, 2, '0')
               || LPAD (SUBSTR (xcbancar, 7, 2), 2, '0')
               || SUBSTR ('    ', 1, 2)
               || '08'
               || ' '
               || LPAD (' ', 5, ' ');
            fitxer_linia (linia);
            -- INSERTEM LA SEGONA LINIA DE CAPÇALERA DEL DOCUMENT. TIPUS REGISTRE 2D
            n_linerr := 1220;
            linia :=
                  '2'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '00'
               || '00000000'
               || RPAD (xcbancar, 25, ' ')
               || SUBSTR (LPAD (TO_CHAR (xnrecibo), 9, ' '), 2, 8)
               || LPAD (' ', 7, ' ')
               || LPAD (' ', 14, ' ')
               || LPAD (' ', 29, ' ')
               || LPAD (' ', 8, ' ')
               || LPAD (' ', 7, ' ')
               || 'D';
            fitxer_linia (linia);
            n_linerr := 1230;
            v_auxdetvalor := NULL;
            error := f_desvalorfijo (8, xcidioma, xctiprec, v_auxdetvalor);

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'F_DOMFICHERO',
                            n_linerr,
                            'f_desvalorfijo t=' || xctiprec || ' i='
                            || xcidioma,
                            error
                           );
            END IF;

            n_linerr := 1240;
            w_desramo := NULL;
            error := f_desramo (wcramo, xcidioma, w_desramo);

            IF error <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            'F_DOMFICHERO',
                            n_linerr,
                            'f_desramo r=' || wcramo || ' i=' || xcidioma,
                            error
                           );
            END IF;

            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 01). TIPUS REGISTRE 3
            n_linerr := 1250;
            linia :=
                  '3'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '01'
               || 'POLISSA:'
               || poliscert
               -->|| SUBSTR (RPAD (v_auxdetvalor, 12, ' '), 1, 12)
               || SUBSTR (RPAD (' ', 12, ' '), 1, 12)
               || 'N.REBUT:'
               || SUBSTR (LPAD (TO_CHAR (xnrecibo), 10, ' '), 1, 10)
               || '     '                                           -- ' RAM '
               || SUBSTR (RPAD (' ', 21, ' '), 1, 21)             -- w_desramo
               || v_fillerln3;
            fitxer_linia (linia);
            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 02). TIPUS REGISTRE 3
            n_linerr := 1260;
            linia :=
                  '3'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '02'
               || 'DATA EFECTE:'
               || RPAD (TO_CHAR (xfefecto_rec, 'dd.mm.yyyy'), 15, ' ')
               || 'DATA VENCIMENT:'
               || RPAD (TO_CHAR (xfvencim_rec, 'dd.mm.yyyy'), 15, ' ')
               || RPAD (' ', 21, ' ')
               || v_fillerln3;
            fitxer_linia (linia);
            n_linerr := 1270;
            error :=
               f_desproducto (wcramo,
                              wcmodali,
                              1,
                              pcidioma,
                              w_text_ramo,
                              wctipseg,
                              wccolect
                             );

            IF error <> 0
            THEN
               prolinea_nova (0,
                                 '(20) e='
                              || error
                              || ' r='
                              || wcramo
                              || ' m='
                              || wcmodali
                              || ' t='
                              || wctipseg
                              || ' c='
                              || wccolect
                             );
            END IF;

            -- Para evitar duplicados de riesgos.
            IF wnriesgo IS NULL
            THEN
               n_linerr := 1280;

               SELECT MIN (nriesgo)
                 INTO wnriesgo
                 FROM riesgos
                WHERE sseguro = xsseguro
                  AND TRUNC (fefecto) <= TRUNC (wfefecto)
                  AND (fanulac IS NULL OR fanulac > wfefecto);
            END IF;

            n_linerr := 1290;
            error :=
               f_desriesgo (xsseguro,
                            wnriesgo,
                            wfefecto,
                            pcidioma,
                            ptriesgo1,
                            ptriesgo2,
                            ptriesgo3
                           );

            IF error <> 0
            THEN
               prolinea_nova (0,
                                 '(21) e='
                              || error
                              || ' s='
                              || xsseguro
                              || ' r='
                              || wnriesgo
                              || ' e='
                              || wfefecto
                             );
            END IF;

            IF vcobjase = 5
            THEN                                                       -- Auto
               n_linerr := 1300;
               wmatric := RPAD (ptriesgo1, 55, ' ');
               w_lit_matric := 'MATRICULA  :';
            ELSIF vcobjase = 1
            THEN                                                    -- Persona
               n_linerr := 1310;
               --wmatric := RPAD (ptriesgo1, 55, ' ');
               --w_lit_matric := 'ASSEGURAT  :';
               wmatric := RPAD (SUBSTR (xtnombre, 1, 55), 55, ' ');
               w_lit_matric := 'PRENEDOR   :';
            ELSIF vcobjase = 2
            THEN                                                   -- Direcció
               n_linerr := 1320;
               wmatric :=
                  RPAD (SUBSTR (ptriesgo1 || ' ' || ptriesgo2 || ' '
                                || ptriesgo3,
                                1,
                                55
                               ),
                        55,
                        ' '
                       );
               w_lit_matric := 'SITUACIO   :';
            ELSE
               n_linerr := 1330;
               wmatric := ' ';
               w_lit_matric := ' ';
            END IF;

            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 03). TIPUS REGISTRE 3
            n_linerr := 1340;
            linia :=
                  '3'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '03'
               || SUBSTR (RPAD (w_lit_matric, 13, ' '), 1, 13)
               || SUBSTR (RPAD (wmatric, 65, ' '), 1, 65)
               || v_fillerln3;
            fitxer_linia (linia);
            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 04). TIPUS REGISTRE 3
            n_linerr := 1350;
            linia :=
                  '3'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '04'
--|| '------------------------------------------------------------------------------'
               || RPAD ('PRODUCTE   :' || w_text_ramo, 78, ' ')
               || v_fillerln3;
            fitxer_linia (linia);

            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 05). TIPUS REGISTRE 3
            BEGIN
               n_linerr := 1360;
               -- IMPORT F.A.G.A., ARBITRIS EN ESPANYA
               -- Concepto no definido
               /*
               SELECT NVL (SUM (iconcep), 0)
               INTO   w_imp_faga
                 FROM detrecibos
                WHERE cconcep IN (6, 56) AND nrecibo = xnrecibo;
               */
               w_imp_faga := 0;
            END;

            n_linerr := 1370;
            linia :=
                  '3'
               || LPAD (xtsufijo, 4, '0')
               || poliscert
               || '05'
               || RPAD ('TOTAL REBUT:', 60, ' ')
               || LPAD (formatea_numero (xitotalr2), 18, ' ')
               || v_fillerln3;
            fitxer_linia (linia);

            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 06). TIPUS REGISTRE 3
            BEGIN
               n_linerr := 1380;

               SELECT NVL (SUM (iconcep), 0)
                 -- IMPORT I.S.I., I.P.S. EN ESPANYA
               INTO   w_imp_isi
                 FROM detrecibos
                WHERE cconcep IN (4, 54) AND nrecibo = xnrecibo;
            END;

            n_linerr := 1390;
-- Bug 10838 - La linea 06 que estaba vacia la llevamos al final. Las lineas 07 y 08 pasan a ser 06 y 07.

            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 06). TIPUS REGISTRE 3
            n_linerr := 1400;
            n_linerr := 1410;

            IF w_imp_faga != 0
            THEN
               linia :=
                     '3'
                  || LPAD (xtsufijo, 4, '0')
                  || poliscert
                  || '06'
                  || RPAD ('F.A.G.A.   :', 60, ' ')
                  || LPAD (formatea_numero (w_imp_faga), 18, ' ')
                  || v_fillerln3;
            ELSE
               linia :=
                     '3'
                  || LPAD (xtsufijo, 4, '0')
                  || poliscert
                  || '06'
                  || RPAD ('.', 78, ' ')
                  || v_fillerln3;
            END IF;

            fitxer_linia (linia);
            -- INSERTEM EL DETALL DEL DOCUMENT (LINIA 07). TIPUS REGISTRE 3
            n_linerr := 1420;

            --ini Bug.: 17422
            IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                   'FICH_DOMI_PNETA'),
                    0
                   ) = 1
            THEN
               linia :=
                     '3'
                  || LPAD (xtsufijo, 4, '0')
                  || poliscert
                  || '07'
                  || RPAD ('PRIMA NETA      :' || formatea_numero (xiprinet2),
                           39,
                           ' '
                          )
                  || RPAD ('I.S.I      :' || formatea_numero (w_imp_isi),
                           39,
                           ' '
                          );
            ELSE
               linia :=
                     '3'
                  || LPAD (xtsufijo, 4, '0')
                  || poliscert
                  || '07'
                  || RPAD ('I.S.I      :', 60, ' ')
                  || LPAD (formatea_numero (w_imp_isi), 18, ' ')
                  || v_fillerln3;
            END IF;

            --Fin bug.: 17422
            fitxer_linia (linia);
-- Bug 10838 inicio
--            linia := '3' || LPAD(xtsufijo, 4, '0') || poliscert || '06' || RPAD('.', 60, ' ')
--                     || LPAD(' ', 18, ' ') || '.';
            n_linerr := 1430;

            IF NVL (pac_parametros.f_parempresa_n (xcempres,
                                                   'FICH_DOMI_MENSAJE'
                                                  ),
                    0
                   ) = 1
            THEN
               BEGIN
                  SELECT SUBSTR (mensaje, 1, 78)
                    INTO w_mensaje
                    FROM mensarecibos m, productos p
                   WHERE m.sproduc = p.sproduc
                     AND p.cramo = wcramo
                     AND p.cmodali = wcmodali
                     AND p.ctipseg = wctipseg
                     AND p.ccolect = wccolect
                     AND m.cidioma = pcidioma
                     AND m.nlinea = 1;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     w_mensaje := NULL;
               END;

               IF w_mensaje IS NULL
               THEN
                  linia :=
                        '3'
                     || LPAD (xtsufijo, 4, '0')
                     || poliscert
                     || '08'
                     || RPAD ('.', 60, ' ')
                     || LPAD (' ', 18, ' ')
                     || v_fillerln3;
               ELSE
                  linia :=
                        '3'
                     || LPAD (xtsufijo, 4, '0')
                     || poliscert
                     || '08'
                     || RPAD (w_mensaje, 78, ' ')
                     || v_fillerln3;
               END IF;
            ELSE
               BEGIN
                  SELECT cagente || ' - ' || f_nombre (a.sperson, 1)
                    INTO w_tcagente
                    FROM agentes a
                   WHERE a.cagente = xcagente;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     w_tcagente := NULL;
               END;

               IF w_tcagente IS NULL
               THEN
                  linia :=
                        '3'
                     || LPAD (xtsufijo, 4, '0')
                     || poliscert
                     || '08'
                     || RPAD ('.', 60, ' ')
                     || LPAD (' ', 18, ' ')
                     || v_fillerln3;
               ELSE
                  linia :=
                        '3'
                     || LPAD (xtsufijo, 4, '0')
                     || poliscert
                     || '08'
                     || RPAD ('AGENT   :' || w_tcagente, 78, ' ')
                     || v_fillerln3;
               END IF;
            END IF;

            fitxer_linia (linia);
-- Bug 10838 fin
            n_linerr := 1440;
            tot_imp_remesa := tot_imp_remesa + NVL (xitotalr, 0);
            tot_num_rebuts := tot_num_rebuts + 1;
            xtnombre := NVL (xtnombre, ' ');
            xcbancar := NVL (xcbancar, '0');
            xitotalr := NVL (xitotalr, '0');
            n_linerr := 1450;

            FETCH cur_domiciliac
             INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment, xcdomsuc;
         END LOOP;

         n_linerr := 1450;

         CLOSE cur_domiciliac;

         n_linerr := 1460;

         FETCH cur_remesa
          INTO xccobban, xfefecto, xcdoment, xcdomsuc, xcramo;
      END LOOP;

      n_linerr := 1470;

      CLOSE cur_remesa;

      -- Insertem un registre de final del Presentador. TIPUS 4
      n_linerr := 1480;
      linia :=
            '4'
         || LPAD (xtsufijo, 4, '0')
         || LPAD (xcdoment, 2, '0')
         || TO_CHAR (d_avui, 'ddmmrr')
         || 'C'
         || isomonedainst
         || LPAD (tot_imp_remesa, 14, '0')
         || LPAD (tot_num_rebuts, 5, '0')
         || LPAD (' ', 14, ' ')
         || LPAD (' ', 78, ' ');
      fitxer_linia (linia);
      n_linerr := 1490;
      fitxer_tancar;
      -- Bug 0013153 - FAL - 18/03/2010 - Renombrar nombre fichero para quitarle '_' cuando ya generado.
      fitxer_renombrar;
      -- Fi Bug 0013153
      RETURN 0;
   EXCEPTION
      WHEN e_salida
      THEN
         -- Cerramos posibles cursores abiertos
         IF cur_domiciliac%ISOPEN
         THEN
            CLOSE cur_domiciliac;
         END IF;

         IF cur_remesa%ISOPEN
         THEN
            CLOSE cur_remesa;
         END IF;

         -- Cerramos posible fichero abierto
         fitxer_tancar;
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMIS',
                      wtraza,
                         'ERROR EN LA GENERACIÓN DEL FICHERO ('
                      || ppath
                      || ')('
                      || ptfitxer
                      || ')',
                      SQLERRM
                     );
         RETURN NVL (error, -9999);
      WHEN OTHERS
      THEN
         error := 102927;          -- Error de I/O (Interacció amb el fitxer)
         prolinea_nova (error,
                           '(99) lin='
                        || n_linerr
                        || ' err='
                        || SQLCODE
                        || ' r='
                        || xnrecibo
                        || SQLERRM
                       );

         -- Cerramos posibles cursores abiertos
         IF cur_domiciliac%ISOPEN
         THEN
            CLOSE cur_domiciliac;
         END IF;

         IF cur_remesa%ISOPEN
         THEN
            CLOSE cur_remesa;
         END IF;

         -- Cerramos posible fichero abierto
         fitxer_tancar;
         RETURN error;
   END f_creafitxer_iban;

---------------------------------
-- bug 11339 - 08/10/2009 - JGM -
   /*************************************************************************
       FUNCTION f_retorna_select
       Función que retornará la select de PREVIO_DOMICILIACIONES
       Ejemplo: 01/01/2009, null,null,null,2

       param in fefecto   : VARCHAR2 - Obligatoria - Fecha Efecto (formato DD/MM/YYYY)
       param in cramo     : NUMBER - Opcional - Codigo Ramo
       param in sproduc   : NUMBER - Opcional - Codigo Producto
       param in cempres   : NUMBER - Opcional - Codigo Empresa
       param in pccobban  : Código de cobrador bancario
       param in pcbanco   : Código de banco
       param in pctipcta  : Tipo de cuenta
       param in pfvtotar  : Fecha de vencimiento tarjeta
       param in pcreferen : Código de referencia
       return             : Devolverá un VARCHAR2 con la SELECT usada en Map, pantalla y proceso.
   *************************************************************************/
   FUNCTION f_retorna_query (
      fefecto          IN   VARCHAR2,
      cramo            IN   NUMBER,
      psproduc         IN   NUMBER,
      cempres          IN   NUMBER,
      psprodom         IN   NUMBER DEFAULT NULL,
      filtradomaximo   IN   BOOLEAN DEFAULT FALSE,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban         IN   NUMBER DEFAULT NULL,
      pcbanco          IN   NUMBER DEFAULT NULL,
      pctipcta         IN   NUMBER DEFAULT NULL,
      pfvtotar         IN   VARCHAR2 DEFAULT NULL,
      pcreferen        IN   VARCHAR2 DEFAULT NULL,
      pdfefecto        IN   VARCHAR2 DEFAULT NULL,
      pcagente         IN   NUMBER DEFAULT NULL,
      -- Código Mediador -- 8. 0021718 / 0111176 - Inicio
      ptagente         IN   VARCHAR2 DEFAULT NULL,          -- Nombre Mediador
      pnnumide         IN   VARCHAR2 DEFAULT NULL,              -- Nif Tomador
      pttomador        IN   VARCHAR2 DEFAULT NULL,           -- Nombre Tomador
      pnrecibo         IN   NUMBER
            DEFAULT NULL      -- Recibo          -- 8. 0021718 / 0111176 - Fin
   )
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN VARCHAR2
   IS
      v_max_reg   NUMBER;
      v_result    VARCHAR2 (4000);
      v_where     VARCHAR2 (200)           := ' and 1=1 ';
      wsproduc    productos.sproduc%TYPE   := psproduc;
      v_cidioma   idiomas.cidioma%TYPE     := pac_md_common.f_get_cxtidioma;
      -- BUG 18825 - 19/07/2011 - JMP
      vtabla      VARCHAR2 (300);
      wobject     VARCHAR2 (1000)          := 'PAC_DOMIS.F_RETORNA_QUERY';
      err         PLS_INTEGER;
   BEGIN
      IF psprodom IS NOT NULL
      THEN
         v_where :=
               ' and pr.sproduc in (SELECT sproduc
           FROM tmp_domisaux
          WHERE sproces = '
            || psprodom
            || '
            AND cestado = 1)  ';
         wsproduc := NULL;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (cempres, 'MONEDA_POL'), 0) = 1
      THEN
         vtabla := 'vdetrecibos_monpol';
      ELSE
         vtabla := 'vdetrecibos';
      END IF;

      v_result :=
            'SELECT S.sseguro, pac_isqlfor.f_empresa(s.sseguro) EMPRESA, f_desproducto_T(S.cramo,S.cmodali,S.ctipseg,S.ccolect,1, nvl('
         || NVL (TO_CHAR (v_cidioma), 'NULL')
         || ', p.nvalpar) ) PRODUCTO,'
         || 'c.ccobban||''-''||c.descripcion CODBANCAR, c.ncuenta COBRADOR, R.nrecibo NRECIBO,s.npoliza|| ''-'' || s.NCERTIF NPOLIZA,DV.tatribu  TIPO_RECIBO,'
         || '(SELECT f_nombre(t1.sperson,1,s1.cagente) FROM TOMADORES t1, SEGUROS s1 '
         || 'WHERE NVL(t1.nordtom,1) = 1 AND t1.sseguro = s1.SSEGURO AND s1.SSEGURO = s.sseguro) TOMADOR,'
         || 'R.fefecto FEFECTO, R.fvencim FVENCIM, R.cbancar CBANCAR, '
         -- 36. 0026169 - 0138818 - Inicio
         || ' DR.itotalr  +  (decode(pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc),2, (SELECT NVL(SUM(v2.itotalr), 0) '
         -- 36. 0026169 - 0138818 - Inicio
         || ' FROM adm_recunif ar, '
         || vtabla
         || ' v2
                   WHERE ar.nrecunif = r.nrecibo
                     AND ar.nrecibo = v2.nrecibo
                     AND ar.nrecunif <> ar.nrecibo AND ar.sdomunif IS NOT NULL) ,0)) ITOTALR, '
         || 'null ctipban_cobra, null ctipban_cban, null proceso, null fichero, '
         -- BUG 18825 - 19/07/2011 - JMP
         || 'ff_desvalorfijo(383, nvl('
         || NVL (TO_CHAR (v_cidioma), 'NULL')
         || ', p.nvalpar), f_cestrec_mv(r.nrecibo, '
         || v_cidioma
         || ', NULL)) estado, '
         || 'ff_desvalorfijo(75, '
         || v_cidioma
         || ', r.cestimp) testimp, '
         || 'null est_domi, null festado ' -- FIN BUG 18825 - 19/07/2011 - JMP
         -- 8. 0021718 / 0111176 - Inicio
         || ', r.cagente, F_DESAGENTE_T(r.cagente) tagente, r.nanuali, r.nfracci, null frecaudo, null frechazo, null cdevrec '
         -- 8. 0021718 / 0111176 - Fin
         || 'FROM productos pr, parinstalacion P,seguros s, cobbancario c, recibos r, movrecibo m, empresas e, detvalores DV, '
         || vtabla
         || ' DR '
         || 'WHERE '
         || 'r.cempres = NVL( '
         || NVL (TO_CHAR (cempres), 'NULL')
         || ' , r.cempres) AND r.cempres = e.cempres AND '
         || 'r.fefecto  <= to_date( '''
         || fefecto
         || ''',''ddmmyyyy'') AND '
         || ' r.fefecto  >= nvl(to_date( '''
         || pdfefecto
         || ''',''ddmmyyyy''),r.fefecto) AND '
         -- 43. 0028200: Error en la domiciliación de recibos de retorno - QT-9324 y QT-9326 - Inicio
         || '(r.cestimp = 4 OR (r.cestimp = 11 AND TRUNC(FESTIMP)<= trunc(f_sysdate))) AND r.ctiprec NOT IN (9, 13, 15) AND r.ccobban = c.ccobban AND '
         -- 43. 0028200: Error en la domiciliación de recibos de retorno - QT-9324 y QT-9326 - Final
         || 'r.sseguro = s.sseguro AND r.nrecibo = m.nrecibo AND m.cestrec = 0 AND  m.fmovfin is null AND  r.cestaux = 0 AND '
         || 'nvl(r.cgescob,1) = 1 AND DV.cvalor = 8 AND DV.catribu = R.ctiprec AND DV.cidioma = nvl('
         -- BUG 18825 - 19/07/2011 - JMP
         || NVL (TO_CHAR (v_cidioma), 'NULL')
         -- FIN BUG 18825 - 19/07/2011 - JMP
         || ', p.nvalpar) AND Dr.nrecibo = R.nrecibo AND '
         -- 36. 0026169 - 0138818 - Inicio
         || '((pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (1,3) and r.nrecibo not in (select nrecibo from adm_recunif)) '
         || '  or '
         || '(pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (2,4) and 0=(select count(0) from adm_recunif a where a.nrecibo = r.nrecibo and a.nrecunif<> r.nrecibo)) '
         || '  or '
         || '  ( NVL(pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc), -1) NOT IN(1, 2, 3, 4))) AND '
         -- 36. 0026169 - 0138818 - Fin
         -- BUG 0019627: GIP102 - Reunificación de recibos - FAL - 10/11/2011
         || 'pr.sproduc(+) = s.sproduc AND s.sproduc = NVL('
         || NVL (TO_CHAR (wsproduc), 'NULL')
         || ', s.sproduc) AND S.cramo = nvl( '
         || NVL (TO_CHAR (cramo), 'NULL')
         || ' , NVL(pr.cramo, S.cramo)) AND '
         || 'S.cmodali = NVL(pr.cmodali, S.cmodali) AND S.ctipseg = NVL(pr.ctipseg, S.ctipseg) AND '
         || 'S.ccolect = NVL(pr.ccolect, S.ccolect) AND P.CPARAME = ''IDIOMARTF'''
         || ' and c.cempres = r.cempres '
         || 'AND('
         || NVL (TO_CHAR (pccobban), 'NULL')
         || ' IS NULL OR '
         || NVL (TO_CHAR (pccobban), 'NULL')
         || ' = r.ccobban) AND c.cdoment = NVL('
         || NVL (TO_CHAR (pcbanco), 'NULL')
         || ', c.cdoment) AND('
         || NVL (TO_CHAR (pctipcta), 'NULL')
         || ' IS NULL OR '
         || NVL (TO_CHAR (pctipcta), 'NULL')
         || ' = r.ctipban) AND('
         || NVL (pfvtotar, 'NULL')
         || ' IS NULL OR '
         || NVL (pfvtotar, 'NULL')
         || ' = SUBSTR(r.cbancar, 21, 4)) AND('
         || NVL (pcreferen, 'NULL')
         || ' IS NULL '
         || 'OR '
         || NVL (pcreferen, 'NULL')
         || ' = (SELECT rebut_ini FROM cnvrecibos '
         || 'WHERE nrecibo = r.nrecibo)) ';

      -- 8. 0021718 / 0111176 - Inicio
      IF pcagente IS NOT NULL
      THEN
         v_result := v_result || ' and r.cagente = ' || pcagente;
      END IF;

      IF ptagente IS NOT NULL
      THEN                                                  -- Nombre Mediador
         v_result :=
               v_result
            || ' and F_DESAGENTE_T(r.cagente) like ''%'
            || UPPER (ptagente)
            || '%'' ';
      END IF;

      --AGG modificaciones SEPA
      IF NVL (pac_parametros.f_parempresa_n (cempres, 'DOMIS_IBAN_XML'), 0) =
                                                                             1
      THEN
         --Comprobamos que el banco del deudor tiene informado el código BIC
         v_result :=
               v_result
            || ' AND EXISTS ( '
            || ' select 1'
            || ' from tipos_cuenta t, bancos b, recibos r '
            || ' where b.cbic is not null'
            || ' and t.ctipban = r.ctipban '
            || ' and b.cbanco = SUBSTR(r.cbancar, NVL(t.pos_entidad, 1), '
            || ' NVL(t.long_entidad, 4)) )';
         --Comprobamos que el mandato esté activo
         v_result :=
               v_result
            || ' AND pac_sepa.f_mandato_activo(s.sseguro, r.nrecibo) = 1 ';
      END IF;

      --AGG fin moficaciones SEPA
      IF pnnumide IS NOT NULL OR pttomador IS NOT NULL
      THEN                                                      -- Nif Tomador
         v_result :=
               v_result
            || ' and EXISTS (SELECT 1 FROM TOMADORES T, PER_PERSONAS P, PER_DETPER Q '
            || ' WHERE t.sseguro = r.sseguro '
            || '   AND t.sperson = p.sperson '
            || '   AND t.sperson = q.sperson ';

         IF pnnumide IS NOT NULL
         THEN
            v_result :=
                  v_result
               || ' AND p.nnumide like '''
               || UPPER (pnnumide)
               || CHR (39);
         --> 30. 0022268 / 0114762 + 0114943 (quitar comillas)
         END IF;

         IF pttomador IS NOT NULL
         THEN
            v_result :=
                  v_result
               || ' AND q.TBUSCAR like ''%'
               || UPPER (pttomador)
               || '%''';
         END IF;

         v_result := v_result || ' )';
      END IF;

      IF pnrecibo IS NOT NULL
      THEN                                                           -- Recibo
         v_result := v_result || ' and r.nrecibo = ' || pnrecibo;
      END IF;

      -- RSA mandatos
      IF NVL (pac_parametros.f_parempresa_n (cempres, 'INS_MANDATO'), 0) = 1
      THEN
         -- Se comprueba que el estado del mandato sea En tránsito o Aprobado
         v_result :=
               v_result
            || ' AND pac_mandatos.f_get_estado_mandato(s.sseguro) IN (1, 3) '
            || ' AND pac_mandatos.f_vigencia_mandato(s.sseguro) = 0 ';
      -- Bug 32676 - 20141016 - MMS -- Agregammos ffinvin
      END IF;

      -- 8. 0021718 / 0111176 - Fin
      v_result := v_result || v_where;

      IF filtradomaximo = TRUE
      THEN
         v_max_reg := f_parinstalacion_n ('N_MAX_REG');

         IF v_max_reg IS NOT NULL
         THEN
            v_result := v_result || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      -- Bug 0029371 - dlF - 05-VIII-2014 - POSAN100-POSADM Domicliación - Inconsistencia Proceso de Prenotificación --
      -- Número máximo de recibos 'REMESADOS' por póliza
      IF NVL (pac_parametros.f_parempresa_n (cempres, 'NUMMAX_REC_DOM_X_POL'),
              0
             ) >= 1
      THEN
         v_result :=
               v_result
            || ' AND NVL(pac_parametros.f_parempresa_n(r.cempres, ''NUMMAX_REC_DOM_X_POL''), 0) > ( '
            || ' select count(1)'
            || ' from recibos x, movrecibo y '
            || ' where x.sseguro = s.sseguro '
            || '   and x.nrecibo = y.nrecibo'
            || '   and y.fmovfin is null '
            || '   and y.cestrec = 3'
            || ')';
      END IF;

      -- fin Bug 0029371 - dlF - 5-VIII-2014 --------------------------------------------------------------------------
      v_result := v_result || ' order by r.cempres, s.npoliza, r.nrecibo';
      err := pac_log.f_log_consultas (v_result, wobject, 1, 3);
      RETURN v_result;
   END f_retorna_query;

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_INSERT_TMP_DOMISAUX
   Función que insertará en la tabla temporal los productos seleccionados para el
   proceso de domiciliación de recibos.
   Parámetros:
    Entrada :
       Pcempres  NUMBER
       Psproces  NUMBER
       Psproduc  NUMBER
       Pseleccio NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_insert_tmp_domisaux (
      pcempres    IN   NUMBER,
      psproces    IN   NUMBER,
      psproduc    IN   NUMBER,
      pseleccio   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
         :=    'Pcempres='
            || pcempres
            || ' Psproces='
            || psproces
            || ' Psproduc='
            || psproduc
            || ' Pseleccio='
            || pseleccio;
      vobject    VARCHAR2 (200) := 'PAC_DOMIS.F_INSERT_TMP_DOMISAUX';
   BEGIN
      -- Control parametros entrada
      IF    pcempres IS NULL
         OR psproces IS NULL
         OR psproduc IS NULL
         OR pseleccio IS NULL
      THEN
         RETURN 140974;                      --Faltan parametros por informar
      END IF;

      -- Función que debe realizar un insert en la tabla tmp_carteraux, con la información recibida.
      INSERT INTO tmp_domisaux
                  (sproces, sproduc, cestado
                  )
           VALUES (psproces, psproduc, pseleccio
                  );

      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      --En el caso de existir el registro debe actualizar  el campo selección.
      WHEN DUP_VAL_ON_INDEX
      THEN
         BEGIN
            UPDATE tmp_domisaux
               SET cestado = pseleccio
             WHERE sproces = psproces AND sproduc = psproduc;

            vpasexec := 3;
            RETURN 0;
         EXCEPTION
            WHEN OTHERS
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam,
                            SQLERRM
                           );
               RETURN 9000691;
         END;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 9000690;
   END f_insert_tmp_domisaux;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación

   -- Bug 19986 - APD - 04/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_agrupa_recibos_domiciliados
   Función que agrupa recibos domiciliados.
   Se agrupan los recibos con la misma cuenta bancaria
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_agrupa_recibos_domiciliados (psproces IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)                     := 1;
      vparam     VARCHAR2 (200)                 := 'Psproces=' || psproces;
      vobject    VARCHAR2 (200)  := 'PAC_DOMIS.F_AGRUPA_RECIBOS_DOMICILIADOS';

      -- 36. 0026169 - 0138818 - Inicio
      /*
      CURSOR cur_domi(ppsproces IN NUMBER) IS
         (SELECT   cbancar
              FROM domiciliaciones d, cobbancario c
             WHERE sproces = ppsproces
               AND NVL(f_parproductos_v(f_sproduc_ret(cramo, cmodali, ctipseg, ccolect),
                                        'RECUNIF'),
                       0) = 2
               AND d.ccobban = c.ccobban
               AND NVL(c.cagruprec, 0) = 1
          GROUP BY cbancar
            HAVING COUNT(cbancar) > 1);
       */
      -- 45.0 - 24/12/2013 - MMM - 0028910: LCOL_MILL-9971 + 9985 + 9969- Problemas con las cargas de devoluciones bancarias - Inicio
      /*CURSOR cur_domi(ppsproces IN NUMBER) IS
         (SELECT   cbancar
              FROM domiciliaciones d
             WHERE sproces = ppsproces
               AND pac_domis.f_agrupa_rec_domis(ccobban, cempres) = 1
          GROUP BY cbancar
            HAVING COUNT(cbancar) > 1);*/
      CURSOR cur_domi (ppsproces IN NUMBER)
      IS
         SELECT   d.cbancar, NVL (r.sperson, t.sperson) sperson
             FROM domiciliaciones d, tomadores t, recibos r
            WHERE sproces = psproces
              AND pac_domis.f_agrupa_rec_domis (d.ccobban, d.cempres) = 1
              AND d.sseguro = t.sseguro
              AND t.nordtom = (SELECT MIN (z.nordtom)
                                 FROM tomadores z
                                WHERE z.sseguro = d.sseguro)
              AND d.nrecibo = r.nrecibo
         GROUP BY d.cbancar, NVL (r.sperson, t.sperson);

      -- 45.0 - 24/12/2013 - MMM - 0028910: LCOL_MILL-9971 + 9985 + 9969- Problemas con las cargas de devoluciones bancarias - Fin

      -- 36. 0026169 - 0138818 - Fin
      vnumerr    NUMBER;
      vncont     NUMBER;
      vnrecibo   domiciliaciones.nrecibo%TYPE;
      salir      EXCEPTION;
   BEGIN
      -- Control parametros entrada
      IF psproces IS NULL
      THEN
         vnumerr := 140974;                  --Faltan parametros por informar
         RAISE salir;
      END IF;

      vpasexec := 2;

      FOR reg IN cur_domi (psproces)
      LOOP
         vpasexec := 3;
         vncont := 1;

         -- 36. 0026169 - 0138818 - Inicio
         /*
            FOR reg2 IN (SELECT   nrecibo, cbancar
                             FROM domiciliaciones d, cobbancario c
                            WHERE sproces = psproces
                              AND NVL(f_parproductos_v(f_sproduc_ret(cramo, cmodali, ctipseg, ccolect),
                                                       'RECUNIF'),
                                      0) = 2
                              AND d.ccobban = c.ccobban
                              AND NVL(c.cagruprec, 0) = 1
                              AND cbancar = reg.cbancar
                         ORDER BY nrecibo) LOOP
         */

         -- misma select que el cursor cur_domi pero añadiendo el filtro por cbancar

         -- 45.0 - 24/12/2013 - MMM - 0028910: LCOL_MILL-9971 + 9985 + 9969- Problemas con las cargas de devoluciones bancarias - Inicio
         /*FOR reg2 IN (SELECT   nrecibo, cbancar
                          FROM domiciliaciones d
                         WHERE sproces = psproces
                           AND pac_domis.f_agrupa_rec_domis(ccobban, cempres) = 1
                           AND cbancar = reg.cbancar
                      ORDER BY nrecibo) LOOP*/
         FOR reg2 IN (SELECT   d.nrecibo, d.cbancar,
                               NVL (r.sperson, t.sperson) sperson
                          FROM domiciliaciones d, tomadores t, recibos r
                         WHERE sproces = psproces
                           AND pac_domis.f_agrupa_rec_domis (d.ccobban,
                                                             d.cempres
                                                            ) = 1
                           AND d.sseguro = t.sseguro
                           AND t.nordtom = (SELECT MIN (z.nordtom)
                                              FROM tomadores z
                                             WHERE z.sseguro = d.sseguro)
                           AND d.nrecibo = r.nrecibo
                           --AND d.nrecibo = reg.nrecibo
                           AND d.cbancar = reg.cbancar
                           AND NVL (r.sperson, t.sperson) = reg.sperson
                      ORDER BY nrecibo)
         LOOP
            -- 45.0 - 24/12/2013 - MMM - 0028910: LCOL_MILL-9971 + 9985 + 9969- Problemas con las cargas de devoluciones bancarias - Fin

            -- 36. 0026169 - 0138818 - Fin
            vpasexec := 4;

            IF vncont = 1
            THEN
               vnrecibo := reg2.nrecibo;
            END IF;

            vpasexec := 5;

            IF vncont <> 1
            THEN
               -- Se realiza el insert en ADM_RECUNIF donde el recibo unificado (NRECUNIF)
               -- será siempre el primer recibo (ya que en este caso no se crea un nuevo
               -- recibo que unifique todos los recibos)
               -- 36. 0026169 - 0138818 - Inicio
               INSERT INTO adm_recunif
                           (nrecibo, nrecunif, sdomunif
                           )
                    VALUES (reg2.nrecibo, vnrecibo, psproces
                           );

               vpasexec := 6;

               IF vncont = 2
               THEN
                  INSERT INTO adm_recunif
                              (nrecibo, nrecunif, sdomunif
                              )
                       VALUES (vnrecibo, vnrecibo, psproces
                              );
               END IF;

               -- 36. 0026169 - 0138818 - Fin
               vpasexec := 7;

               -- Se deben eliminar de DOMICILIACIONES todos los recibos que se han
               -- unificado menos el primer registro (que es el que nos indica el
               -- recibo que unifica todos los recibos)
               DELETE FROM domiciliaciones
                     WHERE sproces = psproces AND nrecibo = reg2.nrecibo;
            END IF;

            vpasexec := 8;
            vncont := vncont + 1;
         END LOOP;
      END LOOP;

      vpasexec := 7;
      -- Si todo ok, se realiza el COMMIT
      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (vnumerr)
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_agrupa_recibos_domiciliados;

-- FI Bug 19986 - APD - 04/11/2011

   -- Bug 19986 - APD - 07/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_desagrupa_recibos_domici
   Función que desagrupa recibos domiciliados.
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_desagrupa_recibos_domici (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'pnrecibo=' || pnrecibo;
      vobject    VARCHAR2 (200) := 'PAC_DOMIS.F_DESAGRUPA_RECIBOS_DOMICI';
      vnumerr    NUMBER;
      salir      EXCEPTION;
   BEGIN
      -- Control parametros entrada
      IF pnrecibo IS NULL
      THEN
         vnumerr := 140974;                  --Faltan parametros por informar
         RAISE salir;
      END IF;

      vpasexec := 2;

      DELETE FROM adm_recunif
            WHERE nrecunif = pnrecibo;

      vpasexec := 3;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (vnumerr)
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_desagrupa_recibos_domici;

-- FI Bug 19986 - APD - 04/11/2011

   -- Bug 19999 - APD - 07/11/2011 - se crea la funcion
   /*******************************************************************************
   FUNCION f_estado_domiciliacion
   Función que modifica el estado de los recibos domiciliados.
   Parámetros:
    Entrada :
       Psproces  NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_estado_domiciliacion (
      pcempres   IN       NUMBER DEFAULT pac_md_common.f_get_cxtempresa,
      psproces   IN       NUMBER,
      pnrecibo   IN       NUMBER,
      pcestrec   IN       NUMBER,
      pnum_ok    OUT      NUMBER,
      pnum_ko    OUT      NUMBER,
      pfdebito   IN       DATE DEFAULT NULL           -- 26. 0021663 / 0109768
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'Psproces=' || psproces;
      vobject    VARCHAR2 (200) := 'PAC_DOMIS.F_ESTADO_DOMICILIACION';

      CURSOR c_dom (psproces NUMBER, pnrecibo NUMBER)
      IS
         SELECT *
           FROM domiciliaciones
          WHERE sproces = psproces
            AND (nrecibo = pnrecibo OR pnrecibo IS NULL)
            AND (cerror = 0 OR
--> 25/11/2011 JGR 0020037: Parametrización de Devoluciones (Necesario para LCOL)
                              cerror IS NULL);

--> 25/11/2011 JGR 0020037: Parametrización de Devoluciones (Necesario para LCOL)
      num_err    NUMBER;
      lnliqlin   NUMBER;
      lnliqmen   NUMBER;
      lsmovagr   NUMBER;
      lcerror    NUMBER;
      lcdomest   NUMBER;
      -- ECP - 30/10/2012-- Actualiza estado de la domiciliación
      xnprolin   NUMBER;
      vfmovini   DATE;
--(NEW)-- 38.0  0027264: Errores en la carga de archivos VISA - QT-6189 - Inicio
      texto      VARCHAR2 (400);
      salir      EXCEPTION;
   BEGIN
      vpasexec := 2;

      -- Control parametros entrada
      IF psproces IS NULL OR pcestrec IS NULL
      THEN
         num_err := 140974;                  --Faltan parametros por informar
         RAISE salir;
      END IF;

      vpasexec := 5;
      pnum_ok := 0;
      pnum_ko := 0;
      lsmovagr := 0;
      vpasexec := 3;
      vpasexec := 10;

      FOR v_dom IN c_dom (psproces, pnrecibo)
      LOOP
         -- Cobrem el rebut
         lnliqmen := NULL;
         lnliqlin := NULL;
         num_err := 0;
         vpasexec := 20;

         -- BUG 0019999 - 14/11/2011 - JMF
         IF pcestrec <> 0
         THEN
            -- Bug 9383 - 09/03/2009 - RSC - CRE: Unificación de recibos
                 -- El cobro del recibo unificado debe dejar los recibos
                 -- pequeñitos en estado cobrado

            -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
            -- 36. Aquí optamos por no controlar si requiere agrupación, si la hay suma sino será 0 - Comentamos el IF

            --IF NVL(f_parproductos_v(f_sproduc_ret(v_dom.cramo, v_dom.cmodali, v_dom.ctipseg,
            --                                      v_dom.ccolect),
            --                        'RECUNIF'),
            --       0) IN(1, 2, 3) THEN
            vpasexec := 30;

            IF NVL
                  (pac_domis.f_agrupa_rec_tipo (v_dom.ccobban,
                                                pcempres,
                                                f_sproduc_ret (v_dom.cramo,
                                                               v_dom.cmodali,
                                                               v_dom.ctipseg,
                                                               v_dom.ccolect
                                                              )
                                               ),
                   0
                  ) IN (1, 2, 3, 4)
            THEN
               -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin

               -- BUG 0019627: GIP102 - Reunificación de recibos - FAL - 10/11/2011
                    -- Si es un recibo agrupado entrará en LOOP
                    -- Bug 19986 - APD - 04/11/2011 - se añade la condicion AND nrecunif <> nrecibo
                    -- para que en el caso que 'RECUNIF' = 2 el recibo unificado lo cobre en el
                    -- f_movrecibo de fuera del LOOP
               vpasexec := 40;

               FOR v_recind IN
                  (SELECT nrecibo
                     FROM adm_recunif a
                    WHERE (   nrecunif IN (SELECT nrecibo
                                             FROM adm_recunif
                                            WHERE nrecunif = v_dom.nrecibo)
                           OR nrecunif = v_dom.nrecibo
                          )
                      AND nrecunif <> nrecibo)
               LOOP
                  vpasexec := 50;

                  -- 38.0  0027264: Errores en la carga de archivos VISA - QT-6189 - Inicio
                  -- Nos aseguramos que no nos impedirá grabar el movimiento
                  -- sobre el recibo a modificar, porque la fecha sea anterior a
                  -- la de su último movimiento
                  BEGIN
                     SELECT fmovini
                       INTO vfmovini
                       FROM movrecibo
                      WHERE nrecibo = v_recind.nrecibo AND fmovfin IS NULL;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        vpasexec := 55;
                        num_err := 104043;
                        -- Error al leer de la tabla MOVRECIBO
                        RAISE salir;
                  END;

                  -- 38.0  0027264: Errores en la carga de archivos VISA - QT-6189 - Fin
                  num_err :=
                     f_movrecibo (v_recind.nrecibo,
                                  pcestrec,
                                  NULL,
                                  NULL,
                                  lsmovagr,
                                  lnliqmen,
                                  lnliqlin,
                                  -- v_dom.fefecto,          -- 26. 28. 0021663 / 0109768
                                  -- 38.0  0027264: Errores en la carga de archivos VISA - QT-6189 - Inicio
                                  -- NVL(pfdebito, v_dom.fefecto),
                                  -- 42.0 - 26/08/2013 - MMM - 0027973: LCOL_A003- QT 0009013: Error al enviar notificacion de cobro de poliza a JDE - Inicio
                                  -- Se modifica el LEAST por el GREATEST para evitar obtener una fecha anterior al último movimiento
                                  --LEAST(NVL(pfdebito, v_dom.fefecto), vfmovini),
                                  GREATEST (NVL (pfdebito, v_dom.fefecto),
                                            vfmovini
                                           ),
                                  -- 42.0 - 26/08/2013 - MMM - 0027973: LCOL_A003- QT 0009013: Error al enviar notificacion de cobro de poliza a JDE - Fin
                                  -- 38.0  0027264: Errores en la carga de archivos VISA - QT-6189 - Fin
                                  -- 26. 28. 0021663 / 0109768
                                  v_dom.ccobban,
                                  NULL,
                                  NULL,
                                  v_dom.cagente,
                                  v_dom.cagrpro,
                                  v_dom.ccompani,
                                  v_dom.cempres,
                                  v_dom.ctipemp,
                                  v_dom.sseguro,
                                  v_dom.ctiprec,
                                  v_dom.cbancar,
                                  v_dom.nmovimi,
                                  v_dom.cramo,
                                  v_dom.cmodali,
                                  v_dom.ctipseg,
                                  v_dom.ccolect,
                                  NULL,                             --nomovrec
                                  NULL,                               --usucob
                                  v_dom.fefecrec,
                                  v_dom.pgasint,
                                  v_dom.pgasext,
                                  v_dom.cfeccob
                                 );
                  vpasexec := 60;

                  IF num_err = 0
                  THEN
                     -- Act rebut com domiciliat
                     vpasexec := 70;

                     BEGIN
                        UPDATE recibos
                           SET cestimp = 5
                         WHERE nrecibo = v_recind.nrecibo;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           vpasexec := 80;
                           num_err := 102358;   -- Error al modificar RECIBOS
                           RAISE salir;
                     END;
                  END IF;
               --num_err := F_COBRECIBOS(NULL, NULL, regs.nrecibo, NULL, NULL);
               END LOOP;

               -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
               -- 32. Debemos desagrupar los recibos tratados, aquí los cobrados. En pac_devolu.f_impaga_rebut_2 los devueltos.
               num_err := pac_domis.f_desagrupa_rec (pnrecibo);
            -- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin
            END IF;

            -- Fin Bug 9383
            vpasexec := 90;
            -- bug 8416
            num_err :=
               f_movrecibo (v_dom.nrecibo,
                            pcestrec,
                            NULL,
                            NULL,
                            lsmovagr,
                            lnliqmen,
                            lnliqlin,
                            -- v_dom.fefecto,          -- 26. 28. 0021663 / 0109768
                            NVL (pfdebito, v_dom.fefecto),
                            -- 26. 28. 0021663 / 0109768
                            v_dom.ccobban,
                            NULL,
                            NULL,
                            v_dom.cagente,
                            v_dom.cagrpro,
                            v_dom.ccompani,
                            v_dom.cempres,
                            v_dom.ctipemp,
                            v_dom.sseguro,
                            v_dom.ctiprec,
                            v_dom.cbancar,
                            v_dom.nmovimi,
                            v_dom.cramo,
                            v_dom.cmodali,
                            v_dom.ctipseg,
                            v_dom.ccolect,
                            NULL,                                   --nomovrec
                            NULL,                                     --usucob
                            v_dom.fefecrec,
                            v_dom.pgasint,
                            v_dom.pgasext,
                            v_dom.cfeccob
                           );
         -- BUG 8416
         END IF;

         vpasexec := 100;

         -- BUG 8416
         IF num_err = 0
         THEN
            -- Act rebut com domiciliat
            BEGIN
               UPDATE recibos
                  SET cestimp = 5
                WHERE nrecibo = v_dom.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  num_err := 102358;            -- Error al modificar RECIBOS
            END;
         END IF;

         -- Si ha anat be fem commit, sino rollback
         -- per cada registre, i guardem el resultat
         -- a domiciliaciones
         vpasexec := 110;
         lcerror := num_err;        -- Es guarda per updatar a domiciliaciones
         vpasexec := 120;

         --ECP- Actualiza el estado de la domiciliaciòn 1 -> OK 0-> KO
         -- 38.0 - 0027264: Errores en la carga de archivos VISA - QT-6189 - Inicio
         /*
         IF lcerror = 0 THEN
            lcdomest := 1;
         ELSE
            lcdomest := 0;
         END IF;
         */
         IF lcerror = 0
         THEN
            lcdomest := 0;
         ELSE
            lcdomest := 1;
         END IF;

         -- 38.0 - 0027264: Errores en la carga de archivos VISA - QT-6189 - Final
         vpasexec := 130;

         IF num_err = 0
         THEN
            pnum_ok := pnum_ok + 1;
            COMMIT;
         ELSE
            pnum_ko := pnum_ko + 1;
            ROLLBACK;
            xnprolin := NULL;
            texto := f_axis_literales (num_err);
            num_err := f_proceslin (psproces, texto, v_dom.nrecibo, xnprolin);
            COMMIT;
         END IF;

         vpasexec := 140;

         BEGIN
            vpasexec := 150;

            UPDATE domiciliaciones
               SET smovrec = lsmovagr,
                   cerror = lcerror,
                   cdomest = lcdomest
             -- ECP -- 30/10/2012 Actualiza estado de la domiciliación
            WHERE  sproces = psproces AND nrecibo = v_dom.nrecibo;

            COMMIT;
         EXCEPTION
            WHEN OTHERS
            THEN
               vpasexec := 160;
               xnprolin := NULL;
               texto := f_axis_literales (102922);
               texto := SUBSTR (texto || ' ' || SQLERRM, 1, 120);
               num_err :=
                       f_proceslin (psproces, texto, v_dom.nrecibo, xnprolin);
               COMMIT;
               RETURN 102922;
         END;
      END LOOP;

      vpasexec := 170;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err)
                     );
         RETURN num_err;
      WHEN OTHERS
      THEN
         ROLLBACK;
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_estado_domiciliacion;

-- FI Bug 19986 - APD - 04/11/2011

   -- Bug 21116 - APD - 27/01/2012 - se crea la funcion
   /*******************************************************************************
   FUNCION f_valida_domi_cobban
   Función que valida que si existe una domiciliación en curso para un cobrador bancario,
   no permita realizar una nueva domiciliación de este cobrador bancario
   Parámetros:
    Entrada :
       pcempres  NUMBER
       pccobban  NUMBER
       psseguro IN NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_valida_domi_cobban (
      pcempres   IN   NUMBER,
      pccobban   IN   NUMBER,
      psseguro   IN   NUMBER DEFAULT NULL,
      psproces   IN   NUMBER DEFAULT NULL
   )                     -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
         :=    'pccobban='
            || pccobban
            || '; pcempres='
            || pcempres
            || '; psseguro='
            || psseguro
            || '; psproces='
            || psproces;
      vobject    VARCHAR2 (200) := 'PAC_DOMIS.F_VALIDA_DOMI_COBBAN';
      num_err    NUMBER;
      salir      EXCEPTION;
      v_cont     NUMBER;
   BEGIN
      vpasexec := 1;

      -- 35. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666 - Inicio
      IF psseguro IS NOT NULL
      THEN
         vpasexec := 2;
         num_err := pac_domis.f_valida_domi_poliza (psseguro);
         RETURN num_err;
      -- IF psproces IS NOT NULL THEN
      ELSIF psproces IS NOT NULL
      THEN
         vpasexec := 3;
         -- 29. JGR 03/04/2012 - 0021718 / 0111176 - Inicio
         -- IF psproces IS NOT NULL THEN
         -- 35. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666 - Fin
         vpasexec := 2;

         SELECT cestdom                               --> 0 Cerrada, 1 Abierta
           INTO v_cont
           FROM domiciliaciones_cab d
          WHERE d.sproces = psproces;

         IF v_cont = 0
         THEN                               --si esta cerrada devolvemos error
            RETURN 9903354;
         END IF;
      ELSE
         vpasexec := 3;

         SELECT COUNT (1)
           INTO v_cont
           FROM domiciliaciones_cab d
          WHERE (d.ccobban = pccobban OR pccobban IS NULL)
            AND (d.cempres = pcempres OR pcempres IS NULL)
            AND cestdom = 1;                                     --> 1 Abierta

         IF v_cont > 0
         THEN
            num_err := 9903188;
            -- Existe una domiciliación en curso para el cobrador bancario
            RAISE salir;
         END IF;
      END IF;

       /*
      SELECT COUNT(1)
        INTO v_cont
        FROM domiciliaciones d
       WHERE (d.ccobban = pccobban
              OR pccobban IS NULL)
         AND(d.cempres = pcempres
             OR pcempres IS NULL)
         AND(d.sseguro = psseguro
             OR psseguro IS NULL)
         -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527 - Cambiar control domis cerrada - Inicio
         AND(d.sproces = psproces
             OR psproces IS NULL)
         AND d.tfiledev IS NULL;
      */
       -- 29. JGR 03/04/2012 - 0021718 / 0111176 - Fin

      --   AND d.nrecibo IN(SELECT r.nrecibo
      --                      FROM recibos r, movrecibo m
      --                     WHERE r.nrecibo = d.nrecibo
      --                       AND r.sseguro = d.sseguro
      --                       AND r.nrecibo = m.nrecibo
      --                       AND m.fmovfin IS NULL
      --                       AND m.cestrec = 3);   -- remesado (v.f.1)
      -- IF v_cont > 0
      --    AND psproces IS NULL THEN   -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
      --    num_err := 9903188;   -- Existe una domiciliación en curso para el cobrador bancario
      --    RAISE salir;
      -- ELSIF psproces IS NOT NULL THEN   -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
      --    RETURN v_cont;   -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
      -- END IF;
      vpasexec := 4;

      -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527 - Cambiar control domis cerrada - Fin
      IF v_cont > 0 AND psproces IS NULL
      THEN               -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
         vpasexec := 5;
         num_err := 9903188;
         -- Existe una domiciliación en curso para el cobrador bancario
         RAISE salir;
         -- 27. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 - Inicio
      -- ELSIF psproces IS NOT NULL THEN   -- 25.JGR 27. 21120: LCOL897-LCOL_A001- Nota: 0109527
      -- RETURN v_cont;
      ELSIF     v_cont = 0           -- No hay ninguna abierta (cerrada) y ...
            AND psproces IS NOT NULL
      THEN                  -- si pscproces está informado es una regeneración
         vpasexec := 6;
         num_err := 9903704;
         -- No se permite regenerar archivos de remesas cerradas
         RAISE salir;
      -- 27. 0022268: LCOL_A001-Revision circuito domiciliaciones - 0114762 + 0114943 - Fin
      END IF;

      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_valida_domi_cobban;

-- FI Bug 21116 - APD - 27/01/2012

   -- ini BUG 21318 : MDS : 13/02/2012
    /*************************************************************************
        FUNCTION f_retorna_query2 (evolución de la f_retorna_query)
        Función que retornará la select de PREVIO_DOMICILIACIONES

        param in fefecto: VARCHAR2 - Obligatoria - Fecha Efecto (formato DD/MM/YYYY)
        param in cramo:   NUMBER - Opcional - Codigo Ramo
        param in sproduc: NUMBER - Opcional - Codigo Producto
        param in cempres: NUMBER - Opcional - Codigo Empresa
        param in FiltradoMaximo: BOOLEAN (defecto FALSE)- Será TRUE si se llama por pantalla para filtrar el numero de resultados.
        param in pccobban  : Código de cobrador bancario
        param in pcbanco   : Código de banco
        param in pctipcta  : Tipo de cuenta
        param in pfvtotar  : Fecha de vencimiento tarjeta
        param in pcreferen : Código de referencia
        return             : Devolverá un VARCHAR2 con la SELECT usada en Map, pantalla y proceso.
    *************************************************************************/
   FUNCTION f_retorna_query2 (
      fefecto          IN   VARCHAR2,
      cramo            IN   NUMBER,
      psproduc         IN   NUMBER,
      cempres          IN   NUMBER,
      psprodom         IN   NUMBER DEFAULT NULL,
      filtradomaximo   IN   BOOLEAN DEFAULT FALSE,
      pccobban         IN   NUMBER DEFAULT NULL,
      pcbanco          IN   NUMBER DEFAULT NULL,
      pctipcta         IN   NUMBER DEFAULT NULL,
      pfvtotar         IN   VARCHAR2 DEFAULT NULL,
      pcreferen        IN   VARCHAR2 DEFAULT NULL,
      pdfefecto        IN   VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      v_max_reg   NUMBER;
      v_result    VARCHAR2 (6000);
      v_where     VARCHAR2 (200)           := ' and 1=1 ';
      wsproduc    productos.sproduc%TYPE   := psproduc;
      v_cidioma   idiomas.cidioma%TYPE     := pac_md_common.f_get_cxtidioma;
      vtabla      VARCHAR2 (300);
      vparam      VARCHAR2 (2000);                   -- 36. 0026169 - 0138818
   BEGIN
      -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
      vparam :=
            'fefecto:'
         || fefecto
         || ' cramo:'
         || cramo
         || ' psproduc:'
         || psproduc
         || ' cempres:'
         || cempres
         || ' psprodom:'
         || psprodom
         || ' filtradomaximo: FALSE pccobban:'
         || pccobban
         || ' pcbanco:'
         || pcbanco
         || ' pctipcta:'
         || pctipcta
         || ' pfvtotar:'
         || pfvtotar
         || ' pcreferen:'
         || pcreferen
         || ' pdfefecto:'
         || pdfefecto;

      -- 36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin

      -- BUG 0021480 - 27/02/2012 - JMF: Afegir camps
      IF v_cidioma IS NULL
      THEN
         SELECT MAX (nvalpar)
           INTO v_cidioma
           FROM parinstalacion
          WHERE cparame = 'IDIOMARTF';
      END IF;

      IF psprodom IS NOT NULL
      THEN
         v_where :=
               ' and pr.sproduc in (SELECT sproduc
           FROM tmp_domisaux
          WHERE sproces = '
            || psprodom
            || '
            AND cestado = 1)  ';
         wsproduc := NULL;
      END IF;

      IF NVL (pac_parametros.f_parempresa_n (cempres, 'MONEDA_POL'), 0) = 1
      THEN
         vtabla := 'vdetrecibos_monpol';
      ELSE
         vtabla := 'vdetrecibos';
      END IF;

      -- Sucursal;Empresa;Ram;Producte;Activitat;Cobrador;Compte recaptador;Rebut;Pòlissa;Tipus;Prenedor;
      -- Número document identificador prenedor;Efecte;Data venciment;Tipus de compte;Codi de banc;
      -- Compte bancari;Fitxer;Data tall procés;Import;Estat rebut;Entitat recaptadora;Codi Banc recaptador;
      -- Data venciment targeta;Assegurat;Número document identificador assegurat;Pagador;
      -- Número document identificador pagador;Codi de matrícula o prenotificació;Subestat rebut;
      -- Tipus document identificador prenedor;Número document identificador assegurat;
      -- Número document identificador pagador;
      v_result :=
            'SELECT '
         -- 40. MMM 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
         --|| '(select ff_desagente(cagente) from    recibosredcom where nrecibo=r.nrecibo and cempres=r.cempres and ctipage = 2) SUCURSAL, '
         || 'ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, NVL(r.cagente, s.cagente), NULL, NULL)) SUCURSAL, '
         -- 40. MMM 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320 -- FIN
         || 'pac_isqlfor.f_empresa(s.sseguro) EMPRESA, '
         || 'ff_desramo(s.cramo, '
         || v_cidioma
         || ') RAMO, '
         || 'f_desproducto_t(s.cramo,s.cmodali,s.ctipseg,s.ccolect,1,'
         || v_cidioma
         || ') PRODUCTO,'
         || 's.cactivi ACTIVIDAD, '
         || 'c.ccobban || ''-'' || c.descripcion COBRADOR, '
         || '''<''||substr(c.ncuenta,5,length(c.ncuenta)-4)||''>'' CUENTA_RECAUDADORA,'
         || 'r.nrecibo RECIBO, '
         || 's.npoliza || ''-'' || s.ncertif NPOLIZA,'
         || 'ff_desvalorfijo(8,'
         || v_cidioma
         || ',r.ctiprec) TIPO_RECIBO, '
         || 'f_nombre(tom.sperson,1,s.cagente) TOMADOR,'
         || '(select pe.nnumide from per_personas pe where sperson = tom.sperson) IDENTIFICA_TOMADOR,'
         || 'r.fefecto FEFECTO, '
         || 'r.fvencim FVENCIM, '
         || '(select ff_desvalorfijo(800049,'
         || v_cidioma
         || ',ctipcc) FROM tipos_cuenta where ctipban = r.ctipban) TIPO_DE_CUENTA, '
         || 'substr(r.cbancar,1,4) || ''-'' || pac_domiciliaciones.ff_nombre_entidad(r.cbancar, r.ctipban)  ENTIDAD_BANCARIA_RECIBO, '
         || '''<''||substr(r.cbancar,5,length(r.cbancar)-4)||''>'' CUENTA_RECIBO, '
         || 'NULL FICHERO, '
         || 'to_date( '''
         || fefecto
         || ''',''ddmmyyyy'') FECHA_CORTE, '
         || 'DR.itotalr  + (select nvl(sum(v2.itotalr), 0) from adm_recunif ar, '
         || vtabla
         || ' v2 where ar.nrecunif = r.nrecibo and ar.nrecibo = v2.nrecibo and ar.nrecunif <> ar.nrecibo and '
         || ' pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) = 4 AND ar.sdomunif IS NOT NULL) ITOTALR, '
         || 'ff_desvalorfijo(383,'
         || v_cidioma
         || ', f_cestrec_mv(r.nrecibo, '
         || v_cidioma
         || ', NULL)) ESTADO_RECIBO, '
         -- campos nuevos
         || 'pac_domiciliaciones.ff_nombre_entidad(c.ncuenta, c.ctipban) entidad_recaudadora, '
         || 'SUBSTR(c.ncuenta, 1, 4) banco_recaudador, '
         || 'pc.fvencim vto_tarjeta,'
         || 'f_nombre(ase.sperson, 1, s.cagente) asegurado,'
         || '(SELECT pe.nnumide FROM per_personas pe WHERE sperson = ase.sperson) identifica_asegurado,'
         || 'f_nombre(x.sperson, 1, s.cagente) pagador,'
         || '(SELECT pe.nnumide FROM per_personas pe WHERE sperson = x.sperson) identifica_pagador,'
         -- BUG 0020278 - 05/10/2012 - JLTS - Se revisa que si es VISA (4) no se muestre la matricula
         -- BUG 0020277 - 24/10/2012 - ECP - LSe revisa que si es MASTERCARD (7) no se muestre la matricula
         || '(CASE WHEN ( select ctipcc FROM tipos_cuenta WHERE ctipban = r.ctipban) in (4,7) THEN NULL ELSE '
         -- 41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390 - Inicio
         -- 40. MMM 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320
         --|| '''<'' || LPAD(SUBSTR((SELECT cagente FROM recibosredcom WHERE nrecibo=r.nrecibo and cempres=r.cempres AND ctipage = 2), -3), 6, ''0'')'
         --|| '''<'' || LPAD(SUBSTR(ff_desagente(pac_redcomercial.f_busca_padre(s.cempres, NVL(r.cagente, s.cagente), NULL, NULL)), -3), 6, ''0'')'
         -- 40. MMM 0027568 Error en campo Sucursal de listado previo y domiciliación ACH (86) Vida - QT8320 -- FIN
         --|| '|| LPAD(s.sproduc, 6, ''0'')'
         --|| '|| LPAD(x.sperson, 8, ''0'') || LPAD(SUBSTR(x.CNORDBAN, 1, 2), 2, ''0'') || LPAD(s.npoliza, 8, ''0'') ||''>'' END) matricula,'
         || '''<''||PAC_DOMIS.f_get_notificaciones_idnotif2(s.sseguro, r.cbancar, r.ctipban)||''>'' END) matricula,'
         -- 41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390 - Fin
         || 'ff_desvalorfijo(75,'
         || v_cidioma
         || ', r.cestimp) subestado_recibo '
         --|| '(select ff_desvalorfijo(672,' || v_cidioma
         --|| ',pe.ctipide) from per_personas pe where sperson = tom.sperson) Tipoident_TOMADOR,'
         --|| '(SELECT ff_desvalorfijo(672,' || v_cidioma
         --|| ',pe.ctipide) FROM per_personas pe WHERE sperson = ase.sperson) Tipoident_asegurado,'
         --|| '(SELECT ff_desvalorfijo(672,' || v_cidioma
         --|| ',pe.ctipide)
         --|| ' FROM per_personas pe WHERE sperson = x.sperson) Tipoident_pagador '
         || ' FROM productos pr, seguros s, cobbancario c, recibos r, movrecibo m, empresas e, '
         || vtabla
         || ' DR '
         || ' ,('
         || '   select a.sseguro, b.sperson, b.CBANCAR, b.ctipban, max(b.CNORDBAN) CNORDBAN from tomadores a, per_ccc b'
         || '   where  b.sperson=a.sperson group by a.sseguro, b.sperson, b.CBANCAR, b.ctipban'
         || '   union'
         || '   select a.sseguro, b.sperson, b.CBANCAR, b.ctipban, max(b.CNORDBAN) CNORDBAN from asegurados a, per_ccc b'
         || '   where  b.sperson=a.sperson group by a.sseguro, b.sperson, b.CBANCAR, b.ctipban'
         -- 44. 0028931: LCOL_MILL-0009968: Error en informacion archivo previo de cobro VISA - 158635 - Inicio
         || '   union'
         || '   select a.sseguro, b.sperson, b.CBANCAR, b.ctipban, max(b.CNORDBAN) CNORDBAN from recibos a, per_ccc b'
         || '   where  b.sperson=a.sperson group by a.sseguro, b.sperson, b.CBANCAR, b.ctipban'
         -- 44. 0028931: LCOL_MILL-0009968: Error en informacion archivo previo de cobro VISA - Final
         || '  ) x'
         || '  , per_ccc pc'
         || '  ,tomadores tom, asegurados ase'
         || ' WHERE 1=1'
         || ' and tom.sseguro=s.sseguro and tom.nordtom=1'
         || ' and ase.sseguro=s.sseguro and ase.norden=1'
         || ' and x.sseguro=r.sseguro and x.cbancar=r.cbancar and x.ctipban=r.ctipban'
         || ' and pc.sperson=x.sperson and pc.CNORDBAN=x.CNORDBAN'
         || ' AND r.cempres = NVL( '
         || NVL (TO_CHAR (cempres), 'NULL')
         || ' , r.cempres)'
         || ' AND r.cempres = e.cempres'
         || ' AND r.fefecto  <= to_date( '''
         || fefecto
         || ''',''ddmmyyyy'') AND '
         || ' r.fefecto  >= nvl(to_date( '''
         || pdfefecto
         || ''',''ddmmyyyy''),r.fefecto) AND '
         -- 43. 0028200: Error en la domiciliación de recibos de retorno - QT-9324 y QT-9326 - Inicio
         -- || '(r.cestimp = 4 OR (r.cestimp = 11 AND TRUNC(FESTIMP)<= trunc(f_sysdate))) AND r.ctiprec <> 9 AND r.ccobban = c.ccobban AND '
         || '(r.cestimp = 4 OR (r.cestimp = 11 AND TRUNC(FESTIMP)<= trunc(f_sysdate))) AND r.ctiprec NOT IN (9, 13, 15) AND r.ccobban = c.ccobban AND '
         -- 43. 0028200: Error en la domiciliación de recibos de retorno - QT-9324 y QT-9326 - Final
         || 'r.sseguro = s.sseguro AND r.nrecibo = m.nrecibo AND m.cestrec = 0 AND  m.fmovfin is null AND  r.cestaux = 0 AND '
         || 'nvl(r.cgescob,1) = 1 AND Dr.nrecibo = R.nrecibo AND '
         || '((pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (1,3) and r.nrecibo not in (select nrecibo from adm_recunif)) '
         || '  or '
         || '(pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) IN (2, 4) and 0=(select count(0) from adm_recunif a where a.nrecibo = r.nrecibo and a.nrecunif<> r.nrecibo)) '
         || '  or '
         || ' (pac_domis.f_agrupa_rec_tipo(r.ccobban, r.cempres, s.sproduc) NOT IN (1, 2, 3, 4)) ) AND '
         || 'pr.sproduc(+) = s.sproduc AND s.sproduc = NVL('
         || NVL (TO_CHAR (wsproduc), 'NULL')
         || ', s.sproduc) AND S.cramo = nvl( '
         || NVL (TO_CHAR (cramo), 'NULL')
         || ' , NVL(pr.cramo, S.cramo)) AND '
         || 'S.cmodali = NVL(pr.cmodali, S.cmodali) AND S.ctipseg = NVL(pr.ctipseg, S.ctipseg) AND '
         || 'S.ccolect = NVL(pr.ccolect, S.ccolect) '
         || ' and c.cempres = r.cempres '
         || 'AND('
         || NVL (TO_CHAR (pccobban), 'NULL')
         || ' IS NULL OR '
         || NVL (TO_CHAR (pccobban), 'NULL')
         || ' = r.ccobban) AND c.cdoment = NVL('
         || NVL (TO_CHAR (pcbanco), 'NULL')
         || ', c.cdoment) AND('
         || NVL (TO_CHAR (pctipcta), 'NULL')
         || ' IS NULL OR '
         || NVL (TO_CHAR (pctipcta), 'NULL')
         || ' = r.ctipban) AND('
         || NVL (pfvtotar, 'NULL')
         || ' IS NULL OR '
         || NVL (pfvtotar, 'NULL')
         || ' = SUBSTR(r.cbancar, 21, 4)) AND('
         || NVL (pcreferen, 'NULL')
         || ' IS NULL '
         || 'OR '
         || NVL (pcreferen, 'NULL')
         || ' = (SELECT rebut_ini FROM cnvrecibos '
         || 'WHERE nrecibo = r.nrecibo)) ';
      v_result := v_result || v_where;

      IF filtradomaximo = TRUE
      THEN
         v_max_reg := f_parinstalacion_n ('N_MAX_REG');

         IF v_max_reg IS NOT NULL
         THEN
            v_result := v_result || ' and rownum <= ' || v_max_reg;
         END IF;
      END IF;

      --AGG modificaciones SEPA
      IF NVL (pac_parametros.f_parempresa_n (cempres, 'DOMIS_IBAN_XML'), 0) =
                                                                             1
      THEN
         -- v_result := v_result || ' AND C.CTIPBAN = 2';   --Comprobamos que la cuenta sea de tipo IBAN
         -- v_result := v_result || ' AND M.CESTADO = 1';   --Comprobamos que el estado del mandato sea activado
          --Comprobamos que el banco del deudor tiene informado el código BIC
         v_result :=
               v_result
            || ' AND EXISTS ( '
            || ' select 1'
            || ' from tipos_cuenta t, bancos b, recibos r '
            || ' where b.cbic is not null'
            || ' and t.ctipban = r.ctipban '
            || ' and b.cbanco = SUBSTR(r.cbancar, NVL(t.pos_entidad, 1), '
            || ' NVL(t.long_entidad, 4)) )';
         --Comprobamos que el mandato esté activo
         v_result :=
               v_result
            || ' AND pac_sepa.f_mandato_activo(s.sseguro, r.nrecibo) = 1 ';
      END IF;

      -- Bug 0029371 - dlF - 05-VIII-2014 - POSAN100-POSADM Domicliación - Inconsistencia Proceso de Prenotificación --
      -- Número máximo de recibos 'REMESADOS' por póliza
      IF NVL (pac_parametros.f_parempresa_n (cempres, 'NUMMAX_REC_DOM_X_POL'),
              0
             ) >= 1
      THEN
         v_result :=
               v_result
            || ' AND NVL(pac_parametros.f_parempresa_n(cempres, ''NUMMAX_REC_DOM_X_POL''), 0) > ( '
            || ' select count(1)'
            || ' from recibos x, movrecibo y '
            || ' where x.sseguro = s.sseguro '
            || '   and y.fmovfin is null '
            || '   and y.cestrec = 3'
            || ')';
      END IF;

      -- fin Bug 0029371 - dlF - 5-VIII-2014 --------------------------------------------------------------------------

      --AGG fin modificaciones SEPA
      v_result := v_result || ' order by r.cempres, s.npoliza, r.nrecibo';
      -- 37.0 - 0027103: No es posible generar el previo de domiciliación para el cobrador Visa (42)Life - QT-4872 - Inicio
        -- p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.f_retorna_query2', 2, vparam, v_result);   -- 36. 0026169 - 0138818
      p_tab_error (f_sysdate,
                   f_user,
                   'PAC_DOMIS.f_retorna_query2',
                   1,
                   vparam,
                   SUBSTR (v_result, 1, 2500)
                  );

      IF LENGTH (v_result) > 2500
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMIS.f_retorna_query2',
                      2,
                      vparam,
                      SUBSTR (v_result, 2501, 5000)
                     );

         IF LENGTH (v_result) > 5000
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'PAC_DOMIS.f_retorna_query2',
                         3,
                         vparam,
                         SUBSTR (v_result, 5001, 6000)
                        );
         END IF;
      END IF;

      -- 37.0 - 0027103: No es posible generar el previo de domiciliación para el cobrador Visa (42)Life - QT-4872 - Final
      RETURN v_result;
   END f_retorna_query2;

   -- fin BUG 21318 : MDS : 13/02/2012

   -- 33. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Inicio
   -- Retorna el código de agente si el recibo pertenece al un agente con acuerdo de colaboración
   -- de no ser así retorna un nulo
   FUNCTION f_age_ctipmed05 (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vcagente   NUMBER;
   BEGIN
      SELECT x.cagente
        INTO vcagente
        FROM recibosredcom x, agentes a
       WHERE a.cagente = x.cagente
         AND a.ctipage = 5
         AND a.ctipmed = 5
         AND x.nrecibo = pnrecibo;

      RETURN vcagente;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_age_ctipmed05;

   FUNCTION f_creafitxer_acuerdo (
      psproces           IN   NUMBER,
      ptsufpresentador   IN   VARCHAR2,
      pcempres           IN   NUMBER,
      pcdoment           IN   NUMBER,
      pcdomsuc           IN   NUMBER,
      ptfitxer           IN   VARCHAR2,
      pcidioma           IN   NUMBER,
      pctipemp           IN   NUMBER,
      ppath              IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      xncuenta              cobbancario.ncuenta%TYPE;
      xtsufijo              cobbancario.tsufijo%TYPE;
      xcempres              cobbancario.cempres%TYPE;
      xcdoment              cobbancario.cdoment%TYPE;
      xcdomsuc              cobbancario.cdomsuc%TYPE;
      xnifcob               cobbancario.nnumnif%TYPE;
      xnnumnif              cobbancario.nnumnif%TYPE;
      xccobban              cobbancario.ccobban%TYPE;
      xnrecibo              domiciliaciones.nrecibo%TYPE;
      xcramo                domiciliaciones.cramo%TYPE;
      xfefecto              DATE;
      xtnumnif              VARCHAR2 (20);
      xtsufijof             cobbancario.tsufijo%TYPE;
      xtcobban              VARCHAR2 (40);
      xtempres              VARCHAR2 (40);
      vegada                NUMBER                         := 1;
      error                 NUMBER;
      xsseguro              seguros.sseguro%TYPE;
      xsperson              NUMBER;
      xcdomici              NUMBER;
      xcidioma              NUMBER;
      xtnombre              VARCHAR2 (100);
      xitotalr              vdetrecibos.itotalr%TYPE;
      xcbancar              seguros.cbancar%TYPE;
      xnpoliza              seguros.npoliza%TYPE;
      xncertif              seguros.ncertif%TYPE;
      fitxer                UTL_FILE.file_type;
      tot_imp_remesa        NUMBER                         := 0;
      tot_num_rebuts        NUMBER                         := 0;
      tot_registres_ord     NUMBER                         := 0;
      tot_remeses_pres      NUMBER                         := 0;
      tot_imp_presentador   NUMBER                         := 0;
      tot_num_rebuts_pres   NUMBER                         := 0;
      tot_registres_pres    NUMBER                         := 0;
      linia                 VARCHAR2 (162);
      poliscert             VARCHAR2 (12);
      espais2               VARCHAR (2)                 := LPAD (' ', 2, ' ');
      espais6               VARCHAR (6)                 := LPAD (' ', 6, ' ');
      espais8               VARCHAR (8)                 := LPAD (' ', 8, ' ');
      espais14              VARCHAR (14)               := LPAD (' ', 14, ' ');
      espais16              VARCHAR (16)               := LPAD (' ', 16, ' ');
      espais20              VARCHAR (20)               := LPAD (' ', 20, ' ');
      espais38              VARCHAR (38)               := LPAD (' ', 38, ' ');
      espais52              VARCHAR (52)               := LPAD (' ', 52, ' ');
      espais66              VARCHAR (66)               := LPAD (' ', 66, ' ');
      espais72              VARCHAR (72)               := LPAD (' ', 72, ' ');
      espais64              VARCHAR (64)               := LPAD (' ', 64, ' ');
      espais80              VARCHAR (80)               := LPAD (' ', 80, ' ');
      lin1                  VARCHAR2 (80);
      lin2                  VARCHAR2 (80);
      lin3                  VARCHAR2 (80);
      lin4                  VARCHAR2 (80);
      lin5                  VARCHAR2 (80);
      lin6                  VARCHAR2 (80);
      lin7                  VARCHAR2 (80);
      lin8                  VARCHAR2 (80);
      p0180                 VARCHAR2 (4)                   := '0180';
      p0380                 VARCHAR2 (4)                   := '0380';
      p0680                 VARCHAR2 (4)                   := '0680';
      p0681                 VARCHAR2 (4)                   := '0681';
      p0682                 VARCHAR2 (4)                   := '0682';
      p0683                 VARCHAR2 (4)                   := '0683';
      p0684                 VARCHAR2 (4)                   := '0684';
      p0685                 VARCHAR2 (4)                   := '0685';
      p0880                 VARCHAR2 (4)                   := '0880';
      p0980                 VARCHAR2 (4)                   := '0980';
      pcdivisa              productos.cdivisa%TYPE;
      xxitotalr             VARCHAR2 (20);
      xcsb54                parinstalacion.nvalpar%TYPE;
      xtnifpresentador      VARCHAR2 (12)                  := '';
      v_ntraza              NUMBER                         := 0;
      v_vobject             VARCHAR2 (500)        := 'pac_domis.f_creafitxer';
      xctipmed05            agentes.cagente%TYPE;

      CURSOR cur_remesa
      IS
         SELECT   ccobban, GREATEST (fefecrec, fefecto) fefecto, cdoment,
                  cdomsuc,
                          -- cramo, -- 34. 0023645 - 0132667 (-)
                          f_age_ctipmed05 (nrecibo) ctipmed05
             -- 34. 0023645 - 0132667 (+)
         FROM     domiciliaciones
            WHERE sproces = psproces
              --AND tsufijo = ptsufijo
              AND cempres = pcempres
              AND cdoment = pcdoment
              AND cdomsuc = pcdomsuc
              AND cerror = 0
         GROUP BY ccobban,
                  GREATEST (fefecrec, fefecto),
                  cdoment,
                  cdomsuc,
                  -- cramo, -- 34. 0023645 - 0132667 (-)
                  f_age_ctipmed05 (nrecibo)
         -- ORDER BY cramo, fefecto;  -- 34. 0023645 - 0132667 (-)
         ORDER BY f_age_ctipmed05 (nrecibo), fefecto;

      -- 34. 0023645 - 0132667 (+)
      CURSOR cur_domiciliac
      IS
         SELECT   nrecibo, LPAD (tsufijo, 3, '0') tsufijo, fefecto, cempres,
                  cdoment, cdomsuc
             FROM domiciliaciones d
            WHERE sproces = psproces
              AND ccobban = xccobban
              AND GREATEST (fefecto, fefecrec) = xfefecto
              AND cerror = 0
              -- 34. 0023645 - 0132667 - Inicio
              -- AND cramo = xcramo
              AND (   (    xctipmed05 IS NOT NULL
                       AND pac_domis.f_age_ctipmed05 (nrecibo) = xctipmed05
                      )
                   OR (    xctipmed05 IS NULL
                       AND pac_domis.f_age_ctipmed05 (nrecibo) IS NULL
                      )
                  )
         -- 34. 0023645 - 0132667 - Fin
         ORDER BY fefecto;

      pinstalacion          VARCHAR2 (100);
      cuenta                NUMBER;
      lccompani             NUMBER;
      xcsubpro              NUMBER;
      vsproduc              NUMBER;
   BEGIN
      --BUSCAMOS LA INSTALACION
      BEGIN
         SELECT UPPER (tvalpar)
           INTO pinstalacion
           FROM parinstalacion
          WHERE UPPER (cparame) = 'GRUPO';
      EXCEPTION
         WHEN OTHERS
         THEN
            pinstalacion := '';
      END;

      --BUSCAMOS SI CSB19 (1) o CSB54 (2)
      BEGIN
         SELECT nvalpar
           INTO xcsb54
           FROM parinstalacion
          WHERE UPPER (cparame) = 'DOMICI';
      EXCEPTION
         WHEN OTHERS
         THEN
            xcsb54 := 1;
      END;

      v_ntraza := 1;
      error := 0;

      IF error = 0
      THEN
         xcempres := pcempres;
         error := f_nifempresa (xcempres, xtnifpresentador);
         v_ntraza := 2;

         IF error = 0
         THEN
            NULL;

            IF error = 0
            THEN
               fitxer := UTL_FILE.fopen (ppath, ptfitxer, 'w');
               v_ntraza := 3;

               OPEN cur_remesa;

               FETCH cur_remesa
                INTO xccobban, xfefecto, xcdoment, xcdomsuc,
                                                            -- xcramo -- 34. 0023645 - 0132667 (-)
                                                            xctipmed05;

               WHILE cur_remesa%FOUND
               LOOP
                  error :=
                     f_cobrador (xccobban,
                                 xnnumnif,
                                 xtsufijo,
                                 xcdoment,
                                 xcempres,
                                 xcdomsuc,
                                 xncuenta,
                                 xnifcob
                                );
                  v_ntraza := 4;

                  SELECT tcobban
                    INTO xtcobban
                    FROM cobbancario
                   WHERE ccobban = xccobban;

                  IF error = 0
                  THEN
                     error := f_nifempresa (xcempres, xtnumnif);
                  ELSE
                     UTL_FILE.fclose (fitxer);
                     RETURN error;
                  END IF;

                  v_ntraza := 5;

                  IF xnifcob IS NOT NULL
                  THEN
                     xtnumnif := xnifcob;
                  END IF;

                  error := f_desempresa (xcempres, NULL, xtempres);

                  IF error <> 0
                  THEN
                     UTL_FILE.fclose (fitxer);
                     RETURN error;
                  END IF;

                  xtnumnif := NVL (xtnumnif, '0');
                  xtsufijo := NVL (xtsufijo, '0');
                  xtempres := NVL (xtempres, '0');
                  xcdoment := NVL (xcdoment, '0');
                  xcdomsuc := NVL (xcdomsuc, '0');
                  xncuenta := NVL (xncuenta, '0');

                  --En caso de la correduria el presentador y el ordenante
                  --son la compa¿¿(CASER, WINTERTHUR, SGA, ...)
                  IF NVL (pctipemp, 0) = 1
                  THEN                                 --estamos en correduria
                     --Contaremos las diferentes cias. del cobrador bancario
                     --Si tiene mas de una haremos el fichero como si fuera cia. y no como correduria
                     cuenta := 0;
                     v_ntraza := 6;

                     BEGIN
--                        p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 2, xccobban,
--                                    xccobban);   -- Bug:14574 - 25/05/2010 - JMC
                        SELECT DISTINCT ccompani
                                   INTO lccompani
                                   FROM productos
                                  WHERE (cramo, cmodali, ctipseg, ccolect) IN (
                                           SELECT cramo, cmodali, ctipseg,
                                                  ccolect
                                             FROM cobbancariosel
                                            WHERE ccobban = xccobban);

--                        p_tab_error(f_sysdate, f_user, 'PAC_DOMIS.CREAFITXER', 3, lccompani,
--                                    lccompani);  -- Bug:14574 - 25/05/2010 - JMC

                        -- Si va be la query ¿que nom¿hi ha una
                        SELECT tapelli, nnumnif
                          INTO xtempres, xtnumnif
                          FROM personas
                         WHERE sperson = (SELECT sperson
                                            FROM companias
                                           WHERE ccompani = lccompani);
                     EXCEPTION
                        WHEN TOO_MANY_ROWS
                        THEN
                           p_tab_error (f_sysdate,
                                        f_user,
                                        'PAC_DOMIS.CREAFITXER',
                                        4,
                                        '*',
                                        '*'
                                       );
                           NULL;
                     END;
                  END IF;

                  v_ntraza := 7;

                  IF vegada = 1
                  THEN
                     v_ntraza := 8;
                     xtsufijof := xtsufijo;

                     --Buscar la moneda del producto
                     --Un mismo cobrador bancario no tendr¿¿de una moneda
                     --Buscamos el sproduc
                     BEGIN
                        SELECT NVL (cdivisa, 2)
                          INTO pcdivisa
                          FROM productos
                         WHERE (cramo, cmodali, ctipseg, ccolect) IN (
                                  SELECT cramo, cmodali, ctipseg, ccolect
                                    FROM seguros
                                   WHERE sseguro IN (
                                            SELECT sseguro
                                              FROM recibos
                                             WHERE nrecibo IN (
                                                      SELECT MIN (nrecibo)
                                                        FROM domiciliaciones
                                                       WHERE sproces =
                                                                      psproces
                                                         AND ccobban =
                                                                      xccobban)));
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           pcdivisa := f_parinstalacion_n ('MONEDAINST');
                     END;

                     v_ntraza := 9;

                     IF pcdivisa != 2 AND xcsb54 = 2
                     THEN                                      --Euros + CSB54
                        v_ntraza := 10;
                        p0180 := '5170';
                        p0380 := '5370';
                        p0680 := '5670';
                        p0681 := '5671';
                        p0682 := '5672';
                        p0683 := '5673';
                        p0684 := '5674';
                        p0685 := '5675';
                        p0880 := '5870';
                        p0980 := '5970';
                     ELSIF pcdivisa = 2 AND xcsb54 = 1
                     THEN                                        --Pts + CSB19
                        v_ntraza := 11;
                        p0180 := '0180';
                        p0380 := '0380';
                        p0680 := '0680';
                        p0681 := '0681';
                        p0682 := '0682';
                        p0683 := '0683';
                        p0684 := '0684';
                        p0685 := '0685';
                        p0880 := '0880';
                        p0980 := '0980';
                     ELSIF pcdivisa != 2 AND xcsb54 = 1
                     THEN                                        --EUR + CSB19
                        v_ntraza := 12;
                        p0180 := '5180';
                        p0380 := '5380';
                        p0680 := '5680';
                        p0681 := '5681';
                        p0682 := '5682';
                        p0683 := '5683';
                        p0684 := '5684';
                        p0685 := '5685';
                        p0880 := '5880';
                        p0980 := '5980';
                     ELSIF pcdivisa = 2 AND xcsb54 = 2
                     THEN                                        --Pts + CSB54
                        v_ntraza := 13;
                        p0180 := '0170';
                        p0380 := '0370';
                        p0680 := '0670';
                        p0681 := '0671';
                        p0682 := '0672';
                        p0683 := '0673';
                        p0684 := '0674';
                        p0685 := '0675';
                        p0880 := '0870';
                        p0980 := '0970';
                     END IF;

                     v_ntraza := 14;
                     -- Grabem el registre del presentador (nom¿la primera vegada)
                     linia :=
                           p0180
                        || LPAD (xtnifpresentador, 9, '0')
                        || LPAD (ptsufpresentador, 3, '0')
                        -- || LPAD (xtsufijo, 3, '0')
                        || TO_CHAR (f_sysdate, 'ddmmyy')
                        || espais6
                        || RPAD (xtempres, 40, ' ')
                        || espais20
                        || LPAD (xcdoment, 4, '0')
                        || LPAD (xcdomsuc, 4, '0')
                        || SUBSTR (espais66, 1, 65)
                        || 'D';
                     UTL_FILE.put_line (fitxer, linia);
                     vegada := 2;
                  END IF;

                  v_ntraza := 15;

                  -- Grabem el registre de l' ordenant
                  -- xtsufijo:= LPAD(xcramo,3,'0');
                  IF xcsb54 = 1
                  THEN                                                 --CSB19
                     linia :=
                           p0380
                        || LPAD (xtnumnif, 9, '0')
                        || LPAD (xtsufijo, 3, '0')
                        || TO_CHAR (f_sysdate, 'ddmmyy')
                        || TO_CHAR (xfefecto, 'ddmmyy')
                        || RPAD (xtcobban, 40, ' ')
                        || LPAD (xncuenta, 20, '0')
                        || espais8
                        || '01'
                        || espais64;
                  ELSE
                     linia :=
                           p0380
                        || LPAD (xtnumnif, 9, '0')
                        || LPAD (xtsufijo, 3, '0')
                        || TO_CHAR (f_sysdate, 'ddmmyy')
                        || TO_CHAR (xfefecto, 'ddmmyy')
                        || RPAD (xtempres, 40, ' ')
                        || LPAD (xncuenta, 20, '0')
                        || espais8
                        || '06'
                        || espais64;
                  END IF;

                  v_ntraza := 16;
                  UTL_FILE.put_line (fitxer, linia);
                  tot_imp_remesa := 0;
                  tot_num_rebuts := 0;

                  OPEN cur_domiciliac;

                  FETCH cur_domiciliac
                   INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment,
                        xcdomsuc;

                  v_ntraza := 17;

                  WHILE cur_domiciliac%FOUND
                  LOOP
                     BEGIN
                        SELECT s.sseguro, s.npoliza, s.ncertif, r.cbancar,
                               p.csubpro
                          INTO xsseguro, xnpoliza, xncertif, xcbancar,
                               xcsubpro
                          FROM recibos r, seguros s, productos p
                         WHERE r.nrecibo = xnrecibo
                           AND r.sseguro = s.sseguro
                           AND s.sproduc = p.sproduc;
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           RETURN 101947;            -- Inconsist¿ia de la BD
                        WHEN OTHERS
                        THEN
                           RETURN 101916;                   -- Error en la BD
                     END;

                     v_ntraza := 18;
                     xsperson := NULL;
                     xcdomici := NULL;
                     xcidioma := pcidioma;
                     error :=
                        f_nomrecibo (xsseguro,
                                     xtnombre,
                                     xcidioma,
                                     xsperson,
                                     xcdomici
                                    );

                     IF error = 0
                     THEN
                        v_ntraza := 19;
                        error :=
                           pac_propio.f_trecibo (xnrecibo,
                                                 xcidioma,
                                                 lin1,
                                                 lin2,
                                                 lin3,
                                                 lin4,
                                                 lin5,
                                                 lin6,
                                                 lin7,
                                                 lin8
                                                );

                        IF error = 0
                        THEN
                           BEGIN
                              SELECT NVL (itotalr, 0)
                                INTO xitotalr
                                FROM vdetrecibos
                               WHERE nrecibo = xnrecibo;
                           EXCEPTION
                              WHEN NO_DATA_FOUND
                              THEN
                                 RETURN 101947;      -- Inconsist¿ia de la BD
                              WHEN OTHERS
                              THEN
                                 RETURN 101916;             -- Error en la BD
                           END;

                           IF xitotalr < 0
                           THEN
                              RETURN 102276;
                           -- Total del rebut no pot ser negatiu
                           ELSE
                                       -- ARA INSERTAREM 6 REGISTRES EN EL FITXER
                                       -- poliscert := LPAD (xnpoliza, 12, '0');
                                       --poliscert := lpad(xnpoliza, 8, ' ') || lpad(xncertif, 4, ' ');
                                       -- Bug 8745 - 06/03/2009 - RSC - Adaptación iAxis a productos colectivos con certificados
                              -- 'ADMITE_CERTIFICADOS'
                              SELECT sproduc
                                INTO vsproduc
                                FROM seguros
                               WHERE sseguro = xsseguro;

                              IF    xcsubpro = 3
                                 OR NVL
                                       (f_parproductos_v
                                                        (vsproduc,
                                                         'ADMITE_CERTIFICADOS'
                                                        ),
                                        0
                                       ) = 1
                              THEN
                                 --colectivo individualizado o colectivo multiple
                                 poliscert :=
                                       LPAD (   SUBSTR (LPAD (xnpoliza, 8,
                                                              '0'),
                                                        1,
                                                        2
                                                       )
                                             || SUBSTR (LPAD (xnpoliza, 8,
                                                              ' '),
                                                        5,
                                                        8
                                                       ),
                                             6,
                                             '0'
                                            )
                                    || LPAD (xncertif, 6, '0');
                              ELSE
                                 poliscert := LPAD (xnpoliza, 12, '0');
                              END IF;

                              -- Fin Bug 8745
                              xtnombre := NVL (xtnombre, ' ');
                              xcbancar := NVL (xcbancar, '0');
                              xitotalr := NVL (xitotalr, '0');
                              lin1 := NVL (lin1, ' ');
                              lin2 := NVL (lin2, ' ');
                              lin3 := NVL (lin3, ' ');
                              lin4 := NVL (lin4, ' ');
                              lin5 := NVL (lin5, ' ');
                              lin6 := NVL (lin6, ' ');
                              lin7 := NVL (lin7, ' ');
                              lin8 := NVL (lin8, ' ');

                              IF pcdivisa = 3
                              THEN                                     --Euros
                                 SELECT TO_NUMBER
                                           (REPLACE
                                               (REPLACE (TO_CHAR ((  xitotalr
                                                                   * 100
                                                                  )
                                                                 ),
                                                         '.',
                                                         ''
                                                        ),
                                                ',',
                                                ''
                                               )
                                           )
                                   INTO xitotalr
                                   FROM DUAL;
                              END IF;

                              -- Aquest ¿el primer
                              IF xcsb54 = 1
                              THEN                                     --CSB19
                                 linia :=
                                       p0680
                                    || LPAD (xtnumnif, 9, '0')
                                    || LPAD (xtsufijo, 3, '0')
                                    || poliscert
                                    || RPAD (xtnombre, 40, ' ')
                                    || LPAD (xcbancar, 20, '0')
                                    || LPAD (xitotalr, 10, '0')
                                    || LPAD (psproces, 6, '0')
                                    || RPAD (LPAD (xnrecibo, 9, '0'), 10, ' ')
                                    || RPAD (NVL (SUBSTR (lin1, 1, 40), ' '),
                                             40,
                                             ' '
                                            )
                                    || espais8;
                              ELSE
                                 linia :=
                                       p0680
                                    || LPAD (xtnumnif, 9, '0')
                                    || LPAD (xtsufijo, 3, '0')
                                    || poliscert
                                    || RPAD (xtnombre, 40, ' ')
                                    || LPAD (xcbancar, 20, '0')
                                    || LPAD (xitotalr, 10, '0')
                                    || LPAD (psproces, 6, '0')
                                    || RPAD (LPAD (xnrecibo, 9, '0'), 10, ' ')
                                    || RPAD (NVL (SUBSTR (lin1, 1, 40), ' '),
                                             40,
                                             ' '
                                            )
                                    || TO_CHAR (xfefecto, 'ddmmyy')
                                    || espais2;
                              END IF;

                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el segon
                              linia :=
                                    p0681
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin1, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin2, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin2, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el tercer
                              linia :=
                                    p0682
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin3, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin3, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin4, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el quart
                              linia :=
                                    p0683
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin4, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin5, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin5, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el cinqu¿
                              linia :=
                                    p0684
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin6, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin6, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin7, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              -- Aquest ¿el sis¿
                              linia :=
                                    p0685
                                 || LPAD (xtnumnif, 9, '0')
                                 || LPAD (xtsufijo, 3, '0')
                                 || poliscert
                                 || RPAD (NVL (SUBSTR (lin7, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin8, 1, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || RPAD (NVL (SUBSTR (lin8, 41, 40), ' '),
                                          40,
                                          ' '
                                         )
                                 || espais14;
                              UTL_FILE.put_line (fitxer, linia);
                              tot_imp_remesa :=
                                            tot_imp_remesa + NVL (xitotalr, 0);
                              tot_num_rebuts := tot_num_rebuts + 1;
                           END IF;
                        ELSE
                           RETURN error;
                        END IF;
                     ELSE
                        v_ntraza := 20;
                        RETURN error;
                     END IF;

                     FETCH cur_domiciliac
                      INTO xnrecibo, xtsufijo, xfefecto, xcempres, xcdoment,
                           xcdomsuc;
                  END LOOP;

                  CLOSE cur_domiciliac;

                  v_ntraza := 21;
                  -- insertem un registre de FINAL DE ORDENANT
                  tot_registres_ord := 2 + 6 * tot_num_rebuts;
                  linia :=
                        p0880
                     || LPAD (xtnumnif, 9, '0')
                     || LPAD (xtsufijo, 3, '0')
                     || espais72
                     || LPAD (tot_imp_remesa, 10, '0')
                     || espais6
                     || LPAD (tot_num_rebuts, 10, '0')
                     || LPAD (tot_registres_ord, 10, '0')
                     || espais38;
                  UTL_FILE.put_line (fitxer, linia);
                  tot_remeses_pres := tot_remeses_pres + 1;
                  tot_imp_presentador := tot_imp_presentador + tot_imp_remesa;
                  tot_num_rebuts_pres := tot_num_rebuts_pres + tot_num_rebuts;

                  FETCH cur_remesa
                   INTO xccobban, xfefecto, xcdoment, xcdomsuc,
                                                               -- xcramo -- 34. 0023645 - 0132667 (-)
                                                               xctipmed05;
               -- 34. 0023645 - 0132667 (+)
               END LOOP;

               CLOSE cur_remesa;

               v_ntraza := 22;
               -- Insertem un registre de final del Presentador
               tot_registres_pres :=
                           2
                         + (2 * tot_remeses_pres)
                         + (6 * tot_num_rebuts_pres);
               linia :=
                     p0980
                  || LPAD (xtnifpresentador, 9, '0')
                  || LPAD (ptsufpresentador, 3, '0')               --xtsufijof
                  || espais52
                  || LPAD (tot_remeses_pres, 4, '0')
                  || espais16
                  || LPAD (tot_imp_presentador, 10, '0')
                  || espais6
                  || LPAD (tot_num_rebuts_pres, 10, '0')
                  || LPAD (tot_registres_pres, 10, '0')
                  || espais38;
               UTL_FILE.put_line (fitxer, linia);
               UTL_FILE.fclose (fitxer);
               UTL_FILE.frename (ppath, ptfitxer, ppath,
                                 LTRIM (ptfitxer, '_'));
               RETURN 0;
            ELSE
               RETURN error;
            END IF;
         ELSE
            RETURN error;
         END IF;
      ELSE
         RETURN error;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      v_vobject,
                      v_ntraza,
                      'Error sqlcode=' || SQLCODE,
                      SQLERRM
                     );

         IF UTL_FILE.is_open (fitxer)
         THEN
            UTL_FILE.fclose (fitxer);
         END IF;

         RETURN SQLCODE;
   END f_creafitxer_acuerdo;

-- 33. 0023645: MDP_A001-Correcciones en Domiciliaciones - 0131871 - Fin

   --35. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666
/*******************************************************************************
   FUNCION f_valida_domi_poliza
   Función que valida que si existe una domiciliación en curso para una póliza
   Parámetros:
    Entrada :
      psseguro IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_valida_domi_poliza (psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'psseguro=' || psseguro;
      vobject    VARCHAR2 (200) := 'PAC_DOMIS.F_VALIDA_DOMI_POLIZA';
      num_err    NUMBER;
      salir      EXCEPTION;
      v_cont     NUMBER;
   BEGIN
      vpasexec := 1;

      IF psseguro IS NULL
      THEN
         vpasexec := 2;
         -- 9000505 Error falten parametres
         num_err := 9000505;
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (num_err,
                                        pac_md_common.f_get_cxtidioma)
                     );
         RETURN num_err;
      ELSE
         vpasexec := 3;

         SELECT COUNT (1)
           INTO v_cont
           FROM domiciliaciones_cab dc, domiciliaciones dm, seguros ss
          WHERE dc.cestdom = 1                                   --> 1 Abierta
            AND dm.sproces = dc.sproces
            AND ss.cbancar IS NOT NULL
            AND dm.sseguro = ss.sseguro
            AND ss.sseguro = psseguro;

         vpasexec := 4;

         IF v_cont > 0
         THEN
            vpasexec := 5;
            num_err := 9903191;
            -- Existe una domiciliación en curso para esta póliza
            RAISE salir;
         END IF;
      END IF;

      vpasexec := 7;
      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1000455;                              -- Error no controlado.
   END f_valida_domi_poliza;

--35. 0025032: LCOL_T001-QT 5464: ERROR CAMBIO DE TOMADOR IAXIS POLIZA 666 - Fin

   --36. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Inicio
/*******************************************************************************
   FUNCION f_agrupa_rec_domis
   Nos informa si las domiciliaciones han de realizar agrupación de recibos, por los siguientes parámtros
   1. COBBANCARIO.CAGRUPREC el cobrador bancario requiere agruación
   2. El parámetro 'RECUNIF_DOMIS' está informado.

   El 'RECUNIF_DOMIS' el la versión para domiciliaciones del parametro 'RECUNIF' de producción.

   Parámetros:
    Entrada :
      pccobban IN NUMBER
      pcempres IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_agrupa_rec_domis (
      pccobban   IN   NUMBER,
      pcempres   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec     NUMBER (8)                   := 1;
      vparam       VARCHAR2 (200)               := 'pccobban=' || pccobban;
      vobject      VARCHAR2 (200)           := 'PAC_DOMIS.F_AGRUPA_REC_DOMIS';
      vcagruprec   cobbancario.cagruprec%TYPE;
      vrecunif     parproductos.cvalpar%TYPE;
      vcempres     empresas.cempres%TYPE        := pcempres;
   BEGIN
      vpasexec := 10;

      SELECT NVL (cagruprec, 0)
        INTO vcagruprec
        FROM cobbancario
       WHERE ccobban = pccobban;

      vpasexec := 20;
      vcempres := NVL (vcempres, pac_md_common.f_get_cxtempresa);
      vpasexec := 30;

      IF vcagruprec = 1
      THEN
         vrecunif :=
            NVL (pac_parametros.f_parempresa_n (vcempres, 'RECUNIF_DOMIS'),
                 0);
      ELSE
         vrecunif := 0;
      END IF;

      vpasexec := 40;
      RETURN vrecunif;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- 103941 Error al leer la tabla COBBANCARIO
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (103941, pac_md_common.f_get_cxtidioma)
                     );
         RETURN 0;
   END f_agrupa_rec_domis;

/*******************************************************************************
   FUNCION f_agrupa_rec_tipo
   Nos informa del tipo de agrupación que deberemos aplicar a los recibos
   Tiene prioridad el de domiciliaciones, después el de producción

   Devuelve
      4 - Agrupación de domiciliaciones
      1,2 o 3 - Tipos agrupación de Prod ('RECUNIF')

   Parámetros:
    Entrada :
      pccobban IN NUMBER
      pcempres IN NUMBER
   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_agrupa_rec_tipo (
      pccobban   IN   NUMBER,
      pcempres   IN   NUMBER DEFAULT NULL,
      psproduc   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)                  := 1;
      vparam     VARCHAR2 (200)
         :=    'psproduc='
            || psproduc
            || ' pccobban='
            || pccobban
            || ' pcempres='
            || pcempres;
      vobject    VARCHAR2 (200)              := 'PAC_DOMIS.F_AGRUPA_REC_TIPO';
      vrecunif   parproductos.cvalpar%TYPE;
      vcempres   empresas.cempres%TYPE       := pcempres;
   BEGIN
      vpasexec := 10;

      IF pac_domis.f_agrupa_rec_domis (pccobban, pcempres) != 0
      THEN
         vpasexec := 20;
         vrecunif := 4;
      ELSIF psproduc IS NOT NULL
      THEN
         vpasexec := 30;
         vrecunif := NVL (f_parproductos_v (psproduc, 'RECUNIF'), 0);
      ELSE
         vpasexec := 40;
         vrecunif := 0;
      END IF;

      vpasexec := 50;
      RETURN vrecunif;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- 103941 Error al leer la tabla COBBANCARIO
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (103941, pac_md_common.f_get_cxtidioma)
                     );
         RETURN 0;
   END f_agrupa_rec_tipo;

/*******************************************************************************
   FUNCION f_desagrupa_rec
         -- Desunificar recibos (solo si es de domiciliaciones [sdomunif is not null]):
         -- 1. Guardamos al agrupación de recibos en el histórico
         -- 2. La eliminamos

   Parámetros:
    Entrada :
      pnrecibo IN NUMBER

   Retorna: un NUMBER con el id del error.
********************************************************************************/
   FUNCTION f_desagrupa_rec (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)                  := 1;
      vparam     VARCHAR2 (200)              := 'pnrecibo=' || pnrecibo;
      vobject    VARCHAR2 (200)              := 'PAC_DOMIS.F_DESAGRUPA_REC';
      verror     NUMBER;
      n_sec      adm_recunif_his.nsec%TYPE;
   BEGIN
      vpasexec := 190;

      SELECT NVL (MAX (nsec), 0) + 1
        INTO n_sec
        FROM adm_recunif_his;

      vpasexec := 200;

      INSERT INTO adm_recunif_his
                  (nrecibo, nrecunif, cuser, fhis, cobj, nsec, sdomunif)
         SELECT nrecibo, nrecunif, f_user, f_sysdate, vobject, n_sec,
                sdomunif
           FROM adm_recunif
          WHERE nrecunif = pnrecibo AND sdomunif IS NOT NULL;

      vpasexec := 210;

      BEGIN
         DELETE      adm_recunif a
               WHERE nrecunif = pnrecibo AND sdomunif IS NOT NULL;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- Error al borrar de la tabla ADM_RECUNIF
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            verror := 9904193;
            RETURN verror;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         -- Error al insertar en la tabla ADM_RECUNIF_HIS
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         verror := 9904015;
         RETURN verror;
   END f_desagrupa_rec;

-- 32. 0026169: LCOL_A003-Estructura listados soporte proceso Domiliacion (VISA) Debito automatico. - 0138818 - Fin

   -- 41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390 - Inicio

   /*******************************************************************************
      FUNCION f_get_notificaciones_idnotif2
            -- Descripcion
            -- Devuelve la matricula a partir de un sseguro y ctipban
      Parámetros:
       Entrada :
         pnrecibo psseguro IN seguros.sseguro%TYPE
         pcbancar IN recibos.cbancar%TYPE
         pctipban recibos.ctipban%TYPE

      Retorna: un VARCHAR2 con la matrícula
   ********************************************************************************/
   FUNCTION f_get_notificaciones_idnotif2 (
      psseguro   IN   seguros.sseguro%TYPE,
      pcbancar   IN   recibos.cbancar%TYPE,
      pctipban   IN   recibos.ctipban%TYPE
   )
      RETURN VARCHAR2
   IS
      vpasexec          NUMBER (8)                    := 1;
      vparam            VARCHAR2 (200)
                     := 'psseguro =' || psseguro || ' pctipban =' || pctipban;
      xsseguro          seguros.sseguro%TYPE;
      xctipban          recibos.ctipban%TYPE;
      vcexistepagador   NUMBER;
      vsperson_notif    tomadores.sperson%TYPE;
      vnnumide          per_personas.nnumide%TYPE;
      vctipide          per_personas.ctipide%TYPE;
      vctipcc           tipos_cuenta.ctipcc%TYPE;
      xidnotif          notificaciones.idnotif%TYPE;
      xidnotif2         VARCHAR2 (30);
      xcbancar          recibos.cbancar%TYPE;
      error             NUMBER;
      e_salida          EXCEPTION;
   BEGIN
      xsseguro := psseguro;
      xcbancar := pcbancar;
      xctipban := pctipban;

      BEGIN
         SELECT NVL (t.cexistepagador, 0), sperson
           INTO vcexistepagador, vsperson_notif
           FROM tomadores t
          WHERE t.sseguro = xsseguro AND t.nordtom = 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            --error := 105111; -- Tomador no encontrado en la tabla TOMADORES.
            RAISE e_salida;
         WHEN OTHERS
         THEN
            --error := 105112; -- Error al leer de la tabla TOMADORES.
            RAISE e_salida;
      END;

      vpasexec := 2;

      IF vcexistepagador = 1
      THEN
         BEGIN
            SELECT g.sperson
              INTO vsperson_notif
              FROM gescobros g
             WHERE g.sseguro = xsseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               --error := 9904082; -- Gestor de cobro / Pagador no encontrado en la tabla GESCOBROS.
               RAISE e_salida;
            WHEN OTHERS
            THEN
               RAISE e_salida;
         END;
      END IF;

      vpasexec := 3;

      SELECT nnumide, ctipide
        INTO vnnumide, vctipide
        FROM per_personas
       WHERE sperson = vsperson_notif;

      vpasexec := 4;

      IF xctipban IS NOT NULL
      THEN
         SELECT ctipcc
           INTO vctipcc
           FROM tipos_cuenta
          WHERE ctipban = xctipban;
      END IF;

      vpasexec := 5;

      -- Buscamos el ID de matrícula que corresponde a la cuenta
      SELECT MAX (idnotif)
        INTO xidnotif
        FROM notificaciones
       WHERE cbancar = xcbancar
         AND ctipcc = vctipcc
         AND nnumide = vnnumide
         AND ctipide = vctipide;

      vpasexec := 6;

      IF xidnotif IS NULL
      THEN
         SELECT MAX (idnotif)
           INTO xidnotif
           FROM notificaciones
          WHERE ctipban = xctipban AND cbancar = xcbancar;
      END IF;

      xidnotif2 := LPAD (xidnotif, 30, '0');
      RETURN xidnotif2;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_DOMIS.f_get_notficaciones_idnotif2',
                      vpasexec,
                      vparam,
                      SQLERRM
                     );
         RETURN NULL;
   END f_get_notificaciones_idnotif2;

-- 41. MMM - 0027598 LCOL_A003-Error en la informacion del campo de matricula generado en el archivo previo de domiciliacion - QT-8390 - Fin

   --Necesitan XNRECIBO ACTUAL
   PROCEDURE p_domic_notif_logerr (p_proces IN NUMBER, p_err IN NUMBER)
   IS
   BEGIN
      IF xnrecibo IS NOT NULL AND xnrecibo <> 0
      THEN
         IF gbdomiciliacion
         THEN
            UPDATE domiciliaciones
               SET cdomest = 1,                                      --OJO err
                   cdomerr = p_err                                   --tip_err
             WHERE sproces = p_proces AND nrecibo = xnrecibo;
         ELSE
            UPDATE notificaciones
               SET cnotest = 1,                                          --err
                   cnoterr = p_err                                   --tip_err
             WHERE sproces = p_proces AND nrecibo = xnrecibo;
         END IF;
      END IF;
   END;

   --Necesitan XNRECIBO ACTUAL
   PROCEDURE p_prolinea_nueva (
      p_proces   IN   NUMBER,
      p_num      IN   NUMBER,
      p_texto    IN   VARCHAR2,
      p_seguro   IN   NUMBER
   )
   IS
      xnprolin   procesoslin.nprolin%TYPE;
      nerror     NUMBER;
   BEGIN
      IF p_num = 0 OR p_num IS NULL
      THEN
         nerror := nlinerr;
      ELSE
         nerror := p_num;
      END IF;

      nerror := NVL (p_seguro, 0);           -->siempre poner número de seguro
      xnprolin := NULL;
      nerror :=
         f_proceslin (p_proces,
                      'Rec:' || xnrecibo || '|' || SUBSTR (p_texto, 1, 105),
                      nerror,
                      xnprolin
                     );

      IF xnrecibo IS NOT NULL AND xnrecibo <> 0
      THEN
         p_domic_notif_logerr (p_proces, k_error_linea);
      END IF;
   END;

   --AGG modificaciones SEPA
   --AGG a la hora de llamar a esta procedimiento hay que tener en cuenta que llama a p_prolinea_nueva
   --que utiliza la variable global xnrecibo que debe estar informada con la valor del recibo actual
   PROCEDURE p_recibo_nombre (
      p_proceso   IN       NUMBER,
      p_seguro    IN       NUMBER,
      p_idioma    IN OUT   NUMBER,
      p_nombre    IN OUT   VARCHAR2,
      p_sperson   IN OUT   NUMBER,
      p_domici    IN OUT   VARCHAR2
   )
   IS
   BEGIN
      error := 0;
      nlinerr := 1;
      error :=
              f_nomrecibo (p_seguro, p_nombre, p_idioma, p_sperson, p_domici);
      --OJO nombre no inc nombre2 para pos
      nlinerr := 2;

      IF error = 0
      THEN
         IF p_sperson IS NULL
         THEN
            error := 180210;
            p_prolinea_nueva (p_proceso,
                              error,
                              'p_recibo_nombre() xsseguro=' || p_seguro,
                              p_seguro
                             );
         END IF;
      ELSE
         p_prolinea_nueva (p_proceso,
                           error,
                              'Error en f_nomrecibo() para seguro :'
                           || p_seguro
                           || ' -p_sperson:'
                           || p_sperson,
                           p_seguro
                          );
      END IF;
   END;

   FUNCTION f_get_numero (pletra IN VARCHAR2)
      RETURN NUMBER
   IS
      vnumero   VARCHAR2 (2);
   BEGIN
      IF pletra = 'A'
      THEN
         vnumero := '10';
      ELSIF pletra = 'B'
      THEN
         vnumero := '11';
      ELSIF pletra = 'C'
      THEN
         vnumero := '12';
      ELSIF pletra = 'D'
      THEN
         vnumero := '13';
      ELSIF pletra = 'E'
      THEN
         vnumero := '14';
      ELSIF pletra = 'F'
      THEN
         vnumero := '15';
      ELSIF pletra = 'G'
      THEN
         vnumero := '16';
      ELSIF pletra = 'H'
      THEN
         vnumero := '17';
      ELSIF pletra = 'I'
      THEN
         vnumero := '18';
      ELSIF pletra = 'J'
      THEN
         vnumero := '19';
      ELSIF pletra = 'K'
      THEN
         vnumero := '20';
      ELSIF pletra = 'L'
      THEN
         vnumero := '21';
      ELSIF pletra = 'M'
      THEN
         vnumero := '22';
      ELSIF pletra = 'N'
      THEN
         vnumero := '23';
      ELSIF pletra = 'O'
      THEN
         vnumero := '24';
      ELSIF pletra = 'P'
      THEN
         vnumero := '25';
      ELSIF pletra = 'Q'
      THEN
         vnumero := '26';
      ELSIF pletra = 'R'
      THEN
         vnumero := '27';
      ELSIF pletra = 'S'
      THEN
         vnumero := '28';
      ELSIF pletra = 'T'
      THEN
         vnumero := '29';
      ELSIF pletra = 'U'
      THEN
         vnumero := '30';
      ELSIF pletra = 'V'
      THEN
         vnumero := '31';
      ELSIF pletra = 'W'
      THEN
         vnumero := '32';
      ELSIF pletra = 'X'
      THEN
         vnumero := '33';
      ELSIF pletra = 'Y'
      THEN
         vnumero := '34';
      ELSIF pletra = 'Z'
      THEN
         vnumero := '35';
      END IF;

      RETURN vnumero;
   END f_get_numero;

    --AGG modificaciones SEPA
    /*******************************************************************************
   FUNCION f_convertir_ccc_ibna
         -- Descripcion
   Parámetros:
    Entrada :
      pccc: Cuenta Bancaria de la que queremos obtener el IBAN
      pPais: País al que pertenece la cuenta bancaria

     Retorna el IBAN correspondiente a la cuenta bancaria
   ********************************************************************************/
   FUNCTION f_convertir_ccc_iban (pccc IN VARCHAR2, ppais IN VARCHAR2)
      RETURN VARCHAR2
   IS
      viban            VARCHAR2 (30) := '';
      vprimeraletra    VARCHAR2 (1);
      vsegundaletra    VARCHAR2 (1);
      vprimernumero    VARCHAR2 (2)  := '';
      vsegundonumero   VARCHAR2 (2)  := '';
      vcadaux          VARCHAR2 (30);
      vnumaux          NUMBER;
      vresto           NUMBER;
   BEGIN
      vprimeraletra := SUBSTR (ppais, 1, 1);
      vsegundaletra := SUBSTR (ppais, 2, 1);
      vprimernumero := f_get_numero (UPPER (vprimeraletra));
      vsegundonumero := f_get_numero (UPPER (vsegundaletra));
      viban :=
         CONCAT (CONCAT (CONCAT (pccc, vprimernumero), vsegundonumero), '00');
      vnumaux := TO_NUMBER (viban, '99999999999999999999999999');
      vresto := MOD (vnumaux, 97);
      vnumaux := 98 - vresto;
      vcadaux := TO_CHAR (vnumaux);

      IF LENGTH (vcadaux) = 1
      THEN
         vcadaux := CONCAT ('0', vcadaux);
      END IF;

      viban := CONCAT (CONCAT (UPPER (ppais), vcadaux), pccc);
      RETURN viban;
   END f_convertir_ccc_iban;

--AGG modificaciones SEPA
   FUNCTION f_get_ident_interv (
      pnif        IN       VARCHAR2,
      psufix      IN       VARCHAR2,
      pidpais     IN       VARCHAR2,
      pidinterv   OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      wcheckdigit   VARCHAR2 (2);
      wchkdigaux    VARCHAR2 (35);
   --
   BEGIN
      -- cobbancario.nnumnif -> V48148639
      wchkdigaux := pnif || 'ES00';
      -- A -> 10, B -> 11 ... Z -> 35
      -- DBMS_OUTPUT.put_line('1.-' || wchkdigaux);
      wchkdigaux := REPLACE (wchkdigaux, 'A', '10');
      wchkdigaux := REPLACE (wchkdigaux, 'B', '11');
      wchkdigaux := REPLACE (wchkdigaux, 'C', '12');
      wchkdigaux := REPLACE (wchkdigaux, 'D', '13');
      wchkdigaux := REPLACE (wchkdigaux, 'E', '14');
      wchkdigaux := REPLACE (wchkdigaux, 'F', '15');
      wchkdigaux := REPLACE (wchkdigaux, 'G', '16');
      wchkdigaux := REPLACE (wchkdigaux, 'H', '17');
      wchkdigaux := REPLACE (wchkdigaux, 'I', '18');
      wchkdigaux := REPLACE (wchkdigaux, 'J', '19');
      wchkdigaux := REPLACE (wchkdigaux, 'K', '20');
      wchkdigaux := REPLACE (wchkdigaux, 'L', '21');
      wchkdigaux := REPLACE (wchkdigaux, 'M', '22');
      wchkdigaux := REPLACE (wchkdigaux, 'N', '23');
      wchkdigaux := REPLACE (wchkdigaux, 'O', '24');
      wchkdigaux := REPLACE (wchkdigaux, 'P', '25');
      wchkdigaux := REPLACE (wchkdigaux, 'Q', '26');
      wchkdigaux := REPLACE (wchkdigaux, 'R', '27');
      wchkdigaux := REPLACE (wchkdigaux, 'S', '28');
      wchkdigaux := REPLACE (wchkdigaux, 'T', '29');
      wchkdigaux := REPLACE (wchkdigaux, 'U', '30');
      wchkdigaux := REPLACE (wchkdigaux, 'V', '31');
      wchkdigaux := REPLACE (wchkdigaux, 'W', '32');
      wchkdigaux := REPLACE (wchkdigaux, 'X', '33');
      wchkdigaux := REPLACE (wchkdigaux, 'Y', '34');
      wchkdigaux := REPLACE (wchkdigaux, 'Z', '35');
      -- MOD 97-10
      -- Calcula el mòdul 97 i es resta el romanent de 98.
      -- Si el resultat és un sol dígit, llavors s'afegeix un zero per l'esquerra.
      -- El  romanent  de la divisió de 000300050000001012345101300 per 97  =  67
      -- 98 - 67 = 31
      wcheckdigit := LPAD (98 - MOD (TO_NUMBER (wchkdigaux), 97), 2, '0');
      --3148148639142800
      --DBMS_OUTPUT.put_line('2.-' || wchkdigaux);
      --wCheckDigit := mod(98 - mod(wChkDigAux * 100, 97), 97);
      pidinterv := pidpais || wcheckdigit || psufix || pnif;
      --
      --DBMS_OUTPUT.put_line('3.-' || wcheckdigit || ':::' || pidinterv);
      RETURN (0);
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN (-1);
   END f_get_ident_interv;
END pac_domis;

/

  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DOMIS" TO "PROGRAMADORESCSI";
