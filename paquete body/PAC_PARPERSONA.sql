--------------------------------------------------------
--  DDL for Package Body PAC_PARPERSONA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_PARPERSONA" AS
   /******************************************************************************
        NOMBRE:       PAC_PARPERSONA
        PROPÓSITO:  Funciones para gestionar los parametros de personas

        REVISIONES:
        Ver        Fecha        Autor             Descripción
        ---------  ----------  ---------------  ------------------------------------
        1.0        30/01/2013   AMC                1. Creación del package.
        ******************************************************************************/
   FUNCTION f_get_detparam(
      pcodigo IN VARCHAR2,
      pcondicion IN VARCHAR2,
      pcidioma IN NUMBER,
      pnumerror IN OUT NUMBER)
      RETURN VARCHAR2 IS
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery := 'select det.cvalpar,det.tvalpar from detparam det ' || ' where det.cparam = '
                 || CHR(39) || pcodigo || CHR(39) || ' and det.cidioma =' || pcidioma;

      IF pcondicion IS NOT NULL THEN
         vsquery := vsquery || ' and upper(det.tvalpar) like' || CHR(39) || '%'
                    || UPPER(pcondicion) || '%' || CHR(39);
      END IF;

      vsquery := vsquery || ' order by det.cvalpar asc';
      RETURN vsquery;
   END f_get_detparam;
END pac_parpersona;

/

  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_PARPERSONA" TO "PROGRAMADORESCSI";
