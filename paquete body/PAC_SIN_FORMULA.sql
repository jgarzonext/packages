--------------------------------------------------------
--  DDL for Package Body PAC_SIN_FORMULA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_SIN_FORMULA" IS
/****************************************************************************
   NOMBRE:       PAC_SIN_FORMULA
   PROPÓSITO:  Funciones para el cálculo de los siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        30/04/2009  XVM               1. Creación del package.
   2.0        22/09/2009  DRA               2. 0011183: CRE - Suplemento de alta de asegurado ya existente
   3.0        04/02/2010  JRH               3. BUG 0012986: CEM - CRS - Ajustes productos CRS
   4.0        22/02/2010  RSC               4. 0013296: CEM - Revisión módulo de rescates
   5.0        24/02/2010  RSC               5. 0013296: CEM - Revisión módulo de rescates
   6.0        27/04/2010  DRA               6. 0014172: CEM800 - SUPLEMENTS: Error en el suplement de preguntes de pòlissa de la pòlissa 60115905.
   7.0        20/05/2010  RSC               7. 0013829: APRB78 - Parametrizacion y adapatacion de rescastes
   8.0        28/05/2010  AMC               8. 0014752: AGA014 - Cambios en alta rápida de siniestros (axissin032). Se crea la función f_cal_fechas_sini.
   9.0        12/07/2010  JRH               9. 0015298: CEM210 - RESCATS: Simulació pagaments rendes per productes 2 CABEZAS
  10.0        23/09/2010  SRA              10. 0016040: AGA003 - generación de pagos en siniestros
  11.0        06/10/2010  FAL              11. 0016219: GRC - Pagos de siniestros de dos garantías
  12.0        16/12/2010  DRA              12. 0016506: CRE - Pantallas de siniestros nuevo módulo
  13.0        16/12/2010  SRA              13. 0016924: GRC003 - Siniestros: estado y tipo de pago por defecto
  14.0        05/09/2011  JRH              14. 0019364: ENSA102-Cambiar en PAC_SIN_FORMULA.f_cal_valora orden de ejecución de los campos
  15.0        22/11/2011  RSC              14. 0020241: LCOL_T004-Parametrización de Rescates (retiros)
  16.0        08/11/2011  JMP              15. 0018423: LCOL000 - Multimoneda
  17.0        23/01/2012  JMP              16. 0018423: LCOL705 - Multimoneda
  18.0        26/01/2012  JMP              17. 0018423/104212: LCOL705 - Multimoneda
  19.0        03/07/2012  ASN              18. 0022674: MDP_S001-SIN - Reserva global (calculo)
  20.0        09/07/2012  JMF              0022490: LCOL_S001-SIN - Poder indicar que se generen los pagos como el último (Id=4604)
  21.0        15/10/2012  ASN              0023764: LCOL_S001-LCOL - SIN - Préstamos y siniestros
  22.0        15/03/2013  ASN              0026108: LCOL_S010-SIN - Tipo de gasto en reservas
  23.0        27/11/2013  JMF              0028909 RSA002-Parametrizacion y ajustes Carga de siniestros RSA
  24.0        26/02/2014  JTT              24  0024708: Nueva funcion EsAmparoDeMuerte
  25.0        02/04/2014  JTT              25. 0029224: Concepto de pago e indemnizacion segun tabla SIN_CAUSA_MOTIVO
  26.0        10/04/2014  NSS              26. 0030525: INT030-Prueba de concepto CONFIANZA
  27.0        25/06/2014  JTT              27. 0024708: Modificamos el calculo de 'CAPITAL' para que tenga en cuenta el NMOVIMI a fecha de siniestro
  28.0        04/07/2014  JTT              28. 0031294/178338: Revision pagos automaticos de baja diaria.
  29.0        27/08/2014  JTT              29. 0031294/177836: Añadir el campo idres a los objetos OB_IAXX_SIN_TRAMI_RESERVA y OB_IAX_SIN_TRAMI_PAGO_GAR
  30.0        29/09/2014  JTT              30. 0032428/188259: Cambio tipo PREGUNSINI.nsinies
  31.0        07/03/2016  JTT              31. 0040889/229315: Modificaion en la funcion F_INSERTA_PAGO para informar la fmovres con la fecha de proceso
****************************************************************************/

   /*************************************************************************
      PROCEDURE p_carga_preguntas
         Funció que carega les preguntes per poder executar la fórmula indicada
         param in psseguro : Número segur
         param in pfecha   : Data efecte segur
         param in pcgarant : Codi garantia
         param in psesion  : Codi sessió
         param in pnriesgo : Número riesgo
         param in pnsinies : Numero de siniestro
   *************************************************************************/
   PROCEDURE p_carga_preguntas(
      psseguro IN NUMBER,
      pfecha IN DATE,
      pcgarant IN NUMBER,
      psesion IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnsinies IN sin_siniestro.nsinies%TYPE DEFAULT NULL   -- Bug 32428 - 30/09/2014 - JTT
                                                         ) IS
      CURSOR c_preg_pol IS
         SELECT *
           FROM pregunpolseg
          WHERE sseguro = psseguro
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunpolseg   -- BUG14172:DRA:27/04/2010
                            WHERE sseguro = psseguro
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      CURSOR c_preg_risc IS
         SELECT *
           FROM pregunseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregunseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      CURSOR c_preg_gar IS
         SELECT *
           FROM pregungaranseg
          WHERE sseguro = psseguro
            AND nriesgo = pnriesgo
            AND cgarant = pcgarant
            AND nmovimi = (SELECT MAX(nmovimi)
                             FROM pregungaranseg
                            WHERE sseguro = psseguro
                              AND nriesgo = pnriesgo
                              AND nmovimi <= (SELECT MAX(nmovimi)
                                                FROM movseguro
                                               WHERE sseguro = psseguro
                                                 AND fefecto <= pfecha));

      --Ini 27354:NSS:19/06/2013
      CURSOR c_preg_sin IS
         SELECT *
           FROM pregunsini
          WHERE nsinies = pnsinies;

      --Fin 27354:NSS:19/06/2013
      e              NUMBER;
   BEGIN
      -- INSERTAMOS LAS PREGUNTAS
      FOR preg_pol IN c_preg_pol LOOP
         e := f_graba_param(psesion, 'RESP' || preg_pol.cpregun, preg_pol.crespue);
      END LOOP;

      FOR preg_risc IN c_preg_risc LOOP
         e := f_graba_param(psesion, 'RESP' || preg_risc.cpregun, preg_risc.crespue);
      END LOOP;

      FOR preg_gar IN c_preg_gar LOOP
         e := f_graba_param(psesion, 'RESP' || preg_gar.cpregun, preg_gar.crespue);
      END LOOP;

      --Ini 27354:NSS:19/06/2013
      FOR preg_sin IN c_preg_sin LOOP
         e := f_graba_param(psesion, 'RESP' || preg_sin.cpregun, preg_sin.crespue);
      END LOOP;
   --Fin 27354:NSS:19/06/2013
   END p_carga_preguntas;

   /*************************************************************************
      FUNCTION f_cal_valora
         Funció que carega les preguntes per poder executar la fórmula indicada
         param in pfsinies  : Data del sinistre
         param in psseguro  : Codi seguro
         param in pnsinies  : Número de sinistre
         param in psproduc  : Codi Producte
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantía
         param in pccausin  : Codi Causa sinistre
         param in pcmotsin  : Codi Subcausa
         param in pfnotifi  : Data notificació
         param in pctramit  : Codi tramitació
         param in pntramit  : Número tramitació
         param out pivalora : Valorització
         param out pipenali : Penalització
         param out picapris : Capital de risc
         param in pnriesgo  : Número risc
         param in pfecval   :
         param in pfperini  : Data inici pagament
         param in pfperfin  : Data fi pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_cal_valora(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE DEFAULT 0,
      pcgarant IN codigaran.cgarant%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      pfecval IN sin_tramita_reserva.fmovres%TYPE DEFAULT f_sysdate,
      pfperini IN sin_tramita_reserva.fresini%TYPE,
      pfperfin IN sin_tramita_reserva.fresfin%TYPE,
      pivalora OUT sin_tramita_reserva.ireserva%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE,
      picapris OUT sin_tramita_reserva.icaprie%TYPE,
      pifranq OUT sin_tramita_reserva.ifranq%TYPE,   --Bug 27059:NSS:05/06/2013
      pndias IN sin_tramita_reserva.ndias%TYPE DEFAULT NULL   --Bug 27487/159742:NSS;28/11/2013
                                                           )
      RETURN NUMBER IS
      -- Bug 0028909 - 27/11/2013 - JMF
      vobj           VARCHAR2(100) := 'PAC_SIN_FORMULA.f_cal_valora';
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha valor del siniestro
      xfecefe        NUMBER;   -- Fecha Alta
      xfecval        NUMBER;   --Fecha de efecto de valoracion
      xfnotifi       NUMBER;   -- Fecha Notificacion
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       NUMBER;
      xipenali       NUMBER;
      xicapris       NUMBER;
      xnriesgo       NUMBER;
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xxfperini      NUMBER(8);
      xxfperfin      NUMBER(8);
      vparam         VARCHAR2(2000);
      vicapital      garanseg.icapital%TYPE;
      vctramit       sin_tramitacion.ctramit%TYPE;
      xifranq        NUMBER;   --Bug 27059:NSS:05/06/2013
      v_cmonres      VARCHAR2(3);
      xxnmovimi      garanseg.nmovimi%TYPE;
      xxndias        sin_tramita_reserva.ndias%TYPE;   --Bug 27487/159742:NSS;28/11/2013

      CURSOR cur_campo(
         ppccausin NUMBER,
         ppcmotsin NUMBER,
         ppsproduc NUMBER,
         ppcactivi NUMBER,
         ppcgarant NUMBER,
         ppctramit NUMBER) IS
         -- Bug 19364 - JRH - 05/09/2011 - 00119364: El orden de cálculo de las fórmulas es ICAPRIS,IPENALI y IVALSIN
         SELECT   DECODE(sfcm.ccampo,
                         'IFRANQ', 1,
                         'ICAPRIS', 2,
                         'IVALSIN', 4,
                         'IPENALI', 3) orden,

                  -- Fi Bug 19364 - JRH - 05/09/2011
                  sfcm.ccampo, sfcm.cclave, sfcm.ctipdes
             FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, sin_causa_motivo scm
            WHERE sfcm.scaumot = sgcm.scaumot
              AND scm.scaumot = sfcm.scaumot
              AND scm.ccausin = ppccausin
              AND scm.cmotsin = ppcmotsin
              AND sgcm.sproduc = ppsproduc
              AND sgcm.cactivi = ppcactivi
              AND(sgcm.cgarant = ppcgarant
                  OR ppcgarant IS NULL)
              AND sgcm.ctramit = ppctramit
              AND sfcm.ccampo IN('IVALSIN', 'ICAPRIS', 'IPENALI', 'IFRANQ')   --Bug 27059:NSS:05/06/2013
              AND sfcm.ctipdes = 0
         ORDER BY 1;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF pctramit IS NULL THEN
         BEGIN
            SELECT ctramit
              INTO vctramit
              FROM sin_tramitacion
             WHERE nsinies = pnsinies
               AND ntramit = pntramit;
         EXCEPTION
            WHEN OTHERS THEN
               vctramit := NULL;
         END;
      ELSE
         vctramit := pctramit;
      END IF;

      xfsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      xfnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));
      xxfperini := TO_NUMBER(TO_CHAR(pfperini, 'yyyymmdd'));
      xxfperfin := TO_NUMBER(TO_CHAR(pfperfin, 'yyyymmdd'));
      xxndias := pndias;   --Bug 27487/159742:NSS;28/11/2013
      vparam := 'parámetros - pfsinies: ' || pfsinies || 'psseguro: ' || psseguro
                || ' pnriesgo: ' || pnriesgo || ' pnsinies: ' || pnsinies || ' pntramit: '
                || pntramit || ' pctramit: ' || vctramit || ' psproduc: ' || psproduc
                || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pccausin: '
                || pccausin || ' pcmotsin: ' || pcmotsin || ' pfnotifi: ' || pfnotifi
                || ' pfecval: ' || pfecval || ' pfperini: ' || pfperini || ' pfperfin: '
                || pfperfin || ' pndias: ' || pndias;   --Bug 27487/159742:NSS;28/11/2013

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         /*
             -- RSC 21/10/2008 Lo hacemos asi para minimizar impacto
                 (en Ahorro esto funciona por tanto este cambio solo lo quiero para
                  rentas).

               Para RVI y RO FFECEFE debe ser la fecha de revisión anterior y si
               no ha renovado pues la de efecto de la póliza. Para el resto no
               afecta.
         */
         SELECT TO_NUMBER(TO_CHAR(NVL(sa.frevant, s.fefecto), 'YYYYMMDD'))
           INTO xfecefe
           FROM seguros_aho sa, seguros s
          WHERE sa.sseguro = s.sseguro
            AND s.sseguro = psseguro;
      ELSE
         xfecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      END IF;

      xfecval := TO_NUMBER(TO_CHAR(pfecval, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         p_tab_error(f_sysdate, f_user, vobj, 292, vparam, 'xxsesion IS NULL');
         RETURN 108418;
      END IF;

      IF pnriesgo IS NULL THEN
         BEGIN
            SELECT nriesgo
              INTO xnriesgo
              FROM sin_siniestro
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, 304, vparam, pnsinies);
               RETURN 104755;   -- clave no esncontrada en siniestros
         END;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

      e := f_graba_param(xxsesion, 'ORIGEN', 2);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 314, vparam, xxsesion || ' ORIGEN= 2');
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 321, vparam, xxsesion);
         RETURN 109843;
      END IF;

-- Insertamos los parametros genericos para el calculo de un seguro.
      e := f_graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 329, vparam, xxsesion || ' FECEFE=' || xfecefe);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 336, vparam,
                     xxsesion || ' FNOTIFI=' || xfnotifi);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 343, vparam,
                     xxsesion || ' FSINIES=' || xfsinies);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SSEGURO', psseguro);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 350, vparam,
                     xxsesion || ' SSEGURO=' || psseguro);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 357, vparam,
                     xxsesion || ' NSINIES=' || pnsinies);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 364, vparam,
                     xxsesion || ' SPRODUC=' || psproduc);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CACTIVI', pcactivi);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 371, vparam,
                     xxsesion || ' CACTIVI=' || pcactivi);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 378, vparam,
                     xxsesion || ' CGARANT=' || pcgarant);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 385, vparam,
                     xxsesion || ' CCAUSIN=' || pccausin);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 392, vparam,
                     xxsesion || ' CMOTSIN=' || pcmotsin);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 399, vparam,
                     xxsesion || ' NRIESGO=' || xnriesgo);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FVALORA', xfecval);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 406, vparam, xxsesion || ' FVALORA=' || xfecval);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FPERINI', xxfperini);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 413, vparam,
                     xxsesion || ' FPERINI=' || xxfperini);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FPERFIN', xxfperfin);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 420, vparam,
                     xxsesion || ' FPERFIN=' || xxfperfin);
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NTRAMIT', pntramit);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 420, vparam,
                     xxsesion || ' NTRAMIT=' || pntramit);
         RETURN 109843;
      END IF;

      --Ini Bug 27487/159742:NSS;28/11/2013
      e := f_graba_param(xxsesion, 'NDIAS', xxndias);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      --Fin Bug 27487/159742:NSS;28/11/2013
      IF pcgarant IS NOT NULL THEN
         BEGIN
            -- Bug 24708 - 25/06/2014  - JTT: Obtenim el MAX(nmovimi) a fsinies
            SELECT NVL(icapital, 0)
              INTO vicapital
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = xnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = pcgarant
                                 AND TRUNC(finiefe) <= TRUNC(pfsinies)
                                 AND(ffinefe IS NULL
                                     OR TRUNC(pfsinies) <= TRUNC(ffinefe)));
         EXCEPTION
            WHEN OTHERS THEN
               vicapital := 0;
         END;

         e := f_graba_param(xxsesion, 'CAPITAL', vicapital);

         IF e <> 0 THEN
            p_tab_error(f_sysdate, f_user, vobj, 450, vparam,
                        xxsesion || ' CAPITAL=' || vicapital);
            RETURN 109843;
         END IF;
      END IF;

      --25607
      SELECT MAX(nmovimi)
        INTO xxnmovimi
        FROM garanseg
       WHERE sseguro = psseguro
         AND TRUNC(finiefe) >= TRUNC(pfsinies);

      IF xxnmovimi IS NULL THEN
         SELECT MAX(nmovimi)
           INTO xxnmovimi
           FROM garanseg
          WHERE sseguro = psseguro;
      END IF;

      e := f_graba_param(xxsesion, 'NMOVIMIS', xxnmovimi);

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 472, vparam,
                     xxsesion || ' NMOVIMIS=' || xxnmovimi);
         RETURN 109843;
      END IF;

      FOR reg IN cur_campo(pccausin, pcmotsin, psproduc, pcactivi, pcgarant, vctramit) LOOP
         BEGIN
            SELECT formula
              INTO xxformula
              FROM sgt_formulas
             WHERE clave = reg.cclave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               p_tab_error(f_sysdate, f_user, vobj, 484, vparam,
                           xxsesion || ' sgt_formulas ' || reg.cclave || ' NO_DATA_FOUND');
               RETURN 108423;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, vobj, 487, vparam,
                           xxsesion || ' sgt_formulas ' || reg.cclave || ' ' || SQLCODE || ' '
                           || SQLERRM);
               RETURN 108423;
         END;

         -- Cargo parametros predefinidos
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         FOR term IN cur_termino(reg.cclave) LOOP
            BEGIN
               IF (term.parametro <> 'IVALSIN'
                   AND term.parametro <> 'ICAPRIS'
                   AND term.parametro <> 'IFRANQ'   --Bug 27059:NSS:05/06/2013
                   AND term.parametro <> 'CAPITAL') THEN   --Bug 24708:JTT:04/07/2014
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PAC_SIN_FORMULA';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

                  IF INSTR(xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
                  END IF;

                  IF INSTR(xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
                  END IF;

                  IF INSTR(xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
                  END IF;

                  IF INSTR(xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
                  END IF;

                  IF INSTR(xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                  END IF;

                  IF INSTR(xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                  END IF;

                  IF INSTR(xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
                  END IF;

                  IF INSTR(xs, ':FVALORA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FVALORA', xfecval);
                  END IF;

                  IF INSTR(xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
                  END IF;

                  IF INSTR(xs, ':NTRAMIT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', pntramit);
                  END IF;

                  --JRH NDURPER Necesita NMOVIMI
                  DECLARE
                     nmovimi        NUMBER;
                  BEGIN
                     SELECT MAX(m.nmovimi)
                       INTO nmovimi
                       FROM movseguro m
                      WHERE m.sseguro = psseguro
                        AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF INSTR(xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                        END IF;
                  END;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF retorno IS NULL THEN
                        p_tab_error(f_sysdate, f_user, vobj, 604, vparam,
                                    xxsesion || ' Formula:' || xs);
                        RETURN 103135;
                     ELSE
                        e := f_graba_param(xxsesion, term.parametro, retorno);

                        IF e <> 0 THEN
                           p_tab_error(f_sysdate, f_user, vobj, 610, vparam,
                                       xxsesion || ' Formula:' || xs);
                           RETURN 109843;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        e := f_graba_param(xxsesion, term.parametro, 0);

                        IF e <> 0 THEN
                           p_tab_error(f_sysdate, f_user, vobj, 619, vparam,
                                       xxsesion || ' ' || term.parametro || ' ' || 0);
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         --e := PAC_CALCULO_FORMULAS.calcula_terminos (xxsesion, reg.clave, 'PK_CALC_SINI', 0);
         p_carga_preguntas(psseguro, pfsinies, pcgarant, xxsesion, NULL, pnsinies);
         val := pk_formulas.eval(xxformula, xxsesion);

         IF (val IS NULL
             OR val < 0) THEN
            p_tab_error(f_sysdate, f_user, vobj, 637, vparam,
                        xxsesion || ' Formula:' || xxformula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'ICAPRIS' THEN
               e := f_graba_param(xxsesion, 'ICAPRIS', val);
               xicapris := val;

               IF e <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobj, 645, vparam, xxsesion || ' ICAPRIS');
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IVALSIN' THEN
               e := f_graba_param(xxsesion, 'IVALSIN', val);
               xivalsin := val;

               IF e <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobj, 653, vparam, xxsesion || ' IVALSIN');
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IPENALI' THEN
               e := f_graba_param(xxsesion, 'IPENALI', val);
               xipenali := val;

               IF e <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobj, 661, vparam, xxsesion || ' IPENALI');
                  RETURN 109843;
               END IF;
            --Ini Bug 27059:NSS:05/06/2013
            ELSIF reg.ccampo = 'IFRANQ' THEN
               e := f_graba_param(xxsesion, 'IFRANQ', val);
               xifranq := val;

               IF e <> 0 THEN
                  p_tab_error(f_sysdate, f_user, vobj, 670, vparam, xxsesion || ' IFRANQ');
                  RETURN 109843;
               END IF;
            --Fin Bug 27059:NSS:05/06/2013
            END IF;
         END IF;
      END LOOP;

--
      e :=
         pac_sin_formula.f_insertar_mensajes
                                    (0, psseguro, 0, 0,

                                     --Se cambia por que la fecha de orden del pago automatico debe ser la fecha de notificacion del siniestro
                                     TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd')),   --Bug 28384:NSS:14/11/2013.
                                     pcactivi, NULL, 1, pcgarant, xivalsin, 0, 0, 0, 0, 0, 0,
                                     0, xicapris, xipenali, 0, xxfperini, xxfperfin, xifranq,   --Bug 27059:NSS:05/06/2013
                                     xxndias   --Bug 27487/159742:NSS;28/11/2013
                                            );

      IF e <> 0 THEN
         p_tab_error(f_sysdate, f_user, vobj, 690, vparam,
                     xxsesion || ' pac_sin_formula.f_insertar_mensajes: ' || e);
         RETURN e;
      END IF;

-- Borro sgt_parms_transitorios
      e := f_borra_param(xxsesion);
      -- Bug 12207 - 19/02/2010 - AMC
      v_cmonres := NVL(pac_monedas.f_moneda_producto_char(vsproduc), 'EUR');   -- Bug 29696 - NSS - 15/01/2014
      xivalsin := f_round_moneda(xivalsin, v_cmonres);
      xipenali := f_round_moneda(xipenali, v_cmonres);
      xicapris := f_round_moneda(xicapris, v_cmonres);
      xifranq := f_round_moneda(xifranq, v_cmonres);   --Bug 27059:NSS:05/06/2013

      -- Fi Bug 12207 - 19/02/2010 - AMC
      IF xivalsin IS NULL THEN
         pivalora := 0;
      ELSE
         pivalora := xivalsin;
      END IF;

      IF xipenali IS NULL THEN
         pipenali := 0;
      ELSE
         pipenali := xipenali;
      END IF;

      IF xicapris IS NULL THEN
         picapris := 0;
      ELSE
         picapris := xicapris;
      END IF;

      --Ini Bug 27059:NSS:05/06/2013
      IF xifranq IS NULL THEN
         pifranq := 0;
      ELSE
         pifranq := xifranq;
      END IF;

      --Fin Bug 27059:NSS:05/06/2013
      RETURN 0;
   END f_cal_valora;

   /*************************************************************************
      FUNCTION f_insertar_mensajes
         Funció que inserta missatges
         param in ptipo     : Tipus 0-Valorarització 1-Pagament
         param in pseguro   : Número segur
         param in psperson  : Número persona
         param in pctipdes  : Tipus destinatari
         param in pffecha   : Data efecto
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantia
         param in pvalsin   : Valorarització del sinistre
         param in pisinret  : Brut
         param in piresrcm  : Rendiments
         param in piresred  : Rendiments Reduïts
         param in piconret  : Import Base
         param in ppretenc  : % de Retenció
         param in piretenc  : Import de Retenció
         param in piimpsin  : Import Net
         param in picapris  : Capital en risc de la valorarització
         param in pipenali  : import penalizació
         param in piprimas  : primes satisfetes
         param in pfperini  : Data inici pagament
         param in pfperfin  : Data fi pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_insertar_mensajes(
      ptipo IN NUMBER,
      pseguro IN seguros.sseguro%TYPE,
      psperson IN sin_tramita_destinatario.sperson%TYPE,
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE,
      pffecha IN NUMBER,
      pcactivi IN activisegu.cactivi%TYPE,
      pnmovres IN sin_tramita_reserva.nmovres%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pivalsin IN sin_tramita_reserva.ireserva%TYPE,
      pisinret IN NUMBER,
      piresrcm IN NUMBER,
      piresred IN NUMBER,
      piconret IN NUMBER,
      ppretenc IN NUMBER,
      piretenc IN NUMBER,
      piimpsin IN NUMBER,
      picapris IN NUMBER,
      pipenali IN NUMBER,
      piprimas IN NUMBER,
      pfperini IN NUMBER,
      pfperfin IN NUMBER,
      pifranq IN sin_tramita_reserva.ifranq%TYPE DEFAULT NULL,   --Bug 27059:NSS:05/06/2013
      pndias IN sin_tramita_reserva.ndias%TYPE   --Bug 27487/159742:NSS;28/11/2013
                                              )
      RETURN NUMBER IS
   BEGIN
      gnvalor := gnvalor + 1;
      valores(gnvalor).ttipo := ptipo;
      valores(gnvalor).ssegu := pseguro;
      valores(gnvalor).perso := psperson;
      valores(gnvalor).desti := pctipdes;
      valores(gnvalor).ffecefe := pffecha;
      valores(gnvalor).ivalsin := pivalsin;
      valores(gnvalor).isinret := pisinret;
      valores(gnvalor).iresrcm := piresrcm;
      valores(gnvalor).iresred := piresred;
      valores(gnvalor).iconret := piconret;
      valores(gnvalor).pretenc := ppretenc;
      valores(gnvalor).iretenc := piretenc;
      valores(gnvalor).iimpsin := piimpsin;
      valores(gnvalor).nmovres := pnmovres;
      valores(gnvalor).ctipres := pctipres;
      valores(gnvalor).cgarant := pcgarant;
      valores(gnvalor).cactivi := pcactivi;
      valores(gnvalor).icapris := picapris;
      valores(gnvalor).ipenali := pipenali;
      valores(gnvalor).iprimas := piprimas;
      valores(gnvalor).fperini := pfperini;
      valores(gnvalor).fperfin := pfperfin;
      valores(gnvalor).ifranq := pifranq;   --Bug 27059:NSS:05/06/2013
      RETURN 0;
   END f_insertar_mensajes;

   /*************************************************************************
      FUNCTION f_graba_param
         Funció que graba en la taula de paràmetres transitoris paràmetres de càlcul
         param in pnsesion : Codi sessió
         param in pparam   : Paràmetre
         param in pvalor   : Valor
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_graba_param(pnsesion IN NUMBER, pparam IN VARCHAR2, pvalor IN NUMBER)
      RETURN NUMBER IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
        -- I - JLB - OPTIM
       /* INSERT INTO sgt_parms_transitorios
                  (sesion, parametro, valor)
           VALUES (pnsesion, pparam, pvalor);

      COMMIT;
      RETURN 0;
      */
      RETURN pac_sgt.put(pnsesion, pparam, pvalor);
   EXCEPTION
         /*WHEN DUP_VAL_ON_INDEX THEN
         UPDATE sgt_parms_transitorios
            SET valor = pvalor
          WHERE sesion = pnsesion
            AND parametro = pparam;

         COMMIT;
         RETURN 0;
      */
      WHEN OTHERS THEN
         -- COMMIT;
         RETURN 109843;
   END f_graba_param;

   /*************************************************************************
      FUNCTION f_borra_param
         Funció que borra paràmetres grabats en la sessió
         param in pnsesion : Codi sessió
         return            : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_borra_param(pnsesion IN NUMBER)
      RETURN NUMBER IS
   BEGIN
        -- i -- jlb
      --  DELETE FROM sgt_parms_transitorios
      --        WHERE sesion = pnsesion;
      RETURN pac_sgt.del(pnsesion);
--      RETURN 0;
         -- F -- jlb
   EXCEPTION
      WHEN OTHERS THEN
         RETURN -9;
   END f_borra_param;

   /*************************************************************************
      FUNCTION f_calcula_pago
         Funció que calcula un pagament a partir d'una reserva
         param in pnsinies  : Número Sinistre
         param in pntramit  : Número Tramitació
         param in psproduc  : Seqüencial Producte
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantia
         param in psseguro  : Seqüencial Seguro
         param in pfsinies  : Data Sinistre
         param in pccausin  : Codi Causa
         param in pcmotsin  : Codi Motiu
         param in pfnotifi  : Data Notificació
         param in psperdes  : Seqüencial Persona Destinatari
         param in pctipdes  : Codi Tipus Destinatari
         param in pidres    : Identificador de reserva
         param in pnriesgo  : Número Risc
         param in pfperini  : Data Periode Inici
         param in pfperfin  : Data Periode Fi
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 31294 - 09/07/2014 - JTT: Se añade el parametro idres.
   *************************************************************************/
   FUNCTION f_calcula_pago(
      pnsinies IN sin_siniestro.nsinies%TYPE,   -- Nro. de Siniestro
      pntramit IN sin_tramitacion.ntramit%TYPE,   -- Nro. Tramitacion
      psproduc IN productos.sproduc%TYPE,   -- SPRODUC
      pcactivi IN activisegu.cactivi%TYPE,   -- Actividad
      pcgarant IN garangen.cgarant%TYPE,   -- Garantía
      psseguro IN sin_siniestro.sseguro%TYPE,   -- SSEGURO
      pfsinies IN sin_siniestro.fsinies%TYPE,   -- Fecha
      pccausin IN sin_siniestro.ccausin%TYPE,   -- Causa del Siniestro
      pcmotsin IN sin_siniestro.cmotsin%TYPE,   -- Subcausa
      pfnotifi IN sin_siniestro.fnotifi%TYPE,   -- Fecha de Notificacion
      psperdes IN sin_tramita_destinatario.sperson%TYPE,   -- sperson del destinatario
      pctipdes IN sin_tramita_destinatario.ctipdes%TYPE,   -- tipo de destinatario
      pidres IN sin_tramita_reserva.idres%TYPE,   -- Identificador de reserva afectada
      pnriesgo IN sin_siniestro.nriesgo%TYPE DEFAULT NULL,   -- Riesgo
      pfperini IN sin_tramita_reserva.fresini%TYPE DEFAULT NULL,   -- Fecha Inicio Pago
      pfperfin IN sin_tramita_reserva.fresfin%TYPE DEFAULT NULL,   -- Fecha Fin Pago
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha de Entrada del siniestro
      xfecefe        NUMBER;
      xfnotifi       NUMBER;
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       sin_tramita_reserva.ireserva%TYPE;   -- Valoración del siniestro
      xipenali       sin_tramita_reserva.ipenali%TYPE;   -- Penalización del siniestro
      xisinret       sin_tramita_pago.isinret%TYPE;   -- Bruto
      xiresrcm       sin_tramita_pago.iresrcm%TYPE;   -- Rendimientos
      xiresred       sin_tramita_pago.iresred%TYPE;   -- Rendimientos Reducidos
      xiconret       sin_tramita_pago.isinret%TYPE;   -- Base de Retención
      xpretenc       sin_tramita_pago_gar.pretenc%TYPE;   -- % de Retención
      xiretenc       sin_tramita_pago.iretenc%TYPE;   -- Importe de Retención
      xiimpsin       NUMBER;   -- Importe Neto
      xsinacum       NUMBER;   -- Acumulado de Brutos
      xicapris       NUMBER;   -- Importe de Capital de Riesgo
      xnriesgo       NUMBER;
      xxcodigo       VARCHAR2(30);
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      -- 07/07/2008
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xfperini       NUMBER;
      xfperfin       NUMBER;
      -- Bug 16040 - 23/09/2010 - SRA
      vbhayformula   BOOLEAN := FALSE;

      CURSOR cur_campo(wcdestin NUMBER) IS
         SELECT   DECODE(ccampo,
                         'ISINRET', 4,
                         'IRESRCM', 5,
                         'IRESRED', 6,
                         'ICONRET', 7,
                         'PRETENC', 8,
                         'IRETENC', 9,
                         'IIMPSIN', 10) orden,
                  ccampo, cclave, ctipdes, scaumot
             FROM sin_for_causa_motivo
            WHERE scaumot IN(SELECT scm.scaumot
                               FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm,
                                    sin_tramitacion st
                              WHERE st.nsinies = pnsinies
                                AND st.ntramit = pntramit
                                AND st.ctramit = sgcm.ctramit
                                AND sgcm.sproduc = psproduc
                                AND sgcm.cactivi = pcactivi
                                AND sgcm.cgarant = pcgarant
                                AND scm.scaumot = sgcm.scaumot
                                AND scm.ccausin = pccausin
                                AND scm.cmotsin = pcmotsin)
              AND ctipdes = wcdestin
              AND ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI', 'ISINRET', 'IRESRCM', 'IRESRED',
                            'ICONRET', 'PRETENC', 'IRETENC', 'IIMPSIN')
         ORDER BY 1;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;
   BEGIN
      xsinacum := 0;
      xfsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      xfnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));
      xfecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'yyyymmdd'));
      xfperini := TO_NUMBER(TO_CHAR(pfperini, 'yyyymmdd'));
      xfperfin := TO_NUMBER(TO_CHAR(pfperfin, 'yyyymmdd'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF pnriesgo IS NULL THEN
         BEGIN
            SELECT nriesgo
              INTO xnriesgo
              FROM siniestros
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104755;   -- calve no esncontrada en siniestros
         END;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

      -- Insertamos parametros genericos para el calculo de los pagos de un siniestro.
      e := pac_sin_formula.f_graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'SSEGURO', psseguro);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'CACTIVI', pcactivi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'ISINACU', xsinacum);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'FPERINI', xfperini);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'FPERFIN', xfperfin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := pac_sin_formula.f_graba_param(xxsesion, 'NTRAMIT', pntramit);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      -- Bug 31294 - 04/07/2014 - JTT: Añadimos a los parametros de formulas :IDRES, :CTIPDES
      e := pac_sin_formula.f_graba_param(xxsesion, 'IDRES', pidres);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      FOR reg IN cur_campo(pctipdes) LOOP
         -- Bug 16040 - 23/09/2010 - SRA
         vbhayformula := TRUE;
         e := pac_sin_formula.f_graba_param(xxsesion, 'SPERDES', psperdes);

         IF e <> 0 THEN
            RETURN 109843;
         END IF;

         e := pac_sin_formula.f_graba_param(xxsesion, 'CTIPDES', pctipdes);

         IF e <> 0 THEN
            RETURN 109843;
         END IF;

         --
         BEGIN
            SELECT formula, codigo
              INTO xxformula, xxcodigo
              FROM sgt_formulas
             WHERE clave = reg.cclave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- Cargo parametros predefinidos
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         -- 07/07/2008 Se rechaza el patch SNVA_249 Utilización de bind variables
         FOR term IN cur_termino(reg.cclave) LOOP
            BEGIN
               BEGIN
                  SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                         || ' WHERE ' || twhere || ' ; END;'
                    INTO xs
                    FROM sgt_carga_arg_prede
                   WHERE termino = term.parametro
                     AND ttable IS NOT NULL
                     AND cllamada = 'PAC_SIN_FORMULA';
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'GENERICO';
               END;

               -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               v_cursor := DBMS_SQL.open_cursor;
               DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
               DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

               IF INSTR(xs, ':NSINIES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
               END IF;

               IF INSTR(xs, ':FECEFE') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
               END IF;

               IF INSTR(xs, ':FNOTIFI') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
               END IF;

               IF INSTR(xs, ':FSINIES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
               END IF;

               IF INSTR(xs, ':SSEGURO') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
               END IF;

               IF INSTR(xs, ':SPRODUC') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
               END IF;

               IF INSTR(xs, ':CACTIVI') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
               END IF;

               IF INSTR(xs, ':CGARANT') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
               END IF;

               IF INSTR(xs, ':NRIESGO') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
               END IF;

               IF INSTR(xs, ':SPERDES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':SPERDES', psperdes);
               END IF;

               IF INSTR(xs, ':CTIPDES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':CTIPDES', pctipdes);
               END IF;

               IF INSTR(xs, ':FECHA') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
               END IF;

               IF INSTR(xs, ':NTRAMIT') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', pntramit);
               END IF;

               IF INSTR(xs, ':IDRES') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':IDRES', pidres);
               END IF;

               --JRH NDURPER Necesita NMOVIMI
               DECLARE
                  nmovimi        NUMBER;
               BEGIN
                  SELECT MAX(m.nmovimi)
                    INTO nmovimi
                    FROM movseguro m
                   WHERE m.sseguro = psseguro
                     AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

                  IF INSTR(xs, ':NMOVIMI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                     END IF;
               END;

               BEGIN
                  v_filas := DBMS_SQL.EXECUTE(v_cursor);
                  DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  IF retorno IS NULL THEN
                     p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_calcula_pago', 1,
                                 'Sesion:' || xxsesion,
                                 'Formula:' || xxformula || ' Sentencia:' || xs);
                     RETURN 103135;
                  ELSE
                     e := pac_sin_formula.f_graba_param(xxsesion, term.parametro, retorno);

                     IF e <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, getuser, 'PAC_SIN_FORMULA.f_calcula_pago', 2,
                                 'Error al evaluar la formula', SQLERRM);
                     p_tab_error(f_sysdate, getuser, 'PAC_SIN_FORMULA.f_calcula_pago', 2,
                                 'Formula:', xs);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     e := pac_sin_formula.f_graba_param(xxsesion, term.parametro, 0);

                     IF e <> 0 THEN
                        RETURN 109843;
                     END IF;
               END;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         --BUG 35608-212247 KJSC 18/08/2015 Adicionar 2 parametros en el packages PAC_SIN_FORMULA, la función F_CALCULA_PAGO
         pac_sin_formula.p_carga_preguntas(psseguro, pfsinies, pcgarant, xxsesion, NULL,
                                           pnsinies);
         val := pk_formulas.eval(xxformula, xxsesion);

         --
         IF val IS NULL THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_calcula_pago', 3,
                        'Sesion:' || xxsesion, 'Formula:' || xxformula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'IVALSIN' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'IVALSIN', val);
               xivalsin := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'ICAPRIS' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'ICAPRIS', val);
               xicapris := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IPENALI' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'IPENALI', val);
               xipenali := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;

               IF xipenali > 0 THEN
                  xivalsin := xivalsin - xipenali;
                  e := pac_sin_formula.f_graba_param(xxsesion, 'IVALSIN', xivalsin);

                  IF e <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            END IF;

            IF reg.ccampo = 'ISINRET' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'ISINRET', val);
               xisinret := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;

               xsinacum := xsinacum + val;
               e := pac_sin_formula.f_graba_param(xxsesion, 'ISINACU', xsinacum);

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRESRCM' THEN
               -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
               IF pimprcm IS NOT NULL THEN
                  e := pac_sin_formula.f_graba_param(xxsesion, 'IRESRCM', pimprcm);
                  xiresrcm := pimprcm;
               ELSE
                  -- Fin Bug 13829
                  e := pac_sin_formula.f_graba_param(xxsesion, 'IRESRCM', val);
                  xiresrcm := val;
               END IF;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRESRED' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'IRESRED', val);
               xiresred := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'ICONRET' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'ICONRET', val);
               xiconret := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'PRETENC' THEN
               -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
               IF ppctreten IS NOT NULL THEN
                  e := pac_sin_formula.f_graba_param(xxsesion, 'PRETENC', ppctreten);
                  xpretenc := ppctreten;
               ELSE
                  -- Fin Bug 13829
                  e := pac_sin_formula.f_graba_param(xxsesion, 'PRETENC', val);
                  xpretenc := val;
               END IF;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IRETENC' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'IRETENC', val);
               xiretenc := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;

            IF reg.ccampo = 'IIMPSIN' THEN
               e := pac_sin_formula.f_graba_param(xxsesion, 'IIMPSIN', val);
               xiimpsin := val;

               IF e <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;
      END LOOP;   -- SIN_FOR_CAUSA_MOTIVO

      -- Bug 16040 - 23/09/2010 - SRA: en caso de que no hubiera ninguna fórmula definida retornamos un mensaje de error
      IF NOT vbhayformula THEN
         RETURN 9901490;
      END IF;

      --
      xivalsin := f_round_moneda(xivalsin, 'EUR');
      xisinret := f_round_moneda(xisinret, 'EUR');
      xiresrcm := f_round_moneda(xiresrcm, 'EUR');
      xiresred := f_round_moneda(xiresred, 'EUR');
      xiconret := f_round_moneda(xiconret, 'EUR');
      xiretenc := f_round_moneda(xiretenc, 'EUR');
      xiimpsin := f_round_moneda(xiimpsin, 'EUR');
      xipenali := f_round_moneda(xipenali, 'EUR');   -- 23764:ASN:15/10/2012
      e :=
         pac_sin_formula.f_insertar_mensajes
                                     (1, psseguro, psperdes, pctipdes,
                                      TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd')),   --BUG 28384:NSS:15/11/2013
                                      pcactivi, NULL, 1, pcgarant, xivalsin, xisinret,
                                      xiresrcm, xiresred, xiconret, xpretenc,
-- 23764:ASN:15/10/2012 ini
                                           --  xiretenc, xiimpsin, 0, 0, 0, xfperini, xfperfin);
                                      xiretenc, xiimpsin, 0, NVL(xipenali, 0), 0, xfperini,
                                      xfperfin);

-- 23764:ASN:15/10/2012 fin
-- I - JLB -- OPTIMI
--      DELETE      sgt_parms_transitorios
 --           WHERE sesion = xxsesion
 --             AND parametro IN('ISINRET', 'IRESRCM', 'IRESRED', 'ICONRET', 'PRETENC',
 --                              'PRETENC', 'IRETENC', 'IIMPSIN');
 -- F - JLB - OPTIMI

      --
      IF e <> 0 THEN
         RETURN e;
      END IF;

      -- Borro sgt_parms_transitorios
      e := pac_sin_formula.f_borra_param(xxsesion);
      RETURN 0;
   END f_calcula_pago;

   /*************************************************************************
      FUNCTION f_genera_pago
         Funció que genera un pagament a partir d'una reserva
         param in psseguro  : Seqüencial Seguro
         param in pnriesgo  : Número Risc
         param in psproduc  : Seqüencial Producte
         param in pcactivi  : Codi Activitat
         param in pnsinies  : Número Sinistre
         param in pntramit  : Número Tramitació
         param in pccausin  : Codi Causa
         param in pcmotsin  : Codi Motiu
         param in pfsinies  : Data Sinistre
         param in pfnotifi  : Data Notificació
         param in pfperini  : Data Periode Inici
         param in pfperfin  : Data Periode Fi
         param in pimprcm   : Parametrizacion y adaptacion de rescates
         param in ppctreten : Parametrizacion y adaptacion de rescates
         param in pidres    : Identificador de la reserva
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 31294 - 04/07/2014 - JTT: Añadimos el parametro pidres
   *************************************************************************/
   FUNCTION f_genera_pago(
      psseguro IN sin_siniestro.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
-- Bug 16219. FAL. 06/10/2010. Parametrizar que la generación del pago sea por garantia
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
-- Fi Bug 16219
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE DEFAULT 0,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,   -- Causa del Siniestro
      pcmotsin IN sin_siniestro.cmotsin%TYPE,   -- Motivo
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,   -- Fecha de Notificacion
      pfperini IN sin_tramita_reserva.fresini%TYPE DEFAULT NULL,   -- Fecha Inicio
      pfperfin IN sin_tramita_reserva.fresfin%TYPE DEFAULT NULL,   -- Fecha Fin
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      pidres IN sin_tramita_reserva.idres%TYPE DEFAULT NULL)   -- Identificador de la reserva
      RETURN NUMBER IS
      next_loop      EXCEPTION;
      -- Variables de asegurados
      xnroaseg       NUMBER;   -- Nro de Asegurados
      -- Variables para mandar al calculo
      num_err        NUMBER;   -- Valor de retorno de funciones.
      --
      xnriesgo       sin_siniestro.nriesgo%TYPE;
      v_provisio     NUMBER;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_num_destinataris NUMBER := 0;
   BEGIN
      DELETE FROM sin_primas_consumidas
            WHERE nsinies = pnsinies;

      SELECT COUNT(*)
        INTO v_num_destinataris
        FROM sin_tramita_destinatario
       WHERE nsinies = pnsinies
         AND ntramit = pntramit
         AND pasigna > 0;

      FOR dest IN (SELECT DISTINCT DECODE(ctipdes, 6, 1, 2) orden, ctipdes, sperson, pasigna
                              FROM sin_tramita_destinatario
                             WHERE nsinies = pnsinies
                               AND ntramit = pntramit
                          ORDER BY 1, 2) LOOP
         IF dest.ctipdes = 1
            AND pnriesgo IS NULL THEN
            BEGIN
               SELECT norden
                 INTO xnriesgo
                 FROM asegurados
                WHERE sperson = dest.sperson
                  AND sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  xnriesgo := NULL;
            END;
         ELSE
            xnriesgo := pnriesgo;
         END IF;

         FOR reg IN
                    -- BUG 18423/104212 - Solo se permiten pagos automáticos para reservas indemnizatorias
                    -- Bug 16219. FAL. 06/10/2010. Parametrizar que la generación del pago sea por garantia
                    -- Bug 31294/178338 - 04/07/2014 -  JTT: Añadimos a la condicion el pidres
                   (SELECT DISTINCT ctipres, cgarant, cmonres, ctipgas, idres   -- 26108
                               FROM sin_tramita_reserva
                              WHERE nsinies = pnsinies
                                AND ntramit = pntramit
                                AND ctipres = 1
                                AND cgarant = NVL(pcgarant, cgarant)
                                AND idres = NVL(pidres, idres)) LOOP
            BEGIN
               -- Bug 31294 - 04/07/2014 - JTT:
               -- No generamos pagos cuando el % ASIGNADO es del 0% y hay otros destinatarios con un % > 0.
               -- El sistema considera un destinatario con pasigna = 0 ó NULL que es del 100%
               -- por eso no podemos descartarlos si es destinatario unico
               IF NVL(dest.pasigna, 0) = 0
                  AND v_num_destinataris > 0 THEN
                  RAISE next_loop;
               END IF;

               -- Se recuperará la provisión del siniestro
               num_err := pac_siniestros.f_tramita_reserva(pnsinies, pntramit, reg.ctipres,
                                                           reg.ctipgas,   -- 26108
                                                           reg.cgarant, reg.cmonres,
                                                           GREATEST(pfsinies, TRUNC(f_sysdate)),
                                                           v_provisio, reg.idres);   --0031294

               IF NVL(v_provisio, 0) <> 0 THEN
                  -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
                  IF pimprcm IS NOT NULL
                     OR ppctreten IS NOT NULL THEN
                     num_err := pac_sin_formula.f_calcula_pago(pnsinies, pntramit, psproduc,
                                                               pcactivi, reg.cgarant,
                                                               psseguro, pfsinies, pccausin,
                                                               pcmotsin, pfnotifi,
                                                               dest.sperson, dest.ctipdes,
                                                               reg.idres, xnriesgo,   --0031294
                                                               pfperini, pfperfin, pimprcm,
                                                               ppctreten);
                  ELSE
                     -- Fin Bug 13829
                     num_err := pac_sin_formula.f_calcula_pago(pnsinies, pntramit, psproduc,
                                                               pcactivi, reg.cgarant,
                                                               psseguro, pfsinies, pccausin,
                                                               pcmotsin, pfnotifi,
                                                               dest.sperson, dest.ctipdes,
                                                               reg.idres, xnriesgo,   --0031294
                                                               pfperini, pfperfin);
                  END IF;

                  IF num_err <> 0 THEN
                     RETURN num_err;
                  END IF;
               END IF;
            EXCEPTION
               WHEN next_loop THEN
                  NULL;
            END;
         END LOOP;
      END LOOP;

      RETURN 0;
   END f_genera_pago;

   /*************************************************************************
      FUNCTION f_inserta_pago
         Funció que inserta un pagament de manera automática
         param in pnsinies  : Número Sinistre
         param in pntramit  : Número Tramitació
         param in psidepag  : Identificador pagament
         param in pipago    : Import pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_inserta_pago(
      pnsinies IN sin_tramita_pago.nsinies%TYPE,
      pntramit IN sin_tramita_pago.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      psidepag OUT sin_tramita_pago.sidepag%TYPE,
      pipago OUT sin_tramita_pago.isinret%TYPE,
      pctipban IN NUMBER DEFAULT NULL,   --JGM: bug 13108 - se añade para que no grabe esto a NULL
      pcbancar IN VARCHAR2 DEFAULT NULL,   --JGM: bug 13108 - se añade para que no grabe esto a NULL
      pfresini IN sin_tramita_reserva.fresini%TYPE DEFAULT NULL,   -- BUG16506:DRA:16/12/2010
      pfresfin IN sin_tramita_reserva.fresfin%TYPE DEFAULT NULL,   -- BUG16506:DRA:16/12/2010
      pcmonres IN sin_tramita_reserva.cmonres%TYPE DEFAULT NULL,
      pctipgas IN sin_tramita_reserva.ctipgas%TYPE DEFAULT NULL)   -- 26108
      RETURN NUMBER IS
      xsidepag       sin_tramita_pago.sidepag%TYPE;
      xctippag       sin_tramita_pago.ctippag%TYPE;
      xcconpag       sin_tramita_pago.cconpag%TYPE;
      xcestpag       sin_tramita_movpago.cestpag%TYPE;
      -- Ini bug 16924 - SRA - 16/12/2010
      xcestval       sin_tramita_movpago.cestval%TYPE;
      -- Fin bug 16924 - SRA - 16/12/2010
      xcforpag       sin_tramita_pago.cforpag%TYPE;
      xctransfer     sin_tramita_pago.ctransfer%TYPE;
      xsgt_sesiones  tmp_sin_tramita_pago.ssesion%TYPE;
      vfperini       sin_tramita_pago_gar.fperini%TYPE;
      vfperfin       sin_tramita_pago_gar.fperfin%TYPE;
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      vnmovres       NUMBER;
      vcount         NUMBER;

      CURSOR dest(psgt_sesiones IN NUMBER) IS
         SELECT DISTINCT sperson
                    FROM tmp_sin_tramita_pago
                   WHERE ssesion = psgt_sesiones;

      num_err        NUMBER;
      nummy          NUMBER;

      CURSOR esvencrentas IS
         SELECT 1
           FROM sin_siniestro s, seguros seg
          WHERE s.nsinies = pnsinies
            AND s.ccausin = 3
            AND seg.sseguro = s.sseguro
            AND NVL(f_parproductos_v(seg.sproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1;

      v_sseguro      seguros.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_fnotifi      siniestros.fnotifi%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cvalpar      pargaranpro.cvalpar%TYPE;
      v_error        NUMBER;
      v_cmonres      eco_codmonedas.cmoneda%TYPE;
      v_ccauind      sin_tramita_pago.ccauind%TYPE := 1;
      v_ffecefe      sin_tramita_movpago.fefepag%TYPE;
      -- Ini bug 16924 - SRA - 16/12/2010
      vnsproduc      seguros.sproduc%TYPE;
      vccausin       sin_siniestro.ccausin%TYPE;
      vcmotsin       sin_siniestro.ccausin%TYPE;
      -- Fin bug 16924 - SRA - 16/12/2010
      v_cempres      seguros.cempres%TYPE;
      -- Bug 0022490 - 09/07/2012 - JMF
      x_scm_cultpag  sin_causa_motivo.cultpag%TYPE;
      v_idres        sin_tramita_pago_gar.idres%TYPE;   -- Bug 31294/177836
   BEGIN
      -- bug 13296 - 22/02/2010 - AMC
      xcforpag := 1;   -- Transferencia
      xctippag := 2;   -- Pago
      xcestpag := 0;   -- Pendiente
      xctransfer := 0;   -- NO TRANSFERIR

      -- Ini bug 16924 - SRA - 16/12/2010
      BEGIN
         SELECT sproduc, ccausin, cmotsin, cempres
           INTO vnsproduc, vccausin, vcmotsin, v_cempres
           FROM seguros s, sin_siniestro si
          WHERE s.sseguro = si.sseguro
            AND si.nsinies = pnsinies;

         -- Bug 0022490 - 09/07/2012 - JMF: añadir CULTPAG
         -- Bug 29224 - 02/04/2014 - JTT: Añadimos CCONPAG y CCAUIND
         SELECT DISTINCT NVL(cforpag, 1), NVL(cestpag, 0), NVL(cestval, 0), scm.cultpag,
                         scm.cconpag, NVL(scm.ccauind, 1)
                    INTO xcforpag, xcestpag, xcestval, x_scm_cultpag,
                         xcconpag, v_ccauind
                    FROM sin_gar_causa_motivo sgcm, sin_causa_motivo scm
                   WHERE sgcm.scaumot = scm.scaumot
                     AND sgcm.sproduc = vnsproduc
                     AND scm.ccausin = vccausin
                     AND scm.cmotsin = vcmotsin
                     AND sgcm.cgarant = pcgarant;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            NULL;
      END;

      -- Fin bug 16924 - SRA - 16/12/2010
      IF pcmonres IS NULL THEN   -- BUG 18423/104212 - 26/01/2012 - JMP - Multimoneda
         -- BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
            v_cmonres := pac_monedas.f_cmoneda_t(pac_oper_monedas.f_monres(pnsinies));
         ELSE
            v_cmonres := NVL(pac_eco_monedas.f_obtener_moneda_defecto, 'EUR');
         END IF;
         -- FIN BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
      -- BUG 18423/104212 - 26/01/2012 - JMP - Multimoneda
      ELSE
         v_cmonres := pcmonres;
      END IF;

      -- FIN BUG 18423/104212 - 26/01/2012 - JMP - Multimoneda
      OPEN esvencrentas;   --Si es un vencimiento de rentas se deja como pdte. de transferir.

      FETCH esvencrentas
       INTO nummy;

      IF esvencrentas%FOUND THEN
         xctransfer := 1;
      -- xcestpag := 1; -- BUG18191:DRA:06/04/2011
      END IF;

      -- Fi bug 13296 - 22/02/2010 - AMC
      CLOSE esvencrentas;

      SELECT sgt_sesiones.NEXTVAL
        INTO xsgt_sesiones
        FROM DUAL;

      FOR j IN 1 .. pac_sin_formula.valores.COUNT LOOP
         IF pac_sin_formula.valores(j).ttipo = 1 THEN
            -- 29224 - 02/04/2014 - JTT: Si no hay concepto de pago por defecto (SIN_CAUSA_SINIESTRO.cconpag) se informa segun el tipo de destinatario
            IF xcconpag IS NULL THEN
               IF pac_sin_formula.valores(j).desti = 7 THEN   -- Es tomador
                  xcconpag := 0;   -- Pago Comercial
               ELSE
                  xcconpag := 1;   -- Indemnización
               END IF;
            END IF;

            -- Bug 8744 - 03/03/2009 - JRB - Se añaden las fechas de inicio y fin del pago
            vfperini := TO_DATE(pac_sin_formula.valores(j).fperini, 'YYYYMMDD');
            vfperfin := TO_DATE(pac_sin_formula.valores(j).fperfin, 'YYYYMMDD');
            v_ffecefe := TO_DATE(pac_sin_formula.valores(j).ffecefe, 'YYYYMMDD');

            --BUG 8744 - 13/05/2009 - JRB - Se añade para comprobar que es un producto de baja y dejar pendiente de transferir.
            SELECT seg.sseguro, seg.sproduc, seg.cactivi, ss.fnotifi, seg.cramo, seg.cmodali,
                   seg.ctipseg, seg.ccolect
              INTO v_sseguro, v_sproduc, v_cactivi, v_fnotifi, v_cramo, v_cmodali,
                   v_ctipseg, v_ccolect
              FROM seguros seg, sin_siniestro ss
             WHERE ss.nsinies = pnsinies
               AND seg.sseguro = ss.sseguro;

            v_error := f_pargaranpro(v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi,
                                     pac_sin_formula.valores(j).cgarant, 'BAJA', v_cvalpar);

            IF v_cvalpar = 1 THEN
               xctransfer := 1;
            -- xcestpag := 1;  -- BUG18191:DRA:06/04/2011
            END IF;

            -- Bug 8744 - 03/03/2009 - JRB - Controla que el pago no sea 0
            IF pac_sin_formula.valores(j).perso IS NOT NULL THEN
               IF (NVL(pac_sin_formula.valores(j).iimpsin, 0) <> 0
                   OR(NVL(pac_sin_formula.valores(j).isinret, 0)
                      - NVL(pac_sin_formula.valores(j).iretenc, 0)) <> 0
                   OR NVL(pac_sin_formula.valores(j).iretenc, 0) <> 0
                   OR NVL(pac_sin_formula.valores(j).iresrcm, 0) <> 0
                   OR NVL(pac_sin_formula.valores(j).iresred, 0) <> 0) THEN
                  -- Insertar cabecera de pago
                  BEGIN
                     INSERT INTO tmp_sin_tramita_pago
                                 (ssesion, nsinies, ntramit, ctipres,
                                  cgarant,
                                  sperson,
                                  ctipdes, ctippag, cconpag,
                                  ccauind, cforpag, fefepag,
                                  ctipban, cbancar, cmonres,
                                  isinret,
                                  iretenc,
                                  pretenc,   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                                  iiva,
                                  isuplid, ifranq,
                                  iresrcm,
                                  iresred, fperini,
                                  fperfin, nfacref, ffacref, ctransfer)
                          VALUES (xsgt_sesiones, pnsinies, pntramit, pctipres,
                                  pac_sin_formula.valores(j).cgarant,
                                  pac_sin_formula.valores(j).perso,
                                  pac_sin_formula.valores(j).desti, xctippag, xcconpag,
                                  v_ccauind, xcforpag, GREATEST(v_ffecefe, TRUNC(SYSDATE)),
                                  pctipban, pcbancar, v_cmonres,
                                  NVL(pac_sin_formula.valores(j).isinret, 0),
                                  NVL(pac_sin_formula.valores(j).iretenc, 0),
                                  NVL(pac_sin_formula.valores(j).pretenc, 0),   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                                  NVL(pac_sin_formula.valores(j).iiva, 0),
                                  NVL(pac_sin_formula.valores(j).isuplid, 0), 0,
                                  NVL(pac_sin_formula.valores(j).iresrcm, 0),
                                  NVL(pac_sin_formula.valores(j).iresred, 0), vfperini,
                                  vfperfin, NULL, NULL, xctransfer);
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_sin_formula.f_inserta_pago', 666,
                                    'when others 1', SQLERRM);
                        RETURN 109022;   -- Errror en la inserción del pago
                  END;
               END IF;
            ELSE
               RETURN 102755;   -- ELEGIR DESTINATARIO
            END IF;
         END IF;
      END LOOP;

      -- Ahora hacemos el insert agrupando por destinatario y tipo de reserva
      FOR i IN dest(xsgt_sesiones) LOOP
         FOR regs IN (SELECT   p.ctipdes, p.sperson, p.ctipres, p.nmovres, p.cgarant,
                               p.cconpag, p.fefepag, p.fperini, p.fperfin, p.cmonres,
                               p.pretenc, p.piva, SUM(p.isinret) isinret,
                               SUM(p.iretenc) iretenc, SUM(p.iresrcm) iresrcm,
                               SUM(p.iresred) iresred, SUM(p.isuplid) isuplid,
                               SUM(p.iiva) iiva, d.ctipban, d.cbancar
                          FROM tmp_sin_tramita_pago p, sin_tramita_destinatario d
                         WHERE p.ssesion = xsgt_sesiones
                           AND p.sperson = i.sperson
                           AND d.nsinies = p.nsinies
                           AND d.ntramit = p.ntramit
                           AND d.sperson = p.sperson
                           AND d.ctipdes = p.ctipdes   -- Bug 31294
                      GROUP BY p.ctipdes, p.sperson, p.ctipres, p.nmovres, p.cgarant,
                               p.cconpag, p.fefepag, p.fperini, p.fperfin, p.cmonres,
                               p.pretenc, p.piva, d.ctipban, d.cbancar) LOOP
            SELECT sidepag.NEXTVAL
              INTO xsidepag
              FROM DUAL;

            -- Bug 11849 - 29/01/2010 - AMC - La fecha fordpag debe ser la fefepag
            BEGIN
               -- Bug 0022490 - 09/07/2012 - JMF: añadir CULTPAG
               -- Bug 29224 - 02/04/2014 - JTT: Informamos .ccnpag a partir de los datos el registro REGS
               INSERT INTO sin_tramita_pago
                           (sidepag, nsinies, ntramit, sperson, ctipdes,
                            ctippag, cconpag, ccauind, cforpag, fordpag,
                            ctipban, cbancar, cmonres, isinret,
                            iretenc, iiva, isuplid, iresrcm,
                            iresred, nfacref, ffacref, cusualt, falta, cultpag)
                    VALUES (xsidepag, pnsinies, pntramit, regs.sperson, regs.ctipdes,
                            xctippag, regs.cconpag, v_ccauind, xcforpag, regs.fefepag,
                            regs.ctipban, regs.cbancar, regs.cmonres, regs.isinret,
                            regs.iretenc, regs.iiva, regs.isuplid, regs.iresrcm,
                            regs.iresred, NULL, NULL, f_user, f_sysdate, x_scm_cultpag);

               -- BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
                  v_error := pac_oper_monedas.f_contravalores_pagosini(xsidepag, 1);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sin_formula.f_inserta_pago', 667,
                              'when others 2', SQLERRM);
                  RETURN 109022;   -- Error en la insercion del apunte del pago;
            END;

            --Fi Bug 11849 - 29/01/2010 - AMC - La fecha fordpag debe ser la fefepag
            psidepag := xsidepag;
            pipago := regs.isinret;

            -- BUG18191:DRA:06/04/2011:Inici: Siempre insertamos el registro "Pendiente"
            BEGIN
               INSERT INTO sin_tramita_movpago
                           (sidepag, nmovpag, cestpag, fefepag, cestval, cusualt, falta)
                    VALUES (xsidepag, 0, 0, regs.fefepag, 0, f_user, f_sysdate);
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sin_formula.f_inserta_pago', 668,
                              'when others 3', SQLERRM);
                  RETURN 109022;
            END;

            -- BUG18191:DRA:06/04/2011:Fi
            IF NVL(xcestpag, 0) <> 0
               OR NVL(xcestval, 0) <> 0 THEN
               BEGIN
                  -- Ini bug 16924 - SRA - 12/01/2011
                  INSERT INTO sin_tramita_movpago
                              (sidepag, nmovpag, cestpag, fefepag, cestval, cusualt,
                               falta)
                       VALUES (xsidepag, 1, xcestpag, regs.fefepag, xcestval, f_user,
                               f_sysdate);
               -- Fin bug 16924 - SRA - 12/01/2011
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_sin_formula.f_inserta_pago', 669,
                                 'when others 4', SQLERRM);
                     RETURN 109022;
               END;
            END IF;

            BEGIN
               SELECT MAX(nmovres)
                 INTO v_nmovres
                 FROM sin_tramita_reserva
                WHERE nsinies = pnsinies
                  AND ntramit = pntramit
                  AND ctipres = pctipres
                  AND NVL(ctipgas, -1) = NVL(pctipgas, -1)   -- 26108
                  AND((cgarant = pcgarant
                       AND pctipres = 1)
                      OR(pctipres <> 1))
                  AND((pfresini IS NOT NULL
                       AND fresini <= pfresini)
                      OR pfresini IS NULL)
                  AND((pfresfin IS NOT NULL
                       AND fresfin >= pfresfin)
                      OR pfresfin IS NULL);
            EXCEPTION
               WHEN OTHERS THEN
                  v_nmovres := NULL;
            END;

            -- Bug 31294/177836 - 27/08/2014 - JTT: Recuperamos el IDRES correspondiente a la reserva para
            -- informarlo en SIN_TRAMITA_PAGO_GAR
            BEGIN
               SELECT DISTINCT idres
                          INTO v_idres
                          FROM sin_tramita_reserva
                         WHERE nsinies = pnsinies
                           AND ntramit = pntramit
                           AND ctipres = pctipres
                           AND nmovres = v_nmovres;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_inserta_pago', 1,
                              'Obtener IDRES. nsinies = ' || pnsinies || ' ntramit = '
                              || pntramit || ' ctipres = ' || pctipres || ' nmovres = '
                              || v_nmovres,
                              SQLCODE || ' ' || SQLERRM);
                  v_idres := NULL;
            END;

            BEGIN
               INSERT INTO sin_tramita_pago_gar
                           (sidepag, ctipres, nmovres, cgarant, fperini, fperfin, cmonres,
                            isinret, iretenc, iiva, isuplid, ifranq, iresrcm, iresred,
                            pretenc, piva, cusualt, falta, idres)
                  SELECT xsidepag, ctipres, v_nmovres, cgarant, fperini, fperfin, cmonres,
                         isinret, iretenc, iiva, isuplid, ifranq, iresrcm, iresred, pretenc,
                         piva, f_user, f_sysdate, v_idres
                    FROM tmp_sin_tramita_pago
                   WHERE ssesion = xsgt_sesiones
                     AND sperson = i.sperson
                     AND ctipdes = regs.ctipdes
                     AND NVL(pretenc, 0) = NVL(regs.pretenc, 0)
                     AND fefepag = regs.fefepag;

               -- BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'MULTIMONEDA'), 0) = 1 THEN
                  v_error := pac_oper_monedas.f_contravalores_pagosini(xsidepag, 2);

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END IF;
            -- FIN BUG 18423 - 08/11/2011 - JMP - LCOL000 - Multimoneda
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate, f_user, 'pac_sin_formula.f_inserta_pago', 670,
                              'when others 4.' || SQLERRM,
                              xsidepag || '|' || v_nmovres || '|' || xsgt_sesiones || '|'
                              || i.sperson || '|' || regs.ctipdes || '|' || regs.pretenc
                              || '|' || regs.fefepag);
                  RETURN 109022;
            END;

            -- Bug 13423 - 04/03/2010 - AMC
            SELECT COUNT(1)
              INTO vcount
              FROM sin_tramita_pago
             WHERE sidepag = xsidepag;

            IF vcount > 0 THEN
               FOR c IN (SELECT rese.nmovres, rese.ccalres, rese.fmovres, rese.cmonres,
                                rese.ireserva, rese.ipago, rese.iingreso, rese.irecobro,
                                rese.fresini, rese.fresfin, rese.iprerec, rese.icaprie,
                                rese.ipenali, rese.fultpag, rese.ntramit, rese.cgarant,
                                rese.ctipres, rese.ctipgas   -- 26108
                           FROM sin_tramita_reserva rese
                          WHERE rese.nmovres = (SELECT MAX(nmovres)
                                                  FROM sin_tramita_reserva
                                                 WHERE nsinies = pnsinies
                                                   AND ntramit = pntramit
                                                   AND ctipres = pctipres
                                                   AND NVL(ctipgas, -1) =
                                                                       NVL(pctipgas, -1)   -- 26108
                                                   AND((pcgarant IS NOT NULL
                                                        AND cgarant = pcgarant)
                                                       OR pcgarant IS NULL)
                                                   AND((pfresini IS NOT NULL
                                                        AND fresini <= pfresini)
                                                       OR pfresini IS NULL)
                                                   AND((pfresfin IS NOT NULL
                                                        AND fresfin >= pfresfin)
                                                       OR pfresfin IS NULL))
                            AND rese.nsinies = pnsinies
                            AND ntramit = pntramit
                            AND ctipres = pctipres
                            AND NVL(ctipgas, -1) = NVL(pctipgas, -1)   -- 26108
                            AND((pcgarant IS NOT NULL
                                 AND cgarant = pcgarant)
                                OR pcgarant IS NULL)) LOOP
                  SELECT MAX(nmovres) + 1
                    INTO vnmovres
                    FROM sin_tramita_reserva
                   WHERE nsinies = pnsinies
                     AND ntramit = c.ntramit;

                  --AND ctipres = c.ctipres; -- 26108
                  -- Bug 40889 - 07/03/2016 - JTT: Cambios en FMOVRES = null (fecha de proceso) y CCALRES = 1
                  v_error := pac_siniestros.f_ins_reserva(pnsinies, c.ntramit, c.ctipres,
                                                          c.cgarant, 1, null,
                                                          c.cmonres,
                                                          (NVL(c.ireserva, 0) - pipago),
                                                          (NVL(c.ipago, 0) + pipago),
                                                          c.icaprie, c.ipenali, c.iingreso,
                                                          c.irecobro, c.fresini, c.fresfin,
                                                          c.fultpag, psidepag, c.iprerec,

                                                          --NULL,   -- 26108
                                                          pctipgas,   -- 26108
                                                          vnmovres, 4);   --cmovres --0031294/0174788: NSS:23/05/2014

                  IF v_error <> 0 THEN
                     RETURN v_error;
                  END IF;
               END LOOP;
            END IF;
         -- Fi Bug 13423 - 04/03/2010 - AMC
         END LOOP;
      END LOOP;

      DELETE FROM tmp_sin_tramita_pago
            WHERE ssesion = xsgt_sesiones;

      pac_sin_formula.p_borra_mensajes;
      RETURN 0;
   -- BUG -21546_108724- 08/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF esvencrentas%ISOPEN THEN
            CLOSE esvencrentas;
         END IF;

         RETURN 140999;
   END f_inserta_pago;

   /*************************************************************************
      PROCEDURE p_borra_mensajes
         Procedimiento que borra la variable valores.
   *************************************************************************/
   PROCEDURE p_borra_mensajes IS
   BEGIN
      valores.DELETE;
      gnvalor := 0;
   END p_borra_mensajes;

   /*************************************************************************
      FUNCTION f_actualiza_reserva
         Funció que actualitza la reserva amb un pagament
         param in pnsinies  : Número Sinistre
         param in pntramit  : Número Tramitació
         param in pctipres  : Tipus de reserva
         param in pcgarant  : Codi garantia
         param in pipago    : Import pagament
         param in piingreso : Import ingrès
         param in pirecobro : Import recobrament
         param in picaprie  : Import capital risc
         param in pipenali  : Import penalització
         param in pfresini  : Data inici reserva
         param in pfresfin  : Data fi reserva
         param in psidepag  : Seqüencial pagament

         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_actualiza_reserva(
      pnsinies IN sin_tramita_reserva.nsinies%TYPE,
      pntramit IN sin_tramita_reserva.ntramit%TYPE,
      pctipres IN sin_tramita_reserva.ctipres%TYPE,
      pcgarant IN sin_tramita_reserva.cgarant%TYPE,
      pipago IN sin_tramita_reserva.ipago%TYPE,
      piingreso IN sin_tramita_reserva.iingreso%TYPE,
      pirecobro IN sin_tramita_reserva.irecobro%TYPE,
      picaprie IN sin_tramita_reserva.icaprie%TYPE,
      pipenali IN sin_tramita_reserva.ipenali%TYPE,
      pfresini IN sin_tramita_reserva.fresini%TYPE,
      pfresfin IN sin_tramita_reserva.fresfin%TYPE,
      psidepag IN sin_tramita_reserva.sidepag%TYPE)
      RETURN NUMBER IS
      v_ireserva     sin_tramita_reserva.ireserva%TYPE;
      v_ipago        sin_tramita_reserva.ipago%TYPE;
      v_iingreso     sin_tramita_reserva.iingreso%TYPE;
      v_irecobro     sin_tramita_reserva.irecobro%TYPE;
      v_icaprie      sin_tramita_reserva.icaprie%TYPE;
      v_ipenali      sin_tramita_reserva.ipenali%TYPE;
      v_nmovres      sin_tramita_reserva.nmovres%TYPE;
      v_nerror       NUMBER;
   BEGIN
      BEGIN
         SELECT NVL(str.ireserva, 0), NVL(str.ipago, 0), NVL(str.iingreso, 0),
                NVL(str.irecobro, 0), NVL(str.icaprie, 0), NVL(str.ipenali, 0)
           INTO v_ireserva, v_ipago, v_iingreso,
                v_irecobro, v_icaprie, v_ipenali
           FROM sin_tramita_reserva str
          WHERE str.nsinies = pnsinies
            AND str.ntramit = pntramit
            AND str.ctipres = pctipres
            AND((str.cgarant = pcgarant
                 AND pctipres = 1)
                OR pctipres <> 1)
            AND str.nmovres = (SELECT MAX(nmovres)
                                 FROM sin_tramita_reserva
                                WHERE nsinies = str.nsinies
                                  AND ntramit = str.ntramit
                                  AND ctipres = str.ctipres
                                  AND(cgarant = str.cgarant
                                      OR str.cgarant IS NULL));
      EXCEPTION
         WHEN OTHERS THEN
            RETURN -1;
      END;

      -- Pago informado
      IF NVL(pipago, 0) <> 0 THEN
         v_ireserva := v_ireserva - NVL(pipago, 0);
         v_ipago := v_ipago + NVL(pipago, 0);
      END IF;

      -- Ingreso informado
      IF NVL(piingreso, 0) <> 0 THEN
         v_ireserva := v_ireserva + NVL(piingreso, 0);
         v_iingreso := v_iingreso + NVL(piingreso, 0);
      END IF;

      -- Recobro informado
      IF NVL(pirecobro, 0) <> 0 THEN
         v_ireserva := v_ireserva + NVL(pirecobro, 0);
         v_irecobro := v_irecobro + NVL(pirecobro, 0);
      END IF;

      -- Capital Riesgo informado
      IF NVL(picaprie, 0) <> 0 THEN
         v_icaprie := v_icaprie + NVL(picaprie, 0);
      END IF;

      -- Penalización informada
      IF NVL(pipenali, 0) <> 0 THEN
         v_ipenali := v_ipenali + NVL(pipenali, 0);
      END IF;

      -- Se crea un nuevo movimiento de reserva
      v_nerror :=
         pac_siniestros.f_ins_reserva
            (pnsinies, pntramit, pctipres, pcgarant, 1, f_sysdate, NULL,   -- BUG 18423 - 14/11/2011 - JMP - Pasamos moneda reserva NULL para que la coja en función
                                                                           -- de si es multimoneda o no
             v_ireserva, v_ipago, v_icaprie, v_ipenali, v_iingreso, v_irecobro, pfresini,
             pfresfin, NULL, psidepag, NULL, NULL, v_nmovres,
             4   --cmovres --0031294/0174788: NSS:23/05/2014
              );

      IF v_nerror <> 0 THEN
         RETURN v_nerror;
      END IF;

      RETURN 0;
   END f_actualiza_reserva;

   /*************************************************************************
      FUNCTION f_simu_calc_sin
         Funció que simula un rescat
         param in psseguro  : Seqüència assegurança
         param in pnriesgo  : Número risc
         param in pactivi   : Codi activitat
         param in pcgarant  : Codi garantia
         param in psproduc  : Seqüència producte
         param in pfsinies  : Data sinistre
         param in pfnotifi  : Data notificació sinistre
         param in pccausin  : Causa sinistre
         param in cmotsin   : Motiu sinistre
         param in picapital : Capital rescatat
         param in pfecval   : Data rescat
         param in pctipdes  : Tipus destinatari

         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_simu_calc_sin(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pcactivi IN activisegu.cactivi%TYPE,
      pcgarant IN codigaran.cgarant%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      picapital IN NUMBER DEFAULT NULL,
      pfecval IN DATE DEFAULT NULL,
      pctipdes IN NUMBER DEFAULT NULL,
      pimppenali IN NUMBER DEFAULT NULL,
      pimprcm IN NUMBER DEFAULT NULL,   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      ppctreten IN NUMBER DEFAULT NULL)   -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
      RETURN NUMBER IS
      /*
       {Cursor formulas de la valoracion: destinatario 0}
      */
      CURSOR cur_campo IS
         SELECT   DECODE(sfcm.ccampo, 'ICAPRIS', 1, 'IVALSIN', 3, 'IPENALI', 2) orden,
                  sfcm.ccampo, sfcm.cclave, sfcm.ctipdes
             FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, sin_causa_motivo scm
            WHERE sfcm.scaumot = sgcm.scaumot
              AND scm.scaumot = sfcm.scaumot
              AND scm.ccausin = pccausin
              AND scm.cmotsin = pcmotsin
              AND sgcm.sproduc = psproduc
              AND sgcm.cactivi = pcactivi
              AND(sgcm.cgarant = pcgarant
                  OR pcgarant IS NULL)
              AND sgcm.ctramit = 0
              AND sfcm.ctipdes = 0
              AND sfcm.ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI')
         ORDER BY 1;

      /* {cursor de formulas para el pago} */
      CURSOR cur_pago(wcdestin NUMBER) IS
         SELECT   DECODE(sfcm.ccampo,
                         'ICAPRIS', 1,
                         'IPENALI', 2,
                         'IVALSIN', 3,
                         'ISINRET', 4,
                         'IRESRCM', 5,
                         'IRESRED', 6,
                         'ICONRET', 7,
                         'PRETENC', 8,
                         'IRETENC', 9,
                         'IIMPSIN', 10,
                         'IPRIMAS', 11) orden,
                  sfcm.ccampo, sfcm.cclave, sfcm.ctipdes
             FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, sin_causa_motivo scm
            WHERE sfcm.scaumot = sgcm.scaumot
              AND scm.scaumot = sfcm.scaumot
              AND scm.ccausin = pccausin
              AND scm.cmotsin = pcmotsin
              AND sgcm.sproduc = psproduc
              AND sgcm.cactivi = pcactivi
              AND(sgcm.cgarant = pcgarant
                  OR pcgarant IS NULL)
              AND sgcm.ctramit = 0
              AND sfcm.ctipdes = wcdestin
              AND sfcm.ccampo IN('ICAPRIS', 'IVALSIN', 'IPENALI', 'ISINRET', 'IRESRCM',
                                 'IRESRED', 'ICONRET', 'PRETENC', 'IRETENC', 'IIMPSIN',
                                 'IPRIMAS')
         ORDER BY 1;

--
      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      CURSOR cur_aseg IS
         SELECT asegurados.norden, asegurados.sperson
           FROM asegurados, seguros
          WHERE asegurados.ffecmue IS NULL
            AND asegurados.sseguro = psseguro
            AND asegurados.ffecfin IS NULL
            AND asegurados.sseguro = seguros.sseguro
            -- Bug 15298 - JRH - 12/07/2010 - 0015298: CEM210 - RESCATS: Simulació pagaments rendes per productes 2 CABEZAS
            AND((NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) =
                    1   --JRH Si 'FISCALIDAD_2_CABEZAS' =1 sólo e paga a un asegurado , el cursor debe devolver 1 registro
                 AND pccausin IN(3, 4, 5)
                 AND asegurados.norden = (SELECT MIN(as2.norden)
                                            FROM asegurados as2
                                           WHERE as2.sseguro = asegurados.sseguro
                                             AND as2.ffecmue IS NULL
                                             AND as2.ffecfin IS NULL))
                OR(NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) <> 1)
                OR(NVL(f_parproductos_v(seguros.sproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
                   AND pccausin NOT IN(3, 4, 5)));   -- BUG11183:DRA:22/09/2009

-- Fi Bug 15298 - JRH - 12/07/2010
      w_error        NUMBER;
      w_fsinies      NUMBER;
      w_fnotifi      NUMBER;
      w_fecefe       NUMBER;
      w_fecval       NUMBER;
      w_sesion       NUMBER;
      w_nriesgo      NUMBER;
      w_retorno      NUMBER;
      w_val          NUMBER;
      w_ctipdes      NUMBER;
      w_ivalsin      NUMBER;
      w_icapris      NUMBER;
      w_ipenali      NUMBER;
      w_isinret      NUMBER;
      w_sinacum      NUMBER;
      w_iresred      NUMBER;
      w_iresrcm      NUMBER;
      w_iconret      NUMBER;
      w_pretenc      NUMBER;
      w_iretenc      NUMBER;
      w_iimpsin      NUMBER;
      w_nsinies      NUMBER := 0;
      w_formula      VARCHAR2(2000);
      w_xs           VARCHAR2(2000);
      w_codigo       VARCHAR2(2000);
      w_isinret_total NUMBER := 0;
      w_iresrcm_total NUMBER := 0;
      w_iresred_total NUMBER := 0;
      w_iconret_total NUMBER := 0;
      w_iretenc_total NUMBER := 0;
      w_iimpsin_total NUMBER := 0;
      xcuantos       NUMBER;
      w_iprimas      NUMBER;
      w_iprimas_total NUMBER := 0;
      -- 07/07/2008
      v_cursor       INTEGER;
      v_filas        NUMBER;
      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      pac_sin_formula.p_borra_mensajes;
      /*
      {convertimos las fechas a formato numerico}
      */
      w_fsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      w_fnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN
         SELECT TO_NUMBER(TO_CHAR(NVL(sa.frevant, s.fefecto), 'YYYYMMDD'))
           INTO w_fecefe
           FROM seguros_aho sa, seguros s
          WHERE sa.sseguro = s.sseguro
            AND s.sseguro = psseguro;
      ELSE
         w_fecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      END IF;

      w_fecval := TO_NUMBER(TO_CHAR(pfecval, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO w_sesion
        FROM DUAL;

      IF w_sesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      w_nriesgo := NVL(pnriesgo, 1);
      /*
      { Insertamos los parametros genericos para el calculo de un seguro.}
      */
      w_error := pac_sin_formula.f_graba_param(w_sesion, 'ORIGEN', 2);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'SESION', w_sesion);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'FECEFE', w_fecefe);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'FNOTIFI', w_fnotifi);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'FSINIES', w_fsinies);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'SSEGURO', psseguro);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'NSINIES', w_nsinies);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'SPRODUC', psproduc);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'CACTIVI', pcactivi);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'CGARANT', pcgarant);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'CCAUSIN', pccausin);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'CMOTSIN', pcmotsin);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'NRIESGO', w_nriesgo);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'FVALORA', w_fecval);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(w_sesion, 'NTRAMIT', 0);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      /*
      {Calculamos las formulas de la valoracion}
      */
      FOR reg IN cur_campo LOOP
         BEGIN
            SELECT formula
              INTO w_formula
              FROM sgt_formulas
             WHERE clave = reg.cclave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- {Cargo parametros predefinidos}
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         -- RSC 07/07/2008 Se rechaza el Patch SNVA_249 (Tarea 5507).
         -- Se incluye modificación propuesta.
         FOR term IN cur_termino(reg.cclave) LOOP
            BEGIN
               IF (term.parametro <> 'IVALSIN'
                   AND term.parametro <> 'ICAPRIS') THEN
                  -- {Se esta calculando en este momento}
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO w_xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PAC_SIN_FORMULA';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO w_xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, w_xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', w_retorno);

                  IF INSTR(w_xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', w_fecefe);
                  END IF;

                  IF INSTR(w_xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', w_nsinies);
                  END IF;

                  IF INSTR(w_xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', w_fsinies);
                  END IF;

                  IF INSTR(w_xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', w_fnotifi);
                  END IF;

                  IF INSTR(w_xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(w_xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(w_xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                  END IF;

                  IF INSTR(w_xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                  END IF;

                  IF INSTR(w_xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', w_nriesgo);
                  END IF;

                  IF INSTR(w_xs, ':NTRAMIT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', 0);
                  END IF;

                  --JRH NDURPER Necesita NMOVIMI
                  DECLARE
                     nmovimi        NUMBER;
                  BEGIN
                     SELECT MAX(m.nmovimi)
                       INTO nmovimi
                       FROM movseguro m
                      WHERE m.sseguro = psseguro
                        AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(w_fsinies), 'yyyymmdd');

                     IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                        END IF;
                  END;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', w_retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF w_retorno IS NULL THEN
                        RETURN 103135;
                     ELSE
                        w_error := pac_sin_formula.f_graba_param(w_sesion, term.parametro,
                                                                 w_retorno);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin',
                                    NULL, 'Error al evaluar la formula', SQLERRM);
                        p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin',
                                    NULL, 'formula', w_xs);

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;

                        w_error := pac_sin_formula.f_graba_param(w_sesion, term.parametro, 0);

                        IF w_error <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  w_xs := NULL;
            END;
         END LOOP;

         --w_error := PAC_CALCULO_FORMULAS.calcula_terminos (w_sesion, reg.clave, 'PK_CALC_SINI', 0);
         pac_sin_formula.p_carga_preguntas(psseguro, pfsinies, pcgarant, w_sesion);

         IF picapital IS NOT NULL THEN
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IVALSIN', picapital);
            w_ivalsin := picapital;

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            w_error := pac_sin_formula.f_graba_param(w_sesion, 'ICAPRIS', picapital);
            w_icapris := picapital;

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            --w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', 0);
            --w_ipenali := 0;

            --IF w_error <> 0 THEN
            --RETURN 109843;

            --END IF;

            -- BUG 12986- 02/2010 - JRH  - 0012986: CEM - CRS - Ajustes productos CRS
            IF reg.ccampo = 'IPENALI' THEN
               -- Volvemos a evaluar la penalización ya que hemos modificado el ICAPRIS
               w_val := pk_formulas.eval(w_formula, w_sesion);
               w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', w_val);
               w_ipenali := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSE
               w_val := pk_formulas.eval(w_formula, w_sesion);
            END IF;
         -- Fi BUG 12986- 02/2010 - JRH
         ELSE
            -- Fin Bug 11993
            w_val := pk_formulas.eval(w_formula, w_sesion);
         -- Bug 11993 - 16/11/2009 - RSC - CRE - Ajustes PPJ Dinámico/Pla Estudiant
         END IF;

         -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
         IF reg.ccampo = 'IPENALI' THEN
            IF pimppenali IS NOT NULL THEN
               w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', pimppenali);
               w_val := pimppenali;
               w_ipenali := pimppenali;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;

         -- Fin Bug 13296

         -- w_val := pk_formulas.eval(w_formula, w_sesion);
         IF (w_val IS NULL
             OR w_val < 0) THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin', 1, reg.ccampo,
                        w_formula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'ICAPRIS' THEN
               w_error := pac_sin_formula.f_graba_param(w_sesion, 'ICAPRIS', w_val);
               w_icapris := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IVALSIN' THEN
               w_error := pac_sin_formula.f_graba_param(w_sesion, 'IVALSIN', w_val);
               w_ivalsin := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            ELSIF reg.ccampo = 'IPENALI' THEN
               w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', w_val);
               w_ipenali := w_val;

               IF w_error <> 0 THEN
                  RETURN 109843;
               END IF;
            END IF;
         END IF;
      END LOOP;

      /*
       {si el tipo de destinatario no esta informado miramos que tipo de dest. tiene el pago}
      */
      IF pctipdes IS NULL THEN
         BEGIN
            SELECT DISTINCT sfcm.ctipdes
                       INTO w_ctipdes
                       FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm,
                            sin_causa_motivo scm
                      WHERE sfcm.scaumot = sgcm.scaumot
                        AND scm.scaumot = sfcm.scaumot
                        AND scm.ccausin = pccausin
                        AND scm.cmotsin = pcmotsin
                        AND sgcm.sproduc = psproduc
                        AND sgcm.cactivi = pcactivi
                        AND sgcm.cgarant = pcgarant
                        AND sgcm.ctramit = 0
                        AND sfcm.ctipdes <> 0;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               RETURN 152494;
         END;
      ELSE
         w_ctipdes := pctipdes;
      END IF;

      IF NVL(f_parproductos_v(vsproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1
         AND pccausin IN(3, 4, 5) THEN   --JRH Sólo hay un pago
         xcuantos := 1;

         DECLARE   --JRH El parámetro IPRIMAS lo necesitamos informado
            primasaportadas NUMBER;
         BEGIN
            SELECT SUM(iprima)
              INTO primasaportadas
              FROM primas_aportadas
             WHERE sseguro = psseguro
               AND fvalmov <= pfsinies;

            primasaportadas := NVL(primasaportadas, 0);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPRIMAS', primasaportadas);
         END;
      ELSE
         -- CPM 20/12/05: Grabem el capital introduit per pantalla (rescat parcial)
         -- RSC 27/03/2008: Si se informa el importe del rescate parcial se da valor a las variables ICAPRIS, IVALSIN y IPENALI
         xcuantos := pac_sin_rescates.f_vivo_o_muerto(psseguro, 1, pfsinies);

         DECLARE   --JRH El parámetro IPRIMAS lo necesitamos informado
            xfmuerte       DATE;
            primasaportadas NUMBER;
         BEGIN
            SELECT MAX(ffecmue)
              INTO xfmuerte
              FROM asegurados
             WHERE sseguro = psseguro
               AND ffecmue IS NOT NULL;

            SELECT NVL(SUM(CASE
                              WHEN fvalmov > NVL(xfmuerte, fvalmov) THEN iprima
                              ELSE ROUND(iprima
                                         / pac_sin_rescates.f_vivo_o_muerto(psseguro, 1,
                                                                            fvalmov),
                                         5)
                           END),
                       0)
              INTO primasaportadas
              FROM primas_aportadas
             WHERE sseguro = psseguro
               AND fvalmov <= pfsinies;

            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPRIMAS', primasaportadas);
         END;
      END IF;

      FOR aseg IN cur_aseg LOOP
         /*
          {calculamos el pago }
         */
         FOR reg IN cur_pago(w_ctipdes) LOOP
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'SPERDES', aseg.sperson);

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            -- Bug 31294 - 04/07/2014 - JTT: Añadimos el parametro :CTIPDES
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'CTIPDES', w_ctipdes);

            IF w_error <> 0 THEN
               RETURN 109843;
            END IF;

            BEGIN
               SELECT formula, codigo
                 INTO w_formula, w_codigo
                 FROM sgt_formulas
                WHERE clave = reg.cclave;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 108423;
               WHEN OTHERS THEN
                  RETURN 108423;
            END;

            -- Cargo parametros predefinidos
            FOR term IN cur_termino(reg.cclave) LOOP
               IF term.parametro <> 'FVALORA'
                  AND term.parametro <> 'IVALSIN'
                  AND   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                     term.parametro <> 'PASIGNA'
                  AND   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                     term.parametro <> 'ICAPRIS'
                  AND   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                     term.parametro <> 'IPENALI' THEN   -- Bug 13296 - RSC - 24/02/2010 - CEM - Revisión módulo de rescates
                  BEGIN
                     BEGIN
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO w_xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'PAC_SIN_FORMULA';
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN   --JRH Ponemos el NDF como en la simulación
                           SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM '
                                  || ttable || ' WHERE ' || twhere || ' ; END;'
                             INTO w_xs
                             FROM sgt_carga_arg_prede
                            WHERE termino = term.parametro
                              AND ttable IS NOT NULL
                              AND cllamada = 'GENERICO';
                     END;

                     -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     v_cursor := DBMS_SQL.open_cursor;
                     DBMS_SQL.parse(v_cursor, w_xs, DBMS_SQL.native);
                     DBMS_SQL.bind_variable(v_cursor, ':RETORNO', w_retorno);

                     IF INSTR(w_xs, ':NSINIES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NSINIES', w_nsinies);
                     END IF;

                     IF INSTR(w_xs, ':FECEFE') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECEFE', w_fecefe);
                     END IF;

                     IF INSTR(w_xs, ':FNOTIFI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', w_fnotifi);
                     END IF;

                     IF INSTR(w_xs, ':FSINIES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FSINIES', w_fsinies);
                     END IF;

                     IF INSTR(w_xs, ':SSEGURO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                     END IF;

                     IF INSTR(w_xs, ':SPRODUC') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                     END IF;

                     IF INSTR(w_xs, ':CACTIVI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                     END IF;

                     IF INSTR(w_xs, ':CGARANT') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                     END IF;

                     IF INSTR(w_xs, ':NRIESGO') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', aseg.norden);
                     END IF;

                     IF INSTR(w_xs, ':SPERDES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':SPERDES', aseg.sperson);
                     END IF;

                     IF INSTR(w_xs, ':CTIPDES') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':CTIPDES', w_ctipdes);
                     END IF;

                     IF INSTR(w_xs, ':FECHA') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':FECHA', w_fsinies);
                     END IF;

                     IF INSTR(w_xs, ':NTRAMIT') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', 0);
                     END IF;

                     --JRH NDURPER Necesita NMOVIMI
                     DECLARE
                        nmovimi        NUMBER;
                     BEGIN
                        SELECT MAX(m.nmovimi)
                          INTO nmovimi
                          FROM movseguro m
                         WHERE m.sseguro = psseguro
                           AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(w_fsinies), 'yyyymmdd');

                        IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           IF INSTR(w_xs, ':NMOVIMI') > 0 THEN
                              DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                           END IF;
                     END;

                     BEGIN
                        v_filas := DBMS_SQL.EXECUTE(v_cursor);
                        DBMS_SQL.variable_value(v_cursor, 'RETORNO', w_retorno);

                        IF DBMS_SQL.is_open(v_cursor) THEN
                           DBMS_SQL.close_cursor(v_cursor);
                        END IF;

                        IF w_retorno IS NULL THEN
                           RETURN 103135;
                        ELSE
                           w_error := pac_sin_formula.f_graba_param(w_sesion, term.parametro,
                                                                    w_retorno);

                           IF w_error <> 0 THEN
                              RETURN 109843;
                           END IF;
                        END IF;
                     EXCEPTION
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin',
                                       NULL, 'Error al evaluar la formula', SQLERRM);
                           p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin',
                                       NULL, 'formula', w_xs);
                           w_error := pac_sin_formula.f_graba_param(w_sesion, term.parametro,
                                                                    0);

                           IF w_error <> 0 THEN
                              RETURN 109843;
                           END IF;
                     END;
                  EXCEPTION
                     WHEN OTHERS THEN
                        w_xs := NULL;
                  END;
               END IF;
            END LOOP;

            --ADOS
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IVALSIN',
                                                     w_icapris - w_ipenali);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'ICAPRIS', w_icapris);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', w_ipenali);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'NDESTI', xcuantos);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'FVALORA', w_fsinies);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'PASIGNA', 100 / xcuantos);
            w_error := pac_sin_formula.f_graba_param(w_sesion, 'NRIESGO', aseg.norden);
            pac_sin_formula.p_carga_preguntas(psseguro, pfsinies, pcgarant, w_sesion);
            --
            w_val := pk_formulas.eval(w_formula, w_sesion);

            --
            IF w_val IS NULL THEN
               --commit;
               p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_simu_calc_sin', 1, w_sesion,
                           w_formula);
               RETURN 103135;
            ELSE
               IF reg.ccampo = 'IVALSIN' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IVALSIN', w_val);
                  w_ivalsin := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'ICAPRIS' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'ICAPRIS', w_val);
                  w_icapris := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IPENALI' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPENALI', w_val);
                  w_ipenali := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;

                  IF w_ipenali > 0 THEN
                     w_ivalsin := w_ivalsin - w_ipenali;
                     w_error := pac_sin_formula.f_graba_param(w_sesion, 'IVALSIN', w_ivalsin);

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               END IF;

               IF reg.ccampo = 'ISINRET' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'ISINRET', w_val);
                  w_isinret := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;

                  w_sinacum := w_sinacum + w_val;
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'ISINACU', w_sinacum);

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRESRCM' THEN
                  -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
                  IF pimprcm IS NOT NULL THEN
                     w_error := pac_sin_formula.f_graba_param(w_sesion, 'IRESRCM', pimprcm);
                     w_iresrcm := pimprcm;

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  ELSE
                     -- Fin bug 13829
                     w_error := pac_sin_formula.f_graba_param(w_sesion, 'IRESRCM', w_val);
                     w_iresrcm := w_val;

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRESRED' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IRESRED', w_val);
                  w_iresred := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'ICONRET' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'ICONRET', w_val);
                  w_iconret := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'PRETENC' THEN
                  -- Bug 13829 - RSC - 20/05/2010 - APRB78 - Parametrizacion y adapatacion de rescastes
                  IF ppctreten IS NOT NULL THEN
                     w_error := pac_sin_formula.f_graba_param(w_sesion, 'PRETENC', ppctreten);
                     w_pretenc := ppctreten;

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  ELSE
                     -- Fin Bug 13829
                     w_error := pac_sin_formula.f_graba_param(w_sesion, 'PRETENC', w_val);
                     w_pretenc := w_val;

                     IF w_error <> 0 THEN
                        RETURN 109843;
                     END IF;
                  END IF;
               END IF;

               IF reg.ccampo = 'IRETENC' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IRETENC', w_val);
                  w_iretenc := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IIMPSIN' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IIMPSIN', w_val);
                  w_iimpsin := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;

               IF reg.ccampo = 'IPRIMAS' THEN
                  w_error := pac_sin_formula.f_graba_param(w_sesion, 'IPRIMAS', w_val);
                  w_iprimas := w_val;

                  IF w_error <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            END IF;
         END LOOP;

         w_isinret_total := w_isinret_total + w_isinret;
         w_iresrcm_total := w_iresrcm_total + w_iresrcm;
         w_iresred_total := w_iresred_total + w_iresred;
         w_iconret_total := w_iconret_total + w_iconret;
         w_iretenc_total := w_iretenc_total + w_iretenc;
         w_iimpsin_total := w_iimpsin_total + w_iimpsin;
         w_iprimas_total := w_iprimas_total + w_iprimas;
      -- SINGARANFORMULA
      END LOOP;

      --
      w_error := pac_sin_formula.f_insertar_mensajes(2, psseguro, NULL, pctipdes,
                                                     TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')),
                                                     pcactivi, NULL, 1, pcgarant, w_ivalsin,
                                                     w_isinret_total, w_iresrcm_total,
                                                     w_iresred_total, w_iconret_total,
                                                     w_pretenc, w_iretenc_total,
                                                     w_iimpsin_total, w_icapris, w_ipenali,
                                                     w_iprimas_total, NULL, NULL);
-- I - JLB -- OPTIMI
--      DELETE      sgt_parms_transitorios
--            WHERE sesion = w_sesion
--              AND parametro IN('ISINRET', 'IRESRCM', 'IRESRED', 'ICONRET', 'PRETENC',
--                               'PRETENC', 'IRETENC', 'IIMPSIN');
-- F - JLB -- OPTIMI
      -- Borro sgt_parms_transitorios
      w_error := pac_sin_formula.f_borra_param(w_sesion);

      --
      IF w_error <> 0 THEN
         RETURN w_error;
      END IF;

      RETURN 0;
   END f_simu_calc_sin;

   /*************************************************************************
      FUNCTION f_retorna_valores
         Funció que retorna valors.

         return             : valores
   *************************************************************************/
   FUNCTION f_retorna_valores
      RETURN t_val IS
   BEGIN
      RETURN valores;
   END f_retorna_valores;

   /*************************************************************************
      FUNCTION f_imaximo_rescatep
         Funció que simula un rescat
         param in psseguro  : Seqüència assegurança
         param in pfsinies  : Data sinistre
         param in pccausin  : Causa sinistre
         param out pimporte : Capital

         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error
   *************************************************************************/
   FUNCTION f_imaximo_rescatep(
      psseguro IN seguros.sseguro%TYPE,
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pimporte OUT NUMBER)
      RETURN NUMBER IS
      xxformula      VARCHAR2(2000);
      xxsesion       NUMBER;
      w_error        NUMBER;
      val            NUMBER;
      v_sproduc      NUMBER;
      nanyos         NUMBER;
      v_fefecto      DATE;
      v_frevant      DATE;
      v_fecha        DATE;
      vclave         NUMBER;
      v_ctipmov      NUMBER;
   BEGIN
      IF pccausin = 4 THEN   -- rescate total
         v_ctipmov := 3;
      ELSIF pccausin = 5 THEN   -- rescate parcial
         v_ctipmov := 2;
      END IF;

      -- Bug 13296 - RSC - 22/02/2010 - CEM - Revisión módulo de rescates

      -- RSC 12/12/2007 (añado la left join con seguros_aho)
      --SELECT s.sproduc, s.fefecto, NVL(sa.frevant, s.fefecto)
      --INTO v_sproduc, v_fefecto, v_frevant
      --FROM seguros s LEFT JOIN seguros_aho sa ON(s.sseguro = sa.sseguro)
      --WHERE s.sseguro = psseguro;

      --IF NVL(f_parproductos_v(v_sproduc, 'EVOLUPROVMATSEG'), 0) = 1 THEN
      --   v_fecha := v_frevant;
      --ELSE
      --   v_fecha := v_fefecto;
      --END IF;

      --nanyos := TRUNC(MONTHS_BETWEEN(pfsinies, v_fecha) / 12);
      nanyos := calc_rescates.f_get_anyos_porcenpenali(psseguro,
                                                       TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')),
                                                       v_ctipmov);

      -- Fin Bug 13296
      BEGIN
         SELECT d.claveimaximo
           INTO vclave
           FROM prodtraresc p, seguros s, detprodtraresc d
          WHERE s.sseguro = psseguro
            AND s.sproduc = p.sproduc
            AND p.sidresc = d.sidresc
            AND p.ctipmov = v_ctipmov
            AND p.finicio <= pfsinies
            AND(p.ffin > pfsinies
                OR p.ffin IS NULL)
            AND d.niniran = (SELECT MIN(dp.niniran)
                               FROM detprodtraresc dp
                              WHERE dp.sidresc = d.sidresc
                                AND nanyos BETWEEN dp.niniran AND dp.nfinran);
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 180809;
      END;

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      w_error := pac_sin_formula.f_graba_param(xxsesion, 'SESION', xxsesion);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(xxsesion, 'FSINIES',
                                               TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd')));

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      w_error := pac_sin_formula.f_graba_param(xxsesion, 'SSEGURO', psseguro);

      IF w_error <> 0 THEN
         RETURN 109843;
      END IF;

      IF vclave IS NOT NULL THEN
         BEGIN
            SELECT formula
              INTO xxformula
              FROM sgt_formulas
             WHERE clave = vclave;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- Evaluamos la fórmula
         pimporte := pk_formulas.eval(xxformula, xxsesion);

         IF (pimporte IS NULL
             OR pimporte < 0) THEN
            RETURN 180809;
         END IF;
      END IF;

      -- Borro sgt_parms_transitorios
      w_error := pac_sin_formula.f_borra_param(xxsesion);

      IF w_error <> 0 THEN
         RETURN w_error;
      END IF;

      RETURN 0;
   END f_imaximo_rescatep;

   FUNCTION f_tramo(pnsesion IN NUMBER, pfecha IN NUMBER, pntramo IN NUMBER, pbuscar IN NUMBER)
      RETURN NUMBER IS
      /*************************************************************************
         FUNCTION f_tramo
            Funció que retorna valor tram
            param in pnsesion  : Sesio
            param in pfecha  : Data
            param in pntramo  : Tram
            param in pbuscar : Valor a trobar

            return             : 0 -> Tot correcte
      *************************************************************************/
      valor          NUMBER;
      ftope          DATE;
   BEGIN
      IF pfecha IS NULL THEN
         ftope := f_sysdate;
      ELSE
         ftope := TO_DATE(pfecha, 'yyyymmdd');
      END IF;

      valor := NULL;

      FOR r IN (SELECT   orden, desde, NVL(hasta, desde) hasta, valor
                    FROM sgt_det_tramos
                   WHERE tramo = (SELECT detalle_tramo
                                    FROM sgt_vigencias_tramos
                                   WHERE tramo = pntramo
                                     AND fecha_efecto =
                                              (SELECT MAX(fecha_efecto)
                                                 FROM sgt_vigencias_tramos
                                                WHERE tramo = pntramo
                                                  AND fecha_efecto <= ftope))
                ORDER BY orden) LOOP
         IF pbuscar BETWEEN r.desde AND r.hasta THEN
            RETURN r.valor;
         END IF;
      END LOOP;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END f_tramo;

   /*************************************************************************
      FUNCTION f_cal_fechas_sini
         Funció que carrega les dates de inici i fi del sinistre
         param in pfsinies  : Data del sinistre
         param in psseguro  : Codi seguro
         param in pnsinies  : Número de sinistre
         param in psproduc  : Codi Producte
         param in pcactivi  : Codi Activitat
         param in pcgarant  : Codi Garantía
         param in pccausin  : Codi Causa sinistre
         param in pcmotsin  : Codi Subcausa
         param in pfnotifi  : Data notificació
         param in pctramit  : Codi tramitació
         param in pntramit  : Número tramitació
         param in pnriesgo  : Número risc
         param in pfecval   :
         param out pfperini  : Data inici pagament
         param out pfperfin  : Data fi pagament
         return             : 0 -> Tot correcte
                              1 -> S'ha produit un error

         Bug 14752 - 28/05/2010 - AMC
   *************************************************************************/
   FUNCTION f_cal_fechas_sini(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN sin_siniestro.nriesgo%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pntramit IN sin_tramitacion.ntramit%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pcactivi IN activisegu.cactivi%TYPE DEFAULT 0,
      pcgarant IN codigaran.cgarant%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      pfnotifi IN sin_siniestro.fnotifi%TYPE,
      pfecval IN sin_tramita_reserva.fmovres%TYPE DEFAULT f_sysdate,
      pfperini OUT sin_tramita_reserva.fresini%TYPE,
      pfperfin OUT sin_tramita_reserva.fresfin%TYPE)
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha valor del siniestro
      xfecefe        NUMBER;   -- Fecha Alta
      xfecval        NUMBER;   --Fecha de efecto de valoracion
      xfnotifi       NUMBER;   -- Fecha Notificacion
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       NUMBER;
      xipenali       NUMBER;
      xicapris       NUMBER;
      xnriesgo       NUMBER;
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xxfperini      NUMBER(8);
      xxfperfin      NUMBER(8);
      vparam         VARCHAR2(2000);
      vicapital      garanseg.icapital%TYPE;
      vctramit       sin_tramitacion.ctramit%TYPE;

      CURSOR cur_campo(
         ppccausin NUMBER,
         ppcmotsin NUMBER,
         ppsproduc NUMBER,
         ppcactivi NUMBER,
         ppcgarant NUMBER,
         ppctramit NUMBER) IS
         SELECT   DECODE(sfcm.ccampo, 'FPERINI', 1, 'FPERFIN', 2) orden, sfcm.ccampo,
                  sfcm.cclave, sfcm.ctipdes
             FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, sin_causa_motivo scm
            WHERE sfcm.scaumot = sgcm.scaumot
              AND scm.scaumot = sfcm.scaumot
              AND scm.ccausin = ppccausin
              AND scm.cmotsin = ppcmotsin
              AND sgcm.sproduc = ppsproduc
              AND sgcm.cactivi = ppcactivi
              AND(sgcm.cgarant = ppcgarant
                  OR ppcgarant IS NULL)
              AND sgcm.ctramit = ppctramit
              AND sfcm.ccampo IN('FPERINI', 'FPERFIN')
              AND sfcm.ctipdes = 0
         ORDER BY 1;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
         ORDER BY 1;

      vsproduc       NUMBER;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      IF pctramit IS NULL THEN
         BEGIN
            SELECT ctramit
              INTO vctramit
              FROM sin_tramitacion
             WHERE nsinies = pnsinies
               AND ntramit = pntramit;
         EXCEPTION
            WHEN OTHERS THEN
               vctramit := NULL;
         END;
      ELSE
         vctramit := pctramit;
      END IF;

      xfsinies := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));
      xfnotifi := TO_NUMBER(TO_CHAR(pfnotifi, 'yyyymmdd'));
      vparam := 'parámetros - pfsinies: ' || pfsinies || 'psseguro: ' || psseguro
                || ' pnriesgo: ' || pnriesgo || ' pnsinies: ' || pnsinies || ' pntramit: '
                || pntramit || ' pctramit: ' || vctramit || ' psproduc: ' || psproduc
                || ' pcactivi: ' || pcactivi || ' pcgarant: ' || pcgarant || ' pccausin: '
                || pccausin || ' pcmotsin: ' || pcmotsin || ' pfnotifi: ' || pfnotifi
                || ' pfecval: ' || pfecval;
      xfecval := TO_NUMBER(TO_CHAR(pfecval, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      IF pnriesgo IS NULL THEN
         BEGIN
            SELECT nriesgo
              INTO xnriesgo
              FROM sin_siniestro
             WHERE nsinies = pnsinies;
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 104755;   -- calve no esncontrada en siniestros
         END;
      ELSE
         xnriesgo := pnriesgo;
      END IF;

      e := f_graba_param(xxsesion, 'ORIGEN', 2);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

-- Insertamos los parametros genericos para el calculo de un seguro.
      e := f_graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SSEGURO', psseguro);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CACTIVI', pcactivi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FVALORA', xfecval);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NTRAMIT', pntramit);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      IF pcgarant IS NOT NULL THEN
         BEGIN
            -- Bug 24708 - 25/06/2014  - JTT: Obtenim el MAX(nmovimi) a fsinies
            SELECT NVL(icapital, 0)
              INTO vicapital
              FROM garanseg
             WHERE sseguro = psseguro
               AND nriesgo = xnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = psseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = pcgarant
                                 AND TRUNC(finiefe) <= TRUNC(pfsinies)
                                 AND(ffinefe IS NULL
                                     OR TRUNC(pfsinies) <= TRUNC(ffinefe)));
         EXCEPTION
            WHEN OTHERS THEN
               vicapital := 0;
         END;

         e := f_graba_param(xxsesion, 'CAPITAL', vicapital);

         IF e <> 0 THEN
            RETURN 109843;
         END IF;
      END IF;

--
      FOR reg IN cur_campo(pccausin, pcmotsin, psproduc, pcactivi, pcgarant, vctramit) LOOP
         BEGIN
            SELECT formula
              INTO xxformula
              FROM sgt_formulas
             WHERE clave = reg.cclave;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 108423;
            WHEN OTHERS THEN
               RETURN 108423;
         END;

         -- Cargo parametros predefinidos
         -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
         FOR term IN cur_termino(reg.cclave) LOOP
            BEGIN
               IF (term.parametro <> 'FPERINI'
                   AND term.parametro <> 'FPERFIN') THEN   --Se esta calculando en este momento
                  BEGIN
                     SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                            || ' WHERE ' || twhere || ' ; END;'
                       INTO xs
                       FROM sgt_carga_arg_prede
                      WHERE termino = term.parametro
                        AND ttable IS NOT NULL
                        AND cllamada = 'PAC_SIN_FORMULA';
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                        SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                               || ' WHERE ' || twhere || ' ; END;'
                          INTO xs
                          FROM sgt_carga_arg_prede
                         WHERE termino = term.parametro
                           AND ttable IS NOT NULL
                           AND cllamada = 'GENERICO';
                  END;

                  -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
                  IF DBMS_SQL.is_open(v_cursor) THEN
                     DBMS_SQL.close_cursor(v_cursor);
                  END IF;

                  v_cursor := DBMS_SQL.open_cursor;
                  DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
                  DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

                  IF INSTR(xs, ':FECEFE') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
                  END IF;

                  IF INSTR(xs, ':NSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
                  END IF;

                  IF INSTR(xs, ':FSINIES') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
                  END IF;

                  IF INSTR(xs, ':FNOTIFI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
                  END IF;

                  IF INSTR(xs, ':SSEGURO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', psseguro);
                  END IF;

                  IF INSTR(xs, ':SPRODUC') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', psproduc);
                  END IF;

                  IF INSTR(xs, ':CACTIVI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', pcactivi);
                  END IF;

                  IF INSTR(xs, ':CGARANT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
                  END IF;

                  IF INSTR(xs, ':NRIESGO') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
                  END IF;

                  IF INSTR(xs, ':FVALORA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FVALORA', xfecval);
                  END IF;

                  IF INSTR(xs, ':FECHA') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
                  END IF;

                  IF INSTR(xs, ':NTRAMIT') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', pntramit);
                  END IF;

                  --JRH NDURPER Necesita NMOVIMI
                  DECLARE
                     nmovimi        NUMBER;
                  BEGIN
                     SELECT MAX(m.nmovimi)
                       INTO nmovimi
                       FROM movseguro m
                      WHERE m.sseguro = psseguro
                        AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

                     IF INSTR(xs, ':NMOVIMI') > 0 THEN
                        DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        IF INSTR(xs, ':NMOVIMI') > 0 THEN
                           DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                        END IF;
                  END;

                  BEGIN
                     v_filas := DBMS_SQL.EXECUTE(v_cursor);
                     DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

                     IF DBMS_SQL.is_open(v_cursor) THEN
                        DBMS_SQL.close_cursor(v_cursor);
                     END IF;

                     IF retorno IS NULL THEN
                        p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_cal_fechas_sini', 1,
                                    xxsesion, 'Formula:' || xs);
                        RETURN 103135;
                     ELSE
                        e := f_graba_param(xxsesion, term.parametro, retorno);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                     END IF;
                  EXCEPTION
                     WHEN OTHERS THEN
                        e := f_graba_param(xxsesion, term.parametro, 0);

                        IF e <> 0 THEN
                           RETURN 109843;
                        END IF;
                  END;
               END IF;
            --
            EXCEPTION
               WHEN OTHERS THEN
                  xs := NULL;
            END;
         END LOOP;

         --e := PAC_CALCULO_FORMULAS.calcula_terminos (xxsesion, reg.clave, 'PK_CALC_SINI', 0);
         p_carga_preguntas(psseguro, pfsinies, pcgarant, xxsesion);
         --
         val := pk_formulas.eval(xxformula, xxsesion);

         IF (val IS NULL
             OR val < 0) THEN
            p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_cal_fechas_sini', 2, xxsesion,
                        'Formula:' || xxformula);
            RETURN 103135;
         ELSE
            IF reg.ccampo = 'FPERINI' THEN
               xxfperini := val;
            ELSIF reg.ccampo = 'FPERFIN' THEN
               xxfperfin := val;
            END IF;
         END IF;
      END LOOP;

--

      -- Borro sgt_parms_transitorios
      e := f_borra_param(xxsesion);

      IF xxfperini IS NULL THEN
         pfperini := NULL;
      ELSE
         pfperini := TO_DATE(xxfperini, 'yyyymmdd');
      END IF;

      IF xxfperfin IS NULL THEN
         pfperfin := NULL;
      ELSE
         pfperfin := TO_DATE(xxfperfin, 'yyyymmdd');
      END IF;

      RETURN 0;
   END f_cal_fechas_sini;

   /*************************************************************************
      FUNCTION f_cal_penali
        Funció que devuelve el importe de penalización
        param in pcgarant
        param in pctramit
        param in pnsinies
        param in pireserva
        param in pfini
        param in pffin
        param out pivalora : Valorització
        param out pipenali : Penalització
        param out picapris : Capital de risc
        return             : 0 -> Tot correcte
                             1 -> S'ha produit un error

        Bug 20655/101537 - 22/12/2011 - AMC
   *************************************************************************/
   FUNCTION f_cal_penali(
      pcgarant IN codigaran.cgarant%TYPE,
      pctramit IN sin_tramitacion.ctramit%TYPE,
      pnsinies IN sin_siniestro.nsinies%TYPE,
      pireserva IN sin_tramita_reserva.ireserva%TYPE,
      pfini IN sin_tramita_reserva.fresini%TYPE,
      pffin IN sin_tramita_reserva.fresfin%TYPE,
      pipenali OUT sin_tramita_reserva.ipenali%TYPE)
      RETURN NUMBER IS
      val            NUMBER;   -- Valor que retorna la formula
      xxformula      VARCHAR2(2000);   -- contiene la Formula a calcular
      xxsesion       NUMBER;   -- Nro de sesion que ejecuta la formula
      xfsinies       NUMBER;   -- Fecha valor del siniestro
      xfecefe        NUMBER;   -- Fecha Alta
      xfecval        NUMBER;   --Fecha de efecto de valoracion
      xfnotifi       NUMBER;   -- Fecha Notificacion
      e              NUMBER;   -- Error Retorno funciones
      xivalsin       NUMBER;
      xipenali       NUMBER;
      xicapris       NUMBER;
      xnriesgo       NUMBER;
      xs             VARCHAR2(2000);
      retorno        NUMBER;
      v_cursor       INTEGER;
      v_filas        NUMBER;
      xxfperini      NUMBER(8);
      xxfperfin      NUMBER(8);
      vparam         VARCHAR2(2000);
      vicapital      garanseg.icapital%TYPE;
      vctramit       sin_tramitacion.ctramit%TYPE;

      CURSOR cur_termino(wclave NUMBER) IS
         SELECT   parametro
             FROM sgt_trans_formula
            WHERE clave = wclave
              AND UPPER(parametro) <> 'ICAPRIS'
         ORDER BY 1;

      vsproduc       NUMBER;
      vccampo        VARCHAR2(8);
      vcclave        NUMBER;
      vctipdes       NUMBER;
      vfsinies       DATE;
      vfnotifi       DATE;
      vnriesgo       NUMBER;
      vcactivi       NUMBER;
      vccausin       NUMBER;
      vcmotsin       NUMBER;
      vsseguro       NUMBER;
   BEGIN
      BEGIN
         SELECT sfcm.ccampo, sfcm.cclave, sfcm.ctipdes, ss.fsinies, ss.fnotifi, s.sproduc,
                ss.nriesgo, s.sseguro, s.cactivi, ss.ccausin, ss.cmotsin
           INTO vccampo, vcclave, vctipdes, vfsinies, vfnotifi, vsproduc,
                vnriesgo, vsseguro, vcactivi, vccausin, vcmotsin
           FROM sin_for_causa_motivo sfcm, sin_gar_causa_motivo sgcm, sin_causa_motivo scm,
                sin_siniestro ss, seguros s
          WHERE sfcm.scaumot = sgcm.scaumot
            AND scm.scaumot = sfcm.scaumot
            AND scm.ccausin = ss.ccausin
            AND scm.cmotsin = ss.cmotsin
            AND ss.sseguro = s.sseguro
            AND sgcm.sproduc = s.sproduc
            AND sgcm.cactivi = s.cactivi
            AND sfcm.ccampo = 'IPENALI'
            AND sfcm.ctipdes = 0
            AND sgcm.cgarant = pcgarant
            AND sgcm.ctramit = pctramit
            AND ss.nsinies = pnsinies;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pipenali := 0;
            RETURN 0;
      END;

      vctramit := pctramit;
      xfsinies := TO_NUMBER(TO_CHAR(vfsinies, 'yyyymmdd'));   -- sin siniestro
      xfnotifi := TO_NUMBER(TO_CHAR(vfnotifi, 'yyyymmdd'));
      xxfperini := TO_NUMBER(TO_CHAR(pfini, 'yyyymmdd'));
      xxfperfin := TO_NUMBER(TO_CHAR(pffin, 'yyyymmdd'));
      vparam := 'parámetros - pcgarant: ' || pcgarant || 'pctramit: ' || pctramit
                || ' pnsinies: ' || pnsinies || ' pireserva: ' || pireserva || ' pfini: '
                || pfini || ' pffin: ' || pffin;

      IF NVL(f_parproductos_v(vsproduc, 'ES_PRODUCTO_RENTAS'), 0) = 1 THEN   -- de la select
         /*
             -- RSC 21/10/2008 Lo hacemos asi para minimizar impacto
                 (en Ahorro esto funciona por tanto este cambio solo lo quiero para
                  rentas).

               Para RVI y RO FFECEFE debe ser la fecha de revisión anterior y si
               no ha renovado pues la de efecto de la póliza. Para el resto no
               afecta.
         */
         SELECT TO_NUMBER(TO_CHAR(NVL(sa.frevant, s.fefecto), 'YYYYMMDD'))
           INTO xfecefe
           FROM seguros_aho sa, seguros s
          WHERE sa.sseguro = s.sseguro
            AND s.sseguro = vsseguro;
      ELSE
         xfecefe := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));
      END IF;

      xfecval := TO_NUMBER(TO_CHAR(f_sysdate, 'YYYYMMDD'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      xnriesgo := vnriesgo;   -- de la select
      e := f_graba_param(xxsesion, 'ORIGEN', 2);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

-- Insertamos los parametros genericos para el calculo de un seguro.
      e := f_graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FNOTIFI', xfnotifi);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FSINIES', xfsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SSEGURO', vsseguro);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NSINIES', pnsinies);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SPRODUC', vsproduc);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CACTIVI', vcactivi);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CGARANT', pcgarant);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CCAUSIN', vccausin);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CMOTSIN', vcmotsin);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NRIESGO', xnriesgo);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FVALORA', xfecval);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FPERINI', xxfperini);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'ICAPRIS', pireserva);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FPERFIN', xxfperfin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'NTRAMIT', pctramit);   -- de la select

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      IF pcgarant IS NOT NULL THEN
         BEGIN
            -- Bug 24708 - 25/06/2014  - JTT: Obtenim el MAX(nmovimi) a fsinies
            SELECT NVL(icapital, 0)
              INTO vicapital
              FROM garanseg
             WHERE sseguro = vsseguro
               AND nriesgo = xnriesgo
               AND cgarant = pcgarant
               AND nmovimi = (SELECT MAX(nmovimi)
                                FROM garanseg
                               WHERE sseguro = vsseguro
                                 AND nriesgo = xnriesgo
                                 AND cgarant = pcgarant
                                 AND TRUNC(finiefe) <= TRUNC(vfsinies)
                                 AND(ffinefe IS NULL
                                     OR TRUNC(vfsinies) <= TRUNC(ffinefe)));
         EXCEPTION
            WHEN OTHERS THEN
               vicapital := 0;
         END;

         e := f_graba_param(xxsesion, 'CAPITAL', vicapital);

         IF e <> 0 THEN
            RETURN 109843;
         END IF;
      END IF;

      BEGIN
         SELECT formula
           INTO xxformula
           FROM sgt_formulas
          WHERE clave = vcclave;   -- de la select
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 108423;
         WHEN OTHERS THEN
            RETURN 108423;
      END;

      -- Cargo parametros predefinidos
      -- RSC 09/06/2008 Tarea 5507 Utilización de bind variables
      FOR term IN cur_termino(vcclave) LOOP
         BEGIN
            BEGIN
               SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                      || ' WHERE ' || twhere || ' ; END;'
                 INTO xs
                 FROM sgt_carga_arg_prede
                WHERE termino = term.parametro
                  AND ttable IS NOT NULL
                  AND cllamada = 'PAC_SIN_FORMULA';
            EXCEPTION
               WHEN NO_DATA_FOUND THEN   --JRH 101/2008 Lo ponemos como en la simulación
                  SELECT 'BEGIN SELECT ' || tcampo || ' INTO :RETORNO  FROM ' || ttable
                         || ' WHERE ' || twhere || ' ; END;'
                    INTO xs
                    FROM sgt_carga_arg_prede
                   WHERE termino = term.parametro
                     AND ttable IS NOT NULL
                     AND cllamada = 'GENERICO';
            END;

            -- RSC 07/07/2008 Mejora propuesta por Sa Nostra (Patch SNVA_249b) Bind Variables
            IF DBMS_SQL.is_open(v_cursor) THEN
               DBMS_SQL.close_cursor(v_cursor);
            END IF;

            v_cursor := DBMS_SQL.open_cursor;
            DBMS_SQL.parse(v_cursor, xs, DBMS_SQL.native);
            DBMS_SQL.bind_variable(v_cursor, ':RETORNO', retorno);

            IF INSTR(xs, ':FECEFE') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECEFE', xfecefe);
            END IF;

            IF INSTR(xs, ':NSINIES') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NSINIES', pnsinies);
            END IF;

            IF INSTR(xs, ':FSINIES') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FSINIES', xfsinies);
            END IF;

            IF INSTR(xs, ':FNOTIFI') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FNOTIFI', xfnotifi);
            END IF;

            IF INSTR(xs, ':SSEGURO') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SSEGURO', vsseguro);
            END IF;

            IF INSTR(xs, ':SPRODUC') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':SPRODUC', vsproduc);
            END IF;

            IF INSTR(xs, ':CACTIVI') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CACTIVI', vcactivi);
            END IF;

            IF INSTR(xs, ':CGARANT') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':CGARANT', pcgarant);
            END IF;

            IF INSTR(xs, ':NRIESGO') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NRIESGO', xnriesgo);
            END IF;

            IF INSTR(xs, ':FVALORA') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FVALORA', xfecval);
            END IF;

            IF INSTR(xs, ':FECHA') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':FECHA', xfsinies);
            END IF;

            IF INSTR(xs, ':NTRAMIT') > 0 THEN
               DBMS_SQL.bind_variable(v_cursor, ':NTRAMIT', pctramit);
            END IF;

            --JRH NDURPER Necesita NMOVIMI
            DECLARE
               nmovimi        NUMBER;
            BEGIN
               SELECT MAX(m.nmovimi)
                 INTO nmovimi
                 FROM movseguro m
                WHERE m.sseguro = vsseguro
                  AND TRUNC(m.fmovimi) <= TO_DATE(TO_CHAR(xfsinies), 'yyyymmdd');

               IF INSTR(xs, ':NMOVIMI') > 0 THEN
                  DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', nmovimi);
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  IF INSTR(xs, ':NMOVIMI') > 0 THEN
                     DBMS_SQL.bind_variable(v_cursor, ':NMOVIMI', '1');
                  END IF;
            END;

            BEGIN
               v_filas := DBMS_SQL.EXECUTE(v_cursor);
               DBMS_SQL.variable_value(v_cursor, 'RETORNO', retorno);

               IF DBMS_SQL.is_open(v_cursor) THEN
                  DBMS_SQL.close_cursor(v_cursor);
               END IF;

               IF retorno IS NULL THEN
                  p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_cal_penali', 1, xxsesion,
                              'Formula:' || xs);
                  RETURN 103135;
               ELSE
                  e := f_graba_param(xxsesion, term.parametro, retorno);

                  IF e <> 0 THEN
                     RETURN 109843;
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  e := f_graba_param(xxsesion, term.parametro, 0);

                  IF e <> 0 THEN
                     RETURN 109843;
                  END IF;
            END;
         --
         EXCEPTION
            WHEN OTHERS THEN
               xs := NULL;
         END;
      END LOOP;

      --e := PAC_CALCULO_FORMULAS.calcula_terminos (xxsesion, reg.clave, 'PK_CALC_SINI', 0);
      p_carga_preguntas(vsseguro, vfsinies, pcgarant, xxsesion);
      val := pk_formulas.eval(xxformula, xxsesion);

      IF (val IS NULL
          OR val < 0) THEN
         p_tab_error(f_sysdate, f_user, 'PAC_SIN_FORMULA.f_cal_valora', 2, xxsesion,
                     'Formula:' || xxformula);
         RETURN 103135;
      ELSE
         e := f_graba_param(xxsesion, 'IPENALI', val);
         xipenali := val;

         IF e <> 0 THEN
            RETURN 109843;
         END IF;
      END IF;

      e := pac_sin_formula.f_insertar_mensajes(0, vsseguro, 0, 0,
                                               TO_NUMBER(TO_CHAR(vfsinies, 'yyyymmdd')),
                                               vcactivi, NULL, 1, pcgarant, xivalsin, 0, 0, 0,
                                               0, 0, 0, 0, xicapris, xipenali, 0, xxfperini,
                                               xxfperfin);

      IF e <> 0 THEN
         RETURN e;
      END IF;

      -- Borro sgt_parms_transitorios
      e := f_borra_param(xxsesion);
      xipenali := f_round_moneda(xipenali, 'EUR');

      IF xipenali IS NULL THEN
         pipenali := 0;
      ELSE
         pipenali := xipenali;
      END IF;

      RETURN 0;
   END f_cal_penali;

   /*************************************************************************
      FUNCTION f_cal_coste
        Funció que devuelve el importe del coste medio
        param in pfsinies
        param in pccausin
        param in pcmotsin
        param in psproduc
        param out pireserva
        return             : 0 -> Tot correcte
                             1 -> S'ha produit un error

        Bug 22674:ASN:03/07/2012
   *************************************************************************/
   FUNCTION f_cal_coste(
      pfsinies IN sin_siniestro.fsinies%TYPE,
      pccausin IN sin_siniestro.ccausin%TYPE,
      pcmotsin IN sin_siniestro.cmotsin%TYPE,
      psproduc IN productos.sproduc%TYPE,
      picoste OUT sin_tramita_reserva.ireserva%TYPE)
      RETURN NUMBER IS
      val            NUMBER;
      xxformula      VARCHAR2(2000);
      xxsesion       NUMBER;
      xfecefe        NUMBER;
      e              NUMBER;
      vparam         VARCHAR2(2000)
         := 'parámetros - pfsinies: ' || pfsinies || 'pccausin: ' || pccausin || ' pcmotsin: '
            || pcmotsin || ' psproduc: ' || psproduc;
   BEGIN
      xfecefe := TO_NUMBER(TO_CHAR(pfsinies, 'yyyymmdd'));

      SELECT sgt_sesiones.NEXTVAL
        INTO xxsesion
        FROM DUAL;

      IF xxsesion IS NULL THEN
         ROLLBACK;
         RETURN 108418;
      END IF;

      e := f_graba_param(xxsesion, 'ORIGEN', 2);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SESION', xxsesion);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'FECEFE', xfecefe);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'SPRODUC', psproduc);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CCAUSIN', pccausin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      e := f_graba_param(xxsesion, 'CMOTSIN', pcmotsin);

      IF e <> 0 THEN
         RETURN 109843;
      END IF;

      SELECT formula
        INTO xxformula
        FROM sgt_formulas
       WHERE clave = 20331;   -- de momento usamos la formula solo para MDP

      val := pk_formulas.eval(xxformula, xxsesion);

      IF val IS NULL THEN
         val := 0;
      END IF;

      picoste := f_round_moneda(val, pac_monedas.f_moneda_producto(psproduc));
      -- Borro sgt_parms_transitorios
      e := f_borra_param(xxsesion);
      RETURN 0;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 0;
   END f_cal_coste;

   /*****************************************************************************************
      Descripcion: Devuelve si es un Amparao de muerte
   *****************************************************************************************/
   FUNCTION f_esamparodemuerte(psproduc IN NUMBER, pcgarant IN NUMBER)
      RETURN NUMBER IS
      v_objec        VARCHAR2(500) := 'pac_sin_formula.F_esampardodemuerte';
      v_param        VARCHAR2(500) := ' psproduc: ' || psproduc || ' pcgarant: ' || pcgarant;
      v_seque        NUMBER := 0;
      v_count        NUMBER := 0;
   BEGIN
      v_seque := 1;

      SELECT COUNT(*)
        INTO v_count
        FROM pargaranpro
       WHERE cpargar = 'MUERTE'
         AND sproduc = psproduc
         AND cgarant = pcgarant;

      v_seque := 2;

      IF v_count > 0 THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objec, v_seque, v_param, SQLERRM);
         RETURN NULL;
   END f_esamparodemuerte;

   /*****************************************************************************************
      Descripcion: Devuelve el valor NUMERICO de la respuesta de SEGUROS
   *****************************************************************************************/
   FUNCTION f_respseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcpregun IN NUMBER,
      pfsinies IN DATE)
      RETURN NUMBER IS
      v_objec        VARCHAR2(500) := 'pac_sin_formula.F_respseg';
      v_param        VARCHAR2(500)
         := ' psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcpregun: '
            || pcpregun || ' pfsinies: ' || pfsinies;
      v_seque        NUMBER := 0;
      v_crespue      NUMBER := 0;
   BEGIN
      v_seque := 1;

      SELECT p.crespue
        INTO v_crespue
        FROM pregunseg p
       WHERE p.sseguro = psseguro
         AND p.nriesgo = pnriesgo
         AND p.cpregun = pcpregun
         AND p.nmovimi = (SELECT MAX(pp.nmovimi)
                            FROM movseguro m, pregunseg pp
                           WHERE m.sseguro = p.sseguro
                             AND m.fefecto < pfsinies
                             AND pp.sseguro = m.sseguro
                             AND pp.nmovimi = m.nmovimi
                             AND pp.nriesgo = p.nriesgo
                             AND pp.cpregun = p.cpregun);

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objec, v_seque, v_param, SQLERRM);
         RETURN NULL;
   END f_respseg;

   /*****************************************************************************************
        Descripcion: Devuelve el valor NUMERICO de la respuesta de las GARANTIAS
     *****************************************************************************************/
   FUNCTION f_respgaranseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pfsinies IN DATE)
      RETURN NUMBER IS
      v_objec        VARCHAR2(500) := 'pac_sin_formula.F_respgaranseg';
      v_param        VARCHAR2(500)
         := ' psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' pcpregun: '
            || pcpregun || ' pfsinies: ' || pfsinies;
      v_seque        NUMBER := 0;
      v_crespue      NUMBER := 0;
   BEGIN
      v_seque := 1;

      SELECT p.crespue
        INTO v_crespue
        FROM pregungaranseg p
       WHERE p.sseguro = psseguro
         AND p.nriesgo = pnriesgo
         AND p.cgarant = pcgarant
         AND p.cpregun = pcpregun
         AND p.nmovimi = (SELECT MAX(pp.nmovimi)
                            FROM pregungaranseg pp
                           WHERE pp.sseguro = p.sseguro
                             AND pp.nriesgo = p.nriesgo
                             AND pp.cgarant = p.cgarant
                             AND pp.cpregun = p.cpregun
                             AND pp.finiefe <= pfsinies);

      RETURN v_crespue;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objec, v_seque, v_param, SQLERRM);
         RETURN NULL;
   END f_respgaranseg;

   /*****************************************************************************************
      Descripcion: Devuelve que RESERVA debe aplicarse a las polizas de Exequia
         1: El importe de la garantia (CAPITAL)
         0: Reserva sera 0
   *****************************************************************************************/
   FUNCTION f_reserva_exequias(
      psproduc IN NUMBER,
      pcgarant IN NUMBER,
      pccausin IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE)
      RETURN NUMBER IS
      v_objec        VARCHAR2(500) := 'pac_sin_formula.F_reserva_exequias';
      v_param        VARCHAR2(500)
         := ' psproduc: ' || psproduc || ' pcgarant: ' || pcgarant || ' pccausin: '
            || pccausin || ' psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo
            || ' pfsinies: ' || pfsinies;
      v_seque        NUMBER := 0;
      v_amparo_muerte NUMBER := 0;
      v_resp_4300    NUMBER := 0;
      v_resp_4651    NUMBER := 0;
      v_fefecto      DATE;
      v_dias         NUMBER := 0;
   BEGIN
      -- Si es una garantia de MORT i la causa es Accident o Homicidi,
      -- la reserva es el import del capital.
      v_seque := 1;
      v_amparo_muerte := f_esamparodemuerte(psproduc, pcgarant);

      IF v_amparo_muerte = 1
         AND pccausin = 2703 THEN
         RETURN 1;
      END IF;

      -- Si se trata de una poliza procedente de un 'traslado' de otras compañias la
      -- reserva es el importe del capital.
      v_seque := 2;
      v_resp_4651 := f_respseg(psseguro, pnriesgo, 4651, pfsinies);

      IF v_resp_4651 = 1 THEN
         RETURN 1;
      END IF;

      -- En el resto de casos comprovamos que la poliza no este dentro del periodo de carencia (FSINIES - FEFECTO)
      -- Para los grupos Familiares (RESP(4300) = 1 ó 2 son 90 dias
      -- Para los asegurados adicionales (RESP(4300) = 3 SON 120 dias
      v_seque := 3;
      v_resp_4300 := f_respseg(psseguro, pnriesgo, 4300, pfsinies);

      SELECT fefecto
        INTO v_fefecto
        FROM seguros
       WHERE sseguro = psseguro;

      v_seque := 4;
      v_dias := pfsinies - v_fefecto;

      IF v_resp_4300 IN(1, 2) THEN
         IF v_dias <= 90 THEN
            RETURN 0;
         ELSE
            RETURN 1;
         END IF;
      ELSE
         IF v_dias <= 120 THEN
            RETURN 0;
         ELSE
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objec, v_seque, v_param, SQLERRM);
         RETURN NULL;
   END f_reserva_exequias;

   /*****************************************************************************************
      Descripcion: Devuelve si la garantia tiene activado el parametro RES_IPERIT
         return             : 0 -> Tot correcte
                             1 -> S'ha produit un error
   *****************************************************************************************/
   FUNCTION f_considera_pretension(
      psseguro IN NUMBER,
      pcgarant IN NUMBER,
      pcactivi IN NUMBER,
      pconsidera_pretension OUT NUMBER)
      RETURN NUMBER IS
      v_objec        VARCHAR2(500) := 'pac_sin_formula.f_considera_pretension';
      v_param        VARCHAR2(500) := ' psseguro: ' || psseguro || ' pcgarant: ' || pcgarant;
      vcmodali       seguros.cmodali%TYPE;
      vccolect       seguros.ccolect%TYPE;
      vctipseg       seguros.ctipseg%TYPE;
      vcramo         seguros.cramo%TYPE;
      vpasexec       NUMBER := 0;
   BEGIN
      SELECT cmodali, ccolect, ctipseg, cramo
        INTO vcmodali, vccolect, vctipseg, vcramo
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 1;
      pconsidera_pretension := f_pargaranpro_v(vcramo, vcmodali, vctipseg, vccolect, pcactivi,
                                               pcgarant, 'RES_IPERIT');
      vpasexec := 2;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, v_objec, vpasexec, v_param, SQLERRM);
         RETURN 1;
   END f_considera_pretension;
END pac_sin_formula;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_FORMULA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FORMULA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_FORMULA" TO "PROGRAMADORESCSI";
