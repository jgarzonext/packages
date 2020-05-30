--------------------------------------------------------
--  DDL for Package PAC_COMCONVENIOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_COMCONVENIOS" AS
   /******************************************************************************
     NOMBRE:     pac_comconvenios
     PROPÓSITO:  Package para gestionar los convenios de sobrecomisión

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        11/02/2012   FAL             0025988: LCOL_C004: Realizar desarrollo Convenio Liberty web
    ******************************************************************************/
   FUNCTION f_val_convenio(
      pcmodo IN NUMBER,
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE)
      RETURN NUMBER;

   FUNCTION f_val_prod_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_val_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      ppcomisi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_alta_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_alta_prod_convenio(pcempres IN NUMBER, pscomconv IN NUMBER, psproduc IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_alta_modcom_convenio(
      pcempres IN NUMBER,
      pscomconv IN NUMBER,
      pcmodcom IN NUMBER,
      pfinivig IN DATE,
      ppcomisi IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_convenio_fec(
      pcempres IN NUMBER,
      pcmodo IN NUMBER,
      pscomconv IN NUMBER,
      ptconvenio IN VARCHAR2,
      pcagente IN NUMBER,
      pfinivig IN DATE,
      pffinvig IN DATE,
      piimporte IN NUMBER,
      pfanul IN DATE,
      pfinivig_out OUT DATE)
      RETURN NUMBER;

   FUNCTION f_sobrecomision_convenio(
      pnrecibo IN NUMBER,
      pcmodcom IN NUMBER,
      pcmodo IN VARCHAR2,
      ptipomovimiento IN NUMBER,
      pcomisi OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_get_next_conv
      RETURN NUMBER;
END pac_comconvenios;

/

  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_COMCONVENIOS" TO "PROGRAMADORESCSI";
