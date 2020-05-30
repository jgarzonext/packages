--------------------------------------------------------
--  DDL for Package PAC_PROPIO_AGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_AGE" IS
/******************************************************************************
   NOMBRE:     PAC_PROPIO_AGE
   PROPÓSITO:  Package que contiene las funciones propias de cada instalación.

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/11/2012   AMC               1. Creación del package Bug 24514.
   2.0        28/01/2013   ICG               2. Bug 27598 Se crea función f_valida_regfiscal.

******************************************************************************/

   /******************************************************************************
       FUNCION: f_get_retencion
       Funcion que devielve el tipo de retención segun la letra del cif.
       Param in psperson
       Param in pcidioma
       Param out pcidioma
       Param out pcidioma
       Retorno 0- ok 1-ko

       Bug 24514/128686 - 15/11/2012 - AMC
   ******************************************************************************/
   FUNCTION f_get_retencion(
      psperson IN NUMBER,
      pcidioma IN NUMBER,
      pcempres IN NUMBER,
      pcretenc OUT NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER;

   /******************************************************************************
       FUNCION: f_valida_regfiscal
       Funcion que valida si el tipo de iva y regimen fiscal son introducidos correctamente.
       Param in pcempres
       Param in pcidioma
       Param in psperson
       Param in pctipage
       Param in pctipiva
       Param in pctipint
       Param out
       Retorno 0- ok 1-ko

       Bug 27598-135742 - 28/01/2013 - ICG
   ******************************************************************************/
   FUNCTION f_valida_regfiscal(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      psperson IN NUMBER,
      pctipage IN NUMBER,
      pctipiva IN NUMBER,
      pctipint IN NUMBER,
      pmensaje OUT VARCHAR2)
      RETURN NUMBER;
END pac_propio_age;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_AGE" TO "AXIS00";
