--------------------------------------------------------
--  DDL for Function F_BORRAR_PRESTAMO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_BORRAR_PRESTAMO" (pctapres IN VARCHAR2) RETURN NUMBER IS
 -- funcion que borra los contratos que no están en prestamoseg
BEGIN
 -- borramos los capitales
 DELETE PRESTCAPITALES
 WHERE ctapres = pctapres;
 --lo cuadros de amortización
 DELETE PRESTCUADRO
  WHERE ctapres = pctapres;
 -- los titulares
 DELETE PRESTTITULARES
  WHERE ctapres = pctapres;
 -- el prestamo
 DELETE PRESTAMOS
  WHERE ctapres = pctapres;
RETURN 0;
EXCEPTION
 WHEN OTHERS THEN
   RETURN 151475;-- Error al borrar el prestamo.
END F_borrar_prestamo;

 
 

/

  GRANT EXECUTE ON "AXIS"."F_BORRAR_PRESTAMO" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_BORRAR_PRESTAMO" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_BORRAR_PRESTAMO" TO "PROGRAMADORESCSI";
