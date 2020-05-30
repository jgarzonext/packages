--------------------------------------------------------
--  DDL for Package PAC_SEGUROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SEGUROS" IS
   /******************************************************************************
      NOMBRE:       PAC_SEGUROS
      PROP¿SITO:    Funciones para realizar acciones sobre la tabla SEGUROS

      REVISIONES:
      Ver        Fecha        Autor             Descripci¿n
      ---------  ----------  ---------------  ------------------------------------
      1.0        ??/??/2008   ???                1. Creaci¿n del package.
      2.0        16/03/2009   DRA                2. BUG0009423: IAX - Gesti¿ propostes retingudes: detecci¿ difer¿ncies al modificar capitals o afegir garanties
      3.0        27/02/2009   RSC                3. Adaptaci¿n iAxis a productos colectivos con certificados
      4.0        01-09-2009:  XPL                4. 11008, CRE - Afegir camps de cerca en la pantalla de selecci¿ de certificat 0.
      5.0        15/12/2009   JTS                5. 10831: CRE - Estado de p¿lizas vigentes con fecha de efecto futura
      6.0        20/01/2009   RSC                6. 7926: APR - Fecha de vencimiento a nivel de garant¿a
      7.0        22/02/2010   JMC                7. BUG 13038 Se a¿ade la funcion f_get_renovacion
      8.0        22/12/2010   APD                8. Bug 16768: APR - Implementaci¿n y parametrizaci¿n del producto GROUPLIFE (II)
      9.0        12/09/2011   JMF                9. 0019444: LCOL_T04: Parametrizaci¿n Rehabilitaci¿n
      10.0       14/01/2012   JRH                10. 0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n
      11.0       17/07/2012   MDS                11. 0022824: LCOL_T010-Duplicado de porpuestas
      12.0       01/10/2012   DRA                12. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
      13.0       10/10/2012   APD                13. 0023817: LCOL - Anulaci¿n de colectivos
      14.0       13/11/2012   APD                14. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
      15.0       12/12/2012   JMF                0024832 LCOL - Cartera colectivos - Procesos
      16.0       11/02/2013   NMM                16. 24735: (POSDE600)-Desarrollo-GAPS Tecnico-Id 33 - Mesadas Extras diferentes a la propia (preguntas)
      17.0       16/04/2013   FAL                17. 026100: RSAG101 - Producto RC Argentina. Incidencias
      18.0       13/05/2013   APD                18. 0026898: LCOL_T031-Fase 3 - Id 18 - Polizas proximas a renovar
      19.0       27/01/2013   JTT                19. 0027429: Mostrar estado en la pantalla de simulaciones
      20.0       15/04/2014   JSV                20. 0030842: LCOL_T010-Revision incidencias qtracker (2014/04)
      21.0       16/06/2016   VCG                21. AMA-187-Realizar el desarrollo del GAP 114
   ******************************************************************************/
   FUNCTION f_get_cagente(psseguro IN NUMBER, ptablas IN VARCHAR2, pcagente OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_sproduc(psseguro IN NUMBER, ptablas IN VARCHAR2, psproduc OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_ultsupl(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      psseguro IN NUMBER,
      pnsuplem IN OUT NUMBER,
      pfefepol IN OUT DATE,
      pfefesupl IN OUT DATE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que valida que la fecha de efecto de una p¿liza
         return             : 0 la validaci¿n ha sido correcta
                           <> 0 la validaci¿n no ha sido correcta
   *************************************************************************/
   FUNCTION f_valida_fefecto(
      psproduc IN seguros.sproduc%TYPE,
      pfefecto IN seguros.fefecto%TYPE,
      pfvencim IN seguros.fvencim%TYPE,
      pcduraci IN seguros.cduraci%TYPE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que modifica la fecha de efecto de una p¿liza
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_set_fefecto(
      psseguro IN seguros.sseguro%TYPE,
      pfefecto IN seguros.fefecto%TYPE,
      pnmovimi IN movseguro.nmovimi%TYPE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que devuelve el NSOLICI o el NPOLIZA en funci¿n de unos criterios
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_nsolici_npoliza(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      psproduc IN seguros.sproduc%TYPE,
      pcsituac IN seguros.csituac%TYPE,
      pnsolici OUT seguros.nsolici%TYPE,
      pnpoliza OUT seguros.npoliza%TYPE,
      pncertif OUT seguros.ncertif%TYPE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que devuelve el CDOMICI de un tomador
      param in     psseguro : Id. seguro
      param in     psperson : id. persona
      param in     ptablas  : 'EST', ...
      param    out pcdomici : Id. domicilio
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_cdomici_tom(
      psseguro IN tomadores.sseguro%TYPE,
      psperson IN tomadores.sperson%TYPE,
      ptablas IN VARCHAR2,
      pcdomici OUT tomadores.cdomici%TYPE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que devuelve y modifica la fecha de cancelaci¿n de una p¿liza
      param in     psseguro : Id. seguro
      param in     ptablas  : 'EST', ...
      param    out pfcancel : Fecha cancelaci¿n
         return             : 0 todo OK
                           <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_set_fcancel(
      psseguro IN tomadores.sseguro%TYPE,
      ptablas IN VARCHAR2,
      pfcancel OUT seguros.fcancel%TYPE)
      RETURN NUMBER;

   /*************************************************************************
     Funci¿n que devuelve la situaci¿n en la que se encuentra una p¿liza
       param  in     psseguro : Id. seguro
       param  in     ptablas  : 'EST', 'SOL', 'SEG', ...
       param  out    pcsituac : CSITUAC de la taula
       return        : 0 todo OK
                       <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_csituac(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2,
      pcsituac OUT seguros.csituac%TYPE)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿n que devuelve los meses con paga extra de los seguros de rentas
      param  in     psseguro : Id. seguro
      param  out    pmesesextra : Meses con paga extra
      return        : 0 todo OK
                      <> 0 algo KO
   *************************************************************************/
   FUNCTION f_get_nmesextra(psseguro IN seguros.sseguro%TYPE, pmesesextra OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
    Funci¿ que retorna l'import dels mesos amb paga xtra de les assegurances de rendes.
      param  in     psseguro : Id. asseguran¿a
      param  out    pmesesextra : Mesos amb paga extra
      return        : 0 tot OK
                      <> 0 Error
   *************************************************************************/
   -- 24735.NMM.
   FUNCTION f_get_imesextra(psseguro IN seguros.sseguro%TYPE, pimesosextra OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Funci¿n que obtiene la lista de p¿lizas de un producto de colectivo con certificados
      param in psproduc  : c¿digo de producto
      param in pnpoliza  : n¿mero de p¿liza
      param out vselect  : select para obtener la lista de p¿lizas
      return              : 0 todo correcto
                            1 ha habido un error
   *************************************************************************/
   FUNCTION f_sel_certificadoscero(
      psproduc IN NUMBER,
      pnpoliza IN NUMBER,
      pbuscar IN VARCHAR2,   --BUG11008-01092009-XPL
      pcintermed IN NUMBER,   --BUG22839/125740:DCT:21/10/2012
      pcsucursal IN NUMBER,   --BUG22839/125740:DCT:21/10/2012
      pcadm IN NUMBER,   --BUG22839/125740:DCT:21/10/2012
      pcidioma IN NUMBER DEFAULT 2,
      pmodo IN VARCHAR2 DEFAULT NULL,   -- Bug 30360/174025 - 09/05/2014 - AMC
      pnsolici IN NUMBER DEFAULT NULL   -- Bug 34409/196980 - 16/04/2015 - POS
                                     )
      RETURN VARCHAR2;

   /*************************************************************************
      Obtiene la actividad de una poliza
       param in psseguro: codigo del seguro
       param in pnpoliza: Numero de p¿liza
       param in pncertif: Numero de certificado de la poliza
       param in ptablas: identificador de tablas EST, SOL, SEG
      param out pcactivi : codigo de la actividad de la poliza
      return             : number (0- Todo OK, num_err - Si ha habido algun error)
   *************************************************************************/
   FUNCTION f_get_cactivi(
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptablas IN VARCHAR2,
      pcactivi OUT NUMBER)
      RETURN NUMBER;

   /******************************************************************
      Funci¿n que nos devuelve una garantia, o bien en polizas o bien en riesgos.
        param in PSSEGURO: Codi de segur
        param in PNRIESGO: N¿mero de risc
        param in PTABLAS : taula 'SOL','EST'...
        RETURN               : NUMBER; (Codi d'activitat)
      RETURN error: 0: correcto
    /*****************************************************************/
   FUNCTION ff_get_actividad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   /******************************************************************
      Funci¿n que nos devuelve el sseguro pasandole el npoliza y ncertificado
        param in pnpoliza: num poliza
        param in pncertif: num certif
        param in PTABLAS : taula 'SOL','EST'...
        param out psseguro: sseguro
        RETURN               : 0-ok : 1-error
    /*****************************************************************/
   FUNCTION f_get_sseguro(
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      ptablas IN VARCHAR2,
      psseguro OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Recupera el nombre del tomador de la p¿liza seg¿n el orden
      param in sseguro   : c¿digo seguro
      param in nordtom   : orden tomador
      param in idioma   : idioma
      return             : nombre tomador
   *************************************************************************/
   FUNCTION f_get_nametomador(sseguro IN NUMBER, nordtom IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2;

   /*************************************************************************
      Funci¿n devuelve el estado detallado de una poliza
      param in psseguro  : sseguro
      param in pcidioma  : idioma
      param in ptipo     : 1- solo situacion; 2- sit + estado; 3- sit + estado + incidencias
      param in p_tabla   : SEG - Tabla SEGUROS, EST - Tabla ESTSEGUROS
      return             : Literal con la situacion
   *************************************************************************/
   FUNCTION ff_situacion_poliza(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_tipo IN NUMBER,
      -- bug 10831.NMM.01/2009.i.
      p_csituac IN seguros.csituac%TYPE DEFAULT NULL,
      p_creteni IN seguros.creteni%TYPE DEFAULT NULL,
      p_fefecto IN seguros.fefecto%TYPE DEFAULT NULL,   -- bug 10831.NMM.01/2009.f.
      p_tabla IN VARCHAR2 DEFAULT 'SEG')   -- Bug27429 - 27/01/2014 - JTT
      RETURN VARCHAR2;

   /*************************************************************************
      Funci¿n devuelve la lista de incidencias de una poliza
      param in psseguro  : sseguro
      param in pcidioma  : idioma
      param in pcsituac  : csituac de seguros (default NULL)
      return             : literal con las incidencias
      --BUG 10831
   *************************************************************************/
   FUNCTION ff_incidencias_poliza(
      p_sseguro IN NUMBER,
      p_cidioma IN NUMBER,
      p_csituac IN NUMBER DEFAULT NULL,
      p_incis IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   /*************************************************************************
     Recupera la fecha de vencimiento de una garant¿a si tiene parametrizada
     la pregunta 1043 indicada en el par¿metro de producto 'CPREGUN_VTOGARAN'.
     En caso de no tener vencimiento la garant¿a retornar¿ NULL.

     param in psseguro  : codigo de seguro
     param in pnriesgo  : codigo de riesgo
     param in pcgarant  : codigo de garant¿a
     param in pnmovimi  : codigo de movimiento
     param in ptablas   : tablas a acceder ('EST' o NULL)
     return             : DATE
   *************************************************************************/
   -- Bug 7926 - 20/01/2009 - RSC - APR - Fecha de vencimiento a nivel de garant¿a
   FUNCTION f_vto_garantia(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN DATE;

-- Fin Bug 7926
   -- BUG : 13038 - 22-02-2010 - JMC - Se a¿ade funcion.
   /***************************************************************************
      FUNCTION f_get_renovacion
      Dado un sseguro, obtenemos si ha renovado o no 0- NO 1- SI
         param in  psseguro:  sseguro de la p¿liza.
         return:              0- NO 1- SI.
   ***************************************************************************/
   FUNCTION f_get_renovacion(psseguro IN NUMBER)
      RETURN NUMBER;

-- FIN BUG : 13038 - 22-02-2010 - JMC

   -- Bug 16106 - 11-10-2010 - RSC
   /***************************************************************************
      FUNCTION f_get_escertifcero
      Dado un npoliza, nos indica si existe el ncertif = 0
      Dado un sseguro, nos indica si ese sseguro es el ncertif = 0
         param in  pnpoliza:  numero de la p¿liza.
         param in  psseguro:  sseguro de la p¿liza.
         return:              0- NO 1- SI.
   ***************************************************************************/
   -- Bug 23817 - APD - 27/09/2012 - se a¿ade el psseguro
   FUNCTION f_get_escertifcero(pnpoliza IN NUMBER, psseguro IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   -- Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_agentecol
   /***************************************************************************
      FUNCTION f_get_agentecol
      Dado un numero de poliza, obtenemos el codigo del agente de su certificado 0
         param in  pnpoliza:  numero de la p¿liza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_agentecol(pnpoliza IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 16768 - APD - 22-11-2010
   -- Bug 16768 - APD - 22-11-2010 - se crea la funcion f_get_cforpagcol
   /***************************************************************************
      FUNCTION f_get_cforpagcol
      Dado un numero de poliza, obtenemos la forma de pago de su certificado 0
         param in  pnpoliza:  numero de la p¿liza.
         return:              NUMBER.
   ***************************************************************************/
   FUNCTION f_get_cforpagcol(pnpoliza IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 16768 - APD - 22-11-2010

   -- Bug 0019274 - 25/08/2011 - JMF
   /***************************************************************************
      FUNCTION f_tiene_garanahorro
      Comprueba si tiene una garantia de ahorro contratada
         param in  pnrecibo: numero de recibo.
         param in  psseguro: numero seguro
         paran in  pfecha: fecha a comprobar
         return:  0-No, 1-Si
   ***************************************************************************/
   FUNCTION f_tiene_garanahorro(
      pnrecibo IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   -- BUG 20671-  01/2012 - JRH  -  0020671: LCOL_T001-LCOL - UAT - TEC: Contrataci?n

   /***********************************************************************
        Ens retorna si ¿s de migraci¿n
       el importe del concepto
       param in psseguro    : c¿digo del seguro
       param in tablas       : modo
       psalida              :0 No ¿s migraci¿n
                            1 ¿s migraci¿n
        return                     es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_es_migracion(
      psseguro IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psalida OUT NUMBER)
      RETURN NUMBER;

-- Fi BUG 20671-  01/2012 - JRH
   --bfp bug 21808 ini
   FUNCTION ff_frenovacion(pnsesion IN NUMBER, psseguro IN NUMBER, porigen NUMBER)
      RETURN VARCHAR2;

--bfp bug 21808 fi

   -- 17/07/2012 - MDS - 0022824: LCOL_T010-Duplicado de propuestas
   FUNCTION f_calcula_npoliza(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pcramo IN NUMBER,
      pcempres IN NUMBER,
      pnpoliza OUT NUMBER)
      RETURN NUMBER;

   PROCEDURE p_emitir_propuesta_col(
      pcempres IN NUMBER,
      pnpoliza IN NUMBER,
      pncertif IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pmoneda IN NUMBER,
      pcidioma IN NUMBER,
      pindice OUT NUMBER,
      pindice_e OUT NUMBER,
      pcmotret OUT NUMBER,   -- BUG9640:DRA:16/04/2009
      psproces IN NUMBER DEFAULT NULL,
      pnordapo IN NUMBER DEFAULT NULL,
      pcommit IN NUMBER DEFAULT NULL);

   /***********************************************************************
       Retorna el tipo de vigencia de una p¿liza f_get_tipo_vigencia
       return                     es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_get_tipo_vigencia(
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psalida OUT NUMBER)
      RETURN NUMBER;

   /***********************************************************************
       Retorna el tipo de vigencia de una p¿liza f_get_tipo_vigencia
       return                     es un c¿digo de error
    ***********************************************************************/
   FUNCTION f_get_tipo_duracion_cero(
      psseguro IN NUMBER,
      pnpoliza IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      psalida OUT NUMBER)
      RETURN NUMBER;

   -- BUG22839:DRA:26/09/2012:Inici
   FUNCTION f_es_col_admin(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   -- Bug 23940 - APD - 26/10/2012 - se crea la funcion
   FUNCTION f_es_col_agrup(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

   FUNCTION f_suplem_obert(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

-- BUG22839:DRA:26/09/2012:Fi

   -- Bug 23817 - APD - 03/10/2012 - se crea la funcion
   FUNCTION f_set_detmovsegurocol(
      psseguro_0 IN NUMBER,
      pnmovimi_0 IN NUMBER,
      psseguro_cert IN NUMBER,
      pnmovimi_cert IN NUMBER)
      RETURN NUMBER;

   -- Bug 23940 - APD - 07/11/2012 - se crea la funcion
   FUNCTION f_set_detrecmovsegurocol(
      psseguro_0 IN NUMBER,
      pnmovimi_0 IN NUMBER,
      psseguro_cert IN NUMBER,
      pnmovimi_cert IN NUMBER,
      pnrecibo IN NUMBER,
      psproces IN NUMBER)
      RETURN NUMBER;

-- BUG 0024450/0129646 - FAL - 15/11/2012
   FUNCTION f_suspendida(psseguro IN NUMBER, pfvalmov IN DATE)
      RETURN NUMBER;

   --BUG 23860/0130231 - FAL - 01/12/2012
   FUNCTION f_valida_borra_plan(psseguro IN NUMBER, pfefecto IN DATE)
      RETURN NUMBER;

   -- BUG 0024832 - 12/12/2012 - JMF
   FUNCTION f_anul_obert(psseguro IN NUMBER, ptablas IN VARCHAR2 DEFAULT 'SEG')
      RETURN NUMBER;

-- BUG 26100 - FAL - 16/04/2013
   FUNCTION f_get_cmoncap(psproduc IN NUMBER, pcgarant IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER;

-- FI BUG 26100 - FAL - 16/04/2013

   --INICIO BUG 25944  -DCT - 06/05/2013
   FUNCTION f_get_bonusmalus(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

--FIN BUG 25944  -DCT - 06/05/2013

   -- Bug 26989 - APD - 09/05/2013 -  se crea la funcion
   FUNCTION f_valor_asegurado(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

-- fin Bug 26989 - APD - 09/05/2013

   --BUG27048/150505 - DCT - 05/08/2013 - Inicio -
   PROCEDURE p_modificar_seguro(psseguro IN NUMBER, pcreteni IN NUMBER);

   --ptablas IN VARCHAR2 DEFAULT 'EST',
   --psalida OUT NUMBER);
--BUG27048/150505 - DCT - 05/08/2013 - Fin -
--Comprovamos si esta en propuesta de suplemento por tratarse de un colectivo
   --adminsitrado que al emitirlo crea un nuevo movimiento de apertura de suplemento
   FUNCTION f_emicol_propsup(psseguro IN NUMBER)
      RETURN NUMBER;

-- Bug 30842/0172526 - 15/04/2014
   FUNCTION f_soycertifcero(psproduc IN NUMBER, pnpoliza IN NUMBER, psseguro IN NUMBER)
      RETURN NUMBER;

   --BUG 27924/151061 - RCL - 20/03/2014
   FUNCTION f_get_movimi_cero_fecha(psseguro_cero IN NUMBER, pfecha IN DATE)
      RETURN NUMBER;

   FUNCTION f_fatca_indicios(
      psseguro IN NUMBER,
      pctipo IN NUMBER,
      pnorden IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'SEG',
      psperson IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_fatca_clasifica(psseguro IN NUMBER)
      RETURN NUMBER;

   --BUG 34409/  javendano - 13/07/2015
   FUNCTION f_ini_certifn(psseguro IN NUMBER, paccion IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_get_tomador_poliza(psseguro IN NUMBER, nordtom IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

   PROCEDURE p_notifica(
      psseguro IN  NUMBER,
      pctipeve IN  NUMBER,
      pnumerr  OUT NUMBER,
      precibo  IN  NUMBER DEFAULT NULL);
/*
Esta funci¿n ser¿ la encargada de disparar o iniciar el proceso de notificaci¿n a las personas relacionadas
con el seguro sobre el que se est¿ realizando la acci¿n.
Deber¿ preparar los par¿metros para iniciar el proceso de env¿o, registrar en la tabla INT_NOTIFICACION_SOA
el inicio del proceso con estado ¿XXXX¿ e iniciar el proceso de env¿o de informaci¿n a AxisConnectNT.

PARAMETRO	TIPO	E/S	DEFINICION
PSSEGURO	NUMBER	E	N¿mero de persona
CTIPEVE		NUMBER	E	Tipo de evento que genera la notificaci¿n
NUMERR		NUMBER	S	N¿mero de error
*/


    PROCEDURE p_procesa_notif(
      psinterf IN  NUMBER,
      pctipeve IN  NUMBER,
      pitippro IN  NUMBER,
      pnumerr  OUT NUMBER,
      precibo  IN  NUMBER DEFAULT NULL );
/*
Esta funci¿n ser¿ la encargada de procesar los mensajes que se encuentren en la tabla  INT_NOTIFICACION_SOA
en un estado que permita el env¿o a SOA.

PARAMETRO	TIPO		E/S	DEFINICION
PSINTERF	NUMBER		E	N¿mero de interficie (int_notificacion_soa)
ITIPPRO		NUMBER(1)	E	Indicador tipo proceso (0-Online,1-batch)
NUMERR		NUMBER		S	N¿mero de error

La funci¿n recibir¿ por par¿metros el c¿digo identificativo del registro de la tabla INT_NOTIFICACION_SOA que se procesar¿.
Si este valor est¿ informado, deber¿ enviarse el par¿metro ITIPPRO informado a ¿0¿,
indicando que el proceso es online, es decir, deber¿ tratarse solo el registro indicado por el par¿metro SINTERF.

Si por el contrario ITIPPRO viene informado a 1, indicar¿ que se deber¿n reprocesar todos aquellos mensajes que est¿n en un
estado que permita el reenv¿o. En este caso SINTERF no deber¿ informarse.

*/

	PROCEDURE p_imprime_doc(psseguro     IN  NUMBER,
                            pnombreplant IN VARCHAR2);

/*
Funci¿n que se encarga de realizar la llamada a la impresi¿n de los documentos de p¿liza para el env¿o de email de ENSA.
*/

/*Funci¿n que se encarga de borrar las simulaciones*/
Function F_Borrar_Simulaciones (Psseguro In Number)
      RETURN NUMBER;

END pac_seguros;

/

  GRANT EXECUTE ON "AXIS"."PAC_SEGUROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SEGUROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SEGUROS" TO "PROGRAMADORESCSI";
