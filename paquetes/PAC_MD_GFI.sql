--------------------------------------------------------
--  DDL for Package PAC_MD_GFI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_GFI" AS
/******************************************************************************
 NOMBRE:       PAC_MD_GFI
 PROPÓSITO: Contiene los métodos y funciones necesarias para poder realizar el mantenimiento de las tablas, realiza las llamadas a sentencias contra la base de datos o funciones propias para devolver la información a los paquetes de la capa interfase de Axis.

 REVISIONES:
 Ver        Fecha        Autor             Descripción
 ---------  ----------  ---------------  ------------------------------------
 1.0        15/04/2008  CSI               1. Creación del package.
 2.0        19/06/2009  DCT               2. Añadir nuevos métodos y nuevas funciones
                                              para gestionar las formulas.
 3.0        17/07/2009  AMC               3.Bug 10716 - Añadir nuevos métodos y nuevas funciones
                                            para gestionar los terminos.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_get_claves(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_rastro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_utili(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_formula(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_lstparametros(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_parametros(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_grabarformparam(pparams IN t_iax_gfiparam, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_eliminarformparam(
      pclave IN NUMBER,
      pparametro IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_consulta(
      pclave IN NUMBER,
      pcodigo IN VARCHAR2,
      pformula IN VARCHAR2,
      pcramo IN NUMBER,
      pcrastro IN NUMBER,
      pcutili IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_grabarformula(
      formula IN ob_iax_gfiform,
      psclave OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Monta el objeto con los nodos de las formulas
      param in  pcur      : cursor sentencia niveles formulas
      param out mensajes  : mensajes de error
      return              : objeto arbol
   ***********************************************************************/
   FUNCTION f_mounttree(pcur IN sys_refcursor, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_gfitree;

   /***********************************************************************
      Recupera la lista de tipos para los términos.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lsttipoterm(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la lista del origen del termino.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstorigen(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la lista de operadores.
      param out mensajes : Mensajes de salida
      return             : ref cursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_lstoperador(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Recupera la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen : Origen del término
      param in ptdesc : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param out mensajes : Mensajes de salida
      return             : sys_refcursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_terminos(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
       Recupera la información del término.
       param in ptermino : Código identificativo del término
       return             : ref cursor

       Bug 10716 - 17/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_get_termino(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Grava la información de los términos.
      param in ptermino : Código identificativo del término
      param in ptipo    : Tipo de término (T=Tabla, P=Parámetro, F=Fórmula)
      param in porigen  : Origen del término
      param in ptdesc   : Descripción del término
      param in poperador : Indica si el termino es un operador o función (0= No, 1= Sí)
      param in pisnew   : 1 es un nuevo termino 0 ja existía
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_grabartermino(
      ptermino IN VARCHAR2,
      ptipo IN VARCHAR2,
      porigen IN NUMBER,
      ptdesc IN VARCHAR2,
      poperador IN NUMBER,
      pisnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
       Elimina el término.
       param in ptermino : Código identificativo del término
       param out mensajes : Mensajes de salida
       return            : 0 ha ido correctamente o bien el código de literal

       Bug 10716 - 17/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_eliminartermino(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /***********************************************************************
      Recupera la información de las vigencias del término.
      param in ptermino : Código identificativo del término
      param out mensajes : Mensajes de salida
      return            : sys_refcursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencias(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
      Elimina la vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param out mensajes : Mensajes de salida
      return            : 0 ha ido correctamente o bien el código de literal

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_eliminartermvigen(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /***********************************************************************
      Recupera la información de las vigencia del término.
      param in ptermino : Código identificativo del término
      param in pclave   : Código de la vigencia
      param out mensajes : Mensajes de salida
      return            : sys_refcursor

      Bug 10716 - 17/07/2009 - AMC
   ***********************************************************************/
   FUNCTION f_get_termvigencia(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /***********************************************************************
       Grabar la vigencia del término.
       param in ptermino : Código identificativo del término
       param in pclave   : Código de la vigencia
       param in pfechaefe : Fecha efecto
       param in pcvalor : Valor de la vigencia
       param in isNew : Indica si Nuevo 1 o 0 edición
       param out mensajes : Mensajes de salida
       return            : 0 ha ido correctamente o bien el código de literal

       Bug 10716 - 17/07/2009 - AMC
    ***********************************************************************/
   FUNCTION f_grabartermvig(
      ptermino IN VARCHAR2,
      pclave IN NUMBER,
      pfechaefe IN DATE,
      pcvalor IN FLOAT,
      isnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Recupera la lista de los tramos
        param in ptramo: Código de tramo
                 pconcepto: Concepto al que se aplica el tramo
        param out:  mensajes de salida
        return:  ref cursor
   *************************************************************************/
   FUNCTION f_consultram(ptramo IN NUMBER, pconcepto IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que elimna un tramo.
       param in ptramo: código de tramo
       param out:  mensajes de error
       return   : NUMBER   :  1 indicando se ha producido un error
                                         0 ha ido correctamente  */
   FUNCTION f_eliminartramo(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que recupera la información de los tramos
       param in ptramo: código de tramo
      param out:  mensajes de error
      return:  ref cursor  */
   FUNCTION f_get_tramo(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que grava la información de los tramos.
      param in ptramo: código de tramo
               pconcepto: Concepto al que se aplica el tramo
               pcptfranja: Concepto Franja
               pcptvalor: Concepto Valor
      param out:  mensajes de salida
      return : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_grabartramo(
      ptramo IN NUMBER,
      pconcepto IN VARCHAR2,
      pcptfranja IN VARCHAR2,
      pcptvalor IN VARCHAR2,
      pisnuevo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que recupera la información de los tramos
     param in ptramo: código de tramo
     param out:  mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_vigtramos(ptramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que recupera la información del detalle del tramo
     param in pdetalletramo: código detalle tramo
     param out:  mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_detvigtramos(pdetalletramo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que grava la información de los tramos.
     param in ptramo: código de tramo
              pfechaefecto: Fecha efecto tramo
              pdetalletramo: Detalle tramo
     return : NUMBER   :  1 indicando se ha producido un error
                          0 ha ido correctamente  */
   FUNCTION f_grabarvigtram(
      ptramo IN NUMBER,
      pfechaefecto IN DATE,
      pdetalletramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que graba la información de la vigencia de los tramos
    param in pdetalletramo: Código detalle tramo
             porden:        Número de orden
             pdesde:        Valor desde
             phasta:        Valor hasta
             pvalor:        Valor
    param out:  mensajes de salida
    return   : NUMBER   :  1 indicando se ha producido un error
                           0 ha ido correctamente  */
   FUNCTION f_grabardetvigtram(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      pdesde IN NUMBER,
      phasta IN NUMBER,
      pvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que elimna la vigencia de un tramo.
      param in ptramo: Código de tramo
               pdetalletramo: Código del detalle tramo
      param out:  mensajes de salida
      return              : NUMBER   :  1 indicando se ha producido un error
                                        0 ha ido correctamente  */
   FUNCTION f_eliminarvigencia(
      ptramo IN NUMBER,
      pdetalletramo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que elimina el detalle de vigencia del tramo.
    param in pdetalletramo: Código del detalle tramo
             porden: Número de orden de secuencia
    param out:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_eliminardetvigencia(
      pdetalletramo IN NUMBER,
      porden IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   ----------
   --BUCLES--
   ----------
   /* Función que recupera la lista de bucles
     param in ptermino: Nombre del término
           in pniterac: Fórmula que nos dirá el número de iteraciones
           in poperacion: Tipo de operación (+, *)
     param out:  mensajes de error
     return:  ref cursor  */
   FUNCTION f_consultbucle(
      ptermino IN VARCHAR2,
      pniterac IN NUMBER,
      poperacion IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que elimna un bucle
     param in ptermino: Nombre del término
     param out:  mensajes de error
     return              : NUMBER   :  1 indicando se ha producido un error
                                       0 ha ido correctamente  */
   FUNCTION f_eliminarbucle(ptermino IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que recupera la lista de operación para el bucle
     param out:  mensajes de error
     return:  ref cursor  */
   FUNCTION f_get_lstoperacion(mensajes OUT t_iax_mensajes)
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
      isnew IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

--------------
--EVALUACIóN--
--------------
 /* Función que recupera los parámetros para poder evaluar una fórmula.
 param in pclave: Clave fórmula
 param out:  psession: Código único de sesión
             mensajes: Mensajes de salida
 return              : T_IAX_GFIPARAMTRANS   :  Objeto con los parámetros de evaluación.*/
   FUNCTION f_get_paramtrans(
      pclave IN NUMBER,
      psession OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfiparamtrans;

   /* Función que grava la información de los parámetros
    param in psession: Número de sesión
             pparamact: Nombre parámetro actual
             pparampos: Nombre parámetro nuevo
             pvalor: Valor del parámetro
    param out: mensajes:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_grabarparamtrans(
      psession IN NUMBER,
      pparamact IN VARCHAR2,
      pparampos IN VARCHAR2,
      pvalor IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que elimina la información de los parámetros
    param in psession: Número de sesión
             pparam: Nombre parámetro
    param out: mensajes:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_eliminarparamtrans(
      psession IN NUMBER,
      pparam IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que Evalúa el resultado de la fórmula.
     param in psession: Código único de sesión
              pclave: Clave fórmula.
              pdebug: Modo de debug
     param out:  mensajes de salida
     return              : NUMBER   :  Valor devuelto por la fórmula  */
   FUNCTION f_evaluar(
      psession IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

------------------
--CÓDIGO FUNCIÓN--
------------------
/* Función que recupera el código de una fórmula.
  param in pclave: Clave fórmula
  param out:  mensajes: mensajes de error
  return:  ref cursor  */
   FUNCTION f_get_source(pclave IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

-------------
--FUNCIONES--
-------------
/* Función que recupera la lista de procesos
  param out:  mensajes: mensajes de error
  return:  ref cursor  */
   FUNCTION f_get_lstfprocesos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que recupera la lista de refresco
    param out:  mensajes: mensajes de error
    return:  ref cursor  */
   FUNCTION f_get_lstfrefrescar(mensajes OUT t_iax_mensajes)
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
      prefresca IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   /* Función que grava la información de la función
    param in pclave: Clave de la fórmula
             pcformula: Código de la fórmula
             ptproceso: Proceso que utiliza esta fórmula
             prefrescar: Indica que la fórmula se tendría que refrescar
    param out: mensajes:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_grabarfuncion(
      pcclave IN NUMBER,
      pcformula IN VARCHAR2,
      ptproceso IN VARCHAR2,
      prefrescar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que genera la formula determinada
    param in pcodigo: Código de la fórmula
             pcomenta: Si se generan comentarios
    param out: mensajes:  mensajes de salida
    return              : NUMBER   :  1 indicando se ha producido un error
                                      0 ha ido correctamente  */
   FUNCTION f_crea_funcion(
      pcodigo IN VARCHAR2,
      pcomenta IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /* Función que comprueba que la fórmula sea correcta
    param in pformula: Texto de la fórmula
    param out: mensajes:  mensajes de salida
    return              : T_IAX_GFIERRORES   :  Objeto que contiene la información de los errores de la fórmula.*/
   FUNCTION f_checkformula(pformula IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN t_iax_gfierrores;

    /*************************************************************************
    FUNCTION f_tramo
         Funci� que retorna valor tram
         param in pnsesion  : Sesio
         param in pfecha  : Data
         param in pntramo  : Tram
         param in pbuscar : Valor a trobar
         param out: mensajes:  mensajes de salida
         return             : 0 -> Tot correcte
   *************************************************************************/
   FUNCTION f_tramo(
      pnsesion IN NUMBER,
      pfecha IN NUMBER,
      pntramo IN NUMBER,
      pbuscar IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_evaluar_formula(
      pnsesion IN NUMBER,
      pclave IN NUMBER,
      pdebug IN NUMBER,
      pparametros IN t_iax_gfiparamvalor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_gfi;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_GFI" TO "PROGRAMADORESCSI";
