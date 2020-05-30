--------------------------------------------------------
--  DDL for Package PAC_DESCARGAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_DESCARGAS" AUTHID CURRENT_USER IS
/******************************************************************************
   NOMBRE:       PAC_INT_ONLINE

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/08/2011   JMC             1. Creación del package.
******************************************************************************/

   /***************************************************************************
      FUNCTION f_set_peticion
      Función que inicia el proceso de descarga.
         param in  pccoddes:     Código de descarga.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_set_peticion(
      pccoddes IN NUMBER,
      psseqdwl IN NUMBER DEFAULT NULL,
      pnnumfil IN NUMBER DEFAULT NULL,
      psseqout OUT NUMBER)
      RETURN NUMBER;

   /***************************************************************************
      FUNCTION f_es_descarg
      Función que inicia si un fichero se encuentra en situación de ser
      descargado.
         param in  ptreforg:     Nombre del fichero.
         return:                0-No, 1-Si
   ***************************************************************************/
   FUNCTION f_es_descarg(ptreforg IN VARCHAR2)
      RETURN NUMBER;

   /***************************************************************************
      FUNCTION f_set_peticion_from_lst
      Función que realiza la descarga de un fichero que se encuentra en la peticion
      de listado de fiheros. (Esta función de llamara desde la pantalla).

         param in  psseqdwl:     Secuencia de descarga (listado).
         param in  pnnumfil:     Número fichero de la descarga (listado).
         param out  psseqout:    Secuencia de la descarga del fichero.
         return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_set_peticion_from_lst(
      psseqdwl IN NUMBER DEFAULT NULL,
      pnnumfil IN NUMBER DEFAULT NULL,
      psseqout OUT NUMBER)
      RETURN NUMBER;

   /***************************************************************************
      FUNCTION F_DESCARGA_FICHEROS
      Función que mirara en los hosts de las compañias si hay ficheros de
      pólizas o recibos (dependiendo del parámetro) por descargar . En caso de
      haberlos y que los distintos procesos se realicen correctamente, los
      descargara, los confirmara y los procesara para cargarlos en iAXIS.
      param in  pccompani:     Código compañia.
      param in  pctipfch:      Tipo fichero 1-póliza 2-Recibo.
      return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_descarga_ficheros(pccompani IN NUMBER, pctipfch IN NUMBER, psproces IN NUMBER)
      RETURN NUMBER;

   /***************************************************************************
      FUNCTION F_SET_PETICION_LST_FILES
      Función que realizara la petición de listado de ficheros para una compañia
      y tipo de listado. Esta función se lanzara desde la pantalla.
      param in  pccompani:     Código compañia.
      param in  pctipfch:      Tipo fichero 1-póliza 2-Recibo.
      param in  psseqout       Número de secuencia de descarga.
      return:                0-OK, <>0-Error
   ***************************************************************************/
   FUNCTION f_set_peticion_lst_files(
      pccompani IN NUMBER,
      pctipfch IN NUMBER,
      psseqout OUT NUMBER)
      RETURN NUMBER;
END pac_descargas;
 

/

  GRANT EXECUTE ON "AXIS"."PAC_DESCARGAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_DESCARGAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_DESCARGAS" TO "PROGRAMADORESCSI";
