--------------------------------------------------------
--  DDL for Package PAC_PROPIO_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_PROPIO_INT" IS
/******************************************************************************
   NOMBRE:     pac_propio_int
   PROPÓSITO:  Funciones propias

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        09/10/2009   DRA               1. 0010381: AGA001 - Creación entorno AGA
   2.0        22/02/2010   DRA               2. 0013318: ENSA001 - Creació de l'empresa ENSA a tots els entorns + Neteja de l'entorn de Validació
   3.0        01/03/2012   DRA               3. 0021467: AGM- Quitar en la descripción de riesgos el plan y al final se muestran caracteres raros
******************************************************************************/
   FUNCTION f_busca_agente_persona(psnip IN VARCHAR2, psinterf IN NUMBER, ocagente OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_busca_agente_poliza(psperson IN NUMBER, ocagente OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_obtener_concepto_cargo(psseguro IN NUMBER, pnrecibo IN NUMBER)
      RETURN VARCHAR2;

   -- BUG21467:DRA:01/03/2012:Inici
   FUNCTION f_pre_int_datos_host(
      datpol IN ob_int_datos_poliza,
      pregpol IN t_int_preg_poliza,
      pcmapead OUT VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_post_int(
      psinterf IN NUMBER,
      datpol IN ob_int_datos_poliza,
      pregpol IN t_int_preg_poliza,
      pcmapead IN VARCHAR2)
      RETURN NUMBER;
-- BUG21467:DRA:01/03/2012:Fi
END pac_propio_int;

/

  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PROPIO_INT" TO "PROGRAMADORESCSI";
