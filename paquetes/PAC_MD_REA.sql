--------------------------------------------------------
--  DDL for Package PAC_MD_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_MD_REA" IS
/******************************************************************************
 /******************************************************************************
 NAME: AXIS_D10.pac_md_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2009                    1. Created this package body.
   2.0        17/06/2009    ETM             2. Se a??aden nuevas funciones--0010471: IAX - REA: Desarrollo PL de la consulta de cesiones
   3.0        18/06/2009    ETM             3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   4.0        02/09/2009    ICV             4. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   5.0        07/09/2009    ICV             5. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   6.0        29/10/2009    AMC             6. 0011605: CRE - Adaptar consulta de cessions als reemborsaments.
   7.0        30/10/2009    ICV             7. 0011353: CEM - Parametrizaci??n mantenimiento de contratos Reaseguro
   8.0        04/07/2011    APD             8. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
   9.0        23/05/2012    AVT             9. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
  10.0        20/08/2012    AVT             10.0022374: LCOL_A004-Mantenimiento de facultativo - Fase 2
  11.0        18/01/2013    AEG             11.0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  12.0        12/07/2013    KBR             12.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 23830/0140221)
  13.0        31/07/2013    ETM             13.0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
  14.0        23/08/2013    KBR             14.0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
  15.0        30/09/2013    RCL             15. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  16.0        09/10/2013    SHA             16.0028454: LCOL895-Añadir la compañ?a propia en la consulta y en el mantenimiento de las cuentas t?cnicas de reaseguro
  17.0        05/11/2013    RCL             17. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  18.0        11/11/2013    SHA             18.0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
  19.0        14/11/2013    DCT             19.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
  20.0        19/11/2013    JDS             20.0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
  21.0        21/01/2014    JAM             21. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  22.0        02/05/2014    KBR             22. 0025860: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones
  23.0        14/05/2014    AGG             23.0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
  23.0        12/06/2014    AGG             24.0031306: POSDE400-Id 80 - Bono por no reclamación
  25.0        18/07/2014    KBR             25. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  26.0        19/11/2015    DCT             26. 0038692   0038692: POSPT500-POS REASEGUROS CESIÓN DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
  27.0        02/09/2016   HRE              27. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
  28.0        15/07/2019    FEPP            28.IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo
  29.0        26/01/2020    INFORCOL        29 Reaseguro facultativo - ajuste para deposito en prima retenida
  30.0        26/05/2020    DFRP            30.IAXIS-5361: Modificar el facultativo antes de la emisión
******************************************************************************/
   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,
      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,
      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_version_rea(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_detallecab_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_codicontrato_rea;

   FUNCTION f_get_contratos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_contrato_rea;

   FUNCTION f_get_detalle_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_contrato_rea;

   FUNCTION f_get_tramos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea;

   FUNCTION f_get_dettramo_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_tramos_rea;

   FUNCTION f_get_cuadroces_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_cuadroces_rea;

   FUNCTION f_get_detcuadro_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pccompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_cuadroces_rea;

   /*************************************************************************
      Selecciona informaci??n sobre la cesiones
      param in pnpoliza   : n??mero de p??liza
      param in pncertif  : n??mero de certificado
      param in pnsinies  : n??mero de sinietro
      param in pnrecibo : n??mero de recibo
      param in pfefeini : fecha inicio efecto(Inicio rango)
      param in pfefefin : fecha fin efecto(Fin rango)
      param in pnreemb  : nA? de reembolso
      param out mensajes : mensajes de error

    BUG 10471 - 17/06/2009 - ETM - IAX : REA- Desarrollo PL de la consulta de cesiones
    Bug 11605 - 29/06/2009 - AMC - CRE - Adaptar consulta de cessions als reemborsaments.
   *************************************************************************/
   FUNCTION f_get_consulta_cesiones(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pnrecibo IN NUMBER,
      pfefeini IN DATE,
      pfefefin IN DATE,
      pnreemb IN NUMBER,
      pscumulo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Selecciona informaci??n sobre la cesiones de la poliza seleccionada
      param in psseguro   :  numero de seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_consulta_det_cesiones(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera informaci??n de cabecera de la cesiones por recibo para uno en concreto o para un movimiento de cesi??n anulizada
      param in pnmovimi  : n??mero de movimiento
      param in pnrecibo : n??mero de recibo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_recibos_ces(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera informaci??n en detalle de la cesiones por recibo
      param in psreaemi  : n??mero de psreaemi
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_datosrecibo_ces(psreaemi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*FIN BUG 10471 - 17/06/2009 - ETM */
/*BUG 10487 - 18/06/2009 - ETM - IAX : REA- Desarrollo PL del mantenimiento de Facultativo */
 /*************************************************************************
      Selecciona las cabeceras de cuadros facultativos
      param in ptempres   : C??digo y descripci??n de la empresa
      param in ptramo  : C??digo y descripci??n del ramo
      param in ptsproduc  : Descripci??n del producto
      param in pnpoliza  : n??mero de poliza
      param in pncertif  : Certificado
      param in psfacult  :  C??digo cuadro facultativo
      param in tcestado : C??digo y descripci??n del estado del cuadro
      param in pfefeini  :  Fecha inicio efecto(Inicio del rango)
      param in pfefefin  :  Fecha fin efecto(Fin del rango)
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuafacul_rea(
      ptempres IN NUMBER,
      ptramo IN NUMBER,
      ptsproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psfacult IN NUMBER,
      tcestado IN NUMBER,
      pfefeini IN DATE,
      pfefefin IN DATE,
      pscumulo IN NUMBER,
      pnsolici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la informaci??n en detalle para un cuadro
      param in psfacult   : C??digo de cuadro facultativo
      param in psseguro  : C??digo del Seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuafacul_det_rea(
      psfacult IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuafacul;

/*************************************************************************
      Recupera la informacion en detalle del cuadro de compa??ias que se reparten el riesgo
      param in psfacult   : C??digo de cuadro facultativo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_rea(psfacult IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera la informacion en detalle para una compa??ia reaseguradora en concreto
      param in psfacult   : C??digo de cuadro facultativo
      param in pccompani  : Compa??ia
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_det_rea(
      psfacult IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuacesfac;

   /*************************************************************************
        funcion que se encargar?! de guardar la informaci??n del detalle del cuadro de facultativo introducido.
        PSFACULT in NUMBER
        PCESTADO in NUMBER
        PFINCUF in DATE
        PPLOCAL in number
        PCCOMPANI in NUMBER
        PPCESION in NUMBER
        PICESFIJ in NUMBER
        PCCOMREA in NUMBER
        PPCOMISI in NUMBER
        PICOMFIG in NUMBER
        PISCONTA in NUMBER
        PPRESERV in NUMBER
        PCINTRES in NUMBER
        PINTRES in NUMBER
        param in out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_set_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
      pplocal IN NUMBER,
      pifacced IN NUMBER, -- IAXIS-5361 26/05/2020
      pccompani IN NUMBER,
      ppcesion IN NUMBER,
      picesfij IN NUMBER,
      pccomrea IN NUMBER,
      ppcomisi IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      -- INICIO INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      ppresrea IN NUMBER,
      -- FIN INFORCOL 26-01-2020 Reaseguro facultativo - ajuste para deposito en prima retenida
      pcintres IN NUMBER,
      pintres IN NUMBER,
      pctipfac IN NUMBER,   -- 20/08/2012 AVT 22374 CUAFACUL
      pptasaxl IN NUMBER,
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374 CUACESFAC
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,
      ptidfcom IN VARCHAR2,   -- 17-01-2013 AEG 25502
      psseguro IN NUMBER,   --BUG38692 19/11/2015 DCT
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 10487 : 18/06/2009 : ETM */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
         funci??n que se encargar?! de borrar un registro de compa???-a participante en el cuadro.
         PSFACULT in NUMBER
         PCESTADO in NUMBER
         PCCOMPANI in NUMBER
         param out mensajes : mensajes de error

    *************************************************************************/
   FUNCTION f_anula_cia_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pccompani IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 10487 : 02/09/2009 : ICV */

   /*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/
   /*************************************************************************
         funci??n que inserta o actualiza informaci??n en cuadroces.
         PCCOMPANI in number,  ob
         PNVERSIO in number, ob
         PSCONTRA in number, ob
         PCTRAMO in number,    ob
         PCCOMREA in number,
         PCESION in number,
         PNPLENOS in number,
         PICESFIJ in number,
         PICOMFIJ in number,
         PISCONTA in number,
         PRESERV in number,
         PINTRES in number,
         PILIACDE in number,
         PPAGOSL in number,
         PCORRED in number,
         PCINTRES in number,
         PCINTREF in number,
         PCRESREF in number,
         PIRESERV in number,
         PTASAJ in number,
         PFUTLIQ in date,
         PIAGREGA in number,
         PIMAXAGR in number,
           -- Bug 18319 - APD - 05/07/2011
           CTIPCOMIS in number,              Tipo Comisi??n
           PCTCOMIS in number,            % Comisi??n fija / provisional
           CTRAMOCOMISION in number,            Tramo comisi??n variable
           -- fin Bug 18319 - APD - 05/07/2011
         mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      pccomrea IN NUMBER,
      ppcesion IN NUMBER,
      pnplenos IN NUMBER,
      picesfij IN NUMBER,
      picomfij IN NUMBER,
      pisconta IN NUMBER,
      ppreserv IN NUMBER,
      ppintres IN NUMBER,
      piliacde IN NUMBER,
      pppagosl IN NUMBER,
      pccorred IN NUMBER,
      pcintres IN NUMBER,
      pcintref IN NUMBER,
      pcresref IN NUMBER,
      pireserv IN NUMBER,
      pptasaj IN NUMBER,
      pfutliq IN DATE,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 05/07/2011
      pctipcomis IN NUMBER,   -- Tipo Comisi??n
      ppctcomis IN NUMBER,   -- % Comisi??n fija / provisional
      pctramocomision IN NUMBER,   --Tramo comisi??n variable
      pctgastosrea    IN NUMBER,   --% Gastos Reasegurador (CONF-587)
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         funci??n que inserta o actualiza informaci??n en tramos.
        --TRAMOS
        PNVERSIO in number--pk
        PSCONTRA in number,--pk
        PCTRAMO in number,--pk
        PITOTTRA in number,
        PNPLENOS in number,
        PCFREBOR in number,--not null
        PLOCAL in number,
        PIXLPRIO in number,
        PIXLEXCE in number,
        PSLPRIO in number,
        PPSLEXCE in number,
        PNCESION in number,
        FULTBOR in date,
        PIMAXPLO in number,
        PNORDEN in number,--not null
        PNSEGCON in number,
        PNSEGVER in number,
        PIMINXL in number,
        PIDEPXL in number,
        PNCTRXL in number,
        PNVERXL in number,
        PTASAXL in number,
        PIPMD in number,
        PCFREPMD in number,
        PCAPLIXL in number,
        PPLIMGAS in number,
        PLIMINX in number,
      -- Bug 18319 - APD - 04/04/2011
      pidaa IN NUMBER,   -- Deducible anual
      pilaa IN NUMBER,   -- L?-mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci??n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep??sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep??sito XL
      ppctminxl IN NUMBER,   -- % Prima M?-nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A??os Loss Corridor
      pclosscorridor IN NUMBER,   -- C??digo cl?!usula Loss Corridor
      pcappedratio IN NUMBER,   -- C??digo cl?!usula Capped Ratio
      pcrepos IN NUMBER,   -- C??digo Reposici??n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci??n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctdep IN NUMBER,   -- % Dep??sito de primas
      pcforpagdep IN NUMBER,   -- Periodo devoluci??n de. primas
      pintdep IN NUMBER,   -- Intereses sobre dep??sito de primas
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg??n coaseguro
      -- Fin Bug 18319 - APD - 04/04/2011
        mensajes IN OUT t_iax_mensajes
    *************************************************************************/
   FUNCTION f_set_tramos(
      pnversio IN NUMBER,   --pk
      pscontra IN NUMBER,   --pk
      pctramo IN NUMBER,   --pk
      pitottra IN NUMBER,
      pnplenos IN NUMBER,
      pcfrebor IN NUMBER,   --not null
      pplocal IN NUMBER,
      pixlprio IN NUMBER,
      pixlexce IN NUMBER,
      ppslprio IN NUMBER,
      ppslexce IN NUMBER,
      pncesion IN NUMBER,
      pfultbor IN DATE,
      pimaxplo IN NUMBER,
      pnorden IN NUMBER,   --not null
      pnsegcon IN NUMBER,
      pnsegver IN NUMBER,
      piminxl IN NUMBER,
      pidepxl IN NUMBER,
      pnctrxl IN NUMBER,
      pnverxl IN NUMBER,
      pptasaxl IN NUMBER,
      pipmd IN NUMBER,
      pcfrepmd IN NUMBER,
      pcaplixl IN NUMBER,
      pplimgas IN NUMBER,
      ppliminx IN NUMBER,
      -- Bug 18319 - APD - 04/04/2011
      pidaa IN NUMBER,   -- Deducible anual
      pilaa IN NUMBER,   -- L?-mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci??n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep??sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep??sito XL
      ppctminxl IN NUMBER,   -- % Prima M?-nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A??os Loss Corridor
      pclosscorridor IN NUMBER,   -- C??digo cl?!usula Loss Corridor
      pccappedratio IN NUMBER,   -- C??digo cl?!usula Capped Ratio
      pcrepos IN NUMBER,   -- C??digo Reposici??n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci??n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg??n coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisión de intermediación
      -- Fin Bug 18319 - APD - 04/04/2011
      pptramo      IN NUMBER,--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - se adiciona ppreest --
      ppiprio IN NUMBER,--Agregar campo prioridad tramo IAXIS-4611
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
       funci??n que inserta o actualiza informaci??n en contratos.
       PSCONTRA in number,
       PNVERSIO in number,
       PNPRIORI in number, --not null
       PFCONINI in date, --not null
       PNCONREL in number,
       PFCONFIN in date,
       PIAUTORI in number,
       PIRETENC in number,
       PIMINCES in number,
       PICAPACI in number,
       PIPRIOXL in number,
       PPPRIOSL in number,
       PTCONTRA in varchar2,
       PTOBSERV in varchar2,
       PPCEDIDO in number,
       PPRIESGOS in number,
       PPDESCUENTO in number,
       PPGASTOS in number,
       PPARTBENE in number,
       PCREAFAC in number,
       PPCESEXT in number,
       PCGARREL in number,
       PCFRECUL in number,
       PSCONQP in number,
       PNVERQP in number,
       PIAGREGA in number, comunes con cuadroces
       PIMAXAGR in number
      -- Bug 18319 - APD - 04/07/2011
      pclavecbr NUMBER,   -- F??rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi??n
      pnanyosloss NUMBER,   -- A??os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?!lculo XL
      pclosscorridor NUMBER,   -- C??digo cl?!usula Loss Corridor
      pccappedratio NUMBER,   -- C??digo cl?!usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci??n
      pcestado NUMBER,   --Estado de la versi??n
      -- Fin Bug 18319 - APD - 04/07/2011
       mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_contratos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pnpriori IN NUMBER,   --not null
      pfconini IN DATE,   --not null
      pnconrel IN NUMBER,
      pfconfin IN DATE,
      piautori IN NUMBER,
      piretenc IN NUMBER,
      piminces IN NUMBER,
      picapaci IN NUMBER,
      piprioxl IN NUMBER,
      pppriosl IN NUMBER,
      ptcontra IN VARCHAR2,
      ptobserv IN VARCHAR2,
      ppcedido IN NUMBER,
      ppriesgos IN NUMBER,
      ppdescuento IN NUMBER,
      ppgastos IN NUMBER,
      pppartbene IN NUMBER,
      pcreafac IN NUMBER,
      ppcesext IN NUMBER,
      pcgarrel IN NUMBER,
      pcfrecul IN NUMBER,
      psconqp IN NUMBER,
      pnverqp IN NUMBER,
      piagrega IN NUMBER,
      pimaxagr IN NUMBER,
      -- Bug 18319 - APD - 04/07/2011
      pclavecbr NUMBER,   -- F??rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi??n
      pnanyosloss NUMBER,   -- A??os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?!lculo XL
      pclosscorridor NUMBER,   -- C??digo cl?!usula Loss Corridor
      pccappedratio NUMBER,   -- C??digo cl?!usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci??n
      pcestado NUMBER,   --Estado de la versi??n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci??n
      pncompext NUMBER,   --% Comisión extra prima (solo para POSITIVA)
	  pnretpol in NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL 
      pnretcul in NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      -- Fin Bug 18319 - APD - 04/07/2011
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
       funci??n que inserta o actualiza informaci??n en codicontratos.
       PSCONTRA in number,--pk
       PSPLENO in number,
       PCEMPRES in number, --not null,
       PCTIPREA in number, --not null
       PFINICTR in date, -- not null
       PCRAMO in number,
       PCACTIVI in number,
       PCMODALI in number,
       PCCOLECT in number,
       PCTIPSEG in number,
       PCGARANT in number,
       PFFINCTR in date
       PNCONREL in number,
       PSCONAGR in number,
       PCVIDAGA in number,
       PCVIDAIR in number,
       PCTIPCUM in number,
       PCVALID in number
       PCMONEDA in varchar  -- Bug 18319 - APD - 04/07/2011
       PTDESCRIPCION in varchar  -- Bug 18319 - APD - 04/07/2011
       mensajes IN OUT t_iax_mensajes
   *************************************************************************/
   FUNCTION f_set_codicontratos(
      pscontra IN NUMBER,   --pk
      pspleno IN NUMBER,
      pcempres IN NUMBER,   --not null,
      pctiprea IN NUMBER,   --not null
      pfinictr IN DATE,   -- not null
      pcramo IN NUMBER,
      pcactivi IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      pcgarant IN NUMBER,
      pffinctr IN DATE,
      pnconrel IN NUMBER,
      psconagr IN NUMBER,
      pcvidaga IN NUMBER,
      pcvidair IN NUMBER,
      pctipcum IN NUMBER,
      pcvalid IN NUMBER,
      pcmoneda IN VARCHAR,   -- Bug 18319 - APD - 04/07/2011
      ptdescripcion IN VARCHAR,   -- Bug 18319 - APD - 04/07/2011
      pcdevento IN NUMBER,
      pnversio IN NUMBER,   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
      -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS

    /*************************************************************************
      Funci?? per consultar els riscs que formen part d'un c??mul quan el SCUMULO del quadre estigui informat
      pscumulo in number
      mensajes in out t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_reariesgos(pscumulo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*FIN BUG 10990 : 07/09/2009 : ICV */

   /*BUG 11353 - 12/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
    /*************************************************************************
    Funci??n que inserta o modifica un contrato incluyendo TRAMOS, CUADROS
   *************************************************************************/
   FUNCTION f_set_contrato_rea(
      pscontra NUMBER,   -- Secuencia del contrato
      pspleno NUMBER,   -- Identificador del pleno
      pcempres NUMBER,   -- C??digo de empresa
      pctiprea NUMBER,   -- C??digo tipo contrato
      pcramo NUMBER,   -- C??digo de ramo
      pcmodali NUMBER,   -- C??digo de modalidad
      pctipseg NUMBER,   -- C??digo de tipo de seguro
      pccolect NUMBER,   -- C??digo de colectivo
      pcactivi NUMBER,   -- Actividad
      pcgarant NUMBER,   -- C??digo de garant?-a
      pcvidaga NUMBER,   -- C??digo de forma de c?!lculo
      psconagr NUMBER,
      pcvidair NUMBER,
      pctipcum NUMBER,
      pcvalid NUMBER,
      pnversio NUMBER,   -- N??mero versi??n contrato reas.
      pnpriori NUMBER,   -- Porcentaje local asumible
      pfconini DATE,   -- Fecha inicial de versi??n
      pnconrel NUMBER,   -- Contrato relacionado
      pfconfin DATE,   -- Fecha final de versi??n
      piautori NUMBER,   -- Importe con autorizaci??n
      piretenc NUMBER,   -- Importe pleno neto de retenci??n
      piminces NUMBER,   -- Importe m?-nimo cesi??n (Pleno neto de retenci??n)
      picapaci NUMBER,   -- Importe de capacidad m?!xima
      piprioxl NUMBER,   -- Importe prioridad XL
      pppriosl NUMBER,   -- Prioridad SL
      ptobserv VARCHAR2,   -- Observaciones varias
      ppcedido NUMBER,   -- Porcentaje cedido
      ppriesgos NUMBER,   -- Porcentaje riesgos agravados
      ppdescuento NUMBER,   -- Porcentaje de descuenctros de selecci??n
      ppgastos NUMBER,   -- Porcentaje de gastos (PB)
      pppartbene NUMBER,   -- Porcentaje de participaci??n en beneficios (PB)
      pcreafac NUMBER,   -- C??digo de facultativo
      ppcesext NUMBER,   -- Porcentaje de cesi??n sobre la extraprima
      pcgarrel NUMBER,   -- C??digo de la garant?-a relacionada
      pcfrecul NUMBER,   -- Frecuencia de liquidaci??n con cia
      psconqp NUMBER,   -- Contrato CP relacionado
      pnverqp NUMBER,   -- Versi??n CP relacionado
      piagrega NUMBER,   -- Importe agregado XL
      pimaxagr NUMBER,   -- Importe agregado m?!ximo XL (L.A.A.)
      ptcontra VARCHAR2,
      p_tobtramos t_iax_tramos_rea,
      -- Bug 18319 - APD - 04/07/2011
      pcmoneda IN VARCHAR,   -- Codigo de la moneda
      ptdescripcion IN VARCHAR,   -- Descripcion del contrato
      pclavecbr NUMBER,   -- F??rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi??n
      pnanyosloss NUMBER,   -- A??os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?!lculo XL
      pclosscorridor NUMBER,   -- C??digo cl?!usula Loss Corridor
      pccappedratio NUMBER,   -- C??digo cl?!usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci??n
      pcestado NUMBER,   --Estado de la versi??n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci??n
      pcdevento IN NUMBER,
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   -- % Comisión extra prima (solo para POSITIVA)
	  pnretpol NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci??n que devuelve la ??ltima versi??n de un contrato.
   *************************************************************************/
   FUNCTION f_get_nversio(
      pscontra IN NUMBER,
      pnversio_datos OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funci??n que inicializa el objeto de BD en memoria
    *************************************************************************/
   FUNCTION f_set_t_tramo_mem(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea;

   /*************************************************************************
   Funci??n que inserta / actualiza las formulas del reaseguro
   *************************************************************************/
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      psproduc IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que inserta / actualiza las cuentas t??cnicas del reaseguro
   *************************************************************************/
   FUNCTION f_set_ctatecnica(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnctatec IN NUMBER,
      pcfrecul IN NUMBER,
      pcestado IN NUMBER,
      pfestado IN DATE,
      pfultimp IN DATE,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 11353 : 12/10/2009 : ICV */

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_tramos(
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que selecciona todas las cl?!usulas de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_clausulas_reas(
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que dada una cl?!usula de reaseguro, devuelve su descripci??n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que dada una cl?!usula de reaseguro, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que graba una cl?!usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda una descripci??n de una cl?!usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda un tramo de una cl?!usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      plim_inf IN NUMBER,
      plim_sup IN NUMBER,
      ppctpart IN NUMBER,
      ppctmin IN NUMBER,
      ppctmax IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que elimina una descripci??n una cl?!usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que elimina un tramo una cl?!usula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que selecciona todas las reposiciones
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_reposicion(pccodigo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que dada una reposicion, devuelve su descripci??n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que dada una reposicion, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
Funci??n que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda una descripci??n de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que elimina una reposici??n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que elimina un detalle de una reposici??n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que selecciona todas las asociaciones de productos a contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

-- BUG 28492 - FIN - DCT - 11/10/2013 - Añadir pilimsub

   /*************************************************************************
Funci??n que graba una asociacion
*************************************************************************/
-- BUG 28492 - INICIO - DCT - 11/10/2013 - Añadir pilimsub
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pilimsub IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
Funci??n que elimina una asociacion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_agr_contratos(
      pscontra IN NUMBER,
      psversion IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pccolect IN NUMBER,
      pctipseg IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que selecciona todas las asociaciones de f??rmulas a garant?-as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que graba una asociacion de f??rmulas a garant?-as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   -- 20/09/2011 - de momento no se crea esta funcion y se utiliza la funcion
   -- f_set_reaformula ya existente
/*
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
*/
   /*************************************************************************
   Funci??n que elimina una asociacion de f??rmulas a garant?-as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que selecciona todas las agrupaciones de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funci??n que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que recupera el objeto ob_iax_clausulas_reas.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_clausulas_reas(
      pccodigo IN NUMBER,   -- C??digo de la cl?!usula
      pobj_clausulas_reas OUT ob_iax_clausulas_reas,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funci??n que recupera el objeto ob_iax_reposicion.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_reposicion(
      pccodigo IN NUMBER,   -- C??digo de la reposicion
      pobj_reposicion OUT ob_iax_reposicion,
      mensajes IN OUT t_iax_mensajes,
      filtro_norden IN VARCHAR)
      RETURN NUMBER;

-- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la funcion del pac_rea y se pasa aqui.
   FUNCTION f_valida_contrato_rea(
      pctiprea IN NUMBER,
      piretenc IN NUMBER,
      picapaci IN NUMBER,
      p_tobtramos IN t_iax_tramos_rea,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que obtiene la lista de cuentas
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_ctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pcestado IN NUMBER DEFAULT 1,
      pciaprop IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que devuelve la cabecera de la cuenta tecnica de reaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_cab_movcta(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,   --23830 KBR 12/07/2013
      pnpoliza IN NUMBER,   --23830 KBR 12/07/2013
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT 27/12/2013
      pspagrea IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que devuelve las cuentas tecnicas de la reaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_movctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcestado IN NUMBER,
      pnpoliza IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,
      pspagrea IN NUMBER,
      pcheckall IN NUMBER DEFAULT 0,   --KBR 02/05/2014 Gap 81
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que elimina un movimiento manual de la cuenta tecnica del reaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_del_movctatecnica(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcconcep IN NUMBER,
      pnnumlin IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT 27/12/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que apunta en la tabla de liquidacion los importes pendientes de la cuenta tecnica del reaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      psproces IN NUMBER,
      pcliquidar IN NUMBER DEFAULT 0,
      pciaprop IN NUMBER DEFAULT NULL,
      pultimoreg IN NUMBER DEFAULT 0,   --KBR 18/07/2014
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
       Funcion que insertara o modificara un movimiento de cuenta tecnica en funcion del pmodo
   *************************************************************************/
   -- Bug 22076 - AVT - 25/05/2012 - se crea la funcion
   FUNCTION f_set_movctatecnica(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pfmovimi IN DATE,
      pfefecto IN DATE,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pcestado IN NUMBER,
      psproces IN NUMBER,
      pscesrea IN NUMBER,
      piimport_moncon IN NUMBER,
      pfcambio IN DATE,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pdescrip IN VARCHAR2,
      pdocumen IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN NUMBER,
      psidepag IN NUMBER DEFAULT NULL,   --QT-6164
      pciaprop IN NUMBER DEFAULT NULL,   --23830 DCT /AVT 27/12/2013
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/***************************************************************************
  Funci?n que retiene un movimiento de cuenta t?cnica para que no se liquide
****************************************************************************/
-- Bug 22076 - AVT - 21/06/2012 - se crea la funcion
   FUNCTION f_set_reten_liquida(
      pccompani IN NUMBER,
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
      pnnumlin IN NUMBER,
      pccorred IN NUMBER DEFAULT NULL,
      pcempres IN NUMBER DEFAULT NULL,
      psproduc IN NUMBER DEFAULT NULL,
      pfcierre IN DATE DEFAULT NULL,
      pestadonew IN NUMBER,
      pestadoold IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta función deberá realizar una llamada a la función de la capa de negocio pac_rea.f_inicializa_liquida_rea
    Parámetros
     Entrada :
       Pfperini NUMBER : Fecha inicio
       Pcempres NUMBER : Empresa

     Salida :
       Mensajes   T_IAX_MENSAJES

    Retorna : NUMBER con el número de proceso.
   ********************************************************************************/-- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
   FUNCTION f_get_movmanual_rea(
      pscontra IN NUMBER,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT 0,
      pnidout OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_insertar_movprevio(
      psproces IN NUMBER,
      pscontra IN NUMBER,
      pcempres IN empresas.cempres%TYPE DEFAULT pac_md_common.f_get_cxtempresa,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      ptdescrip IN VARCHAR2,
      pnidentif IN VARCHAR2,
      pcconcep IN NUMBER,
      pcdebhab IN NUMBER,
      piimport IN NUMBER,
      pnsinies IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcevento IN VARCHAR2,
      pcgarant IN NUMBER DEFAULT 0,
      pnidout IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_borrar_movprevio(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_graba_real_movmanual_rea(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion
   FUNCTION f_get_max_cod_reposicion(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_filtered_tramos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      filter_tramos IN VARCHAR,
      --filter_companias   IN VARCHAR,
      not_in IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_reposiciones_contrato(
      pccodigo IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_liquida(pspagrea IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_val_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pitotal IN NUMBER,
      pmoneda IN VARCHAR2,
      pcestpag IN NUMBER,
      piimporte OUT pagos_ctatec_rea.iimporte%TYPE,
      piimporte_moncon OUT pagos_ctatec_rea.iimporte_moncon%TYPE,
      pctipopag OUT pagos_ctatec_rea.ctipopag%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pitotal IN NUMBER,
      pmoneda IN VARCHAR2,
      pcestpag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_tramo_sin_bono(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_tramo_sin_bono;
     FUNCTION f_get_compani_doc(
               pccompani IN NUMBER,
               mensajes  IN OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;
     FUNCTION f_edit_compani_doc(
               pccompani  IN NUMBER,
               piddocgdx  IN NUMBER,
               pctipo     IN NUMBER,
               ptobserv   IN VARCHAR2,
               ptfilename IN VARCHAR2,
               pfcaduci   IN DATE,
               pfalta     IN DATE,
               mensajes   IN OUT t_iax_mensajes)
          RETURN NUMBER;
     FUNCTION f_ins_compani_doc(
               pccompani  IN NUMBER,
               piddocgdx  IN NUMBER,
               pctipo     IN NUMBER,
               ptobserv   IN VARCHAR2,
               ptfilename IN VARCHAR2,
               pfcaduci   IN DATE,
               pfalta     IN DATE,
               mensajes   IN OUT t_iax_mensajes)
          RETURN NUMBER;
          FUNCTION f_get_compani_docs(
               pccompani IN NUMBER,
               mensajes  IN OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;

   FUNCTION f_get_reaseguro_x_garantia(
      ptabla IN VARCHAR2,
      ppoliza IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pcgenera IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

  /***********************************************************************************************
        Función que indica si una Compañía reaseguradora se encuentra en Cut-Off -- CONF-910

   ********************************************************************************************  */
   FUNCTION f_compania_cutoff(p_ccompani     IN  NUMBER,
                              p_fecha        IN  DATE)
     RETURN VARCHAR2;

	 -- INI - EDBR - 13/06/2019 -  IAXIS4330
/*************************************************************************
      Recupera los trimestres de los dos últimos años
      param in pfinitrim   :  fecha de inicio de trimestre 
      param in pffintrim   :  fecha de fin de trimestre
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
    *************************************************************************/
    FUNCTION f_get_trimestres(
      pfinitrim IN DATE,
      pffintrim IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
-- FIN - EDBR - 13/06/2019 -  IAXIS4330

-- INI - EDBR - 18/06/2019 -  IAXIS4330
    /*************************************************************************
    Funcion que inserta o modifica el registro de patrimoinio tecnico 
   *************************************************************************/
   FUNCTION f_set_patri_tec(
      panio NUMBER,   -- año parametrizado del patrimonio
      ptrimestre NUMBER,   -- trimestre
      pmoneda VARCHAR2,   -- moneda
      pvalor NUMBER,   -- valor  
      pmovimi number,   --numero de moviento NULL nuevo registro ELSE update
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
      -- FIN - EDBR - 18/06/2019 -  IAXIS4330

      -- INI - EDBR - 19/06/2019 -  IAXIS4330
/*************************************************************************
      Recupera los registros de todos los moviementos de los patrimonios segun los parametros de año y trimestre
      param in pnanio   :  año 
      param in pntrim   :  ftrimestre
      param out mensajes  :  mesajes de error
      return              :  sys_refcursor
    *************************************************************************/
    FUNCTION f_get_hist_pat_tec(
      pnanio IN NUMBER,
      pntrim IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
-- FIN - EDBR - 19/06/2019 -  IAXIS4330
   /* INI - ML - 4549
    * f_activar_contrato: ACTIVA INDIVIDUALMENTE UN CONTRATO EN REASEGURO, TOMANDO LA ULTIMA VERSION VALIDA
   */
   FUNCTION f_activar_contrato(
      pscontra IN NUMBER)
      RETURN NUMBER;
END pac_md_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_REA" TO "PROGRAMADORESCSI";
