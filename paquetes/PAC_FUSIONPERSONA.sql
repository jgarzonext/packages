--------------------------------------------------------
--  DDL for Package PAC_FUSIONPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_FUSIONPERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_MD_FUSIONPERSONA
      PROPÃ“SITO: Funciones para gestionar personas

      REVISIONES:
      Ver        Fecha        Autor             DescripciÃ³n
      ---------  ----------  ---------------  ------------------------------------
      1.0        20/02/2012  AMC               1. Creación del package.

   ******************************************************************************/

   /*************************************************************************
      Función que sirve para realizar fusionar des personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 20/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_fusion_per(
      pspersonori IN NUMBER,
      pcagenteori IN NUMBER,
      pspersondes IN NUMBER,
      pcagentedes IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Función que sirve para actualizar personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_actualiza_per(pspersonori IN NUMBER, pspersondes IN NUMBER)
      RETURN NUMBER;

   /*************************************************************************
      Función que sirve para actualizar el detalle personas

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_actualiza_detper(
      pspersonori IN NUMBER,
      pcagenteori IN NUMBER,
      pspersondes IN NUMBER,
      pcagentedes IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Función que devuelve el sperson de la segunda persona con el mismo nif

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_get_perduplicada(psperson IN NUMBER, pcagente IN NUMBER, psperson2 IN OUT NUMBER)
      RETURN NUMBER;

    /*************************************************************************
      Función que borra un persona

        retorno : 0 ok
                  1 error
     Bug 20945/1109228 - 07/03/2012 -  AMC
   *************************************************************************/
   FUNCTION f_del_persona(psperson IN NUMBER, pcagente IN NUMBER)
      RETURN NUMBER;
END pac_fusionpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_FUSIONPERSONA" TO "PROGRAMADORESCSI";
