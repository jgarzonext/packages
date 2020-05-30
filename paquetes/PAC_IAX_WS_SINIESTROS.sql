--------------------------------------------------------
--  DDL for Package PAC_IAX_WS_SINIESTROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_WS_SINIESTROS" AS
/******************************************************************************
   NOMBRE:       pac_iax_ws_siniestros
   PROPÓSITO:  Interficie para llamadas de Traspasos de creacion de Siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        21/12/2009   JGM                1. Creación del package. Bug 10124
******************************************************************************/

   /*************************************************************************
      Función que sirve para aperturar un siniestro con su tramitación y reserva inicial pendiente.
        1.    PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador del producto
        2.    PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.    PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.    PCACTIVI: Tipo numérico. Parámetro de entrada. Identificador de activivad.
        5.    PFSINIES: Tipo Fecha. Parámetro de etnrada. Fecha de siniestro. Desde traspasos se llamará con la fecha de efecto del traspaso
        6.  PFNOTIFI: Tipo Fecha. Parámetro de entrada. Fecha de notificación del siniestro. Desde traspasos se llamará con la fecha de aceptación del traspaso.
        7.  PCCAUSIN:Tipo numérico. Parámetro de entrada. Código de causa del siniestro
        8.  PCMOTSIN:  Tipo numérico. Parámetro de entrada. Código de motivo del siniestro
        9.  PTSINIES: Tipo carácter. Parámetro de entrada.
        10. PTZONAOCU: Tipo carácter. Parámetro de entrada.
        11. PCGARANT: Tipo numérico. Parámetro de entrada. Garantía asignada al traspaso
        12. PITRASPASO: Tipo numérico. Parámetro de entrada. Importe del traspaso.
        13. MENSAJE: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   *************************************************************************/
   FUNCTION f_apertura_siniestro(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcactivi IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      ptsinies IN VARCHAR2,
      ptzonaocu IN VARCHAR2,
      pcgarant IN NUMBER,
      pitraspaso IN NUMBER,
      pnsinies OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_pago_i_cierre_sin(
      pnsinies IN NUMBER,
      xproduc IN NUMBER,
      xcactivi IN NUMBER,
      psidepag IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_ws_siniestros;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SINIESTROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SINIESTROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_WS_SINIESTROS" TO "PROGRAMADORESCSI";
