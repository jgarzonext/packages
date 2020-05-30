--------------------------------------------------------
--  DDL for Package PAC_IAX_BPM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_BPM" IS
/******************************************************************************
   NOMBRE:       PAC_IAX_BPM
   PROPÓSITO: Funciones para integracion de BPM con AXIS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        20/06/2009   JLB                1. Creación del package.
******************************************************************************/
   SUBTYPE tparametros IS pac_md_bpm.tparametros;

   /* TYPE datostomador IS RECORD(
       telefono       VARCHAR2(100),
       email          VARCHAR2(100)
    ); */

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
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
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
      perror OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*********************************************************************************************************************
   * FUNCIONES que deberian estar OBSOLETAS!!! No usar
   * Funciones propias de pilotos y demos, deben subsituirse en los procesos por funciones iaxis.
   *
   *
   **********************************************************************************************************************/
   FUNCTION f_aceptarpropuesta(psseguro IN seguros.sseguro%TYPE   --,
                                                               --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_emitirpropuesta(psseguro IN seguros.sseguro%TYPE, ppoliza OUT VARCHAR2   --,
                                                                                    --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_rechazarpropuesta(psseguro IN seguros.sseguro%TYPE   --,
                                                                --mensajes   out t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_aceptarsobreprima(psseguro IN NUMBER, pprecarg IN NUMBER   --,
                                                                      --mensajes in OUT T_IAX_MENSAJES
   )
      RETURN NUMBER;

   FUNCTION f_getpoblacionasegurado(
      psseguro IN NUMBER,
      ppoblac OUT NUMBER,
      pdescprovin OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_getcontactotomador(
      psseguro IN NUMBER,
      pemail OUT VARCHAR2,
      ptelfmovil OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_informacion_poliza(
      psseguro IN NUMBER,
      pproducto OUT VARCHAR2,
      ptomador OUT VARCHAR2,
      ptelefono OUT VARCHAR2,
      pprima OUT VARCHAR2,
      priesgo OUT VARCHAR2,
      pfefecto OUT VARCHAR2,
      ptipomov OUT VARCHAR2,
      pgarantias OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ins_reserva(
      pnsinies IN VARCHAR2,
      pntramit IN NUMBER,
      pctipres IN NUMBER,
      pcgarant IN NUMBER,
      pccalres IN NUMBER,
      pfmovres IN DATE,
      pcmonres IN VARCHAR2,
      pireserva IN NUMBER,
      pipago IN NUMBER,
      picaprie IN NUMBER,
      pipenali IN NUMBER,
      piingreso IN NUMBER,
      pirecobro IN NUMBER,
      pfresini IN DATE,
      pfresfin IN DATE,
      psidepag IN NUMBER,
      pnmovres IN OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_citamedica(
      psseguro IN seguros.sseguro%TYPE,
      p_fecha_hora_visita IN VARCHAR2   --,
                                     --mensajes              out t_iax_mensajes
   )
      RETURN NUMBER;

   FUNCTION f_getdocs(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfichero1 OUT BLOB,
      pnomfichero1 OUT VARCHAR2,
      pfichero2 OUT BLOB,
      pnomfichero2 OUT VARCHAR2)
      RETURN NUMBER;
END pac_iax_bpm;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BPM" TO "PROGRAMADORESCSI";
