--------------------------------------------------------
--  DDL for Package PAC_MD_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_TRASPASOS" AS
   /******************************************************************************
     NOMBRE:       PAC_MD_traspasos
     PROPÓSITO:  Package para gestionar los traspasos

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/11/2009   ICV                1. Creación del package. (bug 10124)
     2.0        29/06/2010   PFA                2. 15197: CEM210 - La data 'Fecha antigüedad' no es recupera correctament de la taula
     3.0        14/07/2010   SRA                3. 0015372: CEM210 - Errores en grabación y gestión de traspasos de salida
     4.0        20/10/2010   SRA                4. 0016259: HABILITAR CAMPOS DE TEXTO ESP0ECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

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
      mensajes IN OUT t_iax_mensajes   -- Mensaje de error
                                    )
      RETURN t_iax_traspasos;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar una colección de un traspaso.
        PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna una colección T_IAX_TRASPASOS con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_traspasos;

/*************************************************************************
       FUNCTION 4.3.1.6.1.3   F_SET_TRASPASO
Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar si el traspaso esta en estado Sin confirmar o Confirmado.
Parámetros

1. (obl) PSSEGURO:Tipo numérico. Parámetro de entrada. Identificador de póliza.
2. (obl) PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador de producto.
3. (obl) PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto.
4. (obl) PFSOLICI:Tipo fecha. Parámetro de entrada. Fecha de solicitud.
5. (obl) PCINOUT: Tipo numérico. Parámetro de entrada. Entrada / Salida
6. (obl) PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
7. (obl) PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
8. (obl) PCTIPDER: Tipo numérico. Parámetro de entrada. Traspaso prestaciones (derechos económicos) o derechos consolidados.
9. (obl) PCESTADO: Tipo numérico. Parámetro de entrada. Sin Confirmar / Confirmado / …..
10.   (obl) PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo de importe del traspaso solicitado.

(obligatorio al menos uno de los 3 siguientes)

11.   PIIMPTEMP: Tipo numérico. Parámetro de entrada. Importe Solicitado
12.   NPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje solicitado.
13.   NPARPLA: Tipo numérico. Parámetro de entrada. Participaciones solicitadas.

(obligatorio CCOPLA o bien CCOMPANI)

14.   CCOPLA: Tipo numérico. Parámetro de entrada. Código de Plan del o al que se traspasa.
15.   TCCODPLA:Tipo Carácter. Parámetro de entrada. Nombre del plan del o al que se traspasa.
16.   CCOMPANI: Tipo Numérico. Parámetro de entrada. Código de compañía del o al que se traspasa
17.   TCOMPANI: Tipo Carácter. Parámetro de entrada. Nombre de compañía del o al que se traspasa
18.   CTIPBAN:Tipo de cuenta. Parámetro de entrada. Tipo de cuenta del plan al que se traspasa
19.   CBANCAR: Tipo Carácter. Parámetro de entrada. Cuenta del plan al que se traspasa
20.   TPOLEXT: Tipo Carácter. Parámetro de entrada. Código identificativo de la póliza (o plan) del o al que se traspasa,
21.   NCERTEXT: Tipo numérico. Parámetro de entrada. Núm. de certificado cuando el traspaso es interno, entre planes o pólizas de planes de pensiones.
22.   FANTIGI:Tipo fecha. Parámetro de entrada. Fecha de antigüedad de las aportaciones del plan origen.
23.   IIMPANU: Tipo numérico. Parámetro de entrada. Aportaciones del año de traspaso en el plan origen.
24.   NPARRET: Tipo numérico. Parámetro de entrada. Participaciones retenidas para contingencias posteriores.
25.   IIMPRET: Tipo numérico. Parámetro de entrada. Importe retenido para contingencias posteriores a la primera contingencia.
26.   NPARPOS2006: Tipo numérico. Parámetro de entrada. Participaciones posteriores al año 2006.
27.   PORCPOS2006: Tipo numérico. Parámetro de entrada. Porcentaje de las participaciones posteriroes al año 2006.
28.   NPARANT2007: Tipo numérico. Parámetro de entrada. Participaciones anteriores al año 2007.
29.   PORCANT2007: Tipo numérico. Parámetro de entrada. Porcentaje de participaciones anteriores al año 2007.
30.   TMEMO:Tipo Carácter. Parámetro de entrada. Comentarios / observaciones relacionadas con el traspaso.
31.   NREF:Tipo Carácter. Parámetro de entrada. Referencia del traspaso enviado o que se envía en la Norma234
32.   PCTIPCONT: tipo de contingencia acaecida
33.   PFCONTIG: fecha de contingencia acaecida
34.   PCTIPCAP: forma de tipo de cobro
35.   PIMPORTE: importe
36.   PFPROPAG: fecha de próximo pago
37.   PSTRAS: Tipo numérico. Parámetro de salida. Código de traspaso.
38.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

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
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      pstras IN OUT NUMBER,
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
   FUNCTION f_del_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_DESCONFIRMAR_TRASPASO
    Función que sirve para confirmar traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha desconfirmado el traspaso y 1 si se ha producido algún error
    *************************************************************************/
   FUNCTION f_desconfirmar_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para enviar un traspaso con la norma 234.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER, mensajes IN OUT t_iax_mensajes)
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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ANULAR_TRASPASO
    Función que sirve para anular un traspaso. Sólo se puede utilizar si el traspaso está en estado Sin confirmar, Confirmado o en Demora

    1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
    2.   MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

    Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error

    *************************************************************************/
   FUNCTION f_anular_traspaso(
      pstras IN NUMBER,
      cmotivo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_INFORMAR_TRASPASO
       Función que sirve para informar los datos fiscales (aportaciones del año, porcentaje aportaciones 2007, fecha de antigüedad …). Sólo se puede utilizar si el traspaso está en estado 3-Pendientes de informar.

       1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.  FANTIGI: Tipo fecha. Parámetro de entrada. Fecha de antigüedad.
       3.  IIMPANU: Tipo numérico. Parámetro de entrada. Aportaciones del año de traspaso en el plan origen.
       4.  NPARRET: Tipo numérico. Parámetro de entrada. Participaciones retenidas para contingencias posteriores.
       5.  TMEMO:   Tipo varchar. Parametro de entrada. Observaciones.
       6.  IIMPRET: Tipo numérico. Parámetro de entrada. Importe retenido para contingencias posteriores a la primera contingencia.
       7.  NPARPOS2006: Tipo numérico. Parámetro de entrada. Participaciones posteriores al año 2006.
       8.  PORCPOS2006: Tipo numérico. Parámetro de entrada. Porcentaje de las participaciones posteriroes al año 2006.
       9.  NPARANT2007: Tipo numérico. Parámetro de entrada. Participaciones anteriores al año 2007.
      10.  PORCANT2007: Tipo numérico. Parámetro de entrada. Porcentaje de participaciones anteriores al año 2007.
      11.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

         /*************************************************************************
         FUNCTION F_EJECUTAR_TRASPASO
       Función que sirve para ejecutar un traspaso. Sólo se puede utilizar si el traspaso está en estado Confirmado.

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
       2.   PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
       3.   PNRIESGO: Tipo numérico. Parámetro de entrada. Número del riesgo.
       4.   PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
       5.   PCINOUT: Tipo numérico. Parámetro de entrada. Entrada / Salida
       6.   PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
       7.   PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
       8.   PCTIPDER: Tipo numérico. Parámetro de entrada. Traspaso de derechos económicos o consolidados.
       9.   PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo de traspaso solictado.
       10.  PIIMPTEMP: Tipo numérico. Parámetro de entrada. Importe Solicitado
       11.  NPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje solicitado.
       12.  NPARPLA: Tipo numérico. Parámetro de entrada. Participaciones solicitadas.
       13.  CCOPLA: Tipo numérico. Parámetro de entrada. Código de Plan del o al que se traspasa.
       14.  CCOMPANI: Tipo Numérico. Parámetro de entrada. Código de compañía del o al que se traspasa
       15.  CTIPBAN:Tipo de cuenta. Parámetro de entrada. Tipo de cuenta del plan al que se traspasa
       16.  CBANCAR: Tipo Carácter. Parámetro de entrada. Cuenta del plan al que se traspasa
       17.  TPOLEXT: Tipo Carácter. Parámetro de entrada. Código identificativo de la póliza (o plan) del o al que se traspasa,
       18.  NCERTEXT: Tipo numérico. Parámetro de entrada. Núm. de certificado cuando el traspaso es interno, entre planes o pólizas de planes de pensiones.
       19.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
       20.  PFVALMOV: Tipo fecha. Parámetro de etnrada. Fecha de valor del traspaso.
       21.  MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.

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
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_GET_COMPAÑIA
   Función que sirve para recuperar un nombre de compania a traves de DGS
        PCCOMPANI: Tipo varchar2. Parámetro de entrada. Código de DGS compañía
        PTCOMPANI: Tipo varchar2. Parámetro de salida. Nombre de la compañía
        MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error.
   Retorna un NUMBER 0 OK, 1 KO
    *************************************************************************/
   FUNCTION f_get_tcompani(
      pccompani_dgs IN VARCHAR2,
      pccompani IN OUT VARCHAR2,
      ptcompani IN OUT VARCHAR2,
      pctipban IN OUT NUMBER,
      pcbancar IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
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
      pccodpla IN OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

/* BUG 15372 - 14/07/2010 - SRA - se crea la nueva transacción f_get_traspasos_pol para que informe el bloque Traspasos en axisctr097 */
   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_traspasos;
END pac_md_traspasos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_TRASPASOS" TO "PROGRAMADORESCSI";
