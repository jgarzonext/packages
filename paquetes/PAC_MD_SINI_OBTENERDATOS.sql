--------------------------------------------------------
--  DDL for Package PAC_MD_SINI_OBTENERDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SINI_OBTENERDATOS" AS
/******************************************************************************
   NOMBRE:      PAC_MD_SINI_OBTENERDATOS
   PROPÓSITO: Funciones para la gestión de siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        27/12/2007   JAS                1. Creación del package.
******************************************************************************/

   /***********************************************************************
      Recupera los datos generales de un determinado siniestro, sin completar los subojetos PAGOS, DOCUMENTACION, ETC
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la información general del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_datsiniestro(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_siniestros;

   /***********************************************************************
      Recupera las valoraciones de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : T_IAX_GARANSINI con la información de las valoraciones del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_valorasini(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_garansini;

   /***********************************************************************
      Recupera los datos de los pagos de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : T_IAX_PAGOS con la información de los pagos del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_pagos(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN t_iax_pagosini;

   /***********************************************************************
      Recupera los datos de un determinado siniestro
      param in  pnsinies  : número de siniestro
      param out mensajes  : mensajes de error
      return              : OB_IAX_SINIESTROS con la información del siniestro
                            NULL -> Se ha producido un error
   ***********************************************************************/
   FUNCTION f_get_siniestro(pnsinies IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN ob_iax_siniestros;
END pac_md_sini_obtenerdatos;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_OBTENERDATOS" TO "PROGRAMADORESCSI";
