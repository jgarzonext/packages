--------------------------------------------------------
--  DDL for Package PAC_IAX_BUREAU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_BUREAU" AS
/******************************************************************************
   NOMBRE:      PAC_IAX_BUREAU
   PROPOSITO:   OPERACIONES BUREAU

   REVISIONES:
   Ver        Fecha        Autor             Descripcion
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/03/2015   LROA              1. Creacion del package.
******************************************************************************/
FUNCTION f_get_bureau(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_genera_ficha(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_anula_ficha(pfbureau IN NUMBER , pnsuplem IN NUMBER , pnmovimi IN NUMBER,  mensajes OUT t_iax_mensajes)
      RETURN NUMBER;


   FUNCTION f_valida_pol(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_asocia_doc(psseguro IN NUMBER,  pnsuplem IN NUMBER , pnmovimi IN NUMBER,   piddoc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

END PAC_IAX_BUREAU;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BUREAU" TO "PROGRAMADORESCSI";
