--------------------------------------------------------
--  DDL for Package PAC_ECO_MONEDAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ECO_MONEDAS" IS
/****************************************************************************
   NOMBRE:      pac_eco_monedas
   PROPÓSITO:   Funciones y procedimientos para el tratamieto de monedas.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        05/05/2009   LPS              1. Creación del package.(Copia de Liberty)
****************************************************************************/
   TYPE t_descripcion IS RECORD(
      idioma         eco_desmonedas.cidioma%TYPE,
      texto          eco_desmonedas.tmoneda%TYPE
   );

   TYPE t_descripciones_moneda IS TABLE OF t_descripcion
      INDEX BY BINARY_INTEGER;

   TYPE t_moneda IS RECORD(
      codigo         eco_codmonedas.cmoneda%TYPE,
      descripciones  t_descripciones_moneda,
      tipo           eco_codmonedas.ctipmoneda%TYPE,
      decimales      eco_codmonedas.ndecima%TYPE,
      iso4217x       eco_codmonedas.ciso4217x%TYPE,
      iso4217n       eco_codmonedas.ciso4217n%TYPE,
      genero         eco_codmonedas.cgenero%TYPE,
      orden          eco_codmonedas.norden%TYPE,
      visualizable   eco_codmonedas.bvisualiza%TYPE,
      usuario        eco_codmonedas.cusualt%TYPE,
      -- DRA 5-11-2007: Bug Mantis 3356
      bdefecto       eco_codmonedas.bdefecto%TYPE
   );   -- DRA 18-11-2007: Bug Mantis 3901

/*************************************************************************
   FUNCTION obtener_moneda_defecto
   Obtiene la moneda por defecto para la instación actual.
   return             : eco_codmonedas.cmoneda%TYPE
*************************************************************************/
   FUNCTION f_obtener_moneda_defecto
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_descripcion_moneda
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_moneda  : código de moneda
   param in p_idioma  : código de idioma
   return             : eco_codmonedas.cmoneda%TYPE
*************************************************************************/
   FUNCTION f_descripcion_moneda(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      p_error OUT NUMBER)
      RETURN eco_desmonedas.tmoneda%TYPE;

/*************************************************************************
   FUNCTION f_lista_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   return             : Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus descripciones ordenadas.       --
                   --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_desmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
*************************************************************************/
   FUNCTION f_lista_monedas(p_idioma IN eco_desmonedas.cidioma%TYPE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_consulta_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   return             :  Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus datos. Primero se presentan    --
   las visualizables por orden y luego las no visualizables.
                   --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_codmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
          * tipo         (eco_codmonedas.ctipmoneda%TYPE)
          * decimales    (eco_codmonedas.ndecima%TYPE)
          * iso4217x     (eco_codmonedas.ciso4217x%TYPE)
          * iso4217n     (eco_codmonedas.ciso4217n%TYPE)
          * genero       (eco_codmonedas.cgenero%TYPE)
          * orden        (eco_codmonedas.norden%TYPE)
          * visualizable (eco_codmonedas.bvisualiza%TYPE)
*************************************************************************/
   FUNCTION f_consulta_monedas(p_idioma IN eco_desmonedas.cidioma%TYPE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_consulta_monedas
   Obtiene el texto asociado a una moneda para un idioma concreto.
   param in p_idioma  : código de idioma
   param in p_criterios : record type de monedas
   return             : Devuelve una referencia a un cursor ( ya abierto ) con las monedas y sus datos. Primero se presentan    --
   las visualizables por orden y luego las no visualizables. Se le pueden pasar criterios para la
   selección y se hace con el mismo record, rellenando aquellos que deben intervenir en la selección.
                     --> ¡¡¡¡ Al final se debe cerrar el cursor !!!!. <--
   Estructura que devuelve el cursor:
          * codigo       (eco_codmonedas.cmoneda%TYPE)
          * descripcion  (eco_desmonedas.tmoneda%TYPE)
          * tipo         (eco_codmonedas.ctipmoneda%TYPE)
          * decimales    (eco_codmonedas.ndecima%TYPE)
          * iso4217x     (eco_codmonedas.ciso4217x%TYPE)
          * iso4217n     (eco_codmonedas.ciso4217n%TYPE)
          * genero       (eco_codmonedas.cgenero%TYPE)
          * orden        (eco_codmonedas.norden%TYPE)
          * visualizable (eco_codmonedas.bvisualiza%TYPE)
*************************************************************************/
   FUNCTION f_consulta_monedas(
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      p_criterios IN t_moneda)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_consulta_moneda
   Devuelve el registro con los datos para la moneda indicada.
   p_moneda IN        : código de moneda
   return             : eco_codmonedas%ROWTYPE
*************************************************************************/
   FUNCTION f_consulta_moneda(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN eco_codmonedas%ROWTYPE;

/*************************************************************************
   FUNCTION f_datos_moneda_actualizar
   Devuelve los datos asociados a una moneda.
   p_moneda IN        : código de moneda
   return             : Record type t_moneda
*************************************************************************/
   FUNCTION f_datos_moneda_actualizar(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN t_moneda;

/*************************************************************************
   PROCEDURE p_nueva_descripcion_moneda
   Permite crear una nueva descripcion para una moneda dada.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
   p_error OUT        : código de error
*************************************************************************/
   PROCEDURE p_nueva_descripcion_moneda(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion,
      p_error OUT NUMBER);

/*************************************************************************
   PROCEDURE p_actualiza_descripcion
   Permite actualizar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
*************************************************************************/
   PROCEDURE p_actualiza_descripcion(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion);

/*************************************************************************
   PROCEDURE p_borra_descripcion
   Permite borrar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
   p_descripcion IN   : Record type t_descripcion
*************************************************************************/
   PROCEDURE p_borra_descripcion(
      p_moneda IN eco_desmonedas.cmoneda%TYPE,
      p_descripcion IN t_descripcion);

/*************************************************************************
   PROCEDURE p_borra_descripciones
   Permite borrar una descripcion para una monedad dada y un idioma concreto.
   p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_borra_descripciones(p_moneda IN eco_desmonedas.cmoneda%TYPE);

/*************************************************************************
   PROCEDURE p_nueva_moneda
    Permite crear una nueva moneda.
    p_moneda IN        : código de moneda
    p_error  OUT       : código de error
*************************************************************************/
   PROCEDURE p_nueva_moneda(p_moneda IN t_moneda, p_error OUT NUMBER);

/*************************************************************************
   PROCEDURE p_actualiza_moneda
    Permite actualizar una moneda.
    p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_actualiza_moneda(p_moneda IN t_moneda);

/*************************************************************************
   PROCEDURE p_borra_moneda
    Permite actualizar una moneda.
    p_moneda IN        : código de moneda
*************************************************************************/
   PROCEDURE p_borra_moneda(p_moneda IN eco_codmonedas.cmoneda%TYPE);

/*************************************************************************
   PROCEDURE p_desbloquear_registro
    Permite desbloquear el registro que se había bloqueado para la actualización
*************************************************************************/
   PROCEDURE p_desbloquear_registro;

/*************************************************************************
   FUNCTION f_ultima_modificacion
    Permite conocer el momento en que se realizó la última modificación. Si no se ha modificado nunca       --
    devolverá un nulo.
    p_codigo IN        : código de moneda
    return             : fecha de última modificación.
*************************************************************************/
   FUNCTION f_ultima_modificacion(p_codigo IN eco_codmonedas.cmoneda%TYPE)
      RETURN DATE;

/*************************************************************************
   FUNCTION f_decimales
    Retorna el número de decimales de la moneda.
    p_moneda IN        : código de moneda
    return             : número de decimales de precisión de la moneda
*************************************************************************/
   FUNCTION f_decimales(p_moneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_existe_moneda_tpr
    Determina si la moneda está creada en TPR_MONEDAS
    psproduc IN        : código de producto
    pcmoneda IN        : código de moneda
    return             : '1' --> Existe la moneda, '0' --> no existe la moneda
*************************************************************************/
-- DRA 18-1-2008: Bug Mantis 4261. Retorna si la moneda está creada en TPR_MONEDAS
   FUNCTION f_existe_moneda_tpr(psproduc IN NUMBER, pcmoneda IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_obtener_moneda_producto
    Retorna la moneda por defecto para un producto en concreto
    psproduc IN        : código de producto
    return             : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_producto(psproduc IN productos.sproduc%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE;

    /*************************************************************************
      FUNCTION f_obtener_moneda_producto2
       Retorna la moneda delproducto en el seguro
       psproduc IN        : código de producto
       return             : código de la moneda
   *************************************************************************/
   FUNCTION f_obtener_moneda_producto2(psproduc IN productos.sproduc%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_obtener_moneda_seguro
    Retorna la moneda grabada en el seguro
    psproduc IN        : código de producto
    ptablas IN         : tablas a actualizar. 'EST', 'SOL', etc...
    return             : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_seguro(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2 DEFAULT '')
      RETURN eco_codmonedas.cmoneda%TYPE;

      /*************************************************************************
      FUNCTION f_obtener_moneda_seguro2
       Retorna la moneda delproducto en el seguro
       psproduc IN        : código de producto
       return             : código de la moneda
   *************************************************************************/
   FUNCTION f_obtener_moneda_seguro2(psseguro IN seguros.sseguro%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_obtener_moneda_producto
    Retorna la moneda por defecto para un producto en concreto
    pcramo IN           : código del ramo
    pcmodali IN         : código de modalidad
    pctipseg IN         : código de tipo de seguo
    pccolect IN         : código de colectivo
    return              : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_producto(
      pcramo IN productos.cramo%TYPE,
      pcmodali IN productos.cmodali%TYPE,
      pctipseg IN productos.ctipseg%TYPE,
      pccolect IN productos.ccolect%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_obtener_moneda_recibo
    Retorna la moneda de un recibo en concreto
    pnrecibo IN           : número de recibo
    ptablas IN            : tablas a actualizar. 'EST', 'SOL', etc...
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_recibo(
      pnrecibo IN recibos.nrecibo%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_obtener_moneda_recibo2
    Retorna la moneda de un recibo en concreto
    pnrecibo IN           : número de recibo
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_recibo2(pnrecibo IN recibos.nrecibo%TYPE)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_obtener_moneda_prod_seg
    Retorna la moneda de un recibo en concreto
    psseguro IN           : código de seguro
    ptablas IN            : tablas a actualizar. 'EST', 'SOL', etc...
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_obtener_moneda_prod_seg(
      psseguro IN seguros.sseguro%TYPE,
      ptablas IN VARCHAR2 DEFAULT NULL)
      RETURN eco_codmonedas.cmoneda%TYPE;

/*************************************************************************
   FUNCTION f_cambia_moneda_seguro
    Analiza / Realiza el cambio de la moneda o fecha de cambio en una póliza
    psseguro IN           : código de seguro
    pnriesgo IN           : número de riesgo
    pnmovimi IN           : número de movimiento
    pmonedaold IN         : código de moneda antigua
    pmonedanew IN         : código de moneda nueva
    pfcambio IN           : fecha del cambio
    pcmotmov IN           : Mótivo del movimiento
    paccion IN            : Acción --> P: Prueba  R: Real
    return                : código de la moneda
*************************************************************************/
   FUNCTION f_cambia_moneda_seguro(
      psseguro IN seguros.sseguro%TYPE,
      pnriesgo IN NUMBER,   -- DRA 2-7-08: bug mantis 6484
      pnmovimi IN NUMBER,   -- DRA 2-7-08: bug mantis 6484
      pmonedaold IN eco_codmonedas.cmoneda%TYPE,
      pmonedanew IN eco_codmonedas.cmoneda%TYPE,
      pfcambio IN DATE,
      pcmotmov IN VARCHAR2,
      paccion IN VARCHAR2 DEFAULT 'P')   --> P: Prueba  R: Real
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_obtener_formatos_moneda
    Obtiene la lista de patrones de monedas definidas en el sistema
    return                : sys_refcursor con el cmoneda, cmonint y el patron de una moneda
*************************************************************************/
   FUNCTION f_obtener_formatos_moneda
      RETURN sys_refcursor;

/*************************************************************************
   FUNCTION f_obtener_formatos_moneda
    Obtiene la lista de patrones de monedas definidas en el sistema
    param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla eco_codmonedas
    return                : el patron de una moneda
*************************************************************************/
   FUNCTION f_obtener_formatos_moneda1(pmoneda IN eco_codmonedas.cmoneda%TYPE)
      RETURN VARCHAR2;

/*************************************************************************
   FUNCTION f_obtener_formatos_moneda
    Obtiene la lista de patrones de monedas definidas en el sistema
    param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla monedas
    return                : el patron de una moneda
*************************************************************************/
   FUNCTION f_obtener_formatos_moneda2(pmoneda IN monedas.cmoneda%TYPE)
      RETURN VARCHAR2;

    /*************************************************************************
      FUNCTION f_obtener_cmonint
       Obtiene el codigo internacional de la moneda
       param pmoneda IN monedas.cmoneda%TYPE: Codigo de la moneda en la tabla monedas
       return                : Codigo de la moneda internacional
   *************************************************************************/
   FUNCTION f_obtener_cmonint(pmoneda IN monedas.cmoneda%TYPE)
      RETURN monedas.cmonint%TYPE;

   /*************************************************************************
      FUNCTION f_obtener_cmoneda
       Obtiene el codigo moneda
       param monedas.cmonint%TYPE: Codigo de la moneda internacional
       return                : Codigo de la moneda en la tabla de monedas
   *************************************************************************/
   FUNCTION f_obtener_cmoneda(pmoneda IN monedas.cmonint%TYPE)
      RETURN monedas.cmoneda%TYPE;

   /*************************************************************************
      FUNCTION f_obtener_moneda_informe
       Obtiene el codigo moneda a mostrar en los informes
       psseguro IN           : código de seguro
       psproduc IN           : código de producto
       return                : Codigo de la moneda en la tabla de monedas
   *************************************************************************/
   FUNCTION f_obtener_moneda_informe(psseguro IN NUMBER, psproduc IN NUMBER)
      RETURN monedas.cmonint%TYPE;

   /*************************************************************************
      FUNCTION f_obtener_moneda_literal
       Obtiene la descripción de la moneda a mostrar en los documentos
       psproduc IN           : código de producto
       return                : Descripcion de la moneda en la tabla de monedas
   *************************************************************************/
   FUNCTION f_obtener_moneda_literal(
      p_idioma IN eco_desmonedas.cidioma%TYPE,
      psproduc IN NUMBER)
      RETURN monedas.tdescri%TYPE;
END pac_eco_monedas;

/

  GRANT EXECUTE ON "AXIS"."PAC_ECO_MONEDAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ECO_MONEDAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ECO_MONEDAS" TO "PROGRAMADORESCSI";
