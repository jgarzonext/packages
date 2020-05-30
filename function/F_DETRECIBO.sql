--------------------------------------------------------
--  DDL for Function F_DETRECIBO
--------------------------------------------------------

  CREATE OR REPLACE FUNCTION F_DETRECIBO (pnproces        IN NUMBER,
                                       psseguro        IN NUMBER,
                                       pnrecibo        IN NUMBER,
                                       ptipomovimiento IN NUMBER,
                                       pmodo           IN VARCHAR2,
                                       pcmodcom        IN NUMBER,
                                       pfemisio        IN DATE,
                                       pfefecto        IN DATE,
                                       pfvencim        IN DATE,
                                       pfcaranu        IN DATE,
                                       pnimport        IN NUMBER,
                                       pnriesgo        IN NUMBER,
                                       pnmovimi        IN NUMBER,
                                       pcpoliza        IN NUMBER,
                                       pnimport2       OUT NUMBER,
                                       pcfpagapo       IN NUMBER DEFAULT NULL,
                                       pctipapo        IN NUMBER DEFAULT NULL,
                                       ppimpapo        IN NUMBER DEFAULT NULL,
                                       piimpapo        IN NUMBER DEFAULT NULL,
                                       pcgarant        IN NUMBER DEFAULT NULL,
                                       pttabla         IN VARCHAR2 DEFAULT NULL,
                                       pfuncion        IN VARCHAR2 DEFAULT 'CAR',
                                       pmovorigen      IN NUMBER DEFAULT NULL) -- BUG 34462 - AFM
 RETURN NUMBER IS
   /* ******************************************************************
   - Obté el desglòs per risc i garantia de cadascun
   dels conceptes que formen un rebut. L' origen de la informació són les
   garanties que té l' assegurança amb els seus capitals i primes.
   - S' ha tret el càlcul del concepte 9 (Descompte tècnic).
   Per a veure si s' aplica el recàrrec per fraccionament, mirem
   també el camp crecfra, de la taula SEGUROS. També altres modificacions
   per la taula GARANCAR.
   - En el cas de proves = 'P', només en el tipus de moviment = 21
   accedirem a GARANCAR; en els altres casos, accedirem a
   GARANSEG / GARANCOLEC (depenent de si el producte és innominat o no).
   - S' afegeix funció f_vdetrecibo per omplir taula vdetrecibos i
   càlcul de l' impost FNG.
   - Modificaciones debido a la implantacion del COASEGURO.
   Donde si es un coaseguro cedido se debe repetir todos los registros
   de detrecibo por todos los conceptos sumados 50 en su codigo.
   En las extraordinarias no se coaseguran nunca.
   - CAMBIOS EN CONCEPTOS EN TABLAS POR COASEGURO
   - Iprianu ahora tendra el importe de la parte local
   - Ipritot tendra el importe total, lo que nos obliga a cambiar el campo
   recogido en el cursor cur_garanseg y cur_garansegant,cur_garancar
   - Icapital ahora tendra el importe de la parte local
   - Icaptot tendra el importe total, lo que nos obliga a cambiar el campo
   recogido en el cursor cur_garanseg y cur_garansegant,cur_garancar
   - f_difdata(pfefecto, xfvencim, 3, 3, difdias); por
   f_difdata(pfefecto, xfvencim, 1, 3, difdias); Se calculara
   por diferencia real (modulo 365) en vez del modulo 360
   - Se cambian todos los 360 por 365
   - SE ANULAN LOS DOS PASOS ANTERIORES por problemas a la hora
   de cuadrar los importes con cartera.
   - En el caso de los suplementos tanto en el modo real y en
   modo cartera lo calcularemos en modulo 365 con las variables
   difdias,difdiasanu.
   - Si el nº de asegurados es 0, se graba un recibo y se da el mensaje de error (controlado)
   - Cálculo del divisor 365 0 366 para módulo 365
   - Tratamiento de la regularizacion.
   - En el modo 'A' se graban los recibos de aportación extraord.
   - Modifico para que se grabe con cgarant=282. Antes era cgarant=null.
   - Se añade el cálculo de la comisión para la compañía.
   - Se añade reg. comisión en recibos aportación extra. si esta es por prima neta
   - Se añade pcmodcom en la llamada de f_imprecibos
   - Cambios para los nuevos campos de la tabla DETRECIBOS
   - Se ha vuelto a incorporar la funcionalidad que avisa que no se
   grabaron conceptos y en ese caso no grabe el concepto 99 .
   - S'afegeix el mode ='H' per la rehabilitació de riscos i garanties
   - Es modifica la funció perque inserti um rgistre a detrecibos encara
   que el import sigui 0 si s'ha donat d'alta o de baixa una campanya.
   - Se añade el tipomovimiento = 100 en modo 'P' para el cálculo de
   conceptos extraordinarios.
   - Modificada función "fl_grabar_calcomisprev" para que lea la fecha
   de antigüedad de una garantía de GARANSEG.falta en lugar de MOVSEGURO.
   - Modificamos la función "fl_grabar_calcomisprev" para que en modo 'P' y 'N'
   busque el la fecha de alta en garanseg con max(nmovimi).
   - S'afegeixen els paràmetres PCFPAGAPO,PCTIPAPO,PPIMPAPO,PIIMPAPO
   pel càlcul dels imports per aportant (ÉS NOMÉS PER LA PERIÒDICA).
   - Se añade el parámetro pcgarant para el caso pmodo = 'A' poder
   pasar la garantía asociada (ahora se graba siempre la 282)
   - Se añade el tipomovimiento = 11 ==> Suplemento con Recibo por diferencia
   de prima basada en provisión matemática (prima única)
   - Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
     el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
     el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)

      Ver        Fecha        Autor             Descripción
      ---------  ----------  -------  -------------------------------------
      1.0        XX/XX/XXXX   XXX     1. Creación de la función.
      1.1        09/02/2010   AVT     2. 0012993: CRE - Reasegurar garantias que no tienen prima
      1.2        22/02/2010   AVT     2.1 12961: CRE - Detalle del reaseguro por recibo para los extornos
      2.0        10/03/2010   RSC     2. 0013569: APR - error en la renovación de pólizas con aportaciones únicas
      3.0        31/03/2010   FAL     3. 0012589: CEM - Recibos con copago y consorcio
      4.0        07/06/2010   RSC     4. 0014473: CEM - Suplementos en productos con copago
      5.0        28/11/2010   APD     5. 0017382: CRE800 - Impagamet de rebuts
      6.0        01/03/2011   APD     6. 0017243: ENSA101 - Rebuts de comissió
      7.0        15/11/2011   APD     7. 0020153: LCOL_C001: Ajuste en el cálculo del recibo
      8.0        21/11/2011   JMP     8. 0018423: LCOL000 - Multimoneda
      9.0        02/12/2011   JTS     9. 0020342: LCOL_C001: Ajuste de la f_imprecibos
     10.0        08/12/2011   JRH     8. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
     11.0        19/12/2011   JMF     9. 0020480: LCOL_C001: Ajuste de la retención en la función de cálculo
     12.0        03/01/2012   JRH     10. 0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos
     13.0        01/02/2012   JRH     11 0020666: LCOL_T004-LCOL - UAT - TEC - Indicencias de Tarificaci?n
     14.0        23/03/2012   RSC     12. 0021812: LCOL - Revisar la creacion de recibos en cero cuando en consultas no se visualizan
     15.0        23/03/2012   FAL     13. 0021435: GIP003-ID 6 - Gestión de cartera
     16.0        31/10/2012   AVT     14. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
     17.0        20/11/2012   LCF     15.  0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
     18.0        30/05/2013   ECP     16. 0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A. Nota 145340
     19.0        05/06/2013   APD     17. 0027057: LCOL_T031-Gestión prima mínima de extorno (relacionado con QT 7849)
     20.0        17/03/2016   JAEG    20. 41143/229973: Desarrollo Diseño técnico CONF_TEC-01_VIGENCIA_AMPARO
     21.0        25/05/2016   EDA     21. 37066/238054: No genera las cesiones correctamente en la tablas reaseguro.
     22.0        01/08/2019   DFR     22. IAXIS-3980: Gastos de expedición en endosos.
     23.0        03/11/2019   ECP     23. IAXIS-3264. suplemento BAja de Suplementos
     24.0        19/01/2020   JLTS    24. IAXIS-3264. suplemento BAja de Suplementos
   ****************************************************************************/
   -- Para el fetch
   w_error     VARCHAR2(4000);
   xcgarant    NUMBER;
   xnriesgo    NUMBER;
   xfiniefe    DATE;
   xnorden     NUMBER;
   xctarifa    NUMBER;
   xicapital   NUMBER;
   xprecarg    NUMBER;
   xiprianu    NUMBER;
   xfinefe     DATE;
   xcformul    NUMBER;
   xiextrap    NUMBER;
   xctipfra    NUMBER;
   xifranqu    NUMBER;
   xnmovimi    NUMBER;
   xidtocom    NUMBER;
   xpdtocom    NUMBER;
   xnmovimiant NUMBER;
   -- Variables recuperadas de seguros
   xcforpag NUMBER;
   xcrecfra NUMBER;
   xpdtoord NUMBER;
   xcagente NUMBER;
   xfemisio DATE;
   xcmodali NUMBER;
   xccolect NUMBER;
   xcramo   NUMBER;
   xctipseg NUMBER;
   xcactivi NUMBER;
   xcduraci NUMBER;
   xnduraci NUMBER;
   xndurcob NUMBER;
   xcsituac NUMBER;
   xctipcoa NUMBER;
   xncuacoa NUMBER;
   xinnomin NUMBER;
   xfefepol DATE;
   xnpoliza NUMBER;
   -- Para el select del garanseg con el movimiento anterior
   xxcgarant     NUMBER;
   xxnriesgo     NUMBER;
   xxfiniefe     DATE;
   xxiprianu     NUMBER;
   xxffinefe     DATE;
   xxidtocom     NUMBER;
   grabar        NUMBER;
   decimals      NUMBER := 0;
   xiconcep      NUMBER;
   difiprianu    NUMBER;
   comis_agente  NUMBER := 0;
   reten_agente  NUMBER := 0;
   xffinrec      DATE;
   xiprianu2     NUMBER;
   error         NUMBER := 0;
   xtotprimaneta NUMBER;
   xtotprimadeve NUMBER;
   ha_grabat     BOOLEAN := FALSE;
   pgrabar       NUMBER;
   xidtocom2     NUMBER;
   difidtocom    NUMBER;
   xnmeses       NUMBER;
   xffinany      DATE;
   xnimpcom      NUMBER;
   xnimpret      NUMBER;
   xccomisi      NUMBER;
   xcretenc      NUMBER;
   xccalcom      NUMBER;
   xcprorra      NUMBER;
   xcmodulo      NUMBER;
   xcmotmov      NUMBER;
   xaltarisc     BOOLEAN;
   xinsert       BOOLEAN;
   xnasegur      NUMBER;
   xnasegur1     NUMBER;
   -- xcontriesg    NUMBER;
   xctiprec NUMBER;
   xcimprim NUMBER;
   xploccoa NUMBER;
   xpcomcoa NUMBER;
   xcapieve NUMBER;
   xfmovim  DATE;
   -- Variables para el cálculo de prorrateos
   difdias         NUMBER;
   difdiasanu      NUMBER;
   difdias2        NUMBER;
   difdiasanu2     NUMBER;
   divisor         NUMBER;
   divisor2        NUMBER;
   fanyoprox       DATE;
   facnet          NUMBER;
   facdev          NUMBER;
   facnetsup       NUMBER;
   facdevsup       NUMBER;
   facconsor       NUMBER;
   facconsorfra    NUMBER; --JAMF 11903 Factor de prorrateo del consorcio fracionado
   facces          NUMBER;
   xpro_np_360     NUMBER;
   comis_cia       NUMBER := 0;
   xex_pte_imp     NUMBER;
   lcvalpar        NUMBER;
   xcestaux        NUMBER;
   xcageven_gar    NUMBER;
   xnmovima        NUMBER;
   xnmovima_gar    NUMBER;
   xxcageven_gar   NUMBER;
   xxnmovima_gar   NUMBER;
   sw_aln          NUMBER;
   sw_cextr        NUMBER;
   w_nmeses_cexter NUMBER;
   w_importe_aux   NUMBER;
   ---campanya recibos
   v_tecamp        NUMBER;
   xxcampanya      NUMBER;
   xcampanya       NUMBER;
   xpprorata       NUMBER;
   ha_grabado      NUMBER;
   lpermerita      NUMBER;
   xctipreb        NUMBER;
   v_primadev      NUMBER;
   v_apperiodo     NUMBER;
   v_apextraordi   NUMBER;
   v_iprianu       NUMBER;
   xndiaspro       NUMBER;
   v_cgarant       NUMBER;
   xsproduc        NUMBER;
   xclave          NUMBER;
   xprovmat        NUMBER;
   xpgasext        NUMBER;
   prima_comercial NUMBER;
   importecomisae  NUMBER; --JRH 02/2009 Bug 9011
   xitarrea        NUMBER; -- BUG: 12993 AVT 09-02-2010
   xccobprima      NUMBER; -- BUG 41143/229973 - 17/03/2016 - JAEG
   vcgarantfin     garanpro.cgarant%TYPE; -- Bug 17243 - APD - 01/03/2011
   --Bug.: 18852
   xcempres     NUMBER;
   xfecvig      DATE;
   v_fefectovig DATE; --BUG20342 - JTS - 02/12/2011
   v_sproduc    NUMBER; --BUG20342 - JTS - 02/12/2011
   v_fefectopol DATE; --BUG20342 - JTS - 02/12/2011
   -- Inicio IAXIS-3980 01/08/2019
   vgastexpsup  NUMBER;
   n_error      NUMBER;
   -- Fin IAXIS-3980 01/08/2019
   ---
   TYPE tcursor IS REF CURSOR;

   curgaran tcursor;
   vselect  VARCHAR2(2000);
   -- "TIPO" de garantía segun PARGARANPRO -
   -- CS comparan directamente la garantía 48
   w_pargaranpro NUMBER;
   -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
   v_sup_pm_gar     NUMBER;
   vdifprovision    BOOLEAN := FALSE;
   vcrespue         NUMBER;
   vfacnetsupnoprov NUMBER;
   vfacdevsupnoprov NUMBER;
   vexitegar        BOOLEAN;
   vnorec           BOOLEAN := FALSE;
   v_sup_pm_prod    NUMBER;
   --CJM
   f_efecto_apgp DATE;
   vsseguro      NUMBER;
   v_preg4313    NUMBER;

   -- Fi BUG 20163-  12/2011 - JRH
   vfefecto recibos.fefecto%TYPE := NULL; -- 23/05/2016 EDA  Bug: 37066 No debe prorratear los suplementos, si mantener la fecha de efecto del suplemento.
   -- INI --IAXIS-3264 -19/01/2020
   vssolicit  estseguros.sseguro%TYPE;
   -- FIN --IAXIS-3264 -19/01/2020

   CURSOR cur_garanseg IS
      SELECT cgarant,
             nriesgo,
             finiefe,
             norden,
             ctarifa,
             NVL(icaptot, 0),
             precarg,
             NVL(ipritot, 0),
             ffinefe,
             cformul,
             iextrap,
             ctipfra,
             ifranqu,
             nmovimi,
             idtocom,
             cageven,
             nmovima,
             ccampanya,
             pdtocom,
             itarrea, -- BUG: 12993 AVT 09-02-2010
             ccobprima -- BUG 41143/229973 - 17/03/2016 - JAEG
        FROM garanseg g
       WHERE g.sseguro = psseguro
         AND g.nriesgo = NVL(pnriesgo, nriesgo)
         AND g.nmovimi = pnmovimi
         AND pmodo <> 'H'
         AND NVL(f_pargaranpro_v(xcramo,
                                 xcmodali,
                                 xctipseg,
                                 xccolect,
                                 NVL(xcactivi, 0),
                                 g.cgarant,
                                 'TIPO'),
                 0) <> 4
         AND 1 = DECODE(pmodo,
                        'RRIE',
                        DECODE(NVL(f_pargaranpro_v(xcramo,
                                                   xcmodali,
                                                   xctipseg,
                                                   xccolect,
                                                   NVL(xcactivi, 0),
                                                   g.cgarant,
                                                   'TIPO'),
                                   0),
                               6,
                               1,
                               0),
                        DECODE(NVL(f_parproductos_v(xsproduc,
                                                    'SEPARA_RIESGO_AHORRO'),
                                   0),
                               1,
                               DECODE(NVL(f_pargaranpro_v(xcramo,
                                                          xcmodali,
                                                          xctipseg,
                                                          xccolect,
                                                          NVL(xcactivi, 0),
                                                          g.cgarant,
                                                          'TIPO'),
                                          0),
                                      6,
                                      0,
                                      1),
                               1))
      UNION
      SELECT cgarant,
             nriesgo,
             finiefe,
             norden,
             ctarifa,
             NVL(icaptot, 0),
             precarg,
             NVL(ipritot, 0),
             ffinefe,
             cformul,
             iextrap,
             ctipfra,
             ifranqu,
             nmovi_ant,
             idtocom,
             cageven,
             nmovima,
             ccampanya,
             pdtocom,
             itarrea, -- BUG: 12993 AVT 09-02-2010
             ccobprima -- BUG 41143/229973 - 17/03/2016 - JAEG
        FROM garancar g
       WHERE sproces = pnproces
         AND sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND TRUNC(pfefecto) >= TRUNC(finiefe)
         AND ((TRUNC(pfefecto) < TRUNC(ffinefe)) OR (ffinefe IS NULL))
         AND pmodo = 'H'
         AND NVL(f_pargaranpro_v(xcramo,
                                 xcmodali,
                                 xctipseg,
                                 xccolect,
                                 NVL(xcactivi, 0),
                                 g.cgarant,
                                 'TIPO'),
                 0) <> 4 --JRH Las del tipo 4 no cogerlas
         AND 1 =
             DECODE(NVL(f_parproductos_v(xsproduc, 'SEPARA_RIESGO_AHORRO'),
                        0),
                    1,
                    DECODE(NVL(f_pargaranpro_v(xcramo,
                                               xcmodali,
                                               xctipseg,
                                               xccolect,
                                               NVL(xcactivi, 0),
                                               g.cgarant,
                                               'TIPO'),
                               0),
                           6,
                           0,
                           1),
                    1);

   CURSOR cur_garansegant IS
      SELECT cgarant,
             nriesgo,
             finiefe,
             norden,
             ctarifa,
             NVL(icaptot, 0),
             precarg,
             NVL(ipritot, 0),
             ffinefe,
             cformul,
             iextrap,
             ctipfra,
             ifranqu,
             nmovimi,
             idtocom,
             cageven,
             nmovima,
             ccampanya,
             pdtocom,
             itarrea -- BUG: 12993 AVT 09-02-2010
        FROM garanseg
       WHERE sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND nmovimi = xnmovimiant
            --JRH Las del tipo 4 no cogerlas;
         AND NVL(f_pargaranpro_v(xcramo,
                                 xcmodali,
                                 xctipseg,
                                 xccolect,
                                 NVL(xcactivi, 0),
                                 cgarant,
                                 'TIPO'),
                 0) <> 4
            -- Bug 7926 - RSC - 28/05/2009 -- Se modifica la select del cursor  para que tenga en
            --                                cuenta si la garantía ha vencido ya (solo para el previo,
            --                                ya que en la cartera real ya se da de baja la garantía antes
            --                                y por tanto la garantía ya no entra en el cursor.
         AND pfefecto < DECODE(pmodo,
                               'P',
                               NVL(pac_seguros.f_vto_garantia(sseguro,
                                                              nriesgo,
                                                              cgarant,
                                                              xnmovimiant),
                                   pfefecto + 1),
                               'PRIE',
                               NVL(pac_seguros.f_vto_garantia(sseguro,
                                                              nriesgo,
                                                              cgarant,
                                                              xnmovimiant),
                                   pfefecto + 1),
                               pfefecto + 1)
            -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
         AND 1 = DECODE(pmodo,
                        'RRIE',
                        DECODE(NVL(f_pargaranpro_v(xcramo,
                                                   xcmodali,
                                                   xctipseg,
                                                   xccolect,
                                                   NVL(xcactivi, 0),
                                                   garanseg.cgarant,
                                                   'TIPO'),
                                   0),
                               6,
                               1,
                               0),
                        DECODE(NVL(f_parproductos_v(xsproduc,
                                                    'SEPARA_RIESGO_AHORRO'),
                                   0),
                               1,
                               DECODE(NVL(f_pargaranpro_v(xcramo,
                                                          xcmodali,
                                                          xctipseg,
                                                          xccolect,
                                                          NVL(xcactivi, 0),
                                                          garanseg.cgarant,
                                                          'TIPO'),
                                          0),
                                      6,
                                      0,
                                      1),
                               1));

   -- Fin Bug 7926
   CURSOR cur_garancar IS
      SELECT cgarant,
             nriesgo,
             finiefe,
             norden,
             ctarifa,
             NVL(icaptot, 0),
             precarg,
             NVL(ipritot, 0),
             ffinefe,
             cformul,
             iextrap,
             idtocom,
             cageven,
             nmovima,
             pdtocom,
             itarrea -- BUG: 12993 AVT 09-02-2010
        FROM garancar
       WHERE sproces = pnproces
         AND sseguro = psseguro
         AND nriesgo = NVL(pnriesgo, nriesgo)
         AND TRUNC(pfefecto) >= TRUNC(finiefe)
         AND ((TRUNC(pfefecto) < TRUNC(ffinefe)) OR (ffinefe IS NULL))
         AND (canulado IS NULL OR canulado = 2)
         AND NVL(f_pargaranpro_v(xcramo,
                                 xcmodali,
                                 xctipseg,
                                 xccolect,
                                 NVL(xcactivi, 0),
                                 cgarant,
                                 'TIPO'),
                 0) <> 4 --JRH Las del tipo 4 no cogerlas;
            -- Bug 7926 - RSC - 28/05/2009 -- Se modifica la select del cursor  para que tenga en
            --                                cuenta si la garantía ha vencido ya (solo para el previo,
            --                                ya que en la cartera real ya se da de baja la garantía antes
            --                                y por tanto la garantía ya no entra en el cursor.
         AND pfefecto < DECODE(pmodo,
                               'P',
                               NVL(pac_seguros.f_vto_garantia(sseguro,
                                                              nriesgo,
                                                              cgarant,
                                                              nmovi_ant),
                                   pfefecto + 1),
                               'PRIE',
                               NVL(pac_seguros.f_vto_garantia(sseguro,
                                                              nriesgo,
                                                              cgarant,
                                                              nmovi_ant),
                                   pfefecto + 1),
                               pfefecto + 1)
            -- Bug 13569 - RSC - 10/03/2010 -  APR - error en la renovación de pólizas con aportaciones únicas
         AND NVL(cunica, 0) = 0
            -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes
         AND 1 = DECODE(pmodo,
                        'PRIE',
                        DECODE(NVL(f_pargaranpro_v(xcramo,
                                                   xcmodali,
                                                   xctipseg,
                                                   xccolect,
                                                   NVL(xcactivi, 0),
                                                   garancar.cgarant,
                                                   'TIPO'),
                                   0),
                               6,
                               1,
                               0),
                        DECODE(NVL(f_parproductos_v(xsproduc,
                                                    'SEPARA_RIESGO_AHORRO'),
                                   0),
                               1,
                               DECODE(NVL(f_pargaranpro_v(xcramo,
                                                          xcmodali,
                                                          xctipseg,
                                                          xccolect,
                                                          NVL(xcactivi, 0),
                                                          garancar.cgarant,
                                                          'TIPO'),
                                          0),
                                      6,
                                      0,
                                      1),
                               1));

   -- Fin Bug 13567

   -- Fin Bug 7926

   -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
   -- Bug 5467 - 10/06/2009 - RSC - Desarrollo de sistema de copago
   -- Bug 5467 - 30/06/2009 - RSC - Desarrollo de sistema de copago
   CURSOR cur_aportaseg(psseguro NUMBER,
                        pfefecto DATE,
                        pnorden  NUMBER) IS
      SELECT ctipimp,
             pimport,
             iimport
        FROM aportaseg
       WHERE sseguro = psseguro
         AND finiefe <= pfefecto
         AND (ffinefe IS NULL OR ffinefe > pfefecto)
         AND (norden = pnorden OR pnorden IS NULL);

   -- Fin Bug 7854 y 8745
   -- Fin Bug 5467

   --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
   vobj VARCHAR2(200) := 'F_DETRECIBO';
   vpas NUMBER := 1;
   vpar VARCHAR2(500) := SUBSTR('1=' || pnproces || ' 2= ' || psseguro ||
                                '3 =' || pnrecibo || '4=' ||
                                ptipomovimiento || '5=' || pmodo || '6=' ||
                                pcmodcom || '7=' || pfemisio || '8=' ||
                                pfefecto || '9=' || pfvencim || '10=' ||
                                pfcaranu || '11=' || pnimport || '12=' ||
                                pnriesgo || '13=' || pnmovimi || '14=' ||
                                pcpoliza || '15=' || pcfpagapo || '16=' ||
                                pctipapo || '17=' || ppimpapo || '18=' ||
                                piimpapo || '19=' || pcgarant || '20=' ||
                                pttabla || '21=' || pfuncion,
                                1,
                                500);

   --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
   FUNCTION fl_inbucle_extrarec(pnrecibo  IN NUMBER,
                                pfemisrec IN DATE,
                                psseguro  IN NUMBER,
                                pcgarant  IN NUMBER,
                                pploccoa  IN NUMBER,
                                pctipcoa  IN NUMBER,
                                pcageven  IN NUMBER,
                                pnmovima  IN NUMBER,
                                pnproces  IN NUMBER,
                                pnriesgo  IN NUMBER,
                                pnmeses   IN NUMBER,
                                ha_grabat OUT NUMBER) RETURN NUMBER IS
      /********************************************************************************************
        Se añade el parámetro de salida ha_grabat para saber si se
          han grabado registros en DETRECIBOS
      *********************************************************************************************/
      CURSOR cur_inbucle_extrarec(esseguro NUMBER,
                                  ecgarant NUMBER,
                                  enriesgo NUMBER,
                                  enmeses  NUMBER,
                                  eefemis  DATE) IS
         SELECT SUM(NVL(iextrarec, 0))
           FROM extrarec
          WHERE sseguro = esseguro
            AND cgarant = ecgarant
            AND nriesgo = enriesgo
            AND nrecibo IS NULL;

      w_importe NUMBER;
      --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
      vobj VARCHAR2(200) := 'fl_inbucle_extrarec';
      vpas NUMBER := 1;
      vpar VARCHAR2(500) := SUBSTR('n=' || pnrecibo || ' f=' || pfemisrec ||
                                   ' s=' || psseguro || ' g=' || pcgarant ||
                                   ' pp=' || pploccoa || ' t=' || pctipcoa ||
                                   ' ag=' || pcageven || ' m=' || pnmovima ||
                                   ' pr' || pnproces || ' r=' || pnriesgo ||
                                   ' mes=' || pnmeses,
                                   1,
                                   500);
      --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
   BEGIN
      --
      -- Rutina que, dentro del bucle de tratamiento del recibo, graba acumulados
      --   de conceptos extraordinarios para la garantia dada
      --
      vpas := 100;

      OPEN cur_inbucle_extrarec(psseguro,
                                pcgarant,
                                pnriesgo,
                                pnmeses,
                                pfemisrec);

      FETCH cur_inbucle_extrarec
         INTO w_importe;

      IF cur_inbucle_extrarec%NOTFOUND
      THEN
         CLOSE cur_inbucle_extrarec;

         RETURN 0;
      END IF;

      CLOSE cur_inbucle_extrarec;

      vpas := 110;

      IF w_importe <> 0
      THEN
         --
         -- Insercion de un registro en DETRECIBOS con codigo de concepto 26, y posterior
         --   UPDATE de la tabla EXTRAREC informando NRECIBO en los registros sumados en
         --   el cursor.
         --
         -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim RRIE)
         vpas := 120;

         IF pmodo IN ('R', 'RRIE')
         THEN
            -- (MODE REAL PRODUCCIÓ I CARTERA)
            vpas      := 130;
            error     := f_insdetrec(pnrecibo,
                                     26,
                                     w_importe,
                                     pploccoa,
                                     pcgarant,
                                     pnriesgo,
                                     pctipcoa,
                                     pcageven,
                                     pnmovima,
                                     0,
                                     0,
                                     1,
                                     NULL,
                                     NULL,
                                     NULL,
                                     decimals -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                                     );
            ha_grabat := 1;
         ELSIF pmodo IN ('P', 'PRIE')
         THEN
            vpas      := 140;
            error     := f_insdetreccar(pnproces,
                                        pnrecibo,
                                        26,
                                        w_importe,
                                        pploccoa,
                                        pcgarant,
                                        pnriesgo,
                                        pctipcoa,
                                        pcageven,
                                        pnmovima,
                                        0,
                                        0,
                                        1,
                                        NULL,
                                        NULL,
                                        NULL,
                                        decimals);
            ha_grabat := 1;
         END IF;

         IF error <> 0
         THEN
            -- 6- 0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || error);
            RETURN error;
         END IF;

         -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim RRIE)
         vpas := 150;

         IF pmodo IN ('R', 'RRIE')
         THEN
            BEGIN
               UPDATE extrarec
                  SET nrecibo = pnrecibo
                WHERE sseguro = psseguro
                  AND cgarant = pcgarant
                  AND nriesgo = pnriesgo;
            EXCEPTION
               WHEN OTHERS THEN
                  -- 6- 0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
                  p_tab_error(f_sysdate,
                              f_user,
                              vobj,
                              vpas,
                              vpar,
                              'SQLCODE = ' || SQLCODE || ' - ' ||
                              'SQLERRM = ' || SQLERRM || 'error = ' ||
                              111939);
                  RETURN 111939; -- Error modificando tabla EXTRAREC
            END;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur_inbucle_extrarec%ISOPEN
         THEN
            CLOSE cur_inbucle_extrarec;
         END IF;

         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 111938);
         RETURN 111938; -- Error leyendo datos de la tabla EXTRAREC
   END fl_inbucle_extrarec;

   FUNCTION fl_grabar_calcomisprev(psseguro     IN NUMBER,
                                   pnrecibo     IN NUMBER,
                                   pcgarant     IN NUMBER,
                                   pnriesgo     IN NUMBER,
                                   pcageven     IN NUMBER,
                                   pnmovima     IN NUMBER,
                                   picalcom     IN OUT NUMBER,
                                   pfefecto_rec IN DATE,
                                   pfvto_rec    IN DATE,
                                   pmodo        IN VARCHAR2,
                                   pnproces     IN NUMBER) RETURN NUMBER IS
      sw_cgencom NUMBER;
      sw_cgendev NUMBER;
      error      NUMBER;
      w_difmeses NUMBER;
      w_fechaux1 DATE;
      w_fechaux2 DATE;
      w_calcom   NUMBER;
      w_nmeses   NUMBER;
      w_icomcob  NUMBER := 0;
      --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
      vobj VARCHAR2(200) := 'fl_grabar_calcomisprev';
      vpas NUMBER := 1;
      vpar VARCHAR2(500) := SUBSTR('n=' || pnrecibo || ' f=' ||
                                   pfefecto_rec || ' s=' || psseguro ||
                                   ' g=' || pcgarant || ' pp=' || picalcom ||
                                   ' ag=' || pcageven || ' m=' || pnmovima ||
                                   ' pr' || pnproces || ' r=' || pnriesgo ||
                                   ' vto_rec=' || pfvto_rec || 'pmod =' ||
                                   pmodo,
                                   1,
                                   500);
      --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
      /*Añado el parametro pcpoliza (si es baja la falta del ultimo mov)
      además se añade a las selects el nmovima*/
   BEGIN
      --
      -- Funcion que graba los datos necesarios en la tabla CALCOMISPREV
      --   para poder realizar el calculo de comisiones para ALN
      --
      --
      -- Buscamos la primera fecha de inicio de la garantia en la tabla GARANSEG
      --
      -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim RRIE)
      vpas := 100;

      IF pmodo IN ('R', 'H', 'RRIE')
      THEN
         BEGIN
            SELECT g.falta
              INTO w_fechaux1
              FROM garanseg g
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.cgarant = pcgarant
               AND g.nmovima = pnmovima
               AND g.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg g
                                 WHERE g.sseguro = psseguro
                                   AND g.nriesgo = pnriesgo
                                   AND g.cgarant = pcgarant
                                   AND g.nmovima = pnmovima);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104349;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 104349);
               RETURN 104349;
         END;
      ELSIF pmodo IN ('P', 'N', 'PRIE')
      THEN
         BEGIN
            SELECT g.falta
              INTO w_fechaux1
              FROM garanseg g
             WHERE g.sseguro = psseguro
               AND g.nriesgo = pnriesgo
               AND g.cgarant = pcgarant
               AND g.nmovima = pnmovima
               AND g.nmovimi = (SELECT MAX(nmovimi)
                                  FROM garanseg g
                                 WHERE g.sseguro = psseguro
                                   AND g.nriesgo = pnriesgo
                                   AND g.cgarant = pcgarant
                                   AND g.nmovima = pnmovima);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104349;
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 104349);
               RETURN 104349;
         END;
      END IF;

      --
      -- Buscamos la diferencia en meses de la fecha de efecto de la garantia
      --   y la fecha de efecto del recibo
      --
      vpas  := 110;
      error := f_difdata(w_fechaux1, pfefecto_rec, 1, 2, w_difmeses);

      IF error <> 0
      THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || error);
         RETURN error;
      END IF;

      --
      -- Si la diferencia en meses es cero, generamos la comision devengada
      --
      IF w_difmeses = 0
      THEN
         sw_cgendev := 1;
      ELSE
         sw_cgendev := 0;
      END IF;

      --
      -- Si la diferencia de meses es menor que el numero de meses de pago, se generan
      --   comisiones
      --
      BEGIN
         SELECT DECODE(NVL(nmescob, 0), 0, 12, nmescob)
           INTO w_nmeses
           FROM agentes
          WHERE cagente = pcageven;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            w_nmeses := 12;
         WHEN OTHERS THEN
            w_nmeses := 12;
      END;

      vpas := 120;

      --
      -- Calculamos el importe a aplicar a los agentes cobradores
      --
      -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim RRIE)
      IF pmodo = 'R' OR
         pmodo = 'H' OR
         pmodo = 'RRIE'
      THEN
         BEGIN
            SELECT SUM(NVL(iconcep, 0))
              INTO w_icomcob
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cconcep IN (0, 26);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_icomcob := 0;
            WHEN OTHERS THEN
               w_icomcob := 0;
         END;
      ELSIF pmodo IN ('P', 'PRIE')
      THEN
         BEGIN
            SELECT SUM(NVL(iconcep, 0))
              INTO w_icomcob
              FROM detreciboscar
             WHERE sproces = pnproces
               AND nrecibo = pnrecibo
               AND cgarant = pcgarant
               AND nriesgo = pnriesgo
               AND nmovima = pnmovima
               AND cconcep IN (0, 26);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               w_icomcob := 0;
            WHEN OTHERS THEN
               w_icomcob := 0;
         END;
      END IF;

      IF w_difmeses <= w_nmeses
      THEN
         sw_cgencom := 1;
      ELSE
         sw_cgencom := 0;
      END IF;

      --
      -- Calculo del porcentaje de comisión a pagar para dicho recibo
      --
      w_fechaux2 := add_months(w_fechaux1, w_nmeses);

      IF pfvto_rec < w_fechaux2
      THEN
         w_fechaux1 := pfvto_rec;
      ELSE
         w_fechaux1 := w_fechaux2;
      END IF;

      IF pfefecto_rec > w_fechaux1
      THEN
         w_calcom   := 0;
         sw_cgencom := 0;
         sw_cgendev := 0;
      ELSE
         vpas  := 130;
         error := f_difdata(pfefecto_rec, w_fechaux1, 1, 2, w_difmeses);

         IF error <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || error);
            RETURN error;
         END IF;

         w_calcom := w_difmeses;
      END IF;

      IF NVL(picalcom, 0) = 0
      THEN
         --
         -- Si el importe es nulo o cero, no se calcularán comisiones
         --
         sw_cgencom := 0;
         sw_cgendev := 0;
      END IF;

      vpas := 140;

      BEGIN
         INSERT INTO calcomisprev
            (nrecibo, cgarant, nriesgo, cageven, nmovima, icalcom, pcalcom,
             icomcob, nmesagt, cgencom, cgendev)
         VALUES
            (pnrecibo, pcgarant, pnriesgo, pcageven, pnmovima, picalcom,
             w_calcom, w_icomcob, w_nmeses, sw_cgencom, sw_cgendev);
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 111923);
            RETURN 111923;
            -- Error al insertar datos en la tabla CALCOMISPREV
      END;

      RETURN 0;
   END fl_grabar_calcomisprev;

   -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
   FUNCTION f_calculo_prov(pcramo      NUMBER,
                           pcmodali    NUMBER,
                           pccolect    NUMBER,
                           pctipseg    NUMBER,
                           pcactivi    NUMBER,
                           pcgarant    NUMBER,
                           pfefecto    DATE,
                           psproduc    NUMBER,
                           pnriesgo    NUMBER,
                           psseguro    NUMBER,
                           pnmovimiant IN NUMBER,
                           perror      OUT NUMBER) RETURN NUMBER IS
      vclave   NUMBER;
      vprovmat NUMBER;
      --0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
      vobj VARCHAR2(200) := 'f_calculo_prov';
      vpas NUMBER := 1;
      vpar VARCHAR2(500) := SUBSTR('r=' || pcramo || ' m=' || pcmodali ||
                                   ' c=' || pccolect || ' t=' || pctipseg ||
                                   ' ac=' || pcactivi || ' g=' || pcgarant ||
                                   ' e=' || pfefecto || ' p' || psproduc ||
                                   ' r=' || pnriesgo || ' psseg=' ||
                                   psseguro || 'pnmov =' || pnmovimiant,
                                   1,
                                   500);
      --  0024753: MDP - Trazas en las funciones de generación de recibos cuando se produce error
   BEGIN
      -- Calculamos la prima comercial a esta fecha a traves de la reserva
      -- matemática
      -- Fi BUG 20163-  12/2011 - JRH
      vpas := 100;

      BEGIN
         SELECT clave
           INTO vclave
           FROM garanformula
          WHERE cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND ccampo = 'IPROVMAT';
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 110087);
            perror := 110087; -- Error al insertar en GARANFORMULA
            RETURN NULL;
      END;

      perror := pac_calculo_formulas.calc_formul(pfefecto,
                                                 psproduc,
                                                 pcactivi,
                                                 pcgarant,
                                                 pnriesgo,
                                                 psseguro,
                                                 vclave,
                                                 vprovmat,
                                                 pnmovimiant);

      IF perror <> 0
      THEN
         RETURN NULL;
      END IF;

      RETURN vprovmat; --Devolvemos la provisión
   END;

   -- Fi BUG 20163-  12/2011 - JRH  -
   -- Bug 27057/0145439 - APD - 05/06/2013 - se crea la funcion
   FUNCTION f_recalcula_vdetrecibos(pmodo VARCHAR2) RETURN NUMBER IS
      error    NUMBER := 0;
      vobj     VARCHAR2(200) := 'f_recalcula_vdetrecibos';
      vpas     NUMBER := 1;
      vpar     VARCHAR2(500) := 'pmodo=' || pmodo || ' pnrecibo=' ||
                                pnrecibo;
      viprinet NUMBER;
      vitotalr NUMBER;
   BEGIN
      BEGIN
         IF pmodo IN ('R', 'A', 'ANP', 'I', 'RRIE')
         THEN
            SELECT iprinet,
                   itotalr
              INTO viprinet,
                   vitotalr
              FROM vdetrecibos
             WHERE nrecibo = pnrecibo;
         ELSIF pmodo = 'P' OR
               pmodo = 'N' OR
               pmodo = 'PRIE'
         THEN
            SELECT iprinet,
                   itotalr
              INTO viprinet,
                   vitotalr
              FROM vdetreciboscar
             WHERE nrecibo = pnrecibo;
         END IF;

         IF vitotalr < 0
         THEN
            IF xctiprec <> 10
            THEN
               -- No és un extorn d' anul.lació
               BEGIN
                  lpermerita := NVL(f_parinstalacion_n('PERMERITA'), 0);

                  -- xex_pte_imp = 1 (Extorn pendent d'imprimir)
                  -- xex_pte_imp = 0 (Extorn pendent de transferir)
                  UPDATE recibos
                     SET ctiprec = 9, -- Si la prima és negativa,
                         cestimp = DECODE(cestimp,
                                          4,
                                          DECODE(xex_pte_imp, 0, 7, 1),
                                          cestimp),
                         nperven = DECODE(lpermerita,
                                          0,
                                          nperven,
                                          1,
                                          TO_CHAR(femisio, 'yyyymm'))
                   WHERE nrecibo = pnrecibo; -- es tracta d' un extorn
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 102358);
                     RETURN 102358; -- Error al modificar la taula RECIBOS
               END;

               vpas := 800;

               -- BUG: 12961 AVT 22-02-2010 s'ajusta pels rebuts d'extorn
               FOR reg IN (SELECT cgarant,
                                  SUM(iconcep) iconcep
                             FROM detrecibos
                            WHERE nrecibo = pnrecibo
                            GROUP BY cgarant)
               LOOP
                  IF reg.iconcep = 0
                  THEN
                     BEGIN
                        DELETE detrecibos
                         WHERE nrecibo = pnrecibo
                           AND cgarant = reg.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 104377);
                           RETURN 104377;
                     END;
                  END IF;
               END LOOP;
               -- BUG: 12961 FI
            END IF;

            error := f_extornpos(pnrecibo, pmodo, pnproces, ptipomovimiento);

            IF error <> 0
            THEN
               RETURN error;
            END IF;

            IF pmodo IN ('R', 'A', 'ANP', 'I', 'RRIE')
            THEN
               DELETE FROM vdetrecibos_monpol WHERE nrecibo = pnrecibo;

               DELETE FROM vdetrecibos WHERE nrecibo = pnrecibo;
            ELSIF pmodo = 'P' OR
                  pmodo = 'N' OR
                  pmodo = 'PRIE'
            THEN
               DELETE FROM vdetreciboscar_monpol WHERE nrecibo = pnrecibo;

               DELETE FROM vdetreciboscar WHERE nrecibo = pnrecibo;
            END IF;

            error := f_vdetrecibos(pmodo, pnrecibo);
         END IF;
      END;

      RETURN error;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 103513);
         RETURN 103513; -- Error al insertar en DETRECIBOS
   END f_recalcula_vdetrecibos;
   -- fin Bug 27057/0145439 - APD - 05/06/2013
   -------------------------------------------------------------------------------------
   -- FUNCIO PRINCIPAL
   -------------------------------------------------------------------------------------
BEGIN
   --INI -IAXIS-3264 - 19/01/2020
   delete garanseg_baja_tmp d where d.sseguro = psseguro;
   --FIN -IAXIS-3264 - 19/01/2020
   --Cal veure si s'han de deixar els extorns pendents d'imprimir o de transferir
   xex_pte_imp := NVL(f_parinstalacion_n('EX_PTE_IMP'), 0);
   sw_aln      := 0;

   IF NVL(f_parinstalacion_t('CONCEPEXTR'), 'NO') = 'SI'
   THEN
      sw_cextr        := 1;
      w_nmeses_cexter := NVL(f_parinstalacion_n('CEXTRNMES'), 0);
   ELSE
      sw_cextr := 0;
   END IF;

   vpas := 500;

   IF pttabla = 'SOL'
   THEN
      BEGIN
         SELECT cforpag,
                cagente,
                cmodali,
                ccolect,
                cramo,
                ctipseg,
                cactivi,
                cduraci,
                nduraci,
                ndurcob,
                cobjase,
                sproduc,
                falta,
                pac_parametros.f_parinstalacion_n('EMPRESADEF')
           INTO xcforpag,
                xcagente,
                xcmodali,
                xccolect,
                xcramo,
                xctipseg,
                xcactivi,
                xcduraci,
                xnduraci,
                xndurcob,
                xinnomin,
                xsproduc,
                xfefepol,
                xcempres
           FROM solseguros
          WHERE ssolicit = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903; -- Seguro no encontrado en la tabla SEGUROS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 101919);
            RETURN 101919; -- Error al llegir dades de la taula SEGUROS
      END;
   ELSIF pttabla = 'EST'
   THEN
      vpas := 510;

      BEGIN
         SELECT NVL(pcfpagapo, cforpag),
                crecfra,
                pdtoord,
                cagente,
                femisio,
                cmodali,
                ccolect,
                cramo,
                ctipseg,
                cactivi,
                cduraci,
                nduraci,
                ndurcob,
                csituac,
                ctipcoa,
                ncuacoa,
                cobjase,
                fefecto,
                npoliza,
                ctipreb,
                sproduc,
                cempres
           INTO xcforpag,
                xcrecfra,
                xpdtoord,
                xcagente,
                xfemisio,
                xcmodali,
                xccolect,
                xcramo,
                xctipseg,
                xcactivi,
                xcduraci,
                xnduraci,
                xndurcob,
                xcsituac,
                xctipcoa,
                xncuacoa,
                xinnomin,
                xfefepol,
                xnpoliza,
                xctipreb,
                xsproduc,
                xcempres
           FROM estseguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903; -- Seguro no encontrado en la tabla SEGUROS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 101919);
            RETURN 101919; -- Error al llegir dades de la taula SEGUROS
      END;
   ELSE
      vpas := 520;

      BEGIN
         SELECT NVL(pcfpagapo, cforpag),
                crecfra,
                pdtoord,
                cagente,
                femisio,
                cmodali,
                ccolect,
                cramo,
                ctipseg,
                cactivi,
                cduraci,
                nduraci,
                ndurcob,
                csituac,
                ctipcoa,
                ncuacoa,
                cobjase,
                fefecto,
                npoliza,
                ctipreb,
                sproduc,
                cempres
           INTO xcforpag,
                xcrecfra,
                xpdtoord,
                xcagente,
                xfemisio,
                xcmodali,
                xccolect,
                xcramo,
                xctipseg,
                xcactivi,
                xcduraci,
                xnduraci,
                xndurcob,
                xcsituac,
                xctipcoa,
                xncuacoa,
                xinnomin,
                xfefepol,
                xnpoliza,
                xctipreb,
                xsproduc,
                xcempres
           FROM seguros
          WHERE sseguro = psseguro;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 101903; -- Seguro no encontrado en la tabla SEGUROS
         WHEN OTHERS THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 101919);
            RETURN 101919; -- Error al llegir dades de la taula SEGUROS
      END;
   END IF;

   vpas := 530;

   BEGIN
      SELECT ccalcom,
             cprorra, --DECODE(cdivisa, 2, 2, 3, 1),
             -- JLB - I - BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
             --                                DECODE(cdivisa, 3, 1, cdivisa),   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
             pac_monedas.f_moneda_divisa(cdivisa),
             -- JLB - F - BUG 18423 - 15/12/2011 - JLB - LCOL000 - Multimoneda
             ndiaspro,
             pgasext
        INTO xccalcom,
             xcprorra,
             decimals,
             xndiaspro,
             xpgasext
        FROM productos
       WHERE cramo = xcramo
         AND cmodali = xcmodali
         AND ctipseg = xctipseg
         AND ccolect = xccolect;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347; -- Producte no trobat a PRODUCTOS
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 102705);
         RETURN 102705; -- Error al llegir de PRODUCTOS
   END;

   vpas := 540;

   IF pmodo IN ('A', 'ANP')
   THEN
      -- només grabem a DETRECIBOS
      -- ***********************************************************************
      -- Cas d' Estalvi (aportació extraordinària), grabem directament a la prima
      -- neta de DETRECIBOS, i sortim de la funció.
      -- ***********************************************************************
      IF pnimport IS NOT NULL AND
         pnimport <> 0
      THEN
         BEGIN
            SELECT ctiprec,
                   ctipcoa
              INTO xctiprec,
                   xctipcoa
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101902; -- Rebut no trobat a RECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 102367);
               RETURN 102367; -- Error al llegir de RECIBOS
         END;

         vpas := 550;

         -- Si el modo es ANP ' Aportación en el alta', se calcula la prima devengada
         IF pmodo = 'ANP' AND
            NVL(f_parproductos_v(xsproduc, 'NOMESEXTRA'), 0) <> 0
         THEN
            SELECT NVL(SUM(g.icapital), 0),
                   SUM(g.iprianu),
                   MAX(g.cgarant)
              INTO v_apperiodo,
                   v_iprianu,
                   v_cgarant
              FROM garanseg g,
                   seguros  s
             WHERE g.sseguro = psseguro
               AND g.nriesgo = NVL(pnriesgo, 1)
               AND s.sseguro = g.sseguro
               AND NVL(f_pargaranpro_v(s.cramo,
                                       s.cmodali,
                                       s.ctipseg,
                                       s.ccolect,
                                       s.cactivi,
                                       g.cgarant,
                                       'TIPO'),
                       0) = 3;

            SELECT NVL(SUM(icapital), 0)
              INTO v_apextraordi --282
              FROM garanseg g,
                   seguros  s
             WHERE g.sseguro = psseguro
               AND g.nriesgo = NVL(pnriesgo, 1)
               AND s.sseguro = g.sseguro
               AND NVL(f_pargaranpro_v(s.cramo,
                                       s.cmodali,
                                       s.ctipseg,
                                       s.ccolect,
                                       s.cactivi,
                                       g.cgarant,
                                       'TIPO'),
                       0) = 4;

            v_primadev := v_iprianu;

            --if NVL(v_apextraordi,0) <> 0 then --JRH 10/2008
            --  v_cgarant:=NVL (pcgarant, 282);
            --end if;

            --IF NVL(f_parproductos_v(xsproduc, 'NOMESEXTRA'),0) = 0 then --JRH 08/2008
            --    v_apperiodo:=0;
            --    v_cgarant:=NVL (pcgarant, 282);
            --end if;
            IF (xndiaspro IS NOT NULL) AND
               to_number(TO_CHAR(xfefepol, 'dd')) >= xndiaspro AND
               xcforpag = 12
            THEN
               v_primadev := v_iprianu - v_apperiodo;
            END IF;

            IF v_apextraordi <> 0
            THEN
               -- Si se hace una aportación extraordinaria inicial se debe restar una aportación.
               -- abans     v_primadev := v_ApExtraordi + v_primadev - v_apPeriodo;
               error := f_pargaranpro(xcramo,
                                      xcmodali,
                                      xctipseg,
                                      xccolect,
                                      xcactivi,
                                      v_cgarant,
                                      'GENVENTA',
                                      lcvalpar);

               IF error <> 0
               THEN
                  RETURN error;
               ELSE
                  IF NVL(lcvalpar, 1) = 1
                  THEN
                     error := f_insdetrec(pnrecibo,
                                          21,
                                          v_primadev - v_apperiodo,
                                          0,
                                          v_cgarant,
                                          NVL(pnriesgo, 1),
                                          0,
                                          NULL,
                                          1,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                     IF error <> 0
                     THEN
                        RETURN error;
                     END IF;
                  END IF;
               END IF;

               -- queda pendent insertar la prima devengada de l'aportació extraordinaria
               v_primadev := v_apextraordi;
            END IF;
         ELSE
            v_primadev := pnimport;
         END IF;

         vpas := 600;

         BEGIN
            -- Prima Neta
            error := f_insdetrec(pnrecibo,
                                 0,
                                 pnimport,
                                 0,
                                 NVL(pcgarant, 282),
                                 NVL(pnriesgo, 1),
                                 0,
                                 NULL,
                                 1,
                                 0,
                                 0,
                                 1,
                                 NULL,
                                 NULL,
                                 NULL,
                                 decimals);

            IF error <> 0
            THEN
               RETURN error;
            END IF;

            error := f_pargaranpro(xcramo,
                                   xcmodali,
                                   xctipseg,
                                   xccolect,
                                   xcactivi,
                                   NVL(pcgarant, 282),
                                   'GENVENTA',
                                   lcvalpar);

            IF error <> 0
            THEN
               RETURN error;
            ELSE
               IF NVL(lcvalpar, 1) = 1
               THEN
                  error := f_insdetrec(pnrecibo,
                                       21,
                                       v_primadev,
                                       0,
                                       NVL(pcgarant, 282),
                                       NVL(pnriesgo, 1),
                                       0,
                                       NULL,
                                       1,
                                       0,
                                       0,
                                       1,
                                       NULL,
                                       NULL,
                                       NULL,
                                       decimals);
               END IF;

               IF error <> 0
               THEN
                  RETURN error;
               END IF;
            END IF;

            IF xccalcom IN (1, 4)
            THEN
               -- Sobre prima
               --BUG20342 - JTS - 02/12/2011
               --Bug.:18852 - 08/09/2011 - ICV
               /*IF NVL(pac_parametros.f_parempresa_t(xcempres, 'FVIG_COMISION'), 'FEFECTO_REC') =
                                                                                 'FEFECTO_REC' THEN
                  xfecvig := pfefecto;   --Efecto del recibo
               ELSE
                  xfecvig := xfefepol;   --Efecto de la póliza
               END IF;
               */
               --Fi Bug.: 18852
               IF pttabla = 'SOL'
               THEN
                  SELECT sproduc,
                         xfefepol
                    INTO v_sproduc,
                         v_fefectopol
                    FROM solseguros
                   WHERE ssolicit = psseguro;
               ELSIF pttabla = 'EST'
               THEN
                  SELECT sproduc,
                         fefecto
                    INTO v_sproduc,
                         v_fefectopol
                    FROM estseguros
                   WHERE sseguro = psseguro;
               ELSE
                  SELECT sproduc,
                         fefecto
                    INTO v_sproduc,
                         v_fefectopol
                    FROM seguros
                   WHERE sseguro = psseguro;
               END IF;

               IF NVL(pac_parametros.f_parproducto_t(v_sproduc,
                                                     'FVIG_COMISION'),
                      'FEFECTO_REC') = 'FEFECTO_REC'
               THEN
                  v_fefectovig := pfefecto; --Efecto del recibo
               ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                    'FVIG_COMISION') =
                     'FEFECTO_POL'
               THEN
                  --Efecto de la póliza
                  BEGIN
                     IF pttabla = 'EST'
                     THEN
                        SELECT TO_DATE(crespue, 'YYYYMMDD')
                          INTO v_fefectovig
                          FROM estpregunpolseg
                         WHERE sseguro = psseguro
                           AND nmovimi =
                               (SELECT MAX(p.nmovimi)
                                  FROM estpregunpolseg p
                                 WHERE p.sseguro = psseguro)
                           AND cpregun = 4046;
                     ELSE
                        SELECT TO_DATE(crespue, 'YYYYMMDD')
                          INTO v_fefectovig
                          FROM pregunpolseg
                         WHERE sseguro = psseguro
                           AND nmovimi =
                               (SELECT MAX(p.nmovimi)
                                  FROM pregunpolseg p
                                 WHERE p.sseguro = psseguro)
                           AND cpregun = 4046;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_fefectovig := v_fefectopol;
                  END;
               ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                    'FVIG_COMISION') =
                     'FEFECTO_RENOVA'
               THEN
                  -- efecto a la renovacion
                  IF pttabla = 'SOL'
                  THEN
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 0),
                                             'yyyymmdd');
                  ELSIF pttabla = 'EST'
                  THEN
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 1),
                                             'yyyymmdd');
                  ELSE
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 2),
                                             'yyyymmdd');
                  END IF;
               END IF;

               vpas    := 610;
               xfecvig := v_fefectovig;
               --FIBUG20342
               -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
               -- de la variable xfecvig
               -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
               error := f_pcomisi(psseguro,
                                  pcmodcom,
                                  f_sysdate,
                                  comis_agente,
                                  reten_agente,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  pttabla,
                                  pfuncion,
                                  xfecvig);

               -- Fin Bug 20153 - APD - 15/11/2011
               IF error <> 0
               THEN
                  RETURN error;
               END IF;
            END IF;

            vpas := 620;

            IF ptipomovimiento = 10 -- aportación
               AND
               NVL(pac_parametros.f_parempresa_n(xcempres,
                                                 'COMISION_TRASPASO'),
                   0) = 1
            THEN
               -- si aplica comision en aportación
               --Comisión se añade
               IF NVL(pnimport, 0) <> 0 AND
                  NVL(comis_agente, 0) <> 0
               THEN
                  --Insertamos comisión
                  importecomisae := f_round(((pnimport * comis_agente) / 100),
                                            decimals);
                  error          := f_insdetrec(pnrecibo,
                                                11,
                                                importecomisae, -- jrh pnimport,
                                                0,
                                                NVL(pcgarant, 282),
                                                NVL(pnriesgo, 1),
                                                0,
                                                NULL,
                                                1,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                  --xcageven_gar, --JRH 9011
                  --xnmovima_gar,
                  --comis_agente,
                  --psseguro
                  --);
                  IF error <> 0
                  THEN
                     RETURN error;
                  END IF;

                  vpas  := 630;
                  error := f_pargaranpro(xcramo,
                                         xcmodali,
                                         xctipseg,
                                         xccolect,
                                         xcactivi,
                                         xcgarant,
                                         'GENVENTA',
                                         lcvalpar);

                  IF error <> 0
                  THEN
                     RETURN error;
                  ELSE
                     IF NVL(lcvalpar, 1) = 1
                     THEN
                        error := f_insdetrec(pnrecibo,
                                             15,
                                             importecomisae, -- jrh pnimport,
                                             0,
                                             NVL(pcgarant, 282),
                                             NVL(pnriesgo, 1),
                                             0,
                                             NULL,
                                             1,
                                             0,
                                             0,
                                             1,
                                             NULL,
                                             NULL,
                                             NULL,
                                             decimals);

                        IF error <> 0
                        THEN
                           RETURN error;
                        END IF;
                     END IF;
                  END IF;
                  /*IF NVL(reten_agente, 0) <> 0 THEN
                     xnimpret := f_round(((pnimport * comis_agente) / 100), decimals);
                     error := f_insdetrec(pnrecibo, 12, xnimpret, 0, NVL(pcgarant, 282),
                                          NVL(pnriesgo, 1), 0,null,1,0,0,1,null,null,NULL, Decimals);

                         --xcageven_gar, --JRH 9011
                      --xnmovima_gar,
                      --comis_agente,
                      --psseguro
                     --);
                     IF error <> 0 THEN
                        RETURN error;
                     END IF;
                  END IF;
                  */
               END IF;
            ELSE
               vpas := 650;
               --JRH IMP  Ponemos impuestos en la extarordinaria
               xpprorata := 1;
               error     := f_imprecibos(pnproces,
                                         pnrecibo,
                                         ptipomovimiento,
                                         pmodo,
                                         NVL(pnriesgo, 1),
                                         xpdtoord,
                                         xcrecfra,
                                         xcforpag,
                                         xcramo,
                                         xcmodali,
                                         xctipseg,
                                         xccolect,
                                         xcactivi,
                                         comis_agente,
                                         reten_agente,
                                         psseguro,
                                         pcmodcom,
                                         decimals,
                                         xpprorata,
                                         pttabla,
                                         pfuncion);

               IF error <> 0
               THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              'IMPRECIBOS',
                              NULL,
                              'error al insertar en impuestos.',
                              error || ' ( sseguro =' || psseguro || '  )');
                  RETURN error;
               END IF;
               --
            END IF; -- fin tipo movimiento = 10

            vpas := 660;

            -- Fin Comisión
            IF pnimport < 0
            THEN
               IF xctiprec <> 10
               THEN
                  -- No és un extorn d' anul.lació
                  BEGIN
                     lpermerita := NVL(f_parinstalacion_n('PERMERITA'), 0);

                     -- xex_pte_imp = 1 (Extorn pendent d'imprimir)
                     -- xex_pte_imp = 0 (Extorn pendent de transferir)
                     UPDATE recibos
                        SET ctiprec = 9, -- Si la prima és negativa,
                            cestimp = DECODE(cestimp,
                                             4,
                                             DECODE(xex_pte_imp, 0, 7, 1),
                                             cestimp),
                            nperven = DECODE(lpermerita,
                                             0,
                                             nperven,
                                             1,
                                             TO_CHAR(femisio, 'yyyymm'))
                      WHERE nrecibo = pnrecibo; -- es tracta d' un extorn
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    102358);
                        RETURN 102358; -- Error al modificar la taula RECIBOS
                  END;

                  vpas := 670;

                  -- BUG: 12961 AVT 22-02-2010 s'ajusta pels rebuts d'extorn
                  FOR reg IN (SELECT cgarant,
                                     SUM(iconcep) iconcep
                                FROM detrecibos
                               WHERE nrecibo = pnrecibo
                               GROUP BY cgarant)
                  LOOP
                     IF reg.iconcep = 0
                     THEN
                        BEGIN
                           DELETE detrecibos
                            WHERE nrecibo = pnrecibo
                              AND cgarant = reg.cgarant;
                        EXCEPTION
                           WHEN NO_DATA_FOUND THEN
                              NULL;
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate,
                                          f_user,
                                          vobj,
                                          vpas,
                                          vpar,
                                          'SQLCODE = ' || SQLCODE || ' - ' ||
                                          'SQLERRM = ' || SQLERRM ||
                                          'error = ' || 104377);
                              RETURN 104377;
                        END;
                     END IF;
                  END LOOP;
                  -- BUG: 12961 FI
               END IF;

               error := f_extornpos(pnrecibo,
                                    pmodo,
                                    pnproces,
                                    ptipomovimiento);

               IF error <> 0
               THEN
                  RETURN error;
               END IF;
            END IF;

            vpas  := 680;
            error := f_vdetrecibos(pmodo, pnrecibo, pnproces);

            -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
            IF error <> 0
            THEN
               RETURN error;
            END IF;

            error := f_recalcula_vdetrecibos(pmodo);

            -- fin Bug 27057/0145439 - APD - 05/06/2013
            IF error = 0
            THEN
               error := pac_cesionesrea.f_cessio_det(pnproces,
                                                     psseguro,
                                                     pnrecibo,
                                                     xcactivi,
                                                     xcramo,
                                                     xcmodali,
                                                     xctipseg,
                                                     xccolect,
                                                     pfefecto,
                                                     pfvencim,
                                                     1,
                                                     decimals);
            END IF;

            RETURN error;
         EXCEPTION
            WHEN dup_val_on_index THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 102311);
               RETURN 102311; -- registre duplicat en DETRECIBOS
            WHEN OTHERS THEN
               ROLLBACK;
               w_error := SQLERRM;
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || w_error);
               RETURN SQLCODE; -- Error a l' inserir a DETRECIBOS
         END;
      ELSE
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 101901);
         RETURN 101901; -- Pas incorrecte de paràmetres a la funció
      END IF;
   ELSE
      vpas := 700;

      -- Estem en el cas de proves ('P') o real ('R') o recibo anual impresión ('N') o
      -- recibo sobre intereses ('I'), Rehabilitacio ('H'), 'Diferencia provisión ('PM')
      -- Comprobem si existeix l' assegurança entrada com a paràmetre
      IF pmodo = 'N'
      THEN
         -- Estem en el cas de rebut previ (anual)
         xcforpag := 1;
      END IF;

      IF pfuncion = 'CAR'
      THEN
         -- BUG 34462 - AFM INI
         IF pmovorigen IS NULL
         THEN
            error := f_buscanmovimi(psseguro, 1, 1, xnmovimiant);
         ELSE
            xnmovimiant := pmovorigen;
         END IF;
         -- BUG 34462 - AFM FIN
      ELSE
         xnmovimiant := 1;
      END IF;

      IF error <> 0
      THEN
         RETURN error;
      END IF;

      IF xccalcom IN (1, 4)
      THEN
         -- Sobre prima
         NULL;
         -- Se comenta la llamada a f_pcomisi ya que el calculo de la comisión se realiza dentro de f_imprecibos
         /*
                  error :=
                     f_pcomisi (psseguro,
                                pcmodcom,
                                F_SYSDATE,
                                comis_agente,
                                reten_agente,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                NULL,
                                pttabla,
                                pfuncion
                               );

                  IF error <> 0
                  THEN
                     RETURN error;
                  END IF;
         */
      ELSIF xccalcom = 2
      THEN
         -- Sobre interés
         comis_agente := 0;
         reten_agente := 0;
         comis_cia    := 0;
      ELSIF xccalcom = 3
      THEN
         -- Sobre prov. mat.
         comis_agente := 0;
         reten_agente := 0;
         comis_cia    := 0;
      END IF;

      vpas := 710;

      IF pnmovimi IS NOT NULL AND
         pfuncion = 'CAR'
      THEN
         BEGIN
            SELECT cmotmov
              INTO xcmotmov
              FROM movseguro
             WHERE sseguro = psseguro
               AND nmovimi = pnmovimi;

            IF xcmotmov = 243
            THEN
               xaltarisc := TRUE;
            ELSE
               xaltarisc := FALSE;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 104348; -- Num. moviment no trobat a MOVSEGURO
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 104349);
               RETURN 104349; -- Error al llegir de MOVSEGURO
         END;
      END IF;

      IF ptipomovimiento = 6
      THEN
         -- Estem en el cas de rebut de regularització
         xcforpag := 0; -- Calcularem com a forma de pagament única

         -- Si no es una regularització de tickets
         IF xcmotmov NOT IN (602, 604)
         THEN
            -- o de capital eventual
            xcduraci := 3; -- Aplicarem reducció per assegurança de temporada
         ELSIF xcmotmov = 604
         THEN
            xcapieve := 1; -- Es de capital eventual
         END IF;
      END IF;

      /******** Cálculo de los factores a aplicar para el prorrateo ********/
      xffinrec := pfvencim;
      xffinany := pfcaranu;

      --Inicio CJMR
      --busca sseguro de la póliza 0
      SELECT sseguro
        INTO vsseguro
        FROM seguros
       WHERE npoliza = xnpoliza
         AND ncertif = 0;

      BEGIN
         SELECT p.crespue
           INTO v_preg4313
           FROM pregunpolseg p
          WHERE p.sseguro = vsseguro
            AND p.cpregun = 4313
            AND p.nmovimi = (SELECT MAX(nmovimi)
                               FROM pregunpolseg p2
                              WHERE p2.sseguro = p.sseguro
                                AND p2.cpregun = p.cpregun);
      EXCEPTION
         WHEN OTHERS THEN
            v_preg4313 := 0;
      END;

      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         f_efecto_apgp := TO_DATE(frenovacion(NULL, vsseguro, 2),
                                  'yyyymmdd');
      END IF;

      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         fanyoprox := add_months(f_efecto_apgp, 12);
      ELSE
         fanyoprox := add_months(pfefecto, 12);
      END IF;

      --Fin CJMR

      -- Para calcular el divisor del modulo 365 (365 o 366)
      IF xcforpag <> 0
      THEN
         IF xffinany IS NULL
         THEN
            IF xndurcob IS NULL
            THEN
               RETURN 104515;
               -- El camp ndurcob de SEGUROS ha de estar informat
            END IF;

            xnmeses := (xndurcob + 1) * 12;

            --CJM
            IF ptipomovimiento IN (0, 1) AND
               v_preg4313 = 1
            THEN
               xffinany := add_months(f_efecto_apgp, xnmeses);
            ELSE
               xffinany := add_months(pfefecto, xnmeses);
            END IF;

            IF xffinrec IS NULL
            THEN
               xffinrec := xffinany;
            END IF;
         END IF;
      ELSE
         xffinany := xffinrec;
      END IF;

      -- Cálculo de días
      IF xcprorra = 2
      THEN
         -- Mod. 360
         xcmodulo := 3;
      ELSE
         -- Mod. 365
         xcmodulo := 1;
      END IF;

      --CJM
      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         error := f_difdata(f_efecto_apgp, xffinrec, 3, 3, difdias);
      ELSE
         error := f_difdata(pfefecto, xffinrec, 3, 3, difdias);
      END IF;

      IF error <> 0
      THEN
         RETURN error;
      END IF;

      --CJM
      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         error := f_difdata(f_efecto_apgp, xffinany, 3, 3, difdiasanu);
      ELSE
         error := f_difdata(pfefecto, xffinany, 3, 3, difdiasanu);
      END IF;

      IF error <> 0
      THEN
         IF NVL(pac_parametros.f_parempresa_n(xcempres, 'VAL_FEC_CONT_EXT'),
                0) = 1
         THEN
            difdiasanu := NULL;
         ELSE
            RETURN error;
         END IF;
      END IF;

      --CJM
      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         error := f_difdata(f_efecto_apgp, xffinrec, xcmodulo, 3, difdias2);
      ELSE
         error := f_difdata(pfefecto, xffinrec, xcmodulo, 3, difdias2);
      END IF;

      -- dias recibo
      IF error <> 0
      THEN
         RETURN error;
      END IF;

      --CJM
      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         error := f_difdata(f_efecto_apgp,
                            xffinany,
                            xcmodulo,
                            3,
                            difdiasanu2);
      ELSE
         error := f_difdata(pfefecto, xffinany, xcmodulo, 3, difdiasanu2);
      END IF;

      -- dias venta
      IF error <> 0
      THEN
         IF NVL(pac_parametros.f_parempresa_n(xcempres, 'VAL_FEC_CONT_EXT'),
                0) = 1
         THEN
            difdiasanu2 := NULL;
         ELSE
            RETURN error;
         END IF;
      END IF;

      error := f_difdata(pfefecto, fanyoprox, xcmodulo, 3, divisor2);

      -- divisor del módulo de suplementos para pagos anuales
      IF error <> 0
      THEN
         RETURN error;
      END IF;

      --CJM
      IF ptipomovimiento IN (0, 1) AND
         v_preg4313 = 1
      THEN
         IF xcmodulo = 3 AND
            to_number(TO_CHAR(f_efecto_apgp, 'DD')) = 30 AND
            to_number(TO_CHAR(xffinrec, 'DD')) = 31
         THEN
            error := f_difdata(f_efecto_apgp, xffinrec, 1, 3, divisor);
         ELSE
            error := f_difdata(f_efecto_apgp,
                               xffinrec,
                               xcmodulo,
                               3,
                               divisor);
         END IF;
      ELSE
         IF xcmodulo = 3 AND
            to_number(TO_CHAR(xfefepol, 'DD')) = 30 AND
            to_number(TO_CHAR(xffinrec, 'DD')) = 31
         THEN
            error := f_difdata(xfefepol, xffinrec, 1, 3, divisor);
         ELSE
            error := f_difdata(xfefepol, xffinrec, xcmodulo, 3, divisor);
         END IF;
      END IF;

      -- divisor del periodo para pago único
      IF error <> 0
      THEN
         RETURN error;
      END IF;

      vpas := 710;

      -- Calculem els factors a aplicar per prorratejar
      -- També el factor per la reassegurança = diesrebut/dies cessio
      IF xcprorra IN (1, 2)
      THEN
         -- Per dies
         IF xcforpag <> 0
           --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
            OR
            NVL(f_parproductos_v(xsproduc, 'PRORR_PRIMA_UNICA'), 0) = 1
         THEN
            -- El càlcul del factor a la nova producció si s'ha de prorratejar, es fará modul 360 o
            -- mòdul 365 segon un paràmetre d'instal.lació
            xpro_np_360 := f_parinstalacion_n('PRO_NP_360');

            IF NVL(xpro_np_360, 1) = 1
            THEN
               facnet := difdias / 360;
               facdev := difdiasanu / 360;
            ELSE
               IF MOD(difdias, 30) = 0
                 -- Ini Bug 26923 --ECP-- 30/05/2013
                  AND
                  xcforpag <> 1
               -- Fin Bug 26923 --ECP-- 30/05/2013
               THEN
                  -- No hi ha prorrata
                  facnet := difdias / 360;
                  facdev := difdiasanu / 360;

                  IF difdiasanu = 0
                  THEN
                     difdiasanu := 360;
                  END IF;
                  --facces      :=  difdias / difdiasanu;
               ELSE
                  -- Hi ha prorrata, prorratejem mòdul 365
                  facnet := difdias2 / divisor2;
                  facdev := difdiasanu2 / divisor2;
               END IF;
            END IF;

            facnetsup := difdias2 / divisor2;
            facdevsup := difdiasanu2 / divisor2;
         ELSE
            facnet    := 1;
            facdev    := 1;
            facnetsup := difdias2 / divisor;
            facdevsup := difdiasanu2 / divisor;
         END IF;
      ELSIF xcprorra = 3
      THEN
         BEGIN
            IF ptipomovimiento IN (0, 1) AND
               v_preg4313 = 1
            THEN
               SELECT f1.npercen / 100
                 INTO facnet
                 FROM federaprimas f1
                WHERE f1.npoliza = xnpoliza
                  AND f1.diames =
                      (SELECT MAX(f2.diames)
                         FROM federaprimas f2
                        WHERE f1.npoliza = f2.npoliza
                          AND f2.diames <= TO_CHAR(f_efecto_apgp, 'mm/dd'));
            ELSE
               SELECT f1.npercen / 100
                 INTO facnet
                 FROM federaprimas f1
                WHERE f1.npoliza = xnpoliza
                  AND f1.diames =
                      (SELECT MAX(f2.diames)
                         FROM federaprimas f2
                        WHERE f1.npoliza = f2.npoliza
                          AND f2.diames <= TO_CHAR(pfefecto, 'mm/dd'));
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 109086);
               RETURN 109086;
               -- Porcentajes de prorrateo no dados de alta para la póliza
         END;

         IF xcforpag <> 0
         THEN
            RETURN 109087;
            -- Tipo de prorrateo incompatible con la forma de pago
         ELSE
            facdev    := facnet;
            facnetsup := facnet;
            facdevsup := facnet;
         END IF;
      ELSE
         RETURN 109085; -- Codi de prorrateig inexistent
      END IF;

      IF NVL(f_parinstalacion_n('PRO_SP_360'), 0) = 1
      THEN
         facnetsup := facnet;
         facdevsup := facdev;
      END IF;

      -- nunu Factor de prorrateig de reassegurança
      IF ptipomovimiento IN (0, 6, 21, 22)
      THEN
         facces := facnet;
      ELSE
         facces := facnetsup;
      END IF;

      -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
      IF ptipomovimiento = 11
      THEN
         vfacnetsupnoprov := facnetsup;
         vfacdevsupnoprov := facdevsup; --Nos  guardamos el antiguo valor los prorrateos para las garantías que no van por dif. de provisión
         facnetsup        := 1;
         facdevsup        := 1;
      END IF;

      vpas := 720;

      -- Fi BUG 20163-  12/2011 - JRH
      IF ptipomovimiento = 6
      THEN
         --JRH 0272015 Convenios. La regularización a priori no ha de prorratear la prima.
         facnet := 1;
         facdev := 1;
      END IF;

      -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim RRIE)
      IF pmodo = 'R' OR
         pmodo = 'I' OR
         pmodo = 'H' OR
         pmodo = 'RRIE'
      THEN
         BEGIN
            SELECT ctiprec,
                   cestaux
              INTO xctiprec,
                   xcestaux
              FROM recibos
             WHERE nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 101902; -- Rebut no trobat a RECIBOS
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 102367);
               RETURN 102367; -- Error al llegir de RECIBOS
         END;
      ELSE
         BEGIN
            SELECT ctiprec,
                   cestaux
              INTO xctiprec,
                   xcestaux
              FROM reciboscar
             WHERE sproces = pnproces
               AND nrecibo = pnrecibo;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETURN 105304; -- Rebut no trobat a RECIBOSCAR
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 105305);
               RETURN 105305; -- Error al llegir de RECIBOSCAR
         END;
      END IF;

      vpas := 730;

      -- Buscamos el porcentaje local si es un coaseguro.
      IF xctipcoa != 0
      THEN
         BEGIN
            SELECT ploccoa
              INTO xploccoa
              FROM coacuadro
             WHERE ncuacoa = xncuacoa
               AND sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 105447);
               RETURN 105447;
         END;
      END IF;

      --****************************************************************
      --******************   M O D O    R E A L  ***********************
      --******************   MODO REHABILITACION ***********************
      --****************************************************************
      vpas := 740;

      -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim 'RRIE')
      IF pmodo = 'R' OR
         pmodo = 'H' OR
         pmodo = 'RRIE'
      THEN
         -- MODE REAL (Producció, Cartera i Rehabilitacio)
         OPEN cur_garanseg;

         FETCH cur_garanseg
            INTO xcgarant,
                 xnriesgo,
                 xfiniefe,
                 xnorden,
                 xctarifa,
                 xicapital,
                 xprecarg,
                 xiprianu,
                 xfinefe,
                 xcformul,
                 xiextrap,
                 xctipfra,
                 xifranqu,
                 xnmovimi,
                 xidtocom,
                 xcageven_gar,
                 xnmovima_gar,
                 xcampanya,
                 xpdtocom,
                 xitarrea, -- BUG: 12993 AVT 09-02-2010
                 xccobprima; -- BUG 41143/229973 - 17/03/2016 - JAEG
         WHILE cur_garanseg%FOUND
         LOOP
            w_pargaranpro := f_pargaranpro_v(xcramo,
                                             xcmodali,
                                             xctipseg,
                                             xccolect,
                                             xcactivi,
                                             xcgarant,
                                             'TIPO');
            xnasegur      := NULL;
            xnasegur1     := NULL;
            xidtocom      := 0 - NVL(xidtocom, 0);

            -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
            IF ptipomovimiento = 11
            THEN
               vnorec        := FALSE;
               v_sup_pm_prod := NVL(f_parproductos_v(xsproduc, 'REC_SUP_PM'),
                                    1);
               v_sup_pm_gar  := NVL(f_pargaranpro_v(xcramo,
                                                    xcmodali,
                                                    xctipseg,
                                                    xccolect,
                                                    xcactivi,
                                                    xcgarant,
                                                    'REC_SUP_PM_GAR'),
                                    1);

               IF v_sup_pm_gar = 1
               THEN
                  vdifprovision := TRUE;
                  facnetsup     := 1;
                  facdevsup     := 1;
               ELSIF v_sup_pm_gar = 2
               THEN
                  error := pac_preguntas.f_get_pregungaranseg(psseguro,
                                                              xcgarant,
                                                              NVL(pnriesgo,
                                                                  1),
                                                              4045,
                                                              'SEG',
                                                              vcrespue);

                  IF error NOT IN (0, 120135)
                  THEN
                     RETURN 110420;
                  END IF;

                  IF NVL(vcrespue, 0) = 1
                  THEN
                     vdifprovision := TRUE;
                     facnetsup     := 1;
                     facdevsup     := 1;
                  ELSE
                     IF v_sup_pm_prod = 4
                     THEN
                        -- Vamos a forzarlo
                        vdifprovision := TRUE;
                        vnorec        := TRUE;
                        facnetsup     := 1;
                        facdevsup     := 1;
                     ELSE
                        vdifprovision := FALSE;
                        facnetsup     := vfacnetsupnoprov;
                        facdevsup     := vfacdevsupnoprov;
                     END IF;
                  END IF;
               ELSE
                  IF v_sup_pm_prod = 4
                  THEN
                     -- Vamos a forzarlo
                     vdifprovision := TRUE;
                     vnorec        := TRUE;
                     facnetsup     := 1;
                     facdevsup     := 1;
                  ELSE
                     vdifprovision := FALSE;
                     facnetsup     := vfacnetsupnoprov;
                     facdevsup     := vfacdevsupnoprov;
                  END IF;
               END IF;
            ELSE
               vdifprovision := FALSE; --APlica diferencia de provisión false si el tipo mov<>11 (ya tiene el los factoes correctos)
            END IF;

            IF ptipomovimiento = 11 AND
               vdifprovision
            THEN
               IF vnorec
               THEN
                  xprovmat := 0;
               ELSE
                  -- Calculamos la prima comercial a esta fecha a traves de la reserva
                  -- matemática
                  --Buscamos la provisión actual
                  xprovmat := f_calculo_prov(xcramo,
                                             xcmodali,
                                             xccolect,
                                             xctipseg,
                                             xcactivi,
                                             xcgarant,
                                             pfefecto,
                                             xsproduc,
                                             xnriesgo,
                                             psseguro,
                                             xnmovimi,
                                             error);

                  IF error <> 0
                  THEN
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Sin Gastos los aplicamos después
               prima_comercial := NVL(xprovmat, 0) / (1 - (0 / 100));
               xidtocom        := 0; --Sin descuentos
               -- Fi BUG 20672-  01/2012 - JRH
               xiprianu := prima_comercial;
            END IF;

            -- Fi BUG 20163-  12/2011 - JRH
            vpas := 760;

            -- comprobem si hi ha més d'un registre pel mateix cgarant-nriesgo-
            -- nmovimi-finiefe
            BEGIN
               SELECT DECODE(nasegur, NULL, 1, nasegur),
                      nmovima
                 INTO xnasegur,
                      xnmovima
                 FROM riesgos
                WHERE sseguro = psseguro
                  AND nriesgo = xnriesgo;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  CLOSE cur_garanseg;

                  RETURN 103836;
               WHEN OTHERS THEN
                  CLOSE cur_garanseg;

                  p_tab_error(f_sysdate,
                              f_user,
                              vobj,
                              vpas,
                              vpar,
                              'SQLCODE = ' || SQLCODE || ' - ' ||
                              'SQLERRM = ' || SQLERRM || 'error = ' ||
                              103509);
                  RETURN 103509;
            END;

            -- *******************************************************************************
            -- Fase 1: Càlcul de la Prima Neta (cconcep = 0) y de la Prima Devengada (Fase 2).
            -- *******************************************************************************
            -- ********** Conceptos extraordinarios ***********
            IF sw_cextr = 1
            THEN
               error := fl_inbucle_extrarec(pnrecibo,
                                            pfemisio,
                                            psseguro,
                                            xcgarant,
                                            xploccoa,
                                            xctipcoa,
                                            xcageven_gar,
                                            xnmovima_gar,
                                            pnproces,
                                            xnriesgo,
                                            w_nmeses_cexter,
                                            ha_grabado);

               IF ha_grabado = 1
               THEN
                  ha_grabat := TRUE;
               END IF;

               IF error <> 0
               THEN
                  CLOSE cur_garanseg;

                  RETURN error;
               END IF;
            END IF;

            IF ptipomovimiento IN (0, 6, 21, 22)
            THEN
               -- ********** Prima Neta ***********
               xiprianu2 := f_round(xiprianu * facnet * xnasegur, decimals);

               -- En PP y PPA comprobamos en carrtera y renovación que no sobrepasamos el limite de aportaciones.
               IF ptipomovimiento IN (21, 22) AND
                  w_pargaranpro = 3
                 --{si el tipo de garantía es prima ahorro }-xcgarant = 48
                  AND
                  NVL(xiprianu2, 0) > 0
               THEN
                  DECLARE
                     persona    NUMBER;
                     agrupacion NUMBER;
                     pendiente  NUMBER;
                     minimo     NUMBER;
                     partes     NUMBER;
                     traspasos  NUMBER;
                  BEGIN
                     SELECT COUNT(1)
                       INTO partes
                       FROM prestaplan
                      WHERE sseguro = psseguro;

                     IF partes = 0
                     THEN
                        --> Parte de prestaciones
                        -- Bug 17382 - APD - 28/01/2011 - Antes se miraba si en PP y Ahorro tienen mas de 1
                        -- recibo pendiente no genera cartera, pero se ha eliminado esta validacion
                        -- Añadimos 'TIPO_LIMITE' (Cúmulos PIAS)
                        IF NVL(f_parproductos_v(xsproduc, 'APORTMAXIMAS'),
                               0) = 1 OR
                           NVL(f_parproductos_v(xsproduc, 'TIPO_LIMITE'), 0) <> 0
                        THEN
                           -- Bug 10053 - APD - 08/05/2009 - se sustituye la funcion f_maxapor_pp por
                           -- pac_ppa_planes.ff_importe_por_aportar_persona
                           SELECT cagrpro,
                                  riesgos.sperson,
                                  garanpro.iprimin,
                                  DECODE(NVL(f_parproductos_v(xsproduc,
                                                              'APORTMAXIMAS'),
                                             0),
                                         1,
                                         pac_ppa_planes.ff_importe_por_aportar_persona(to_number(TO_CHAR(pfefecto,
                                                                                                         'yyyy')),
                                                                                       psseguro,
                                                                                       riesgos.nriesgo,
                                                                                       riesgos.sperson),
                                         --                                           f_maxapor_pp(riesgos.sperson,
                                         --                                                         TO_NUMBER(TO_CHAR(pfefecto, 'yyyy')),
                                         --                                                         psseguro),
                                         pac_limites_ahorro.ff_importe_por_aportar_persona(to_number(TO_CHAR(pfefecto,
                                                                                                             'yyyy')),
                                                                                           f_parproductos_v(xsproduc,
                                                                                                            'TIPO_LIMITE'),
                                                                                           riesgos.sperson,
                                                                                           pfefecto))
                             INTO agrupacion,
                                  persona,
                                  minimo,
                                  pendiente
                             FROM seguros,
                                  riesgos,
                                  garanpro
                            WHERE seguros.sseguro = riesgos.sseguro
                              AND riesgos.fanulac IS NULL
                              AND garanpro.sproduc = seguros.sproduc
                              AND NVL(f_pargaranpro_v(seguros.cramo,
                                                      seguros.cmodali,
                                                      seguros.ctipseg,
                                                      seguros.ccolect,
                                                      seguros.cactivi,
                                                      garanpro.cgarant,
                                                      'TIPO'),
                                      0) = 3
                                 --AND garanpro.cgarant = 48
                              AND seguros.sseguro = psseguro;

                           -- Bug 10053 - APD - 08/05/2009 - Fin

                           --IF PENDIENTE > 0 AND PENDIENTE < MINIMO THEN
                           --  XIPRIANU2 := 0;
                           -- XIPRIANU := 0;
                           IF pendiente <= 0
                           THEN
                              xiprianu2 := 0;
                              xiprianu  := 0;
                           ELSIF pendiente > 0 AND
                                 xiprianu2 > pendiente
                           THEN
                              --AND PENDIENTE >MINIMO
                              xiprianu2 := pendiente;
                              xiprianu  := pendiente;
                           END IF;
                        END IF;

                        -- Bug 17382 - APD - 28/01/2011 - fin
                        -- Si tiene TDC Salida Confirmados Totales no generamos el recibo ya que
                        -- estos traspasos anularán la póliza
                        SELECT COUNT(*)
                          INTO traspasos
                          FROM trasplainout
                         WHERE cinout = 2
                           AND cestado = 2
                           AND ctiptras = 1
                           AND sseguro = psseguro;

                        IF traspasos > 0
                        THEN
                           xiprianu2 := 0;
                           xiprianu  := 0;
                        END IF;
                     ELSE
                        --> tIENE PARTE DE PRESTACIONES
                        xiprianu2 := 0;
                        xiprianu  := 0;
                     END IF; -- PArte de prstaciones
                  END;
               END IF;

               -- Copiamos la prima para el dtos de campanya
               xpprorata := facnet;

               -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  --IF pctipapo = 1 THEN
                  --   xiprianu2 :=
                  --          f_round (xiprianu2 * ppimpapo / 100, decimals);
                  --ELSIF pctipapo = 2 THEN
                  --   xiprianu2 :=
                  --        f_round (piimpapo * facnet * xnasegur, decimals);
                  --END IF;

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 * vapor.pimport / 100,
                                                decimals);
                           -- Bug 13397 - RSC - 26/02/2010 - CRE201 - Error cartera PIAM Colectivo (257)
                           xitarrea := f_round(xitarrea * vapor.pimport / 100,
                                               decimals);
                           -- Fin Bug 13397
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xiprianu2 := least(xiprianu2, vapor.iimport);
                           -- Bug 13397 - RSC - 26/02/2010 - CRE201 - Error cartera PIAM Colectivo (257)
                           xitarrea := least(xitarrea, vapor.iimport);
                           -- Fin Bug 13397
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                           -- Bug 13397 - RSC - 26/02/2010 - CRE201 - Error cartera PIAM Colectivo (257)
                           xitarrea := f_round(xitarrea *
                                               (1 - (vapor.pimport / 100)),
                                               decimals);
                           -- Fin Bug 13397
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xiprianu2 := greatest(0,
                                                 xiprianu2 - vapor.iimport);
                           -- Bug 13397 - RSC - 26/02/2010 - CRE201 - Error cartera PIAM Colectivo (257)
                           xitarrea := greatest(0, xitarrea - vapor.iimport);
                           -- Fin Bug 13397
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xiprianu2 := 0;
                  --END IF;
               END IF;

               -- BUG: 12993 AVT 09-02-2010
               -- Bug 21812 - RSC - 23/03/2012 - Afegim parametre REASEGURO
               IF NVL(xiprianu2, 0) <> 0 OR
                  (NVL(xitarrea, 0) <> 0 AND
                   NVL(f_parproductos_v(xsproduc, 'REASEGURO'), 0) = 1)
               THEN
                  error := f_insdetrec(pnrecibo,
                                       0,
                                       xiprianu2,
                                       xploccoa,
                                       xcgarant,
                                       xnriesgo,
                                       xctipcoa,
                                       xcageven_gar,
                                       xnmovima_gar,
                                       0,
                                       0,
                                       1,
                                       NULL,
                                       NULL,
                                       NULL,
                                       decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;

                     IF sw_aln = 1
                     THEN
                        w_importe_aux := f_round(xiprianu * xnasegur,
                                                 decimals);
                        error         := fl_grabar_calcomisprev(psseguro,
                                                                pnrecibo,
                                                                xcgarant,
                                                                xnriesgo,
                                                                xcageven_gar,
                                                                xnmovima_gar,
                                                                w_importe_aux,
                                                                pfefecto,
                                                                pfvencim,
                                                                pmodo,
                                                                pnproces);

                        IF error <> 0
                        THEN
                           CLOSE cur_garanseg;

                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               --  ******* Descuento comercial *******
               xidtocom2 := f_round(xidtocom * facnet * xnasegur, decimals);

               -- Si te ctipreb = 4 (per aportant) l'import s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3
                  --THEN
                  /*
                  IF pctipapo = 1
                  THEN
                     xidtocom2 :=
                            f_round (xidtocom2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2
                  THEN
                     -- hen de calcular el descompte per l'import fixe xiprianu2
                     xidtocom2 :=
                        f_round (  f_round ((xiprianu2 * xpdtocom) / 100,
                                            decimals
                                           )
                                 * facnet
                                 * xnasegur,
                                 decimals
                                );
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals); -- Se porratea el importe de descuento

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := least((xidtocom2 * vapor.iimport) /
                                                 xiprianu2,
                                                 vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals);

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := greatest(0,
                                                    ((xidtocom2 *
                                                    vapor.iimport) /
                                                    xiprianu2) -
                                                    vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xidtocom2 := 0;
                  --END IF;
               END IF;

               IF xidtocom2 <> 0 AND
                  xidtocom2 IS NOT NULL
               THEN
                  error := f_insdetrec(pnrecibo,
                                       10,
                                       xidtocom2,
                                       xploccoa,
                                       xcgarant,
                                       xnriesgo,
                                       xctipcoa,
                                       xcageven_gar,
                                       xnmovima_gar,
                                       0,
                                       0,
                                       1,
                                       NULL,
                                       NULL,
                                       NULL,
                                       decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;
                  ELSE
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               -- ******** Prima Devengada **********
               IF ptipomovimiento IN (0, 2, 6, 21)
               THEN
                  xiprianu2 := f_round(xiprianu * facdev * xnasegur,
                                       decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-o->'||facdevsup||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3
                     --THEN
                     /*
                     IF pctipapo = 1
                     THEN
                        xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2
                     THEN
                        xiprianu2 :=
                           f_round (piimpapo * facdev * xnasegur,
                                    decimals);
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 *
                                                   vapor.pimport / 100,
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := least(xiprianu2, vapor.iimport);
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 * (1 -
                                                   (vapor.pimport / 100)),
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := greatest(0,
                                                    xiprianu2 -
                                                    vapor.iimport);
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiprianu2 := 0;
                     --END IF;
                  END IF;

                  IF NVL(xiprianu2, 0) <> 0
                  THEN
                     -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                     error := f_pargaranpro(xcramo,
                                            xcmodali,
                                            xctipseg,
                                            xccolect,
                                            xcactivi,
                                            xcgarant,
                                            'GENVENTA',
                                            lcvalpar);

                     IF error <> 0
                     THEN
                        RETURN error;
                     ELSE
                        IF NVL(lcvalpar, 1) = 1
                        THEN
                           -- La garantia genera venda
                           error := f_insdetrec(pnrecibo,
                                                21,
                                                xiprianu2,
                                                xploccoa,
                                                xcgarant,
                                                xnriesgo,
                                                xctipcoa,
                                                xcageven_gar,
                                                xnmovima_gar,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                           IF error = 0
                           THEN
                              ha_grabat := TRUE;
                           ELSE
                              CLOSE cur_garanseg;

                              RETURN error;
                           END IF;
                        END IF;
                     END IF;
                     ---------------
                  END IF;
               END IF;

               -- *******************************************************
               -- **************** Suplementos **************************
               -- *******************************************************
               vpas := 780;
            ELSIF ptipomovimiento IN (1, 11)
            THEN
               BEGIN
                  xxcgarant := NULL;
                  xxnriesgo := NULL;
                  xxfiniefe := NULL;
                  xxiprianu := NULL;
                  xxffinefe := NULL;
                  xxidtocom := NULL;
                  vexitegar := TRUE;

                  SELECT cgarant,
                         nriesgo,
                         finiefe,
                         ipritot,
                         ffinefe,
                         idtocom,
                         cageven,
                         nmovima,
                         ccampanya
                    INTO xxcgarant,
                         xxnriesgo,
                         xxfiniefe,
                         xxiprianu,
                         xxffinefe,
                         xxidtocom,
                         xxcageven_gar,
                         xxnmovima_gar,
                         xxcampanya
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = xnmovimiant
                     AND nmovima = xnmovima_gar;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL; -- No hi ha garantia anterior
                     vexitegar := FALSE;
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garanseg;

                     error := 102310; -- Garantia-Risc repetida en GARANSEG
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 error);
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     error := 103500; -- Error al llegir de GARANSEG
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 error);
                     RETURN error;
               END;

               -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
               IF ptipomovimiento = 11 AND
                  vdifprovision
               THEN
                  IF vexitegar
                  THEN
                     -- Calculamos la prima comercial a esta fecha a traves de la reserva
                     -- matemática
                     IF vnorec
                     THEN
                        xprovmat := 0;
                     ELSE
                        xprovmat := f_calculo_prov(xcramo,
                                                   xcmodali,
                                                   xccolect,
                                                   xctipseg,
                                                   xcactivi,
                                                   xcgarant,
                                                   pfefecto,
                                                   xsproduc,
                                                   xnriesgo,
                                                   psseguro,
                                                   xnmovimiant,
                                                   error);

                        IF error <> 0
                        THEN
                           CLOSE cur_garanseg;

                           RETURN error;
                        END IF;
                     END IF;

                     -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Sin Gastos los aplicamos después
                     prima_comercial := NVL(xprovmat, 0) / (1 - (0 / 100)); --xpgasext
                     xxidtocom       := 0; --Sin descuentos
                     -- Fi BUG 20672-  01/2012 - JRH
                     xxiprianu := prima_comercial;
                  ELSE
                     xxiprianu := 0;
                  END IF;
               END IF;

               -- Fi BUG 20163-  12/2011 - JRH
               xxidtocom := 0 - NVL(xxidtocom, 0);

               --INI BUG 41143/229973 - 17/03/2016 - JAEG
               IF NVL(f_parproductos_v(xsproduc, 'PRIMA_VIG_AMPARO'), 0) = 0
               THEN
                  IF xccobprima = 1
                  THEN
                     --
                     difiprianu := (xiprianu * xnasegur) -
                                   NVL(xxiprianu * xnasegur, 0);
                     --
                  ELSE
                     --
                     difiprianu := 0;
                     --
                  END IF;
               ELSE
                  IF xccobprima = 1
                  THEN
                     --
                     difiprianu := f_prima_vig_amparo(psseguro,
                                                      xcgarant,
                                                      pfefecto,
                                                      xnriesgo,
                                                      xnmovimiant,
                                                      xnmovimi,
                                                      xiprianu,
                                                      xxiprianu,
                                                      xnasegur,
                                                      error);
                    
                    --Ini IAXIS-3264 -- ECP --03/11/2019
                    if difiprianu = 101901 then
                    difiprianu:=0;
                    end if;
                    --Fin  IAXIS-3264 -- ECP --03/11/2019
  P_CONTROL_ERROR(vobj,'REA','difiprianu-prima vig->'||difiprianu||' NVL(f_parproductos_v(xsproduc, ''PRIMA_VIG_AMPARO''), 0) '||NVL(f_parproductos_v(xsproduc, 'PRIMA_VIG_AMPARO'), 0)||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR 
                        IF xcforpag <> 0 OR
                        NVL(f_parproductos_v(xsproduc, 'PRORR_PRIMA_UNICA'),
                            0) = 1
                     THEN
                        facnetsup := difdias2 / divisor2;
                     ELSE
                        facnetsup := 1;
                        facdevsup := 1;
                     END IF;
                  END IF;
               END IF;
               -- FIN BUG 41143/229973 - 17/03/2016 - JAEG
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup '||facdevsup||' crida a difiprianu owe = '||difiprianu||' tipo movimiento-->'||ptipomovimiento||'facnetsup-->'||facnetsup||'difdias2-->'||difdias2||'divisor2-->'||divisor2);--> BORRAR JGR
               -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Tratamos a nivel de garantíía
               IF ptipomovimiento = 11 AND
                  vdifprovision
               THEN
                  IF difiprianu > 0
                  THEN
                     difiprianu := difiprianu / (1 - (xpgasext / 100)); -- Si no és extorno
                     P_CONTROL_ERROR('f_detrecibo','REA',' crida a difiprianu o = '||difiprianu||' xpgasext-->'||xpgasext);--> BORRAR JGR
                  ELSE
                     -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
                     difiprianu := difiprianu * (1 - (xpgasext / 100)); -- Si és extorno le damos menos
                     -- Fi BUG 20666-  01/2012 - JRH
                     P_CONTROL_ERROR('f_detrecibo','REA',' crida a difiprianu else o = '||difiprianu||' xpgasext-->'||xpgasext);--> BORRAR JGR
                  END IF;
               END IF;

               -- Fi BUG 20672-  01/2012 - JRH
               difidtocom := NVL(xidtocom * xnasegur, 0) -
                             NVL(xxidtocom * xnasegur, 0);
               xinsert    := TRUE;
               --Calculamos la prima para dtos. de campanya
               --utilizamos el prorrateo de alta de garantía.
               xpprorata := facnetsup;

               IF xaltarisc
               THEN
                  IF xnmovima = pnmovimi
                  THEN
                     xinsert := TRUE;
                  ELSE
                     xinsert := FALSE;
                  END IF;
               END IF;

               --mirem si s'ha donat d'alta una campanya.
               IF f_parinstalacion_n('CAMPANYA') = 1
               THEN
                  IF NVL(xxcampanya, -2) <> NVL(xcampanya, -2)
                  THEN
                     v_tecamp := 1;
                  ELSE
                     v_tecamp := 0;
                  END IF;
               ELSE
                  v_tecamp := 0;
               END IF;

               -- si tiene campanya forzamos que entre y grabe en detrecibos.
               IF xinsert OR
                  v_tecamp = 1
               THEN
                  -- ******* Prima Neta ********
                  xiconcep := f_round(difiprianu * facnetsup, decimals);
P_CONTROL_ERROR('f_detrecibo','REA',' crida a difiprianu oce = '||difiprianu||' xiconcep-->'||xiconcep||'facnetsup-->'||facnetsup);--> BORRAR JGR
                  -- facnetsup ya aplica la forma de pago

                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3
                     --THEN
                     /*
                     IF pctipapo = 1 THEN
                        xiconcep :=
                             f_round (xiconcep * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        -- Apliquem la proporció del fixe sobre l'anual
                        xiconcep :=
                           f_round ((xiconcep * piimpapo / xiprianu),
                                    decimals
                                   );
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * vapor.pimport / 100,
                                                  decimals);
                              -- Bug 14473 - 07/06/2010 - RSC - CEM - Suplementos en productos con copago
                              xitarrea := f_round(xitarrea * vapor.pimport / 100,
                                                  decimals);
                              -- Fin Bug 14473
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := least(xiconcep, vapor.iimport);
                              -- Bug 14473 - 07/06/2010 - RSC - CEM - Suplementos en productos con copago
                              xitarrea := least(xitarrea, vapor.iimport);
                              -- Fin Bug 14473
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * (1 -
                                                  (vapor.pimport / 100)),
                                                  decimals);
                              -- Bug 14473 - 07/06/2010 - RSC - CEM - Suplementos en productos con copago
                              xitarrea := f_round(xitarrea * (1 -
                                                  (vapor.pimport / 100)),
                                                  decimals);
                              -- Fin Bug 14473
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := greatest(0,
                                                   xiconcep - vapor.iimport);
                              -- Bug 14473 - 07/06/2010 - RSC - CEM - Suplementos en productos con copago
                              xitarrea := greatest(0,
                                                   xitarrea - vapor.iimport);
                              -- Fin Bug 14473
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiconcep := 0;
                     --END IF;
                  END IF;

                  -- Bug 12993 AVT 09-02-2010
                  -- Bug 21812 - RSC - 23/03/2012 - Afegim Parametre REASEGURO
                  --
                  -- Inicio IAXIS-3980 01/08/2019                 
                  -- Si la respuesta a la pregunta de Gastos de Expedición es afirmativa, 
                  -- se obliga a insertar en la detrecibos el concepto y su IVA.
                  n_error := pac_preguntas.f_get_pregunseg(psseguro, NVL(pnriesgo, 1), 9800, NVL(pttabla, 'SEG'), vgastexpsup);
                  --
                  -- Fin IAXIS-3980 01/08/2019 
                  --
                  IF NVL(xiconcep, 0) <> 0 OR
                     (NVL(xitarrea, 0) <> 0 AND
                      NVL(f_parproductos_v(xsproduc, 'REASEGURO'), 0) = 1) OR
                     NVL(v_tecamp, 0) = 1 OR
                     NVL(vgastexpsup,0) = 1 -- IAXIS-3980 01/08/2019
                  THEN
                     error := f_insdetrec(pnrecibo,
                                          0,
                                          xiconcep,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                     IF error = 0
                     THEN
                        ha_grabat := TRUE;

                        IF sw_aln = 1
                        THEN
                           w_importe_aux := f_round(difiprianu, decimals);
                           error         := fl_grabar_calcomisprev(psseguro,
                                                                   pnrecibo,
                                                                   xcgarant,
                                                                   xnriesgo,
                                                                   xcageven_gar,
                                                                   xnmovima_gar,
                                                                   w_importe_aux,
                                                                   pfefecto,
                                                                   pfvencim,
                                                                   pmodo,
                                                                   pnproces);

                           IF error <> 0
                           THEN
                              CLOSE cur_garanseg;

                              RETURN error;
                           END IF;
                        END IF;
                     ELSE
                        CLOSE cur_garanseg;

                        RETURN error;
                     END IF;
                  END IF;

                  -- ******** Descuento comercial ******
                  xiconcep := f_round(difidtocom * facnetsup, decimals);

                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3 THEN
                     /*
                     IF pctipapo = 1 THEN
                        xiconcep :=
                             f_round (xiconcep * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        -- Apliquem la proporció del fixe sobre l'anual
                        xiconcep :=
                           f_round ((xiconcep * piimpapo / xiprianu),
                                    decimals
                                   );
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * vapor.pimport / 100,
                                                  decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := least(xiconcep, vapor.iimport);
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * (1 -
                                                  (vapor.pimport / 100)),
                                                  decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := greatest(0,
                                                   xiconcep - vapor.iimport);
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiconcep := 0;
                     --END IF;
                  END IF;

                  IF xiconcep <> 0 AND
                     xiconcep IS NOT NULL
                  THEN
                     error := f_insdetrec(pnrecibo,
                                          10,
                                          xiconcep,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                     IF error = 0
                     THEN
                        ha_grabat := TRUE;
                     ELSE
                        CLOSE cur_garanseg;

                        RETURN error;
                     END IF;
                  END IF;

                  -- ****** Prima Devengada ******
                  xiconcep := f_round(difiprianu * facdevsup, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-->'||facdevsup||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3 THEN
                     /*
                     IF pctipapo = 1 THEN
                        xiconcep :=
                             f_round (xiconcep * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        -- Apliquem la proporció del fixe sobre l'anual
                        xiconcep :=
                           f_round ((xiconcep * piimpapo / xiprianu),
                                    decimals
                                   );
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * vapor.pimport / 100,
                                                  decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := least(xiconcep, vapor.iimport);
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiconcep := f_round(xiconcep * (1 -
                                                  (vapor.pimport / 100)),
                                                  decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xiconcep := greatest(0,
                                                   xiconcep - vapor.iimport);
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiconcep := 0;
                     --END IF;
                  END IF;

                  IF NVL(xiconcep, 0) <> 0
                  THEN
                     -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                     error := f_pargaranpro(xcramo,
                                            xcmodali,
                                            xctipseg,
                                            xccolect,
                                            xcactivi,
                                            xcgarant,
                                            'GENVENTA',
                                            lcvalpar);

                     IF error <> 0
                     THEN
                        RETURN error;
                     ELSE
                        IF NVL(lcvalpar, 1) = 1
                        THEN
                           -- La garantia genera venda
                           error := f_insdetrec(pnrecibo,
                                                21,
                                                xiconcep,
                                                xploccoa,
                                                xcgarant,
                                                xnriesgo,
                                                xctipcoa,
                                                xcageven_gar,
                                                xnmovima_gar,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                           IF error = 0
                           THEN
                              ha_grabat := TRUE;
                           ELSE
                              CLOSE cur_garanseg;

                              RETURN error;
                           END IF;
                        END IF;
                     END IF;
                     ---------------
                  END IF;
               END IF; -- Fi del if del xinsert
            ELSIF ptipomovimiento = 100
            THEN
               NULL;
            ELSE
               CLOSE cur_garanseg;

               error := 101901; -- Paso incorrecto de parámetros a la función
               RETURN error;
            END IF;

            FETCH cur_garanseg
               INTO xcgarant,
                    xnriesgo,
                    xfiniefe,
                    xnorden,
                    xctarifa,
                    xicapital,
                    xprecarg,
                    xiprianu,
                    xfinefe,
                    xcformul,
                    xiextrap,
                    xctipfra,
                    xifranqu,
                    xnmovimi,
                    xidtocom,
                    xcageven_gar,
                    xnmovima_gar,
                    xcampanya,
                    xpdtocom,
                    xitarrea, -- BUG: 12993 AVT 09-02-2010
                    xccobprima; -- BUG 41143/229973 - 17/03/2016 - JAEG
         END LOOP;

         CLOSE cur_garanseg;

         -- ********************************************************************
         -- Ara buscarem les garanties que estaven en (fefecto-1) i ara no estan
         -- ********************************************************************
         IF ptipomovimiento IN (1, 11)
         THEN
            OPEN cur_garansegant;

            FETCH cur_garansegant
               INTO xcgarant,
                    xnriesgo,
                    xfiniefe,
                    xnorden,
                    xctarifa,
                    xicapital,
                    xprecarg,
                    xiprianu,
                    xfinefe,
                    xcformul,
                    xiextrap,
                    xctipfra,
                    xifranqu,
                    xnmovimi,
                    xidtocom,
                    xcageven_gar,
                    xnmovima_gar,
                    xcampanya,
                    xpdtocom,
                    xitarrea; -- BUG: 12993 AVT 09-02-2010

            WHILE cur_garansegant%FOUND
            LOOP
               xnasegur  := NULL;
               xnasegur1 := NULL;

               BEGIN
                  SELECT DECODE(nasegur, NULL, 1, nasegur)
                    INTO xnasegur1
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = xnriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garansegant;

                     RETURN 103836;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 103509);
                     RETURN 103509;
               END;

               xidtocom := 0 - NVL(xidtocom, 0);

               -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
               IF ptipomovimiento = 11
               THEN
                  vnorec        := FALSE;
                  v_sup_pm_prod := NVL(f_parproductos_v(xsproduc,
                                                        'REC_SUP_PM'),
                                       1);
                  v_sup_pm_gar  := NVL(f_pargaranpro_v(xcramo,
                                                       xcmodali,
                                                       xctipseg,
                                                       xccolect,
                                                       xcactivi,
                                                       xcgarant,
                                                       'REC_SUP_PM_GAR'),
                                       1);

                  IF v_sup_pm_gar = 1
                  THEN
                     vdifprovision := TRUE;
                     facnetsup     := 1;
                     facdevsup     := 1;
                  ELSIF v_sup_pm_gar = 2
                  THEN
                     error := pac_preguntas.f_get_pregungaranseg(psseguro,
                                                                 xcgarant,
                                                                 NVL(pnriesgo,
                                                                     1),
                                                                 4045,
                                                                 'SEG',
                                                                 vcrespue);

                     IF error NOT IN (0, 120135)
                     THEN
                        RETURN 110420;
                     END IF;

                     IF NVL(vcrespue, 0) = 1
                     THEN
                        vdifprovision := TRUE;
                        facnetsup     := 1;
                        facdevsup     := 1;
                     ELSE
                        IF v_sup_pm_prod = 4
                        THEN
                           -- Vamos a forzarlo
                           vdifprovision := TRUE;
                           vnorec        := TRUE;
                           facnetsup     := 1;
                           facdevsup     := 1;
                        ELSE
                           vdifprovision := FALSE;
                           facnetsup     := vfacnetsupnoprov;
                           facdevsup     := vfacdevsupnoprov;
                        END IF;
                     END IF;
                  ELSE
                     IF v_sup_pm_prod = 4
                     THEN
                        -- Vamos a forzarlo
                        vdifprovision := TRUE;
                        vnorec        := TRUE;
                        facnetsup     := 1;
                        facdevsup     := 1;
                     ELSE
                        vdifprovision := FALSE;
                        facnetsup     := vfacnetsupnoprov;
                        facdevsup     := vfacdevsupnoprov;
                     END IF;
                  END IF;
               ELSE
                  vdifprovision := FALSE; --APlica diferencia de provisión
               END IF;

               vpas := 790;

               -- i BUG 20163-  12/2011 - JRH
               BEGIN
                  grabar    := 0;
                  xxcgarant := NULL;
                  xxnriesgo := NULL;
                  xxfiniefe := NULL;
                  xxiprianu := NULL;
                  xxffinefe := NULL;
                  xxidtocom := NULL;

                  SELECT cgarant,
                         nriesgo,
                         finiefe,
                         ipritot,
                         ffinefe,
                         idtocom,
                         cageven,
                         nmovima,
                         ccampanya
                    INTO xxcgarant,
                         xxnriesgo,
                         xxfiniefe,
                         xxiprianu,
                         xxffinefe,
                         xxidtocom,
                         xxcageven_gar,
                         xxnmovima_gar,
                         xcampanya
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND cgarant = xcgarant
                     AND nriesgo = xnriesgo
                     AND nmovimi = pnmovimi
                     AND nmovima = xnmovima_gar;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     grabar := 1; -- És una garantia desapareguda
                     --INI -IAXIS-3264 -19/01/2020
                    INSERT INTO garanseg_baja_tmp
                      (sseguro,
                       nriesgo,
                       cgarant,
                       nmovimi,
                       finiefe)
                    VALUES
                      (psseguro,
                       xnriesgo,
                       xcgarant,
                       pnmovimi,
                       xfinefe);
                     --FIN -IAXIS-3264 -19/01/2020
                  WHEN TOO_MANY_ROWS THEN
                     CLOSE cur_garansegant;

                     error := 102310; -- Garantia-Risc repetida en GARANSEG
                     RETURN error;
                  WHEN OTHERS THEN
                     CLOSE cur_garansegant;

                     error := 103500; -- Error al llegir de GARANSEG
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 103500);
                     RETURN error;
               END;

               IF grabar = 1
               THEN
                  -- suplemento con recibo dif. PM

                  -- BUG 20163-  12/2011 - JRH  -  0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
                  IF ptipomovimiento = 11 AND
                     vdifprovision
                  THEN
                     -- Calculamos la prima comercial a esta fecha a traves de la reserva
                     -- matemática
                     -- Fi BUG 20163-  12/2011 - JRH
                     IF vnorec
                     THEN
                        xprovmat := 0;
                     ELSE
                        xprovmat := f_calculo_prov(xcramo,
                                                   xcmodali,
                                                   xccolect,
                                                   xctipseg,
                                                   xcactivi,
                                                   xcgarant,
                                                   pfefecto,
                                                   xsproduc,
                                                   xnriesgo,
                                                   psseguro,
                                                   xnmovimi,
                                                   error);

                        IF error <> 0
                        THEN
                           CLOSE cur_garansegant;

                           RETURN error;
                        END IF;
                     END IF;

                     -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Sin Gastos  los aplicamos después
                     prima_comercial := NVL(xprovmat, 0) / (1 - (0 / 100));
                     xidtocom        := 0; --Si descuentos
                     -- Fi BUG 20672-  01/2012 - JRH  -
                     xiprianu := prima_comercial;
                  END IF;

                  xxidtocom  := 0 - NVL(xxidtocom * xnasegur1, 0);
                  -- INI -IAXIS-3264 19/01/2020
                  IF NVL (pac_parametros.f_parproducto_n (xsproduc,'BAJA_AMP_DEV_TOT'),0) = 1 THEN
                    vssolicit := pac_iax_produccion.poliza.det_poliza.sseguro;
                    xiprianu := F_GET_VALORES_BAJA_AMP(vssolicit,xcgarant,pnmovimi,1,1);
                  END IF;
                  -- FIN -IAXIS-3264 19/01/2020
                  difiprianu := 0 - (xiprianu * xnasegur1);

                  -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Sin Gastos  los aplicamos después
                  IF ptipomovimiento = 11 AND
                     vdifprovision
                  THEN
                     IF difiprianu > 0
                     THEN
                        difiprianu := difiprianu / (1 - (xpgasext / 100)); -- Si no és extorno
                     ELSE
                        -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
                        difiprianu := difiprianu * (1 - (xpgasext / 100)); -- Si és extorno le damos menos
                        -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
                     END IF;
                  END IF;

                  -- Fi BUG 20672-  01/2012 - JRH  -
                  difidtocom := 0 - NVL(xidtocom * xnasegur1, 0);
                  --copiamos la prima neta para dtos de campanya
                  xpprorata := facnetsup;

                  IF difiprianu <> 0
                  THEN
                     -- ******* Prima Neta ******
                     xiconcep := f_round(difiprianu * facnetsup, decimals);

                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                                 xitarrea := f_round(xitarrea *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                                 xitarrea := least(xitarrea, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                                 xitarrea := f_round(xitarrea * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                                 xitarrea := greatest(0,
                                                      xitarrea -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiconcep := 0;
                        --END IF;
                     END IF;

                     -- Bug 12993 AVT 09-02-2010 S'afegeix el xitarrea
                     -- Bug 21812 - RSC - 23/03/2012 - Afegim parametre REASEGURO
                     IF NVL(xiconcep, 0) <> 0 OR
                        (NVL(xitarrea, 0) <> 0 AND
                         NVL(f_parproductos_v(xsproduc, 'REASEGURO'), 0) = 1)
                     THEN
                        error := f_insdetrec(pnrecibo,
                                             0,
                                             xiconcep,
                                             xploccoa,
                                             xcgarant,
                                             xnriesgo,
                                             xctipcoa,
                                             xcageven_gar,
                                             xnmovima_gar,
                                             0,
                                             0,
                                             1,
                                             NULL,
                                             NULL,
                                             NULL,
                                             decimals);

                        IF error = 0
                        THEN
                           ha_grabat := TRUE;

                           IF sw_aln = 1
                           THEN
                              w_importe_aux := f_round(difiprianu, decimals);
                              error         := fl_grabar_calcomisprev(psseguro,
                                                                      pnrecibo,
                                                                      xcgarant,
                                                                      xnriesgo,
                                                                      xcageven_gar,
                                                                      xnmovima_gar,
                                                                      w_importe_aux,
                                                                      pfefecto,
                                                                      pfvencim,
                                                                      pmodo,
                                                                      pnproces);

                              IF error <> 0
                              THEN
                                 CLOSE cur_garansegant;

                                 RETURN error;
                              END IF;
                           END IF;
                        ELSE
                           CLOSE cur_garansegant;

                           RETURN error;
                        END IF;
                     END IF;

                     -- ***** Prima Devengada ******
                     xiconcep := f_round(difiprianu * facdevsup, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-xx->'||facdevsup||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1
                        THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --  xiconcep := 0;
                        --END IF;
                     END IF;

                     IF NVL(xiconcep, 0) <> 0
                     THEN
                        -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                        error := f_pargaranpro(xcramo,
                                               xcmodali,
                                               xctipseg,
                                               xccolect,
                                               xcactivi,
                                               xcgarant,
                                               'GENVENTA',
                                               lcvalpar);

                        IF error <> 0
                        THEN
                           RETURN error;
                        ELSE
                           IF NVL(lcvalpar, 1) = 1
                           THEN
                              -- La garantia genera venda
                              error := f_insdetrec(pnrecibo,
                                                   21,
                                                   xiconcep,
                                                   xploccoa,
                                                   xcgarant,
                                                   xnriesgo,
                                                   xctipcoa,
                                                   xcageven_gar,
                                                   xnmovima_gar,
                                                   0,
                                                   0,
                                                   1,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   decimals);

                              IF error = 0
                              THEN
                                 ha_grabat := TRUE;
                              ELSE
                                 CLOSE cur_garansegant;

                                 RETURN error;
                              END IF;
                           END IF;
                        END IF;
                        ---------------
                     END IF;
                  END IF;

                  IF difidtocom <> 0 AND
                     difidtocom IS NOT NULL
                  THEN
                     -- ******* Dte.comercial ********
                     xiconcep := f_round(difidtocom * facnetsup, decimals);

                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiconcep := 0;
                        --END IF;
                     END IF;

                     IF NVL(xiconcep, 0) <> 0
                     THEN
                        error := f_insdetrec(pnrecibo,
                                             10,
                                             xiconcep,
                                             xploccoa,
                                             xcgarant,
                                             xnriesgo,
                                             xctipcoa,
                                             xcageven_gar,
                                             xnmovima_gar,
                                             0,
                                             0,
                                             1,
                                             NULL,
                                             NULL,
                                             NULL,
                                             decimals);

                        IF error = 0
                        THEN
                           ha_grabat := TRUE;
                        ELSE
                           CLOSE cur_garansegant;

                           RETURN error;
                        END IF;
                     END IF;
                  END IF;
               END IF;

               FETCH cur_garansegant
                  INTO xcgarant,
                       xnriesgo,
                       xfiniefe,
                       xnorden,
                       xctarifa,
                       xicapital,
                       xprecarg,
                       xiprianu,
                       xfinefe,
                       xcformul,
                       xiextrap,
                       xctipfra,
                       xifranqu,
                       xnmovimi,
                       xidtocom,
                       xcageven_gar,
                       xnmovima_gar,
                       xcampanya,
                       xpdtocom,
                       xitarrea; -- BUG: 12993 AVT 09-02-2010
            END LOOP;

            CLOSE cur_garansegant;
         END IF;

         -- **********************************************************
         -- Ara cridarem a la funció que calcula les dades del consorci
         -- **********************************************************
         IF ptipomovimiento IN (1, 11)
         THEN
            facconsor    := facdevsup;
            facconsorfra := facnet; --JAMF  11903
         ELSE
            facconsor    := facdev;
            facconsorfra := facnet; --JAMF  11903
         END IF;

         error := f_consorci(pnproces,
                             psseguro,
                             pnrecibo,
                             pnriesgo,
                             pfefecto,
                             xffinrec,
                             pmodo,
                             ptipomovimiento,
                             xcramo,
                             xcmodali,
                             xcactivi,
                             xccolect,
                             xctipseg,
                             xcduraci,
                             xnduraci,
                             pnmovimi,
                             pgrabar,
                             xnmovimiant,
                             facconsor,
                             facconsorfra, --JAMF 11903
                             xaltarisc,
                             xcapieve,
                             pttabla,
                             pfuncion,
                             pctipapo); -- Bug 12589 - FAL - 31/03/2010 -- Añadir parametro pctipapo a f_consorci

         IF error = 0
         THEN
            IF pgrabar = 1
            THEN
               ha_grabat := TRUE;
            END IF;
         ELSE
            RETURN error;
         END IF;

         -- *******1***************************************************
         -- FASE 3 : Càlcul descomptes, recàrrecs i impostos
         -- **********************************************************
         error := f_imprecibos(pnproces,
                               pnrecibo,
                               ptipomovimiento,
                               pmodo,
                               pnriesgo,
                               xpdtoord,
                               xcrecfra,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               xcactivi,
                               comis_agente,
                               reten_agente,
                               psseguro,
                               pcmodcom,
                               decimals,
                               xpprorata,
                               pttabla,
                               pfuncion);

         IF error <> 0
         THEN
            RETURN error;
         END IF;

         -- ********************************************************************************
         -- Ara mirarem si la prima neta total és negativa. Si ho és, es tracta d' un extorn
         -- ********************************************************************************
         BEGIN
            SELECT SUM(DECODE(cconcep, 0, iconcep, 50, iconcep, 0)) -
                   SUM(DECODE(cconcep, 29, iconcep, 26, iconcep, 0)),
                   -- total neta
                   SUM(DECODE(cconcep, 21, iconcep, 71, iconcep, 0))
            -- total devengada
              INTO xtotprimaneta,
                   xtotprimadeve
              FROM detrecibos
             WHERE nrecibo = pnrecibo
               AND cconcep IN (0, 50, 21, 71, 26, 29);
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 103512; -- Error al llegir de DETRECIBOS
         END;

         vpas := 790;

         IF xtotprimaneta < 0 OR
            xtotprimadeve < 0
         THEN
            IF xctiprec <> 10
            THEN
               -- No és un extorn d' anul.lació
               BEGIN
                  lpermerita := NVL(f_parinstalacion_n('PERMERITA'), 0);

                  -- xex_pte_imp = 1 (Extorn pendent d'imprimir)
                  -- xex_pte_imp = 0 (Extorn pendent de transferir)
                  UPDATE recibos
                     SET ctiprec = 9, -- Si la prima és negativa,
                         cestimp = DECODE(cestimp,
                                          4,
                                          DECODE(xex_pte_imp, 0, 7, 1),
                                          cestimp),
                         nperven = DECODE(lpermerita,
                                          0,
                                          nperven,
                                          1,
                                          TO_CHAR(femisio, 'yyyymm'))
                   WHERE nrecibo = pnrecibo; -- es tracta d' un extorn
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 102358);
                     RETURN 102358; -- Error al modificar la taula RECIBOS
               END;

               vpas := 800;

               -- BUG: 12961 AVT 22-02-2010 s'ajusta pels rebuts d'extorn
               FOR reg IN (SELECT cgarant,
                                  SUM(iconcep) iconcep
                             FROM detrecibos
                            WHERE nrecibo = pnrecibo
                            GROUP BY cgarant)
               LOOP
                  IF reg.iconcep = 0
                  THEN
                     BEGIN
                        DELETE detrecibos
                         WHERE nrecibo = pnrecibo
                           AND cgarant = reg.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 104377);
                           RETURN 104377;
                     END;
                  END IF;
               END LOOP;
               -- BUG: 12961 FI
            END IF;
	    -- INI --IAXIS-3264 -- 28/02/2020
            IF pac_iax_suplementos.lstmotmov IS NOT NULL ANd pac_iax_suplementos.lstmotmov.count > 0 THEN
              IF not (pac_iax_suplementos.lstmotmov(1).cmotmov = 239) THEN
                  error := f_extornpos(pnrecibo, pmodo, pnproces, ptipomovimiento);
                  IF error <> 0
                  THEN
                    RETURN error;
                  END IF;
              END IF;
	      -- FIN --IAXIS-3264 -- 28/02/2020
            END IF;
         END IF;

         IF ha_grabat = TRUE
         THEN
            error := f_vdetrecibos(pmodo, pnrecibo);

            -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
            IF error <> 0
            THEN
               RETURN error;
            END IF;

            error := f_recalcula_vdetrecibos(pmodo);

            -- fin Bug 27057/0145439 - APD - 05/06/2013
            IF error = 0
            THEN
               -- Inicio 23/05/2016 EDA  Bug: 37066 No debe prorratear los suplementos, y si mantener la fecha de efecto del suplemento.
               IF NVL(f_parproductos_v(xsproduc, 'NO_PRORRATEO_SUPLEM'), 0) = 1
               THEN
                  BEGIN
                     SELECT fefecto
                       INTO vfefecto
                       FROM recibos
                      WHERE nrecibo = pnrecibo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        RETURN 101902; -- Rebut no trobat a RECIBOS
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    102367);
                        RETURN 102367; -- Error al llegir de RECIBOS
                  END;
               END IF;
               -- Fin 23/05/2016 EDA  Bug: 37066
               error := pac_cesionesrea.f_cessio_det(pnproces,
                                                     psseguro,
                                                     pnrecibo,
                                                     xcactivi,
                                                     xcramo,
                                                     xcmodali,
                                                     xctipseg,
                                                     xccolect,
                                                     -- 23/05/2016 EDA 37066
                                                     CASE
                                                      f_parproductos_v(xsproduc,
                                                                       'NO_PRORRATEO_SUPLEM')
                                                        WHEN 1 THEN
                                                         vfefecto
                                                        ELSE
                                                         pfefecto
                                                     END, -- Fin 23/05/2016 EDA
                                                     pfvencim,
                                                     facces,
                                                     decimals);

               IF error <> 0
               THEN
                  RETURN error;
               END IF;

               IF pfemisio < pfefecto
               THEN
                  xfmovim := pfefecto;
               ELSE
                  xfmovim := pfemisio;
               END IF;

               error := f_rebnoimprim(pnrecibo, xfmovim, xcimprim, xcestaux);
               RETURN error;
            ELSE
               RETURN error;
            END IF;

            vpas := 900;
         ELSIF NVL(f_parinstalacion_n('DETREC99NO'), 0) != 1
         THEN
            -- No ha grabat res a DETRECIBOS
            --    IF xinnomin = 4 THEN  -- si es innominado
            --      BEGIN
            --     SELECT NVL(COUNT(nriesgo), 0)
            --       INTO xcontriesg
            --       FROM riesgos
            --      WHERE sseguro = psseguro
            --                  AND ((nriesgo = pnriesgo) OR pnriesgo is NULL)
            --                  AND nasegur > 0
            --                  AND fanulac is null;
            --      EXCEPTION
            --     WHEN others THEN
            --       RETURN 103509;    -- Error al llegir de RIESGOS
            --      END;
            --      IF xcontriesg = 0 THEN      -- Es innominat i tots els
            -- riscs ténen nasegur = 0
            -- Si nasegur = 0, grabamos el concepto 99 en DETRECIBOS,
            -- y generamos VDETRECIBOS, y hacemos el recibo no imprimible
            BEGIN
               SELECT MIN(cgarant),
                      MIN(nriesgo)
                 INTO xcgarant,
                      xnriesgo
                 FROM garanseg
                WHERE sseguro = psseguro
                  AND ffinefe IS NULL;
            EXCEPTION
               WHEN OTHERS THEN
                  p_tab_error(f_sysdate,
                              f_user,
                              vobj,
                              vpas,
                              vpar,
                              'SQLCODE = ' || SQLCODE || ' - ' ||
                              'SQLERRM = ' || SQLERRM || 'error = ' ||
                              103500);
                  RETURN 103500; -- Error al llegir de GARANSEG
            END;

            error := f_insdetrec(pnrecibo,
                                 -99,
                                 0,
                                 xploccoa,
                                 xcgarant,
                                 xnriesgo,
                                 xctipcoa,
                                 xcageven_gar,
                                 xnmovima_gar,
                                 0,
                                 0,
                                 1,
                                 NULL,
                                 NULL,
                                 NULL,
                                 decimals);

            IF error = 0
            THEN
               error := f_vdetrecibos(pmodo, pnrecibo);

               -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
               IF error <> 0
               THEN
                  RETURN error;
               END IF;

               error := f_recalcula_vdetrecibos(pmodo);

               -- fin Bug 27057/0145439 - APD - 05/06/2013
               IF error = 0
               THEN
                  error := pac_cesionesrea.f_cessio_det(pnproces,
                                                        psseguro,
                                                        pnrecibo,
                                                        xcactivi,
                                                        xcramo,
                                                        xcmodali,
                                                        xctipseg,
                                                        xccolect,
                                                        pfefecto,
                                                        pfvencim,
                                                        facces,
                                                        decimals);

                  IF error <> 0
                  THEN
                     RETURN error;
                  END IF;

                  IF pfemisio < pfefecto
                  THEN
                     xfmovim := pfefecto;
                  ELSE
                     xfmovim := pfemisio;
                  END IF;

                  error := f_rebnoimprim(pnrecibo,
                                         xfmovim,
                                         xcimprim,
                                         xcestaux);
                  RETURN error;
               ELSE
                  RETURN error;
               END IF;
            ELSE
               RETURN error;
            END IF;
         ELSE
            vpas := 905;
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 103108);
            RETURN 103108;
            -- No se ha grabado ningún registro en el cálculo de recibos
         END IF;
         --         RETURN 105154;  -- Error especial (que se controla en la llamada de esta función
         --  ELSE
         --    RETURN 103108; -- No se ha grabado ningún registro en el cálculo de recibos
         --         END IF;
         --       ELSE              -- No és innominat
         --  RETURN 103108;   -- No s' ha grabat cap registre en el càlcul de rebuts
         --       END IF;
      ELSIF pmodo IN ('P', 'PRIE')
      THEN
         -- proves (avanç cartera)
         --*****************************************************************
         --********************** M O D O    P R U E B A S *****************
         --*****************************************************************
         IF ptipomovimiento = 21
         THEN
            OPEN cur_garancar;

            FETCH cur_garancar
               INTO xcgarant,
                    xnriesgo,
                    xfiniefe,
                    xnorden,
                    xctarifa,
                    xicapital,
                    xprecarg,
                    xiprianu,
                    xfinefe,
                    xcformul,
                    xiextrap,
                    xidtocom,
                    xcageven_gar,
                    xnmovima_gar,
                    xpdtocom,
                    xitarrea; -- BUG: 12993 AVT 09-02-2010

            WHILE cur_garancar%FOUND
            LOOP
               xnasegur  := NULL;
               xnasegur1 := NULL;
               vpas      := 906;

               IF pttabla = 'SOL'
               THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur
                       FROM solriesgos
                      WHERE ssolicit = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garancar;

                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE cur_garancar;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               ELSIF pttabla = 'EST'
               THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garancar;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103836);
                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE cur_garancar;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               ELSE
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur)
                       INTO xnasegur
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_garancar;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103836);
                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE cur_garancar;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               END IF;

               xidtocom := 0 - NVL(xidtocom, 0);
               vpas     := 908;

               -- ********** Conceptos extraordinarios ***********
               IF sw_cextr = 1
               THEN
                  error := fl_inbucle_extrarec(pnrecibo,
                                               pfemisio,
                                               psseguro,
                                               xcgarant,
                                               xploccoa,
                                               xctipcoa,
                                               xcageven_gar,
                                               xnmovima_gar,
                                               pnproces,
                                               xnriesgo,
                                               w_nmeses_cexter,
                                               ha_grabado);

                  IF ha_grabado = 1
                  THEN
                     ha_grabat := TRUE;
                  END IF;

                  IF error <> 0
                  THEN
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               -- ******** Prima Neta *********
               xiprianu2 := f_round(xiprianu * facnet * xnasegur, decimals);
               xpprorata := facnet;

               -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  /*
                  IF pctipapo = 1
                  THEN
                     xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2
                  THEN
                     xiprianu2 :=
                          f_round (piimpapo * facnet * xnasegur, decimals);
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := least(xiprianu2, vapor.iimport);
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := greatest(0,
                                                 xiprianu2 - vapor.iimport);
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xiprianu2 := 0;
                  --END IF;
               END IF;

               IF NVL(xiprianu2, 0) <> 0
               THEN
                  error := f_insdetreccar(pnproces,
                                          pnrecibo,
                                          0,
                                          xiprianu2,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;

                     IF sw_aln = 1
                     THEN
                        w_importe_aux := f_round(xiprianu * xnasegur,
                                                 decimals);
                        error         := fl_grabar_calcomisprev(psseguro,
                                                                pnrecibo,
                                                                xcgarant,
                                                                xnriesgo,
                                                                xcageven_gar,
                                                                xnmovima_gar,
                                                                w_importe_aux,
                                                                pfefecto,
                                                                pfvencim,
                                                                pmodo,
                                                                pnproces);

                        IF error <> 0
                        THEN
                           CLOSE cur_garancar;

                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     CLOSE cur_garancar;

                     RETURN error;
                  END IF;
               END IF;

               -- ******* Dte. comercial *******
               xidtocom2 := f_round(xidtocom * facnet * xnasegur, decimals);

               -- Si te ctipreb = 4 (per aportant) l'import s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  /*
                  IF pctipapo = 1 THEN
                     xidtocom2 :=
                            f_round (xidtocom2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2 THEN
                     -- hen de calcular el descompte per l'import fixe xiprianu2
                     xidtocom2 :=
                        f_round (  f_round ((xiprianu2 * xpdtocom) / 100,
                                            decimals
                                           )
                                 * facnet
                                 * xnasegur,
                                 decimals
                                );
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals); -- Se porratea el importe de descuento

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := least((xidtocom2 * vapor.iimport) /
                                                 xiprianu2,
                                                 vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals);

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := greatest(0,
                                                    ((xidtocom2 *
                                                    vapor.iimport) /
                                                    xiprianu2) -
                                                    vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xidtocom2 := 0;
                  --END IF;
               END IF;

               IF xidtocom2 <> 0 AND
                  xidtocom2 IS NOT NULL
               THEN
                  error := f_insdetreccar(pnproces,
                                          pnrecibo,
                                          10,
                                          xidtocom2,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;
                  ELSE
                     CLOSE cur_garancar;

                     RETURN error;
                  END IF;
               END IF;

               -- ******** Prima Devengada *******
               xiprianu2 := f_round(xiprianu * facdev * xnasegur, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-22->'||facdevsup||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
               -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  /*
                  IF pctipapo = 1 THEN
                     xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2 THEN
                     xiprianu2 :=
                          f_round (piimpapo * facdev * xnasegur, decimals);
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := least(xiprianu2, vapor.iimport);
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := greatest(0,
                                                 xiprianu2 - vapor.iimport);
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xiprianu2 := 0;
                  --END IF;
               END IF;

               IF NVL(xiprianu2, 0) <> 0
               THEN
                  -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                  error := f_pargaranpro(xcramo,
                                         xcmodali,
                                         xctipseg,
                                         xccolect,
                                         xcactivi,
                                         xcgarant,
                                         'GENVENTA',
                                         lcvalpar);

                  IF error <> 0
                  THEN
                     RETURN error;
                  ELSE
                     IF NVL(lcvalpar, 1) = 1
                     THEN
                        -- La garantia genera venda
                        error := f_insdetreccar(pnproces,
                                                pnrecibo,
                                                21,
                                                xiprianu2,
                                                xploccoa,
                                                xcgarant,
                                                xnriesgo,
                                                xctipcoa,
                                                xcageven_gar,
                                                xnmovima_gar,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                        IF error = 0
                        THEN
                           ha_grabat := TRUE;
                        ELSE
                           CLOSE cur_garancar;

                           RETURN error;
                        END IF;
                     END IF;
                  END IF;
                  ---------------
               END IF;

               FETCH cur_garancar
                  INTO xcgarant,
                       xnriesgo,
                       xfiniefe,
                       xnorden,
                       xctarifa,
                       xicapital,
                       xprecarg,
                       xiprianu,
                       xfinefe,
                       xcformul,
                       xiextrap,
                       xidtocom,
                       xcageven_gar,
                       xnmovima_gar,
                       xpdtocom,
                       xitarrea; -- BUG: 12993 AVT 09-02-2010
            END LOOP;

            CLOSE cur_garancar;

            vpas := 300;
         ELSIF ptipomovimiento IN (0, 1, 6, 22, 100)
         THEN
            IF pfuncion = 'TAR'
            THEN
               vselect := 'SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL (icapital, 0),' ||
                          '       precarg, NVL (iprianu, 0), ffinefe, cformul, iextrap, ctipfra,' ||
                          '       ifranqu, 1, idtocom, cageven, nmovima, ccampanya, pdtocom' ||
                          ' FROM tmp_garancar' || ' WHERE sseguro = ' ||
                          psseguro || '   AND sproces = ' || pnproces;

               IF pnriesgo IS NOT NULL
               THEN
                  vselect := vselect || ' AND nriesgo = ' || pnriesgo;
               END IF;
            ELSIF pfuncion = 'CAR'
            THEN
               vselect := 'SELECT cgarant, nriesgo, finiefe, norden, ctarifa, NVL (icaptot, 0),' ||
                          '       precarg, NVL (ipritot, 0), ffinefe, cformul, iextrap, ctipfra,' ||
                          '       ifranqu, nmovimi, idtocom, cageven, nmovima, ccampanya, pdtocom' ||
                          ' FROM garanseg' || ' WHERE sseguro = ' ||
                          psseguro;

               IF pnriesgo IS NOT NULL
               THEN
                  vselect := vselect || ' AND nriesgo = ' || pnriesgo;
               END IF;

               vselect := vselect || ' AND nmovimi = ' || pnmovimi;
               --JRH 11/2008 Corregimos el previo de cartera para que no salgan recibos de P Extraordinaria.
               vselect := vselect || ' AND NVL (f_pargaranpro_v (' ||
                          xcramo || ', ' || '                          ' ||
                          xcmodali || ', ' || '                          ' ||
                          xctipseg || ', ' || '                          ' ||
                          xccolect || ', ' ||
                          '                          NVL (' || xcactivi ||
                          ', 0),' ||
                          '                          garanseg.cgarant,' ||
                          '                          ''TIPO''' ||
                          '                           ), 0) <> 4';
               -- Bug 7926 - RSC - 28/05/2009 -- Se modifica la select del cursor  para que tenga en
               --                                cuenta si la garantía ha vencido ya (solo para el previo,
               --                                ya que en la cartera real ya se da de baja la garantía antes
               --                                y por tanto la garantía ya no entra en el cursor.
               vselect := vselect || ' AND  TO_DATE(''' ||
                          TO_CHAR((pfefecto), 'dd/mm/yyyy') ||
                          ''',''dd/mm/yyyy'') ' ||
                          '< NVL(pac_seguros.F_VTO_GARANTIA(sseguro,
                                                           nriesgo,
                                                           cgarant,
                                                           nmovimi), TO_DATE(''' ||
                          TO_CHAR((pfefecto + 1), 'dd/mm/yyyy') ||
                          ''',''dd/mm/yyyy''))';

               -- Fin Bug 7926

               -- Bug 21167 - RSC - 20/03/2012 - LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera
               IF pmodo = 'PRIE'
               THEN
                  vselect := vselect || ' AND 1 = DECODE(NVL(';
                  vselect := vselect || 'f_pargaranpro_v (' || xcramo || ', ' ||
                             '                          ' || xcmodali || ', ' ||
                             '                          ' || xctipseg || ', ' ||
                             '                          ' || xccolect || ', ' ||
                             '                          NVL (' || xcactivi ||
                             ', 0),' ||
                             '                          garanseg.cgarant,' ||
                             '                          ''TIPO''' ||
                             '                           ), 0), 6, 1, 0) ';
               ELSIF pmodo = 'P'
               THEN
                  IF NVL(f_parproductos_v(xsproduc, 'SEPARA_RIESGO_AHORRO'),
                         0) = 1
                  THEN
                     vselect := vselect || ' AND 1 = DECODE(NVL(';
                     vselect := vselect || 'f_pargaranpro_v (' || xcramo || ', ' ||
                                '                          ' || xcmodali || ', ' ||
                                '                          ' || xctipseg || ', ' ||
                                '                          ' || xccolect || ', ' ||
                                '                          NVL (' ||
                                xcactivi || ', 0),' ||
                                '                          garanseg.cgarant,' ||
                                '                          ''TIPO''' ||
                                '                           ), 0), 6, 0, 1) ';
                  END IF;
               END IF;
               -- Fin Bug 21167
            END IF;

            vpas := 310;

            OPEN curgaran FOR vselect;

            FETCH curgaran
               INTO xcgarant,
                    xnriesgo,
                    xfiniefe,
                    xnorden,
                    xctarifa,
                    xicapital,
                    xprecarg,
                    xiprianu,
                    xfinefe,
                    xcformul,
                    xiextrap,
                    xctipfra,
                    xifranqu,
                    xnmovimi,
                    xidtocom,
                    xcageven_gar,
                    xnmovima_gar,
                    xcampanya,
                    xpdtocom;

            WHILE curgaran%FOUND
            LOOP
               xnasegur  := NULL;
               xnasegur1 := NULL;

               IF pttabla = 'SOL'
               THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur),
                            1
                       INTO xnasegur,
                            xnmovima
                       FROM solriesgos
                      WHERE ssolicit = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103836);
                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               ELSIF pttabla = 'EST'
               THEN
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur),
                            nmovima
                       INTO xnasegur,
                            xnmovima
                       FROM estriesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103836);
                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               ELSE
                  BEGIN
                     SELECT DECODE(nasegur, NULL, 1, nasegur),
                            nmovima
                       INTO xnasegur,
                            xnmovima
                       FROM riesgos
                      WHERE sseguro = psseguro
                        AND nriesgo = xnriesgo;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE curgaran;

                        RETURN 103836;
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103509);
                        RETURN 103509;
                  END;
               END IF;

               -- ********** Conceptos extraordinarios ***********
               IF sw_cextr = 1
               THEN
                  error := fl_inbucle_extrarec(pnrecibo,
                                               pfemisio,
                                               psseguro,
                                               xcgarant,
                                               xploccoa,
                                               xctipcoa,
                                               xcageven_gar,
                                               xnmovima_gar,
                                               pnproces,
                                               xnriesgo,
                                               w_nmeses_cexter,
                                               ha_grabado);

                  IF ha_grabado = 1
                  THEN
                     ha_grabat := TRUE;
                  END IF;

                  IF error <> 0
                  THEN
                     CLOSE curgaran;

                     RETURN error;
                  END IF;
               END IF;

               xidtocom := 0 - NVL(xidtocom, 0);

               -- *******************************************************************************
               -- Fase 1: Càlcul de la Prima Neta (cconcep = 0) y de la Prima Devengada (Fase 2).
               -- *******************************************************************************
               IF ptipomovimiento IN (0, 6, 22)
               THEN
                  -- ***** Prima Neta *****
                  xiprianu2 := f_round(xiprianu * facnet * xnasegur,
                                       decimals);
                  xpprorata := facnet;
P_CONTROL_ERROR('f_detrecibo','REA','facnet-->'||facnet||' crida a xiprianu o = '||xiprianu||' xnasegur-aqui->'||xnasegur||'facdevsup--> '||facdevsup);--> BORRAR JGR
                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3 THEN
                     /*
                     IF pctipapo = 1 THEN
                        xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        xiprianu2 :=
                           f_round (piimpapo * facnet * xnasegur,
                                    decimals);
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 *
                                                   vapor.pimport / 100,
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := least(xiprianu2, vapor.iimport);
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 * (1 -
                                                   (vapor.pimport / 100)),
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := greatest(0,
                                                    xiprianu2 -
                                                    vapor.iimport);
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiprianu2 := 0;
                     --END IF;
                  END IF;

                  IF NVL(xiprianu2, 0) <> 0
                  THEN
                     error := f_insdetreccar(pnproces,
                                             pnrecibo,
                                             0,
                                             xiprianu2,
                                             xploccoa,
                                             xcgarant,
                                             xnriesgo,
                                             xctipcoa,
                                             xcageven_gar,
                                             xnmovima_gar,
                                             0,
                                             0,
                                             1,
                                             NULL,
                                             NULL,
                                             NULL,
                                             decimals);

                     IF error = 0
                     THEN
                        ha_grabat := TRUE;

                        IF sw_aln = 1
                        THEN
                           w_importe_aux := f_round(xiprianu * xnasegur,
                                                    decimals);
                           error         := fl_grabar_calcomisprev(psseguro,
                                                                   pnrecibo,
                                                                   xcgarant,
                                                                   xnriesgo,
                                                                   xcageven_gar,
                                                                   xnmovima_gar,
                                                                   w_importe_aux,
                                                                   pfefecto,
                                                                   pfvencim,
                                                                   pmodo,
                                                                   pnproces);

                           IF error <> 0
                           THEN
                              CLOSE curgaran;

                              RETURN error;
                           END IF;
                        END IF;
                     ELSE
                        CLOSE curgaran;

                        RETURN error;
                     END IF;
                  END IF;

                  -- ****** Descuento comercial
                  xidtocom2 := f_round(xidtocom * facnet * xnasegur,
                                       decimals);

                  -- Si te ctipreb = 4 (per aportant) l'import s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3 THEN
                     /*
                     IF pctipapo = 1 THEN
                        xidtocom2 :=
                            f_round (xidtocom2 * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        -- hen de calcular el descompte per l'import fixe xiprianu2
                        xidtocom2 :=
                           f_round (  f_round ((xiprianu2 * xpdtocom) / 100,
                                               decimals
                                              )
                                    * facnet
                                    * xnasegur,
                                    decimals
                                   );
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xidtocom2 := f_round(xidtocom2 *
                                                   vapor.pimport / 100,
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xidtocom2 := f_round(f_round((xiprianu2 *
                                                           xpdtocom) / 100,
                                                           decimals) *
                                                   facnet * xnasegur,
                                                   decimals); -- Se porratea el importe de descuento

                              --BUG11280-XVM-29092009 inici
                              IF xiprianu2 <> 0
                              THEN
                                 xidtocom2 := least((xidtocom2 *
                                                    vapor.iimport) /
                                                    xiprianu2,
                                                    vapor.iimport);
                              ELSE
                                 xidtocom2 := 0;
                              END IF;
                              --BUG11280-XVM-29092009 fi
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xidtocom2 := f_round(xidtocom2 * (1 -
                                                   (vapor.pimport / 100)),
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              xidtocom2 := f_round(f_round((xiprianu2 *
                                                           xpdtocom) / 100,
                                                           decimals) *
                                                   facnet * xnasegur,
                                                   decimals);

                              --BUG11280-XVM-29092009 inici
                              IF xiprianu2 <> 0
                              THEN
                                 xidtocom2 := greatest(0,
                                                       ((xidtocom2 *
                                                       vapor.iimport) /
                                                       xiprianu2) -
                                                       vapor.iimport);
                              ELSE
                                 xidtocom2 := 0;
                              END IF;
                              --BUG11280-XVM-29092009 fi
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xidtocom2 := 0;
                     --END IF;
                  END IF;

                  IF xidtocom2 <> 0 AND
                     xidtocom2 IS NOT NULL
                  THEN
                     error := f_insdetreccar(pnproces,
                                             pnrecibo,
                                             10,
                                             xidtocom2,
                                             xploccoa,
                                             xcgarant,
                                             xnriesgo,
                                             xctipcoa,
                                             xcageven_gar,
                                             xnmovima_gar,
                                             0,
                                             0,
                                             1,
                                             NULL,
                                             NULL,
                                             NULL,
                                             decimals);

                     IF error = 0
                     THEN
                        ha_grabat := TRUE;
                     ELSE
                        -- CLOSE cur_garanseg;
                        CLOSE curgaran;

                        RETURN error;
                     END IF;
                  END IF;

                  -- ******* Prima Devengada ********
                  IF ptipomovimiento IN (0, 6)
                  THEN
                     xiprianu2 := f_round(xiprianu * facdev * xnasegur,
                                          decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-->'||facdevsup||' crida a xnasegur o = '||xnasegur||' xiprianu-aqui->'||xiprianu||'facdev--> '||facdev);--> BORRAR JGR
                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiprianu2 :=
                              f_round (xiprianu2 * ppimpapo / 100,
                                       decimals
                                      );
                        ELSIF pctipapo = 2 THEN
                           xiprianu2 :=
                              f_round (piimpapo * facdev * xnasegur,
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiprianu2 := f_round(xiprianu2 *
                                                      vapor.pimport / 100,
                                                      decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                                 xiprianu2 := least(xiprianu2,
                                                    vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiprianu2 := f_round(xiprianu2 * (1 -
                                                      (vapor.pimport / 100)),
                                                      decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                                 xiprianu2 := greatest(0,
                                                       xiprianu2 -
                                                       vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiprianu2 := 0;
                        --END IF;
                     END IF;

                     IF NVL(xiprianu2, 0) <> 0
                     THEN
                        -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                        error := f_pargaranpro(xcramo,
                                               xcmodali,
                                               xctipseg,
                                               xccolect,
                                               xcactivi,
                                               xcgarant,
                                               'GENVENTA',
                                               lcvalpar);

                        IF error <> 0
                        THEN
                           RETURN error;
                        ELSE
                           IF NVL(lcvalpar, 1) = 1
                           THEN
                              -- La garantia genera venda
                              error := f_insdetreccar(pnproces,
                                                      pnrecibo,
                                                      21,
                                                      xiprianu2,
                                                      xploccoa,
                                                      xcgarant,
                                                      xnriesgo,
                                                      xctipcoa,
                                                      xcageven_gar,
                                                      xnmovima_gar,
                                                      0,
                                                      0,
                                                      1,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      decimals);

                              IF error = 0
                              THEN
                                 ha_grabat := TRUE;
                              ELSE
                                 CLOSE curgaran;

                                 RETURN error;
                              END IF;
                           END IF;
                        END IF;
                        ---------------
                     END IF;
                  END IF;

                  -- ***********************************************************
                  -- ********************Suplementos ***************************
                  -- ***********************************************************
                  vpas := 350;
               ELSIF ptipomovimiento = 1
               THEN
                  BEGIN
                     xxcgarant := NULL;
                     xxnriesgo := NULL;
                     xxfiniefe := NULL;
                     xxiprianu := NULL;
                     xxffinefe := NULL;
                     xxidtocom := NULL;

                     SELECT cgarant,
                            nriesgo,
                            finiefe,
                            ipritot,
                            ffinefe,
                            idtocom,
                            cageven,
                            nmovima
                       INTO xxcgarant,
                            xxnriesgo,
                            xxfiniefe,
                            xxiprianu,
                            xxffinefe,
                            xxidtocom,
                            xxcageven_gar,
                            xxnmovima_gar
                       FROM garanseg
                      WHERE sseguro = psseguro
                        AND cgarant = xcgarant
                        AND nriesgo = xnriesgo
                        AND nmovimi = xnmovimiant
                        AND nmovima = xnmovima_gar;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        NULL; -- No hi ha garantia anterior
                     WHEN TOO_MANY_ROWS THEN
                        CLOSE curgaran;

                        error := 102310;
                        -- Garantia-Risc repetida en GARANSEG
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE curgaran;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103500);
                        error := 103500; -- Error al llegir de GARANSEG
                        RETURN error;
                  END;

                  xxidtocom := 0 - NVL(xxidtocom, 0);

                  -- INI BUG 41143/229973 - 17/03/2016 - JAEG
                  IF NVL(f_parproductos_v(xsproduc, 'PRIMA_VIG_AMPARO'), 0) = 0
                  THEN
                     difiprianu := (xiprianu * xnasegur) -
                                   NVL(xxiprianu * xnasegur, 0);
                  ELSE
                     difiprianu := f_prima_vig_amparo(psseguro,
                                                      xcgarant,
                                                      pfefecto,
                                                      xnriesgo,
                                                      xnmovimiant,
                                                      xnmovimi,
                                                      xiprianu,
                                                      xxiprianu,
                                                      xnasegur,
                                                      error);
                     IF xcprorra IN (1, 2)
                     THEN
                        IF xcforpag <> 0 OR
                           NVL(f_parproductos_v(xsproduc,
                                                'PRORR_PRIMA_UNICA'),
                               0) = 1
                        THEN
                           facnetsup := difdias2 / divisor2;
                        ELSE
                           facnetsup := 1;
                           facdevsup := 1;
                        END IF;
                     END IF;
                  END IF;
                  -- FIN BUG 41143/229973 - 17/03/2016 - JAEG

                  difidtocom := NVL(xidtocom * xnasegur, 0) -
                                NVL(xxidtocom * xnasegur, 0);
                  xinsert    := TRUE;
                  xpprorata  := facnetsup;

                  IF xaltarisc
                  THEN
                     IF xnmovima = pnmovimi
                     THEN
                        xinsert := TRUE;
                     ELSE
                        xinsert := FALSE;
                     END IF;
                  END IF;

                  --mirem si s'ha donat d'alta una campanya.
                  IF f_parinstalacion_n('CAMPANYA') = 1
                  THEN
                     IF NVL(xxcampanya, -2) <> NVL(xcampanya, -2)
                     THEN
                        v_tecamp := 1;
                     ELSE
                        v_tecamp := 0;
                     END IF;
                  ELSE
                     v_tecamp := 0;
                  END IF;

                  IF xinsert OR
                     v_tecamp = 1
                  THEN
                     -- ****** Prima Neta ******
                     xiconcep  := f_round(difiprianu * facnetsup, decimals);
                     xpprorata := facnetsup;

                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiconcep := 0;
                        --END IF;
                     END IF;

                     IF NVL(xiconcep, 0) <> 0
                     THEN
                        error := f_insdetreccar(pnproces,
                                                pnrecibo,
                                                0,
                                                xiconcep,
                                                xploccoa,
                                                xcgarant,
                                                xnriesgo,
                                                xctipcoa,
                                                xcageven_gar,
                                                xnmovima_gar,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                        IF error = 0
                        THEN
                           ha_grabat := TRUE;

                           IF sw_aln = 1
                           THEN
                              w_importe_aux := f_round(difiprianu, decimals);
                              error         := fl_grabar_calcomisprev(psseguro,
                                                                      pnrecibo,
                                                                      xcgarant,
                                                                      xnriesgo,
                                                                      xcageven_gar,
                                                                      xnmovima_gar,
                                                                      w_importe_aux,
                                                                      pfefecto,
                                                                      pfvencim,
                                                                      pmodo,
                                                                      pnproces);

                              IF error <> 0
                              THEN
                                 CLOSE curgaran;

                                 RETURN error;
                              END IF;
                           END IF;
                        ELSE
                           CLOSE curgaran;

                           RETURN error;
                        END IF;
                     END IF;

                     -- ******* Descuento comercial *********
                     xiconcep := f_round(difidtocom * facnetsup, decimals);

                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiconcep := 0;
                        --END IF;
                     END IF;

                     IF xiconcep <> 0 AND
                        xiconcep IS NOT NULL
                     THEN
                        error := f_insdetreccar(pnproces,
                                                pnrecibo,
                                                10,
                                                xiconcep,
                                                xploccoa,
                                                xcgarant,
                                                xnriesgo,
                                                xctipcoa,
                                                xcageven_gar,
                                                xnmovima_gar,
                                                0,
                                                0,
                                                1,
                                                NULL,
                                                NULL,
                                                NULL,
                                                decimals);

                        IF error = 0
                        THEN
                           ha_grabat := TRUE;
                        ELSE
                           CLOSE curgaran;

                           RETURN error;
                        END IF;
                     END IF;

                     -- ****** Prima Devengada *******
                     xiconcep := f_round(difiprianu * facdevsup, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','difiprianu-->'||difiprianu||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                     -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                     -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                     --        pctipapo = 1 (import fixe = piimpapo)
                     IF xctipreb = 4
                     THEN
                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                        --IF w_pargaranpro = 3 THEN
                        /*
                        IF pctipapo = 1 THEN
                           xiconcep :=
                              f_round (xiconcep * ppimpapo / 100,
                                       decimals);
                        ELSIF pctipapo = 2 THEN
                           -- Apliquem la proporció del fixe sobre l'anual
                           xiconcep :=
                              f_round ((xiconcep * piimpapo / xiprianu),
                                       decimals
                                      );
                        END IF;
                        */

                        -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                        IF pctipapo = 1
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep *
                                                     vapor.pimport / 100,
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := least(xiconcep, vapor.iimport);
                              END IF;
                           END LOOP;
                        ELSIF pctipapo = 2
                        THEN
                           FOR vapor IN cur_aportaseg(psseguro,
                                                      pfefecto,
                                                      xnriesgo)
                           LOOP
                              IF vapor.ctipimp = 1
                              THEN
                                 xiconcep := f_round(xiconcep * (1 -
                                                     (vapor.pimport / 100)),
                                                     decimals);
                              ELSIF vapor.ctipimp = 2
                              THEN
                                 xiconcep := greatest(0,
                                                      xiconcep -
                                                      vapor.iimport);
                              END IF;
                           END LOOP;
                        END IF;
                        --ELSE
                        --   xiconcep := 0;
                        --END IF;
                     END IF;

                     IF NVL(xiconcep, 0) <> 0
                     THEN
                        -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                        error := f_pargaranpro(xcramo,
                                               xcmodali,
                                               xctipseg,
                                               xccolect,
                                               xcactivi,
                                               xcgarant,
                                               'GENVENTA',
                                               lcvalpar);

                        IF error <> 0
                        THEN
                           RETURN error;
                        ELSE
                           IF NVL(lcvalpar, 1) = 1
                           THEN
                              -- La garantia genera venda
                              error := f_insdetreccar(pnproces,
                                                      pnrecibo,
                                                      21,
                                                      xiconcep,
                                                      xploccoa,
                                                      xcgarant,
                                                      xnriesgo,
                                                      xctipcoa,
                                                      xcageven_gar,
                                                      xnmovima_gar,
                                                      0,
                                                      0,
                                                      1,
                                                      NULL,
                                                      NULL,
                                                      NULL,
                                                      decimals);

                              IF error = 0
                              THEN
                                 ha_grabat := TRUE;
                              ELSE
                                 CLOSE curgaran;

                                 RETURN error;
                              END IF;
                           END IF;
                        END IF;
                        ---------------
                     END IF;
                  END IF;
               END IF;

               FETCH curgaran
                  INTO xcgarant,
                       xnriesgo,
                       xfiniefe,
                       xnorden,
                       xctarifa,
                       xicapital,
                       xprecarg,
                       xiprianu,
                       xfinefe,
                       xcformul,
                       xiextrap,
                       xctipfra,
                       xifranqu,
                       xnmovimi,
                       xidtocom,
                       xcageven_gar,
                       xnmovima_gar,
                       xcampanya,
                       xpdtocom;
            END LOOP;

            CLOSE curgaran;

            vpas := 400;

            -- ********************************************************************
            -- Ara buscarem les garanties que estaven en (fefecto-1) i ara no estan
            -- ********************************************************************
            IF ptipomovimiento = 1
            THEN
               OPEN cur_garansegant;

               FETCH cur_garansegant
                  INTO xcgarant,
                       xnriesgo,
                       xfiniefe,
                       xnorden,
                       xctarifa,
                       xicapital,
                       xprecarg,
                       xiprianu,
                       xfinefe,
                       xcformul,
                       xiextrap,
                       xctipfra,
                       xifranqu,
                       xnmovimi,
                       xidtocom,
                       xcageven_gar,
                       xnmovima_gar,
                       xcampanya,
                       xpdtocom,
                       xitarrea; -- BUG: 12993 AVT 09-02-2010

               WHILE cur_garansegant%FOUND
               LOOP
                  xnasegur  := NULL;
                  xnasegur1 := NULL;

                  IF pttabla = 'SOL'
                  THEN
                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur1
                          FROM solriesgos
                         WHERE ssolicit = psseguro
                           AND nriesgo = xnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegant;

                           RETURN 103836;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 103509);
                           RETURN 103509;
                     END;
                  ELSIF pttabla = 'EST'
                  THEN
                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur1
                          FROM estriesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = xnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegant;

                           RETURN 103836;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 103509);
                           RETURN 103509;
                     END;
                  ELSE
                     BEGIN
                        SELECT DECODE(nasegur, NULL, 1, nasegur)
                          INTO xnasegur1
                          FROM riesgos
                         WHERE sseguro = psseguro
                           AND nriesgo = xnriesgo;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_garansegant;

                           RETURN 103836;
                        WHEN OTHERS THEN
                           CLOSE cur_garansegant;

                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 103509);
                           RETURN 103509;
                     END;
                  END IF;

                  xidtocom := 0 - NVL(xidtocom, 0);
                  vpas     := 410;

                  BEGIN
                     grabar    := 0;
                     xxcgarant := NULL;
                     xxnriesgo := NULL;
                     xxfiniefe := NULL;
                     xxiprianu := NULL;
                     xxffinefe := NULL;
                     xxidtocom := NULL;

                     SELECT cgarant,
                            nriesgo,
                            finiefe,
                            ipritot,
                            ffinefe,
                            idtocom,
                            cageven,
                            nmovima
                       INTO xxcgarant,
                            xxnriesgo,
                            xxfiniefe,
                            xxiprianu,
                            xxffinefe,
                            xxidtocom,
                            xxcageven_gar,
                            xxnmovima_gar
                       FROM garanseg
                      WHERE sseguro = psseguro
                        AND cgarant = xcgarant
                        AND nriesgo = xnriesgo
                        AND nmovimi = pnmovimi
                        AND nmovima = xnmovima_gar;

                     xxidtocom := 0 - NVL(xxidtocom, 0);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        grabar := 1; -- És una garantia desapareguda
                     WHEN TOO_MANY_ROWS THEN
                        CLOSE cur_garansegant;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    102310);
                        error := 102310;
                        -- Garantia-Risc repetida en GARANSEG
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE cur_garansegant;

                        p_tab_error(f_sysdate,
                                    f_user,
                                    vobj,
                                    vpas,
                                    vpar,
                                    'SQLCODE = ' || SQLCODE || ' - ' ||
                                    'SQLERRM = ' || SQLERRM || 'error = ' ||
                                    103500);
                        error := 103500; -- Error al llegir de GARANSEG
                        RETURN error;
                  END;

                  IF grabar = 1
                  THEN
                     difiprianu := 0 - (xiprianu * xnasegur1);

                     IF difiprianu <> 0
                     THEN
                        -- ****** Prima Neta *******
                        xiconcep  := f_round(difiprianu * facnetsup,
                                             decimals);
                        xpprorata := facnetsup;

                        -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                        -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                        --        pctipapo = 1 (import fixe = piimpapo)
                        IF xctipreb = 4
                        THEN
                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                           --IF w_pargaranpro = 3 THEN
                           /*
                           IF pctipapo = 1 THEN
                              xiconcep :=
                                 f_round (xiconcep * ppimpapo / 100,
                                          decimals
                                         );
                           ELSIF pctipapo = 2 THEN
                              -- Apliquem la proporció del fixe sobre l'anual
                              xiconcep :=
                                 f_round ((xiconcep * piimpapo / xiprianu
                                          ),
                                          decimals
                                         );
                           END IF;
                           */

                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           IF pctipapo = 1
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep *
                                                        vapor.pimport / 100,
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := least(xiconcep,
                                                      vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep * (1 -
                                                        (vapor.pimport / 100)),
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := greatest(0,
                                                         xiconcep -
                                                         vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                           --ELSE
                           --   xiconcep := 0;
                           --END IF;
                        END IF;

                        IF NVL(xiconcep, 0) <> 0
                        THEN
                           error := f_insdetreccar(pnproces,
                                                   pnrecibo,
                                                   0,
                                                   xiconcep,
                                                   xploccoa,
                                                   xcgarant,
                                                   xnriesgo,
                                                   xctipcoa,
                                                   xcageven_gar,
                                                   xnmovima_gar,
                                                   0,
                                                   0,
                                                   1,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   decimals);

                           IF error = 0
                           THEN
                              ha_grabat := TRUE;

                              IF sw_aln = 1
                              THEN
                                 w_importe_aux := f_round(difiprianu,
                                                          decimals);
                                 error         := fl_grabar_calcomisprev(psseguro,
                                                                         pnrecibo,
                                                                         xcgarant,
                                                                         xnriesgo,
                                                                         xcageven_gar,
                                                                         xnmovima_gar,
                                                                         w_importe_aux,
                                                                         pfefecto,
                                                                         pfvencim,
                                                                         pmodo,
                                                                         pnproces);

                                 IF error <> 0
                                 THEN
                                    CLOSE cur_garanseg;

                                    RETURN error;
                                 END IF;
                              END IF;
                           ELSE
                              CLOSE cur_garansegant;

                              RETURN error;
                           END IF;
                        END IF;

                        -- ***** Prima Devengada *******
                        xiconcep := f_round(difiprianu * facdevsup,
                                            decimals);
P_CONTROL_ERROR('f_detrecibo','REA','difiprianu-->'||difiprianu||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                        -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                        -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                        --        pctipapo = 1 (import fixe = piimpapo)
                        IF xctipreb = 4
                        THEN
                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                           --IF w_pargaranpro = 3 THEN
                           /*
                           IF pctipapo = 1 THEN
                              xiconcep :=
                                 f_round (xiconcep * ppimpapo / 100,
                                          decimals
                                         );
                           ELSIF pctipapo = 2 THEN
                              -- Apliquem la proporció del fixe sobre l'anual
                              xiconcep :=
                                 f_round ((xiconcep * piimpapo / xiprianu
                                          ),
                                          decimals
                                         );
                           END IF;
                           */

                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           IF pctipapo = 1
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep *
                                                        vapor.pimport / 100,
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := least(xiconcep,
                                                      vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep * (1 -
                                                        (vapor.pimport / 100)),
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := greatest(0,
                                                         xiconcep -
                                                         vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                           --ELSE
                           --   xiconcep := 0;
                           --END IF;
                        END IF;

                        IF NVL(xiconcep, 0) <> 0
                        THEN
                           -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                           error := f_pargaranpro(xcramo,
                                                  xcmodali,
                                                  xctipseg,
                                                  xccolect,
                                                  xcactivi,
                                                  xcgarant,
                                                  'GENVENTA',
                                                  lcvalpar);

                           IF error <> 0
                           THEN
                              RETURN error;
                           ELSE
                              IF NVL(lcvalpar, 1) = 1
                              THEN
                                 -- La garantia genera venda
                                 error := f_insdetreccar(pnproces,
                                                         pnrecibo,
                                                         1,
                                                         xiconcep,
                                                         xploccoa,
                                                         xcgarant,
                                                         xnriesgo,
                                                         xctipcoa,
                                                         xcageven_gar,
                                                         xnmovima_gar,
                                                         0,
                                                         0,
                                                         1,
                                                         NULL,
                                                         NULL,
                                                         NULL,
                                                         decimals);

                                 IF error = 0
                                 THEN
                                    ha_grabat := TRUE;
                                 ELSE
                                    CLOSE cur_garansegant;

                                    RETURN error;
                                 END IF;
                              END IF;
                           END IF;
                           ---------------
                        END IF;
                     END IF;

                     -- ******* Descuento Comercial ********
                     difidtocom := 0 - NVL(xidtocom * xnasegur1, 0);

                     IF difidtocom <> 0 AND
                        difidtocom IS NOT NULL
                     THEN
                        xiconcep := f_round(difidtocom * facnetsup,
                                            decimals);

                        -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                        -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                        --        pctipapo = 1 (import fixe = piimpapo)
                        IF xctipreb = 4
                        THEN
                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                           --IF w_pargaranpro = 3 THEN
                           /*
                           IF pctipapo = 1 THEN
                              xiconcep :=
                                 f_round (xiconcep * ppimpapo / 100,
                                          decimals
                                         );
                           ELSIF pctipapo = 2 THEN
                              -- Apliquem la proporció del fixe sobre l'anual
                              xiconcep :=
                                 f_round ((xiconcep * piimpapo / xiprianu
                                          ),
                                          decimals
                                         );
                           END IF;
                           */

                           -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                           IF pctipapo = 1
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep *
                                                        vapor.pimport / 100,
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := least(xiconcep,
                                                      vapor.iimport);
                                 END IF;
                              END LOOP;
                           ELSIF pctipapo = 2
                           THEN
                              FOR vapor IN cur_aportaseg(psseguro,
                                                         pfefecto,
                                                         xnriesgo)
                              LOOP
                                 IF vapor.ctipimp = 1
                                 THEN
                                    xiconcep := f_round(xiconcep * (1 -
                                                        (vapor.pimport / 100)),
                                                        decimals);
                                 ELSIF vapor.ctipimp = 2
                                 THEN
                                    xiconcep := greatest(0,
                                                         xiconcep -
                                                         vapor.iimport);
                                 END IF;
                              END LOOP;
                           END IF;
                           --ELSE
                           --   xiconcep := 0;
                           --END IF;
                        END IF;

                        IF NVL(xiconcep, 0) <> 0
                        THEN
                           error := f_insdetreccar(pnproces,
                                                   pnrecibo,
                                                   10,
                                                   xiconcep,
                                                   xploccoa,
                                                   xcgarant,
                                                   xnriesgo,
                                                   xctipcoa,
                                                   xcageven_gar,
                                                   xnmovima_gar,
                                                   0,
                                                   0,
                                                   1,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   decimals);

                           IF error = 0
                           THEN
                              ha_grabat := TRUE;
                           ELSE
                              CLOSE cur_garansegant;

                              RETURN error;
                           END IF;
                        END IF;
                     END IF;
                  END IF;

                  FETCH cur_garansegant
                     INTO xcgarant,
                          xnriesgo,
                          xfiniefe,
                          xnorden,
                          xctarifa,
                          xicapital,
                          xprecarg,
                          xiprianu,
                          xfinefe,
                          xcformul,
                          xiextrap,
                          xctipfra,
                          xifranqu,
                          xnmovimi,
                          xidtocom,
                          xcageven_gar,
                          xnmovima_gar,
                          xcampanya,
                          xpdtocom,
                          xitarrea; -- BUG: 12993 AVT 09-02-2010
               END LOOP;

               CLOSE cur_garansegant;
            END IF;
         ELSE
            error := 101901; -- Paso incorrecto de parámetros a la función
            RETURN error;
         END IF;

         -- ***********************************************************
         -- Ara cridarem a la funció que calcula les dades del consorci
         -- ***********************************************************
         IF ptipomovimiento = 1
         THEN
            facconsor    := facdevsup;
            facconsorfra := facnet; --JAMF  11903
         ELSE
            facconsor    := facdev;
            facconsorfra := facnet; --JAMF  11903
         END IF;

         error := f_consorci(pnproces,
                             psseguro,
                             pnrecibo,
                             pnriesgo,
                             pfefecto,
                             xffinrec,
                             pmodo,
                             ptipomovimiento,
                             xcramo,
                             xcmodali,
                             xcactivi,
                             xccolect,
                             xctipseg,
                             xcduraci,
                             xnduraci,
                             pnmovimi,
                             pgrabar,
                             xnmovimiant,
                             facconsor,
                             facconsorfra, --JAMF 11903
                             xaltarisc,
                             xcapieve,
                             pttabla,
                             pfuncion,
                             pctipapo); -- Bug 12589 - FAL - 31/03/2010 -- Añadir parametro pctipapo a f_consorci

         IF error = 0
         THEN
            IF pgrabar = 1
            THEN
               ha_grabat := TRUE;
            END IF;
         ELSE
            RETURN error;
         END IF;

         -- **********************************************************
         -- FASE 3 : Càlcul descomptes, recàrrecs i impostos
         -- **********************************************************
         error := f_imprecibos(pnproces,
                               pnrecibo,
                               ptipomovimiento,
                               pmodo,
                               pnriesgo,
                               xpdtoord,
                               xcrecfra,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               xcactivi,
                               comis_agente,
                               reten_agente,
                               psseguro,
                               pcmodcom,
                               decimals,
                               xpprorata,
                               pttabla,
                               pfuncion,
                               pfefecto); -- Bug 21435 - FAL - 23/03/2012. Informar a f_imprecibos efecto del recibo para calculo correcto de anualidad.

         IF error <> 0
         THEN
            RETURN error;
         END IF;

         vpas := 420;

         -- ********************************************************************************
         -- Ara mirarem si la prima neta total és negativa. Si ho és, es tracta d' un extorn
         -- ********************************************************************************
         BEGIN
            SELECT SUM(DECODE(cconcep, 0, iconcep, 50, iconcep, 0)) -
                   SUM(DECODE(cconcep, 26, iconcep, 29, iconcep, 0)),
                   -- total neta
                   SUM(DECODE(cconcep, 21, iconcep, 71, iconcep, 0))
            -- total devengada
              INTO xtotprimaneta,
                   xtotprimadeve
              FROM detreciboscar
             WHERE sproces = pnproces
               AND nrecibo = pnrecibo
               AND cconcep IN (0, 50, 21, 71, 26, 29);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 103516);
               RETURN 103516; -- Error al llegir de DETRECIBOS
         END;

         IF xtotprimaneta < 0 OR
            xtotprimadeve < 0
         THEN
            IF xctiprec <> 10
            THEN
               -- No és un extorn d' anul.lació
               BEGIN
                  -- xex_pte_imp = 1 (Extorn pendent d'imprimir)
                  -- xex_pte_imp = 0 (Extorn pendent de transferir)
                  UPDATE reciboscar
                     SET ctiprec = 9,
                         -- Si la prima és negativa,es tracta d' un extorn
                         cestimp = DECODE(cestimp,
                                          4,
                                          DECODE(xex_pte_imp, 0, 7, 1),
                                          cestimp)
                   WHERE sproces = pnproces
                     AND nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 103520);
                     RETURN 103520; -- Error al modificar la taula RECIBOSCAR
               END;

               -- BUG: 12961 AVT 22-02-2010 s'ajusta pels rebuts d'extorn
               FOR reg IN (SELECT cgarant,
                                  SUM(iconcep) iconcep
                             FROM detreciboscar
                            WHERE nrecibo = pnrecibo
                            GROUP BY cgarant)
               LOOP
                  IF reg.iconcep = 0
                  THEN
                     BEGIN
                        DELETE detreciboscar
                         WHERE nrecibo = pnrecibo
                           AND cgarant = reg.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 104377);
                           RETURN 104377;
                     END;
                  END IF;
               END LOOP;
               -- BUG: 12961 FI
            END IF;

            error := f_extornpos(pnrecibo, pmodo, pnproces, ptipomovimiento);

            IF error <> 0
            THEN
               RETURN error;
            END IF;
         END IF;

         IF ha_grabat = TRUE
         THEN
            error := f_vdetrecibos(pmodo, pnrecibo, pnproces);

            -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
            IF error <> 0
            THEN
               RETURN error;
            END IF;

            error := f_recalcula_vdetrecibos(pmodo);

            -- fin Bug 27057/0145439 - APD - 05/06/2013
            IF error <> 0
            THEN
               RETURN error;
            END IF;
            -- A proves no calculem reasseguro
         ELSIF NVL(f_parinstalacion_n('DETREC99NO'), 0) != 1
         THEN
            vpas := 430;
            -- No ha grabat res a DETRECIBOS
            -- Si nasegur = 0, grabamos el concepto 99 en DETRECIBOSCAR,
            -- y generamos VDETRECIBOSCAR
            error := f_insdetreccar(pnproces,
                                    pnrecibo,
                                    99,
                                    0,
                                    xploccoa,
                                    xcgarant,
                                    xnriesgo,
                                    xctipcoa,
                                    xcageven_gar,
                                    xnmovima_gar,
                                    0,
                                    0,
                                    1,
                                    NULL,
                                    NULL,
                                    NULL,
                                    decimals);

            IF error = 0
            THEN
               error := f_vdetrecibos(pmodo, pnrecibo, pnproces);

               -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
               IF error <> 0
               THEN
                  RETURN error;
               END IF;

               error := f_recalcula_vdetrecibos(pmodo);

               -- fin Bug 27057/0145439 - APD - 05/06/2013
               IF error <> 0
               THEN
                  RETURN error;
               END IF;
               -- No calculem reasseguro pq te prima 0
            END IF;

            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 105154);
            RETURN 105154;
            -- Error especial (que es controla a la crida de aquesta funció
         ELSE
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 103108);
            RETURN 103108; -- No s' ha grabat cap registre en la funció
            --             -- de càlcul de rebuts
            --        END IF;
            -- ELSE  -- No és innominat
            --   RETURN 103108;  -- No s' ha grabat cap registre en la funció
            --                   -- de càlcul de rebuts
            -- END IF;
         END IF;

         --**********************************************************************
         --******* M O D O    P A R A     P R E V I O    D E  R E C I B O   *****
         --**********************************************************************
         vpas := 450;
      ELSIF pmodo = 'N'
      THEN
         -- Cas de crida per f_prevrecibo (Anual)
         IF ptipomovimiento IN (0, 6)
         THEN
            OPEN cur_garanseg;

            FETCH cur_garanseg
               INTO xcgarant,
                    xnriesgo,
                    xfiniefe,
                    xnorden,
                    xctarifa,
                    xicapital,
                    xprecarg,
                    xiprianu,
                    xfinefe,
                    xcformul,
                    xiextrap,
                    xctipfra,
                    xifranqu,
                    xnmovimi,
                    xidtocom,
                    xcageven_gar,
                    xnmovima_gar,
                    xcampanya,
                    xpdtocom,
                    xitarrea, -- BUG: 12993 AVT 09-02-2010
                    xccobprima; -- BUG 41143/229973 - 17/03/2016 - JAEG
            WHILE cur_garanseg%FOUND
            LOOP
               xnasegur  := NULL;
               xnasegur1 := NULL;

               BEGIN
                  SELECT DECODE(nasegur, NULL, 1, nasegur)
                    INTO xnasegur
                    FROM riesgos
                   WHERE sseguro = psseguro
                     AND nriesgo = xnriesgo;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     CLOSE cur_garanseg;

                     RETURN 103836;
                  WHEN OTHERS THEN
                     CLOSE cur_garanseg;

                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 103509);
                     RETURN 103509;
               END;

               xidtocom := 0 - NVL(xidtocom, 0);
               -- Fase 1: Cálculo de la Prima Neta (cconcep = 0) y de la Prima Devengada (Fase 2).
               -- ****** Prima Neta *******
               xiprianu2 := f_round(xiprianu * xnasegur, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','fxiprianu-->'||xiprianu||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
               -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  /*
                  IF pctipapo = 1 THEN
                     xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2 THEN
                     xiprianu2 := f_round (piimpapo * xnasegur, decimals);
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := least(xiprianu2, vapor.iimport);
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xiprianu2 := f_round(xiprianu2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                           xiprianu2 := greatest(0,
                                                 xiprianu2 - vapor.iimport);
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xiprianu2 := 0;
                  --END IF;
               END IF;

               IF NVL(xiprianu2, 0) <> 0
               THEN
                  error := f_insdetreccar(pnproces,
                                          pnrecibo,
                                          0,
                                          xiprianu2,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;

                     IF sw_aln = 1
                     THEN
                        w_importe_aux := xiprianu;
                        error         := fl_grabar_calcomisprev(psseguro,
                                                                pnrecibo,
                                                                xcgarant,
                                                                xnriesgo,
                                                                xcageven_gar,
                                                                xnmovima_gar,
                                                                xiprianu,
                                                                pfefecto,
                                                                pfvencim,
                                                                pmodo,
                                                                pnproces);

                        IF error <> 0
                        THEN
                           CLOSE cur_garanseg;

                           RETURN error;
                        END IF;
                     END IF;
                  ELSE
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               -- ***** Descuento com ******
               xidtocom2 := f_round(xidtocom * xnasegur, decimals);

               -- Si te ctipreb = 4 (per aportant) l'import s'ha de repartir
               -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
               --        pctipapo = 1 (import fixe = piimpapo)
               IF xctipreb = 4
               THEN
                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                  --IF w_pargaranpro = 3 THEN
                  /*
                  IF pctipapo = 1 THEN
                     xidtocom2 :=
                            f_round (xidtocom2 * ppimpapo / 100, decimals);
                  ELSIF pctipapo = 2 THEN
                     -- hen de calcular el descompte per l'import fixe xiprianu2
                     xidtocom2 :=
                        f_round (  f_round ((xiprianu2 * xpdtocom) / 100,
                                            decimals
                                           )
                                 * xnasegur,
                                 decimals
                                );
                  END IF;
                  */

                  -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                  IF pctipapo = 1
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 * vapor.pimport / 100,
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals); -- Se porratea el importe de descuento

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := least((xidtocom2 * vapor.iimport) /
                                                 xiprianu2,
                                                 vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  ELSIF pctipapo = 2
                  THEN
                     FOR vapor IN cur_aportaseg(psseguro,
                                                pfefecto,
                                                xnriesgo)
                     LOOP
                        IF vapor.ctipimp = 1
                        THEN
                           xidtocom2 := f_round(xidtocom2 *
                                                (1 - (vapor.pimport / 100)),
                                                decimals);
                        ELSIF vapor.ctipimp = 2
                        THEN
                           xidtocom2 := f_round(f_round((xiprianu2 *
                                                        xpdtocom) / 100,
                                                        decimals) * facnet *
                                                xnasegur,
                                                decimals);

                           --BUG11280-XVM-29092009 inici
                           IF xiprianu2 <> 0
                           THEN
                              xidtocom2 := greatest(0,
                                                    ((xidtocom2 *
                                                    vapor.iimport) /
                                                    xiprianu2) -
                                                    vapor.iimport);
                           ELSE
                              xidtocom2 := 0;
                           END IF;
                           --BUG11280-XVM-29092009 fi
                        END IF;
                     END LOOP;
                  END IF;
                  --ELSE
                  --   xidtocom2 := 0;
                  --END IF;
               END IF;

               IF xidtocom2 <> 0 AND
                  xidtocom2 IS NOT NULL
               THEN
                  error := f_insdetreccar(pnproces,
                                          pnrecibo,
                                          10,
                                          xidtocom2,
                                          xploccoa,
                                          xcgarant,
                                          xnriesgo,
                                          xctipcoa,
                                          xcageven_gar,
                                          xnmovima_gar,
                                          0,
                                          0,
                                          1,
                                          NULL,
                                          NULL,
                                          NULL,
                                          decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;
                  ELSE
                     CLOSE cur_garanseg;

                     RETURN error;
                  END IF;
               END IF;

               -- ****** Prima Devengada ********
               IF ptipomovimiento IN (0, 6)
               THEN
                  xiprianu := f_round(xiprianu * xnasegur, decimals);
P_CONTROL_ERROR('f_detrecibo','REA','facdevsup-->'||facdevsup||' crida a xctipreb o = '||xctipreb||' xiconcep-aqui->'||xiconcep||'facdevsup--> '||facdevsup);--> BORRAR JGR
                  -- Si te ctipreb = 4 (per aportant) la prima s'ha de repartir
                  -- segons pctipapo = 1 ( Aplicar el porcentatge = ppimpapo)
                  --        pctipapo = 1 (import fixe = piimpapo)
                  IF xctipreb = 4
                  THEN
                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     -- Bug 7854 y 8745 Eliminamos esta condiciona 'w_pargaranpro = 3'
                     --IF w_pargaranpro = 3 THEN
                     /*
                     IF pctipapo = 1 THEN
                        xiprianu2 :=
                            f_round (xiprianu2 * ppimpapo / 100, decimals);
                     ELSIF pctipapo = 2 THEN
                        xiprianu2 :=
                                   f_round (piimpapo * xnasegur, decimals);
                     END IF;
                     */

                     -- Bug 7854 y 8745 - 11/02/2009 - RSC - CRE: Desarrollo de sistema de copago
                     IF pctipapo = 1
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 *
                                                   vapor.pimport / 100,
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := least(xiprianu2, vapor.iimport);
                           END IF;
                        END LOOP;
                     ELSIF pctipapo = 2
                     THEN
                        FOR vapor IN cur_aportaseg(psseguro,
                                                   pfefecto,
                                                   xnriesgo)
                        LOOP
                           IF vapor.ctipimp = 1
                           THEN
                              xiprianu2 := f_round(xiprianu2 * (1 -
                                                   (vapor.pimport / 100)),
                                                   decimals);
                           ELSIF vapor.ctipimp = 2
                           THEN
                              --xiprianu2 := f_round (vapor.iimport * facnet * xnasegur, decimals);
                              xiprianu2 := greatest(0,
                                                    xiprianu2 -
                                                    vapor.iimport);
                           END IF;
                        END LOOP;
                     END IF;
                     --ELSE
                     --   xiprianu2 := 0;
                     --END IF;
                  END IF;

                  IF NVL(xiprianu, 0) <> 0
                  THEN
                     -- Comprovar si ha de generar venda, segons el paràmetre per garantia GENVENTA
                     error := f_pargaranpro(xcramo,
                                            xcmodali,
                                            xctipseg,
                                            xccolect,
                                            xcactivi,
                                            xcgarant,
                                            'GENVENTA',
                                            lcvalpar);

                     IF error <> 0
                     THEN
                        RETURN error;
                     ELSE
                        IF NVL(lcvalpar, 1) = 1
                        THEN
                           -- La garantia genera venda
                           error := f_insdetreccar(pnproces,
                                                   pnrecibo,
                                                   21,
                                                   xiprianu,
                                                   xploccoa,
                                                   xcgarant,
                                                   xnriesgo,
                                                   xctipcoa,
                                                   xcageven_gar,
                                                   xnmovima_gar,
                                                   0,
                                                   0,
                                                   1,
                                                   NULL,
                                                   NULL,
                                                   NULL,
                                                   decimals);

                           IF error = 0
                           THEN
                              ha_grabat := TRUE;
                           ELSE
                              CLOSE cur_garanseg;

                              RETURN error;
                           END IF;
                        END IF;
                     END IF;
                     ---------------
                  END IF;
               END IF;

               FETCH cur_garanseg
                  INTO xcgarant,
                       xnriesgo,
                       xfiniefe,
                       xnorden,
                       xctarifa,
                       xicapital,
                       xprecarg,
                       xiprianu,
                       xfinefe,
                       xcformul,
                       xiextrap,
                       xctipfra,
                       xifranqu,
                       xnmovimi,
                       xidtocom,
                       xcageven_gar,
                       xnmovima_gar,
                       xcampanya,
                       xpdtocom,
                       xitarrea, -- BUG: 12993 AVT 09-02-2010
                       xccobprima; -- BUG 41143/229973 - 17/03/2016 - JAEG
            END LOOP;

            CLOSE cur_garanseg;
         ELSE
            error := 101901; -- Paso incorrecto de parámetros a la función
            RETURN error;
         END IF;

         -- ***********************************************************
         -- Ara cridarem a la funció que calcula les dades del consorci
         -- ***********************************************************
         facconsor    := 1; -- No debe prorratear nunca
         facconsorfra := facnet; --JAMF  11903
         error        := f_consorci(pnproces,
                                    psseguro,
                                    pnrecibo,
                                    pnriesgo,
                                    pfefecto,
                                    xffinrec,
                                    'N',
                                    ptipomovimiento,
                                    xcramo,
                                    xcmodali,
                                    xcactivi,
                                    xccolect,
                                    xctipseg,
                                    xcduraci,
                                    xnduraci,
                                    pnmovimi,
                                    pgrabar,
                                    xnmovimiant,
                                    facconsor,
                                    facconsorfra, --JAMF 11903
                                    xaltarisc,
                                    xcapieve,
                                    pttabla,
                                    pfuncion,
                                    pctipapo); -- Bug 12589 - FAL - 31/03/2010 -- Añadir parametro pctipapo a f_consorci

         IF error = 0
         THEN
            IF pgrabar = 1
            THEN
               ha_grabat := TRUE;
            END IF;
         ELSE
            RETURN error;
         END IF;

         vpas  := 500;
         error := f_imprecibos(pnproces,
                               pnrecibo,
                               ptipomovimiento,
                               pmodo,
                               pnriesgo,
                               xpdtoord,
                               xcrecfra,
                               xcforpag,
                               xcramo,
                               xcmodali,
                               xctipseg,
                               xccolect,
                               xcactivi,
                               comis_agente,
                               reten_agente,
                               psseguro,
                               pcmodcom,
                               decimals,
                               xpprorata,
                               pttabla,
                               pfuncion);

         IF error <> 0
         THEN
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || error);
            RETURN error;
         END IF;

         vpas := 510;

         -- ********************************************************************************
         -- Ara mirarem si la prima neta total és negativa. Si ho és, es tracta d' un extorn
         -- ********************************************************************************
         BEGIN
            SELECT SUM(DECODE(cconcep, 0, iconcep, 50, iconcep, 0)),
                   -- total neta
                   SUM(DECODE(cconcep, 21, iconcep, 71, iconcep, 0))
            -- total devengada
              INTO xtotprimaneta,
                   xtotprimadeve
              FROM detreciboscar
             WHERE sproces = pnproces
               AND nrecibo = pnrecibo
               AND cconcep IN (0, 50, 21, 71);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || 103516);
               RETURN 103516; -- Error al llegir de DETRECIBOS
         END;

         IF xtotprimaneta < 0 OR
            xtotprimadeve < 0
         THEN
            IF xctiprec <> 10
            THEN
               -- No és un extorn d' anul.lació
               BEGIN
                  -- xex_pte_imp = 1 (Extorn pendent d'imprimir)
                  -- xex_pte_imp = 0 (Extorn pendent de transferir)
                  UPDATE reciboscar
                     SET ctiprec = 9,
                         -- Si la prima és negativa,es tracta d' un extorn
                         cestimp = DECODE(cestimp,
                                          4,
                                          DECODE(xex_pte_imp, 0, 7, 1),
                                          cestimp)
                   WHERE sproces = pnproces
                     AND nrecibo = pnrecibo;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 103520);
                     RETURN 103520; -- Error al modificar la taula RECIBOSCAR
               END;

               -- BUG: 12961 AVT 22-02-2010 s'ajusta pels rebuts d'extorn
               FOR reg IN (SELECT cgarant,
                                  SUM(iconcep) iconcep
                             FROM detreciboscar
                            WHERE nrecibo = pnrecibo
                            GROUP BY cgarant)
               LOOP
                  IF reg.iconcep = 0
                  THEN
                     BEGIN
                        DELETE detreciboscar
                         WHERE nrecibo = pnrecibo
                           AND cgarant = reg.cgarant;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           NULL;
                        WHEN OTHERS THEN
                           p_tab_error(f_sysdate,
                                       f_user,
                                       vobj,
                                       vpas,
                                       vpar,
                                       'SQLCODE = ' || SQLCODE || ' - ' ||
                                       'SQLERRM = ' || SQLERRM ||
                                       'error = ' || 104377);
                           RETURN 104377;
                     END;
                  END IF;
               END LOOP;
               -- BUG: 12961 FI
            END IF;

            error := f_extornpos(pnrecibo, pmodo, pnproces, ptipomovimiento);

            IF error <> 0
            THEN
               RETURN error;
            END IF;
         END IF;

         IF ha_grabat = TRUE
         THEN
            error := f_vdetrecibos('N', pnrecibo, pnproces);

            -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
            IF error <> 0
            THEN
               RETURN error;
            END IF;

            error := f_recalcula_vdetrecibos('N');
            -- fin Bug 27057/0145439 - APD - 05/06/2013
            -- No fem reasseguro pq és un rebut fictici
            RETURN error;
         ELSIF NVL(f_parinstalacion_n('DETREC99NO'), 0) != 1
         THEN
            -- No ha grabat res a DETRECIBOS
            error := f_insdetreccar(pnproces,
                                    pnrecibo,
                                    99,
                                    0,
                                    xploccoa,
                                    xcgarant,
                                    xnriesgo,
                                    xctipcoa,
                                    xcageven_gar,
                                    xnmovima_gar,
                                    0,
                                    0,
                                    1,
                                    NULL,
                                    NULL,
                                    NULL,
                                    decimals);

            IF error = 0
            THEN
               error := f_vdetrecibos('N', pnrecibo, pnproces);

               -- Bug 27057/0145439 - APD - 05/06/2013 - se recalcula la vdetrecibos si itotalr < 0
               IF error <> 0
               THEN
                  RETURN error;
               END IF;

               error := f_recalcula_vdetrecibos('N');
               -- fin Bug 27057/0145439 - APD - 05/06/2013
               -- No fem reasseguro pq és un rebut fictici
               RETURN error;
            END IF;

            vpas := 520;
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 105154);
            RETURN 105154;
            -- Error especial (que es controla a la crida de aquesta funció
         ELSE
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 103108);
            RETURN 103108; -- No s' ha grabat cap registre en la funció
         END IF;

         vpas := 530;
         -- Rèdit de interessos en comptes de estalvi ************************
      ELSIF pmodo = 'I'
      THEN
         IF pnimport IS NOT NULL AND
            pnrecibo IS NOT NULL AND
            pfefecto IS NOT NULL AND
            psseguro IS NOT NULL
         THEN
            IF xctipcoa = 8 OR
               xctipcoa = 9
            THEN
               /*  Si se trata de un coaseguro aceptado. Puede pasar que nosotros paguemos
                  directamente al agente con lo que pcomcoa sera nulo, y deberemos ir a
                  buscar los porcentajes por p_fcomisi.
                  Sino pcomcoa sera diferente a nulo, y tendra el porcentaje a pagar a la otra compañia y la
                  comision y retencio en vdetrecibos sera 0.
               */
               BEGIN
                  SELECT pcomcoa
                    INTO xpcomcoa
                    FROM coacedido
                   WHERE sseguro = psseguro
                     AND ncuacoa = xncuacoa;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     -- 23183 AVT 31/10/2012 no hi ha coacedido a la Coa. Acceptada
                     xpcomcoa := NULL;
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 105582);
                     RETURN 105582; -- Error al leer de la tabla COACEDIDO
               END;

               IF xpcomcoa IS NULL
               THEN
                  --BUG20342 - JTS - 02/12/2011
                  --Bug.:18852 - 08/09/2011 - ICV
                  /*IF NVL(pac_parametros.f_parempresa_t(xcempres, 'FVIG_COMISION'),
                         'FEFECTO_REC') = 'FEFECTO_REC' THEN
                     xfecvig := pfefecto;   --Efecto del recibo
                  ELSE
                     xfecvig := xfefepol;   --Efecto de la póliza
                  END IF;
                  */
                  --Fi Bug.: 18852
                  IF pttabla = 'SOL'
                  THEN
                     SELECT sproduc,
                            xfefepol
                       INTO v_sproduc,
                            v_fefectopol
                       FROM solseguros
                      WHERE ssolicit = psseguro;
                  ELSIF pttabla = 'EST'
                  THEN
                     SELECT sproduc,
                            fefecto
                       INTO v_sproduc,
                            v_fefectopol
                       FROM estseguros
                      WHERE sseguro = psseguro;
                  ELSE
                     SELECT sproduc,
                            fefecto
                       INTO v_sproduc,
                            v_fefectopol
                       FROM seguros
                      WHERE sseguro = psseguro;
                  END IF;

                  IF NVL(pac_parametros.f_parproducto_t(v_sproduc,
                                                        'FVIG_COMISION'),
                         'FEFECTO_REC') = 'FEFECTO_REC'
                  THEN
                     v_fefectovig := pfefecto; --Efecto del recibo
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                       'FVIG_COMISION') =
                        'FEFECTO_POL'
                  THEN
                     --Efecto de la póliza
                     BEGIN
                        IF pttabla = 'EST'
                        THEN
                           SELECT TO_DATE(crespue, 'YYYYMMDD')
                             INTO v_fefectovig
                             FROM estpregunpolseg
                            WHERE sseguro = psseguro
                              AND nmovimi =
                                  (SELECT MAX(p.nmovimi)
                                     FROM estpregunpolseg p
                                    WHERE p.sseguro = psseguro)
                              AND cpregun = 4046;
                        ELSE
                           SELECT TO_DATE(crespue, 'YYYYMMDD')
                             INTO v_fefectovig
                             FROM pregunpolseg
                            WHERE sseguro = psseguro
                              AND nmovimi =
                                  (SELECT MAX(p.nmovimi)
                                     FROM pregunpolseg p
                                    WHERE p.sseguro = psseguro)
                              AND cpregun = 4046;
                        END IF;
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_fefectovig := v_fefectopol;
                     END;
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                       'FVIG_COMISION') =
                        'FEFECTO_RENOVA'
                  THEN
                     -- efecto a la renovacion
                     IF pttabla = 'SOL'
                     THEN
                        v_fefectovig := TO_DATE(frenovacion(NULL,
                                                            psseguro,
                                                            0),
                                                'yyyymmdd');
                     ELSIF pttabla = 'EST'
                     THEN
                        v_fefectovig := TO_DATE(frenovacion(NULL,
                                                            psseguro,
                                                            1),
                                                'yyyymmdd');
                     ELSE
                        v_fefectovig := TO_DATE(frenovacion(NULL,
                                                            psseguro,
                                                            2),
                                                'yyyymmdd');
                     END IF;
                  END IF;

                  xfecvig := v_fefectovig;
                  --FIBUG20342
                  -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
                  -- de la variable xfecvig
                  -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
                  error := f_pcomisi(psseguro,
                                     pcmodcom,
                                     f_sysdate,
                                     xccomisi,
                                     xcretenc,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     NULL,
                                     pttabla,
                                     pfuncion,
                                     xfecvig);
                  -- fin Bug 20153 - APD - 15/11/2011
               ELSE
                  xccomisi := 0;
                  xcretenc := 0;
                  error    := 0;
               END IF;
            ELSE
               --BUG20342 - JTS - 02/12/2011
               --Bug.:18852 - 08/09/2011 - ICV
               /*IF NVL(pac_parametros.f_parempresa_t(xcempres, 'FVIG_COMISION'), 'FEFECTO_REC') =
                                                                                 'FEFECTO_REC' THEN
                  xfecvig := pfefecto;   --Efecto del recibo
               ELSE
                  xfecvig := xfefepol;   --Efecto de la póliza
               END IF;
               */
               --Fi Bug.: 18852
               IF pttabla = 'SOL'
               THEN
                  SELECT sproduc,
                         xfefepol
                    INTO v_sproduc,
                         v_fefectopol
                    FROM solseguros
                   WHERE ssolicit = psseguro;
               ELSIF pttabla = 'EST'
               THEN
                  SELECT sproduc,
                         fefecto
                    INTO v_sproduc,
                         v_fefectopol
                    FROM estseguros
                   WHERE sseguro = psseguro;
               ELSE
                  SELECT sproduc,
                         fefecto
                    INTO v_sproduc,
                         v_fefectopol
                    FROM seguros
                   WHERE sseguro = psseguro;
               END IF;

               IF NVL(pac_parametros.f_parproducto_t(v_sproduc,
                                                     'FVIG_COMISION'),
                      'FEFECTO_REC') = 'FEFECTO_REC'
               THEN
                  v_fefectovig := pfefecto; --Efecto del recibo
               ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                    'FVIG_COMISION') =
                     'FEFECTO_POL'
               THEN
                  --Efecto de la póliza
                  BEGIN
                     IF pttabla = 'EST'
                     THEN
                        SELECT TO_DATE(crespue, 'YYYYMMDD')
                          INTO v_fefectovig
                          FROM estpregunpolseg
                         WHERE sseguro = psseguro
                           AND nmovimi =
                               (SELECT MAX(p.nmovimi)
                                  FROM estpregunpolseg p
                                 WHERE p.sseguro = psseguro)
                           AND cpregun = 4046;
                     ELSE
                        SELECT TO_DATE(crespue, 'YYYYMMDD')
                          INTO v_fefectovig
                          FROM pregunpolseg
                         WHERE sseguro = psseguro
                           AND nmovimi =
                               (SELECT MAX(p.nmovimi)
                                  FROM pregunpolseg p
                                 WHERE p.sseguro = psseguro)
                           AND cpregun = 4046;
                     END IF;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        v_fefectovig := v_fefectopol;
                  END;
               ELSIF pac_parametros.f_parproducto_t(v_sproduc,
                                                    'FVIG_COMISION') =
                     'FEFECTO_RENOVA'
               THEN
                  -- efecto a la renovacion
                  IF pttabla = 'SOL'
                  THEN
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 0),
                                             'yyyymmdd');
                  ELSIF pttabla = 'EST'
                  THEN
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 1),
                                             'yyyymmdd');
                  ELSE
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 2),
                                             'yyyymmdd');
                  END IF;
               END IF;

               xfecvig := v_fefectovig;
               --FIBUG20342
               -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
               -- de la variable xfecvig
               -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
               error := f_pcomisi(psseguro,
                                  pcmodcom,
                                  f_sysdate,
                                  xccomisi,
                                  xcretenc,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  pttabla,
                                  pfuncion,
                                  xfecvig);
               -- fin Bug 20153 - APD - 15/11/2011
            END IF;

            IF error = 0
            THEN
               -- ******* Comision bruta ******
               xnimpcom := f_round(((pnimport * xccomisi) / 100), decimals);

               -- Posada la garantia 48, prima del periode
               --  IF NVL (xnimpcom, 0) <> 0
               -- THEN
               -- Bug 17243 - APD - 01/03/2011 - si el parametro pcgarant IS NULL se busca
               -- la garantia de tipo 3
               IF pcgarant IS NULL
               THEN
                  BEGIN
                     SELECT g.cgarant
                       INTO vcgarantfin
                       FROM seguros  s,
                            garanpro g
                      WHERE s.sseguro = psseguro
                        AND g.sproduc = s.sproduc
                        AND NVL(f_pargaranpro_v(g.cramo,
                                                g.cmodali,
                                                g.ctipseg,
                                                g.ccolect,
                                                NVL(s.cactivi, 0),
                                                g.cgarant,
                                                'TIPO'),
                                0) = 3;
                  EXCEPTION
                     WHEN OTHERS THEN
                        vcgarantfin := 48;
                  END;
               ELSE
                  vcgarantfin := pcgarant;
               END IF;

               vpas := 560;
               -- Bug 17243 - APD - 01/03/2011 - se sustiye el valor 48 fijo por el valor
               -- de la variable ivcgarantfin
               error := f_insdetrec(pnrecibo,
                                    11,
                                    pnimport,
                                    xploccoa,
                                    vcgarantfin /*48*/,
                                    pnriesgo,
                                    xctipcoa,
                                    xcageven_gar,
                                    xnmovima_gar,
                                    xccomisi,
                                    psseguro,
                                    1,
                                    NULL,
                                    NULL,
                                    NULL,
                                    decimals);

               -- Fin Bug 17243 - APD - 01/03/2011
               IF error = 0
               THEN
                  ha_grabat := TRUE;
               ELSE
                  CLOSE cur_garanseg;

                  p_tab_error(f_sysdate,
                              f_user,
                              vobj,
                              vpas,
                              vpar,
                              'SQLCODE = ' || SQLCODE || ' - ' ||
                              'SQLERRM = ' || SQLERRM || 'error = ' ||
                              error);
                  RETURN error;
               END IF;

               pnimport2 := pnimport - xnimpcom;
               -- ******* Retencion *******
               -- Calculamos el irpf que es comun al local y al cedido
               xnimpret := f_round(((pnimport * xcretenc) / 100), decimals);

               IF NVL(xnimpret, 0) <> 0
               THEN
                  error := f_insdetrec(pnrecibo,
                                       12,
                                       xnimpret,
                                       xploccoa,
                                       48,
                                       pnriesgo,
                                       xctipcoa,
                                       xcageven_gar,
                                       xnmovima_gar,
                                       xccomisi,
                                       psseguro,
                                       1,
                                       NULL,
                                       NULL,
                                       NULL,
                                       decimals);

                  IF error = 0
                  THEN
                     ha_grabat := TRUE;
                  ELSE
                     CLOSE cur_garanseg;

                     p_tab_error(f_sysdate,
                                 f_user,
                                 vobj,
                                 vpas,
                                 vpar,
                                 'SQLCODE = ' || SQLCODE || ' - ' ||
                                 'SQLERRM = ' || SQLERRM || 'error = ' ||
                                 error);
                     RETURN error;
                  END IF;
               END IF;

               vpas  := 570;
               error := f_vdetrecibos(pmodo, pnrecibo);

               IF error = 0
               THEN
                  error := pac_cesionesrea.f_cessio_det(pnproces,
                                                        psseguro,
                                                        pnrecibo,
                                                        xcactivi,
                                                        xcramo,
                                                        xcmodali,
                                                        xctipseg,
                                                        xccolect,
                                                        pfefecto,
                                                        pfvencim,
                                                        1,
                                                        decimals);

                  IF error <> 0
                  THEN
                     RETURN error;
                  END IF;
               END IF;

               RETURN error;
               --ELSE                                            -- Comissió = 0
               --   pnimport2 := NVL (pnimport, 0);
               /*
                  IF sw_aln = 1
                  THEN
                     BEGIN
                        DELETE FROM calcomisprev
                              WHERE nrecibo = pnrecibo;
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           RETURN 112182;
                     -- Error borrando registros de CALCOMISPREV
                     END;
                  END IF;

                  RETURN 0;
               END IF;
               */
            ELSE
               p_tab_error(f_sysdate,
                           f_user,
                           vobj,
                           vpas,
                           vpar,
                           'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                           SQLERRM || 'error = ' || error);
               RETURN error; -- Error en el p_comisi
            END IF;
         ELSE
            p_tab_error(f_sysdate,
                        f_user,
                        vobj,
                        vpas,
                        vpar,
                        'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                        SQLERRM || 'error = ' || 101901);
            RETURN 101901; -- Pas de paràmetres incorrecte a la funció
         END IF;
      ELSE
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vpas,
                     vpar,
                     'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                     SQLERRM || 'error = ' || 101901);
         RETURN 101901; -- Pas incorrecte de paràmetres a la funció
      END IF;
   END IF; -- IF que diferencia el cas de Ahorro dels altres dos

   RETURN 0;
   -- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_garanseg%ISOPEN
      THEN
         CLOSE cur_garanseg;
      END IF;

      IF cur_garansegant%ISOPEN
      THEN
         CLOSE cur_garansegant;
      END IF;

      IF cur_garancar%ISOPEN
      THEN
         CLOSE cur_garancar;
      END IF;

      IF curgaran%ISOPEN
      THEN
         CLOSE curgaran;
      END IF;

      IF curgaran%ISOPEN
      THEN
         CLOSE curgaran;
      END IF;

      p_tab_error(f_sysdate,
                  f_user,
                  vobj,
                  vpas,
                  vpar,
                  'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' ||
                  SQLERRM || 'error = ' || 140999);
      RETURN 140999;
END f_detrecibo;

/

  