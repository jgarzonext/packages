--------------------------------------------------------
--  DDL for Package Body PAC_PARPNOCTURNOS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PARPNOCTURNOS" AS
/****************************************************************************
   NOMBRE:       PAC_PARPNOCTURNOS
   PROPÓSITO:  Contiene variables globales para utilizar en los diferentes procesos nocturnos

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ----------------------------------
   1.0        29/08/2013   AMC              1. Creación del package Bug 27986/151387

 ***************************************************************************/
   PROCEDURE p_inicializa IS
   BEGIN
      finicio := f_sysdate;
   END p_inicializa;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARPNOCTURNOS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARPNOCTURNOS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARPNOCTURNOS" TO "PROGRAMADORESCSI";
