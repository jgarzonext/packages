--------------------------------------------------------
--  DDL for Function FS_POSICION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."FS_POSICION" (mens IN VARCHAR2,
    segm IN VARCHAR2, ord  IN NUMBER) RETURN NUMBER IS
  pos NUMBER;
BEGIN
   SELECT NVL(sum(longitud), 0)
   INTO pos
   FROM formatos_segmento
   WHERE mensaje = mens
   AND segmento = segm
   AND orden < ord;

   RETURN pos+1;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RETURN NULL;
  WHEN OTHERS THEN
     RETURN NULL;
END FS_POSICION;

 
 

/

  GRANT EXECUTE ON "AXIS"."FS_POSICION" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."FS_POSICION" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."FS_POSICION" TO "PROGRAMADORESCSI";
