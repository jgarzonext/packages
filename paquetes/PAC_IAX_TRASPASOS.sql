--------------------------------------------------------
--  DDL for Package PAC_IAX_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_TRASPASOS" AS
   /******************************************************************************
     NOMBRE:       PAC_IAX_traspasos
     PROPÓSITO:  Package para gestionar los traspasosS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
     2.0        14/07/2010   SRA                2. 0015372: CEM210 - Errores en grabación y gestión de traspasos de salida
     3.0        20/10/2010   SRA                3. 0016259: HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
          FUNCTION f_get_dattraspasos
          Función para devolver los campos descriptivos de un traspasos.
          param in Ptraspasos: Tipo carácter. Id. del traspasos.
          param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
          return             : Retorna un sys_refcursor con los campos descriptivos de un traspasos.
   *************************************************************************/
   /*************************************************************************
      FUNCTION F_GET_TRASPASOS
      Función que sirve para recuperar una colección de traspasos.
           PSPRODUC: Tipo numérico. Parámetro de entrada. Código de producto.
           PFILTROPROD: Tipo carácter. Parámetro de entrada. Valor 'TRASPASO'.
           NPOLIZA: Tipo numérico. Parámetro de entrada. Id. de póliza.
           NCERTIF: Tipo numérico. Parámetro de entrada. Id. de certificado
           PNNUMNIDE: Tipo carácter. Parámetro de entrada. Documento.
           PBUSCAR: Tipo carácter. Parámetro de entrada. Nombre de la persona.
           PTIPOPERSONA: Tipo numérico. Parámetro de entrada. Indica si buscamos por Tomador o Asegurado
           PSNIP: Tipo carácter. Parámetro de entrada. Número d'identificador.
           PCINOUT: Tipo numérico. Parámetro de entrada. Traspasos de entrada o salida
           PCESTADO: Tipo numérico. Parámetro de entrada. Indica el estado.
           PFSOLICI: Tipo fecha. Parámetro de entrada. Fecha solicitud.
           PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total o Parcial
           PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo importe Potser sobra o millor algun altre paràmetre com PCTIPDER.
           MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección T_IAX_TRASPASOS.
       *************************************************************************/
   FUNCTION f_get_traspasos(
      psproduc IN NUMBER,   -- Código de producto
      cramo IN NUMBER,   -- Código de ramo
      pfiltroprod IN VARCHAR2,   -- Valor ‘TRASPASO’
      npoliza IN NUMBER,   -- Id  de póliza
      ncertif IN NUMBER,   -- Id  de certificado
      pnnumnide IN VARCHAR2,   -- Documento
      pbuscar IN VARCHAR2,   -- Nombre de la persona
      ptipopersona IN NUMBER,   -- Indica si buscamos por Tomador o Asegurado
      psnip IN VARCHAR2,   -- Número d’identificador
      pcinout IN NUMBER,   -- Traspasos de entrada o salida
      pcestado IN NUMBER,   -- Indica el estado
      pfsolici IN DATE,   -- Fecha solicitud
      pctiptras IN NUMBER,   -- Total o Parcial
      pctiptrassol IN NUMBER,   -- Tipo importe
      pmodo IN VARCHAR2,   -- Mode amb que es entra a fer traspasos (Anulacio, revocació, solicitud...)
      mensajes OUT t_iax_mensajes   -- Mensaje de error
                                 )
      RETURN t_iax_traspasos;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar una colección de un traspaso.
        PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección T_IAX_TRASPASOS con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN ob_iax_traspasos;

   /*************************************************************************
   FUNCTION F_GET_COMPAÑIA
   Función que sirve para recuperar un nombre de compania a traves de DGS
        PCCOMPANI_DGS: Tipo varchar2. Parámetro de entrada. Código de DGS compañía
        PCCOMPANI: Tipo NUMBER. Parámetro de salida. Código de CIA
        PTCOMPANI: Tipo varchar2. Parámetro de salida. Nombre de la compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_tcompani(
      pccompani_dgs IN VARCHAR2,
      pccompani OUT NUMBER,
      ptcompani OUT VARCHAR2,
      pctipban OUT NUMBER,
      pcbancar OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
FUNCTION F_SET_TRASPASO
Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar si el traspaso esta en estado Sin confirmar o Confirmado.

Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_set_traspaso(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pcagrpro IN NUMBER,
      pfsolici IN DATE,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pcestado IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      tccodpla IN VARCHAR2,
      ccompani IN NUMBER,
      tcompani IN VARCHAR2,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      tmemo IN VARCHAR2,
      nref IN VARCHAR2,
      cmotivo IN NUMBER,
      fefecto IN DATE,
      fvalor IN DATE,
      pstras IN NUMBER,
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      pstras_out OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_DEL_TRASPASO
       Función que sirve para borrar los datos del traspaso. Sólo se puede utilizar
       si el traspaso esta en estado Sin confirmar. Y sólo se permite a un perfil de seguridad

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_del_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_CONFIRMAR_TRASPASO
          Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha confirmado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_confirmar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_DESCONFIRMAR_TRASPASO
    Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha desconfirmado el traspaso y 1 si se ha producido algún error
    *************************************************************************/
   FUNCTION f_desconfirmar_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_DEMORAR_TRASPASO
       Función que sirve para demorar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar.

           1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
           2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha demorado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_demorar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para enviar un traspaso con la norma 234.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_RECHAZAR_TRASPASO
       Función que sirve para rechazar un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora.

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

   Retorna un valor numérico: 0 si ha rechazado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_rechazar_traspaso(
      pstras IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ANULAR_TRASPASO
    Función que sirve para anular un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora

    1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
    2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error

    *************************************************************************/
   FUNCTION f_anular_traspaso(pstras IN NUMBER, cmotivo IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    FUNCTION F_INFORMAR_TRASPASO
       Función que sirve para informar los datos fiscales (aportaciones del año, porcentaje aportaciones 2007, fecha de antigüedad …).
       Sólo se puede utilizar si el traspaso está en estado 3-Pendientes de informar.

    Retorna un valor numérico: 0 si ha informado el traspaso y 1 si se ha producido algún error.
    *************************************************************************/
   FUNCTION f_informar_traspaso(
      pstras IN NUMBER,
      fantigi IN DATE,
      iimpanu IN NUMBER,
      nparret IN NUMBER,
      iimpret IN NUMBER,
      tmemo IN VARCHAR2,   -- BUG 15197 - PFA - Afegir camp observacions
      nparpos2006 IN NUMBER,
      porcpos2006 IN NUMBER,
      nparant2007 IN NUMBER,
      porcant2007 IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
    FUNCTION F_EJECUTAR_TRASPASO
       Función que sirve para ejecutar un traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

    Retorna un valor numérico: 0 si ha ejecutado el traspaso y 1 si se ha producido algún error.
*************************************************************************/
   FUNCTION f_ejecutar_traspaso(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pcinout IN NUMBER,
      pctiptras IN NUMBER,
      pcextern IN NUMBER,
      pctipder IN NUMBER,
      pctiptrassol IN NUMBER,
      piimptemp IN NUMBER,
      nporcen IN NUMBER,
      nparpla IN NUMBER,
      ccodpla IN NUMBER,
      ccompani IN NUMBER,
      ctipban IN NUMBER,
      cbancar IN VARCHAR2,
      tpolext IN VARCHAR2,
      ncertext IN NUMBER,
      pfefecto IN DATE,
      pfvalmov IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION f_get_ccodpla
   Función que sirve para recuperar el codigo del plan a traves del codigo DGS
        PCCODPLA_DGS: Tipo varchar2. Parámetro de salida. Código de DGS plan
        PCCODPLA: Tipo numérico. Parámetro de entrada. Código de compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_ccodpla(
      pccodpla_dgs IN VARCHAR2,
      pccodpla OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/* BUG 15372 - 14/07/2010 - SRA - se crea la nueva transacción f_get_traspasos_pol para que informe el bloque Traspasos en axisctr097 */
   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_traspasos;
END pac_iax_traspasos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_TRASPASOS" TO "PROGRAMADORESCSI";
