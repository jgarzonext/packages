--------------------------------------------------------
--  DDL for Package PAC_MD_LIQUIDACION_TASA_X_MIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" 
AS
   /******************************************************************************
    NOMBRE:      PAC_MD_LIQUIDACION_TASA_X_MIL
    PROP¿SITO:   LIQUIDACION DE TASA POR MIL

    REVISIONES:
    Ver        Fecha        Autor             Descripci¿n
    ---------  ----------  ---------------  ------------------------------------
    1.0        21/12/2016   FFO                1. Creaci¿n del package.*/


     /*************************************************************************/


   FUNCTION LIQUIDACION_TASA_X_MIL(
      pcmodo                IN       NUMBER,
      pcempresa             IN       NUMBER,
      pcagente              IN       NUMBER,
      pcsucursal            IN       NUMBER,
      pfdesde               IN       DATE,
      pfhasta               IN       DATE,
      mensajes              OUT   t_iax_mensajes
   ) RETURN NUMBER;
END PAC_MD_LIQUIDACION_TASA_X_MIL;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LIQUIDACION_TASA_X_MIL" TO "PROGRAMADORESCSI";
