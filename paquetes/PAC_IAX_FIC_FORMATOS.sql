--------------------------------------------------------
--  DDL for Package PAC_IAX_FIC_FORMATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_FIC_FORMATOS" AS
/******************************************************************************
   NOMBRE:       PAC_IAX_FIC_FORMATOS
   PROPÓSITO: Nuevo paquete de la capa IAX que tendrá las funciones para la gestión de formatos del gestor de informes.
              Controlar todos posibles errores con PAC_IOBJ_MNSAJES.P_TRATARMENSAJE


   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/06/2009   JMG                1. Creación del package.
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Función que ejecuta los formatos de un gestor
      del modelo del parámetro
      param in  pcempres : código empresa
      param in  ptgestor : fecha de contabilidad inicial
      param in ptformat  : mensajes de error
      param in  panio : código empresa
      param in  pmes : fecha de contabilidad inicial
      param in  pmes_dia  : mensajes de error
      param in  pchk_genera : código empresa
      param in  pchkescribe : fecha de contabilidad inicial
      param in out mensajes  : mensajes de error
   *************************************************************************/
   FUNCTION f_genera_formatos(
      pcempres IN NUMBER,
      ptgestor IN VARCHAR2,
      ptformat IN VARCHAR2,
      panio IN NUMBER,
      pmes IN VARCHAR2,
      pmes_dia IN VARCHAR2,
      pchk_genera IN VARCHAR2,
      pchkescribe VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_iax_fic_formatos;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_FORMATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_FORMATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_FIC_FORMATOS" TO "PROGRAMADORESCSI";
