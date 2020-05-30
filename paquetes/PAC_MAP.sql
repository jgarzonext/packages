--------------------------------------------------------
--  DDL for Package PAC_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MAP" AUTHID CURRENT_USER IS
   /******************************************************************************
     NOMBRE:       PAC_MAP
     PROPÓSITO:  Package para gestionar los MAPS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     5.0        06/05/2009   ICV               5. Adaptación para IAX Bug.: 9940
   ******************************************************************************/
   vg_tipomap     map_cabecera.ttipomap%TYPE;
   vg_liniaini    VARCHAR2(32000);   -- Linia d'entrada amb els paràmetres necessaris
   vg_domdoc      xmldom.domdocument;   -- "Punter" al XML
   vg_idfitxer    UTL_FILE.file_type;   -- "Punter" al fitxer
   vg_node        xmldom.domnode;   -- "Punter" al node XML que estem tractant
   vg_linia       VARCHAR2(32000);   -- Linia del fitxer que estem tractant
   vg_debug       NUMBER(2);   -- Nivell de debug
   vg_deb_orden   NUMBER := 0;   -- Ordre de inserció en la taula debugger
   vg_deb_smap    NUMBER;   -- Smapead del map que estem debugant
   vg_numlin      NUMBER := 0;   -- Numero de la linia que estem llegint o escribint

   FUNCTION f_valor_linia(
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      ppos IN NUMBER,
      plong IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_valor_parametro(
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      pnorden NUMBER,
      pcmapead IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_map_replace(
      pcadena IN VARCHAR2,
      pcamp IN VARCHAR2,
      pliniapare IN VARCHAR2,
      pcmapead IN VARCHAR2,
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      psmapead IN VARCHAR2,
      ptag IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_cuenta_lineas(
      ptabla IN VARCHAR2,
      psepara IN VARCHAR2,
      pcmapead IN VARCHAR2,
      plinpare IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_ejecuta_select_map(
      pcmapead IN VARCHAR2,
      psepara IN VARCHAR2,
      ptabla IN VARCHAR2,
      pparam1 IN VARCHAR2 DEFAULT NULL,
      pparam2 IN VARCHAR2 DEFAULT NULL,
      pparam3 IN VARCHAR2 DEFAULT NULL,
      pparam4 IN VARCHAR2 DEFAULT NULL,
      pparam5 IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION f_proces_obtenir_parametres(
      pcmapead IN VARCHAR2,
      pcproces IN NUMBER,
      plinea IN VARCHAR2,
      pnorden IN NUMBER)
      RETURN VARCHAR2;

   FUNCTION f_resultado_proceso(pcmapead IN VARCHAR2, pcproces IN NUMBER, psproces IN NUMBER)
      RETURN NUMBER;

   FUNCTION buscartexto(p_node xmldom.domnode, p_tag IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_numfills(pnomfill IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_vgnode
      RETURN xmldom.domnode;

   FUNCTION f_vgdocument
      RETURN xmldom.domdocument;

   FUNCTION buscar_en_arbre_complert_valor(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pttagbuscat IN VARCHAR2,
      ptparebuscat IN VARCHAR2,
      ptatributbuscat IN VARCHAR2,
      pvalorbuscat IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION f_valor_tag_fill(ptagpare IN VARCHAR2, ptagfill IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE p_carga_parametros_xml(
      pdomdoc IN xmldom.domdocument,
      pliniaini IN VARCHAR2,
      pdebug IN NUMBER DEFAULT 0);

   PROCEDURE p_carga_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0);

   FUNCTION carga_map(pcmapead IN VARCHAR2, psmapead OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_carga_map(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0)
      RETURN VARCHAR2;

   FUNCTION f_obtener_xml_texto
      RETURN VARCHAR2;

   FUNCTION f_obtener_xml
      RETURN xmldom.domdocument;

   PROCEDURE p_genera_parametros_xml(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pdebug IN NUMBER DEFAULT 0);

   PROCEDURE p_genera_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0,
      pcconruta IN NUMBER DEFAULT NULL);

   FUNCTION genera_map(pcmapead IN VARCHAR2, psmapead OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_genera_map(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0,
      pcconruta IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2;

   PROCEDURE p_map_debug(
      psmapead IN VARCHAR2,
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      nordfill IN NUMBER,
      ptag IN VARCHAR2,
      pliniapare IN VARCHAR2,
      plinia IN VARCHAR2,
      pcamp IN VARCHAR2,
      pnveces IN NUMBER,
      ptcondicion IN VARCHAR2,
      pncondi IN NUMBER,
      ptabla IN NUMBER,
      ptipo IN NUMBER,
      pcadena IN VARCHAR2);

   FUNCTION f_extraccion(
      p_cmapead IN VARCHAR2,
      p_linea IN VARCHAR2,
      p_fich_in IN VARCHAR2 DEFAULT NULL,
      p_fich_out OUT VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION F_GET_NOMFICHERO
       Función que retornará la ruta y el fichero creado.
       param in PMAP: Id. del Map
       return             : Devolverá una cadena con la ruta y código del fichero generado.
   *************************************************************************/
   FUNCTION f_get_nomfichero(pmap IN VARCHAR2)
      RETURN VARCHAR2;

   /*************************************************************************
       FUNCTION F_get_tipomap
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       return             : Devolverá una numérico con el tipo de fichero que genera el map.
   *************************************************************************/
   FUNCTION f_get_tipomap(pmap IN VARCHAR2)
      RETURN NUMBER;

   /*************************************************************************
       FUNCTION F_get_ejereport
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       return             : Devolverá una numérico indicando si puede ejecutar reports.
                            0- No 1 - Si

       Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_ejereport(pmap IN VARCHAR2)
      RETURN NUMBER;

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
      pcmapead_salida OUT VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_mapcomodin(pcmapead IN VARCHAR2, pcmapcom IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_mapcomodin(pcmapead IN VARCHAR2, pcmapcom IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptsenten IN VARCHAR2,
      pcparam IN NUMBER,
      pcpragma IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_mapcabtratar(pcmapead IN VARCHAR2, pctabla IN NUMBER, pnveces IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      pcatributs IN NUMBER,
      pctablafills IN NUMBER,
      pnorden IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      pttag IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_mapdetalle(pcmapead IN VARCHAR2, pnorden IN NUMBER)
      RETURN NUMBER;

   FUNCTION f_set_maptabla(
      pctabla IN NUMBER,
      ptfrom IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pctabla_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_maptabla(pctabla IN NUMBER)
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
      ptsetwhere IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_del_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2)
      RETURN NUMBER;

   FUNCTION f_set_mapcondicion(
      pncondicion IN NUMBER,
      ptvalcond IN VARCHAR2,
      pnposcond IN NUMBER,
      pnlongcond IN NUMBER,
      pnordcond IN NUMBER,
      pctabla IN NUMBER,
      pncondicion_out OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_del_mapcondicion(pncondicion IN NUMBER)
      RETURN NUMBER;
END pac_map;

/

  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "PROGRAMADORESCSI";
