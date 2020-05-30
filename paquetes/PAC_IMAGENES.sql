--------------------------------------------------------
--  DDL for Package PAC_IMAGENES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IMAGENES" AUTHID CURRENT_USER IS
	-- *** 0007870 - Inicializar atributos contextuales en nuevas sesiones y parametrización de las imágenes para los listados
 FUNCTION F_Get_Imagen    (pcimagen IN IMAGENES.CIMAGEN%TYPE, pcempres IN EMPRESAS.CEMPRES%TYPE) RETURN BLOB;
END pac_imagenes;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IMAGENES" TO "PROGRAMADORESCSI";
