/* Formatted on 2019/11/06 09:53 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PACKAGE BODY pac_gestion_rec
IS
   /******************************************************************************
       NOMBRE:      PAC_GESTION_REC
       PROP¿SITO:   Impresion de recibos

       REVISIONES:
       Ver        Fecha        Autor             Descripci¿n
       ---------  ----------  ---------------  ------------------------------------
       1.0        28/01/2009                   1. Creaci¿n del package.
       1.1        11/02/2009   FAL             1. A¿adir funcionalidades de gesti¿n de recibos. Bug: 0007657
       1.2        27/02/2009   MCC             1. Excel para la impresion del docket. Bug 009005: APR - docket para los brokers
       1.3        09/03/2009   RSC             1. Unificaci¿n de recibos
       1.4        07/04/2009   JTS             1. 9006: APR - Plantilla RTF pra la impresi¿n de recibos manuales
       1.5        15/06/2009   JTS             1. Bug 10069
       1.6        24/07/2009   APD             1. Bug 10787: APR - Campo CTIPCOB a nivel de recibo
       1.7        29/07/2009   ASN             1. Bug 10019: APR - Cobro automatico al imprimir recibos con tipo cobrador broker
       1.8        11/08/2009   ICV             1. Bug 10019: APR - cobro de recibos por broker
       1.9        04/09/2009   JTS             1. Bug 10529: Pantallas de recibos
       2.0        28/12/2009   MCA             1. Bug 12148: Los apuntes que se generaban en CTACTES cuando se cobra un recibo se elimina
       3          24/03/2010   XPL             1. 0013450: APREXT02 - Transferencia de saldos entre rebuts
       4.0        30/03/2009   XPL             4  Bug 13850: APRM00 - Lista de recibos por personas
       5          29/04/2010   LCF             4  14302 Campo descripci¿n traspaso saldo
       6.0        04/05/2010   DRA             6. 0014298: Pantalla de modificaci¿n de recibos
       7.0        12/05/2010   JTS             7. BUG 14438
       8.0        20/07/2010   AMC             8. 0015449: AGA - Modificaci¿n de recibos
       9.0        30/09/2010   ETM             9. 0016141: AGA003 - rebuts en gesti¿
      10.0        18/10/2010   ICV            10. 0016297: CRE998 - Canvi en la visualitzaci¿ de rebuts de la Posici¿ global
      11.0        25/05/2010   ICV            11. 14586: CRT - A¿adir campo recibo compa¿ia
      12.0        17/11/2010   ICV            12. 0016383: AGA003 - recargo por devoluci¿n de recibo (renegociaci¿n de recibos)
      13.0        14/12/2010   JTS            13. 14586: CRT001 - A¿adir campo recibo compa¿ia
      14.0        14/02/2011   JRH            14. 0017247: ENSA103 - Instalar els web-services als entorns CSI
      15.0        23/03/2011   DRA            15. 0018054: AGM003 - Administraci¿n - Secuencia de nrecibo.
      16.0        14/04/2011   APD            16. 0018225: AGM704 - Realizar la modificaci¿n de precisi¿n el cagente
      17.0        15/11/2011   APD            17. 0018946: LCOL_P001 - PER - Visibilidad en personas
      18.0        13/12/2011   APD            18. 0019792: ENSA800- Convertir fondo ENSA en plan contributivo por participe. Repasar Suplementos por fichero.
      19.0        03/01/2012   JMF            19. 0020761 LCOL_A001- Quotes targetes
      20.0        18/07/2012   ICV            20. 0022960: LCOL_A003-Modificacion contable de la fecha de administracion una vez cerrado el mes
      21.0        07/08/2012   APD            21. 0022342: MDP_A001-Devoluciones
      22.0        24/07/2012   JGR            22. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028
      23.0        25/10/2012   DRA            23. 0023853: LCOL - PRIMAS M¿NIMAS PACTADAS POR P¿LIZA Y POR COBRO
      24.0        05/11/2012   DRA            24. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
      25.0        08/01/2013   APD            25. 0023853: LCOL - PRIMAS M¿NIMAS PACTADAS POR P¿LIZA Y POR COBRO
      26.0        17/01/2013   ECP            26. 0025583: LCOL - Revision incidencias qtracker (IV)
      27.0        07/02/2013   ECP            27. 0025583: LCOL - Revision incidencias qtracker (IV) Nota 137444
      28.0        12/02/2013   JMF            0026035: LCOL_T020-Qtracker: 0005944: CONSULTAS COASEGURO CEDIDO JDE
      29.0        18/02/2013   DRA            29. 0026111: LCOL: Revisar Retorno en Colectivos
      30.0        19/02/2013   APD            30. 0026022: LCOL: Liquidaciones de Colectivos
      31.0        28/02/2013   DRA            31. 0026229: LCOL: Retorno sobre el recibo de Regularizaci?n de prima m?nima
      32.0        25/06/2013   RCL            32. 0024697: Canvi mida camp sseguro
      33.0        18/09/2013   JGR            33. 0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package
      34.0        19/11/2013   DCT            34. 0027048: LCOL_T010-Revision incidencias qtracker (V)
      35.0        25/11/2012   ETM            35. 0029009: POSRA100-POS - Pantalla manual de recibos
      36.0        21/01/2014   JDS            36. 0029603: POSRA300-Texto en la columna Pagador del Recibo para recibos de Colectivos
      37.0        27/03/2014   MMM            37. 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion...
      38.0        03/04/2014   MMM            38. 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas...
      39.0        02/06/2014   MMM            39. 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario
      40.0        03/11/2015   FAL            40. 0038346: ERROR PROCESANDO ACTUALIZACION CONVENIOS POLIZA HIJO (bug hermano interno)
      41.0        21/11/2017   AAB            41. CONF-403:SE ADICIONA UNA VALIDACION PARA QUE SE EJECUTE POR AGENTE CORRETAJE O AGENTE
      42.0        15/05/2019   ECP            42. IAXIS-3592. Proceso de terminación por no pago
      43.0        09/07/2019   DFR            43. IAXIS-3651 Proceso calculo de comisiones de outsourcing
      44.0        18/07/2019   SA             44. IAXIS-4753 Ajuste campos Servicio L003
      45.0    19/07/2019   PK    45. Cambio de IAXIS-4844 - Optimizar Petición Servicio I017
      46.0       15/07/2019   Shakti          46. IAXIS-4753 Ajuste campos Servicio L003
      47.0       01/08/2019   Shakti          47. IAXIS-4944 TAREAS CAMPOS LISTENER
      48.0       05/09/2019   ECP             48. IAXIS-5149. Verificación proceso cancelación por no pago
      49.0       23/09/2019   ECP             49. IAXIS-5149. Verificación proceso cancelación por no pago
      50.0       12/12/2019   DFR             50. IAXIS-7983: Perdida de información en valor de comisiones y % comisión en recibos 
      51.0       06/03/2020   ECP             51. IAXIS-12974. Identificación automática productos que no se cancelan
      52.0       08/05/2020   ECP             52. IAXIS-13321.Error en pantalla Terminación por no pago
   ******************************************************************************/

   /*******************************************************************************
   PROCESO proceso_batch_cierre

   Se ejecuta en los cierres, actualiza la FEFEADM DE RECIBOS

   ********************************************************************************/
   PROCEDURE proceso_batch_cierre (
      pmodo      IN       NUMBER,
      pcempres   IN       NUMBER,
      pmoneda    IN       NUMBER,
      pcidioma   IN       NUMBER,
      pfperini   IN       DATE,
      pfperfin   IN       DATE,
      pfcierre   IN       DATE,
      pcerror    OUT      NUMBER,
      psproces   OUT      NUMBER,
      pfproces   OUT      DATE
   )
   IS
      num_err      NUMBER          := 0;
      text_error   VARCHAR2 (500)  := 0;
      pnnumlin     NUMBER;
      texto        VARCHAR2 (400);
      conta_err    NUMBER          := 0;
      v_titulo     VARCHAR2 (50);
      xmodo        VARCHAR2 (1);
      v_func       VARCHAR2 (4000);
      v_aux        VARCHAR2 (40);
   BEGIN
      IF pmodo = 1
      THEN
         v_titulo := 'Proceso Cierre Previo';
         xmodo := 'P';
      ELSE
         v_titulo := 'Proceso Cierre Mensual';
         xmodo := 'R';
      END IF;

      --Insertamos en la tabla PROCESOSCAB el registro identificativo de proceso -----
      num_err :=
         f_procesini (f_user,
                      pcempres,
                      'CIERRE PRODUCCION',
                      v_titulo,
                      psproces
                     );
      COMMIT;

      IF num_err <> 0
      THEN
         pcerror := 1;
         conta_err := conta_err + 1;
         texto := f_axis_literales (num_err, pcidioma);
         pnnumlin := NULL;
         num_err :=
            f_proceslin (psproces,
                         SUBSTR (   'CIERRE PRODUCCION '
                                 || texto
                                 || ' '
                                 || text_error,
                                 1,
                                 120
                                ),
                         0,
                         pnnumlin
                        );
         COMMIT;
      ELSE
         pcerror := 0;

         IF pmodo = 1
         THEN                                                        --Previo
            NULL;
         ELSE                                                           --Real
            UPDATE movrecibo
               SET fefeadm =
                      TO_DATE (   '01'
                               || TO_CHAR (ADD_MONTHS (pfperini, 1), 'mmyyyy'),
                               'ddmmyyyy'
                              )
             WHERE TRUNC (fefeadm) > pfcierre
               --La fecha de administraci¿n sea mayor que la fecha en la que se cierra
               AND TRUNC (fefeadm) <= LAST_DAY (pfperfin);
--Hasta final de mes, por seguirdad se pone last_day aunque siempre es final de mes
         END IF;
      END IF;

      num_err := f_procesfin (psproces, conta_err);
      pfproces := f_sysdate;
      pcerror := 0;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'CIERRE PRODUCCION PROCESO =' || psproces,
                      NULL,
                      'when others del cierre =' || pfperfin,
                      SQLERRM
                     );
         pcerror := 1;
   END proceso_batch_cierre;

   /*******************************************************************************
   FUNCION f_poblac
    Devuelve el CP y la poblacion de una persona

      param in psperson : persona
      param in pcdomici : codigo domicilio
      return : NUMBER
   ********************************************************************************/
   FUNCTION f_poblac (psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2
   IS
      v_tpoblac   per_direcciones.cpostal%TYPE;
--       v_tpoblac      VARCHAR2(300); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      SELECT cpostal || ' ' || f_despoblac2 (cpoblac, cprovin)
        INTO v_tpoblac
        FROM per_direcciones
       WHERE sperson = psperson AND cdomici = NVL (pcdomici, 1);

      RETURN v_tpoblac;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_poblac;

/*******************************************************************************
 FUNCION f_adresa
 Devuelve la direccion de una persona

   param in psperson : persona
   param in pcdomici : Codigo domicilio
   return : NUMBER
********************************************************************************/
   FUNCTION f_adresa (psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2
   IS
      v_tdomici   per_direcciones.tdomici%TYPE;
      v_csiglas   per_direcciones.csiglas%TYPE;
      v_tnomvia   per_direcciones.tnomvia%TYPE;
      v_nnumvia   per_direcciones.nnumvia%TYPE;
      v_tcomple   per_direcciones.tcomple%TYPE;
   BEGIN
      SELECT tdomici                  --csiglas,tnomvia,nnumvia,tcomple --  --
        INTO v_tdomici        -- v_csiglas,v_tnomvia,v_nnumvia,v_tcomple -- --
        FROM per_direcciones
       WHERE sperson = psperson AND cdomici = NVL (pcdomici, 1);

      --  v_tdomici := pac_persona.f_tdomici(v_csiglas, v_tnomvia,v_nnumvia,v_tcomple);
      -- P_CREAR_TDOMICILI(v_csiglas, v_tnomvia,v_nnumvia,v_tcomple, v_tdomici);
      RETURN v_tdomici;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_adresa;

/*******************************************************************************
FUNCION f_importe_recibo
 Devuelve el importe de un recibo

   param in pnrecibo : Recibo
   return : NUMBER
********************************************************************************/
   FUNCTION f_importe_recibo (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      imprecibo   NUMBER;
   BEGIN
      SELECT SUM (itotalr)
        INTO imprecibo
        FROM vdetrecibos
       WHERE nrecibo = pnrecibo;

      RETURN imprecibo;
   END f_importe_recibo;

/*******************************************************************************
FUNCION f_nom
 Devuelve el nombre y apellidos de una persona

   param in psperson : persona
   param in pcagente : agente
   return : NUMBER
********************************************************************************/
   FUNCTION f_nom (psperson IN NUMBER, pcagente IN NUMBER)
      RETURN VARCHAR2
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (300) := 'psperson=' || psperson;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.F_NOM';
      v_nombre   VARCHAR2 (100);
   BEGIN
      SELECT    TRIM (pd.tapelli1)
             || ' '
             || TRIM (pd.tapelli2)
             || ' , '
             || TRIM (pd.tnombre)
        INTO v_nombre
        FROM per_personas p, per_detper pd
       WHERE p.sperson = pd.sperson
         --AND pd.cagente = pcagente
         AND p.sperson = psperson
         -- AND p.swpubli = 1
         AND pd.fmovimi = (SELECT MAX (d.fmovimi)
                             FROM per_detper d
                            WHERE d.sperson = pd.sperson);

      RETURN v_nombre;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN '***';
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN NULL;
   END f_nom;

/*******************************************************************************
FUNCION F_IMPR_PENDIENTE_MAN
la funcion se encargar¿ de grabar en la tabla temporal de la impresi¿n de recibos aquellos que cumplan con los criterios de b¿squeda

   param in psproduc : Id. producto
   param in pcagente : Agente
   param in psproces : Proceso
   param in pnpoliza : Poliza
   param in pnrecibo : Recibo
   param in pdataini : Fecha inicio
   param in pdatafin : Fecha fin
   param in pcreimp  : Reimpresion
   param in psproimp : Codigo proceso
   param in pcreccia : Recibo compa¿ia
   param out psproimp2 : Codigo proceso
   return: number con el c¿digo de error.
********************************************************************************/
   FUNCTION f_impr_pendiente_man (
      psproduc    IN       NUMBER,
      pcagente    IN       NUMBER,
      psproces    IN       NUMBER,
      pnpoliza    IN       NUMBER,
      pnrecibo    IN       NUMBER,
      pdataini    IN       DATE,
      pdatafin    IN       DATE,
      pcreimp     IN       NUMBER,
      psproimp    IN       NUMBER,
      pcreccia    IN       VARCHAR2,
      --Bug 14586-PFA-25/05/2010- A¿adir campo recibo compa¿ia
      psproimp2   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      vpasexec    NUMBER (8)                    := 1;
      vparam      VARCHAR2 (300)
         :=    'psproduc='
            || psproduc
            || ' pcagente='
            || pcagente
            || ' psproces='
            || psproces
            || ' pnpoliza='
            || pnpoliza
            || ' pnrecibo='
            || pnrecibo
            || ' pdataini='
            || pdataini
            || ' pdatafin='
            || pdatafin
            || ' pcreimp='
            || pcreimp
            || ' psproimp='
            || psproimp
            || ' pcreccia='
            || pcreccia;
      --Bug 14586-PFA-25/05/2010- A¿adir campo recibo compa¿ia
      vobject     VARCHAR2 (200)     := 'PAC_GESTION_REC.F_IMPR_PENDIENTE_MAN';
      num         NUMBER;
      v_smovrec   tmp_recgestion.smovrec%TYPE;
      --       v_smovrec      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_sproimp   tmp_recgestion.sproimp%TYPE;
      --       v_sproimp      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tot       NUMBER;
   BEGIN
/* La funci¿n se encargar¿ de grabar en la tabla temporal de la impresi¿n de recibos aquellos que cumplan con los criterios de b¿squeda y
que no est¿n en la tabla temporal (tmp_recgestion).

En el caso de reimpresi¿n :
Solo se permitir¿ la reimpresi¿n de p¿lizas y  recibos (sin informar  el psproimp), en el caso de querer reimprimir un agente,
 producto  o todo un proceso se deber¿ obligar a informar el proceso de impresi¿n.
*/
      v_tot := 0;

      -- p_Tab_error (f_sysdate,f_user,vobject,vpasexec,'1 '||vparam,sqlerrm);
      -- vpasexec :=2;
      IF pcreimp IS NOT NULL
      THEN
         IF     (pnpoliza IS NOT NULL OR pnrecibo IS NOT NULL)
            AND psproimp IS NOT NULL
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                            vparam
                         || ' No ha informado bien los parametros de busqueda.',
                         SQLERRM
                        );
            RETURN 9901779;
         END IF;

         IF     (pcagente IS NOT NULL OR psproduc IS NOT NULL)
            AND psproimp IS NULL
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                            vparam
                         || ' No ha informado bien los parametros de busqueda.',
                         SQLERRM
                        );
            RETURN 9901779;
         END IF;
      END IF;

/*En el caso que del par¿metro del Pcreimp venga informado (seleccionado) se insertar¿ en la tabla tmp_regestion aquellos recibos
de la tabla recgestion que cumplan con las condiciones informadas por par¿metro aunque el estado de impresi¿n no sea 1.
En el caso de que el pcreimp o el psproimp no venga informado se tiene que seleccionar aquellos recibos con estado de impresi¿n
cestimp =1 (pendiente de imprimir), y que las fecha de  efecto est¿n comprendidas entre las fechas de inicio o final.
(En el caso de que la fecha final no venga informada la fecha de efecto deber¿ coincidir con la fecha de incio.
El campo cestado deber¿ informarse por defecto con un  1, y el campo sproces con el valor de psproces.
El campo smovrec ser¿ el smovrec de movrecibo para el ¿ltimo movimiento.
*/
      IF pcreimp IS NOT NULL
      THEN
         IF psproimp IS NULL
         THEN
            SELECT seqsproimp.NEXTVAL
              INTO v_sproimp
              FROM DUAL;
         ELSE
            v_sproimp := psproimp;
         END IF;

         FOR cur IN
            (SELECT r.sproimp, r.nrecibo, r.cagecob, r.fgestio, r.smovrec,
                    r.fefecto, r.sproces, r.fimpres, r.cestado, re.creccia
               FROM recgestion r, recibos re, seguros s
              WHERE r.sproimp = NVL (psproimp, r.sproimp)
                AND r.cagecob = NVL (pcagente, r.cagecob)
                AND
                    --sproces = NVL (psproces,sproces) AND
                    r.nrecibo = NVL (pnrecibo, r.nrecibo)
                AND r.nrecibo = re.nrecibo
                AND (   pcreccia IS NULL
                     OR (pcreccia IS NOT NULL AND re.creccia = pcreccia)
                    )                               --Bug 14586-JTS-14/12/2010
                AND re.sseguro = s.sseguro
                AND s.npoliza = NVL (pnpoliza, s.npoliza)
                AND s.sproduc = NVL (psproduc, s.sproduc))
         LOOP
            v_tot := v_tot + 1;

            SELECT MAX (smovrec)
              INTO v_smovrec
              FROM movrecibo
             WHERE nrecibo = cur.nrecibo;

            BEGIN
               INSERT INTO tmp_recgestion
                           (sproimp, nrecibo, cagecob,
                            fgestio, smovrec, fefecto,
                            sproces, fimpres, cestado
                           )
                    VALUES (v_sproimp, cur.nrecibo, cur.cagecob,
                            cur.fgestio, v_smovrec, cur.fefecto,
                            cur.sproces, f_sysdate, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam || ' v_sproim=' || v_sproimp,
                               SQLERRM
                              );
                  RETURN SQLCODE;
            END;
         END LOOP;
      ELSIF pcreimp IS NULL OR psproimp IS NULL
      THEN
         IF psproimp IS NULL
         THEN
            SELECT seqsproimp.NEXTVAL
              INTO v_sproimp
              FROM DUAL;
         ELSE
            v_sproimp := psproimp;
         END IF;

         FOR cur IN
            (SELECT r.nrecibo, r.femisio, r.fefecto, r.cagente, r.creccia
               FROM recibos r, seguros s
              WHERE cestimp = 1
                AND (   r.fefecto BETWEEN pdataini AND pdatafin
                     OR (    TRUNC (r.fefecto) = TRUNC (pdataini)
                         AND pdatafin IS NULL
                        )
                    )
                AND r.cagente = NVL (pcagente, r.cagente)
                AND r.nrecibo = NVL (pnrecibo, r.nrecibo)
                AND (   pcreccia IS NULL
                     OR (pcreccia IS NOT NULL AND r.creccia = pcreccia)
                    )                               --Bug 14586-JTS-14/12/2010
                AND r.sseguro = s.sseguro
                AND s.npoliza = NVL (pnpoliza, s.npoliza)
                AND s.sproduc = NVL (psproduc, s.sproduc))
         LOOP
            v_tot := v_tot + 1;

            SELECT MAX (smovrec)
              INTO v_smovrec
              FROM movrecibo
             WHERE nrecibo = cur.nrecibo;

            BEGIN
               INSERT INTO tmp_recgestion
                           (sproimp, nrecibo, cagecob,
                            fgestio, smovrec, fefecto, sproces,
                            fimpres, cestado
                           )
                    VALUES (v_sproimp, cur.nrecibo, cur.cagente,
                            cur.femisio, v_smovrec, cur.fefecto, psproces,
                            f_sysdate, 0
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam || ' v_sproim=' || v_sproimp,
                               SQLERRM
                              );
                  RETURN SQLCODE;
            END;
         END LOOP;
      END IF;

      --p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'v_sproim=' || v_sproimp);
      IF v_tot = 0
      THEN
         -- No se han encontrado datos
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam || ' No se han encontrado datos.',
                      SQLERRM
                     );
         RETURN 1000254;
      END IF;

      IF v_sproimp IS NULL
      THEN
         psproimp2 := psproimp;
      ELSE
         psproimp2 := v_sproimp;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_impr_pendiente_man;

/*******************************************************************************
FUNCION F_GET_IMPR_PENDIENTE_MAN
Esta funci¿n retornar¿ el conteniendo de la tabla tmp_recgestion para el proceso solicitado.
   param in psproimp : Codigo proceso
   param in pcidioma : Idioma
   param in pitotalr : Total recibo
   return: ref_cursor con los registros que cumplan con el criterio
********************************************************************************/
   FUNCTION f_get_impr_pendiente_man (
      psproimp   IN       NUMBER,
      pcidioma   IN       NUMBER,
      pitotalr   OUT      NUMBER
   )
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
                       := 'Psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.F_GET_IMPR_PENDIENTE_MAN';
   BEGIN
      -- Esta funci¿n retornar¿ el conteniendo de la tabla tmp_recgestion para el proceso solicitado.
      pitotalr := 0;

      -- Control parametros entrada
      IF psproimp IS NULL OR pcidioma IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      f_axis_literales (140974, pcidioma) || '  ' || vparam,
                      SQLERRM
                     );
         RETURN cur;                          --Faltan parametros por informar
      END IF;

/*
 Se deber¿ retornar los la siguiente informaci¿n de los recibos afectados.
¿    C¿digo de proceso
¿    N¿mero de p¿liza
¿    N¿mero de recibo
¿    Nombre del tomador de la p¿liza
¿    Situaci¿n de la p¿liza.
¿    producto
¿    cestado
*/
      OPEN cur FOR
         SELECT t.sproces, s.npoliza, t.nrecibo,
                f_nombre (tom.sperson, 1, r.cagente) tnombre,
                ff_desvalorfijo (61, pcidioma, s.csituac) tsituac,
                f_desproducto_t (s.cramo,
                                 s.cmodali,
                                 s.ctipseg,
                                 s.ccolect,
                                 1,
                                 pcidioma
                                ) tproducto,
                t.cestado, f_importe_recibo (r.nrecibo) imprecibo, r.creccia
           FROM seguros s, recibos r, tomadores tom, tmp_recgestion t
          WHERE t.sproimp = psproimp
            AND t.nrecibo = r.nrecibo
            AND r.sseguro = s.sseguro
            AND s.sseguro = tom.sseguro
            AND tom.nordtom = 1;

      vpasexec := 2;

      --El pitotalr de salida se informar¿ con itotalr de vdetrcibos para los recibos seleccionados para su impresi¿n cestado =1
      BEGIN
         SELECT SUM (itotalr)
           INTO pitotalr
           FROM vdetrecibos v
          WHERE nrecibo IN (SELECT nrecibo
                              FROM tmp_recgestion
                             WHERE sproimp = psproimp AND cestado = 1);
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
            pitotalr := 0;
      END;

      --Retorna un ref_cursor con los registros que cumplan con el criterio
      RETURN cur;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN cur;
   END f_get_impr_pendiente_man;

/*******************************************************************************
FUNCION F_SET_IMPR_PENDIENTE_MAN
Se actualizar¿ el cestado de la tabla tmp_recgestion para el recibo y proceso informado por par¿metro.
   param in psproimp : Codigo proceso
   param in pnrecibo : Recibo
   param in pcestado : Estado
   param out pitotalr : Total recibo
   return: NUMBER
********************************************************************************/
   FUNCTION f_set_impr_pendiente_man (
      psproimp   IN       NUMBER,
      pnrecibo   IN       NUMBER,
      pcestado   IN       NUMBER,
      pitotalr   OUT      NUMBER
   )
      RETURN NUMBER
   IS
      num        NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
         :=    'psproimp='
            || psproimp
            || ' pnrecibo='
            || pnrecibo
            || ' pcestado='
            || pcestado;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.F_SET_IMPR_PENDIENTE_MAN';
   BEGIN
      -- Control parametros entrada
      IF psproimp IS NULL OR pnrecibo IS NULL OR pcestado IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Faltan parametros por informar: ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

      --Se actualizar¿ el cestado de la tabla tmp_recgestion para el recibo y proceso informado por par¿metro.
      vpasexec := 2;

      UPDATE tmp_recgestion
         SET cestado = pcestado
       WHERE nrecibo = pnrecibo AND sproimp = psproimp;

      --El pitotalr de salida se informar¿ con itotalr de vdetrcibos para los recibos seleccionados para su impresi¿n cestado =1
      BEGIN
         SELECT SUM (itotalr)
           INTO pitotalr
           FROM vdetrecibos v
          WHERE nrecibo IN (SELECT nrecibo
                              FROM tmp_recgestion
                             WHERE sproimp = psproimp AND cestado = 1);
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
            pitotalr := 0;
      END;

      --Retorna un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_set_impr_pendiente_man;

/*******************************************************************************
FUNCION F_CANCEL_IMPRESION_MAN
Se borrar¿ la tabla tmp_recgestion para el sproimp informado

  param in psproimp : Codigo proceso  Psproimp IN  NUMBER
  return: NUMBER , un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero
********************************************************************************/
   FUNCTION f_cancel_impresion_man (psproimp IN NUMBER)
      RETURN NUMBER
   IS
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (300) := 'psproimp=' || psproimp;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.F_CANCEL_IMPRESION_MAN';
      num        NUMBER;
   BEGIN
      -- Control parametros entrada
      IF psproimp IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Faltan parametros por informar: ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

      vpasexec := 2;

      --Se borrar¿ la tabla tmp_recgestion para el sproimp informado
      DELETE FROM tmp_recgestion
            WHERE sproimp = psproimp;

      --Retorna un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_cancel_impresion_man;

/*******************************************************************************
FUNCION F_IMPRESION_RECIBOS_MAN
Funci¿n que imprimir¿ los recibos seleccionados.

  param in psproimp : Codigo proceso
  param in pcidioma : Codigo idioma
  param out pfichero : Ruta del fichero generado
  return : number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
  --BUG9006 - 07/04/2009 - JTS - 9006: APR - Plantilla RTF pra la impresi¿n de recibos manuales
********************************************************************************/
   FUNCTION f_impresion_recibos_man (
      psproimp    IN       NUMBER,
      pcidioma    IN       NUMBER,
      pfichero    OUT      VARCHAR2,
      pcreafich   IN       NUMBER DEFAULT 1
   )
      RETURN NUMBER
   IS
      vpasexec           NUMBER (8)                     := 1;
      vparam             VARCHAR2 (300)
                       := 'psproimp=' || psproimp || ' pcidioma=' || pcidioma;
      vobject            VARCHAR2 (200)
                                 := 'PAC_GESTION_REC.F_IMPRESION_RECIBOS_MAN';
      num                NUMBER;
      v_dir              VARCHAR2 (100);
      v_dir_url          VARCHAR2 (100);
      v_nomf             VARCHAR2 (100);
      v_str              VARCHAR2 (500);
      v_nombre           VARCHAR2 (200);
      v_desprod          VARCHAR2 (200);
      v_npol             seguros.npoliza%TYPE;
--       v_npol         VARCHAR2(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cabecera         VARCHAR2 (300);
      v_dataini          DATE;    --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_datafin          DATE;
      v_cramo            seguros.cramo%TYPE;
      v_cmodali          seguros.cmodali%TYPE;
      v_ctipseg          seguros.ctipseg%TYPE;
      v_ccolect          seguros.ccolect%TYPE;
      v_sperson          tomadores.sperson%TYPE;
      v_f                UTL_FILE.file_type;
      v_sseguro          NUMBER;
      v_cagente          agentes.cagente%TYPE;
      --       v_cagente      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
          -- Bug 18225 - APD - 11/04/2011 - la precisi¿n debe ser NUMBER
      v_tdomici_broker   VARCHAR2 (150);
      v_tnombre_broker   VARCHAR2 (150);
      v_poblac_broker    VARCHAR2 (150);
      v_postal_broker    per_direcciones.tdomici%TYPE;
--       v_postal_broker VARCHAR2(150); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ccc_broker       VARCHAR2 (150);
      v_tdomici_holder   VARCHAR2 (150);
      v_tnombre_holder   VARCHAR2 (150);
      v_poblac_holder    VARCHAR2 (150);
      v_postal_holder    per_direcciones.tdomici%TYPE;
--       v_postal_holder VARCHAR2(150); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_npoliza          VARCHAR2 (150);
      v_fefecto          DATE;
      v_fvencim          DATE;
      v_nrecibo          recibos.nrecibo%TYPE;
--       v_nrecibo      NUMBER(20); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tnombre_risk     VARCHAR2 (150);
      v_amount_basics    detrecibos.iconcep%TYPE;        --20.3NUMBER(15, 2);
      v_amount_others    detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_kost_basics      detrecibos.iconcep%TYPE;        --20.3NUMBER(15, 2);
      v_kost_compl       detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_tax_basic        detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_tax_comlp        detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_total_basic      detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_total_compl      detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_total            detrecibos.iconcep%TYPE;           ---NUMBER(15, 2);
      v_impagos          NUMBER (8);
      v_smovrec          movrecibo.smovrec%TYPE;
      v_ctipcob          seguros.ctipcob%TYPE;
      v_ccobban          recibos.ccobban%TYPE;
      v_cempres          recibos.cempres%TYPE;
      v_cdelega          recibos.cdelega%TYPE;
      v_err              NUMBER;
      v_nnumlin          NUMBER;
      v_totrecibo        NUMBER;
      v_totcomision      NUMBER;
      vcestant           movrecibo.cestant%TYPE;
      vcestrec           movrecibo.cestrec%TYPE;
      vfmovini           movrecibo.fmovini%TYPE;
      vfcontab           movrecibo.fcontab%TYPE;
      vuser              movrecibo.cusuari%TYPE;
   BEGIN
      -- Control parametros entrada
      IF psproimp IS NULL OR pcidioma IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      f_axis_literales (140974, pcidioma) || '  ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

/*
Se imprimir¿n los recibos seleccionados, una vez imprimidos se traspasar¿ dicha selecci¿n a la tabla recgestion  y se marcar¿n
los recibos con cestimp =2 (imprimidos).  En el caso de que el campo sproces de la tabla tmp_recgestion est¿ informado no se
trapasar¿ a la tabla , ni se modificar¿ la situaci¿n del estado de la impresi¿n (se trata de una reimpresi¿n).
Despues de esto se deber¿ lanzar el report de recibos.
*/
      IF pcreafich = 1
      THEN
         -- Generar excel
         v_dir := f_parinstalacion_t ('INFORMES');
         v_dir_url := f_parinstalacion_t ('INFORMES_C');

         -- File
         IF pcidioma = 1
         THEN
            v_nomf := 'impressio_rebuts_' || psproimp || '.csv';
         ELSE
            v_nomf := 'impresion_recibos_' || psproimp || '.csv';
         END IF;

         pfichero := v_dir_url || '\' || v_nomf;
         v_f := UTL_FILE.fopen (v_dir, v_nomf, 'w');
         v_cabecera :=
               'CAGENTE;TDOMICI_BROKER;TNOMBRE_BROKER;POBLAC_BROKER;POSTAL_BROKER;CCC_BROKER;TDOMICI_HOLDER;TNOMBRE_HOLDER;'
            || 'POBLAC_HOLDER;POSTAL_HOLDER;NPOLIZA;FEFECTO;FVENCIM;NRECIBO;TNOMBRE_RISK;AMOUNT_BASICS;'
            || 'AMOUNT_OTHERS;KOST_BASICS;KOST_COMPL;TAX_BASIC;TAX_COMLP;TOTAL_BASIC;TOTAL_COMPL;TOTAL;';
         UTL_FILE.put_line (v_f, v_cabecera);
      END IF;

      FOR cur IN (SELECT sproimp, nrecibo, cagecob, fgestio, smovrec, fefecto,
                         sproces, cestado, fimpres
                    FROM tmp_recgestion
                   WHERE sproimp = psproimp AND cestado = 1)
      LOOP
         -- Llamar al report de impresion recibos
         IF cur.sproces IS NULL
         THEN
            BEGIN
               vpasexec := 2;

               BEGIN
                  SELECT s.npoliza npol,
                         f_desproducto_t (s.cramo,
                                          s.cmodali,
                                          s.ctipseg,
                                          s.ccolect,
                                          1,
                                          pcidioma
                                         ),
                         f_nombre (v_sperson, 1, r.cagente), r.fefecto,
                         r.fvencim, s.sseguro, t.sperson,
                         r.sseguro
                    INTO v_npol,
                         v_desprod,
                         v_nombre, v_dataini,
                         v_datafin, v_sseguro, v_sperson,
                         v_sseguro                                -- Bug 10019
                    FROM seguros s, recibos r, tomadores t
                   WHERE r.nrecibo = cur.nrecibo
                     AND r.sseguro = s.sseguro
                     AND s.sseguro = t.sseguro
                     AND t.nordtom = 1;

                  v_npoliza := v_npol;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               BEGIN
                  SELECT DISTINCT a.cagente cagente,
                                  f_nombre (a.sperson, 1, a.cagente)
                                                               tnombre_broker,
                                  d.tdomici tdomici_broker,
                                  cpostal postal_broker,
                                  tpoblac poblac_broker, a.cbancar ccc_broker
                             INTO v_cagente,
                                  v_tnombre_broker,
                                  v_tdomici_broker,
                                  v_postal_broker,
                                  v_poblac_broker, v_ccc_broker
                             FROM recibos r,
                                  agentes a,
                                  per_direcciones d,
                                  poblaciones p
                            WHERE a.cagente = cur.cagecob
                              AND r.sseguro = v_sseguro
                              AND r.cagente = a.cagente
                              AND a.sperson = d.sperson
                              AND p.cprovin = d.cprovin
                              AND p.cpoblac = d.cpoblac;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               BEGIN
                  SELECT DISTINCT f_nombre (a.sperson, 1, v_cagente)
                                                               tnombre_holder,
                                  d.tdomici tdomici_holder,
                                  cpostal postal_holder,
                                  tpoblac poblac_holder
                             INTO v_tnombre_holder,
                                  v_tdomici_holder,
                                  v_postal_holder,
                                  v_poblac_holder
                             FROM recibos r,
                                  tomadores a,
                                  per_direcciones d,
                                  poblaciones p
                            WHERE a.sperson = v_sperson
                              AND a.sseguro = v_sseguro
                              AND r.sseguro = a.sseguro
                              AND a.sperson = d.sperson
                              AND p.cprovin = d.cprovin
                              AND p.cpoblac = d.cpoblac;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               BEGIN
                  SELECT r.nrecibo nrecibo, r.fefecto fefecto,
                         r.fvencim fvencim,
                         f_nombre (ri.sperson, 1, v_cagente) tnombre_risk,
                         r.cempres, r.cdelega, r.ccobban, s.ctipcob
                    -- Bug 10019 22/07/2009 ASN - APR - cobro de recibos por broker
                  INTO   v_nrecibo, v_fefecto,
                         v_fvencim,
                         v_tnombre_risk,
                         v_cempres, v_cdelega, v_ccobban, v_ctipcob
                    FROM recibos r, seguros s, riesgos ri
                   WHERE nrecibo = cur.nrecibo
                     AND r.sseguro = s.sseguro
                     AND s.sseguro = ri.sseguro;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               BEGIN
                  SELECT   (  SUM (DECODE (cconcep, 0, iconcep, 0))
                            + SUM (DECODE (cconcep, 1, iconcep, 0))
                            + SUM (DECODE (cconcep, 2, iconcep, 0))
                            + SUM (DECODE (cconcep, 3, iconcep, 0))
                            + SUM (DECODE (cconcep, 4, iconcep, 0))
                            + SUM (DECODE (cconcep, 5, iconcep, 0))
                            + SUM (DECODE (cconcep, 6, iconcep, 0))
                            + SUM (DECODE (cconcep, 7, iconcep, 0))
                            + SUM (DECODE (cconcep, 8, iconcep, 0))
                            + SUM (DECODE (cconcep, 14, iconcep, 0))
                            - SUM (DECODE (cconcep, 13, iconcep, 0))
                           ) total,
                           (  SUM (DECODE (cconcep, 4, iconcep, 0))
                            + SUM (DECODE (cconcep, 5, iconcep, 0))
                            + SUM (DECODE (cconcep, 6, iconcep, 0))
                            + SUM (DECODE (cconcep, 7, iconcep, 0))
                           ) tax,
                           SUM (DECODE (cconcep, 8, iconcep, 0)) kost,
                           (  SUM (DECODE (cconcep, 0, iconcep, 0))
                            + SUM (DECODE (cconcep, 1, iconcep, 0))
                            + SUM (DECODE (cconcep, 2, iconcep, 0))
                            + SUM (DECODE (cconcep, 3, iconcep, 0))
                            + SUM (DECODE (cconcep, 14, iconcep, 0))
                            - SUM (DECODE (cconcep, 13, iconcep, 0))
                           ) amount
                      INTO v_total_basic,
                           v_tax_basic,
                           v_kost_basics,
                           v_amount_basics
                      FROM detrecibos d, recibos r, seguros s, garanpro g
                     WHERE r.nrecibo = v_nrecibo
                       AND d.nrecibo = r.nrecibo
                       AND r.sseguro = s.sseguro
                       AND s.cramo = g.cramo
                       AND s.cmodali = g.cmodali
                       AND s.ctipseg = g.ctipseg
                       AND s.ccolect = g.ccolect
                       AND d.cgarant = g.cgarant
                       AND cbasica = 1
                  GROUP BY g.cbasica;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               BEGIN
                  SELECT   (  SUM (DECODE (cconcep, 0, iconcep, 0))
                            + SUM (DECODE (cconcep, 1, iconcep, 0))
                            + SUM (DECODE (cconcep, 2, iconcep, 0))
                            + SUM (DECODE (cconcep, 3, iconcep, 0))
                            + SUM (DECODE (cconcep, 4, iconcep, 0))
                            + SUM (DECODE (cconcep, 5, iconcep, 0))
                            + SUM (DECODE (cconcep, 6, iconcep, 0))
                            + SUM (DECODE (cconcep, 7, iconcep, 0))
                            + SUM (DECODE (cconcep, 8, iconcep, 0))
                            + SUM (DECODE (cconcep, 14, iconcep, 0))
                            - SUM (DECODE (cconcep, 13, iconcep, 0))
                           ) total,
                           (  SUM (DECODE (cconcep, 4, iconcep, 0))
                            + SUM (DECODE (cconcep, 5, iconcep, 0))
                            + SUM (DECODE (cconcep, 6, iconcep, 0))
                            + SUM (DECODE (cconcep, 7, iconcep, 0))
                           ) tax,
                           SUM (DECODE (cconcep, 8, iconcep, 0)) kost,
                           (  SUM (DECODE (cconcep, 0, iconcep, 0))
                            + SUM (DECODE (cconcep, 1, iconcep, 0))
                            + SUM (DECODE (cconcep, 2, iconcep, 0))
                            + SUM (DECODE (cconcep, 3, iconcep, 0))
                            + SUM (DECODE (cconcep, 14, iconcep, 0))
                            - SUM (DECODE (cconcep, 13, iconcep, 0))
                           ) amount
                      INTO v_total_compl,
                           v_tax_comlp,
                           v_kost_compl,
                           v_amount_others
                      FROM detrecibos d, recibos r, seguros s, garanpro g
                     WHERE r.nrecibo = v_nrecibo
                       AND d.nrecibo = r.nrecibo
                       AND r.sseguro = s.sseguro
                       AND s.cramo = g.cramo
                       AND s.cmodali = g.cmodali
                       AND s.ctipseg = g.ctipseg
                       AND s.ccolect = g.ccolect
                       AND d.cgarant = g.cgarant
                       AND cbasica = 0
                  GROUP BY g.cbasica;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     NULL;
               END;

               v_total := NVL (v_total_compl, 0) + NVL (v_total_basic, 0);

               IF pcreafich = 1
               THEN
                  v_str :=
                        v_cagente
                     || ';'
                     || v_tdomici_broker
                     || ';'
                     || v_tnombre_broker
                     || ';'
                     || v_poblac_broker
                     || ';'
                     || v_postal_broker
                     || ';'
                     || v_ccc_broker
                     || ';'
                     || v_tdomici_holder
                     || ';'
                     || v_tnombre_holder
                     || ';'
                     || v_poblac_holder
                     || ';'
                     || v_postal_holder
                     || ';'
                     || v_npoliza
                     || ';'
                     || v_fefecto
                     || ';'
                     || v_fvencim
                     || ';'
                     || v_nrecibo
                     || ';'
                     || NVL (v_tnombre_risk, 0)
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_amount_basics,
                                            '99999999999990D00'
                                           )
                                  ),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_amount_others,
                                            '99999999999990D00'
                                           )
                                  ),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_kost_basics,
                                            '99999999999990D00')
                                  ),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_kost_compl, '99999999999990D00')),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_tax_basic, '99999999999990D00')),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_tax_comlp, '99999999999990D00')),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_total_basic,
                                            '99999999999990D00')
                                  ),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_total_compl,
                                            '99999999999990D00')
                                  ),
                             '0,00'
                            )
                     || ';'
                     || NVL (TRIM (TO_CHAR (v_total, '99999999999990D00')),
                             '0,00'
                            );
                  UTL_FILE.put_line (v_f, v_str);
               END IF;

               vpasexec := 3;

               UPDATE recibos
                  SET cestimp = 2
                WHERE nrecibo = cur.nrecibo;

               -- Bug 10019 22/07/2009 ASN - APR - cobro de recibos por broker
               vpasexec := 4;

               IF v_ctipcob = 4
               THEN
                  -- Bug 10019: APR - 11/08/09 - ICV - Se a¿ade el GREATEST con la fecha del ¿ltimo movimiento del recibo
                  v_err :=
                     f_ultsitrec (cur.nrecibo,
                                  vcestant,
                                  vcestrec,
                                  vfmovini,
                                  vfcontab,
                                  vuser
                                 );

                  IF v_err <> 0
                  THEN
                     p_tab_error
                        (f_sysdate,
                         f_user,
                         'PAC_GESTION_REC.f_impresion_recibos_man',
                         NULL,
                            'par¿metros - pcempres - pnrecibo - pfmovini - pccobban - pcdelega - pctipcob: '
                         || v_cempres
                         || '-'
                         || cur.nrecibo
                         || '-'
                         || f_sysdate
                         || '-'
                         || v_ccobban
                         || '-'
                         || v_cdelega
                         || '-'
                         || v_ctipcob,
                            'Error al ejecutar F_ULTSITREC en pac_gestion_rec.f_impresion_recibos_man - vnumerr: '
                         || v_err
                        );
                     RETURN v_err;
                  END IF;

                  v_err :=
                     pac_gestion_rec.f_cobro_recibo (v_cempres,
                                                     cur.nrecibo,
                                                     GREATEST (f_sysdate,
                                                               vfmovini
                                                              ),
                                                     NULL,
                                                     NULL,
                                                     v_ccobban,
                                                     v_cdelega,
                                                     v_ctipcob
                                                    );
               --BUG 12148 Se eliminan los apuntes de comisiones en CTACTES cuando se cobra el recibo
               END IF;

               -- Bug 10019 fin
               vpasexec := 5;

               INSERT INTO recgestion
                           (sproimp, nrecibo, cagecob,
                            fgestio, smovrec, fefecto,
                            sproces, fimpres, cestado
                           )
                    VALUES (cur.sproimp, cur.nrecibo, cur.cagecob,
                            cur.fgestio, cur.smovrec, cur.fefecto,
                            cur.sproces, cur.fimpres, cur.cestado
                           );
            EXCEPTION
               WHEN DUP_VAL_ON_INDEX
               THEN
                  NULL;
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                               SQLERRM
                              );
                  RETURN SQLCODE;
            END;

            --Bug 9204-MCC-03/03/2009-Restructuraci¿n del package
            FOR c_reb IN (SELECT r.sseguro, r.nrecibo,
                                 r.fefecto + ndiaavis ffejecu,
                                 f_sysdate ffecalt, d.cactimp, 1 ctractat,
                                 1 cmotivo, d.cmodelo ccarta, 0 nimpagad
                            FROM recibos r,
                                 seguros s,
                                 prodreprec p,
                                 detprodreprec d
                           WHERE r.sseguro = s.sseguro
                             AND s.sproduc = p.sproduc
                             AND p.finiefe <= r.fefecto
                             AND (p.ffinefe IS NULL OR p.ffinefe > r.fefecto
                                 )
                             AND d.sidprodp = p.sidprodp
                             AND r.nrecibo = cur.nrecibo)
            LOOP
               SELECT COUNT (*)
                 INTO v_impagos
                 FROM tmp_impagados ti
                WHERE ti.sseguro = c_reb.sseguro
                  AND ti.nrecibo = c_reb.nrecibo
                  AND ti.ffejecu = c_reb.ffejecu;

               IF v_impagos <> 0
               THEN
                  SELECT MAX (smovrec)
                    INTO v_smovrec
                    FROM movrecibo
                   WHERE nrecibo = c_reb.nrecibo;

                  --AND fmovfin IS NULL;
                  INSERT INTO tmp_impagados
                              (sseguro, nrecibo, ffejecu,
                               ffecalt, cactimp, ctractat,
                               ttexto, cmotivo, terror, ccarta, nimpagad,
                               sdevolu, smovrec
                              )
                       VALUES (c_reb.sseguro, c_reb.nrecibo, c_reb.ffejecu,
                               f_sysdate, c_reb.cactimp, c_reb.ctractat,
                               NULL, c_reb.cmotivo, NULL, c_reb.ccarta, 0,
                               psproimp, v_smovrec
                              );
               END IF;
            END LOOP;
         --Bug FIN 9204-MCC-03/03/2009-Restructuraci¿n del package
         END IF;
      END LOOP;

      --Fi BUG9006 - 07/04/2009 - JTS
      IF pcreafich = 1
      THEN
         UTL_FILE.fclose (v_f);
      END IF;

      --Retorna un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF UTL_FILE.is_open (v_f)
         THEN
            UTL_FILE.fclose (v_f);
         END IF;

         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_impresion_recibos_man;

/*******************************************************************************
FUNCION F_SELEC_TODOS_RECIBOS
Se actualizar¿ el cestado a 1 de todos los recibos la tabla tmp_recgestion para un proceso psproimp por par¿metro.
  param in psproimp : Codigo proceso
  param in pitotalr : Total recibos
  return : NUMBER
********************************************************************************/
   FUNCTION f_selec_todos_recibos (psproimp IN NUMBER, pitotalr OUT NUMBER)
      RETURN NUMBER
   IS
      num        NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'psproimp=' || psproimp;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.F_SELECC_TODOS_RECIBOS';
   BEGIN
      -- Control parametros entrada
      IF psproimp IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Faltan parametros por informar: ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

      UPDATE tmp_recgestion
         SET cestado = 1
       WHERE sproimp = psproimp;

      vpasexec := 2;

      --El pitotalr de salida se informar¿ con itotalr de vdetrcibos para los recibos seleccionados para su impresi¿n cestado =1
      BEGIN
         SELECT SUM (itotalr)
           INTO pitotalr
           FROM vdetrecibos v
          WHERE nrecibo IN (SELECT nrecibo
                              FROM tmp_recgestion
                             WHERE sproimp = psproimp AND cestado = 1);
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
            pitotalr := 0;
      END;

      --Retorna un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_selec_todos_recibos;

/*******************************************************************************
FUNCION F_DESSELEC_TODOS_RECIBOS
Se actualizar¿ el cestado a 0 de todos los recibos de la tabla tmp_recgestion para un proceso psproimp por par¿metro.

  param in psproimp : Codigo proceso
  param in pitotalr : Total recibos
  return : NUMBER
********************************************************************************/
   FUNCTION f_desselec_todos_recibos (psproimp IN NUMBER, pitotalr OUT NUMBER)
      RETURN NUMBER
   IS
      num        NUMBER;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200) := 'psproimp=' || psproimp;
      vobject    VARCHAR2 (200)
                               := 'PAC_GESTION_REC.F_DESSELECC_TODOS_RECIBOS';
   BEGIN
      -- Control parametros entrada
      IF psproimp IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      'Faltan parametros por informar: ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

      UPDATE tmp_recgestion
         SET cestado = 0
       WHERE sproimp = psproimp;

      vpasexec := 2;
      pitotalr := 0;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_desselec_todos_recibos;

/*-----------------------------------------------------------------------*/
/* Gesti¿n manual de recibos                                             */
/* Bug: 0007657: IAX - Gesti¿n de recibos                                            */
/* FAL                                              */
/*-----------------------------------------------------------------------*/

   --BUG 10069 - 15/06/2009 - JTS
   --BUG 11777 - 11/11/2009 - JRB - Se pasa el ctipban y cbancar para actualizarlo en el recibo.
   /*******************************************************************************
   FUNCION F_COBRO_RECIBO
   Funci¿n que realiza el cobro para usuarios de central (cobro manual)
      param in pcempres : empres
      param in pnrecibo : recibo
      param in pfmovini : fecha de cobro
      param in pctipban : Tipo de cuenta.
      param in pcbancar : Cuenta bancaria.
      param in pccobban : cobrador bancario
      param in pdelega : delegaci¿n
      return: number indicando c¿digo de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_cobro_recibo (
      pcempres     IN   NUMBER,
      pnrecibo     IN   NUMBER,
      pfmovini     IN   DATE,
      pctipban     IN   NUMBER,
      pcbancar     IN   VARCHAR2,
      pccobban     IN   NUMBER,
      pdelega      IN   NUMBER,
      pctipcob     IN   NUMBER DEFAULT 0,
              -- Bug 10019 22/07/2009 ASN - APR - cobro de recibos por broker)
      pnreccaj     IN   VARCHAR2 DEFAULT NULL,
-- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro /* Cambios de IAXIS-4753 */
      pcmreca      IN   NUMBER DEFAULT NULL,
                        -- INI -IAXIS-4153 - JLTS - 07/06/2019 nuevo parámetro
      pcindicaf    IN   VARCHAR2 DEFAULT NULL,          ------Changes for 4944
      pcsucursal   IN   VARCHAR2 DEFAULT NULL,          ------Changes for 4944
      pndocsap     IN   VARCHAR2 DEFAULT NULL,          ------Changes for 4944
      pcususap     IN   VARCHAR2 DEFAULT NULL
   )                                                    ------Changes for 4944
      RETURN NUMBER
   IS
      xfultcon      empresas.fmescon%TYPE;
      err           NUMBER                    := 0;
      recestado     NUMBER;
      vsmovrecibo   movrecibo.smovagr%TYPE    := 0;
      xnliqmen      liquidacab.nliqmen%TYPE;
      dummy         NUMBER;
      -- Bug 9383 - 06/03/2009 - RSC - CRE: Unificaci¿n de recibos
      vcramo        seguros.cramo%TYPE;
      vcmodali      seguros.cmodali%TYPE;
      vctipseg      seguros.ctipseg%TYPE;
      vccolect      seguros.ccolect%TYPE;
      vcountagrp    NUMBER;
      vccobban      seguros.ccobban%TYPE;
      --       vccobban       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcagente      seguros.cagente%TYPE;
      --       vcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
          -- Fin Bug 9383
      vctipcob      recibos.ctipcob%TYPE;                        -- Bug 10019
   BEGIN
      IF (   pcempres IS NULL
          OR pnrecibo IS NULL
          OR pfmovini IS NULL
          OR (pccobban IS NULL AND pdelega IS NULL)
         )
      THEN
         RETURN (100900);
      END IF;

      -- BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP No se permite conbrar recibos
      IF     NVL (pac_parametros.f_parempresa_n (pcempres, 'GESTIONA_COBPAG'),
                  0
                 ) = 1
         AND NVL (pac_parametros.f_parempresa_n (pcempres, 'COBPAG_PANTALLA'),
                  0
                 ) = 0
      THEN
         RETURN 110300;
      END IF;

      -- Fi  BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP
      err := f_fcontab (pcempres, xfultcon);

      IF err != 0
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'F_FCONTAB',
             NULL,
             'par¿metros - pcempres: ' || pcempres,
                'Error al ejecutar procedimiento o funci¿ f_fcontab - vnumerr: '
             || err
            );
         RETURN err;
      END IF;

      IF     (   pdelega IS NOT NULL
              OR pccobban IS NOT NULL
              OR f_parinstalacion_t ('DELCOBRA') = 'NO'
             )
         AND pfmovini IS NOT NULL
         AND pfmovini > xfultcon
         AND pcempres IS NOT NULL
      THEN
         IF NVL
               (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                               'PAGAR_REB_PAGADOS'
                                              ),
                0
               ) = 0
         THEN
            err := f_situarec (pnrecibo, pfmovini, recestado);
         ELSE
            recestado := 99;
         END IF;

         IF err != 0
         THEN
            p_tab_error
               (f_sysdate,
                f_user,
                'F_SITUAREC',
                NULL,
                   'par¿metros - pnrecibo - pfmovini: '
                || pnrecibo
                || '-'
                || pfmovini,
                   'Error al ejecutar f_situarec en pac_gestion_rec.f_cobro_recibo - vnumerr: '
                || err
               );
            RETURN err;
         END IF;

         -- Bug 19880 - 22/12/2011 - JRB - Que permita el estado 3 tambi¿n.
         IF recestado IN (0, 3, 99)
         THEN                                                     -- pendiente
            err := f_situarec (pnrecibo, f_sysdate, recestado);

            -- Bug 9383 - 05/03/2009 - RSC - CRE: Unificaci¿n de recibos
            -- El cobro del recibo agrupado debe dejar los recibos peque¿itos en
                 -- estado cobrado
            BEGIN
               SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cagente
                 INTO vcramo, vcmodali, vctipseg, vccolect, vcagente
                 FROM recibos r, seguros s
                WHERE r.nrecibo = pnrecibo AND r.sseguro = s.sseguro;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_gestion_rec.f_cobro_recibo',
                               1,
                               'Error al buscar datos del recibo: '
                               || pnrecibo,
                               SQLERRM
                              );
                  err := 101731;                       -- recibo no encontrado
                  RETURN err;
            END;

            IF NVL (f_parproductos_v (f_sproduc_ret (vcramo,
                                                     vcmodali,
                                                     vctipseg,
                                                     vccolect
                                                    ),
                                      'RECUNIF'
                                     ),
                    0
                   ) IN (1, 3)
            THEN
               -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
                    /******************************************
                    No se puede cobrar un recibo peque¿ito que
                    pertenezca a una agrupaci¿n de recibos.
                    *******************************************/
               SELECT COUNT (*)
                 INTO vcountagrp
                 FROM adm_recunif
                WHERE nrecibo = pnrecibo;

               IF vcountagrp > 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_gestion_rec.p_cobro_recibo',
                               2,
                               f_axis_literales (9001154, f_idiomauser),
                               SQLERRM
                              );
                  err := 9001154;
                  -- No se pueden cobrar recibos pertenecientes
                  -- a un recibo agrupado.
                  RETURN err;
               END IF;
            END IF;

            SELECT DECODE (pctipcob, 4, 0, 2, NULL, pctipcob)
              INTO vctipcob
              FROM DUAL;

            IF NVL (f_parproductos_v (f_sproduc_ret (vcramo,
                                                     vcmodali,
                                                     vctipseg,
                                                     vccolect
                                                    ),
                                      'RECUNIF'
                                     ),
                    0
                   ) IN (1, 2, 3)
            THEN
               -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
                    -- Si es un recibo agrupado entrar¿ en LOOP
               FOR v_recind IN (SELECT nrecibo
                                  FROM adm_recunif a
                                 WHERE nrecunif = pnrecibo)
               LOOP
                  -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos pnreccaj,pcmreca
                  err :=
                     f_movrecibo (v_recind.nrecibo,
                                  01,
                                  NULL,
                                  NULL,
                                  vsmovrecibo,
                                  xnliqmen,
                                  dummy,
                                  pfmovini,
                                  pccobban,
                                  pdelega,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  vctipcob,
                                  pnreccaj,
                                  pcmreca,
                                  pcindicaf,
                                  pcsucursal,
                                  pndocsap,
                                  pcususap
                                 ); -- Bug 10019 vctipcob en lugar de pctipcob

                  -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos pnreccaj,pcmreca
                  ---PCINDICAF,PCSUCURSAL,PNDOCSAP,pcususap changes for 4944
                  IF err <> 0
                  THEN
                     RETURN err;
                  END IF;
               END LOOP;
            END IF;

                -- Fin Bug 9383
            -- INI -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos pnreccaj,pcmreca
            err :=
               f_movrecibo (pnrecibo,
                            01,
                            NULL,
                            NULL,
                            vsmovrecibo,
                            xnliqmen,
                            dummy,
                            pfmovini,
                            pccobban,
                            pdelega,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            vctipcob,
                            pnreccaj,
                            pcmreca,
                            pcindicaf,
                            pcsucursal,
                            pndocsap,
                            pcususap
                           );       -- Bug 10019 vctipcob en lugar de pctipcob
         -- FIN -IAXIS-4153 - JLTS - 07/06/2019 Se incluyen los nuevos pnreccaj,pcmreca
         ---PCINDICAF,PCSUCURSAL,PNDOCSAP,pcususap changes for 4944
         ELSE
            RETURN 101126;           -- El rebut no est¿ pendent de cobrament
         END IF;

         --BUG 11777 - 11/11/2009 - JRB - Se pasa el ctipban y cbancar para actualizarlo en el recibo.
         IF pctipban IS NOT NULL AND pcbancar IS NOT NULL
         THEN
            /*vccobban := f_buscacobban(vcramo, vcmodali, vctipseg, vccolect, vcagente,
                                      pcbancar, pctipban, err);

            IF vccobban IS NULL THEN
               p_tab_error(f_sysdate, f_user, 'pac_gestion_rec.f_cobro_recibo', 2,
                           'Error al buscar cobrador bancario: ' || pnrecibo || ' cuenta: '
                           || pcbancar,
                           SQLERRM);
               RETURN err;
            END IF;

            -- Modificamos el recibo con la cuenta y el cobrador elegido
            BEGIN
               UPDATE recibos
                  SET cbancar = pcbancar,
                      ccobban = vccobban,
                      ctipban = pctipban
                WHERE nrecibo = pnrecibo;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_emision_mv.p_cobro_recibo', 3,
                              'Error al modificar la cuenta del recibo: ' || pnrecibo,
                              SQLERRM);
                  err := 102358;   -- error al modificar recibos
                  RETURN err;
            END;*/
            err := f_set_reccbancar (pnrecibo, pcbancar, pctipban);
            RETURN err;
         END IF;

         RETURN err;
      ELSE
         IF pcempres IS NULL
         THEN
            RETURN 103019;
         ELSIF pfmovini IS NULL
         THEN
            RETURN 105463;
         ELSIF pfmovini <= xfultcon
         THEN
            RETURN 107861;
         ELSIF pdelega IS NULL AND pccobban IS NULL
         THEN
            RETURN 107868;
         ELSIF xfultcon IS NULL
         THEN
            RETURN 9001248;
         END IF;
      END IF;
   END f_cobro_recibo;

   --Fi BUG 10069 - 15/06/2009 - JTS

   /*******************************************************************************
   FUNCION F_ANULA_RECIBO
   Funci¿n que realiza la anulaci¿n de un recibo.
      param in pnrecibo : recibo
      param in pfanulac : fecha anulaci¿n
      param in pcmotanu : motivo anulaci¿n
      return: number indicando c¿digo de error (0: sin errores)
   ********************************************************************************/
   FUNCTION f_anula_recibo (
      pnrecibo   IN   NUMBER,
      pfanulac   IN   DATE,
      pcmotanu   IN   NUMBER
   )
      RETURN NUMBER
   IS
      err   NUMBER;
   BEGIN
      err := f_anula_rec (pnrecibo, pfanulac, pcmotanu);

      IF err != 0
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'F_ANULA_REC',
             NULL,
                'par¿metros - pnrecibo - pfanulac - pcmotanu: '
             || pnrecibo
             || '-'
             || pfanulac
             || '-'
             || pcmotanu,
                'Error al ejecutar f_anula_rec en pac_gestion_rec.f_anula_recibo - vnumerr: '
             || err
            );
         RETURN err;
      END IF;

      RETURN err;
   END f_anula_recibo;

/*******************************************************************************
FUNCION F_MODIFICA_RECIBO
Funci¿n que realiza modificaci¿n en el recibo.
   param in pnrecibo : recibo
   param in pctipban : tipo cuenta
   param in pcbancar : cuenta bancaria
   param in pcgescob : gestor de cobro
   param in pcestimp : estado de impresi¿n
   param in pcaccpre : c¿digo de acci¿n preconocida
   param in pcaccret : c¿digo de acci¿n retenida
   param in ptobserv : texto de observaciones
   return: number indicando c¿digo de error (0: sin errores)
   -- BUG 0020761 - 03/01/2012 - JMF: ncuotar
   -- Bug 22342 - APD - 11/06/2012 - se a¿aden los parametros pcaccpre, pcaccret y ptobserv
********************************************************************************/
   FUNCTION f_modifica_recibo (
      pnrecibo   IN   NUMBER,
      pctipban   IN   NUMBER,
      pcbancar   IN   VARCHAR2,
      pcgescob   IN   NUMBER,
      pcestimp   IN   NUMBER,
      pccobban   IN   NUMBER,
      pncuotar   IN   NUMBER DEFAULT NULL,
      pcaccpre   IN   NUMBER DEFAULT NULL,
      pcaccret   IN   NUMBER DEFAULT NULL,
      ptobserv   IN   VARCHAR2 DEFAULT NULL,
      pctipcob   IN   NUMBER DEFAULT NULL,
      --AAC_INI-CONF_OUTSOURCING-20160906
      pcgescar   IN   NUMBER DEFAULT NULL
   --AAC_FI-CONF_OUTSOURCING-20160906
   )
      RETURN NUMBER
   IS
      recestado      NUMBER;
      err            NUMBER                       := 0;
      wctipban       recibos.ctipban%TYPE;
      wcbancar       recibos.cbancar%TYPE;
      wcgescob       recibos.cgescob%TYPE;
      wctiprec       recibos.ctiprec%TYPE;
      wcestimp       recibos.cestimp%TYPE;
      wccobban       recibos.ccobban%TYPE;
      -- BUG 0020761 - 03/01/2012 - JMF
      wncuotar       recibos.ncuotar%TYPE;
      -- bug 15449 - 20/07/2010 - AMC
      vcramo         seguros.cramo%TYPE;
      --       vcramo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcmodali       seguros.cmodali%TYPE;
      --       vcmodali       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vctipseg       seguros.ctipseg%TYPE;
      --       vctipseg       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccolect       seguros.ccolect%TYPE;
      --       vccolect       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcagente       seguros.cagente%TYPE;
      --       vcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccobban       recibos.ccobban%TYPE;
      --       vccobban       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
          -- Fi bug 15449 - 20/07/2010 - AMC
                -- Bug 22342 - APD - 11/06/202
      wcaccpre       recibos_comp.caccpre%TYPE;
      wcaccret       recibos_comp.caccret%TYPE;
      wtobserv       recibos_comp.tobserv%TYPE;
      -- fin Bug 22342 - APD - 11/06/202
      vctipcob       recibos.ctipcob%TYPE;
      wctipcob       recibos.ctipcob%TYPE;
      --
      wtextoagetit   VARCHAR2 (500);
      wtextoage      VARCHAR2 (500);
      wtextocampo    VARCHAR2 (500);
      --
      ttipban        tipos_cuentades.ttipo%TYPE;
--       ttipban        VARCHAR2(500); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_idobs        NUMBER;
   BEGIN
      IF NVL (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                             'PAGAR_REB_PAGADOS'
                                            ),
              0
             ) = 0
      THEN
         err := f_situarec (pnrecibo, f_sysdate, recestado);
      ELSE
         recestado := 99;
      END IF;

      IF err != 0
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             'F_SITUAREC',
             NULL,
             'par¿metros - pnrecibo - pfmovini: ' || pnrecibo || '-'
             || f_sysdate,
                'Error al ejecutar f_situarec en pac_gestion_rec.f_cobro_recibo - vnumerr: '
             || err
            );
         RETURN err;
      END IF;

      -- Bug 19880 - 22/12/2011 - JRB - Que permita el estado 3 tambi¿n.
      IF recestado IN (0, 3, 99)
      THEN                                                        -- pendiente
         err := f_situarec (pnrecibo, f_sysdate, recestado);

         -- BUG 0020761 - 03/01/2012 - JMF
         SELECT r.ctipban, r.cbancar, r.cgescob, r.ctiprec, r.cestimp,
                r.ncuotar, rc.caccpre, rc.caccret, rc.tobserv, r.ctipcob
           INTO wctipban, wcbancar, wcgescob, wctiprec, wcestimp,
                wncuotar, wcaccpre, wcaccret, wtobserv, wctipcob
           FROM recibos r, recibos_comp rc
          WHERE rc.nrecibo(+) = r.nrecibo AND r.nrecibo = pnrecibo;

           -- Inicio Bug 40325/232337 - 13/04/2016 - AMC
         /* SELECT DECODE(pctipcob, 4, 0, pctipcob)
            INTO vctipcob
            FROM DUAL;*/
            -- Fin Bug 40325/232337 - 13/04/2016 - AMC

         -- Bug 22342 - APD - 11/06/2012 -
         IF     NVL (wctipban, -1) = NVL (pctipban, -1)
            AND NVL (wcbancar, '-1') = NVL (pcbancar, '-1')
            --AND NVL(wcgescob, -1) = NVL(pcgescob, -1)   -- BUG14298:DRA:04/05/2010
            AND NVL (wcestimp, -1) = NVL (pcestimp, -1)
            AND NVL (wccobban, -1) = NVL (pccobban, -1)
            AND NVL (wncuotar, -1) = NVL (pncuotar, -1)
            AND NVL (wcaccpre, -1) = NVL (pcaccpre, -1)
            AND NVL (wcaccret, -1) = NVL (pcaccret, -1)
            AND NVL (wtobserv, -1) = NVL (ptobserv, -1)
            AND NVL (wctipcob, -1) = NVL (vctipcob, -1)
         THEN
            RETURN 120466;                   -- No hi ha canvis en les dades.
         ELSE
            -- Bug 22342 - APD - 11/06/2012 - si ha habido alg¿n cambio en recibos
            IF    NVL (wctipban, -1) <> NVL (pctipban, -1)
               OR NVL (wcbancar, '-1') <> NVL (pcbancar, '-1')
               --OR NVL(wcgescob, -1) <> NVL(pcgescob, -1)   -- BUG14298:DRA:04/05/2010
               OR NVL (wcestimp, -1) <> NVL (pcestimp, -1)
               OR NVL (wccobban, -1) <> NVL (pccobban, -1)
               OR NVL (wncuotar, -1) <> NVL (pncuotar, -1)
               OR NVL (wctipcob, -1) <> NVL (vctipcob, -1)
            THEN
               -- BUG14298:DRA:04/05/2010:Inici
               /*IF pcgescob = 2
                  AND pcestimp = 4 THEN
                  RETURN 111355;
               END IF;*/
               -- BUG14298:DRA:04/05/2010:Fi
               IF wctiprec = 9 AND pcestimp IN (4, 5, 6)
               THEN
                  RETURN 111382;
               END IF;

               IF wctiprec <> 9 AND pcestimp IN (7, 8, 9)
               THEN
                  RETURN 111383;
               END IF;

               IF pcestimp IN (4, 5, 6) AND pcbancar IS NULL
               THEN
                  RETURN 9000899;
               END IF;

               -- bug 15449 - 20/07/2010 - AMC
               SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect, s.cagente
                 INTO vcramo, vcmodali, vctipseg, vccolect, vcagente
                 FROM recibos r, seguros s
                WHERE r.nrecibo = pnrecibo AND r.sseguro = s.sseguro;

               --Bug.: 0020757 - 05/01/2012 - ICV
               IF pccobban IS NULL
               THEN
                  vccobban :=
                     f_buscacobban (vcramo,
                                    vcmodali,
                                    vctipseg,
                                    vccolect,
                                    vcagente,
                                    pcbancar,
                                    pctipban,
                                    err
                                   );
               ELSE
                  vccobban := pccobban;
               END IF;

               BEGIN
                  -- BUG 0020761 - 03/01/2012 - JMF
--AAC_FI-CONF_OUTSOURCING-20160906
                  INSERT INTO hisrecibos
                              (shisrec, nrecibo, ctipban, cestaux, cestimp,
                               cbancar, cgescob, fmodban, fmodif, cusumod,
                               ccobban, ncuotar, cgescar)
                     SELECT shisrec.NEXTVAL, r.nrecibo, r.ctipban, r.cestaux,
                            r.cestimp, r.cbancar, r.cgescob,
                            DECODE (NVL (r.cbancar, '-1'), NULL, f_sysdate),
                            f_sysdate, f_user, r.ccobban, r.ncuotar,
                            r.cgescar
                       FROM recibos r
                      WHERE nrecibo = pnrecibo;
--AAC_FI-CONF_OUTSOURCING-20160906
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN 111631;
               -- Error a l'inserir en la taula HISRECIBOS
               END;

               BEGIN
                  -- BUG 0020761 - 03/01/2012 - JMF
                  UPDATE recibos
                     SET ctipban = pctipban,
                         cestimp = pcestimp,
                         cbancar = pcbancar,
                         ccobban = vccobban,
                         --cgescob = pcgescob   -- BUG14298:DRA:04/05/2010
                         ctipcob = pctipcob,
                                 -- Inicio Bug 40325/232337 - 13/04/2016 - AMC
                         ncuotar = NVL (pncuotar, ncuotar),
--AAC_INI-CONF_OUTSOURCING-20160906
                         cgescar = pcgescar,
                         fmarcagest =
                            DECODE
                               (pcgescar,
                                2, f_sysdate,
                                NULL
                               )
                      --SGM IAXIS 5241 Marcacion con fecha gestion outsourcing
--AAC_FI-CONF_OUTSOURCING-20160906
                  WHERE  nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN 102358;    -- Error al modificar la taula RECIBOS
               END;
            END IF;

            -- Bug 22342 - APD - 11/06/2012 - si ha habido alg¿n cambio en recibos complementarios
            IF    NVL (wcaccpre, -1) <> NVL (pcaccpre, -1)
               OR NVL (wcaccret, -1) <> NVL (pcaccret, -1)
               OR NVL (wtobserv, -1) <> NVL (ptobserv, -1)
            THEN
               BEGIN
                  INSERT INTO hisrecibos_comp
                              (shisrec_comp, nrecibo, caccpre, caccret,
                               tobserv, cusumod, fmodif)
                     SELECT shisrec_comp.NEXTVAL, rc.nrecibo, rc.caccpre,
                            rc.caccret, rc.tobserv, f_user, f_sysdate
                       FROM recibos_comp rc
                      WHERE rc.nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     RETURN 9903788;
               -- Error al insertar en la tabla HISRECIBOS_COMP
               END;

               BEGIN
                  INSERT INTO recibos_comp
                              (nrecibo, caccpre, caccret, tobserv,
                               cusualt, falta
                              )
                       VALUES (pnrecibo, pcaccpre, pcaccret, ptobserv,
                               f_user, f_sysdate
                              );
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX
                  THEN
                     BEGIN
                        UPDATE recibos_comp
                           SET caccpre = pcaccpre,
                               caccret = pcaccret,
                               tobserv = ptobserv
                         WHERE nrecibo = pnrecibo;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           RETURN 9903789;
                     --Error al modificar la tabla RECIBOS_COMP
                     END;
                  WHEN OTHERS
                  THEN
                     RETURN 9903789;
               --Error al modificar la tabla RECIBOS_COMP
               END;
            END IF;

            -- fin Bug 22342 - APD - 11/06/2012

            -- Fi bug 15449 - 20/07/2010 - AMC

            --
            IF NVL
                  (pac_parametros.f_parempresa_n
                                              (pac_md_common.f_get_cxtempresa,
                                               'AGENDA_MOD_RECIBO'
                                              ),
                   0
                  ) = 1
            THEN
               wtextoagetit :=
                    f_axis_literales (1000192, pac_md_common.f_get_cxtidioma);
               wtextoage :=
                     f_axis_literales (9904386,
                                       pac_md_common.f_get_cxtidioma)
                  || ' ';

               -- Inicio Bug 40325/232337 - 13/04/2016 - AMC
               IF pctipban IS NOT NULL
               THEN
                  IF NVL (wctipban, -1) != NVL (pctipban, -1)
                  THEN
                     SELECT ttipo
                       INTO ttipban
                       FROM tipos_cuentades
                      WHERE ctipban = pctipban
                        AND cidioma = pac_md_common.f_get_cxtidioma;

                     wtextocampo :=
                           f_axis_literales (9904387,
                                             pac_md_common.f_get_cxtidioma
                                            )
                        || ': '
                        || ttipban;
                     err :=
                        pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (1000374,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
                  END IF;
               END IF;

               IF pcbancar IS NOT NULL
               THEN
                  IF NVL (wcbancar, '-1') != NVL (pcbancar, '-1')
                  THEN
                     wtextocampo :=
                           f_axis_literales (9904557,
                                             pac_md_common.f_get_cxtidioma
                                            )
                        || ': '
                        || wcbancar
                        || ' '
                        || f_axis_literales (9904387,
                                             pac_md_common.f_get_cxtidioma
                                            )
                        || ': '
                        || pcbancar;
                     err :=
                        pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (100965,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
                  END IF;
               END IF;

               -- Fin Bug 40325/232337 - 13/04/2016 - AMC
               IF NVL (wcestimp, -1) != NVL (pcestimp, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || ff_desvalorfijo (75,
                                         pac_md_common.f_get_cxtidioma,
                                         pcestimp
                                        );
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (1000571,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wccobban, -1) != NVL (pccobban, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || pccobban;
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (100879,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wncuotar, -1) != NVL (pncuotar, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || pncuotar;
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (9901245,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wcaccpre, -1) != NVL (pcaccpre, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || ff_desvalorfijo (800086,
                                         pac_md_common.f_get_cxtidioma,
                                         pcaccpre
                                        );
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (9903810,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wcaccret, -1) != NVL (pcaccret, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || ff_desvalorfijo (800089,
                                         pac_md_common.f_get_cxtidioma,
                                         pcaccret
                                        );
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (9903811,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wtobserv, -1) != NVL (ptobserv, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || ptobserv;
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (9903900,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;

               IF NVL (wctipcob, -1) != NVL (vctipcob, -1)
               THEN
                  wtextocampo :=
                        f_axis_literales (9904387,
                                          pac_md_common.f_get_cxtidioma
                                         )
                     || ': '
                     || ff_desvalorfijo (1026,
                                         pac_md_common.f_get_cxtidioma,
                                         vctipcob
                                        );
                  err :=
                     pac_agenda.f_set_obs
                           (pac_md_common.f_get_cxtempresa,
                            NULL,
                            5,
                            0,
                            wtextoagetit,
                               wtextoage
                            || f_axis_literales (101516,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                            || '. '
                            || wtextocampo,
                            f_sysdate,
                            NULL,
                            2,
                            NULL,
                            NULL,
                            NULL,
                            NULL,
                            1,
                            f_sysdate,
                            v_idobs,
                            NULL,
                            pnrecibo,
                            NULL,
                            NULL,
                            NULL
                           );
               END IF;
            END IF;

            --
            RETURN err;
         END IF;
      ELSE
         RETURN 101126;              -- El rebut no est¿ pendent de cobrament
      END IF;
   END f_modifica_recibo;

/*******************************************************************************
FUNCION F_ANULACION_PENDIENTE
Funci¿n que marca un recibo como pendiente de anulaci¿n
   param in pnrecibo : recibo
   return: number indicando c¿digo de error (0: sin errores)
********************************************************************************/
   FUNCTION f_anulacion_pendiente (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      wcestadorec   movrecibo.cestrec%TYPE;
      err           NUMBER                   := 0;
      wcbancar      recibos.cbancar%TYPE;
   BEGIN
      BEGIN
         SELECT cestrec
           INTO wcestadorec
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND smovrec = (SELECT MAX (smovrec)
                                                    FROM movrecibo
                                                   WHERE nrecibo = pnrecibo);
      EXCEPTION
         WHEN OTHERS
         THEN
            err := 104043;           -- Error al llegir de la taula MOVRECIBO
            p_tab_error
               (f_sysdate,
                f_user,
                'movrecibo',
                NULL,
                'par¿metros - pnrecibo: ' || pnrecibo,
                   'Error al recuperar ¿ltima situaci¿n de movrecibo - vnumerr: '
                || err
               );
            RETURN err;
      END;

      BEGIN
         SELECT cbancar
           INTO wcbancar
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            err := 102367;           -- Error al llegir de la taula MOVRECIBO
            p_tab_error
                  (f_sysdate,
                   f_user,
                   'movrecibo',
                   NULL,
                   'par¿metros - pnrecibo: ' || pnrecibo,
                      'Error al llegir dades de la taula recibos - vnumerr: '
                   || err
                  );
            RETURN err;
      END;

      IF wcestadorec = 1 AND wcbancar IS NOT NULL
      THEN
         BEGIN
            INSERT INTO devbananu
                        (nrecibo, fsistema, cuser, sproces
                        )
                 VALUES (pnrecibo, f_sysdate, f_user, NULL
                        );
         EXCEPTION
            WHEN OTHERS
            THEN
               err := 1;
               p_tab_error (f_sysdate,
                            f_user,
                            'devbananu',
                            NULL,
                            'par¿metros - pnrecibo: ' || pnrecibo,
                            'Error al inserir a la taula devbananu'
                           );
               RETURN err;
         END;
      ELSE
         IF wcestadorec <> 1
         THEN
            RETURN 110633;
         ELSIF wcbancar IS NULL
         THEN
            RETURN 140066;
         END IF;
      END IF;

      RETURN err;
   END f_anulacion_pendiente;

/*******************************************************************************
FUNCION F_VALIDA_COBRO
Funci¿n que valida si el recibo pertenece a la empresa: pempresa
   param in pempresa : empresa
   param in pnrecibo : recibo
   return: number indicando c¿digo de error (0: sin errores)
********************************************************************************/
   FUNCTION f_valida_cobro (pempresa IN NUMBER, pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      error      NUMBER                 := 0;
      xcempres   recibos.cempres%TYPE;
   BEGIN
      BEGIN
         SELECT cempres
           INTO xcempres
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            error := 100526;
         WHEN OTHERS
         THEN
            error := 102367;
      END;

      IF xcempres <> pempresa
      THEN
         error := 102873;
      END IF;

      RETURN error;
   END f_valida_cobro;

/*******************************************************************************
FUNCION F_IMPRESION_REGISTRO_MAN
Funci¿n que lanza los reports de agente.

Par¿metros:
  param in pcagente : Codigo agente
  param in pdataini : Fecha Inicio
  param in pdatafin : Fecha Fin
  param in pcidioma : Codigo idioma
  param out pfichero: ruta del fichero generado --BUg 9005-MCC-Creacion fichero
  return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
********************************************************************************/
   FUNCTION f_impresion_registro_man (
      pcagente    IN       NUMBER,
      pdataini    IN       DATE,
      pdatafin    IN       DATE,
      pcidioma    IN       NUMBER,
      pfichero1   OUT      VARCHAR2,
      pfichero2   OUT      VARCHAR2
   )   --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      RETURN NUMBER
   IS
      vpasexec        NUMBER                   := 1;
      vparam          VARCHAR2 (300)
         :=    'pcagente='
            || pcagente
            || ' pdataini='
            || pdataini
            || ' pdatafin='
            || pdatafin
            || ' pcidioma='
            || pcidioma;
      vobject         VARCHAR2 (200)
                                 := 'PAC_GESTION_REC.F_IMPRESION_REGISTRO_MAN';
      num             NUMBER;
      v_dir           VARCHAR2 (200);
      v_dir_url       VARCHAR2 (200);
      v_nomf1         VARCHAR2 (200);
      v_nomf2         VARCHAR2 (200);
      v_str           VARCHAR2 (4000);
      v_f1            UTL_FILE.file_type;
      v_f2            UTL_FILE.file_type;
      v_tsperson      tomadores.sperson%TYPE;
      --       v_tsperson     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_tcdomici      tomadores.cdomici%TYPE;
      --       v_tcdomici     NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_totimp        NUMBER;
      v_cabecera      VARCHAR2 (500);
      v_total_bill    NUMBER;
      v_total_comis   NUMBER;
      v_head          NUMBER;
      v_head2         NUMBER;
      v_head2_2       NUMBER;
      v_foot          NUMBER;
      verror          NUMBER;
      v_idiomacnt     NUMBER                   := 0;
      v_cidioma       personas.cidioma%TYPE;
      v_tipo          VARCHAR2 (5);

      FUNCTION f_prima_garantias (
         pcbasica   IN   NUMBER,
         pcramo     IN   NUMBER,
         pcmodali   IN   NUMBER,
         ctipseg    IN   NUMBER,
         pccolect   IN   NUMBER,
         pcactivi   IN   NUMBER,
         pnrecibo   IN   NUMBER
      )
         RETURN NUMBER
      IS
         v_prima   NUMBER;
      BEGIN
         SELECT NVL (SUM (d.iconcep), 0)
           INTO v_prima
           FROM garanpro g, detrecibos d
          WHERE g.cbasica = pcbasica
            AND d.nrecibo = pnrecibo
            AND g.cgarant = d.cgarant;

         RETURN v_prima;
      END f_prima_garantias;

      FUNCTION f_total_gastos (
         pcramo     IN   NUMBER,
         pcmodali   IN   NUMBER,
         ctipseg    IN   NUMBER,
         pccolect   IN   NUMBER,
         pcactivi   IN   NUMBER,
         pnrecibo   IN   NUMBER
      )
         RETURN NUMBER
      IS
         v_prima   NUMBER;
      BEGIN
         SELECT NVL (SUM (d.iconcep), 0)
           INTO v_prima
           FROM garanpro g, detrecibos d
          WHERE d.nrecibo = pnrecibo AND g.cgarant = d.cgarant
                AND d.cconcep = 8;

         RETURN v_prima;
      END f_total_gastos;

      FUNCTION f_comision (
         pcramo     IN   NUMBER,
         pcmodali   IN   NUMBER,
         ctipseg    IN   NUMBER,
         pccolect   IN   NUMBER,
         pcactivi   IN   NUMBER,
         pnrecibo   IN   NUMBER,
         pcconcep   IN   NUMBER
      )
         RETURN NUMBER
      IS
         v_prima   NUMBER;
      BEGIN
         SELECT NVL (SUM (d.iconcep), 0)
           INTO v_prima
           FROM garanpro g, detrecibos d
          WHERE d.nrecibo = pnrecibo
            AND g.cgarant = d.cgarant
            AND d.cconcep = pcconcep;

         RETURN v_prima;
      END f_comision;

      --Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT
      -- Bug 10787 - APD - 24/07/2009 - se sustituye el parametro de entra pcempres por pctipcob
      FUNCTION f_gestion (
         pctipcob   IN       NUMBER,
         pctiprec   IN       NUMBER,
         phead      OUT      NUMBER,
         phead2     OUT      NUMBER,
         pfoot      OUT      NUMBER,
         phead2_2   OUT      NUMBER
      )
         RETURN NUMBER
      IS
      BEGIN
         --El Brocker es APRA
         -- Bug 10787 - APD - 24/07/2009 - se sustituye el pcempres = 2 por pctipcob <> 4
         IF pctipcob <> 4
         THEN
            IF pctiprec = 3
            THEN
               phead := 9001012;
               phead2 := 9001014;
               pfoot := 9001019;
            ELSE
               phead := 9001013;
               phead2 := 9001016;
               phead2_2 := 9001014;
               pfoot := 9001019;
            END IF;
         END IF;

         --El Brocker no es APRA
         -- Bug 10787 - APD - 24/07/2009 - se sustituye el pcempres <> 2 por pctipcob = 4
         IF pctipcob = 4
         THEN
            IF pctiprec = 3
            THEN
               phead := 9001012;
               phead2 := 9001015;
               pfoot := 9001018;
            ELSE
               phead := 9001013;
               phead2 := 9001017;
               phead2_2 := 9001015;
               pfoot := 9001018;
            END IF;
         END IF;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            phead := NULL;
            phead2 := NULL;
            pfoot := NULL;
            RETURN 1;
      END f_gestion;
   --FIN Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT
   BEGIN
      -- Control parametros entrada
      IF pdataini IS NULL OR pcidioma IS NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      f_axis_literales (140974, pcidioma) || '  ' || vparam,
                      SQLERRM
                     );
         RETURN 140974;                       --Faltan parametros por informar
      END IF;

      -- Generar excel
      v_dir := f_parinstalacion_t ('INFORMES');
      v_dir_url := f_parinstalacion_t ('INFORMES_C');

      --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      FOR curidioma IN (SELECT DISTINCT a.sperson,
                                        NVL (p.cidioma, 2) AS idioma
                                   FROM seguros s,
                                        recibos r,
                                        agentes a,
                                        personas p
                                  WHERE a.cagente = pcagente
                                    AND r.cagente = pcagente
                                    AND r.sseguro = s.sseguro
                                    AND (   (r.fefecto BETWEEN pdataini
                                                           AND pdatafin
                                            )
                                         OR     pdatafin IS NULL
                                            AND TRUNC (r.fefecto) =
                                                              TRUNC (pdataini)
                                        )
                                    AND a.sperson = p.sperson)
      LOOP
         v_idiomacnt := v_idiomacnt + 1;
         v_cidioma := curidioma.idioma;
      END LOOP;

      IF v_idiomacnt > 1
      THEN
         v_nomf1 :=
               'impression_agente_'
            || NVL (TO_CHAR (pcagente), 'todos')
            || '_'
            || TO_CHAR (f_sysdate, 'ddmmyyyy')
            || '_NL'
            || '.csv';
         v_nomf2 :=
               'impression_agente_'
            || NVL (TO_CHAR (pcagente), 'todos')
            || '_'
            || TO_CHAR (f_sysdate, 'ddmmyyyy')
            || '_FR'
            || '.csv';
         --Fichero 1
         pfichero1 := v_dir_url || '\' || v_nomf1;
         v_f1 := UTL_FILE.fopen (v_dir, v_nomf1, 'w');
         --Fichero 2
         pfichero2 := v_dir_url || '\' || v_nomf2;
         v_f2 := UTL_FILE.fopen (v_dir, v_nomf2, 'w');
      ELSIF v_idiomacnt = 1
      THEN
         IF v_cidioma = 6
         THEN
            v_tipo := '_NL';
         ELSIF v_cidioma = 7
         THEN
            v_tipo := '_FR';
         ELSE
            v_tipo := NULL;
         END IF;

         v_nomf1 :=
               'impresion_agente_'
            || NVL (TO_CHAR (pcagente), 'todos')
            || '_'
            || TO_CHAR (f_sysdate, 'ddmmyyyy')
            || v_tipo
            || '.csv';
         pfichero1 := v_dir_url || '\' || v_nomf1;
         v_f1 := UTL_FILE.fopen (v_dir, v_nomf1, 'w');
      END IF;

      --Fin Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"

      /*IF pcidioma = 1 THEN
         v_nomf := 'impressio_agent_' || NVL(TO_CHAR(pcagente), 'tots') || '_'
                   || TO_CHAR(f_sysdate, 'ddmmyyyy') || '.csv';
      ELSE
         v_nomf := 'impresion_agente_' || NVL(TO_CHAR(pcagente), 'todos') || '_'
                   || TO_CHAR(f_sysdate, 'ddmmyyyy') || '.csv';
      END IF;

--'AGENT;NAME_AGE;DIR_AGE;POB_AGE;POLIS;NAME_HOLD;DIR_HOLD;POB_HOLD;PRODUCT;RECEIPT;EFECT;MADUR;BASICS;COMPLE;CHARGES;TAX;TOTAL_BILL;ADQUI;ENCAIS;TOTAL_COMIS;DATE;HEAD;HEAD2;FOOT;
      pfichero := v_dir_url || '\' || v_nomf;
      v_f := UTL_FILE.fopen(v_dir, v_nomf, 'w');*/
      --Bug 9005-MCC-Creacion fichero
/*      -- 100584 Agente    -- 105889 Direccion   -- 120118 Num.Poliza   -- 112553 Datos del Tomador
      -- 101027 Tomador   -- 100829 Producto    -- 103006 Recibo      -- 110460 Fecha de efecto
      -- 100885 Fecha vencimiento     -- 101368 Prima   -- 100903 Garant¿as
      -- 109084 Garant¿as Complementarias   -- 101709 Total Impuestos   -- 110766 Comision
      -- 102174 Cartera   -- 140699 fecha impresion
      v_cabecera := f_axis_literales(100584, pcidioma) || ';' || f_axis_literales(105889, pcidioma) || ' '
                    || f_axis_literales(100584, pcidioma) || ';';
      v_cabecera := v_cabecera || f_axis_literales(120118, pcidioma) || ';'
                    || f_axis_literales(105889, pcidioma) || ' ' || f_axis_literales(101027, pcidioma) || ';';
      v_cabecera := v_cabecera || f_axis_literales(100829, pcidioma) || ';'
                    || f_axis_literales(103006, pcidioma) || ';' || f_axis_literales(110460, pcidioma) || ';';
      v_cabecera := v_cabecera || f_axis_literales(100885, pcidioma) || ';';
      v_cabecera := v_cabecera || f_axis_literales(101368, pcidioma) || ' '
                    || f_axis_literales(100903, pcidioma) || ';';   --'Prima de las garant¿as principales;';
      v_cabecera := v_cabecera || f_axis_literales(101368, pcidioma) || ' '
                    || f_axis_literales(109084, pcidioma) || ';';   -- 'Prima de las garant¿as complementarias;';
      SELECT DECODE(pcidioma,
                    1, 'Suma de despeses;Suma d''impostos;',
                    'Suma de gastos;Suma de impuestos;')
        INTO v_str
        FROM DUAL;

      v_cabecera := v_cabecera || v_str;

      SELECT DECODE(pcidioma, 1, 'Comissi¿ d''aquisici¿;', 'Comisi¿n de adquisici¿n;')
        INTO v_str
        FROM DUAL;

      v_cabecera := v_cabecera || v_str;
      v_cabecera := v_cabecera || f_axis_literales(110766, pcidioma) || ' '
                    || f_axis_literales(102174, pcidioma) || ';';   --'Comisi¿n de cartera;';
      v_cabecera := v_cabecera || f_axis_literales(140699, pcidioma) || ' '
                    || f_axis_literales(103006, pcidioma);   --'Fecha de impresi¿n recibo';*/
      --FIN Bug 9005-MCC-Creacion fichero
      v_cabecera :=
         'AGENT;NAME_AGE;DIR_AGE;POB_AGE;POLIS;NAME_HOLD;DIR_HOLD;POB_HOLD;PRODUCT;RECEIPT;';
      v_cabecera :=
            v_cabecera
         || 'EFECT;MADUR;BASICS;COMPLE;CHARGES;TAX;TOTAL_BILL;ADQUI;ENCAIS;TOTAL_COMIS;DATE;HEAD;HEAD2;FOOT;';

      --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      --UTL_FILE.put_line(v_f, v_cabecera);
      IF v_idiomacnt > 1
      THEN
         UTL_FILE.put_line (v_f1, v_cabecera);
         --BUg 9005-MCC-11/03/2009-Cabecera
         UTL_FILE.put_line (v_f2, v_cabecera);
      ELSIF v_idiomacnt = 1
      THEN
         UTL_FILE.put_line (v_f1, v_cabecera);
      END IF;

      --Fin Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      IF pcagente IS NOT NULL
      THEN
         FOR cur IN (SELECT   a.cagente, a.sperson,
                              NVL (a.cdomici, 1) cdomici, s.sseguro,
                              s.npoliza npol, s.cramo, s.cmodali, s.ctipseg,
                              s.ccolect, s.cactivi, r.nrecibo, r.fefecto,
                              r.fvencim, r.femisio, r.ctiprec, r.cempres,
                              
                              --Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT
                              r.ctipcob
-- Bug 10787 - APD - 24/07/2009 -- se a¿ade el campo ctipcob necesario para la funcion f_gestion
                     FROM     seguros s, recibos r, agentes a
                        WHERE a.cagente = pcagente
                          AND r.cagente = pcagente
                          AND r.sseguro = s.sseguro
                          AND (   (r.fefecto BETWEEN pdataini AND pdatafin)
                               OR     pdatafin IS NULL
                                  AND TRUNC (r.fefecto) = TRUNC (pdataini)
                              )
                     ORDER BY s.npoliza)
         LOOP
            BEGIN
               SELECT sperson, cdomici
                 INTO v_tsperson, v_tcdomici
                 FROM tomadores
                WHERE sseguro = cur.sseguro AND nordtom = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            BEGIN
               SELECT NVL (itotimp, 0)
                 INTO v_totimp
                 FROM vdetrecibos
                WHERE nrecibo = cur.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            v_total_bill :=
                 f_prima_garantias (0,
                                    cur.cramo,
                                    cur.cmodali,
                                    cur.ctipseg,
                                    cur.ccolect,
                                    cur.cactivi,
                                    cur.nrecibo
                                   )
               + f_prima_garantias (1,
                                    cur.cramo,
                                    cur.cmodali,
                                    cur.ctipseg,
                                    cur.ccolect,
                                    cur.cactivi,
                                    cur.nrecibo
                                   )
               + f_total_gastos (cur.cramo,
                                 cur.cmodali,
                                 cur.ctipseg,
                                 cur.ccolect,
                                 cur.cactivi,
                                 cur.nrecibo
                                )
               + v_totimp;
            v_total_comis :=
                 f_comision (cur.cramo,
                             cur.cmodali,
                             cur.ctipseg,
                             cur.ccolect,
                             cur.cactivi,
                             cur.nrecibo,
                             11
                            )
               + f_comision (cur.cramo,
                             cur.cmodali,
                             cur.ctipseg,
                             cur.ccolect,
                             cur.cactivi,
                             cur.nrecibo,
                             17
                            );
            v_str :=
                  cur.cagente
               || ';'
               || f_nombre (cur.sperson, 1, cur.cagente)
               || ';'
               || f_adresa (cur.sperson, cur.cdomici)
               || ';'
               || f_poblac (cur.sperson, cur.cdomici)
               || ';'
               || cur.npol
               || ';'
               || f_nombre (v_tsperson, 1, cur.cagente)
               || ';'
               || f_adresa (v_tsperson, v_tcdomici)
               || ';'
               || f_poblac (v_tsperson, v_tcdomici)
               || ';'
               || f_desproducto_t (cur.cramo,
                                   cur.cmodali,
                                   cur.ctipseg,
                                   cur.ccolect,
                                   1,
                                   pcidioma
                                  )
               || ';'
               || cur.nrecibo
               || ';'
               || cur.fefecto
               || ';'
               || cur.fvencim
               || ';'
               || f_prima_garantias (0,
                                     cur.cramo,
                                     cur.cmodali,
                                     cur.ctipseg,
                                     cur.ccolect,
                                     cur.cactivi,
                                     cur.nrecibo
                                    )
               || ';'
               || f_prima_garantias (1,
                                     cur.cramo,
                                     cur.cmodali,
                                     cur.ctipseg,
                                     cur.ccolect,
                                     cur.cactivi,
                                     cur.nrecibo
                                    )
               || ';'
               || f_total_gastos (cur.cramo,
                                  cur.cmodali,
                                  cur.ctipseg,
                                  cur.ccolect,
                                  cur.cactivi,
                                  cur.nrecibo
                                 )
               || ';'
               || v_totimp
               || ';'
               || v_total_bill
               || ';'
               || f_comision (cur.cramo,
                              cur.cmodali,
                              cur.ctipseg,
                              cur.ccolect,
                              cur.cactivi,
                              cur.nrecibo,
                              11
                             )                         -- Comision adquisicion
               || ';'
               || f_comision (cur.cramo,
                              cur.cmodali,
                              cur.ctipseg,
                              cur.ccolect,
                              cur.cactivi,
                              cur.nrecibo,
                              17
                             )                             -- Comision cartera
               || ';'
               || v_total_comis
               || ';'
               || cur.femisio;
            --|| ';;;'; --Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT (COMENTADO)
            --Bug 9005-MCC-Obtener-HEAD / HEAD2 / FOOT
            verror :=
               f_gestion (cur.ctipcob,
                          cur.ctiprec,
                          v_head,
                          v_head2,
                          v_foot,
                          v_head2_2
                         );

            IF v_head2_2 IS NULL
            THEN
               v_str :=
                     v_str
                  || ';'
                  || f_axis_literales (v_head, pcidioma)
                  || ';'
                  || f_axis_literales (v_head2, pcidioma)
                  || ';'
                  || f_axis_literales (v_foot, pcidioma)
                  || ';;;';
            ELSE
               v_str :=
                     v_str
                  || ';'
                  || f_axis_literales (v_head, pcidioma)
                  || ';'
                  || f_axis_literales (v_head2, pcidioma)
                  || ' - '
                  || f_axis_literales (v_head2_2, pcidioma)
                  || ';'
                  || f_axis_literales (v_foot, pcidioma)
                  || ';;;';
            END IF;

            --FIN Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT

            --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
            --UTL_FILE.put_line(v_f, v_str);
            IF v_idiomacnt > 1
            THEN
               UTL_FILE.put_line (v_f1, v_str);
               UTL_FILE.put_line (v_f2, v_str);
            ELSIF v_idiomacnt = 1
            THEN
               UTL_FILE.put_line (v_f1, v_str);
            END IF;
         --Fin Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
         END LOOP;
      ELSE
         FOR cur IN (SELECT   a.cagente, a.sperson,
                              NVL (a.cdomici, 1) cdomici, s.sseguro,
                              s.npoliza npol, s.cramo, s.cmodali, s.ctipseg,
                              s.ccolect, s.cactivi, r.nrecibo, r.fefecto,
                              r.fvencim, r.femisio, r.ctiprec, r.cempres,
                              
                              --Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT
                              r.ctipcob
-- Bug 10787 - APD - 24/07/2009 -- se a¿ade el campo ctipcob necesario para la funcion f_gestion
                     FROM     seguros s, recibos r, agentes a
                        WHERE a.cagente = r.cagente
                          AND                              --a.cagente = 1 AND
                              r.sseguro = s.sseguro
                          AND (   (r.fefecto BETWEEN pdataini AND pdatafin)
                               OR     pdatafin IS NULL
                                  AND TRUNC (r.fefecto) = TRUNC (pdataini)
                              )
                     ORDER BY a.cagente)
         LOOP
            BEGIN
               SELECT sperson, cdomici
                 INTO v_tsperson, v_tcdomici
                 FROM tomadores
                WHERE sseguro = cur.sseguro AND nordtom = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            BEGIN
               SELECT NVL (itotimp, 0)
                 INTO v_totimp
                 FROM vdetrecibos
                WHERE nrecibo = cur.nrecibo;
            EXCEPTION
               WHEN OTHERS
               THEN
                  NULL;
            END;

            v_total_bill :=
                 f_prima_garantias (0,
                                    cur.cramo,
                                    cur.cmodali,
                                    cur.ctipseg,
                                    cur.ccolect,
                                    cur.cactivi,
                                    cur.nrecibo
                                   )
               + f_prima_garantias (1,
                                    cur.cramo,
                                    cur.cmodali,
                                    cur.ctipseg,
                                    cur.ccolect,
                                    cur.cactivi,
                                    cur.nrecibo
                                   )
               + f_total_gastos (cur.cramo,
                                 cur.cmodali,
                                 cur.ctipseg,
                                 cur.ccolect,
                                 cur.cactivi,
                                 cur.nrecibo
                                )
               + v_totimp;
            v_total_comis :=
                 f_comision (cur.cramo,
                             cur.cmodali,
                             cur.ctipseg,
                             cur.ccolect,
                             cur.cactivi,
                             cur.nrecibo,
                             11
                            )
               + f_comision (cur.cramo,
                             cur.cmodali,
                             cur.ctipseg,
                             cur.ccolect,
                             cur.cactivi,
                             cur.nrecibo,
                             17
                            );
            v_str :=
                  cur.cagente
               || ';'
               || f_nombre (cur.sperson, 1, cur.cagente)
               || ';'
               || f_adresa (cur.sperson, cur.cdomici)
               || ';'
               || f_poblac (cur.sperson, cur.cdomici)
               || ';'
               || cur.npol
               || ';'
               || f_nombre (v_tsperson, 1, cur.cagente)
               || ';'
               || f_adresa (v_tsperson, v_tcdomici)
               || ';'
               || f_poblac (v_tsperson, v_tcdomici)
               || ';'
               || f_desproducto_t (cur.cramo,
                                   cur.cmodali,
                                   cur.ctipseg,
                                   cur.ccolect,
                                   1,
                                   pcidioma
                                  )
               || ';'
               || cur.nrecibo
               || ';'
               || cur.fefecto
               || ';'
               || cur.fvencim
               || ';'
               || f_prima_garantias (0,
                                     cur.cramo,
                                     cur.cmodali,
                                     cur.ctipseg,
                                     cur.ccolect,
                                     cur.cactivi,
                                     cur.nrecibo
                                    )
               || ';'
               || f_prima_garantias (1,
                                     cur.cramo,
                                     cur.cmodali,
                                     cur.ctipseg,
                                     cur.ccolect,
                                     cur.cactivi,
                                     cur.nrecibo
                                    )
               || ';'
               || f_total_gastos (cur.cramo,
                                  cur.cmodali,
                                  cur.ctipseg,
                                  cur.ccolect,
                                  cur.cactivi,
                                  cur.nrecibo
                                 )
               || ';'
               || v_totimp
               || ';'
               || v_total_bill
               || ';'
               || f_comision (cur.cramo,
                              cur.cmodali,
                              cur.ctipseg,
                              cur.ccolect,
                              cur.cactivi,
                              cur.nrecibo,
                              11
                             )                         -- Comision adquisicion
               || ';'
               || f_comision (cur.cramo,
                              cur.cmodali,
                              cur.ctipseg,
                              cur.ccolect,
                              cur.cactivi,
                              cur.nrecibo,
                              17
                             )                             -- Comision cartera
               || ';'
               || v_total_comis
               || ';'
               || cur.femisio;
             --|| ';;;';--Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT (COMENTADO)
            --Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT
            verror :=
               f_gestion (cur.ctipcob,
                          cur.ctiprec,
                          v_head,
                          v_head2,
                          v_foot,
                          v_head2_2
                         );

            --v_str := v_str || ';' || f_axis_literales(v_head, pcidioma) || ';' || f_axis_literales(v_head2, pcidioma) || ';' || f_axis_literales(v_foot, pcidioma)|| ';;;';
            IF v_head2_2 IS NULL
            THEN
               v_str :=
                     v_str
                  || ';'
                  || f_axis_literales (v_head, pcidioma)
                  || ';'
                  || f_axis_literales (v_head2, pcidioma)
                  || ';'
                  || f_axis_literales (v_foot, pcidioma)
                  || ';;;';
            ELSE
               v_str :=
                     v_str
                  || ';'
                  || f_axis_literales (v_head, pcidioma)
                  || ';'
                  || f_axis_literales (v_head2, pcidioma)
                  || ' - '
                  || f_axis_literales (v_head2_2, pcidioma)
                  || ';'
                  || f_axis_literales (v_foot, pcidioma)
                  || ';;;';
            END IF;

            --FIN Bug 9005-MCC-Obtener HEAD / HEAD2 / FOOT

            --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
            --UTL_FILE.put_line(v_f, v_str);
            IF v_idiomacnt > 1
            THEN
               UTL_FILE.put_line (v_f1, v_str);
               UTL_FILE.put_line (v_f2, v_str);
            ELSIF v_idiomacnt = 1
            THEN
               UTL_FILE.put_line (v_f1, v_str);
            END IF;
         --Fin Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
         END LOOP;
      END IF;

      --Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"
      --UTL_FILE.fclose(v_f);
      IF v_idiomacnt > 1
      THEN
         UTL_FILE.fclose (v_f1);
         UTL_FILE.fclose (v_f2);
      ELSIF v_idiomacnt = 1
      THEN
         UTL_FILE.fclose (v_f1);
      END IF;

      --Fin Bug 9005 -01/03/2009- MCC- Apertura de ficheros para "NL" y para "FR"

      --Retorna un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF UTL_FILE.is_open (v_f1)
         THEN
            UTL_FILE.fclose (v_f1);
         END IF;

         IF UTL_FILE.is_open (v_f2)
         THEN
            UTL_FILE.fclose (v_f2);
         END IF;

         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN SQLCODE;
   END f_impresion_registro_man;

/*******************************************************************************
FUNCION F_AGRUPARECIBO
Funci¿n que realiza la unificaci¿n de recibos. Tiene dos modalidades de ejecuci¿n:
 1.- Agrupa los recibos de cartera anterior a la fecha pasada por par¿metro.
 2.- Agrupa los recibos pasados en la colecci¿n T_LISTA_ID.

Par¿metros:
  param in psproduc  : Codigo de producto
  param in pfecha    : Fecha de limite
  param in pfemisio  : Fecha de emisi¿n de la unificaci¿n
  param in pcempres  : C¿digo de empresa
  param in plistarec : Colecci¿n de recibos
  return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
********************************************************************************/
-- Bug 9383 - 06/03/2009 - RSC -CRE: Unificaci¿n de recibos
   /*******************************************************************************
FUNCION F_AGRUPARECIBO
Funci¿n que realiza la unificaci¿n de recibos. Tiene dos modalidades de ejecuci¿n:
 1.- Agrupa los recibos de cartera anterior a la fecha pasada por par¿metro.
 2.- Agrupa los recibos pasados en la colecci¿n T_LISTA_ID.

Par¿metros:
  param in psproduc  : Codigo de producto
  param in pfecha    : Fecha de limite
  param in pfemisio  : Fecha de emisi¿n de la unificaci¿n
  param in pcempres  : C¿digo de empresa
  param in plistarec : Colecci¿n de recibos
  return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
********************************************************************************/
-- Bug 9383 - 06/03/2009 - RSC -CRE: Unificaci¿n de recibos
   FUNCTION f_agruparecibo (
      psproduc         IN   NUMBER,
      pfecha           IN   DATE,
      pfemisio         IN   DATE,
      pcempres         IN   NUMBER,
      plistarec        IN   t_lista_id DEFAULT NULL,
      pctiprec         IN   NUMBER DEFAULT 3,
      pextornn         IN   NUMBER DEFAULT 0,
      pcommitpag       IN   NUMBER DEFAULT 1,
      pctipapor        IN   NUMBER DEFAULT NULL,
      pctipaportante   IN   NUMBER DEFAULT NULL
   )
--Bug.: 15708 - ICV - 08/06/2011 - Se a¿ade el tipo de recibo para poder agrupar recibos que no sean de cartera)
   RETURN NUMBER
   IS
      pnrecibo             recibos_comp.nrecibo%TYPE;
      --       pnrecibo       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vpfecha              DATE;

      TYPE assoc_array_recunif IS TABLE OF NUMBER
         INDEX BY VARCHAR2 (200);

      vrecunif             assoc_array_recunif;
      vnpoliza             NUMBER;
      num_err              NUMBER;
      vsseguro             recibos.sseguro%TYPE;
      --       vsseguro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcagente             seguros.cagente%TYPE;
      --       vcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccobban             seguros.ccobban%TYPE;
      --       vccobban       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcbancar             seguros.cbancar%TYPE;
--       vcbancar       VARCHAR2(34); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vctiprec             NUMBER;
      vnmovimi             recibos.nmovimi%TYPE;
      --       vnmovimi       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcestimp             recibos.cestimp%TYPE;
      --       vcestimp       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vfvencim             DATE;
      vfefecto             DATE;
      vtraza               NUMBER;
      -- Modalidad pasando un listado de recibos
      vrecibos             VARCHAR2 (8000);
      v_sel                VARCHAR2 (8000);
      v_sproduc            VARCHAR2 (20);
      --
      vfemisio             DATE;
      -- BUG22839:DRA:05/11/2012:Inici
      vnrecibo             recibos.nrecibo%TYPE;
      vcempres             recibos.cempres%TYPE;
      pcestrec             movrecibo.cestrec%TYPE;
      xcestrec             movrecibo.cestant%TYPE;
      -- ini BUG 0026035 - 12/02/2013 - JMF
      d_eferec             recibos.fefecto%TYPE;
      d_emirec             recibos.femisio%TYPE;
      n_movrec             movrecibo.smovrec%TYPE;
      d_fmovim             recibos.fefecto%TYPE;
      v_obj                VARCHAR2 (500) := 'pac_gestion_rec.f_agruparecibo';
      v_par                VARCHAR2 (500)
         :=    'pro='
            || psproduc
            || ' fec='
            || pfecha
            || ' emi='
            || pfemisio
            || ' emp='
            || pcempres
            || ' tip='
            || pctiprec;
      -- fin BUG 0026035 - 12/02/2013 - JMF
      v_signo              NUMBER;             -- Bug 26022 - APD - 18/02/2013
      v_cestrec            movrecibo.cestrec%TYPE;
      -- Bug 26022 - APD - 18/02/2013
      v_fmovdia            movrecibo.fmovdia%TYPE;
      -- Bug 26022 - APD - 18/02/2013
      v_sperson            recibos.sperson%TYPE;
      v_grabasperson       NUMBER (1)                  := 0;

      -- BUG22839:DRA:05/11/2012:Fi
      TYPE t_cursor IS REF CURSOR;

      c_rebuts             t_cursor;
      /*TYPE registre IS RECORD(
         npoliza        seguros.npoliza%TYPE,
         nrecibo        recibos.nrecibo%TYPE,
         iprinet        vdetrecibos.iprinet%TYPE,
         itotalr        vdetrecibos.itotalr%TYPE,
         icomcia        vdetrecibos.icomcia%TYPE,
         itotimp        vdetrecibos.icomcia%TYPE,
         itotcon        vdetrecibos.itotcon%TYPE,
         sperson        recibos.sperson%TYPE,
         nrecunif       adm_recunif.nrecunif%TYPE
      );

      rec            registre;*/
      v_polpol             seguros.npoliza%TYPE;
      v_perper             recibos.sperson%TYPE;
      v_uniuni             adm_recunif.nrecunif%TYPE;
      v_recrec             recibos.nrecibo%TYPE;
      v_nrec_dif_unifrec   NUMBER;
      v_agr_max_fechas     NUMBER;
      v_pneta              NUMBER;           -- BUG 0038217 - FAL - 30/11/2015

------------------------------------------
      CURSOR c_recunif (csproduc NUMBER, ppfecha DATE)
      IS
         SELECT s.npoliza, r.*, v.iprinet, v.itotalr, v.icomcia, v.itotimp,
                v.itotcon
           FROM recibos r, seguros s, vdetrecibos v
          WHERE r.ctiprec = pctiprec
            AND r.cestaux = 2  -- Los de cartera de productos colectivos con
                               -- certificados se deber¿n crear en este estado
            AND r.fefecto <= ppfecha
            AND r.sseguro = s.sseguro
            AND r.ctipapor = NVL (pctipapor, r.ctipapor)
            AND s.sproduc = csproduc
            AND r.esccero = 1                             -- del certificado 0
            AND r.nrecibo = v.nrecibo
            AND NVL (f_cestrec (r.nrecibo, NULL), 0) = 0
            -- que no esten cobrados
            AND r.nrecibo NOT IN (SELECT nrecibo
                                    FROM adm_recunif);

      --BUG 14438 - JTS - 12/05/2010
      CURSOR c_detrecibo (ppnrecibo NUMBER)
      IS
         SELECT   d.nrecibo, d.cconcep, d.cgarant, d.nriesgo,
                  SUM (DECODE (pctiprec,
                               9, d.iconcep,
                               13, d.iconcep,
                               DECODE (r.ctiprec,
                                       9, (-1) * d.iconcep,
                                       d.iconcep
                                      )
                              )
                      ) iconcep
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = ppnrecibo AND r.nrecibo = d.nrecibo
         GROUP BY d.nrecibo, d.cconcep, d.cgarant, d.nriesgo;

      CURSOR c_detrecibo_neg (ppnrecibo NUMBER)
      IS
         SELECT   d.nrecibo, d.cconcep, d.cgarant, d.nriesgo,
                  SUM (DECODE (r.ctiprec, 9, (-1) * d.iconcep, d.iconcep)
                      ) iconcep
             FROM detrecibos d, recibos r
            WHERE d.nrecibo = ppnrecibo AND r.nrecibo = d.nrecibo
         GROUP BY d.nrecibo, d.cconcep, d.cgarant, d.nriesgo;
   BEGIN
      vpfecha := NVL (pfecha, f_sysdate);
      vfemisio := NVL (pfemisio, f_sysdate);
      v_nrec_dif_unifrec :=
         NVL (pac_parametros.f_parempresa_n (pcempres, 'NREC_DIF_UNIFREC'),
              0);
      v_agr_max_fechas :=
                       NVL (f_parproductos_v (psproduc, 'AGR_MAX_FECHAS'), 0);

      IF plistarec IS NULL
      THEN
         vtraza := 1;

         FOR regs IN c_recunif (psproduc, vpfecha)
         LOOP
            IF vrecunif.EXISTS (regs.npoliza)
            THEN
               vtraza := 2;

               -- Insertamos en tabla de detalle de agrupaci¿n
               INSERT INTO adm_recunif
                           (nrecibo, nrecunif
                           )
                    VALUES (regs.nrecibo, vrecunif (regs.npoliza)
                           );
            ELSE
               vtraza := 3;

               -- Obtenemos numero de recibo que agrupa los recibos
               -- peque¿itos
               -- BUG18054:DRA:23/03/2011:Inici
               IF v_nrec_dif_unifrec = 0
               THEN
                  pnrecibo := pac_adm.f_get_seq_cont (pcempres);
               ELSE
                  pnrecibo := pac_adm.f_get_seq_cont (NULL);
               END IF;

               -- BUG18054:DRA:23/03/2011:Fi
               vrecunif (regs.npoliza) := pnrecibo;

               -- Insertamos en tabla de detalle de agrupaci¿n
               INSERT INTO adm_recunif
                           (nrecibo, nrecunif
                           )
                    VALUES (regs.nrecibo, vrecunif (regs.npoliza)
                           );
            END IF;
         END LOOP;
      ELSE
         vtraza := 4;

         FOR reg IN plistarec.FIRST .. plistarec.LAST
         LOOP
            SELECT s.npoliza, r.sperson, a.nrecunif, r.nrecibo
              INTO v_polpol, v_perper, v_uniuni, v_recrec
              FROM recibos r, seguros s, vdetrecibos v, adm_recunif a
             WHERE r.nrecibo = plistarec (reg).idd
               AND r.sseguro = s.sseguro
               AND r.nrecibo = v.nrecibo
               AND r.nrecibo = a.nrecibo(+);

            IF v_uniuni IS NULL
            THEN
               --miramos si los recibos son de la misma persona, caso retornos
               IF v_sperson IS NOT NULL
               THEN
                  IF v_perper IS NULL OR v_sperson <> v_perper
                  THEN
                     v_grabasperson := 1;
                  END IF;
               ELSIF v_grabasperson = 0
               THEN
                  v_sperson := v_perper;
               END IF;

               IF vrecunif.EXISTS (v_polpol)
               THEN
                  vtraza := 9;

                  -- Insertamos en tabla de detalle de agrupaci¿n
                  INSERT INTO adm_recunif
                              (nrecibo, nrecunif
                              )
                       VALUES (v_recrec, vrecunif (v_polpol)
                              );
               ELSE
                  vtraza := 10;

                  -- Obtenemos numero de recibo que agrupa los recibos
                  -- peque¿itos
                  -- BUG18054:DRA:23/03/2011:Inici
                  IF v_nrec_dif_unifrec = 0
                  THEN
                     pnrecibo := pac_adm.f_get_seq_cont (pcempres);
                  ELSE
                     pnrecibo := pac_adm.f_get_seq_cont (NULL);
                  END IF;

                  vtraza := 11;
                  -- BUG18054:DRA:23/03/2011:Fi
                  vrecunif (v_polpol) := pnrecibo;

                  -- Insertamos en tabla de detalle de agrupaci¿n
                  INSERT INTO adm_recunif
                              (nrecibo, nrecunif
                              )
                       VALUES (v_recrec, vrecunif (v_polpol)
                              );
               END IF;
            END IF;
         END LOOP;
      END IF;

      vtraza := 12;
      -- Aqui debemos insertar el recibo 'grande' con el total de los recibos peque¿itos.
      vnpoliza := vrecunif.FIRST;

      LOOP
         EXIT WHEN vnpoliza IS NULL;
         vtraza := 13;
         vctiprec := pctiprec;

         IF NVL
               (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                               'CRITERIO_UNIFREC'
                                              ),
                0
               ) = 1
         THEN                                -- BUG 0038346 - FAL - 03/11/2015
            SELECT sseguro, cagente, ccobban, cbancar
              INTO vsseguro, vcagente, vccobban, vcbancar
              FROM seguros
             WHERE npoliza = vnpoliza
               AND sseguro =
                      (SELECT DISTINCT sseguro
                                  FROM recibos
                                 WHERE nrecibo IN (
                                          SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif =
                                                           vrecunif (vnpoliza)));
         ELSE
            SELECT sseguro, cagente, ccobban, cbancar
              INTO vsseguro, vcagente, vccobban, vcbancar
              FROM seguros
             WHERE npoliza = vnpoliza AND ncertif = 0;
         END IF;

         vtraza := 14;

         -- No se genera movimiento de seguro. Se busca
         -- el ¿ltimo movimiento vigente
         --num_err := f_buscanmovimi(vsseguro, 1, 2, vnmovimi);
         -- Bug 10613 - 06/07/2009 - RSC - Ajustes en productos de Salud
         -- ¿ltimo movimiento del certificado
         SELECT MAX (nmovimi)
           INTO vnmovimi
           FROM movseguro
          WHERE sseguro = vsseguro;

         -- Fin Bug 10613
         vtraza := 15;

         IF plistarec IS NULL
         THEN
            vtraza := 16;

            IF v_agr_max_fechas = 1
            THEN
               SELECT MAX (r2.fefecto), MAX (r2.femisio), MAX (r2.fvencim)
                 INTO vfefecto, vfemisio, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN (
                         SELECT r.nrecibo
                           FROM recibos r, seguros s, vdetrecibos v
                          WHERE r.cestaux = 2
                            AND r.fefecto <= vpfecha
                            AND r.sseguro = s.sseguro
                            -- AND s.sproduc = psproduc
                            AND r.esccero = 1
                            AND r.nrecibo = v.nrecibo
                            AND s.npoliza = vnpoliza
                            AND r.nrecibo IN (
                                          SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif =
                                                           vrecunif (vnpoliza)));
            ELSE
               SELECT MIN (r2.fefecto), MAX (r2.fvencim)
                 INTO vfefecto, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN (
                         SELECT r.nrecibo
                           FROM recibos r, seguros s, vdetrecibos v
                          WHERE r.cestaux = 2
                            AND r.fefecto <= vpfecha
                            AND r.sseguro = s.sseguro
                            -- AND s.sproduc = psproduc
                            AND r.esccero = 1
                            AND r.nrecibo = v.nrecibo
                            AND s.npoliza = vnpoliza
                            AND r.nrecibo IN (
                                          SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif =
                                                           vrecunif (vnpoliza)));
            END IF;
         ELSE
            vtraza := 18;

            -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrizaci¿n b¿sica producto Vida Individual Pagos Permanentes
            -- Borramos: AND r.esccero = 1 (no lo creemos necesarios en esta modalidad de ejecuci¿n)
            IF v_agr_max_fechas = 1
            THEN
               SELECT MAX (r2.fefecto), MAX (r2.femisio), MAX (r2.fvencim)
                 INTO vfefecto, vfemisio, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN (
                         SELECT r.nrecibo
                           FROM recibos r, seguros s, vdetrecibos v
                          WHERE r.sseguro = s.sseguro
                            --AND r.cestaux = 2 -- 22. 0022763 Unificacion / Desunificacion de recibos - 0119028
                            --AND r.esccero = 1 -- Bug 19096 - RSC - 03/08/2011
                            AND r.nrecibo = v.nrecibo
                            AND s.npoliza = vnpoliza
                            AND r.nrecibo IN (
                                          SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif =
                                                           vrecunif (vnpoliza)));
            ELSE
               SELECT MIN (r2.fefecto), MAX (r2.fvencim)
                 INTO vfefecto, vfvencim
                 FROM recibos r2
                WHERE r2.nrecibo IN (
                         SELECT r.nrecibo
                           FROM recibos r, seguros s, vdetrecibos v
                          WHERE r.sseguro = s.sseguro
                            --AND r.cestaux = 2 -- 22. 0022763 Unificacion / Desunificacion de recibos - 0119028
                            --AND r.esccero = 1 -- Bug 19096 - RSC - 03/08/2011
                            AND r.nrecibo = v.nrecibo
                            AND s.npoliza = vnpoliza
                            AND r.nrecibo IN (
                                          SELECT nrecibo
                                            FROM adm_recunif
                                           WHERE nrecunif =
                                                           vrecunif (vnpoliza)));
            END IF;

            vtraza := 19;
         END IF;

         vtraza := 20;

         IF vcbancar IS NOT NULL AND vccobban IS NOT NULL
         THEN                                       -- BUG22839:DRA:05/11/2012
            vcestimp := 4;
         ELSE
            vcestimp := 1;
         END IF;

         vtraza := 21;

         -- Insertamos el nuevo recibo 'grande'

         -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrizaci¿n b¿sica producto Vida Individual Pagos Permanentes
         -- IF plistarec IS NULL THEN -- 22. 0022763 / 0119028 - (segun DRA)
            -- Fin 19096
         IF NVL
               (pac_parametros.f_parempresa_n (pac_md_common.f_get_cxtempresa,
                                               'CRITERIO_UNIFREC'
                                              ),
                0
               ) = 1
         THEN                                -- BUG 0038346 - FAL - 03/11/2015
            num_err :=
               f_insrecibo (vsseguro,
                            vcagente,
                            vfemisio,
                            vfefecto,
                            vfvencim,
                            vctiprec,
                            NULL,
                            NULL,
                            vccobban,
                            vcestimp,
                            1,
                            vrecunif (vnpoliza),
                            'R',
                            NULL,
                            NULL,
                            vnmovimi,
                            TRUNC (f_sysdate),
                            NULL
                           );
         ELSE
            num_err :=
               f_insrecibo (vsseguro,
                            vcagente,
                            vfemisio,
                            vfefecto,
                            vfvencim,
                            vctiprec,
                            NULL,
                            NULL,
                            vccobban,
                            vcestimp,
                            1,
                            vrecunif (vnpoliza),
                            'R',
                            NULL,
                            NULL,
                            vnmovimi,
                            TRUNC (f_sysdate),
                            'CERTIF0'
                           );
         END IF;

         vtraza := 22;

         IF num_err <> 0
         THEN
            RETURN num_err;
         ELSE
            IF v_grabasperson = 0
            THEN
               UPDATE recibos
                  SET sperson = v_sperson
                WHERE nrecibo = vrecunif (vnpoliza);
            END IF;
         END IF;

         -- Fin 19096
         IF num_err <> 0
         THEN
            RETURN num_err;
         ELSE
            vtraza := 23;

            BEGIN
               -- Pomes CESTAUX = 0 ya que el recibo grande si queremos procesarlo
               UPDATE recibos
                  SET cestaux = 0,
                      -- cestimp = vcestimp,
                      cmanual = 1,
                      cbancar = vcbancar,
                      ccobban = vccobban,
                      ctipapor = NVL (pctipapor, ctipapor),
                      ctipaportante = NVL (pctipaportante, ctipaportante)
                WHERE nrecibo = vrecunif (vnpoliza);
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN 102358;
            END;

            vtraza := 24;

            -- Obtenemos los recibos peque¿itos de una p¿liza
            -- (por si tenemos que hacer algo con ellos)
            IF plistarec IS NULL
            THEN
               vtraza := 25;

               FOR regs IN (SELECT   d.cconcep, d.nriesgo, d.cgarant,
                                     SUM (DECODE (pctiprec,
                                                  9, DECODE (r.ctiprec,
                                                             9, d.iconcep,
                                                             (-1
                                                             ) * d.iconcep
                                                            ),
                                                  13, DECODE (r.ctiprec,
                                                              13, d.iconcep,
                                                              (-1
                                                              ) * d.iconcep
                                                             ),
                                                  DECODE (r.ctiprec,
                                                          9, (-1) * d.iconcep,
                                                          d.iconcep
                                                         )
                                                 )
                                         ) iconcep
                                FROM adm_recunif a, recibos r, detrecibos d
                               WHERE a.nrecunif = vrecunif (vnpoliza)
                                 AND a.nrecibo = r.nrecibo
                                 AND a.nrecibo = d.nrecibo
                                 AND r.esccero = 1
                                 AND r.fefecto <= vpfecha
                            GROUP BY d.cconcep, d.nriesgo, d.cgarant)
               LOOP
                  INSERT INTO detrecibos
                              (nrecibo, cconcep,
                               cgarant, nriesgo, iconcep
                              )
                       VALUES (vrecunif (vnpoliza), regs.cconcep,
                               regs.cgarant, regs.nriesgo, regs.iconcep
                              );
               END LOOP;
                  -- BUG 26488_0143335 - JLTS - 25/04/2013 - ini
            --UPDATE detrecibos
            --SET iconcep = ABS(iconcep)
            --WHERE nrecibo = vrecunif(vnpoliza);
               -- BUG 26488_0143335 - JLTS - 25/04/2013 - fin
            ELSE
               vtraza := 26;

               --En los recibos de extorno los conceptos negativos son a cobrar (positivos) y los conceptos positivos son a pagar.
               --En los recibos a cobrar, los conceptos negativos son a pagar (extornos) y los conceptos positivos son a cobrar.
               FOR regs IN (SELECT   d.cconcep, d.nriesgo, d.cgarant,
                                     SUM (DECODE (pctiprec,
                                                  9, DECODE (r.ctiprec,
                                                             9, d.iconcep,
                                                             (-1
                                                             ) * d.iconcep
                                                            ),
                                                  13, DECODE (r.ctiprec,
                                                              13, d.iconcep,
                                                              (-1
                                                              ) * d.iconcep
                                                             ),
                                                  DECODE (r.ctiprec,
                                                          9, (-1) * d.iconcep,
                                                          d.iconcep
                                                         )
                                                 )
                                         ) iconcep
                                FROM adm_recunif a, recibos r, detrecibos d
                               WHERE a.nrecunif = vrecunif (vnpoliza)
                                 AND a.nrecibo = r.nrecibo
                                 AND a.nrecibo = d.nrecibo
                            GROUP BY d.cconcep, d.nriesgo, d.cgarant)
               LOOP
                  INSERT INTO detrecibos
                              (nrecibo, cconcep,
                               cgarant, nriesgo, iconcep
                              )
                       VALUES (vrecunif (vnpoliza), regs.cconcep,
                               regs.cgarant, regs.nriesgo, regs.iconcep
                              );
               END LOOP;
                  -- BUG 26488_0143335 - JLTS - 25/04/2013 - ini
            --UPDATE detrecibos
            --SET iconcep = ABS(iconcep)
            --WHERE nrecibo = vrecunif(vnpoliza);
               -- BUG 26488_0143335 - JLTS - 25/04/2013 - fin
            END IF;

            -- BUG 0038217 - FAL - 30/11/2015 - Si el recibo agrupador es negativo (sea porque agrupa extornos, ...) invertir signo de los importes del detalle del recibo y ponerlo como de tipo extorno
            BEGIN
               SELECT SUM (iconcep)
                 INTO v_pneta
                 FROM detrecibos
                WHERE nrecibo = vrecunif (vnpoliza) AND cconcep = 0;
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_pneta := 0;
            END;

            IF v_pneta < 0
            THEN
               UPDATE detrecibos
                  SET iconcep = iconcep * (-1)
                WHERE nrecibo = vrecunif (vnpoliza);

               UPDATE recibos
                  SET ctiprec = 9
                WHERE nrecibo = vrecunif (vnpoliza);
            END IF;

            -- FI BUG 0038217
            vtraza := 27;
            num_err := f_vdetrecibos ('R', vrecunif (vnpoliza));

            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- 37.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Inicio

            -- Cambiamos la manera de hacer el reparto de corretaje. Llamamos directamente a PAC_CORRETAJE.F_REPARTO_CORRETAJE

            -- 38.0 - 03/04/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Inicio
            IF pac_corretaje.f_tiene_corretaje (vsseguro, NULL) = 1
            THEN
               num_err :=
                  pac_corretaje.f_reparto_corretaje (vsseguro,
                                                     vnmovimi,
                                                     vrecunif (vnpoliza)
                                                    );
            END IF;

            -- 38.0 - 03/04/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion en polizas... Fin
            IF num_err <> 0
            THEN
               RETURN num_err;
            END IF;

            -- Bug 26022 - APD - 18/02/2013 - Liquidaciones de Colectivos
            -- Cuando se genera el recibo agrupado se ha de informar la COMRECIBO con la suma de los conceptos
            -- de cada uno de los recibos de los n-certificados para que la liquidaci¿n, ya que se liquida a
            -- nivel de recibo agrupado, pueda tener informada la COMRECIBO
            /*IF pac_corretaje.f_tiene_corretaje(vsseguro, NULL) = 1 THEN
               FOR reg IN (SELECT   a.cagente, c.cgarant, SUM(c.icombru) icombru,
                                    SUM(c.icomret) icomret, SUM(c.icomdev) icomdev,
                                    SUM(c.iretdev) iretdev
                               FROM recibos r, age_corretaje a, comrecibo c
                              WHERE a.sseguro = r.sseguro
                                AND a.nmovimi = (SELECT MAX(a1.nmovimi)
                                                   FROM age_corretaje a1
                                                  WHERE a1.sseguro = a.sseguro
                                                    AND a1.cagente = a.cagente)
                                AND c.nrecibo = r.nrecibo
                                AND c.cagente = a.cagente
                                AND r.cestaux = 2
                                AND r.nrecibo IN(SELECT nrecibo
                                                   FROM adm_recunif
                                                  WHERE nrecunif = vrecunif(vnpoliza))
                           GROUP BY a.cagente, c.cgarant) LOOP
                  IF vctiprec = 9 THEN
                     v_signo := -1;
                  ELSE
                     v_signo := 1;
                  END IF;

                  SELECT m.cestrec, m.fmovdia
                    INTO v_cestrec, v_fmovdia
                    FROM movrecibo m
                   WHERE m.nrecibo = vrecunif(vnpoliza)
                     AND m.smovrec = (SELECT MAX(m1.smovrec)
                                        FROM movrecibo m1
                                       WHERE m1.nrecibo = m.nrecibo);

                  num_err := pac_comisiones.f_alt_comisionrec(vrecunif(vnpoliza), v_cestrec,
                                                              v_fmovdia, reg.icombru * v_signo,
                                                              reg.icomret * v_signo,
                                                              reg.icomdev * v_signo,
                                                              reg.iretdev * v_signo,
                                                              reg.cagente, reg.cgarant);

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END LOOP;
            END IF;*/
            -- 37.0 - 27/03/2014 - MMM - 0030713: LCOL_F002-0011957-11958-11959: Se realizo anulacion... Fin

            -- fin Bug 26022 - APD - 18/02/2013 - Liquidaciones de Colectivos

            -- Siguiente p¿liza
            vnpoliza := vrecunif.NEXT (vnpoliza);
         END IF;
      END LOOP;

      vtraza := 28;

      --Bug.: 15708 - ICV - 09/06/2011
      IF NVL (pac_parametros.f_parempresa_n (pcempres, 'GESTIONA_COBPAG'), 0) =
                                                                             1
      THEN
         vnpoliza := vrecunif.FIRST;

         LOOP
            EXIT WHEN vnpoliza IS NULL;
            vnrecibo := vrecunif (vnpoliza);
            vtraza := 29;

            BEGIN
               SELECT r.cempres, r.sseguro, r.nmovimi, r.femisio, r.fefecto
                 INTO vcempres, vsseguro, vnmovimi, d_emirec, d_eferec
                 FROM recibos r
                WHERE r.nrecibo = vnrecibo;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  num_err := 101902;
            -- Recibo no encontrado en la tabla RECIBOS
            END;

            vtraza := 30;

            BEGIN
               SELECT m.cestrec, m.cestant, m.smovrec
                 INTO pcestrec, xcestrec, n_movrec
                 FROM movrecibo m
                WHERE m.nrecibo = vnrecibo AND m.fmovfin IS NULL;
            EXCEPTION
               WHEN OTHERS
               THEN
                  pcestrec := NULL;
                  xcestrec := NULL;
            END;

            IF NOT (pcestrec = 0 AND NVL (xcestrec, 0) = 0) --SI NO ES EMISION
            THEN
               RETURN 0;
            END IF;

            vtraza := 31;

            -- ini BUG 0026035 - 12/02/2013 - JMF
            IF num_err = 0
            THEN
               --BUG 23183-XVM-08/11/2012.Inicio
               IF d_emirec < d_eferec
               THEN
                  d_fmovim := d_eferec;
               ELSE
                  d_fmovim := d_emirec;
               END IF;

               num_err :=
                  f_insctacoas (vnrecibo,
                                1,
                                vcempres,
                                n_movrec,
                                TRUNC (d_fmovim)
                               );

               IF num_err != 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               v_obj,
                               vtraza,
                                  'r='
                               || vnrecibo
                               || ' m='
                               || n_movrec
                               || ' f='
                               || d_fmovim
                               || ' '
                               || v_par,
                               num_err || ' - ' || SQLCODE
                              );
                  RETURN num_err;
               END IF;
            END IF;

            --BUG 23183-XVM-08/11/2012.Fin
            -- fin BUG 0026035 - 12/02/2013 - JMF
            vtraza := 40;

            IF pcommitpag = 1
            THEN
               -- BUG22839:DRA:05/11/2012:Inici
               IF num_err = 0
               THEN
                  num_err :=
                     pac_ctrl_env_recibos.f_proc_recpag_mov (vcempres,
                                                             vsseguro,
                                                             vnmovimi,
                                                             4,
                                                             NULL
                                                            );
               END IF;

               -- BUG22839:DRA:05/11/2012:Fi
               IF num_err <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               'pac_gestion_rec.f_agruparecibo',
                               vtraza,
                                  'psproduc = '
                               || psproduc
                               || ' pfecha = '
                               || pfecha
                               || ' pfemisio = '
                               || pfemisio
                               || ' vcempres = '
                               || vcempres
                               || ' vcempres = '
                               || vcempres
                               || ' vsseguro = '
                               || vsseguro
                               || ' vnmovimi = '
                               || vnmovimi
                               || ' pcestrec = '
                               || pcestrec
                               || ' xcestrec = '
                               || xcestrec,
                                  num_err
                               || ' - '
                               || f_axis_literales (num_err, f_usu_idioma)
                              );
                  --Mira si borraar sin_tramita_movpago porque se tiene que hacer un commit para que loo vea el sap
                  RETURN num_err;
               END IF;
            END IF;

            vnpoliza := vrecunif.NEXT (vnpoliza);
         END LOOP;
      END IF;

      --Fi Bug.: 15708
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_agruparecibo',
                      vtraza,
                         'psproduc = '
                      || psproduc
                      || ' pfecha = '
                      || pfecha
                      || ' pfemisio = '
                      || pfemisio
                      || ' pcempres = '
                      || pcempres,
                      SQLERRM
                     );
         RETURN 9901207;
   END f_agruparecibo;

   -- Fin Bug 9383

   /****************************************************************************
     Funci¿n que nos dir¿ si un recibo es o no agrupado.
     param in pnrecibo  : Codigo de recibo
     return           : NUMBER
   ****************************************************************************/
   -- Bug 9383 - 09/03/2009 - RSC -CRE: Unificaci¿n de recibos
   FUNCTION f_recunif (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vrecunif   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vrecunif
        FROM adm_recunif
       WHERE nrecunif = pnrecibo;

      IF vrecunif > 0
      THEN
         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END f_recunif;

   /****************************************************************************
     Funci¿n que nos dir¿ si un recibo es padre o no
     param in pnrecibo  : Codigo de recibo
     return           : NUMBER
   ****************************************************************************/
   FUNCTION f_recunif_list (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      vrecunif   NUMBER;
   BEGIN
      SELECT COUNT (*)
        INTO vrecunif
        FROM adm_recunif
       WHERE nrecunif = pnrecibo;

      IF vrecunif > 0
      THEN
         SELECT COUNT (*)
           INTO vrecunif
           FROM adm_recunif
          WHERE nrecibo = pnrecibo;

         IF vrecunif > 0
         THEN
            RETURN 0;
         END IF;

         RETURN 1;
      ELSE
         RETURN 0;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END f_recunif_list;

-- Fin Bug 9383

   /*******************************************************************************
   FUNCION f_get_anula_pend
   Funci¿n que recupera si un recibo est¿ marcado como pendiente de anulaci¿n ¿ est¿ desmarcado
      param in pnrecibo : recibo
      return: number indicando si el recibo esta marcado como pendiente de anulaci¿n
   ********************************************************************************/
   FUNCTION f_get_anula_pend (pnrecibo IN NUMBER)
      RETURN NUMBER
   IS
      wanualpend   NUMBER := 0;
   BEGIN
      SELECT COUNT (*)
        INTO wanualpend
        FROM devbananu
       WHERE nrecibo = pnrecibo AND sproces IS NULL;

      IF wanualpend > 0
      THEN
         RETURN 1;
      END IF;

      RETURN (wanualpend);
   END f_get_anula_pend;

      /*******************************************************************************
   FUNCION F_GET_ACCIONES
   Funci¿n que recupera las acciones posibles a realizar sobre un recibo en funci¿n del estado del recibo y configuraci¿n del usuario
      param in pnrecibo : recibo
      param in psproduc : c¿digo producto
      return: sysrefcursor con las posibles acciones a realizar
   ********************************************************************************/
   FUNCTION f_get_acciones (
      pnrecibo   IN       NUMBER,
      psproduc   IN       NUMBER,
      pcidioma   IN       NUMBER,
      pcempres   IN       NUMBER,
      pcusuari   IN       VARCHAR2,
      psaltar    OUT      NUMBER
   )
      RETURN sys_refcursor
   IS
      cur           sys_refcursor;
      w_cestrec     movrecibo.cestrec%TYPE;
      v_error       NUMBER;
      salir         EXCEPTION;
      v_texterror   VARCHAR2 (200)           := NULL;
      recibo        ob_iax_recibos;
      err           NUMBER;
      vsproduc      productos.sproduc%TYPE;
   BEGIN
      w_cestrec := f_cestrec (pnrecibo, f_sysdate);

      IF w_cestrec IS NULL
      THEN
         w_cestrec := -1;
                     --Bug 0016141 30/09/2010-ETM-- AGA003 - rebuts en gesti¿
      --v_error := 111898;
      --RAISE salir;
      END IF;

      SELECT COUNT (*)
        INTO psaltar
        FROM (SELECT DISTINCT c.cform, c.tform
                         FROM cfg_accion_recibo c, cfg_user u
                        WHERE UPPER (u.cuser) = UPPER (pcusuari)
                          -- pac_md_common.f_get_cxtusuario)
                          AND u.cempres = pcempres
                          -- pac_md_common.f_get_cxtempresa
                          AND c.ccfgacc = u.ccfgacc
                          AND c.cempres = u.cempres
                          AND (   (c.sproduc = psproduc)
                               OR (c.sproduc = 0 AND psproduc <> 0)
                              ));

      OPEN cur FOR
         SELECT DISTINCT c.cform,
                         f_axis_literales (c.tform, pcidioma) tform  --c.tform
                    FROM cfg_accion_recibo c, cfg_user u
                   WHERE UPPER (u.cuser) = UPPER (pcusuari)
                     -- UPPER(pac_md_common.f_get_cxtusuario)
                     AND u.cempres = pcempres --pac_md_common.f_get_cxtempresa
                     AND c.ccfgacc = u.ccfgacc
                     AND c.cempres = u.cempres
                     AND (   (c.sproduc = psproduc)
                          OR (c.sproduc = 0 AND psproduc <> 0)
                         )
                     AND c.cestrec = w_cestrec
                ORDER BY cform;

      RETURN cur;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_gestion_rec.f_get_acciones',
                      1,
                         'Error esperado: '
                      || v_error
                      || ':'
                      || f_axis_literales (v_error, f_idiomauser),
                      SQLERRM || v_texterror
                     );

         IF cur%ISOPEN
         THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_acciones;

   --BUG 10069 - 15/06/2009 - JTS
   /*******************************************************************************
   FUNCION F_COBRO_RECIBO_ONLINE
   Funci¿n que realiza el cobro online
      param in pcempres : empres
      param in pnrecibo : recibo
      param in pterminal : terminal
      param out pcobrado : cobrado
      param out psinterf : interficie
      param out perror : error
      return: 0.- OK, Otros.- KO
   ********************************************************************************/
   FUNCTION f_cobro_recibo_online (
      pcempresa   IN       NUMBER,
      pnrecibo    IN       NUMBER,
      pterminal   IN       VARCHAR2,
      pcobrado    OUT      NUMBER,
      psinterf    OUT      NUMBER,
      perror      OUT      VARCHAR2,
      pusuario    IN       VARCHAR2
   )
      RETURN NUMBER
   IS
      v_error   NUMBER := 0;
      v_paso    NUMBER := 1;
   BEGIN
      v_error :=
         pac_con.f_cobro_recibo (pcempresa,
                                 pnrecibo,
                                 pterminal,
                                 pcobrado,
                                 psinterf,
                                 perror,
                                 pusuario
                                );
      RETURN v_error;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_gestion_rec.f_cobro_recibo_online',
                      v_paso,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN SQLCODE;
   END f_cobro_recibo_online;

--Fi BUG 10069 - 15/06/2009 - JTS

   /*******************************************************************************
    FUNCION F_COBRADOR_REC
    Funci¿n que retorna el cobrador bancario para un recibo
       param in pnrecibo : recibo
       param out pselect : select con los cobradores
       return: 0.- OK, Otros.- KO
   --BUG 10529 - 04/09/2009 - JTS
   ********************************************************************************/
   FUNCTION f_cobrador_rec (pnrecibo IN NUMBER, pselect OUT VARCHAR2)
      RETURN NUMBER
   IS
      v_cempres   recibos.cempres%TYPE;
      --       v_cempres      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_ccobban   recibos.ccobban%TYPE;
      --       v_ccobban      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_count     NUMBER;
      v_out       NUMBER;
      v_ret       NUMBER;
      v_paso      NUMBER                 := 0;

      CURSOR v_cur
      IS
         SELECT cramo, cmodali, ctipseg, ccolect, cagente, cbancar, ctipban
           FROM seguros
          WHERE sseguro = (SELECT sseguro
                             FROM recibos
                            WHERE nrecibo = pnrecibo);
   BEGIN
      SELECT ccobban, cempres
        INTO v_ccobban, v_cempres
        FROM recibos
       WHERE nrecibo = pnrecibo;

      v_paso := 1;

      SELECT COUNT (*)
        INTO v_count
        FROM cobbancario
       WHERE cempres = v_cempres AND ccobban = v_ccobban AND cbaja <> 1;

      v_paso := 2;

      IF v_count > 0
      THEN
         v_paso := 3;
         pselect :=
               'SELECT ccobban, ncuenta FROM cobbancario WHERE ccobban = '
            || v_ccobban
            || ' ORDER BY ccobban';
      ELSE
         v_paso := 4;

         FOR i IN v_cur
         LOOP
            v_ret :=
               f_buscacobban (i.cramo,
                              i.cmodali,
                              i.ctipseg,
                              i.ccolect,
                              i.cagente,
                              i.cbancar,
                              i.ctipban,
                              v_out
                             );
         END LOOP;

         v_paso := 5;

         IF v_out = 0 AND v_ret IS NOT NULL
         THEN
            pselect :=
                  'SELECT ccobban, ncuenta FROM cobbancario WHERE ccobban = '
               || v_ret
               || ' ORDER BY ccobban';
         ELSE
            pselect :=
                  'SELECT ccobban, ncuenta FROM cobbancario WHERE cempres = '
               || v_cempres
               || ' AND cbaja <> 1 ORDER BY ccobban';
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_cobrador_rec',
                      v_paso,
                      SQLCODE,
                      SQLERRM
                     );
         pselect :=
               'SELECT ccobban, ncuenta FROM cobbancario WHERE cempres = '
            || ' pac_md_common.f_get_cxtempresa AND cbaja <> 1 ORDER BY ccobban';
         RETURN 1;
   END f_cobrador_rec;

/*******************************************************************************
FUNCION F_get_saldo_inicial
Funci¿n que recupera el saldo de un recibo
   param in pnrecibo : recibo
   param out pisaldo : importe total
   return: number, 0 OK 1 KO
   24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
********************************************************************************/
   FUNCTION f_get_saldo_inicial (pnrecibo IN NUMBER, pisaldo OUT NUMBER)
      RETURN NUMBER
   IS
      err           NUMBER         := 0;
      vobjectname   VARCHAR2 (500) := 'PAC_GESTION_REC.F_get_saldo_inicial';
      vparam        VARCHAR2 (500) := 'par¿metros - pnrecibo: ' || pnrecibo;
      vpasexec      NUMBER (5)     := 1;
      v_paso        NUMBER         := 0;
   BEGIN
      SELECT SUM (iimporte)
        INTO pisaldo
        FROM detmovrecibo
       WHERE nrecibo = pnrecibo;

      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         pisaldo := 0;
         RETURN 0;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_get_saldo_inicial',
                      v_paso,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_get_saldo_inicial;

/*******************************************************************************
FUNCION f_transferir
Funci¿n que se encarga de transferir el importe al recibo
destino y de cobrar el recibo destino si fuese necesario
   param in pnrecibo_origen : recibo origen
   param in pnrecibo_destino : recibo destino
   param out pisaldo : importe total
   return: number, 0 OK 1 KO
   24/03/2010 - XPL Bug 0013450: APREXT02 - Transferencia de saldos entre rebuts
********************************************************************************/
   FUNCTION f_transferir (
      pnrecibo_origen    IN   NUMBER,
      pnrecibo_destino   IN   NUMBER,
      pisaldo            IN   NUMBER,
      ptdescrip          IN   VARCHAR2
   )                                            --BUG 14302 - 28/04/2010 - LCF
      RETURN NUMBER
   IS
      err                NUMBER                      := 0;
      vobjectname        VARCHAR2 (500)     := 'PAC_GESTION_REC.f_transferir';
      vparam             VARCHAR2 (500)
         :=    'par¿metros - PNRECIBO_ORIGEN: '
            || pnrecibo_origen
            || '- PNRECIBO_DESTINO: '
            || pnrecibo_destino
            || '- PISALDO : '
            || pisaldo
            || '- PTDESCRIP : '
            || ptdescrip;
      vpasexec           NUMBER (5)                  := 1;
      v_paso             NUMBER                      := 0;
      vsmovrec_origen    detmovrecibo.smovrec%TYPE;
      --       vsmovrec_origen NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnorden_origen     detmovrecibo.norden%TYPE;
      --       vnorden_origen NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vsmovrec_destino   detmovrecibo.smovrec%TYPE;
      --       vsmovrec_destino NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vnorden_destino    detmovrecibo.norden%TYPE;
   --       vnorden_destino NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      BEGIN
         SELECT smovrec, norden + 1
           INTO vsmovrec_origen, vnorden_origen
           FROM detmovrecibo
          WHERE nrecibo = pnrecibo_origen
            AND fmovimi = (SELECT MAX (fmovimi)
                             FROM detmovrecibo
                            WHERE nrecibo = pnrecibo_origen);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT MAX (smovrec)
              INTO vsmovrec_origen
              FROM movrecibo
             WHERE nrecibo = pnrecibo_origen;

            vnorden_origen := 1;
      END;

      v_paso := 1;

      BEGIN
         SELECT smovrec, norden + 1
           INTO vsmovrec_destino, vnorden_destino
           FROM detmovrecibo
          WHERE nrecibo = pnrecibo_destino
            AND fmovimi = (SELECT MAX (fmovimi)
                             FROM detmovrecibo
                            WHERE nrecibo = pnrecibo_destino);
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT MAX (smovrec)
              INTO vsmovrec_destino
              FROM movrecibo
             WHERE nrecibo = pnrecibo_destino;

            vnorden_destino := 1;
      END;

      v_paso := 2;

--Haremos dos apuntes en detmovrecibo, uno positivo para el
--nrecibo_destino y uno negative para el nrecibo_origen
--BUG 14302 - 28/04/2010 - LCF
      INSERT INTO detmovrecibo
                  (smovrec, norden, nrecibo,
                   iimporte, fmovimi, fefeadm, cusuari, sdevolu, nnumnlin,
                   cbancar1, nnumord, smovrecr, nordenr, tdescrip
                  )
           VALUES (vsmovrec_origen, vnorden_origen, pnrecibo_origen,
                   -pisaldo, f_sysdate, f_sysdate, f_user, 0, 0,
                   0, 0, vsmovrec_destino, vnorden_destino, ptdescrip
                  );

      v_paso := 3;

      INSERT INTO detmovrecibo
                  (smovrec, norden, nrecibo,
                   iimporte, fmovimi, fefeadm, cusuari, sdevolu, nnumnlin,
                   cbancar1, nnumord, smovrecr, nordenr, tdescrip
                  )
           VALUES (vsmovrec_destino, vnorden_destino, pnrecibo_destino,
                   pisaldo, f_sysdate, f_sysdate, f_user, 0, 0,
                   0, 0, vsmovrec_origen, vnorden_origen, ptdescrip
                  );

--Fi BUG 14302 - 28/04/2010 - LCF
      v_paso := 4;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'f_transferir',
                      v_paso,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_transferir;

/*******************************************************************************
FUNCION f_get_rebtom
Funci¿n que se encarga de devolver los recibos del tomador en los ultimos 5 a¿os
   param in sperson : seq. persona a buscar
   param out pipagado : importe de todos los recibos cobrados
   param out pipendiente : importe de todos los recibos pendientes
   param out pimpagados : importe de todos los recibos impagados
   param out pquery  : Query a devolver
   return: number, 0 OK 1 KO
   30/03/2009#XPL#13850: APRM00 - Lista de recibos por personas
********************************************************************************/
   FUNCTION f_get_rebtom (
      psperson      IN       NUMBER,
      pcempres      IN       NUMBER,
      pidioma       IN       NUMBER,
      pipagado      OUT      NUMBER,
      pipendiente   OUT      NUMBER,
      pimpagado     OUT      NUMBER,
      pisaldo       OUT      NUMBER,
      pquery        OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      err           NUMBER         := 0;
      vobjectname   VARCHAR2 (500) := 'PAC_GESTION_REC.get_rebtom';
      vparam        VARCHAR2 (500) := 'par¿metros - psperson: ' || psperson;
      vpasexec      NUMBER (5)     := 1;
      v_paso        NUMBER         := 0;
      v_select      VARCHAR2 (500) := '';
   BEGIN
      BEGIN
         -- Bug 18946 - APD - 15/11/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
         SELECT NVL (SUM (DECODE (r.ctiprec, 9, -vr.itotalr, vr.itotalr)), 0)
           INTO pipendiente
           FROM seguros s,
                tomadores t,
                recibos r,
                vdetrecibos vr,
                agentes_agente_pol aa
          WHERE s.cempres = pcempres
            AND s.cempres = r.cempres
            AND t.sseguro = s.sseguro
            AND t.sperson = psperson
            AND r.sseguro = s.sseguro
            AND f_cestrec_mv (r.nrecibo, NULL) = 0
            AND r.ctiprec NOT IN (13, 15)
            AND vr.nrecibo = r.nrecibo
            AND s.cagente = aa.cagente
            AND s.cempres = aa.cempres
            AND r.cestaux = 0;
--se suman los importes de los recibos certificado 0 (si se suman tb los hijos el importe saldria duplicado)
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pipendiente := 0;
      END;

      BEGIN
         -- Bug 18946 - APD - 15/11/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
         SELECT NVL (SUM (vr.itotalr), 0)
           INTO pipagado
           FROM seguros s,
                tomadores t,
                recibos r,
                vdetrecibos vr,
                agentes_agente_pol aa
          WHERE s.cempres = pcempres
            AND s.cempres = r.cempres
            AND t.sseguro = s.sseguro
            AND t.sperson = psperson
            AND r.sseguro = s.sseguro
            AND f_cestrec_mv (r.nrecibo, NULL) = 1
            --   AND TRUNC(r.fefecto) >= TRUNC(ADD_MONTHS(f_sysdate, -60))
            AND vr.nrecibo = r.nrecibo
            AND s.cagente = aa.cagente
            AND s.cempres = aa.cempres
            AND r.cestaux = 0;
--se suman los importes de los recibos certificado 0 (si se suman tb los hijos el importe saldria duplicado)
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pipagado := 0;
      END;

      BEGIN
         -- Bug 18946 - APD - 15/11/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
         SELECT NVL (SUM (vr.itotalr), 0)
           INTO pimpagado
           FROM seguros s,
                tomadores t,
                recibos r,
                vdetrecibos vr,
                agentes_agente_pol aa
          WHERE s.cempres = pcempres
            AND s.cempres = r.cempres
            AND t.sseguro = s.sseguro
            AND t.sperson = psperson
            AND r.sseguro = s.sseguro
            AND f_cestrec_mv (r.nrecibo, NULL) = 4
            AND vr.nrecibo = r.nrecibo
            AND s.cagente = aa.cagente
            --  AND TRUNC(r.fefecto) >= TRUNC(ADD_MONTHS(f_sysdate, -60))
            AND s.cempres = aa.cempres
            AND r.cestaux = 0;
--se suman los importes de los recibos certificado 0 (si se suman tb los hijos el importe saldria duplicado)
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            pimpagado := 0;
      END;

      IF NVL (pac_parametros.f_parempresa_n (pcempres, 'DETALLE_RECIBOS'), 0) =
                                                                             1
      THEN
         BEGIN
            -- Bug 18946 - APD - 15/11/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
            SELECT NVL (SUM (d.iimporte), 0)
              INTO pisaldo
              FROM seguros s,
                   tomadores t,
                   recibos r,
                   vdetrecibos vr,
                   agentes_agente_pol aa,
                   detmovrecibo d
             WHERE s.cempres = pcempres
               AND s.cempres = r.cempres
               AND t.sseguro = s.sseguro
               AND t.sperson = psperson
               AND r.sseguro = s.sseguro
               AND vr.nrecibo = r.nrecibo
               AND s.cagente = aa.cagente
               AND r.nrecibo = d.nrecibo
               --  AND TRUNC(r.fefecto) >= TRUNC(ADD_MONTHS(f_sysdate, -60))
               AND s.cempres = aa.cempres
               AND r.cestaux = 0;
--se suman los importes de los recibos certificado 0 (si se suman tb los hijos el importe saldria duplicado)
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               pisaldo := 0;
         END;

         pisaldo :=
              (NVL (pimpagado, 0) + NVL (pipagado, 0) + NVL (pipendiente, 0)
              )
            - NVL (pisaldo, 0);
         v_select :=
               v_select
            || ' , nvl((v.itotalr - (SELECT SUM(nvl(dm.iimporte,0)) FROM detmovrecibo dm WHERE dm.nrecibo = v.nrecibo)),0) isaldo';
      END IF;

      --Bug.: 16297 - ICV - 14/10/2010
         -- Bug 18946 - APD - 15/11/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      pquery :=
            'select s.npoliza,f_desproducto_t(s.CRAMO,s.CMODALI,s.CTIPSEG,
                s.CCOLECT,1,'
         || pidioma
         || ') desproducto, r.fefecto, v.ITOTALR,  r.cagente,
                ff_desagente(r.cagente) tagente, pac_eco_monedas.F_OBTENER_MONEDA_RECIBO2(r.nrecibo) CMONEDAREC,
                 ff_desvalorfijo( 8 , '
         || pidioma
         || ', r.ctiprec ) ttiprec,
             f_cestrec_mv (r.nrecibo, null) cestrec,
                ff_desvalorfijo( 383 , '
         || pidioma
         || ',f_cestrec_mv (r.nrecibo, null)) testrec, r.nrecibo'
         || v_select
         || ' FROM  recibos r, vdetrecibos v, seguros s, tomadores t, agentes_agente_pol aa
            WHERE
                r.sseguro= s.sseguro
                and t.sseguro = s.sseguro
                and r.nrecibo = v.nrecibo
                and s.cagente = aa.cagente
                and s.cempres = aa.cempres
                and (nvl(pac_parametros.F_PAREMPRESA_N(r.cempres,''NO_REC_IMP_CERO''),0) = 0 or v.itotalr <> 0)
                and t.sperson = '
         || psperson
         || '
                and r.cempres = '
         || pcempres
         || 'and s.cempres = r.cempres
                and trunc(r.fefecto) >= trunc(ADD_MONTHS(f_sysdate, -60))
                ';
      pquery := pquery || ' order by r.fefecto desc ';
      --Fin bug.: 16297
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      v_paso,
                      SQLCODE,
                      SQLERRM
                     );
         RETURN 1;
   END f_get_rebtom;

   --BUG16992 - JTS - 18/11/2010
   FUNCTION f_set_reccbancar (
      pnrecibo   IN   NUMBER,
      pcbancar   IN   VARCHAR2,
      pctipban   IN   NUMBER
   )
      RETURN NUMBER
   IS
      vsseguro      recibos.sseguro%TYPE;
      --       vsseguro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccobban      recibos.ccobban%TYPE;
      --       vccobban       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcramo        seguros.cramo%TYPE;
      --       vcramo         NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcmodali      seguros.cmodali%TYPE;
      --       vcmodali       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vctipseg      seguros.ctipseg%TYPE;
      --       vctipseg       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vccolect      seguros.ccolect%TYPE;
      --       vccolect       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vcagente      seguros.cagente%TYPE;
      --       vcagente       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      err           NUMBER;
      vcempres      recibos.cempres%TYPE;
      --       vcempres       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vactccobban   NUMBER;
   BEGIN
      BEGIN
         SELECT sseguro, cempres
           INTO vsseguro, vcempres
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_set_reccbancar',
                         1,
                         'No es troba el rebut: ' || pnrecibo,
                         SQLERRM
                        );
            err := 101902;                             -- recibo no encontrado
            RETURN err;
      END;

      BEGIN
         SELECT cramo, cmodali, ctipseg, ccolect, cagente
           INTO vcramo, vcmodali, vctipseg, vccolect, vcagente
           FROM seguros
          WHERE sseguro = vsseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_set_reccbancar',
                         1,
                         'No es troba el seguro: ' || vsseguro,
                         SQLERRM
                        );
            err := 101903;                             -- recibo no encontrado
            RETURN err;
      END;

      --
      IF pcbancar IS NOT NULL AND pctipban IS NOT NULL
      THEN
         vccobban :=
            f_buscacobban (vcramo,
                           vcmodali,
                           vctipseg,
                           vccolect,
                           vcagente,
                           pcbancar,
                           pctipban,
                           err
                          );

         IF vccobban IS NULL
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'pac_gestion_rec.f_cobro_recibo',
                         2,
                            'Error al buscar cobrador bancario: '
                         || pnrecibo
                         || ' cuenta: '
                         || pcbancar,
                         SQLERRM
                        );
            RETURN err;
         END IF;
      ELSE
         vccobban := NULL;
         vactccobban :=
                       pac_parametros.f_parempresa_n (vcempres, 'ACTCCOBBAN');
      END IF;

      -- Modificamos el recibo con la cuenta y el cobrador elegido
      BEGIN
         IF vactccobban IS NOT NULL
         THEN
            IF vactccobban = 1
            THEN
               UPDATE recibos
                  SET cbancar = pcbancar,
                      ccobban = vccobban,
                      ctipban = pctipban
                WHERE nrecibo = pnrecibo;
            ELSE
               UPDATE recibos
                  SET cbancar = pcbancar,
                      ctipban = pctipban
                WHERE nrecibo = pnrecibo;
            END IF;
         ELSE
            UPDATE recibos
               SET cbancar = pcbancar,
                   ccobban = vccobban,
                   ctipban = pctipban
             WHERE nrecibo = pnrecibo;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_set_reccbancar',
                         3,
                            'Error al modificar la cuenta del recibo: '
                         || pnrecibo
                         || ' cuenta: '
                         || pcbancar,
                         SQLERRM
                        );
            err := 102358;                       -- error al modificar recibos
            RETURN err;
      END;

      --

      -- COMMIT;  -- BUG18201:DRA:07/04/2011: Se comenta porque sino deja cobrados los recibos aunque falle por HOST online
      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_set_reccbancar;

   --Bug.: 18632 - ICV - 07/06/2011
   FUNCTION f_set_aportante (
      pnrecibo         IN   NUMBER,
      pctipapor        IN   NUMBER,
      psperapor        IN   NUMBER,
      ptipoaportante   IN   NUMBER
   )
      RETURN NUMBER
   IS
      err   NUMBER := 0;
   BEGIN
      -- Modificamos el recibo con la cuenta y el cobrador elegido
      BEGIN
         -- Bug 19792 - APD - 13/12/2011 - se modifica pctipapor por ptipoaportante
         IF ptipoaportante = 4
         THEN
            -- fin Bug 19792 - APD - 13/12/2011
            UPDATE recibos
               SET ctipapor = pctipapor,
                   sperson = psperapor,
                   ctipaportante = ptipoaportante,
                   esccero = 1,
                   cestaux = 2
             WHERE nrecibo = pnrecibo;
         ELSE
            UPDATE recibos
               SET ctipapor = pctipapor,
                   sperson = psperapor,
                   ctipaportante = ptipoaportante
             WHERE nrecibo = pnrecibo;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'f_set_aportante',
                         1,
                            'Error al modificar el aportante del recibo: '
                         || pnrecibo,
                         SQLERRM
                        );
            err := 102358;                       -- error al modificar recibos
            RETURN err;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN SQLCODE;
   END f_set_aportante;

      /***********************************************************************************************************
        F_REHABILITA_REC. Funci¿n que rehabilita un recibo.
        pnrecibo: Recibo que queremos anular
        pfrehabi: Fecha de efecto de rehabilitacion del recibo
        psmovagr: agrupaci¿n de recibos por remesa. Si es null se incrementa la secuencia
        Bug 18908/93215 - 05/10/2011 - AMC
   **********************************************************************************************************/
   FUNCTION f_rehabilita_rec (
      pnrecibo   IN   NUMBER,
      pfrehabi   IN   DATE,
      psmovagr   IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      num_err         NUMBER;
      ccdelega        recibos.cdelega%TYPE;
      --       ccdelega       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ccempres        recibos.cempres%TYPE;
      --       ccempres       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_fmovini       movrecibo.fmovini%TYPE;
      --       v_fmovini      DATE; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cestrec       movrecibo.cestrec%TYPE;
      --       v_cestrec      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      v_cestant       movrecibo.cestant%TYPE;
      --       v_cestant      NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      ffrehabilirec   DATE;
      v_smovagr       NUMBER;
      nnliqmen        NUMBER;
      nnliqlin        NUMBER;
      vcramo          seguros.cramo%TYPE;
      vcmodali        seguros.cmodali%TYPE;
      vctipseg        seguros.ctipseg%TYPE;
      vccolect        seguros.ccolect%TYPE;
      vcountagrp      NUMBER;
   BEGIN
      BEGIN
         SELECT cdelega, cempres
           INTO ccdelega, ccempres
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 112614;          --{rebut no trobat a la llista de rebuts}
      END;

      BEGIN
         SELECT fmovini, cestrec, cestant
           INTO v_fmovini, v_cestrec, v_cestant
           FROM movrecibo
          WHERE nrecibo = pnrecibo AND fmovfin IS NULL;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN 104939;      -- recibo no encontrado en la tabla MOVRECIBO
      END;

      IF v_cestrec NOT IN (2)
      THEN
         RETURN 9902452;                         -- El recibo no est¿ anulado
      END IF;

      IF psmovagr IS NULL
      THEN
         SELECT smovagr.NEXTVAL
           INTO v_smovagr
           FROM DUAL;
      ELSE
         v_smovagr := psmovagr;
      END IF;

      IF pfrehabi >= TRUNC (f_sysdate)
      THEN
         ffrehabilirec := pfrehabi;
      ELSE
         SELECT LAST_DAY (ADD_MONTHS (MAX (fperini), 1))
           INTO ffrehabilirec
           FROM cierres
          WHERE ctipo = 1 AND cestado = 1 AND cempres = ccempres;

         IF TRUNC (f_sysdate) < ffrehabilirec
         THEN
            ffrehabilirec := TRUNC (f_sysdate);
         END IF;
      END IF;

      IF ffrehabilirec < v_fmovini OR ffrehabilirec IS NULL
      THEN
         ffrehabilirec := v_fmovini;
      END IF;

      BEGIN
         SELECT s.cramo, s.cmodali, s.ctipseg, s.ccolect
           INTO vcramo, vcmodali, vctipseg, vccolect
           FROM recibos r, seguros s
          WHERE r.nrecibo = pnrecibo AND r.sseguro = s.sseguro;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'F_REHABILITA_REC',
                         1,
                         'Error al buscar datos del recibo: ' || pnrecibo,
                         SQLERRM
                        );
            RETURN 101731;
      END;

      IF NVL (f_parproductos_v (f_sproduc_ret (vcramo,
                                               vcmodali,
                                               vctipseg,
                                               vccolect
                                              ),
                                'RECUNIF'
                               ),
              0
             ) IN (1, 3)
      THEN
         -- BUG 0019627: GIP102 - Reunificaci¿n de recibos - FAL - 10/11/2011
         SELECT COUNT (*)
           INTO vcountagrp
           FROM adm_recunif
          WHERE nrecibo = pnrecibo;

         IF vcountagrp > 0
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         'F_REHABILITA_REC',
                         2,
                         f_axis_literales (9001160, f_idiomauser),
                         SQLERRM
                        );
            RETURN 9001160;
         END IF;
      END IF;

      IF NVL (f_parproductos_v (f_sproduc_ret (vcramo,
                                               vcmodali,
                                               vctipseg,
                                               vccolect
                                              ),
                                'RECUNIF'
                               ),
              0
             ) = 2
      THEN
         -- Si se rehabilita un recibo agrupado entrar¿ en LOOP
         FOR v_recind IN (SELECT nrecibo
                            FROM adm_recunif a
                           WHERE nrecunif = pnrecibo)
         LOOP
            num_err :=
               f_movrecibo (v_recind.nrecibo,
                            0,
                            pfrehabi,
                            2,
                            v_smovagr,
                            nnliqmen,
                            nnliqlin,
                            ffrehabilirec,
                            NULL,
                            ccdelega,
                            NULL,
                            NULL
                           );
         END LOOP;
      END IF;

      /* {creamos el movimiento de rehabilitaci¿n del recibo} */
      num_err :=
         f_movrecibo (pnrecibo,
                      0,
                      pfrehabi,
                      2,
                      v_smovagr,
                      nnliqmen,
                      nnliqlin,
                      ffrehabilirec,
                      NULL,
                      ccdelega,
                      NULL,
                      NULL
                     );

      IF num_err <> 0
      THEN
         RETURN num_err;
      END IF;

      RETURN 0;
   END f_rehabilita_rec;

      /*******************************************************************************
       FUNCION F_GET_TOMRECIBO
       Funci¿n que devuelve el tomador de un recibo
      param in pnrecibo : recibo
      param out pspertom   : identificador del tomador
      return: number indicando c¿digo de error (0: sin errores)

      Bug 20012/96897 - 11/11/2011 - AMC
   ********************************************************************************/
   FUNCTION f_get_tomrecibo (pnrecibo IN NUMBER, pspertom OUT NUMBER)
      RETURN NUMBER
   IS
      vsseguro   recibos.sseguro%TYPE;
   --       vsseguro       NUMBER; --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      IF pnrecibo IS NULL
      THEN
         RETURN 1;
      END IF;

      SELECT sseguro
        INTO vsseguro
        FROM recibos
       WHERE nrecibo = pnrecibo;

      SELECT sperson
        INTO pspertom
        FROM tomadores
       WHERE sseguro = vsseguro AND nordtom = 1;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_gestion_rec.f_get_tomrecibo',
                      1,
                      'error no controlado',
                      SQLERRM
                     );
         RETURN 1;
   END f_get_tomrecibo;

/*******************************************************************************
FUNCION F_MODIFICA_ACCPRECONOCIDA
Funci¿n que realiza modificaci¿n en el recibo complementario.
   param in pnrecibo : recibo
   param in pcaccpre : c¿digo de acci¿n preconocida
   return: number indicando c¿digo de error (0: sin errores)
   Bug 22342 - 11/06/2012 - APD
********************************************************************************/
   FUNCTION f_modifica_accpreconocida (pnrecibo IN NUMBER, pcaccpre IN NUMBER)
      RETURN NUMBER
   IS
      recestado   NUMBER;
      vnumerr     NUMBER                      := 0;
      wcaccpre    recibos_comp.caccpre%TYPE;
      salir       EXCEPTION;
      vparam      VARCHAR2 (1000)
                  := 'pnrecibo = ' || pnrecibo || '; pcaccpre = ' || pcaccpre;
      vtraza      NUMBER;
   BEGIN
      vtraza := 1;

      BEGIN
         SELECT caccpre
           INTO wcaccpre
           FROM recibos_comp rc
          WHERE rc.nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            wcaccpre := NULL;
         WHEN OTHERS
         THEN
            vnumerr := 9903885;    --Error al consultar la tabla RECIBOS_COMP
            RAISE salir;
      END;

      vtraza := 2;

      IF NVL (wcaccpre, -1) = NVL (pcaccpre, -1)
      THEN
         RETURN 120466;                      -- No hi ha canvis en les dades.
      ELSE
         vtraza := 3;

         BEGIN
            INSERT INTO hisrecibos_comp
                        (shisrec_comp, nrecibo, caccpre, caccret, tobserv,
                         cusumod, fmodif)
               SELECT shisrec_comp.NEXTVAL, rc.nrecibo, rc.caccpre,
                      rc.caccret, rc.tobserv, f_user, f_sysdate
                 FROM recibos_comp rc
                WHERE rc.nrecibo = pnrecibo;
         EXCEPTION
            WHEN OTHERS
            THEN
               vnumerr := 9903788;
               -- Error al insertar en la tabla HISRECIBOS_COMP
               RAISE salir;
         END;

         vtraza := 4;

         BEGIN
            INSERT INTO recibos_comp
                        (nrecibo, caccpre, caccret, tobserv, cusualt, falta
                        )
                 VALUES (pnrecibo, pcaccpre, NULL, NULL, f_user, f_sysdate
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               BEGIN
                  vtraza := 5;

                  UPDATE recibos_comp
                     SET caccpre = pcaccpre
                   WHERE nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     vnumerr := 9903789;
                     --Error al modificar la tabla RECIBOS_COMP
                     RAISE salir;
               END;
            WHEN OTHERS
            THEN
               vnumerr := 9903789; --Error al modificar la tabla RECIBOS_COMP
               RAISE salir;
         END;

         RETURN 0;
      END IF;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_gestion_rec.f_modifica_accpreconocida',
                      vtraza,
                      vparam,
                      f_axis_literales (vnumerr)
                     );
         RETURN vnumerr;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_gestion_rec.f_modifica_accpreconocida',
                      vtraza,
                      vparam,
                      SQLERRM
                     );
         RETURN 1000455;
   END f_modifica_accpreconocida;

   -- 22. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Inicio
   /*******************************************************************************
   FUNCION PAC_GESTION_REC.F_DESAGRUPARECIBO
   Funci¿n que realiza la desunificaci¿n de recibos y opcionalmente anula el recibo.
   Cuando el PFANULAC est¿ informado (IS NOT NULL).

   Par¿metros:
     param in pnrecunif : N¿mero del recibo agrupado
     param in pfanulac : Fecha de anulaci¿n
     param in pcidioma : C¿digo de idioma
     return: number un n¿mero con el id del error, en caso de que todo vaya OK, retornar¿ un cero.
   ********************************************************************************/
   FUNCTION f_desagruparecibo (
      pnrecunif   IN   NUMBER,
      pfanulac    IN   DATE DEFAULT NULL,
      pcidioma    IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vfanulac      DATE                 := NVL (pfanulac, TRUNC (f_sysdate));
      vcdelega      recibos.cdelega%TYPE;
      vcempres      recibos.cempres%TYPE;
      vfanulacrec   DATE;
      vfmovini      DATE;
      vpasexec      NUMBER (8)             := 0;
      v_max_reg     NUMBER;             -- n¿mero m¿xim de registres mostrats
      vparam        VARCHAR2 (1500)
         :=    'par¿metros - pnrecunif: '
            || pnrecunif
            || ', pfanulac: '
            || pfanulac
            || ', pcidioma: '
            || pcidioma;
      vobject       VARCHAR2 (200)      := 'pac_gestion_rec.f_desagruparecibo';
      vcidioma      NUMBER    := NVL (pcidioma, pac_md_common.f_get_cxtidioma);
      verror        NUMBER                 := 0;
      salir         EXCEPTION;
      w_sproduc     NUMBER;
      ---
      vsperson      NUMBER;
      vsseguro      NUMBER;
      vffecmov      DATE;
      vffecval      DATE;
      vtdescri      VARCHAR2 (100);
      viimppro      NUMBER;
      vcmoneda      NUMBER;
      viimpope      NUMBER;
      viimpins      NUMBER;
      vfcambio      DATE;
      vseqcaja      NUMBER;
      vsproces      NUMBER;
      vsproduc      NUMBER;
   BEGIN
      /*
           {buscamos la delegaci¿n}
          */
      BEGIN
         vpasexec := 3;

         SELECT cdelega, cempres
           INTO vcdelega, vcempres
           FROM recibos
          WHERE nrecibo = pnrecunif;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            verror := 112614;       --{rebut no trobat a la llista de rebuts}
            RAISE salir;
      END;

      -- Guardamos conjunto anterior en el historico.
      DECLARE
         n_sec      adm_recunif_his.nsec%TYPE;
         n_recnou   adm_recunif.nrecunif%TYPE;
      BEGIN
         vpasexec := 15;

         SELECT NVL (MAX (nsec), 0) + 1
           INTO n_sec
           FROM adm_recunif_his;

         vpasexec := 20;

         INSERT INTO adm_recunif_his
                     (nrecibo, nrecunif, cuser, fhis, cobj, nsec)
            SELECT nrecibo, nrecunif, f_user, f_sysdate, vobject, n_sec
              FROM adm_recunif
             WHERE nrecunif = pnrecunif;
      EXCEPTION
         WHEN OTHERS
         THEN
            -- Error al insertar en la tabla ADM_RECUNIF_HIS
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            verror := 9904015;
            RAISE salir;
      END;

      SELECT sproduc
        INTO w_sproduc
        FROM recibos r, seguros s
       WHERE r.sseguro = s.sseguro AND r.nrecibo = pnrecunif;

      --INI BUG 0031322/0175728:NSS:11/06/2014
      FOR r IN (SELECT nrecibo
                  FROM adm_recunif
                 WHERE nrecunif = pnrecunif)
      LOOP
         UPDATE recibos
            SET cestaux = 0
          WHERE nrecibo = r.nrecibo;

         --Bug 31135  Desunificación han de crear nuevo movimiento de Cuota en la CTACLIENTE
         IF NVL (f_parproductos_v (w_sproduc, 'HAYCTACLIENTE'), 0) = 1
         THEN
            SELECT cempres, sperson, sseguro, ffecmov, ffecval,
                   tdescri, iimppro * (-1), cmoneda, iimpope * (-1),
                   iimpins * (-1), fcambio, seqcaja, sproces, sproduc
              INTO vcempres, vsperson, vsseguro, vffecmov, vffecval,
                   vtdescri, viimppro, vcmoneda, viimpope,
                   viimpins, vfcambio, vseqcaja, vsproces, vsproduc
              FROM ctacliente
             WHERE nrecibo = r.nrecibo
               AND nnumlin = (SELECT MAX (nnumlin)
                                FROM ctacliente
                               WHERE nrecibo = r.nrecibo);

            verror :=
               pac_ctacliente.f_insctacliente (vcempres,
                                               vsperson,
                                               vsseguro,
                                               NULL,
                                               vffecmov,
                                               vffecval,
                                               1,
                                               vtdescri,
                                               viimppro,
                                               vcmoneda,
                                               viimpope,
                                               viimpins,
                                               vfcambio,
                                               r.nrecibo,
                                               vsproces,
                                               vsproduc,
                                               vseqcaja
                                              );

            IF verror <> 0
            THEN
               RAISE salir;
            END IF;
-- Bug 33886/199825 -- ACL
         ELSIF NVL (f_parproductos_v (w_sproduc, 'HAYCTACLIENTE'), 0) = 2
         THEN
            SELECT cempres, sperson, sseguro, ffecmov, ffecval,
                   tdescri, iimppro * (-1), cmoneda, iimpope * (-1),
                   iimpins * (-1), fcambio, seqcaja, sproces, sproduc
              INTO vcempres, vsperson, vsseguro, vffecmov, vffecval,
                   vtdescri, viimppro, vcmoneda, viimpope,
                   viimpins, vfcambio, vseqcaja, vsproces, vsproduc
              FROM ctacliente
             WHERE nrecibo = r.nrecibo
               AND nnumlin = (SELECT MAX (nnumlin)
                                FROM ctacliente
                               WHERE nrecibo = r.nrecibo);

            verror :=
               pac_ctacliente.f_insctacliente_spl (vcempres,
                                                   vsperson,
                                                   vsseguro,
                                                   NULL,
                                                   vffecmov,
                                                   vffecval,
                                                   1,
                                                   vtdescri,
                                                   viimppro,
                                                   vcmoneda,
                                                   viimpope,
                                                   viimpins,
                                                   vfcambio,
                                                   r.nrecibo,
                                                   vsproces,
                                                   vsproduc,
                                                   vseqcaja
                                                  );

            IF verror <> 0
            THEN
               RAISE salir;
            END IF;
         --Fin Bug 33886/199825
         END IF;
      --Fin bug 31135
      END LOOP;

      --FIN BUG 0031322/0175728:NSS:11/06/2014

      -- Borrar conjunto anterior.
      BEGIN
         DELETE      adm_recunif
               WHERE nrecunif = pnrecunif;
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
            verror := 9904014;
            RAISE salir;
      END;

      -- ANULAR EL RECIBO --
         /*
         {
          La fecha de efecto de la anulaci¿n del recibo, para que sea coherente con las ventas ser¿:
            1.- La de la anulaci¿n de la p¿liza si se anula con fecha futura.
            2.- La del dia si no estamos en el tiempo a¿adido de un mes no cerrado.
            3.- La del ¿ltimo dia del mes de ventas abierto , si estamos en en el tiempo a¿adido de un mes no cerrado.
           Y siempre se tendr¿ en cuenta que no puede ser anterior al ¿ltimo movimiento
          }
         */
      IF vfanulac >= TRUNC (f_sysdate)
      THEN
         vpasexec := 5;
         vfanulacrec := vfanulac;
      ELSE
         vpasexec := 7;

         SELECT LAST_DAY (ADD_MONTHS (MAX (fperini), 1))
           INTO vfanulacrec
           FROM cierres
          WHERE ctipo = 1 AND cestado = 1 AND cempres = vcempres;

         IF TRUNC (f_sysdate) < vfanulacrec
         THEN
            vpasexec := 9;
            vfanulacrec := TRUNC (f_sysdate);
         END IF;
      END IF;

      vpasexec := 10;

      SELECT MAX (fmovini)
        INTO vfmovini
        FROM movrecibo
       WHERE nrecibo = pnrecunif AND fmovfin IS NULL;

      IF vfanulacrec < vfmovini OR vfanulacrec IS NULL
      THEN
         vpasexec := 11;
         vfanulacrec := vfmovini;
      END IF;

      -- 249 - Desunificaci¿n de recibos
      vpasexec := 30;
      verror := pac_gestion_rec.f_anula_recibo (pnrecunif, vfanulacrec, 249);

      IF verror != 0
      THEN
         RAISE salir;
      END IF;

      --Marcamos el recibo para no contabilizarlo
      UPDATE recibos
         SET cestaux = 2                      --0031322/0175728:NSS:11/06/2014
       WHERE nrecibo = pnrecunif;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      f_axis_literales (verror) || '. ' || SQLERRM
                     );
         RETURN verror;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         -- Error desunificando recibos
         RETURN 9903943;
   END f_desagruparecibo;

-- 22. 0022763: MDP_A001-Unificacion / Desunificacion de recibos - 0119028 - Fin

   -- BUG23853:DRA:25/10/2012:Inici
   FUNCTION f_genrec_primin_col (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pctiprec   IN       NUMBER,
      pfemisio   IN       DATE,
      pfefecto   IN       DATE,
      pfvencim   IN       DATE,
      piimprec   IN       NUMBER,
      pnrecibo   IN OUT   NUMBER,
      pmodo      IN       VARCHAR2,
      psproces   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'SEG'
   )
      RETURN NUMBER
   IS
      --
      vnumerr           NUMBER (8)                 := 0;
      vpasexec          NUMBER (8)                 := 0;
      v_max_reg         NUMBER;         -- n¿mero m¿xim de registres mostrats
      vparam            VARCHAR2 (1500)
         :=    'par¿metros - psseguro: '
            || psseguro
            || ', pnmovimi: '
            || pnmovimi
            || ', pctiprec: '
            || pctiprec
            || ', piimprec: '
            || piimprec
            || ', pnrecibo: '
            || pnrecibo
            || ', pfemisio: '
            || pfemisio
            || ', pfefecto: '
            || pfefecto
            || ', pfvencim: '
            || pfvencim
            || ', pmodo: '
            || pmodo
            || ', psproces: '
            || psproces
            || ', ptablas: '
            || ptablas;
      vobject           VARCHAR2 (200)
                                      := 'PAC_GESTION_REC.F_GENREC_PRIMIN_COL';
      v_numrec          recibos.nrecibo%TYPE;
      xnbancarf         seguros.cbancar%TYPE;
      xtbancar          seguros.cbancar%TYPE;
      xnmovimi          movseguro.nmovimi%TYPE;
      dummy             NUMBER;
      xcestaux          recibos.cestaux%TYPE;
      xctiprec          recibos.ctiprec%TYPE;
      xfvencim          recibos.fvencim%TYPE;
      xcperven          NUMBER;
      xnperven          recibos.nperven%TYPE;
      xcgescob          recibos.cgescob%TYPE;
      xcmanual          recibos.cmanual%TYPE;
      xcestimp          recibos.cestimp%TYPE;
      xsperson          tomadores.sperson%TYPE;
      xctipban          per_ccc.ctipban%TYPE;
      xcbancar          per_ccc.cbancar%TYPE;
      xcbancob          parempresas.nvalpar%TYPE;
      xtipomovimiento   NUMBER;
      xcmodcom          NUMBER (1);
      xctipcoa          recibos.ctipcoa%TYPE;
--       xctipcoa       NUMBER(1);   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xncuacoa          seguros.ncuacoa%TYPE;
--       xncuacoa       NUMBER(2);   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xploccoa          coacuadro.ploccoa%TYPE     := 0;
-- Bug 25583 -- ECP -- 17/01/2013   --       xploccoa       NUMBER(5, 2) := 0;   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vimport           NUMBER;
      decimals          NUMBER                     := 0;
      v_exist_rec       NUMBER;
      -- Bug 23853 - RSC - 17/12/201
      v_primadev        NUMBER;
      -- Fin bug 23853
      v_fefectovig      DATE;                  -- Bug 26060 - APD - 11/02/2013
      xfecvig           DATE;                  -- Bug 26060 - APD - 11/02/2013
      vpcomisi          NUMBER                     := 0;
      -- Bug 26060 - APD - 11/02/2013
      vpretenc          NUMBER                     := 0;
      -- Bug 26060 - APD - 11/02/2013
      importecomisi     NUMBER;                -- Bug 26060 - APD - 11/02/2013
      v_cmotmov_prev    NUMBER;          --Bug 29665/168265 - 03/03/2014 - AMC
   BEGIN
      vpasexec := 1;

      IF NVL (piimprec, 0) <> 0
      THEN
         -- Miramos si ya hay generado un recibo por prima m¿nima
         SELECT COUNT (1)
           INTO v_exist_rec
           FROM recibos r, detrecibos d
          WHERE r.sseguro = psseguro
            AND d.nrecibo = r.nrecibo
            AND r.ctiprec = pctiprec            -- Bug 23853 - RSC - 17/12/201
            -- Bug 23853 - APD - 07/01/2013
            /*AND(pctiprec = 0
                OR(pctiprec <> 0
                   AND TRUNC(r.femisio) = TRUNC(pfemisio)))*/
            -- fin Bug 23853 - APD - 07/01/2013
            --BUG 27048 - INICIO - DCT - 14/11/2013
            AND (   pctiprec = 0
                 OR (pctiprec = 3 AND TRUNC (r.femisio) = TRUNC (pfemisio))
                )
            --BUG 27048 - FIN - DCT - 14/11/2013
            AND d.cgarant = 400
            AND f_cestrec_mv (r.nrecibo, 2) <> 2
            AND d.iconcep <> 0;

         --Bug 29665/168265 - 03/03/2014 - AMC
         SELECT cmotmov
           INTO v_cmotmov_prev
           FROM movseguro
          WHERE sseguro = psseguro AND nmovimi = pnmovimi - 1;

         IF v_exist_rec > 0 AND v_cmotmov_prev != 674
         THEN
            RETURN 0;
         END IF;

         --Fi Bug 29665/168265 - 03/03/2014 - AMC
         FOR s0 IN (SELECT s.sseguro, s.cempres, s.ctipban, s.cbancar,
                           s.cagente, s.ccobban, s.fefecto, s.cforpag,
                           s.ctipcob, s.nanuali, s.nfracci, s.ctipcoa,
                           s.sproduc, s.fcaranu
                      FROM seguros s
                     WHERE s.sseguro = psseguro AND ptablas = 'SEG'
                    UNION ALL
                    SELECT s.sseguro, s.cempres, s.ctipban, s.cbancar,
                           s.cagente, s.ccobban, s.fefecto, s.cforpag,
                           s.ctipcob, s.nanuali, s.nfracci, s.ctipcoa,
                           s.sproduc, s.fcaranu
                      FROM estseguros s
                     WHERE s.sseguro = psseguro AND ptablas = 'EST')
         LOOP
            BEGIN
               SELECT pac_monedas.f_moneda_divisa (cdivisa)
                 -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               INTO   decimals
                 FROM productos
                WHERE sproduc = s0.sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 104347;            -- Producte no trobat a PRODUCTOS
               WHEN OTHERS
               THEN
                  RETURN 102705;              -- Error al llegir de PRODUCTOS
            END;

            -- <BUSCAR LOS DATOS BANCARIOS POR DEFECTO DEL BENEFICIARIO>
            vpasexec := 2;
            xnmovimi := pnmovimi;
            xctiprec := pctiprec;
            xfvencim := ADD_MONTHS (NVL (pfefecto, s0.fefecto), 12);
            vpasexec := 3;

            BEGIN
               vnumerr :=
                  f_insrecibo (s0.sseguro,
                               s0.cagente,
                               NVL (pfemisio, f_sysdate),
                               NVL (pfefecto, s0.fefecto),
                               NVL (pfvencim, xfvencim),
                               xctiprec,
                               s0.nanuali,
                               s0.nfracci,
                               s0.ccobban,
                               NULL,
                               NULL,
                               v_numrec,
                               pmodo,
                               psproces,
                               NULL,
                               xnmovimi,
                               f_sysdate,
                               'CERTIF0',
                               s0.cforpag,
                               s0.cbancar,
                               ptablas,
                               'CAR',
                               s0.ctipban
                              );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || s0.cagente
                               || '-'
                               || f_sysdate
                               || '-'
                               || s0.fefecto
                               || '-'
                               || xfvencim
                               || '-'
                               || xctiprec
                               || '-'
                               || s0.nanuali
                               || '-'
                               || s0.nfracci
                               || '-'
                               || s0.ccobban
                               || '-'
                               || NULL
                               || '-'
                               || NULL
                               || '-'
                               || v_numrec
                               || '-'
                               || pmodo
                               || '-'
                               || psproces
                               || '-'
                               || NULL
                               || '-'
                               || xnmovimi
                               || '-'
                               || f_sysdate
                               || '-'
                               || 'CERTIF0'
                               || '-'
                               || s0.cforpag
                               || '-'
                               || s0.cbancar
                               || '-'
                               || ptablas
                               || '-'
                               || 'CAR'
                               || '-'
                               || s0.ctipban
                              );
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || s0.cagente
                               || '-'
                               || f_sysdate
                               || '-'
                               || s0.fefecto
                               || '-'
                               || xfvencim
                               || '-'
                               || xctiprec
                               || '-'
                               || s0.nanuali
                               || '-'
                               || s0.nfracci
                               || '-'
                               || s0.ccobban
                               || '-'
                               || NULL
                               || '-'
                               || NULL
                               || '-'
                               || v_numrec
                               || '-'
                               || pmodo
                               || '-'
                               || psproces
                               || '-'
                               || NULL
                               || '-'
                               || xnmovimi
                               || '-'
                               || f_sysdate
                               || '-'
                               || 'CERTIF0'
                               || '-'
                               || s0.cforpag
                               || '-'
                               || s0.cbancar
                               || '-'
                               || ptablas
                               || '-'
                               || 'CAR'
                               || '-'
                               || s0.ctipban
                               || '-'
                               || SQLERRM
                              );
                  RETURN 103847;
            END;

            vpasexec := 4;

            IF xnmovimi = 1
            THEN
               xtipomovimiento := 0;
            ELSIF xnmovimi > 1
            THEN
               xtipomovimiento := 1;
            END IF;

            vpasexec := 5;

            IF f_es_renovacion (s0.sseguro) = 0
            THEN                                                 -- es cartera
               xcmodcom := 2;
            ELSE                                -- si es 1 es nueva produccion
               xcmodcom := 1;
            END IF;

            vpasexec := 6;
            /********************************************************************************
            vnumerr := f_detrecibo(psproces, s0.sseguro, v_numrec, xtipomovimiento, pmodo,
                                   xcmodcom, f_sysdate, s0.fefecto, xfvencim, s0.fcaranu, piimprec,
                                   NULL, xnmovimi, NULL, vimport, NULL, NULL, NULL, NULL, 400,
                                   ptablas);

            IF vnumerr <> 0 THEN
               p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                           vnumerr || '-' || psproces || '-' || s0.sseguro || '-' || v_numrec
                           || '-' || xtipomovimiento || '-' || pmodo || '-' || xcmodcom || '-'
                           || f_sysdate || '-' || s0.fefecto || '-' || xfvencim || '-' || NULL
                           || '-' || piimprec || '-' || NULL || '-' || xnmovimi || '-' || NULL
                           || '-' || vimport || '-' || NULL || '-' || NULL || '-' || NULL || '-'
                           || NULL || '-' || 400 || '-' || ptablas);
               RETURN vnumerr;
            END IF;
            *********************************************************************************/
            vpasexec := 7;

            -- Ini Bug 25583 -- ECP -- 17/01/2013
            BEGIN
               SELECT ctipcoa
                 INTO xctipcoa
                 FROM recibos
                WHERE nrecibo = v_numrec;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  xctipcoa := 0;
            END;

            BEGIN
               SELECT ncuacoa
                 INTO xncuacoa
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  xncuacoa := 0;
            END;

            IF xctipcoa != 0
            THEN
               BEGIN
                  SELECT ploccoa
                    INTO xploccoa
                    FROM coacuadro
                   WHERE ncuacoa = xncuacoa AND sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     xploccoa := 0;
               END;
            END IF;

            -- Prima Neta
            BEGIN
               vnumerr :=
                  f_insdetrec (v_numrec,
                               0,
                               piimprec,
                               xploccoa,
                               400,
                               1,
                               s0.ctipcoa,
                               NULL,
                               xnmovimi,
                               0,
                               s0.sseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               decimals
                              );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                              );
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                               || SQLERRM
                              );
                  RETURN 103513;
            END;

            --Fin Bug 25583 -- ECP -- 17/01/2013
            vpasexec := 8;

---------------------------------------------------------------------
            -- Bug 26060 - APD - 11/02/2013
            -- Comision
            IF NVL (pac_parametros.f_parproducto_t (s0.sproduc,
                                                    'FVIG_COMISION'
                                                   ),
                    'FEFECTO_REC'
                   ) = 'FEFECTO_REC'
            THEN
               v_fefectovig := NVL (pfefecto, s0.fefecto);
            --Efecto del recibo
            ELSIF pac_parametros.f_parproducto_t (s0.sproduc, 'FVIG_COMISION') =
                                                                 'FEFECTO_POL'
            THEN                                         --Efecto de la p¿liza
               BEGIN
                  IF ptablas = 'EST'
                  THEN
                     SELECT TO_DATE (crespue, 'YYYYMMDD')
                       INTO v_fefectovig
                       FROM estpregunpolseg
                      WHERE sseguro = psseguro
                        AND nmovimi = (SELECT MAX (p.nmovimi)
                                         FROM estpregunpolseg p
                                        WHERE p.sseguro = psseguro)
                        AND cpregun = 4046;
                  ELSE
                     SELECT TO_DATE (crespue, 'YYYYMMDD')
                       INTO v_fefectovig
                       FROM pregunpolseg
                      WHERE sseguro = psseguro
                        AND nmovimi = (SELECT MAX (p.nmovimi)
                                         FROM pregunpolseg p
                                        WHERE p.sseguro = psseguro)
                        AND cpregun = 4046;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     v_fefectovig := s0.fefecto;
               END;
            ELSIF pac_parametros.f_parproducto_t (s0.sproduc, 'FVIG_COMISION') =
                                                              'FEFECTO_RENOVA'
            THEN                                     -- efecto a la renovacion
               IF ptablas = 'EST'
               THEN
                  v_fefectovig :=
                        TO_DATE (frenovacion (NULL, psseguro, 1), 'yyyymmdd');
               ELSE
                  v_fefectovig :=
                        TO_DATE (frenovacion (NULL, psseguro, 2), 'yyyymmdd');
               END IF;
            END IF;

            vpasexec := 10;
            xfecvig := v_fefectovig;
            vnumerr :=
               f_pcomisi (psseguro,
                          xcmodcom,
                          f_sysdate,
                          vpcomisi,
                          vpretenc,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ptablas,
                          'CAR',
                          xfecvig
                         );

            IF vnumerr <> 0
            THEN
               RETURN vnumerr;
            END IF;

            vpasexec := 15;

            -- Se inserta el detalle de comision
            BEGIN
               importecomisi :=
                  f_round (((NVL (piimprec, 0) * NVL (vpcomisi, 0)) / 100),
                           decimals
                          );
               vpasexec := 20;
               vnumerr :=
                  f_insdetrec (v_numrec,
                               11,
                               importecomisi,
                               0,
                               400,
                               1,
                               0,
                               NULL,
                               xnmovimi,
                               0,
                               s0.sseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               decimals
                              );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                              );
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                               || SQLERRM
                              );
                  RETURN 103513;
            END;

            -- fin Bug 26060 - APD - 11/02/2013
---------------------------------------------------------------------
            vpasexec := 25;

            -- Bug 23853 - RSC - 17/12/201
            IF pctiprec = 0
            THEN                                           -- Nueva produccion
               v_primadev := piimprec * s0.cforpag;
            END IF;

            -- Fin bug 23853

            -- Prima Devengada
            /*BEGIN
               vnumerr := f_insdetrec(v_numrec, 21, v_primadev, xploccoa, 400, 1, s0.ctipcoa,
                                      NULL, xnmovimi, 0, s0.sseguro, 1, NULL, NULL, NULL,
                                      decimals);

               IF vnumerr <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                              vnumerr || '-' || s0.sseguro || '-' || v_numrec || '-'
                              || s0.ctipcoa || '-' || xnmovimi || '-' || decimals);
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                              s0.sseguro || '-' || v_numrec || '-' || s0.ctipcoa || '-'
                              || xnmovimi || '-' || decimals || SQLERRM);
                  RETURN 103513;
            END;*/

            --Fin Bug 25583 -- ECP -- 17/01/2013
            vpasexec := 30;
            vnumerr := f_vdetrecibos (pmodo, v_numrec, psproces);

            IF vnumerr <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam,
                               vnumerr
                            || '-'
                            || pmodo
                            || '-'
                            || v_numrec
                            || '-'
                            || psproces
                           );
               RETURN vnumerr;
            END IF;

            vpasexec := 31;

            -- Bug 26022 - APD - 20/02/2013 - si la poliza tiene corretaje se debe
            -- realizar el reparto del corretaje al recibo de prima minima
            IF pac_corretaje.f_tiene_corretaje (s0.sseguro, NULL) = 1
            THEN
               vnumerr :=
                  pac_corretaje.f_reparto_corretaje (s0.sseguro,
                                                     xnmovimi,
                                                     v_numrec
                                                    );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || xnmovimi
                               || '-'
                               || v_numrec
                               || '-'
                               || psproces
                               || '-'
                               || pmodo
                               || '-'
                               || 'CERTIF0'
                              );
                  RETURN vnumerr;
               END IF;
            END IF;

            -- fin Bug 26022 - APD - 20/02/2013
            vpasexec := 35;

            IF pac_retorno.f_tiene_retorno (NULL, s0.sseguro, NULL, ptablas) =
                                                                             1
            THEN
               vnumerr :=
                  pac_retorno.f_generar_retorno (s0.sseguro,
                                                 xnmovimi,
                                                 v_numrec,
                                                 psproces,
                                                 pmodo,
                                                 'CERTIF0'
                                                );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || xnmovimi
                               || '-'
                               || v_numrec
                               || '-'
                               || psproces
                               || '-'
                               || pmodo
                               || '-'
                               || 'CERTIF0'
                              );
                  RETURN vnumerr;
               END IF;
            END IF;
         END LOOP;

         -- Bug 23853 - APD - 07/01/2013 - se devuelve el nrecibo como parametro de salida
         pnrecibo := v_numrec;
      -- fin Bug 23853 - APD - 07/01/2013
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9903386;
   END f_genrec_primin_col;

   FUNCTION f_desctiprec (pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2
   IS
      vnumerr    NUMBER;
      vpasexec   NUMBER (8)              := 0;
      vparam     VARCHAR2 (1500)
         := 'par¿metros - pnrecibo: ' || pnrecibo || ', pcidioma: '
            || pcidioma;
      vobject    VARCHAR2 (200)          := 'PAC_GESTION_REC.F_DESCTIPREC';
      v_texto    VARCHAR2 (500)          := NULL;
      v_desc     garangen.tgarant%TYPE;
--       v_desc         VARCHAR2(500); --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
   BEGIN
      -- Miramos si el recibo es de agrupaci¿n
      SELECT DECODE (COUNT (1),
                     0, NULL,
                     f_axis_literales (9904025, pcidioma)
                    )
        INTO v_desc
        FROM adm_recunif a
       WHERE a.nrecunif = pnrecibo;

      IF v_desc IS NOT NULL
      THEN
         IF v_texto IS NOT NULL
         THEN
            v_texto := v_texto || ' - ';
         END IF;

         v_texto := v_texto || v_desc;
         RETURN v_texto;
      END IF;

      -- Miramos si el recibo es de Prima M¿nima
      BEGIN
         SELECT DISTINCT g.tgarant
                    INTO v_desc
                    FROM detrecibos d, garangen g, vdetrecibos v
                   WHERE d.nrecibo = pnrecibo
                     AND d.cgarant = 400
                     AND g.cgarant = d.cgarant
                     AND g.cidioma = pcidioma
                     AND d.nrecibo = v.nrecibo
                     AND d.iconcep = v.itotalr;
      EXCEPTION
         WHEN OTHERS
         THEN
            v_desc := NULL;
      END;

      IF v_desc IS NOT NULL
      THEN
         IF v_texto IS NOT NULL
         THEN
            v_texto := v_texto || ' - ';
         END IF;

         v_texto := v_texto || v_desc;
      END IF;

      -- Miramos si el recibo es de Gastos de Expedici¿n.
      BEGIN
         SELECT f_axis_literales (9902596, pcidioma)
           INTO v_desc
           FROM recibos r, detrecibos d, garanseg g, vdetrecibos v
          WHERE r.nrecibo = pnrecibo
            AND r.nrecibo = d.nrecibo
            AND r.sseguro = g.sseguro
            AND r.nmovimi = g.nmovimi
            AND d.cgarant = g.cgarant
            AND d.nriesgo = g.nriesgo
            AND d.cgarant = g.cgarant
            AND d.cconcep = 14
            AND r.nrecibo = v.nrecibo
            AND d.iconcep = v.itotalr;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_desc := NULL;
      END;

      IF v_desc IS NOT NULL
      THEN
         IF v_texto IS NOT NULL
         THEN
            v_texto := v_texto || ' - ';
         END IF;

         v_texto := v_texto || v_desc;
      END IF;

      -- Agrupado en recibo
      SELECT DECODE (COUNT (1),
                     0, NULL,
                     f_axis_literales (9904103, pcidioma)
                    )
        INTO v_desc
        FROM adm_recunif a
       WHERE a.nrecibo = pnrecibo;

      IF v_desc IS NOT NULL
      THEN
         IF v_texto IS NOT NULL
         THEN
            v_texto := v_texto || ' - ';
         END IF;

         v_texto := v_texto || v_desc;
      END IF;

      RETURN v_texto;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN '**';
   END f_desctiprec;

-- BUG23853:DRA:25/10/2012:Fi

   -- 23074 - JLB: 17/12/2012
   FUNCTION f_genrec_gastos_expedicion (
      psseguro   IN       NUMBER,
      pnmovimi   IN       NUMBER,
      pctiprec   IN       NUMBER,
      pfemisio   IN       DATE,
      pfefecto   IN       DATE,
      pfvencim   IN       DATE,
      piimprec   IN       NUMBER,
      pnrecibo   IN OUT   NUMBER,
      pmodo      IN       VARCHAR2,
      psproces   IN       NUMBER,
      ptablas    IN       VARCHAR2 DEFAULT 'SEG'
   )
      RETURN NUMBER
   IS
      --
      vnumerr           NUMBER (8)                 := 0;
      vpasexec          NUMBER (8)                 := 0;
      v_max_reg         NUMBER;         -- n¿mero m¿xim de registres mostrats
      vparam            VARCHAR2 (1500)
         :=    'par¿metros - psseguro: '
            || psseguro
            || ', pnmovimi: '
            || pnmovimi
            || ', pctiprec: '
            || pctiprec
            || ', piimprec: '
            || piimprec
            || ', pnrecibo: '
            || pnrecibo
            || ', pfemisio: '
            || pfemisio
            || ', pfefecto: '
            || pfefecto
            || ', pfvencim: '
            || pfvencim
            || ', pmodo: '
            || pmodo
            || ', psproces: '
            || psproces
            || ', ptablas: '
            || ptablas;
      vobject           VARCHAR2 (200)
                               := 'PAC_GESTION_REC.f_genrec_gastos_expedicion';
      v_numrec          recibos.nrecibo%TYPE;
      xnbancarf         seguros.cbancar%TYPE;
      xtbancar          seguros.cbancar%TYPE;
      xnmovimi          movseguro.nmovimi%TYPE;
      dummy             NUMBER;
      xcestaux          recibos.cestaux%TYPE;
      xctiprec          recibos.ctiprec%TYPE;
      xfvencim          recibos.fvencim%TYPE;
      xcperven          NUMBER;
      xnperven          recibos.nperven%TYPE;
      xcgescob          recibos.cgescob%TYPE;
      xcmanual          recibos.cmanual%TYPE;
      xcestimp          recibos.cestimp%TYPE;
      xsperson          tomadores.sperson%TYPE;
      xctipban          per_ccc.ctipban%TYPE;
      xcbancar          per_ccc.cbancar%TYPE;
      xcbancob          parempresas.nvalpar%TYPE;
      xtipomovimiento   NUMBER;
      xcmodcom          NUMBER (1);
      xctipcoa          recibos.ctipcoa%TYPE;
--       xctipcoa       NUMBER(1);   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xncuacoa          seguros.ncuacoa%TYPE;
--       xncuacoa       NUMBER(2);   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      xploccoa          coacuadro.ploccoa%TYPE     := 0;
-- Bug 25583 -- ECP -- 17/01/2013   --       xploccoa       NUMBER(5, 2) := 0;   -- Bug 25583 -- ECP -- 17/01/2013 --- BUG 25803: DECIMALES Y OTROS CAMPOS ---
      vimport           NUMBER;
      decimals          NUMBER                     := 0;
      vcgarant          garanseg.cgarant%TYPE;
      -- Bug 25583 - RSC - 11/01/2013
      v_exist_rec       NUMBER;
   -- Fin Bug 25583
   BEGIN
      vpasexec := 1;

      IF NVL (piimprec, 0) <> 0
      THEN
         -- Bug 25583 - RSC - 11/01/2013
         SELECT COUNT (1)
           INTO v_exist_rec
           FROM recibos r, detrecibos d, garanseg g
          WHERE r.sseguro = psseguro
            AND r.nrecibo = d.nrecibo
            AND r.sseguro = g.sseguro
            AND d.cgarant = g.cgarant
            AND d.nriesgo = g.nriesgo
            AND d.cgarant = g.cgarant
            AND d.cconcep = 14
            AND f_cestrec_mv (r.nrecibo, 2) <> 2
            AND (   pctiprec = 0
                 OR (pctiprec <> 0 AND TRUNC (r.femisio) = TRUNC (pfemisio))
                )
            AND d.iconcep <> 0
            AND r.nrecibo NOT IN (SELECT nrecunif
                                    FROM adm_recunif);

         IF v_exist_rec > 0
         THEN
            RETURN 0;
         END IF;

         -- Fin bug 25583
         FOR s0 IN (SELECT s.sseguro, s.cempres, s.ctipban, s.cbancar,
                           s.cagente, s.ccobban, s.fefecto, s.cforpag,
                           s.ctipcob, s.nanuali, s.nfracci, s.ctipcoa,
                           s.sproduc, s.fcaranu
                      FROM seguros s
                     WHERE s.sseguro = psseguro AND ptablas = 'SEG'
                    UNION ALL
                    SELECT s.sseguro, s.cempres, s.ctipban, s.cbancar,
                           s.cagente, s.ccobban, s.fefecto, s.cforpag,
                           s.ctipcob, s.nanuali, s.nfracci, s.ctipcoa,
                           s.sproduc, s.fcaranu
                      FROM estseguros s
                     WHERE s.sseguro = psseguro AND ptablas = 'EST')
         LOOP
            BEGIN
               SELECT pac_monedas.f_moneda_divisa (cdivisa)
                 -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               INTO   decimals
                 FROM productos
                WHERE sproduc = s0.sproduc;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  RETURN 104347;            -- Producte no trobat a PRODUCTOS
               WHEN OTHERS
               THEN
                  RETURN 102705;              -- Error al llegir de PRODUCTOS
            END;

            -- <BUSCAR LOS DATOS BANCARIOS POR DEFECTO DEL BENEFICIARIO>
            vpasexec := 2;
            xnmovimi := pnmovimi;
            xctiprec := pctiprec;
            xfvencim := ADD_MONTHS (NVL (pfefecto, s0.fefecto), 12);
            vpasexec := 3;

            BEGIN
               vnumerr :=
                  f_insrecibo (s0.sseguro,
                               s0.cagente,
                               NVL (pfemisio, f_sysdate),
                               NVL (pfefecto, s0.fefecto),
                               NVL (pfvencim, xfvencim),
                               xctiprec,
                               s0.nanuali,
                               s0.nfracci,
                               s0.ccobban,
                               NULL,
                               NULL,
                               v_numrec,
                               pmodo,
                               psproces,
                               NULL,
                               xnmovimi,
                               f_sysdate,
                               'CERTIF0',
                               s0.cforpag,
                               s0.cbancar,
                               ptablas,
                               'CAR',
                               s0.ctipban
                              );

               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || s0.cagente
                               || '-'
                               || f_sysdate
                               || '-'
                               || s0.fefecto
                               || '-'
                               || xfvencim
                               || '-'
                               || xctiprec
                               || '-'
                               || s0.nanuali
                               || '-'
                               || s0.nfracci
                               || '-'
                               || s0.ccobban
                               || '-'
                               || NULL
                               || '-'
                               || NULL
                               || '-'
                               || v_numrec
                               || '-'
                               || pmodo
                               || '-'
                               || psproces
                               || '-'
                               || NULL
                               || '-'
                               || xnmovimi
                               || '-'
                               || f_sysdate
                               || '-'
                               || 'CERTIF0'
                               || '-'
                               || s0.cforpag
                               || '-'
                               || s0.cbancar
                               || '-'
                               || ptablas
                               || '-'
                               || 'CAR'
                               || '-'
                               || s0.ctipban
                              );
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || s0.cagente
                               || '-'
                               || f_sysdate
                               || '-'
                               || s0.fefecto
                               || '-'
                               || xfvencim
                               || '-'
                               || xctiprec
                               || '-'
                               || s0.nanuali
                               || '-'
                               || s0.nfracci
                               || '-'
                               || s0.ccobban
                               || '-'
                               || NULL
                               || '-'
                               || NULL
                               || '-'
                               || v_numrec
                               || '-'
                               || pmodo
                               || '-'
                               || psproces
                               || '-'
                               || NULL
                               || '-'
                               || xnmovimi
                               || '-'
                               || f_sysdate
                               || '-'
                               || 'CERTIF0'
                               || '-'
                               || s0.cforpag
                               || '-'
                               || s0.cbancar
                               || '-'
                               || ptablas
                               || '-'
                               || 'CAR'
                               || '-'
                               || s0.ctipban
                               || '-'
                               || SQLERRM
                              );
                  RETURN 103847;
            END;

            vpasexec := 4;

            IF xnmovimi = 1
            THEN
               xtipomovimiento := 0;
            ELSIF xnmovimi > 1
            THEN
               xtipomovimiento := 1;
            END IF;

            vpasexec := 5;

            IF f_es_renovacion (s0.sseguro) = 0
            THEN                                                 -- es cartera
               xcmodcom := 2;
            ELSE                                -- si es 1 es nueva produccion
               xcmodcom := 1;
            END IF;

            vpasexec := 61;

            -- Prima Neta
            BEGIN
               ---Ini-AMA-509-VCG
               IF ptablas = 'EST'
               THEN
                  BEGIN
                     SELECT cgarant
                       INTO vcgarant
                       FROM estgaranseg
                      WHERE cobliga = 1
                        AND cderreg = 1
                        AND sseguro = s0.sseguro
                        AND nriesgo = 1
                        AND ffinefe IS NULL
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           SELECT imp.cgarant
                             INTO vcgarant
                             FROM imprec imp, productos p, estseguros s
                            WHERE imp.cconcep = 14
                              AND s.sproduc = p.sproduc
                              AND s.sseguro = s0.sseguro
                              AND p.cramo = imp.cramo
                              AND p.ccolect = imp.ccolect
                              AND p.ctipseg = imp.ctipseg
                              AND p.cmodali = imp.cmodali;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              vcgarant := 0;
                        END;
                  END;
               ELSE
                  BEGIN
                     SELECT cgarant
                       INTO vcgarant
                       FROM garanseg
                      WHERE cderreg = 1
                        AND sseguro = s0.sseguro
                        AND nriesgo = 1
                        AND ffinefe IS NULL
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN
                           SELECT imp.cgarant
                             INTO vcgarant
                             FROM imprec imp, productos p, seguros s
                            WHERE imp.cconcep = 14
                              AND s.sproduc = p.sproduc
                              AND s.sseguro = s0.sseguro
                              AND p.cramo = imp.cramo
                              AND p.ccolect = imp.ccolect
                              AND p.ctipseg = imp.ctipseg
                              AND p.cmodali = imp.cmodali;
                        EXCEPTION
                           WHEN NO_DATA_FOUND
                           THEN
                              vcgarant := 0;
                        END;
                  END;
               END IF;

               --Fin-AMA-509-VCG

               -- Ini Bug 25583 -- ECP -- 17/01/2013
               BEGIN
                  SELECT ctipcoa
                    INTO xctipcoa
                    FROM recibos
                   WHERE nrecibo = v_numrec;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     xctipcoa := 0;
               END;

               BEGIN
                  SELECT ncuacoa
                    INTO xncuacoa
                    FROM seguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     xncuacoa := 0;
               END;

               IF xctipcoa != 0
               THEN
                  BEGIN
                     SELECT ploccoa
                       INTO xploccoa
                       FROM coacuadro
                      WHERE ncuacoa = xncuacoa AND sseguro = psseguro;
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        xploccoa := 0;
                  END;
               END IF;

               -- Ini Bug 25583 -- ECP -- 07/02/2013  se cambia xploccoa por 0
               vnumerr :=
                  f_insdetrec (v_numrec,
                               14,
                               piimprec,
                               100,
                               vcgarant,
                               1,
                               s0.ctipcoa,
                               NULL,
                               xnmovimi,
                               0,
                               s0.sseguro,
                               1,
                               NULL,
                               NULL,
                               NULL,
                               decimals
                              );

               -- Fin Bug 25583 -- ECP -- 07/02/2013
               IF vnumerr <> 0
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  vnumerr
                               || '-'
                               || s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                              );
                  RETURN vnumerr;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  p_tab_error (f_sysdate,
                               f_user,
                               vobject,
                               vpasexec,
                               vparam,
                                  s0.sseguro
                               || '-'
                               || v_numrec
                               || '-'
                               || s0.ctipcoa
                               || '-'
                               || xnmovimi
                               || '-'
                               || decimals
                               || SQLERRM
                              );
                  RETURN 103513;
            END;

            -- Fin Bug 25583 -- ECP -- 17/01/2013
            vpasexec := 62;
            vnumerr := f_vdetrecibos (pmodo, v_numrec, psproces);

            IF vnumerr <> 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobject,
                            vpasexec,
                            vparam,
                               vnumerr
                            || '-'
                            || pmodo
                            || '-'
                            || v_numrec
                            || '-'
                            || psproces
                           );
               RETURN vnumerr;
            END IF;

            vpasexec := 8;
         /*vnumerr := pac_retorno.f_generar_retorno(s0.sseguro, xnmovimi, v_numrec, psproces,
                                                  pmodo, 'CERTIF0');

         IF vnumerr <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam,
                        vnumerr || '-' || s0.sseguro || '-' || xnmovimi || '-' || v_numrec
                        || '-' || psproces || '-' || pmodo || '-' || 'CERTIF0');
            RETURN vnumerr;
         END IF;*/
         END LOOP;

         pnrecibo := v_numrec;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9903386;
   END f_genrec_gastos_expedicion;

   -- Bug 27057/0145439 - APD - 04/06/2013 - se crea la funcion
   FUNCTION f_borra_recibo (pnrecibo IN NUMBER, pmodo IN VARCHAR2 DEFAULT 'R')
      RETURN NUMBER
   IS
      --
      vnumerr    NUMBER (8)      := 0;
      vpasexec   NUMBER (8)      := 0;
      vparam     VARCHAR2 (1500)
             := 'par¿metros - pnrecibo: ' || pnrecibo || ', pmodo: ' || pmodo;
      vobject    VARCHAR2 (200)  := 'PAC_GESTION_REC.f_borra_recibo';
   BEGIN
      IF pmodo IN ('R', 'A', 'ANP', 'I', 'H', 'RRIE')
      THEN
         vpasexec := 10;

         -- 33. 0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Inicio
         DELETE FROM agd_movobs
               WHERE (cempres, idobs) IN (SELECT cempres, idobs
                                            FROM agd_observaciones
                                           WHERE nrecibo = pnrecibo);

         DELETE FROM agd_obs_vision
               WHERE (cempres, idobs) IN (SELECT cempres, idobs
                                            FROM agd_observaciones
                                           WHERE nrecibo = pnrecibo);

         -- 33. 0028206: LCOL_PROD-Revision de mensajes en TxNoPago y otros package - Final
         DELETE FROM agd_observaciones
               WHERE nrecibo = pnrecibo;

         vpasexec := 20;

         DELETE FROM comrecibo
               WHERE nrecibo = pnrecibo;

         vpasexec := 30;

         DELETE FROM detrecibos
               WHERE nrecibo = pnrecibo;

         vpasexec := 40;

         DELETE FROM domiciliaciones
               WHERE nrecibo = pnrecibo;

         vpasexec := 50;

         DELETE FROM hisrecibos
               WHERE nrecibo = pnrecibo;

         vpasexec := 60;

         DELETE FROM liquidalin
               WHERE nrecibo = pnrecibo;

         vpasexec := 70;

         DELETE FROM detmovrecibo
               WHERE nrecibo = pnrecibo;

         vpasexec := 80;

         DELETE FROM ctacoaseguro
               WHERE nrecibo = pnrecibo;

         vpasexec := 90;

         DELETE FROM movrecibo
               WHERE nrecibo = pnrecibo;

         vpasexec := 100;

         DELETE FROM notificaciones
               WHERE nrecibo = pnrecibo;

         vpasexec := 110;

         DELETE FROM recibos_comp
               WHERE nrecibo = pnrecibo;

         vpasexec := 120;

         DELETE FROM recibosredcom
               WHERE nrecibo = pnrecibo;

         vpasexec := 130;

         DELETE FROM remuneracion_canal_rec
               WHERE nrecibo = pnrecibo;

         vpasexec := 140;

         DELETE FROM tmp_impagados
               WHERE nrecibo = pnrecibo;

         vpasexec := 150;

         DELETE FROM adm_recunif
               WHERE nrecibo = pnrecibo;

         vpasexec := 160;

         DELETE FROM adm_recunif
               WHERE nrecunif = pnrecibo;

         vpasexec := 170;

         DELETE FROM adm_recunif_his
               WHERE nrecibo = pnrecibo;

         vpasexec := 180;

         DELETE FROM adm_recunif_his
               WHERE nrecunif = pnrecibo;

         vpasexec := 190;

         DELETE FROM cartaavis
               WHERE nrecibo = pnrecibo;

         vpasexec := 200;

         DELETE FROM ctaseguro
               WHERE nrecibo = pnrecibo;

         vpasexec := 204;

         DELETE FROM ctaseguro_shadow
               WHERE nrecibo = pnrecibo;

         vpasexec := 210;

         DELETE FROM ctactes
               WHERE nrecibo = pnrecibo;

         vpasexec := 220;

         DELETE FROM ctactes_previo
               WHERE nrecibo = pnrecibo;

         vpasexec := 230;

         DELETE FROM detrecmovsegurocol
               WHERE nrecibo = pnrecibo;

         vpasexec := 240;

         DELETE FROM devbanrecibos
               WHERE nrecibo = pnrecibo;

         vpasexec := 250;

         DELETE FROM docsimpresion
               WHERE nrecibo = pnrecibo;

         vpasexec := 260;

         DELETE FROM doc_diferida
               WHERE nrecibo = pnrecibo;

         vpasexec := 270;
         --
         -- Inicio IAXIS-7983 12/12/2019
         --
         vpasexec := 275;
         
         DELETE FROM his_comrecibo 
               WHERE nrecibo = pnrecibo;
         --
         -- Fin IAXIS-7983 12/12/2019
         --
         DELETE FROM his_recibos
               WHERE nrecibo = pnrecibo;

         vpasexec := 280;
-- JLB - I - 26050 - optimizacion
         --DELETE FROM int_carga_ctrl_linea
          --     WHERE nrecibo = pnrecibo;
-- JLB - F - 26050
         vpasexec := 290;

         DELETE FROM reasegemi
               WHERE nrecibo = pnrecibo;

         vpasexec := 380;

         DELETE FROM reaseguro
               WHERE nrecibo = pnrecibo;

         vpasexec := 390;

         DELETE FROM reaseguroaux
               WHERE nrecibo = pnrecibo;

         vpasexec := 400;

         DELETE FROM recibosclon
               WHERE nreciboant = pnrecibo;

         vpasexec := 410;

         DELETE FROM recibosclon
               WHERE nreciboact = pnrecibo;

         vpasexec := 420;

         DELETE FROM remesas
               WHERE nrecibo = pnrecibo;

         vpasexec := 430;

         DELETE FROM remesas_previo
               WHERE nrecibo = pnrecibo;

         vpasexec := 440;

         DELETE FROM rtn_recretorno
               WHERE nrecibo = pnrecibo;

         vpasexec := 450;

         DELETE FROM traspacarage
               WHERE nrecibo = pnrecibo;

         vpasexec := 460;

         DELETE FROM vdetrecibos_monpol
               WHERE nrecibo = pnrecibo;

         vpasexec := 470;

         DELETE FROM contab_asient_interf
               WHERE idpago = pnrecibo;

         vpasexec := 480;

         DELETE FROM estado_proc_recibos
               WHERE npago = pnrecibo;

         vpasexec := 490;

         DELETE FROM vdetrecibos
               WHERE nrecibo = pnrecibo;

         vpasexec := 500;

         DELETE FROM recibos
               WHERE nrecibo = pnrecibo;
      ELSIF pmodo IN ('P', 'N', 'PRIE')
      THEN
         vpasexec := 100;

         DELETE FROM vdetreciboscar_monpol
               WHERE nrecibo = pnrecibo;

         vpasexec := 200;

         DELETE FROM vdetreciboscar
               WHERE nrecibo = pnrecibo;

         vpasexec := 300;

         DELETE FROM reciboscar
               WHERE nrecibo = pnrecibo;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 105115;
   END f_borra_recibo;

   -- BUG 29009 -- ETM -- 25/11/2013 -- INI
   FUNCTION f_recman_pens (
      psseguro   IN   NUMBER,
      pnmovimi   IN   NUMBER,
      pctiprec   IN   NUMBER,
      pimporte   IN   NUMBER,
      pctipcob   IN   NUMBER
   )
      RETURN NUMBER
   IS
      num_err        NUMBER                    := 0;
      vobjectname    VARCHAR2 (500)        := 'PAC_GESTION_REC.F_RECMAN_PENS';
      vparam         VARCHAR2 (500)
         :=    'par¿metros - psseguro: '
            || psseguro
            || ',pnmovimi:='
            || pnmovimi
            || ',pctiprec:='
            || pctiprec
            || ',pimporte:='
            || pimporte
            || ',pctipcob:='
            || pctipcob;
      vnrecibo_aux   recibos.nrecibo%TYPE;
      v_cagrpro      seguros.cagrpro%TYPE;
      v_ctipcob      seguros.ctipcob%TYPE;
      v_tipocert     VARCHAR2 (100);
      v_cempres      empresas.cempres%TYPE;
      lsproces       NUMBER;
      vpcomisi       NUMBER                    := 0;
      vpretenc       NUMBER                    := 0;
      v_ctiprec      NUMBER;
      v_xcmodcom     NUMBER;
      vtraza         NUMBER                    := 1;
      salir          EXCEPTION;
      vcmoneda       codidivisa.cmoneda%TYPE;
      v_sproces      NUMBER                    := 1;
      reg_seg        seguros%ROWTYPE;
      vfvencim       DATE;
      vfefecto       DATE;
      v_cont         NUMBER                    := 0;
      v_cgarant      detrecibos.cgarant%TYPE;
      v_situac       seguros.csituac%TYPE;
      v_cidioma      seguros.cidioma%TYPE;
      v_ctipcoa      seguros.ctipcoa%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
   BEGIN
      BEGIN
         SELECT s.cagrpro, DECODE (s.ncertif, 0, 'CERTIF0', NULL),
                s.csituac, NVL (ctipcob, 0), cidioma, NVL (ctipcoa, 0),
                sproduc                                           --detvalores
           INTO v_cagrpro, v_tipocert,
                v_situac, v_ctipcob, v_cidioma, v_ctipcoa,
                v_sproduc
           FROM seguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_cagrpro := 0;
      END;

      IF v_situac <> 0
      THEN
         p_tab_error
                 (f_sysdate,
                  f_user,
                  vobjectname,
                  vtraza,
                  vparam,
                     'Solo se pueden realizar apuntes de una poliza vigente '
                  || SQLERRM
                 );
         RETURN 120129;
      END IF;

      vtraza := 2;

      IF (v_cagrpro NOT IN (10, 22)) AND v_ctipcoa <> 8
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             vobjectname,
             vtraza,
             vparam,
                'Solo se pueden realizar apuntes de un producto que no sea del ramo pesional '
             || SQLERRM
            );
         RETURN 9906307;
      ELSIF (v_cagrpro = 22 AND v_tipocert <> 'CERTIF0') AND v_ctipcoa <> 8
      THEN
         p_tab_error
            (f_sysdate,
             f_user,
             vobjectname,
             vtraza,
             vparam,
                'Solo se pueden realizar apuntes de un producto que no sea del ramo pesional '
             || SQLERRM
            );
         RETURN 9906307;    --nose puede realizar un apunte para este producto
      END IF;

      v_cempres := pac_md_common.f_get_cxtempresa ();

      SELECT COUNT (*)
        INTO v_cont
        FROM recibos
       WHERE nmovimi = pnmovimi
         AND cempres = v_cempres
         AND sseguro = psseguro
         AND NVL (f_cestrec_mv (nrecibo, v_cidioma, f_sysdate), 0) <> 2;

      IF v_cont <> 0 AND v_ctipcoa <> 8
      THEN
         RETURN 9906321;
      END IF;

      vtraza := 3;

      SELECT *
        INTO reg_seg
        FROM seguros
       WHERE sseguro = psseguro;

      vtraza := 4;

      BEGIN
         SELECT pac_monedas.f_moneda_producto (sproduc)
           INTO vcmoneda
           FROM productos
          WHERE cramo = reg_seg.cramo
            AND cmodali = reg_seg.cmodali
            AND ctipseg = reg_seg.ctipseg
            AND ccolect = reg_seg.ccolect;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            num_err := 104347;              -- Producte no trobat a PRODUCTOS
            RAISE salir;
         WHEN OTHERS
         THEN
            num_err := 102705;                -- Error al llegir de PRODUCTOS
            RAISE salir;
      END;

      vtraza := 5;

      IF pctipcob <> v_ctipcob
      THEN
         UPDATE seguros
            SET ctipcob = pctipcob
          WHERE sseguro = psseguro;
      END IF;

      vtraza := 6;

      BEGIN
         vfvencim := f_sysdate + 1;

         IF pctiprec = 0
         THEN                   --la pantalla eligieron apunte de tipo RECIBO
            v_ctiprec := 1;
         ELSE
            v_ctiprec := 9;                                         --extorno
         END IF;

         vtraza := 7;
         num_err :=
            f_insrecibo (psseguro,
                         NULL,
                         TRUNC (f_sysdate),
                         TRUNC (NVL (vfefecto, f_sysdate)),
                         TRUNC (vfvencim),
                         v_ctiprec,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         vnrecibo_aux,
                         'R',
                         NULL,
                         NULL,
                         pnmovimi,
                         f_sysdate,
                         v_tipocert
                        );

         IF num_err NOT IN (0, 103108)
         THEN
            RAISE salir;
         END IF;

         vtraza := 8;
      EXCEPTION
         WHEN OTHERS
         THEN
            num_err := 105156;
            RAISE salir;
      END;

      IF v_ctipcoa <> 8
      THEN
         UPDATE recibos
            SET cestaux = 0
          WHERE nrecibo = vnrecibo_aux;
      END IF;

      vtraza := 8;

      -- INSERTAR CONCEPTO 0 Y 21 CON EL IMPORTE DE PANTALLA
      IF v_ctipcoa <> 8
      THEN
         v_cgarant :=
            NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                'CGARANT_RECMAN_PENS'
                                               ),
                 0
                );
      ELSE
         BEGIN
            SELECT MAX (cgarant)
              INTO v_cgarant
              FROM garanpro
             WHERE sproduc = v_sproduc AND cbasica = 1;
         EXCEPTION
            WHEN OTHERS
            THEN
               v_cgarant := 0;
         END;
      END IF;

      IF v_cgarant = 0
      THEN
         num_err := 9903335;                 --Error al comprobar la garant¿a
         RAISE salir;
      END IF;

      BEGIN
         INSERT INTO detrecibos
                     (nrecibo, cconcep, cgarant, nriesgo, iconcep
                     )
              VALUES (vnrecibo_aux, 0, v_cgarant, 1, pimporte
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            num_err := 9906311;
            RAISE salir;
      END;

      vtraza := 9;

      BEGIN
         INSERT INTO detrecibos
                     (nrecibo, cconcep, cgarant, nriesgo, iconcep
                     )
              VALUES (vnrecibo_aux, 21, v_cgarant, 1, pimporte
                     );
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX
         THEN
            num_err := 9906311;
            RAISE salir;
      END;

      vtraza := 10;

      -- INSERTAR CONCEPTO 11 Y 15 CON EL IMPORTE DE LA F_PCOMISI
      IF f_es_renovacion (psseguro) = 0
      THEN                                                       -- es cartera
         v_xcmodcom := 2;
      ELSE                                      -- si es 1 es nueva produccion
         v_xcmodcom := 1;
      END IF;

      vtraza := 11;
      num_err :=
               f_pcomisi (psseguro, v_xcmodcom, f_sysdate, vpcomisi, vpretenc);
      vtraza := 12;

      IF num_err = 0
      THEN
         BEGIN
            INSERT INTO detrecibos
                        (nrecibo, cconcep, cgarant, nriesgo,
                         iconcep
                        )
                 VALUES (vnrecibo_aux, 11, v_cgarant, 1,
                         (pimporte * vpcomisi
                         ) / 100
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               num_err := 9906311;
               RAISE salir;
         END;

         vtraza := 13;

         BEGIN
            INSERT INTO detrecibos
                        (nrecibo, cconcep, cgarant, nriesgo,
                         iconcep
                        )
                 VALUES (vnrecibo_aux, 15, v_cgarant, 1,
                         (pimporte * vpcomisi
                         ) / 100
                        );
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX
            THEN
               num_err := 9906311;
               RAISE salir;
         END;
      END IF;

      vtraza := 14;

      DELETE FROM vdetrecibos_monpol
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 15;

      DELETE      vdetrecibos
            WHERE nrecibo = vnrecibo_aux;

      vtraza := 16;
      num_err := f_vdetrecibos ('R', vnrecibo_aux);
      vtraza := 17;

      IF num_err != 0
      THEN
         vtraza := 18;
         RAISE salir;
      END IF;

      vtraza := 19;

      IF pac_corretaje.f_tiene_corretaje (psseguro, pnmovimi) = 1
      THEN
         num_err :=
            pac_corretaje.f_reparto_corretaje (psseguro,
                                               pnmovimi,
                                               vnrecibo_aux
                                              );
      END IF;

      IF num_err != 0
      THEN
         vtraza := 20;
         RAISE salir;
      END IF;

      vtraza := 21;
      num_err :=
         pac_cesionesrea.f_cessio_det (v_sproces,
                                       psseguro,
                                       vnrecibo_aux,
                                       reg_seg.cactivi,
                                       reg_seg.cramo,
                                       reg_seg.cmodali,
                                       reg_seg.ctipseg,
                                       reg_seg.ccolect,
                                       f_sysdate,
                                       vfvencim,
                                       1,
                                       vcmoneda
                                      );
      vtraza := 22;

      IF num_err <> 0
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vtraza,
                      vparam,
                      f_axis_literales (num_err) || SQLERRM
                     );
         RETURN num_err;
      ELSE
         --lo mando a SAP
         IF num_err = 0
         THEN
            IF     NVL (pac_parametros.f_parempresa_n (v_cempres,
                                                       'GESTIONA_COBPAG'
                                                      ),
                        0
                       ) = 1
               AND num_err = 0
            THEN
               num_err :=
                  f_procesini (f_user,
                               v_cempres,
                               'APUNTE RECIBO MANUAL',
                               'Emisi¿n de apunte recibo manual',
                               lsproces
                              );
               num_err :=
                  pac_ctrl_env_recibos.f_proc_recpag_mov (v_cempres,
                                                          psseguro,
                                                          pnmovimi,
                                                          4,
                                                          lsproces
                                                         );

               --Si ha dado error
               IF num_err <> 0
               THEN
                  --ROLLBACK;
                  p_tab_error (f_sysdate,
                               f_user,
                               'APUNTE RECIBO MANUAL',
                               5,
                                  'v_cempres = '
                               || v_cempres
                               || ' psseguro = '
                               || psseguro
                               || ' pnmovimi = '
                               || pnmovimi,
                               num_err
                              );
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_GESTION_REC.F_RECMAN_PENS',
                      vtraza,
                      num_err,
                      f_axis_literales (num_err)
                     );
         ROLLBACK;
         RETURN num_err;
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vtraza,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         ROLLBACK;
         RETURN 9906312;                    ---ERROR AL CREAL EL APUNTE MANUAL
   END f_recman_pens;

-- FIN  BUG 29009 -- ETM -- 25/11/2013

   --BUG 29603 -- JDS -- 21/01/2014
/*******************************************************************************
FUNCION f_desctippag
Funci¿n que devolver¿ el literal del pagador del recibo.
param in pnrecibo
param in pcidioma
********************************************************************************/
   FUNCTION f_desctippag (pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2
   IS
      vobjectname   VARCHAR2 (500)         := 'PAC_GESTION_REC.f_desctippag';
      vparam        VARCHAR2 (500)
         := 'par¿metros - pnrecibo: ' || pnrecibo || ',pcidioma:='
            || pcidioma;
      vtraza        NUMBER (5)             := 1;
      vnumerr       NUMBER                 := 0;
      v_texto       VARCHAR2 (500)         := '';
      v_esccero     recibos.esccero%TYPE;
   BEGIN
      BEGIN
         SELECT NVL (esccero, 0)
           INTO v_esccero
           FROM recibos
          WHERE nrecibo = pnrecibo;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            v_esccero := 0;
      END;

      vtraza := 2;

      IF v_esccero = 1
      THEN
         v_texto := f_axis_literales (9001129, pcidioma);
      ELSE
         v_texto := f_axis_literales (9001047, pcidioma);
      END IF;

      RETURN v_texto;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobjectname,
                      vtraza,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
   END f_desctippag;

-- FIN  BUG 29603 -- JDS -- 21/01/2014
--BUG 0029706: ENSA998-Estancia en Luanda
   FUNCTION f_get_tipo_rec (piidioma IN NUMBER, pnrecibo IN NUMBER)
      RETURN VARCHAR2
   IS
      vtatributmp   VARCHAR2 (2000);
      vtatribufin   VARCHAR2 (2000);
      vcount        NUMBER          := 0;
      vseprator     VARCHAR2 (5);
      vobject       VARCHAR2 (200)  := 'f_get_tipo_rec';
      vcount2       NUMBER;

      CURSOR tiprec
      IS
         SELECT DISTINCT ctiprec
                    FROM recibos a, adm_recunif b, detvalores c
                   WHERE a.nrecibo = b.nrecibo
                     AND nrecunif = pnrecibo
                     AND c.cvalor = 8
                     AND c.cidioma = piidioma
                     AND c.catribu = a.ctiprec;
   BEGIN
      SELECT NVL (COUNT (*), 0)
        INTO vcount2
        FROM adm_recunif
       WHERE nrecunif = pnrecibo;

      IF vcount2 <> 0
      THEN
         FOR c IN tiprec
         LOOP
            SELECT tatribu
              INTO vtatributmp
              FROM detvalores
             WHERE cvalor = 8 AND cidioma = piidioma AND catribu = c.ctiprec;

            IF vcount <> 0
            THEN
               vseprator := ' - ';
            END IF;

            vtatribufin := vtatribufin || vseprator || vtatributmp;
            vcount := vcount + 1;
         END LOOP;
      ELSE
         SELECT DISTINCT c.tatribu
                    INTO vtatribufin
                    FROM recibos a, detvalores c
                   WHERE a.nrecibo = pnrecibo
                     AND c.cvalor = 8
                     AND c.cidioma = piidioma
                     AND c.catribu = a.ctiprec;
      END IF;

      RETURN vtatribufin;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN ' ';
   END;

   -- 39.0 - 02/06/2014 - MMM - 0028551: LCOLF3BADM-Id. 162 - Terminacion por no pago por convenio a nivel de intermediario - Inicio

   /*******************************************************************************
   FUNCION f_get_lista_dias_gracia
   Funcion que devuelve un cursor con los registros de parametrizacion de dias de gracia,
   dado un codigo de agente y producto
   param in pcagente
   param in psproduc
   ********************************************************************************/
   FUNCTION f_get_lista_dias_gracia (pcagente IN NUMBER, psproduc IN NUMBER)
      RETURN sys_refcursor
   IS
      cur        sys_refcursor;
      vpasexec   NUMBER (8)     := 1;
      vparam     VARCHAR2 (200)
                       := 'pcagente=' || pcagente || ' psproduc=' || psproduc;
      vobject    VARCHAR2 (200) := 'PAC_GESTION_REC.f_get_lista_dias_gracia';
   BEGIN
      /* Se deberá retornar los la siguiente información de la parametrizacion de dias de gracia.
          SPRODUCTO    - Código del producto
          TPRODUCTO    - Nombre del producto
          CAGENTE      - Código del agente
          TAGENTE      - Nombre del agente
          FECHA_INI    - Fecha de entrada en vigor de la parametrizacíón
          FECHA_FIN    - Fecha de fin de vigor de la parametrización
          DIAS_GRACIA  - Valor del parámetro de los días de gracis
      */
      BEGIN
         OPEN cur FOR
            SELECT cagente, nombre AS tagente, sproduc AS sproduc,
                   ttitulo AS tproduc, fmovini AS fecha_ini,
                   fmovfin AS fecha_fin, ndias_gracia AS dias_gracia
              FROM (SELECT   pac_redcomercial.ff_desagente
                                       (a.cagente,
                                        pac_md_common.f_get_cxtidioma,
                                        1
                                       ) nombre,
                             p.nnumide, ag.*, t.ttitulo
                        FROM agentes_convenio_prod ag,
                             agentes a,
                             per_personas p,
                             agentes_agente_pol ap,
                             titulopro t,
                             productos pr
                       WHERE a.cagente = ap.cagente
                         AND a.sperson = p.sperson
                         AND ap.cempres = pac_md_common.f_get_cxtempresa
                         AND ag.cagente = a.cagente
                         AND t.cramo = pr.cramo
                         AND t.ccolect = pr.ccolect
                         AND t.ctipseg = pr.ctipseg
                         AND t.cmodali = pr.cmodali
                         AND t.cidioma = pac_md_common.f_get_cxtidioma ()
                         AND NVL (pcagente, ag.cagente) = ag.cagente
                         AND NVL (psproduc, ag.sproduc) = ag.sproduc
                         AND ag.sproduc = pr.sproduc
                    ORDER BY ag.sproduc, ag.cagente, ag.fmovini);

         vpasexec := 2;
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
      END;

      --Retorna un ref_cursor con los registros que cumplan con el criterio
      RETURN cur;
   END f_get_lista_dias_gracia;

   /*******************************************************************************
   FUNCION f_set_dias_gracia_agente_prod
   Funcion que inserta un registro de parametrizacion de dias de gracia, dado un
   agente y producto
   param in pcagente
   param in psproduc
   pfini in DATE
   pdias in NUMBER
   ********************************************************************************/
   FUNCTION f_set_dias_gracia_agente_prod (
      pcagente   IN   NUMBER,
      psproduc   IN   NUMBER,
      pfini      IN   DATE,
      pdias      IN   NUMBER
   )
      RETURN NUMBER
   IS
      vobject    VARCHAR2 (500)
                           := 'pac_gestion_rec.f_set_dias_gracia_agente_prod';
      vparam     VARCHAR2 (550)
         :=    'parámetros - pcagente:'
            || pcagente
            || ' psproduc:'
            || psproduc
            || 'pfini:'
            || pfini
            || ' pdias:'
            || pdias;
      vpasexec   NUMBER (5)     := 1;
      vtmpdate   DATE;
   BEGIN
      -- Comprobamos cual es la fecha de inicio del último registro
      SELECT MAX (fmovini)
        INTO vtmpdate
        FROM agentes_convenio_prod
       WHERE cagente = pcagente AND sproduc = psproduc;

      vpasexec := 2;

      -- 1. Si la fecha que hay en la tabla es posterior a la fecha de inicio que queremos grabar lanzamos error
      -- 2. Si la fecha que hay en la tabla es igual a la que llega como parámetro, actualizamos los días
      -- 3. Si la fecha que hay en la tabla es anterior a la que llega como parámetro, insertamos el nuevo registro
      IF vtmpdate > pfini
      THEN
         RETURN 153037;
      ELSIF vtmpdate = pfini
      THEN
         UPDATE agentes_convenio_prod
            SET ndias_gracia = pdias
          WHERE cagente = pcagente AND sproduc = psproduc AND fmovini = pfini;
      ELSIF vtmpdate IS NULL OR vtmpdate < pfini
      THEN
         -- Insertamos el nuevo registro
         INSERT INTO agentes_convenio_prod
                     (cagente, sproduc, fmovini, fmovfin, ndias_gracia,
                      falta, cusuari
                     )
              VALUES (pcagente, psproduc, pfini, NULL, pdias,
                      f_sysdate, f_user
                     );

         -- Actualizamos la fecha de fin del registro anterior
         UPDATE agentes_convenio_prod
            SET fmovfin = pfini
          WHERE cagente = pcagente AND sproduc = psproduc
                AND fmovini = vtmpdate;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1;
   END f_set_dias_gracia_agente_prod;

   /*******************************************************************************
   FUNCION f_del_dias_gracia_agente_prod
   Funcion que borra un registro de parametrizacion de dias de gracia, dado un
   agente y producto, asi como fecha de inicio
   param in pcagente
   param in psproduc
   pfini in DATE
   ********************************************************************************/
   FUNCTION f_del_dias_gracia_agente_prod (
      pcagente   IN   NUMBER,
      psproduc   IN   NUMBER,
      pfini      IN   DATE
   )
      RETURN NUMBER
   IS
      vobject     VARCHAR2 (500)
                           := 'pac_gestion_rec.f_del_dias_gracia_agente_prod';
      vparam      VARCHAR2 (550)
         :=    'parámetros - pcagente:'
            || pcagente
            || ' psproduc:'
            || psproduc
            || 'pfini:'
            || pfini;
      vpasexec    NUMBER (5)     := 1;
      vtmpdate    DATE;
      vultimo     BOOLEAN;
      vtmptotal   NUMBER;
   BEGIN
      -- Comprobamos que la fecha de fin sea nula y no hay recibos pendientes
      BEGIN
         BEGIN
            SELECT fmovfin
              INTO vtmpdate
              FROM agentes_convenio_prod
             WHERE cagente = pcagente AND sproduc = psproduc
                   AND fmovini = pfini;

            vpasexec := 2;

            IF vtmpdate IS NOT NULL
            THEN
               RETURN 9906282;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               NULL;
         END;

         SELECT COUNT (*)
           INTO vtmptotal
           FROM movrecibo r1
          WHERE r1.nrecibo IN (
                   SELECT r2.nrecibo
                     FROM recibos r2, seguros s
                    WHERE r2.sseguro = s.sseguro
                      AND s.cagente = pcagente
                      AND s.sproduc = psproduc)
            AND NVL (f_cestrec (r1.nrecibo, TRUNC (f_sysdate)), 0) = 0;

         vpasexec := 3;

         IF vtmptotal > 0
         THEN
            RETURN 9906281;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            RETURN 1000402;
      END;

      vpasexec := 4;

      -- Buscamos la fecha de inicio del último registro que haya para el agente / producto
      SELECT MAX (fmovini)
        INTO vtmpdate
        FROM agentes_convenio_prod
       WHERE cagente = pcagente AND sproduc = psproduc;

      vpasexec := 5;

      -- Comprobamos si el que vamos a borrar es el último
      IF vtmpdate = pfini
      THEN
         vultimo := TRUE;
      END IF;

      vpasexec := 6;

      -- Borramos el registro
      DELETE      agentes_convenio_prod
            WHERE cagente = pcagente AND sproduc = psproduc
                  AND fmovini = pfini;

      vpasexec := 7;

      -- Si el que borramos es el ultimo, tratamos de activar el anterior
      IF vultimo
      THEN
         -- Comprobamos cual es la fecha de inicio del último registro que queda para
         -- esa combinación de agente  / producto
         SELECT MAX (fmovini)
           INTO vtmpdate
           FROM agentes_convenio_prod
          WHERE cagente = pcagente AND sproduc = psproduc;

         vpasexec := 8;

         -- Si existe registro, le vamos a actualizar la fmovfin a NULL para que pase a estar vigente
         IF vtmpdate IS NOT NULL
         THEN
            -- Actualizamos la fecha de fin del registro anterior a NULL
            UPDATE agentes_convenio_prod
               SET fmovfin = NULL
             WHERE cagente = pcagente
               AND sproduc = psproduc
               AND fmovini = vtmpdate;
         END IF;
      END IF;                                                   -- Del vultimo

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 1;
   END f_del_dias_gracia_agente_prod;

   FUNCTION f_get_anula_x_no_pago (
      pcempres     IN       NUMBER,
      pcramo       IN       NUMBER,
      psproduc     IN       NUMBER,
      pcagente     IN       NUMBER,
      pnpoliza     IN       NUMBER,
      pncertif     IN       NUMBER,
      psucur       IN       NUMBER,
      pnrecibo     IN       NUMBER,
      pidtomador   IN       VARCHAR2,
      pntomador    IN       VARCHAR2,
      abrecibo     IN       NUMBER,
      soferta      IN       NUMBER,
      pcmodif      IN       NUMBER,
      ppdlegal     IN       NUMBER,
      ppjudi       IN       NUMBER,
      ppgunica     IN       NUMBER,
      ppestatal    IN       NUMBER,
      psquery      OUT      VARCHAR2
   )
      RETURN NUMBER
   IS
      param_like       VARCHAR2 (3000);
      param_not_like   VARCHAR2 (3000);
      nombaux          VARCHAR2 (1000);
      nerr             NUMBER (10);
      condicion        VARCHAR2 (1000);
      vobject          VARCHAR2 (500)
                                   := 'PAC_GESTION_REC.f_get_anula_x_no_pago';
      vparam           VARCHAR2 (500)
         :=    'parámetros - pcempres: '
            || pcempres
            || ', pcramo: '
            || pcramo
            || ', psproduc: '
            || psproduc
            || ', pcagente: '
            || pcagente
            || ', pncertif: '
            || pncertif
            || ', pnrecibo: '
            || pnrecibo
            || ', psucur: '
            || psucur
            || ', pidtomador: '
            || pidtomador
            || ', pntomador: '
            || pntomador
            || ', abrecibo: '
            || abrecibo
            || ', soferta: '
            || soferta
            || ', pcmodif: '
            || pcmodif
            || ', ppdlegal: '
            || ppdlegal
            || ', ppjudi: '
            || ppjudi
            || ', ppgunica: '
            || ppgunica
            || ', ppestatal: '
            || ppestatal;
            vsquery          VARCHAR2(10000):= null;
      vsquery1         VARCHAR2(10000):= null;    -- IAXIS-3592  --ECP -- 04/06/2019
      vcactivi         VARCHAR2(2000):=null;

BEGIN
   IF     soferta IS NULL
      AND ppdlegal IS NULL
      AND ppjudi IS NULL
      AND ppgunica IS NULL
      AND ppestatal IS NULL
      AND pcmodif IS NULL
      AND abrecibo IS NULL
      AND pcramo IS NULL
      AND psucur IS NULL
   THEN
      IF    pnrecibo IS NOT NULL
         OR pcempres IS NOT NULL
         OR pcramo IS NOT NULL
         OR psproduc IS NOT NULL
         OR pcagente IS NOT NULL
         OR pnpoliza IS NOT NULL
         OR pncertif IS NOT NULL
         OR psucur IS NOT NULL
         OR pidtomador IS NOT NULL
         OR pntomador IS NOT NULL
      THEN
         -- Ini AXIS-13321 -- 04/05/2020
         vsquery1 :=
            'SELECT '''' AS cestado,
     f_estado_recibo(r.nrecibo) AS testado,
     r.nrecibo as nrecibo,
     r.fefecto as fefecto,
     r.fvencim as fvencim,
     NVL(pac_parametros.f_parproducto_n(s.sproduc, ''DIAS_CONVENIO_RNODOM''), 0) ndgraci,
     pac_devolu.f_fecha_periodo_gracia(0, r.nrecibo) AS ftermin,
     r.ctiprec AS ctipo,
     (SELECT tatribu FROM detvalores WHERE cvalor = 8 AND cidioma = pac_md_common.f_get_cxtidioma AND catribu = r.ctiprec ) AS ttipo,
     s.cramo as cramo,
     (SELECT tramo FROM ramos WHERE cidioma = pac_md_common.f_get_cxtidioma AND cramo = s.cramo ) AS tramo,
     s.sproduc as sproduc,
     pac_isqlfor.f_plan(s.sseguro, pac_md_common.f_get_cxtidioma) AS tproduc,
     r.cagente as cagente,
     s.npoliza as npoliza,
     (SELECT COUNT(1) FROM DEVBANRECIBOS WHERE to_date(FREMESA) = to_date(f_sysdate) AND NRECIBO =r.nrecibo) AS cexiste,
     det.itotalr AS itotal,
     (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM (RTRIM(pd.tapelli2)) || '' ''|| LTRIM(RTRIM(pd.tnombre))
     FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = ag.sperson ) AS tagente,
     (SELECT rc.cpadre FROM redcomercial rc WHERE rc.cagente = r.cagente and rc.fmovfin is null ) AS csucurs,
     (SELECT LTRIM(RTRIM(d1.tapelli1)) || '' '' || LTRIM(RTRIM(d1.tapelli2)) || '' '' || LTRIM(RTRIM( d1.tnombre)) FROM per_personas p1, per_detper d1, redcomercial rc, agentes a1
     WHERE rc.cpadre = a1.cagente  AND rc.cagente = s.cagente AND p1.sperson = d1.sperson and a1.sperson=p1.sperson and rc.fmovfin is null) AS tsucurs,
     t.sperson AS ntomado,
     (SELECT  nvl(pd.tsiglas,LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM(RTRIM( pd.tapelli2)) || '' '' || LTRIM(RTRIM(pd.tnombre))) FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson and pd.cagente = 19000 ) AS ttomado
     FROM seguros s, recibos r, vdetrecibos det, agentes ag, tomadores t
     WHERE s.sseguro = r.sseguro
     and s.csituac = 0
     and r.nrecibo = (select max(rr.nrecibo) from recibos rr where rr.nrecibo = r.nrecibo and rr.ctiprec = r.ctiprec)
     AND s.cagente = ag.cagente
     AND r.nrecibo = det.nrecibo
     AND t.sseguro = s.sseguro
     AND t.nordtom = 1 
     AND (f_estado_recibo(r.nrecibo)<>''COBRADO'') ';

         -- Fin IAXIS-5149 -- ECP -- 05/09/2019
         IF pcempres IS NOT NULL
         THEN
            param_not_like :=
               ' OFERTA|LEGAL|JUDICIAL|GARANTÍA ÚNICA|ESTATAL|COASEGURO|ACEPTADO|COA|ACEP| CA|SERVICIOS|ECOPETROL';
            vsquery1 := vsquery1 || ' and s.cempres = ' || pcempres||' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ';
            vsquery1 :=
                  vsquery1
               || CHR (13)
               || ' AND s.sproduc NOT IN((select p.sproduc from productos p, titulopro t  WHERE t.cidioma = 8 and  t.cramo = p.cramo AND t.CMODALI = p.CMODALI  AND t.CTIPSEG = p.CTIPSEG AND t.CCOLECT = p.CCOLECT AND  REGEXP_LIKE(UPPER(T.TTITULO), ''('
               || param_not_like
               || ')'') ))';
            vsquery1 :=
                  vsquery1
               || CHR (13)
               || ' AND s.cactivi NOT IN(select t.cactivi from productos p, activisegu t  WHERE p.sproduc = s.sproduc and  p.cramo = t.cramo and t.cidioma = 8 AND  REGEXP_LIKE(UPPER(T.TACTIVI), ''('
               || param_not_like
               || ')'') )';
         END IF;

         IF pcramo IS NOT NULL
         THEN
            vsquery1 := vsquery1 || CHR (13) || ' and s.cramo = ' || pcramo||' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ';
         END IF;

         IF psproduc IS NOT NULL
         THEN
            vsquery1 := vsquery1 || ' and s.sproduc = ' || psproduc;
         END IF;

         IF pcagente IS NOT NULL
         THEN
            vsquery1 :=
                       vsquery1 || CHR (13) || ' and r.cagente = '
                       || pcagente;
         END IF;

         IF pnpoliza IS NOT NULL
         THEN
            vsquery1 :=
                  vsquery1
               || ' and s.npoliza = '
               || pnpoliza
               || ' and not exists  (SELECT 1
        FROM sin_siniestro sin
       WHERE sin.sseguro = s.sseguro
         )';
         END IF;

         IF pncertif IS NOT NULL
         THEN
            vsquery1 := vsquery1 || ' and s.ncertif = ' || pncertif;
         END IF;

         IF pnrecibo IS NOT NULL
         THEN
            vsquery1 := vsquery1 || ' and r.nrecibo = ' || pnrecibo;
         END IF;

         IF psucur IS NOT NULL
         THEN
            vsquery1 :=
                  vsquery1
               || ' and (SELECT rc.cpadre FROM redcomercial rc WHERE rc.cagente = s.cagente and rc.fmovfin is null ) = '
               || psucur;
         END IF;

         IF pidtomador IS NOT NULL
         THEN
            vsquery1 :=
                  vsquery1
               || ' and (SELECT pp.NNUMIDE  FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson) = '''
               || pidtomador
               || '''';
         END IF;

         -- Ini IAXIS-5149 -- ECP --09/09/2019
         IF pntomador IS NOT NULL
         THEN
            nombaux := UPPER ('%' || ff_strstd (pntomador) || '%');
            vsquery1 :=
                  vsquery1
               || ' and UPPER( (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM(RTRIM(pd.tapelli2)) || '' '' || LTRIM(RTRIM(pd.tnombre)) FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson and pd.cagente = 19000)) LIKE '
               || CHR (39)
               || nombaux
               || CHR (39);
         END IF;

-- Fin IAXIS-5149 -- ECP --09/09/2019
--         p_tab_error (f_sysdate,
--                      f_user,
--                      'PAC_GESTION_REC.f_set_anula_x_no_pago',
--                      1,
--                      vparam,
--                      SUBSTR ('vsquery1' || vsquery1, 1, 2500)
--                     );
         vsquery1 := vsquery1 || ' union ';
      END IF;
   END IF;

-- Ini IAXIS-5149 -- ECP --09/09/2019
   vsquery :=
         'SELECT '''' AS cestado,
     f_estado_recibo(r.nrecibo) AS testado,
     r.nrecibo as nrecibo,
     r.fefecto as fefecto,
     r.fvencim as fvencim,
     NVL(pac_parametros.f_parproducto_n(s.sproduc, ''DIAS_CONVENIO_RNODOM''), 0) ndgraci,
     pac_devolu.f_fecha_periodo_gracia(0, r.nrecibo) AS ftermin,
     r.ctiprec AS ctipo,
     (SELECT tatribu FROM detvalores WHERE cvalor = 8 AND cidioma = pac_md_common.f_get_cxtidioma AND catribu = r.ctiprec ) AS ttipo,
     s.cramo as cramo,
     (SELECT tramo FROM ramos WHERE cidioma = pac_md_common.f_get_cxtidioma AND cramo = s.cramo ) AS tramo,
     s.sproduc as sproduc,
     pac_isqlfor.f_plan(s.sseguro, pac_md_common.f_get_cxtidioma) AS tproduc,
     r.cagente as cagente,
     s.npoliza as npoliza,
     (SELECT COUNT(1) FROM DEVBANRECIBOS WHERE to_date(FREMESA) = to_date(f_sysdate) AND NRECIBO =r.nrecibo) AS cexiste,
     det.itotalr AS itotal,
     (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM (RTRIM(pd.tapelli2)) || '' ''|| LTRIM(RTRIM(pd.tnombre))
     FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = ag.sperson ) AS tagente,
     (SELECT rc.cpadre FROM redcomercial rc WHERE rc.cagente = s.cagente and rc.fmovfin is null) AS csucurs,
     (SELECT LTRIM(RTRIM(d1.tapelli1)) || '' '' || LTRIM(RTRIM(d1.tapelli2)) || '' '' || LTRIM(RTRIM( d1.tnombre)) FROM per_personas p1, per_detper d1, redcomercial rc, agentes a1
     WHERE rc.cpadre = a1.cagente  AND rc.cagente = r.cagente AND p1.sperson = d1.sperson and a1.sperson=p1.sperson and rc.fmovfin is null ) AS tsucurs,
     t.sperson AS ntomado,
     (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM(RTRIM( pd.tapelli2)) || '' '' || LTRIM(RTRIM(pd.tnombre)) FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson and pd.cagente = 19000 ) AS ttomado
     FROM seguros s, recibos r, vdetrecibos det, agentes ag, tomadores t
     WHERE s.sseguro = r.sseguro
     and s.csituac = 0
     and s.ctipcoa = 0
     AND s.cagente = ag.cagente
     and r.nrecibo = (select max(rr.nrecibo) from recibos rr where rr.nrecibo = r.nrecibo and rr.ctiprec = r.ctiprec)
     AND r.nrecibo = det.nrecibo
     AND t.sseguro = s.sseguro
     AND t.nordtom = 1
     AND (f_estado_recibo(r.nrecibo)=''PENDIENTE'' OR f_estado_recibo(r.nrecibo)=''IMPAGADO'')
     AND to_date(pac_devolu.f_fecha_periodo_gracia(0, r.nrecibo)) <=  to_date(f_sysdate) '
      || ' and not exists  (SELECT 1
        FROM sin_siniestro sin
       WHERE sin.sseguro = s.sseguro) ';

-- Ini IAXIS-5149 -- ECP --09/09/2019
-- IAXIS-3592  --ECP -- 15/05/2019
   IF pcempres IS NOT NULL
   THEN
      vsquery := vsquery || ' and s.cempres = ' || pcempres||' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ';
   END IF;

   IF pcramo IS NOT NULL
   THEN
      vsquery := vsquery || CHR (13) || ' and s.cramo = ' || pcramo||' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ';
   END IF;

   IF psproduc IS NOT NULL
   THEN
      vsquery := vsquery || ' and s.sproduc = ' || psproduc;
   END IF;

   IF pcagente IS NOT NULL
   THEN
      vsquery := vsquery || CHR (13) || ' and r.cagente = ' || pcagente;
   END IF;

   IF pnpoliza IS NOT NULL
   THEN
      vsquery :=
            vsquery
         || ' and s.npoliza = '
         || pnpoliza
         || ' and not exists  (SELECT 1
        FROM sin_siniestro sin
         WHERE sin.sseguro = s.sseguro)
        ';
      vsquery :=
            vsquery
         || CHR (13)
         || ' AND  r.nrecibo in (SELECT UNIQUE dp.NRECIBO FROM DETMOVRECIBO_PARCIAL dp where dp.nrecibo = r.nrecibo) ';
   END IF;

   IF pncertif IS NOT NULL
   THEN
      vsquery := vsquery || ' and s.ncertif = ' || pncertif;
   END IF;

   IF pnrecibo IS NOT NULL
   THEN
      vsquery := vsquery || ' and r.nrecibo = ' || pnrecibo;
      vsquery :=
            vsquery
         || CHR (13)
         || ' AND  r.nrecibo in (SELECT UNIQUE dp.NRECIBO FROM DETMOVRECIBO_PARCIAL dp where dp.nrecibo = r.nrecibo) ';
   END IF;

   IF psucur IS NOT NULL
   THEN
      vsquery :=
            vsquery
         || ' and (SELECT rc.cpadre FROM redcomercial rc WHERE rc.cagente = s.cagente and rc.fmovfin is null) = '
         || psucur;
   END IF;

   IF pidtomador IS NOT NULL
   THEN
      vsquery :=
            vsquery
         || ' and (SELECT pp.NNUMIDE  FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson) = '''
         || pidtomador
         || '''';
   END IF;

-- Ini IAXIS-5149 -- ECP --09/09/2019
   IF pntomador IS NOT NULL
   THEN
      nombaux := UPPER ('%' || ff_strstd (pntomador) || '%');
      vsquery :=
            vsquery
         || ' and UPPER( (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' || LTRIM(RTRIM(pd.tapelli2)) || '' '' || LTRIM(RTRIM(pd.tnombre)) FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson and pd.cagente = 19000 )) LIKE '
         || CHR (39)
         || nombaux
         || CHR (39);
   END IF;

-- Fin  IAXIS-5149 -- ECP --09/09/2019
   -- Recibos con abonos
   IF abrecibo IS NOT NULL AND abrecibo = 1
   THEN
      vsquery :=
            vsquery
         || CHR (13)
         || ' and s.cactivi = 1 AND  r.nrecibo in (SELECT UNIQUE dp.NRECIBO FROM DETMOVRECIBO_PARCIAL dp where dp.nrecibo = r.nrecibo) '
         ||' AND r.nmovimi = (SELECT MAX (r1.nmovimi) FROM recibos r1 WHERE r1.sseguro = r.sseguro) and csubtiprec = 0 ';
   ELSE
      IF pnrecibo IS NULL
      THEN
         IF pnpoliza IS NULL
         THEN
            vsquery :=
                  vsquery
               || CHR (13)
               || ' AND r.nrecibo not in (SELECT UNIQUE dp.NRECIBO FROM DETMOVRECIBO_PARCIAL dp where dp.nrecibo = r.nrecibo) ';
         END IF;
      END IF;
   END IF;

   IF     pnrecibo IS NULL
      AND pcempres IS NULL
      AND pcramo IS NULL
      AND psproduc IS NULL
      AND pcagente IS NULL
      AND pnpoliza IS NULL
      AND pncertif IS NULL
      AND psucur IS NULL
      AND pidtomador IS NULL
      AND pntomador IS NULL
      AND soferta IS NULL
      AND pcmodif IS NULL
      AND ppdlegal IS NULL
      AND ppjudi IS NULL
      AND ppgunica IS NULL
      AND ppestatal IS NULL
   THEN
      -- Ini IAXIS-12974 -- ECP -- 06/03/2020
      vsquery :=
            vsquery
         || CHR (13)
         || '  AND r.ctiprec = 0 ';
      param_not_like :=
         ' OFERTA|LEGAL|JUDICIAL|GARANTÍA ÚNICA|ESTATAL|COASEGURO|ACEPTADO|COA|ACEP| CA|SERVICIOS|ECOPETROL';
--            vsquery := vsquery || ' and s.cempres = ' || pcempres;
      vsquery :=
            vsquery
         || CHR (13)
         || ' AND s.sproduc NOT IN((select p.sproduc from productos p, titulopro t  WHERE t.cidioma = 8 and  t.cramo = p.cramo AND t.CMODALI = p.CMODALI  AND t.CTIPSEG = p.CTIPSEG AND t.CCOLECT = p.CCOLECT AND  REGEXP_LIKE(UPPER(T.TTITULO), ''('
         || param_not_like
         || ')'') ))';
      vsquery :=
            vsquery
         || CHR (13)
         || ' AND s.cactivi NOT IN(select t.cactivi from productos p, activisegu t  WHERE p.sproduc = s.sproduc and  p.cramo = t.cramo and t.cidioma = 8 AND  REGEXP_LIKE(UPPER(T.TACTIVI), ''('
         || param_not_like
         || ')'') )';
   -- Fin IAXIS-12974 -- ECP -- 06/03/2020
   END IF;

   -- Seriedades de oferta4000034
   IF soferta IS NOT NULL AND soferta = 1
   THEN
      /*IF param_like IS NULL
      THEN
         param_like := 'OFERTA';
      ELSE
         param_like := param_like || '|OFERTA';
      END IF;*/
      vsquery :=
            vsquery
         || CHR (13)
         || '  AND exists (select 1 from garanseg a where a.sseguro = s.sseguro and a.cgarant = 7000 ) ';
   ELSE
      IF param_not_like IS NULL
      THEN
         param_not_like := 'OFERTA';
      ELSE
         param_not_like := param_not_like || '|OFERTA';
      END IF;
   END IF;

   -- Pólizas con modificaciones
   IF pcmodif IS NOT NULL AND pcmodif = 1
   THEN
      vsquery :=
            vsquery
         || CHR (13)
         || ' and s.cactivi = 1 and r.ctiprec in (0,1,9) and r.csubtiprec <> 0 ';
   ELSE
      vsquery :=
            vsquery
         || CHR (13)
         || '  AND r.ctiprec IN(0,3)  ';
   END IF;

   -- Pólizas de producto Disposiciones legales
   IF ppdlegal IS NOT NULL AND ppdlegal = 1
   THEN
      IF param_like IS NULL
      THEN
         param_like := 'LEGAL';
      ELSE
         param_like := param_like || '|LEGAL';
      END IF;
   ELSE
      IF param_not_like IS NULL
      THEN
         param_not_like := 'LEGAL';
      ELSE
         param_not_like := param_not_like || '|LEGAL';
      END IF;
   END IF;

   -- Pólizas de producto Judiciales
   IF ppjudi IS NOT NULL AND ppjudi = 1
   THEN
      IF param_like IS NULL
      THEN
         param_like := 'JUDICIAL';
      ELSE
         param_like := param_like || '|JUDICIAL';
      END IF;
   ELSE
      IF param_not_like IS NULL
      THEN
         param_not_like := 'JUDICIAL';
      ELSE
         param_not_like := param_not_like || '|JUDICIAL';
      END IF;
   END IF;

   --. Pólizas de producto Garantía única
   IF ppgunica IS NOT NULL AND ppgunica = 1
   THEN
      IF param_like IS NULL
      THEN
         param_like := 'GARANTÍA ÚNICA|CUMPLIMIENTO DERIVADO DE CONTRATO';
         vsquery :=
              vsquery || CHR (13)
              || ' AND s.CACTIVI = 0 ';
         vsquery:= replace(vsquery,' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ','');
      ELSE
         param_like :=
            param_like || '|GARANTÍA ÚNICA|CUMPLIMIENTO DERIVADO DE CONTRATO';
         vsquery :=
              vsquery || CHR (13)
              || ' AND s.CACTIVI = 0 ';
              vsquery:= replace(vsquery,' and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''GU'',''GX'',''GA'') and b.sseguro = s.sseguro) ','');
      END IF;
   ELSE
      -- vsquery := vsquery || CHR (13) || '  AND s.CACTIVI <> 0 ';
      IF param_not_like IS NULL
      THEN
         param_not_like := 'GARANTÍA ÚNICA';
      ELSE
         param_not_like := param_not_like || '|GARANTÍA ÚNICA';
      END IF;
   END IF;

   -- Pólizas de productos con entidades estatales
   IF ppestatal IS NOT NULL AND ppestatal = 1
   THEN
      IF param_like IS NULL
      THEN
         --param_like := 'ESTATAL';
         vsquery :=
               vsquery
            || CHR (13)
            || '  AND ((s.cramo = 801 and s.CACTIVI = 2) or (s.cramo = 802 and s.CACTIVI in (0,2))) and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''RC'',''RM'') and b.sseguro = s.sseguro)';
      ELSE
         --param_like := param_like || '|ESTATAL';
         vsquery :=
               vsquery
            || CHR (13)
            || '  AND ((s.cramo = 801 and s.CACTIVI = 2) or (s.cramo = 802 and s.CACTIVI in (0,2))) and not exists (select 1 from rango_dian_movseguro b where substr(b.ncertdian,1,2) in (''RC'',''RM'')  and b.sseguro = s.sseguro) ';
      END IF;
   ELSE
      IF param_not_like IS NULL
      THEN
         param_not_like := 'ESTATAL|COASEGURO|ACEPTADO|COA|ACEP| CA|SERVICIOS|ECOPETROL';
      ELSE
         param_not_like :=
                 param_not_like || '|ESTATAL|COASEGURO|ACEPTADO|COA|ACEP| CA|SERVICIOS|ECOPETROL';
      END IF;
   END IF;

   
   if ppdlegal IS NOT NULL
      OR ppjudi IS NOT NULL then
      vcactivi := null;
      else
   vcactivi :=
             CHR (13)
            || ' AND s.cactivi IN(select t.cactivi from productos p, activisegu t  WHERE p.cactivo = 1 and p.sproduc = s.sproduc and  p.cramo = t.cramo and t.cidioma = 8 AND  REGEXP_LIKE(UPPER(T.TACTIVI), ''('
            || param_like
            || ')'') )';
            end if;
   IF    soferta IS NOT NULL
      OR ppgunica IS NOT NULL
      OR ppestatal IS NOT NULL
      OR ppdlegal IS NOT NULL
      OR ppjudi IS NOT NULL
      
      THEN
          vsquery :=
            vsquery
         || CHR (13)
         || ' AND s.sproduc IN((select p.sproduc from productos p, titulopro t  WHERE t.cidioma = 8 and p.cactivo = 1 and  t.cramo = p.cramo AND t.CMODALI = p.CMODALI  AND t.CTIPSEG = p.CTIPSEG AND t.CCOLECT = p.CCOLECT AND  REGEXP_LIKE(UPPER(T.TTITULO), ''('
         || param_like
         || ')'') ))';
          
         vsquery := vsquery ||vcactivi;
      END IF;

      
   IF    soferta IS NULL
      OR ppdlegal IS NULL
      OR ppjudi IS NULL
      OR ppgunica IS NULL
      OR ppestatal IS NULL
   THEN
      vsquery :=
            vsquery
         || CHR (13)
         || ' AND s.sproduc NOT IN((select p.sproduc from productos p, titulopro t  WHERE t.cidioma = 8 and  t.cramo = p.cramo AND t.CMODALI = p.CMODALI  AND t.CTIPSEG = p.CTIPSEG AND t.CCOLECT = p.CCOLECT AND  REGEXP_LIKE(UPPER(T.TTITULO), ''('
         || param_not_like
         || ')'') ))';

   END IF;

   -- Fin AXIS-13321 -- 04/05/2020
   vsquery := vsquery1 || ' ' || vsquery;

  
   vsquery :=
         vsquery
      || ' ORDER BY nrecibo,fefecto,fvencim,ndgraci,ftermin,ttipo,testado,tramo,tproduc,tsucurs,tagente,npoliza,ttomado,itotal';
   psquery := vsquery;

   -- Fin IAXIS-13321 --06/05/2020
--   p_tab_error (f_sysdate,
--                      f_user,
--                      'PAC_GESTION_REC.f_get_anula_x_no_pago',
--                      1,
--                      vparam,
--                      substr(psquery,1,2500)               );
--                      p_tab_error (f_sysdate,
--                      f_user,
--                      'PAC_GESTION_REC.f_get_anula_x_no_pago',
--                      1,
--                      vparam,
--                      substr(psquery,2501,5000)               );
--p_tab_error (f_sysdate,
--                      f_user,
--                      'PAC_GESTION_REC.f_get_anula_x_no_pago',
--                      1,
--                      vparam,
--                      substr(psquery,5001,7500)               );

      --DBMS_OUTPUT.PUT_LINE('Query:'||psquery);
   RETURN 0;
EXCEPTION
   WHEN OTHERS
   THEN
      p_tab_error (f_sysdate,
                   f_user,
                   'PAC_GESTION_REC.f_get_anula_x_no_pago',
                   1,
                   vparam,
                   'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                  );
      RETURN 9908775;

END f_get_anula_x_no_pago;
   FUNCTION f_estado_recibo (pnrecibo IN NUMBER)
      RETURN VARCHAR2
   AS
      vcestrec        NUMBER;
      vtotalrecivos   NUMBER;
      vestado00       NUMBER := 0;
      vestado01       NUMBER := 0;
      vestado1        NUMBER := 0;
      vestado2        NUMBER := 0;

      CURSOR crecibos
      IS
         SELECT   cestrec
             FROM movrecibo
            WHERE nrecibo = pnrecibo
         ORDER BY cestrec ASC;

      CURSOR ctotalrecibos
      IS
         SELECT COUNT (nrecibo) AS total
           FROM movrecibo
          WHERE nrecibo = pnrecibo;
   BEGIN
      /*Total de registros encontrados*/
      OPEN ctotalrecibos;

      LOOP
         FETCH ctotalrecibos
          INTO vtotalrecivos;

         EXIT WHEN ctotalrecibos%NOTFOUND;
      END LOOP;

      CLOSE ctotalrecibos;

      /*PENDIENTE si en la tabla MOVRECIBO , Solo hay un registro de ese recibo con CESTREC=0*/
      IF vtotalrecivos = 1
      THEN
         vestado00 := 0;

         OPEN crecibos;

         LOOP
            FETCH crecibos
             INTO vcestrec;

            EXIT WHEN crecibos%NOTFOUND;

            IF vcestrec = 0
            THEN
               vestado00 := vestado00 + 1;
            END IF;
         END LOOP;

         CLOSE crecibos;

         IF vestado00 = 1
         THEN
            RETURN 'PENDIENTE';
         END IF;
      END IF;

      /*COBRADO si en la tabla MOVRECIBO , Solo hay dos registros de ese recibo con CESTREC=0 y CESTREC=1*/
      IF vtotalrecivos = 2
      THEN
         vestado00 := 0;
         vestado1 := 0;

         OPEN crecibos;

         LOOP
            FETCH crecibos
             INTO vcestrec;

            EXIT WHEN crecibos%NOTFOUND;

            IF vcestrec = 0
            THEN
               vestado00 := vestado00 + 1;
            END IF;

            IF vcestrec = 1
            THEN
               vestado1 := vestado1 + 1;
            END IF;
         END LOOP;

         CLOSE crecibos;

         IF vestado00 = 1 AND vestado1 = 1
         THEN
            RETURN 'COBRADO';
         END IF;
      END IF;

      /*IMPAGADO si en la tabla MOVRECIBO , Solo hay tres registros de ese recibo con CESTREC=0 , CESTREC=1 y CESTREC=0*/
      IF vtotalrecivos = 3
      THEN
         vestado00 := 1;
         vestado01 := 2;
         vestado1 := 0;

         OPEN crecibos;

         LOOP
            FETCH crecibos
             INTO vcestrec;

            EXIT WHEN crecibos%NOTFOUND;

            IF vcestrec = 0 AND vestado00 = 1
            THEN
               vestado00 := vestado00 + 1;
            END IF;

            IF vcestrec = 1
            THEN
               vestado1 := vestado1 + 1;
            END IF;

            IF vcestrec = 0 AND vestado01 = 2
            THEN
               vestado01 := vestado01 + 1;
            END IF;
         END LOOP;

         CLOSE crecibos;

         IF vestado00 = 1 AND vestado1 = 1 AND vestado01 = 1
         THEN
            RETURN 'IMPAGADO';
         END IF;
      END IF;

      /*ANULADO si en la tabla MOVRECIBO , Solo hay 4 registros de ese recibo con CESTREC=0 , CESTREC=1 , CESTREC=0 y CESTREC=2*/
      IF vtotalrecivos = 4
      THEN
         vestado00 := 1;
         vestado01 := 2;
         vestado1 := 0;
         vestado2 := 0;

         OPEN crecibos;

         LOOP
            FETCH crecibos
             INTO vcestrec;

            EXIT WHEN crecibos%NOTFOUND;

            IF vcestrec = 0 AND vestado00 = 1
            THEN
               vestado00 := vestado00 + 1;
            END IF;

            IF vcestrec = 1
            THEN
               vestado1 := vestado1 + 1;
            END IF;

            IF vcestrec = 0 AND vestado00 = 2
            THEN
               vestado01 := vestado01 + 1;
            END IF;

            IF vcestrec = 2
            THEN
               vestado1 := vestado1 + 1;
            END IF;
         END LOOP;

         CLOSE crecibos;

         IF vestado00 = 1 AND vestado1 = 1 AND vestado01 = 1 AND vestado2 = 1
         THEN
            RETURN 'ANULADO';
         END IF;
      END IF;

      /*ANULADO COBRADO si en la tabla MOVRECIBO , Solo hay dos registros de ese recibo con CESTREC=1 y CESTREC=2*/
      IF vtotalrecivos = 2
      THEN
         vestado1 := 0;
         vestado2 := 0;

         OPEN crecibos;

         LOOP
            FETCH crecibos
             INTO vcestrec;

            EXIT WHEN crecibos%NOTFOUND;

            IF vcestrec = 1
            THEN
               vestado1 := vestado1 + 1;
            END IF;

            IF vcestrec = 2
            THEN
               vestado2 := vestado2 + 1;
            END IF;
         END LOOP;

         CLOSE crecibos;

         IF vestado1 = 1 AND vestado2 = 1
         THEN
            RETURN 'ANULADO COBRADO';
         END IF;
      END IF;

      RETURN '';
   END f_estado_recibo;

   FUNCTION f_set_anula_x_no_pago (pnrecibo IN NUMBER, pccheck IN NUMBER)
      RETURN NUMBER
   IS
      vobject        VARCHAR2 (500)
                                   := 'PAC_GESTION_REC.f_get_anula_x_no_pago';
      vparam         VARCHAR2 (500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ', pccheck: ' || pccheck;
      vsquery        VARCHAR2 (9000);
      vcont          NUMBER;
      vidgenerated   NUMBER;
      vpasexec       NUMBER (8)                        := 1;
      vnrecibo       recibos.nrecibo%TYPE;
      vcbancar       recibos.cbancar%TYPE;
      vccobban       recibos.ccobban%TYPE;
      vctipban       recibos.ctipban%TYPE;
      vitotalr       vdetrecibos_monpol.itotalr%TYPE;

      CURSOR cur_recibos
      IS
         SELECT nrecibo, cbancar, ccobban, ctipban
           FROM recibos
          WHERE nrecibo = pnrecibo;

      CURSOR cur_vdetrecibos_monpol
      IS
         SELECT itotalr
           FROM vdetrecibos_monpol
          WHERE nrecibo = pnrecibo;
   BEGIN
      BEGIN
         SELECT COUNT (1)
           INTO vcont
           FROM devbanpresentadores
          WHERE cempres = pac_md_common.f_get_cxtempresa
            AND TO_DATE (fsoport) = TO_DATE (f_sysdate)
            AND tprenom = 'Convenio'
            AND TO_DATE (fcarga) = TO_DATE (f_sysdate);

         vpasexec := 2;

         IF vcont = 0
         THEN
            INSERT INTO devbanpresentadores
                        (sdevolu,
                         cempres, cdoment, cdomsuc,
                         fsoport, nnumnif, tsufijo, tprenom, fcarga,
                         cusuari, tficher, nprereg, ipretot_r, ipretot_t,
                         npretot_r, npretot_t, sproces
                        )
                 VALUES ((SELECT NVL (MAX (sdevolu), 0) + 1
                            FROM devbanpresentadores),
                         pac_md_common.f_get_cxtempresa, '0', '0',
                         f_sysdate, 'x', 'x', 'Convenio', f_sysdate,
                         f_user, 'x', NULL, NULL, NULL,
                         NULL, NULL, 0
                        );

            vpasexec := 3;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 4;
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            RETURN (9908776);
                           -- Error insertando en la tabla DEVBANPRESENTADORES
      END;

      vcont := 0;

      BEGIN
         SELECT COUNT (1)
           INTO vcont
           FROM devbanordenantes
          WHERE TO_DATE (fremesa) = TO_DATE (f_sysdate)
            AND ccobban = 202
            AND tordnom = 'Convenio';

         vpasexec := 5;

         IF vcont = 0
         THEN
            SELECT NVL (MAX (sdevolu), 0) + 1
              INTO vidgenerated
              FROM devbanordenantes;

            INSERT INTO devbanordenantes
                        (sdevolu, nnumnif, tsufijo, fremesa, ccobban,
                         tordnom, nordccc, nordreg, iordtot_r, iordtot_t,
                         nordtot_r, nordtot_t, ctipban
                        )
                 VALUES (vidgenerated, 'x', 'x', f_sysdate, 202,
                         'Convenio', 'x', '1', NULL, NULL,
                         NULL, NULL, NULL
                        );

            vpasexec := 6;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 7;
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            RETURN (9908778); -- Error insertando en la tabla DEVBANORDENANTES
      END;

      BEGIN
         IF pccheck = 0
         THEN
            vcont := 0;

            SELECT COUNT (1)
              INTO vcont
              FROM devbanrecibos
             WHERE TO_DATE (fremesa) = TO_DATE (f_sysdate)
               AND nrecibo = pnrecibo;

            vpasexec := 8;

            IF vcont = 1
            THEN
               DELETE FROM devbanrecibos
                     WHERE TO_DATE (fremesa) = TO_DATE (f_sysdate)
                       AND nrecibo = pnrecibo;

               vpasexec := 9;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 10;
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            RETURN (9908779);      -- Error borrando en la tabla DEVBANRECIBOS
      END;

      BEGIN
         IF pccheck = 1
         THEN
            vcont := 0;

            SELECT COUNT (1)
              INTO vcont
              FROM devbanrecibos
             WHERE TO_DATE (fremesa) = TO_DATE (f_sysdate)
               AND nrecibo = pnrecibo;

            vpasexec := 11;

            IF vcont = 0
            THEN
               OPEN cur_recibos;

               LOOP
                  FETCH cur_recibos
                   INTO vnrecibo, vcbancar, vccobban, vctipban;

                  EXIT WHEN cur_recibos%NOTFOUND;
                  DBMS_OUTPUT.put_line (   vnrecibo
                                        || ' '
                                        || vcbancar
                                        || ' '
                                        || vccobban
                                        || ' '
                                        || vctipban
                                       );
                  vpasexec := 12;
               END LOOP;

               CLOSE cur_recibos;

               OPEN cur_vdetrecibos_monpol;

               LOOP
                  FETCH cur_vdetrecibos_monpol
                   INTO vitotalr;

                  EXIT WHEN cur_vdetrecibos_monpol%NOTFOUND;
                  DBMS_OUTPUT.put_line (vitotalr);
               END LOOP;

               CLOSE cur_vdetrecibos_monpol;

               vpasexec := 13;

               SELECT sdevolu
                 INTO vidgenerated
                 FROM devbanordenantes
                WHERE TO_DATE (fremesa) = TO_DATE (f_sysdate)
                  AND ccobban = 202
                  AND tordnom = 'Convenio';

               INSERT INTO devbanrecibos
                           (sdevolu, nnumnif, tsufijo, fremesa,
                            crefere, nrecibo, trecnom,
                            nrecccc, irecdev, cdevrec,
                            crefint, cdevmot, cdevsit, tprilin, ccobban,
                            ctipban
                           )
                    VALUES (vidgenerated, 'x', 'x', f_sysdate,
                            LPAD (vnrecibo, 12, '0'), vnrecibo, 'Convenio',
                            NVL (vcbancar, -1), vitotalr, 'x',
                            LPAD (vnrecibo, 10, '0'), 9, 1, NULL, vccobban,
                            vctipban
                           );

               vpasexec := 14;
            END IF;
         END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
            vpasexec := 15;
            p_tab_error (f_sysdate,
                         f_user,
                         vobject,
                         vpasexec,
                         vparam,
                         SQLERRM
                        );
            RETURN (9908779);     -- Error guardando en la tabla DEVBANRECIBOS
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'PAC_GESTION_REC.f_set_anula_x_no_pago',
                      1,
                      vparam,
                      'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM
                     );
         RETURN 9908779;
   /*Error guardando en la tabla DEVBANRECIBOS-*/
   END f_set_anula_x_no_pago;

--AAC_INI-CONF_379-20160927
   FUNCTION f_liquidar_carga_corte_fac (psproces IN NUMBER, p_cproces IN NUMBER)
      RETURN NUMBER
   IS
      vobj             VARCHAR2 (100)
                                     := 'PAC_CARGAS_POS.F_LIQUIDAR_CARGA_FAC';

        /*
      Estado control de linea "int_carga_ctrl.cestado"
      1       Error
      2       Aviso
      3       Pendiente
      4       Correcto
      5       No procesado
      */
      CURSOR fact_liq (psproces2 IN NUMBER)
      IS
         SELECT   a.sproces, a.nlinea, a.cagente, a.nrecibo, a.fcobro,
                  a.cortecuenta, a.cmoneda, a.itotalr itotalr_int,
                  a.icomision, iva, iretefuente, ireteiva, ireteica,
                  NVL (vm.iprinet, v.iprinet) iprinet, r.ctiprec, r.cgescob,
                  r.ccobban, r.cdelega, r.sseguro, r.nmovimi,
                  NVL (vm.icombru, v.icombru) icomisi,
                  NVL (vm.icomret, v.icomret) icomret,
                  NVL (vm.itotalr, v.itotalr) itotalr,
                  NVL (vm.itotimp, v.itotimp) itotimp,
                  NVL (r.sperson, ff_sperson_tomador (r.sseguro))
                                                                 sperson_pag
             FROM int_facturas_agentes a,
                  vdetrecibos v,
                  vdetrecibos_monpol vm,
                  recibos r
                           /* 4.0 - 0024803 - Inicial*/
         ,
                  int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND v.nrecibo = r.nrecibo
              AND vm.nrecibo(+) = r.nrecibo
              AND a.nrecibo = r.nrecibo
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*  AND EXISTS(SELECT 1*/
         /*               FROM int_carga_ctrl*/
         /*              WHERE int_carga_ctrl.sproces = a.sproces*/
         /*                AND int_carga_ctrl.cestado = 4)*/
         /*  FOR UPDATE OF a.cagente, a.cempres, a.nliqmen, a.nliqlin*/
         /* 4.0 - 0024803 - Final*/
         /*Solo las no procesadas*/
         ORDER BY nlinea;

      CURSOR ctactes_liq (psproces2 IN NUMBER)
      IS
         SELECT   a.cagente, a.cempres, a.nliqmen,
                  NVL (MIN (a.cortecuenta), g.cliquido) cliquido
             FROM agentes g, int_facturas_agentes a
                                                   /* 4.0 - 0024803 - Inicial*/
                  , int_carga_ctrl_linea c
            /* 4.0 - 0024803 - Final*/
         WHERE    a.sproces = psproces2
              AND a.cagente = g.cagente
              /* 4.0 - 0024803 - Inicial*/
              AND c.sproces = a.sproces
              AND c.nlinea = a.nlinea
              AND c.cestado IN 4
         /*> Trate solo los pendientes -- 4.0 - 0024803*/
         /* 4.0 - 0024803 - Inicial*/
         GROUP BY a.cagente, a.cempres, a.nliqmen, g.cliquido
         ORDER BY a.cagente;

      CURSOR pago_corte_cuenta (psproces IN NUMBER)
      IS
         SELECT DISTINCT (p.spago) spago
                    FROM ctactes c, pagoscomisiones p
                   WHERE c.sproces = psproces
                     AND c.nnumlin = p.nnumlin
                     AND p.cagente = c.cagente
                     AND p.cestado = 1
                     AND p.cempres = c.cempres;

-- Version 41
      CURSOR c_age_corretaje (c_nrecibo IN recibos.nrecibo%TYPE)
      IS
         SELECT DISTINCT ac.cagente
                    FROM recibos r, age_corretaje ac
                   WHERE ac.sseguro = r.sseguro
                     AND ac.nmovimi = r.nmovimi
                     AND r.nrecibo = c_nrecibo;

      vtraza           NUMBER                                    := 0;
      vdeserror        VARCHAR2 (1000);
      errorini         EXCEPTION;
      /*Indica error grabando estados.--Error que para ejecución*/
      vcoderror        NUMBER;
      v_deserror       int_carga_ctrl_linea_errs.tmensaje%TYPE;
      v_tfichero       int_carga_ctrl.tfichero%TYPE;
      e_errorliq       EXCEPTION;
      vnum_err         NUMBER;
      v_idioma         NUMBER;
      v_errdat         VARCHAR2 (4000);
      v_errtot         NUMBER                                    := 0;
      /* v_sproces      NUMBER; -- 4.0 - 0024803*/
      vcempres         empresas.cempres%TYPE := pac_md_common.f_get_cxtempresa;
      vnrecibo         recibos.nrecibo%TYPE;
      v_regext         ext_seguros%ROWTYPE;
      v_ncarga         mig_cargas.ncarga%TYPE;
      vmodo            NUMBER;
      vnliqmen         liquidalin.nliqmen%TYPE;
      vnliqlin         liquidalin.nliqlin%TYPE;
      vcageliq         agentes.cagente%TYPE;
      vcagente         agentes.cagente%TYPE                      := -1;
      vsmovrec         movrecibo.smovrec%TYPE;
      v_cmultimon      NUMBER;
      v_cmoncia        NUMBER;
      v_itasa          NUMBER;
      v_fcambio        DATE;
      v_icomisi        NUMBER;
      vnnumlin         NUMBER;
      vfecliq          DATE                               := TRUNC (f_sysdate);
      v_signo          NUMBER;
      vnliqmen2        NUMBER;
      vnnumlin2        NUMBER;
      vcliquido        agentes.cliquido%TYPE;
      vconcta59        NUMBER;
      /* Factura*/
      vconcta60        NUMBER;
      /* Recibos*/
      vconcta99        NUMBER;
      /* Saldo final de los apuntes automáticos (Comisión)*/
      vcdebhab1        NUMBER;
      /* Debe*/
      vcdebhab2        NUMBER;
      /* Haber*/
      vconcta53        NUMBER;
      /* IVA*/
      vconcta54        NUMBER;
      /* RETEFUENTE*/
      vconcta55        NUMBER;
      /* RETEIVA*/
      vconcta56        NUMBER;
      /* RETEICA*/
      vcestado         NUMBER;
      verror           NUMBER;
      vsmovagr         NUMBER                                    := 0;
      vvalor_ica       NUMBER;
      vvalor_fuente    NUMBER;
      vvalor_iva       NUMBER;
      vvalor_reteiva   NUMBER;
      vyacargado       NUMBER;
      /* 4.0 - 0024803*/
      vsproces         NUMBER;
      /* 5.0*/
      vterminal        VARCHAR2 (200);
      vemitido         NUMBER;
      perror           VARCHAR2 (2000);
      psinterf         NUMBER;
      vspago           NUMBER;
      l_tippag         NUMBER;                                    --Version 41
      l_sseguro        NUMBER;                                    --Version 41

      FUNCTION f_get_nliqmen (
         pcempres    IN   NUMBER,
         pcagente    IN   NUMBER,
         pfecliq     IN   DATE,
         psproces    IN   NUMBER,
         pmodo       IN   NUMBER,
         pcliquido   IN   NUMBER
      )
         RETURN NUMBER
      IS
         vnumerr      NUMBER         := 0;
         v_nliqmen    NUMBER         := NULL;
         v_nliqaux2   NUMBER         := NULL;
         v_selec      CLOB;
         v_object     VARCHAR2 (500) := 'PAC_CARGAS_POS.f_get_nliqmen';
         v_param      VARCHAR2 (500)
            :=    'parámetros - pcempres: '
               || pcempres
               || ', pcagente: '
               || pcagente
               || ', pfecliq: '
               || pfecliq
               || ', psproces: '
               || psproces
               || ', pmodo: '
               || pmodo;
         v_pasexec    NUMBER (5)     := 1;
         vdiasliq     NUMBER (5)     := 0;
      BEGIN
         /*Borramos si hay algun previo para este agente / empresa / fecha SOLO SI estamos en real*/
         SELECT MAX (nliqmen)
           INTO v_nliqaux2
           FROM liquidacab
          WHERE cagente = pcagente
            AND fliquid = pfecliq
            AND ctipoliq = 1
            AND cempres = pcempres;

         v_pasexec := 2;

         /* Si existe algun previo y estamos en modo real borramos el previo que existe.*/
         IF v_nliqaux2 IS NOT NULL AND pmodo = 0
         THEN
            DELETE FROM liquidalin
                  WHERE nliqmen = v_nliqaux2
                    AND cagente = pcagente
                    AND cempres = pcempres;

            DELETE FROM ext_liquidalin
                  WHERE nliqmen = v_nliqaux2
                    AND cagente = pcagente
                    AND cempres = pcempres;

            DELETE FROM liquidacab
                  WHERE ctipoliq = 1
                    AND cagente = pcagente
                    AND cempres = pcempres
                    AND nliqmen = v_nliqaux2
                    AND fliquid = pfecliq;
         END IF;

         v_pasexec := 3;

         BEGIN
            SELECT nliqmen
              INTO v_nliqmen
              FROM liquidacab
             WHERE cempres = pcempres
               AND sproliq = psproces
               AND cagente = pcagente;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT NVL (MAX (nliqmen), 0) + 1
                 INTO v_nliqmen
                 FROM liquidacab
                WHERE cempres = pcempres AND cagente = pcagente;

               v_pasexec := 4;
               /*Creamos la cabecera de liquidacab por agente*/
               vnumerr :=
                  pac_liquida.f_set_cabeceraliq (pcagente,
                                                 v_nliqmen,
                                                 pfecliq,
                                                 f_sysdate,
                                                 NULL,
                                                 pcempres,
                                                 psproces,
                                                 NULL,
                                                 NULL,
                                                 NULL,
                                                 pmodo,
                                                 NULL,
                                                 NULL,
                                                 NULL
                                                );

               IF vnumerr <> 0
               THEN
                  RETURN vnumerr;
               END IF;

               v_pasexec := 5;
         END;

         v_pasexec := 6;
         RETURN v_nliqmen;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         v_object,
                         v_pasexec,
                         v_param,
                         SQLCODE || ' - ' || SQLERRM
                        );
            RETURN NULL;
      END f_get_nliqmen;

      /* 4.0 - 0024803 - Inicial*/
      /* Alta de personas en SAP*/
      FUNCTION f_set_personas_a_sap (
         psperson   IN   NUMBER,
         psseguro   IN   NUMBER,
         pnmovimi   IN   NUMBER
      )
         RETURN NUMBER
      IS
         vpsinterf        NUMBER;
         vperror          VARCHAR2 (2000);
         vterminal        VARCHAR2 (200);
         vemitido         NUMBER;
         perror           VARCHAR2 (2000);
         psinterf         NUMBER;
         verror_pago      NUMBER;
         v_host           VARCHAR2 (50);
         v_nnumerr        NUMBER;
         v_object         VARCHAR2 (500)
                                     := 'PAC_CARGAS_POS.f_set_personas_a_sap';
         v_pasexec        NUMBER                         := 0;
         v_param          VARCHAR2 (500)
            :=    'parámetros - psperson: '
               || psperson
               || ', psseguro: '
               || psseguro
               || ', pnmovimi: '
               || pnmovimi;
         /* Cambios de IAXIS-4844 : start */
         vperson_num_id   per_personas.nnumide%TYPE;
         vdigitoide       per_personas.tdigitoide%TYPE;
         vctipide         per_personas.ctipide%TYPE;
      /* Cambios de IAXIS-4844 : end */
      BEGIN
         /* Cambios de IAXIS-4844 : start */
         BEGIN
            SELECT pp.nnumide, pp.tdigitoide
              INTO vperson_num_id, vdigitoide
              FROM per_personas pp
             WHERE pp.sperson = psperson AND ROWNUM = 1;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               SELECT pp.ctipide, pp.nnumide
                 INTO vctipide, vperson_num_id
                 FROM per_personas pp
                WHERE pp.sperson = psperson;

               vdigitoide :=
                  pac_ide_persona.f_digito_nif_col (vctipide,
                                                    UPPER (vperson_num_id)
                                                   );
         END;

         /* Cambios de IAXIS-4844 : end */
         v_host :=
            pac_parametros.f_parempresa_t (pac_md_common.f_get_cxtempresa,
                                           'ALTA_INTERM_HOST'
                                          );
         v_pasexec := 10;

         IF v_host IS NOT NULL
         THEN
            v_pasexec := 20;

            IF pac_persona.f_persona_duplicada_nnumide (psperson) = 1
            THEN
               v_host :=
                  pac_parametros.f_parempresa_t
                                             (pac_md_common.f_get_cxtempresa,
                                              'DUPL_ACREEDOR_HOST'
                                             );
            END IF;

            v_pasexec := 30;
            v_nnumerr := pac_user.f_get_terminal (f_user, vterminal);
            v_pasexec := 40;
            /* Cambios de IAXIS-4844 : start */
            v_nnumerr :=
               pac_con.f_alta_persona (pac_md_common.f_get_cxtempresa,
                                       psperson,
                                       vterminal,
                                       vpsinterf,
                                       verror_pago,
                                       pac_md_common.f_get_cxtusuario,
                                       1,
                                       'ALTA',
                                       vdigitoide,
                                       v_host
                                      );
            /* Cambios de IAXIS-4844 : end */
            v_pasexec := 50;

            IF v_nnumerr <> 0
            THEN
               RETURN v_nnumerr;
            END IF;
         END IF;

         v_pasexec := 60;

         IF     NVL (pac_parametros.f_parempresa_n (k_empresaaxis,
                                                    'CONTAB_ONLINE'
                                                   ),
                     0
                    ) = 1
            AND NVL (pac_parametros.f_parempresa_n (k_empresaaxis,
                                                    'GESTIONA_COBPAG'
                                                   ),
                     0
                    ) = 1
         THEN
            v_pasexec := 70;
            v_nnumerr :=
               pac_user.f_get_terminal (pac_md_common.f_get_cxtusuario,
                                        vterminal
                                       );
            v_pasexec := 80;
            v_nnumerr :=
               pac_con.f_emision_pagorec (k_empresaaxis,
                                          1,
                                          17,
                                          psseguro,
                                          pnmovimi,
                                          vterminal,
                                          vemitido,
                                          vpsinterf,
                                          verror_pago,
                                          f_user,
                                          NULL,
                                          NULL,
                                          NULL,
                                          1
                                         );
            v_pasexec := 90;

            IF v_nnumerr <> 0 OR TRIM (verror_pago) IS NOT NULL
            THEN
               v_pasexec := 90;

               IF v_nnumerr = 0
               THEN
                  v_nnumerr := 9903116;
                  /*151323;*/
                  RETURN v_nnumerr;
               END IF;
            /*p_tab_error(f_sysdate, f_user, v_tobjeto, v_ntraza,*/
            /*            'carga REVERSIONES-SGP - error no controlado ',*/
            /*            verror_pago || ' - ' || v_nnumerr);*/
            END IF;
         END IF;

         v_pasexec := 100;
         RETURN 0;
      EXCEPTION
         WHEN OTHERS
         THEN
            p_tab_error (f_sysdate,
                         f_user,
                         v_object,
                         v_pasexec,
                         v_param,
                         SQLCODE || ' - ' || SQLERRM
                        );
            RETURN 1;
      END f_set_personas_a_sap;
   /* 4.0 - 0024803 - Final*/
   BEGIN
      /*vnum_err := f_procesini(f_user, k_empresaaxis, 'CARGA_FACT_AGE_LIQ', 'PROCESO',*/
      /*                        v_sproces); -- 4.0 - 0024803*/
      vtraza := 5;
      v_idioma := k_idiomaaaxis;

      IF psproces IS NULL
      THEN
         vnum_err := 9000505;
         pac_gestion_rec.p_genera_logs (vobj,
                                        vtraza,
                                        'Error:' || vnum_err,
                                        'Parámetro psproces obligatorio.',
                                        psproces,
                                           f_axis_literales (vnum_err,
                                                             v_idioma
                                                            )
                                        || ':'
                                        || v_tfichero
                                        || ' : '
                                        || vnum_err
                                       );
         RAISE errorini;
      END IF;

      vtraza := 10;

      SELECT MIN (tfichero)
        INTO v_tfichero
        FROM int_carga_ctrl
       WHERE sproces = psproces;

      vtraza := 20;

      IF v_tfichero IS NULL
      THEN
         vnum_err := 9901092;
         p_tab_error (f_sysdate,
                      f_user,
                      vobj,
                      vtraza,
                      vnum_err,
                      'Falta fichero para proceso: ' || psproces
                     );
         vnnumlin2 := NULL;
         vnum_err :=
            f_proceslin (psproces,
                            f_axis_literales (vnum_err, v_idioma)
                         || ':'
                         || v_tfichero
                         || ' : '
                         || vnum_err,
                         1,
                         vnnumlin2
                        );
         RAISE errorini;
      END IF;

      vtraza := 30;

      FOR x IN fact_liq (psproces)
      LOOP
         vtraza := 40;

         BEGIN
                  /* 5.0  - Facturas intermediario - 170459 - Inicio*/
                  /*
            IF vnliqmen IS NULL
            OR NVL(vcagente, -1) != x.cagente THEN
            vcagente := x.cagente;
            vtraza := 60;
            IF pac_parametros.f_parempresa_n(vcempres, 'LIQUIDA_CTIPAGE') IS NULL THEN
            vcageliq := vcagente;
            ELSE
            vtraza := 70;
            vcageliq :=
            pac_agentes.f_get_cageliq
            (vcempres,
            pac_parametros.f_parempresa_n(vcempres,
            'LIQUIDA_CTIPAGE'),
            vcagente);

















            END IF;
            -- Que la liquidación sea por corte de cuenta (liquido/autoliquidación)[1] o no [0]
            -- Se dejará grabado en LIQUIDACAB
            vtraza := 80;
            IF x.cortecuenta IS NULL THEN
            BEGIN
            vtraza := 90;
            SELECT NVL(cliquido, 0)
            INTO vcliquido
            FROM agentes
            WHERE cagente = vcageliq;
            END;
            ELSE
            vtraza := 100;
            vcliquido := x.cortecuenta;



            END IF;
            vmodo := 0;   --> Modo real
            vtraza := 110;
            vnliqmen := f_get_nliqmen(vcempres, x.cagente, vfecliq, psproces, vmodo,
            vcliquido);
            vnliqlin := 1;
            ELSE
            vtraza := 120;
            vcagente := x.cagente;
            vnliqlin := vnliqlin + 1;
            END IF;
            -- Si el recibo tiene cobros parciales hace la liquidación parcial
            -- No se tratarán los cobros parciales
            --IF pac_adm_cobparcial.f_get_importe_cobro_parcial(x.nrecibo) != 0 THEN
            --   vnum_err := pac_liquida.f_set_recibos_parcial_liq_ind(vcempres, vcageliq,
            --                                                         vfecliq, NULL, psproces,
            --                                                         0, vnliqmen2, NULL,
            --                                                         x.nrecibo);
            --ELSE
            vtraza := 130;
            IF x.cgescob = 3 THEN
            v_icomisi :=(-x.itotalr + x.icomisi);
            ELSE
            v_icomisi := x.icomisi;












            END IF;
            vtraza := 140;
            IF x.ctiprec IN(9, 13) THEN
            v_signo := -1;
            ELSE
            v_signo := 1;


            END IF;
            vtraza := 150;
            v_cmultimon := NVL(pac_parametros.f_parempresa_n(vcempres, 'MULTIMONEDA'), 0);
            IF v_cmultimon = 1 THEN
            v_cmoncia := pac_parametros.f_parempresa_n(vcempres, 'MONEDAEMP');
            vnum_err := pac_oper_monedas.f_datos_contraval(NULL, x.nrecibo, NULL,
            f_sysdate, 2, v_itasa,
            v_fcambio);




            END IF;
            */
                  /* 5.0  - Facturas intermediario - 170459 - Final*/
                  /*END IF;*/
                  /* 3.0  0024803 - 158543 - Inicio*/
            vtraza := 190;
            verror :=
                   f_set_personas_a_sap (x.sperson_pag, x.sseguro, x.nmovimi);
                  /* A SAP solo se envía los tipos de cobro = 2*/
                  /*
            -- 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2
            UPDATE recibos
            SET ctipcob = 2
            WHERE nrecibo = x.nrecibo;
            */
                  /* 3.0  0024803 - 158543 - Final*/
            vtraza := 200;

            IF verror != 0
            THEN
               p_tab_error
                  (f_sysdate,
                   f_user,
                   vobj,
                   vtraza,
                   verror,
                      'Error('
                   || verror
                   || ') generando alta personas en SAP. f_set_personas_a_sap('
                   || x.sperson_pag
                   || ','
                   || x.sseguro
                   || ','
                   || x.nmovimi
                   || ')'
                  );
               RAISE e_errorliq;
            END IF;

            /* COBRAR RECIBO*/
            vtraza := 210;
            verror :=
               f_movrecibo (x.nrecibo,
                            1,
                            f_sysdate,
                            NULL,
                            vsmovagr,
                            vnliqmen,
                            vnliqlin,
                            f_sysdate,
                            x.ccobban,
                            x.cdelega,
                            NULL,
                            NULL
                           );
            vtraza := 230;

            IF verror != 0
            THEN
               p_tab_error (f_sysdate,
                            f_user,
                            vobj,
                            vtraza,
                            verror,
                               'Error('
                            || verror
                            || ') cobrado RECIBO ('
                            || x.nrecibo
                            || ')'
                           );
               RAISE e_errorliq;
            END IF;

            vtraza := 240;

            UPDATE int_facturas_agentes
               SET nliqmen = vnliqmen,
                   nliqlin = vnliqlin
             /* ,cempres = vcempres*/
             /*WHERE CURRENT OF fact_liq;*/
            WHERE  sproces = x.sproces AND nlinea = x.nlinea;

            vtraza := 250;
                  /* 5.0  - Facturas intermediario - 170459 - Inicio*/
                  /*
            SELECT MAX(smovrec)
            INTO vsmovrec
            FROM movrecibo
            WHERE nrecibo = x.nrecibo;
            vtraza := 260;
            INSERT INTO liquidalin
            (cempres, nliqmen, cagente, nliqlin, nrecibo, smovrec,
            itotimp, itotalr,
            iprinet, icomisi,
            iretenccom, isobrecomision, iretencsobrecom, iconvoleducto,
            iretencoleoducto, ctipoliq, itotimp_moncia,
            itotalr_moncia,
            iprinet_moncia,
            icomisi_moncia,
            iretenccom_moncia, isobrecom_moncia, iretencscom_moncia,
            iconvoleod_moncia, iretoleod_moncia, fcambio,
            cagerec)
            VALUES (vcempres, vnliqmen, vcageliq, vnliqlin, x.nrecibo, vsmovrec,
            NVL(x.itotimp, 0) * v_signo, NVL(x.itotalr, 0) * v_signo,
            NVL(x.iprinet, 0) * v_signo, NVL(v_icomisi, 0) * v_signo,
            NVL(x.icomret, 0) * v_signo, NULL, NULL, NULL,
            NULL, NULL, f_round(NVL(x.itotimp, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.itotalr, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.iprinet, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(v_icomisi, 0) * v_signo * v_itasa, v_cmoncia),
            f_round(NVL(x.icomret, 0) * v_signo * v_itasa, v_cmoncia), NULL, NULL,
            NULL, NULL, DECODE(v_cmultimon, 0, NULL, NVL(v_fcambio, f_sysdate)),
            x.cagente);
            */
            vsproces := NULL;
            /*se envía el agente a null necesariamente para que liquide el cocorretaje.*/
            /*Modificamos las cuentas para que no se envíen aqui, sino más abajo en corte de cuenta.*/
            verror :=
               pac_liquida.f_liquidaliq_age (NULL,
                                             vcempres,
                                             0,
                                             vfecliq,
                                             v_idioma,
                                             pac_md_common.f_get_cxtagente,
                                             vsproces,
                                             NULL,
                                             x.nrecibo
                                            );

            /* 5.0  - Facturas intermediario - 170459 - Final*/
            IF verror <> 0
            THEN
               p_int_error
                  (f_axis_literales (9900986, v_idioma),
                      'p_procesos_nocturnos_pos Liquidación de comisiones diarias '
                   || f_axis_literales (9901093, v_idioma),
                   2,
                   verror
                  );
            /*  7.0 - Corregimos el proceso para enviar el aviso de cobro a SAP - 177026 - Inicio*/
            ELSE
               /*lanzamos a mano el movimiento del cobro por corte de cuenta*/
               IF     NVL (pac_parametros.f_parempresa_n (vcempres,
                                                          'CONTAB_ONLINE'
                                                         ),
                           0
                          ) = 1
                  /*AND pmodo <> 1*/
                  /*AND verror <> 0*/
                  AND NVL (pac_parametros.f_parempresa_n (vcempres,
                                                          'GESTIONA_COBPAG'
                                                         ),
                           0
                          ) = 1
               /*AND v_nrecpend = 0*/
               THEN
                  psinterf := NULL;
                  verror :=
                     pac_user.f_get_terminal (pac_md_common.f_get_cxtusuario,
                                              vterminal
                                             );
                  verror :=
                     pac_con.f_emision_pagorec (vcempres,
                                                1,
                                                4,
                                                x.nrecibo,
                                                NULL,
                                                vterminal,
                                                vemitido,
                                                psinterf,
                                                perror,
                                                f_user,
                                                NULL,
                                                NULL,
                                                NULL,
                                                1
                                               );
                  --Version 41
                  l_tippag :=
                      pac_contab_conf.f_catribu (963, 8, 'CAUSACION COMISION');

                  --
                  IF l_tippag IS NOT NULL
                  THEN
                     --
                     l_sseguro :=
                               pac_contab_conf.f_sseguro_coretaje (x.nrecibo);

                     --
                     IF l_sseguro <> 0
                     THEN
                        --
                        FOR y IN c_age_corretaje (x.nrecibo)
                        LOOP
                           --
                           verror :=
                              pac_con.f_emision_pagorec (vcempres,
                                                         1,
                                                         l_tippag,
                                                         y.cagente,
                                                         x.nrecibo,
                                                         vterminal,
                                                         vemitido,
                                                         psinterf,
                                                         perror,
                                                         f_user,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         1
                                                        );
                        --
                        END LOOP;
                     --
                     ELSE
                        --
                        verror :=
                           pac_con.f_emision_pagorec (vcempres,
                                                      1,
                                                      l_tippag,
                                                      x.cagente,
                                                      x.nrecibo,
                                                      vterminal,
                                                      vemitido,
                                                      psinterf,
                                                      perror,
                                                      f_user,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      1
                                                     );
                     --
                     END IF;
                  --
                  END IF;

                  --Version 41
                  IF verror <> 0 OR TRIM (perror) IS NOT NULL
                  THEN
                     IF verror = 0
                     THEN
                        verror := 9903116;
                        /*151323;*/
                        RETURN verror;
                     END IF;

                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_cargas_pos.f_liquidar_carga_fac',
                                  1,
                                  'error no controlado',
                                  perror || ' ' || verror
                                 );
                  END IF;
               END IF;
            END IF;

            /*lanzamos a mano el movimiento de liquidación por corte de cuenta*/
            IF     NVL (pac_parametros.f_parempresa_n (vcempres,
                                                       'CONTAB_ONLINE'
                                                      ),
                        0
                       ) = 1
               /*AND pmodo <> 1*/
               /*AND verror <> 0*/
               AND NVL (pac_parametros.f_parempresa_n (vcempres,
                                                       'GESTIONA_COBPAG'
                                                      ),
                        0
                       ) = 1
               AND vsproces IS NOT NULL
            /*AND v_nrecpend = 0*/
            THEN
               FOR cur_corte IN pago_corte_cuenta (vsproces)
               LOOP
                  psinterf := NULL;
                  verror :=
                     pac_user.f_get_terminal (pac_md_common.f_get_cxtusuario,
                                              vterminal
                                             );
                  verror :=
                     pac_con.f_emision_pagorec (vcempres,
                                                1,
                                                21,
                                                cur_corte.spago,
                                                NULL,
                                                vterminal,
                                                vemitido,
                                                psinterf,
                                                perror,
                                                f_user,
                                                NULL,
                                                NULL,
                                                NULL,
                                                1
                                               );

                  IF verror <> 0 OR TRIM (perror) IS NOT NULL
                  THEN
                     IF verror = 0
                     THEN
                        verror := 9903116;
                        /*151323;*/
                        RETURN verror;
                     END IF;

                     p_tab_error (f_sysdate,
                                  f_user,
                                  'pac_cargas_pos.f_liquidar_carga_fac',
                                  1,
                                  'error no controlado',
                                  perror || ' ' || verror
                                 );
                  END IF;
               END LOOP;
            END IF;

                  /*esto fuera*/
                  /*
            IF NVL(pac_parametros.f_parempresa_n(vcempres, 'CONTAB_ONLINE'), 0) = 1
            --AND pmodo <> 1
            --AND verror <> 0
            AND NVL(pac_parametros.f_parempresa_n(vcempres, 'GESTIONA_COBPAG'), 0) = 1
            --AND v_nrecpend = 0
            THEN
            SELECT MAX(spago)
            INTO vspago
            FROM pagoscomisiones
            WHERE (cagente, cempres, nnumlin) IN(SELECT cagente, cempres, nnumlin
            FROM ctactes
            WHERE sproces = vsproces)
            AND cestado = 1;
            verror := pac_user.f_get_terminal(pac_md_common.f_get_cxtusuario, vterminal);
            verror := pac_con.f_emision_pagorec(vcempres, 1, 20, vspago, NULL, vterminal,
            vemitido, psinterf, perror, f_user, NULL,
            NULL, NULL, 1);
            IF verror <> 0
            OR TRIM(perror) IS NOT NULL THEN
            IF verror = 0 THEN
            verror := 9903116;   --151323;
            RETURN verror;

            END IF;
            p_tab_error(f_sysdate, f_user, 'pac_cargas_pos.f_liquidar_carga_fac', 1,
            'error no controlado', perror || ' ' || verror);


            END IF;


            END IF;
            */
            vtraza := 270;
         EXCEPTION
            WHEN e_errorliq
            THEN
               /* ROLLBACK; -- 4.0 - 0024803*/
               v_errtot := 1;
               vnum_err :=
                  pac_gestion_rec.p_marcalinea (psproces,
                                                x.nlinea,
                                                2,
                                                1,
                                                0,
                                                NULL,
                                                'ALTA(KO-ERROR)',
                                                NULL,
                                                NULL,
                                                NULL,
                                                x.cagente,
                                                x.nrecibo
                                               );
               /*- IF vnum_err <> 0 THEN*/
               /*-    RAISE errorini;   --Error que para ejecución*/
               /*- END IF;*/
               vnum_err :=
                  pac_gestion_rec.p_marcalineaerror
                            (psproces,
                             x.nlinea,
                             NULL,
                             1,
                             verror,
                                /* 2.0 - 24803 - 154143 (añadir)*/
                                f_axis_literales
                                                (verror,
                                                 pac_md_common.f_get_cxtidioma
                                                )
                             || ' '
                             || x.nrecibo
                            /* , verror  -- 2.0 - 24803 - 154143 (comentar)*/
                            );
         /*IF vnum_err <> 0 THEN*/
         /*   RAISE errorini;   --Error que para ejecución*/
         /*END IF;*/
         /*-RAISE errorini;   -- Si hay error mejor que no sigua con el resto del proceso*/
         END;
      END LOOP;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Inicio*/
      IF v_errtot = 1
      THEN
         RAISE errorini;
      /* Si hay error mejor que no sigua con el resto del proceso*/
      END IF;

      /* 4.0 - 0024803 - Ahora no hace falta que sea cticob = 2 - Final*/
      vtraza := 300;
        /* 5.0  - Facturas intermediario - 170459 - Inicio*/
        /*
      FOR y IN ctactes_liq(psproces) LOOP
      vtraza := 310;
      IF y.cliquido = 1 THEN
      -- LIQUIDACIÓN POR CORTE DE CUENTA / LIQUIDO
      vtraza := 320;
      SELECT NVL(MAX(nnumlin), 0)
      INTO vnnumlin
      FROM ctactes
      WHERE cagente = y.cagente;
      vtraza := 330;
      SELECT NVL(SUM(l.icomision), 0), NVL(SUM(l.itotalr - l.icomision), 0),
      NVL(SUM(l.itotalr), 0), NVL(SUM(l.iva), 0), NVL(SUM(l.iretefuente), 0),
      NVL(SUM(l.ireteiva), 0), NVL(SUM(l.ireteica), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0)
      INTO vconcta99,   -- Saldo final de los apuntes automáticos (Comisión)
      vconcta59,   -- Factura
      vconcta60,   -- Recibos
      vconcta53,   -- IVA
      vconcta54,   -- RETEFUENTE
      vconcta55,   -- RETEIVA
      vconcta56,   -- RETEICA
      vcdebhab1,   -- Debe
      vcdebhab2   -- Haber
      FROM int_facturas_agentes l
      WHERE l.cempres = y.cempres
      AND l.nliqmen = y.nliqmen
      AND l.cagente = y.cagente
      AND l.sproces = psproces;
      vcestado := 0;   --> Liquidado
      -- DEBE (siempre que los importes sean positivos)
      vtraza := 350;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
      vconcta99, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      vtraza := 360;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
      vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- HABER (siempre que los importes sean positivos)
      vtraza := 370;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
      vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      vtraza := 380;
      IF vconcta53 IS NOT NULL
      AND vconcta53 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 53, vcestado, NULL, f_sysdate,
      vconcta53, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;
      vtraza := 390;
      IF vconcta54 IS NOT NULL
      AND vconcta54 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 54, vcestado, NULL, f_sysdate,
      vconcta54, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);












      END IF;
      vtraza := 400;
      IF vconcta55 IS NOT NULL
      AND vconcta55 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 55, vcestado, NULL, f_sysdate,
      vconcta55, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);


      END IF;
      vtraza := 410;
      IF vconcta56 IS NOT NULL
      AND vconcta56 != 0 THEN
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 56, vcestado, NULL, f_sysdate,
      vconcta56, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);




      END IF;
      ELSE
      vtraza := 450;
      -- LIQUIDACIÓN SIN CORTE DE CUENTA
      SELECT NVL(MAX(nnumlin), 0)
      INTO vnnumlin
      FROM ctactes
      WHERE cagente = y.cagente;
      vtraza := 460;
      SELECT NVL(SUM(l.itotalr), 0), NVL(SUM(l.itotalr), 0), NVL(SUM(l.icomision), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 2, 1), 0),
      NVL(DECODE(SIGN(SUM(l.icomision)), -1, 1, 2), 0)
      INTO vconcta59,   -- Factura
      vconcta60,   -- Recibos
      vconcta99,   -- Saldo final de los apuntes automáticos (Comisión)
      vcdebhab1,   -- Debe
      vcdebhab2   -- Haber
      FROM int_facturas_agentes l
      WHERE l.cempres = y.cempres
      AND l.nliqmen = y.nliqmen
      AND l.cagente = y.cagente
      AND l.sproces = psproces;
      vcestado := 0;   --> Liquidado
      -- DEBE (siempre que los importes sean positivos)
      vtraza := 500;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 59, vcestado, NULL, f_sysdate,
      vconcta59, f_axis_literales(9002057, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- HABER (siempre que los importes sean positivos)
      vtraza := 510;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres, nrecibo,
      nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab2, 60, vcestado, NULL, f_sysdate,
      vconcta60, f_axis_literales(9002265, v_idioma), 0, vcempres, NULL,
      NULL, NULL, psproces, vfecliq, 0);
      -- DEBE (siempre que los importes sean positivos)[Pendiente de liquidar]
      -- Cuando es sin corte de cuenta, por tanto sin autoliquidación, la comisión la dejamos pendiente
      -- y cuando se liquide ya se le calcularán además los impuestos automáticamente.
      IF vconcta99 != 0 THEN
      vcestado := 1;   --> Pendiente de liquidar
      vtraza := 520;
      vnnumlin := vnnumlin + 1;
      INSERT INTO ctactes
      (cagente, nnumlin, cdebhab, cconcta, cestado, ndocume, ffecmov,
      iimport, tdescrip, cmanual, cempres,
      nrecibo, nsinies, sseguro, sproces, fvalor, sproduc)
      VALUES (y.cagente, vnnumlin, vcdebhab1, 99, vcestado, NULL, f_sysdate,
      vconcta99, f_axis_literales(9002265, v_idioma), 0, vcempres,
      NULL, NULL, NULL, psproces, vfecliq, 0);
      END IF;






















































      END IF;
      END LOOP;
      */
        /* 5.0  - Facturas intermediario - 170459 - Final*/
        /*Actualizamos la cabecera del proceso indicando si ha habido o no algún error o warning en todo el proceso de carga*/
      vtraza := 550;
      vnum_err :=
         pac_gestion_procesos.f_set_carga_ctrl_cabecera (psproces,
                                                         v_tfichero,
                                                         f_sysdate,
                                                         f_sysdate,
                                                         v_errtot,
                                                         p_cproces,
                                                         0,
                                                         NULL
                                                        );
      vtraza := 560;
      /* vnum_err := f_procesfin(v_sproces, 0); -- 4.0 - 0024803*/
      RETURN 0;
   EXCEPTION
      WHEN errorini
      THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_gestion_rec.p_genera_logs (vobj,
                                        vtraza,
                                        'Error:' || vnum_err,
                                        SQLERRM,
                                        psproces,
                                           f_axis_literales (103187, v_idioma)
                                        || ':'
                                        || v_tfichero
                                        || ' : '
                                        || SQLERRM
                                       );
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera (psproces,
                                                            v_tfichero,
                                                            f_sysdate,
                                                            NULL,
                                                            1,
                                                            p_cproces,
                                                            151541,
                                                            SQLERRM
                                                           );

         IF vnum_err <> 0
         THEN
            pac_gestion_rec.p_genera_logs
               (vobj,
                vtraza,
                vnum_err,
                'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                psproces,
                   f_axis_literales (180856, v_idioma)
                || ':'
                || v_tfichero
                || ' : '
                || vnum_err
               );
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
      WHEN OTHERS
      THEN
         ROLLBACK;
         /*KO si ha habido algun error en la cabecera*/
         pac_gestion_rec.p_genera_logs (vobj,
                                        vtraza,
                                        'Error No Controlado:' || vnum_err,
                                        SQLERRM,
                                        psproces,
                                           f_axis_literales (103187, v_idioma)
                                        || ':'
                                        || v_tfichero
                                        || ' : '
                                        || SQLERRM
                                       );
         vnum_err :=
            pac_gestion_procesos.f_set_carga_ctrl_cabecera (psproces,
                                                            v_tfichero,
                                                            f_sysdate,
                                                            NULL,
                                                            1,
                                                            p_cproces,
                                                            151541,
                                                            SQLERRM
                                                           );

         IF vnum_err <> 0
         THEN
            pac_gestion_rec.p_genera_logs
               (vobj,
                vtraza,
                vnum_err,
                'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2',
                psproces,
                   f_axis_literales (180856, v_idioma)
                || ':'
                || v_tfichero
                || ' : '
                || vnum_err
               );
         END IF;

         /* vnum_err := f_procesfin(v_sproces, 1); -- 4.0 - 0024803*/
         COMMIT;
         RETURN 1;
   END f_liquidar_carga_corte_fac;

       /*************************************************************************
       Procedimiento que guarda logs en las diferentes tablas.
       param p_tabobj in : tab_error tobjeto
       param p_tabtra in : tab_error ntraza
       param p_tabdes in : tab_error tdescrip
       param p_taberr in : tab_error terror
       param p_propro in : PROCESOSLIN sproces
       param p_protxt in : PROCESOSLIN tprolin
       devuelve número o null si existe error.
   *************************************************************************/
   PROCEDURE p_genera_logs (
      p_tabobj   IN   VARCHAR2,
      p_tabtra   IN   NUMBER,
      p_tabdes   IN   VARCHAR2,
      p_taberr   IN   VARCHAR2,
      p_propro   IN   NUMBER,
      p_protxt   IN   VARCHAR2
   )
   IS
      vnnumlin   NUMBER;
      vnum_err   NUMBER;
   BEGIN
      IF p_tabobj IS NOT NULL AND p_tabtra IS NOT NULL
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      p_tabobj,
                      p_tabtra,
                      SUBSTR (p_tabdes, 1, 500),
                      SUBSTR (p_taberr, 1, 2500)
                     );
      END IF;

      IF p_propro IS NOT NULL AND p_protxt IS NOT NULL
      THEN
         vnnumlin := NULL;
         vnum_err :=
               f_proceslin (p_propro, SUBSTR (p_protxt, 1, 120), 1, vnnumlin);
      END IF;
   END p_genera_logs;

       /*************************************************************************
             Función que marca linea que tratamos con un estado.
          param p_pro in : proceso
          param p_lin in : linea
          param p_tip in : tipo
          param p_est in : estado
          param p_val in : validado
          param p_seg in : seguro
          devuelve número o null si existe error.
   *************************************************************************/
   FUNCTION p_marcalinea (
      p_pro      IN   NUMBER,
      p_lin      IN   NUMBER,
      p_tip      IN   NUMBER,
      p_est      IN   NUMBER,
      p_val      IN   NUMBER,
      p_seg      IN   NUMBER,
      p_id_ext   IN   VARCHAR2,
      p_ncarg    IN   NUMBER,
      p_sin      IN   NUMBER DEFAULT NULL,
      p_tra      IN   NUMBER DEFAULT NULL,
      p_per      IN   NUMBER DEFAULT NULL,
      p_rec      IN   NUMBER DEFAULT NULL
   )
      RETURN NUMBER
   IS
      vobj      VARCHAR2 (100) := 'PAC_GESTION_REC.P_MARCALINEA';
      num_err   NUMBER;
      vtipo     NUMBER;
      num_lin   NUMBER;
      num_aux   NUMBER;
   BEGIN
      p_control_error ('AAC_379', vobj, 0);
      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea (p_pro,
                                                      p_lin,
                                                      p_tip,
                                                      p_lin,
                                                      p_tip,
                                                      p_est,
                                                      p_val,
                                                      p_seg,
                                                      p_id_ext,
                                                      p_ncarg,
                                                      p_sin,
                                                      p_tra,
                                                      p_per,
                                                      p_rec
                                                     );

      IF num_err <> 0
      THEN       /*Si fallan estas funciones de gestión salimos del programa*/
         p_genera_logs (vobj,
                        1,
                        num_err,
                           'p='
                        || p_pro
                        || ' l='
                        || p_lin
                        || ' t='
                        || p_tip
                        || ' EST='
                        || p_est
                        || ' v='
                        || p_val
                        || ' s='
                        || p_seg,
                        p_pro,
                        'Error ' || num_err || ' l=' || p_lin || ' e='
                        || p_est
                       );
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalinea;

   /*************************************************************************
        Función que marca el error de la linea que tratamos.
          param p_pro in : proceso
          param p_lin in : linea
          param p_ner in : numero error
          param p_tip in : tipo
          param p_cod in : codigo
          param p_men in : mensaje
          devuelve número o null si existe error.
   *************************************************************************/
   FUNCTION p_marcalineaerror (
      p_pro   IN   NUMBER,
      p_lin   IN   NUMBER,
      p_ner   IN   NUMBER,
      p_tip   IN   NUMBER,
      p_cod   IN   NUMBER,
      p_men   IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      vobj      VARCHAR2 (100) := 'PAC_GESTION_REC.P_MARCALINEAERROR';
      num_err   NUMBER;
   BEGIN
      p_control_error ('AAC_379', vobj, 0);
      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea_error (p_pro,
                                                            p_lin,
                                                            p_ner,
                                                            p_tip,
                                                            p_cod,
                                                            p_men
                                                           );

      IF num_err <> 0
      THEN       /*Si fallan estas funciones de gestión salimos del programa*/
         p_genera_logs (vobj,
                        1,
                        num_err,
                           'p='
                        || p_pro
                        || ' l='
                        || p_lin
                        || ' n='
                        || p_ner
                        || ' t='
                        || p_tip
                        || ' c='
                        || p_cod
                        || ' m='
                        || p_men,
                        p_pro,
                        'Error ' || num_err || ' l=' || p_lin || ' c='
                        || p_cod
                       );
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalineaerror;

--AAC_FI-CONF_379-20160927
--
-- Inicio IAXIS-3651 09/07/2019
--
/*******************************************************************************
FUNCION f_get_liquidacion
Función que obtiene los recibos a liquidar para un outsourcing especificado.
param in pnumide   -> Número de identificación del tomador/outsourcing
param in pcestgest -> Estado de la liquidación liquidado/pendiente
param in pfefeini  -> Fecha inicio de efecto
param in pfefefin  -> Fecha fin de efecto
param in pnrecibo  -> Número de recibo
param in pctipoper -> Tipo de persona tomador/outsourcing
********************************************************************************/
   FUNCTION f_get_liquidacion (
      pnumidetom   IN       VARCHAR2,
      pcestgest    IN       NUMBER,
      pfefeini     IN       DATE,
      pfefefin     IN       DATE,
      pcagente     IN       NUMBER,
      pnrecibo     IN       NUMBER,
      pctipoper    IN       NUMBER,
      mensajes     OUT      t_iax_mensajes
   )
      RETURN VARCHAR2
   IS
      vobject    VARCHAR2 (500)  := 'pac_gestion_rec.f_get_liquidacion';
      vparam     VARCHAR2 (500)
         :=    'parÃ¡metros - pnrecibo: '
            || pnrecibo
            || ', pnumidetom: '
            || pnumidetom
            || ', pcestgest: '
            || pcestgest
            || ', pfefeini: '
            || pfefeini
            || ', pfefefin: '
            || pfefefin
            || ', pcagente: '
            || pcagente;
      vpasexec   NUMBER (5)      := 0;
      vsquery    VARCHAR2 (9000);
   BEGIN
      vpasexec := 1;
      -- Se definen los campos cabecera de la consulta
      vsquery :=
         'SELECT testrec,nrecibo,npoliza,itotrec,tnomage,tnomtom, 
              pac_gestion_rec.f_get_imp_ges_out(nrecibo, fobs) AS igesout,
              fobs AS fgesout, TO_DATE(fmovpago) AS frecmovrec, cestges, pac_gestion_rec.f_get_imp_pnd_liq(nrecibo, fobs) AS iimppendliq FROM (';
      -- Se define la subtabla
      vsquery :=
            vsquery
         || 'SELECT ff_desvalorfijo(383, 8, f_cestrec_mv(r.nrecibo, NULL)) AS testrec,r.nrecibo AS nrecibo,'
         || '       s.npoliza AS npoliza,det.itotalr AS itotrec,(SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' ||'
         || '       LTRIM(RTRIM(pd.tapelli2)) || '' '' ||LTRIM(RTRIM(pd.tnombre)) FROM per_personas pp,per_detper pd'
         || '       WHERE pp.sperson = pd.sperson AND pp.sperson = ag.sperson) AS tnomage,'
         || '       (SELECT LTRIM(RTRIM(pd.tapelli1)) || '' '' ||LTRIM(RTRIM(pd.tapelli2)) || '' '' || LTRIM(RTRIM(pd.tnombre))'
         || '       FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson)'
         || '       AS tnomtom,dmr.iimporte,agd.fobs,DECODE(f_cestrec_mv(r.nrecibo, NULL),0,DECODE(NVL(dmr.iimporte, 0),0,'
         || '       NULL,(SELECT MAX(dmr2.fmovimi) FROM detmovrecibo dmr2 WHERE dmr2.nrecibo = dmr.nrecibo)),'
         || '       (SELECT mv1.fmovini FROM movrecibo mv1 WHERE mv1.nrecibo = r.nrecibo'
         || '       AND mv1.cestrec = f_cestrec_mv(r.nrecibo, NULL))) AS fmovpago,CASE WHEN pac_gestion_rec.f_get_imp_pnd_liq(r.nrecibo, agd.fobs) > 0'
         || '       THEN ''Pendiente'' ELSE ''Liquidado'' END AS cestges '
         || '  FROM recibos r,seguros s,per_personas p,per_detper d,vdetrecibos_monpol det,agentes ag, tomadores t,'
         || '       agd_observaciones agd,adm_observa_outsourcing adm,per_personas p1,per_detper d1,detmovrecibo dmr,'
         || '       movrecibo mv,adm_det_comisiones admcom'
         || ' WHERE r.sseguro = s.sseguro'
         || '   AND s.cagente = ag.cagente'
         || '   AND r.sseguro = s.sseguro'
         || '   AND mv.nrecibo = r.nrecibo'
         || '   AND p.sperson = ag.sperson'
         || '   AND d.sperson = p.sperson'
         || '   AND det.nrecibo = r.nrecibo'
         || '   AND t.sseguro = s.sseguro'
         || '   AND f_cestrec_mv(r.nrecibo, NULL) = mv.cestrec'
         || '   AND agd.nrecibo = r.nrecibo'
         || '   AND CASE WHEN f_cestrec_mv(r.nrecibo, NULL) = 0 THEN DECODE(dmr.iimporte, 0, NULL, TRUNC(dmr.fmovimi))'
         || '       ELSE DECODE(dmr.iimporte, 0, NULL, mv.fmovini) END >= TRUNC(agd.fobs)'
         || '   AND REPLACE(UPPER(agd.TTITOBS), '' '', '''') = ''GESTIONOUTSOURCING'''
         || '   AND agd.idobs = adm.idobs'
         || '   AND p1.nnumide = adm.nit'
         || '   AND p1.sperson = d1.sperson'
         || '   AND f_cestrec_mv(r.nrecibo, NULL) IN (0, 1)'
         || '   AND dmr.nrecibo(+) = r.nrecibo'
         || '   AND r.cgescar = 2'
         || '   AND admcom.nrecibo(+) = r.nrecibo'
         || '   AND admcom.nit(+) = adm.nit'
         || '   AND admcom.nnumordabo(+) = NVL(dmr.norden, 0)';

      IF pcagente IS NOT NULL
      THEN
         vsquery := vsquery || CHR (13) || ' and r.cagente = ' || pcagente;
      END IF;

      IF pnrecibo IS NOT NULL
      THEN
         vsquery := vsquery || ' and r.nrecibo = ' || pnrecibo;
      END IF;

      IF pctipoper = 1
      THEN
         IF pnumidetom IS NOT NULL
         THEN
            vsquery :=
                  vsquery
               || ' and (SELECT pp.NNUMIDE  FROM per_personas pp, per_detper pd WHERE pp.sperson = pd.sperson AND pp.sperson = t.sperson) = '
               || CHR (39)
               || pnumidetom
               || CHR (39);
         END IF;
      ELSE
         IF pnumidetom IS NOT NULL
         THEN
            vsquery :=
               vsquery || ' and adm.nit = ' || CHR (39) || pnumidetom
               || CHR (39);
         END IF;
      END IF;

      IF pfefeini IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' and TRUNC(r.fefecto) >= to_date('''
            || TO_CHAR (pfefeini, 'ddmmyyyy')
            || ''',''ddmmyyyy'')';
      END IF;

      IF pfefefin IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' and TRUNC(r.fefecto) <= to_date('''
            || TO_CHAR (pfefefin, 'ddmmyyyy')
            || ''',''ddmmyyyy'')';
      END IF;

      vsquery := vsquery || ')';

      IF pcestgest IS NOT NULL
      THEN
         vsquery :=
               vsquery
            || ' WHERE cestges =  DECODE('
            || pcestgest
            || ', 1, ''Pendiente'', ''Liquidado'')';
      END IF;

      vsquery :=
            vsquery
         || ' GROUP BY testrec, nrecibo, npoliza, itotrec, tnomage, tnomtom, fobs, fmovpago, cestges';
      vsquery :=
            vsquery || ' ORDER BY nrecibo, testrec, npoliza, tnomtom, itotrec';
      RETURN vsquery;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_liquidacion;

/*******************************************************************************
FUNCION f_get_imp_pnd_liq
Función que obtiene el importe gestionado por el outsourcing pendiente de liquidar
param in pnrecibo  -> Número de recibo
param in pfgesrec  -> Fecha de primera gestión del outsourcing
******************************************************************************/
   FUNCTION f_get_imp_pnd_liq (pnrecibo IN NUMBER, pfgesrec IN DATE)
      RETURN NUMBER
   IS
      vobject        VARCHAR2 (500) := 'pac_gestion_rec.f_get_imp_pnd_liq';
      vparam         VARCHAR2 (500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ', pfgesrec: '
            || pfgesrec;
      vpasexec       NUMBER (5)     := 1;
      --
      vestrec        NUMBER;
      vnrecibo       NUMBER         := pnrecibo;
      vfgesout       DATE           := pfgesrec;
      vncont         NUMBER         := 0;
      viimporteges   NUMBER         := 0;
   BEGIN
      vpasexec := 1;
      --
      vestrec := f_cestrec_mv (pnrecibo => vnrecibo, pidioma => NULL);
      --
      vpasexec := 2;

      --
      IF vestrec = 1
      THEN
         -- Se revisan pagos parciales aunque esté pagado
         SELECT COUNT (*)
           INTO vncont
           FROM detmovrecibo d
          WHERE d.nrecibo = vnrecibo;

         IF vncont > 0
         THEN
            -- Se retornan los pagos parciales pendientes de liquidación luego de la fecha de primera gestión
            SELECT NVL (SUM (d.iimporte_moncon), 0)
              INTO viimporteges
              FROM detmovrecibo d
             WHERE d.nrecibo = vnrecibo
               AND d.fmovimi >= vfgesout
               AND NOT EXISTS (
                       SELECT 1
                         FROM adm_det_comisiones a
                        WHERE a.nrecibo = d.nrecibo
                              AND a.nnumordabo = d.norden);
         ELSE
            -- Si no existen pagos parciales, se retorna el valor del recibo pendiente de gestión (único pago)
            BEGIN
               SELECT v.itotalr
                 INTO viimporteges
                 FROM vdetrecibos_monpol v, movrecibo m
                WHERE v.nrecibo = vnrecibo
                  AND v.nrecibo = m.nrecibo
                  AND m.cestrec = 1
                  AND m.fmovini >= vfgesout
                  AND NOT EXISTS (
                         SELECT 1
                           FROM adm_det_comisiones a
                          WHERE a.nrecibo = v.nrecibo
                            AND a.nnumordabo = 0
                            AND a.smovrec = m.smovrec);
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  viimporteges := 0;
            END;
         END IF;
      ELSIF vestrec = 0
      THEN
         -- Se revisan pagos parciales
         SELECT COUNT (*)
           INTO vncont
           FROM detmovrecibo d
          WHERE d.nrecibo = vnrecibo;

         IF vncont > 0
         THEN
            -- Se retornan los pagos parciales pendientes de liquidación luego de la fecha de primera gestión
            SELECT NVL (SUM (d.iimporte_moncon), 0)
              INTO viimporteges
              FROM detmovrecibo d
             WHERE d.nrecibo = vnrecibo
               AND d.fmovimi >= vfgesout
               AND NOT EXISTS (
                       SELECT 1
                         FROM adm_det_comisiones a
                        WHERE a.nrecibo = d.nrecibo
                              AND a.nnumordabo = d.norden);
         ELSE
            -- Si no existen pagos parciales, y el recibo està pendiente, entonces no se ha pagado
            viimporteges := 0;
         END IF;
      END IF;

      RETURN viimporteges;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_imp_pnd_liq;

/*******************************************************************************
FUNCION f_get_imp_ges_out
Función que obtiene el importe gestionado por el outsourcing
param in pnrecibo  -> Número de recibo
param in pfgesrec  -> Fecha de primera gestión del outsourcing
******************************************************************************/
   FUNCTION f_get_imp_ges_out (pnrecibo IN NUMBER, pfgesrec IN DATE)
      RETURN NUMBER
   IS
      vobject        VARCHAR2 (500) := 'pac_gestion_rec.f_get_imp_ges_out';
      vparam         VARCHAR2 (500)
         := 'parámetros - pnrecibo: ' || pnrecibo || ', pfgesrec: '
            || pfgesrec;
      vpasexec       NUMBER (5)     := 1;
      --
      vestrec        NUMBER;
      vnrecibo       NUMBER         := pnrecibo;
      vfgesout       DATE           := pfgesrec;
      vncont         NUMBER         := 0;
      viimporteges   NUMBER         := 0;
   BEGIN
      vpasexec := 1;
      --
      vestrec := f_cestrec_mv (pnrecibo => vnrecibo, pidioma => NULL);
      --
      vpasexec := 2;

      --
      IF vestrec = 1
      THEN
         -- Se revisan pagos parciales aunque esté pagado
         SELECT COUNT (*)
           INTO vncont
           FROM detmovrecibo d
          WHERE d.nrecibo = vnrecibo;

         IF vncont > 0
         THEN
            -- Se retornan los pagos parciales pendientes de liquidación luego de la fecha de primera gestión
            SELECT NVL (SUM (d.iimporte_moncon), 0)
              INTO viimporteges
              FROM detmovrecibo d
             WHERE d.nrecibo = vnrecibo AND d.fmovimi >= vfgesout;
         ELSE
            -- Si no existen pagos parciales, se retorna el valor del recibo pendiente de gestión (único pago)
            BEGIN
               SELECT v.itotalr
                 INTO viimporteges
                 FROM vdetrecibos_monpol v, movrecibo m
                WHERE v.nrecibo = vnrecibo
                  AND v.nrecibo = m.nrecibo
                  AND m.cestrec = 1
                  AND m.fmovini >= vfgesout;
            EXCEPTION
               WHEN NO_DATA_FOUND
               THEN
                  viimporteges := 0;
            END;
         END IF;
      ELSIF vestrec = 0
      THEN
         -- Se revisan pagos parciales
         SELECT COUNT (*)
           INTO vncont
           FROM detmovrecibo d
          WHERE d.nrecibo = vnrecibo;

         IF vncont > 0
         THEN
            -- Se retornan los pagos parciales pendientes de liquidación luego de la fecha de primera gestión
            SELECT NVL (SUM (d.iimporte_moncon), 0)
              INTO viimporteges
              FROM detmovrecibo d
             WHERE d.nrecibo = vnrecibo AND d.fmovimi >= vfgesout;
         ELSE
            -- Si no existen pagos parciales, y el recibo està pendiente, entonces no se ha pagado
            viimporteges := 0;
         END IF;
      END IF;

      RETURN viimporteges;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      vobject,
                      vpasexec,
                      vparam,
                      SQLCODE || ' - ' || SQLERRM
                     );
         RETURN NULL;
   END f_get_imp_ges_out;
--
-- Fin IAXIS-3651 09/07/2019
--
END pac_gestion_rec;
/