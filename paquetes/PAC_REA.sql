--------------------------------------------------------
--  DDL for Package PAC_REA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "AXIS"."PAC_REA" IS
/******************************************************************************
    NAME:       pac_md_rea
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/07/2009    ETM            1. Created this package body.--Nuevo paquete de negocio que contiene las funciones del m?dulo de reaseguro
   2.0        13/07/2009    ETM            2. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   3.0        02/09/2009    ICV            3. 0010487: IAX - REA: Desarrollo PL del mantenimiento de Facultativo
   4.0        07/09/2009    ICV            4. 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos
   5.0        30/10/2009    ICV            5. 0011353: CEM - Parametrizaci?n mantenimiento de contratos Reaseguro
   6.0        04/07/2011    APD            6. 0018319: LCOL003 - Pantalla de mantenimiento del contrato de reaseguro
   7.0        10/10/2011    APD            7. 0019724: LCOL_A002-Nuevas pantallas relacionadas con el reaseguro
   8.0        23/05/2012    AVT            8. 0022076: LCOL_A004-Mantenimientos de cuenta tecnica del reaseguro y del coaseguro
   9.0        18/01/2013    AEG            9. 0025502: LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
   10.0       25/06/2013    DCT           10. 0021559: LCOL999-Cambios en el Reaseguro
   11.0       23/08/2013    KBR           11. 0027911: LCOL_A004-Qtracker: 6163: Validacion campos pantalla mantenimiento cuentas reaseguro (Liquidaciones)
   12.0       30/09/2013    RCL           12. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca (Nota: 22076/0123753)
   13.0       11/11/2013    SHA           13. 0028083: LCOL_A004-0008945: Error en pantalla consulta de reposiciones
   14.0       14/11/2013    DCT           14. 0028492: LCOLF3BREA-Revisi?n de los contratos de REASEGURO F3B
   15.0       15/11/2013    JDS           15. 0028493: LCOLF3BREA-Revisi?n interfaces Liquidaci?n Reaseguro F3B
   16.0       04/12/2013    RCM           16. 0028992: (POSPG400)-Parametrizacion (Apuntes manuales)
   17.0       21/01/2014    JAM           17. 0023830: LCOL_A004 Ajustar el Manteniment dels Comptes de Reasseguranca
   18.0       14/05/2014    AGG           18. 0026622: POSND100-(POSDE400)-Desarrollo-GAPS Reaseguro, Coaseguro -Id 97 - Comisiones calculadas solo sobre extraprima
   19.0       16/07/2014    KBR           19. 0030203: LCOL_A004-Qtracker: 8993, 8995, 9865, 8987, 8991 Liquidaci?n de saldos
   20.0       19/11/2015    DCT           20. 0038692: POSPT500-POS REASEGUROS CESIÓN DE VIDA INDIVIDUAL Y COMISIONES SOBRE EXTRA PRIMAS
   21.0       02/09/2016    HRE           21. CONF-250: Se incluye manejo de contratos Q1, Q2, Q3
   22.0       15/07/2019    FEPP          22. IAXIS-4611:Campo para grabar la prioridad por tramo y el limite por tramo
   23.0       26/01/2020    INFORCOL      23. Reaseguro facultativo - ajuste para deposito en prima retenida
   24.0       26/05/2020    DFRP          46. IAXIS-5361: Modificar el facultativo antes de la emisión
******************************************************************************/

   /*BUG 10487 - 13/07/2009 - ETM - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
   /*************************************************************************
      Valida que todos los campos obligatorios se hayan introducido, que no se informen campos incompatibles entre si
      y que la suma de la cesi?n a compa??as, cuando el cuadro est? completo sea siempre igual a 100%.
      PSFACULT in NUMBER
      PCESTADO in NUMBER
      PFINCUF in DATE
      PCCOMPANI in NUMBER
      PPCESION in NUMBER
      PICESFIJ in NUMBER
      PCCOMREA in NUMBER
      PPCOMISI in NUMBER
      PICOMFIj in NUMBER
      PISCONTA in NUMBER
      PPRESERV in NUMBER
      PCINTRES in NUMBER
      PINTRES in NUMBER
   *************************************************************************/
   FUNCTION f_valida_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
      pplocal IN NUMBER,
      pifacced  IN NUMBER, -- IAXIS-5361 26/05/2020
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
      ptidfcom IN VARCHAR2,   -- BUG: 25502 17-01-2013 AEG
      psseguro IN NUMBER)   --BUG38692 19/11/2015 DCT)
      RETURN NUMBER;

   /*************************************************************************
        Nueva funci?n que inserta los datos correspondientes a las compa??as una vez validados.
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

     *************************************************************************/
   FUNCTION f_set_cuadro_fac(
      psfacult IN NUMBER,
      pcestado IN NUMBER,
      pfincuf IN DATE,
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
      ppintres IN NUMBER,
      pccorred IN NUMBER,   -- 20/08/2012 AVT 22374
      pcfreres IN NUMBER,
      pcresrea IN NUMBER,
      pcconrec IN NUMBER,
      pfgarpri IN DATE,
      pfgardep IN DATE,
      ppimpint IN NUMBER,
      ptidfcom IN VARCHAR2)   -- bug 25502 17-01-2013 AEG
      RETURN NUMBER;

/*FIN BUG 10487 : 13/07/2009 : ETM */

   /*BUG 10487 - 02/09/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */
    /*************************************************************************
           funci?n que se encargar? de borrar un registro de compa??a participante en el cuadro.
           PSFACULT in NUMBER
           PCESTADO in NUMBER
           PCCOMPANI in NUMBER
      *************************************************************************/
   FUNCTION f_anula_cia_fac(psfacult IN NUMBER, pcestado IN NUMBER, pccompani IN NUMBER)
      RETURN NUMBER;

/*FIN BUG 10487 : 02/09/2009 : ICV */

   /*BUG 10990 - 07/09/2009 - 0010990: IAX - REA: Desarrollo PL del mantenimiento de contratos*/
   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en cuadroces.
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
           CTIPCOMIS in number,              Tipo Comisi?n
           PCTCOMIS in number,            % Comisi?n fija / provisional
           CTRAMOCOMISION in number,            Tramo comisi?n variable
           -- fin Bug 18319 - APD - 05/07/2011
   *************************************************************************/
   -- INI - AXIS 4451 - 20/06/2019 - AABG - SE AGREGA CAMPO PARA ALMACENAR EL PORCENTAJE DE GASTOS
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
      pctipcomis IN NUMBER,   -- Tipo Comisi?n
      ppctcomis IN NUMBER,   -- % Comisi?n fija / provisional
      pctramocomision IN NUMBER,   --Tramo comisi?n variable
      pctgastosrea    IN NUMBER
      )   --% Gastos Reasegurador (CONF-587)
      -- Fin Bug 18319 - APD - 05/07/2011
      -- FIN - AXIS 4451 - 20/06/2019 - AABG - SE AGREGA CAMPO PARA ALMACENAR EL PORCENTAJE DE GASTOS
   RETURN NUMBER;

   /*************************************************************************
         funci?n que inserta o actualiza informaci?n en tramos.
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
      pilaa IN NUMBER,   -- L?mite agregado anual
      pctprimaxl IN NUMBER,   -- Tipo Prima XL
      piprimafijaxl IN NUMBER,   -- Prima fija XL
      piprimaestimada IN NUMBER,   -- Prima Estimada para el tramo
      pcaplictasaxl IN NUMBER,   -- Campo aplicaci?n tasa XL
      pctiptasaxl IN NUMBER,   -- Tipo tasa XL
      pctramotasaxl IN NUMBER,   -- Tramo de tasa variable XL
      ppctpdxl IN NUMBER,   -- % Prima Dep?sito
      pcforpagpdxl IN NUMBER,   -- Forma pago prima de dep?sito XL
      ppctminxl IN NUMBER,   -- % Prima M?nima XL
      ppctpb IN NUMBER,   -- % PB
      pnanyosloss IN NUMBER,   -- A?os Loss Corridor
      pclosscorridor IN NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio IN NUMBER,   -- C?digo cl?usula Capped Ratio
      pcrepos IN NUMBER,   -- C?digo Reposici?n Xl
      pibonorec IN NUMBER,   -- Bono Reclamaci?n
      pimpaviso IN NUMBER,   -- Importe Avisos Siniestro
      pimpcontado IN NUMBER,   -- Importe pagos contado
      ppctcontado IN NUMBER,   -- % Pagos Contado
      ppctgastos IN NUMBER,   -- Gastos
      pptasaajuste IN NUMBER,   -- Tasa ajuste
      picapcoaseg IN NUMBER,   -- Capacidad seg?n coaseguro
      picostofijo IN NUMBER,   --Costo Fijo de la capa
      ppcomisinterm IN NUMBER,   --% de comisión de intermediación
      pptramo       IN NUMBER,--BUG CONF-250  Fecha (02/09/2016) - HRE - Contratos Q1, Q2, Q3 se adiciona pptramo
      ppreest      IN NUMBER,--BUG CONF-1048  Fecha (29/08/2017) - HRE - Contratos no proporcionales
      ppiprio IN NUMBER--Agregar campo prioridad tramo IAXIS-4611
      )
      -- Fin Bug 18319 - APD - 04/04/2011
   RETURN NUMBER;

       /*************************************************************************
       funci?n que inserta o actualiza informaci?n en contratos.
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
      pclavecbr NUMBER,   -- F?rmula para el CBR
      pcercartera NUMBER,   -- Tipo E/R cartera
      piprimaesperadas NUMBER,   -- Primas esperadas totales para la versi?n
      pnanyosloss NUMBER,   -- A?os Loss-Corridos
      pcbasexl NUMBER,   -- Base para el c?lculo XL
      pclosscorridor NUMBER,   -- C?digo cl?usula Loss Corridor
      pccappedratio NUMBER,   -- C?digo cl?usula Capped Ratio
      pscontraprot NUMBER,   -- Contrato XL protecci?n
      pcestado NUMBER,   --Estado de la versi?n
      pnversioprot NUMBER,   -- Version del Contrato XL protecci?n
      pncomext NUMBER, --%Comisión extra prima (solo para POSITIVA) --AGG 14/05/2014 Se añade la comisión de la extra prima
      pnretpol IN NUMBER, --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro de Retencion por poliza NRETPOL
      pnretcul IN NUMBER --EDBR - 11/06/2019 - IAXIS3338 - se agrega parametro por Cumulo NRETCUL
	  )
      -- Fin Bug 18319 - APD - 04/07/2011
   RETURN NUMBER;

     /*************************************************************************
       funci?n que inserta o actualiza informaci?n en codicontratos.
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
      ptdescripcion IN VARCHAR,
      pcdevento IN NUMBER,   -- Bug 18319 - APD - 04/07/2011
      pnversio IN NUMBER)   -- INI - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS
      RETURN NUMBER;
      -- FIN - AXIS 4853 - 26/07/2019 - AABG - SE AGREGA ATRIBUTO PNVERSIO PARA AGR_CONTRATOS

/*FIN BUG 10990 : 07/09/2009 : ICV */

   /*BUG 11353 - 12/10/2009 - ICV - IAX : REA: Desarrollo PL del mantenimiento de Facultativo */

   /*************************************************************************
       Funci?n que valida la introducci?n o modificaci?n de un contrato de reaseguro
       Devuelve un number con 0 si todo ha ido correcto o el n?mero de error en caso contrario
   *************************************************************************/
   -- BUG 21546_108727- 23/02/2012 - JLTS - Se quita la funcion del aqui y se pasa al pac_md_rea.
/*   FUNCTION f_valida_contrato_rea(
      pctiprea IN NUMBER,
      piretenc IN NUMBER,
      picapaci IN NUMBER,
      p_tobtramos IN t_iax_tramos_rea)
      RETURN NUMBER;*/

   /*************************************************************************
   Funci?n que inserta / actualiza las formulas del reaseguro
   *************************************************************************/
   FUNCTION f_set_reaformula(
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que inserta / actualiza las cuentas t?cnicas del reaseguro
   *************************************************************************/
   FUNCTION f_set_ctatecnica(
      pccompani IN NUMBER,   --pk
      pscontra IN NUMBER,   --pk
      pnversio IN NUMBER,   --pk
      pctramo IN NUMBER,   --pk
      pnctatec IN NUMBER,
      pcfrecul IN NUMBER,
      pcestado IN NUMBER,
      pfestado IN DATE,
      pfultimp IN DATE,
      pcempres IN NUMBER,
      psproduc IN NUMBER,   --pk
      pccorred IN NUMBER)
      RETURN NUMBER;

/*FIN BUG 11353 : 12/10/2009 : ICV */
   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_cuadroces(
      pccompani IN NUMBER,   --ob
      pnversio IN NUMBER,   --ob
      pscontra IN NUMBER,   --ob
      pctramo IN NUMBER)   --ob
      RETURN NUMBER;

   -- Bug 18319 - APD - 07/07/2011
   -- se crea la funcion
   FUNCTION f_del_tramos(pnversio IN NUMBER,   --ob
                                            pscontra IN NUMBER,   --ob
                                                               pctramo IN NUMBER)   --ob
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que graba una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_clausulas_reas(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctipo IN NUMBER,
      pfefecto IN DATE DEFAULT f_sysdate,
      pfvencim IN DATE)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda un tramo de una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_clausulas_reas_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pctramo IN NUMBER,
      pilim_inf IN NUMBER,
      pilim_sup IN NUMBER,
      ppctpart IN NUMBER,
      ppctmin IN NUMBER,
      ppctmax IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina una descripci?n una cl?usula de reaseguro
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas(pccodigo IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina un tramo una cl?usula de reaseguro o un tramo escalonado
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_clausulas_reas_det(pccodigo IN NUMBER, pctramo IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
Funci?n que graba una reposicion
*************************************************************************/
-- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_cod_reposicion(pccodigo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda una descripci?n de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones(
      pccodigo IN NUMBER,
      pcidioma IN NUMBER,
      ptdescripcion IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda un tramo de una reposicion
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_reposiciones_det(
      pcmodo IN NUMBER,
      pccodigo IN NUMBER,
      pnorden IN NUMBER,
      picapacidad IN NUMBER,
      pptasa IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_cod_reposicion(pccodigo IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina un detalle de una reposici?n
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reposiciones_det(pccodigo IN NUMBER, pnorden IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_agrupcontrato(psconagr IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que guarda una descripcion de una agrupacion de contrato
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_desagrupcontrato(
      psconagr IN NUMBER,
      pcidioma IN NUMBER,
      ptconagr IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
Funci?n que graba una asociacion
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
      pilimsub IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
Funci?n que elimina una asociacion
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
      pcgarant IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que graba una asociacion de f?rmulas a garant?as
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
      pclave IN NUMBER)
      RETURN NUMBER;
*/
   /*************************************************************************
   Funci?n que elimina una asociacion de f?rmulas a garant?as
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_reaformula(
      pscontra IN NUMBER,
      pnversion IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pccampo IN VARCHAR2,
      pclave IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que graba una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_set_contratosagr(psconagr IN NUMBER, pcidioma IN NUMBER, ptconagr IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina una agrupacion de contratos
   *************************************************************************/
   -- Bug 18319 - APD - 08/07/2011 - se crea la funcion
   FUNCTION f_del_contratosagr(psconagr IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que devuelve el siguiente codigo de agrupacion de contrato
   *************************************************************************/
   -- Bug 19724 - APD - 10/10/2011 - se crea la funcion
   FUNCTION f_get_sconagr_next(psmaxconagr OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que elimina un movimiento manual de la cuenta t?cnica del reaseguro
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
      pciaprop IN NUMBER DEFAULT NULL)   --23830 DCT 27/12/2013)
      RETURN NUMBER;

   /*************************************************************************
   Funci?n que apunta en la tabla de liquidaci?n los importes pendientes de la cuenta t?cnica del reaseguro.
   *************************************************************************/
   FUNCTION f_liquida_ctatec_rea(
      pcempres IN NUMBER,
      psproduc IN NUMBER,
      pccorred IN NUMBER,
      pccompani IN NUMBER,
      pscontra IN NUMBER,
      pnversio IN NUMBER,
      pctramo IN NUMBER,
      pfcierre IN DATE,
      pcidioma IN NUMBER,
      psproces IN NUMBER,
      pcliquidar IN NUMBER DEFAULT 0,
      pciaprop IN NUMBER DEFAULT NULL,
      pultimoreg IN NUMBER DEFAULT 0)   --30203 KBR 16/07/2014
      RETURN NUMBER;

   /*************************************************************************
       Funci?n que insertar? o modificar? un movimiento de cuenta t?cnica en funci?n del pmodo
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
      pestadoold IN NUMBER)
      RETURN NUMBER;

   /*******************************************************************************
                                                                                                                                                                                                                                                    FUNCION F_INICIALIZA_CARTERA
     Esta funciÃ³n devuelve el sproces con el que se realizarÃ¡ la liquidaciÃ³ del Reaseguro,
     para ello llamarÃ¡ a la funciÃ³n de f_procesini.
    ParÃ¡metros
     Entrada :
        Pfperini  DATE     : Fecha
        Pcempres  NUMBER   : Empresa
        Ptexto    VARCHAR2 :
     Salida :
        Psproces  NUMBER  : Numero proceso de cartera.
    Retorna :NUMBER con el nÃºmero de proceso
    *********************************************************************************/-- Bug 22076 - AVT - 04/10/2012 - se crea la funcion
   FUNCTION f_inicializa_liquida_rea(
      pfperini IN DATE,
      pcempres IN NUMBER,
      ptexto IN VARCHAR2,
      pcidioma IN NUMBER,
      psproces OUT NUMBER)
      RETURN NUMBER;

   /*****************************************************************************
   La nueva función recibirá como parámetro la garantía que se está contratando y producto,
   con ellos se obtendrán todas las que estén dentro del mismo grupo (tabla: PARGARANPRO),
   del grupo de garantías se verificará por cada una de ellas si está contratada y
   si su capital es mayor al de la garantía que recibimos por parámetro.
   En caso que ninguna de las garantías contratadas tenga un capital mayor retornará su capital en caso contrario retornará 0 (cero)
   *********************************************************************************/
   FUNCTION f_max_gar_reaseg_agrup(
      sesion IN NUMBER,
      p_sseguro IN NUMBER,
      p_nriesgo IN NUMBER,
      p_nmovimi IN NUMBER,
      p_gar_ppal IN NUMBER,
      p_sproduc IN NUMBER)
      RETURN NUMBER;

   -- Bug 26444 - ETM - 31/07/2012 - se crea la funcion -INI
   FUNCTION f_borrar_movprevio(pcempres IN NUMBER, pnid IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insertar_movprevio(
      psproces IN NUMBER,
      pscontra IN NUMBER,
      pcempres IN NUMBER,
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
      pcgarant IN NUMBER,
      pnidout IN NUMBER)
      RETURN NUMBER;

   -- BUG - RCM - 03/11/2013 - Validación capacidad del contrato
   FUNCTION f_valida_capacidad_contrato(
      pcempres IN NUMBER,
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
      pcgarant IN NUMBER,
      pnidout IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_insertar_movctaaux(
      pcempres IN NUMBER,
      pnid IN NUMBER,
      psproces IN NUMBER,
      pnsinies IN NUMBER,
      piimport IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_graba_real_movmanual_rea(pcempres IN NUMBER, pnid IN NUMBER)
      RETURN NUMBER;

-- FIN Bug 26444 - ETM - 31/07/2012 - se crea la funcion

   /*************************************************************************
   Función que devuelve  la póliza y el certificado al que pertenece un siniestro
   *************************************************************************/
   -- Bug 23830 - DCT- 04/09/2013 -
   FUNCTION f_get_npoliza(pnsinies IN NUMBER, pnpoliza OUT NUMBER, pncertif OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_contrato_rea(pscontra IN NUMBER)   --ob
      RETURN NUMBER;

   FUNCTION f_set_liquida(
      pspagrea IN NUMBER,
      pfcambio IN DATE,
      pcestpag IN NUMBER,
      piimporte IN pagos_ctatec_rea.iimporte%TYPE,
      piimporte_moncon IN pagos_ctatec_rea.iimporte_moncon%TYPE,
      pctipopag IN pagos_ctatec_rea.ctipopag%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
     FUNCTION f_edit_compani_doc(
               pccompani IN NUMBER,
               piddocgdx IN NUMBER,
               pctipo    IN NUMBER,
               ptobserv  IN VARCHAR2,
               pfcaduci  IN DATE,
               pfalta    IN DATE,
               mensajes  IN OUT t_iax_mensajes)
          RETURN NUMBER;

   FUNCTION f_ins_compani_doc(
             pccompani IN NUMBER,
             piddocgdx IN NUMBER,
             pctipo    IN NUMBER,
             ptobserv  IN VARCHAR2,
             pfcaduci  IN DATE,
             pfalta    IN DATE,
             mensajes  IN OUT t_iax_mensajes)
        RETURN NUMBER;

   FUNCTION f_get_reaseguro_x_garantia(
      ptabla IN VARCHAR2,
      ppoliza IN NUMBER,
      psseguro IN NUMBER,
      psproces IN NUMBER,
      pcgenera IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

	  -- INI - EDBR - 18/06/2019 -  IAXIS4330
    /*************************************************************************
    Funcion que inserta o modifica el registro de patrimoinio tecnico 
   *************************************************************************/
   FUNCTION f_set_patri_tec(
      panio NUMBER,   -- año parametrizado del patrimonio
      ptrimestre NUMBER,   -- trimestre
      pmoneda VARCHAR2,   -- moneda
      pvalor NUMBER , -- valor 
      pmovimi number) --numero de moviento NULL nuevo registro ELSE update
      RETURN NUMBER;
 -- FIN - EDBR - 18/06/2019 -  IAXIS4330

 /* INI - ML - 4549
    * f_activar_contrato: ACTIVA INDIVIDUALMENTE UN CONTRATO EN REASEGURO, TOMANDO LA ULTIMA VERSION VALIDA
   */
   FUNCTION f_activar_contrato(
      pscontra IN NUMBER)
      RETURN NUMBER;
 
END pac_rea;

/

  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_REA" TO "PROGRAMADORESCSI";
