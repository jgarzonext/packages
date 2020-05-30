--------------------------------------------------------
--  DDL for Package PAC_BPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_BPM" IS
/******************************************************************************
   NOMBRE:       PAC_BPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/06/2009   JLB                1. Creación del package.
******************************************************************************/
   num_parametros CONSTANT NUMBER := 20;

   TYPE rparametros IS VARRAY(20) OF VARCHAR2(200);

   SUBTYPE tparametros IS rparametros;

   /*********************************************************************************************************************
   * Funcion f_crear_proceso
   * Funcion que crea un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_crear_proceso(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   /*********************************************************************************************************************
   * Funcion f_envio_evento
   * Funcion que envia un evento (pevento) a un proceso (pproceso) BPM, llama al axisconnectBPM
   * Parametros: pempresa: empresa a la que pertence el proceso
   *             pusuario: usuario con que se abre el proceso
   *             password: paswrod usuario
   *             pparametros: array de parametros que necesita el proceso
   * Return: 0 OK, otro valor error.
   *********************************************************************************************************************/
   FUNCTION f_envio_evento(
      pempresa IN NUMBER,
      pusuario IN VARCHAR2,
      ppassword IN VARCHAR2,
      pproceso IN VARCHAR2,
      pevento IN VARCHAR2,
      pparametros IN tparametros,
      psinterf IN OUT NUMBER,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   /*********************************************************************************************************************
   * Funcion f_lanzar_proceso
   * Funcion que dado un sseguro, nmovimi y/o nsinies, perfil del usuario y modo  mira si se tiene que lanzar un proceso
   * BPM.
   * Parametros: psseguro: sseguro de la poliza
   *             pnmovimi: número de movimiento de la poliza
   *             pnsinies: número de siniestro
   *             pcperfil: perfil del usuario
   *             pcmodo  : operación que se está realizando (EMISION,SUPLEMENTO,SINIESTRO,etc)
   *             mensajes out: mensajes de error
   * Return: 0 OK, otro valor error.
   **********************************************************************************************************************/
   FUNCTION f_lanzar_proceso(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnsinies IN VARCHAR2,
      pcperfil IN VARCHAR2,
      pcmodo IN VARCHAR2,
      perror OUT VARCHAR2)
      RETURN NUMBER;

   /*********************************************************************************************************************
   * FUNCIONES que deberian estar OBSOLETAS!!! No usar
   * Funciones propias de pilotos y demos, deben subsituirse en los procesos por funciones iaxis.
   *
   *
   **********************************************************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_emitirpropuesta(
      psseguro IN seguros.sseguro%TYPE,
      pnmovimi IN NUMBER,
      ppoliza OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_aceptarsobreprima(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      pprecarg IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_citamedica(
      psseguro IN seguros.sseguro%TYPE,
      p_fecha_hora_visita IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_bpm;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_BPM" TO "PROGRAMADORESCSI";
