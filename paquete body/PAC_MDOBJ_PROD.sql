CREATE OR REPLACE PACKAGE BODY "PAC_MDOBJ_PROD" AS
/******************************************************************************
   NOMBRE:       PAC_MDOBJ_PROD
   PROPÓSITO:  Funciones de tratamiento objetos produccion

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        07/03/2008   ACC                1. Creación del package.
   2.0        10/06/2009   RSC                2. Bug 9905: Suplemento de cambio de forma de pago diferido
   3.0        25/06/2009   RSC                3. 0010101: APR - Detalle de garantía (Consulta)
   4.0        26/10/2009   XPL                4. 11559 -APR - Pantalla de simulación no muestra nombres
   5.0        17/12/2009   JMF                5. 0010908 CRE - ULK - Parametrització del suplement automàtic d'actualització de patrimoni
   6.0        27/01/2010   DRA                6. 0012421: CRE 80- Saldo deutors II
   7.0        02/10/2010   DRA                7. 0012384: CEM - Ajustes pantallas contatación/simulación de CRS (prima única)
   8.0        13/05/2010   RSC                8. 0011735: APR - suplemento de modificación de capital /prima
   9.0        30/07/2010   XPL                9. 14429: AGA005 - Primes manuals pels productes de Llar, CTARMAN
  10.0        07/10/2010   FAL               10. 0016242: CRT - Error mostrando descripción del riesgo en axisctr005 (GESTION DE RIESGOS)
  11.0        11/10/2010   FAL               11. 0014888: CRT002 - Carga de polizas,recibos y siniestros Allianz
  12.0        24/05/2011   ICV               12. 0018638: CRT - Nuevo campo garanseg ITOTANU (total prima anualizada)
  13.0        08/09/2011   APD               13. 0018848: LCOL003 - Vigencia fecha de tarifa
  14.0        26/09/2011   DRA               14. 0019532: CEM - Tratamiento de la extraprima en AXIS
  15.0        21/10/2011   JGR               15. 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
  16.0        19/12/2011   APD               16. 0020448: LCOL - UAT - TEC - Despeses d'expedició no es fraccionen
  17.0         01/02/2012  JRH               17. 0020666: LCOL_T004-LCOL - UAT - TEC - Indicencias de Tarificaci?n
  18.0        10/04/2012   APD               18. 0021121: MDP701 - TEC - DETALLE DE PRIMAS DE GARANTIAS
  19.0        23/04/2011   MDS               19. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
  19.0        23/04/2011   MDS               19. 0021907: MDP - TEC - Descuentos y recargos (técnico y comercial) a nivel de póliza/riesgo/garantía
  20.0        19/06/2012   JRH               20. 0022504: MDP_T001- TEC - Capital Recomendado
  21.0        02/08/2012   APD               21. 0023074: LCOL_T010-Tratamiento Gastos de Expedición
  22.0        14/08/2012   DCG               22. 0023183: LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
  23.0        20/09/2012   FAL               23. 0023565: MDP - Mutua Comercio 2009. Revisión incidèncias
  24.0        08/02/2013   JMF               0025583: LCOL - Revision incidencias qtracker (IV)
  25.0        02/11/2013   ECP               25. 0025952: LCOL_T001- QT 5906: Revisar porque est? cobrando dos veces los gastos de expedicion en polizas de Vida Individual
  26.0        08/03/2013   DCT               26. 0026241: LCOL_T031-LCOL - Fase 3 - Descripcion del riesgo
  27.0        21/03/2013   dlF               27. 0025940: AGM801-Problema sobreprima con regularizacin por prima minina
  28.0        10/04/2013   AFM              28. 0025537: RSA000 - Gestión de incidencias. 26657: Importe de 1er Recibo en pantalla de emisión de Póliza Mal Estimados. Se hace redondeo
                                     con moneda de la instalación. Se cambia a la del producto que es la correcta.
  29.0        06/05/2013   FAL              29.  0026835: GIP800 - Incidencias reportadas 23/4
  30.0        24/05/2013   APD              30.  0026419: LCOL - TEC - Revisión Q-Trackers Fase 3A
  31.0        14/06/2013   APD              31.  0026923: LCOL - TEC - Revisión Q-Trackers Fase 3A
  32.0        20/06/2013   AFM              32.  0026870: RSA - Importe de 1er Recibo en pantalla de emsión de Póliza (axisctr207 y 007) no se calcula bien
  33.0        28/08/2013   FAL              33.  0026733: GIP800 - Incidencias reportadas 15/4
  34.0        16/09/2013   FAL              34.  0026733: GIP800 - Incidencias reportadas 15/4
  35.0        22/10/2013   FAL              35.  0028420: ERROR EN SOLICITUD 4395
  36.0        22/10/2013   FAL              36.  0028420: ERROR EN SOLICITUD 4395
  37.0        21/01/2014   JTT              37.  0026501: Añadir el parametro PMT_NPOLIZA a las preguntas de tipo CONSULTA
  38.0        25/06/2014   FBL              38. 0028974: MSV0003-Desarrollo de Comisiones (COM04-Commercial Network Management)
  39.0        31/07/2014   AGG              39. 0026420: POSRA200-Parametrizaci?n Final de Vida Individual
  40.0        02/03/2015   MDS              40. 0034416: POSND600-POSTEC - Ajuste producto Salud (bug hermano interno)
  41.0        27/08/2015   FAL              41. 0037271: INCIDENCIAS EN DUPLICADOS DE PÓLIZAS (bug hermano interno)
  42.0        09/12/2015   FAL              42. 0036730: I - Producto Subsidio Individual
  43.0        27/01/2016   MDS              43. 0039815: DESCUADRES ENTRE PRIMA TOTAL ANUAL Y PRIMA TOTAL ANUAL DE DUPLICADO DE PÓLIZA (bug hermano interno)
  44.0        19/06/2015   VCG              44. AMA-209-Redondeo SRI
  45.0        15/03/2018   JLTS             45. SV1 Calculo IVA 20180313 - No está teniendo en cuenta los gastos en el IVA
  46.0        21/07/2019   DFR              46. IAXIS-3980: Gastos de expedición en endosos
  47.0        22/08/2019   CJMR             47. IAXIS-5115: IVA Moneda extranjera
  48.0        13/12/2019   CJMR             48. IAXIS-3640: Anulaciones moneda extranjera
  49.0        19/01/2020   JLTS             49. IAXIS-3264: Se realiza el ajuste del valor de prima.itotdev para que sea ajustado cuando
                                                sea una baja de amparo y lo toma de la sumatoria de los recibos de movimientos anteriores.
******************************************************************************/

   -- BUG 26835 - FAL - 06/05/2013
   FUNCTION f_control_carbritrios(
      pmode IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pmode = ' || pmode || '; psseguro = ' || psseguro || '; pnmovimi = ' || pnmovimi
            || '; pnriesgo = ' || pnriesgo || '; pcgarant = ' || pcgarant;
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
                                          'EST', v_crespue8023);

         IF v_crespue8023 IS NULL
            AND num_err = 0 THEN
            num_err :=
               pac_preguntas.f_get_pregunpolseg
                                           (psseguro,
                                            pac_parametros.f_parempresa_n(v_cempres,
                                                                          'PREG_MERCA_PELIG'),
                                            'EST', v_crespue8023);

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
      pmode IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER IS
       /*
          /FUNCIÓN QUE NOS INDICA SI ES LA PRIMERA VEZ QUE SE CONTRATA UNA GARANTIA./
        /SI ES LA PRIMERA VEZ QUE SE CONTRATA Y LA GARANTIA TIENE INFORMADO EL
      CDERREG = 1 (SI GENERA DERECHOS), Y LOS DERECHOS NO SE HAN INCLUIDO EN
      NINGÚN RECIBO EN SITUACIÓN PENDIENTE O COBRADO HASTA EL MOMENTO RETORNAMOS UN 0 */
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pmode = ' || pmode || '; psseguro = ' || psseguro || '; pnmovimi = ' || pnmovimi
            || '; pnriesgo = ' || pnriesgo || '; pcgarant = ' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.f_control_cderreg';
      v_cempres      NUMBER;
      v_preg_gast_emi NUMBER;
      w_aplica_impost_x_preg NUMBER := 0;
      wcrespue       NUMBER;
      wnumgaraplicderreg NUMBER := 0;
      w_aplica_gastemi NUMBER := 0;
      vncertif       seguros.ncertif%TYPE;
      xsproduc       productos.sproduc%TYPE;
      vcsubpro       productos.csubpro%TYPE;
      xnfracci       NUMBER := 0;
      xctiprec       NUMBER := 0;
      num_err        NUMBER;
      vcagastexp     NUMBER;
      vcperiogast    NUMBER;
      salir          EXCEPTION;
      vnum_err       NUMBER;
      --bug0025826
      v_res4093      pregunpolseg.crespue%TYPE;
      v_res4094      pregunpolseg.crespue%TYPE;
      v_res9800       pregunseg.crespue%TYPE; -- IAXIS-3980 21/07/2019
      vctipcoa       seguros.ctipcoa%TYPE;
      v_gastexp_calculo NUMBER;
      n_error        NUMBER;
      v_crespue9082  pregungaranseg.crespue%TYPE;   -- BUG 0026835 - FAL - 06/05/2013
   BEGIN
      -- BUG 0026835 - FAL - 06/05/2013
      v_cempres := pac_parametros.f_parinstalacion_n('EMPRESADEF');

      IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'IMPOST_PER_PREG'), 0) = 1
         AND NVL(pac_parametros.f_parempresa_n(v_cempres, 'PREG_GASTO_EMI'), 0) <> 0 THEN
         v_crespue9082 := NVL(pac_preguntas.f_get_pregungaranseg_v(psseguro, pcgarant,
                                                                   pnriesgo, 9082, 'EST',
                                                                   NULL),
                              0);

         IF v_crespue9082 = 0 THEN
            RETURN 1;   -- para que no calcule los gastos de expedicion
         END IF;
      END IF;

      -- FI BUG 0026835 - FAL - 06/05/2013
      BEGIN
         IF pmode = 'EST' THEN
            SELECT p.sproduc, p.csubpro, s.ncertif, ctipcoa
              INTO xsproduc, vcsubpro, vncertif, vctipcoa
              FROM estseguros s, productos p
             WHERE s.sseguro = psseguro
               AND s.sproduc = p.sproduc;

            IF pac_iax_produccion.issuplem THEN
               xctiprec := 1;
            ELSE
               xctiprec := 0;
            END IF;
         ELSE
            SELECT p.sproduc, p.csubpro, s.ncertif, ctipcoa
              INTO xsproduc, vcsubpro, vncertif, vctipcoa
              FROM seguros s, productos p
             WHERE s.sseguro = psseguro
               AND s.sproduc = p.sproduc;

            IF pac_iax_produccion.isconsult IS NOT NULL
               AND pac_iax_produccion.isconsult THEN
               xctiprec := 0;
            ELSE
               SELECT DECODE(c.cmovseg, 0, 0, -1)
                 INTO xctiprec
                 FROM movseguro m, codimotmov c
                WHERE m.cmotmov = c.cmotmov
                  AND m.sseguro = psseguro
                  AND m.nmovimi = pnmovimi;
            END IF;
         END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vnum_err := 104347;   -- Producte no trobat a PRODUCTOS
            RAISE salir;
         WHEN OTHERS THEN
            vnum_err := 102705;   -- Error al llegir de PRODUCTOS
            RAISE salir;
      END;

      vpasexec := 2;
      -- bug0025826
      -- 4093 Aplica gastos de expedición
      n_error := pac_preguntas.f_get_pregunpolseg(psseguro, 4093, pmode, v_res4093);
      v_res4093 := NVL(v_res4093, 2);
      -- 4094 Periodicidad de los gastos
      n_error := pac_preguntas.f_get_pregunpolseg(psseguro, 4094, pmode, v_res4094);
      v_res4094 := NVL(v_res4094, 2);
      v_gastexp_calculo := NVL(f_parproductos_v(xsproduc, 'GASTEXP_CALCULO'), 0);
      -- Inicio IAXIS-3980 21/07/2019
      -- Nueva pregunta para identificar si se cobran o no gastos de expedición en suplementos
      -- Sólo aplica para endosos.
      n_error:= pac_preguntas.f_get_pregunseg(psseguro, pnriesgo, 9800, pmode, v_res9800);
      v_res9800 := NVL(v_res9800, 2);
      -- Fin IAXIS-3980 21/07/2019

      IF v_res4093 = 0
         OR v_gastexp_calculo = 0 THEN
         RETURN 1;
      ELSIF v_res4093 = 1
            AND NVL(vncertif, 0) <> 0 THEN
         RETURN 1;
      ELSIF vctipcoa = 8 THEN
         -- coaseguro
         RETURN 1;
      -- Inicio IAXIS-3980 21/07/2019
      ELSIF (v_res9800 = 1 AND pac_iax_produccion.issuplem) THEN
         RETURN 0; --Calcula gastos
      -- Fin IAXIS-3980 21/07/2019
      ELSIF v_res4094 = 2 THEN
         -- Anual
         IF xctiprec <> 0 THEN
            RETURN 1;
         END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN salir THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, f_axis_literales(vnum_err));
         RETURN 1;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
         RETURN 1;
   END f_control_cderreg;

   /*************************************************************************
      Recarrega las garanties despues de tarificar
      param in/out garant    : objeto garantia
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
      param in     pnriesgo  : número de riesgo
   *************************************************************************/
   PROCEDURE p_get_garaftertargar(
      garant IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_GarAfterTarGar';
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      vcgarant       NUMBER;
      vnmovimi       NUMBER;
      vcobliga       NUMBER;
      vctipgar       NUMBER;
      vicapital      NUMBER;
      vcrevali       NUMBER;
      vprevali       NUMBER;
      virevali       NUMBER;
      vcfranq        NUMBER;
      vifranqu       NUMBER;
      vfiniefe       DATE;
      vicaptot       FLOAT;
      vsproduc       NUMBER;
      vftarifa       DATE;   -- Bug 18848
      vnfactor       NUMBER;   -- Bug 30171/173304 - 24/04/2014 - AMC
   BEGIN
      vpasexec := 1;

      IF pmode = 'SOL' THEN
         vtab := 'SOLGARANSEG';

         SELECT sproduc
           INTO vsproduc
           FROM solseguros
          WHERE sseguro = pssolicit;
      ELSIF pmode = 'EST' THEN
         vtab := 'ESTGARANSEG';

         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = pssolicit;
      ELSE
         vtab := 'GARANSEG';

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = pssolicit;
      END IF;

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      -- Bug 18848 - APD - 08/09/2011 - se añade el FTARIFA
      squery :=
         'SELECT cgarant,nmovimi,cobliga,ctipgar,icapital,crevali,prevali,irevali,cfranq,ifranqu,finiefe,icaptot,ftarifa';

      -- Bug 30171/173304 - 24/04/2014 - AMC
      IF pmode <> 'SOL' THEN
         squery := squery || ',nfactor';
      END IF;

      squery := squery || ' FROM ' || vtab || ' WHERE SSEGURO=' || pssolicit || ' AND '
                || '       FFINEFE IS NULL AND ' || '       NRIESGO=' || pnriesgo || ' AND '
                || '       CGARANT=' || garant.cgarant;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 6;
      DBMS_SQL.define_column(curid, 1, vcgarant);
      DBMS_SQL.define_column(curid, 2, vnmovimi);
      DBMS_SQL.define_column(curid, 3, vcobliga);
      DBMS_SQL.define_column(curid, 4, vctipgar);
      DBMS_SQL.define_column(curid, 5, vicapital);
      DBMS_SQL.define_column(curid, 6, vcrevali);
      DBMS_SQL.define_column(curid, 7, vprevali);
      DBMS_SQL.define_column(curid, 8, virevali);
      DBMS_SQL.define_column(curid, 9, vcfranq);
      DBMS_SQL.define_column(curid, 10, vifranqu);
      DBMS_SQL.define_column(curid, 11, vfiniefe);
      DBMS_SQL.define_column(curid, 12, vicaptot);
      DBMS_SQL.define_column(curid, 13, vftarifa);

      -- Bug 30171/173304 - 24/04/2014 - AMC
      IF pmode <> 'SOL' THEN
         DBMS_SQL.define_column(curid, 14, vnfactor);
      END IF;

      vpasexec := 7;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, vcgarant);
         DBMS_SQL.COLUMN_VALUE(curid, 2, vnmovimi);
         DBMS_SQL.COLUMN_VALUE(curid, 3, vcobliga);
         DBMS_SQL.COLUMN_VALUE(curid, 4, vctipgar);
         DBMS_SQL.COLUMN_VALUE(curid, 5, vicapital);
         DBMS_SQL.COLUMN_VALUE(curid, 6, vcrevali);
         DBMS_SQL.COLUMN_VALUE(curid, 7, vprevali);
         DBMS_SQL.COLUMN_VALUE(curid, 8, virevali);
         DBMS_SQL.COLUMN_VALUE(curid, 9, vcfranq);
         DBMS_SQL.COLUMN_VALUE(curid, 10, vifranqu);
         DBMS_SQL.COLUMN_VALUE(curid, 11, vfiniefe);
         DBMS_SQL.COLUMN_VALUE(curid, 12, vicaptot);
         DBMS_SQL.COLUMN_VALUE(curid, 13, vftarifa);

         -- Bug 30171/173304 - 24/04/2014 - AMC
         IF pmode <> 'SOL' THEN
            DBMS_SQL.COLUMN_VALUE(curid, 14, vnfactor);
         END IF;

         garant.cgarant := vcgarant;
         garant.nmovimi := vnmovimi;
         garant.cobliga := vcobliga;
         garant.ctipgar := vctipgar;
         garant.icapital := vicapital;
         garant.crevali := vcrevali;
         garant.prevali := vprevali;
         garant.cfranq := vcfranq;
         garant.ifranqu := vifranqu;
         garant.finiefe := vfiniefe;
         garant.icaptot := vicaptot;
         -- Bug 18848 - APD - 08/09/2011 - después de tarifar se debe actualizar
         -- el campo FTARIFA del objeto
         garant.masdatos.ftarifa := vftarifa;
         garant.nfactor := vnfactor;   -- Bug 30171/173304 - 24/04/2014 - AMC
      END LOOP;

      vpasexec := 8;
      DBMS_SQL.close_cursor(curid);
      vpasexec := 9;

      IF NVL(f_parproductos_v(vsproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
         p_get_garaftertardatosgar(garant.masdatos, garant.cgarant, pssolicit, pmode,
                                   pnriesgo);
      END IF;

      -- Bug 21121 - APD - 05/03/2012 - recarga el detalle de primas de las garantias
      IF NVL(f_parproductos_v(vsproduc, 'DETPRIMAS'), 0) = 1 THEN
         p_get_detprimas(garant, pssolicit, pnmovimi, pmode, pnriesgo);
      END IF;

      -- fin Bug 21121 - APD - 05/03/2012
      vpasexec := 10;
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_garaftertargar;

   /*************************************************************************
      Recarrega los detalles de las garanties despues de tarificar
      param in/out garantmasdatos    : objeto masdatosgar
      param in     pcgarant : código garantia
      param in     pssolicit : código solicitud
      param in     pmode     : modo EST POL
      param in     pnriesgo  : número de riesgo
   *************************************************************************/
   PROCEDURE p_get_garaftertardatosgar(
      garantmasdatos IN OUT ob_iax_masdatosgar,
      pcgarant IN NUMBER,
      pssolicit IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_GARAFTERTARDATOSGAR';
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      ndetgar        NUMBER;
      fefecto        DATE;
      fvencim        DATE;
      ndurcob        NUMBER;
      ffincob        DATE;
      pinttec        NUMBER;
      pintmin        NUMBER;
      fprovmat0      DATE;
      provmat0       NUMBER;
      fprovmat1      DATE;
      provmat1       NUMBER;
      ctarifa        NUMBER;
      cunica         NUMBER;
      cagente        NUMBER;
      iprianu        FLOAT;
      icapital       FLOAT;
      vsproduc       NUMBER;
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         vtab := 'ESTDETGARANSEG';
      ELSE
         vtab := 'DETGARANSEG';
      END IF;

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery :=
         'SELECT ndetgar,fefecto,fvencim,ndurcob,ffincob,pinttec,
         pintmin,fprovmat0,provmat0,fprovmat1,provmat1,ctarifa,cunica,cagente,iprianu, icapital '
         || ' FROM ' || vtab || ' WHERE SSEGURO=' || pssolicit || ' and  NRIESGO=' || pnriesgo
         || ' AND ' || '       CGARANT=' || pcgarant;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 6;
      DBMS_SQL.define_column(curid, 1, ndetgar);
      DBMS_SQL.define_column(curid, 2, fefecto);
      DBMS_SQL.define_column(curid, 3, fvencim);
      DBMS_SQL.define_column(curid, 4, ndurcob);
      DBMS_SQL.define_column(curid, 5, ffincob);
      DBMS_SQL.define_column(curid, 6, pinttec);
      DBMS_SQL.define_column(curid, 7, pintmin);
      DBMS_SQL.define_column(curid, 8, fprovmat0);
      DBMS_SQL.define_column(curid, 9, provmat0);
      DBMS_SQL.define_column(curid, 10, fprovmat1);
      DBMS_SQL.define_column(curid, 11, provmat1);
      DBMS_SQL.define_column(curid, 12, ctarifa);
      DBMS_SQL.define_column(curid, 13, cunica);
      DBMS_SQL.define_column(curid, 14, cagente);
      DBMS_SQL.define_column(curid, 15, iprianu);
      DBMS_SQL.define_column(curid, 16, icapital);
      vpasexec := 7;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, ndetgar);
         DBMS_SQL.COLUMN_VALUE(curid, 2, fefecto);
         DBMS_SQL.COLUMN_VALUE(curid, 3, fvencim);
         DBMS_SQL.COLUMN_VALUE(curid, 4, ndurcob);
         DBMS_SQL.COLUMN_VALUE(curid, 5, ffincob);
         DBMS_SQL.COLUMN_VALUE(curid, 6, pinttec);
         DBMS_SQL.COLUMN_VALUE(curid, 7, pintmin);
         DBMS_SQL.COLUMN_VALUE(curid, 8, fprovmat0);
         DBMS_SQL.COLUMN_VALUE(curid, 9, provmat0);
         DBMS_SQL.COLUMN_VALUE(curid, 10, fprovmat1);
         DBMS_SQL.COLUMN_VALUE(curid, 11, provmat1);
         DBMS_SQL.COLUMN_VALUE(curid, 12, ctarifa);
         DBMS_SQL.COLUMN_VALUE(curid, 13, cunica);
         DBMS_SQL.COLUMN_VALUE(curid, 14, cagente);
         DBMS_SQL.COLUMN_VALUE(curid, 15, iprianu);
         DBMS_SQL.COLUMN_VALUE(curid, 16, icapital);
         garantmasdatos.ndetgar := ndetgar;
         garantmasdatos.fefecto := fefecto;
         garantmasdatos.fvencim := fvencim;
         garantmasdatos.ndurcob := ndurcob;
         garantmasdatos.ffincob := ffincob;
         garantmasdatos.pinttec := pinttec;
         garantmasdatos.pintmin := pintmin;
         garantmasdatos.fprovt0 := fprovmat0;
         garantmasdatos.iprovt0 := provmat0;
         garantmasdatos.fprovt1 := fprovmat1;
         garantmasdatos.iprovt1 := provmat1;
         garantmasdatos.ctarifa := ctarifa;
         garantmasdatos.cunica := cunica;
         garantmasdatos.cagente := cagente;
         vpasexec := 8;

         -- Reducida / No reducida
         IF iprianu = 0
            AND icapital <> 0 THEN
            garantmasdatos.estado := 1;
            garantmasdatos.testado := ff_desvalorfijo(61, pac_md_common.f_get_cxtidioma, 11);
         ELSE
            garantmasdatos.estado := 0;
            garantmasdatos.testado := ff_desvalorfijo(668, pac_md_common.f_get_cxtidioma, 2);
         END IF;

         vpasexec := 9;
      END LOOP;

      vpasexec := 10;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_garaftertardatosgar;

   /*************************************************************************
      Recupera de la base de dades las primas de las garantias
      param in/out prima     : objeto prima
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
      param in     pnriesgo  : número de riesgo
      param in     pcgarant  : código de garantia
   *************************************************************************/
   -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta):  Añadimos parámetro pndetgar
   /* BUG 24657 - 29/12/2012  - HPM - SUPLEMENTOS,  SE MODIFICA LA FOMRA DE CALCULAR EL PRIMER RECIBO DE MANERA QUE DIVIDA LA PRIMA ANUAL ANTES DE CLACULAR
   LOS IMPUESTOS EN CASO QUE ESTOS SE DEBAN DIVIDIR POR LA FORMA DE PAGO*/
   PROCEDURE p_get_prigarant(
      prima IN OUT ob_iax_primas,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pndetgar IN NUMBER,
      pctarman IN NUMBER) IS   --S'afegeix CTARMAN#30/07/2010#XPL#14429: AGA005 - Primes manuals pels productes de Llar
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi || ' pmode=' || pmode
            || ' pnriesgo=' || pnriesgo || ' pcgarant=' || pcgarant;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_PriGarant';
      squery         VARCHAR2(4000);
      vtab           VARCHAR2(200);
      vfield         VARCHAR2(1000);
      cur            sys_refcursor;
      capital        NUMBER;
      vnmovimi       NUMBER;   -- Bug 0039815 - MDS - 27/01/2016
      vpdtocom       FLOAT;
      vidtocom       FLOAT;
      vprecarg       FLOAT;
      virecarg       FLOAT;
      viextrap       FLOAT;
      viiextrap      FLOAT;
      vcrecfra       NUMBER(1);
      nerr           NUMBER;
      xpago          NUMBER;
      vcforpag       NUMBER(2);
      -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta)
      v_sproduc      seguros.sproduc%TYPE;
      v_npoliza      seguros.npoliza%TYPE;
      -- Fin Bug 10101
      -- Bug 20448 - APD - 19/12/2011
      viimpprireb    NUMBER := 0;   -- Importe impuestos primer recibo
      -- Fin Bug 20448 - APD - 19/12/2011

      -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR
      vcapital_ini   NUMBER;
      vcapital_def   NUMBER;
      vcrespuesta    NUMBER;
      -- Fi BUG 20666-  01/2012 - JRH
      viivacderreg   NUMBER;   -- Bug 23074 - APD - 02/08/2012
      vcagastexp     NUMBER;   -- Bug 23074 - APD - 02/08/2012
      vcperiogast    NUMBER;   -- Bug 23074 - APD - 02/08/2012
      xcimpcons      garanpro.cimpcon%TYPE;   -- BUG 23565/0123797 - FAL - 20/09/2012
      -- ini Bug 0025583 - 08/02/2013 - JMF: prorrateo
      facnet         NUMBER;
      d_efecto       seguros.fefecto%TYPE;
      d_renova       seguros.frenova%TYPE;
      d_carpro       seguros.fcarpro%TYPE;
      v_cprorra      productos.cprorra%TYPE;
      v_crevfpg      productos.crevfpg%TYPE;
      v_ctipefe      productos.ctipefe%TYPE;
      v_diaspro      productos.ndiaspro%TYPE;
      v_fcaranu      seguros.fcaranu%TYPE;
      v_fultrenova   seguros.frenova%TYPE;
      v_ssegpol      seguros.sseguro%TYPE;
      v_suple        NUMBER;
      n_div          NUMBER;
      d_fin          DATE;
      d_ini          DATE;
      n_cuotas       NUMBER;
      v_primadev     FLOAT:=0;
      -- fin Bug 0025583 - 08/02/2013 - JMF: prorrateo
      --
      --  INI BUG 0026870 - AFM - 20/06/2013
      d_caranu       seguros.fcaranu%TYPE;
      d_vencim       seguros.fvencim%TYPE;
      facdev         NUMBER;
      v_monprod      productos.cdivisa%TYPE;
      v_cempres      seguros.cempres%TYPE;
      v_cramo        seguros.cramo%TYPE;
      v_cmodali      seguros.cmodali%TYPE;
      v_ctipseg      seguros.ctipseg%TYPE;
      v_ccolect      seguros.ccolect%TYPE;
      v_cactivi      seguros.cactivi%TYPE;
      v_ctipcon      imprec.ctipcon%TYPE;
      v_nvalcon      imprec.nvalcon%TYPE;
      v_cfracci      imprec.cfracci%TYPE;
      v_cbonifi      imprec.cbonifi%TYPE;
      v_crecfra      imprec.crecfra%TYPE;
      v_climit       imprec.climite%TYPE;
      v_cmonimp      imprec.cmoneda%TYPE;
      v_cderreg      imprec.cderreg%TYPE;
      v_impips       NUMBER;
      xcimpips       NUMBER;
      -- FIN BUG 0026870 - AFM - 20/06/2013
      w_iips         NUMBER;   -- BUG 28420/0156750 - FAL - 24/10/2013
      v_cduraci      NUMBER;
      -- INI Bug 38345 - AFM
      v_cons         NUMBER;
      v_clea         NUMBER;
      v_arb          NUMBER;
      v_fng          NUMBER;
      v_rec          NUMBER;
      v_iprigar      garanseg.ipritar%TYPE;
      -- FIN Bug 38345 - AFM
            --CJM
      v_sseguro      NUMBER;
      v_preg4313     NUMBER;
      b_primerderreg  BOOLEAN;
      n_derreg_poliza NUMBER;
      gars            t_iax_garantias;
      mensajes        t_iax_mensajes;

      v_cambio_trm NUMBER;--bartolo herrera 29-03-2019
      v_cambio_trm_dev NUMBER;--bartolo herrera 29-03-2019
      v_cmoneda NUMBER;--bartolo herrera 29-03-2019
      v_tmoneda       VARCHAR2(200);
      --INI IAXIS-5115 CJMR  22/08/2019
    v_cmonint_app monedas.cmonint%TYPE;
      v_cmonint_prod monedas.cmonint%TYPE;
      --FIN IAXIS-5115 CJMR  22/08/2019
      -- INI AXIS-3640 CJMR  13/12/2019
      num_err         NUMBER;
      v_crespue9802   pregunseg.crespue%TYPE;
      v_femisio       DATE;
      -- FIN AXIS-3640 CJMR  13/12/2019
      -- INI -IAXIS-3264 -19/01/2020
      v_cmotmov       movseguro.cmotmov%TYPE;
      vcobliga        estgaranseg.cobliga%TYPE;
      -- FIN -IAXIS-3264 -19/01/2020


   BEGIN
      vpasexec := 2;

      --bug0025826
      IF pac_iax_produccion.issuplem THEN
         v_suple := 1;
      ELSE
         v_suple := 0;
      END IF;

      IF NVL(prima.needtarifar, 0) = 1 THEN
        -- INI -IAXIS-3264 -19/01/2020
        IF not( v_suple = 1 AND
            pac_iax_suplementos.lstmotmov(1).cmotmov = 239 and
            NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.poliza.det_poliza.sproduc,'BAJA_AMP_DEV_TOT'),0) = 1) THEN
        -- FIN -IAXIS-3264 -19/01/2020
         --(JAS)03.06.2008 - Neteja dels camps de l'objecte OB_IAX_PRIMES repetits.
         --prima.primaseguro := null;
         --prima.impuestos   := null;
         --prima.recargos    := null;
         --prima.primatotal  := null;
         --prima.primarecibo := null;
         IF NVL(pctarman, 0) = 0 THEN
            prima.iprianu := NULL;   -- Importe prima anual local (sin coaseguro)
            prima.ipritar := NULL;   -- Importe tarifa
            prima.ipritot := NULL;   -- Importe prima anual total (con coaseguro)
            prima.itotanu := NULL;   --Importe prima anualizada
            prima.iprivigencia := NULL;   --Bug 30509/168760 - 10/03/2014 - AMC
         END IF;

         --prima.precarg := null; -- Porcentage recargo (sobreprima)
         prima.irecarg := NULL;   -- Importe del recargo (sobreprima)
         --prima.pdtocom := null; -- Porcentage descuento comercial
         prima.idtocom := NULL;   -- Importe descuento comercial
         prima.itarifa := NULL;   -- Tarifa + extraprima
         prima.iconsor := NULL;   -- Consorcio
         prima.ireccon := NULL;   -- Recargo Consorcio
         prima.iips := NULL;   -- Impuesto IPS
         prima.idgs := NULL;   -- Impuesto CLEA/DGS
         prima.iarbitr := NULL;   -- Arbitrios (bomberos, ...)
         prima.icderreg := NULL;   -- derechos de registro  -- Bug 0019578 - FAL - 26/09/2011
         prima.ifng := NULL;   -- Impuesto FNG
         prima.irecfra := NULL;   -- Recargo Fraccionamiento
         prima.itotpri := NULL;   -- Total Prima Neta
         prima.itotdto := NULL;   -- Total Descuentos
         prima.itotcon := NULL;   -- Total Consorcio
         prima.itotimp := NULL;   -- Total Impuestos y Arbitrios
         prima.itotalr := NULL;   -- TOTAL RECIBO
         prima.irecfra := NULL;
         prima.iprireb := NULL;   -- Prima del 1er rebut
         prima.iiextrap := NULL;   -- Import de la extraprima (BUG19532:DRA:26/09/2011)
        END IF; --IAXIS-3264 - 19/01/2020
      ELSE
         vpasexec := 3;

         IF pmode = 'SOL' THEN
            vtab := 'solgaranseg';
            vfield := 'SSOLICIT=' || pssolicit;
            vfield := vfield || ' and NRIESGO=' || pnriesgo;
            vfield := vfield || ' and CGARANT=' || pcgarant;
         ELSIF pmode = 'EST' THEN
            -- BUG 23565/0123797 - FAL - 20/09/2012
            SELECT sproduc
              INTO v_sproduc
              FROM estseguros
             WHERE sseguro = pssolicit;
            -- FI BUG 23565/0123797
            -- INI -IAXIS-3264 -02/01/2020
            vpasexec := 31;
            IF v_suple = 1 THEN
              if pac_iax_suplementos.lstmotmov IS NOT NULL AND pac_iax_suplementos.lstmotmov.COUNT > 0 then
                 IF pac_iax_suplementos.lstmotmov(1).cmotmov = 239 and
                    NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.poliza.det_poliza.sproduc,'BAJA_AMP_DEV_TOT'),0) = 1 then
                   v_cmotmov := pac_iax_suplementos.lstmotmov(1).cmotmov;
                 END IF;
              end if;
            ELSE
              v_cmotmov := 0;
            end if;
            vpasexec := 32;
      -- FIN -IAXIS-3264 -02/01/2020
            vtab := 'estgaranseg';
            vfield := ' SSEGURO=' || pssolicit;
            vfield := vfield || ' and FFINEFE IS NULL ';   --// ACC 06032008 no s'ha de buscar per moviment ' and NMOVIMI='||pnmovimi;
            vfield := vfield || ' and NRIESGO=' || pnriesgo;
            vfield := vfield || ' and CGARANT=' || pcgarant;
            --BUG 0025940 - 06-03-2013 - Txema ini (modificación dlF)
            --vfield := vfield || ' and COBLIGA=1';
            -- INI -IAXIS-3264 - 02/01/2020
            vfield := vfield || ' and (COBLIGA=1 or (cobliga=0 and ctipgar=9) or(cobliga=0 and '|| NVL(v_cmotmov,0) ||' = 239 and
         NVL (pac_parametros.f_parproducto_n ('||v_sproduc||',''BAJA_AMP_DEV_TOT''),0) = 1) and finivig is not null and ffinvig is not null)';
            -- FIN -IAXIS-3264 - 02/01/2020

            --fin BUG 0025940 - 06-03-2013 - Txema


         ELSE
            -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta)
            SELECT sproduc
              INTO v_sproduc
              FROM seguros
             WHERE sseguro = pssolicit;

            IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
               vtab := 'GARANSEG g, DETGARANSEG dg';
               vfield := 'g.SSEGURO=' || pssolicit;
               vfield := vfield || ' AND g.FFINEFE IS NULL ';   --// ACC 06032008 no s'ha de buscar per moviment ' and NMOVIMI='||pnmovimi;
               vfield := vfield || ' AND g.NRIESGO=' || pnriesgo;
               vfield := vfield || ' AND g.CGARANT=' || pcgarant;
               vfield := vfield || ' AND dg.ndetgar=' || pndetgar;
               vfield := vfield || ' AND g.sseguro = dg.sseguro'
                         || ' AND g.nriesgo = dg.nriesgo' || ' AND g.cgarant = dg.cgarant'
                         || ' AND g.finiefe = dg.finiefe' || ' AND g.nmovimi = dg.nmovimi';
            ELSE
               -- Fin Bug 10101
               vtab := 'garanseg';
               vfield := 'SSEGURO=' || pssolicit;
               vfield := vfield || ' and FFINEFE IS NULL ';   --// ACC 06032008 no s'ha de buscar per moviment ' and NMOVIMI='||pnmovimi;
               vfield := vfield || ' and NRIESGO=' || pnriesgo;
               vfield := vfield || ' and CGARANT=' || pcgarant;
            -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta)
            END IF;
         -- Fin Bug 10101
         END IF;

         --
         v_monprod := pac_monedas.f_moneda_producto(v_sproduc);
         --
         vpasexec := 4;

         -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta)
         IF NVL(f_parproductos_v(v_sproduc, 'DETALLE_GARANT'), 0) IN(1, 2) THEN
            -- Bug 11735 - RSC - 13/05/2010 - APR - suplemento de modificación de capital /prima
            IF pmode = 'EST' THEN
               -- aquí vtab es solgaranseg
                  -- Bug 21907 -- MDS -- 23/04/2012, añadir los cuatro campos como 0
                  -- FBL. 25/06/2014 MSV Bug 0028974 añado otro cero para mantener el número de columnas igualado en las tres querys

               --AGG 31/07/2014 Se quita un 0 de la select porque el número de campos de las select no era igual al del cursor, fallaba la tarificación
               -- Bug 0039815 - MDS - 27/01/2016, añadir nmovimi
               -- INI -IAXIS-3264 - 19/01/2020. Se adiciona la columna cobliga
               squery :=
                  'select cobliga,nmovimi, icapital, NVL(iextrap,0) iextrap, iprianu, NVL(ipritar,0),iprianu ipritot,NVL(precarg,0),NVL(irecarg,0),NVL(itarifa,0),NVL(pdtocom,0),NVL(idtocom,0), nvl(itotanu,0) '
                  || ', nvl(pdtotec,0), nvl(preccom,0), nvl(idtotec,0), nvl(ireccom,0) ,nvl(ipricom,0),nvl(ipridev,0)'
                  || ' from ' || vtab || ' where ' || vfield;
               -- FIN -IAXIS-3264 - 19/01/2020
            -- Fin Bug 0028974 - FBL - 27/11/2013
            ELSE
                  -- Fin Bug 11735
               -- aquí vtab es ARANSEG g, DETGARANSEG dg
                  -- Bug 21907 -- MDS -- 23/04/2012, añadir los cuatro campos como 0
                  -- Ini Bug 0028974 - FBL - 27/11/2013 ; añado columan ipricom
                  -- Bug 0039815 - MDS - 27/01/2016, añadir nmovimi
                  -- INI -IAXIS-3264 - 19/01/2020. Se adiciona la columna cobliga
               squery :=
                  'select null cobliga,g.nmovimi, g.icapital, NVL(iextrap,0) iextrap, dg.iprianu, NVL(dg.ipritar,0),dg.iprianu ipritot,NVL(dg.precarg,0),NVL(dg.irecarg,0),NVL(itarifa,0),NVL(dg.pdtocom,0),NVL(dg.idtocom,0), nvl(itotanu,0) '
                  || ', nvl(pdtotec,0), nvl(preccom,0), nvl(idtotec,0), nvl(ireccom,0) ,nvl(g.ipricom,0),nvl(ipridev,0)'
                  || ' from ' || vtab || ' where ' || vfield;
                  -- FIN -IAXIS-3264 - 19/01/2020.
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
            END IF;
         ELSE
            -- Fin Bug 10101
            -- aquí vtab es garanseg
               -- Bug 21907 -- MDS -- 23/04/2012, añadir los cuatro campos
            -- FBL. 25/06/2014 MSV Bug 0028974 añado columan ipricom
            -- INI -IAXIS-3264 - 19/01/2020. Se adiciona la columna cobliga
            IF pmode = 'EST' THEN
            squery :=
               'select cobliga,nmovimi, icapital,NVL(iextrap,0),iprianu,NVL(ipritar,0),NVL(ipritot,0),NVL(precarg,0),NVL(irecarg,0),NVL(itarifa,0),NVL(pdtocom,0),NVL(idtocom,0), nvl(itotanu,0) '
               || ', nvl(pdtotec,0), nvl(preccom,0), nvl(idtotec,0), nvl(ireccom,0), nvl(ipricom, 0),nvl(ipridev,0) '
               || ' from ' || vtab || ' where ' || vfield;
            ELSE
            squery :=
               'select null cobliga,nmovimi, icapital,NVL(iextrap,0),iprianu,NVL(ipritar,0),NVL(ipritot,0),NVL(precarg,0),NVL(irecarg,0),NVL(itarifa,0),NVL(pdtocom,0),NVL(idtocom,0), nvl(itotanu,0) '
               || ', nvl(pdtotec,0), nvl(preccom,0), nvl(idtotec,0), nvl(ireccom,0), nvl(ipricom, 0),nvl(ipridev,0) '
               || ' from ' || vtab || ' where ' || vfield;
            END IF;
            -- FIN -IAXIS-3264 - 19/01/2020
            -- Fin FBL. 25/06/2014 MSV Bug 0028974
         -- Bug 10101 - 25/06/2009 - RSC - Detalle de garantía (Consulta)
         END IF;

         -- Fin Bug 10101
         OPEN cur FOR squery;

         -- FBL. 25/06/2014 MSV Bug 0028974 añado columan ipricom
         -- Bug 0039815 - MDS - 27/01/2016, añadir nmovimi
         FETCH cur
          INTO vcobliga, vnmovimi, capital, viextrap, prima.iprianu, prima.ipritar, prima.ipritot,
               vprecarg, virecarg, prima.itarifa, vpdtocom, vidtocom, prima.itotanu,

-- Ini Bug 21907 -- MDS -- 23/04/2012
               prima.pdtotec, prima.preccom, prima.idtotec, prima.ireccom, prima.ipricom,prima.itotdev;

         -- Fin FBL. 25/06/2014 MSV Bug 0028974

         -- Fin Bug 21907 -- MDS -- 23/04/2012
         CLOSE cur;

         vpasexec := 5;

         -- Bug 9905 - RSC - 10/06/2009 - Suplemento de cambio de forma de pago diferido
         -- Se ha detectado que existen garantías contratadas con iprianu = 0. 0 es igual
         -- a -0 y por tanto estaba realizando RETURN. Al realizar return no se estaba informando
         -- correctamente el campo precarg en el objeto ni en las EST y por tanto se estaba
         -- detectando erroneamente un suplemento 801 por la diferencia existente entre
         -- garanseg y estgaranseg (precarg 0 y precard = null, respectivamente.
         --IF NVL(prima.iprianu, -0) = -0 THEN
         -- INI -IAXIS-3264 -19/01/2020
         IF NOT (v_suple = 1 AND vcobliga = 0 AND
            pac_iax_suplementos.lstmotmov(1).cmotmov = 239 and
            NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.poliza.det_poliza.sproduc,'BAJA_AMP_DEV_TOT'),0) = 1) THEN
         -- FIN -IAXIS-3264 -19/01/2020
           IF NVL(prima.iprianu, -1) = -1 THEN
             RETURN;
           END IF;
         END IF; --IAXIS-3264 -19/01/2020

         -- INI AXIS-3640 CJMR  13/12/2019
         IF pac_iax_produccion.issuplem AND prima.itotdev < 0 THEN
            num_err := pac_preguntas.f_get_pregunseg(pssolicit, pnriesgo, 9802, pmode, v_crespue9802);
            
            IF num_err = 0 THEN
            
               SELECT TRUNC(femisio)
                 INTO v_femisio
                 FROM recibos 
                WHERE sseguro = pac_iax_produccion.poliza.det_poliza.ssegpol
                  AND nmovimi = v_crespue9802;
            
            ELSE
               v_femisio := TRUNC(F_SYSDATE);
            END IF;
         ELSE
            v_femisio := TRUNC(F_SYSDATE);
         END IF;
         -- FIN AXIS-3640 CJMR  13/12/2019

         -- Fin Bug 9905
         prima.iextrap := NVL(viextrap, 0);
         prima.precarg := NVL(vprecarg, 0);
         prima.irecarg := NVL(virecarg, 0);
         prima.pdtocom := NVL(vpdtocom, 0);
         -- Bug 26923/0146520 - APD - 14/06/2013 - no se multiplica por -1 el idtocom para que tenga el mismo
         -- signo que idtotec y los dos se sumen con el mismo signo en itotdto
         --prima.idtocom := (-1) * NVL(vidtocom, 0);   --(JAS)03.06.2008 - Els descomptes es guraden a BD amb signe negatiu, però els tractem/retornem a pantalla amb signe positiu.
         -- fin Bug 26923/0146520 - APD - 14/06/2013
         prima.idtocom := NVL(vidtocom, 0);   --(JAS)03.06.2008 - Els descomptes es guraden a BD amb signe negatiu, però els tractem/retornem a pantalla amb signe positiu.
         -- BUG 20666-  01/2012 - JRH  -  20666:   -- BUG 20666-  01/2012 - JRH  -  20666:  Buscar en las CAR Si tenemos el capitalo inicial informado la extraprima utiliza este capital
         vcapital_ini := NULL;
         vcapital_def := NULL;

         IF NVL(f_parproductos_v(v_sproduc, 'CAPITAL_REVAL'), 0) <> 1 THEN
            nerr := pac_preguntas.f_get_pregungaranseg(pssolicit, pcgarant, pnriesgo, 4071,
                                                       pmode, vcapital_ini);

            IF nerr = 0 THEN
               vcapital_def := vcapital_ini;
            ELSIF nerr = 120135 THEN
               vcapital_def := capital;
            ELSE
               p_tab_error(f_sysdate, f_user, 'pac_mobj_prod.calculextraprima', vpasexec,
                           'Error extraprima',
                           nerr || ' - ' || 'Error buscando capital inicial');
               vcapital_def := capital;   --No hacemos raise del error de momento
            END IF;
         ELSE
            vcapital_def := capital;   --CAPITAL REVALORIZADO
         END IF;

         --  FiBUG 20666-  01/2012 - JRH
         prima.iiextrap := vcapital_def * prima.iextrap;   -- Import de la extraprima (BUG19532:DRA:26/09/2011)
         vpasexec := 6;

         BEGIN
            -- Bug 0025583 - 08/02/2013 - JMF: prorrateo
            IF pmode = 'EST' THEN
               SELECT NVL(a.crecfra, 0), a.cforpag, a.fefecto, a.frenova, b.cprorra,
                      b.crevfpg, b.ctipefe, b.ndiaspro, a.fcaranu, a.ssegpol, cempres,
                      a.cramo, a.cmodali, a.ctipseg, a.ccolect, a.cactivi, a.fvencim,
                      a.cduraci, a.npoliza
                 INTO vcrecfra, vcforpag, d_efecto, d_renova, v_cprorra,
                      v_crevfpg, v_ctipefe, v_diaspro, v_fcaranu, v_ssegpol, v_cempres,
                      v_cramo, v_cmodali, v_ctipseg, v_ccolect, v_cactivi, d_vencim,
                      v_cduraci, v_npoliza
                 FROM estseguros a, productos b
                WHERE sseguro = pssolicit
                  AND b.sproduc = a.sproduc;

               SELECT NVL(MAX(fefecto), d_efecto)
                 INTO v_fultrenova
                 FROM movseguro m
                WHERE sseguro = v_ssegpol
                  AND nmovimi <= pnmovimi
                  AND cmovseg IN(0, 2);
            ELSE
               SELECT NVL(a.crecfra, 0), a.cforpag, a.fefecto, a.frenova, b.cprorra,
                      b.crevfpg, b.ctipefe, b.ndiaspro, a.fcaranu, cempres, a.cramo,
                      a.cmodali, a.ctipseg, a.ccolect, a.cactivi, a.fvencim, a.cduraci,
                      a.npoliza
                 INTO vcrecfra, vcforpag, d_efecto, d_renova, v_cprorra,
                      v_crevfpg, v_ctipefe, v_diaspro, v_fcaranu, v_cempres, v_cramo,
                      v_cmodali, v_ctipseg, v_ccolect, v_cactivi, d_vencim, v_cduraci,
                      v_npoliza
                 FROM seguros a, productos b
                WHERE sseguro = pssolicit
                  AND b.sproduc = a.sproduc;

               SELECT MAX(fefecto)
                 INTO v_fultrenova
                 FROM movseguro
                WHERE sseguro = pssolicit
                  AND nmovimi <= pnmovimi
                  AND cmovseg IN(0, 2);
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               vcrecfra := 0;
         END;

         -- ini Bug 0025583 - 08/02/2013 - JMF: prorrateo
         --Inicio CJMR
         BEGIN
            --busca sseguro de la póliza 0
            SELECT sseguro
              INTO v_sseguro
              FROM seguros
             WHERE npoliza = v_npoliza
               AND ncertif = 0;

            --nerr := pac_preguntas.f_get_pregunpolseg(v_sseguro, 4313, NULL, v_preg4313);
            BEGIN
               SELECT p.crespue
                 INTO v_preg4313
                 FROM pregunpolseg p
                WHERE p.sseguro = v_sseguro
                  AND p.cpregun = 4313
                  AND p.nmovimi = (SELECT MAX(nmovimi)
                                     FROM pregunpolseg p2
                                    WHERE p2.sseguro = p.sseguro
                                      AND p2.cpregun = p.cpregun);
            EXCEPTION
               WHEN OTHERS THEN
                  v_preg4313 := 0;
            END;

            IF pnmovimi IN(0, 1)
               AND v_preg4313 = 1 THEN
               d_efecto := TO_DATE(frenovacion(NULL, v_sseguro, 2), 'yyyymmdd');
            END IF;
         EXCEPTION
            WHEN OTHERS THEN
               nerr := 1;
         END;

         --Fin CJMR
         IF ((vcforpag = 1
              AND v_cduraci <> 6)
             --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
             OR(vcforpag = 0
                AND NVL(f_parproductos_v(v_sproduc, 'PRORR_PRIMA_UNICA'), 0) <> 1)) THEN
            facnet := 1;
            facdev := 1;   -- BUG 0026870 - AFM - 20/06/2013
         ELSIF (d_renova IS NULL
                OR v_suple = 1)
               --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
               AND vcforpag <> 0 THEN
            facnet := 1 / vcforpag;
            facdev := 1;   -- BUG 0026870 - AFM - 20/06/2013
         ELSE
            -- ini calcular la fecha proxima cartera
            DECLARE
               lcforpag       NUMBER;
               lmeses         NUMBER;
               ddmm           VARCHAR2(4);
               dd             VARCHAR2(2);
               lfcanua        DATE;
               fecha_aux      DATE;
               l_fefecto_1    DATE;
               lfaux          DATE;
               lfcapro        DATE;
            BEGIN
               IF vcforpag = 0
                  AND v_crevfpg = 1 THEN
                  lcforpag := 1;
               -- que calcule las fechas como si fuera pago anual
               ELSE
                  lcforpag := vcforpag;
               END IF;

               lmeses := 12 / lcforpag;

               IF d_renova IS NOT NULL THEN
                  dd := TO_CHAR(d_renova, 'dd');   -- SUBSTR(LPAD(v_pol.nrenova, 4, 0), 3, 2);
                  ddmm := TO_CHAR(d_renova, 'ddmm');   -- dd || SUBSTR(LPAD(v_pol.nrenova, 4, 0), 1, 2);
               ELSE
                  dd := SUBSTR(LPAD(d_renova, 4, 0), 3, 2);
                  ddmm := dd || SUBSTR(LPAD(d_renova, 4, 0), 1, 2);
               -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
               END IF;

               -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
               IF d_renova IS NOT NULL THEN
                  lfcanua := d_renova;
               ELSE
                  -- Fin bug 23117
                  IF TO_CHAR(d_efecto, 'DDMM') = ddmm
                     OR LPAD(d_renova, 4, 0) IS NULL THEN
                     --lfcanua     := ADD_MONTHS(v_pol.fefecto, 12);
                     lfcanua := f_summeses(d_efecto, 12, dd);
                  ELSE
                     IF v_ctipefe = 2 THEN   -- a día 1/mes por exceso
                        fecha_aux := ADD_MONTHS(d_efecto, 13);
                        lfcanua := TO_DATE(ddmm || TO_CHAR(fecha_aux, 'YYYY'), 'DDMMYYYY');
                     ELSE
                        BEGIN
                           lfcanua := TO_DATE(ddmm || TO_CHAR(d_efecto, 'YYYY'), 'DDMMYYYY');
                        EXCEPTION
                           WHEN OTHERS THEN
                              IF ddmm = 2902 THEN
                                 ddmm := 2802;
                                 lfcanua := TO_DATE(ddmm || TO_CHAR(d_efecto, 'YYYY'),
                                                    'DDMMYYYY');
                              ELSE
                                 --Fecha de renovación (mmdd) incorrecta
                                 p_tab_error(f_sysdate, f_user, vobject, 909,
                                             'ddmm=' || ddmm || ' d_efecto=' || d_efecto
                                             || ' ' || vparam,
                                             SQLERRM);
                              END IF;
                        END;
                     END IF;

                     IF lfcanua <= d_efecto THEN
                        --lfcanua     := ADD_MONTHS(lfcanua, 12);
                        lfcanua := f_summeses(lfcanua, 12, dd);
                     END IF;
                  END IF;
               -- Bug 23117 - RSC - 31/07/2012 -  LCOL_T010-LCOL - POLIZAS RENOVABLES Y VIGENCIA DIFERENTE A UN A?O
               END IF;

               IF d_renova IS NOT NULL
                  AND lcforpag IN(0, 1) THEN
                  lfcapro := d_renova;
               ELSE
                  -- Se calcula la próx. cartera partiendo de la cartera de renovación (fcaranu)
                  -- y restándole periodos de pago
                  -- Calculem la data de propera cartera
                  IF v_ctipefe = 2
                     AND TO_CHAR(d_efecto, 'dd') <> 1
                     AND lcforpag <> 12 THEN
                     l_fefecto_1 := '01/' || TO_CHAR(ADD_MONTHS(d_efecto, 1), 'mm/yyyy');
                  ELSE
                     l_fefecto_1 := d_efecto;
                  END IF;

                  lfaux := lfcanua;

                  WHILE TRUE LOOP
                     --lfaux        := ADD_MONTHS(lfaux, -lmeses);
                     lfaux := f_summeses(lfaux, -lmeses, dd);

                     IF lfaux <= l_fefecto_1 THEN
                        lfcapro := f_summeses(lfaux, lmeses, dd);
                        --lfcapro      := ADD_MONTHS(lfaux, lmeses);
                        EXIT;
                     END IF;
                  END LOOP;
               END IF;

               IF (v_diaspro IS NOT NULL) THEN
                  IF TO_NUMBER(TO_CHAR(d_efecto, 'dd')) >= v_diaspro
                     AND TO_NUMBER(TO_CHAR(lfcapro, 'mm')) =
                                              TO_NUMBER(TO_CHAR(ADD_MONTHS(d_efecto, 1), 'mm')) THEN
                     -- és a dir , que el dia sigui > que el dia 15 de l'ultim més del periode
                     lfcapro := ADD_MONTHS(lfcapro, lmeses);

                     IF lfcapro > lfcanua THEN
                        lfcapro := lfcanua;
                     END IF;
                  END IF;
               END IF;

               d_caranu := lfcanua;   -- BUG 0026870 - AFM - 20/06/2013
               d_carpro := lfcapro;
            END;

            -- fin calcular la fecha proxima cartera

            -------------------> ini PRORRATEO  <------------------->
            DECLARE
               v_ini          DATE := d_efecto;
               v_fin          DATE := d_carpro;
               xcprorra       NUMBER := v_cprorra;
               xcforpag       NUMBER := vcforpag;
               fanyoprox      DATE;
               xcmodulo       NUMBER;
               difdias        NUMBER;
               difdias2       NUMBER;
               -- ini Bug 0026070 - 15/02/2013 - JMF: qt 6156
               divisor2       NUMBER;   --Descomentado por DCT 24/04/2015
               num_err        NUMBER;
               xpro_np_360    NUMBER;
               -- ini BUG 0026870 - AFM - 20/06/2013
               difdiasanu     NUMBER;
               difdiasanu2    NUMBER;
               xffinany       DATE;
            -- fin BUG 0026870 - AFM - 20/06/2013
            BEGIN
               --fanyoprox := d_renova;  --Comentado por DCT 24/04/2015
               fanyoprox := ADD_MONTHS(v_ini, 12);   --Nuevo por DCT 24/04/2015

               IF xcprorra = 2 THEN   -- Mod. 360
                  xcmodulo := 3;
               ELSE   -- Mod. 365
                  xcmodulo := 1;
               END IF;

               -- ini BUG 0026870 - AFM - 20/06/2013
               IF xcforpag <> 0 THEN
                  xffinany := NVL(d_caranu, d_renova);
               ELSE
                  --  DRA:28/10/2013:Inici:0028690: POSTEC Camio forma de pago
                  IF NVL(f_parproductos_v(v_sproduc, 'PRORR_PRIMA_UNICA'), 0) = 1
                     AND d_vencim IS NOT NULL THEN
                     v_fin := d_vencim;
                  END IF;

                  --  DRA:28/10/2013:Fi:0028690: POSTEC Camio forma de pago
                  xffinany := v_fin;
               END IF;

               -- fin BUG 0026870 - AFM - 20/06/2013
               num_err := f_difdata(v_ini, v_fin, 3, 3, difdias);
               num_err := f_difdata(v_ini, v_fin, xcmodulo, 3, difdias2);
               -- ini BUG 0026870 - AFM - 20/06/2013
               num_err := f_difdata(v_ini, xffinany, 3, 3, difdiasanu);
               num_err := f_difdata(v_ini, xffinany, xcmodulo, 3, difdiasanu2);
               -- fin BUG 0026870 - AFM - 20/06/2013

               -- ini Bug 0026070 - 15/02/2013 - JMF: qt 6156
               num_err := f_difdata(v_ini, fanyoprox, xcmodulo, 3, divisor2);   --Descomentado por DCT 24/04/2015

               -- fin Bug 0026070 - 15/02/2013 - JMF: qt 6156
               IF xcprorra IN(1, 2) THEN   -- Per dies
                  IF xcforpag <> 0
                     --  DRA:28/10/2013:0028690: POSTEC Camio forma de pago
                     OR NVL(f_parproductos_v(v_sproduc, 'PRORR_PRIMA_UNICA'), 0) = 1 THEN
                     -- El càlcul del factor a la nova producció si s'ha de prorratejar, es fará modul 360 o
                     -- mòdul 365 segon un paràmetre d'instal.lació
                     xpro_np_360 := f_parinstalacion_n('PRO_NP_360');

                     IF NVL(xpro_np_360, 1) = 1 THEN
                        facnet := difdias / 360;
                        facdev := difdiasanu / 360;   -- BUG 0026870 - AFM - 20/06/2013
                     ELSE
                        IF MOD(difdias, 30) = 0
                           AND xcforpag <> 1 THEN
                           -- No hi ha prorrata
                           facnet := difdias / 360;
                           facdev := difdiasanu / 360;   -- BUG 0026870 - AFM - 20/06/2013
                        ELSE
                           -- Hi ha prorrata, prorratejem mòdul 365
                           -- ini Bug 0026070 - 15/02/2013 - JMF: qt 6156
                           facnet := difdias2 / divisor2;   --Nuevo por DCT 24/04/2015
                           --facnet := difdias2 / 365;  --Comentado por DCT 24/04/2015

                           --facdev := difdiasanu2 / 365;   -- BUG 0026870 - AFM - 20/06/2013 --Comentado por DCT 24/04/2015
                           facdev := difdiasanu2 / divisor2;   --Nuevo por DCT 24/04/2015
                        -- fin Bug 0026070 - 15/02/2013 - JMF: qt 6156
                        END IF;
                     END IF;
                  ELSE
                     facnet := 1;
                     facdev := 1;   -- BUG 0026870 - AFM - 20/06/2013
                  END IF;
               END IF;
            END;
         END IF;

         -------------------> fin PRORRATEO  <------------------->
         -- fin Bug 0025583 - 08/02/2013 - JMF: prorrateo
         vpasexec := 7;

         -- BUG 23565/0123797 - FAL - 20/09/2012
         BEGIN
            SELECT NVL(cimpcon, 0), NVL(cimpips, 0)
              INTO xcimpcons, xcimpips
              FROM garanpro
             WHERE sproduc = v_sproduc
               AND cgarant = pcgarant
               AND cactivi = v_cactivi;   -- BUG 0036730 - FAL - 09/12/2015
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  SELECT NVL(cimpcon, 0)
                    INTO xcimpcons
                    FROM garanpro
                   WHERE sproduc = v_sproduc
                     AND cgarant = pcgarant
                     AND cactivi = 0;
               END;
         END;

         IF xcimpcons = 1 THEN   -- Calcular consorcio si consorciable
            -- Bug 0039815 - MDS - 27/01/2016, substituir pnmovimi por vnmovimi
            xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, vnmovimi,
                                                           pmode, 2, vcrecfra, pcgarant,
                                                           prima.iprianu, prima.pdtocom,
                                                           NVL(prima.itotcon, 0)),
                         1);

            IF xpago <> 1 THEN
               -- Bug 0039815 - MDS - 27/01/2016, substituir pnmovimi por vnmovimi
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, vnmovimi, pmode, 2,
                                                      vcrecfra, pcgarant,
                                                      prima.iprianu / xpago, prima.pdtocom,
                                                      prima.iconsor);
            ELSE
               -- Bug 0039815 - MDS - 27/01/2016, substituir pnmovimi por vnmovimi
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, vnmovimi, pmode, 2,
                                                      vcrecfra, pcgarant, prima.iprianu,
                                                      prima.pdtocom, prima.iconsor);
            END IF;

            -- INI Bug 38345 - AFM
            -- viimpprireb := viimpprireb + NVL(prima.iconsor, 0);
            v_cons := NVL(prima.iconsor, 0);
            -- FIN Bug 38345 - AFM
            prima.iconsor := NVL(prima.iconsor, 0) * xpago;
         END IF;

         prima.iconsor := NVL(prima.iconsor, 0);

         -- FI BUG 23565/0123797
         -- Bug 26419/0144875 - APD - 24/05/2013
         --IF NVL(prima.iprianu, -0) <> -0 THEN
         -- Bug 28041/160429 - JSV - 03/12/2013 - INI
         --IF NVL(prima.iprianu, 0) <> 0 THEN

         ------------------------------------------------------------DESDE aca FAC--------------------------------------------------------

         IF NVL(prima.iprianu, 0) <> 0
            OR(NVL(prima.iprianu, 0) = 0
               AND NVL(pac_parametros.f_pargaranpro_n(v_sproduc, 0, 801, 'CALC_IMP_PRIMA_0'),
                       0) = 1
               AND NOT(pac_seguros.f_es_col_agrup(pssolicit, pmode) = 1
                       AND pac_seguros.f_soycertifcero(v_sproduc, v_npoliza, pssolicit) = 0)) THEN
            -- Bug 28041/160429 - JSV - 03/12/2013 - FIN
            -- fin Bug 26419/0144875 - APD - 24/05/2013
            /*
            nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 2,
                                                   vcrecfra, pcgarant, prima.iprianu,
                                                   prima.pdtocom, prima.iconsor);
            */  -- BUG 23565/0123797 - FAL - 20/09/2012  Calcular consorcio aunque no haya prima

            --inicio bartolo herrera 01-04-2019

            v_cambio_trm_dev := prima.itotdev;
            v_cambio_trm := prima.iprianu;

            select cmoncap into v_cmoneda from garanpro where cgarant = pcgarant and sproduc = PAC_IAX_PRODUCCION.poliza.det_poliza.sproduc and rownum <= 1;

            if v_cmoneda <> 8 then

                select cmonint into v_tmoneda from monedas where cidioma = 8 and cmoneda = v_cmoneda and rownum <=1;
                -- INI AXIS-3640 CJMR  13/12/2019
                --v_cambio_trm := pac_eco_tipocambio.f_importe_cambio(v_tmoneda,'COP',F_SYSDATE,v_cambio_trm);
                --v_cambio_trm_dev := pac_eco_tipocambio.f_importe_cambio(v_tmoneda,'COP',F_SYSDATE,v_cambio_trm_dev);
                v_cambio_trm := pac_eco_tipocambio.f_importe_cambio(v_tmoneda,'COP',v_femisio,v_cambio_trm);
                v_cambio_trm_dev := pac_eco_tipocambio.f_importe_cambio(v_tmoneda,'COP',v_femisio,v_cambio_trm_dev);
                -- FIN AXIS-3640 CJMR  13/12/2019

            end if;

      --fin bartolo herrera 01-04-2019

           IF NVL(f_parproductos_v(v_sproduc, 'PRIMA_VIG_AMPARO'), 0) = 0 then
                    xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                               pmode, 4, vcrecfra, pcgarant,
                                                               --prima.iprianu, prima.pdtocom,
                                                               v_cambio_trm, prima.pdtocom, --bartolo herrera 01-04-2019
                                                               NVL(prima.iips, 0)),
                         1);
           ELSE
                   xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                               pmode, 4, vcrecfra, pcgarant,
                                                               --prima.itotdev, prima.pdtocom,
                                                               v_cambio_trm_dev, prima.pdtocom,--bartolo herrera 01-04-2019
                                                               NVL(prima.iips, 0)),
                         1);

           END IF;

            -- BUG 26733/0152629 - FAL - 16/09/2013 - Aunque impuesto fraccionado, calculo impuesto + derechos registro en GIP, sobre la prima anual
            IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'IMPOST_PER_PREG'), 0) = 1 THEN
               xpago := 1;
            END IF;

            -- FI BUG 26733/0152629
            IF xpago <> 1 THEN
               IF NVL(f_parproductos_v(v_sproduc, 'PRIMA_VIG_AMPARO'), 0) = 0 then
                 nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 4,
                                                        vcrecfra, pcgarant,
                                                       -- prima.iprianu / xpago, prima.pdtocom,
                                                        v_cambio_trm / xpago, prima.pdtocom,--bartolo herrera 01-04-2019
                                                        prima.iips);
              ELSE
                 nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 4,
                                                          vcrecfra, pcgarant,
                                                          --prima.itotdev / xpago, prima.pdtocom,
                                                          v_cambio_trm_dev / xpago, prima.pdtocom,--bartolo herrera 01-04-2019
                                                          prima.iips);
              END IF;
            ELSE
                IF NVL(f_parproductos_v(v_sproduc, 'PRIMA_VIG_AMPARO'), 0) = 0 then

                nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 4,
                                                          --vcrecfra, pcgarant, prima.iprianu,
                                                          vcrecfra, pcgarant, v_cambio_trm,--bartolo herrera 01-04-2019
                                                          prima.pdtocom, prima.iips);
                ELSE
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 4,
                                                          vcrecfra, pcgarant,
                                                          --prima.itotdev / xpago, prima.pdtocom,
                                                          v_cambio_trm_dev/xpago, prima.pdtocom,--bartolo herrera 01-04-2019
                                                          prima.iips);
                END IF;
            END IF;

            -- INI Bug 38345 - AFM
            v_impips := NVL(prima.iips, 0);
              -- viimpprireb := viimpprireb + NVL(prima.iips, 0); -- Bug 26870 - AFM - 20/06/2013
            -- FIN Bug 38345 - AFM
            prima.iips := prima.iips * xpago;
            xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                           pmode, 5, vcrecfra, pcgarant,
                                                           prima.iprianu, prima.pdtocom,
                                                           NVL(prima.iips, 0)),
                         1);

            IF xpago <> 1 THEN
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 5,
                                                      vcrecfra, pcgarant,
                                                      prima.iprianu / xpago, prima.pdtocom,
                                                      prima.idgs);   --Bug 9034
            ELSE
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 5,
                                                      vcrecfra, pcgarant, prima.iprianu,
                                                      prima.pdtocom, prima.idgs);
            END IF;

            -- INI Bug 38345 - AFM
            -- viimpprireb := viimpprireb + NVL(prima.idgs, 0);
            v_clea := NVL(prima.idgs, 0);
            -- FIN Bug 38345 - AFM
            prima.idgs := prima.idgs * xpago;
            vpasexec := 8;

            -- BUG 26835 - FAL - 06/05/2013
            IF f_control_carbritrios(pmode, pssolicit, pnmovimi, pnriesgo, pcgarant) = 0 THEN
               -- FI BUG 26835 - FAL - 06/05/2013
               xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                              pmode, 6, vcrecfra, pcgarant,
                                                              prima.iprianu, prima.pdtocom,
                                                              NVL(prima.iips, 0)),
                            1);

               -- BUG 26733/0152629 - FAL - 16/09/2013 - Aunque impuesto fraccionado, calculo impuesto + derechos registro en GIP sobre la prima anual
               IF NVL(pac_parametros.f_parempresa_n(v_cempres, 'IMPOST_PER_PREG'), 0) = 1 THEN
                  xpago := 1;
               END IF;

               -- FI BUG 26733/0152629
               IF xpago <> 1 THEN
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         6, vcrecfra, pcgarant,
                                                         prima.iprianu / xpago, prima.pdtocom,
                                                         prima.iarbitr);
               ELSE
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         6, vcrecfra, pcgarant, prima.iprianu,
                                                         prima.pdtocom, prima.iarbitr);
               END IF;

               -- INI Bug 38345 - AFM
               --viimpprireb := viimpprireb + NVL(prima.iarbitr, 0);
               v_arb := NVL(prima.iarbitr, 0);
               -- FIN Bug 38345 - AFM
               prima.iarbitr := prima.iarbitr * xpago;
            -- BUG 26835 - FAL - 06/05/2013
            ELSE
               prima.iarbitr := 0;
            -- FI BUG 26835 - FAL - 06/05/2013
            END IF;

            xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                           pmode, 7, vcrecfra, pcgarant,
                                                           prima.iprianu, prima.pdtocom,
                                                           NVL(prima.ifng, 0)),
                         1);

            IF xpago <> 1 THEN
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 7,
                                                      vcrecfra, pcgarant,
                                                      prima.iprianu / xpago, prima.pdtocom,
                                                      prima.ifng);
            ELSE
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 7,
                                                      vcrecfra, pcgarant, prima.iprianu,
                                                      prima.pdtocom, prima.ifng);
            END IF;

            -- INI Bug 38345 - AFM
            --viimpprireb := viimpprireb + NVL(prima.ifng, 0);
            v_fng := NVL(prima.ifng, 0);
            -- FIN Bug 38345 - AFM
            prima.ifng := prima.ifng * xpago;
            xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                           pmode, 8, vcrecfra, pcgarant,
                                                           prima.iprianu, prima.pdtocom,
                                                           NVL(prima.irecfra, 0)),
                         1);

            IF xpago <> 1 THEN
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 8,
                                                      vcrecfra, pcgarant,
                                                      prima.iprianu / xpago, prima.pdtocom,
                                                      prima.irecfra);
            ELSE
               nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode, 8,
                                                      vcrecfra, pcgarant, prima.iprianu,
                                                      prima.pdtocom, prima.irecfra);
            END IF;

            -- INI Bug 38345 - AFM
            --viimpprireb := viimpprireb + NVL(prima.irecfra, 0);   -- BUG 0037271 - FAL - 27/08/2015 - Acumular el recfracc en el importe 1º recibo igual que el resto de impuestos
            v_rec := NVL(prima.irecfra, 0);
            -- FIN Bug 38345 - AFM
            prima.irecfra := prima.irecfra * xpago;
            vpasexec := 9;

            n_derreg_poliza   := NVL(pac_parametros.f_parproducto_n(v_sproduc, 'DERREG_POLIZA'), 0);
            --Se añade condición para el caso de que los gastos de expedición se apliquen a nivel de póliza y no de garantia
            b_primerderreg := TRUE;
            vpasexec := 91;
            gars               := pac_iobj_prod.f_partriesgarantias(pac_iobj_prod.f_partpolriesgo(pac_iax_produccion.poliza.det_poliza, 1, mensajes), mensajes);

            -- INI -IAXIS-3264 -19/01/2020
            vpasexec := 92;
            IF gars is not null and gars.count > 0 then
              FOR vgar IN gars.first..gars.last LOOP
                 exit when gars(vgar).cgarant=pcgarant;
                 if nvl(gars(vgar).primas.icderreg,0) > 0 then
                   b_primerderreg := FALSE;
                 end if;
              END LOOP;
            end if;
            vpasexec := 93;
            -- FIN -IAXIS-3264 -19/01/2020

            IF f_control_cderreg(pmode, pssolicit, pnmovimi, pnriesgo, pcgarant) = 0 AND NOT (b_primerderreg = FALSE AND n_derreg_poliza = 1) THEN
               vpasexec := 94;
               xpago := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                              pmode, 14, vcrecfra, pcgarant,
                                                              prima.iprianu, prima.pdtocom,
                                                              NVL(prima.icderreg, 0)),
                            1);
               vpasexec := 95;

               IF xpago <> 1 THEN
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         14, vcrecfra, pcgarant,
                                                         prima.iprianu / xpago, prima.pdtocom,
                                                         prima.icderreg);
                  vpasexec := 96;
                  -- Bug 23074 - APD - 02/08/2012 - si hay gastos de expedicion, se calcula tambien
                  -- su iva (cconcep = 86 (v.f.27))
                  -- AMA-214 : Se cambia viivacderreg por prima.iivaimp
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         86, vcrecfra, pcgarant,
                                                         prima.iprianu / xpago, prima.pdtocom,
                                                         viivacderreg);
                  vpasexec := 97;
                  prima.iivaimp := viivacderreg;
               ELSE
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         14, vcrecfra, pcgarant,
                                                         prima.iprianu, prima.pdtocom,
                                                         prima.icderreg);
                  -- AMA-214 : Se cambia viivacderreg por prima.iivaimp
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         86, vcrecfra, pcgarant,
                                                         prima.iprianu, prima.pdtocom,
                                                         viivacderreg);
                  vpasexec := 98;
                  prima.iivaimp := viivacderreg;
               END IF;

               -- Bug 25952 --ECP-- 02/11/2011 Se suma  NVL(viivacderreg, 0)
               --viimpprireb := viimpprireb + NVL(prima.icderreg, 0) + NVL(viivacderreg, 0);
               prima.icderreg := prima.icderreg * xpago;
               viivacderreg := viivacderreg * xpago;
               vpasexec := 99;
            -- fin Bug 23074 - APD - 02/08/2012
            ELSE
               prima.icderreg := 0;
               viivacderreg := 0;   -- Bug 23074 - APD - 02/08/2012
            END IF;
         -- Bug 26419/0144875 - APD - 24/05/2013
         ELSE
            prima.iips := 0;
            prima.idgs := 0;
            prima.iarbitr := 0;
            prima.ifng := 0;
            prima.irecfra := 0;
            prima.icderreg := 0;
         -- fin Bug 26419/0144875 - APD - 24/05/2013
         END IF;

         vpasexec := 10;
         prima.irecfra := NVL(prima.irecfra, 0);
         prima.itotpri := NVL(prima.iprianu, 0);
         prima.idgs := NVL(prima.idgs, 0);   -- + NVL(prima.IARBITR,0) + NVL(prima.IFNG,0);
         -- Ini Bug 21907 -- MDS -- 23/04/2012
         --prima.itotdto := NVL(prima.idtocom, 0);   --(ITOTPRI*PDTOCOM);
         prima.itotdto := NVL(prima.idtocom, 0) + NVL(prima.idtotec, 0);
         prima.itotrec := NVL(prima.ireccom, 0) + NVL(prima.irecarg, 0);
         -- Fin Bug 21907 -- MDS -- 23/04/2012
         -- Bug 0019578 - FAL - 26/09/2011 - Cálculo derechos de registro
         prima.icderreg := NVL(prima.icderreg, 0);
         -- Fi Bug 0019578
         prima.itotcon := NVL(prima.iconsor, 0) + NVL(prima.ireccon, 0);
         -- Bug 23074 - APD - 02/08/2012 - se suma tambien el iva de los gastos de expedicion (viivacderreg)
         prima.itotimp := NVL(prima.itotcon, 0) + NVL(prima.iips, 0) + NVL(prima.idgs, 0)
                          + NVL(prima.iarbitr, 0)
                          + NVL(prima.ifng, 0)   -- + NVL(prima.icderreg, 0)
                          + NVL(viivacderreg, 0);   -- Bug 0019578 - FAL - 26/09/2011 - Añadir derechos de registro como impueto
         -- fin Bug 23074 - APD - 02/08/2012
         --(JAS)03.06.2008 - La prima total ha de tenir en compte el concepte IPRITOT pel cas de coaseguro,
         --i no cal aplicar el descompte (ITOTDTO) ni la sobreprima(IRECARG), perquè tant la IPRIANU com la IPRITOT, com la ITOTPRI ja els tenen aplicats.
         --prima.ITOTALR := NVL(prima.ITOTPRI,0) - NVL(prima.ITOTDTO,0) + NVL(prima.ITOTIMP,0) + NVL(prima.irecarg,0) + NVL(prima.IRECFRA,0);
         -- INI SV1 Cálculo IVA - 15/03/2018 -- JLTS - Se ajusta la prima.iips para que contenga todos los gastos (viivacderreg)
         prima.iips := prima.iips + NVL(viivacderreg, 0);
         -- FIN SV1 Cálculo IVA - 15/03/2018 -- JLTS
		 
		 --INI IAXIS-5115 CJMR  22/08/2019
		 v_cmonint_app := pac_monedas.f_cmoneda_t(f_parinstalacion_n('MONEDAINST'));
		 v_cmonint_prod := pac_monedas.f_moneda_producto_char(pac_iax_produccion.poliza.det_poliza.sproduc);

     -- INI AXIS-3640 CJMR  13/12/2019
     --prima.irecfra := pac_eco_tipocambio.f_importe_cambio(v_cmonint_prod, v_cmonint_app, TRUNC(F_SYSDATE), prima.irecfra);
     --prima.itotdev := pac_eco_tipocambio.f_importe_cambio(v_cmonint_prod, v_cmonint_app, TRUNC(F_SYSDATE), prima.itotdev);
     prima.irecfra := pac_eco_tipocambio.f_importe_cambio(v_cmonint_prod, v_cmonint_app, v_femisio, prima.irecfra);
     -- INI -IAXIS-3264 -19/01/2020
     p_control_error('JLTS','PAC_MDOBJ_PROD.P_GET_PRIGARANT','01 pcgarant='||pcgarant||' prima.itotdev='||prima.itotdev||' v_suple='||v_suple||' vcobliga='||vcobliga);
     IF v_suple = 1 AND vcobliga = 0 THEN
       IF  pac_iax_suplementos.lstmotmov(1).cmotmov = 239 and
            NVL (pac_parametros.f_parproducto_n (pac_iax_produccion.poliza.det_poliza.sproduc,'BAJA_AMP_DEV_TOT'),0) = 1 THEN
            -- Siempre en MONEDAINST (COP) para la patalla
           IF pac_monedas.f_moneda_producto(pac_iax_produccion.poliza.det_poliza.sproduc) != f_parinstalacion_n('MONEDAINST') THEN
             prima.itotdev := f_get_valores_baja_amp(pssolicit,pcgarant,pnmovimi,1,2);
           ELSE
             prima.itotdev := f_get_valores_baja_amp(pssolicit,pcgarant,pnmovimi,1,1);
           END IF;
       ELSE
         prima.itotdev := pac_eco_tipocambio.f_importe_cambio(v_cmonint_prod, v_cmonint_app, v_femisio, prima.itotdev);
       end if;
     ELSE
     -- FIN -IAXIS-3264 -19/01/2020
       prima.itotdev := pac_eco_tipocambio.f_importe_cambio(v_cmonint_prod, v_cmonint_app, v_femisio, prima.itotdev);
     END IF; --IAXIS-3264 -19/01/2020
     -- INI AXIS-3640 CJMR  13/12/2019
     --FIN IAXIS-5115 CJMR  22/08/2019

		--
         IF NVL(f_parproductos_v(v_sproduc, 'PRIMA_VIG_AMPARO'), 0) = 0 then
           prima.itotalr := NVL(prima.ipritot, 0) + NVL(prima.itotimp, 0)
                            + NVL(prima.icderreg, 0) + NVL(prima.irecfra, 0);
         else
           prima.itotalr := NVL(prima.itotdev, 0) + NVL(prima.itotimp, 0)
                            + NVL(prima.icderreg, 0) + NVL(prima.irecfra, 0);
         end if;


         --(DCT)03.02.2009
         IF NVL(vcforpag, 0) = 0 THEN
            vcforpag := 1;
         END IF;

         -- Bug 20448 - APD - 19/12/2011 - el calculo del importe del primer recibo no siempre se
         -- debe dividir entre la forma de pago
         -- SOLO se debe DIVIDIR ipritot e IRECFRA y aquellos impuestos que se indiquen en
         -- la tabla imprec (campo cfracci)
         --prima.iprireb := NVL(prima.itotalr, 0) / vcforpag;
         -- Bug 23074 - APD - 03/08/2012 - los impuestos Gastos de Expedicion (cconcep = 14) e
         -- IVA - Gastos de Expedicion (86) se pueden dividir entre la forma de pago
         -- según indiquen las preguntas 4093.- Aplica gastos de expedición y
         -- 4094.- Periodicidad de los gastos
         nerr := pac_preguntas.f_get_pregunpolseg(pssolicit, 4093, pmode, vcagastexp);   -- Aplica gastos de expedición
         nerr := pac_preguntas.f_get_pregunpolseg(pssolicit, 4094, pmode, vcperiogast);   -- Periodicidad de los gastos

         /* prima.icderreg := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                                  pmode, 14, vcrecfra, pcgarant,
                                                                  prima.iprianu, prima.pdtocom,
                                                                  NVL(prima.icderreg, 0)),
                                0);
          -- Bug 23074 - APD - 02/08/2012 - se suma tambien el iva de los gastos de expedicion (viivacderreg)
          viivacderreg := NVL(pac_mdobj_prod.f_importe_impuesto(pssolicit, pnriesgo, pnmovimi,
                                                                pmode, 86, vcrecfra, pcgarant,
                                                                prima.iprianu, prima.pdtocom,
                                                                NVL(viivacderreg, 0)),
                              0);*/
         IF NVL(vcagastexp, 2) <> 0
            AND NVL(vcperiogast, 2) = 1
            AND vcforpag NOT IN(0, 1)   --Bug 32705/188497-01/10/2014-AMC
                                     THEN
            d_ini := v_fultrenova;
            d_fin := NVL(v_fcaranu, NVL(d_renova, ADD_MONTHS(d_efecto, 12)));
            n_div := 12 / vcforpag;

            IF d_ini IS NOT NULL
               AND d_fin IS NOT NULL THEN
               --BUG 33488/192098-20/11/2014-AMC
               n_cuotas := CEIL(MONTHS_BETWEEN(d_fin, d_ini) / n_div);   --Bug 32705/190821-05/11/2014-AMC
               prima.icderreg := f_round(prima.icderreg / n_cuotas);
               viivacderreg := f_round(viivacderreg / n_cuotas);
            END IF;
         -- fin Bug 23074 - APD - 03/08/2012
         END IF;

         --viimpprireb := viimpprireb + NVL(prima.icderreg, 0) -- Bug 25952--ECP-- 02/11/2013
                                                            -- Bug 23074 - APD - 02/08/2012 - se suma tambien el iva de los gastos de expedicion (viivacderreg)
         --               + NVL(viivacderreg, 0);    -- Bug 25952--ECP-- 02/11/2013

         -- Ini Bug 26870 - AFM - 20/06/2013
         -- Se realiza aquí porque se necesita la prima devengada para calcular el IPS.   Los otros impuestos también tendrían que calcularse aqui.
         -- IF facnet <> 1 THEN   -- BUG 28420 - FAL - 22/10/2013
         IF facnet <> 1
            AND facdev <> 1 THEN   -- BUG 28420/0156750 - FAL - 24/10/2013
            viimpprireb := 0;

            -- 2 Consorcio
            -- INI Bug 38345
            IF xcimpcons = 1 THEN
               nerr := f_concepto(2, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         2, v_crecfra, pcgarant,
                                                         NVL(prima.ipritot, 0), vidtocom,
                                                         v_cons);

                  IF v_cfracci = 0 THEN
                     v_cons := f_round(NVL(v_cons, 0) * facdev, v_monprod);
                  ELSE
                     v_cons := f_round(NVL(v_cons, 0) * facnet, v_monprod);
                  END IF;

                  viimpprireb := viimpprireb + NVL(v_cons, 0);
               END IF;
            END IF;

            -- 4 IPS
            IF xcimpips = 1 THEN
               nerr := f_concepto(4, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  IF v_cfracci = 0 THEN
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facdev, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  ELSE
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facnet, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  END IF;

                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         4, v_crecfra, pcgarant, v_iprigar,
                                                         vidtocom, v_impips);

                  --AQ Se añade una validación que en el caso en que el IVA es formulado , al no devolver el
                  --valor prorrateado entonces el prorrateo se calcula aqui
                  IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                       'PRORATEO_IVA'),
                         0) = 1 THEN
                     IF v_cfracci = 0 THEN
                        v_impips :=
                           f_round(NVL(v_impips, 0) * facdev, v_monprod,
                                   NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                     'REDONDEO_SRI'),
                                       0));
                     ELSE
                        v_impips :=
                           f_round(NVL(v_impips, 0) * facnet, v_monprod,
                                   NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                     'REDONDEO_SRI'),
                                       0));
                     END IF;
                  END IF;

                  viimpprireb := viimpprireb + NVL(v_impips, 0);
               END IF;
            END IF;

            -- 5 DGS/CLEA
            IF NVL(v_clea, 0) <> 0 THEN
               nerr := f_concepto(5, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  IF v_cfracci = 0 THEN
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facdev, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  ELSE
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facnet, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  END IF;

                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         5, v_crecfra, pcgarant, v_iprigar,
                                                         vidtocom, v_clea);
                  viimpprireb := viimpprireb + NVL(v_clea, 0);
               END IF;
            END IF;

            -- 6 Arbitrios
            IF NVL(v_arb, 0) <> 0 THEN
               nerr := f_concepto(6, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  IF v_cfracci = 0 THEN
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facdev, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  ELSE
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facnet, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  END IF;

                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         6, v_crecfra, pcgarant, v_iprigar,
                                                         vidtocom, v_arb);
                  viimpprireb := viimpprireb + NVL(v_arb, 0);
               END IF;
            END IF;

            -- 7 FNG
            IF NVL(v_fng, 0) <> 0 THEN
               nerr := f_concepto(7, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  IF v_cfracci = 0 THEN
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facdev, v_monprod);
                  ELSE
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facnet, v_monprod);
                  END IF;

                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         7, v_crecfra, pcgarant, v_iprigar,
                                                         vidtocom, v_fng);
                  viimpprireb := viimpprireb + NVL(v_fng, 0);
               END IF;
            END IF;

            -- 8 Recargo Fraccionamienot
            IF vcrecfra = 1 THEN
               nerr := f_concepto(8, v_cempres, d_efecto, vcforpag, v_cramo, v_cmodali,
                                  v_ctipseg, v_ccolect, v_cactivi, pcgarant, v_ctipcon,
                                  v_nvalcon, v_cfracci, v_cbonifi, v_crecfra, v_climit,
                                  v_cmonimp, v_cderreg);

               IF nerr = 0 THEN
                  IF v_cfracci = 0 THEN
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facdev, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  ELSE
                     v_iprigar := f_round(NVL(prima.ipritot, 0) * facnet, v_monprod,
                                          NVL(pac_parametros.f_parempresa_n(v_cempres,
                                                                            'REDONDEO_SRI'),
                                              0));
                  END IF;

                  nerr := pac_tarifas.f_calcula_concepto(pssolicit, pnriesgo, pnmovimi, pmode,
                                                         8, vcrecfra, pcgarant, v_iprigar,
                                                         vidtocom, v_rec);
                  viimpprireb := viimpprireb + NVL(v_rec, 0);
               END IF;
            END IF;
         ELSE
            -- BUG 28420/0156750 - FAL - 24/10/2013
            -- viimpprireb := viimpprireb + NVL(prima.iips, 0);
            --viimpprireb := viimpprireb + NVL(w_iips, 0);
            -- FI BUG 28420/0156750 - FAL - 24/10/2013
            viimpprireb := NVL(v_impips, 0) + NVL(v_cons, 0) + NVL(v_clea, 0) + NVL(v_fng, 0)
                           + NVL(v_arb, 0) + NVL(v_rec, 0);
         END IF;

         -- FIN Bug 38345

         -- FI BUG 28420 - FAL - 22/10/2013

         -- Fin Bug 26870 - AFM - 20/06/2013

         -- ini Bug 0025583 - 08/02/2013 - JMF: prorrateo
         --prima.iprireb := ((NVL(prima.ipritot, 0) + NVL(prima.irecfra, 0)) / vcforpag) + NVL(viimpprireb, 0);
         -- 25537. AFM. Se añade la moneda del producto en el f_round
         --prima.iprireb := f_round(((NVL(prima.ipritot, 0) + NVL(prima.irecfra, 0)) * facnet),
          --                        v_monprod)
         --                 + NVL(viimpprireb, 0) + prima.icderreg + viivacderreg;
         -- fin Bug 0025583 - 08/02/2013 - JMF: prorrateo

         -- BUG 0037271 - FAL - 27/08/2015 - No incluir el recfracc en el fraccionamiento. Acumularlo en el importe 1º recibo igual que el resto de impuestos
         prima.iprireb := f_round(((NVL(prima.ipritot, 0)) * facnet), v_monprod)
                          + NVL(viimpprireb, 0) + prima.icderreg + viivacderreg;
         -- FI BUG 0037271 - FAL - 27/08/2015

         -- Fin Bug 20448 - APD - 19/12/2011
         vpasexec := 11;

         --(JAS)03.06.2008 - Neteja dels camps de l'objecte OB_IAX_PRIMES repetits.
         --prima.primaseguro := prima.ITOTPRI;
         --prima.impuestos   := prima.ITOTIMP;
         --prima.recargos    := prima.IRECFRA;
         --prima.primatotal  := prima.ITOTALR;
         --prima.primarecibo := prima.ITOTALR;

         -- Bug 30509/168760 - 10/03/2014 - AMC
             DECLARE
                v_ini          DATE := d_efecto;
                v_fin          DATE; -- := d_renova; Bug AMA-351 - 06/07/2016 - DMC
                vxpro_np_360   NUMBER;
                vdifdias       NUMBER;
                vnum_err       NUMBER;
             BEGIN
                vxpro_np_360 := f_parinstalacion_n('PRO_NP_360');

                v_fin := NVL(v_fcaranu, NVL(d_renova, ADD_MONTHS(d_efecto, 12)));-- Bug AMA-351 - 06/07/2016 - DMC

                IF NVL(vxpro_np_360, 1) = 1 THEN
                   vnum_err := f_difdata(v_ini, v_fin, 3, 3, vdifdias);
                   prima.iprivigencia := (vdifdias * prima.iprianu) / 360;
                ELSE
                   vnum_err := f_difdata(v_ini, v_fin, 1, 3, vdifdias);
                   prima.iprivigencia := (vdifdias * prima.iprianu) / 365;
                END IF;

                prima.iprivigencia := f_round(prima.iprivigencia, v_monprod);
             END;
          -- Fi Bug 30509/168760 - 10/03/2014 - AMC
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_prigarant;

   /*************************************************************************
      Recupera las preguntas de riesgo automaticas
      param in/out riesgo    : objeto riesgo
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_pregauto(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                := 'pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_PregAuto';
      curid          INTEGER;
      curid2         INTEGER;
      curid3         INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      vtab3          VARCHAR2(50);
      squery         VARCHAR2(2000);
      squery2        VARCHAR2(2000);
      squery3        VARCHAR2(2000);
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      nmovimi        NUMBER;
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      preg           t_iax_preguntas;
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      nwprg          NUMBER;
      mensajes       t_iax_mensajes := t_iax_mensajes();

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      cur            sys_refcursor;
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      vcagente       NUMBER;
   BEGIN
      vpasexec := 1;

      IF pmode = 'SOL' THEN
         vtab := 'SOLPREGUNSEG';
         vtab3 := 'PREGUNSEGTAB';
      ELSIF pmode = 'EST' THEN
         vtab := 'ESTPREGUNSEG';
         vtab3 := 'ESTPREGUNSEGTAB';
      ELSE
         vtab := 'PREGUNSEG';
         vtab3 := 'PREGUNSEGTAB';
      END IF;

      -- BUG26501 - 21/01/2014 - JTT: Recuperem la polissa
      SELECT sproduc, npoliza, cagente
        INTO vsproduc, vnpoliza, vcagente
        FROM (SELECT sproduc, npoliza, cagente
                FROM estseguros
               WHERE sseguro = pssolicit
                 AND pmode = 'EST'
              UNION ALL
              SELECT sproduc, npoliza, cagente
                FROM seguros
               WHERE sseguro = pssolicit
                 AND NVL(pmode, 'SEG') <> 'EST');

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery := 'SELECT CPREGUN,CRESPUE,TRESPUE ' || ' FROM ' || vtab || ' S '
                || ' WHERE S.SSEGURO=' || pssolicit || ' AND ' || '       S.NMOVIMI='
                || pnmovimi || ' AND ' || '       S.NRIESGO=' || riesgo.nriesgo;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      vpasexec := 6;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         nwprg := 1;
         vpasexec := 7;

         IF riesgo.preguntas IS NOT NULL THEN
            IF riesgo.preguntas.COUNT > 0 THEN
               FOR vprg IN riesgo.preguntas.FIRST .. riesgo.preguntas.LAST LOOP
                  IF riesgo.preguntas.EXISTS(vprg) THEN
                     IF riesgo.preguntas(vprg).cpregun = cpregun THEN
                        vpasexec := 8;
                        riesgo.preguntas(vprg).crespue := crespue;
                        riesgo.preguntas(vprg).trespue := trespue;
                        nwprg := 0;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 9;

         IF nwprg = 1 THEN
            vpasexec := 10;

            -- BUG12384:DRA:02/02/2010:Inici
            IF riesgo.preguntas IS NULL THEN
               riesgo.preguntas := t_iax_preguntas();
            END IF;

            vpasexec := 11;
            -- BUG12384:DRA:02/02/2010:Fi
            riesgo.preguntas.EXTEND;
            riesgo.preguntas(riesgo.preguntas.LAST) := ob_iax_preguntas();
            riesgo.preguntas(riesgo.preguntas.LAST).cpregun := cpregun;
            riesgo.preguntas(riesgo.preguntas.LAST).crespue := crespue;
            riesgo.preguntas(riesgo.preguntas.LAST).trespue := trespue;
         END IF;
      END LOOP;

      vpasexec := 12;
      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' S ' || ' WHERE S.SSEGURO='
                || pssolicit || ' AND S.NRIESGO=' || riesgo.nriesgo || ' AND ' || ' S.NMOVIMI='
                || pnmovimi;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' S '
                    || ' WHERE S.SSEGURO=' || pssolicit || ' AND S.NRIESGO=' || riesgo.nriesgo
                    || ' AND S.CPREGUN = ' || cpregun || ' AND ' || ' S.NMOVIMI=' || pnmovimi;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := nmovimi;
            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('R', cpregun, NULL,
                                                                         mensajes);
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR' || ' FROM ' || vtab3
                       || ' S WHERE S.SSEGURO=' || pssolicit || ' AND S.NRIESGO='
                       || riesgo.nriesgo || ' AND S.CPREGUN = ' || cpregun
                       || ' AND s.nlinea = ' || nlinea || ' AND ' || ' S.NMOVIMI=' || pnmovimi;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              -- Bug26501 - 21/01/2014 - JTT: Informamos el PMT_NPOLIZA
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;

         IF riesgo.preguntas IS NULL THEN
            riesgo.preguntas := t_iax_preguntas();
         END IF;

         vpasexec := 110;
         -- BUG12384:DRA:02/02/2010:Fi
         riesgo.preguntas.EXTEND;
         riesgo.preguntas := preg;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_pregauto;

   /*************************************************************************
      Recarrega las garantias despues de tarificar
      param in/out riesgo    : objeto riesgo
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_garaftertarrie(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                := 'pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_GarAfterTarRie';
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      cgarant        NUMBER;
      nmovimi        NUMBER;
      cobliga        NUMBER;
      ctipgar        NUMBER;
      icapital       NUMBER;
      crevali        NUMBER;
      prevali        NUMBER;
      irevali        NUMBER;
      cfranq         NUMBER;
      ifranqu        NUMBER;
      finiefe        DATE;
      gar            t_iax_garantias;
      nwgar          NUMBER;
   BEGIN
      vpasexec := 1;

      IF pmode = 'SOL' THEN
         vtab := 'SOLGARANSEG';
      ELSIF pmode = 'EST' THEN
         vtab := 'ESTGARANSEG';
      ELSE
         vtab := 'GARANSEG';
      END IF;

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery :=
         'SELECT cgarant,nmovimi,cobliga,ctipgar,icapital,crevali,prevali,irevali,cfranq,ifranqu,finiefe '
         || ' FROM ' || vtab || ' WHERE SSEGURO=' || pssolicit || ' AND '
         || '       FFINEFE IS NULL AND ' ||   --// ACC 06032008 no s'ha de buscar per moviment '  NMOVIMI='|| pnmovimi ||' AND '||
                                            '       NRIESGO=' || riesgo.nriesgo;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 6;
      DBMS_SQL.define_column(curid, 1, cgarant);
      DBMS_SQL.define_column(curid, 2, nmovimi);
      DBMS_SQL.define_column(curid, 3, cobliga);
      DBMS_SQL.define_column(curid, 4, ctipgar);
      DBMS_SQL.define_column(curid, 5, icapital);
      DBMS_SQL.define_column(curid, 6, crevali);
      DBMS_SQL.define_column(curid, 7, prevali);
      DBMS_SQL.define_column(curid, 8, irevali);
      DBMS_SQL.define_column(curid, 9, cfranq);
      DBMS_SQL.define_column(curid, 10, ifranqu);
      DBMS_SQL.define_column(curid, 11, finiefe);
      vpasexec := 7;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cgarant);
         DBMS_SQL.COLUMN_VALUE(curid, 2, nmovimi);
         DBMS_SQL.COLUMN_VALUE(curid, 3, cobliga);
         DBMS_SQL.COLUMN_VALUE(curid, 4, ctipgar);
         DBMS_SQL.COLUMN_VALUE(curid, 5, icapital);
         DBMS_SQL.COLUMN_VALUE(curid, 6, crevali);
         DBMS_SQL.COLUMN_VALUE(curid, 7, prevali);
         DBMS_SQL.COLUMN_VALUE(curid, 8, irevali);
         DBMS_SQL.COLUMN_VALUE(curid, 9, cfranq);
         DBMS_SQL.COLUMN_VALUE(curid, 10, ifranqu);
         DBMS_SQL.COLUMN_VALUE(curid, 11, finiefe);
         nwgar := 1;
         vpasexec := 8;

         IF riesgo.garantias IS NOT NULL THEN
            IF riesgo.garantias.COUNT > 0 THEN
               FOR vgar IN riesgo.garantias.FIRST .. riesgo.garantias.LAST LOOP
                  IF riesgo.garantias.EXISTS(vgar) THEN
                     IF riesgo.garantias(vgar).cgarant = cgarant THEN
                        vpasexec := 9;
                        nwgar := 0;
                        riesgo.garantias(vgar).p_get_garaftertar(pssolicit, pnmovimi, pmode,
                                                                 riesgo.nriesgo);
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 10;

         IF nwgar = 1 THEN
            vpasexec := 11;

            -- BUG12384:DRA:02/02/2010:Inici
            IF riesgo.garantias IS NULL THEN
               riesgo.garantias := t_iax_garantias();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 12;
            riesgo.garantias.EXTEND;
            riesgo.garantias(riesgo.garantias.LAST) := ob_iax_garantias();
            riesgo.garantias(riesgo.garantias.LAST).cgarant := cgarant;
            riesgo.garantias(riesgo.garantias.LAST).p_get_garaftertar(pssolicit, pnmovimi,
                                                                      pmode, riesgo.nriesgo);
         END IF;
      END LOOP;

      vpasexec := 13;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_garaftertarrie;

   /*************************************************************************
      Recupera la descripción del riesgo según el tipo riesgo
      param in/out riesgo    : objeto riesgo
      param in     vcobjase  : código de objeto asegurado
   *************************************************************************/
   PROCEDURE p_descriesgo(
      riesgo IN OUT ob_iax_riesgos,
      pcobjase IN NUMBER,
      psseguro IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000) := 'pcobjase=' || pcobjase || ', psseguro=' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_DescRiesgo';
      verror         NUMBER;
      vidioma        NUMBER;
      vtexto         VARCHAR2(200);
      mensajes       t_iax_mensajes;
      wcagente       NUMBER;
   BEGIN
      IF pcobjase = 1 THEN   -- personal
         vpasexec := 9;

         IF riesgo.riespersonal IS NOT NULL THEN
            vpasexec := 10;

            IF riesgo.riespersonal.COUNT > 0 THEN
               vpasexec := 11;

               FOR vrper IN riesgo.riespersonal.FIRST .. riesgo.riespersonal.LAST LOOP
                  vpasexec := 11;

                  IF riesgo.riespersonal.EXISTS(vrper) THEN
                     vpasexec := 12;

                     IF pmode = 'EST' THEN
                        riesgo.triesgo :=
                                     TRIM(f_nombre_est(riesgo.riespersonal(vrper).sperson, 1));
                     ELSE
                        verror := pac_seguros.f_get_cagente(psseguro, 'REAL', wcagente);
                        riesgo.triesgo := TRIM(f_nombre(riesgo.riespersonal(vrper).sperson, 1,
                                                        wcagente));
                     END IF;

                     --XPLBug11559 26/10/2009
                     BEGIN
                        verror := TO_NUMBER(SUBSTR(riesgo.riespersonal(vrper).tnombre, 3));
                     EXCEPTION
                        WHEN OTHERS THEN
                           verror := 1;
                     END;

                     IF SUBSTR(riesgo.riespersonal(vrper).nnumide, 1, 2) = 'ZZ'
                        AND verror != 1 THEN
                        riesgo.triesgo := riesgo.riespersonal(vrper).tsexper || ' - '
                                          || TO_CHAR(riesgo.riespersonal(vrper).fnacimi,
                                                     'DD/MM/YYYY');
                     END IF;

                     vpasexec := 14;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      ELSIF pcobjase = 2 THEN   --domicilio
         vpasexec := 16;
         --JRB 14-07-08
         --riesgo.triesgo := riesgo.tnatrie;
         riesgo.triesgo := pac_md_obtenerdatos.f_desriesgos(pmode, psseguro, riesgo.nriesgo,
                                                            mensajes);

         -- Bug 16242. FAL. 07/10/2010. Recuperar desc. riesgo del objeto pq no está en las EST hasta tarificación
         IF riesgo.triesgo = '**' THEN
            riesgo.triesgo := riesgo.riesdireccion.tdomici;
         END IF;

         -- Fi Bug 16242. FAL. 07/10/2010
         vpasexec := 17;
      ELSIF pcobjase = 3
            OR pcobjase = 4 THEN   --descripción
         vpasexec := 24;
         --riesgo.triesgo := riesgo.tnatrie;

         /*riesgo.triesgo := pac_md_obtenerdatos.f_desriesgos(pmode, psseguro, riesgo.nriesgo,
                                                            mensajes);

         -- Bug 16242. FAL. 07/10/2010. Recuperar desc. riesgo del objeto pq no está en las EST hasta tarificación
         IF riesgo.triesgo = '**' THEN
            riesgo.triesgo := riesgo.tnatrie;
         END IF;

         -- Fi Bug 16242. FAL. 07/10/2010*/
         riesgo.tnatrie := riesgo.triesgo;
         vpasexec := 25;
      ELSIF pcobjase = 5 THEN   --automovil
         vpasexec := 27;

         IF riesgo.riesautos IS NOT NULL THEN
            vpasexec := 28;

            IF riesgo.riesautos.COUNT > 0 THEN
               vpasexec := 29;

               FOR vraut IN riesgo.riesautos.FIRST .. riesgo.riesautos.LAST LOOP
                  vpasexec := 30;

                  IF riesgo.riesautos.EXISTS(vraut) THEN
                     vpasexec := 31;
                     riesgo.riesautos(vraut).get_descripcion(psseguro, riesgo.nriesgo,
                                                             riesgo.triesgo, pmode);
                     vpasexec := 33;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_descriesgo;

   /*************************************************************************
      Concatena la dirección
      param in/out direccion : objeto dirección
      param out    odirec    : parametro de salida con la dirección concatenada
   *************************************************************************/
   PROCEDURE p_get_direccion(
      direccion IN OUT ob_iax_direcciones,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      odirec OUT VARCHAR2,
      pmode VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.Get_Direccion';
      dir            VARCHAR2(1000);
      errnum         NUMBER;
      vtpoblac       VARCHAR2(50);
      vtprovin       VARCHAR2(30);
      vcpais         NUMBER;
      vtpais         VARCHAR2(20);
   BEGIN
      vpasexec := 1;
      dir := direccion.tdomici;
      vpasexec := 2;

      IF NVL(direccion.tpoblac, '') = '' THEN
         errnum := f_despoblac(direccion.cpoblac, direccion.cprovin, vtpoblac);
         vpasexec := 3;

         IF errnum = 0 THEN
            direccion.tpoblac := vtpoblac;
         END IF;
      END IF;

      vpasexec := 4;

      IF direccion.cpostal = ''
         OR direccion.cpostal IS NULL THEN
         dir := dir || ' ' || direccion.tpoblac;
      ELSE
         dir := dir || ' ' || LPAD(TO_CHAR(direccion.cpostal), 5, '0') || ' '
                || direccion.tpoblac;
      END IF;

      vpasexec := 5;
      errnum := f_desprovin(direccion.cprovin, vtprovin, vcpais, vtpais);
      vpasexec := 6;

      IF errnum = 0 THEN
         direccion.tprovin := vtprovin;
         direccion.cpais := vcpais;
         direccion.tpais := vtpais;
      END IF;

      vpasexec := 7;

      IF LOWER(direccion.tprovin) <> LOWER(direccion.tpoblac) THEN
         dir := dir || ' ' || direccion.tprovin;
      END IF;

      vpasexec := 8;

      IF direccion.cpais <> NVL(f_parinstalacion_n('PAIS_DEF'), 0) THEN
         dir := dir || ' ' || direccion.tpais;
      END IF;

      vpasexec := 9;
      odirec := dir;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_direccion;

   /*************************************************************************
      Descripción automóbil
      param in/out autorie   : objeto automovil riesgo
      param out    odesc     : parametro de salida con la descripción del
                               riesgo
   *************************************************************************/
   PROCEDURE p_get_descripcionauto(
      autorie IN OUT ob_iax_autriesgos,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      odesc OUT VARCHAR2,
      pmode VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.Get_DescripcionAuto';
      vmarca         VARCHAR2(1000);
      vmodelo        VARCHAR2(1000);
-- Bug 0014888. FAL. 11/10/2010. Recuperar desc. riesgo (autriesgos.triesgo) en polizas de cargas Allianz Autos.
      err            NUMBER;
      ptriesgo1      VARCHAR2(1000);
      ptriesgo2      VARCHAR2(1000);
      ptriesgo3      VARCHAR2(1000);
      wcversion      VARCHAR2(11);
-- Fi Bug 0014888. FAL. 11/10/2010.
   BEGIN
      --Bug 9247 - APD -- 17/03/2009 - la descripcion de la marca y el modelo se obtienen de pac_autos
      vpasexec := 1;

      IF pmode = 'EST' THEN
         err := f_estdesriesgo(psseguro, pnriesgo, NULL, pac_md_common.f_get_cxtidioma,
                               ptriesgo1, ptriesgo2, ptriesgo3);
      ELSE
         err := f_desriesgo(psseguro, pnriesgo, NULL, pac_md_common.f_get_cxtidioma,
                            ptriesgo1, ptriesgo2, ptriesgo3);
      END IF;

      IF err = 0 THEN
         odesc := ptriesgo1;
      END IF;

      vpasexec := 2;

      IF odesc IS NULL THEN
         vmodelo := pac_autos.f_desmodelo(autorie.cmodelo, autorie.cmarca);
         vpasexec := 3;
         vmarca := pac_autos.f_desmarca(autorie.cmarca);
         --Bug 9247 - APD -- 17/03/2009 - Fin
         vpasexec := 4;
         odesc := autorie.cmatric || ' - ' || vmarca || ' - ' || vmodelo;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_descripcionauto;

   /*************************************************************************
      Preguntes automàtiques a nivell de garantia
      param in out priesgo   : objecte risc
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
   *************************************************************************/
   PROCEDURE p_get_pregautoriegar(
      priesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
              := 'pssolicit=' || pssolicit || ', pnmovimi=' || pnmovimi || ', pmode=' || pmode;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.P_Get_PregAutoRieGar';
      vgar           NUMBER;
   BEGIN
      FOR vgar IN priesgo.garantias.FIRST .. priesgo.garantias.LAST LOOP
         IF priesgo.garantias.EXISTS(vgar) THEN
            priesgo.garantias(vgar).p_get_pregautogar(pssolicit, pnmovimi, pmode,
                                                      priesgo.nriesgo);
         END IF;
      END LOOP;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_pregautoriegar;

   /*************************************************************************
      Preguntes automàtiques a nivell de garantia
      param in out pgaran    : objecte garantia
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
      param in     pnriesgo  : codi del risc
   *************************************************************************/
   PROCEDURE p_get_pregautogar(
      pgaran IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST',
      pnriesgo IN NUMBER) IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
         := 'pssolicit=' || pssolicit || ', pnmovimi=' || pnmovimi || ', pmode=' || pmode
            || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.P_Get_PregAutoGar';
      vtab           VARCHAR2(20);
      curid          INTEGER;
      squery         VARCHAR2(2000);
      dummy          INTEGER;
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      nmovima        NUMBER;
      finiefe        DATE;
      nova_pregunta  CHAR(2);
      pmovimi        NUMBER;
      pmovima        NUMBER;
      pfiniefe       DATE;

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      curid3         INTEGER;
      vtab3          VARCHAR2(50);
      squery3        VARCHAR2(2000);
      curid2         INTEGER;
      squery2        VARCHAR2(2000);
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      mensajes       t_iax_mensajes := t_iax_mensajes();
      preg           t_iax_preguntas;
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      cur            sys_refcursor;
      vcagente       NUMBER;
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         vtab := 'ESTPREGUNGARANSEG';
         vtab3 := 'ESTPREGUNGARANSEGTAB S';
      ELSE
         vtab := 'PREGUNGARANSEG';
         vtab3 := 'ESTPREGUNGARANSEGTAB S';
      END IF;

      SELECT sproduc, npoliza, cagente
        INTO vsproduc, vnpoliza, vcagente
        FROM (SELECT sproduc, npoliza, cagente
                FROM estseguros
               WHERE sseguro = pssolicit
                 AND pmode = 'EST'
              UNION ALL
              SELECT sproduc, npoliza, cagente
                FROM seguros
               WHERE sseguro = pssolicit
                 AND NVL(pmode, 'SEG') <> 'EST');

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery := 'SELECT CPREGUN,CRESPUE,TRESPUE,NMOVIMA,FINIEFE' || ' FROM ' || vtab || ' S'
                || ' WHERE S.SSEGURO=' || pssolicit || ' AND   S.NMOVIMI=' || pnmovimi
                || ' AND   S.NRIESGO=' || pnriesgo || ' AND   S.CGARANT=' || pgaran.cgarant;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 4;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 5;
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      DBMS_SQL.define_column(curid, 4, nmovima);
      DBMS_SQL.define_column(curid, 5, finiefe);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         vpasexec := 6;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         DBMS_SQL.COLUMN_VALUE(curid, 4, nmovima);
         DBMS_SQL.COLUMN_VALUE(curid, 5, finiefe);
         vpasexec := 7;
         nova_pregunta := 'SI';

         IF pgaran.preguntas IS NOT NULL THEN
            IF pgaran.preguntas.COUNT > 0 THEN
               FOR vprg IN pgaran.preguntas.FIRST .. pgaran.preguntas.LAST LOOP
                  IF pgaran.preguntas.EXISTS(vprg) THEN
                     IF pgaran.preguntas(vprg).cpregun = cpregun THEN
                        pgaran.preguntas(vprg).crespue := crespue;
                        pgaran.preguntas(vprg).trespue := trespue;
                        nova_pregunta := 'NO';
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 8;

         IF nova_pregunta = 'SI' THEN
            vpasexec := 81;

            -- BUG12384:DRA:02/02/2010:Inici
            IF pgaran.preguntas IS NULL THEN
               pgaran.preguntas := t_iax_preguntas();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 82;
            pgaran.preguntas.EXTEND;
            pgaran.preguntas(pgaran.preguntas.LAST) := ob_iax_preguntas();
            pgaran.preguntas(pgaran.preguntas.LAST).cpregun := cpregun;
            pgaran.preguntas(pgaran.preguntas.LAST).crespue := crespue;
            pgaran.preguntas(pgaran.preguntas.LAST).nmovima := nmovima;
            pgaran.preguntas(pgaran.preguntas.LAST).finiefe := finiefe;
         END IF;
      END LOOP;

      vpasexec := 9;
      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                || pssolicit || ' AND S.NRIESGO=' || pnriesgo || ' and cgarant='
                || pgaran.cgarant;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         preg(preg.LAST).finiefe := pfiniefe;
         preg(preg.LAST).nmovima := pmovima;
         preg(preg.LAST).nmovimi := pmovimi;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                    || pssolicit || ' AND   S.NMOVIMI=' || pnmovimi || ' AND S.NRIESGO='
                    || pnriesgo || ' AND S.CPREGUN = ' || cpregun || ' and cgarant='
                    || pgaran.cgarant;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := pmovimi;
            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('G', cpregun,
                                                                         pgaran.cgarant,
                                                                         mensajes);
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR' || ' FROM ' || vtab3
                       || ' WHERE S.SSEGURO=' || pssolicit || ' AND   S.NMOVIMI=' || pnmovimi
                       || ' AND S.NRIESGO=' || pnriesgo || ' AND S.CPREGUN = ' || cpregun
                       || ' AND s.nlinea = ' || nlinea || ' and cgarant=' || pgaran.cgarant;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              -- Bug26501 - 21/01/2014 - JTT: Informamos el PMT_NPOLIZA
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;

         IF pgaran.preguntas IS NULL THEN
            pgaran.preguntas := t_iax_preguntas();
         END IF;

         vpasexec := 110;
         -- BUG12384:DRA:02/02/2010:Fi
         pgaran.preguntas.EXTEND;
         pgaran.preguntas := preg;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_pregautogar;

   --ACC 171200208
    /*************************************************************************
       Recupera si es poden recuperar les primes a nivell de poliza
       param in   det_poliza : objecta de la pòlissa
       return 1 necesita tarificar i no recuperar primes
              0 recuperar primes
    *************************************************************************/
   FUNCTION f_get_needtarificarpol(det_poliza IN ob_iax_detpoliza)
      RETURN NUMBER IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80) := 'objecte poliza';
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.F_Get_NeedtarificarPol';
      retval         NUMBER(1) := 0;   -- No sha trobat indicador o no val 1
      rie            ob_iax_riesgos;
      gar            ob_iax_garantias;
   BEGIN
      vpasexec := 1;

      IF det_poliza IS NULL THEN
         RETURN 1;
      END IF;

      vpasexec := 2;

      IF det_poliza.primas IS NOT NULL THEN
         IF det_poliza.primas.COUNT > 0 THEN
            FOR vpri IN det_poliza.primas.FIRST .. det_poliza.primas.LAST LOOP
               IF det_poliza.primas.EXISTS(vpri) THEN
                  IF det_poliza.primas(vpri) IS NOT NULL THEN
                     IF det_poliza.primas(vpri).needtarifar = 1 THEN
                        RETURN 1;   -- ha de tarificar
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 3;

      IF det_poliza.riesgos IS NOT NULL THEN
         IF det_poliza.riesgos.COUNT > 0 THEN
            FOR vrie IN det_poliza.riesgos.FIRST .. det_poliza.riesgos.LAST LOOP
               IF det_poliza.riesgos.EXISTS(vrie) THEN
                  rie := det_poliza.riesgos(vrie);
                  vpasexec := 4;

                  IF rie.garantias IS NOT NULL THEN
                     IF rie.garantias.COUNT > 0 THEN
                        FOR vgar IN rie.garantias.FIRST .. rie.garantias.LAST LOOP
                           IF rie.garantias.EXISTS(vgar) THEN
                              gar := rie.garantias(vgar);

                              IF gar.primas IS NOT NULL THEN
                                 IF gar.primas.needtarifar = 1 THEN
                                    RETURN 1;   -- ha de tarificar
                                 END IF;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      vpasexec := 5;
      RETURN retval;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END f_get_needtarificarpol;

--ACC 17122008

   --bug 7535 ACC 17022009
   /*************************************************************************
      Comprova si tots el riscos estan tarificats i si ho estan deixa el
      indicador de pòlissa con a tarficat o bé com a no tarificat
      param in out     det_poliza : objecte de la pòlissa
   *************************************************************************/
   PROCEDURE p_check_needtarificarpol(det_poliza IN OUT ob_iax_detpoliza) AS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80) := 'objecte poliza';
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.P_Check_NeedtarificarPol';
      retval         NUMBER(1) := 0;   -- No sha trobat indicador o no val 1
      rie            ob_iax_riesgos;
      gar            ob_iax_garantias;
   BEGIN
      vpasexec := 1;

      IF det_poliza IS NOT NULL THEN
         IF det_poliza.riesgos IS NOT NULL THEN
            IF det_poliza.riesgos.COUNT > 0 THEN
               FOR vrie IN det_poliza.riesgos.FIRST .. det_poliza.riesgos.LAST LOOP
                  IF det_poliza.riesgos.EXISTS(vrie) THEN
                     rie := det_poliza.riesgos(vrie);
                     vpasexec := 2;

                     IF rie.garantias IS NOT NULL THEN
                        IF rie.garantias.COUNT > 0 THEN
                           FOR vgar IN rie.garantias.FIRST .. rie.garantias.LAST LOOP
                              IF rie.garantias.EXISTS(vgar) THEN
                                 gar := rie.garantias(vgar);
                                 vpasexec := 3;

                                 IF gar.primas IS NOT NULL THEN
                                    IF gar.primas.needtarifar = 1 THEN
                                       retval := 1;   -- ha de tarificar
                                       EXIT;
                                    END IF;
                                 END IF;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 4;
         det_poliza.p_set_needtarpol(retval);
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_check_needtarificarpol;

   --bug 7535 ACC 17022009

   -- BUG9263:DRA:11/05/2009:Inici
   /*************************************************************************
      Recupera las preguntas de póliza automaticas
      param in/out detpoliza : objeto detalle póliza
      param in     pssolicit : código solicitud
      param in     pnmovimi  : número movimiento
      param in     pmode     : modo SOL EST POL
   *************************************************************************/
   PROCEDURE p_get_pregautopol(
      detpoliza IN OUT ob_iax_detpoliza,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2) AS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                := 'pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_PregAutoPol';
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      cpregun        NUMBER;
      crespue        FLOAT;
      trespue        VARCHAR2(2000);
      preg           t_iax_preguntas;
      pregtab        t_iax_preguntastab := t_iax_preguntastab();
      pregtab_col    t_iax_preguntastab_columns := t_iax_preguntastab_columns();
      nwprg          NUMBER;

      CURSOR c_lista(cprg NUMBER, colum VARCHAR2) IS
         SELECT   pcd.clista, tlista
             FROM preguntab_colum_lista pcl, preguntab_colum_deslista pcd
            WHERE pcl.cpregun = cprg
              AND pcd.cpregun = pcl.cpregun
              AND pcl.ccolumn = colum
              AND pcl.ccolumn = pcd.columna
              AND pcd.cidioma = pac_md_common.f_get_cxtidioma
              AND pcl.clista = pcd.clista
         ORDER BY pcd.clista;

      vconsulta      VARCHAR2(4000);
      cur            sys_refcursor;
      catribu        NUMBER;
      tatribu        VARCHAR2(1000);
      vsproduc       NUMBER;
      vnpoliza       NUMBER;
      curid3         INTEGER;
      vtab3          VARCHAR2(50);
      squery3        VARCHAR2(2000);
      curid2         INTEGER;
      squery2        VARCHAR2(2000);
      ccolumna       VARCHAR2(50);
      nlinea         NUMBER;
      tvalor         VARCHAR2(250);
      fvalor         DATE;
      nvalor         NUMBER;
      vcagente       NUMBER;
      mensajes       t_iax_mensajes := t_iax_mensajes();
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         vtab := 'ESTPREGUNPOLSEG';
         vtab3 := 'ESTPREGUNPOLSEGTAB S';
      ELSE
         vtab := 'PREGUNPOLSEG';
         vtab3 := 'PREGUNPOLSEGTAB S';
      END IF;

      SELECT sproduc, npoliza, cagente
        INTO vsproduc, vnpoliza, vcagente
        FROM (SELECT sproduc, npoliza, cagente
                FROM estseguros
               WHERE sseguro = pssolicit
                 AND pmode = 'EST'
              UNION ALL
              SELECT sproduc, npoliza, cagente
                FROM seguros
               WHERE sseguro = pssolicit
                 AND NVL(pmode, 'SEG') <> 'EST');

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery := 'SELECT CPREGUN,CRESPUE,TRESPUE ' || ' FROM ' || vtab || ' S '
                || ' WHERE S.SSEGURO=' || pssolicit || ' AND S.NMOVIMI=' || pnmovimi;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 6;
      DBMS_SQL.define_column(curid, 1, cpregun);
      DBMS_SQL.define_column(curid, 2, crespue);
      DBMS_SQL.define_column(curid, 3, trespue, 2000);
      vpasexec := 7;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         DBMS_SQL.COLUMN_VALUE(curid, 2, crespue);
         DBMS_SQL.COLUMN_VALUE(curid, 3, trespue);
         nwprg := 1;
         vpasexec := 8;

         IF detpoliza.preguntas IS NOT NULL THEN
            IF detpoliza.preguntas.COUNT > 0 THEN
               FOR vprg IN detpoliza.preguntas.FIRST .. detpoliza.preguntas.LAST LOOP
                  IF detpoliza.preguntas.EXISTS(vprg) THEN
                     IF detpoliza.preguntas(vprg).cpregun = cpregun THEN
                        vpasexec := 9;
                        detpoliza.preguntas(vprg).crespue := crespue;
                        detpoliza.preguntas(vprg).trespue := trespue;
                        nwprg := 0;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 10;

         IF nwprg = 1 THEN
            vpasexec := 11;

            -- BUG12384:DRA:02/02/2010:Inici
            IF detpoliza.preguntas IS NULL THEN
               detpoliza.preguntas := t_iax_preguntas();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 12;
            detpoliza.preguntas.EXTEND;
            detpoliza.preguntas(detpoliza.preguntas.LAST) := ob_iax_preguntas();
            detpoliza.preguntas(detpoliza.preguntas.LAST).cpregun := cpregun;
            detpoliza.preguntas(detpoliza.preguntas.LAST).crespue := crespue;
            detpoliza.preguntas(detpoliza.preguntas.LAST).trespue := trespue;
         END IF;
      END LOOP;

      vpasexec := 13;
      DBMS_SQL.close_cursor(curid);
      curid := DBMS_SQL.open_cursor;
      curid2 := DBMS_SQL.open_cursor;
      curid3 := DBMS_SQL.open_cursor;
      squery := 'SELECT distinct(cpregun)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                || pssolicit || ' AND S.NMOVIMI=' || pnmovimi;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, cpregun);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, cpregun);
         preg.EXTEND;
         preg(preg.LAST) := ob_iax_preguntas();
         preg(preg.LAST).cpregun := cpregun;
         preg(preg.LAST).crespue := NULL;
         preg(preg.LAST).trespue := NULL;
         squery2 := 'SELECT distinct(NLINEA)' || ' FROM ' || vtab3 || ' WHERE S.SSEGURO='
                    || pssolicit || ' AND S.NMOVIMI=' || pnmovimi || ' AND S.CPREGUN = '
                    || cpregun;
         DBMS_SQL.parse(curid2, squery2, DBMS_SQL.v7);
         dummy := DBMS_SQL.EXECUTE(curid2);
         DBMS_SQL.define_column(curid2, 1, nlinea);

         LOOP
            EXIT WHEN DBMS_SQL.fetch_rows(curid2) = 0;
            DBMS_SQL.COLUMN_VALUE(curid2, 1, nlinea);
            pregtab.EXTEND;
            pregtab(pregtab.LAST) := ob_iax_preguntastab();
            pregtab(pregtab.LAST).cpregun := cpregun;
            pregtab(pregtab.LAST).nlinea := nlinea;
            pregtab(pregtab.LAST).nmovimi := pnmovimi;
            pregtab_col := pac_iaxpar_productos.f_get_cabecera_preguntab('P', cpregun, NULL,
                                                                         mensajes);
            squery3 := 'SELECT CCOLUMNA,TVALOR,FVALOR, NVALOR' || ' FROM ' || vtab3
                       || ' WHERE S.SSEGURO=' || pssolicit || ' AND S.NMOVIMI=' || pnmovimi
                       || ' AND S.CPREGUN = ' || cpregun || ' AND s.nlinea = ' || nlinea;
            DBMS_SQL.parse(curid3, squery3, DBMS_SQL.v7);
            dummy := DBMS_SQL.EXECUTE(curid3);
            DBMS_SQL.define_column(curid3, 1, ccolumna, 50);
            DBMS_SQL.define_column(curid3, 2, tvalor, 250);
            DBMS_SQL.define_column(curid3, 3, fvalor);
            DBMS_SQL.define_column(curid3, 4, nvalor);

            LOOP
               EXIT WHEN DBMS_SQL.fetch_rows(curid3) = 0;
               DBMS_SQL.COLUMN_VALUE(curid3, 1, ccolumna);
               DBMS_SQL.COLUMN_VALUE(curid3, 2, tvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 3, fvalor);
               DBMS_SQL.COLUMN_VALUE(curid3, 4, nvalor);

               IF pregtab_col IS NOT NULL THEN
                  IF pregtab_col.COUNT <> 0 THEN
                     FOR k IN pregtab_col.FIRST .. pregtab_col.LAST LOOP
                        IF pregtab_col(k).ccolumna = ccolumna THEN
                           pregtab_col(k).ccolumna := ccolumna;
                           pregtab_col(k).tvalor := tvalor;
                           pregtab_col(k).fvalor := fvalor;
                           pregtab_col(k).nvalor := nvalor;

                           IF pregtab_col(k).ctipcol = 4 THEN
                              FOR rsp IN c_lista(cpregun, pregtab_col(k).ccolumna) LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                     rsp.clista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                     rsp.tlista;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;
                              END LOOP;
                           ELSIF pregtab_col(k).ctipcol = 5 THEN
                              vconsulta := REPLACE(pregtab_col(k).tconsulta, ':PMT_IDIOMA',
                                                   pac_md_common.f_get_cxtidioma);
                              vconsulta := REPLACE(vconsulta, ':PMT_SPRODUC', vsproduc || ' ');
                              -- Bug26501 - 21/01/2014 - JTT: Informamos el PMT_NPOLIZA
                              vconsulta := REPLACE(vconsulta, ':PMT_NPOLIZA', vnpoliza || ' ');
                              vconsulta := REPLACE(vconsulta, ':PMT_CAGENTE', vcagente || ' ');
                              vpasexec := 14;
                              cur := pac_md_listvalores.f_opencursor(vconsulta, mensajes);
                              vpasexec := 15;

                              FETCH cur
                               INTO catribu, tatribu;

                              vpasexec := 16;

                              WHILE cur%FOUND LOOP
                                 IF pregtab_col(k).tlista IS NULL THEN
                                    pregtab_col(k).tlista := t_iax_preglistatab();
                                 END IF;

                                 pregtab_col(k).tlista.EXTEND;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST) :=
                                                                          ob_iax_preglistatab
                                                                                             ();
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).cpregun :=
                                                                                        cpregun;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).clista :=
                                                                                        catribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).tlista :=
                                                                                        tatribu;
                                 pregtab_col(k).tlista(pregtab_col(k).tlista.LAST).columna :=
                                                                        pregtab_col(k).ccolumna;

                                 FETCH cur
                                  INTO catribu, tatribu;

                                 vpasexec := 20;
                              END LOOP;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;

            pregtab(pregtab.LAST).tcolumnas := pregtab_col;
         END LOOP;

         preg(preg.LAST).tpreguntastab := pregtab;

         IF detpoliza.preguntas IS NULL THEN
            detpoliza.preguntas := t_iax_preguntas();
         END IF;

         vpasexec := 110;
         -- BUG12384:DRA:02/02/2010:Fi
         detpoliza.preguntas.EXTEND;
         detpoliza.preguntas := preg;
      END LOOP;

      DBMS_SQL.close_cursor(curid);
      DBMS_SQL.close_cursor(curid2);
      DBMS_SQL.close_cursor(curid3);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_pregautopol;

-- BUG9263:DRA:11/05/2009:Fi

   -- ini Bug 0010908 - 17/12/2009 - JMF
   /*************************************************************************
      Prestams a nivell de pòlissa
      param in out pprestamoseg : objecte prestams
      param in     psseguro     : sseguro de la pòlissa
      param in     pnmovimi     : nmovimi de la pòlissa
      param in     pnriesgo     : codi del risc
      param in     ptablas      : el valor de com recuperar les dades (EST)
   *************************************************************************/
   PROCEDURE p_get_prestamoseg(
      pprestamoseg IN OUT t_iax_prestamoseg,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
          := 's=' || psseguro || ', n=' || pnmovimi || ', r=' || pnriesgo || ', t=' || ptablas;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.p_get_prestamoseg';
      vtab           VARCHAR2(30);
      curid          INTEGER;
      squery         VARCHAR2(2000);
      dummy          INTEGER;
      v_ctapres      seguros.cbancar%TYPE;   -- 7.0 21-10-2011 JGR - 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      v_finiprest    DATE;
      v_ffinprest    DATE;
      v_pporcen      NUMBER(5, 2);
      v_ctipcuenta   NUMBER(4);   -- BUG12421:DRA:27/01/2010
      v_ctipban      seguros.ctipban%TYPE;   -- 7.0 21-10-2011 JGR - 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      v_ctipimp      NUMBER(3);
      v_isaldo       NUMBER(15, 2);
      v_porcen       NUMBER(5, 2);
      v_ilimite      NUMBER(15, 2);
      v_icapmax      NUMBER(15, 2);
      v_icapital     NUMBER(15, 2);
      v_cmoneda      VARCHAR2(10);
      v_icapaseg     NUMBER(15, 2);
      v_falta        DATE;
      b_nova         BOOLEAN;
      v_descripcion  VARCHAR2(2000);
   BEGIN
      vtab := 'ESTPRESTAMOSEG';
      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery :=
         'SELECT CTAPRES, FINIPREST, FFINPREST, PPORCEN, CTIPCUENTA, CTIPBAN, CTIPIMP,'
         || ' ISALDO, PORCEN, ILIMITE, ICAPMAX, ICAPITAL, CMONEDA, ICAPASEG, FALTA, DESCRIPCION '
         || ' FROM ' || vtab || ' S' || ' WHERE S.SSEGURO=' || psseguro || ' AND S.NMOVIMI='
         || pnmovimi || ' AND   S.NRIESGO=' || pnriesgo;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 4;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 5;
      DBMS_SQL.define_column(curid, 1, v_ctapres, 34);
      DBMS_SQL.define_column(curid, 2, v_finiprest);
      DBMS_SQL.define_column(curid, 3, v_ffinprest);
      DBMS_SQL.define_column(curid, 4, v_pporcen);
      DBMS_SQL.define_column(curid, 5, v_ctipcuenta);
      DBMS_SQL.define_column(curid, 6, v_ctipban);
      DBMS_SQL.define_column(curid, 7, v_ctipimp);
      DBMS_SQL.define_column(curid, 8, v_isaldo);
      DBMS_SQL.define_column(curid, 9, v_porcen);
      DBMS_SQL.define_column(curid, 10, v_ilimite);
      DBMS_SQL.define_column(curid, 11, v_icapmax);
      DBMS_SQL.define_column(curid, 12, v_icapital);
      DBMS_SQL.define_column(curid, 13, v_cmoneda, 10);
      DBMS_SQL.define_column(curid, 14, v_icapaseg);
      DBMS_SQL.define_column(curid, 15, v_falta);
      DBMS_SQL.define_column(curid, 16, v_descripcion, 2000);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         vpasexec := 6;
         DBMS_SQL.COLUMN_VALUE(curid, 1, v_ctapres);
         DBMS_SQL.COLUMN_VALUE(curid, 2, v_finiprest);
         DBMS_SQL.COLUMN_VALUE(curid, 3, v_ffinprest);
         DBMS_SQL.COLUMN_VALUE(curid, 4, v_pporcen);
         DBMS_SQL.COLUMN_VALUE(curid, 5, v_ctipcuenta);
         DBMS_SQL.COLUMN_VALUE(curid, 6, v_ctipban);
         DBMS_SQL.COLUMN_VALUE(curid, 7, v_ctipimp);
         DBMS_SQL.COLUMN_VALUE(curid, 8, v_isaldo);
         DBMS_SQL.COLUMN_VALUE(curid, 9, v_porcen);
         DBMS_SQL.COLUMN_VALUE(curid, 10, v_ilimite);
         DBMS_SQL.COLUMN_VALUE(curid, 11, v_icapmax);
         DBMS_SQL.COLUMN_VALUE(curid, 12, v_icapital);
         DBMS_SQL.COLUMN_VALUE(curid, 13, v_cmoneda);
         DBMS_SQL.COLUMN_VALUE(curid, 14, v_icapaseg);
         DBMS_SQL.COLUMN_VALUE(curid, 15, v_falta);
         DBMS_SQL.COLUMN_VALUE(curid, 16, v_descripcion);
         vpasexec := 7;
         b_nova := TRUE;

         IF pprestamoseg IS NOT NULL THEN
            IF pprestamoseg.COUNT > 0 THEN
               FOR vprg IN pprestamoseg.FIRST .. pprestamoseg.LAST LOOP
                  IF pprestamoseg.EXISTS(vprg) THEN
                     IF pprestamoseg(vprg).idcuenta = v_ctapres THEN
                        pprestamoseg(vprg).idcuenta := v_ctapres;
                        pprestamoseg(vprg).sseguro := psseguro;
                        pprestamoseg(vprg).nmovimi := pnmovimi;
                        pprestamoseg(vprg).ctipcuenta := v_ctipcuenta;
                        pprestamoseg(vprg).ctipban := v_ctipban;
                        pprestamoseg(vprg).ctipimp := v_ctipimp;
                        pprestamoseg(vprg).isaldo := v_isaldo;
                        pprestamoseg(vprg).porcen := v_porcen;
                        pprestamoseg(vprg).icapital := v_icapital;
                        pprestamoseg(vprg).icapmax := v_icapmax;
                        pprestamoseg(vprg).cmoneda := v_cmoneda;
                        pprestamoseg(vprg).icapaseg := v_icapaseg;
                        pprestamoseg(vprg).finiprest := v_finiprest;
                        pprestamoseg(vprg).ffinprest := v_ffinprest;
                        pprestamoseg(vprg).pporcen := v_pporcen;
                        pprestamoseg(vprg).ilimite := v_ilimite;
                        pprestamoseg(vprg).falta := v_falta;
                        pprestamoseg(vprg).descripcion := v_descripcion;
                        -- 12384 - JLB - Se actualiza el seleccionado, para que se baje el prestamoa a base de datos, si se ha insertado directamente en las EST (caso ULK)
                        pprestamoseg(vprg).selsaldo := 1;
                        p_get_prestcuadroseg(psseguro, pnmovimi, v_ctapres,
                                             pprestamoseg(vprg).cuadro);   --  Bug 13884: xpl
                        b_nova := FALSE;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 8;

         IF b_nova THEN
            vpasexec := 81;

            -- BUG12384:DRA:02/02/2010:Inici
            IF pprestamoseg IS NULL THEN
               pprestamoseg := t_iax_prestamoseg();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 82;
            pprestamoseg.EXTEND;
            pprestamoseg(pprestamoseg.LAST) := ob_iax_prestamoseg();
            pprestamoseg(pprestamoseg.LAST).idcuenta := v_ctapres;
            pprestamoseg(pprestamoseg.LAST).sseguro := psseguro;
            pprestamoseg(pprestamoseg.LAST).nmovimi := pnmovimi;
            pprestamoseg(pprestamoseg.LAST).finiprest := v_finiprest;
            pprestamoseg(pprestamoseg.LAST).ffinprest := v_ffinprest;
            pprestamoseg(pprestamoseg.LAST).pporcen := v_pporcen;
            pprestamoseg(pprestamoseg.LAST).ctipcuenta := v_ctipcuenta;
            pprestamoseg(pprestamoseg.LAST).ctipban := v_ctipban;
            pprestamoseg(pprestamoseg.LAST).ctipimp := v_ctipimp;
            pprestamoseg(pprestamoseg.LAST).isaldo := v_isaldo;
            pprestamoseg(pprestamoseg.LAST).porcen := v_porcen;
            pprestamoseg(pprestamoseg.LAST).ilimite := v_ilimite;
            pprestamoseg(pprestamoseg.LAST).icapmax := v_icapmax;
            pprestamoseg(pprestamoseg.LAST).icapital := v_icapital;
            pprestamoseg(pprestamoseg.LAST).cmoneda := v_cmoneda;
            pprestamoseg(pprestamoseg.LAST).icapaseg := v_icapaseg;
            pprestamoseg(pprestamoseg.LAST).falta := v_falta;
            pprestamoseg(pprestamoseg.LAST).descripcion := v_descripcion;
            -- 12384 - JLB - Se actualiza el seleccionado, para que se baje el prestamoa a base de datos, si se ha insertado directamente en las EST (caso ULK)
            pprestamoseg(pprestamoseg.LAST).selsaldo := 1;
            p_get_prestcuadroseg(psseguro, pnmovimi, v_ctapres,
                                 pprestamoseg(pprestamoseg.LAST).cuadro);   --  Bug 13884: xpl
         END IF;
      END LOOP;

      vpasexec := 9;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_prestamoseg;

   -- fin Bug 0010908 - 17/12/2009 - JMF
   -- ini Bug 0010908 - 17/12/2009 - JMF
    /*************************************************************************
       Prestams a nivell de pòlissa
       param in out pprestamoseg : objecte prestams
       param in     psseguro     : sseguro de la pòlissa
       param in     pnmovimi     : nmovimi de la pòlissa
       param in     ctapres     : codi del prestec
       param in     ptablas      : el valor de com recuperar les dades (EST)
    *************************************************************************/
   PROCEDURE p_get_prestcuadroseg(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pctapres IN VARCHAR2,
      pprestcuadroseg IN OUT t_iax_prestcuadroseg,
      ptablas IN VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
         := 's=' || psseguro || ', n=' || pnmovimi || ', t=' || ptablas || ', ctapres= '
            || pctapres;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.p_get_prestcuadroseg';
      vtab           VARCHAR2(30);
      curid          INTEGER;
      squery         VARCHAR2(2000);
      dummy          INTEGER;
      v_ctapres      seguros.cbancar%TYPE;   -- 7.0 21-10-2011 JGR - 0018944: LCOL_P001 - PER - Tarjetas (nota 0095276) en desarrollo AXIS3181
      v_finicuaseg   DATE;
      v_ffincuaseg   DATE;
      v_fefecto      DATE;
      v_fvencim      DATE;
      v_isaldo       NUMBER(15, 2);
      v_iinteres     NUMBER(5, 2);
      v_icappend     NUMBER(15, 2);
      v_icapital     NUMBER(15, 2);
      v_falta        DATE;
      b_nova         BOOLEAN;
   BEGIN
      IF ptablas = 'EST' THEN
         vtab := 'ESTPRESTCUADROSEG';
      ELSE
         vtab := 'PRESTCUADROSEG';
      END IF;

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery := 'SELECT FINICUASEG, FFINCUASEG, FEFECTO,'
                || ' FVENCIM, ICAPITAL, IINTERES, ICAPPEND, FALTA' || ' FROM ' || vtab || ' S'
                || ' WHERE S.SSEGURO=' || psseguro || ' AND S.NMOVIMI=' || pnmovimi
                || ' AND   S.CTAPRES=' || CHR(39) || pctapres || CHR(39);
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 4;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 5;
      DBMS_SQL.define_column(curid, 1, v_finicuaseg);
      DBMS_SQL.define_column(curid, 2, v_ffincuaseg);
      DBMS_SQL.define_column(curid, 3, v_fefecto);
      DBMS_SQL.define_column(curid, 4, v_fvencim);
      DBMS_SQL.define_column(curid, 5, v_icapital);
      DBMS_SQL.define_column(curid, 6, v_iinteres);
      DBMS_SQL.define_column(curid, 7, v_icappend);
      DBMS_SQL.define_column(curid, 8, v_falta);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         vpasexec := 6;
         DBMS_SQL.COLUMN_VALUE(curid, 1, v_finicuaseg);
         DBMS_SQL.COLUMN_VALUE(curid, 2, v_ffincuaseg);
         DBMS_SQL.COLUMN_VALUE(curid, 3, v_fefecto);
         DBMS_SQL.COLUMN_VALUE(curid, 4, v_fvencim);
         DBMS_SQL.COLUMN_VALUE(curid, 5, v_icapital);
         DBMS_SQL.COLUMN_VALUE(curid, 6, v_iinteres);
         DBMS_SQL.COLUMN_VALUE(curid, 7, v_icappend);
         DBMS_SQL.COLUMN_VALUE(curid, 8, v_falta);
         vpasexec := 7;
         b_nova := TRUE;

         IF pprestcuadroseg IS NOT NULL THEN
            IF pprestcuadroseg.COUNT > 0 THEN
               FOR vprg IN pprestcuadroseg.FIRST .. pprestcuadroseg.LAST LOOP
                  IF pprestcuadroseg.EXISTS(vprg) THEN
                     IF pprestcuadroseg(vprg).ctapres = pctapres
                        AND pprestcuadroseg(vprg).sseguro = psseguro
                        AND pprestcuadroseg(vprg).nmovimi = pnmovimi
                        AND pprestcuadroseg(vprg).fefecto = v_fefecto THEN
                        pprestcuadroseg(vprg).ctapres := pctapres;
                        pprestcuadroseg(vprg).sseguro := psseguro;
                        pprestcuadroseg(vprg).nmovimi := pnmovimi;
                        pprestcuadroseg(vprg).finicuaseg := v_finicuaseg;
                        pprestcuadroseg(vprg).ffincuaseg := v_ffincuaseg;
                        pprestcuadroseg(vprg).fefecto := v_fefecto;
                        pprestcuadroseg(vprg).fvencim := v_fvencim;
                        pprestcuadroseg(vprg).iinteres := v_iinteres;
                        pprestcuadroseg(vprg).icappend := v_icappend;
                        pprestcuadroseg(vprg).icapital := v_icapital;
                        pprestcuadroseg(vprg).icuota := NVL(v_icapital, 0)
                                                        + NVL(v_iinteres, 0);
                        pprestcuadroseg(vprg).falta := v_falta;
                        b_nova := FALSE;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 8;

         IF b_nova THEN
            vpasexec := 81;

            -- BUG12384:DRA:02/02/2010:Inici
            IF pprestcuadroseg IS NULL THEN
               pprestcuadroseg := t_iax_prestcuadroseg();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 82;
            pprestcuadroseg.EXTEND;
            pprestcuadroseg(pprestcuadroseg.LAST) := ob_iax_prestcuadroseg();
            pprestcuadroseg(pprestcuadroseg.LAST).ctapres := pctapres;
            pprestcuadroseg(pprestcuadroseg.LAST).sseguro := psseguro;
            pprestcuadroseg(pprestcuadroseg.LAST).nmovimi := pnmovimi;
            pprestcuadroseg(pprestcuadroseg.LAST).finicuaseg := v_finicuaseg;
            pprestcuadroseg(pprestcuadroseg.LAST).ffincuaseg := v_ffincuaseg;
            pprestcuadroseg(pprestcuadroseg.LAST).fefecto := v_fefecto;
            pprestcuadroseg(pprestcuadroseg.LAST).fvencim := v_fvencim;
            pprestcuadroseg(pprestcuadroseg.LAST).iinteres := v_iinteres;
            pprestcuadroseg(pprestcuadroseg.LAST).icappend := v_icappend;
            pprestcuadroseg(pprestcuadroseg.LAST).iinteres := v_iinteres;
            pprestcuadroseg(pprestcuadroseg.LAST).icapital := v_icapital;
            pprestcuadroseg(pprestcuadroseg.LAST).icuota :=
                                                         NVL(v_icapital, 0)
                                                         + NVL(v_iinteres, 0);
            pprestcuadroseg(pprestcuadroseg.LAST).falta := v_falta;
         END IF;
      END LOOP;

      vpasexec := 9;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   END p_get_prestcuadroseg;

   -- ini Bug 0010908 - 17/12/2009 - JMF
   /*************************************************************************
      Tablas generadas por preguntas automáticas
      param in out priesgo      : objecte risc
      param in     psseguro     : sseguro de la pòlissa
      param in     pnmovimi     : nmovimi de la pòlissa
      param in     ptablas      : el valor de com recuperar les dades (EST)
   *************************************************************************/
   PROCEDURE p_get_tablaspregauto(
      priesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST') IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
                                 := 's=' || pssolicit || ', n=' || pnmovimi || ', m=' || pmode;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.p_get_tablaspregauto';
      vsproduc       seguros.sproduc%TYPE;
   BEGIN
      vpasexec := 1;

      IF pmode = 'SOL' THEN
         vpasexec := 2;

         SELECT sproduc
           INTO vsproduc
           FROM solseguros
          WHERE sseguro = pssolicit;
      ELSIF pmode = 'EST' THEN
         vpasexec := 3;

         SELECT sproduc
           INTO vsproduc
           FROM estseguros
          WHERE sseguro = pssolicit;
      ELSE
         vpasexec := 4;

         SELECT sproduc
           INTO vsproduc
           FROM seguros
          WHERE sseguro = pssolicit;
      END IF;

      vpasexec := 5;

      IF NVL(f_parproductos_v(vsproduc, 'TABPREAUT_PRESTAMOS'), 0) = 1 THEN
         vpasexec := 6;
         pac_mdobj_prod.p_get_prestamoseg(priesgo.prestamo, pssolicit, pnmovimi,
                                          priesgo.nriesgo, pmode);
      END IF;

      vpasexec := 7;
   EXCEPTION
      WHEN OTHERS THEN
         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_tablaspregauto;

-- fin Bug 0010908 - 17/12/2009 - JMF

   /***********************************************************************
      Càlculo del importe del impuesto segun la forma de pago si se debe fraccionar el importe
      param in psseguro    : código del seguro
      param in pmode       : modo
      param in pcconcep    : código del concepto que se desea calcular (VF 27)
      param in pcrecfra    : indica si existe recargo por fraccionamiento o no
      param in pcgarant    : código de la garantia
      param in piprianu    : prima anual
      param in piconcep   : importe del concepto
      return               : importe del concepto dividido entre la forma de pago si aplica (segun imprec.cfracci)
   ***********************************************************************/
   -- Bug 20448 - APD - 19/12/2011 - se crea la funcion
   /* BUG 24657 - 29/12/2012  - HPM - SUPLEMENTOS,  SE MODIFICA LA FUNCION PARA QUE DEVUELVA LA FORMA
   DE PAGO QUE CORRESPONDA EN CASO DE QUE EL IMPUESTO DEBA SER FRANCCIONADO*/
   FUNCTION f_importe_impuesto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2,
      pcconcep IN NUMBER,
      pcrecfra IN NUMBER,
      pcgarant IN NUMBER,
      piprianu IN NUMBER,
      pidtocom IN NUMBER,
      piconcep IN NUMBER)
      RETURN NUMBER IS
      e_object_error EXCEPTION;
      e_param_error  EXCEPTION;
      salir          EXCEPTION;
      vobjectname    tab_error.tdescrip%TYPE;
      vparam         tab_error.tdescrip%TYPE;
      vpasexec       NUMBER(8);
      vnumerr        NUMBER(8);
      vfefecto       seguros.fefecto%TYPE;
      vfcaranu       seguros.fcaranu%TYPE;
      vsproduc       seguros.sproduc%TYPE;
      vcactivi       seguros.cactivi%TYPE;
      vcforpag       seguros.cforpag%TYPE;
      viconcep       NUMBER;
      xcramo         productos.cramo%TYPE;
      xcmodali       productos.cmodali%TYPE;
      xctipseg       productos.ctipseg%TYPE;
      xccolect       productos.ccolect%TYPE;
      xcprorra       productos.cprorra%TYPE;
      xcrevfpg       productos.crevfpg%TYPE;
      xcforpag       seguros.cforpag%TYPE;
      vcempres       NUMBER;
      vnvalcon       NUMBER;
      vctipcon       NUMBER;
      vcfracci       NUMBER;
      vcbonifi       NUMBER;
      vcrecfra       NUMBER;
      w_climit       NUMBER;
      v_cmonimp      imprec.cmoneda%TYPE;   -- BUG 18423: LCOL000 - Multimoneda
      vcderreg       NUMBER;   -- Bug 0020314 - FAL - 29/11/2011
      -- indicador de si aplicamos CLEA al recargo por fraccionamiento
      xcimpclea      NUMBER;
      -- indicador de si la garantía calcula DGS (CLEA)
      xcimpips       NUMBER;   -- indicador de si la garantía calcula IPS
      xcderreg       NUMBER;
      -- indicador de si la garantía calcula DER. REG.
      xcimparb       NUMBER;
      -- indicador de si la garantía calcula ARBITRIOS
      xcimpfng       NUMBER;   -- indicador de si la garantía calcula FNG
      xcimpcons      NUMBER;
   -- indicador de si la garantía calcula CONSORCIO
   BEGIN
      vobjectname := 'pac_mdobj_prod.f_importe_impuesto';
      vparam := 'parámetros - psseguro: ' || psseguro || ' - pmode: ' || pmode || ' cconcep: '
                || pcconcep || ' - pcrecfra: ' || pcrecfra || ' - pcgarant: ' || pcgarant
                || ' - piprianu: ' || piprianu || ' - pidtocom: ' || pidtocom
                || ' - piconcep: ' || piconcep;
      vnumerr := 0;
      vpasexec := 1;

      --Comprovació dels parámetres d'entrada
      IF psseguro IS NULL
         OR pmode IS NULL
         OR pcconcep IS NULL
         OR pcrecfra IS NULL
         OR pcgarant IS NULL
         OR piprianu IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnumerr := pac_tarifas.f_param_concepto(psseguro, pnriesgo, pnmovimi, pmode, pcconcep,
                                              pcrecfra, pcgarant, piprianu, pidtocom, piconcep,
                                              vfefecto, vfcaranu, vsproduc, vcactivi, vcforpag);

      IF vnumerr <> 0 THEN
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      --Obtenemos datos del producto
      SELECT p.cramo, p.cmodali, p.ctipseg, p.ccolect, p.cprorra,
             DECODE(vcforpag, 0, 1, vcforpag), crevfpg
        INTO xcramo, xcmodali, xctipseg, xccolect, xcprorra,
             xcforpag, xcrevfpg
        FROM productos p
       WHERE p.sproduc = vsproduc;

      vpasexec := 6;

      -- LPS (10/09/2008). Se modifica la forma de obtener los impuestos por el Nuevo módulo de impuestos.
      BEGIN
         SELECT cempres
           INTO vcempres
           FROM codiram
          WHERE cramo = xcramo;
      EXCEPTION
         WHEN OTHERS THEN
            vcempres := NULL;
      END;

      vpasexec := 7;
          -- Comentado (LPS 17/09/2008), para el nuevo módulo de impuestos.
          -- El IPS se aplica al recargo de fraccionamiento 0.- No, 1.- Si
          --xips_fracc := NVL (f_parinstalacion_n ('IPS_FRACC'), 1);
          -- Los impuestos: CLEA, arbitris se aplican sobre la prima bonificada o no
          --ximp_boni := NVL (f_parinstalacion_n ('IMP_BONI'), 0);
          -- La CLEA se aplica al recargo por fraccionamiento 0.- no, 1.- si
          --xclea_fracc := NVL (f_parinstalacion_n ('CLEA_FRACC'), 0);
      /*    BEGIN
             SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                    NVL(cimpfng, 0), NVL(cimpcon, 0)
               INTO xcimpclea, xcimpips, xcderreg, xcimparb,
                    xcimpfng, xcimpcons
               FROM garanpro
              WHERE cramo = xcramo
                AND cmodali = xcmodali
                AND ctipseg = xctipseg
                AND ccolect = xccolect
                AND cactivi = vcactivi
                AND cgarant = pcgarant;
          EXCEPTION
             WHEN OTHERS THEN
                BEGIN
                   SELECT NVL(cimpdgs, 0), NVL(cimpips, 0), NVL(cderreg, 0), NVL(cimparb, 0),
                          NVL(cimpfng, 0), NVL(cimpcon, 0)
                     INTO xcimpclea, xcimpips, xcderreg, xcimparb,
                          xcimpfng, xcimpcons
                     FROM garanpro
                    WHERE cramo = xcramo
                      AND cmodali = xcmodali
                      AND ctipseg = xctipseg
                      AND ccolect = xccolect
                      AND cactivi = 0
                      AND cgarant = pcgarant;
                EXCEPTION
                   WHEN OTHERS THEN
                      --Garantía erronea pel producte
                      --RETURN 141095;
                      vnumerr := 141095;
                      RAISE e_object_error;
                END;
          END;

          IF pcconcep = 2 THEN   -- consorcio
             IF xcimpcons = 0 THEN   -- No hay consorcio
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          ELSIF pcconcep = 4 THEN   -- IPS
             IF xcimpips = 0 THEN   -- No hay IPS
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          ELSIF pcconcep = 5 THEN   -- CLEA
             IF xcimpclea = 0 THEN   -- No hay  CLEA
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          ELSIF pcconcep = 6 THEN   -- impuestos arbitrarios
             IF xcimparb = 0 THEN   -- No hay  ARB
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          ELSIF pcconcep = 7 THEN   -- FNG
             IF xcimpfng = 0 THEN   -- No hay  FNG
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          ELSIF pcconcep = 14 THEN   -- Derechos de registros (o Gastos de expedicion para Lcol)
             IF xcderreg = 0 THEN   -- No hay  Derechos de registro
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          -- Bug 23074 - APD - 02/08/2012 - se añade el cconcep = 86 (v.f.27)
          ELSIF pcconcep = 86 THEN   -- IVA - Derechos de registros (o IVA - Gastos de expedicion para Lcol)
             IF xcderreg = 0 THEN   -- No hay  Derechos de registro, ENTONCES tampoco hay IVA
                RAISE salir;   -- no se divide entre la forma de pago
             END IF;
          END IF;*/
      vctipcon := NULL;
      vnvalcon := NULL;
      vcfracci := NULL;
      vcbonifi := NULL;
      vcrecfra := NULL;
      vpasexec := 8;
      vnumerr := f_concepto(pcconcep, vcempres, vfefecto, xcforpag, xcramo, xcmodali, xctipseg,
                            xccolect, vcactivi, pcgarant, vctipcon, vnvalcon, vcfracci,
                            vcbonifi, vcrecfra, w_climit,   -- Bug 10864.NMM.01/08/2009.
                            v_cmonimp,   -- BUG 18423: LCOL000 - Multimoneda
                            vcderreg);   -- Bug 0020314 - FAL - 29/11/2011
      vpasexec := 9;

      IF vnumerr <> 0 THEN
         -- Realmente, si la funcion f_concepto ha dado un error no tenemos que
         -- mostrar el error sino que la funcion devuelva el importe del concepto
         -- tal y como se le ha pasado por parametro, es decir, sin dividirlo
         -- entre la forma de pago
         --RAISE e_object_error;
         RAISE salir;
      ELSE
         vpasexec := 10;

         IF NVL(vcfracci, 0) <> 0 THEN
            viconcep := NVL(xcforpag, 1);
         ELSE
            viconcep := 1;
         END IF;
      END IF;

      RETURN viconcep;
   EXCEPTION
      WHEN salir THEN
         viconcep := 1;
         RETURN viconcep;
      WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Objeto invocado con parámetros erroneos');
         RETURN NULL;
      WHEN e_object_error THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'Error al llamar procedimiento o función - numerr: ' || vnumerr);
         RETURN NULL;
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_importe_impuesto;

   /*************************************************************************
      Detalle de primas a nivell de garantia
      param in out pgaran    : objecte garantia
      param in     pssolicit : sseguro de la pòlissa
      param in     pnmovimi  : nmovimi de la pòlissa
      param in     pmode     : el valor de com recuperar les dades (EST o POL)
      param in     pnriesgo  : codi del risc
   *************************************************************************/
   -- Bug 21121 - APD - 02/03/2012 - se crea la funcion
   PROCEDURE p_get_detprimas(
      pgaran IN OUT ob_iax_garantias,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2 DEFAULT 'EST',
      pnriesgo IN NUMBER) IS
      vpasexec       NUMBER(2) := 1;
      vparam         VARCHAR2(80)
         := 'pssolicit=' || pssolicit || ', pnmovimi=' || pnmovimi || ', pmode=' || pmode
            || ', pnriesgo=' || pnriesgo;
      vobject        VARCHAR2(50) := 'PAC_MDOBJ_PROD.P_Get_detprimas';
      vtab           VARCHAR2(20);
      curid          INTEGER;
      squery         VARCHAR2(2000);
      dummy          INTEGER;
      ccampo         VARCHAR2(2000);
      cconcep        VARCHAR2(2000);
      norden         NUMBER;
      iconcep        NUMBER;
      iconcep2       NUMBER;
      finiefe        DATE;
      b_nova         BOOLEAN;
      vsproduc       NUMBER;   -- Bug 21121 - APD - 10/04/2012
      vcactivi       NUMBER;   -- Bug 21121 - APD - 10/04/2012

      -- Bug 21121 - APD - 10/04/2012 - se añade la subfuncion
      FUNCTION ff_tcampo(pccampo IN VARCHAR2)
         RETURN VARCHAR2 IS
         vtcampo        codcampo.tcampo%TYPE;
      BEGIN
         SELECT tcampo
           INTO vtcampo
           FROM codcampo
          WHERE ccampo = pccampo;

         RETURN vtcampo;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END ff_tcampo;

      -- fin Bug 21121 - APD - 10/04/2012
      -- Bug 21121 - APD - 10/04/2012 - se añade la subfuncion
      FUNCTION ff_ndecvis(
         psproduc IN NUMBER,
         pcactivi IN NUMBER,
         pcgarant IN NUMBER,
         pccampo IN VARCHAR2,
         pcconcep IN VARCHAR2)
         RETURN NUMBER IS
         vndecvis       detgaranformula.ndecvis%TYPE;
      BEGIN
         SELECT ndecvis
           INTO vndecvis
           FROM detgaranformula
          WHERE sproduc = psproduc
            AND cactivi = pcactivi
            AND cgarant = pcgarant
            AND ccampo = pccampo
            AND cconcep = pcconcep;

         RETURN vndecvis;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN NULL;
      END ff_ndecvis;
   -- fin Bug 21121 - APD - 10/04/2012
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         vtab := 'ESTDETPRIMAS';
      ELSE
         vtab := 'DETPRIMAS';
      END IF;

      -- Bug 21121 - APD - 10/04/2012 - se busca el sproduc y cactivi
      IF pmode = 'EST' THEN
         BEGIN
            SELECT sproduc, cactivi
              INTO vsproduc, vcactivi
              FROM estseguros
             WHERE sseguro = pssolicit;
         EXCEPTION
            WHEN OTHERS THEN
               vsproduc := NULL;
               vcactivi := NULL;
         END;
      ELSE
         BEGIN
            SELECT sproduc, cactivi
              INTO vsproduc, vcactivi
              FROM seguros
             WHERE sseguro = pssolicit;
         EXCEPTION
            WHEN OTHERS THEN
               vsproduc := NULL;
               vcactivi := NULL;
         END;
      END IF;

      -- fin Bug 21121 - APD - 10/04/2012
      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery := 'SELECT FINIEFE, CCAMPO, CCONCEP, NORDEN, ICONCEP, ICONCEP2' || ' FROM '
                || vtab || ' S' || ' WHERE S.SSEGURO=' || pssolicit || ' AND   S.NMOVIMI='
                || pnmovimi || ' AND   S.NRIESGO=' || pnriesgo || ' AND   S.CGARANT='
                || pgaran.cgarant
                || ' ORDER BY DECODE(CCAMPO,''TASA'',1,''IPRITAR'',2,''IPRIANU'',3,4), NORDEN';
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 4;
      dummy := DBMS_SQL.EXECUTE(curid);
      vpasexec := 5;
      DBMS_SQL.define_column(curid, 1, finiefe);
      DBMS_SQL.define_column(curid, 2, ccampo, 2000);
      DBMS_SQL.define_column(curid, 3, cconcep, 2000);
      DBMS_SQL.define_column(curid, 4, norden);
      DBMS_SQL.define_column(curid, 5, iconcep);
      DBMS_SQL.define_column(curid, 6, iconcep2);

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         vpasexec := 6;
         DBMS_SQL.COLUMN_VALUE(curid, 1, finiefe);
         DBMS_SQL.COLUMN_VALUE(curid, 2, ccampo);
         DBMS_SQL.COLUMN_VALUE(curid, 3, cconcep);
         DBMS_SQL.COLUMN_VALUE(curid, 4, norden);
         DBMS_SQL.COLUMN_VALUE(curid, 5, iconcep);
         DBMS_SQL.COLUMN_VALUE(curid, 6, iconcep2);
         b_nova := TRUE;

         IF pgaran.detprimas IS NOT NULL THEN
            IF pgaran.detprimas.COUNT > 0 THEN
               FOR vprg IN pgaran.detprimas.FIRST .. pgaran.detprimas.LAST LOOP
                  IF pgaran.detprimas.EXISTS(vprg) THEN
                     IF pgaran.detprimas(vprg).ccampo = ccampo
                        AND pgaran.detprimas(vprg).cconcep = cconcep THEN
                        pgaran.detprimas(vprg).tcampo :=
                                                      ff_tcampo(pgaran.detprimas(vprg).ccampo);
                        pgaran.detprimas(vprg).tconcep :=
                                                     ff_tcampo(pgaran.detprimas(vprg).cconcep);
                        pgaran.detprimas(vprg).norden := norden;
                        pgaran.detprimas(vprg).iconcep := iconcep;
                        pgaran.detprimas(vprg).iconcep2 := iconcep2;
                        pgaran.detprimas(vprg).ndecvis :=
                           ff_ndecvis(vsproduc, vcactivi, pgaran.cgarant,
                                      pgaran.detprimas(vprg).ccampo,
                                      pgaran.detprimas(vprg).cconcep);
                        b_nova := FALSE;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 8;

         IF b_nova THEN
            vpasexec := 81;

            -- BUG12384:DRA:02/02/2010:Inici
            IF pgaran.detprimas IS NULL THEN
               pgaran.detprimas := t_iax_detprimas();
            END IF;

            -- BUG12384:DRA:02/02/2010:Fi
            vpasexec := 82;
            pgaran.detprimas.EXTEND;
            pgaran.detprimas(pgaran.detprimas.LAST) := ob_iax_detprimas();
            pgaran.detprimas(pgaran.detprimas.LAST).ccampo := ccampo;
            pgaran.detprimas(pgaran.detprimas.LAST).tcampo :=
                                      ff_tcampo(pgaran.detprimas(pgaran.detprimas.LAST).ccampo);
            pgaran.detprimas(pgaran.detprimas.LAST).cconcep := cconcep;
            pgaran.detprimas(pgaran.detprimas.LAST).tconcep :=
                                     ff_tcampo(pgaran.detprimas(pgaran.detprimas.LAST).cconcep);
            pgaran.detprimas(pgaran.detprimas.LAST).norden := norden;
            pgaran.detprimas(pgaran.detprimas.LAST).iconcep := iconcep;
            pgaran.detprimas(pgaran.detprimas.LAST).iconcep2 := iconcep2;
            pgaran.detprimas(pgaran.detprimas.LAST).ndecvis :=
               ff_ndecvis(vsproduc, vcactivi, pgaran.cgarant,
                          pgaran.detprimas(pgaran.detprimas.LAST).ccampo,
                          pgaran.detprimas(pgaran.detprimas.LAST).cconcep);
         END IF;
      END LOOP;

      vpasexec := 9;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         -- BUG12384:DRA:02/02/2010:Inici
         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   -- BUG12384:DRA:02/02/2010:Fi
   END p_get_detprimas;

   /*************************************************************************
        Grabar el capital recomendado para cada garantia
        param in sseguro  : numero de seguro
        param in nriesgo  : numero de riesgo
        param out mensajes : mensajes de error
        return             : 0 todo correcto
                             1 ha habido un error
     *************************************************************************/
   FUNCTION f_act_cap_recomend(
      pnriesgo IN NUMBER,
      pobgaran IN OUT ob_iax_garantias,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      gar            t_iax_garantias;
      tgr            ob_iax_garantias;
      rie            ob_iax_riesgos;
      npos           NUMBER;
      nerr           NUMBER := 0;
      vmensaje       VARCHAR2(1000);
      tgarant        VARCHAR2(1000);
      desmsj         VARCHAR2(1000);
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION.f_act_cap_recomend';
      detpoliza      ob_iax_detpoliza;
   BEGIN
      nerr := 0;

      IF pobgaran IS NOT NULL THEN
         pobgaran.excaprecomend := NVL(pac_parametros.f_pargaranpro_n(psproduc, pcactivi,
                                                                      pobgaran.cgarant,
                                                                      'CAPRECOMEND'),
                                       0);

         IF pobgaran.excaprecomend = 1 THEN
            --pobgaran.icaprecomend := 1000;   --faltará función el pac_cal_comu
            -- Bug 20504 - JRH - 19/06/2012 - Cálculo capital orientativo
            detpoliza := pac_iobj_prod.f_getpoliza(mensajes);
            nerr := pac_calc_comu.f_act_cap_recomend(pac_iax_produccion.vpmode,
                                                     pac_iax_produccion.vsolicit,
                                                     detpoliza.gestion.cactivi, pnriesgo,   --pnriesgo IN NUMBER,
                                                     pobgaran.cgarant, pobgaran.finiefe,
                                                     pobgaran.nmovimi, pobgaran.icaprecomend);
         -- Fi Bug 20504 - JRH - 19/06/2012
         END IF;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_act_cap_recomend;

   --bfp bug 21947 ini
   PROCEDURE p_get_garansegcom(
      riesgo IN OUT ob_iax_riesgos,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode IN VARCHAR2) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
                := 'pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.P_Get_GARANSEGCOM';
      curid          INTEGER;
      dummy          INTEGER;
      vtab           VARCHAR2(20);
      squery         VARCHAR2(2000);
      vsseguro       NUMBER;
      vnriesgo       NUMBER;
      vcgarant       NUMBER;
      vnmovimi       NUMBER;
      vfiniefe       DATE;
      vcmodcom       NUMBER;
      vpcomisi       NUMBER;
      vninialt       NUMBER;
      vnfinalt       NUMBER;
      vpcomisicua    NUMBER;
      vfalta         DATE;
      vcusualt       VARCHAR2(32);
      vfmodifi       DATE;
      vcusumod       VARCHAR2(32);
      nwprg          NUMBER;
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         vtab := 'ESTGARANSEGCOM';
      ELSE
         vtab := 'GARANSEGCOM';
      END IF;

      vpasexec := 2;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 3;
      squery :=
         'select sseguro,nriesgo,cgarant,nmovimi,finiefe,cmodcom,pcomisi,niinialt,nfinalt, pcomisicua,
falta,cusualt,fmodifi,cusumod from '
         || vtab || ' s where s.NRIESGO= ' || riesgo.nriesgo || ' and s.sseguro = '
         || pssolicit || ' and s.nmovimi = ' || pnmovimi;
      vpasexec := 4;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 5;
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, vsseguro);
      DBMS_SQL.define_column(curid, 2, vnriesgo);
      DBMS_SQL.define_column(curid, 3, vcgarant);
      DBMS_SQL.define_column(curid, 4, vnmovimi);
      DBMS_SQL.define_column(curid, 5, vfiniefe);
      DBMS_SQL.define_column(curid, 6, vcmodcom);
      DBMS_SQL.define_column(curid, 7, vpcomisi);
      DBMS_SQL.define_column(curid, 8, vninialt);
      DBMS_SQL.define_column(curid, 9, vnfinalt);
      DBMS_SQL.define_column(curid, 10, vpcomisicua);
      DBMS_SQL.define_column(curid, 11, vfalta);
      DBMS_SQL.define_column(curid, 12, vcusualt, 32);
      DBMS_SQL.define_column(curid, 13, vfmodifi);
      DBMS_SQL.define_column(curid, 14, vcusumod, 32);
      vpasexec := 6;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, vsseguro);
         DBMS_SQL.COLUMN_VALUE(curid, 2, vnriesgo);
         DBMS_SQL.COLUMN_VALUE(curid, 3, vcgarant);
         DBMS_SQL.COLUMN_VALUE(curid, 4, vnmovimi);
         DBMS_SQL.COLUMN_VALUE(curid, 5, vfiniefe);
         DBMS_SQL.COLUMN_VALUE(curid, 6, vcmodcom);
         DBMS_SQL.COLUMN_VALUE(curid, 7, vpcomisi);
         DBMS_SQL.COLUMN_VALUE(curid, 8, vninialt);
         DBMS_SQL.COLUMN_VALUE(curid, 9, vnfinalt);
         DBMS_SQL.COLUMN_VALUE(curid, 10, vpcomisicua);
         DBMS_SQL.COLUMN_VALUE(curid, 11, vfalta);
         DBMS_SQL.COLUMN_VALUE(curid, 12, vcusualt);
         DBMS_SQL.COLUMN_VALUE(curid, 13, vfmodifi);
         DBMS_SQL.COLUMN_VALUE(curid, 14, vcusumod);
         nwprg := 1;
         vpasexec := 7;

         IF riesgo.att_garansegcom IS NOT NULL THEN
            IF riesgo.att_garansegcom.COUNT > 0 THEN
               FOR vpgsc IN riesgo.att_garansegcom.FIRST .. riesgo.att_garansegcom.LAST LOOP
                  IF riesgo.preguntas.EXISTS(vpgsc) THEN
                     IF (riesgo.att_garansegcom(vpgsc).cgarant = vcgarant)
                        AND(riesgo.att_garansegcom(vpgsc).cmodcom = vcmodcom)
                        AND(riesgo.att_garansegcom(vpgsc).ninialt = vninialt) THEN
                        vpasexec := 8;
--                        riesgo.att_garansegcom(vpgsc).sseguro := vsseguro;
--                        riesgo.att_garansegcom(vpgsc).nriesgo := vnriesgo;
                        riesgo.att_garansegcom(vpgsc).cgarant := vcgarant;
                        riesgo.att_garansegcom(vpgsc).nmovimi := vnmovimi;
                        riesgo.att_garansegcom(vpgsc).finiefe := vfiniefe;
                        riesgo.att_garansegcom(vpgsc).cmodcom := vcmodcom;
                        riesgo.att_garansegcom(vpgsc).pcomisi := vpcomisi;
                        riesgo.att_garansegcom(vpgsc).ninialt := vninialt;
                        riesgo.att_garansegcom(vpgsc).nfinalt := vnfinalt;
                        riesgo.att_garansegcom(vpgsc).pcomisicua := vpcomisicua;
--                        riesgo.att_garansegcom(vpgsc).falta := vfalta;
--                        riesgo.att_garansegcom(vpgsc).cusualt := vcusualt;
--                        riesgo.att_garansegcom(vpgsc).fmodifi := vfmodifi;
--                        riesgo.att_garansegcom(vpgsc).cusumod := vcusumod;
                        nwprg := 0;
                        EXIT;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 9;

         IF nwprg = 1 THEN
            vpasexec := 10;

            IF riesgo.att_garansegcom IS NULL THEN
               riesgo.att_garansegcom := t_iax_garansegcom();
            END IF;

            vpasexec := 11;
            riesgo.att_garansegcom.EXTEND;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST) := ob_iax_garansegcom();
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).sseguro := vsseguro;
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).nriesgo := vnriesgo;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).cgarant := vcgarant;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).nmovimi := vnmovimi;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).finiefe := vfiniefe;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).cmodcom := vcmodcom;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).pcomisi := vpcomisi;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).ninialt := vninialt;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).nfinalt := vnfinalt;
            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).pcomisicua := vpcomisicua;
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).falta := vfalta;
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).cusualt := vcusualt;
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).fmodifi := vfmodifi;
--            riesgo.att_garansegcom(riesgo.att_garansegcom.LAST).cusumod := vcusumod;
         END IF;
      END LOOP;

      vpasexec := 12;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   END p_get_garansegcom;

--bfp bug 21947 fi

   -- Bug 0023183 - DCG - 14/08/2012 - LCOL_T020-COA-Circuit d'alta de propostes amb coasseguran
   /*************************************************************************
      Tablas de coacuadro
      param in out pdetpoliza   : detpoliza
      param in     pssolicit    : modalidad comisión
      param in     pnmovimi     : inicio de altura
      param in     pmode        : fin de altura
   *************************************************************************/
   PROCEDURE p_get_coacuadro(
      pdetpoliza IN OUT ob_iax_detpoliza,
      pssolicit IN NUMBER,
      pnmovimi IN NUMBER,
      pmode VARCHAR2) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1000)
         := 'pdetpoliza=' || 'A' || ' pssolicit=' || pssolicit || ' pnmovimi=' || pnmovimi
            || ' pmode=' || pmode;
      vobject        VARCHAR2(200) := 'PAC_MDOBJ_PROD.p_get_coacuadro';
      curid          INTEGER;
      dummy          INTEGER;
      vtab2          VARCHAR2(20);
      squery         VARCHAR2(2000);
      vccompan       NUMBER;
      vpcoatcompani  VARCHAR2(50);
      vpcomcoa       NUMBER;
      vpcomgas       NUMBER;
      vpcomcon       NUMBER;
      vpcescoa       NUMBER;
      vpcesion       NUMBER;
      nwprg          NUMBER;
      ptcompani      VARCHAR2(40);
      pcoatcompani   VARCHAR2(40);
      coacedido      t_iax_coacedido;
      pncuacoa       NUMBER;
      psseguro       NUMBER;
      pploccoa       NUMBER;
      pfinicoa       DATE;
      pffincoa       DATE;
      pfcuacoa       DATE;
      pccompan       NUMBER;
      pnpoliza       VARCHAR2(50);
   BEGIN
      vpasexec := 1;

      IF pmode = 'EST' THEN
         SELECT sseguro, ncuacoa, ploccoa, finicoa, ffincoa, fcuacoa, ccompan, npoliza
           INTO psseguro, pncuacoa, pploccoa, pfinicoa, pffincoa, pfcuacoa, pccompan, pnpoliza
           FROM estcoacuadro
          WHERE npoliza = pssolicit
            AND ncuacoa = pnmovimi;

         vtab2 := 'ESTCOACEDIDO co';
      ELSE
         vpasexec := 2;

         SELECT sseguro, ncuacoa, ploccoa, finicoa, ffincoa, fcuacoa, ccompan, npoliza
           INTO psseguro, pncuacoa, pploccoa, pfinicoa, pffincoa, pfcuacoa, pccompan, pnpoliza
           FROM coacuadro
          WHERE npoliza = pssolicit
            AND ncuacoa = pnmovimi;

         vtab2 := 'COACEDIDO co';
      END IF;

      vpasexec := 3;

      SELECT tcompani
        INTO ptcompani
        FROM companias
       WHERE ccompani = pccompan;

      vpasexec := 4;
      pdetpoliza.coacuadro.ncuacoa := pncuacoa;
      pdetpoliza.coacuadro.ploccoa := pploccoa;
      pdetpoliza.coacuadro.finicoa := pfinicoa;
      pdetpoliza.coacuadro.ffincoa := pffincoa;
      pdetpoliza.coacuadro.fcuacoa := pfcuacoa;
      pdetpoliza.coacuadro.ccompan := pccompan;
      pdetpoliza.coacuadro.tcompan := ptcompani;
      pdetpoliza.coacuadro.npoliza := pnpoliza;
      curid := DBMS_SQL.open_cursor;
      vpasexec := 5;
      squery :=
         'SELECT co.ccompan,(SELECT tcompani FROM COMPANIAS where ccompani = co.ccompan) pcoatcompani,co.pcomcoa,co.pcomgas,co.pcomcon,co.pcescoa,co.pcesion '
         || ' FROM ' || vtab2 || ' WHERE co.SSEGURO=' || psseguro || ' AND co.ncuacoa='
         || pncuacoa;
      DBMS_SQL.parse(curid, squery, DBMS_SQL.v7);
      vpasexec := 6;
      dummy := DBMS_SQL.EXECUTE(curid);
      DBMS_SQL.define_column(curid, 1, vccompan);
      DBMS_SQL.define_column(curid, 2, vpcoatcompani, 50);   --);
      DBMS_SQL.define_column(curid, 3, vpcomcoa);
      DBMS_SQL.define_column(curid, 4, vpcomgas);
      DBMS_SQL.define_column(curid, 5, vpcomcon);
      DBMS_SQL.define_column(curid, 6, vpcescoa);
      DBMS_SQL.define_column(curid, 7, vpcesion);
      vpasexec := 7;

      LOOP
         EXIT WHEN DBMS_SQL.fetch_rows(curid) = 0;
         DBMS_SQL.COLUMN_VALUE(curid, 1, vccompan);
         DBMS_SQL.COLUMN_VALUE(curid, 2, vpcoatcompani);
         DBMS_SQL.COLUMN_VALUE(curid, 3, vpcomcoa);
         DBMS_SQL.COLUMN_VALUE(curid, 4, vpcomgas);
         DBMS_SQL.COLUMN_VALUE(curid, 5, vpcomcon);
         DBMS_SQL.COLUMN_VALUE(curid, 6, vpcescoa);
         DBMS_SQL.COLUMN_VALUE(curid, 7, vpcesion);
         nwprg := 1;
         vpasexec := 8;

         IF pdetpoliza.coacuadro.coacedido IS NOT NULL THEN
            IF pdetpoliza.coacuadro.coacedido.COUNT > 0 THEN
               FOR vpgsc IN
                  pdetpoliza.coacuadro.coacedido.FIRST .. pdetpoliza.coacuadro.coacedido.LAST LOOP
                  IF pdetpoliza.coacuadro.coacedido.EXISTS(vpgsc) THEN
                     vpasexec := 9;
                     pdetpoliza.coacuadro.coacedido(vpgsc).ccompan := vccompan;
                     pdetpoliza.coacuadro.coacedido(vpgsc).tcompan := vpcoatcompani;
                     pdetpoliza.coacuadro.coacedido(vpgsc).pcomcoa := vpcomcoa;
                     pdetpoliza.coacuadro.coacedido(vpgsc).pcomgas := vpcomgas;
                     pdetpoliza.coacuadro.coacedido(vpgsc).pcomcon := vpcomcon;
                     pdetpoliza.coacuadro.coacedido(vpgsc).pcescoa := vpcescoa;
                     pdetpoliza.coacuadro.coacedido(vpgsc).pcesion := vpcesion;
                     nwprg := 0;
                     EXIT;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         vpasexec := 10;

         IF nwprg = 1 THEN
            vpasexec := 11;

            IF pdetpoliza.coacuadro.coacedido IS NULL THEN
               pdetpoliza.coacuadro.coacedido := t_iax_coacedido();
            END IF;

            vpasexec := 12;
            pdetpoliza.coacuadro.coacedido.EXTEND;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST) :=
                                                                             ob_iax_coacedido
                                                                                             ();
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).ccompan :=
                                                                                       vccompan;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).tcompan :=
                                                                                  vpcoatcompani;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).pcomcoa :=
                                                                                       vpcomcoa;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).pcomgas :=
                                                                                       vpcomgas;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).pcomcon :=
                                                                                       vpcomcon;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).pcescoa :=
                                                                                       vpcescoa;
            pdetpoliza.coacuadro.coacedido(pdetpoliza.coacuadro.coacedido.LAST).pcesion :=
                                                                                       vpcesion;
         END IF;
      END LOOP;

      vpasexec := 13;
      DBMS_SQL.close_cursor(curid);
   EXCEPTION
      WHEN OTHERS THEN
         IF DBMS_SQL.is_open(curid) THEN
            DBMS_SQL.close_cursor(curid);
         END IF;

         p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, SQLERRM);
   END p_get_coacuadro;
-- Fin Bug 0023183
END pac_mdobj_prod;
/
