--------------------------------------------------------
--  DDL for Package PAC_MD_DOMICILIACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DOMICILIACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_MD_DOMICILIACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones. gestión

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/02/2009   XCG                1. Creación del package.
   2.0        27/08/2010   FAL                2. 0015750: CRE998 - Modificacions mòdul domiciliacions
   3.0        19/07/2011   JMP                3. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
   4.0        03/04/2012   JGR                4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

 ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   e_error_controlat EXCEPTION;

/**************************************************************************
        Función que inserta las domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PFFECCOB   : fecha de remesea de la domiciliación
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PIDIOMA   : idioma
        PARAM OUT PNOK      : nº recibos domiciliados correctamente
        PARAM OUT PNKO      : nº recibos domiciliados incorrectamente
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
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER,
      pcbanco IN NUMBER,
      pctipcta IN NUMBER,
      pfvtotar IN VARCHAR2,
      pcreferen IN VARCHAR2,
      pdfefecto IN DATE,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      --BUG 23645 - 07/09/2012 - JTS
      pcagente IN NUMBER,
      ptagente IN VARCHAR2,
      pnnumide IN VARCHAR2,
      pttomador IN VARCHAR2,
      pnrecibo IN NUMBER,
      --FI BUG 23645
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      sproces OUT NUMBER,
      nommap1 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nommap2 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nomdr OUT VARCHAR2,   --Path Completo Fichero de DR,
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
        PARAM OUT mensaje    : Tratamiento del mensaje
   *************************************************************************/
   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar varios productos en el proceso domiciliación
      psprodom IN NUMBER,
      -- FI Bug 15750 - FAL - 27/08/2010
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL,
      -- FIN BUG 18825 - 19/07/2011 - JMP
      pcagente IN NUMBER DEFAULT NULL,   -- Código Mediador -- 4. 0021718 / 0111176 - Inicio
      ptagente IN VARCHAR2 DEFAULT NULL,   -- Nombre Mediador
      pnnumide IN VARCHAR2 DEFAULT NULL,   -- Nif Tomador
      pttomador IN VARCHAR2 DEFAULT NULL,   -- Nombre Tomador
      pnrecibo IN NUMBER DEFAULT NULL,   -- Recibo -- 4. 0021718 / 0111176 - Fin
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   -- Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación
   /*******************************************************************************
   FUNCION F_SET_PRODDOMIS
   Función que inserta los productos seleccionados para realizar la domiciliación en el proceso.
    Parámetros:
     Pcempres  NUMBER : Id. empresa
     Psproces  NUMBER : ID.
     Psproduc  NUMBER : Id. producto
     Pseleccio NUMBER : Valor seleccionado
    Salida :
     Mensajes  T_IAX_MENSAJES

    Retorna: un NUMBER con el id de error.
   ********************************************************************************/
   FUNCTION f_set_proddomis(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      psproduc IN NUMBER,
      pseleccio IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

-- FI Bug 15750 - FAL - 27/08/2010 - Permitir seleccionar productos en el proceso domiciliación

   /*************************************************************************
    --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

          Funcion en capa MD para obtener los datos de la cabecera de domiciliaciones
          param in pcempres   : Código de empresa
          param in psproces   : Código de proceso (número de remesa)
          param in pccobban   : Código de cobrador bancario
          param in pfinirem   : Fecha inicio remesa
          param in pffinrem   : Fecha fin remesa
          param out mensaje   : Tratamiento del mensaje
          return           : 0 indica cambio realizado correctamente
                             <> 0 indica error
   *************************************************************************/
   FUNCTION f_get_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfinirem IN DATE,
      pffinrem IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/*************************************************************************
 --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para modificar el cabecera de domiciliaciones
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pccobban   : Código de cobrador bancario
       param in pfefecto   : Fecha de efecto de la remesa
       param in ptfileenv  : Nombre del fichero de envío
       param in ptfiledev  : Nombre del fichero de devolución
       param in pcestdom   : Estado de la remesa
       param in pcremban   : Número de remesa interna de la entidad bancaria
       param in pidioma    : Código de idioma
       param out psquery   : Query
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_set_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pfefecto IN DATE,
      ptfileenv IN VARCHAR2,
      ptfiledev IN VARCHAR2,
      pcestdom IN NUMBER,
      pcremban IN VARCHAR2,
      psdevolu IN NUMBER,
      psprocie IN NUMBER,   -- 9. 0022753: MDP_A001-Cierre de remesa (+)
      pcidioma IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

/*************************************************************************
 --4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para retroceder una domiciliación
       param in pcempres   : Código de empresa
       param in psproces   : Código de proceso (número de remesa)
       param in pfecha     : Fecha de la retrocesión
       param in pidioma    : Código de idioma
       return              : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_retro_domiciliacion(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pfecha IN DATE,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_domiciliaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DOMICILIACIONES" TO "PROGRAMADORESCSI";
