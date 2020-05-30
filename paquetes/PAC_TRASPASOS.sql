--------------------------------------------------------
--  DDL for Package PAC_TRASPASOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_TRASPASOS" AS
   /******************************************************************************
     NOMBRE:       PAC_traspasos
     PROPÓSITO:  Package para gestionar los traspasos

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/11/2009   ICV                1. Creación del package. (bug 10124)
     2.0        29/06/2010   PFA                2. 15197: CEM210 - La data 'Fecha antigüedad' no es recupera correctament de la taula
     3.0        14/07/2010   SRA                2. 0015372: CEM210 - Errores en grabación y gestión de traspasos de salida
     4.0        22/07/2010   SRA                4. 0015489: CEM - LListat de traspassos
     5.0        18/10/2010   SRA                5. 0016259: HABILITAR CAMPOS DE TEXTO ESPECÍFICOS PARA TRASPASOS DERECHOS ECONÓMICOS
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

      /*************************************************************************
      FUNCTION F_GET_TRASPASOS
      Función que sirve para recuperar una colección de traspasos.
        1.    PSPRODUC: Tipo numérico. Parámetro de entrada. Código de producto.
        2.    PFILTROPROD: Tipo carácter. Parámetro de entrada. Valor 'TRASPASO'.
        3.    NPOLIZA: Tipo numérico. Parámetro de entrada. Id. de póliza.
        4.    NCERTIF: Tipo numérico. Parámetro de entrada. Id. de certificado
        5.  PNNUMNIDE: Tipo carácter. Parámetro de entrada. Documento.
        6.  PBUSCAR: Tipo carácter. Parámetro de entrada. Nombre de la persona.
        7.  PTIPOPERSONA: Tipo numérico. Parámetro de entrada. Indica si buscamos por Tomador o Asegurado
        8.  PSNIP: Tipo carácter. Parámetro de entrada. Número d'identificador.
        9.  PCINOUT: Tipo numérico. Parámetro de entrada. Traspasos de entrada o salida
        10. PCESTADO: Tipo numérico. Parámetro de entrada. Indica el estado.
        11. PFSOLICI: Tipo fecha. Parámetro de entrada. Fecha solicitud.
        12. PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total o Parcial
        13. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo importe Potser sobra o millor algun altre paràmetre com PCTIPDER.
        14. PCERROR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correctamente o un código identificativo si ha habido algún error.
   Retorna una colección SYS_REF_CURSOR
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
      pcerror OUT NUMBER)
      RETURN sys_refcursor;

   /*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar los datos de un traspaso.
        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  NUM_ERR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correcto y sino código identificativo de error.

   Retorna una colección T_IAX_TRASPASOS con UN SOLO TRAPASO
    *************************************************************************/
   FUNCTION f_get_traspaso(pstras IN NUMBER, num_err OUT NUMBER)
      RETURN sys_refcursor;

/*************************************************************************
       FUNCTION 4.3.1.6.1.3   F_SET_TRASPASO
Función que sirve para insertar o actualizar datos del traspaso. Sólo se puede utilizar si el traspaso esta en estado Sin confirmar o Confirmado.
Parámetros

1. PSSEGURO:Tipo numérico. Parámetro de entrada. Identificador de póliza.
2. PSPRODUC: Tipo numérico. Parámetro de entrada. Identificador de producto.
3. PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
4. PFSOLICI:Tipo fecha. Parámetro de entrada. Fecha de solicitud.
5. PCINOUT: Tipo numérico. Parámetro de entrada. Entrada / Salida
6. PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
7. PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
8. PCTIPDER: Tipo numérico. Parámetro de entrada. Traspasa derechos económicos o consolidados.
9. PCESTADO: Tipo numérico. Parámetro de entrada. Sin Confirmar / Confirmado / …..
10.   PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Tipo de traspaso solictado.
11.   PIIMPTEMP: Tipo numérico. Parámetro de entrada. Importe Solicitado
12.   NPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje solicitado.
13.   NPARPLA: Tipo numérico. Parámetro de entrada. Participaciones solicitadas.
14.   CCOPLA: Tipo numérico. Parámetro de entrada. Código de Plan del o al que se traspasa.
15.   TCCODPLA:Tipo Carácter. Parámetro de entrada. Nombre del plan del o al que se traspasa.
16.   CCOMPANI: Tipo Numérico. Parámetro de entrada. Código de compañía del o al que se traspasa
17.   TCOMPANI: Tipo Carácter. Parámetro de entrada. Nombre de compañía del o al que se traspasa
18.   CTIPBAN:Tipo de cuenta. Parámetro de entrada. Tipo de cuenta del plan al que se traspasa
19.   CBANCAR: Tipo Carácter. Parámetro de entrada. Cuenta del plan al que se traspasa
20.   TPOLEXT: Tipo Carácter. Parámetro de entrada. Código identificativo de la póliza (o plan) del o al que se traspasa,
21.   NCERTEXT: Tipo numérico. Parámetro de entrada. Núm. de certificado cuando el traspaso es interno, entre planes o pólizas de planes de pensiones.
22.   CCODPLA: Tipo numérico. Parámetro de entrada. Código del plan.
23.   TCODPLA: Tipo carácter. Parámetro de entrada. Nombre del plan.
24.   FANTIGI:Tipo fecha. Parámetro de entrada. Fecha de antigüedad de las aportaciones del plan origen.
25.   IIMPANU: Tipo numérico. Parámetro de entrada. Aportaciones del año de traspaso en el plan origen.
26.   NPARRET: Tipo numérico. Parámetro de entrada. Participaciones retenidas para contingencias posteriores.
27.   IIMPRET: Tipo numérico. Parámetro de entrada. Importe retenido para contingencias posteriores a la primera contingencia.
28.   NPARPOS2006: Tipo numérico. Parámetro de entrada. Participaciones posteriores al año 2006.
29.   PORCPOS2006: Tipo numérico. Parámetro de entrada. Porcentaje de las participaciones posteriroes al año 2006.
30.   NPARANT2007: Tipo numérico. Parámetro de entrada. Participaciones anteriores al año 2007.
31.   PORCANT2007: Tipo numérico. Parámetro de entrada. Porcentaje de participaciones anteriores al año 2007.
32.   TMEMO:Tipo Carácter. Parámetro de entrada. Comentarios / observaciones relacionadas con el traspaso.
33.   NREF:Tipo Carácter. Parámetro de entrada. Referencia del traspaso enviado o que se envía en la Norma234
34.   PCTIPCONT: tipo de contingencia acaecida
35.   PFCONTIG: fecha de contingencia acaecida
36.   PCTIPCAP: forma de tipo de cobro
37.   PIMPORTE: importe
38.   PFPROPAG: fecha de próximo pago
39.   PSTRAS: Tipo numérico. Parámetro de entrada/salida. Código de traspaso.
Retorna un valor numérico: 0 si ha grabado el traspaso y 1 si se ha producido algún error.
   *************************************************************************/
   FUNCTION f_set_traspaso(
      ppsseguro IN NUMBER,
      ppfsolici IN DATE,
      ppcinout IN NUMBER,
      ppctiptras IN NUMBER,
      ppcextern IN NUMBER,
      ppctipder IN NUMBER,
      ppcestado IN NUMBER,
      ppctiptrassol IN NUMBER,
      ppiimptemp IN NUMBER,
      nnporcen IN NUMBER,
      nnparpla IN NUMBER,
      cccodpla IN NUMBER,
      ttccodpla IN VARCHAR2,
      cccompani IN NUMBER,
      ttcompani IN VARCHAR2,
      cctipban IN NUMBER,
      ccbancar IN VARCHAR2,
      ttpolext IN VARCHAR2,
      nncertext IN NUMBER,
      ffantigi IN DATE,
      iiimpanu IN NUMBER,
      nnparret IN NUMBER,
      iiimpret IN NUMBER,   --es en realidad iimporte.
      nnparpos2006 IN NUMBER,
      pporcpos2006 IN NUMBER,
      nnparant2007 IN NUMBER,
      pporcant2007 IN NUMBER,
      ttmemo IN VARCHAR2,
      nnref IN VARCHAR2,
      ccmotivo IN NUMBER,
      ffefecto IN DATE,
      ffvalor IN DATE,
-- Ini Bug 16259 - SRA - 20/10/2010: nuevos campos en la pantalla axisctr093
      pctipcont IN NUMBER,
      pfcontig IN DATE,
      pctipcap IN NUMBER,
      pimporte IN NUMBER,
      pfpropag IN DATE,
-- Fin Bug 16259 - SRA - 20/10/2010
      ppstras IN OUT NUMBER)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_DEL_TRASPASO
       Función que sirve para borrar los datos del traspaso. Sólo se puede utilizar
       si el traspaso esta en estado Sin confirmar. Y sólo se permite a un perfil de seguridad

       1.   PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_del_traspaso(pstras IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ACTEST_TRASPASO
       Función que sirve para actualizar el estado de un traspaso.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
         2. PCESTADO: Tipo numérico. Parámetro de entrada. Código de estado.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_actest_traspaso(
      pstras IN NUMBER,
      pcestado IN NUMBER,
      pinout IN NUMBER,
      pextern IN NUMBER,
      cmotivo IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_ENVIAR_TRASPASO
       Función que sirve para enviar un traspaso con la norma 234.

         1. PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.

    Retorna un valor numérico: 0 si ha grabado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_enviar_traspaso(pstras IN NUMBER)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_OUT_PARTIC
       Función que realiza un traspaso de salida.
       Esta función adapta y actualiza la función PK_TRASPASOS.F_OUT_PARTIC.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PPARTRAS: Tipo numérico. Parámetro de entrada. Importe del traspaso en participaciones.
        9.  PNPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje a traspasar.
        10. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Indicador del tipo de importe a traspasar (importe, porcentaje...)
        11.  PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
        12. PSSEGURO_DS: Tipo numérico. Parámetro de entrada. Póliza destino si es traspaso interno.
        13. PAUTOMATIC: Tipo numérico. Parámetro de entrada. Indica si el traspaso inverso se ejecuta o no (evitar bucles infinitos en traspasos internos).
        14. PPORDCONS: Tipo numérico. Parámetro de entrada. Porcentaje.
        15. PPORDECON: Tipo numérico. Parámetro de entrada. Porcentaje.
        16. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.

   Retorna un valor numérico: 0 si ha ejecutado el traspaso y un código identificativo de error si se ha producido algún problema.
       *************************************************************************/
   FUNCTION f_out_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      pctiptrassol IN NUMBER,
      pcextern IN NUMBER,
      psseguro_ds IN NUMBER,
      pautomatic IN NUMBER,
      ppordcons IN NUMBER,
      ppordecon IN NUMBER,
      psproces IN NUMBER,
      ptipder IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
   FUNCTION F_IN_PARTIC
    Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Total / Parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PPARTRAS: Tipo numérico. Parámetro de entrada. Importe del traspaso en participaciones.
        9.  PNPORCEN: Tipo numérico. Parámetro de entrada. Porcentaje a traspasar.
        10. PCTIPTRASSOL: Tipo numérico. Parámetro de entrada. Indicador del tipo de importe a traspasar (importe, porcentaje...)
        11. PCEXTERN: Tipo numérico. Parámetro de entrada. Interno / Externo
        12. PSSEGURO_OR: Tipo numérico. Parámetro de entrada. Póliza destino si es traspaso interno.
        13. PAUTOMATIC: Tipo numérico. Parámetro de entrada. Indica si el traspaso inverso se ejecuta o no (evitar bucles infinitos en traspasos internos).
        14. PPORDCONS: Tipo numérico. Parámetro de entrada. Porcentaje.
        15. PPORDECON: Tipo numérico. Parámetro de entrada. Porcentaje.
        16. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.


    Retorna un valor numérico: 0 si ha ejecutado el traspaso y un código identificativo de error si se ha producido algún problema.
    *************************************************************************/
   FUNCTION f_in_partic(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN DATE,
      pfefecto IN DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      pctiptrassol IN NUMBER,
      pcextern IN NUMBER,
      psseguro_or IN NUMBER,
      pautomatic IN NUMBER,
      ppordcons IN NUMBER,
      ppordecon IN NUMBER,
      psproces IN NUMBER,
      ptipder IN NUMBER)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_IN
        Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        3.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        4.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        5.  PFVALMOV: Tipo fecha. Parámetro de entrada. Fecha de valor del traspaso.
        6.  PFEFECTO: Tipo fecha. Parámetro de entrada. Fecha de efecto del traspaso.
        7.  PIMOVIMI: Tipo numérico. Parámetro de entrada. Importe del traspaso en dinero
        8.  PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.
        9.  PNNUMLIN: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        10. PFCONTAB: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        11. PNRECIBO: Tipo numérico. Parámetro de salida. Recibo creado.

   Retorna un valor numérico: 0 si ha borrado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_in(
      pstras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN NUMBER,
      psproces IN NUMBER,
      pnnumlin OUT NUMBER,
      pfcontab IN OUT DATE,
      pnrecibo OUT NUMBER)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_OUT
       Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Tipo de traspaso Total o parcial
        3.  PSSEGURO: Tipo numérico. Parámetro de entrada. Código de póliza.
        4.  PNRIESGO: Tipo numérico. Parámetro de entrada. Número de riesgo.
        5.  PCAGRPRO: Tipo numérico. Parámetro de entrada. Código agrupación de producto
        6.  PFVALMOV: Tipo fecha. Parámetro de entrada/salida. Fecha de valor del traspaso.
        7.  PFEFECTO: Tipo fecha. Parámetro de entrada/salida. Fecha de efecto del traspaso.
        8.  PIMOVIMI: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en dinero.
        9.  PPARTRAS: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en participaciones.
        10. PSPERSDESTIN: Tipo numérico. Parámetro de entrada. Destinatario del pago.
        11. PEPAGSIN: Tipo numérico. Parámetro de entrada. Estado del pago del siniestro aceptado o pagado
        12. PCBANCAR: Tipo carácter. Parámetro de entrada.Cuenta bancaria destino del pago.
        13. PCTIBBAN: Tipo numérico. Parámetro de entrada. Tipo de cuenta.
        14. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.
        15. PNNUMLIN: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.
        16. PFCONTAB: Tipo numérico. Parámetro de salida. Clave en CTASEGURO.

   Retorna un valor numérico: 0 si ha demorado el traspaso y 1 si se ha producido algún error.
       *************************************************************************/
   FUNCTION f_out(
      pstras IN NUMBER,
      pctiptras IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pcagrpro IN NUMBER,
      pfvalmov IN OUT DATE,
      pfefecto IN OUT DATE,
      pimovimi IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pspersdestin IN NUMBER,
      pepagsin IN NUMBER,
      pcbancar IN VARCHAR2,
      pctibban IN NUMBER,
      psproces IN NUMBER,
      pnnumlin OUT NUMBER,
      pfcontab OUT DATE)
      RETURN NUMBER;

      /*************************************************************************
      FUNCTION F_TRASPASO_INVERSO
       Función que realiza un traspaso de salida.

        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  PSSEGURO_DS: Tipo numérico. Parámetro de entrada. Identificador de la póliza destino.
        3.  PNRIESGO_DS: Tipo numérico. Parámetro de entrada. Núm. del riesgo.
        4.  PSSEGURO_OR: Tipo numérico. Parámetro de entrada. Identificador de la póliza origen.
        5.  PNRIESGO_OR: Tipo numérico. Parámetro de entrada. Núm. del riesgo.
        6.  PIMOVIMI: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en dinero.
        7.  PPARTRAS: Tipo numérico. Parámetro de entrada/salida. Importe del traspaso en participaciones.
        8.  PCTIPTRAS: Tipo numérico. Parámetro de entrada. Tipo de traspaso Total o parcial
        9.  PCINOUT: Tipo numérico. Parámetro de entrada. Sentido del traspaso que se crea.
        10. PSTRASIN: Tipo numérico. Parámetro de entrada/salida. Identificador del traspaso inverso creado.
        11. PSPROCES: Tipo numérico. Parámetro de entrada. Identificador de proceso.

   Retorna un valor numérico: 0 si ha insertado el traspaso inverso o un código identificativo de error si se ha producido algún problema.
       *************************************************************************/
   FUNCTION f_traspaso_inverso(
      pstras IN NUMBER,
      psseguro_ds IN NUMBER,
      pnriesgo_ds IN NUMBER,
      psseguro_or IN NUMBER,
      pnriesgo_or IN NUMBER,
      pctipder IN NUMBER,
      pimovimi IN OUT NUMBER,
      pnporcen IN OUT NUMBER,
      ppartras IN OUT NUMBER,
      pctiptras IN NUMBER,
      pctiptrassol IN NUMBER,
      pcinout IN NUMBER,
      pstrasin IN OUT NUMBER,
      psproces IN NUMBER)
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

   Retorna un valor numérico: 0 si ha informado el traspaso o un código de error identificativo.
       *************************************************************************/
   FUNCTION f_informar_traspaso(
      pstras IN NUMBER,
      zfantigi IN DATE,
      ziimpanu IN NUMBER,
      znparret IN NUMBER,
      ziimpret IN NUMBER,
      ztmemo IN VARCHAR2,   -- BUG 15197 - PFA - Afegir camp observacions
      znparpos2006 IN NUMBER,
      zporcpos2006 IN NUMBER,
      znparant2007 IN NUMBER,
      zporcant2007 IN NUMBER)
      RETURN NUMBER;

/* BUG 15372 - 14/07/2010 - SRA - se crea la nueva transacción f_get_traspasos_pol para que informe el bloque Traspasos en axisctr097 */
   FUNCTION f_get_traspasos_pol(
      psseguro IN seguros.sseguro%TYPE,
      pmodo IN VARCHAR2,
      pcerror OUT NUMBER)
      RETURN sys_refcursor;

   -- BUG 15296 - 06/07/2010 - SRA: función para obtener el listado de traspasos
   FUNCTION f_obtener_traspasos(
      pfdesde IN DATE,
      pfhasta IN DATE,
      pcempres IN NUMBER,
      pfichero OUT VARCHAR2)
      RETURN NUMBER;

-- Bug 16259 - SRA - 18/10/2010: recuperamos en la consulta los campos de "contingencia acaecida" y "fecha de contingencia"
   /*************************************************************************
   FUNCTION F_GET_TRASPLAPRESTA
   Función que sirve para recuperar información de la prestación en caso de traspaso de derechos económicos.
        1.  PSTRAS: Tipo numérico. Parámetro de entrada. Código de traspaso.
        2.  NUM_ERR: Tipo numérico. Parámetro de Salida. 0 si todo ha ido correcto y sino código identificativo de error.
    *************************************************************************/
   FUNCTION f_get_trasplapresta(pstras IN NUMBER, num_err OUT NUMBER)
      RETURN sys_refcursor;

   /********* ALBERTO ****************
   Llena la talba de aportaciones TRASPLAAPORTACIONES de un traspaso destino "ptrasout"
   a partir de la tabla PRIMAS_CONSUMIDAS del siniestro de su traspaso origen "ptrasfin"
   **********************************************/
   FUNCTION f_llenar_primas ( ptrasfin IN NUMBER, ptrasout IN NUMBER )
      RETURN NUMBER;

   /********* ALBERTO ****************
   Informa los campos de TRASPLAINOUT del nuevo traspaso creado "ptrasout" con los campos
   asociados al registro 228 para la póliza del traspaso Origen "ptrasfin"
   **********************************************/
   FUNCTION f_llenar_datos_228 ( ptrasfin IN NUMBER, ptrasout IN NUMBER )
      RETURN NUMBER;



END pac_traspasos;

/

  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_TRASPASOS" TO "PROGRAMADORESCSI";
