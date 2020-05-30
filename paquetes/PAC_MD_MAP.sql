--------------------------------------------------------
--  DDL for Package PAC_MD_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MD_MAP" IS
   /******************************************************************************
     NOMBRE:       PAC_MD_MAP
     PROPÓSITO:  Package para gestionar los MAPS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      FUNCTION f_get_datmap
      Función para devolver los campos descriptivos de un map.
      param in PMAP: Tipo carácter. Id. del map.
      param in out MENSAJES: Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
      return             : Retorna un sys_refcursor con los campos descriptivos de un map.
   *************************************************************************/
   FUNCTION f_get_datmap(pmap IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

    /*************************************************************************
      FUNCTION f_ejecuta
      Función que generará el fichero correspondiente del map.
      param in PMAP: Tipo carácter. Id. del map.
      param in PPARAM: Tipo carácter. Parámetros del map separados por '|'
      param in out MENSAJES: Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
      return             : Retorna una cadena de texto con el nombre y ruta del fichero ó con el código xml generado si todo ha ido bien.
                           Un nulo en caso contrario.

   Bug 14067 - 13/04/2010 - AMC - Se añade el parametro pejecutarep
   *************************************************************************/
   FUNCTION f_ejecuta(
      pmap IN VARCHAR2,
      pparam IN VARCHAR2,
      pejecutarep OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   /*************************************************************************
       FUNCTION F_get_tipomap
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       param in out MENSAJES: Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
       return             : Devolverá una numérico con el tipo de fichero que genera el map.
   *************************************************************************/
   FUNCTION f_get_tipomap(pmap IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
        FUNCTION f_ejecuta_multimap
        Función que generará el fichero correspondiente del map.
        param in PMAPS: Tipo carácter. Ids. de los maps. separados por '@'
        param in PPARAM: Tipo carácter. Parámetros del map separados por '|' mas '|' de la cuenta estan permitidos
        param out MENSAJES: Tipo t_iax_mensajes. Parámetro de Salida. Mensaje de error
        return             : Retorna una cadena de texto con los nombres y rutas de los ficheros generados separados por '@'
     *************************************************************************/
   FUNCTION f_ejecuta_multimap(
      pmaps IN VARCHAR2,
      pparam IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_get_arbol(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_listadomaps(
      ptiptrat IN VARCHAR2,
      ptipmap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_cabeceramap(
      pcmapead IN VARCHAR2,
      ptcomentario IN OUT VARCHAR2,
      ptipotrat IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_lsttablahijos(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_objeto(
      node_value IN VARCHAR2,
      node_label IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_mapdettratar(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_set_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcampo IN VARCHAR2,
      ptmascara IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      pctipcampo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_mapcabecera(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_mapcomodin(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_mapcabtratar(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_maptabla(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_mapcondicion(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_generar_listados(
      pmap IN VARCHAR2,
      pparam IN VARCHAR2,
      pejecutarep OUT NUMBER,
      vtimp OUT t_iax_impresion,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2;

   FUNCTION f_set_mapcabecera(
      pcmapead IN VARCHAR2,
      ptdesmap IN VARCHAR2,
      ptparpath IN VARCHAR2,
      pttipomap IN NUMBER,
      pcseparador IN VARCHAR2,
      pcmapcomodin IN VARCHAR2,
      pttipotrat IN VARCHAR2,
      ptcomentario IN VARCHAR2,
      ptparametros IN VARCHAR2,
      pcmanten IN NUMBER,
      pgenera_report IN NUMBER,
      pcmapead_salida OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptsenten IN VARCHAR2,
      pcparam IN NUMBER,
      pcpragma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      pcatributs IN NUMBER,
      pctablafills IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      pttag IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_maptabla(
      pctabla IN NUMBER,
      ptfrom IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pctabla_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_maptabla(pctabla IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pctipcampo IN VARCHAR2,
      ptmascara IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_set_mapcondicion(
      pncondicion IN NUMBER,
      ptvalcond IN VARCHAR2,
      pnposcond IN NUMBER,
      pnlongcond IN NUMBER,
      pnordcond IN NUMBER,
      pctabla IN NUMBER,
      pncondicion_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_del_mapcondicion(pncondicion IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER;

   FUNCTION f_get_unico_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_unico_mapcondicion(pncondicion IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;

   FUNCTION f_get_unico_maptabla(pctabla IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_md_map;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "PROGRAMADORESCSI";
