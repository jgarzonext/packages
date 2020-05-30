--------------------------------------------------------
--  DDL for Package PAC_MD_PREGUNTAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_PREGUNTAS" AUTHID CURRENT_USER IS
   /******************************************************************************
      NOMBRE:       PAC_PREGUNTAS
      PROPÓSITO:    Funciones para realizar acciones sobre las tablas de PREGUNTAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        22/07/2013  AMC                1. Creación del package.
   ******************************************************************************/
   FUNCTION f_es_plan(
      pcpregun IN preguntas.cpregun%TYPE,
      psproduc IN productos.sproduc%TYPE,
      pesplan OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_preguntas;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PREGUNTAS" TO "PROGRAMADORESCSI";
