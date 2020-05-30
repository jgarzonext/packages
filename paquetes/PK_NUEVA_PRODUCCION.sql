--------------------------------------------------------
--  DDL for Package PK_NUEVA_PRODUCCION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_NUEVA_PRODUCCION" IS
   /******************************************************************************
    NAME:       PAC_MD_VALIDACIONES
    PURPOSE:

    REVISIONS:
    Ver        Date        Author           Description
    ---------  ----------  ---------------  ------------------------------------
    1.0        ??/??/????  ???              1. Created this package body.
    2.0        11/03/2009  DRA              2. 0009216: IAX - Revisió de la gestió de garanties en la contractació
    3.0        02/06/2009  ICV              3. 0008947: CRE046 - Gestión de cobertura Enfermedad Grave en siniestros
    4.0        18/03/2009  DRA              4. 0009496: IAX - Contractació: Gestió de preguntes de garantia + control selecció mínim 1 garantia
    5.0        24/02/2010  DRA              5. 0013352: CEM003 - SUPLEMENTS: Parametritzar canvi de forma de pagament pels productes de risc
    6.0        29/03/2010  DRA              6. 0013945: CRE 80- Saldo deutors III
    7.0        26/04/2010  DRA              7. 0014279: CRE 80- Saldo deutors IV
    8.0        07/06/2010  DRA              8. 0011288: CRE - Modificación de propuestas retenidas
    9.0        11/01/2011  APD              9. 0017221: APR - Se crea la funcion f_validar_baja_gar_col
    10.0       24/01/2011  JMP              10.0017341: APR703 - Suplemento de preguntas - FlexiLife
    11.0       04/05/2011  ICV              33. 0018350: LCOL003 - Garantías dependientes múltiples 'AND'
    12.0       25/05/2011  SRA              12. 0018345: LCOL003 - Validación de garantías dependientes de respuestas u otros factores
    13.0       19/10/2011  RSC              13. 0019412: LCOL_T004: Completar parametrización de los productos de Vida Individual
    14.0       21/11/2011  JMC              14. 0019303: LCOL_T003-Analisis Polissa saldada/prorrogada. LCOL_TEC_ProductosBrechas04
    15.0       10/12/2011  RSC              15. 0020163: LCOL_T004-Completar parametrización de los productos de Vida Individual (2ª parte)
    16.0       27/04/2012  APD              16. 0021706: MDP_T001- TEC : Capital máximo calculado o dependiente de otra
    17.0       18/05/2012  APD              17. 0021786: MDP_T001-Modificaciones pk_nueva_produccion para corregir inidencias en dependencias
   ******************************************************************************/

   -- Algunas funciones son las mismas para la emisión que para la simulación de TF
   -- Algunas funciones con código común, comenzaran a fusionarse aquí para saber el modo, se utiliza esta función.
   --- Por defecto el modo es 'EST'
   --- Valores: NULO o EST - emisión
   ---          SOL        - simulación
   PROCEDURE p_define_modo(p_in_modo IN VARCHAR2);

   /******************************************************************************
    Package encargado de las validaciones e inserciones en la introducción de
    polizas
   ******************************************************************************/
   FUNCTION f_ins_esttomador(psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_tomador(psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ins_estriesgo_tomador(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      pcdomici IN NUMBER,
      pfnacimi IN DATE,
      pcsexper IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_datosgestion(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2,
      modo IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ins_estriesgo(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pmodo IN NUMBER DEFAULT 1,
      pcdomici IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_ins_estassegurat(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pmodo IN NUMBER DEFAULT 1,
      pcdomici IN NUMBER DEFAULT NULL,
      pfefecto IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_valida_estriesgo(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      psproduc IN NUMBER,
      pcdomici IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_motivo_retencion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_ins_estpregunseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcpregun IN NUMBER,
      pcrespue IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_estpregunseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_obtener_digitoctr_bm(pcbancar IN VARCHAR2, pctipban IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_obtener_cuenta010_bm(pcbancar IN VARCHAR2, pctipban IN NUMBER DEFAULT 1)
      RETURN VARCHAR2;

   FUNCTION f_garanpro_estgaranseg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pcactivi IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_claubenseg_estclau(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      psproduc NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_clausulas(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_clausulas_gen(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_validacion_cobliga(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_valida_incompatibles(
      pcgarant IN NUMBER,
      pcobliga IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_marcar_dep_obliga(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_dependencias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_valida_obligatorias(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_validar_edad(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_validar_edad_seg(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_validar_capital_max_depen(
      picapital IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_valida_dependencias_k(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_cargar_lista_valores(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_borra_lista
      RETURN NUMBER;

   FUNCTION f_capital_maximo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin
      RETURN NUMBER;

   FUNCTION f_valida_capital(
      paccion IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION reseleccionar_gar_dependientes(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER,
      paccion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_validar_garantias_al_tarifar(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_validar_garantias(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   PROCEDURE p_modificar_fefecto_seg(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      ptablas IN VARCHAR2 DEFAULT 'EST');

   FUNCTION f_marcar_basicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_marcar_completo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_primas_a_null(psseguro IN NUMBER, pnriesgo IN NUMBER, pnmovimi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_oficina_mv
      RETURN NUMBER;

   FUNCTION f_validar_capitalmin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pnriesgo IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pnmovimi IN NUMBER,   -- Bug 0026501 - MMS - 20130416
      pcicapital IN NUMBER,
      pcicapmin IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_validar_aport_max(
      pmodo IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pfefepol IN DATE,
      psperson IN NUMBER,
      pcforpag IN NUMBER,
      pnrenova IN VARCHAR2,
      psproduc IN NUMBER,
      pfcarpro IN DATE)
      RETURN NUMBER;

--JRH 09/2007 Tarea 2674: Intereses para LRC. Añadimos los nuevos campos ndesde y nhasta.
   FUNCTION f_ins_intertecseg(
      ptabla IN VARCHAR2,
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefemov IN DATE,
      ppinttec IN NUMBER,
      pninttec IN NUMBER,
      pndesde IN NUMBER DEFAULT 0,
      pnhasta IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_valida_exclugarseg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_inserta_estpresttitulares(pctapres IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_inserta_vinculado(pctapres IN VARCHAR2, psseguro IN NUMBER, pporcent IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_poliza_prestamo(
      pctapres IN VARCHAR2,
      psperson IN NUMBER,   -- BUG13945:DRA:30/03/2010
      psseguro IN NUMBER)   -- BUG13945:DRA:30/03/2010
      RETURN NUMBER;

   FUNCTION f_valida_risc_vin(psproduc IN NUMBER, psseguro IN NUMBER, psperson IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_obtener_estcap_vin(psseguro IN NUMBER, picapital OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_obtener_titular(psseguro IN NUMBER, pctapres IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_duplicar_titular(pctapres IN VARCHAR2, psnip IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_vincpolizas_productos(pctapres IN VARCHAR2, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_fvencim_vinculados(pctapres IN VARCHAR2, pfefecto IN DATE)
      RETURN NUMBER;

   FUNCTION f_ins_estseguros(
      psproduc IN NUMBER,
      pcempres IN NUMBER DEFAULT 1,
      psseguro OUT NUMBER,
      pcidioma IN NUMBER DEFAULT 2,
      pcagente IN NUMBER DEFAULT NULL,
      pnpoliza IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      p_est_sseguro OUT NUMBER,
      pnmovimi OUT NUMBER,
      pcmodo IN VARCHAR2 DEFAULT NULL,
      ptform IN VARCHAR2 DEFAULT NULL,
      ptcampo IN VARCHAR2 DEFAULT '*')
      RETURN NUMBER;

   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, pnempleado IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_calculo_capital_calculado(
      pfecha IN DATE,
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      porigen IN NUMBER,
      pcapital OUT NUMBER)   -- 0.- sol, 1.- est, 2.- SEG
      RETURN NUMBER;

   FUNCTION f_obtener_fvencim_nduraci(
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pcduraci IN NUMBER,
      pnduraci IN OUT NUMBER,
      pfvencim IN OUT DATE)
      RETURN NUMBER;

   --(JAS)11.12.2007 - Gestió de preguntes per pòlissa
   -- Función que valida preguntas de poliza
   FUNCTION f_valida_pregun_poliza(
      p_in_sseguro IN seguros.sseguro%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_validacion_primaminfrac
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   param out p_prima : prima anual
   return             : NUMBER
   *************************************************************************/
   FUNCTION f_validacion_primaminfrac(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pprima OUT NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_validacion_primamin
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   param out p_prima : prima anual
   return             : NUMBER
   *************************************************************************/
   FUNCTION f_validacion_primamin(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pprima OUT NUMBER)
      RETURN NUMBER;

   -- BUG9216:DRA:23-02-2009
   /*************************************************************************
       FUNCTION f_comprueba_basicos
       Comprueba que alguna garantia básica haya sido seleccionada
       param in psseguro  : código del seguro
       param in pssolici  : código de la solicitud
       param in pnriesgo  : numero de riesgo
       param in psproduc  : código del producto
       param in pcactivi  : código de la actividad
       param in pnmovimi  : numero de movimiento
       param in pnmovima  : numero de movimiento de alta
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_comprueba_basicos(
      psseguro IN NUMBER,
      pssolici IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pnmovimi IN NUMBER,
      pnmovima IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   -- BUG9496:17/03/2009:DRA:Validem que estiguin contestades les preg. obligatories
   /*************************************************************************
       FUNCTION f_valida_pregun_garant
       Comprueba que la garantia tenga respondidas las preg. obligatorias
       param in psseguro  : código del seguro
       param in pnriesgo  : numero de riesgo
       param in pnmovimi  : numero de movimiento
       param in psproduc  : código del producto
       param in pcactivi  : código de la actividad
       param in pcgarant  : código de la garantía
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_pregun_garant(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN estgaranseg.cgarant%TYPE DEFAULT NULL,
      pmensa OUT VARCHAR2)
      RETURN NUMBER;

--BUG 9709 - 06/04/2009 - LPS - Validación del limite del % de crecimiento geométrico
    /*************************************************************************
       FUNCTION f_valida_limrevalgeom
       Comprueba el límite de valorización geométrica
       param in psproduc  : código del producto
       param in prevali   : porcentaje de revalorización
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_limrevalgeom(
      psproduc IN NUMBER,
      pprevali IN NUMBER,
      pplimrev OUT NUMBER,
      pcrevali IN NUMBER DEFAULT 2)
      RETURN NUMBER;

   /*************************************************************************
       Valida dependencia entre padre - dependientes. Es decir, si el padre
       está seleccionada, alguna de las dependientes debe estar seleccionada.

       param in  P_sseguro  : Código de Seguro
       param in  P_nriesgo  : Código de Riesgo
       param in  P_sproduc  : Código de Producto
       param out mensajes   : mensajes de error
       return               : 0 la validación ha sido correcta
                              1 la validación no ha sido correcta
   *************************************************************************/
   -- Bug 10113 - 18/05/2009 - RSC - Ajustes FlexiLife nueva emisión
   FUNCTION f_valida_dependencia_basica(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER)
      RETURN NUMBER;

-- Fin Bug 10113

   /*************************************************************************
        FUNCTION f_valida_siniestro
        Función para saber si se ha de mostrar o no una determinada garantía apartir del producto.
        param in ptabla: Tipo varchar2. Parámetro de entrada. Indica si va sobre las EST o las Reales.
        param in psseguro: Tipo numérico. Parámetro de entrada. Codigo del seguro
        param in pnriesgo: Tipo numérico. Parámetro de entrada. Indicador del riesgo
        param in pcgarant: Tipo numérico. Parámetro de entrada. Codigo de la garantía.
        return             : 1 se muestra la garantía
                             0 no se muestra

         Bug: 8947 - ICV - 02/06/2009
    *************************************************************************/
   FUNCTION f_validar_siniestro(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcgarant IN NUMBER)
      RETURN NUMBER;

   -- BUG9496:17/03/2009:DRA
   /*************************************************************************
       FUNCTION f_valida_marcadas
       Validem que hi hagi marcada alguna garantia
       param in psseguro  : código del seguro
       param in pnriesgo  : numero de riesgo
       param in pnmovimi  : numero de movimiento
       return             : NUMBER
   *************************************************************************/
   FUNCTION f_valida_marcadas(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER)
      RETURN NUMBER;

   -- BUG13352:DRA:24/02/2010:Inici
   /*************************************************************************
   FUNCTION ff_validacion_primaminfrac
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   return               : prima anual
   *************************************************************************/
   FUNCTION ff_validacion_primaminfrac(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION ff_validacion_primamin
   Valida la prima minima
   param in p_sproduc   : código del producto
   param in p_sseguro   : código del seguro
   param in p_nriesgo   : código del riesgo
   return               : prima anual
   *************************************************************************/
   FUNCTION ff_validacion_primamin(psproduc IN NUMBER, psseguro IN NUMBER, pnriesgo IN NUMBER)
      RETURN NUMBER;

-- BUG13352:DRA:24/02/2010:Fi

   -- BUG14279:DRA:26/04/2010:Inici
   /*************************************************************************
       FUNCTION f_capmax_poliza_prestamo
       Retorna el importe maximo a asegurar
       param in psperson   : código de la persona
       param in psseguro   : código del seguro
       param in psproduc   : código del producto
       param out picapmax  : importe maximo a asegurar
       return              : 0--> OK    <> 0 --> Error
   *************************************************************************/
   FUNCTION f_capmax_poliza_prestamo(
      psperson IN NUMBER,
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      picapmax OUT NUMBER)
      RETURN NUMBER;

   -- BUG14279:DRA:26/04/2010:Fi

   -- BUG11288:DRA:07/06/2010:Inici
   FUNCTION f_borrar_riesgo(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT NULL,
      pmodo IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

-- BUG11288:DRA:07/06/2010:Fi

   -- BUG17221:APD:11/01/2011:Inici
   FUNCTION f_validar_baja_gar_col(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER;

-- BUG17221:APD:11/01/2011:Fi
   /*************************************************************************
       PROCEDURE p_select_tarifar_detalle
       Marca con CUNICA = 3 la línea de detalle de garantía que se debe
       tarificar, y con CUNICA = 2 las que no se deben tarificar.
       Las líneas de detalle con CUNICA = 1 se dejan tal como están.
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in pcgarant : código de garantía
   *************************************************************************/
   -- Bug 17341 - 24/01/2011 - JMP - Se crea la función
   PROCEDURE p_select_tarifar_detalle(
      psseguro IN NUMBER,
      psolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcgarant IN NUMBER);

   /*************************************************************************
       FUNCTION f_marcar_dep_multiples
       Función para marcar las garantías multiples dependientes
       param in psproduc : código de producto
       param in pcactivi : código de actividad
       param in pcgarant : código de garantía
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in out pmensa : texto de error
       param in out pnmovima : número de movimiento alta
   *************************************************************************/
   --Bug.: 18350 - ICV - 29/04/2011
   FUNCTION f_marcar_dep_multiples(
      paccion VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
       FUNCTION f_cumpleix_dep_multiple
       Función para marcar las garantías multiples dependientes
       param in psproduc : código de producto
       param in pcactivi : código de actividad
       param in pcgarant : código de garantía
       param in psseguro : código de seguro
       param in pnriesgo : número de riesgo
       param in pnmovimi : número de movimiento
       param in out pmensa : texto de error
       param in out pnmovima : número de movimiento alta
   *************************************************************************/
   --Bug.: 18350 - ICV - 01/05/2011
   FUNCTION f_cumpleix_dep_multiple(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pnmovima IN NUMBER)
      RETURN NUMBER;

   -- Ini bug 18345 - SRA - 02/05/2011
   /*************************************************************************
      FUNCTION f_valida_garanproval
      Función que recorrerá GARANPRO_VALIDACION y recuperará las funciones que de validación que se han definido
      para las garantías seleccionadas.
      pcgarant in number: código de la garantía
      pcobliga in number: indicador de si la garantía está marcada
      psseguro in number: identificador del seguro
      pnriesgo in number: número del riesgo
      pnmovimi in number: número de movimiento
      psproduc in number: código de producto
      pcactivi in number: código de la actividad
      pmensa in out number: parámetro de entrada/salida
      return number: retorno de la función f_valida_garanproval
   *************************************************************************/
   FUNCTION f_valida_garanproval(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2,
      pcprepost IN VARCHAR2 DEFAULT NULL)
      RETURN NUMBER;

-- Fi bug 18345 - SRA - 02/05/2011
   -- Ini bug 19303 - JMC - 21/11/2011
   /*************************************************************************
      FUNCTION f_crearpropuesta_sp
      Función que generara una póliza del producto SALDAR o PRORROGAR, tomando
      los datos de una póliza origen
      psseguro in number: código del seguro origen
      piprima_np in number:
      picapfall_np in number: capital fallecimiento de la nueva póliza
      pfvencim_np in date: fecha vencimiento de la nueva póliza
      pmode in number: Modo
      pfecha in date: fecha efecto nueva póliza.
      psolicit out number: Número solicitud.
      purl out varchar2:
      pmensa in out varchar2: mensajes de error.
      return number: retorno de la función f_crearpropuesta_sp
   *************************************************************************/
   FUNCTION f_crearpropuesta_sp(
      psseguro IN NUMBER,
      piprima_np IN NUMBER,
      picapfall_np IN NUMBER,
      pfvencim_np IN DATE,
      pmode IN VARCHAR2,
      pfecha IN DATE,
      pssolicit OUT NUMBER,
      purl OUT VARCHAR2,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER;

-- Fi bug 19303 - JMC - 21/11/2011
   -- Bug 21706 - APD - 24/04/2012 - se crea la funcion
   FUNCTION f_capital_maximo_garantia_post(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcapital OUT NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin)
      RETURN NUMBER;

   FUNCTION f_capital_minimo_garantia_post(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,   -- Bug.14322:ASN:28/04/2010.ini
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcapital OUT NUMBER,
      pnmovima NUMBER DEFAULT 1)   -- Bug.14322:ASN:28/04/2010.fin)
      RETURN NUMBER;

   -- Ini bug 21786 - APD - 18/05/2012
   /*************************************************************************
      FUNCTION f_valida_dep_garantias
      Función que recorrerá DEP_GARANTIAS y recuperará las funciones que de validación que se han definido
      para las garantías seleccionadas.
      pcgarant in number: código de la garantía
      psseguro in number: identificador del seguro
      pnriesgo in number: número del riesgo
      pnmovimi in number: número de movimiento
      psproduc in number: código de producto
      pcactivi in number: código de la actividad
      pmensa in out number: parámetro de entrada/salida
      return number: retorno de la función f_valida_garanproval
   *************************************************************************/
   FUNCTION f_valida_dep_garantias(
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa IN OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************/
   FUNCTION f_capital_minimo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER
                        --pcicapmin IN OUT NUMBER  --************
   )
      RETURN NUMBER;
/*************************************************/
END pk_nueva_produccion;

/

  GRANT EXECUTE ON "AXIS"."PK_NUEVA_PRODUCCION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_NUEVA_PRODUCCION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_NUEVA_PRODUCCION" TO "PROGRAMADORESCSI";
