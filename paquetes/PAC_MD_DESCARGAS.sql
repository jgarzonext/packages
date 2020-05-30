--------------------------------------------------------
--  DDL for Package PAC_MD_DESCARGAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_DESCARGAS" AS
/******************************************************************************
   NOMBRE:       PAC_MD_DESCARGAS
   PROPOSITO: Funciones para gestionar descargas

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        29/08/2011  JMC              1. Creación del package.
******************************************************************************//***************************************************************************
      FUNCTION f_get_cias
      Función que retorna lista con las compañias que tiene configurada alguna
      descarga.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_cias(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/***************************************************************************
      FUNCTION f_get_descargas
      Función que retorna lista con las descargas, se puede filtrar por
      compañia y/o tipo de petición.
      param in pccompani : Código compañía
      param in pctippet : Tipo de petición (1-Descarga, 2-Confirmación, 3-Listado)
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_descargas(
      pccompani IN NUMBER,
      pctippet IN NUMBER,
      psseqdwl IN NUMBER,
      pctipfch IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/***************************************************************************
      FUNCTION f_get_ficheros
      Función que retorna lista con los ficheros de una descarga.
      param in psseqdwl : Secuencia de descarga.
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_get_ficheros(psseqdwl IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;

/***************************************************************************
      FUNCTION f_set_peticion
      Función que realiza la petición de descarga.
      param in pccoddes : Código descarga.
      param in psseqdwl : Secuencia de descarga (listado).
      param in pnnumfil : Número de fichero.
      param out psseqout : secuencia de descarga (descarga).
      param out mensajes : mensajes de error
      return             : ref cursor
   ***************************************************************************/
   FUNCTION f_set_peticion(
      psseqdwl IN NUMBER,
      pnnumfil IN NUMBER,
      psseqout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
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
      psseqout OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;
END pac_md_descargas;
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCARGAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCARGAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_DESCARGAS" TO "PROGRAMADORESCSI";
