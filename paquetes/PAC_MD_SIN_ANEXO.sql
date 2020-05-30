--------------------------------------------------------
--  DDL for Package PAC_MD_SIN_ANEXO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SIN_ANEXO" AS
/******************************************************************************
   NOMBRE:     PAC_MD_SIN_ANEXO
   PROP¿SITO:  Funciones para la gesti¿n de siniestros

   REVISIONES:
   Ver        Fecha        Autor             Descripci¿n
   ---------  ----------  ---------------  ------------------------------------
*/
    FUNCTION f_get_datos_sin(
      psprofes IN NUMBER,
      pnnumide IN VARCHAR2,
      ptnombre IN VARCHAR2,
      pnsinies IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_sin_anexo;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SIN_ANEXO" TO "PROGRAMADORESCSI";
