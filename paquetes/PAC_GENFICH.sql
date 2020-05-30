--------------------------------------------------------
--  DDL for Package PAC_GENFICH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_GENFICH" AS
   /******************************************************************************
      NOMBRE:       PAC_GENFICH
      PROPÓSITO: Generación de ficheros

      REVISIONES:
      Ver        Fecha       Autor  Descripción
      ---------  ----------  -----  ------------------------------------
      1.0        22/07/2011  APD    Creación del package. (Bug 18843)
   ******************************************************************************/

   /*************************************************************************
      FUNCTION f_llistat_comissions
      return               : 0 OK - 1 KO
   *************************************************************************/
   FUNCTION f_llistat_comissions(
      p_cempres IN NUMBER,
      p_cagente IN NUMBER,
      p_sproliq IN NUMBER,
      p_cidioma IN NUMBER,
      p_fecini IN DATE,
      p_fecfin IN DATE,
      p_tipoproceso IN VARCHAR2,
      p_rutafich OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_llistat_impostos(p_cempres IN NUMBER, p_periodo IN DATE, p_rutafich OUT VARCHAR2)
      RETURN NUMBER;
END pac_genfich;

/

  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_GENFICH" TO "PROGRAMADORESCSI";
