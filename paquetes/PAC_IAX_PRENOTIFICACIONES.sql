--------------------------------------------------------
--  DDL for Package PAC_IAX_PRENOTIFICACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_PRENOTIFICACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_PRENOTIFICACIONES
   PROPÓSITO:  Mantenimiento actividades.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        18/11/2011   JMF                1. 0020000: LCOL_A001-Prenotificaciones
   2.0        15/05/2013   JDS                2. 0026967: LCOL_A003-No se puede regenerar el archivo plano de prenotificaciones
 ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/**************************************************************************
        Función que genara las domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PFFECCOB   : fecha de remesea de la domiciliación
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PIDIOMA   : idioma
            NomMap1 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomMap2 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomDR OUT VARCHAR2,   --Path Completo Fichero de DR,
        PARAM OUT mensaje    : Tratamiento del mensaje
        PARAM OUT NERROR     : Código de error (0: opración correcta sino error)
   *************************************************************************/
   FUNCTION f_domiciliar(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pfefecto IN DATE,
      pffeccob IN DATE,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      psprodom IN NUMBER,
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,
      nommap2 OUT VARCHAR2,
      nomdr OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /**************************************************************************
          Función que se retorna la información de domiciliaciones
          PARAM IN PSPROCES   : nº proceso de domiciliación
          PARAM IN PCEMPRES   : nº empresa
          PARAM IN PCRAMO     : nº ramo
          PARAM IN PSPRODUC   : nº producto
          PARAM IN PEFECTO    : fecha efecto límite de recibos
          PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
          PARAM IN PCCOBBAN   : Código de cobrador bancario
          PARAM IN PCBANCO    : Código de banco
          PARAM IN PCTIPCTA   : Tipo de cuenta
          PARAM IN PFVTOTAR   : Fecha de vencimiento tarjeta
          PARAM IN PCREFEREN  : Código de referencia
          PARAM OUT mensaje   : Tratamiento del mensaje
     *************************************************************************/
   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      psprodom IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL)
      RETURN sys_refcursor;

   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Entrada :
       Pcempres   NUMBER : Identificador empresa
       Psproces   NUMBER : Id. proceso
       Psproduc   NUMBER : Id. producto
       Pseleccio  NUMBER : Valor seleccionado
     Salida :
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*******************************************************************************
   FUNCION F_GET_PROCESO
   Función que recupera id. proceso que agrupa de los productos a domiciliar
    Parámetros:
     Entrada :
     Salida :
       psproces   NUMBER
       Mensajes   T_IAX_MENSAJES
   Retorna: un NUMBER con el código de error.
   ********************************************************************************/
   FUNCTION f_get_proceso(psproces OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_domrecibos(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pruta OUT VARCHAR2,
      pfcobro IN DATE DEFAULT NULL,
      vtimp OUT t_iax_impresion,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_prenotificaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_PRENOTIFICACIONES" TO "PROGRAMADORESCSI";
