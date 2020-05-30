--------------------------------------------------------
--  DDL for Package PAC_IAX_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_IAX_REA" IS
/******************************************************************************
     NAME:       pac_iax_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2009                    1. Created this package body.
   2.0        17/06/2009    ETM             2. Se a?aden nuevas funciones--0010471: IAX - REA: Desarrollo PL de la consulta de cesiones
   3.0        18/06/2009    ETM             3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   4.0        02/09/2009    ICV             4. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   5.0        07/09/2009    ICV             5. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   6.0        29/10/2009    AMC             6. 0011605: CRE - Adaptar consulta de cessions als reemborsaments.
   7.0        30/10/2009    ICV             7. 0011353: CEM - Parametrizacion mantenimiento de contratos Reaseguro
   8.0        04/07/2011    APD             8. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
   9.0        23/05/2012    AVT             9. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
  10.0        20/08/2012    AVT             10.0022374: LCOL_A004-Mantenimiento de facultativo - Fase 2
  11.0        18/01/2013    AEG             11.0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
  12.0        12/07/2013    KBR             12.0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 23830/0140221)
  13.0        31/07/2013    ETM             13.0026444: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 150 -entidad economica de las agrupaciones (Fase3)
  14.0        23/08/2013    KBR             14.0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
  15.0        30/09/2013    RCL             15. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  16.0        09/10/2013    SHA             16.0028454: LCOL895-A¿adir la compa¿?a propia en la consulta y en el mantenimiento de las cuentas t?cnicas de reaseguro
  17.0        05/11/2013    RCL             17. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
  18.0        11/11/2013    SHA             18.0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
  19.0        14/11/2013    DCT             19.0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
  20.0        19/11/2013    JDS             20.0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
  21.0        21/01/2014    JAM             21. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
  22.0        02/05/2014    KBR             22. 0025860: (POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 81 - Monitorizacion tasas variables/comisiones
  23.0        14/05/2014    AGG             23.0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
  24.0        18/07/2014    KBR             24. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
  25.0        19/11/2015    DCT             25. 0038692   0038692: POSPT500-POS REASEGUROS CESI¿N DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
  26.0        02/09/2016   HRE              26. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
  27.0        15/07/2019    FEPP            27.IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo.
  28.0        26/01/2020    INFORCOL        28. Reaseguro facultativo - ajuste para deposito en prima retenida
  29.0        26/05/2020    DFRP            29.IAXIS-5361: Modificar el facultativo antes de la emisión
******************************************************************************/

   /*BUG 11353 - 30/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   v_tobtramos    t_iax_tramos_rea;
   v_new_scontra  NUMBER;

   /*FIN BUG 11353*/
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_contratos_rea_prod(
      pscontra IN NUMBER,
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pctiprea IN NUMBER,
      psconagr IN NUMBER,
      pccompani IN NUMBER,
      pcdevento IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_version_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_detallecab_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_codicontrato_rea;

   FUNCTION f_get_contratosvers_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN t_iax_contrato_rea;

   FUNCTION f_get_detalle_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_contrato_rea;

   FUNCTION f_get_tramos_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea;

   FUNCTION f_get_dettramo_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_tramos_rea;

   FUNCTION f_get_cuadroces_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_cuadroces_rea;

   FUNCTION f_get_detcuadro_rea(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuadroces_rea;

/*************************************************************************
      Selecciona informacion sobre la cesiones
      param in pnpoliza   : numero de poliza
      param in pncertif  : numero de certificado
      param in pnsinies  : numero de sinietro
      param in pnrecibo : numero de recibo
      param in pfefeini : fecha inicio efecto(Inicio rango)
      param in pfefefin : fecha fin efecto(Fin rango)
      param out mensajes : mensajes de error

    BUG 10471 - 17/06/2009 - ETM - IAX : REA- Desarrollo PL de la consulta de cesiones
    Bug 11605 - 29/06/2009 - AMC - CRE : Adaptar consulta de cessions als reemborsaments.
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
      Selecciona informacion sobre la cesiones de la poliza seleccionada
      param in psseguro   :  numero de seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_consulta_det_cesiones(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera informacion de cabecera de la cesiones por recibo para uno en concreto o para un movimiento de cesion anulizada
      param in pnmovimi  : numero de movimiento
      param in pnrecibo : numero de recibo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_recibos_ces(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
      Recupera informacion en detalle de la cesiones por recibo
      param in psreaemi  : numero de psreaemi
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_datosrecibo_ces(psreaemi IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*FIN BUG 10471 : 17/06/2009 : ETM */

   /*************************************************************************
        Selecciona las cabeceras de cuadros facultativos
        param in ptempres   : Codigo y descripcion de la empresa
        param in ptramo  : Codigo y descripcion del ramo
        param in ptsproduc  : Descripcion del producto
        param in pnpoliza  : numero de poliza
        param in pncertif  : Certificado
        param in psfacult  :  Codigo cuadro facultativo
        param in tcestado : Codigo y descripcion del estado del cuadro
        param in pfefeini  :  Fecha inicio efecto(Inicio del rango)
        param in pfefefin  :  Fecha fin efecto(Fin del rango)
        param out mensajes : mensajes de error

     *************************************************************************/
     /*BUG 10487 - 18/06/2009 - ETM - IAX : REA- Desarrollo PL del mantenimiento de Facultativo  */
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
      pnsolici IN NUMBER,   -- 22374 AVT 22/08/2012
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
      Recupera la informacion en detalle para un cuadro
      param in psfacult   : Codigo de cuadro facultativo
      param in psseguro  : Codigo del Seguro
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuafacul_det_rea(
      psfacult IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuafacul;

/*************************************************************************
      Recupera la informacion en detalle del cuadro de compa?ias que se reparten el riesgo
      param in psfacult   : Codigo de cuadro facultativo
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_rea(psfacult IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      Recupera la informacion en detalle para una compa?ia reaseguradora en concreto
      param in psfacult   : Codigo de cuadro facultativo
      param in pccompani  : Compa?ia
      param out mensajes : mensajes de error

   *************************************************************************/
   FUNCTION f_get_cuacesfac_det_rea(
      psfacult IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN ob_iax_cuacesfac;

     /*************************************************************************
        funcion que se encargara de guardar la informacion del detalle del cuadro de facultativo introducido.
        PSFACULT in NUMBER
        PCESTADO in NUMBER
        PFINCUF in DATE
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
        param out mensajes : mensajes de error

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
      ppimpint IN NUMBER,   -- bug: 25502  17-01-2013  AEG
      ptidfcom IN VARCHAR2,
      psseguro IN NUMBER,   --BUG38692 19/11/2015 DCT
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 10487 - 18/06/2009 - ETM   */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
          funcion que se encargara de borrar un registro de compa?ia participante en el cuadro.
          PSFACULT in NUMBER
          PCESTADO in NUMBER
          PCCOMPANI in NUMBER
          param out mensajes : mensajes de error

     *************************************************************************/
   FUNCTION f_anula_cia_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 10487 - 18/06/2009 - ICV */

   /*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/
     /*************************************************************************
           funcion que inserta o actualiza informacion en cuadroces.
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
           CTIPCOMIS in number,              Tipo Comision
           PCTCOMIS in number,            % Comision fija / provisional
           CTRAMOCOMISION in number,            Tramo comision variable
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
      pctipcomis IN NUMBER,   -- Tipo Comision
      ppctcomis IN NUMBER,   -- % Comision fija / provisional
      pctramocomision IN NUMBER,   --Tramo comision variable
      pctgastosrea    IN NUMBER,   --% Gastos Reasegurador (CONF-587)
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         funcion que inserta o actualiza informacion en tramos.
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
      pilaa IN NUMBER,   -- Limite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Deposito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl IN NUMBER,   -- % Prima Minima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- Codigo clausula Loss Corridor
      pcappedratio IN NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos IN NUMBER,   -- Codigo Reposicion Xl
      pibonorec IN NUMBER,   -- Bono Reclamacion
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctdep IN NUMBER,   -- % Deposito de primas
      pcforpagdep IN NUMBER,   -- Periodo devolucion de. primas
      pintdep IN NUMBER,   -- Intereses sobre deposito de primas
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad segun coaseguro
      -- Fin Bug 18319 - APD - 04/04/2011
        mensajes OUT t_iax_mensajes
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
      pilaa IN NUMBER,   -- Limite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Deposito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl IN NUMBER,   -- % Prima Minima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio IN NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos IN NUMBER,   -- Codigo Reposicion Xl
      pibonorec IN NUMBER,   -- Bono Reclamacion
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad segun coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisi¿n de intermediaci¿n
      -- Fin Bug 18319 - APD - 04/04/2011
      pptramo      IN NUMBER,--BUG CONF-250  Fecha (02/09/2016) - HRE - se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - se adiciona ppreest
      ppiprio IN NUMBER,--Agregar campo prioridad tramo IAXIS-4611
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
       funcion que inserta o actualiza informacion en contratos.
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
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      -- Fin Bug 18319 - APD - 04/07/2011
       mensajes OUT t_iax_mensajes
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
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      pnversioprot NUMBER,   -- Version del Contrato XL proteccion
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   --% Comisi¿n extra prima (solo para POSITIVA)
	  pnretpol NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

     /*************************************************************************
       funcion que inserta o actualiza informacion en codicontratos.
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
       mensajes OUT t_iax_mensajes
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
      pcdevento IN VARCHAR,
      pnversio IN NUMBER,   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
      -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS

   /*************************************************************************
      Funcio per consultar els riscs que formen part d'un cumul quan el SCUMULO del quadre estigui informat
      pscumulo in number
      mensajes out t_iax_mensajes
   *************************************************************************/
   FUNCTION f_get_reariesgos(pscumulo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*FIN BUG 10990 : 07/09/2009 : ICV */

   /*BUG 11353 - 30/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
     /*************************************************************************
        funcion graba en una variable global de la capa IAX los valores del objeto
        tramos_rea

       *************************************************************************/
   FUNCTION f_set_objetotramosrea(
      pnversio NUMBER,   -- Numero version contrato reas.
      pscontra NUMBER,   -- Secuencia del contrato
      pctramo NUMBER,   -- Codigo tramo
      pitottra NUMBER,   -- Importe total tramo
      pnplenos NUMBER,   -- Numero de plenos
      pcfrebor NUMBER,   -- Codigo frecuencia bordero
      pplocal NUMBER,   -- Porcentaje retencion local
      pixlprio NUMBER,   -- Importe prioridad XL
      pixlexce NUMBER,   -- Importe excedente XL
      ppslprio NUMBER,   -- Porcentaje prioridad SL
      ppslexce NUMBER,   -- Porcentaje excedente SL
      pncesion NUMBER,   -- Numero cesion
      pfultbor DATE,   -- Fecha ultimo bordero (cierre mensual)
      pimaxplo NUMBER,   -- Importe maximo retencion propia
      pnorden NUMBER,   -- orden de aplicacion de los tramos
      pnsegcon NUMBER,   -- Segundo contrato de proteccion
      piminxl NUMBER,   -- Prima minima para contratos XL
      pidepxl NUMBER,   -- Prima de deposito para contratos XL
      pnsegver NUMBER,   -- Version del segundo contrato de proteccion.
      pptasaxl NUMBER,   -- Porcentaje de l tasa aplicable para contratos XL
      pnctrxl NUMBER,   -- Contrato XL de preoteccion
      pnverxl NUMBER,   -- Version CTR. XL de proteccion
      pipmd NUMBER,   -- Importe Prima Minima Deposito XL
      pcfrepmd NUMBER,   -- Codigo frecuencia pago PMD
      pcaplixl NUMBER,   -- Aplica o no el limite por contrato del XL (0-Si, 1-No)
      pplimgas NUMBER,   -- Porcentaje de aumento del limite XL por gastos
      ppliminx NUMBER,   -- Porcentaje limite de aplicacion de la indexacion
      -- Bug 18319 - APD - 04/07/2011
      pidaa NUMBER,   -- Deducible anual
      pilaa NUMBER,   -- Limite agregado anual
      pctprimaxl NUMBER,   -- Tipo Prima XL
      piprimafijaxl NUMBER,   -- Prima fija XL
      piprimaestimada NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl NUMBER,   -- Campo aplicacion tasa XL
      pctiptasaxl NUMBER,   -- Tipo tasa XL
      pctramotasaxl NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl NUMBER,   -- % Prima Deposito
      pcforpagpdxl NUMBER,   -- Forma pago prima de deposito XL
      ppctminxl NUMBER,   -- % Prima Minima XL
      ppctpb NUMBER,   -- % PB
      pnanyosloss NUMBER,   -- A?os Loss Corridor
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pcrepos NUMBER,   -- Codigo Reposicion Xl
      pibonorec NUMBER,   -- Bono Reclamacion
      pimpaviso NUMBER,   -- Importe Avisos Siniestro
      pimpcontado NUMBER,   -- Importe pagos contado
      ppctcontado NUMBER,   -- % Pagos Contado
      ppctgastos NUMBER,   -- Gastos
      pptasaajuste NUMBER,   -- Tasa ajuste
      picapcoaseg NUMBER,   -- Capacidad segun coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisi¿n de intermediaci¿n
      -- fin Bug 18319 - APD - 04/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/**************************************************************************/
   FUNCTION f_set_objetocuadrorea(
      pccompani NUMBER,   -- Codigo de la compa?ia
      pnversio NUMBER,   -- Numero de version contrato reas.
      pscontra NUMBER,   -- Secuencia de contrato
      pctramo NUMBER,   -- Codigo de tramo
      pccomrea NUMBER,   -- Codigo de comision en contratos de reaseguro.
      ppcesion NUMBER,   -- Porcentaje de cesion
      pnplenos NUMBER,   -- Numero de plenos
      picesfij NUMBER,   -- Importe de cesion fijo
      picomfij NUMBER,   -- Importe de comision dijo
      pisconta NUMBER,   -- Importe limite pago siniestros al contado
      ppreserv NUMBER,   -- Porcentaje de reserva sobre cesion
      ppintres NUMBER,   -- Porcentaje de interes sobre reserva
      piliacde NUMBER,   -- Importe limite acumulacion deducible(XLoss)
      pppagosl NUMBER,   -- Porcentaje a pagar por el reasegurador sobre el porcentaje que ha asumido
      pccorred NUMBER,   -- Indicador corredor ( Cia que agrupamos )
      pcintref NUMBER,   -- Codigo de interes referenciado
      pcresref NUMBER,   -- Codigo de reserva referenciada
      pcintres NUMBER,   -- Codigo de interes de reaseguro
      pireserv NUMBER,   -- Importe fijo de reserva
      pptasaj NUMBER,   -- Tasa de ajuste de la reserva
      pfultliq DATE,   -- Ultima liquidacion reservas
      piagrega NUMBER,   -- Importe Agregado XL
      pimaxagr NUMBER,   -- Importe Agregado Maximo XL ( L.A.A )
      -- Bug 18319 - APD - 05/07/2011
      pctipcomis IN NUMBER,   -- Tipo Comision
      ppctcomis IN NUMBER,   -- % Comision fija / provisional
      pctramocomision IN NUMBER,   --Tramo comision variable
      -- Fin Bug 18319 - APD - 05/07/2011
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funcion que recupera el objeto persistente ob_iax_tramos_rea
   *************************************************************************/
   FUNCTION f_get_objeto_tramos(ptramosrea OUT t_iax_tramos_rea, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      funcion que borra una tramo del objeto
   *************************************************************************/
   FUNCTION f_del_objetotramosrea(
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    funcion que borra un objeto cuadro dentro de la coleccion de objetos de tramos
   *************************************************************************/
   FUNCTION f_del_objetocuadrorea(
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pscontra IN NUMBER,
      pccompani IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Funcion que inserta o modifica un contrato incluyendo TRAMOS, CUADROS
   *************************************************************************/
   FUNCTION f_set_contrato_rea(
      pscontra NUMBER,   -- Secuencia del contrato
      pspleno NUMBER,   -- Identificador del pleno
      pcempres NUMBER,   -- Codigo de empresa
      pctiprea NUMBER,   -- Codigo tipo contrato
      pcramo NUMBER,   -- Codigo de ramo
      pcmodali NUMBER,   -- Codigo de modalidad
      pctipseg NUMBER,   -- Codigo de tipo de seguro
      pccolect NUMBER,   -- Codigo de colectivo
      pcactivi NUMBER,   -- Actividad
      pcgarant NUMBER,   -- Codigo de garantia
      pcvidaga NUMBER,   -- Codigo de forma de calculo
      psconagr NUMBER,
      pcvidair NUMBER,
      pctipcum NUMBER,
      pcvalid NUMBER,
      --CONTRATOS
      --SCONTRA      number(6),             -- Secuencia del contrato
      pnversio NUMBER,   -- Numero version contrato reas.
      pnpriori NUMBER,   -- Porcentaje local asumible
      pfconini DATE,   -- Fecha inicial de version
      pnconrel NUMBER,   -- Contrato relacionado
      pfconfin DATE,   -- Fecha final de version
      piautori NUMBER,   -- Importe con autorizacion
      piretenc NUMBER,   -- Importe pleno neto de retencion
      piminces NUMBER,   -- Importe minimo cesion (Pleno neto de retencion)
      picapaci NUMBER,   -- Importe de capacidad maxima
      piprioxl NUMBER,   -- Importe prioridad XL
      pppriosl NUMBER,   -- Prioridad SL
      ptobserv VARCHAR2,   -- Observaciones varias
      ppcedido NUMBER,   -- Porcentaje cedido
      ppriesgos NUMBER,   -- Porcentaje riesgos agravados
      ppdescuento NUMBER,   -- Porcentaje de descuenctros de seleccion
      ppgastos NUMBER,   -- Porcentaje de gastos (PB)
      pppartbene NUMBER,   -- Porcentaje de participacion en beneficios (PB)
      pcreafac NUMBER,   -- Codigo de facultativo
      ppcesext NUMBER,   -- Porcentaje de cesion sobre la extraprima
      pcgarrel NUMBER,   -- Codigo de la garantia relacionada
      pcfrecul NUMBER,   -- Frecuencia de liquidacion con cia
      psconqp NUMBER,   -- Contrato CP relacionado
      pnverqp NUMBER,   -- Version CP relacionado
      piagrega NUMBER,   -- Importe agregado XL
      pimaxagr NUMBER,   -- Importe agregado maximo XL (L.A.A.),
      ptcontra VARCHAR2,
      -- Bug 18319 - APD - 04/07/2011
      pcmoneda IN VARCHAR,   -- Codigo de la moneda
      ptdescripcion IN VARCHAR,   -- Descripcion del contrato
      pclavecbr NUMBER,   -- Formula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la version
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el calculo XL
      pclosscorridor NUMBER,   -- Codigo clausula Loss Corridor
      pccappedratio NUMBER,   -- Codigo clausula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL proteccion
      pcestado NUMBER,   --Estado de la version
      pnversioprot NUMBER,   -- Version del Contrato XL proteccion
      pcdevento NUMBER,
      -- Fin Bug 18319 - APD - 04/07/2011
      pncomext NUMBER,   --% Comisi¿nn extra prima solo para POSITIVA
	  pnretpol NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul NUMBER, ---EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por Cumulo NRETCUL
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que inicializa el objeto de BD en memoria
   *************************************************************************/
   FUNCTION f_set_t_tramo_mem(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que devuelve la ultima version de un contrato.
   *************************************************************************/
   FUNCTION f_get_nversio(
      pscontra IN NUMBER,
      pnversio_datos OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que inicializa el objeto para evitar problemas de cache
   *************************************************************************/
   FUNCTION f_ini_obj_tramos(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*FIN BUG 11353 : 30/10/2009 : ICV */

   /*************************************************************************
   Funcion que selecciona todas las clausulas de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_clausulas_reas(
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que dada una clausula de reaseguro, devuelve su descripcion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que dada una clausula de reaseguro, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que graba una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE,
      pfvencim IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda una descripcion de una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda un tramo de una clausula de reaseguro
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina una descripcion una clausula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina un tramo una clausula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que selecciona todas las reposiciones
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_cod_reposicion(pccodigo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que dada una reposicion, devuelve su descripcion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que dada una reposicion, devuelve sus tramos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
Funcion que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda una descripcion de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina un detalle de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que selecciona todas las asociaciones de productos a contratos
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
Funcion que graba una asociacion
*************************************************************************/
-- BUG 28492 - INICIO - DCT - 11/10/2013 - A¿adir pilimsub
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- BUG 28492 - FIN - DCT - 11/10/2013 - A¿adir pilimsub
/*************************************************************************
Funcion que elimina una asociacion
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que selecciona todas las asociaciones de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que graba una asociacion de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina una asociacion de formulas a garantias
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que selecciona todas las agrupaciones de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_get_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que recupera el objeto ob_iax_clausulas_reas.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_clausulas_reas(
      pccodigo IN NUMBER,   -- Codigo de la clausula
      pobj_clausulas_reas OUT ob_iax_clausulas_reas,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que recupera el objeto ob_iax_reposicion.
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_objeto_reposicion(
      pccodigo IN NUMBER,   -- Codigo de la reposicion
      pobj_reposicion OUT ob_iax_reposicion,
      mensajes OUT t_iax_mensajes,
      filtro_norden IN VARCHAR)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que obtiene la lista de cuentas
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_ctatecnica(
      pcempres IN NUMBER,
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
      pcestado IN NUMBER,
      pciaprop IN NUMBER DEFAULT NULL,
      psproces IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que devuelve la cabecera de la cuenta tecnica de reaseguro consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_cab_movcta(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que devuelve las cuentas tecnicas de la reaseguradora consultada
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_get_movctatecnica(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /*************************************************************************
   Funcion que elimina un movimiento manual de la cuenta tecnica del reaseguro
   *************************************************************************/
   -- Bug 22076 - AVT - 22/05/2012 - se crea la funcion
   FUNCTION f_del_movctatecnica(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   Funcion que apunta en la tabla de liquidacion los importes pendientes de la cuenta tecnica del reaseguro.
   *************************************************************************/
   -- Bug 22076 - AVT - 24/05/2012 - se crea la funcion
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
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
      pcempres IN NUMBER,
      pdescrip IN VARCHAR2,
      pdocumen IN VARCHAR2,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pnsinies IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN NUMBER,
      mensajes OUT t_iax_mensajes,
      psidepag IN NUMBER DEFAULT NULL,
      pciaprop IN NUMBER DEFAULT NULL)   --23830 DCT /AVT 27/12/2013
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
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION F_REGISTRA_PROCESO
   Esta funci¿n nos devolver¿ el c¿digo de proceso real para la liquidaci¿n del reaseguro
    Par¿metros:
     Entrada :
       Pfperini NUMBER  : Fecha Inicio
       Pcempres NUMBER  : Empresa
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna : NUMBER con el n¿mero de proceso.
   ********************************************************************************/
   -- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_registra_proceso(
      pfperini IN DATE,
      pcempres IN NUMBER,
      pnproceso OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
   /*******************************************************************************
    FUNCION f_get_movmanual_rea
    Esta funcion permite crear movimientos manuales de cesiones de reaseguro
     Par?tros:

      Entrada :
       pscontra : NUMBER
       pcempres : NUMBER
       pnversio : NUMBER
       pctramo  : NUMBER
       pfcierre   :    DATE
       ptdescrip    :  VARCHAR2(500)
       pnidentif    :  VARCHAR2(100)
       pcconcep  : NUMBER(2)
       pcdebhab  : NUMBER(1)
       piimport  : NUMBER(13,2)
       pnsinies  : NUMBER(8)
       pnpoliza  : NUMBER(8)
       pncertif  : NUMBER(6)
       pcevento  : VARCHAR2(20 BYTE)
       pcgarant  : NUMBER(4) garantia
       pnid_in      : NUMBER(6) numerdo de id

      Salida :
        Mensajes   T_IAX_MENSAJES
    Retorna : cursor
    ********************************************************************************/
   FUNCTION f_get_movmanual_rea(
      pscontra IN NUMBER,
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
      pnid IN NUMBER,
      pnidout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_movmanual_rea(pnid IN NUMBER, paccion IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion
   FUNCTION f_get_max_cod_reposicion(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_filtered_tramos(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      filter_tramos IN VARCHAR,
      not_in IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramos_rea;

   FUNCTION f_del_filtered_tramos(
      pnversio IN NUMBER,
      filtert IN VARCHAR,
      pscontra IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_new_scontra(mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER,   --ob
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_reposiciones_contrato(
      pccodigo IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_del_tramos(
      pnversio IN NUMBER,
      pscontra IN NUMBER,
      pctramo IN NUMBER,
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
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_tramo_sin_bono;

     FUNCTION f_get_compani_doc(
               pccompani IN NUMBER,
               mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;
     FUNCTION f_edit_compani_doc(
               pccompani  IN NUMBER,
               piddocgdx  IN NUMBER,
               pctipo     IN NUMBER,
               ptobserv   IN VARCHAR2,
               ptfilename IN VARCHAR2,
               pfcaduci   IN DATE,
               pfalta     IN DATE,
               mensajes OUT t_iax_mensajes)
          RETURN NUMBER;
     FUNCTION f_ins_compani_doc(
               pccompani  IN NUMBER,
               piddocgdx  IN NUMBER,
               pctipo     IN NUMBER,
               ptobserv   IN VARCHAR2,
               ptfilename IN VARCHAR2,
               pfcaduci   IN DATE,
               pfalta     IN DATE,
               mensajes OUT t_iax_mensajes)
          RETURN NUMBER;
          FUNCTION f_get_compani_docs(
               pccompani IN NUMBER,
               mensajes OUT t_iax_mensajes)
          RETURN SYS_REFCURSOR;

		FUNCTION f_get_reaseguro_x_garantia(
			  ptabla IN VARCHAR2,
			  ppoliza IN NUMBER,
			  psseguro IN NUMBER,
			  psproces IN NUMBER,
        pcgenera IN NUMBER,
			  mensajes OUT t_iax_mensajes)
			  RETURN sys_refcursor;

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
    --          
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
      mensajes OUT t_iax_mensajes)
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
           pscontra IN NUMBER,
           mensajes OUT t_iax_mensajes)
   		   RETURN NUMBER;	  
END pac_iax_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_REA" TO "PROGRAMADORESCSI";
