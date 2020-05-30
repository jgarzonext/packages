--------------------------------------------------------
--  DDL for Package Body PAC_PROPIO_CONF_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PROPIO_CONF_INT" IS
/******************************************************************************
   NOMBRE:    PAC_PROPIO_LCOL_INT
   PROP¿SITO: Funciones propias.

   REVISIONES:
   Ver        Fecha       Autor  Descripci¿n
   ---------  ----------  -----  ------------------------------------
   1.0        17/06/2011  DRA    0018790: LCOL001 - Alta empresa Liberty Colombia en DESA y TEST
   2.0        17/09/2012  MCA    0023708: LCOL: Ajuste para la interface de comisiones liquidada y producci¿n de comisiones
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   FUNCTION f_obtener_ttippag(pctiprec IN NUMBER)
      RETURN NUMBER IS
/***********************************************************************

***********************************************************************/
      vnpoliza       NUMBER;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      vcidioma       NUMBER;
   BEGIN
      RETURN 4;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN 4;
      WHEN OTHERS THEN
         RETURN 4;
   END f_obtener_ttippag;
END pac_propio_conf_int;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "PROGRAMADORESCSI";
