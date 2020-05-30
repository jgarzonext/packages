  CREATE OR REPLACE PACKAGE "PAC_CUMULOS_CONF" AS
  /******************************************************************************
        NOMBRE:       PAC_CUMULOS_CONF
        PROPÓSITO:  Funciones para gestionar los cumulos del tomador

        REVISIONES:
        Ver        Fecha        Autor   Descripción
       ---------  ----------  ------   ------------------------------------
        1.0        25/01/2017   HRE     1. Creación del package.
        2.0        05/02/2020   DFR     2. IAXIS-11903: Anulación de póliza
        3.0        27/04/2020   DFR     3. IAXIS-12992: Cesión en contratos con más de un tramo
  ******************************************************************************/
/*************************************************************************
    FUNCTION f_set_depuracion_manual
    Permite generar el registro de depuracion manual
    param in pfcorte        : Fecha de corte
    param in ptcumulo       : Tipo de cumulo
    param in pnnumide       : Documento del tomador
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_set_depuracion_manual(psseguro       IN     NUMBER,
                                    pcgenera       IN     NUMBER,
                                    pcgarant       IN     NUMBER,
                                    pindicad       IN     VARCHAR2,
                                    pvalor         IN     NUMBER
                                    )
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_depura_auto
    Permite obtener por poliza y garantia el valor de la depuracion automatica
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param in pmodo          : modo (Alta, consulta)
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depura_auto(pfcorte  IN DATE,
                                  psseguro IN NUMBER,
                                  pcgarant IN NUMBER,
                                  psperson IN NUMBER,
                                  ptablas  IN VARCHAR2 DEFAULT 'POL',
                                  pmodo    IN VARCHAR2 DEFAULT 'ALTA') -- IAXIS-11903 05/02/2020
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_depura_manual
    Permite obtener por poliza y garantia el valor de la depuracion manual
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depura_manual(pfcorte  IN     DATE,
                                  psseguro   IN     NUMBER,
                                  pcgarant   IN     NUMBER,
                                  pcgenera   IN NUMBER,
                                  psperson IN NUMBER)
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_comfu_cont
    Permite obtener por poliza los compromisos futuros contractuales
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_comfu_cont(psseguro   IN     NUMBER,
                                 psperson IN NUMBER)

   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_comfu_pos
    Permite obtener por poliza los compromisos futuros poscontractuales
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param out mensajes      : mesajes de error
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_comfu_pos(psseguro   IN     NUMBER,
                                psperson IN NUMBER)

   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_cupo_autorizado
    Permite obtener el cupo autorizado de una persona a una fecha
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_cupo_autorizado(pfcorte  IN DATE,
                                      psperson IN NUMBER)

   RETURN NUMBER;

  /*************************************************************************
    FUNCTION f_calcula_cupo_modelo
    Permite obtener el cupo modelo de una persona a una fecha
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_cupo_modelo(pfcorte  IN DATE,
                                  psperson IN NUMBER)

   RETURN NUMBER;
  /*************************************************************************
    FUNCTION f_get_fechadepu
    Permite obtener la fecha de depuracion del maximo movimiento de depuracion
    para el seguro y amparo
    param in psseguro       : seguro
    param in pcgarant       : garantia
    return                  : date
   *************************************************************************/
   FUNCTION f_get_fechadepu(psseguro IN     NUMBER,
                            pcgarant IN     NUMBER)

   RETURN DATE;
   /*************************************************************************
    FUNCTION f_get_porc_garantia
    Permite obtener el porcentaje que representan los diferentes tramos en cada
    garantia de depuracion automatica
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in pscontra       : contrato de reaseguro
    param in psseguro       : eguro
    param in pcgarant       : garantia
    return                  : number
   *************************************************************************/
   FUNCTION f_get_porc_garantia(pfcorte  IN DATE,
                                psperson IN NUMBER,
                                pscontra IN NUMBER,
                                psseguro IN NUMBER,
                                pcgarant IN NUMBER
                                )
   RETURN NUMBER;
  /*************************************************************************
    FUNCTION f_calcula_cumries_tramo
    Permite obtener el cumulo en riesgo por tramo
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in pscontra       : contrato de reaseguro
    param in pctramo        : tramo de contrato de reaseguro
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_cumries_tramo(pfcorte  IN DATE,
                                  psperson IN NUMBER,
                                  pscontra IN NUMBER,
                                  pctramo  IN NUMBER)
   RETURN NUMBER;
  /*************************************************************************
    FUNCTION f_calcula_disponible_tramo
    Calcula el minimo porcentaje disponible en el tramo por persona
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona del consorcio/tomador
    param in pscontra       : contrato de reaseguro
    param in pnversio       : version del contrato
    param in pctramo        : tramo de contrato de reaseguro
    param in pivalaseg      : valor asegurado de la poliza
    param in pconsorcio     : indica si es o no un consorcio
    param in pctipcoa       : tipo de coaseguro
    param in sseguro        : seguro
    param in pmotiu         : tipo de cesión
    param ptablas           : tablas (reales, estudio)
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_disponible_tramo(pfcorte    IN DATE,
                                       psperson   IN NUMBER,
                                       pscontra   IN NUMBER,
                                       pnversio   IN NUMBER,
                                       pctramo    IN NUMBER,
                                       pivalaseg  IN NUMBER,
                                       pconsorcio IN VARCHAR2,
                                       pctipcoa   IN NUMBER,
                                       -- Inicio IAXIS-12992 26/04/2020
                                       psseguro   IN NUMBER,
                                       pmotiu     IN NUMBER,
                                       ptablas    IN VARCHAR2
                                       -- Fin IAXIS-12992 26/04/2020
                                       )
   RETURN NUMBER;

  /*************************************************************************
    FUNCTION f_get_cons_cesionesrea
    Obtiene el consecutivo de cesionesrea para un participante de consorcio
    param in psseguro       : seguro
    param in pscontra       : contrato de reaseguro
    param in pnversio       : version del contrato
    param in pctramo        : tramo de contrato de reaseguro
    param in pnriesgo       : riesgo
    param in pctrampa       : tramo padre
    param in pcgenera       : tipo de movimiento
    param in pnmovimi       : numero movimiento
    return                  : number
   *************************************************************************/
   FUNCTION f_get_cons_cesionesrea(psseguro IN NUMBER,
                                   pscontra IN NUMBER,
                                   pnversio IN NUMBER,
                                   pctramo  IN NUMBER,
                                   pnriesgo IN NUMBER,
                                   pctrampa IN NUMBER,
                                   pcgenera IN NUMBER,
                                   pnmovimi IN NUMBER
                                   )
   RETURN NUMBER;
--

/*************************************************************************
    FUNCTION fun_cum_nories_tom
    Obtiene el cumulo en no riesgo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_nories_tom(p_nnumide IN VARCHAR2,

                                   p_fcorte IN DATE
                                   )
   RETURN NUMBER;

/*************************************************************************
    FUNCTION fun_cum_nories_serie
    Obtiene el cumulo en no riesgo total por tomador y anio/serie
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    param in p_serie       : anio/ serie
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_nories_serie(p_nnumide IN VARCHAR2,
                                   p_fcorte IN DATE,
                                   p_serie IN VARCHAR2
                                   )
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_cum_total_tom
    Obtiene el cumulo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_total_tom(p_nnumide IN VARCHAR2,
                            p_fcorte  IN DATE,
                            p_ctramo  IN NUMBER DEFAULT NULL) -- IAXIS-12992 27/04/2020
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION fun_cum_ries_tom
    Obtiene el cumulo en riesgo total por tomador
    param in p_nnumide      : identificacion del tomador
    param in p_fcorte       : fecha de corte
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_ries_tom(p_nnumide IN VARCHAR2,
                           p_fcorte  IN DATE)
   RETURN NUMBER;
   --
   -- Inicio IAXIS-12992 27/04/2020
   --
   /*************************************************************************
    FUNCTION f_calcula_depuracion_pol
    Permite obtener por poliza el valor depurado automáticamente de la garantía
    de entrada. Se devuelve un valor diferente de 0 con el valor del capital de 
    la garantía si debe depurarse.
    param in pfcorte        : fecha de corte
    param in psseguro       : seguro
    param in pcgarant       : garantia
    param in psperson       : Tomador/Afianzado
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depuracion_pol(pfcorte  IN DATE,
                                     psseguro IN NUMBER,
                                     pcgarant IN NUMBER,
                                     psperson IN NUMBER) 
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_depuracion_tramo
    Permite obtener la depuración por tramo para un contrato y versión en específico
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in psseugro       : seguro
    param in pscontra       : contrato de reaseguro
    param in pnversio       : versión del contrato
    param in pctramo        : tramo de contrato de reaseguro
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depuracion_tramo(pfcorte  IN DATE,
                                       psperson IN NUMBER,
                                       psseguro IN NUMBER,
                                       pscontra IN NUMBER,
                                       pnversio IN NUMBER,
                                       pctramo  IN NUMBER)
   RETURN NUMBER;                                    
   /*************************************************************************
    FUNCTION f_cum_total_tom_tramo
    Obtiene el cumulo total del tomador/afianzado por tramo.
    param in p_sperson      : secuencia de persona (tomador/afianzado)
    param in p_fcorte       : fecha de corte
    param in p_sseguro      : seguro
    param in p_scontra      : contrato de reaseguro
    param in p_nversio      : versión del contrato
    param in p_ctramo       : tramo del contrato
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_total_tom_tramo(p_sperson IN NUMBER,
                                  p_fcorte  IN DATE,
                                  p_sseguro IN NUMBER,
                                  p_scontra IN NUMBER,
                                  p_nversio IN NUMBER,
                                  p_ctramo  IN NUMBER)
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_cum_total_tom_otros
    Obtiene el cumulo total del tomador/afianzado proveniente de otras versiones del contrato de reaseguros 
    param in p_sperson      : secuencia de persona (tomador/afianzado)
    param in p_fcorte       : fecha de corte
    param in p_sseguro      : seguro
    param in p_scontra      : contrato de reaseguro
    param in p_nversio      : versión del contrato
    param in p_ctramo       : tramo del contrato
    return                  : number
   *************************************************************************/
   FUNCTION f_cum_total_tom_otros(p_sperson IN NUMBER,
                                  p_fcorte  IN DATE,
                                  p_sseguro IN NUMBER,
                                  p_scontra IN NUMBER,
                                  p_nversio IN NUMBER,
                                  p_ctramo  IN NUMBER)
   RETURN NUMBER;
   /*************************************************************************
    FUNCTION f_calcula_depuracion_otros
    Obtiene la depuración proveniente de otras versiones del contrato de reaseguros 
    param in pfcorte        : fecha de corte
    param in psperson       : codigo de persona
    param in psseguro       : seguro
    param in pscontra       : contrato de reaseguro
    param in pnversio       : versión del contrato
    param in pctramo        : tramo de contrato de reaseguro
    return                  : number
   *************************************************************************/
   FUNCTION f_calcula_depuracion_otros(pfcorte  IN DATE,
                                       psperson IN NUMBER,
                                       psseguro IN NUMBER,
                                       pscontra IN NUMBER,
                                       pnversio IN NUMBER,
                                       pctramo  IN NUMBER)
   RETURN NUMBER;      
   --
   -- Fin IAXIS-12992 27/04/2020
   --
END pac_cumulos_conf;

/
