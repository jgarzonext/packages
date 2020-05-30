CREATE OR REPLACE FUNCTION f_imprecibos(
   pnproces IN NUMBER,
   pnrecibo IN NUMBER,
   ptipomovimiento IN NUMBER,
   pmodo IN VARCHAR2,
   pnriesgo IN NUMBER,
   ppdtoord IN NUMBER,
   pcrecfra IN NUMBER,
   pcforpag IN NUMBER,
   pcramo IN NUMBER,
   pcmodali IN NUMBER,
   pctipseg IN NUMBER,
   pccolect IN NUMBER,
   pcactivi IN NUMBER,
   pcomisagente IN NUMBER,
   pretenagente IN NUMBER,
   psseguro IN NUMBER,
   pcmodcom IN NUMBER,
   pmoneda IN NUMBER DEFAULT 1,
   pprorata IN NUMBER,
   pttabla IN VARCHAR2 DEFAULT NULL,
   pfuncion IN VARCHAR2 DEFAULT 'CAR',
   pfcarpro IN DATE DEFAULT NULL)   -- BUG 21435 - FAL - 16/03/2012
   RETURN NUMBER IS
   -- CALCULA ELS IMPOSTOS DELS REBUTS.
   -- IMPLEMENTACION DEL COASEGURO EN RECIBOS TRABAJAMOS CON IMPORTES TOTALES: LOCAL + CEDIDO
   -- CANVIS PER MILLORAR RENDIMENT.
   -- Acceso a PARINSTALACION para decidir cargar o no el recargo por fraccionamiento en el calculo del IPS
   -- Calcul de la clea en el primer rebut
   -- No calcular les 10 pts d'OFESAUTO si es un suplement
   -- EL RECARREC PER FRACCIONAMENT ARA ESTA PER PRODUCTE-ACTIVITAT-GARANTIA
   -- Generamos Der. Reg con importe igual a la prima neta para las instalaciones con
   -- Parinstalacion (DER_REG) y garanpro.CDERREG=1
   -- Añadimos el modo H rehabilitacion.
   -- control del not_data_found en la funcion de f_control_cderreg.Para cuando estamos
   -- generamos un recibo de extorno devolvemos un 1.
   -- 22/4/2004 YIL. Se añade el tipomovimiento = 11 ==> Suplemento con Recibo por diferencia
   --              de prima basada en provisión matemática (prima única)
   /******************************************************************************
      NOMBRE:       F_IMPRECIBOS
   PROPÓSITO:    Procedimient per imprimir rebuts.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        ??/??/????  ???                1. Creación del package.
   5.0        29/05/2009  JTS                5. BUG 9658 - JTS - APR - Desarrollo PL de comisiones de adquisión.#6.
   6.0        21/07/2009  ICV-DCT            6. BUG 10709 - ICV - DCT - Modificación recargo Clea Ley 6/2009
   7.0        10/08/2009  RSC                7.0 Bug 10865: APR - error en comisiones de adquisición
   8.0        01/08/2009  NMM                7. Bug 10864: CEM - Tasa aplicable en Consorcio
   9.0        10/10/2009  LCF                2. 0009422: Limpiar estructura de impuestos antigua
   10.0       10/03/2010  RSC               10. 13515: APR - Error en el calculo de comisiones
   11.0       11/03/2010  ASN               11. 0013607: APR - Comisiones de adquisión en previo de cartera
   12.0       11/05/2010  ICV               12. 0014476: APR707 - Error en el previo de cartera-> comisiones
   13.0       16/12/2010   SMF              13. 0017017: AGA203 - comisiones de primer año anualizado
   14.0       07/02/2011  SMF               14. 0017503: Error en el calculo de comisiones anualizadas
   15.0       28/09/2011  JMC               15. 0019586: Comisiones Indirectas a distintos niveles.
   16.0       15/11/2011  APD               16. 0020153: LCOL_C001: Ajuste en el cálculo del recibo
   17.0       21/11/2011  JMP               17. 0018423: LCOL000 - Multimoneda
   18.0       02/12/2011  JTS               18. 0020342: LCOL_C001: Ajuste de la f_imprecibos
   19.0       19/12/2011  JMF               19. 0020480: LCOL_C001: Ajuste de la retención en la función de cálculo
   20.0       03/01/2012   JRH              20. 0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos
   21.0       14/01/2012   JRH              21. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
   22.0       18/01/2012   DRA              22. 0020977: CIV800-Error Reduccion cobertura
   23.0       26/01/2012   APD              23. 0020999: LCOL_C001: Comisiones Indirectas para ADN Bancaseguros
   24.0       23/03/2012   FAL              24. 0021435: GIP003-ID 6 - Gestión de cartera
   25.0       24/04/2012   JMF              25. 0022027 CRE800 Previ de cartera
   26.0       18/05/2012   DRA              26. 0022255: LCOL_C001: Cálculo de comisión teniendo en cuenta el recargo de fraccionamiento
   27.0       26/06/2012  JRH               27. 21947: Añadir nriesgo como parámetro a f_pcomisi
   28.0       02/08/2012  APD               28. 0023074: LCOL_T010-Tratamiento Gastos de Expedición
   29.0       20/08/2012  JMF               29. 0021947 MDP - TEC - Comisión especial a nivel de garantía
   30.0       31/10/2012  AVT               30. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   31.0       13/02/2013  FAL               31. 0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
   32.0       22/04/2013  AVT               32. 0026755: LCOL_A004-Qtracker: 7266 (iAxis F3A UAT_PILOTO): ERROR EN EMISI?N CON COASEGURO CEDIDO
   33.0       24/04/2013  FAL               33. 0026733: GIP800 - Incidencias reportadas 15/4
   34.0       06/05/2013  FAL               34. 0026835: GIP800 - Incidencias reportadas 23/4
   35.0       13/06/2013  AFM               35. 0027067: RSA: Registrar información en la DETRECIBOS de las comisiones por concepto
   36.0       02/08/2013  JSV               36. 0027752: LCOL_A004-Qtracker: 0008346: ERROR EN LA APLICACION DE LA PRIMA
   37.0       03/10/2013  FAL               37. 0027735: RSAG998 - Pago por cuotas
   38.0       20/11/2013  JLV               38. 158945: LCOL_C004: Error en participación comisión oleoducto con co-corretaje.
   39.0       11/12/2013  FAL               39. 0026733: GIP800 - Incidencias reportadas 15/4
   40.0       19/05/2014  KBR               40. 0031458: POSPG100-Configuracion de IVA
   41.0       26/05/2014  JGR               41. 0029362: LCOL_C004-Error en comisiones Liberty Web - Nota: 175735
   42.0       25/06/2014  FBL               42. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   43.0       25/07/2014  RDD               43. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
   44.0       02/06/2015  VCG               42. 0036137: LAG8_895-Gastos de Expedición- Nota: 205750
   45.0       19/06/2015  VCG               45. AMA-209-Redondeo SRI
   46.0       19/06/2015  FAC               46. AMA-209-Redondeo SRI CONF-439 CONF_ADM-05_CAMBIOS_PROCESO_COMISIONES
   47.0       16/07/2019  JLTS              47. IAXIS-4160-Se elimina el redondeo de todo el proceso, solo se deja redondeo cuando se envía a la función f_insdetrec
   48.0       21/07/2019  DFR               48. IAXIS-3980: Gastos de expedición en endosos
   ******************************************************************************/

   /* SMF 15/09/2004
        {Se añaden los parametros funcion y tabla para el calculo del primer recibo al tarifar,
      el parametro tabla indica a que tablas tiene que ir a buscar importes ('EST','SOL',NULLL),
      el parametro función indica si estoy tarifando (TAR) o en la cartera o previo de cartera (CAR)}
   */

   -- ini Bug 0022027 - JMF - 24/04/2012
   vobj           VARCHAR2(500) := 'F_IMPRECIBOS';
   vpar           VARCHAR2(900)
      := 'p=' || pnproces || ' r=' || pnrecibo || ' t=' || ptipomovimiento || ' m=' || pmodo
         || ' r=' || pnriesgo || ' d=' || ppdtoord || ' r=' || pcrecfra || ' f=' || pcforpag
         || ' r=' || pcramo || ' m=' || pcmodali || ' t=' || pctipseg || ' c=' || pccolect
         || ' a=' || pcactivi || ' c=' || pcomisagente || ' r=' || pretenagente || ' s='
         || psseguro || ' c=' || pcmodcom || ' m=' || pmoneda || ' p=' || pprorata || ' t='
         || pttabla || ' f=' || pfuncion;
   vpas           NUMBER(5) := 0;
   -- fin Bug 0022027 - JMF - 24/04/2012
   error          NUMBER := 0;
   dummy          NUMBER;
   xcgarant       NUMBER;
   xnriesgo       NUMBER;
   xcageven       NUMBER;
   xnmovima       NUMBER;
   xprecarg       NUMBER;
   grabar         NUMBER;
   xiconcep       NUMBER;
   xcimpcon       NUMBER;
   xcimpdgs       NUMBER;
   xcimpips       NUMBER;
   xcimpcom       NUMBER;
   xcimpces       NUMBER;
   xcimparb       NUMBER;
   xcimpfng       NUMBER;
   xcderreg       NUMBER;
   iconcep0       NUMBER;
   xidtocam       NUMBER;
   iconcep21      NUMBER;
   idto           NUMBER;
   idto21         NUMBER;
   tot_iconcepdgs NUMBER;
   tot_iconcepips NUMBER;
   tot_iconceparb NUMBER;
   tot_iconcepfng NUMBER;
   tot_iconcepderreg NUMBER;
   -- I - jlb 03/11/2011
   tot_iconcep    NUMBER;
   viconcep0neto  NUMBER;
   -- F - jlb 03/11/2011
   taxadgs        NUMBER;
   taxaips        NUMBER;
   taxacon        NUMBER;
   taxaces        NUMBER;
   taxaarb        NUMBER;
   taxafng        NUMBER;
   taxaderreg     NUMBER;
   totrecfracc    NUMBER;
   comis_calc     NUMBER;
   reten_calc     NUMBER;
   xxiconcep      NUMBER;
   xploccoa       NUMBER;   -- COASEGURO
   xctipcoa       NUMBER;
   xncuacoa       NUMBER;
   xpcomcoa       NUMBER;
   xcrespue       NUMBER;
   porcagente     NUMBER;
   porragente     NUMBER;
   xips_fracc     NUMBER;
   xdgs_fracc     NUMBER;
   xarb_frac      NUMBER;
   ximp_boni      NUMBER;
   xfefecto       DATE;   --SMF
   xfeferec       DATE;
   xfefepol       DATE;   --17017
   xctiprec       NUMBER;   --17017
   --Bug 10851 - APD - 31/07/2009 -- se añade la variable xfefecrec
   xfvencim       DATE;   --SM
   totrecfracc_dgs NUMBER;
   xicapital      NUMBER;   -- DRA 27-8-08: bug mantis 7372
   xcempres       NUMBER;
   xnmovimi       NUMBER;
   vctipcon       NUMBER;
   vnvalcon       NUMBER;
   vcfracci       NUMBER;
   vcbonifi       NUMBER;
   vcrecfra       NUMBER;
   viconcep       NUMBER;
   vidto          NUMBER;
   oiconcep       NUMBER;
   vnerror        NUMBER;
   xccalcom       NUMBER;
   v_comian       NUMBER;
   -- Bug 17017 : se calculan las comisiones en el primer recibo ( NP)=
   xsproduc       productos.sproduc%TYPE;   --Bug.: 10709 - ICV - 16/07/09
   num_err        NUMBER;   --Bug.: 10709 - ICV - 16/07/09
   nmovren        movseguro.nmovimi%TYPE;   --Bug.: 10709 - ICV - 16/07/09
   vfefectmov     movseguro.fefecto%TYPE;   --Bug.: 10709 - ICV - 16/07/09
   fefeseg        DATE;   --Bug.: 10709 - ICV - 16/07/09
   v_tipfec       NUMBER;   --Bug.: 10709 - ICV - 16/07/09
   xfcaranu       DATE;   --Bug.: 10709 - DCT - 20/07/09
   -- Bug 10864.NMM.01/08/2009.
   w_climit       NUMBER;
   xcagente       NUMBER;   --Bug : 19586 - JMC - 10/10/2011
   vcageind       NUMBER;   --Bug : 19586 - JMC - 10/10/2011
   -- Bug 0019578 - FAL - 26/09/2011 - Aplicar arbitrios en función de la pregunta mercaderias peligrosas
   wcrespue       NUMBER := 0;
   v_cempres      NUMBER := pac_parametros.f_parinstalacion_n('EMPRESADEF');
   v_preg_merca_pelig NUMBER;
   w_aplica_arbrit NUMBER := 0;
   w_aplica_impost_x_preg NUMBER := 0;
   -- Fi Bug 0019578
   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
   v_femisio      DATE;
   v_cmultimon    parempresas.nvalpar%TYPE;
   v_cmonemp      parempresas.nvalpar%TYPE;
   v_cmonpol      monedas.cmoneda%TYPE;
   v_cmonimp      imprec.cmoneda%TYPE;
   v_fcambio      DATE;
   v_itasa        eco_tipocambio.itasa%TYPE;
   v_fcambioo     DATE;
   iconcep0_monpol NUMBER;
   iconcep21_monpol NUMBER;
   idto_monpol    NUMBER;
   idto21_monpol  NUMBER;
   xidtocam_monpol NUMBER;
   xicapital_monpol NUMBER;
   oiconcep_monpol NUMBER;
   v_iconcep_monpol NUMBER;
   tot_iconcepdgs_monpol NUMBER;
   tot_iconcepips_monpol NUMBER;
   tot_iconceparb_monpol NUMBER;
   tot_iconcepfng_monpol NUMBER;
   tot_iconcepderreg_monpol NUMBER;
   totrecfracc_monpol NUMBER;
   -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
   v_fefectovig   DATE;   --BUG20342 - JTS - 02/12/2011
   v_sproduc      NUMBER;   --BUG20342 - JTS - 02/12/2011
   v_fefectopol   DATE;   --BUG20342 - JTS - 02/12/2011
   vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011
-- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Comisión 0 en diferencia de provisión
   v_sup_pm_gar   NUMBER;
   vdifprovision  BOOLEAN := FALSE;
   vcrespue       NUMBER;
   --vtrespue pregunpolseg.trespue%TYPE;
-- Fi BUG 20672-  01/2012 - JRH
   v_fefectorec   DATE;   -- Bug 20384 - APD - 09/01/2012
   vccomind       agentes.ccomisi_indirect%TYPE;   --Bug : 20999 - APD - 26/01/2012
   vcmodcom       comisionprod.cmodcom%TYPE;   --Bug : 20999 - APD - 26/01/2012
   vcage_padre    redcomercial.cpadre%TYPE;   --Bug : 20999 - APD - 26/01/2012
   vmodo_comind   NUMBER;   --Bug : 20999 - APD - 26/01/2012
   -- Bug 21167 - RSC - 03/02/2012 - LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera
   v_nanuali      seguros.nanuali%TYPE;
   -- Bug 21435 - FAL - 16/03/2012
   v_fcarpro      DATE;
   v_fcaranu      DATE;
   w_nanuali      NUMBER;
   -- Fi Bug 21435
   iconcep8       NUMBER;   -- BUG22255:DRA:18/05/2012
   iconcep8_monpol NUMBER;   -- BUG22255:DRA:18/05/2012
-- JLB - I - 23074
   xnfracci       recibos.nfracci%TYPE;
   xnanuali       recibos.nanuali%TYPE;
   vcagastexp     seguroscol.cagastexp%TYPE := 0;
   vcperiogast    seguroscol.cperiogast%TYPE := 0;
   vcsubpro       productos.csubpro%TYPE;
   v_gastexp_calculo NUMBER;
-- JLB - F - 23074

   -- Fin bug 21167
   tot_iconcepivaderreg NUMBER;   -- Bug 23074 - APD - 01/08/2012
   tot_iconcepivaderreg_monpol NUMBER;   -- Bug 23074 - APD - 01/08/2012
   taxaivaderreg  NUMBER;   -- Bug 23074 - APD - 01/08/2012
   v_sobrecomis   NUMBER(1);   -- BUG 25988 - FAL - 13/02/2013
   v_pcomisi      comconvenios_mod.pcomisi%TYPE;   -- BUG 25988 - FAL - 13/02/2013
   -- bug 0025826
   v_res4093      pregunpolseg.crespue%TYPE;
   v_res4094      pregunpolseg.crespue%TYPE;
   v_res9800      pregunseg.crespue%TYPE; --IAXIS-3980 21/07/2019
   d_ini          DATE;
   d_fin          DATE;
   d_renova       seguros.frenova%TYPE;
   d_caranu       seguros.fcaranu%TYPE;
   n_div          NUMBER;
   n_error        NUMBER;
   v_iconcep      NUMBER;
   v_ppartici     NUMBER;
   v_ctipage      NUMBER;
   v_iconcep_monpol_1 NUMBER;
   -- INI Bug 27067 - AFM - 13/06/2013
   ppcomisi_concep comisiongar_concep.pcomisi%TYPE;
   concep_concep  detrecibos.cconcep%TYPE;
   comis_calc_concep detrecibos.iconcep%TYPE;
   comis_calc_concep_monpol detrecibos.iconcep_monpol%TYPE;
   vsumcomis      detrecibos.iconcep%TYPE;
   vsumcomis_monpol detrecibos.iconcep_monpol%TYPE;
   vsumporcage    comisiongar.pcomisi%TYPE;
   v_ploccoa_ivaced NUMBER;   --KBR 19/05/2014  31458
-- FBL. 25/06/2014 MSV Bug 0028974
   v_comisi_total NUMBER;
   v_comisi_monpol_total NUMBER;
   v_ctipcom      NUMBER;
   v_prorrata_net NUMBER;
   v_prorrata_dev NUMBER;
   v_modcal       VARCHAR2(100);
   v_genera_indirecta NUMBER;
   b_primerderreg     BOOLEAN := TRUE;
   n_derreg_poliza    NUMBER;
   vcprovin NUMBER; -- BUG 1970 AP
   vcpoblac NUMBER; -- BUG 1970 AP
   --INI IAXIS-4160 - JLTS - 14/06/2019. Se incluye cdivisa
   vcdivisa PRODUCTOS.CDIVISA%TYPE:=0; 
   --FIN IAXIS-4160 - JLTS - 14/06/2019. Se incluye cdivisa

-- Fin FBL. 25/06/2014 MSV Bug 0028974

   -- FINI Bug 27067 - AFM - 13/06/2013
   CURSOR cur_detrecibos IS
      SELECT   nriesgo, cgarant, cageven, nmovima
          FROM detrecibos
         WHERE nrecibo = pnrecibo
      GROUP BY nriesgo, cgarant, cageven, nmovima;

   CURSOR cur_detreciboscar IS
      SELECT   nriesgo, cgarant, cageven, nmovima
          FROM detreciboscar
         WHERE sproces = pnproces
           AND nrecibo = pnrecibo
           AND nriesgo = NVL(pnriesgo, nriesgo)
      GROUP BY nriesgo, cgarant, cageven, nmovima;

   -- BUG 26835 - FAL - 06/05/2013
   FUNCTION f_control_carbritrios(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'psseguro = ' || psseguro || '; pnmovimi = ' || pnmovimi || '; pnriesgo = '
            || pnriesgo || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.f_control_carbritrios';
      num_err        NUMBER;
      v_cempres      NUMBER;
      v_crespue8023  pregunseg.crespue%TYPE;
   BEGIN
      v_cempres := pac_parametros.f_parinstalacion_n('EMPRESADEF');

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'IMPOST_PER_PREG'), 0) = 1
         AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'PREG_MERCA_PELIG'), 0) <> 0 THEN
         num_err :=
            pac_preguntas.f_get_pregunseg(psseguro, pnriesgo,
                                          pac_parametros.f_parempresa_n(v_cempres,
                                                                        'PREG_MERCA_PELIG'),
                                          'SEG', v_crespue8023);

         IF v_crespue8023 IS NULL
            AND num_err = 0 THEN
            num_err :=
               pac_preguntas.f_get_pregunpolseg
                                           (psseguro,
                                            pac_parametros.f_parempresa_n(v_cempres,
                                                                          'PREG_MERCA_PELIG'),
                                            'SEG', v_crespue8023);

            IF v_crespue8023 = 2
               AND num_err = 0 THEN
               RETURN 1;   -- para que no calcule los arbitrios
            END IF;
         END IF;

         IF v_crespue8023 = 2
            AND num_err = 0 THEN
            RETURN 1;   -- para que no calcule los arbitrios
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 0;
   END f_control_carbritrios;

-- FI BUG 26835 - FAL - 06/05/2013
   FUNCTION f_control_cderreg(
      psseguro NUMBER,
      pnriesgo NUMBER,
      pcgarant NUMBER,
      pfefecto DATE,
      pnmovima NUMBER,
      ptipomovimiento NUMBER)
      RETURN NUMBER IS
       /*
          /FUNCIÓN QUE NOS INDICA SI ES LA PRIMERA VEZ QUE SE CONTRATA UNA GARANTIA./
        /SI ES LA PRIMERA VEZ QUE SE CONTRATA Y LA GARANTIA TIENE INFORMADO EL
      CDERREG = 1 (SI GENERA DERECHOS), Y LOS DERECHOS NO SE HAN INCLUIDO EN
      NINGÚN RECIBO EN SITUACIÓN PENDIENTE O COBRADO HASTA EL MOMENTO RETORNAMOS UN 0 */
      v_cont         NUMBER;
      v_cderreg      NUMBER;
      v_resultado    NUMBER := 0;
      wcrespue       NUMBER := 0;
      -- Bug 0019578 - FAL - 26/09/2011 - Aplicar derechos de registro en función de la pregunta gastos de emisión.
      v_preg_gast_emi NUMBER;
      w_aplica_derreg NUMBER := 0;
      wnumgaraplicderreg NUMBER := 0;

      CURSOR cur IS
         SELECT nrecibo
           FROM recibos
          WHERE sseguro = psseguro
            AND f_cestrec(nrecibo, NULL) IN(0, 1, 3);

      CURSOR curcar IS
         SELECT nrecibo
           FROM reciboscar
          WHERE sseguro = psseguro
            AND sproces = pnproces;

      CURSOR car IS
         SELECT nrecibo
           FROM recibos
          WHERE sseguro = psseguro
            AND nmovimi >= (SELECT MAX(b.nmovimi)
                              FROM movseguro b
                             WHERE b.sseguro = psseguro
                               AND b.cmovseg IN(0, 2)
                               AND b.fefecto <= pfefecto)
            AND f_cestrec(nrecibo, NULL) IN(0, 1, 3);

      CURSOR rebcar IS
         SELECT nrecibo
           FROM reciboscar
          WHERE sseguro = psseguro
            AND sproces = pnproces
            AND nrecibo = pnrecibo;

--            AND nmovimi >= (SELECT MAX(b.nmovimi)
--                              FROM movseguro b
--                             WHERE b.sseguro = psseguro
--                               AND b.cmovseg IN(0, 2)
--                               AND b.fefecto <= pfefecto);
--
      valor          NUMBER;
      vncertif       seguros.ncertif%TYPE;
      vctipcoa       seguros.ctipcoa%TYPE;
      v_crespue9082  pregungaranseg.crespue%TYPE;   -- BUG 0026835 - FAL - 06/05/2013
      w_fefecto      recibos.fefecto%TYPE; -- bug AMA-415 - FAL - 13/07/2016
   BEGIN
      vpas := 1000;
      -- Inicio IAXIS-3980 21/07/2019
      n_error := pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 9800, 'SEG', v_res9800);
      v_res9800 := NVL(v_res9800, 2);
      -- Fin IAXIS-3980 21/07/2019
      -- Bug 23074 - APD - 07/08/2012 - se busca el cderreg de la parametrizacion de
      -- garanpro, pues en el caso de las polizas individuales de las polizas colectivas
      -- no se propaga correctamente el valor de garanpro.cderreg a garanseg.cderreg
      BEGIN
         vpas := 1001;

         SELECT NVL(g.cderreg, 0)
           INTO v_cderreg
           FROM garanpro g, seguros s
          WHERE g.cramo = s.cramo
            AND g.cmodali = s.cmodali
            AND g.ccolect = s.ccolect
            AND g.ctipseg = s.ctipseg
            AND g.cactivi = pac_seguros.ff_get_actividad(psseguro, pnriesgo)
            AND g.cgarant = pcgarant
            AND s.sseguro = psseguro;
      --si cderreg no es 1, no hay que aplicar los derechos de generación
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            BEGIN
               vpas := 1002;

               SELECT NVL(g.cderreg, 0)
                 INTO v_cderreg
                 FROM garanpro g, seguros s
                WHERE g.cramo = s.cramo
                  AND g.cmodali = s.cmodali
                  AND g.ccolect = s.ccolect
                  AND g.ctipseg = s.ctipseg
                  AND g.cactivi = 0
                  AND g.cgarant = pcgarant
                  AND s.sseguro = psseguro;
            --si cderreg no es 1, no hay que aplicar los derechos de generación
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  RETURN 1;
               --SMF: si no se encuentra nada no hay registro de derechos.
               WHEN OTHERS THEN
                  RETURN 1;
            --SMF: si no se encuentra nada no hay registro de derechos.
            END;
         WHEN OTHERS THEN
            RETURN 1;
      --SMF: si no se encuentra nada no hay registro de derechos.
      END;

      -- fin Bug 23074 - APD - 07/08/2012
      IF v_cderreg = 1 THEN
         -- BUG 0026835 - FAL - 06/05/2013
         v_cempres := pac_parametros.f_parinstalacion_n('EMPRESADEF');

         IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'IMPOST_PER_PREG'), 0) = 1
            AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'PREG_GASTO_EMI'), 0) <> 0 THEN
            v_crespue9082 := NVL(pac_preguntas.f_get_pregungaranseg_v(psseguro, pcgarant,
                                                                      pnriesgo, 9082, 'SEG',
                                                                      NULL),
                                 0);

            IF v_crespue9082 = 0 THEN
               RETURN 1;   -- para que no calcule los gastos de expedicion
            ELSIF v_crespue9082 = 1
                  AND xctiprec = 3 THEN   -- BUG 26733 - FAL - 11/12/2013
               RETURN 1;
            -- FI BUG 26733 - FAL - 11/12/2013
            END IF;
         END IF;

         -- FI BUG 0026835 - FAL - 06/05/2013
         vpas := 1010;

         SELECT MAX(NVL(ncertif, 0)), MAX(ctipcoa)
           INTO vncertif, vctipcoa
           FROM seguros
          WHERE sseguro = psseguro;

         IF v_res4093 = 0
            OR v_gastexp_calculo = 0 THEN
            RETURN 1;
         ELSIF v_res4093 = 1
               AND NVL(vncertif, 0) <> 0 THEN
            RETURN 1;
         ELSIF vctipcoa = 8 THEN
            -- coaseguro, no calcular
            RETURN 1;
         --BUG27048 - INICIO - DCT - 0027048: LCOL_T010-Revision incidencias qtracker (V)
         ELSIF v_res4094 = 1 THEN
            IF ptipomovimiento IN(0, 21, 22) THEN
               RETURN 0;   --Calcula gastos
            ELSE
               RETURN 1;   --No calcula gastos
            END IF;
         -- Inicio IAXIS-3980 21/07/2019
         ELSIF (v_res9800 = 1 AND pac_iax_produccion.issuplem) THEN
           RETURN 0; --Calcula gastos
         -- Fin IAXIS-3980 21/07/2019
         --BUG27048 - FIN - DCT - 0027048: LCOL_T010-Revision incidencias qtracker (V)
         ELSIF v_res4094 = 2 THEN
            -- Anual
            IF v_gastexp_calculo = 1 THEN
               -- Nueva produccion

               -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
               v_cont := pac_seguros.f_es_migracion(psseguro, 'SEG', valor);

               IF v_cont = 0 THEN
                  IF valor <> 0 THEN
                     RETURN 1;
                  --  Si estamos en migración  no debe generar derechos de registro
                  END IF;
               ELSE
                  --Error, difñicil que suceda, pero por si acaso hacemos un raise para que savuelva a la función anterior
                  p_tab_error(f_sysdate, f_user, vobj, 1,
                              'seg=' || psseguro || ' cont=' || v_cont || ' val=' || valor,
                              'Error en pac_seguros.f_es_migracion');
                  RAISE NO_DATA_FOUND;
               END IF;

               v_resultado := 0;

               IF pfuncion = 'CAR' THEN
                  FOR c IN curcar LOOP
                     vpas := 1050;

                     SELECT COUNT(1)
                       INTO v_cont
                       FROM detreciboscar
                      WHERE nrecibo = c.nrecibo
                        AND cgarant = pcgarant
                        AND NVL(nmovima, -1) = NVL(pnmovima, -1)   --JLV Bug 27311. 22/07/2013
                        AND cconcep = 14
                        AND nriesgo = pnriesgo;

                     v_resultado := NVL(v_resultado, 0) + v_cont;
                  END LOOP;
               ELSE
                  FOR c IN cur LOOP
                     vpas := 1050;

                     SELECT COUNT(1)
                       INTO v_cont
                       FROM detrecibos
                      WHERE nrecibo = c.nrecibo
                        --AND cgarant = pcgarant--VCG Bug 36137. 02/06/2015
                        AND NVL(nmovima, -1) = NVL(pnmovima, -1)   --JLV Bug 27311. 22/07/2013
                        AND cconcep = 14
                        AND nriesgo = pnriesgo;

                     v_resultado := NVL(v_resultado, 0) + v_cont;
                  END LOOP;
               END IF;

               RETURN v_resultado;
            ELSIF v_gastexp_calculo = 2 THEN
               -- Nueva produccion y Cartera
               v_resultado := 0;

               -- bug AMA-415 - FAL - 13/07/2016
               SELECT fcaranu
                 INTO v_fcaranu
                 FROM seguros
                WHERE sseguro = psseguro;
              -- bug AMA-415 - FAL - 13/07/2016

               -- INI bug AMA-415 - FAL - 13/07/2016 - sóo en el previo cartera y si el efecto del recibo = renovacion anual buscar en detreciboscar
               -- IF pfuncion = 'CAR' THEN
               IF (pmodo = 'P') THEN

                  begin
                     select fefecto into w_fefecto
                     from reciboscar
                     where nrecibo = pnrecibo;
                  exception
                    when no_data_found then
                       w_fefecto:= null;
                  end;

                  IF trunc(w_fefecto) = trunc(v_fcaranu) THEN
                  -- FI bug AMA-415 - FAL - 13/07/2016 - sóo en el previo cartera y si el efecto del recibo = renovacion anual buscar en detreciboscar

                      FOR c IN rebcar LOOP
                         vpas := 1050;

                         SELECT COUNT(1)
                           INTO v_cont
                           FROM detreciboscar
                          WHERE nrecibo = c.nrecibo
                            --AND cgarant = pcgarant--VCG Bug 36137. 02/06/2015
                            AND NVL(nmovima, -1) = NVL(pnmovima, -1)   --JLV Bug 27311. 22/07/2013
                            AND cconcep = 14
                            AND nriesgo = pnriesgo;

                         v_resultado := NVL(v_resultado, 0) + v_cont;
                      END LOOP;
                  END IF;

                  RETURN v_resultado;
               ELSE
                  FOR c IN car LOOP
                     vpas := 1050;

                     SELECT COUNT(1)
                       INTO v_cont
                       FROM detrecibos
                      WHERE nrecibo = c.nrecibo
                        --AND cgarant = pcgarant--VCG Bug 36137. 02/06/2015
                        AND NVL(nmovima, -1) = NVL(pnmovima, -1)   --JLV Bug 27311. 22/07/2013
                        AND cconcep = 14
                        AND nriesgo = pnriesgo;

                     v_resultado := NVL(v_resultado, 0) + v_cont;
                  END LOOP;

                  RETURN v_resultado;
               END IF;
            ELSE
               -- No calcula
               RETURN 1;
            END IF;
         END IF;

         RETURN 0;
      ELSE
         RETURN 1;
      --si cderreg no es 1, no hay que aplicar los derechos de generación
      END IF;
   END f_control_cderreg;

BEGIN
   vpas := 1070;

   -- ACCESO A PARINSTALACION
   -- s'ha d'aplicar l'ips al recarrec de fracionament 0-No 1-Si
   --   xips_fracc := f_parinstalacion_n ('IPS_FRACC');
   -- s'ha de fraccionar els arbitris 0-No 1-Si
   --   xarb_frac := f_parinstalacion_n ('ARB_FRAC');
   -- Els impostos : clea, arbitris s'apliquen sobre la prima bonificada o no
   --   ximp_boni := f_parinstalacion_n ('IMP_BONI');
   -- s'ha d'aplicar DGS (CLEA) al recarrec de fracionament 0-No 1-Si
   --   xdgs_fracc := f_parinstalacion_n ('CLEA_FRACC');

   --Bug.: 10709 - ICV - 16/07/09 - Se añade la recuperación del producto
   BEGIN
      vpas := 1080;

      -- 23074 -- JLB - I
      --INI IAXIS-4160 - JLTS - 14/06/2019. Se incluye cdivisa
      SELECT ccalcom, sproduc, csubpro, cdivisa
        INTO xccalcom, xsproduc, vcsubpro, vcdivisa
        FROM productos
       WHERE cramo = pcramo
         AND cmodali = pcmodali
         AND ctipseg = pctipseg
         AND ccolect = pccolect;
      --FIN IAXIS-4160 - JLTS - 14/06/2019. Se incluye cdivisa
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 104347;   -- Producte no trobat a PRODUCTOS
      WHEN OTHERS THEN
         RETURN 102705;   -- Error al llegir de PRODUCTOS
   END;

   v_gastexp_calculo := NVL(f_parproductos_v(xsproduc, 'GASTEXP_CALCULO'), 0);
   n_derreg_poliza   := NVL(pac_parametros.f_parproducto_n(xsproduc, 'DERREG_POLIZA'), 0);

   --BUSCAMOS EL PORCENTAJE LOCAL SI ES UN COASEGURO.
   IF pfuncion = 'CAR' THEN
      vpas := 1090;

      SELECT ctipcoa, ncuacoa
        INTO xctipcoa, xncuacoa
        FROM seguros
       WHERE sseguro = psseguro;
   END IF;

   IF xctipcoa != 0 THEN
      vpas := 1100;

      SELECT ploccoa
        INTO xploccoa
        FROM coacuadro
       WHERE ncuacoa = xncuacoa
         AND sseguro = psseguro;
   END IF;

   --COASEGURO ACEPTADO NO NOS INTERESA APLICAR DOS VECES EL PORCENTAJE LOCAL
   IF xctipcoa = 8
      OR xctipcoa = 9 THEN
      xploccoa := 100;
   END IF;

   -- bug0025826
   -- 4093 Aplica gastos de expedición
   n_error := pac_preguntas.f_get_pregunpolseg(psseguro, 4093, 'SEG', v_res4093);
   v_res4093 := NVL(v_res4093, 2);
   -- 4094 Periodicidad de los gastos
   n_error := pac_preguntas.f_get_pregunpolseg(psseguro, 4094, 'SEG', v_res4094);
   v_res4094 := NVL(v_res4094, 2);

   -- DESCOMPTES (CCONCEP = 13) -- CALCUL IMPOSTOS
   -- DGS, IPS, BOMBERS(ARBITRIS), FNG (CCONCEP = 5, 4, 6 I 7) I DERREG (14)
   -- Bug 19096 - RSC - 03/08/2011 - LCOL - Parametrización básica producto Vida Individual Pagos Permanentes (Afegim 'RRIE')
-- FBL. 25/06/2014 MSV Bug 0028974
   IF pmodo = 'R' THEN
      v_modcal := 'NP';
   ELSE
      v_modcal := 'CAR';
   END IF;

-- Fin FBL. 25/06/2014 MSV Bug 0028974
   IF pmodo = 'R'
      OR pmodo = 'H'
      OR pmodo IN('A', 'ANP')
      OR pmodo = 'RRIE' THEN   -- (MODE REAL PRODUCCIÓ I CARTERA)
      --SMF. (ALN) NECESSITAMOS LA FECHA DE EFECTO DEL RECIBO PARA LOS DERECHOS
      --DE REGISTRO.
      vpas := 1100;

      SELECT fefecto, fvencim, cempres, nmovimi, ctiprec, cagente, femisio,
             cempres
                    -- 23074 -- JLB - I
      ,      nfracci, nanuali
        -- 23074 -- JLB - F
      INTO   xfefecto, xfvencim, xcempres, xnmovimi, xctiprec, xcagente, v_femisio,
             v_cempres
                      -- 23074 -- JLB - I
      ,      xnfracci, xnanuali
        -- 23074 -- JLB - F
      FROM   recibos
       WHERE nrecibo = pnrecibo;

      -- Bug 20384 - APD - 09/01/2012 - se guarda la fecha efecto del recibo necesaria
      -- para pasarla a la funcion f_pcomisi
      -- aunque se busca tambien en la select de arriba, se vuelve a buscar ya que la
      -- variable xfefecto puede cambiar luego de valor y no ser por tanto la fecha
      -- de efecto real del recibo
      vpas := 1110;

      SELECT fefecto
        INTO v_fefectorec
        FROM recibos
       WHERE nrecibo = pnrecibo;

      -- fin Bug 20384 - APD - 09/01/2012
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(xcempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 1 THEN
         v_cmonemp := pac_parametros.f_parempresa_n(xcempres, 'MONEDAEMP');
         vpas := 1120;

         SELECT NVL(cmoneda, v_cmonemp)
           INTO v_cmonpol
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda

      --Bug 10851 - APD - 31/07/2009 - se guarda en la variable xfeferec la fecha de efecto del recibo
      -- la variable xfefecto se utiliza para guardar la fecha de efecto de la vigencia de los recargos
      -- e impuestos que se deben aplicar.
      xfeferec := xfefecto;
      --Bug.: 10709 - ICV - 16/07/09 - Se elige la fecha de impuestos dependiendo de parametro.
      -- si es del tipo 1 fecha efecto del recibo no se hace nada
      v_tipfec := pac_parametros.f_parproducto_n(xsproduc, 'FECHA_IMPUESTOS');
      v_comian := NVL(pac_parametros.f_parproducto_n(xsproduc, 'COMISANU'), 0);

      -- bug 17017
      IF v_tipfec = 0 THEN   --f_ultrenova
         num_err := f_ultrenova(psseguro, xfefecto, xfefecto, nmovren);

         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'f_imprecibos', 1,
                        'psseguro : ' || psseguro || ' pmodo : ' || pmodo, SQLERRM);
            RETURN num_err;
         END IF;
      ELSIF v_tipfec = 2 THEN   --efecto del seguro
         vpas := 1130;

         SELECT fefecto
           INTO xfefecto
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- BUG 17017
      vpas := 1140;

      -- FBL. 25/06/2014 MSV Bug 0028974
      SELECT fefecto, ctipcom
        INTO xfefepol, v_ctipcom
        FROM seguros
       WHERE sseguro = psseguro;

      -- Fin FBL. 25/06/2014 MSV Bug 0028974

      -- FIN BUG 17017

      --Fi bug.: 10709
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      IF v_cmultimon = 1 THEN
         num_err := pac_oper_monedas.f_contravalores_recibo(pnrecibo, pmodo);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpas := 1150;

         SELECT NVL(MAX(fcambio), v_femisio)
           INTO v_fcambio
           FROM detrecibos
          WHERE nrecibo = pnrecibo;

         num_err := pac_oper_monedas.f_datos_contraval(NULL, pnrecibo, NULL, v_fcambio, 1,
                                                       v_itasa, v_fcambioo);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda

      --
      vpas := 1160;

      OPEN cur_detrecibos;

      FETCH cur_detrecibos
       INTO xnriesgo, xcgarant, xcageven, xnmovima;

      WHILE cur_detrecibos%FOUND LOOP
         vpas := 1170;
         iconcep0 := 0;
         iconcep0_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
         iconcep21 := 0;
         iconcep21_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
         idto := 0;
         idto_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
         xprecarg := 0;
         taxaips := 0;
         taxadgs := 0;
         taxaarb := 0;
         taxafng := 0;
         xcimpips := 0;
         xcimparb := 0;
         xcimpdgs := 0;
         xcimpfng := 0;
         xcrespue := 1;
         totrecfracc := 0;
         totrecfracc_dgs := 0;

-- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  Comisión 0 en diferencia de provisión
         IF ptipomovimiento = 11 THEN
            v_sup_pm_gar := NVL(f_pargaranpro_v(pcramo, pcmodali, pctipseg, pccolect,
                                                pcactivi, xcgarant, 'REC_SUP_PM_GAR'),
                                1);

            IF v_sup_pm_gar = 1 THEN
               vdifprovision := TRUE;
            ELSIF v_sup_pm_gar = 2 THEN
               vpas := 1180;
               error := pac_preguntas.f_get_pregungaranseg(psseguro, xcgarant,
                                                           NVL(pnriesgo, 1), 4045, 'SEG',
                                                           vcrespue);

               IF error NOT IN(0, 120135) THEN
                  RETURN 110420;
               END IF;

               IF NVL(vcrespue, 0) = 1 THEN
                  vdifprovision := TRUE;
               ELSE
                  vdifprovision := FALSE;
               END IF;
            ELSE
               vdifprovision := FALSE;
            END IF;
         ELSE
            vdifprovision := FALSE;   --APlica diferencia de provisión
         END IF;

-- Fi BUG 20672-  01/2012 - JRH
         IF ptipomovimiento IN(0, 1, 6, 21, 22, 11) THEN
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 0
            BEGIN
               vpas := 1190;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO iconcep0, iconcep0_monpol
                   FROM detrecibos
                  WHERE nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cconcep IN(0, 50)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;

               xiconcep := iconcep0;
               grabar := 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
                  grabar := 0;
               WHEN OTHERS THEN
                  CLOSE cur_detrecibos;

                  error := 103512;   -- ERROR AL LLEGIR DE DETRECIBOS
                  RETURN error;
            END;

            IF NVL(ppdtoord, 0) <> 0 THEN
               IF grabar = 1 THEN   --CALCULEM EL DESCOMPTE O.M. (CCONCEP=13)
                  xxiconcep := (xiconcep * ppdtoord) / 100;

                  IF NVL(xxiconcep, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        vpas := 1200;
                        v_iconcep_monpol := (iconcep0_monpol * ppdtoord) / 100;
                        vpas := 1210;
                        error := f_insdetrec(pnrecibo, 13, xxiconcep, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             0, 0, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 1220;
                        error := f_insdetrec(pnrecibo, 13, xxiconcep, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            END IF;

            --BUG9658 -- 02/04/2009 -- JTS
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 17
            IF error = 0 THEN
               DECLARE
                  v_diasvigencia NUMBER(3);
                  v_iconcep17    detrecibos.iconcep_monpol%TYPE;   --NUMBER(15, 2); ampliación decimales

                  -- Bug 10865 - RSC - 04/08/2009 - APR: error en comisiones de adquisición
                  CURSOR cur_comisigaranseg IS
                     SELECT *
                       FROM comisigaranseg
                      WHERE sseguro = psseguro
                        --AND nmovimi = xnmovimi -- Bug 10865
                        AND finiefe <= xfeferec
                        AND ffinpg > xfeferec
                        -- Bug 13515 - 10/03/2010 - RSC - APR - Error en el calculo de comisiones
                        AND cgarant = xcgarant
                        AND itotcom > 0;
               -- Bug 10865 - RSC - 10/08/2009 - APR: error en comisiones de adquisición
               -- Fin Bug 10865
               BEGIN
                  vpas := 1230;

                  FOR i IN cur_comisigaranseg LOOP
                     -- Bug 10851 - APD - 31/07/2009 - se le debe pasar la xfeferec a la funcion
                     -- f_difdata en vez de xfefecto
                     vpas := 1240;
                     error := f_difdata(xfeferec, xfvencim, 3, 3, v_diasvigencia);
                     v_iconcep17 := i.icomanu *(v_diasvigencia / 360);

                     IF NVL(v_iconcep17, 0) <> 0 THEN
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        IF v_cmultimon = 1 THEN
                           v_iconcep_monpol := v_iconcep17 * v_itasa;
                           vpas := 1250;
                           error := f_insdetrec(pnrecibo, 17, v_iconcep17, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        ELSE
                           -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                           vpas := 1260;
                           error := f_insdetrec(pnrecibo, 17, v_iconcep17, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro);
                        END IF;

                        IF error != 0 THEN
                           CLOSE cur_detrecibos;

                           RETURN error;
                        END IF;
                     END IF;
                  END LOOP;
               END;
            ELSE
               CLOSE cur_detrecibos;

               RETURN error;
            END IF;

            --BUG9658 -- 02/04/2009 -- JTS

            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 29
            --SMF CONCEPTO DE CAMPANYES
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 29
            vpas := 1270;
            error := f_calculo_dtocampanya(psseguro, xnriesgo, xcgarant, xnmovima, xfvencim,
                                           iconcep0, pprorata, xidtocam);
            xidtocam_monpol := xidtocam * v_itasa;

            --  BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            IF error = 0 THEN
               IF NVL(xidtocam, 0) <> 0 THEN
                  xidtocam := xidtocam;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := xidtocam_monpol;
                     vpas := 1280;
                     error := f_insdetrec(pnrecibo, 29, xidtocam, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1290;
                     error := f_insdetrec(pnrecibo, 29, xidtocam, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            ELSE
               CLOSE cur_detrecibos;

               RETURN error;
            END IF;

            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 21
            BEGIN
               vpas := 1300;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO iconcep21, iconcep21_monpol
                   FROM detrecibos
                  WHERE nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cconcep IN(21, 71)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detrecibos;

                  error := 103512;   -- ERROR AL LLEGIR DE DETRECIBOS
                  RETURN error;
            END;

            -- TROBEM EL CONCEPTE DE LA BONIFICACIÓ DEL REBUT
            BEGIN
               vpas := 1310;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO idto, idto_monpol
                   FROM detrecibos
                  WHERE nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cconcep IN(10 + 60)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detrecibos;

                  error := 103512;   -- ERROR AL LLEGIR DE DETRECIBOS
                  RETURN error;
            END;

            IF pcforpag <> 1
               AND iconcep21 <> 0 THEN
               -- Si no és anual i és el primer rebut
               -- necessitem la bonif. anualitzada
               -- TROBEM EL CONCEPTE DE LA BONIFICACIÓ ANUALITZADA
               BEGIN
                  vpas := 1320;

                  SELECT SUM(idtocom * -1)
                    INTO idto21
                    FROM garanseg
                   WHERE (sseguro, nmovimi) IN(SELECT sseguro, nmovimi
                                                 FROM recibos
                                                WHERE nrecibo = pnrecibo)
                     AND nriesgo = xnriesgo
                     AND cgarant = xcgarant;

                  idto21_monpol := idto21 * v_itasa;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE cur_detrecibos;

                     error := 107209;   -- ERROR AL LLEGIR DE GARANSEG
                     RETURN error;
               END;
            ELSE
               vpas := 1330;

               IF pcforpag = 1 THEN
                  -- Si és anual coincideix amb la del rebut
                  idto21 := idto;
                  idto21_monpol := idto_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  -- concepte 21 = 0
                  idto21 := 0;
                  idto21_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               END IF;
            END IF;

            -- Bug 0020314 - FAL - 29/11/2011 - Se sube arriba el recuperar si aplica que impuestos
            BEGIN
               vpas := 1340;

               SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                      NVL(cimpfng, 0)
                 INTO xcimpdgs, xcimpips, xcderreg, xcimparb,
                      xcimpfng
                 FROM garanpro
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ccolect = pccolect
                  AND ctipseg = pctipseg
                  AND cgarant = xcgarant
                  AND cactivi = NVL(pcactivi, 0);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     vpas := 1350;

                     SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0),
                            NVL(cimparb, 0), NVL(cimpfng, 0)
                       INTO xcimpdgs, xcimpips, xcderreg,
                            xcimparb, xcimpfng
                       FROM garanpro
                      WHERE cramo = pcramo
                        AND cmodali = pcmodali
                        AND ccolect = pccolect
                        AND ctipseg = pctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detrecibos;

                        error := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        error := 103503;
                        -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN error;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detrecibos;

                  error := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN error;
            END;

            -- Fin Bug 0020314 - FAL - 29/11/2011

            -- BUG 9422 - 14/10/2009 - LCF - Se comenta
            -- Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro
            IF xcderreg > 0 THEN
               -- Bug 0019578 - FAL - 26/09/2011. Incluir llamada concepto 14 (derechos registro)
               vpas := 1360;
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepderreg := NULL;
               tot_iconcepderreg_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        -- Fi Bug 0019578
                        -- Bug 19557 - APD - 31/10/2011 - de momento para Liberty, los gastos de
                        -- expedicion se calculan de manera diferente que para el resto de empresas
                        -- (se deben calcular sin tener en cuenta la tabla TARIFAS)
                        -- por eso se crea el parempresa 'MODO_CALC_GASTEXP'
                        -- El importe de los gastos de expedicion sólo se debe calcular en el
                        -- momento de la emisión ('GASTEXP_CALCULO' = 1 (indica que si se debe calcular
                        -- el importe de los gastos de expedicion para el producto) y
                        -- ptipomovimiento = 0.-Nueva produccion para que sólo se calcule en el momento
                        -- de la emisión)
               vpas := 1370;

               IF f_control_cderreg(psseguro, xnriesgo, xcgarant, xfeferec, xnmovima,
                                    ptipomovimiento) = 0 AND NOT (b_primerderreg = FALSE AND n_derreg_poliza = 1) THEN
                 --Se añade condición para el caso de que los gastos de expedición se apliquen a nivel de póliza y no de garantia
                 b_primerderreg := FALSE;
                  -- BUG 20671-  01/2012 - JRH  -  0020671: Usamos   f_control_cderreg  porque hay veces que si ha de generar gastos
                  -- Fi BUG 20671-  01/2012 - JRH
                  -- Bug 10864.NMM.01/08/2009.
                  -- BUG 18423: LCOL000 - Multimoneda
                  -- Bug 0020314 - FAL - 29/11/2011
                  vpas := 1380;
                  error := f_concepto(14, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                      pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                      vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,
                                      v_cmonimp, vcderreg);

                  IF error <> 0 THEN
                     CLOSE cur_detrecibos;

                     p_tab_error(f_sysdate, f_user, vobj, vpas,
                                 'error ' || error || '.-' || f_axis_literales(error)
                                 || ' al llamar a f_concepto. pmodo = ' || pmodo,
                                 '(xcempres = ' || xcempres || ') - ' || '(xsproduc = '
                                 || xsproduc || ') - ' || '(cconcep = ' || 14 || ') - '
                                 || '(ptipomovimiento = ' || ptipomovimiento || ') - '
                                 || '(xfefecto = ' || xfefecto || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(xcderreg = ' || xcderreg || ') - ');
                     RETURN error;
                  END IF;
               ELSE
                  vnvalcon := 0;   -- para que no calcule el importe del concepto
               END IF;

               -- Bug 0019578 - FAL - 26/09/2011. Incluir llamada concepto 14 (derechos registro)
               vpas := 1430;
               taxaderreg := NVL(vnvalcon, 0);

               IF NVL(taxaderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1440;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol, NULL,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 1450;
                        oiconcep :=
                           oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1460;
                        -- INI IAXSIS-4160 - JLTS - 12/06/2019. Ser cambia oiconcep por oiconcep_monpol, porque viene en COP
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, xprecarg, vctipcon,
                                                                     1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep_monpol, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                     oiconcep := oiconcep_monpol / v_itasa;
                     -- FIN IAXSIS-4160 - JLTS - 12/06/2019. 
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1470;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                  -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                    -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 1480;

                  -- bug0025826
                  IF v_res4094 = 1
                     AND pcforpag NOT IN(0, 1) THEN
                     error := f_ultrenova(psseguro, xfefecto, d_ini, xnmovimi);

                     SELECT MAX(frenova), MAX(fcaranu)
                       INTO d_renova, d_caranu
                       FROM seguros
                      WHERE sseguro = psseguro;

                     d_fin := NVL(d_caranu, NVL(d_renova, ADD_MONTHS(xfefecto, 12)));
                     n_div := 12 / pcforpag;

                     IF d_ini IS NOT NULL
                        AND d_fin IS NOT NULL THEN
                        --BUG 33488/192098-20/11/2014-AMC
                        tot_iconcepderreg := NVL(oiconcep, 0)
                                             / CEIL(MONTHS_BETWEEN(d_fin, d_ini) / n_div);   --Bug 32705/190821-05/11/2014-AMC
                        tot_iconcepderreg_monpol :=
                            NVL(oiconcep_monpol, 0)
                            / CEIL(MONTHS_BETWEEN(d_fin, d_ini) / n_div);   --Bug 32705/190821-05/11/2014-AMC
                     ELSE
                        tot_iconcepderreg := NVL(oiconcep, 0);
                        tot_iconcepderreg_monpol := oiconcep_monpol;
                     END IF;
                  ELSE
                     tot_iconcepderreg := NVL(oiconcep, 0);
                     tot_iconcepderreg_monpol := oiconcep_monpol;
                  END IF;
               ELSE
                  tot_iconcepderreg := 0;
               END IF;
            -- Fi Bug 0019578 - FAL
            ELSE
               tot_iconcepderreg := 0;
            END IF;

            -- Bug 23074 - APD - 01/08/2012 - Incluir llamada concepto 86 (iva - derechos registro)
            IF tot_iconcepderreg <> 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               oiconcep_monpol := NULL;
               tot_iconcepivaderreg := NULL;
               tot_iconcepivaderreg_monpol := NULL;
               error := f_concepto(86, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaivaderreg := NVL(vnvalcon, 0);

               IF NVL(taxaivaderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1440;
                        error :=
                           pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0_monpol,
                                                               iconcep21_monpol, idto_monpol,
                                                               idto21_monpol, xidtocam_monpol,
                                                               xicapital_monpol, NULL,
                                                               xprecarg, vctipcon, 1,

                                                               -- Ponemos forpag = 1, ya que es un recibo
                                                               vcfracci, vcbonifi, vcrecfra,
                                                               oiconcep_monpol, NULL,
                                                               tot_iconcepderreg_monpol,
                                                               -- Bug 0020314 - FAL - 29/11/2011
                                                               --NULL, NULL, NULL, NULL, NULL,
                                                               --v_cmonpol);
                                                               -- MRB 31/08/2012
                                                               NULL, xfefecto, psseguro,
                                                               NVL(xnriesgo, 1), xcgarant,
                                                               v_cmonpol);
                        vpas := 1450;
                        oiconcep :=
                           oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1460;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, xprecarg, vctipcon,
                                                                     1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     tot_iconcepderreg,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                        -- INI IAXIS-4153 - JLTS - 19/06/2019. Se adiciona la conversión de la moneda (COP) según el valor de la moneda extranjera
                        oiconcep_monpol :=  oiconcep * v_itasa;
                        -- FIN IAXIS-4153 - JLTS - 19/06/2019. 
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1470;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  tot_iconcepderreg,
                                                                  -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                    -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                  --NULL, NULL, NULL, NULL,
                                                                  --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep :=oiconcep;
                     END IF;
                  END IF;

                  tot_iconcepivaderreg := NVL(oiconcep, 0);
                  tot_iconcepivaderreg_monpol := NVL(oiconcep_monpol, 0);
               -- JLB - F -
               ELSE
                  tot_iconcepivaderreg := 0;
                  tot_iconcepivaderreg_monpol := 0;
               END IF;
            ELSE
               tot_iconcepivaderreg := 0;
               tot_iconcepivaderreg_monpol := 0;
            END IF;

            -- fin Bug 23074 - APD - 01/08/2012

            -- Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro
            -- Fi Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- fi BUG 9422 - 14/10/2009 - LCF

            -- CALCULEM EL RECARREC PER FRACCIONAMENT (CCONCEP = 8)

            -- LPS (04/08/2008), Modificado el cálculo para el nuevo módulo de impuestos.
            IF pcrecfra = 1
               AND pcforpag IS NOT NULL THEN
               xprecarg := NULL;
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               totrecfracc := NULL;
               vpas := 1490;
               error := f_concepto(8, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               xprecarg := NVL(vnvalcon, 0);

               -- Damos valor al procentaje de recargo para los otros conceptos.
               IF vctipcon = 4
                  AND error = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 1500;
                  error := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                   xnriesgo, pttabla,
                                                                   'CRECFRA', xicapital,
                                                                   xcgarant);

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol :=(xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol :=
                        (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               vpas := 1510;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1520;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol, NULL,
                                                                     NULL, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol,
                                                                     'SEG', NULL, NULL,
                                                                     xnmovimi,
                                                                     ptipomovimiento);
                        vpas := 1530;
                        oiconcep :=
                           oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1540;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, NULL, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda, 'SEG',
                                                                     NULL, NULL, xnmovimi,
                                                                     ptipomovimiento);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1550;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  NULL, vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                  -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                    -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                  --NULL, NULL, NULL, NULL,
                                                                  --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda, 'SEG', NULL, NULL,
                                                                  xnmovimi, ptipomovimiento);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  totrecfracc := oiconcep;

                  -- Fin LPS (04/08/2008)
                  IF NVL(totrecfracc, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        v_iconcep_monpol := oiconcep_monpol;
                        vpas := 1560;
                        error := f_insdetrec(pnrecibo, 8, totrecfracc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             0, 0, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 1570;
                        error := f_insdetrec(pnrecibo, 8, totrecfracc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            END IF;

            vpas := 1580;

            IF xcimpdgs > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepdgs := NULL;
               tot_iconcepdgs_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 1600;
               error := f_concepto(5, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxadgs := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND error = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 1610;
                  error := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                   xnriesgo, pttabla,
                                                                   'CIMPDGS', xicapital,
                                                                   xcgarant);

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF error <> 0 THEN
                  CLOSE cur_detrecibos;

                  RETURN error;
               END IF;

               vpas := 1620;

               IF NVL(taxadgs, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1630;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0_monpol, iconcep21_monpol,
                                                  idto_monpol, idto21_monpol, xidtocam_monpol,
                                                  xicapital_monpol, NULL, xprecarg, vctipcon,
                                                  1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra,
                                                  oiconcep_monpol, NULL, NULL, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  v_cmonpol);
                        vpas := 1640;
                        oiconcep :=
                           oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1650;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  NULL, NULL, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1660;
                     error :=
                        pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  NULL, NULL, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep :=oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  tot_iconcepdgs := NVL(oiconcep, 0);
                  tot_iconcepdgs_monpol := oiconcep_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconcepdgs := 0;
               END IF;


               -- Fin LPS (04/08/2008)

               -- Miramos si aun hay que calcular la DGS prorrateada.
               BEGIN
                  vpas := 1670;

                  SELECT sseguro
                    INTO dummy
                    FROM segcleafrac
                   WHERE sseguro = psseguro;

                  IF ptipomovimiento = 21 THEN
                     vpas := 1680;

                     DELETE FROM segcleafrac
                           WHERE sseguro = psseguro;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE cur_detrecibos;

                     error := 101919;
                     RETURN error;
               END;
            ELSE
               tot_iconcepdgs := 0;
            END IF;

            -- Fin LPS (04/09/2008)

            --Bug 24656-XVM-20/11/2012.Cambiamos orden en el cálculo: 1º Arbitrios, 2º IPS.Inicio
            vpas := 1760;

            IF xcimparb > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconceparb := NULL;
               tot_iconceparb_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 1810;
               vnerror := f_concepto(6, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaarb := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND vnerror = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 1820;
                  vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                     xnriesgo, pttabla,
                                                                     'CIMPARB', xicapital,
                                                                     xcgarant);
                  vpas := 1830;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detrecibos;

                  RETURN vnerror;
               END IF;

               IF NVL(taxaarb, 0) <> 0 THEN
                  vpas := 1860;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1870;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0_monpol, iconcep21_monpol,
                                                  idto_monpol, idto21_monpol, xidtocam_monpol,
                                                  xicapital_monpol, NULL, xprecarg, vctipcon,
                                                  1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra,
                                                  oiconcep_monpol, tot_iconcepderreg,
                                                  vcderreg, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, v_cmonpol);
                        vpas := 1880;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1890;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  tot_iconcepderreg, vcderreg, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1900;
                     error :=
                        pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  tot_iconcepderreg, vcderreg, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  tot_iconceparb := NVL(oiconcep, 0);
                  tot_iconceparb_monpol := oiconcep_monpol;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda

                  -- BUG 26835 - FAL - 06/05/2013
                  IF f_control_carbritrios(psseguro, xnmovima, xnriesgo, xcgarant) = 1 THEN
                     tot_iconceparb := 0;
                  END IF;
               -- FI BUG 26835 - FAL - 06/05/2013
               ELSE
                  tot_iconceparb := 0;
               END IF;
            ELSE
               tot_iconceparb := 0;
            END IF;

            -- LPS (04/09/2008)
            IF xcimpfng > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepfng := NULL;
               tot_iconcepfng_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 1920;
               vnerror := f_concepto(7, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxafng := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND vnerror = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 1930;
                  vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                     xnriesgo, pttabla,
                                                                     'CIMPFNG', xicapital,
                                                                     xcgarant);
                  vpas := 1940;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detrecibos;

                  RETURN vnerror;
               END IF;

               IF NVL(taxafng, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1950;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0_monpol, iconcep21_monpol,
                                                  idto_monpol, idto21_monpol, xidtocam_monpol,
                                                  xicapital_monpol, NULL, xprecarg, vctipcon,
                                                  1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra,
                                                  oiconcep_monpol, NULL, NULL, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  v_cmonpol);
                        vpas := 1960;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1970;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  NULL, NULL, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1980;
                     error :=
                        pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  NULL, NULL, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  tot_iconcepfng := NVL(oiconcep, 0);
                  tot_iconcepfng_monpol := oiconcep_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconcepfng := 0;
               END IF;
            ELSE
               tot_iconcepfng := 0;
            END IF;

            vpas := 1990;

            -- Fin LPS (04/09/2008)
            IF NVL(tot_iconcepdgs, 0) <> 0
               AND taxadgs IS NOT NULL THEN
               tot_iconcepdgs := tot_iconcepdgs;

               IF NVL(tot_iconcepdgs, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol :=tot_iconcepdgs_monpol;
                     vpas := 2000;
                     error := f_insdetrec(pnrecibo, 5, tot_iconcepdgs, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2010;
                     error := f_insdetrec(pnrecibo, 5, tot_iconcepdgs, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            vpas := 2180;

            IF NVL(tot_iconceparb, 0) <> 0
               AND taxaarb IS NOT NULL THEN
               tot_iconceparb := tot_iconceparb;

               IF NVL(tot_iconceparb, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol :=tot_iconceparb_monpol;
                     vpas := 2190;
                     error := f_insdetrec(pnrecibo, 6, tot_iconceparb, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2200;
                     error := f_insdetrec(pnrecibo, 6, tot_iconceparb, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            IF NVL(iconcep0, 0) <> 0 THEN
               --JRH Sólo calculamos el ISI para prima <>0
               --JRH Solución temporal para el ISI. Lo calculamos y substiruimosel valor del IPS por el ISI.
               DECLARE
                  isiform        NUMBER;
                  vsproduc       NUMBER;
                  vcactivi       NUMBER;
                  vcapgaran      NUMBER;
                  a              NUMBER;
                  vfefecto       DATE;
                  importeisi     NUMBER;
                  wicapital      NUMBER;   -- DRA 27-8-08: bug mantis 7372
                  xftarifa       DATE;   -- jrh 27-8-08: bug mantis 7372
               BEGIN
                  vpas := 2020;

                  SELECT sproduc, cactivi
                    INTO vsproduc, vcactivi
                    FROM seguros
                   WHERE sseguro = psseguro;

                  vpas := 2030;
                  error := f_pargaranpro(pcramo, pcmodali, pctipseg, pccolect, vcactivi,
                                         xcgarant, 'ISI_FORMULA', isiform);
                  vpas := 2040;
                  isiform := NVL(isiform, 0);

                  IF isiform <> 0 THEN
                     vpas := 2050;

                     -- DRA 27-8-08: bug mantis 7372
                     BEGIN
                        SELECT g.icapital, g.ftarifa
                          INTO xicapital, xftarifa
                          FROM garanseg g
                         WHERE g.sseguro = psseguro
                           AND g.nriesgo = NVL(pnriesgo, 1)
                           AND g.cgarant = xcgarant
                           AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                                              FROM garanseg g1
                                             WHERE g1.sseguro = g.sseguro
                                               AND g1.nriesgo = g.nriesgo
                                               AND g1.cgarant = g.cgarant);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           CLOSE cur_detrecibos;

                           RETURN 103500;
                     END;

                     vpas := 2060;

                     SELECT cgarant, icapital
                       INTO vcapgaran, wicapital
                       FROM garanseg
                      WHERE sseguro = psseguro
                        AND f_pargaranpro_v(pcramo, pcmodali, pctipseg, pccolect, vcactivi,
                                            cgarant, 'TIPO') = 5
                        AND ffinefe IS NULL;

                     vpas := 2070;

                     SELECT fefecto
                       INTO vfefecto
                       FROM recibos
                      WHERE nrecibo = pnrecibo;

                     vpas := 2080;
                     a := pac_calculo_formulas.calc_formul(vfefecto, vsproduc, vcactivi,
                                                           vcapgaran, NVL(pnriesgo, 1),
                                                           psseguro, 1000 + isiform,
                                                           importeisi, NULL, NULL, 2, xftarifa,
                                                           'R');
                     tot_iconcepips := NVL(importeisi, tot_iconcepips);
                     vpas := 2090;

                     -- DRA 27-8-08: bug mantis 7372
                     IF NVL(xicapital, 0) <> 0
                        AND NVL(importeisi, 0) = 0 THEN
                        CLOSE cur_detrecibos;

                        p_tab_error(f_sysdate, f_user, 'impuestos recibos', vpas,
                                    'error al insertar impuestos. pmodo = ' || pmodo,
                                    '(sseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                    || xcgarant || ') - ' || '(vcapgaran = ' || vcapgaran
                                    || ') - ' || '(isiform = ' || isiform || ') - '
                                    || '(vfefecto = ' || vfefecto || ') - ' || '(pnriesgo = '
                                    || pnriesgo || ') - ' || '(vcactivi = ' || vcactivi
                                    || ') - ' || '(vsproduc = ' || vsproduc || ') - '
                                    || '(wicapital = ' || wicapital || ') - '
                                    || '(xicapital = ' || xicapital || ') - '
                                    || '(pnrecibo = ' || pnrecibo || ') - ');
                        RETURN 180880;
                     END IF;

                     vpas := 2100;

                     SELECT pimpips
                       INTO taxaips
                       FROM impuestos
                      WHERE cimpues = 1;

                     --JRH 11/12 Bug 8064: Problemas con el redondeo de los recibos de PPJ
                     --Restamos a la prima el impuesto directamente del recibo
                     IF NVL(tot_iconcepips, 0) <> 0
                        AND taxaips IS NOT NULL THEN
                        tot_iconcepips := tot_iconcepips;
                        --Nos aseguramos, vamos por PK
                        vpas := 2110;

                        UPDATE detrecibos
                           SET iconcep = iconcep - tot_iconcepips
                         WHERE nrecibo = pnrecibo
                           AND cconcep = 0   --prima
                           AND cgarant = xcgarant
                           AND nriesgo = NVL(xnriesgo, 0);

                        vpas := 2120;

                        SELECT iconcep
                          INTO iconcep0
                          -- JRH Bug 9011  actualizo iconcep0 parra el calculo de la comision.
                        FROM   detrecibos
                         WHERE nrecibo = pnrecibo
                           AND cconcep = 0   --prima
                           AND cgarant = xcgarant
                           AND nriesgo = NVL(xnriesgo, 0);
                     END IF;
                  END IF;
               EXCEPTION
                  WHEN OTHERS THEN
                     CLOSE cur_detrecibos;

                     p_tab_error(f_sysdate, f_user, 'impuestos recibos', vpas,
                                 'error al insertar impuestos. pmodo = ' || pmodo,
                                 SQLERRM || ' (sseguro = ' || psseguro || ')');
                     RETURN 180879;
               END;
            ELSE
               tot_iconcepips := 0;
            END IF;

            -- JRH
            vpas := 2130;
            vpas := 1800;

            -- LPS (04/09/2008)
            IF xcimpips > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepips := NULL;
               tot_iconcepips_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 1690;
               vnerror := f_concepto(4, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaips := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND error = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 1700;
                  error := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                   xnriesgo, 'TMP', 'CIMPIPS',
                                                                   xicapital, xcgarant);
                  vpas := 1710;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detrecibos;

                  RETURN vnerror;
               END IF;

               IF NVL(taxaips, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1720;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0_monpol, iconcep21_monpol,
                                                  idto_monpol, idto21_monpol, xidtocam_monpol,
                                                  xicapital_monpol, NULL, xprecarg, vctipcon,
                                                  1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra,
                                                  oiconcep_monpol, tot_iconcepderreg,
                                                  vcderreg, NULL, xfefecto, psseguro,
                                                  NVL(xnriesgo, 1), xcgarant, v_cmonpol,
                                                  'SEG', 1, tot_iconceparb_monpol);   -- Substituïr tot_iconceparb per monpol 24656/131450.2012.12.03.NMM
                        vpas := 1730;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1740;
                        error :=
                           pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  tot_iconcepderreg, vcderreg, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  pmoneda, NULL, 1, tot_iconceparb);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1750;
                     error :=
                        pac_impuestos.f_calcula_impconcepto
                                                 (vnvalcon, iconcep0, iconcep21, idto, idto21,
                                                  xidtocam, xicapital, NULL, xprecarg,
                                                  vctipcon, 1,   -- Ponemos forpag = 1, ya que es un recibo
                                                  vcfracci, vcbonifi, vcrecfra, oiconcep,
                                                  tot_iconcepderreg, vcderreg, NULL, xfefecto,
                                                  psseguro, NVL(xnriesgo, 1), xcgarant,
                                                  pmoneda, NULL, 1, tot_iconceparb);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep :=oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  -- INI IAXIS-4160 - JLTS - 11/06/2019 Se intercambia el valor del concepto por que viene en la moneda de la empresa (COP)
                  tot_iconcepips := NVL(oiconcep, 0);
                  tot_iconcepips_monpol := tot_iconcepips * v_itasa;
                  -- FIN IAXIS-4160 - JLTS - 11/06/2019
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconcepips := 0;
               END IF;
            -- Fin LPS (04/08/2008)
            ELSE
               tot_iconcepips := 0;
            END IF;

            --Bug 24656-XVM-20/11/2012.Cambiamos orden en el cálculo: 1º Arbitrios, 2º IPS.FINAL

            -- Fin LPS (04/09/2008)
            vpas := 1910;

            IF NVL(tot_iconcepips, 0) <> 0
               AND taxaips IS NOT NULL THEN
               tot_iconcepips := tot_iconcepips;
               --KBR 19/05/2014  31458
               v_ploccoa_ivaced := 100;

               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'APLICA_IVA_COACED'), 0) = 1 THEN
                  v_ploccoa_ivaced := xploccoa;
               END IF;

               --KBR 19/05/2014  31458
               IF NVL(tot_iconcepips, 0) <> 0 THEN
                  IF v_cmultimon = 1 THEN
										-- INI IAXSIS-4160 - JLTS - 12/06/2019. Se tendrá en cuenta si el valor es para un producto de moneda extranjera
                     IF vcdivisa != pac_parametros.f_parempresa_n(v_cempres, 'MONEDAEMP') THEN
			v_iconcep_monpol := tot_iconcepips * v_itasa;
                     ELSE
                    -- FIN IAXSIS-4160 - JLTS - 12/06/2019. 
                     v_iconcep_monpol :=tot_iconcepips_monpol;
                    END IF; -- IAXSIS-4160 - JLTS - 12/06/2019. 
                     vpas := 2140;
                     error := f_insdetrec(pnrecibo, 4, tot_iconcepips, v_ploccoa_ivaced,   --KBR 19/05/2014  31458
                                          xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                          xnmovima, 0, 0, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  ELSE
                     vpas := 2150;
                     error := f_insdetrec(pnrecibo, 4, tot_iconcepips, v_ploccoa_ivaced,   --KBR 19/05/2014  31458
                                          xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                          xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            IF NVL(tot_iconcepderreg, 0) <> 0
               AND taxaderreg IS NOT NULL THEN
               tot_iconcepderreg :=tot_iconcepderreg;

               IF NVL(tot_iconcepderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := tot_iconcepderreg_monpol;
                     vpas := 2160;
                     -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                     error := f_insdetrec(pnrecibo, 14, tot_iconcepderreg,   --xploccoa
                                          100, xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                          xnmovima, 0, 0, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2170;
                     -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                     error := f_insdetrec(pnrecibo, 14, tot_iconcepderreg,   --xploccoa
                                          100, xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                          xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            -- Bug 23074 - APD - 01/08/2012 - se inserta en detrecibos el concepto 86
            IF NVL(tot_iconcepivaderreg, 0) <> 0
               AND taxaivaderreg IS NOT NULL THEN
               tot_iconcepivaderreg := tot_iconcepivaderreg;

               IF NVL(tot_iconcepivaderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := tot_iconcepivaderreg_monpol;
                     vpas := 2160;
                     -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                     error := f_insdetrec(pnrecibo, 86, tot_iconcepivaderreg,   -- xploccoa
                                          100, xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
					  -- IAXIS-4153 -JLTS -19/06/2019 - Se coloca solo v_iconcep_monpol porque arriba se calcula
                                          xnmovima, 0, 0, 1, v_iconcep_monpol, -- BUG 1970 AP
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2170;
                     -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                     error := f_insdetrec(pnrecibo, 86, tot_iconcepivaderreg,   --xploccoa
                                          100, xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                          xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            -- fin Bug 23074 - APD - 01/08/2012
            IF NVL(tot_iconcepfng, 0) <> 0
               AND taxafng IS NOT NULL THEN
               tot_iconcepfng := tot_iconcepfng;

               IF NVL(tot_iconcepfng, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := tot_iconcepfng_monpol;
                     vpas := 2210;
                     error := f_insdetrec(pnrecibo, 7, tot_iconcepfng, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2220;
                     error := f_insdetrec(pnrecibo, 7, tot_iconcepfng, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;
               END IF;
            END IF;

            -- JLB - I -  CAMBIO 03/11/2011
            vpas := 2230;

            FOR reg_con IN (SELECT cconcep
                              FROM garanpro_imp g1
                             WHERE cramo = pcramo
                               AND cmodali = pcmodali
                               AND ctipseg = pctipseg
                               AND ccolect = pccolect
                               AND cactivi = pcactivi
                               AND cgarant = xcgarant
                            UNION
                            SELECT cconcep
                              FROM garanpro_imp g2
                             WHERE cramo = pcramo
                               AND cmodali = pcmodali
                               AND ctipseg = pctipseg
                               AND ccolect = pccolect
                               AND cactivi = 0
                               AND cgarant = xcgarant
                               AND NOT EXISTS(SELECT 1
                                                FROM garanpro_imp
                                               WHERE cramo = g2.cramo
                                                 AND cmodali = g2.cmodali
                                                 AND ctipseg = g2.ctipseg
                                                 AND ccolect = g2.ccolect
                                                 AND cactivi = pcactivi
                                                 AND cgarant = g2.cgarant)) LOOP
               vpas := 2240;
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcep := NULL;
               vpas := 2250;
               vnerror := f_concepto(reg_con.cconcep, xcempres, xfefecto, pcforpag, pcramo,
                                     pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                     vctipcon, vnvalcon, vcfracci, vcbonifi, vcrecfra,
                                     w_climit,   -- Bug 10864.NMM.01/08/2009.
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

               IF vnerror <> 0 THEN
                  CLOSE cur_detrecibos;

                  RETURN vnerror;
               END IF;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  BEGIN
                     vpas := 2260;

                     SELECT   NVL(SUM(iconcep), 0)
                         INTO viconcep0neto
                         FROM detrecibos
                        WHERE nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                          AND cconcep = 0   -- LOCAL
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        viconcep0neto := 0;
                     WHEN OTHERS THEN
                        CLOSE cur_detrecibos;

                        error := 103512;   -- ERROR AL LLEGIR DE DETRECIBOS
                        RETURN error;
                  END;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 2270;

                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF vctipcon = 4
                        AND vnerror = 0 THEN
                        -- Para impuesto sobre capital (no sobre prima)
                        vpas := 7900;
                        vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                           xnriesgo, pttabla,
                                                                           'SIN_CONCEPTO',
                                                                           xicapital,
                                                                           xcgarant);
                        vpas := 7910;

                        IF vcfracci = 0 THEN
                           IF xctiprec <> 3
                              OR(xctiprec = 3
                                 AND xnfracci = 0) THEN
                              xicapital_monpol := (xicapital * v_itasa);
                              -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                              xicapital := xicapital;
                           -- Parte que corresponde al recibo
                           END IF;
                        ELSE
                           xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                           -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                           xicapital := xicapital / pcforpag;
                        END IF;
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 2280;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol, NULL,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Añadir gastos de emisión

                                                                     --nuevos campos
                                                                     viconcep0neto, xfefecto,
                                                                     psseguro, xnriesgo,
                                                                     xcgarant,
                                                                     -- fin nuevos campos,
                                                                     v_cmonpol);
                        vpas := 2290;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 2300;

                        IF vctipcon = 4
                           AND vnerror = 0 THEN
                           -- Para impuesto sobre capital (no sobre prima)
                           vpas := 7900;
                           vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro,
                                                                              xnmovimi,
                                                                              xnriesgo,
                                                                              pttabla,
                                                                              'SIN_CONCEPTO',
                                                                              xicapital,
                                                                              xcgarant);
                           vpas := 7910;

                           IF vcfracci = 0 THEN
                              IF xctiprec <> 3
                                 OR(xctiprec = 3
                                    AND xnfracci = 0) THEN
                                 xicapital_monpol := (xicapital * v_itasa);
                                 -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                 xicapital := xicapital;
                              -- Parte que corresponde al recibo
                              END IF;
                           ELSE
                              xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                              -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                              xicapital := xicapital / pcforpag;
                           END IF;
                        -- Parte que corresponde al recibo
                        END IF;

                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital, NULL,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Añadir gastos de emisión

                                                                     --nuevos campos
                                                                     viconcep0neto, xfefecto,
                                                                     psseguro, xnriesgo,
                                                                     xcgarant,
                                                                     -- fin nuevos campos,
                                                                     pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 2310;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                  -- Bug 0020314 - FAL - 29/11/2011 - Añadir gastos de emisión

                                                                  --nuevos campos
                                                                  viconcep0neto, xfefecto,
                                                                  psseguro, xnriesgo,
                                                                  xcgarant,
                                                                  -- fin nuevos campos,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep :=oiconcep;
                     END IF;
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  END IF;

                  vpas := 2320;

                  IF reg_con.cconcep IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
                     AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                     -- xmoneda := xmoneda + NVL(pac_parametros.f_parempresa_n(vcempres, 'REDONDEO_SRI'), 0);
                     tot_iconcep :=NVL(oiconcep, 0);
                  ELSE
                     tot_iconcep := NVL(oiconcep, 0);
                  END IF;

                  IF NVL(tot_iconcep, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        IF reg_con.cconcep IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
                           AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <>
                                                                                              0 THEN
                           v_iconcep_monpol := oiconcep_monpol;
                        ELSE
                           v_iconcep_monpol := oiconcep_monpol;
                        END IF;

                        vpas := 2330;
                        error := f_insdetrec(pnrecibo, reg_con.cconcep, tot_iconcep, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima, 0, 0, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 2340;
                        error := f_insdetrec(pnrecibo, reg_con.cconcep, tot_iconcep, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;
                  END IF;
               ELSE
                  tot_iconcep := 0;
               END IF;
            END LOOP;

            -- JLB - F -  CAMBIO 03/11/2011

            --CALCUL COMISIONS I RETENCIONS (MODE 'R': REAL)
            --SI SE TRATA DE UN COASEGURO ACEPTADO. PUEDE PASAR QUE NOSOTROS PAGUEMOS DIRECTAMENTE AL
            --AGENTE CON LO QUE PCOMCOA SERA NULO, Y DEBEREMOS IR A BUSCAR LOS PORCENTAJES POR P_FCOMISI.
            --SINO PCOMCOA SERA DIFERENTE A NULO, Y TENDRA EL PORCENTAJE A PAGAR A LA OTRA COMPAÑIA Y LA
            --COMISION Y RETENCIO EN VDETRECIBOS SERA 0.
            IF xctipcoa = 8
               OR xctipcoa = 9 THEN
               BEGIN
                  vpas := 2350;

                  SELECT pcomcoa
                    INTO xpcomcoa
                    FROM coacedido
                   WHERE sseguro = psseguro
                     AND ncuacoa = xncuacoa;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   -- 23183 AVT 31/10/2012 no hi ha coacedido a la Coa. Acceptada
                     xpcomcoa := NULL;
                  WHEN OTHERS THEN
                     RETURN 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
               END;

               IF xpcomcoa IS NULL THEN
                  porcagente := pcomisagente;
                  porragente := pretenagente;
               ELSE
                  porcagente := 0;
                  porragente := 0;
               END IF;
            ELSE
               porcagente := pcomisagente;
               porragente := pretenagente;
            END IF;

            --
            -- Calculo de comisiones
            --
            -- Sobre prima
            -- Bug 0021947 - JMF - 20/08/2012
            IF xccalcom IN(1, 4)
               AND NOT(NVL(iconcep0, 0) <> 0
                       OR NVL(iconcep21, 0) <> 0) THEN
               porcagente := 0;
               porragente := 0;
            ELSIF xccalcom IN(1, 4)
                  AND(NVL(iconcep0, 0) <> 0
                      OR NVL(iconcep21, 0) <> 0) THEN
               --BUG20342 - JTS - 02/12/2011
               --Bug.:18852 - 08/09/2011 - ICV
               vpas := 2360;

                   -- QT de produccion 13565 --   es de migración y se aplica sobrecomisión de cartera
               -- Añadimos en la selet nanuali, fcarpro,
               SELECT sproduc, fefecto, nanuali, fcarpro, fcaranu
                 INTO v_sproduc, v_fefectopol, w_nanuali, v_fcarpro, v_fcaranu
                 FROM seguros
                WHERE sseguro = psseguro;

               -- FBL. 25/06/2014 MSV Bug 0028974
               IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                 pcparam => 'AFECTA_COMISESPPROD') = 1 THEN   --and pfuncion != 'CAR' then
                  -- MSV Comisiones especiales
                  n_error :=
                     pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 11,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                  IF n_error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ') - ' || '(vcageind = '
                                 || vcageind || ') - ' || '(pcramo = ' || pcramo || ') - '
                                 || '(pcmodali = ' || pcmodali || ') - ' || '(pctipseg = '
                                 || pctipseg || ') - ' || '(pccolect = ' || pccolect || ') - ');
                     RETURN error;
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               ELSE
                  IF NVL(pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION'),
                         'FEFECTO_REC') = 'FEFECTO_REC' THEN
                     v_fefectovig := v_fefectorec;   --Efecto del recibo
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                                  'FEFECTO_POL' THEN   --Efecto de la póliza
                     vpas := 2370;
                     error := pac_preguntas.f_get_pregunpolseg(psseguro, 4046, 'SEG',
                                                               vcrespue);

                     IF error NOT IN(0, 120135) THEN
                        RETURN error;
                     ELSE
                        v_fefectovig := NVL(TO_DATE(vcrespue, 'YYYYMMDD'), v_fefectopol);
                     END IF;
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                               'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 2), 'yyyymmdd');
                  END IF;

                  --FIBUG20342

                  ---
                    -- QT de produccion 13565 --   es de migración y se aplica sobrecomisión de cartera

                  -- Fin bug 21167

                  -- Bug 21435 - FAL - 16/03/2012. Comparar fcarpro y fcaranu para ver si sumar 1 a la anualidad
                  vpas := 2375;

                  -- Bug 22583 - XVM - 26/03/2013
                  IF pcmodcom = 2
                     AND w_nanuali < 2 THEN
                     w_nanuali := 2;
                  END IF;

                  -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
                  -- de la variable v_fefectorec
                  -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia
                  vpas := 2380;
                  error := f_pcomisi(psseguro, pcmodcom, f_sysdate, porcagente, porragente,
                                     NULL, NULL, NULL, NULL, NULL, NULL, xcgarant, pttabla,
                                     pfuncion, v_fefectovig, w_nanuali, 0, NVL(xnriesgo, 1));

                  -- fin Bug 20153 - APD - 15/11/2011
                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomisi', 1,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(w_nanuali = ' || w_nanuali
                                 || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ')');
                     RETURN error;
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               END IF;
            END IF;

            -- BUG22255:DRA:18/05/2012:Inici
            iconcep8 := 0;
            iconcep8_monpol := 0;

            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONCEP_COMISION'), 0) = 1 THEN
               SELECT NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                 INTO iconcep8, iconcep8_monpol
                 FROM detrecibos
                WHERE nrecibo = pnrecibo
                  AND nriesgo = xnriesgo
                  AND cgarant = xcgarant
                  AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                  AND cconcep IN(8, 58);   -- LOCAL + CEDIDA
            END IF;

               -- BUG22255:DRA:18/05/2012:Fi
            -- FBL. 25/06/2014 MSV Bug 0028974
            IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                              pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
               --AND v_comisi_total > 0 THEN  rdd 28042015
               -- MSV Comisiones especiales

               -- la función f_pcomespecial ya inserta en detreciboscom/detreciboscarcom
               -- ahora solo falta insertar en det recibos los importes calculados en dicha función
               IF v_cmultimon = 1 THEN
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  vpas := 2482;
                  error := f_insdetrec(pnrecibo, 11, v_comisi_total, xploccoa, xcgarant,
                                       NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                       porcagente, psseguro, 1, v_comisi_monpol_total,   --rdd v_iconcep_monpol,
                                       NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
               ELSE
                  vpas := 2484;
                  error := f_insdetrec(pnrecibo, 11, v_comisi_total, xploccoa, xcgarant,
                                       NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                       porcagente, psseguro);
               END IF;
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            ELSE
               IF v_comian = 0 THEN
                  -- 17017 : comportamiento normal, comission por recibo
                  vpas := 2390;
                  comis_calc := (NVL(iconcep0, 0) + NVL(iconcep8, 0)) * porcagente / 100;
                  vpas := 2400;
                  v_iconcep_monpol := (NVL(iconcep0_monpol, 0)
                                               + NVL(iconcep8_monpol, 0))
                                              * porcagente / 100;
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  vpas := 2410;

                  -- comission en el recio de nueva producción y cartera renovación
                  IF ADD_MONTHS(xfefepol, v_comian * 12) > xfeferec
                     AND((xctiprec = 0)
                         OR xctiprec = 3
                            AND TO_CHAR(xfefepol) = TO_CHAR(xfeferec)) THEN
                     vpas := 2420;
                     comis_calc := (NVL(iconcep21, 0) + NVL(iconcep8, 0)) * porcagente
                                           / 100;
                     vpas := 2430;
                     v_iconcep_monpol := (NVL(iconcep21_monpol, 0)
                                                  + NVL(iconcep8_monpol, 0))
                                                 * porcagente / 100;
                  ELSIF ADD_MONTHS(xfefepol, v_comian * 12) <= xfeferec THEN
                     vpas := 2440;
                     comis_calc := (NVL(iconcep0, 0) + NVL(iconcep8, 0)) * porcagente
                                           / 100;
                     vpas := 2450;
                     v_iconcep_monpol := (NVL(iconcep0_monpol, 0)
                                                  + NVL(iconcep8_monpol, 0))
                                                 * porcagente / 100;
                  -- comportamiento normal
                  END IF;
               END IF;

               vpas := 2460;

               IF NVL(comis_calc, 0) <> 0
                  AND NVL(porcagente, 0) <> 0
                  -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  por diferencia de provisión Sin Comisiones
                  AND(NOT vdifprovision)
                                        -- Fi BUG 20672-  01/2012 - JRH
               THEN   --INSERTEM LA COMISIO
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 2470;
                     error := f_insdetrec(pnrecibo, 11, comis_calc, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  ELSE
                     vpas := 2480;
                     error := f_insdetrec(pnrecibo, 11, comis_calc, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;

                  -- INI Bug 27067 - AFM - 13/06/2013
                  vsumcomis := 0;
                  vsumcomis_monpol := 0;
                  vsumporcage := 0;
                  ppcomisi_concep := 0;

                  --
                  FOR i IN 1 .. 3 LOOP
                     --
                     error := f_busca_pcomisi_concep(psseguro, xcgarant, i, pcmodcom,
                                                     v_fefectovig, 0, ppcomisi_concep);

                     --
                     IF error != 0 THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    'Error al volver de f_busca_pcomisi_concep error:'
                                    || error || '-' || SQLCODE || ' ' || SQLERRM);
                        ppcomisi_concep := 0;
                        error := 0;
                     END IF;

                     --
                     vsumporcage := vsumporcage + ppcomisi_concep;

                     --
                     IF NVL(ppcomisi_concep, 0) <> 0
                        AND error = 0 THEN
                        IF i = 1 THEN
                           concep_concep := 44;
                        ELSIF i = 2 THEN
                           concep_concep := 45;
                        ELSE
                           concep_concep := 46;
                        END IF;

                        --
                        comis_calc_concep := NVL(comis_calc, 0) * ppcomisi_concep/ porcagente;

                        --
                        IF (vsumporcage = porcagente) THEN   -- Ajustamos
                           comis_calc_concep := comis_calc - vsumcomis;
                        END IF;

                        --
                        vsumcomis := vsumcomis + comis_calc_concep;

                        --
                        IF v_cmultimon = 1 THEN
                           --
                           vpas := 2482;
                           --
                           comis_calc_concep_monpol := NVL(v_iconcep_monpol, 0) * ppcomisi_concep / porcagente;

                           --
                           IF (vsumporcage = porcagente) THEN   -- Ajustamos
                              comis_calc_concep_monpol := v_iconcep_monpol - vsumcomis_monpol;
                           END IF;

                           --
                           vsumcomis_monpol := vsumcomis_monpol + comis_calc_concep_monpol;
                           --
                           error := f_insdetrec(pnrecibo, concep_concep, comis_calc_concep,
                                                xploccoa, xcgarant, NVL(xnriesgo, 0), xctipcoa,
                                                xcageven, xnmovima, ppcomisi_concep, psseguro,
                                                1, comis_calc_concep_monpol,
                                                NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                        ELSE
                           vpas := 2483;
                           --
                           error := f_insdetrec(pnrecibo, concep_concep, comis_calc_concep,
                                                xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                xctipcoa, xcageven, xnmovima, ppcomisi_concep,
                                                psseguro);
                        END IF;
                     --
                     END IF;
                  --
                  END LOOP;

                  -- FIN Bug 27067 - AFM - 13/06/2013
                  vpas := 2490;
                  reten_calc := ((comis_calc * porragente) / 100);
                  vpas := 2500;
                  v_iconcep_monpol := ((v_iconcep_monpol * porragente) / 100);
                  --- SE INHABILITA INI BUG 2074 AP 04/05/2018
              /*    IF NVL(reten_calc, 0) <> 0 THEN   -- INSERTEM LA RETENCIO
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2510;
                        error := f_insdetrec(pnrecibo, 12, reten_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     ELSE
                        vpas := 2520;
                        error := f_insdetrec(pnrecibo, 12, reten_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;

                     END IF;
                  END IF; */ --- SE INHABILITA FIN BUG 2074 AP 04/05/2018

                  -----------------------------------------FC0001-----------------------------------------
                  --verificamos si el agente es un corredor
                  select ctipage into v_ctipage
                    from agentes
                   where cagente in (select cagente
                                       from seguros
                                      where sseguro=psseguro);

                  IF v_ctipage IN (4,5,6) THEN --CONF-403 LR
                            IF NVL(comis_calc, 0) <> 0 THEN
                                   FOR reg IN (SELECT cconcta_imp,clave
                                                 FROM codctactes_imp
                                                WHERE CCONCTA=99
                                                  AND (SPRODUC=v_sproduc OR SPRODUC = 0) )
                                        LOOP

                                                      error := pac_impuestos.f_calcula_impconcepto(reg.clave,
                                                                                               comis_calc,
                                                                                               iconcep21_monpol,
                                                                                               idto_monpol,
                                                                                               idto21_monpol,
                                                                                               xidtocam_monpol,
                                                                                               xicapital_monpol, NULL,
                                                                                               xprecarg, 11, 1,
                                                                                               vcfracci, vcbonifi,
                                                                                               vcrecfra,
                                                                                               oiconcep_monpol, NULL,
                                                                                               NULL,
                                                                                               viconcep0neto, xfefecto,
                                                                                               psseguro, xnriesgo,
                                                                                               xcgarant,
                                                                                               v_cmonpol);

                                                  oiconcep_monpol  := oiconcep_monpol;
                                                  v_iconcep_monpol := oiconcep_monpol;
                                                  reten_calc := ((oiconcep_monpol * porragente) / 100);
                                                  v_iconcep_monpol_1 := ((v_iconcep_monpol * porragente) / 100);
                                             --INI  BUG 1970 AP
                                                    SELECT a.cprovin cprovin,
                                                           a.cpoblac cpoblac
                                                      INTO vcprovin,
                                                           vcpoblac
                                                      FROM agentes_comp a,
                                                           agentes ag,
                                                           per_personas p,
                                                           (SELECT sperson,
                                                                   cregfiscal
                                                              FROM per_regimenfiscal
                                                             WHERE (sperson, fefecto) IN
                                                                   (SELECT sperson,
                                                                           MAX(fefecto)
                                                                      FROM per_regimenfiscal
                                                                     group by sperson)) r
                                                     WHERE ag.cagente = (select cagente
                                                                           from seguros
                                                                          where sseguro=psseguro)
                                                       AND a.cagente = ag.cagente
                                                       and p.sperson = ag.sperson
                                                       and p.sperson = r.sperson(+);
                 --FIN BUG 1970 AP
                                               IF v_cmultimon = 1 THEN
                                                     IF  reg.cconcta_imp=53 THEN
                                                        if oiconcep_monpol <> 0 then
                                                            IF vcprovin NOT IN (88  , 91) THEN -- BUG 1970 AP EXCEPTOS DE IVA AMAZONAS Y SAN ANDRES
                                                                error := f_insdetrec(pnrecibo,32, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES
                                                                               NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                                     porcagente, psseguro, 1, f_round(v_iconcep_monpol * v_itasa, v_cmonpol), -- BUG 1970 AP
                                                                               NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                                                            END IF;
                                               END IF;
                                                     ELSIF reg.cconcta_imp=54 THEN
                                                        if oiconcep_monpol <> 0 then
                                                         error := f_insdetrec(pnrecibo,33, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro, 1, f_round(v_iconcep_monpol * v_itasa, v_cmonpol), -- BUG 1970 AP
                                                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                                                        end if;
                                                     ELSIF reg.cconcta_imp=55 THEN
                                                        if oiconcep_monpol <> 0 then
                                                         error := f_insdetrec(pnrecibo,34, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro, 1, f_round(v_iconcep_monpol * v_itasa, v_cmonpol), -- BUG 1970 AP
                                                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                                                        end if;
                                                     ELSE
                                                        if oiconcep_monpol <> 0 then
                                                         error := f_insdetrec(pnrecibo,35, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro, 1, f_round(v_iconcep_monpol * v_itasa, v_cmonpol), -- BUG 1970 AP
                                                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                                                       end if;
                                                     END IF;
                                               ELSE
                                                     IF  reg.cconcta_imp=53 THEN
                                                       if oiconcep_monpol <> 0 then
                      IF vcprovin NOT IN (88  , 91) THEN -- BUG 1970 AP EXCEPTOS DE IVA AMAZONAS Y SAN ANDRES
                                                                  error := f_insdetrec(pnrecibo, 32, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro);
                                                          END IF;
                  END IF;
                                                      ELSIF reg.cconcta_imp=54 THEN
                                                        if oiconcep_monpol <> 0 then
                                                         error := f_insdetrec(pnrecibo, 33, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro);
                                                        end if;

                                                      ELSIF reg.cconcta_imp=55 THEN
                                                        if oiconcep_monpol <> 0 then
                                                          error := f_insdetrec(pnrecibo, 34, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro);
                                                       end if;
                                                      ELSE
                                                        if oiconcep_monpol <> 0 then
                                                           error := f_insdetrec(pnrecibo, 35, oiconcep_monpol, xploccoa, xcgarant, ---oiconcep_monpol-reten_calc SE QUITA LAS RETENCIONES BUG 1970 AP
                                                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                                                             porcagente, psseguro);
                                                        end if;
                                                      END IF;

                                               END IF;

                                               IF error != 0 THEN
                                                  CLOSE cur_detrecibos;
                                                  RETURN error;
                                               END IF;
                                   END LOOP;
                            END IF;
                  END IF;
               END IF;
            -- FBL. 25/06/2014 MSV Bug 0028974
            END IF;

            -- Fin FBL. 25/06/2014 MSV Bug 0028974
               --CALCUL COMISIO I RETENCIO DEVENGADES(CCONCEP = 15 I 16)(MODE 'R' : REAL)
               --COMIS_CALC := ROUND(((COMIS_CALC * PORCAGENTE) / 100), 0);
            vpas := 2530;
            comis_calc := NVL(iconcep21, 0) * porcagente / 100;
            vpas := 2540;
            v_iconcep_monpol := NVL(iconcep21_monpol, 0) * porcagente / 100;   -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda

            IF NVL(comis_calc, 0) <> 0
               AND NVL(porcagente, 0) <> 0
               -- BUG 20672-  01/2012 - JRH  -  0020672: LCOL_T001-LCOL - UAT - TEC: Suplementos  por diferencia de provisión Sin Comisiones
               AND(NOT vdifprovision)
                                     -- Fi BUG 20672-  01/2012 - JRH
            THEN
               --INSERTEM LA COMISIO DEVENGADA
               -- FBL. 25/06/2014 MSV Bug 0028974
               IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                 pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                  -- MSV Comisiones especiales
                  n_error :=
                     pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 15,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                  IF n_error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ') - ' || '(vcageind = '
                                 || vcageind || ') - ' || '(pcramo = ' || pcramo || ') - '
                                 || '(pcmodali = ' || pcmodali || ') - ' || '(pctipseg = '
                                 || pctipseg || ') - ' || '(pccolect = ' || pccolect || ') - ');
                     RETURN error;
                  END IF;

                  --IF v_comisi_total > 0 THEN  --rdd28042015
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 2550;
                     error := f_insdetrec(pnrecibo, 15, v_comisi_total, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_comisi_monpol_total,   -- rdd v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     vpas := 2560;
                     error := f_insdetrec(pnrecibo, 15, v_comisi_total, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;
                  --END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               ELSE
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 2550;
                     error := f_insdetrec(pnrecibo, 15, comis_calc, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     vpas := 2560;
                     error := f_insdetrec(pnrecibo, 15, comis_calc, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detrecibos;

                     RETURN error;
                  END IF;

                  vpas := 2570;
                  reten_calc := ((comis_calc * porragente) / 100);
                  vpas := 2580;
                  v_iconcep_monpol := ROUND(((v_iconcep_monpol * porragente) / 100), v_cmonpol);

                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                 /* IF NVL(reten_calc, 0) <> 0 THEN --- SE INHABILITA INI BUG 2074 AP 04/05/2018
                     -- INSERTEM LA RETENCIO DEVENGADA
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2590;
                        error := f_insdetrec(pnrecibo, 16, reten_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        vpas := 2600;
                        error := f_insdetrec(pnrecibo, 16, reten_calc, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;
                  END IF; */  --- SE INHABILITA FIN BUG 2074 AP 04/05/2018
               -- FBL. 25/06/2014 MSV Bug 0028974
               END IF;

               -- MSV, ponemos el porcentaje a cero
               porcagente := 0;
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            END IF;

-- Bug 19586. JMC. 28/09/2011. Comisiones indirectas
--Calculo Comisiones Indirectas.
-------------------------------
--Obtención Agente indirecto
            vpas := 2610;

            IF NVL(pac_parametros.f_parempresa_n(xcempres, 'CALC_COMIND'), 0) = 2 THEN
               vpas := 2620;
               vcageind := pac_agentes.f_get_cageind(xcagente, xfefecto);
               vccomind := NULL;
            ELSIF NVL(pac_parametros.f_parempresa_n(xcempres, 'CALC_COMIND'), 0) = 1 THEN
               -- Bug 20999 - APD - 26/01/2012
               -- Bug 20999 - APD - 26/01/2012 - se busca el agente padre del agente y la
               -- comision indirecta del agente padre
               vcageind := NULL;
               vpas := 2630;
               error := pac_agentes.f_get_ccomind(xcempres, xcagente, v_fefectovig, vccomind,
                                                  vcage_padre);

               IF error <> 0 THEN
                  RETURN error;
               END IF;
            ELSIF NVL(pac_parametros.f_parempresa_n(xcempres, 'CALC_COMIND'), 0) = 3 THEN
               v_genera_indirecta := 0;

               SELECT NVL(MAX(b.nvalpar), 0)
                 INTO v_genera_indirecta
                 FROM age_paragentes b
                WHERE b.cparam = 'GEN_COMI_IN_PADRE'
                  AND b.cagente = xcagente;

               IF v_genera_indirecta = 1 THEN
                  error := pac_agentes.f_get_ccomind(pcempres => xcempres,
                                                     pcagente => xcagente, pfecha => xfefecto,
                                                     pccomind => vccomind,
                                                     pcpadre => vcage_padre);

                  IF error <> 0 THEN
                     RETURN error;
                  END IF;
               END IF;
            ELSE   -- No aplica comisión indirecta
               vcageind := NULL;
               vccomind := NULL;
            END IF;

            -- fin Bug 20999 - APD - 26/01/2012
            IF vcageind IS NOT NULL
               OR vccomind IS NOT NULL THEN   -- Bug 20999 - APD - 26/01/2012
               -- Sobre prima
               -- Bug 0021947 - JMF - 20/08/2012
               IF xccalcom IN(1, 4)
                  AND NOT(NVL(iconcep0, 0) <> 0
                          OR NVL(iconcep21, 0) <> 0) THEN
                  porcagente := 0;
                  porragente := 0;
               ELSIF xccalcom IN(1, 4)
                     AND(NVL(iconcep0, 0) <> 0
                         OR NVL(iconcep21, 0) <> 0) THEN
                  -- ini BUG 0020480 - 19/12/2011 - JMF: calia afegir
                  --BUG20342 - JTS - 02/12/2011
                  vpas := 2640;

                  SELECT sproduc, fefecto
                    INTO v_sproduc, v_fefectopol
                    FROM seguros
                   WHERE sseguro = psseguro;

                  vpas := 2650;

                  IF NVL(pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION'),
                         'FEFECTO_REC') = 'FEFECTO_REC' THEN
                     v_fefectovig := v_fefectorec;   --Efecto del recibo
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                                  'FEFECTO_POL' THEN   --Efecto de la póliza
                     vpas := 2650;
                     error := pac_preguntas.f_get_pregunpolseg(psseguro, 4046, 'SEG',
                                                               vcrespue);

                     IF error NOT IN(0, 120135) THEN
                        RETURN error;
                     ELSE
                        v_fefectovig := NVL(TO_DATE(vcrespue, 'YYYYMMDD'), v_fefectopol);
                     END IF;
                  ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                               'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
                     v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 2), 'yyyymmdd');
                  END IF;

                  --FIBUG20342
                  -- fin BUG 0020480 - 19/12/2011 - JMF: calia afegir
                  -- Bug 20999 - APD - 26/01/2012 - si existe comision indirecta,
                  -- vcmodcom = pcmodcom (caso de Liberty)
                  -- vcageind = vcage_padre (agente padre del xcagente)
                  -- sino
                  -- vcmodcom = pcmodcom + 2 (resto empresas)
                  vpas := 2660;

                  IF vccomind IS NOT NULL THEN
                     vcmodcom := pcmodcom;
                     vcageind := vcage_padre;
                     -- el calculo del porcentaje de la comision debe hacerse
                     -- por cuadros de comisión indirecta pero modalidad directa
                     vmodo_comind := 1;
                  ELSE
                     vcmodcom := pcmodcom + 2;
                     -- el calculo del porcentaje de la comision debe hacerse
                     -- Por agente indirecto y modalidad indirecta en el cuadro asignado al agente
                     vmodo_comind := 0;
                  END IF;

                  -- fin Bug 20999 - APD - 26/01/2012
                  -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
                  -- de la variable v_fefectorec
                  -- Bug 20999 - APD - 26/01/2012 - se informa el parametro pccomind con el valor
                  -- 1 para indicar que se quiere calcular el porcentaje de la comision indirecta
                  vpas := 2670;

                  -- FBL. 25/06/2014 MSV Bug 0028974
                  IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                    pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                     -- MSV Comisiones especiales
                     n_error :=
                        pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 17,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                     IF n_error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                    'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                    '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                    || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                    || ') - ' || '(porragente = ' || porragente || ') - '
                                    || '(v_fefectorec = ' || v_fefectorec || ') - '
                                    || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                    || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom
                                    || ') - ' || '(pnrecibo = ' || pnrecibo || ') - '
                                    || '(vcageind = ' || vcageind || ') - ' || '(pcramo = '
                                    || pcramo || ') - ' || '(pcmodali = ' || pcmodali
                                    || ') - ' || '(pctipseg = ' || pctipseg || ') - '
                                    || '(pccolect = ' || pccolect || ') - ');
                        RETURN error;
                     END IF;
                  -- Fin FBL. 25/06/2014 MSV Bug 0028974
                  ELSE
                     error := f_pcomisi(psseguro, vcmodcom, f_sysdate, porcagente, porragente,
                                        vcageind, pcramo, pcmodali, pctipseg, pccolect, NULL,
                                        xcgarant, pttabla, pfuncion, v_fefectovig, NULL,
                                        vmodo_comind, NVL(xnriesgo, 1));   --JRH nRiesgo

                     -- fin Bug 20999 - APD - 26/01/2012
                     -- fin Bug 20153 - APD - 15/11/2011
                     IF error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomisi', 2,
                                    'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                    '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                    || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                    || ') - ' || '(porragente = ' || porragente || ') - '
                                    || '(v_fefectorec = ' || v_fefectorec || ') - '
                                    || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                    || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom
                                    || ') - ' || '(pnrecibo = ' || pnrecibo || ') - '
                                    || '(vcageind = ' || vcageind || ') - ' || '(pcramo = '
                                    || pcramo || ') - ' || '(pcmodali = ' || pcmodali
                                    || ') - ' || '(pctipseg = ' || pctipseg || ') - '
                                    || '(pccolect = ' || pccolect || ') - ');
                        RETURN error;
                     END IF;
                  -- FBL. 25/06/2014 MSV Bug 0028974
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               END IF;

               vpas := 2680;
               comis_calc := 0;
               reten_calc := 0;

               IF v_comian = 0 THEN
                  vpas := 2690;
                  comis_calc := NVL(iconcep0, 0) * porcagente / 100;
                  v_iconcep_monpol := NVL(iconcep0_monpol, 0) * porcagente / 100;
               ELSE
                  vpas := 2700;

                  IF ADD_MONTHS(xfefepol, v_comian * 12) > xfeferec
                     AND((xctiprec = 0)
                         OR xctiprec = 3
                            AND TO_CHAR(xfefepol) = TO_CHAR(xfeferec)) THEN
                     vpas := 2710;
                     comis_calc := NVL(iconcep21, 0) * porcagente / 100;
                     vpas := 2720;
                     v_iconcep_monpol := NVL(iconcep21_monpol, 0) * porcagente / 100;
                  ELSIF ADD_MONTHS(xfefepol, v_comian * 12) <= xfeferec THEN
                     vpas := 2730;
                     comis_calc := NVL(iconcep0, 0) * porcagente / 100;
                     v_iconcep_monpol := NVL(iconcep0_monpol, 0) * porcagente / 100;
                  END IF;
               END IF;

               IF NVL(comis_calc, 0) <> 0
                  AND NVL(porcagente, 0) <> 0 THEN   --INSERTEM LA COMISIO
                  -- FBL. 25/06/2014 MSV Bug 0028974
                  IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                    pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                     --AND v_comisi_total > 0 THEN  --rdd28042015
                     -- MSV Comisiones especiales
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2740;
                        error :=
                           f_insdetrec
                                (pnrecibo, 17, v_comisi_total, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro, 1, v_comisi_monpol_total,   --rdd v_iconcep_monpol,
                                 NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     ELSE
                        vpas := 2750;
                        error :=
                           f_insdetrec
                                (pnrecibo, 17, v_comisi_total, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro);
                     END IF;
                  -- Fin FBL. 25/06/2014 MSV Bug 0028974
                  ELSE
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2740;
                        error :=
                           f_insdetrec
                                (pnrecibo, 17, comis_calc, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro, 1, v_iconcep_monpol,
                                 NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     ELSE
                        vpas := 2750;
                        error :=
                           f_insdetrec
                                (pnrecibo, 17, comis_calc, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;

                     -- INI Bug 27067 - AFM - 13/06/2013
                     vpas := 2751;
                     vsumcomis := 0;
                     vsumcomis_monpol := 0;
                     ppcomisi_concep := 0;
                     vsumporcage := 0;

                     --
                     FOR i IN 1 .. 3 LOOP
                        --
                        error := f_busca_pcomisi_concep(psseguro, xcgarant, i, pcmodcom,
                                                        v_fefectovig, vmodo_comind,
                                                        ppcomisi_concep);

                        IF error != 0 THEN
                           p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                       'Error al volver de f_busca_pcomisi_concep error:'
                                       || error || '-' || SQLCODE || ' ' || SQLERRM);
                           ppcomisi_concep := 0;
                           error := 0;
                        END IF;

                        --
                        vsumporcage := vsumporcage + ppcomisi_concep;

                        --
                        IF NVL(ppcomisi_concep, 0) <> 0
                           AND error = 0 THEN
                           IF i = 1 THEN
                              concep_concep := 47;
                           ELSIF i = 2 THEN
                              concep_concep := 48;
                           ELSE
                              concep_concep := 49;
                           END IF;

                           --
                           comis_calc_concep := NVL(comis_calc, 0) * ppcomisi_concep / porcagente;

                           --
                           IF (vsumporcage = porcagente) THEN   -- Ajustamos si ya no hay más %, ya que la suma de conceptos es = total comision
                              comis_calc_concep := comis_calc - vsumcomis;
                           END IF;

                           --
                           vsumcomis := vsumcomis + comis_calc_concep;

                           --
                           IF v_cmultimon = 1 THEN
                              --
                              vpas := 2752;
                              --
                              comis_calc_concep_monpol :=NVL(v_iconcep_monpol, 0) * ppcomisi_concep / porcagente;

                              --
                              IF (vsumporcage = porcagente) THEN   -- Si es el último o no Ajustamos,
                                 comis_calc_concep_monpol :=
                                                           v_iconcep_monpol - vsumcomis_monpol;
                              END IF;

                              --
                              vsumcomis_monpol := vsumcomis_monpol + comis_calc_concep_monpol;
                              --
                              error := f_insdetrec(pnrecibo, concep_concep, comis_calc_concep,
                                                   xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                   xctipcoa, xcageven, xnmovima,
                                                   ppcomisi_concep, psseguro, 1,
                                                   comis_calc_concep_monpol,
                                                   NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                   pmoneda);
                           ELSE
                              vpas := 2753;
                              error := f_insdetrec(pnrecibo, concep_concep, comis_calc_concep,
                                                   xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                   xctipcoa, xcageven, xnmovima,
                                                   ppcomisi_concep, psseguro);
                           END IF;
                        --
                        END IF;
                     --
                     END LOOP;

                     -- FIN Bug 27067 - AFM - 13/06/2013
                     vpas := 2760;
                     reten_calc := ((comis_calc * porragente) / 100);
                     vpas := 2770;
                     v_iconcep_monpol := ((v_iconcep_monpol * porragente) / 100);

                     IF NVL(reten_calc, 0) <> 0 THEN   -- INSERTEM LA RETENCIO
                        IF v_cmultimon = 1 THEN
                           -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                           vpas := 2780;
                           error := f_insdetrec(pnrecibo, 18, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                        ELSE
                           vpas := 2790;
                           error := f_insdetrec(pnrecibo, 18, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro);
                        END IF;

                        IF error != 0 THEN
                           CLOSE cur_detrecibos;

                           RETURN error;
                        END IF;
                     END IF;
                  -- FBL. 25/06/2014 MSV Bug 0028974
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               END IF;

               --CALCUL COMISIO I RETENCIO INDIRECTES DEVENGADES(CCONCEP = 19 I 20)(MODE 'R' : REAL)
               vpas := 2800;
               comis_calc := NVL(iconcep21, 0) * porcagente / 100;
               vpas := 2810;
               v_iconcep_monpol := NVL(iconcep21_monpol, 0) * porcagente / 100;

               IF NVL(comis_calc, 0) <> 0
                  AND NVL(porcagente, 0) <> 0 THEN
                  --INSERTEM LA COMISIO DEVENGADA
                  -- FBL. 25/06/2014 MSV Bug 0028974
                  IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                    pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                     n_error :=
                        pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 19,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                     IF n_error <> 0 THEN
                        p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                    'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                    '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                    || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                    || ') - ' || '(porragente = ' || porragente || ') - '
                                    || '(v_fefectorec = ' || v_fefectorec || ') - '
                                    || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                    || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom
                                    || ') - ' || '(pnrecibo = ' || pnrecibo || ') - '
                                    || '(vcageind = ' || vcageind || ') - ' || '(pcramo = '
                                    || pcramo || ') - ' || '(pcmodali = ' || pcmodali
                                    || ') - ' || '(pctipseg = ' || pctipseg || ') - '
                                    || '(pccolect = ' || pccolect || ') - ');
                        RETURN error;
                     END IF;

                     --IF v_comisi_total > 0 THEN  rdd28042015
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2550;
                        error := f_insdetrec(pnrecibo, 19, v_comisi_total, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro, 1,
                                             --v_iconcep_monpol,  rdd
                                             v_comisi_monpol_total,   --rdd
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        vpas := 2560;
                        error := f_insdetrec(pnrecibo, 19, v_comisi_total, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro);
                     END IF;
                     --END IF;
                  -- Fin FBL. 25/06/2014 MSV Bug 0028974
                  ELSE
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 2820;
                        error :=
                           f_insdetrec
                                (pnrecibo, 19, comis_calc, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro, 1, v_iconcep_monpol,
                                 NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                     ELSE
                        vpas := 2830;
                        error :=
                           f_insdetrec
                                (pnrecibo, 19, comis_calc, xploccoa, xcgarant,
                                 NVL(xnriesgo, 0), xctipcoa, vcageind,   -- AFM 13/06/2013 liquidaciones Indirectas xcageven,
                                 xnmovima, porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detrecibos;

                        RETURN error;
                     END IF;

                     vpas := 2840;
                     reten_calc := ((comis_calc * porragente) / 100);
                     vpas := 2850;
                     v_iconcep_monpol := ((v_iconcep_monpol * porragente) / 100);

                     IF NVL(reten_calc, 0) <> 0 THEN
                        -- INSERTEM LA RETENCIO DEVENGADA
                        IF v_cmultimon = 1 THEN
                           -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                           vpas := 2860;
                           error := f_insdetrec(pnrecibo, 20, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                        ELSE
                           vpas := 2870;
                           error := f_insdetrec(pnrecibo, 20, reten_calc, xploccoa, xcgarant,
                                                NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro);
                        END IF;

                        IF error != 0 THEN
                           CLOSE cur_detrecibos;

                           RETURN error;
                        END IF;
                     END IF;
                  -- FBL. 25/06/2014 MSV Bug 0028974
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               END IF;
            END IF;

            -- BUG 25988 - FAL - 13/02/2013
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(xcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            -- 41. 0029362: LCOL_C004-Error en comisiones Liberty Web - Nota: 175735 - Inicio
            -- En caso de sobrecomisiones no se ha de tener en cuenta la parte cedida
            --IF iconcep0 <> 0
            --   AND v_sobrecomis = 1 THEN
            IF v_sobrecomis = 1 THEN
               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO iconcep0, iconcep0_monpol
                   FROM detrecibos
                  WHERE nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cconcep IN(0)   -- LOCAL
               GROUP BY nriesgo, cgarant;

               IF iconcep0 <> 0 THEN
                  -- 41. 0029362: LCOL_C004-Error en comisiones Liberty Web - Nota: 175735 - Final
                  error :=
                     pac_comconvenios.f_sobrecomision_convenio
                                        (pnrecibo, pcmodcom, pmodo,   --Bug 25988/145451 - 10/06/2013 - AMC
                                         ptipomovimiento,   --Bug 25988/145451 - 10/06/2013 - AMC
                                         v_pcomisi);

                  IF error = 0
                     AND v_pcomisi <> 0 THEN
                     -- 25988/144278 - 14/05/2013 - AMC
                     BEGIN
                        SELECT ppartici / 100
                          INTO v_ppartici
                          FROM age_corretaje
                         WHERE sseguro = psseguro
                           AND islider = 1
                           AND nmovimi = (SELECT MAX(nmovimi)
                                            FROM age_corretaje
                                           WHERE sseguro = psseguro);
                     EXCEPTION
                        WHEN NO_DATA_FOUND THEN
                           v_ppartici := 1;
                     END;

                     --INI bug 29362#c161261, JDS 12/12/2013
                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'CONCEP_COMISION'), 0) = 1 THEN
                        SELECT NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                          INTO iconcep8, iconcep8_monpol
                          FROM detrecibos
                         WHERE nrecibo = pnrecibo
                           AND nriesgo = xnriesgo
                           AND cgarant = xcgarant
                           AND NVL(nmovima, -1) = NVL(xnmovima, -1)
                           -- 41. 0029362: LCOL_C004-Error en comisiones Liberty Web - Nota: 175735 - Inicial
                           AND cconcep IN(8);   -- LOCAL + CEDIDA
                        -- AND cconcep IN(8, 58);   -- LOCAL + CEDIDA
                     -- 41. 0029362: LCOL_C004-Error en comisiones Liberty Web - Nota: 175735 - Final
                     ELSE
                        iconcep8 := 0;
                        iconcep8_monpol := 0;
                     END IF;

                     --JLV si tiene co-corretaje le aplicará el porcentaje de participación que le corresponda,
                     --sino, lo multiplica por la unidad.
                     --v_iconcep := f_round((v_pcomisi *(iconcep0 * v_ppartici) / 100), pmoneda);
                     --v_iconcep_monpol := f_round((v_pcomisi *(iconcep0_monpol * v_ppartici) / 100),
                                              --   v_cmonpol);
                     v_iconcep := (v_pcomisi *((NVL(iconcep0, 0) + NVL(iconcep8, 0)) * v_ppartici) / 100);
                     v_iconcep_monpol := (v_pcomisi
                                                  *((NVL(iconcep0_monpol, 0)
                                                     + NVL(iconcep8_monpol, 0))
                                                    * v_ppartici)
                                                  / 100);

                     --FI bug 29362#c161261, JDS 12/12/2013
                     IF v_cmultimon = 1 THEN
                        vpas := 2880;
                        error := f_insdetrec(pnrecibo, 43, v_iconcep, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), 0, xcageven, xnmovima,
                                             porcagente, psseguro, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);   --Bug 29362  xctipcoa  Liberty Web no genera cedido
                     ELSE
                        vpas := 2890;
                        error := f_insdetrec(pnrecibo, 43, v_iconcep, xploccoa, xcgarant,
                                             NVL(xnriesgo, 0), 0, xcageven, xnmovima,
                                             porcagente, psseguro);   --Bug 29362  xctipcoa  Liberty Web no genera cedido
                     END IF;
                  END IF;
               END IF;
            END IF;

            -- FI BUG 25988

            -- FIN Bug 19586. JMC. 28/09/2011.
            IF error != 0 THEN
               CLOSE cur_detrecibos;

               RETURN error;
            END IF;
         END IF;   -- IF DE SELECCIO DELS TIPUS 00, 01, 21 I 22

         vpas := 2880;

         FETCH cur_detrecibos
          INTO xnriesgo, xcgarant, xcageven, xnmovima;
      END LOOP;

      CLOSE cur_detrecibos;

      RETURN 0;
   ELSIF pmodo IN('N', 'P', 'PRIE') THEN
      -- CAS DE CRIDA PER F_PREVRECIBO (ANUAL)/PROVES(AVANÇ CARTERA)
      --SMF. (ALN) NECESSITAMOS LA FECHA DE EFECTO DEL RECIBO PARA LOS DERECHOS
      --DE REGISTRO.
      vpas := 2900;

      SELECT fefecto, fvencim, cempres, ctiprec, femisio, cempres
                                                                 --, nmovimi
                                                                 -- 23074 -- JLB - I
      ,      nfracci, nanuali
        -- 23074 -- JLB - F
      INTO   xfefecto, xfvencim, xcempres, xctiprec, v_femisio, v_cempres
                                                                         --, xnmovimi -- No para cartera
                                                                             -- 23074 -- JLB - I
      ,      xnfracci, xnanuali
        -- 23074 -- JLB - F
      FROM   reciboscar
       WHERE sproces = pnproces
         AND nrecibo = pnrecibo;

      -- Bug 20384 - APD - 09/01/2012 - se guarda la fecha efecto del recibo necesaria
      -- para pasarla a la funcion f_pcomisi
      -- aunque se busca tambien en la select de arriba, se vuelve a buscar ya que la
      -- variable xfefecto puede cambiar luego de valor y no ser por tanto la fecha
      -- de efecto real del recibo
      vpas := 2910;

      SELECT fefecto
        INTO v_fefectorec
        FROM reciboscar
       WHERE nrecibo = pnrecibo
         AND sproces = pnproces;

      -- Bug 0021435/0110494 - FAL - 23/03/2012 - Filtrar tmb por proceso.

      -- fin Bug 20384 - APD - 09/01/2012
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      vpas := 2920;
      v_cmultimon := NVL(pac_parametros.f_parempresa_n(xcempres, 'MULTIMONEDA'), 0);

      IF v_cmultimon = 1 THEN
         v_cmonemp := pac_parametros.f_parempresa_n(xcempres, 'MONEDAEMP');
      END IF;

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda

      --Bug 10851 - APD - 31/07/2009 - se guarda en la variable xfeferec la fecha de efecto del recibo
      -- la variable xfefecto se utiliza para guardar la fecha de efecto de la vigencia de los recargos
      -- e impuestos que se deben aplicar.
      vpas := 2930;
      xfeferec := xfefecto;
      v_tipfec := pac_parametros.f_parproducto_n(xsproduc, 'FECHA_IMPUESTOS');
      v_comian := NVL(pac_parametros.f_parproducto_n(xsproduc, 'COMISANU'), 0);

      -- bug 170717
      IF v_tipfec = 0 THEN
         --Bug.: 10709 - DCT - 20/07/09
         BEGIN
            vpas := 2940;

            SELECT fcaranu
              INTO xfcaranu
              FROM seguros
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  vpas := 2950;

                  SELECT NVL(fcaranu, fefecto)
                    INTO xfcaranu
                    FROM estseguros
                   WHERE sseguro = psseguro;
               EXCEPTION
                  WHEN OTHERS THEN
                     error := 101919;
                     RETURN error;
               END;
         END;

         -- Si la Fecha cartera anualidad es menor que la fecha del recibo (aun no ha renovado
         -- la poliza) la Fecha CLEA se debe comparar con la Fecha cartera anualidad
         -- En caso contrario, la Fecha CLEA se debe comparar con la fecha de renovacion
         IF xfcaranu <= xfefecto THEN
            xfefecto := xfcaranu;
         ELSE
            vpas := 2960;
            error := f_ultrenova(psseguro, xfefecto, xfefecto, xnmovimi);

            IF error != 0 THEN
               RETURN error;
            END IF;
         END IF;
      ELSIF v_tipfec = 2 THEN   --efecto del seguro
         -- Bug 10851 - APD - 31/07/2009 - En funcion de si se está realizando un Previo de Cartera
         -- o creando una nueva poliza, se buscará la fefecto de la tabla seguros o estseguros
         IF pmodo IN('P', 'PRIE') THEN   -- Previo Cartera
            BEGIN
               vpas := 2970;

               SELECT fefecto
                 INTO xfefecto
                 FROM seguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  error := 101919;   --Error al leer datos de la tabla SEGUROS
                  RETURN error;
            END;
         ELSIF pmodo = 'N' THEN   -- Nueva produccion
            BEGIN
               vpas := 2980;

               SELECT fefecto
                 INTO xfefecto
                 FROM estseguros
                WHERE sseguro = psseguro;
            EXCEPTION
               WHEN OTHERS THEN
                  error := 101919;   --Error al leer datos de la tabla SEGUROS
                  RETURN error;
            END;
         END IF;
      END IF;

      --FI Bug.: 10709 - DCT - 20/07/09
      -- bug17017
      IF pmodo IN('P', 'PRIE') THEN   -- Previo Cartera
         vpas := 2990;

         SELECT fefecto, NVL(cmoneda, v_cmonemp)
           INTO xfefepol, v_cmonpol
           FROM seguros
          WHERE sseguro = psseguro;
      ELSIF pmodo = 'N' THEN   -- Nueva produccion
         vpas := 3000;

         SELECT fefecto
           INTO xfefepol
           FROM estseguros
          WHERE sseguro = psseguro;
      ELSE
         vpas := 3010;

         SELECT fefecto, NVL(cmoneda, v_cmonemp)
           INTO xfefepol, v_cmonpol
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;

      -- End bug 17017

      /*--Bug.: 10709 - ICV - 16/07/09 - Se elige la fecha de impuestos dependiendo de parametro.
            -- si es del tipo 1 fecha efecto del recibo no se hace nada
      v_tipfec := pac_parametros.f_parproducto_n(xsproduc, 'FECHA_IMPUESTOS');
      IF v_tipfec = 0 THEN   --f_ultrenova
         num_err := f_ultrenova(psseguro, xfefecto, xfefecto, nmovren);
         IF num_err <> 0 THEN
            p_tab_error(f_sysdate, f_user, 'f_imprecibos', 2,
                        'psseguro : ' || psseguro || ' pmodo : ' || pmodo, SQLERRM);
            RETURN num_err;
         END IF;
      ELSIF v_tipfec = 2 THEN   --efecto del seguro
         SELECT fefecto
           INTO xfefecto
           FROM seguros
          WHERE sseguro = psseguro;
      END IF;
      --Fi bug.: 10709*/

      --
      -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      vpas := 3020;

      IF v_cmultimon = 1
         AND ptipomovimiento IN(0, 1, 6, 21, 22) THEN
         vpas := 3030;
         num_err := pac_oper_monedas.f_contravalores_recibo(pnrecibo, pmodo, pnproces);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;

         vpas := 3040;

         SELECT NVL(MAX(fcambio), v_femisio)
           INTO v_fcambio
           FROM detreciboscar
          WHERE sproces = pnproces
            AND nrecibo = pnrecibo;

         vpas := 3050;
         num_err := pac_oper_monedas.f_datos_contraval(NULL, pnrecibo, NULL, v_fcambio, 1,
                                                       v_itasa, v_fcambioo, pmodo, pnproces);

         IF num_err <> 0 THEN
            RETURN num_err;
         END IF;
      END IF;

      -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
      vpas := 3060;

      OPEN cur_detreciboscar;

      vpas := 3070;

      FETCH cur_detreciboscar
       INTO xnriesgo, xcgarant, xcageven, xnmovima;

      vpas := 3080;

      WHILE cur_detreciboscar%FOUND LOOP
         iconcep0 := 0;
         iconcep0_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
         iconcep21 := 0;
         iconcep21_monpol := 0;   -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
         xprecarg := 0;
         taxaips := 0;
         taxadgs := 0;
         taxaarb := 0;
         taxafng := 0;
         xcimpips := 0;
         xcimparb := 0;
         xcimpdgs := 0;
         xcimpfng := 0;
         xcrespue := 1;
         totrecfracc := 0;

         IF ptipomovimiento IN(0, 1, 6, 21, 22) THEN
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 0
            BEGIN
               vpas := 3090;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO iconcep0, iconcep0_monpol
                   FROM detreciboscar
                  WHERE sproces = pnproces
                    AND nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cgarant = xcgarant
                    AND cconcep IN(0, 50)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;

               xiconcep := iconcep0;
               grabar := 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
                  grabar := 0;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                  RETURN error;
            END;

            IF NVL(ppdtoord, 0) <> 0 THEN
               IF grabar = 1 THEN   -- CALCULEM EL DESCOMPTE O.M. (CCONCEP=13)
                  vpas := 3100;
                  xxiconcep := (xiconcep * ppdtoord) / 100;

                  IF NVL(xxiconcep, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        v_iconcep_monpol := (iconcep0_monpol * ppdtoord) / 100;
                        vpas := 3110;
                        error := f_insdetreccar(pnproces, pnrecibo, 13, xxiconcep, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima, 0, 0, 1, v_iconcep_monpol,
                                                NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 3120;
                        error := f_insdetreccar(pnproces, pnrecibo, 13, xxiconcep, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detreciboscar;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            END IF;

            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 21
            BEGIN
               vpas := 3130;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO iconcep21, iconcep21_monpol
                   FROM detreciboscar
                  WHERE sproces = pnproces
                    AND nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND cgarant = xcgarant
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cconcep IN(21, 71)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                  RETURN error;
            END;

            -- TROBEM EL CONCEPTE DE LA BONIFICACIÓ DEL REBUT
            BEGIN
               vpas := 3140;

               SELECT   NVL(SUM(iconcep), 0), NVL(SUM(iconcep_monpol), 0)
                   INTO idto, idto_monpol
                   FROM detreciboscar
                  WHERE sproces = pnproces
                    AND nrecibo = pnrecibo
                    AND nriesgo = xnriesgo
                    AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                    AND cgarant = xcgarant
                    AND cconcep IN(10 + 60)   -- LOCAL + CEDIDA
               GROUP BY nriesgo, cgarant;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                  RETURN error;
            END;

            --BUG9658 -- 02/04/2009 -- JTS
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 17
            vpas := 3150;

            IF error = 0 THEN
               DECLARE
                  v_diasvigencia NUMBER(3);
                  v_iconcep17    detrecibos.iconcep_monpol%TYPE;   --NUMBER(15, 2); Ampliación decimales

                  -- Bug 10865 - RSC - 04/08/2009 - APR: error en comisiones de adquisición
                  -- Se modifica cursor
                  CURSOR cur_comisigaranseg IS
                     SELECT icomanu icomanu, sseguro sseguro, nriesgo nriesgo,
                            finiefe finiefe, ffinpg ffinpg
                       FROM comisigaransegcar
                      -- Bug.13607 APR - Comisiones de adquisión en previo de cartera
                     WHERE  sseguro = psseguro
                        --AND nmovimi = xnmovimi -- Bug 10865
                        AND sproces = pnproces
                        -- Bug.13607 APR - Comisiones de adquisión en previo de cartera
                        AND finiefe <= xfeferec
                        AND ffinpg > xfeferec
                        -- Bug 13515 - 10/03/2010 - RSC - APR - Error en el calculo de comisiones
                        AND cgarant = xcgarant
                        AND itotcom > 0
                     UNION   --Bug.: 14476 - ICV - 11/05/2010
                     SELECT icomanu, sseguro, nriesgo, finiefe, ffinpg
                       FROM comisigaranseg
                      -- Bug.13607 APR - Comisiones de adquisión en previo de cartera
                     WHERE  sseguro = psseguro
                        AND finiefe <= xfeferec
                        AND ffinpg > xfeferec
                        -- Bug 13515 - 10/03/2010 - RSC - APR - Error en el calculo de comisiones
                        AND cgarant = xcgarant
                        AND itotcom > 0;
               -- Bug 10865 - RSC - 10/08/2009 - APR: error en comisiones de adquisición
               --Fin bug.: 14476
               -- Fin Bug 10865
               BEGIN
                  vpas := 3160;

                  FOR i IN cur_comisigaranseg LOOP
                     -- Bug 10851 - APD - 31/07/2009 - se le debe pasar la xfeferec a la funcion
                     -- f_difdata en vez de xfefecto
                     vpas := 3170;
                     error := f_difdata(xfeferec, xfvencim, 3, 3, v_diasvigencia);
                     v_iconcep17 := i.icomanu *(v_diasvigencia / 360);

                     IF NVL(v_iconcep17, 0) <> 0 THEN
                           -- Bug 10865 - RSC - 04/08/2009 - APR: error en comisiones de adquisición
                           -- Se le pasa el pnproces, anteriormente no se le pasaba y cascaba!!!
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        IF v_cmultimon = 1 THEN
                           vpas := 3180;
                           v_iconcep_monpol := v_iconcep17 * v_itasa;
                           error := f_insdetreccar(pnproces, pnrecibo, 17, v_iconcep17,
                                                   xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                   xctipcoa, xcageven, xnmovima, porcagente,
                                                   psseguro, 1, v_iconcep_monpol,
                                                   NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                   pmoneda);
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        ELSE
                           -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                           vpas := 3190;
                           error := f_insdetreccar(pnproces, pnrecibo, 17, v_iconcep17,
                                                   xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                   xctipcoa, xcageven, xnmovima, porcagente,
                                                   psseguro);
                        END IF;

                        -- Fin Bug 10865
                        IF error != 0 THEN
                           CLOSE cur_detreciboscar;

                           RETURN error;
                        END IF;
                     END IF;
                  END LOOP;
               END;
            ELSE
               CLOSE cur_detreciboscar;

               RETURN error;
            END IF;

            --BUG9658 -- 02/04/2009 -- JTS

            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 29
            --SMF CONCEPTO DE CAMPANYES
            --TROBEM EL TOTAL DE ICONCEP PER CCONCEP = 29
            --pasamos el importe recibido por parametros no el
            --hayado en esta funcion (descuentos de campanya
            --alta o baja de campanya en un suplemento sin dar
            -- de alta la garantia en ese movimiento)
            vpas := 3200;
            error := f_calculo_dtocampanya(psseguro, xnriesgo, xcgarant, xnmovima, xfvencim,
                                           iconcep0, pprorata, xidtocam);
            vpas := 3210;
            xidtocam_monpol := xidtocam * v_itasa;

            --  BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            IF error = 0 THEN
               IF NVL(xidtocam, 0) <> 0 THEN
                  xidtocam := xidtocam;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := xidtocam_monpol;
                     vpas := 3220;
                     error := f_insdetreccar(pnproces, pnrecibo, 29, xidtocam, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima, porcagente, psseguro, 1,
                                             v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                             v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3230;
                     error := f_insdetreccar(pnproces, pnrecibo, 29, xidtocam, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima, porcagente, psseguro);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detreciboscar;

                     RETURN error;
                  END IF;
               END IF;
            ELSE
               CLOSE cur_detreciboscar;

               RETURN error;
            END IF;

            -- TROBEM EL CONCEPTE DE LA BONIFICACIÓ ANUALITZADA
            -- Només tindrem informat garancar si és renovació
            BEGIN
               vpas := 3240;

               SELECT SUM(idtocom * -1)
                 INTO idto21
                 FROM garancar
                WHERE sproces = pnproces
                  AND sseguro IN(SELECT sseguro
                                   FROM reciboscar
                                  WHERE sproces = pnproces
                                    AND nrecibo = pnrecibo)
                  AND nriesgo = xnriesgo
                  AND cgarant = xcgarant;

               idto21_monpol := idto21 * v_itasa;
            -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  NULL;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  error := 103502;   -- ERROR AL LLEGIR DE GARANCAR
                  RETURN error;
            END;

            --CALCULEM EL RECARREC PER FRACCIONAMENT (CCONCEP = 8)
            IF pcrecfra = 1
               AND pcforpag IS NOT NULL THEN
               vpas := 3250;
               xprecarg := NULL;
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               totrecfracc := NULL;
               totrecfracc_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 3260;
               error := f_concepto(8, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               xprecarg := NVL(vnvalcon, 0);

               --Damos valor al porcetaje de recargo por fraccionamiento
               IF NVL(vnvalcon, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3270;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol, NULL,
                                                                     NULL, NULL, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol,
                                                                     'SEG', NULL, NULL,
                                                                     xnmovimi);
                        vpas := 3280;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3290;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, NULL, NULL,
                                                                     NULL, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda, 'SEG',
                                                                     NULL, NULL, xnmovimi);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3300;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, NULL, NULL, NULL,
                                                                  vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                       -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda, 'SEG', NULL, NULL,
                                                                  xnmovimi);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 3310;
                  totrecfracc := oiconcep;
                  totrecfracc_monpol := oiconcep_monpol;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda

                  -- Fin LPS (04/08/2008)
                  IF NVL(totrecfracc, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        v_iconcep_monpol := totrecfracc_monpol;
                        vpas := 3320;
                        error := f_insdetreccar(pnproces, pnrecibo, 8, totrecfracc, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima, 0, 0, 1, v_iconcep_monpol,
                                                NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 3330;
                        error := f_insdetreccar(pnproces, pnrecibo, 8, totrecfracc, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detreciboscar;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            END IF;

            --BUSQUEM EL IMPOST DGS DE LA GARANTIA I ELS DEMÉS
            BEGIN
               vpas := 3340;

               SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                      NVL(cimpfng, 0)
                 INTO xcimpdgs, xcimpips, xcderreg, xcimparb,
                      xcimpfng
                 FROM garanpro
                WHERE cramo = pcramo
                  AND cmodali = pcmodali
                  AND ccolect = pccolect
                  AND ctipseg = pctipseg
                  AND cgarant = xcgarant
                  AND cactivi = NVL(pcactivi, 0);
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  BEGIN
                     vpas := 3350;

                     SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0),
                            NVL(cimparb, 0), NVL(cimpfng, 0)
                       INTO xcimpdgs, xcimpips, xcderreg,
                            xcimparb, xcimpfng
                       FROM garanpro
                      WHERE cramo = pcramo
                        AND cmodali = pcmodali
                        AND ccolect = pccolect
                        AND ctipseg = pctipseg
                        AND cgarant = xcgarant
                        AND cactivi = 0;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detreciboscar;

                        error := 104110;   -- PRODUCTE NO TROBAT A GARANPRO
                        RETURN error;
                     WHEN OTHERS THEN
                        CLOSE cur_detreciboscar;

                        error := 103503;
                        -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                        RETURN error;
                  END;
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  error := 103503;   -- ERROR AL LLEGIR DE LA TAULA GARANPRO
                  RETURN error;
            END;

            vpas := 3360;

            -- LPS (03/10/2009), se comenta la parte de derechos de registro, ya que no se tarifica y no se utiliza este impuesto.
            -- En caso de que se necesite hacer un tratamiento como el de los demás impuestos.
            -- Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro
            IF xcderreg > 0 THEN
               -- Bug 0019578 - FAL - 26/09/2011. Incluir llamada concepto 14 (derechos registro)
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepderreg := NULL;
               tot_iconcepderreg_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - Multimoneda
               vpas := 3370;

               -- Bug 19557 - APD - 31/10/2011 - de momento para Liberty, los gastos de
               -- expedicion se calculan de manera diferente que para el resto de empresas
               -- (se deben calcular sin tener en cuenta la tabla TARIFAS)
               -- por eso se crea el parempresa 'MODO_CALC_GASTEXP'
               -- El importe de los gastos de expedicion sólo se debe calcular en el
               -- momento de la emisión ('GASTEXP_CALCULO' = 1 (indica que si se debe calcular
               -- el importe de los gastos de expedicion para el producto) y
               -- ptipomovimiento = 0.-Nueva produccion para que sólo se calcule en el momento
               -- de la emisión)
               IF f_control_cderreg(psseguro, xnriesgo, xcgarant, xfeferec, xnmovima,
                                    ptipomovimiento) = 0 AND NOT (b_primerderreg = FALSE AND n_derreg_poliza = 1) THEN
                  --Se añade condición para el caso de que los gastos de expedición se apliquen a nivel de póliza y no de garantia
                  b_primerderreg := FALSE;

                  vpas := 3380;
                  -- Bug 10864.NMM.01/08/2009.
                  -- BUG 18423: LCOL000 - Multimoneda
                  -- Bug 0020314 - FAL - 29/11/2011
                  error := f_concepto(14, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                      pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                      vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,
                                      v_cmonimp, vcderreg);

                  IF error <> 0 THEN
                     CLOSE cur_detreciboscar;

                     p_tab_error(f_sysdate, f_user, vobj, vpas,
                                 'error ' || error || '.-' || f_axis_literales(error)
                                 || ' al llamar a f_concepto. pmodo = ' || pmodo,
                                 '(xcempres = ' || xcempres || ') - ' || '(xsproduc = '
                                 || xsproduc || ') - ' || '(cconcep = ' || 14 || ') - '
                                 || '(ptipomovimiento = ' || ptipomovimiento || ') - '
                                 || '(xfefecto = ' || xfefecto || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(xcderreg = ' || xcderreg || ') - ');
                     RETURN error;
                  END IF;
               ELSE
                  vnvalcon := 0;   -- para que no calcule el importe del concepto
               END IF;

               -- Bug 0019578 - FAL - 26/09/2011. Incluir llamada concepto 14 (derechos registro)
               vpas := 3440;
               taxaderreg := NVL(vnvalcon, 0);

               IF NVL(taxaderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3450;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol, NULL,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 3460;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3470;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, xprecarg, vctipcon,
                                                                     1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3480;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                       -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- bug0025826
                  vpas := 3490;

                  IF v_res4094 = 2
                     AND pcforpag NOT IN(0, 1) THEN
                     error := f_ultrenova(psseguro, xfefecto, d_ini, xnmovimi);

                     SELECT MAX(frenova), MAX(fcaranu)
                       INTO d_renova, d_caranu
                       FROM seguros
                      WHERE sseguro = psseguro;

                     d_fin := NVL(d_caranu, NVL(d_renova, ADD_MONTHS(xfefecto, 12)));
                     n_div := 12 / pcforpag;

                     IF d_ini IS NOT NULL
                        AND d_fin IS NOT NULL THEN
                        tot_iconcepderreg := NVL(oiconcep, 0)
                                             /(ROUND(MONTHS_BETWEEN(d_fin, d_ini)) / n_div);
                        tot_iconcepderreg_monpol :=
                           NVL(oiconcep_monpol, 0)
                           /(ROUND(MONTHS_BETWEEN(d_fin, d_ini)) / n_div);
                     ELSE
                        tot_iconcepderreg := NVL(oiconcep, 0);
                        tot_iconcepderreg_monpol := oiconcep_monpol;
                     END IF;
                  ELSE
                     tot_iconcepderreg := NVL(oiconcep, 0);
                     tot_iconcepderreg_monpol := oiconcep_monpol;
                  END IF;
               ELSE
                  tot_iconcepderreg := 0;
               END IF;
            -- Fi Bug 0019578 - FAL
            ELSE
               tot_iconcepderreg := 0;
            END IF;

            -- Bug 23074 - APD - 01/08/2012 - Incluir llamada concepto 86 (iva - derechos registro)
            IF tot_iconcepderreg <> 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               oiconcep_monpol := NULL;
               tot_iconcepivaderreg := NULL;
               tot_iconcepivaderreg_monpol := NULL;
               error := f_concepto(86, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaivaderreg := NVL(vnvalcon, 0);

               IF NVL(taxaivaderreg, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 1440;
                        error :=
                           pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0_monpol,
                                                               iconcep21_monpol, idto_monpol,
                                                               idto21_monpol, xidtocam_monpol,
                                                               xicapital_monpol, NULL,
                                                               xprecarg, vctipcon, 1,

                                                               -- Ponemos forpag = 1, ya que es un recibo
                                                               vcfracci, vcbonifi, vcrecfra,
                                                               oiconcep_monpol, NULL,
                                                               tot_iconcepderreg_monpol,
                                                               -- Bug 0020314 - FAL - 29/11/2011
                                                               --NULL, NULL, NULL, NULL, NULL,
                                                               --v_cmonpol);
                                                               -- MRB 31/08/2012
                                                               NULL, xfefecto, psseguro,
                                                               NVL(xnriesgo, 1), xcgarant,
                                                               v_cmonpol);
                        vpas := 1450;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 1460;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, xprecarg, vctipcon,
                                                                     1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     tot_iconcepderreg,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 1470;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  tot_iconcepderreg,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                       -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep :=oiconcep;
                     END IF;
                  END IF;

                  tot_iconcepivaderreg := NVL(oiconcep, 0);
                  tot_iconcepivaderreg_monpol := NVL(oiconcep_monpol, 0);
               ELSE
                  tot_iconcepivaderreg := 0;
                  tot_iconcepivaderreg_monpol := 0;
               END IF;
            ELSE
               tot_iconcepivaderreg := 0;
               tot_iconcepivaderreg_monpol := 0;
            END IF;

            -- fin Bug 23074 - APD - 01/08/2012
            vpas := 3500;

            --*/
            -- Fi Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- Fin Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro

            -- LPS (04/09/2008)
            IF xcimpdgs > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepdgs := NULL;
               tot_iconcepdgs_monpol := NULL;   -- BUG 18423 - 21/11/2011 - JMP - Multimoneda
               vpas := 3510;
               error := f_concepto(5, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                   pctipseg, pccolect, pcactivi, xcgarant, vctipcon, vnvalcon,
                                   vcfracci, vcbonifi, vcrecfra, w_climit,
                                   -- Bug 10864.NMM.01/08/2009.
                                   v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                   vcderreg   -- Bug 0020314 - FAL - 29/11/2011
                                           );
               taxadgs := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND error = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 3520;
                  error := pac_impuestos.f_calcula_impuestocapital(psseguro, NULL, xnriesgo,
                                                                   'CAR', 'CIMPDGS',
                                                                   xicapital, xcgarant);
                  vpas := 3530;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF error <> 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;

               IF NVL(taxadgs, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3540;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol,
                                                                     totrecfracc_monpol,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 3550;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3560;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     totrecfracc, xprecarg,
                                                                     vctipcon, 1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3570;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital,
                                                                  totrecfracc, xprecarg,
                                                                  vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                       -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 3580;
                  tot_iconcepdgs := NVL(oiconcep, 0);
                  tot_iconcepdgs_monpol := oiconcep_monpol;
               ELSE
                  tot_iconcepdgs := 0;
               END IF;

               -- Miramos si aun hay que calcular la DGS prorrateada.
               BEGIN
                  vpas := 3590;

                  SELECT sseguro
                    INTO dummy
                    FROM segcleafrac
                   WHERE sseguro = psseguro;

                  IF ptipomovimiento = 21 THEN
                     vpas := 3600;

                     DELETE FROM segcleafrac
                           WHERE sseguro = psseguro;
                  -- LPS (04/09/2008). Comentado, ya se calcula arriba.
                  /*ELSE
                                       IF vctipcon = 3
                     THEN
                        tot_iconcepdgs :=
                           f_round (  NVL (iconcep0, 0)
                                    * (NVL (vnvalcon, 0) / 100),
                                    pmoneda
                                   );
                     END IF;*/
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     NULL;
                  WHEN OTHERS THEN
                     CLOSE cur_detreciboscar;

                     error := 101919;
                     RETURN error;
               END;
            ELSE
               tot_iconcepdgs := 0;
            END IF;

            -- Fin LPS (04/09/2008)

            -- LPS (03/10/2009), se comenta la parte de derechos de registro, ya que no se tarifica y no se utiliza este impuesto.
            -- En caso de que se necesite hacer un tratamiento como el de los demás impuestos.
            -- Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro
            -- Fi Bug 0019578 - FAL - 26/09/2011 - Se descomenta
            -- Fin Bug 0020314 - FAL - 29/11/2011 - Se sube arriba para se calcule primero los derechos de registro

            -- LPS (04/09/2008)
            vpas := 3700;

            IF xcimpips > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepips := NULL;
               tot_iconcepips_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 3710;
               vnerror := f_concepto(4, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,

                                     -- Bug 10864.NMM.01/08/2009.
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaips := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND vnerror = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 3720;
                  vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, NULL, xnriesgo,
                                                                     'CAR', 'CIMPIPS',
                                                                     xicapital, xcgarant);
                  vpas := 3730;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN vnerror;
               END IF;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3740;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol,
                                                                     totrecfracc_monpol,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol,
                                                                     tot_iconcepderreg,
                                                                     vcderreg,
                                                                           -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gasto de emisión
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 3750;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3760;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     totrecfracc, xprecarg,
                                                                     vctipcon, 1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep,
                                                                     tot_iconcepderreg,
                                                                     vcderreg,
                                                                           -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gasto de emisión
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3770;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital,
                                                                  totrecfracc, xprecarg,
                                                                  vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep,
                                                                  tot_iconcepderreg, vcderreg,

                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gasto de emisión
                                                                                           -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 3780;
                  tot_iconcepips := NVL(oiconcep, 0);
                  tot_iconcepips_monpol := oiconcep_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconcepips := 0;
               END IF;
            ELSE
               --Ini Bug: 10196 - ICV - 25/05/2009
               tot_iconcepips := 0;
            --Fin Bug: 10196
            END IF;

            -- Fin LPS (04/08/2008)
            vpas := 3790;

            -- LPS (04/09/2008)
            IF xcimparb > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconceparb := NULL;
               tot_iconceparb_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 3800;
               vnerror := f_concepto(6, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,

                                     -- Bug 10864.NMM.01/08/2009.
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxaarb := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND vnerror = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 3810;
                  vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, NULL, xnriesgo,
                                                                     'CAR', 'CIMPARB',
                                                                     xicapital, xcgarant);
                  vpas := 3820;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN vnerror;
               END IF;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3830;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol,
                                                                     totrecfracc_monpol,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol,
                                                                     tot_iconcepderreg,
                                                                     vcderreg,
                                                                           -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 3840;
                        oiconcep :=oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3850;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     totrecfracc, xprecarg,
                                                                     vctipcon, 1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep,
                                                                     tot_iconcepderreg,
                                                                     vcderreg,
                                                                           -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3860;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital,
                                                                  totrecfracc, xprecarg,
                                                                  vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep,
                                                                  tot_iconcepderreg, vcderreg,

                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión
                                                                                           -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 3870;
                  tot_iconceparb := NVL(oiconcep, 0);
                  tot_iconceparb_monpol := oiconcep_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconceparb := 0;
               END IF;
            ELSE
               tot_iconceparb := 0;
            END IF;

            -- Fin LPS (04/09/2008)

            -- LPS (04/09/2008)
            vpas := 3880;

            IF xcimpfng > 0 THEN
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcepfng := NULL;
               tot_iconcepfng_monpol := NULL;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               vpas := 3890;
               vnerror := f_concepto(7, xcempres, xfefecto, pcforpag, pcramo, pcmodali,
                                     pctipseg, pccolect, pcactivi, xcgarant, vctipcon,
                                     vnvalcon, vcfracci, vcbonifi, vcrecfra, w_climit,

                                     -- Bug 10864.NMM.01/08/2009.
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
               taxafng := NVL(vnvalcon, 0);

               IF vctipcon = 4
                  AND vnerror = 0 THEN
                  -- Para impuesto sobre capital (no sobre prima)
                  vpas := 3900;
                  vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, NULL, xnriesgo,
                                                                     'CAR', 'CIMPFNG',
                                                                     xicapital, xcgarant);
                  vpas := 3910;

                  IF vcfracci = 0 THEN
                     IF xctiprec <> 3
                        OR(xctiprec = 3
                           AND xnfracci = 0) THEN
                        xicapital_monpol := (xicapital * v_itasa);
                        -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        xicapital := xicapital;
                     -- Parte que corresponde al recibo
                     END IF;
                  ELSE
                     xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     xicapital := xicapital / pcforpag;
                  END IF;
               -- Parte que corresponde al recibo
               END IF;

               IF vnerror <> 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN vnerror;
               END IF;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 3920;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol,
                                                                     totrecfracc_monpol,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, v_cmonpol);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, v_cmonpol);
                        vpas := 3930;
                        oiconcep :=oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 3940;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     totrecfracc, xprecarg,
                                                                     vctipcon, 1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                           -- Bug 0020314 - FAL - 29/11/2011
                                                                           --NULL, NULL, NULL, NULL,
                                                                           --NULL, pmoneda);
                                                                     -- MRB 31/08/2012
                                                                     NULL, xfefecto, psseguro,
                                                                     NVL(xnriesgo, 1),
                                                                     xcgarant, pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 3950;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital,
                                                                  totrecfracc, xprecarg,
                                                                  vctipcon, 1,
                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011
                                                                                                                       -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                     --NULL, NULL, NULL, NULL,
                                                                     --NULL, pmoneda);
                                                                  -- MRB 31/08/2012
                                                                  NULL, xfefecto, psseguro,
                                                                  NVL(xnriesgo, 1), xcgarant,
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  vpas := 3960;
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  tot_iconcepfng := NVL(oiconcep, 0);
                  tot_iconcepfng_monpol := oiconcep_monpol;
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               ELSE
                  tot_iconcepfng := 0;
               END IF;
            ELSE
               tot_iconcepfng := 0;
            END IF;

            -- Fin LPS (04/09/2008)
            IF NVL(tot_iconcepdgs, 0) <> 0
               AND taxadgs IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconcepdgs_monpol;
                  vpas := 3970;
                  error := f_insdetreccar(pnproces, pnrecibo, 5, tot_iconcepdgs, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 3980;
                  error := f_insdetreccar(pnproces, pnrecibo, 5, tot_iconcepdgs, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            --JRH Solución temporal para el ISI. Lo calculamos y substiruimosel valor del IPS por el ISI.
            DECLARE
               isiform        NUMBER;
               vsproduc       NUMBER;
               vcactivi       NUMBER;
               vcapgaran      NUMBER;
               a              NUMBER;
               vfefecto       DATE;
               importeisi     NUMBER;
               wicapital      NUMBER;   -- DRA 27-8-08: bug mantis 7372
               xftarifa       DATE;   -- jrh 27-8-08: bug mantis 7372
            BEGIN
               vpas := 4000;

               SELECT sproduc, cactivi
                 INTO vsproduc, vcactivi
                 FROM seguros
                WHERE sseguro = psseguro;

               vpas := 4010;
               error := f_pargaranpro(pcramo, pcmodali, pctipseg, pccolect, vcactivi, xcgarant,
                                      'ISI_FORMULA', isiform);
               isiform := NVL(isiform, 0);

               IF isiform <> 0 THEN
                  vpas := 4020;

                  -- DRA 27-8-08: bug mantis 7372
                  BEGIN
                     SELECT g.icapital, g.ftarifa
                       INTO xicapital, xftarifa
                       FROM garanseg g
                      WHERE g.sseguro = psseguro
                        AND g.nriesgo = NVL(pnriesgo, 1)
                        AND g.cgarant = xcgarant
                        AND g.nmovimi = (SELECT MAX(g1.nmovimi)
                                           FROM garanseg g1
                                          WHERE g1.sseguro = g.sseguro
                                            AND g1.nriesgo = g.nriesgo
                                            AND g1.cgarant = g.cgarant);
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        CLOSE cur_detreciboscar;

                        RETURN 103500;
                  END;

                  vpas := 4030;

                  SELECT cgarant, icapital
                    INTO vcapgaran, wicapital
                    FROM garanseg
                   WHERE sseguro = psseguro
                     AND f_pargaranpro_v(pcramo, pcmodali, pctipseg, pccolect, vcactivi,
                                         cgarant, 'TIPO') = 5
                     AND ffinefe IS NULL;

                  vpas := 4040;

                  SELECT fefecto
                    INTO vfefecto
                    FROM reciboscar
                   WHERE nrecibo = pnrecibo;

                  vpas := 4050;
                  a := pac_calculo_formulas.calc_formul(vfefecto, vsproduc, NVL(vcactivi, 0),
                                                        vcapgaran, NVL(pnriesgo, 1), psseguro,
                                                        1000 + isiform, importeisi, NULL, NULL,
                                                        2, xftarifa, 'R');
                  tot_iconcepips := NVL(importeisi, tot_iconcepips);
                  vpas := 4060;

                  -- DRA 27-8-08: bug mantis 7372
                  IF NVL(xicapital, 0) <> 0
                     AND NVL(importeisi, 0) = 0 THEN
                     CLOSE cur_detreciboscar;

                     p_tab_error(f_sysdate, f_user, 'impuestos recibos', vpas,
                                 'error al insertar impuestos. pmodo = ' || pmodo,
                                 '(sseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(vcapgaran = ' || vcapgaran
                                 || ') - ' || '(isiform = ' || isiform || ') - '
                                 || '(vfefecto = ' || vfefecto || ') - ' || '(pnriesgo = '
                                 || pnriesgo || ') - ' || '(vcactivi = ' || vcactivi || ') - '
                                 || '(vsproduc = ' || vsproduc || ') - ' || '(wicapital = '
                                 || wicapital || ') - ' || '(xicapital = ' || xicapital
                                 || ') - ' || '(pnrecibo = ' || pnrecibo || ') - ');
                     RETURN 180880;
                  END IF;

                  vpas := 4070;

                  SELECT pimpips
                    INTO taxaips
                    FROM impuestos
                   WHERE cimpues = 1;

                  --JRH 11/12 Bug 8064: Problemas con el redondeo de los recibos de PPJ
                  --Restamos a la prima el impuesto directamente del recibo
                  IF NVL(tot_iconcepips, 0) <> 0
                     AND taxaips IS NOT NULL THEN
                     tot_iconcepips := tot_iconcepips;
                     --Nos aseguramos, vamos por PK
                     vpas := 4080;

                     UPDATE detreciboscar
                        SET iconcep = iconcep - tot_iconcepips
                      WHERE nrecibo = pnrecibo
                        AND cconcep = 0   --prima
                        AND cgarant = xcgarant
                        AND nriesgo = NVL(xnriesgo, 0);

                     vpas := 4090;

                     SELECT iconcep
                       INTO iconcep0
                       -- JRH Bug 9011 actualizo iconcep0 parra el calculo de la comision.
                     FROM   detreciboscar
                      WHERE nrecibo = pnrecibo
                        AND cconcep = 0   --prima
                        AND cgarant = xcgarant
                        AND nriesgo = NVL(xnriesgo, 0);
                  END IF;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                  CLOSE cur_detreciboscar;

                  p_tab_error(f_sysdate, f_user, 'impuestos recibos', vpas,
                              'error al insertar impuestos. pmodo = ' || pmodo,
                              SQLERRM || ' (sseguro = ' || psseguro || ')');
                  RETURN 180879;
            END;

            vpas := 4100;

            -- JRH
            IF NVL(tot_iconcepips, 0) <> 0
               AND taxaips IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconcepips_monpol;
                  vpas := 4110;
                  error := f_insdetreccar(pnproces, pnrecibo, 4, tot_iconcepips,
                                          -- BUG 0027752/0150485 - 02/08/2013 - JSV - INI
                                          --xploccoa,
                                          100,
                                          -- BUG 0027752/0150485 - 02/08/2013 - JSV - FIN
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 4120;
                  error := f_insdetreccar(pnproces, pnrecibo, 4, tot_iconcepips,
                                          -- BUG 0027752/0150485 - 02/08/2013 - JSV - INI
                                          --xploccoa,
                                          100,
                                          -- BUG 0027752/0150485 - 02/08/2013 - JSV - FIN
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            vpas := 4130;

            IF tot_iconcepderreg IS NOT NULL
               AND tot_iconcepderreg <> 0
               AND taxaderreg IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconcepderreg_monpol;
                  vpas := 4140;
                  -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                  error := f_insdetreccar(pnproces, pnrecibo, 14, tot_iconcepderreg,   --xploccoa
                                          100, xcgarant, xnriesgo, xctipcoa, xcageven,
                                          xnmovima, 0, 0, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 4150;
                  -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                  error := f_insdetreccar(pnproces, pnrecibo, 14, tot_iconcepderreg,   --xploccoa
                                          100, xcgarant, xnriesgo, xctipcoa, xcageven,
                                          xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            -- Bug 23074 - APD - 01/08/2012 - se inserta en detrecibos el concepto 86
            IF tot_iconcepivaderreg IS NOT NULL
               AND tot_iconcepivaderreg <> 0
               AND taxaivaderreg IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconcepivaderreg_monpol;
                  vpas := 4140;
                  -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                  error := f_insdetreccar(pnproces, pnrecibo, 86, tot_iconcepivaderreg,
                                          --xploccoa
                                          100, xcgarant, xnriesgo, xctipcoa, xcageven,
                                          xnmovima, 0, 0, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 4150;
                  -- 26755 AVT 22/04/2013 pels conceptes que el 100% va al concepte normal no fem el concepte de coaseguro (cc: 14 i 86)
                  error := f_insdetreccar(pnproces, pnrecibo, 86, tot_iconcepivaderreg,
                                          --xploccoa
                                          100, xcgarant, xnriesgo, xctipcoa, xcageven,
                                          xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            -- fin Bug 23074 - APD - 01/08/2012
            IF tot_iconceparb IS NOT NULL
               AND tot_iconceparb <> 0
               AND taxaarb IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconceparb_monpol;
                  vpas := 4160;
                  error := f_insdetreccar(pnproces, pnrecibo, 6, tot_iconceparb, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 4170;
                  error := f_insdetreccar(pnproces, pnrecibo, 6, tot_iconceparb, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            vpas := 4180;

            IF tot_iconcepfng IS NOT NULL
               AND tot_iconcepfng <> 0
               AND taxafng IS NOT NULL THEN
               -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
               IF v_cmultimon = 1 THEN
                  v_iconcep_monpol := tot_iconcepfng_monpol;
                  vpas := 4190;
                  error := f_insdetreccar(pnproces, pnrecibo, 7, tot_iconcepfng, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima, 0,
                                          0, 1, v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                          v_cmonpol, pmoneda);
               -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
               ELSE
                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  vpas := 4200;
                  error := f_insdetreccar(pnproces, pnrecibo, 7, tot_iconcepfng, xploccoa,
                                          xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima);
               END IF;

               IF error != 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN error;
               END IF;
            END IF;

            -- JLB - I -  CAMBIO 03/11/2011
            vpas := 4210;

            FOR reg_con IN (SELECT cconcep
                              FROM garanpro_imp g1
                             WHERE cramo = pcramo
                               AND cmodali = pcmodali
                               AND ctipseg = pctipseg
                               AND ccolect = pccolect
                               AND cactivi = pcactivi
                               AND cgarant = xcgarant
                            UNION
                            SELECT cconcep
                              FROM garanpro_imp g2
                             WHERE cramo = pcramo
                               AND cmodali = pcmodali
                               AND ctipseg = pctipseg
                               AND ccolect = pccolect
                               AND cactivi = 0
                               AND cgarant = xcgarant
                               AND NOT EXISTS(SELECT 1
                                                FROM garanpro_imp
                                               WHERE cramo = g2.cramo
                                                 AND cmodali = g2.cmodali
                                                 AND ctipseg = g2.ctipseg
                                                 AND ccolect = g2.ccolect
                                                 AND cactivi = pcactivi
                                                 AND cgarant = g2.cgarant)) LOOP
               vctipcon := NULL;
               vnvalcon := NULL;
               vcfracci := NULL;
               vcbonifi := NULL;
               vcrecfra := NULL;
               oiconcep := NULL;
               tot_iconcep := NULL;
               vpas := 4220;
               vnerror := f_concepto(reg_con.cconcep, xcempres, xfefecto, pcforpag, pcramo,
                                     pcmodali, pctipseg, pccolect, pcactivi, xcgarant,
                                     vctipcon, vnvalcon, vcfracci, vcbonifi, vcrecfra,
                                     w_climit,   -- Bug 10864.NMM.01/08/2009.
                                     v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                                     vcderreg);   -- Bug 0020314 - FAL - 29/11/2011

               IF vnerror <> 0 THEN
                  CLOSE cur_detreciboscar;

                  RETURN vnerror;
               END IF;

               IF NVL(vnvalcon, 0) <> 0 THEN
                  BEGIN
                     vpas := 4230;

                     SELECT   NVL(SUM(iconcep), 0)
                         INTO viconcep0neto
                         FROM detreciboscar
                        WHERE sproces = pnproces
                          AND nrecibo = pnrecibo
                          AND nriesgo = xnriesgo
                          AND cgarant = xcgarant
                          AND NVL(nmovima, -1) = NVL(xnmovima, -1)   --JLV Bug 27311. 22/07/2013
                          AND cconcep = 0   -- LOCAL
                     GROUP BY nriesgo, cgarant;
                  EXCEPTION
                     WHEN NO_DATA_FOUND THEN
                        viconcep0neto := 0;
                     WHEN OTHERS THEN
                        CLOSE cur_detreciboscar;

                        error := 103516;   -- ERROR AL LLEGIR DE DETRECIBOSCAR
                        RETURN error;
                  END;

                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF v_cmultimon = 1 THEN
                     IF vctipcon = 2
                        AND v_cmonimp NOT IN(pmoneda, v_cmonpol) THEN
                        RETURN 9902860;   -- Caso multimoneda no contemplado
                     END IF;

                     --AÑADIR CTIPCON 4
                     IF vctipcon = 4
                        AND vnerror = 0 THEN
                        -- Para impuesto sobre capital (no sobre prima)
                        vpas := 7900;
                        vnerror := pac_impuestos.f_calcula_impuestocapital(psseguro, xnmovimi,
                                                                           xnriesgo, pttabla,
                                                                           'SIN_CONCEPTO',
                                                                           xicapital,
                                                                           xcgarant);
                        vpas := 7910;

                        IF vcfracci = 0 THEN
                           IF xctiprec <> 3
                              OR(xctiprec = 3
                                 AND xnfracci = 0) THEN
                              xicapital_monpol := (xicapital * v_itasa);
                              -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                              xicapital := xicapital;
                           END IF;
                        ELSE
                           xicapital_monpol := (xicapital * v_itasa) / pcforpag;
                           -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                           xicapital := xicapital / pcforpag;
                        END IF;
                     -- Parte que corresponde al recibo
                     END IF;

                     IF v_cmonimp = v_cmonpol
                                             -- BUG 0027735/0154621 - FAL - 03/10/2013
                                             --OR vctipcon <> 2 THEN
                                             -- BUG 33346/0193024 - MDS - 28/11/2014
                                             -- Quitar esta casuística para que no entre en el OR para los impuestos y recargos
                                             --OR vctipcon NOT IN(2, 7)
                     THEN
                        -- FI BUG 0027735/0154621 - FAL - 03/10/2013
                        vpas := 4240;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon,
                                                                     iconcep0_monpol,
                                                                     iconcep21_monpol,
                                                                     idto_monpol,
                                                                     idto21_monpol,
                                                                     xidtocam_monpol,
                                                                     xicapital_monpol, NULL,
                                                                     xprecarg, vctipcon, 1,

                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra,
                                                                     oiconcep_monpol, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión

                                                                     --nuevos campos
                                                                     viconcep0neto, xfefecto,
                                                                     psseguro, xnriesgo,
                                                                     xcgarant,
                                                                     -- fin nuevos campos
                                                                     v_cmonpol);
                        vpas := 4250;
                        oiconcep := oiconcep_monpol / v_itasa;
                     ELSE
                        vpas := 4260;
                        error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                     iconcep21, idto, idto21,
                                                                     xidtocam, xicapital,
                                                                     NULL, xprecarg, vctipcon,
                                                                     1,
                                                                     -- Ponemos forpag = 1, ya que es un recibo
                                                                     vcfracci, vcbonifi,
                                                                     vcrecfra, oiconcep, NULL,
                                                                     NULL,
                                                                     -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión

                                                                     --nuevos campos
                                                                     viconcep0neto, xfefecto,
                                                                     psseguro, xnriesgo,
                                                                     xcgarant,
                                                                     -- fin nuevos campos
                                                                     pmoneda);
                     END IF;
                  ELSE
                     -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     vpas := 4270;
                     error := pac_impuestos.f_calcula_impconcepto(vnvalcon, iconcep0,
                                                                  iconcep21, idto, idto21,
                                                                  xidtocam, xicapital, NULL,
                                                                  xprecarg, vctipcon, 1,

                                                                  -- Ponemos forpag = 1, ya que es un recibo
                                                                  vcfracci, vcbonifi,
                                                                  vcrecfra, oiconcep, NULL,
                                                                  NULL,
                                                                  -- Bug 0020314 - FAL - 29/11/2011 - Se añaden gastos de emisión
                                                                                        --nuevos campos
                                                                  viconcep0neto, xfefecto,
                                                                  psseguro, xnriesgo,
                                                                  xcgarant,
                                                                  -- fin nuevos campos
                                                                  -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                                                                  pmoneda);

                     IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                        oiconcep := oiconcep;
                     END IF;
                  END IF;

                  -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                  IF reg_con.cconcep IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
                     AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <> 0 THEN
                     tot_iconcep :=NVL(oiconcep, 0);
                  ELSE
                     tot_iconcep := NVL(oiconcep, 0);
                  END IF;

                  IF NVL(tot_iconcep, 0) <> 0 THEN
                     -- BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                     IF v_cmultimon = 1 THEN
                        IF reg_con.cconcep IN(4, 5, 6, 8, 14, 54, 55, 56, 58, 64, 86)
                           AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'REDONDEO_SRI'), 0) <>
                                                                                              0 THEN
                           v_iconcep_monpol := oiconcep_monpol;
                        ELSE
                           v_iconcep_monpol := oiconcep_monpol;
                        END IF;

                        vpas := 4280;
                        error := f_insdetreccar(pnproces, pnrecibo, reg_con.cconcep,
                                                tot_iconcep, xploccoa, xcgarant, xnriesgo,
                                                xctipcoa, xcageven, xnmovima, 0, 0, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     ELSE
                        -- FIN BUG 18423 - 21/11/2011 - JMP - LCOL000 - Multimoneda
                        vpas := 4290;
                        error := f_insdetreccar(pnproces, pnrecibo, reg_con.cconcep,
                                                tot_iconcep, xploccoa, xcgarant, xnriesgo,
                                                xctipcoa, xcageven, xnmovima);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detreciboscar;

                        RETURN error;
                     END IF;
                  END IF;
               ELSE
                  tot_iconcep := 0;
               END IF;
            END LOOP;

            -- JLB - F -  CAMBIO 03/11/2011
            IF xctipcoa = 8
               OR xctipcoa = 9 THEN
               BEGIN
                  vpas := 4300;

                  SELECT pcomcoa
                    INTO xpcomcoa
                    FROM coacedido
                   WHERE sseguro = psseguro
                     AND ncuacoa = xncuacoa;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN   -- 23183 AVT 31/10/2012 no hi ha coacedido a la Coa. Acceptada
                     xpcomcoa := NULL;
                  WHEN OTHERS THEN
                     RETURN 105582;   -- ERROR AL LEER DE LA TABLA COACEDIDO
               END;

               IF xpcomcoa IS NULL THEN
                  porcagente := pcomisagente;
                  porragente := pretenagente;
               ELSE
                  porcagente := 0;
                  porragente := 0;
               END IF;
            ELSE
               porcagente := pcomisagente;
               porragente := pretenagente;
            END IF;

            --
            -- Calculo de comisiones
            --

            -- Sobre prima
            -- Bug 0021947 - JMF - 20/08/2012
            IF xccalcom IN(1, 4)
               AND NOT(NVL(iconcep0, 0) <> 0
                       OR NVL(iconcep21, 0) <> 0) THEN
               porcagente := 0;
               porragente := 0;
            ELSIF xccalcom IN(1, 4)
                  AND(NVL(iconcep0, 0) <> 0
                      OR NVL(iconcep21, 0) <> 0) THEN
               --BUG20342 - JTS - 02/12/2011
               --Bug.:18852 - 08/09/2011 - ICV
               vpas := 4240;

               SELECT sproduc, fefecto
                 INTO v_sproduc, v_fefectopol
                 FROM seguros
                WHERE sseguro = psseguro;

               IF NVL(pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION'),
                      'FEFECTO_REC') = 'FEFECTO_REC' THEN
                  v_fefectovig := v_fefectorec;   --Efecto del recibo
               ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') = 'FEFECTO_POL' THEN   --Efecto de la póliza
                  vpas := 4250;
                  error := pac_preguntas.f_get_pregunpolseg(psseguro, 4046, 'SEG', vcrespue);

                  IF error NOT IN(0, 120135) THEN
                     RETURN error;
                  ELSE
                     v_fefectovig := NVL(TO_DATE(vcrespue, 'YYYYMMDD'), v_fefectopol);
                  END IF;
               ELSIF pac_parametros.f_parproducto_t(v_sproduc, 'FVIG_COMISION') =
                                                                               'FEFECTO_RENOVA' THEN   -- efecto a la renovacion
                  v_fefectovig := TO_DATE(frenovacion(NULL, psseguro, 2), 'yyyymmdd');
               END IF;

               --FIBUG20342
               -- Bug 20153 - APD - 15/11/2011 - se informa el parametro pfecha con el valor
               -- de la variable v_fefectorec
               -- BUG 0020480 - 19/12/2011 - JMF: pfretenc te que ser data del dia

               -- Bug 21167 - RSC - 03/02/2012 - LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera
               vpas := 4260;

               SELECT nanuali, fcarpro,
                      fcaranu
                 INTO v_nanuali, v_fcarpro,
                      v_fcaranu   -- Bug 21435 - FAL - 16/03/2012. Recuperar fcarpro y fcaranu
                 FROM seguros
                WHERE sseguro = psseguro;

               -- Fin bug 21167

               -- Bug 21435 - FAL - 16/03/2012. Comparar fcarpro y fcaranu para ver si sumar 1 a la anualidad
               w_nanuali := NULL;
               vpas := 4270;

               IF NVL(pfcarpro, v_fcarpro) >= v_fcaranu THEN
                  -- BUG 0022583 - FAL - Se añade el mayor para previos posteriores a la renovación anual también debe incrementar la anualidad.
                  w_nanuali := v_nanuali + 1;
               ELSE
                  w_nanuali := v_nanuali;
               END IF;

               -- Fi Bug 21435

               -- Bug 21167 - RSC - 03/02/2012 - LCOL_T001-LCOL - UAT - TEC: Incidencias del proceso de Cartera
               -- Pasamos v_nanuali + 1 ya que como en el previo no se incrementa/modifica el NANUALI de seguros
               -- entonces la comisión que calcularia en caso de renovación real no sería correcta. Para los clientes
               -- que no utilizan la altura también es correcto.

               -- Bug 22583 - XVM - 26/03/2013
               IF pcmodcom = 2
                  AND w_nanuali < 2 THEN
                  w_nanuali := 2;
               END IF;

               -- Bug 22583 - XVM - 26/03/2013
               vpas := 4280;

               -- FBL. 25/06/2014 MSV Bug 0028974
               IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                 pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                  -- MSV Comisiones especiales
                  n_error :=
                     pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 11,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                  IF n_error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ') - ' || '(vcageind = '
                                 || vcageind || ') - ' || '(pcramo = ' || pcramo || ') - '
                                 || '(pcmodali = ' || pcmodali || ') - ' || '(pctipseg = '
                                 || pctipseg || ') - ' || '(pccolect = ' || pccolect || ') - ');
                     RETURN error;
                  END IF;

                  IF v_comisi_total > 0 THEN
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 4360;
                        error := f_insdetreccar(pnproces, pnrecibo, 11, v_comisi_total,
                                                xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                xctipcoa, xcageven, xnmovima, porcagente,
                                                psseguro, 1,
                                                --v_iconcep_monpol, rdd
                                                v_comisi_monpol_total,   --rdd
                                                NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                pmoneda);
                     ELSE
                        vpas := 4370;
                        error := f_insdetreccar(pnproces, pnrecibo, 11, v_comisi_total,
                                                xploccoa, xcgarant, NVL(xnriesgo, 0),
                                                xctipcoa, xcageven, xnmovima, porcagente,
                                                psseguro);
                     END IF;
                  END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               ELSE
                  error := f_pcomisi(psseguro, pcmodcom, f_sysdate, porcagente, porragente,
                                     NULL, NULL, NULL, NULL, NULL, NULL, xcgarant, pttabla,
                                     pfuncion,
                                     --v_fefectovig, v_nanuali + 1);
                                     v_fefectovig, w_nanuali, 0, NVL(xnriesgo, 1));

                  -- Bug 21435 - FAL - 16/03/2012. Se comenta que sume 1 siempre a la anualidad. Solo en la renovación anual

                  -- fin Bug 20153 - APD - 15/11/2011
                  IF error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomisi', 3,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ')');
                     RETURN error;
                  END IF;
               -- FBL. 25/06/2014 MSV Bug 0028974
               END IF;
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            END IF;

            --COMIS_CALC := ROUND(((COMIS_CALC * PORCAGENTE) / 100), 0);
            -- 17017
            IF v_comian = 0 THEN
               -- 17017 : comportamiento normal, comission por recibo
               vpas := 4290;
               comis_calc := NVL(iconcep0, 0) * porcagente / 100;
               vpas := 4300;
               v_iconcep_monpol := NVL(iconcep0_monpol, 0) * porcagente / 100;
            ELSE
               -- comission en el recio de nueva producción y cartera renovación
               vpas := 4310;

               IF ADD_MONTHS(xfefepol, v_comian * 12) > xfeferec
                  AND((xctiprec = 0)
                      OR xctiprec = 3
                         AND TO_CHAR(xfefepol) = TO_CHAR(xfeferec)) THEN
                  vpas := 4320;
                  comis_calc := NVL(iconcep21, 0) * porcagente / 100;
                  vpas := 4330;
                  v_iconcep_monpol := NVL(iconcep21_monpol, 0) * porcagente / 100;
               ELSIF ADD_MONTHS(xfefepol, v_comian * 12) <= xfeferec THEN
                  vpas := 4340;
                  comis_calc := NVL(iconcep0, 0) * porcagente / 100;
                  vpas := 4350;
                  v_iconcep_monpol := NVL(iconcep0_monpol, 0) * porcagente / 100;
               -- comportamiento normal
               END IF;
            END IF;

            IF NVL(comis_calc, 0) <> 0
               AND NVL(porcagente, 0) <> 0 THEN   --INSERTEM LA COMISIO
               -- FBL. 25/06/2014 MSV Bug 0028974
               IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                 pcparam => 'AFECTA_COMISESPPROD') != 1 THEN
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 4360;
                     error := f_insdetreccar(pnproces, pnrecibo, 11, comis_calc, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima, porcagente, psseguro, 1,
                                             v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                             v_cmonpol, pmoneda);
                  ELSE
                     vpas := 4370;
                     error := f_insdetreccar(pnproces, pnrecibo, 11, comis_calc, xploccoa,
                                             xcgarant, NVL(xnriesgo, 0), xctipcoa, xcageven,
                                             xnmovima, porcagente, psseguro);
                  END IF;

                  vpas := 4380;

                  IF error != 0 THEN
                     CLOSE cur_detreciboscar;

                     RETURN error;
                  END IF;

                  -- INI Bug 27067 - AFM - 13/06/2013
                  vpas := 4381;
                  vsumcomis := 0;
                  vsumcomis_monpol := 0;
                  vsumporcage := 0;
                  ppcomisi_concep := 0;

                  --
                  FOR i IN 1 .. 3 LOOP
                     --
                     error := f_busca_pcomisi_concep(psseguro, xcgarant, i, pcmodcom,
                                                     v_fefectovig, 0, ppcomisi_concep);

                     IF error != 0 THEN
                        p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                                    'Error al volver de f_busca_pcomisi_concep error:'
                                    || error || '-' || SQLCODE || ' ' || SQLERRM);
                        ppcomisi_concep := 0;
                        error := 0;
                     END IF;

                     --
                     vsumporcage := vsumporcage + ppcomisi_concep;

                     --
                     IF NVL(ppcomisi_concep, 0) <> 0
                        AND error = 0 THEN
                        IF i = 1 THEN
                           concep_concep := 44;
                        ELSIF i = 2 THEN
                           concep_concep := 45;
                        ELSE
                           concep_concep := 46;
                        END IF;

                        --
                        comis_calc_concep := NVL(comis_calc, 0) * ppcomisi_concep / porcagente;

                        --
                        IF (vsumporcage = porcagente) THEN   -- Ajustamos
                           comis_calc_concep := comis_calc - vsumcomis;
                        END IF;

                        --
                        vsumcomis := vsumcomis + comis_calc_concep;

                        --
                        IF v_cmultimon = 1 THEN
                           --
                           vpas := 4382;
                           comis_calc_concep_monpol := NVL(v_iconcep_monpol, 0) * ppcomisi_concep / porcagente;

                           --
                           IF (vsumporcage = porcagente) THEN   -- Ajustamos
                              comis_calc_concep_monpol := v_iconcep_monpol - vsumcomis_monpol;
                           END IF;

                           --
                           vsumcomis_monpol := vsumcomis_monpol + comis_calc_concep_monpol;
                           --
                           error := f_insdetreccar(pnproces, pnrecibo, concep_concep,
                                                   comis_calc_concep, xploccoa, xcgarant,
                                                   NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                   xnmovima, ppcomisi_concep, psseguro, 1,
                                                   comis_calc_concep_monpol,
                                                   NVL(v_fcambioo, v_fcambio), v_cmonpol,
                                                   pmoneda);
                        ELSE
                           vpas := 4383;
                           error := f_insdetreccar(pnproces, pnrecibo, concep_concep,
                                                   comis_calc_concep, xploccoa, xcgarant,
                                                   NVL(xnriesgo, 0), xctipcoa, xcageven,
                                                   xnmovima, ppcomisi_concep, psseguro);
                        END IF;
                     --
                     END IF;
                  --
                  END LOOP;

                  -- FIN Bug 27067 - AFM - 13/06/2013
                  vpas := 4390;
                  reten_calc := ((comis_calc * porragente) / 100);
                  v_iconcep_monpol := ((v_iconcep_monpol * porragente) / 100);

                  IF reten_calc <> 0
                     AND reten_calc IS NOT NULL THEN   -- INSERTEM LA RETENCIO
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 4400;
                        error := f_insdetreccar(pnproces, pnrecibo, 12, reten_calc, xploccoa,
                                                xcgarant, NVL(xnriesgo, 0), xctipcoa,
                                                xcageven, xnmovima, porcagente, psseguro, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                     ELSE
                        vpas := 4410;
                        error := f_insdetreccar(pnproces, pnrecibo, 12, reten_calc, xploccoa,
                                                xcgarant, NVL(xnriesgo, 0), xctipcoa,
                                                xcageven, xnmovima, porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detreciboscar;

                        RETURN error;
                     END IF;
                  END IF;
               END IF;
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            END IF;

            --COMIS_CALC := ROUND(((COMIS_CALC * PORCAGENTE) / 100), 0);
            vpas := 4420;
            comis_calc := NVL(iconcep21, 0) * porcagente / 100;
            vpas := 4430;
            v_iconcep_monpol := NVL(iconcep21_monpol, 0) * porcagente / 100;

            IF comis_calc <> 0
               AND porcagente <> 0
               AND comis_calc IS NOT NULL
               AND pcomisagente IS NOT NULL THEN   --INSERTEM LA COMISIO
               -- FBL. 25/06/2014 MSV Bug 0028974
               IF pac_parametros.f_parproducto_n(psproduc => v_sproduc,
                                                 pcparam => 'AFECTA_COMISESPPROD') = 1 THEN
                  -- MSV Comisiones especiales
                  n_error :=
                     pac_comisiones.f_pcomespecial
                                             (p_sseguro => psseguro, p_nriesgo => xnriesgo,
                                              p_cgarant => xcgarant, p_ctipcom => v_ctipcom,
                                              p_nrecibo => pnrecibo, p_cconcep => 15,
                                              p_fecrec => v_fefectorec, p_modocal => v_modcal,
                                              p_icomisi_total => v_comisi_total,
                                              p_icomisi_monpol_total => v_comisi_monpol_total,
                                              p_pcomisi => porcagente, p_sproces => pnproces,
                                              p_nmovimi => xnmovimi, p_prorrata => pprorata);

                  IF n_error <> 0 THEN
                     p_tab_error(f_sysdate, f_user, 'F_IMPRECIBOS - f_pcomespecial', 2,
                                 'error al obtener f_pcomisi. pmodo = ' || pmodo,
                                 '(psseguro = ' || psseguro || ') - ' || '(xcgarant = '
                                 || xcgarant || ') - ' || '(porcagente = ' || porcagente
                                 || ') - ' || '(porragente = ' || porragente || ') - '
                                 || '(v_fefectorec = ' || v_fefectorec || ') - '
                                 || '(pttabla = ' || pttabla || ') - ' || '(pfuncion = '
                                 || pfuncion || ') - ' || '(pcmodcom = ' || pcmodcom || ') - '
                                 || '(pnrecibo = ' || pnrecibo || ') - ' || '(vcageind = '
                                 || vcageind || ') - ' || '(pcramo = ' || pcramo || ') - '
                                 || '(pcmodali = ' || pcmodali || ') - ' || '(pctipseg = '
                                 || pctipseg || ') - ' || '(pccolect = ' || pccolect || ') - ');
                     RETURN error;
                  END IF;

                  --IF v_comisi_total > 0 THEN  --rdd28042015
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 2550;
                     error := f_insdetrec(pnrecibo, 15, v_comisi_total, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_comisi_monpol_total,   --rdd v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                  ELSE
                     vpas := 2560;
                     error := f_insdetrec(pnrecibo, 15, v_comisi_total, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;
                 -- END IF;
               -- Fin FBL. 25/06/2014 MSV Bug 0028974
               ELSE
                  IF v_cmultimon = 1 THEN
                     -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                     vpas := 4440;
                     error := f_insdetreccar(pnproces, pnrecibo, 15, comis_calc, xploccoa,
                                             xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro, 1, v_iconcep_monpol,
                                             NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  ELSE
                     vpas := 4450;
                     error := f_insdetreccar(pnproces, pnrecibo, 15, comis_calc, xploccoa,
                                             xcgarant, xnriesgo, xctipcoa, xcageven, xnmovima,
                                             porcagente, psseguro);
                  END IF;

                  IF error != 0 THEN
                     CLOSE cur_detreciboscar;

                     RETURN error;
                  END IF;

                  vpas := 4460;
                  reten_calc := ((comis_calc * porragente) / 100);
                  v_iconcep_monpol := ((v_iconcep_monpol * porragente) / 100);

                  IF NVL(reten_calc, 0) <> 0 THEN   -- INSERTEM LA RETENCIO
                     IF v_cmultimon = 1 THEN
                        -- BUG 18423 - 27/12/2011 - JLB - LCOL000 - Multimoneda
                        vpas := 4470;
                        error := f_insdetreccar(pnproces, pnrecibo, 16, reten_calc, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro, 1,
                                                v_iconcep_monpol, NVL(v_fcambioo, v_fcambio),
                                                v_cmonpol, pmoneda);
                     ELSE
                        vpas := 4480;
                        error := f_insdetreccar(pnproces, pnrecibo, 16, reten_calc, xploccoa,
                                                xcgarant, xnriesgo, xctipcoa, xcageven,
                                                xnmovima, porcagente, psseguro);
                     END IF;

                     IF error != 0 THEN
                        CLOSE cur_detreciboscar;

                        RETURN error;
                     END IF;
                  END IF;
               -- FBL. 25/06/2014 MSV Bug 0028974
               END IF;
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            END IF;

            -- BUG 25988 - FAL - 13/02/2013
            v_sobrecomis := NVL(pac_parametros.f_parempresa_n(xcempres, 'SOBRECOMISION_EMISIO'),
                                0);

            IF iconcep0 <> 0
               AND v_sobrecomis = 1 THEN
               error :=
                  pac_comconvenios.f_sobrecomision_convenio
                                        (pnrecibo, pcmodcom, pmodo,   --Bug 25988/145451 - 10/06/2013 - AMC
                                         ptipomovimiento,   --Bug 25988/145451 - 10/06/2013 - AMC
                                         v_pcomisi);

               IF error = 0
                  AND v_pcomisi <> 0 THEN
                  IF v_cmultimon = 1 THEN
                     v_iconcep_monpol := v_pcomisi;
                     vpas := 2880;
                     error := f_insdetrec(pnrecibo, 43, v_pcomisi, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro, 1, v_iconcep_monpol,
                                          NVL(v_fcambioo, v_fcambio), v_cmonpol, pmoneda);
                  ELSE
                     vpas := 2890;
                     error := f_insdetrec(pnrecibo, 43, v_pcomisi, xploccoa, xcgarant,
                                          NVL(xnriesgo, 0), xctipcoa, xcageven, xnmovima,
                                          porcagente, psseguro);
                  END IF;
               END IF;
            END IF;

            -- FI BUG 25988
            IF error != 0 THEN
               CLOSE cur_detreciboscar;

               RETURN error;
            END IF;
         END IF;   -- IF DE SELECCIO DELS TIPUS 00, 01, 06, 21 I 22

         vpas := 4490;

         FETCH cur_detreciboscar
          INTO xnriesgo, xcgarant, xcageven, xnmovima;
      END LOOP;

      CLOSE cur_detreciboscar;

      RETURN 0;
   ELSE
      RETURN 101901;   -- PAS INCORRECTE DE PARÀMETRES A LA FUNCIÓ
   END IF;
-- ini Bug 0022027 - JMF - 24/04/2012
-- BUG 21546_108724 - 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
EXCEPTION
   WHEN OTHERS THEN
      IF cur_detrecibos%ISOPEN THEN
         CLOSE cur_detrecibos;
      END IF;

      IF cur_detreciboscar%ISOPEN THEN
         CLOSE cur_detreciboscar;
      END IF;

      p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                  error || '-' || SQLCODE || ' ' || SQLERRM||' - '||DBMS_UTILITY.FORMAT_CALL_STACK);
      RETURN 140999;
-- fin Bug 0022027 - JMF - 24/04/2012
END f_imprecibos;
/
