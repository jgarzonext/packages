--------------------------------------------------------
--  DDL for Package PAC_MD_AYUDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_AYUDA" AS
/*************************************************************************
       Para la ayuda de AXIS, se encargará de de retornar el contenido de la
       tabla AXIS_AYUDA
       param in  AYUDACURSOR    : Cursor con todos los valores de la tabla
                                   AXIS_AYUDA
       param out mensajes       : mensajes de error
       return    NUMBER         : 0 -> Finaliza correctamente.
                                : 1 -> Finaliza con error.
    *************************************************************************/
   FUNCTION f_get_ayuda(ayudacursor OUT sys_refcursor, mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_ayuda(
      cidioma IN NUMBER,
      cform IN VARCHAR2,
      ayudacursor OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_ayuda;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_AYUDA" TO "PROGRAMADORESCSI";
