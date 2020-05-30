--------------------------------------------------------
--  DDL for Package PAC_MD_PRODUCCION_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PRODUCCION_FINV" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_PRODUCCION_FINV
      PROPÓSITO:   Funciones para la producción en segunda capa de productos financieros
                   de inversión.

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/03/2008   RSC               1. Creación del package.
   ******************************************************************************/

   /*************************************************************************
      Graba en el objeto poliza la distribución seleccionada
      param in pcmodelo  : Código de modelo de inversión
      param in ppoliza   : Objeto póliza
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_grabar_modeloinvfinv(
      pcmodelo IN NUMBER,
      ppoliza IN OUT ob_iax_poliza,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_produccion_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "PROGRAMADORESCSI";
