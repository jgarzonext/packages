--------------------------------------------------------
--  DDL for Package PAC_NOMBRES_FICHEROS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_NOMBRES_FICHEROS" AUTHID CURRENT_USER IS
   /****************************************************************************
        NOMBRE:     PAC_NOMBRES_FICHEROS
        PROPÓSITO:  Especificación del paquete de las funciones para el nombramiento de ficheros

        REVISIONES:
        Ver        Fecha        Autor             Descripción
        ---------  ----------  ---------------  ----------------------------------
        1          17/03/2010   FAL             1.Creación
        2.0        14/11/2011   JMF             2. 0019999: LCOL_A001-Domis - Generacion de los diferentes formatos de fichero
     ****************************************************************************/

   -- BUG 0019999 - 14/11/2011 - JMF: Afegir pctipban
   FUNCTION f_nom_domici(
      psproces IN NUMBER,
      pcempres IN NUMBER,
      pcdoment IN NUMBER,
      pcdomsuc IN NUMBER,
      pctipban IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_nom_transf(pnremesa IN NUMBER, pccc IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_nom_tras_ent(psproces IN NUMBER, pordrefitxer IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_nom_tras_sal(psproces IN NUMBER, pordrefitxer IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION ff_ruta_fichero(pcempres IN NUMBER, pcfichero IN NUMBER, pctipo IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_ruta_fichero(
      pcempres IN NUMBER,
      pcfichero IN NUMBER,
      ptpath OUT VARCHAR2,
      ptpath_c OUT VARCHAR2)
      RETURN NUMBER;
END pac_nombres_ficheros;

/

  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_NOMBRES_FICHEROS" TO "PROGRAMADORESCSI";
