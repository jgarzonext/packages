--------------------------------------------------------
--  DDL for Package PAC_MD_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*F_GET_CIERRES
Nueva función que seleccionará información sobre cierres dependiendo de los parámetros de entrada.

Parámetros

1.    PCEMPRES:   Entrada y numérico.   Empresa.
2.    PCTIPO:     Entrada y numérico.   Tipo de cierre.
3.    PCESTADO:   Entrada y numérico.   Estado de cierre.
4.    PFCIERRE:   Entrada y fecha.      Fecha del cierre.
5.    MENSAJE: Salida y mensajes del tipo T_IAX_MENSAJES
*/
   FUNCTION f_get_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfcierre IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_cierres;

   FUNCTION f_get_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_cierres;

/*Función para grabar los datos de un cierre (programar/desprogramar o grabar nuevo registro).*/
   FUNCTION f_set_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*Función para ejecutar on-line un cierre programado o un previo.*/
   FUNCTION f_ejecutar(mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*Nueva función que hará validaciones del registro de alta y cargará el campo de Estado de cierre según valores correctos.*/
   FUNCTION f_get_validacion(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini OUT DATE,
      pfperfin OUT DATE,
      pfcierre OUT DATE,
      pmodif OUT NUMBER,
      pprevio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*F_BORRAR_CIERRE
Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1. PCEMPRES: Entrada y numérico. Empresa.
2. PCTIPO: Entrada y numérico. Tipo de cierre.
3. PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4. PCESTADO: Entrada y númerico. Estado del cierre.
5. MENSAJE: Entrada y Salida.  mensajes del tipo t_iax_mensajes

*/
   FUNCTION f_borrar_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      pcestado IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/*
F_CONFIG_CIERRE Nueva función que nos devuelve la configuración del cierre (Si se pueden modificar las fechas y si se permite un previo).

Parámetros

CEMPRES: Entrada y numérico.
CTIPO: Entrada y numérico.
PFECMODIF: Salida y numérico.
PPREVIO: Salida y numérico.
MENSAJES:Entrada/Salida y mensajes del tipo t_iax_mensajes*/
   FUNCTION f_config_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfecmodif OUT NUMBER,
      pprevio OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   -- BUG 0020701 - 02/01/2012 - JMF
   -- Realiza validaciones sobre la fecha de cierre (0=Correcto, 1=Error).
   FUNCTION f_val_fcierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_cierres;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_CIERRES" TO "PROGRAMADORESCSI";
