CREATE OR REPLACE PACKAGE pac_propio_albsgt_conf IS

   /******************************************************************************
      NOMBRE:     PAC_PROPIO_ALBSGT_CONF
      PROPÓSITO:  Cuerpo del paquete de las funciones para
                  el cáculo de las preguntas relacionadas con
                  productos de CONF

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/07/2011   JLTS            1. XXXXXX: CONF - Parametrización básica producto Vida Individual Pagos Permanentes
      2.0        08/09/2016   NMM             1. Función f_capacidad_contrato
      3.0        24/10/2016   LPP             A�ado funci�n f_respues_tip_colect que da las respuestas en funci�n del tipo colectivo y la pregunta a informar
   ******************************************************************************/
   resultado      NUMBER;
   /*************************************************************************
      FUNCTION f_capacidad_contrato

      param in psseguro  : Identificador seguro
      return             : number
   *************************************************************************/
   FUNCTION f_capacidad_contrato( ptablas   IN VARCHAR2
                                , psseguro  IN NUMBER
                                , pnriesgo  IN NUMBER
                                , pfefecto  IN DATE
                                , pnmovimi  IN NUMBER
                                , cgarant   IN NUMBER
                                , psproces  IN NUMBER
                                , pnmovima  IN NUMBER
                                , picapital IN NUMBER) RETURN NUMBER;
--
    FUNCTION f_edad_riesgo(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_aportacion(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_aportextr(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE, -- No s'utilitza
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER, -- No s'utilitza
             picapital    IN    NUMBER -- No s'utilitza

    )
      RETURN NUMBER;

    FUNCTION f_primasriesgo(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE, -- No s'utilitza
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER, -- No s'utilitza
             picapital    IN    NUMBER -- No s'utilitza

    )
      RETURN NUMBER;

    FUNCTION f_imc(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_decada_nivelada(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_edad_decada_nivelada(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_doc_requerida(
             ptablas    IN    VARCHAR2,
             pcactivi    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnmovimi    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_extraprima_ocupacion(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_extraprima_zona(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_extraprima_deporte(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_extraprima_salud(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_comision_c1(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_comision_c2_c(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_tabla_mortalidad(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_fecha_efecto(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_fefecto_migracion(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_capital_inicial(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_sexo_riesgo(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_fechavto(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_version_condicionado(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_fecha_renovacion(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_calcula_revaloriza(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pmodo    IN    NUMBER DEFAULT 1
    )   RETURN NUMBER;

    FUNCTION f_prima_nivelada_gar(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_beneficiario_oneroso(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_fecha_tasa_cambio(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcmonori    IN    VARCHAR2 DEFAULT 'COP',
             pcmondes    IN    VARCHAR2 DEFAULT 'USD'
    )   RETURN NUMBER;

    FUNCTION f_tasa_cambio(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcmonori    IN    VARCHAR2 DEFAULT 'COP',
             pcmondes    IN    VARCHAR2 DEFAULT 'USD'
    )   RETURN NUMBER;

    FUNCTION f_capital_decada_nivelada(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_calc_prima_inicial(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_edad_promedio(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_arrastra_pregunta(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER,
             pcpregun    IN    NUMBER DEFAULT NULL,
             pnriesgocp    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_hereda_pregunta(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER,
             pcpregun_orig    IN    NUMBER DEFAULT NULL,
             pcgarant_orig    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_num_asegur(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_porcen_valor_aseg(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_num_aseg_mayor_12(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_num_aseg_menor_12(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_arrastra_pregunta_plan(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_smmlv(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcmonori    IN    VARCHAR2 DEFAULT 'SMV',
             pcmondes    IN    VARCHAR2 DEFAULT 'COP',
             pcpregun    IN    NUMBER DEFAULT 4823
    )   RETURN NUMBER;

    FUNCTION ftaxeda(
             psession    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             pcpregun    IN    NUMBER,
             pccolumn    IN    NUMBER,
             pedad    IN    NUMBER,
             porigen    IN    NUMBER DEFAULT 1
    )   RETURN NUMBER;

    FUNCTION f_arrastra_tasa(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_respue_si_contributivo(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_sucursal_user(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_porcen_pu(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION ftsmmlv(
             psession    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pcgarant    IN    NUMBER,
             pmonori    IN    VARCHAR2,
             pmondtn    IN    VARCHAR2,
             pfefecto    IN    NUMBER,
             porigen    IN    NUMBER DEFAULT 1
    )   RETURN NUMBER;

    FUNCTION f_cartera(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_arrastra_capital(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_alta_certificado_doc(
             ptablas    IN    VARCHAR2,
             pcactivi    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnmovimi    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_prima_minima(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_tabla_mortalidad_reempl(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_prima_manual_anualizada(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_discriminante(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_preg_subtab(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER,
             pcsubtabla    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_respue_retorno(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_arrastra_pregunta_carencia(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_autos_antiguedad(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_autos_siniestros(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_copia_pregunta(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_buscabonfran(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcgrup    IN    NUMBER,
             pcque    IN    NUMBER
    )   RETURN VARCHAR2;

    FUNCTION f_autos_continuidad(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN VARCHAR2;

    FUNCTION f_sucursal(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_factor_disposi(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcsubtabla    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_factor_deduci(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcsubtabla    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_max_subtab(
             pcempres    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION fant(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_garant_planbenef(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_capital_planbenef(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_dto_campanya(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_tasa_unica(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_agente(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_clas_motos(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_cmoto(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_rarea(
             psseguro    IN    NUMBER,
             pfcaranu    IN    DATE
    )   RETURN NUMBER;

    FUNCTION f_alta_certificado(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER
    )   RETURN BOOLEAN;

    FUNCTION f_factor_disposi_pac(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcsubtabla    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_factor_deduci_pac(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcsubtabla    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION ftpcegr(
             psesion    IN    NUMBER,
             psproduc    IN    NUMBER,
             pcgarant    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_modpi(
             psesion    IN    NUMBER,
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnmovimi    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_m6047(
             psesion    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pnmovimi    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_pgara(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_moawl(
             psesion    IN    NUMBER,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pnmovimi    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_agrup_vehi(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_arrastra_pretabcolum(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pcpregun    IN    NUMBER,
             pnval    IN    NUMBER DEFAULT 1
    )   RETURN NUMBER;

    FUNCTION f_factorg(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
             pnpoliza    IN    NUMBER DEFAULT NULL
    )   RETURN NUMBER;

    FUNCTION f_notas_tecnicas_nuevas(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             pcgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_nriesgo_aseg_pcpal(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_reparte_peso(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER
    )   RETURN NUMBER;

    FUNCTION f_respues_recibo_por(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
       pcpregun IN  NUMBER
    )   RETURN NUMBER;

  FUNCTION f_valida_comisiones(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
       pcrespue IN NUMBER,
       pcpregun IN VARCHAR2
    )   RETURN NUMBER;

  FUNCTION f_valida_comisiones_unif(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
       pcrespue IN NUMBER,
       pcpregun IN VARCHAR2
    )   RETURN NUMBER;
    FUNCTION f_valida_comision_rce(
             ptablas    IN    VARCHAR2,
             psseguro    IN    NUMBER,
             pnriesgo    IN    NUMBER,
             pfefecto    IN    DATE,
             pnmovimi    IN    NUMBER,
             cgarant    IN    NUMBER,
             psproces    IN    NUMBER,
             pnmovima    IN    NUMBER,
             picapital    IN    NUMBER,
       pcrespue IN NUMBER,
       pcpregun IN VARCHAR2
    )   RETURN NUMBER;

   FUNCTION f_recuperar_vsubtabla(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      p_in_nsesion IN NUMBER,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      p_in_v_fecha IN DATE DEFAULT NULL)
      RETURN NUMBER;
      FUNCTION f_recuperar_tasa_convenio(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      p_in_nsesion IN NUMBER,
      p_in_csubtabla IN sgt_subtabs_det.csubtabla%TYPE,
      p_in_cquery IN VARCHAR2,
      p_in_cval IN NUMBER,
      p_in_ccla1 IN sgt_subtabs_det.ccla1%TYPE,
      p_in_ccla2 IN sgt_subtabs_det.ccla2%TYPE DEFAULT NULL,
      p_in_ccla3 IN sgt_subtabs_det.ccla3%TYPE DEFAULT NULL,
      p_in_ccla4 IN sgt_subtabs_det.ccla4%TYPE DEFAULT NULL,
      p_in_ccla5 IN sgt_subtabs_det.ccla5%TYPE DEFAULT NULL,
      p_in_ccla6 IN sgt_subtabs_det.ccla6%TYPE DEFAULT NULL,
      p_in_ccla7 IN sgt_subtabs_det.ccla7%TYPE DEFAULT NULL,
      p_in_ccla8 IN sgt_subtabs_det.ccla8%TYPE DEFAULT NULL,
      p_in_ccla9 IN sgt_subtabs_det.ccla9%TYPE DEFAULT NULL,
      p_in_ccla10 IN sgt_subtabs_det.ccla10%TYPE DEFAULT NULL,
      p_in_v_fecha IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_anyo_vinc_cons_carg(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_tipo_contragarantia(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calc_capfinan(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER,
      ptipo IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_es_consorcio(
      ptablas IN VARCHAR2,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      cgarant IN NUMBER,
      psproces IN NUMBER,
      pnmovima IN NUMBER,
      picapital IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_suma_preguntas_trdm(
            ptablas    IN    VARCHAR2,
            psseguro    IN    NUMBER,
            pnriesgo    IN    NUMBER,
            pfefecto    IN    DATE,
            pnmovimi    IN    NUMBER,
            pcgarant    IN    NUMBER,
            psproces    IN    NUMBER,
            pnmovima    IN    NUMBER,
            picapital    IN    NUMBER,
            pcpregun    IN    NUMBER)
      RETURN NUMBER;

   FUNCTION f_calc_val_ind_trdm(
            ptablas    IN    VARCHAR2,
            psseguro    IN    NUMBER,
            pnriesgo    IN    NUMBER,
            pfefecto    IN    DATE,
            pnmovimi    IN    NUMBER,
            pcgarant    IN    NUMBER,
            psproces    IN    NUMBER,
            pnmovima    IN    NUMBER,
            picapital    IN    NUMBER)
      RETURN NUMBER;

    FUNCTION f_tasa_rc(
         ptablas    IN    VARCHAR2,
            psseguro    IN    NUMBER,
            pnriesgo    IN    NUMBER,
            pfefecto    IN    DATE,
            pnmovimi    IN    NUMBER,
            pcgarant    IN    NUMBER,
            psproces    IN    NUMBER,
            pnmovima    IN    NUMBER,
            picapital    IN    NUMBER)
      RETURN NUMBER;

     FUNCTION f_recupera_comision (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant     IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER;
      --IAXIS - 4802 -- ECP -- 07/08/2019
FUNCTION f_tasa_convenio_rc (
      ptablas     IN   VARCHAR2,
      psseguro    IN   NUMBER,
      pnriesgo    IN   NUMBER,
      pfefecto    IN   DATE,
      pnmovimi    IN   NUMBER,
      pcgarant    IN   NUMBER,
      psproces    IN   NUMBER,
      pnmovima    IN   NUMBER,
      picapital   IN   NUMBER
   )
      RETURN NUMBER;
      
  --IAXIS - 4802 -- ECP -- 07/08/2019    
END pac_propio_albsgt_conf;
/
