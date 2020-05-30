--------------------------------------------------------
--  DDL for Package PAC_DESCVALORES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DESCVALORES" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       PAC_DESCVALORES
   PROPÓSITO:    Funciones para retornar descripciones
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/04/2009   DCT             1.Creación paquete
   2.0        27/04/2010   AMC             2. Bug 14284 Se añade la función f_desgarant
   3.0        29/12/2010   JMP             3. Bug 16092: Se añade la función ff_desactivi
   4.0        24/01/2011   DRA             4. 0016576: AGA602 - Parametrització de reemborsaments per veterinaris
   5.0        06/06/2012   ETM             5.0021404: MDP - PER - Validación de documentos en función del tipo de sociedad
******************************************************************************/
   FUNCTION f_desctipocuenta(
      pctipban IN NUMBER,
      pcidioma IN NUMBER,
      pttipo OUT tipos_cuentades.ttipo%TYPE)
      RETURN NUMBER;

   /*******************************************************
      Función que devuelve la descripción de una garantía
      PARAM IN pcgarant : codigo de la garantía
      PARAM IN pcidioma : código de idioma
      PARAM OUT ptgarant : descripción de la garantía
      RETURN NUMBER

      Bug 14284 - 27/04/2010 - AMC
   *******************************************************/
   FUNCTION f_descgarant(pcgarant IN NUMBER, pcidioma IN NUMBER, ptgarant OUT VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION FF_DESACTIVI
   Devuelve la descripción de una actividad de un ramo
     param in p_cactivi : código de la actividad
     param in p_cramo   : código del ramo
     param in p_cidioma : código del idioma
     return             : la descripción de la actividad
*************************************************************************/
   FUNCTION ff_desactivi(p_cactivi IN NUMBER, p_cramo IN NUMBER, p_cidioma IN NUMBER)
      RETURN VARCHAR2;

   -- BUG16576:DRA:24/01/2011:Inici
   /*********************************************************************************
        F_DESACTO: Función que devuelve la descripción del acto.
   ********************************************************************************/
   FUNCTION ff_desacto(
      pcacto IN VARCHAR2,
      pcgarant IN NUMBER,
      pagr_salud IN VARCHAR2,
      pcidioma IN NUMBER)
      RETURN VARCHAR2;

-- BUG16576:DRA:24/01/2011:Inici
  --bug 21404--ETM-- 06/06/2012
   /*************************************************************************
       Recupera la descripción del tipo de sociedad
       param in pnnumide     : nubero de nif/cif
            return              : descripción del tipo de sociedad
    *************************************************************************/
   FUNCTION f_get_descsociedad(pnnumide IN VARCHAR2)
      RETURN VARCHAR2;
END pac_descvalores;

/

  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DESCVALORES" TO "PROGRAMADORESCSI";
