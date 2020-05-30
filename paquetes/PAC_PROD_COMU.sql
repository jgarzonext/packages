--------------------------------------------------------
--  DDL for Package PAC_PROD_COMU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROD_COMU" AUTHID CURRENT_USER IS
   /****************************************************************************
      NOMBRE:       pac_prod_comu
      PROPÓSITO:  Funciones para la gestión común.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ----------------------------------
      2.0        10/02/2009   RSC                  Desarrollo de sistema de copago
      2.1        12/02/2009   RSC             Adaptacion a colectivos multiples
                                              con certificados
      2.2        23/04/2009   APD             Se añade el parametro psseguro a p_revision_renovacion
      2.3        29/04/2009   APD             Bug 9803 - se añade a la funcion f_grabar_inttec el parametro pninttec
      2.4        15/06/2009   JTS             BUG 10069
      2.5        21/06/2011   JMF             0018812: ENSA102-Proceso de alta de prestación en forma de renta actuarial
      2.6        04/03/2013   AEG             0024685: (POSDE600)-Desarrollo-GAPS Tecnico-Id 5 -- N?mero de p?liza manual
   ****************************************************************************/

   -- JRH 29/10/2007: Array para insertar preguntas.
   TYPE r_preguntas IS RECORD(
      codigo         codipregun.cpregun%TYPE,
      respuesta      VARCHAR2(2000),
      tipo           VARCHAR2(1)
   );

   TYPE t_preguntas IS TABLE OF r_preguntas
      INDEX BY BINARY_INTEGER;

   TYPE t_recibos_imp IS TABLE OF NUMBER(9)
      INDEX BY BINARY_INTEGER;

   FUNCTION f_grabar_alta_poliza(psseguro_est IN NUMBER, psseguro OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabar_esttomador(
      psseguro IN NUMBER,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pnordtom IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabar_estriesgos_persona(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovima IN NUMBER,
      pfefecto IN DATE,
      psperson IN NUMBER,
      pcdomici IN NUMBER,
      pspermin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_grabar_estassegurats(
      psseguro IN NUMBER,
      pnorden IN NUMBER,
      pfefecto IN DATE,
      psperson IN NUMBER,
      pcdomici IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_borrar_estassegurats(psseguro IN NUMBER)
      RETURN NUMBER;

   -- Bug 0018812 - 21/06/2011 - JMF: añadir pctipban
   FUNCTION f_actualiza_datos_gestion(
      psseguro IN NUMBER,
      pcidioma IN NUMBER,
      pcagente IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pndurper IN NUMBER,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_grabar_beneficiarios(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER;

/********************************************************************************************************************
   --JRH 09/2007 Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar de este interés.

   Función que graba el interés técnico de la póliza en ESTINTERTECSEG siempre y cuando haya interés técnico
   definido a nivel de producto.

   En el caso de que se informe el importe se han añadido los tramos para el caso de LRC (periodo anualidad) a los que se refiere el importe.

     Para ramos tipo LRC en el caso de que no se informe el importe se daran de alta en las tablas de intereses a nivel de póliza
     los intereses correspondientes a todas las anualidades del periodo seleccionado (parametrizados a nivel de producto).

   En el resto de casos si el parámetro PINTTEC es NULO, entonces se busca el interés parametrizado en el producto
********************************************************************************************************************/
   FUNCTION f_grabar_inttec(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER,
      pinttec IN NUMBER DEFAULT NULL,
      ptablas IN VARCHAR2 DEFAULT 'EST',
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL,   --JRH 09/2007 Tarea 2674: Intereses para LRC.Añadimos el tramo que queremos insertar este interés.
      pninttec IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*********************************************************************************************************************************
 JRH 29/10/2007:  Función que inserta las preguntas de una poliza a partir de un array del tipo r_preguntas que las contiene.

*******************************************************************************************************************************/
   FUNCTION f_grabar_preguntas(
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfefecto IN DATE,
      tab_pregun t_preguntas,
      pcidioma_user IN NUMBER,
      pnmovimi IN NUMBER DEFAULT 1)
      RETURN NUMBER;

/*********************************************************************************************************************************
--JRH Esta función estaba antes en el producción AHO, la psamos al comu con el nuevo parametro capital para rentas.
*******************************************************************************************************************************/
   FUNCTION f_programa_revision_renovacion(
      psseguro IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pcapital IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_grabar_penalizacion(
      pmodo IN NUMBER,
      psproduc IN NUMBER,
      psseguro IN NUMBER,
      pfefecto IN DATE,
      pnmovimi IN NUMBER DEFAULT 1,
      ptablas IN VARCHAR2 DEFAULT 'EST')
      RETURN NUMBER;

   FUNCTION f_emite_propuesta(
      psseguro IN NUMBER,
      pnpoliza OUT NUMBER,
      pncertif OUT NUMBER,
      pnrecibo OUT NUMBER,
      pnsolici OUT NUMBER)
      RETURN NUMBER;

--JRH Añadimos un vector con preguntas y sus respuestas (a nivel de producto)
-- Bug 0018812 - 21/06/2011 - JMF: añadir pctipban
   FUNCTION f_inicializa_propuesta(
      psproduc IN NUMBER,
      psperson1 IN NUMBER,
      pcdomici1 IN NUMBER,
      psperson2 IN NUMBER,
      pcdomici2 IN NUMBER,
      pcagente IN NUMBER,
      pcidioma IN NUMBER,
      pfefecto IN DATE,
      pnduraci IN NUMBER,
      pfvencim IN DATE,
      pcforpag IN NUMBER,
      pcbancar IN VARCHAR2,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2,
      prima_inicial IN NUMBER,
      prima_per IN NUMBER,
      prevali IN NUMBER,
      pcfallaseg1 IN NUMBER,
      pcfallaseg2 IN NUMBER,
      pcaccaseg1 IN NUMBER,
      pcaccaseg2 IN NUMBER,
      psseguro IN OUT NUMBER,
      tab_pregun t_preguntas,
      pformpagorent NUMBER DEFAULT NULL,
      pctipban NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cambio_ccc(psseguro IN NUMBER, pcbancar IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cambio_beneficiario(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psclaben IN NUMBER,
      ptclaben IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_cambio_oficina(psseguro IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cambio_domicilio(psseguro IN NUMBER, pnordtom IN NUMBER, pcdomici IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_cambio_idioma(psseguro IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER;

--JRH 09/2007 Tarea 2674:
--Funciona como siempre exepto para los intereses de LRC. Para estos añadimos el tramo (periodo - anualidad) del que queremos cambbiar el interés.
   FUNCTION f_cambio_interes(
      psseguro IN NUMBER,
      pndurper IN NUMBER,
      ppinttec IN NUMBER,
      pnmovimi IN NUMBER,
      pvtramoini IN NUMBER DEFAULT NULL,
      pvtramofin IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

   FUNCTION f_cambio_fall_asegurado(psseguro IN NUMBER, psperson IN NUMBER, pffallec IN DATE)
      RETURN NUMBER;

--JRH 11/2007 Pasamos este proceso del produccion_aho al produccion_comu
   PROCEDURE p_revision_renovacion(
      pfecha IN DATE,
      psproduc IN NUMBER,
      psproces IN OUT NUMBER,
      psseguro IN NUMBER DEFAULT NULL);

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_emision_cobro_recibo

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_cobro_rimpagados

   --BUG 11777 - 25/11/2009 - JRB - Se elimina la funcion f_cobro_recibo_online
   FUNCTION f_cambio_rescate_parcial(
      psseguroreal IN NUMBER,
      psseguro IN NUMBER,
      pfecha IN DATE,
      v_movimi IN NUMBER,
      pirescatep IN NUMBER)
      RETURN NUMBER;

   -- Bug 5467 - 10/02/2009 - RSC - CRE - Desarrollo de sistema de copago
   FUNCTION f_grabar_copago(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      porden IN NUMBER,
      ppersona IN NUMBER,
      pfinicio IN DATE,
      pffinal IN DATE,
      pbancar IN NUMBER,
      pforpag IN NUMBER,
      ptipo IN NUMBER,
      pporcen IN NUMBER,
      pimporte IN NUMBER,
      ptipban IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************
       -- BUG 24685 - 2013-02-14 - AEG
       Formatea numero de poliza real
       param in  psseguro:  numero del seguro para traer el ramo
       param in  pnpolizamanual:  numero de la póliza digitada por el usuario.
       return: NUMBER (numero de poliza real, null si hay errores.
    ***************************************************************************/
   FUNCTION f_obtener_polizamanual(psproduc IN NUMBER, pnpolizamanual IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************
       -- BUG 24685 - 2013-02-14 - AEG
       Actualiza estado de reserva rangos
       param in  ptipo  :  tipo del rango a actualizar
       param in  pcramo :  pcramo del rango a actualizar
       param in  pnpolizamanual:  numero de la póliza digitada por el usuario.
       return: NUMBER (1 error 0 no error).
    ***************************************************************************/
   FUNCTION f_asignarango(ptipo IN NUMBER, pcramo IN NUMBER, npolizamanual IN NUMBER)
      RETURN NUMBER;
END pac_prod_comu;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROD_COMU" TO "PROGRAMADORESCSI";
