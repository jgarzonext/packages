--------------------------------------------------------
--  DDL for Package PAC_MAP2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_MAP2" AUTHID CURRENT_USER IS
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
      pdebug IN NUMBER DEFAULT 0);

   FUNCTION genera_map(pcmapead IN VARCHAR2, psmapead OUT NUMBER)
      RETURN NUMBER;

   FUNCTION f_genera_map(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0)
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

/*************************************************************************
      Función para crear ficheros xml
      param in pcmapead     : Codigo del map
      param in pparam : Parametros del map
      param in pnomfitxer: Nombre del fichero
      param in pdebug: Indica si debuga
      param out p_fgenerado: Nombre del fichero generado
      return             : 0 todo ha sido correcto
                           1 ha habido un error

      Bug 17373 - 08/02/2011 - AMC
   *************************************************************************/
   FUNCTION f_genera_xml(
      pcmapead IN VARCHAR2,
      pparam IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0,
      p_fgenerado OUT VARCHAR2)
      RETURN NUMBER;
END;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "PROGRAMADORESCSI";
