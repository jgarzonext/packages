--------------------------------------------------------
--  DDL for Package PK_SIMULACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PK_SIMULACIONES" AUTHID CURRENT_USER IS
   FUNCTION f_crea_solicitud(
      psproduc IN NUMBER,
      pssolicit OUT NUMBER,
      pnumriesgos IN NUMBER DEFAULT 1,
      pfefecto IN DATE DEFAULT f_sysdate)
      RETURN NUMBER;

   FUNCTION f_crea_solriesgo(pssolicit IN NUMBER, pnriesgo IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_crea_solasegurado(
      pssolicit IN NUMBER,
      pnorden IN NUMBER,
      ptapelli IN VARCHAR2 DEFAULT '*',
      ptnombre IN VARCHAR2 DEFAULT '*',
      pfnacimi IN DATE DEFAULT NULL,
      pcsexper IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_crea_solgarant(
      pssolicit IN NUMBER,
      pnriesgo IN NUMBER,
      pcramo IN NUMBER,
      pcmodali IN NUMBER,
      pctipseg IN NUMBER,
      pccolect IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE)
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

   FUNCTION f_validar_capital_max_depen(
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

   FUNCTION f_cargar_lista_valores
      RETURN NUMBER;

   FUNCTION f_borra_lista
      RETURN NUMBER;

   FUNCTION f_capital_maximo_garantia(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER)
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

   FUNCTION f_int_estimado(psproduc IN NUMBER, pcactivi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_validar_edad_prod(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pssolicit IN NUMBER DEFAULT NULL,
      pfnacimi2 IN DATE DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_control_edat_sim(
      pfnacimi IN DATE,
      pfecha IN DATE,
      pnedamic IN NUMBER,
      pciedmic IN NUMBER,
      pnedamac IN NUMBER,
      pciedmac IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_calcula_importe_maximo(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      anyo NUMBER,
      pcforpag IN NUMBER,
      pfefecto IN DATE,
      pfnacimi IN DATE,
      pcestado IN NUMBER DEFAULT 0)
      RETURN NUMBER;

   FUNCTION f_validar_capitalmin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcforpag IN NUMBER,
      pcgarant IN NUMBER,
      pcicapital IN NUMBER,
      pcicapmin IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_datosgestion(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_valida_solpregunseg(
      p_in_ssolicit IN solseguros.ssolicit%TYPE,
      pnriesgo IN NUMBER,
      psproduc IN NUMBER,
      tipo OUT NUMBER,
      campo OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_valida_pregun_garant(
      p_in_sseguro IN seguros.sseguro%TYPE,
      pnriesgo IN riesgos.nriesgo%TYPE,
      pnmovimi IN NUMBER,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pmensa OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
      Grabar un registro en la tabla PERSISTENCIA_SIMUL si no existe
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_alta_persistencia_simul(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
      Actualiza el estado de la simulacion a 4 y borra la simulacion de la tabla de persisntecia
      param in psseguro     : cdigo de solicitud
      param in out mensajes : mensajes error
      return                : 0 todo correcto
                              1 ha habido un error
   *************************************************************************/
   FUNCTION f_actualizar_persistencia(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
/******************************************************************************
  Package encargado de las simulaciones
******************************************************************************/
END pk_simulaciones;

/

  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PK_SIMULACIONES" TO "PROGRAMADORESCSI";
