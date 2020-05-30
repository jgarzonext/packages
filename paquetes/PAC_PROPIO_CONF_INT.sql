--------------------------------------------------------
--  DDL for Package PAC_PROPIO_CONF_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_CONF_INT" IS
/******************************************************************************
   NOMBRE:    PAC_PROPIO_LCOL_INT
   PROP¿SITO: Funciones propias.

   REVISIONES:
   Ver        Fecha       Autor  Descripci¿n
   ---------  ----------  -----  ------------------------------------
   1.0        17/06/2011  DRA    0018790: LCOL001 - Alta empresa Liberty Colombia en DESA y TEST
   2.0        17/09/2012  MCA    0023708: LCOL: Ajuste para la interface de comisiones liquidada y producci¿n de comisiones
******************************************************************************/
   FUNCTION f_obtener_ttippag(pctiprec IN NUMBER)
      RETURN NUMBER;
END pac_propio_conf_int;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_CONF_INT" TO "PROGRAMADORESCSI";
