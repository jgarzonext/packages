--------------------------------------------------------
--  DDL for Package Body PAC_IMAGENES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_IMAGENES" IS
-- *** 0007870 - Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados
  FUNCTION F_Get_Imagen    (pcimagen IN IMAGENES.CIMAGEN%TYPE, pcempres IN EMPRESAS.CEMPRES%TYPE) RETURN BLOB
  IS
   pimagen BLOB;
  	begin
  		pimagen := null;

  		select imagen
  		into pimagen
  		FROM IMAGENES
  		WHERE cimagen = pcimagen AND cempres = pcempres;

        return pimagen;

      EXCEPTION
      	  WHEN NO_DATA_FOUND THEN
      	  BEGIN
 	  	  		select imagen
        		into pimagen
  		      FROM IMAGENES
  		      WHERE cimagen = pcimagen AND cempres = 0;

            return pimagen;

      	  EXCEPTION
          WHEN OTHERS THEN
            RETURN NULL;

      	  END ;

          WHEN OTHERS THEN
            RETURN NULL;

 END F_Get_Imagen;
END pac_imagenes;

/

  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "PROGRAMADORESCSI";
