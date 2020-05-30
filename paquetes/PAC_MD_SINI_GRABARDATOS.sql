--------------------------------------------------------
--  DDL for Package PAC_MD_SINI_GRABARDATOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_SINI_GRABARDATOS" AS
/******************************************************************************
   NOMBRE:     PAC_MD_SINI_GRABARDATOS
   PROPÓSITO:  Funciones para la gestión de siniestros (Grabar objetos a base de datos)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        02/01/2008   JAS                1. Creación del package.
******************************************************************************/


    /***********************************************************************
       Graba en la base de datos, los datos del siniestro guardado en la variable global del paquete
       param out pObSini   : Objeto con la información del siniestro que se debe dar de alta.
       param out onsinies  : número de siniestro asignado en el alta de siniestro
       param out mensajes  : mensajes de error
       return              : 1 -> Todo correcto
                             0 -> Se ha producido un error
    ***********************************************************************/
	FUNCTION F_AltaSiniestro (
        pObSini     IN      OB_IAX_SINIESTROS,
        onsinies    OUT     NUMBER,
        mensajes    IN OUT  T_IAX_MENSAJES
    )
    RETURN NUMBER;


END PAC_MD_SINI_GRABARDATOS;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_SINI_GRABARDATOS" TO "PROGRAMADORESCSI";
