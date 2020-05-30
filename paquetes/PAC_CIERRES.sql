--------------------------------------------------------
--  DDL for Package PAC_CIERRES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CIERRES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_CIERRES
   PROPÓSITO: Funciones para cierres contables

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/08/2008   JGM                1. Creación del package.
   2.0        12/01/2010   MCA                2. Creación de función para obtener la fecha cierre de un tipo de cierre
   3.0        02/01/2012   JMF                3. 0020701 LCOL_F001 - UAT-FIN - La parametrizacion para programacion de cierres no funciono
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*F_SET_CIERRES
Función que grabará los datos de un nuevo cierre.

Parámetros

1. CEMPRES: : Entrada y numérico.
2. CTIPO: : Entrada y numérico.
3. CESTADO: Entrada y numérico.
4. FPERINI: Entrada y fecha.
5. FPERFIN: Entrada y fecha.
6. FCIERRE: Entrada y fecha.

*/
   FUNCTION f_set_cierres(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER;

/*F_fechas_nuevo_cierre
Retorna 0 si va todo bien.
Función que ha de mirar las fechas del último cierre del mismo tipo que entra por parámetro,
para proponer las del siguiente cierren, que serán:
   Pfperini :=  (fecha_final_ultimo_cierre + 1);
   Pfperfin :=  last_day(to_date((fecha_final_ultimo_cierre + 1) ));
   Pfcierre :=  last_day(to_date((fecha_final_ultimo_cierre + 1) ));


Parámetros

1. CEMPRES: : Entrada y numérico.
2. CTIPO: : Entrada y numérico.
3. FPERINI: Salida y Fecha.
5. FPERFIN: Salida y Fecha.
5. PFCIERRE: Salida y Fecha.


*/
   FUNCTION f_fechas_nuevo_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini OUT DATE,
      pfperfin OUT DATE,
      pfcierre OUT DATE)
      RETURN NUMBER;

/*
F_config_cierre
Nueva función que nos devuelve la configuración del cierre.
Devolverá un numérico. 1 si ha podido recuperar su configuración y 0 si no la ha podido recuperar.

Parámetros
1. CEMPRES: Entrada y numérico.
2. CTIPO: Entrada y numérico.
3. PFECMODIF: Salida y numérico.
4. PPREVIO: Salida y numérico.

*/
   FUNCTION f_config_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pmodif OUT NUMBER,
      pprevio OUT NUMBER)
      RETURN NUMBER;

/*F_BORRAR_CIERRE
Nueva función que se utilizará para borrar un CIERRE (sólo se pueden borrar aquellos que esten pendientes).

Parámetros

1. PCEMPRES: Entrada y numérico. Empresa.
2. PCTIPO: Entrada y numérico. Tipo de cierre.
3. PFPERINI: Entrada y fecha. Fecha inicio del cierre.
4. PCESTADO: Entrada y númerico. Estado del cierre.

*/
   FUNCTION f_borrar_cierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pfperini IN DATE,
      pcestado IN NUMBER)
      RETURN NUMBER;

/*F_FECHA_ULTCIERRE
Nueva función que devolverá la fecha del último cierre hecho del tipo que entra por parámetro
Param.
1. PCEMPRES: Empresa.
2. PCTIPO: Tipo de cierre
3.  PFECHA: Fecha fin del último cierre hecho
*/
   FUNCTION f_fecha_ultcierre(pcempres IN NUMBER, pctipo IN NUMBER)
      RETURN DATE;

-- BUG 0020701 - 02/01/2012 - JMF
   FUNCTION f_val_fcierre(
      pcempres IN NUMBER,
      pctipo IN NUMBER,
      pcestado IN NUMBER,
      pfperini IN DATE,
      pfperfin IN DATE,
      pfcierre IN DATE)
      RETURN NUMBER;
END pac_cierres;

/

  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CIERRES" TO "PROGRAMADORESCSI";
