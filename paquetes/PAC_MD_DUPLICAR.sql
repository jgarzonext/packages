--------------------------------------------------------
--  DDL for Package PAC_MD_DUPLICAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DUPLICAR" IS
/******************************************************************************
   NOMBRE:      PAC_MD_DUPLICAR
   PROPÓSITO:    Funcions per gestionar duplicació

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/06/2013   RCL                1. Creación del package.
   2.0
******************************************************************************/

   /*************************************************************************
     FUNCTION f_valida_dup_seguro
        Funció que valida si es possible duplicar una proposta
        param in     sseguroorig : número seguro
        param out     mensajes     : col·lecció de missatges
        return                 : 0 -> OK
                                  1 -> NO OK
   *************************************************************************/
   FUNCTION f_valida_dup_seguro(psseguroorig IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_duplicar;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DUPLICAR" TO "PROGRAMADORESCSI";
