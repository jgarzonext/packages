--------------------------------------------------------
--  DDL for Package PAC_IAX_BONFRAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_BONFRAN" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_BONFRAN
   PROP¿SITO:  Permite modificar deducibles - franquicias

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
   1.0        04/10/2016   IGIL              1. Creaci¿n del package

   *************************************************************************/
   FUNCTION f_set_deducible(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 IN NUMBER,
      pimpvalor1 IN NUMBER,
      pcimpmin IN NUMBER,
      pimpmin IN NUMBER,
      pcimpmax IN NUMBER,
      pimpmax IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
   FUNCTION f_validar_deducible_manual(
      pcgrup IN NUMBER,
      pcsubgrup IN NUMBER,
      pcversion IN NUMBER,
      pcnivel IN NUMBER,
      pcvalor1 OUT NUMBER,
      pimpvalor1 OUT NUMBER,
      pcimpmin OUT NUMBER,
      pimpmin OUT NUMBER,
      pcimpmax OUT NUMBER,
      pimpmax OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_bonfran;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BONFRAN" TO "PROGRAMADORESCSI";
