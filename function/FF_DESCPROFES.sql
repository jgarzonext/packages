--------------------------------------------------------
--  DDL for Function FF_DESCPROFES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FF_DESCPROFES" (
   pcprofes IN VARCHAR2,
   pcidioma IN NUMBER,
   pcempresa IN NUMBER,   -- Bug 25456/133727 - 16/01/2013 - AMC
   plongitud IN NUMBER DEFAULT 100)
   RETURN VARCHAR2 AUTHID CURRENT_USER IS
   ptprofes       profesiones.tprofes%TYPE;
/***********************************************************************
 Descripción de una profesión

***********************************************************************/
BEGIN
   IF plongitud < 1 THEN
      ptprofes := '';
      RETURN ptprofes;
   END IF;

--
   IF pcprofes IS NULL THEN
      ptprofes := '';
      RETURN ptprofes;
   END IF;

--
    -- Bug 25456/133727 - 16/01/2013 - AMC
   IF NVL(pac_parametros.f_parempresa_n(pcempresa, 'PER_PROFESION'), 0) = 0 THEN
      SELECT SUBSTR(tprofes, 1, plongitud)
        INTO ptprofes
        FROM profesiones
       WHERE cprofes = pcprofes
         AND cidioma = pcidioma;
   ELSE
      SELECT d.tprofes
        INTO ptprofes
        FROM codprofesionprod c, detprofesionprod d
       WHERE c.cprofes = pcprofes
         AND c.cprofes = d.cprofes
         AND d.cidioma = pcidioma;
   END IF;

   -- Fi Bug 25456/133727 - 16/01/2013 - AMC

   --
   RETURN ptprofes;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      ptprofes := '';
      RETURN ptprofes;
   WHEN OTHERS THEN
      ptprofes := '';
      RETURN ptprofes;
END;

/

  GRANT EXECUTE ON "AXIS"."FF_DESCPROFES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FF_DESCPROFES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FF_DESCPROFES" TO "PROGRAMADORESCSI";
