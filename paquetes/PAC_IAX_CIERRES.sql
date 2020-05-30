--------------------------------------------------------
--  DDL for Package PAC_IAX_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
******************************************************************************/

    e_object_error  exception;
    e_param_error   exception;


/*F_GET_CIERRES
Nueva función que seleccionará información sobre cierres dependiendo de los parámetros de entrada.

Parámetros

1.	PCEMPRES:   Entrada y numérico.   Empresa.
2.	PCTIPO:     Entrada y numérico.   Tipo de cierre.
3.	PCESTADO:   Entrada y numérico.   Estado de cierre.
4.	PFCIERRE:   Entrada y fecha.      Fecha del cierre.
5.	MENSAJE: Salida y mensajes del tipo T_IAX_MENSAJES
*/
    FUNCTION F_Get_Cierres  (pcempres IN NUMBER,
                             pctipo IN NUMBER,
                             pcestado IN NUMBER,
                             pfcierre IN DATE,
                             mensajes OUT T_IAX_MENSAJES) RETURN T_IAX_CIERRES ;
/*
Nueva función que seleccionará información de un cierre dependiendo de los parámetros de entrada.
*/
    FUNCTION F_Get_Cierre   (pcempres IN NUMBER,
                             pctipo IN NUMBER,
                             pfperini IN DATE,
                             mensajes OUT T_IAX_MENSAJES) RETURN OB_IAX_CIERRES ;

/*Función para grabar los datos de un cierre (programar/desprogramar o grabar nuevo registro).*/
    FUNCTION F_set_Cierres  (pcempres IN NUMBER,
                             pctipo IN NUMBER,
                             pcestado IN NUMBER,
                             pfperini IN DATE,
                             pfperfin IN DATE,
                             pfcierre IN DATE,
                             mensajes OUT T_IAX_MENSAJES) RETURN NUMBER ;

/*Función para ejecutar on-line un cierre programado o un previo.*/
    FUNCTION F_ejecutar  (mensajes OUT T_IAX_MENSAJES) RETURN NUMBER ;

/*Nueva función que nos dirá si un cierre es modificable o no lo es.*/
    FUNCTION F_get_modificable  (pcestado IN NUMBER, mensajes OUT T_IAX_MENSAJES) RETURN NUMBER ;

/*Nueva función que hará validaciones del registro de alta y cargará el campo de Estado de cierre según valores correctos.*/
    FUNCTION F_get_Validacion (pcempres IN NUMBER,
                               pctipo IN NUMBER,
                               pfperini OUT DATE,
                               pfperfin OUT DATE,
                               pfcierre OUT DATE,
                               pmodif OUT NUMBER,
                               pprevio OUT NUMBER,
                               mensajes OUT T_IAX_MENSAJES) RETURN NUMBER;

/*F_BORRAR_CIERRE
Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1.	PCEMPRES: Entrada y numérico. Empresa.
2.	PCTIPO: Entrada y numérico. Tipo de cierre.
3.	PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4.	PCESTADO: Entrada y númerico. Estado del cierre.
5.	MENSAJE: Salida y mensajes del tipo t_iax_mensajes

*/
    FUNCTION F_BORRAR_CIERRE(pcempres IN NUMBER,
                             pctipo IN NUMBER,
                             pfperini IN DATE,
                             pcestado IN NUMBER,
                             mensajes OUT T_IAX_MENSAJES) RETURN NUMBER;

/*
F_CONFIG_CIERRE Nueva función que nos devuelve la configuración del cierre (Si se pueden modificar las fechas y si se permite un previo).

Parámetros

CEMPRES: Entrada y numérico.
CTIPO: Entrada y numérico.
PFECMODIF: Salida y numérico.
PPREVIO: Salida y numérico.
MENSAJES:Salida y mensajes del tipo t_iax_mensajes*/

    FUNCTION F_CONFIG_CIERRE(pcempres IN NUMBER,
                             pctipo IN NUMBER,
                             pfecmodif OUT NUMBER,
                             pprevio OUT NUMBER,
                             mensajes OUT T_IAX_MENSAJES) RETURN NUMBER;

END PAC_IAX_CIERRES;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_CIERRES" TO "PROGRAMADORESCSI";
