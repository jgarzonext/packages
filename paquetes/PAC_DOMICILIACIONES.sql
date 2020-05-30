--------------------------------------------------------
--  DDL for Package PAC_DOMICILIACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DOMICILIACIONES" AS
/******************************************************************************
   NOMBRE:       PAC_DOMICILIACIONES
   PROPÓSITO:  Mantenimiento domiciliaciones capa lógica

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/02/2009   XCG                1. Creación del package.
   2.0        27/08/2010   FAL                2. 0015750: CRE998 - Modificacions mòdul domiciliacions
   3.0        19/07/2011   JMP                3. 0018825: LCOL_A001- Modificacion de la pantalla de domiciliaciones
   4.0        03/04/2012   JGR                4. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176
   5.0        17/07/2012   JGR                5. 0022753: MDP_A001-Cierre de remesa

 ******************************************************************************/
/**************************************************************************
        Función que inserta las domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PFFECCOB   : fecha de remesea de la domiciliación
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PSPRODOM   : nº proceso selección productos a domiciliar
        PARAM IN PIDIOMA    : idioma
        PARAM OUT PNOK      : nº recibos domiciliados correctamente
        PARAM OUT PNKO      : nº recibos domiciliados incorrectamente
        PARAM OUT PPATH     : Dirección donde se guardan los ficheros generados
            NomMap1 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomMap2 OUT VARCHAR2, --Path Completo Fichero de map 312,
            NomDR OUT VARCHAR2,   --Path Completo Fichero de DR,
        PARAM OUT NERROR    : Código de error (0: opración correcta sino error)

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
      pidioma IN NUMBER,
      pnok OUT NUMBER,
      pnko OUT NUMBER,
      ppath OUT VARCHAR2,
      nommap1 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nommap2 OUT VARCHAR2,   --Path Completo Fichero de map 312,
      nomdr OUT VARCHAR2,   --Path Completo Fichero de DR,
      vsproces OUT NUMBER)
      RETURN NUMBER;

/**************************************************************************
        Función que se retorna la información de domiciliaciones
        PARAM IN PSPROCES   : nº proceso de domiciliación
        PARAM IN PCEMPRES   : nº empresa
        PARAM IN PCRAMO     : nº ramo
        PARAM IN PSPRODUC   : nº producto
        PARAM IN PEFECTO    : fecha efecto límite de recibos
        PARAM IN PIDIOMA    : idioma
        PARAM OUT PSQUERY   : consulta a realizar construida en función de los parametros
        PARAM IN PCCOBBAN   : Código de cobrador bancario
        PARAM IN PCBANCO    : Código de banco
        PARAM IN PCTIPCTA   : Tipo de cuenta
        PARAM IN PFVTOTAR   : Fecha de vencimiento tarjeta
        PARAM IN PCREFEREN  : Código de referencia
        RETURN              : Código de error (0: opración correcta sino error)

   *************************************************************************/
   FUNCTION f_get_domiciliacion(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcramo IN NUMBER,
      psproduc IN NUMBER,
      pfefecto IN DATE,
      pidioma IN NUMBER,
      psquery OUT VARCHAR2,
      psprodom IN NUMBER DEFAULT NULL,
      -- BUG 18825 - 19/07/2011 - JMP
      pccobban IN NUMBER DEFAULT NULL,
      pcbanco IN NUMBER DEFAULT NULL,
      pctipcta IN NUMBER DEFAULT NULL,
      pfvtotar IN VARCHAR2 DEFAULT NULL,
      pcreferen IN VARCHAR2 DEFAULT NULL,
      pdfefecto IN DATE DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,   -- Código Mediador -- 8. 0021718 / 0111176 - Inicio
      ptagente IN VARCHAR2 DEFAULT NULL,   -- Nombre Mediador
      pnnumide IN VARCHAR2 DEFAULT NULL,   -- Nif Tomador
      pttomador IN VARCHAR2 DEFAULT NULL,   -- Nombre Tomador
      pnrecibo IN NUMBER DEFAULT NULL   -- Recibo           -- 8. 0021718 / 0111176 - Fin
                                     )
      -- FIN BUG 18825 - 19/07/2011 - JMP
   RETURN NUMBER;

   FUNCTION ff_nombre_entidad(pcbancar VARCHAR2, pctipban NUMBER)
      RETURN VARCHAR;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

       Funcion para obtener los datos de la cabecera de domiciliaciones
       param in psproces   : Código de proceso (número de remesa)
       param in pcempres   : Código de empresa
       param in pccobban   : Código de cobrador bancario
       param in pidioma    : Código de idioma
       param in pfinirem   : Fecha inicio remesa
       param in pffinrem   : Fecha fin remesa
       param out psquery   : Query
       return           : 0 indica cambio realizado correctamente
                          <> 0 indica error
*************************************************************************/
   FUNCTION f_get_domiciliacion_cab(
      pcempres IN NUMBER,
      psproces IN NUMBER,
      pccobban IN NUMBER,
      pidioma IN NUMBER,
      pfinirem IN DATE,
      pffinrem IN DATE,
      psquery OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

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
       return              : 0 indica cambio realizado correctamente
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
      psprocie IN NUMBER,   -- 5. 0022753: MDP_A001-Cierre de remesa (+)
      pcidioma IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

/*************************************************************************
 --8. 0021718: MDP_A001-Domiciliaciones: modificaciones generales - 0111176

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
      pfecha IN DATE DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

     /*******************************************************************************
   FUNCION f_cierre_remesa
   Función que cierra las remesa y el estado de los sus recibos.
   Parámetros:
    Entrada :
       Psproces NUMBER

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_cierre_remesa(
      pcempres IN NUMBER DEFAULT pac_md_common.f_get_cxtempresa,
      psproces IN NUMBER,   --> DOMICILIACIONES.SPROCES
      psproces2 IN NUMBER,   --> LIQUIDACAB.SPROCES
      pnum_ok OUT NUMBER,
      pnum_ko OUT NUMBER,
      psmovagr IN OUT NUMBER,
      pfdebito IN DATE DEFAULT NULL,
      pfproces IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*******************************************************************************
   FUNCION f_cierre_automatico_remesas
   Función que busca las remesas que se han de cerrar automáticamente.
   Existen dos parámetros por empresa
     DIASGEST_DIRECTO = 0; -- (0-No, 1-Sí)
     DIASGEST := Nº tramo creado en el punto anterior.

   Sí DIASGEST_DIRECTO = 1 (Sí), los días son los que hay directamente en DIASGEST,
   Sino DIASGEST contiene el tramo donde se guardan los días de gestión por meses

   Parámetros:
    Entrada :
       Pcempres
       Psproces
       Pnmes
       Pfproces

    Retorna: un NUMBER con el id del error.
   ********************************************************************************/
   FUNCTION f_cierre_automatico_remesas(
      pcempres IN NUMBER,
      pfcierre IN DATE,
      pfdebito IN DATE DEFAULT NULL,
      pfproces IN DATE DEFAULT NULL)
      RETURN NUMBER;

   /*************************************************************************
   Función que se encargará gde generar el listado de acciones de los recibos
   de una remesa por cierre

   Este listado se generará automáticamente al cerrar la remesa y mostrará las
   acciones relacionadas con los recibos que cambian de estado de ‘remesado’ a ‘cobrado’.
   Quedará en el directorio parametrizado para este listado.

        param in psproces     : nº proceso de devolución
        param out mensajes    : mensajes de error
        return                : NUMBER 0 / 1

     *************************************************************************/
   FUNCTION f_get_listado_cierre_remesa(
      psproces IN NUMBER,
      pidioma IN NUMBER,
      pnomfichero OUT VARCHAR2)
      RETURN NUMBER;
END pac_domiciliaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DOMICILIACIONES" TO "PROGRAMADORESCSI";
