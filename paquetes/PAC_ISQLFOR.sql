create or replace PACKAGE pac_isqlfor AS
   /******************************************************************************
      NOMBRE:       PAC_ISQLFOR
      PROPSITO: Frmulas de consultas de plantillas

      REVISIONES:
      Ver        Fecha       Autor  Descripcin
      ---------  ----------  -----  ------------------------------------
      1.0                           Creacin del package.
      2.0        01/04/2009  SBG    Modificaci select de funci f_cuestsaa
      3.0        02/04/2009  SBG    Modifs. a f_garantias_ass1 i f_capitales_ass1(BUG 9574)
      4.0        08/04/2009  SBG    Modifs. a f_garantias_ass1, f_capitales_ass1,
                                       f_titgarantias i f_capgarantias(BUG 9512)
      5.0        09/04/2009  SBG    Modifs. a f_capitales_ass1 (BUG 9505)
      6.0        23/04/2009  SBG    Nova funci f_salud_preguntas (Bug 9472)
      7.0        29/04/2009  JTS    Noves funcions condicionat particular (Bug 8871)
      8.0        26/05/2009  APD    Bug 10199: se crea la funcion f_anulacion
      13.0       01/09/2009  JTS    10365 - Plantillas simulaciones
      14.0       07/09/2009  ASN    11006 - Se elimina el parametro p_ntipsel en f_garantias_ass1 y f_capitales_ass1
      15.0       03/11/2009  NMM    11654: CRE - Modificacin plantillas PPJ /Pla Estudiant.
      16.0       30/11/2009  NMM    12101: CRE084 - Aadir rentabilidad en consulta de plizas.
      17.0       23/12/2009  NMM    12301: CRE084 - Plantilles retencions i suplements Pla Estudiant i PPJ Dinmic.
      18.0       31/12/2009  JRH    0012485: CEM201 - Incidencias varias PPA
      25.0       20/01/2010  JTS    12764: CEM - Plantilla PPA
      26.0       05/02/2010  DRA    0010522: CRE069 - Modificacin rtfs para incluir preguntas de los riegos
      27.0       24/02/2010  JTS    13025: CEM210: PLANTILLES RESCATS - CRS + PIES + PEA
      29.0       03/03/2010  JTS    13480: CEM800 - PLANTILLES: Capital garantit a venciment en duplicat de plantilles estalvi
      30.0       04/03/2010  JTS    13404: CEM800 - PLANTILLES: Nova plantilla per imprimir CTASEGURO
      35.0       15/07/2010  JTS    11651: AGA002 - Valores de rescate anual en productos de ahorro
      36.0       13/08/2010  RSC    0014775: AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
      37.0       21/10/2010  DRA    0016373: CRE998 - Modificaci pdf moviment compte assegurana
      38.0       05/11/2011  AMC    0016485: CRT101 - Modificar las plantillas de productos genricos
      39.0       08/04/2011  RSC    0017657: MSGV101 - Creaci i parametritzaci producte Vida-Risc
      40.0       14/04/2011  FAL    0018172: CRT - Modificacion documentacin
      41.0       11/05/2011  JGM    18483: MSGV101 - Actualitzaci de la plantilla de projecte pel producte de Vida Risc
      42.0       23/05/2011  ETM    0018606: MSGV003 - Plantilla per la impressi del rebut
      43.0       17/06/2011  ETM    0018835: MSGV101 - Modificaci de les condicions particulars per a que aparegui el deglos del rebut
      44.0       14/09/2011  DRA    0018682: AGM102 - Producto SobrePrecio- Definicin y Parametrizacin
      45.0       27/09/2011  JMP    0019322: ENSA102-Segunda Documentacin productos Contribucin Definida Individual
      46.0       21/10/2011  JMP    0019780: GIP103 - condicionado del producto Transporte Mercaderas CMR
      47.0       27/10/2011  MDS    0019726: AGM - Documentacin del producto de sobre-precio
      48.0       10/04/2012  MDS    0021873: AGM - Documentacin que genera iAxis en Siniestros (sobreprecio)
      49.0       30/04/2012  MDS    0022088: AGM - La consultas de 1321 no est preparada cuando el nombre contiene un apstrofe.
      50.0       04/06/2012  MDS    0022009: AGM101 - Impresin de los documentos relacionados (produccin, recibos, siniestros...)
      51.0       23/07/2012  ECP    0023077: ENSA102-Visualizacin erronea de los movimientos de CTASEGURO en la plantilla ENSA121
      52.0       02/08/2012  LCF    0022009  AGM - Parametros de Clasulas - Entidad /Prstamo
      53.0       17/08/2012  LCF    0022009  AGM - Presupuesto Plantilla EST Tablas
      54.0       13/02/2013  JMF    0025097: LCOL_T020-Qtrackers: 5609, 5624, 5625, 5626, 5627, 5628, 5629 i 5630
      55.0       16/02/2013  RDD    0024813   (POSDE100)-Desarrollo-GAPS Administracion-Id 109 - Reportes de comisiones
      56.0       19/05/2014  JTT    0029943: Afegim el parametre ndetgar a la funcion f_provisio_actual
      57.0       18/08/2014  MMS    0031135: Montar Entorno Colmena en VAL
      58.0       15/11/2018  WAJ    GE-FO-18-02: Ajuste Codigo Pais Alfanumerico
      59.0	 	 20/11/2018  KK     IAXIS-3152:Ficha financiera intermediario - Verificacin datos
      60.0       20/09/2019  Swapnil Cambios de IAXIS-5337	  
      61.0       15/04/2019  ID     IAXIS 7585: Reporte Siniestros Pagados, Recobros y Reservas - Reaseg 

   ****************************************************************************/
   FUNCTION f_ccc_mov(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_ccc(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_fecha_pie(p_fecha IN DATE DEFAULT f_sysdate, p_idioma IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_persona(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_dni(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_domicilio(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tcomple(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_numvia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_nomvia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;
   FUNCTION f_domiciriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_pobriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_nacim(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_sexo(
      psseguro IN NUMBER DEFAULT NULL,
      pctipo IN NUMBER DEFAULT NULL,
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_provriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_cpriesgo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_pobagente(pcagente IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR;

   FUNCTION f_codpostal(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_poblacion(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_provincia(psperson IN NUMBER, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_dirpais(
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pcidioma IN NUMBER DEFAULT f_usu_idioma)
      RETURN VARCHAR2;

   FUNCTION f_nacion(psperson IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_profesion(psperson IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_matricula(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_marca(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_modelo(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_clase(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_cia(psseguro IN NUMBER, pcia IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_usuario
      RETURN VARCHAR2;

   FUNCTION f_ramo(pramo IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_agente(pcagente IN NUMBER)
      RETURN VARCHAR;

   FUNCTION f_firma
      RETURN VARCHAR2;

   FUNCTION f_telefono(psperson IN NUMBER)
      RETURN VARCHAR2;

  FUNCTION f_telefono_movil(psperson IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_conductor(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_sexoconductor(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_permiso(psseguro IN NUMBER DEFAULT NULL, psperson IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   /*
       FUNCTION F_FPERMISO( psseguro IN NUMBER DEFAULT NULL) RETURN VARCHAR2;
   */
   FUNCTION f_cobbancario(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_titulopro(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_empresa(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_plan(psseguro IN NUMBER DEFAULT NULL, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_codplan(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_fondo(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_codfondo(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_gestora(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_codgestora(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_depositaria(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_coddepositaria(psseguro IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_motsin(pnsinies IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_causin(pnsinies IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tramitador(pnsinies IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_solnomcon(pdni IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_solcodpostalcon(pdni IN VARCHAR2, pcdomici IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_soltelefonocon(pdni IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_solnacimientocon(pdni IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_solfcarnetcon(pdni IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_sexoriesgo(psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_primaperiodo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_primaextra(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_primaanual(p_seguro IN NUMBER, p_riesgo IN NUMBER, p_movimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_primarecargo(p_seguro IN NUMBER, p_riesgo IN NUMBER, p_movimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_revalorizacion(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_formapago(
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 2,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   FUNCTION f_clausulas(psseguro IN NUMBER, pidioma IN NUMBER DEFAULT 2)
      RETURN VARCHAR2;

   FUNCTION f_prestacapital(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_prestarenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_prestaformarenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_prestafpagocapital(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_prestafpagorenta(psperson IN NUMBER, pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_docuparte(pparte IN VARCHAR2, ptipo IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_parte_col1(pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parte_col1(pparte IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_parte_col2(pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parte_col3(pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_parte_col3(pparte IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_parte_col4(pparte IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_cumulos_tar(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_beneftar(psseguro IN NUMBER, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tarprimamuerte(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tarprimainv(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tarprimailt(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tarprimaotros(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tarprimamensual(pnsolini IN NUMBER, pnsolfin IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_litaltamodif(ptipo IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_litcabaltamodif(ptipo IN VARCHAR2, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION fechahoy_idioma(pfecha IN DATE, pidioma IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tab_simpp_ejercicio(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tab_simpp_apormes(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tab_simpp_capital(psesion IN NUMBER, parte IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_titgarantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pseparador IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_capgarantias(psseguro IN NUMBER, pnriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_max_nmovimi(p_sseguro IN NUMBER, p_cduplica IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_prox_recibo(psseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_prima_mensual_inicial(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_prima_anual(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_prima_total(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_recarreg(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tributs(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_dades_persona(
      p_sperson IN NUMBER,
      p_tipo IN NUMBER,
-- 1 DNI, 2 Data Naixement , 3 Sexe , 4 nom, 5 cognoms , 6 pais, 7 nacionalitat, 8 tipus document
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
       p_cagente IN NUMBER DEFAULT ff_agenteprod)
      RETURN VARCHAR2;

   FUNCTION f_direccion(
      p_sperson IN NUMBER,
      p_cdomici IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   FUNCTION f_import_garantia(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_import_garantia_aho(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_revali(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   --BUG 10264 - JTS - 28/05/2009 - CRE - Incidencia condicionado particular PPJ
   FUNCTION f_revali_seguro(p_sseguro IN NUMBER)
      RETURN NUMBER;

   --BUG 12839 - JTS - 04/02/2010
   FUNCTION f_per_o_imp_creix_seguro(p_sseguro IN NUMBER, p_modo IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   --Fi BUG 10264 - JTS - 28/05/2009
   FUNCTION f_per_o_imp_creix(p_garant IN NUMBER, p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_fecha_ultpago(p_sseguro IN NUMBER, p_sproduc IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_import_concepto(p_sseguro IN NUMBER, p_concepto IN NUMBER, p_ctrecibo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_fsuplem(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_recfracc_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_tributs_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_prtotal_ultimsuplement(p_sseguro IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_prima_mensual_nmovimi(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_altresa_nom(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_altresa_parent(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_altresa_sexe(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_altresa_fnac(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_altresa_nif(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_altresa_cass(p_sseguro IN NUMBER, p_tipo NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_cuestsaa(p_sseguro IN NUMBER, p_cidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_detalleds(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_garantias_ass1(
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL'
                                                                      /*,
                                      p_ntipsel IN NUMBER DEFAULT 1  */ -- Bug 11006 - 07/09/2009 - ASN
   )
      RETURN VARCHAR2;

   FUNCTION f_capitales_ass1(p_sseguro IN NUMBER, p_mode IN VARCHAR2 DEFAULT 'POL'
                                                                                                                   /*,
                                                                                  p_ntipsel IN NUMBER DEFAULT 1    */ -- Bug 11006 - 07/09/2009 - ASN
   )
      RETURN VARCHAR2;

   FUNCTION f_benefs_riesgos(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_idioma IN NUMBER DEFAULT 1,
      p_claucre IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_benefs(p_sseguro IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   -- JGM --
   FUNCTION f_for_dirdele(pcdelega IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_for_poblacion(pcdelega IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_for_aportextra(
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_tipo IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_for_aportperio(
      p_sseguro IN NUMBER,
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_dirdeleg(
      pcdelega IN NUMBER,
      pcformat IN NUMBER,
      ptlin1 OUT VARCHAR2,
      ptlin2 OUT VARCHAR2,
      ptlin3 OUT VARCHAR2,
      ptlin4 OUT VARCHAR2,
      ptlin5 OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_litnompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_litcognompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_nompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_cognompersona(p_sperson IN NUMBER, p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_clausula_particular(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_replace IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_camp_ctaseguros(
      psseguro IN NUMBER,
      pcampo IN NUMBER,
      pfechaini IN DATE DEFAULT NULL,
      pfechafin IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

   --BUG 9059 - 19/03/2009 - JTS
   FUNCTION f_recibosimpagados(psseguro IN NUMBER, pfvencim IN DATE)
      RETURN VARCHAR2;

   -- BUG 9575-25/03/2009-AMC- Noves funcions

   /*************************************************************************
    FUNCTION f_conreb_nmovimi
    Recupera los diferentes importes del ltimo recibo
    param in psseguro   : cdigo del seguro
    param in pnmovimi   : nmero de movimiento
    param in pcampo     : nmero de campo que se quiere recuperar
    return             : importe del campo requerido
    *************************************************************************/
   FUNCTION f_conreb_nmovimi(psseguro IN NUMBER, pnmovimi IN NUMBER, pcampo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_tconreb_nmovimi
     Funcin que te devuelve la cabecera del campo si este es diferente de null
     param in psseguro   : cdigo del seguro
     param in pnmovimi   : nmero de movimiento
     param in pcampo     : nmero de campo que se quiere recuperar
     param in pidioma    : idioma del literal
     return             : texto con el nombre del campo del RTF.
     *************************************************************************/
   FUNCTION f_tconreb_nmovimi(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcampo IN NUMBER,
      pidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   --Fi BUG 9575-25/03/2009-AMC

   -- BUG 9472 - 23/04/2009 - SBG - Es crea la funci f_salud_preguntas
   /*************************************************************************
     FUNCTION f_salud_preguntas
     Devuelve cuestionario de salud para un asegurado determinado
     param in p_sseguro  : cdigo del seguro
     param in p_nriesgo  : cdigo del riesgo
     param in pidioma    : idioma de las preguntas
     return              : texto con pregs. + las respuestas del nriesgo.
   *************************************************************************/
   FUNCTION f_salud_preguntas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_cidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   -- FINAL BUG 9472 - 23/04/2009 - SBG

   --BUG 8871 - 29/04/2009 - JTS
   /*************************************************************************
     FUNCTION f_capitalamort_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     param in p_campo    : columna
     return              : texto
   *************************************************************************/
   FUNCTION f_capitalamort_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_iprianu_tot
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_tot(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_garantax_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_garantax_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_garantclea_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_garantclea_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_iprianu_comp
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_comp(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_iprianu_princ
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_iprianu_princ(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_garantcomp_apr
     param in p_sseguro  : cdigo del seguro
     return              : texto
   *************************************************************************/
   FUNCTION f_garantcomp_apr(p_sseguro IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_ipritotdec_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ipritotdec_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_icaptotdec_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_icaptotdec_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_ipritotvid_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ipritotvid_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_icaptotvid_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_icaptotvid_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_titgarantias_apr
     param in p_sseguro  : cdigo del seguro
     param in p_cidioma  : cdigo de idioma
     param in p_nriesgo  : riesgo
     return              : texto
   *************************************************************************/
   FUNCTION f_titgarantias_apr(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_respuesta_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     param in p_cpregun  : cdigo de la pregunta
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta_apr(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_clausulas_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     param in p_cidioma  : idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_clausulas_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_ndurcob_apr
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     return              : texto
   *************************************************************************/
   FUNCTION f_ndurcob_apr(p_sseguro IN NUMBER, p_nmovimi IN NUMBER)
      RETURN VARCHAR2;

   --FINAL BUG 8871 - 29/04/2009 - JTS

   --BUG 10233 - 03/06/2009 - JTS
   /*************************************************************************
     FUNCTION f_camposrecibosimp_apr
     param in p_sseguro  : cdigo del seguro
     param in p_campo    : campo
     return              : texto
   *************************************************************************/
   FUNCTION f_camposrecibosimp_apr(p_sseguro IN NUMBER, p_campo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_totalesrecibosimp
     param in p_sseguro   : cdigo de la carta
     param in p_fefecto   : cdigo de la carta
     param in p_campo     : campo
     return               : texto
   *************************************************************************/
   FUNCTION f_totalesrecibosimp(p_sseguro IN NUMBER, p_fefecto IN DATE, p_campo IN NUMBER)
      RETURN VARCHAR2;

   --Fi BUG 10233 - 03/06/2009 - JTS

   -- Bug 10199 - APD - 26/05/2009 - se crea la funcion f_anulacion
   /*************************************************************************
     FUNCTION f_fanulacion
     Funcin que devuelve la fecha de anulacion de una poliza una vez sta ha
     sido anulada o programada para la anulacion
     param in p_sseguro  : cdigo del seguro
     return              : date
   *************************************************************************/
   FUNCTION f_fanulacion(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 10199 - APD - 26/05/2009 - se crea la funcion f_importerescate
   /*************************************************************************
     FUNCTION f_importerescate
     Funcin que devuelve el importe del rescate
     param in p_nsinies  : cdigo del siniestro
     return              : number
   *************************************************************************/
   FUNCTION f_importerescateparcial(p_nsinies IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     FUNCTION f_tituloSaldoDeutor
     Funcin que devuelve la cabecera del saldo deutores
     param in p_sproduc  : cdigo del producto
     param in p_column   : indica que columna devuelve
     param in p_sseguro  : cdigo del seguro
     param in p_idioma   : idioma
     return              : texto de la cabecera

     Bug 10857 - 31/07/2009 - AMC
   *************************************************************************/
   FUNCTION f_capitales_ase(
      p_sproduc IN NUMBER,
      p_colum IN NUMBER,
      p_sseguro IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_sum_calculoconcepto
     param in psseguro  : cdigo del seguro
     param in pnriesgo  : numero de riesgo
     param in pnmovimi  : nmero de movimiento
     param in pmodo     : modo EST\POL
     param in pconcep   : concepto
     return             : cantidad

     Bug 10365 - 01/09/2009 - JTS
   *************************************************************************/
   FUNCTION f_sum_calculoconcepto(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmodo IN VARCHAR2,
      pconcep IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
     FUNCTION f_sum_calculoconcepto
     param in psseguro  : cdigo del seguro
     param in pcidioma  : codigo del idioma
     return             : opcin

     Bug 11097 - 10/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_opciondinamica(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_perfil_inversion
     param in psseguro  : cdigo del seguro
     param in pcidioma  : codigo del idioma
     return             : perfil de inversin

     Bug 11097 - 10/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_perfil_inversion(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')   -- 12301.21/12/2009.NMM
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_detperfil_inversion
     param in psseguro  : cdigo del seguro
     return             : detalle perfil de inversin

     Bug 11097 - 10/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_detperfil_inversion(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_datosestudiante
     param in psseguro  : cdigo del seguro
     return             : datos estudiante

     Bug 11097 - 14/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_datosestudiante(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_fnacimiento
     param in psseguro  : cdigo del seguro
     return             : fecha nacimiento del estudiante

     Bug 11097 - 14/09/2009 - AMC
   *************************************************************************/
   FUNCTION f_fnacimiento(psseguro IN NUMBER)
      RETURN VARCHAR2;

/*************************************************************************
  FUNCTION f_respuesta_nacionalidad
  param in p_sseguro  : cdigo del seguro
  param in p_nmovimi  : cdigo del movimiento
  param in p_cpregun  : cdigo de la pregunta
  return              : texto
*************************************************************************/
/*
FUNCTION f_respuesta_nacionalidad(
   p_sseguro IN NUMBER,
   p_nmovimi IN NUMBER,
   p_cpregun IN NUMBER)
   RETURN VARCHAR2;*/--
--------------------------------------------------------------------------------
   /*************************************************************************
     FUNCTION F_GARANT_ADDICIONAL
     param in psseguro  : codi assegurana
     return             : descripci garantia

     Bug 11654 - 03/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_garant_addicional(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_idioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION F_CAPITAL_GARANT_AD
     param in psseguro  : codi assegurana
     return             : capital garantia addicional

     Bug 11654 - 03/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_capital_garant_ad(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION F_tot_prima_periodica
     param in psseguro  : codi assegurana
     return             : capital garantia addicional

     Bug 11654 - 03/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_tot_prima_periodica(
      p_sseguro IN VARCHAR2,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cgarant IN NUMBER,
      p_primaini IN NUMBER,
      p_idioma IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_suma_aportacio
     param in psseguro   : codi assegurana
     param in p_fecini   : data inici
     param in p_fecfin   : data fin
     param in p_ctipapor : tipus d'aportacions
                           E - Empresa
                           P - Partcep
     return              : suma aportaci

     Bug 12101 - 30/11/2009 - NMM.
   *************************************************************************/
   FUNCTION f_suma_aportacio(
      p_sseguro IN VARCHAR2,
      p_fecini IN DATE DEFAULT NULL,   -- BUG 19322 - 27/09/2011 - JMP
      p_fecfin IN DATE DEFAULT NULL,   -- BUG 19322 - 27/09/2011 - JMP
      p_ctipapor IN VARCHAR2 DEFAULT NULL)   -- BUG 19322 - 27/09/2011 - JMP
      RETURN VARCHAR2;

   -- BUG 12485- 12/2009 - JRH  - Incidencias varias PPA
   /*************************************************************************

     FUNCTION f_interes_neto: retorna interes net
     param in psseguro  : codi assegurana
     return             : interes net


   *************************************************************************/
   FUNCTION f_interes_neto(p_sseguro IN VARCHAR2)
      RETURN NUMBER;

   --Fi  BUG 12485- 12/2009

   /*************************************************************************
      FUNCTION f_perccc: retorna el CCC formatat d'una persona
      param in p_sperson : sperson
      return             : CCC de la persona
      BUG 12764 - JTS - 20/01/2010
    *************************************************************************/
   FUNCTION f_perccc(p_sperson IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
     FF_FORMATOCCC: Retorna el compte bancari sense formatejar en un
     string formatejat
     Encapsula la funci f_formatoccc per a poder-la utilitzar directament
     en selects
     param pcbancar IN        : pcbancar
     param pctipban IN        : pctipban
     param pquitarformato IN  : pquitarformato
           return             : CCC formatat
     BUG 12764 - JTS - 20/01/2010
     ******************************************************************/
   FUNCTION ff_formatoccc(
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER DEFAULT 1,
      pquitarformato IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   -- BUG10522:DRA:08/02/2010:Inici
   /*****************************************************************
    F_TITPREG_RIE: Retorna els ttols de les preguntes de risc
    param p_sseguro IN        : sseguro
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_preguntas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
    F_PREG_RIE: Retorna la resposta de les preguntes de risc
    param p_sseguro IN        : sseguro
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_respuestas(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

-- BUG10522:DRA:08/02/2010:Fi

   /*************************************************************************
     FUNCTION f_imports
     param in psseguro  : codi assegurana
     return             : import brut, rendiment, retencio, import_net

     Bug 13025 - JTS - 24/2/2010
   *************************************************************************/
   FUNCTION f_imports(p_sseguro IN seguros.sseguro%TYPE, p_tipus IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_total_parcial
     param in psseguro  : codi assegurana
     return             : total o parcial

     Bug 12388 - 28/12/2009 - NMM.
   *************************************************************************/
   FUNCTION f_total_parcial(p_sseguro IN seguros.sseguro%TYPE, pcidioma IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_provisio_actual
      param in psseguro  : codi assegurana
      param in pconcepto : camp de la provisio
      param in p_fecha   : data de clcul
      return             : cap defuncio
      --BUG13480-JTS-03/03/2010
     -- BUG 19322 - 28/09/2011 - JMP
     -- Bug 0025097 - 13/02/2013 - JMF
    *************************************************************************/
   FUNCTION f_provisio_actual(
      p_sseguro IN VARCHAR2,
      p_concepto IN VARCHAR2,
      p_fecha IN DATE DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_ndetgar IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
      FUNCTION f_apunts_ctaseguro
      param in psseguro  : codi assegurana
      param in pidioma   : idioma
      param in pcamp     : camp
      return             : apunt
      --BUG13404-JTS-04/03/2010
    *************************************************************************/
   FUNCTION f_apunts_ctaseguro(p_sseguro IN NUMBER, p_idioma IN NUMBER, p_camp IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_apunts_rescat_anual
      param in psseguro  : codi assegurana
      param in pcamp     : camp de la provisio
      return             : apunt del rescat anual
      --BUG11651-JTS-15/07/2010
    *************************************************************************/
   FUNCTION f_apunts_rescat_anual(p_sseguro IN NUMBER, p_camp IN NUMBER, p_tablas IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_capital_estimat
      param in psseguro  : codi assegurana
      param in pnriesgo  : riesgo
      param in pcamp     : camp de la provisio
      return             : apunt del rescat anual
      --BUG11651-JTS-15/07/2010
    *************************************************************************/
   FUNCTION f_capital_estimat(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_fefecto IN DATE,
      p_camp IN NUMBER)
      RETURN VARCHAR2;

   -- Bug 14775 - RSC - 13/08/2010- AGA003 - Error en dades rebut plantilla Condicionat Particular AGA012
   FUNCTION f_tmp_prima_anual(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tmp_prima_total(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tmp_recarreg(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tmp_tributs(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_tmp_prima_mensual_inicial(p_sseguro IN NUMBER, psproces IN NUMBER)
      RETURN VARCHAR2;

-- Fin bug 14775

   -- BUG16373:DRA:21/10/2010:Inici
   FUNCTION f_camp_ctaseguros_sinsaldo(
      psseguro IN NUMBER,
      pcampo IN NUMBER,
      pfechaini IN DATE DEFAULT NULL,
      pfechafin IN DATE DEFAULT NULL)
      RETURN VARCHAR2;

-- BUG16373:DRA:21/10/2010:Fi

   /*****************************************************************
    F_PREGUNTAS_GAR: Retorna els ttols de les preguntes de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

     Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_preguntas_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
    F_RESPUESTAS_GAR: Retorna els respuestas de les preguntes de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

    Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_respuestas_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
    F_CAPITAL_GAR: Retorna els capitals de garantia
    param p_sseguro IN        : sseguro
    param p_nriesgo IN        : numero de riesgo
    param p_nmovimi IN        : numero de movimiento
    param p_cidioma IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2

    Bug 16485 - 05/11/2010 - AMC
    ******************************************************************/
   FUNCTION f_capital_gar(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT 1,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
    F_SUPLEMENTOS: Retorna los suplementos
    param p_sseguro IN  : sseguro
    param p_nriesgo IN  : numero de riesgo
    param p_cidioma IN  : idioma
    return              : VARCHAR2

     Bug 16485 - 22/11/2010 - AMC
   ******************************************************************/
   FUNCTION f_suplementos(psseguro IN NUMBER, pnriesgo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
    f_formapagorecibo: Retorna la forma de pago del recibo
    f_formapagorecibo: Retorna la forma de pago del recibo
    param p_nrecibo IN  : nrecibo
    param p_cidioma IN  : idioma
    return              : VARCHAR2

     Bug 17435 - 03/02/2011 - JTS
   ******************************************************************/
   FUNCTION f_formapagorecibo(pnrecibo IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /***********************************************************************
          F_PER_CONTACTOS:  Retorna datos de contacto de una persona.
   **********************************************************************/
   -- Bug 17657 -RSC - 08/04/2011 -: MSGV101 - Creaci i parametritzaci producte Vida-Risc
   FUNCTION f_per_contactos(p_sperson IN NUMBER, p_tipcon IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_per_contactos_est(p_sperson IN NUMBER, p_tipcon IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_respuesta
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     param in p_cpregun  : cdigo de la pregunta
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_datos_asegurados
     param in p_sseguro  : cdigo del seguro
     param in p_nriesgo  : cdigo del riesgo
     param in p_cidioma  : cdigo de idioma
     param in p_simul    : 1:proyecto / 0:emision
     param in p_mode     : POL' / 'EST'
     return              : texto
   *************************************************************************/
   FUNCTION f_datos_asegurados(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_simul IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_dniconductor
     param in p_sseguro  : cdigo del seguro
     param in pnorden   : cdigo de orden
     return              : texto
   *************************************************************************/
   FUNCTION f_dniconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_nacimconduct
     param in p_sseguro  : cdigo del seguro
     param in pnorden   : cdigo de orden
     return              : texto
   *************************************************************************/
   FUNCTION f_nacimconduct(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_fcarnetconduct
     param in p_sseguro  : cdigo del seguro
     param in pnorden   : cdigo de orden
     return              : texto
   *************************************************************************/
   FUNCTION f_fcarnetconduct(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_fcarnetconduct
     param in p_sseguro  : cdigo del seguro
     param in pnorden   : cdigo de orden
     return              : texto
   *************************************************************************/
   FUNCTION f_cpconductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_version
     param in p_sseguro  : cdigo del seguro
     param in priesgo   : cdigo de riesgo
     return              : texto
   *************************************************************************/
   FUNCTION f_version(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_importe
     param in p_sseguro  : cdigo del seguro
     param in priesgo   : cdigo de riesgo
     return              : texto
   *************************************************************************/
   FUNCTION f_importe(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_matriculacion
     param in p_sseguro  : cdigo del seguro
     param in priesgo   : cdigo de riesgo
     return              : texto
   *************************************************************************/
   FUNCTION f_matriculacion(psseguro IN NUMBER, priesgo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_fcarnettomador
     param in p_sseguro  : cdigo del seguro
     return              : texto
   *************************************************************************/
   FUNCTION f_fcarnettomador(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_direccion_conductor
     param in p_sseguro  : cdigo del seguro
     param in pnorden   : cdigo de orden
     return              : texto
   *************************************************************************/
   FUNCTION f_direccion_conductor(psseguro IN NUMBER, pnorden IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_respuesta
     param in p_sseguro  : cdigo del seguro
     param in p_nmovimi  : cdigo del movimiento
     param in p_cpregun  : cdigo de la pregunta
     return              : texto
   *************************************************************************/
   FUNCTION f_respuesta_pol(
      p_sseguro IN NUMBER,
      p_nmovimi IN NUMBER,
      p_cpregun IN NUMBER,
      p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_requisits_mdics
     param in pfnacimi   : Data Naixement
     param in pCapital   : Capital assegurat
     return              : text: Retorna els requsits mnims per aquesta edat i aquests capital.
   *************************************************************************/
   FUNCTION f_requisits_medics(pfnacimi IN DATE, pcapital IN NUMBER)
      RETURN VARCHAR;

      --ETM INI BUG--18606
/*************************************************************************
     FUNCTION f_import_garantias
    param in p_sseguro  : cdigo del seguro
     param in pcidioma  : cdigo de idioma
     param in pnriesgo  : riesgo
     param in pnrecibo   : recibo
     param in pconcept  :concepto
     return              : number devuelve el importe de los diferentes conceptos(prima, isi...)
  *****************************************************************************/
   FUNCTION f_import_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      pconcept IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

       /*************************************************************************
      FUNCTION  f_total_import_garantias
     param in p_sseguro  : cdigo del seguro
      param in pcidioma  : cdigo de idioma
      param in pnriesgo  : riesgo
      param in pnrecibo   : recibo
     return              : number devuelve el total del importe de los diferentes conceptos(prima, isi...)
   *****************************************************************************/
   FUNCTION f_total_import_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   /*************************************************************************
       FUNCTION  f_import_comis_garantias
      param in p_sseguro  : cdigo del seguro
       param in pcidioma  : cdigo de idioma
       param in pnriesgo  : riesgo
       param in pnrecibo   : recibo
       param in ptotal    : 0 comision de garantias
      return              : number devuelve el importe comision de las garantias
    *****************************************************************************/
   FUNCTION f_import_comis_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION  f_import_liquidar_garantias
     param in p_sseguro  : cdigo del seguro
      param in pcidioma  : cdigo de idioma
      param in pnriesgo  : riesgo
      param in pnrecibo   : recibo
      param in ptotal    : 0 comision de garantias
     return              : number devuelve el importe a liquidar de las garantias
   *****************************************************************************/
   FUNCTION f_import_liquidar_garantias(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pnrecibo IN NUMBER,
      ptotal IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

--etm fin --18606

   --bug 18835--etm--ini
   /*************************************************************************
        FUNCTION  f_fefecto_recibo
       param in p_sseguro  : cdigo del seguro
      return              : la fecha efecto del recibo
     *****************************************************************************/
   FUNCTION f_fefecto_recibo(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
        FUNCTION  f_fvencim_recibo
       param in p_sseguro  : cdigo del seguro
      return              : la fecha vencimiento del recibo
     *****************************************************************************/
   FUNCTION f_fvencim_recibo(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

--FIN --bug 18835--etm

   /*****************************************************************
    F_DESCSUPLEMENTOS: Retorna los suplementos
    param p_sseguro IN  : sseguro
    param p_nriesgo IN  : numero de riesgo
    param p_cidioma IN  : idioma
    param pctipo IN : 1 - Descripcion suplementos 2- Estado anterior 3-Estado actual
    return              : VARCHAR2

     Bug 18874/89912 - 18/07/2011- AMC
   ******************************************************************/
   FUNCTION f_descsuplementos(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcidioma IN NUMBER,
      pctipo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      FUNCTION f_conreb_unifi
      Recupera los diferentes importes de un recibo teniendo en cuenta si est unificado
      param in pnrecibo   : nmero de recibo
      param in pcampo     : nmero de campo que se quiere recuperar
      return             : importe del campo requerido
      *************************************************************************/
   FUNCTION f_conreb_unifi(pnrecibo IN NUMBER, pcampo IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_docs_sini
     param in p_nsinies  : cdigo del siniestro
     param in p_cidioma  : cdigo de idioma
     return              : texto
   *************************************************************************/
   FUNCTION f_docs_sini(p_nsinies IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
     FUNCTION f_declarante
     param in p_nsinies  : cdigo del siniestro
     return              : texto

     Bug 19389/91837 - 07/09/2011 - AMC
   *************************************************************************/
   FUNCTION f_declarante(p_nsinies IN NUMBER)
      RETURN VARCHAR2;

   -- BUG18682:DRA:04/07/2011:Inici
   /*****************************************************************
    F_RESP_RIE: Retorna la resposta de les preguntes de tots els riscos
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   -- BUG18682:DRA:04/07/2011:Inici
   /*****************************************************************
    F_RESP_RIE_MDEC: Retorna la resposta de les preguntes de tots els riscos, mascara de format amb 10 decimals
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie_mdec(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
    F_CAP_RIE: Retorna el capital assegurat de tots els riscos
    param p_sseguro IN        : sseguro
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_cap_rie(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
      p_columna IN VARCHAR2 DEFAULT 'ICAPASE')
      RETURN VARCHAR2;

   /*****************************************************************
    F_CAP_TOT: Retorna la suma del capital assegurat de tots els riscos
    param p_sseguro IN        : sseguro
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_cap_tot(
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_cgarant IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL',
      p_columna IN VARCHAR2 DEFAULT 'ICAPASE')
      RETURN VARCHAR2;

-- BUG18682:DRA:04/07/2011:Fi

   -- BUG 19322 - 28/09/2011 - JMP
   /*****************************************************************
    FUNCTION F_IUNIACT_FECHA:
      Calcula el valor unitari de les aportacions d'una assegurana
      a una data determinada.

    param IN psseguro  : sseguro
    param IN pfecha    : data del valor
    return             : valor unitari de les aportacions
    ******************************************************************/
   FUNCTION f_iuniact_fecha(psseguro IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   /*****************************************************************
    FUNCTION F_SUMAPOR_TIPUS:
      Calcula la suma d'aportacions donats una assegurana, un
      interval de dates i un tipus d'aportaci.

    param IN psseguro  : sseguro
    param IN pfecini   : data d'inici
    param IN pfecfin   : data de fi
    param IN pctipapor : tipus d'aportaci
                           E - Empresa
                           P - Partcep
    return             : suma d'aportacions
    ******************************************************************/
   FUNCTION f_sumapor_tipus(
      psseguro IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pctipapor IN VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************
    FUNCTION F_VALAPOR_TIPUS:
      Calcula el valor de les aportacions donats una assegurana, un
      interval de dates i un tipus d'aportaci.

    param IN psseguro  : sseguro
    param IN pfecini   : data d'inici
    param IN pfecfin   : data de fi
    param IN pctipapor : tipus d'aportaci
                           E - Empresa
                           P - Partcep
    return             : valor de les aportacions
    ******************************************************************/
   FUNCTION f_valapor_tipus(
      psseguro IN NUMBER,
      pfecini IN DATE,
      pfecfin IN DATE,
      pctipapor IN VARCHAR2)
      RETURN NUMBER;

   /*****************************************************************
    FUNCTION F_CALC_RENDIMENT:
      Calcula el rendiment de les aportacions d'una assegurana a una
      data determinada

     param IN psseguro   : sseguro
     param IN pfecha     : data de clcul
     param IN ptipo      : 1 - El rendiment es calcula sobre la suma
                               d'aportacions des de l'inici
                           2 - El rendiment es calcula sobre la suma
                               d'aportacions en un any
     param IN pctipapor  : tipus d'aportacions
                           E - Empresa
                           P - Partcep
     return              : rendiment
    ******************************************************************/
   FUNCTION f_calc_rendiment(
      psseguro IN NUMBER,
      pfecha IN DATE,
      ptipo IN NUMBER,
      pctipapor IN VARCHAR2)
      RETURN VARCHAR2;

-- FIN BUG 19322 - 28/09/2011 - JMP

   /*****************************************************************
   FUNCTION f_get_riesgos
     Devuelve la naturaleza de los riesgos de la pliza

    param IN psseguro   : sseguro
    return              : rendiment

    Bug 19726/94425 - 11/10/2011 - AMC
   ******************************************************************/
   FUNCTION f_get_riesgos(psseguro IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_sobreprecio
     Devuelve los sobreprecios

    param IN psseguro   : sseguro
    param IN p_cpregum  : codi pregunta
   param IN p_nmovimi  : numero moviment
   param IN p_idioma   : idioma
   param IN p_mode    : modo en que se llama
    return              : rendiment

    Bug 19726/94425 - 11/10/2011 - AMC
   ******************************************************************/
   FUNCTION f_get_sobreprecio(
      psseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_cpregun2 IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_sobreprecio
     Devuelve los sobreprecios

    param IN pcempres  : codigo de empresa
    param IN pcagente  : codi de agente
   param IN pmodo  : 1-Nombre padre 2-Tipo Agente
   param IN pcidioma   : idioma
   return              : descripcion

    Bug 19726/94425 - 11/10/2011 - AMC
   ******************************************************************/
   FUNCTION f_get_mediador(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      pmodo IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_garantias_riesgo
     Devuelve las garantas de un riesgo

    param IN psseguro  : codigo de seguro
    param IN pnriesgo  : nmero de riesgo
    param IN pcidioma  : codigo de idioma
    param IN pmodo     : modo EST/POL
    return             : texto con las garantas del riesgo

    Bug 19780 - 21/10/2011 - JMP
   ******************************************************************/
   FUNCTION f_garantias_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pcidioma IN NUMBER DEFAULT 1,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_capitales_riesgo
     Devuelve los capitales de un riesgo

    param IN psseguro  : codigo de seguro
    param IN pnriesgo  : nmero de riesgo
    param IN pmodo     : modo EST/POL
    return             : texto con los capitales del riesgo

    Bug 19780 - 21/10/2011 - JMP
   ******************************************************************/
   FUNCTION f_capitales_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT 1,
      pmodo IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   --Bug 0019726 - MDS - 27/10/2011 - devolver todos los riesgos, mediante distinct
   FUNCTION f_titgarantias_distinct(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pseparador IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_sobreprecio_riesgo
     Devuelve el sobreprecio de un riesgo

    param IN psseguro   : sseguro
    param IN p_cpregum  : codigo pregunta
    param IN p_nmovimi  : numero movimiento
    param IN p_idioma   : idioma
    param IN p_mode     : modo en que se llama
    param IN p_nriesgo  : nmero de riesgo
    return              : sobreprecio

    Bug 21873 - 10/04/2012 - MDS
   ******************************************************************/
   FUNCTION f_get_sobreprecio_riesgo(
      psseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_cpregun2 IN NUMBER,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2,
      p_nriesgo IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION ff_numlet

    Funcin que llama F_NUMLET (para que devuelva directamente el importe en letras)

    Bug 21873 - 10/04/2012 - MDS
   ******************************************************************/
   FUNCTION ff_numlet(nidioma IN NUMBER, np_nume IN NUMBER, moneda IN VARCHAR2)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION ff_nombre

   Funcin que llama F_NOMBRE

   Bug 22088 - 30/04/2012 - MDS
   ******************************************************************/
   FUNCTION ff_nombre(
      psperson IN NUMBER,
      pnformat IN NUMBER,
      pcagente IN agentes.cagente%TYPE DEFAULT NULL)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_respuesta_pol

   Funcin que devuelve la respuesta de una pregunta de una pliza

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pcpregun  : cdigo de pregunta
     param IN pcidioma  : cdigo de idioma
     param IN ptippre   : modo de tipo de pregunta
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuesta_pol(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_respuestas_pol

   Funcin que devuelve las respuestas de unas preguntas de una pliza

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pcpregun1 : cdigo de pregunta
     param IN pcpregun2 : cdigo de pregunta
     param IN pcpregun3 : cdigo de pregunta
     param IN pcpregun4 : cdigo de pregunta
     param IN pcpregun5 : cdigo de pregunta
     param IN pcidioma  : cdigo de idioma
     param IN ptippre   : modo de tipo de pregunta
    param IN p_mode 'POL' EST)   --22009
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuestas_pol(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun1 IN NUMBER,
      pcpregun2 IN NUMBER,
      pcpregun3 IN NUMBER,
      pcpregun4 IN NUMBER,
      pcpregun5 IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')   --22009
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_desglose_garant

   Funcin que devuelve el desglose de una garanta de una pliza

     param IN psseguro  : cdigo de seguro
     param IN pnriesgo  : nmero de riesgo
     param IN pcgarant  : cdigo de garanta
     param IN pnmovimi  : nmero de movimiento
     return             : Desglose de garantas

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_desglose_garant(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_respuesta_garan

   Funcin que devuelve la respuesta de una pregunta de una garantia

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pcpregun  : cdigo de pregunta
     param IN pcgarant  : cdigo de garanta
     param IN pcidioma  : cdigo de idioma
     param IN ptippre   : modo de tipo de pregunta
     return             : Texto de la respuesta

   Bug 22009 - 04/06/20102 - MDS
   ******************************************************************/
   FUNCTION f_get_respuesta_garan(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcgarant IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

    /*****************************************************************
    Funcin que devuelve el cdigo del condicionado particular

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pcpregun  : cdigo de pregunta
     return             : cdigo del condicionado

     Bug 22936/118962- 18/07/20102 - AMC
   ******************************************************************/
   FUNCTION f_get_cod_condparticular(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER)
      RETURN VARCHAR2;

    /*****************************************************************
    Funcin que devuelve el parmetros de las Clausulas Entidad / Prestamo

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pnriesgo  : numero de riesgo
     param IN pnsclagen : secuencia clasula
     param IN pnparame  : nmero de parmetro
     return             : Texto del parmetro de la clausula

     Bug 22009/119279- 02/08/20102 - LCF
   ******************************************************************/
   FUNCTION f_get_param_clau(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pnsclagen IN NUMBER,
      pnparame IN NUMBER)
      RETURN VARCHAR2;

   /*****************************************************************
   FUNCTION f_get_respuestas_gar

   Funcin que devuelve las respuestas de unas preguntas de una pliza

     param IN psseguro  : cdigo de seguro
     param IN pnmovimi  : nmero de movimiento
     param IN pcpregun1 : cdigo de pregunta
     param IN pcpregun2 : cdigo de pregunta
     param IN pcpregun3 : cdigo de pregunta
     param IN pcpregun4 : cdigo de pregunta
     param IN pcpregun5 : cdigo de pregunta
     param IN pcidioma  : cdigo de idioma
     param IN ptippre   : modo de tipo de pregunta
    param IN p_mode 'POL' EST)   --22009
     return             : Texto de la respuesta

   ******************************************************************/
   FUNCTION f_get_respuestas_gar(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun1 IN NUMBER,
      pcpregun2 IN NUMBER,
      pcpregun3 IN NUMBER,
      pcpregun4 IN NUMBER,
      pcpregun5 IN NUMBER,
      pcidioma IN NUMBER,
      ptippre IN NUMBER DEFAULT NULL,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   --Bug 24598 - XVM - 27/12/2012
   FUNCTION f_tratamiento(
      p_sperson IN NUMBER,
      p_idioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   --Bug 24813 - RDD - 16/02/2013
   FUNCTION f_calc_formula_agente(
      pcagente IN NUMBER,
      pclave IN NUMBER,
      pfecefe IN DATE,
      psproduc IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_total_rec(p_sseguro IN NUMBER)
      RETURN VARCHAR2;

   -- Inico BUG31135:MMS:18/08/2014
   /*****************************************************************
    F_RESP_RIE: Retorna la resposta de les preguntes de tots els riscos
    Modificacin utilizada en el PAC_INFORMES
    param p_sseguro IN        : sseguro
    param p_cpregum IN        : codi pregunta
    param p_nmovimi IN        : numero moviment
    param p_idioma  IN        : idioma
    param p_mode    IN        : modo en que se llama
          return              : VARCHAR2
    ******************************************************************/
   FUNCTION f_resp_rie_inf(
      p_sseguro IN NUMBER,
      p_cpregun IN NUMBER,
      p_nriesgo IN NUMBER DEFAULT NULL,
      p_nmovimi IN NUMBER DEFAULT 1,
      p_cidioma IN NUMBER DEFAULT 1,
      p_mode IN VARCHAR2 DEFAULT 'POL')
      RETURN VARCHAR2;

   FUNCTION f_lee_pregunta(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;
-- Fin BUG31135:MMS:18/08/2014

   FUNCTION f_cantidad_garantias_poliza(
      psseguro IN NUMBER,
      pcvalpar IN NUMBER,
      ptipo    IN NUMBER)
      RETURN NUMBER;

-- Inico GE-FO-18-02 15/11/2018
   FUNCTION f_pais_abreviatura(
      ppais IN NUMBER)
      RETURN VARCHAR2;
-- Fin GE-FO-18-02 15/11/2018               

-- INI BUG 3324 - SGM Interaccin del Rango DIAN con la pliza (No. Certificado)
    FUNCTION f_certifdian(
        psseguro IN SEGUROS.SSEGURO%TYPE,
        pnmovimi IN MOVSEGURO.NMOVIMI%TYPE
    )   RETURN VARCHAR2;

    FUNCTION f_resoldian(
        psseguro IN SEGUROS.SSEGURO%TYPE,
        pnmovimi IN MOVSEGURO.NMOVIMI%TYPE
    )   RETURN VARCHAR2; 
-- FIN BUG 3324 - SGM Interaccin del Rango DIAN con la pliza (No. Certificado)    
FUNCTION f_tipo_contrato(
        psseguro IN NUMBER,
        pnpoliza IN NUMBER,
        p_idioma IN NUMBER DEFAULT 1
    )   RETURN VARCHAR2;
-- FIN BUG 4167 - suscriptor para generar reporte de siniestros   

FUNCTION f_tercer_afectado( pnsinies IN NUMBER, pntramit  IN NUMBER )    
        RETURN VARCHAR2;
-- FIN BUG 4167 - nombre del tercer afectado   

 FUNCTION f_suscriptor(
        psseguro IN NUMBER,
        pnmovimi IN NUMBER
    )   RETURN VARCHAR2;
-- FIN BUG 4167 - obtener suscriptor   

FUNCTION f_sucursal(pcagente IN NUMBER )  
        RETURN VARCHAR2;
-- FIN BUG 4167 - nombre de la sucursal

FUNCTION f_get_coacuadro(p_sseguro IN NUMBER,
        p_tipo IN NUMBER) 
        RETURN VARCHAR2;
-- FIN BUG 4167 - obtener coaseguro de tabla coacuadro

FUNCTION f_get_coacedido(p_sseguro IN NUMBER,
        p_tipo IN NUMBER) 
        RETURN VARCHAR2;
-- FIN BUG 4167 - obtener coacedido de tabla coacuadro

--BUG 2485
FUNCTION f_num_letras(
        idioma IN NUMBER,
        numeros IN VARCHAR2
    )   RETURN VARCHAR2;
-- RETORNA EN LETRAS UN VALOR NUMERICO
--IAXIS-3152 :Changes for tipo de canal
 FUNCTION f_tipo_canal(
    psperson IN NUMBER
    )RETURN VARCHAR2;

/*Cambios de IAXIS-5337 : Start */
  FUNCTION F_PAISE_SAP(PI_SPERSON IN NUMBER) RETURN NUMBER;
/*Cambios de IAXIS-5337 : End */	


 FUNCTION F_INT_EXT_REPORTE (p_sseguro IN NUMBER,
                             p_valorca IN NUMBER,
                             p_identif   IN NUMBER)
     RETURN NUMBER;

END pac_isqlfor;
