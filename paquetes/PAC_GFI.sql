--------------------------------------------------------
--  DDL for Package PAC_GFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GFI" AUTHID CURRENT_USER IS
      /******************************************************************************
      NOMBRE:      PAC_GFI
      PROPÓSITO:   Funciones para el mantenimiento de las Formulas

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0                                       1. Creación del package.
      2.0        18/06/2009   DCT               2. Añadir nuevos métodos y nuevas funciones
                                                   para gestionar las formulas.
      3.0        17/07/2009   AMC               3. Bug 10716 - Añadir nuevos métodos y nuevas funciones
                                                   para gestionar los terminos.
   ******************************************************************************/
   TYPE terr IS TABLE OF VARCHAR2(50)
      INDEX BY BINARY_INTEGER;

   terrs          terr;
   errs           NUMBER := 1;
   sinonim        VARCHAR2(30);
   comenta        VARCHAR2(2);

   FUNCTION busca_token(s IN OUT VARCHAR2, pdeclare IN OUT VARCHAR2, pselec IN OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_crea_func(pformula IN VARCHAR2, pcomenta IN NUMBER DEFAULT 1)
      RETURN NUMBER;

   FUNCTION f_sgt_parms(pnom VARCHAR2, psesio NUMBER)
      RETURN NUMBER;

   FUNCTION comprobar_token(ptoken IN VARCHAR2, pformula IN VARCHAR2)
      RETURN NUMBER;

   PROCEDURE p_grabar_rastro(
      psesion IN NUMBER,
      pparametro IN VARCHAR2,
      pvalor IN NUMBER,
      prastro IN NUMBER);

   FUNCTION f_eval_clave(pclave NUMBER, psesio NUMBER)
      RETURN NUMBER;

   /***********************************************************************
       Recupera la lista de tipos para los términos.
       param in pcidioma : Código idioma
       return             : ref cursor

       Bug 10716 - 16/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_get_lsttipoterm(pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la lista del origen del término.
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstorigen
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la lista de operadores.
      param in pcidioma : Código idioma
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstoperador(pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen : Origen del término
      param in ptdesc : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pcidioma : Código idioma
      return             : ref cursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_terminos(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /***********************************************************************
       Recupera la información del término.
       param in ptermino : Código identificativo del término
       return             : ref cursor

       Bug 10716 - 16/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_get_termino(ptermino IN VARCHAR2)
      RETURN sys_refcursor;

   /***********************************************************************
      Grava la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo    : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen  : Origen del término
      param in ptdesc   : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pisnew   : 1 es un nuevo termino 0 ja existía
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermino(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pisnew IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Elimina el término.
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermino(ptermino IN VARCHAR2)
      RETURN NUMBER;

   /***********************************************************************
      Comprueba que el termino indicado no se este usando en alguna formula.
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION trobar_terme(ptermino IN VARCHAR)
      RETURN NUMBER;

   /***********************************************************************
      Elimina el parámetro pasado por parámetro.
      param in ptermino : Código identificativo del término

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   PROCEDURE borrar_parametros(ptermino IN VARCHAR2);

   /***********************************************************************
      Elimina el sinónimo .
      param in ptermino : Código identificativo del término
      return            : 0 ha ido correctamente o bien el código de literal
      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION borrar_sinonimos(ptermino IN VARCHAR2)
      RETURN NUMBER;

    /***********************************************************************
      Elimina las vigencias.
      param in ptermino : Código identificativo del término

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   PROCEDURE borrar_vigencias(ptermino IN VARCHAR2);

   /***********************************************************************
      Recupera la información de las vigencias del término.
      param in ptermino : Código identificativo del término
      return            : sys_refcursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencias(ptermino IN VARCHAR2)
      RETURN sys_refcursor;

   /***********************************************************************
      Elimina la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermvigen(ptermino IN VARCHAR2, pclave IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la información de la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      return            : sys_refcursor

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencia(ptermino IN VARCHAR2, pclave IN NUMBER)
      RETURN sys_refcursor;

   /***********************************************************************
      Grabar la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param in pfechaefe : Fecha efecto
      param in pcvalor : Valor de la vigencia
      param in isNew : Indica si Nuevo 1 o 0 edición
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermvig(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      pfechaefe IN DATE,
      pcvalor IN FLOAT,
      isnew IN NUMBER)
      RETURN NUMBER;

   /***********************************************************************
      Comprueba que no exista ja una vigencia de término con esta fecha efecto.
      param in pfecha_efecto : Fecha efecto
      param in pcodigo  : Código identificativo del término
      return            : numero re registros encontrados

      Bug 10716 - 16/07/2009 - AMC
   ***********************************************************************/
   FUNCTION countsameefect(pfecha_efecto DATE, pcodigo VARCHAR2)
      RETURN NUMBER;

   /* Función que recupera la lista de los tramos
        param in ptramo: Código de tramo
                 pconcepto: Concepto al que se aplica el tramo
        return:  ref cursor     */
   FUNCTION f_consultram(ptramo IN NUMBER, pconcepto IN VARCHAR2)
      RETURN sys_refcursor;

   /* Función que elimna un tramo.
      param in ptramo: código de tramo
      return : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminartramo(ptramo IN NUMBER)
      RETURN NUMBER;

   /* Función que recupera la información de los tramos
      param in ptramo: código de tramo
     return:  ref cursor  */
   FUNCTION f_get_tramo(ptramo IN NUMBER)
      RETURN sys_refcursor;

   /* Función que grava la información de los tramos.
       param in ptramo: código de tramo
                pconcepto: Concepto al que se aplica el tramo
                pcptfranja: Concepto Franja
                pcptvalor: Concepto Valor
       return : NUMBER   :  1 indicando se ha producido un error
                            0 ha ido correctamente  */
   FUNCTION f_grabartramo(
      ptramo IN NUMBER,
      pconcepto IN VARCHAR2,
      pcptfranja IN VARCHAR2,
      pcptvalor IN VARCHAR2,
      pisnuevo IN NUMBER)
      RETURN NUMBER;

   /* Función que recupera la información de los tramos
      param in ptramo: código de tramo
      return:  ref cursor  */
   FUNCTION f_get_vigtramos(ptramo IN NUMBER)
      RETURN sys_refcursor;

   /* Función que recupera la información del detalle del tramo
      param in pdetalletramo: código detalle tramo
      return:  ref cursor  */
   FUNCTION f_get_detvigtramos(pdetalletramo IN NUMBER)
      RETURN sys_refcursor;

   /* Función que grava la información de los tramos.
     param in ptramo: código de tramo
              pfechaefecto: Fecha efecto tramo
              pdetalletramo: Detalle tramo
     return : NUMBER   :  1 indicando se ha producido un error
                          0 ha ido correctamente  */
   FUNCTION f_grabarvigtram(ptramo IN NUMBER, pfechaefecto IN DATE, pdetalletramo IN NUMBER)
      RETURN NUMBER;

   /* Función que graba la información de la vigencia de los tramos
    param in pdetalletramo: Código detalle tramo
             porden:        Número de orden
             pdesde:        Valor desde
             phasta:        Valor hasta
             pvalor:        Valor
    return   : NUMBER   :  1 indicando se ha producido un error
                           0 ha ido correctamente  */
   FUNCTION f_grabardetvigtram(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      pdesde IN NUMBER,
      phasta IN NUMBER,
      pvalor IN NUMBER)
      RETURN NUMBER;

   /* Función que elimna la vigencia de un tramo.
     param in ptramo: Código de tramo
              pdetalletramo: Código del detalle tramo
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_eliminarvigencia(ptramo IN NUMBER, pdetalletramo IN NUMBER)
      RETURN NUMBER;

   /* Función que elimna la vigencia de un tramo.
     param in pdetalletramo: Código del detalle tramo
              porden: Número de orden de secuencia
     return              : NUMBER   :  Error código literal
                                       0 ha ido correctamente  */
   FUNCTION f_eliminardetvigencia(pdetalletramo IN NUMBER, porden IN NUMBER)
      RETURN NUMBER;

   ----------
   --BUCLES--
   ----------
   /* Función que recupera la lista de bucles
     param in ptermino: Nombre del término
           in pniterac: Fórmula que nos dirá el número de iteraciones
           in poperacion: Tipo de operación (+, *)
     return:  ref cursor  */
   FUNCTION f_consultbucle(ptermino IN VARCHAR2, pniterac IN VARCHAR2, poperacion IN VARCHAR2)
      RETURN sys_refcursor;

   /* Función que elimna un bucle
     param in ptermino: Nombre del término
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_eliminarbucle(ptermino IN VARCHAR2)
      RETURN NUMBER;

   /* Función que recupera la lista de operación para el bucle
     return:  ref cursor  */
   FUNCTION f_get_lstoperacion
      RETURN sys_refcursor;

   /* Función que grava la información del bucle.
    param in ptermino: Nombre del término
             pniterac: Fórmula que nos dirá el número de iteraciones
             poperacion: Tipo de operación (+, *)
             isnew: 1 Indica que es nuevo y 0 Modificación
    param out:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_grabarbucle(
      ptermino IN VARCHAR2,
      pniterac IN VARCHAR2,
      poperacion IN VARCHAR2,
      isnew IN NUMBER)
      RETURN NUMBER;

--------------
--EVALUACIóN--
--------------
 /* Función que recupera los parámetros para poder evaluar una fórmula.
 param in pclave: Clave fórmula
 param out:  psession: Código único de sesión
 return:  ref cursor  */
   FUNCTION f_get_paramtrans(pclave IN NUMBER, psession OUT NUMBER)
      RETURN sys_refcursor;

   /* Función que grava la información de los parámetros
    param in psession: Número de sesión
             pparamact: Nombre parámetro actual
             pparampos: Nombre parámetro nuevo
             pvalor: Valor del parámetro

    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_grabarparamtrans(
      psession IN NUMBER,
      pparamact IN VARCHAR2,
      pparampos IN VARCHAR2,
      pvalor IN NUMBER)
      RETURN NUMBER;

   /* Función que elimina la información de los parámetros
    param in psession: Número de sesión
             pparam: Nombre parámetro
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_eliminarparamtrans(psession IN NUMBER, pparam IN VARCHAR2)
      RETURN NUMBER;

   /* Función que Evalúa el resultado de la fórmula.
    param in psession: Código único de sesión
             pclave: Clave fórmula.
             pdebug: Modo de debug
    param out:  pformula: Código de la fórmula
    return              : NUMBER   :  Valor devuelto por la fórmula  */
   FUNCTION f_evaluar(
      psession IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      pformula OUT VARCHAR2)
      RETURN NUMBER;

------------------
--CÓDIGO FUNCIÓN--
------------------
/* Función que recupera el código de una fórmula.
  param in pclave: Clave fórmula
  return:  ref cursor  */
   FUNCTION f_get_source(pclave IN NUMBER)
      RETURN sys_refcursor;

-------------
--FUNCIONES--
-------------
/* Función que recupera la lista de procesos
  param in:  pcidioma: Número de idioma
  return:  ref cursor  */
   FUNCTION f_get_lstfprocesos(pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /* Función que recupera la lista de refresco
     param in:  pcidioma: Número de idioma
     return:  ref cursor  */
   FUNCTION f_get_lstfrefrescar(pcidioma IN NUMBER)
      RETURN sys_refcursor;

   /* Función que recupera la información de las funciones
     param in pclave: Clave fórmula
              pformula: Código fórmula
              ptproceso: Proceso que utiliza esta fórmula
              prefresca: Indica que la fórmula se tendría que refrescar
     param out:  mensajes: mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_funciones(
      pclave IN NUMBER,
      pformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefresca IN NUMBER)
      RETURN sys_refcursor;

   /* Función que grava la información de la función
      param in pclave: Clave de la fórmula
               pcformula: Código de la fórmula
               ptproceso: Proceso que utiliza esta fórmula
               prefrescar: Indica que la fórmula se tendría que refrescar
      return              : NUMBER   :  X Error Código de literal
                                        0 ha ido correctamente  */
   FUNCTION f_grabarfuncion(
      pcclave IN NUMBER,
      pcformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefrescar IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
    FUNCTION f_tramo
         Funció que retorna valor tram
         param in pnsesion  : Sesio
         param in pfecha  : Data
         param in pntramo  : Tram
         param in pbuscar : Valor a trobar

         return             : 0 -> Tot correcte
   *************************************************************************/
   FUNCTION f_tramo(pnsesion IN NUMBER, pfecha IN NUMBER, pntramo IN NUMBER, pbuscar IN NUMBER)
      RETURN NUMBER;
END pac_gfi;

/

  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GFI" TO "PROGRAMADORESCSI";
