--------------------------------------------------------
--  DDL for Package PAC_SIN_INSERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_SIN_INSERT" AUTHID CURRENT_USER IS
/***************************************************************
    PROPÓSITO:  PAC_SIN_INSERT: Especificación del paquete de las
                                funciones para la inserción de registros en
                                las tablas de siniestros para los formularios
                                de entrada rápida de siniestros

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        --/--/----   ---               1. Creación del package. (bug 10124)
    7.0        20/10/2011   RSC               7. 0019425/94998: CIV998-Activar la nova gestio de traspassos
***************************************************************/
   FUNCTION ff_contador_siniestros(pcramo IN NUMBER, pmodali IN NUMBER, pccausin IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------
   FUNCTION f_insert_siniestros(
      pnsinies OUT NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pfsinies IN DATE,
      pfnotifi IN DATE,
      pcestsin IN NUMBER,
      ptsinies IN VARCHAR2,
      pccausin IN NUMBER,
      pnsinref IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------
   FUNCTION f_insert_localizatrami(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      ptubicac IN VARCHAR2,
      ptcontac IN VARCHAR2,
      pcpais IN NUMBER,
      pcprovin IN NUMBER,
      psperson IN NUMBER,
      pcpoblac IN NUMBER,
      pcpostal IN codpostal.cpostal%TYPE,   --3606 jdomingo 30/11/2007  canvi format codi postal
      ptlocali IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------
---------------------------------------------------------------
   FUNCTION f_insert_valoraciones(
      pnsinies IN NUMBER,
      pcgarant IN NUMBER,
      pfecha IN DATE,
      pivalora IN NUMBER,
      pipenali IN NUMBER,
      picaprisc IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

---------------------------------------------------------------
   FUNCTION f_insert_destinatarios(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;

 /*JFD 20080117 se vuel a cargar la función original con los cambios
      relacionados con las modificaciones de cuentas bancarias */
---------------------------------------------------------------
   FUNCTION f_insert_pago(
      pnsinies IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pdes IN NUMBER,
      pffecmov IN DATE,
      pctipdes IN NUMBER,
      psperson IN NUMBER,
      pctippag IN NUMBER,
      pcestpag IN NUMBER,
      pcforpag IN NUMBER,
      pccodcon IN NUMBER,
      pcmanual IN NUMBER,
      pcimpres IN NUMBER,
      pfefepag IN DATE,
      pfordpag IN DATE,
      pnmescon IN DATE,
      ptcoddoc IN NUMBER,
      pisinret IN NUMBER,
      piconret IN NUMBER,
      piretenc IN NUMBER,
      piimpiva IN NUMBER,
      ppretenc IN NUMBER,
      pcptotal IN NUMBER,
      pfimpres IN DATE,
      moneda IN NUMBER,
      pmuerto IN NUMBER,
      pirendi IN NUMBER,
      pireduc IN NUMBER,
      pimpsin IN NUMBER)
      RETURN NUMBER;

---------------------------------------------------------------
   FUNCTION f_insert_destinatario(
      pnsinies IN NUMBER,
      psperson IN NUMBER,
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      ppagdes IN NUMBER,
      pctipdes IN NUMBER,
      pcpagdes IN NUMBER,
      pivalora IN NUMBER,
      pcactpro IN NUMBER,
      pcbancar IN VARCHAR2,
      pcbancar2 IN VARCHAR2,
      pctipban IN NUMBER DEFAULT NULL,
      pctipban2 IN NUMBER DEFAULT NULL)
      RETURN NUMBER;
END pac_sin_insert;

/

  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_SIN_INSERT" TO "PROGRAMADORESCSI";
