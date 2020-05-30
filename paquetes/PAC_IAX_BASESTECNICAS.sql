--------------------------------------------------------
--  DDL for Package PAC_IAX_BASESTECNICAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_BASESTECNICAS" AS
/*****************************************************************************
   NAME:       PAC_IAX_BASESTECNICAS
   PURPOSE:    Funciones de obtención de las bases técnicas de una póliza

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        14/12/2009   APD             1. Creación del package.
******************************************************************************/

   --JRH 14/12/2009
    /*************************************************************************
       Obtiene un objeto del tipo OB_IAX_BASESTECNICAS con las bases técnicas
       param in psseguro  : póliza
       param in pnriesgo  : riesgo (si pnriesgo IS NULL, se mostraron todos)
       param in pnmovimi  : pnmovimi
       param out mensajes : mensajes de error
       return             : El objeto del tipo OB_IAX_BASESTECNICAS con los valores de esos importes
    *************************************************************************/
   FUNCTION f_obtbasestecnicas(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes,
      ptabla IN VARCHAR2 DEFAULT 'SEG')
      RETURN ob_iax_basestecnicas;
END pac_iax_basestecnicas;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_BASESTECNICAS" TO "PROGRAMADORESCSI";
