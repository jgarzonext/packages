--------------------------------------------------------
--  DDL for Package PAC_IAX_FUSIONPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_FUSIONPERSONA" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_FUSIONPERSONA
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
   FUNCTION f_fusionar_per(
      psperson1 IN NUMBER,
      pcagente1 IN NUMBER,
      psperson2 IN NUMBER,
      pcagente2 IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

    /*************************************************************************
      Función que devuelve el sperson de la segunda persona con el mismo nif

        retorno : 0 ok
                  1 error
     Bug 20945/104041 - 21/02/2012 -  AMC
   *************************************************************************/
   FUNCTION f_get_perduplicada(
      psperson IN NUMBER,
      pcagente IN NUMBER,
      psperson2 OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_fusionpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FUSIONPERSONA" TO "PROGRAMADORESCSI";
