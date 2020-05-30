--------------------------------------------------------
--  DDL for Package Body PAC_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MAP" IS
   /******************************************************************************
     NOMBRE:       PAC_MAP
     PROPÓSITO:  Package para gestionar los MAPS

     REVISIONES:
     Ver        Fecha        Autor             Descripción
     ---------  ----------  ---------------  ------------------------------------
     5.0        06/05/2009   ICV                5. Adaptación para IAX Bug.: 9940
     6.0        07/10/2009   JGM                6. Se añade la gestión par el nuevo TIPO DE MAP - DINAMICO -
     7.0        08/01/2010   NMM                7. 12600: CRE999 - Incidències consulta simulació desglós comptabilitat
     8.0        10/02/2010   DRA                8. 0012913: CRE200 - Mejoras en Transferencias
     9.0        27/05/2010   ICV                9. 0014701: CEM - Cambio en la ruta del fichero de Contabilidad
    10.0        14/12/2010   JMF               10. 0016529 CRT003 - Análisis listados
    11.0        07/02/2012   JTS               11. 20905: LCOL897 - INCIDENCIA IMPRESIONS
    12.0        16/01/2013   NMM               12.25376: CALI - Revisión de incidencias implantación del módulo de traspasos
   ******************************************************************************/
   FUNCTION f_valor_linia(
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      ppos IN NUMBER,
      plong IN NUMBER)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 18/03/04
-- Funció per extraure el valor d'una cadena
-----------------------------------------------------------------
      vvalor         VARCHAR2(4000);
   BEGIN
      IF ppos IS NULL
         OR plong IS NULL THEN
         vvalor := plinia;
      ELSIF psepara IS NULL THEN
         vvalor := SUBSTR(plinia, ppos, plong);
      ELSE
         IF INSTR(plinia, psepara, 1) <> 0 THEN
            IF ppos = 0
               AND INSTR(plinia, psepara, 1) = 1 THEN
               vvalor := NULL;
            ELSE
               IF INSTR(plinia, psepara, 2 - ppos, plong + ppos) = 0 THEN
                  --estem a l'últim troç
                  vvalor := SUBSTR(plinia, INSTR(plinia, psepara, ppos, plong) + ppos,
                                   ABS(LENGTH(plinia) + 1
                                       - INSTR(plinia, psepara, ppos, plong) - 1));
               ELSE
                  --estem a un troç intermig
                  vvalor := SUBSTR(plinia, INSTR(plinia, psepara, ppos, plong) + ppos,
                                   ABS(INSTR(plinia, psepara, 2 - ppos, plong + ppos)
                                       - INSTR(plinia, psepara, ppos, plong) - 1));
               END IF;
            END IF;
         ELSE
            vvalor := plinia;
         END IF;
      END IF;

      RETURN vvalor;
   END f_valor_linia;

   FUNCTION f_valor_parametro(
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      pnorden NUMBER,
      pcmapead IN VARCHAR2)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 18/03/04
-- Funció per extraure el valor d'una cadena
-- Pasem la linia pq. l'utilitzem per poder fer AMBOS (en una GENERACIO
--  sempre serà la linia inicial)
-----------------------------------------------------------------
      vvalor         VARCHAR2(4000);
      vpos           NUMBER;
      vlong          NUMBER;
   BEGIN
      SELECT nposicion, nlongitud
        INTO vpos, vlong
        FROM map_detalle d, map_comodin c
       WHERE norden = pnorden
         AND d.cmapead = c.cmapcom
         AND c.cmapead = pcmapead;

      vvalor := f_valor_linia(psepara, plinia, vpos, vlong);
      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN plinia;
   END f_valor_parametro;

   FUNCTION f_map_replace(
      pcadena IN VARCHAR2,
      pcamp IN VARCHAR2,
      pliniapare IN VARCHAR2,
      pcmapead IN VARCHAR2,
      psepara IN VARCHAR2,
      plinia IN VARCHAR2,
      psmapead IN VARCHAR2,
      ptag IN VARCHAR2)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 18/11/2004
-- Realitza el replace de totes les paraules reservades
-----------------------------------------------------------------
      vresul         VARCHAR2(32000);
   BEGIN
      vresul :=
         REPLACE
            (REPLACE
                (REPLACE
                    (REPLACE
                        (REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(pcadena, '#debug',
                                                                         vg_debug),
                                                                 '#numlin', vg_numlin),
                                                         '#nomtag', ptag),
                                                 '#smapead', psmapead),
                                         '#lineaini', vg_liniaini),
                                 '#campo', pcamp),
                         '#separa', psepara),
                     '#cmapead', pcmapead),
                 '#lineapare', pliniapare),
             '#lineaactual', REPLACE(plinia, '''', '''||chr(39)||'''));
      --hem substituit la cometa de la lineaactual pel caràcter corresponent
      -- en aquest punt, ja que aquesta funció es crida sempre que s'està a punt
      --  de executar una select
      RETURN vresul;
   END f_map_replace;

   FUNCTION f_cuenta_lineas(
      ptabla IN VARCHAR2,
      psepara IN VARCHAR2,
      pcmapead IN VARCHAR2,
      plinpare IN VARCHAR2)
      RETURN NUMBER IS
-----------------------------------------------------------------
-- EAS, CPM 14/07/2004
-- Compta el numero de registres que retorna una select de map_tabla
-----------------------------------------------------------------
      nlinias        NUMBER;
      vselect        VARCHAR2(4000);
   BEGIN
      SELECT f_map_replace(tfrom, NULL, plinpare, pcmapead, psepara, NULL, NULL, NULL)
        INTO vselect
        FROM map_tabla
       WHERE ctabla = ptabla;

      vselect := ' begin select count(linea) into :nlinias from ' || vselect || '; end;';

      EXECUTE IMMEDIATE vselect
                  USING OUT nlinias;

      p_map_debug(NULL, pcmapead, NULL, NULL, NULL, plinpare, SUBSTR(vselect, 1, 1000), NULL,
                  NULL, NULL, NULL, ptabla, 6, 'f_cuenta_lineas: ' || nlinias);
      RETURN nlinias;
   END f_cuenta_lineas;

   FUNCTION f_ejecuta_select_map(
      pcmapead IN VARCHAR2,
      psepara IN VARCHAR2,
      ptabla IN VARCHAR2,
      pparam1 IN VARCHAR2 DEFAULT NULL,
      pparam2 IN VARCHAR2 DEFAULT NULL,
      pparam3 IN VARCHAR2 DEFAULT NULL,
      pparam4 IN VARCHAR2 DEFAULT NULL,
      pparam5 IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM  03/11/2005
-- Executa una select de map_tabla i torna el resultat. La select només pot tornar un
--   registre, ja que la seva funció és formar part de una altra select (com si fos
--   una subselect) i unir-la amb "joins" a través dels paràmetres.
--  Es necessari incloure la taula que s'executarà amb aquesta funció a
--   map_cab_tratar perquè el script genera_ins_map tingui en compte aquesta taula.
-----------------------------------------------------------------
      vselect        VARCHAR2(32000);
      resultat       VARCHAR2(1000);
   BEGIN
      SELECT pac_map.f_map_replace(tfrom, NULL, NULL, pcmapead, psepara, NULL, NULL, NULL)
        INTO vselect
        FROM map_tabla
       WHERE ctabla = ptabla;

      vselect := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(vselect, '#param1', pparam1),
                                                 '#param2', pparam2),
                                         '#param3', pparam3),
                                 '#param4', pparam4),
                         '#param5', pparam5);
      vselect := ' begin select linea into :resultat from ' || vselect || '; end;';

      EXECUTE IMMEDIATE vselect
                  USING OUT resultat;

      p_map_debug(NULL, pcmapead, NULL, NULL, NULL, NULL, SUBSTR(vselect, 1, 1000), NULL, NULL,
                  NULL, NULL, ptabla, 6, SUBSTR('f_ejecuta_select_map: ' || resultat, 1, 500));
      RETURN resultat;
   END f_ejecuta_select_map;

   FUNCTION f_proces_obtenir_parametres(
      pcmapead IN VARCHAR2,
      pcproces IN NUMBER,
      plinea IN VARCHAR2,
      pnorden IN NUMBER)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 16/12/2004
-- Per un cproces i un norden del procès, llegeix de la taula PROCESMAP_DET
--   les posicions dels paràmetres i els obté de plinia.
-----------------------------------------------------------------
      vparam         VARCHAR2(250);
      vcadenaini     VARCHAR2(30);
      vposicio       VARCHAR2(10);
      i              NUMBER;
      j              NUMBER;
   BEGIN
      SELECT tparametros
        INTO vcadenaini
        FROM procesmap_det
       WHERE cproces = pcproces
         AND norden = pnorden;

      p_map_debug(NULL, pcmapead, NULL, NULL, NULL, NULL, plinea, NULL, pnorden, NULL,
                  pcproces, NULL, 6,
                  SUBSTR('f_proces_obtenir_parametres:' || 'cadena recuperada ' || vcadenaini,
                         1, 500));

      IF vcadenaini IS NULL THEN
         vparam := '';
      ELSE
         vposicio := pac_map.f_valor_linia('|', vcadenaini, 0, 1);

         IF INSTR(vposicio, '#') = 0 THEN
            -- és un paràmetre
            vparam := pac_map.f_valor_parametro('|', plinea, 200 + vposicio, pcmapead);
         ELSE
            -- és una constant
            vparam := REPLACE(vposicio, '#', '');
         END IF;

         i := INSTR(vcadenaini, '|');
         j := 1;

         WHILE i > 0 LOOP
            vposicio := pac_map.f_valor_linia('|', vcadenaini, 1, j);

            IF INSTR(vposicio, '#') = 0 THEN
               -- és un paràmetre
               vparam := vparam || '@'
                         || pac_map.f_valor_parametro('|', plinea, 200 + vposicio, pcmapead);
            ELSE
               -- és una constant
               vparam := vparam || '@' || REPLACE(vposicio, '#', '');
            END IF;

            j := j + 1;
            i := INSTR(vcadenaini, '|', i + 1);
         END LOOP;
      END IF;

      p_map_debug(NULL, pcmapead, NULL, NULL, NULL, NULL, plinea, NULL, pnorden, NULL,
                  pcproces, NULL, 6,
                  SUBSTR('f_proces_obtenir_parametres:' || 'cadena resultat ' || vparam, 1,
                         500));

      IF vparam IS NOT NULL THEN
         vparam := '@' || vparam;
      END IF;

      RETURN(vparam);
   END f_proces_obtenir_parametres;

   FUNCTION f_resultado_proceso(pcmapead IN VARCHAR2, pcproces IN NUMBER, psproces IN NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------
-- EAS, CPM 16/12/2004
-- Per un cproces i un norden del procès, llegeix de la taula PROCESMAP_DET
--   les posicions dels paràmetres i els obté de plinia.
-----------------------------------------------------------------
      vresultat      NUMBER;
      vtparfrom      procesmap.tparfrom%TYPE;
      vtdescrip      procesmap.tdescrip%TYPE;
      vto            VARCHAR2(100);
      vfrom          VARCHAR2(100);
      vtext          VARCHAR2(500);
   BEGIN
      SELECT COUNT('a')
        INTO vresultat
        FROM procesoslin
       WHERE sproces = psproces
         AND npronum <> 0
         AND NVL(ctiplin, 0) = 1;

      IF vresultat <> 0 THEN
         SELECT tparfrom, tdescrip
           INTO vtparfrom, vtdescrip
           FROM procesmap
          WHERE cproces = pcproces;

         IF vtparfrom IS NOT NULL THEN
            vto := f_parinstalacion_t(vtparfrom);
            vfrom := f_parinstalacion_t('MAILERRFRO');
            vtext := 'Error en el proceso ' || vtdescrip || ' con sproces: ' || psproces;
            p_enviar_correo(vfrom, vto, vfrom, vto, 'Error en un proceso', vtext);
         END IF;
      END IF;

      RETURN vresultat;
   END f_resultado_proceso;

-------------------------------------------------------------
-- Buscar el valor del texto del primer nodo con tag p_tag
-------------------------------------------------------------
   FUNCTION buscartexto(p_node xmldom.domnode, p_tag IN VARCHAR2)
      RETURN VARCHAR2 IS
      nl             xmldom.domnodelist;
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
   BEGIN
      nl := xmldom.getelementsbytagname(xmldom.makeelement(p_node), p_tag);

      IF xmldom.getlength(nl) <> 0 THEN
         mynode := xmldom.item(nl, 0);
         mynode := xmldom.getfirstchild(mynode);

         IF NOT xmldom.isnull(mynode) THEN
            p_map_debug(NULL, NULL, NULL, NULL, p_tag, NULL, NULL, NULL, NULL, NULL, NULL,
                        NULL, 6,
                        SUBSTR('buscarTexto: node missatge ' || xmldom.getnodename(p_node)
                               || 'valor trobat ' || xmldom.getnodevalue(mynode),
                               1, 500));
            RETURN xmldom.getnodevalue(mynode);
         ELSE
            RETURN NULL;
         END IF;
      ELSE
         RETURN NULL;
      END IF;
   END buscartexto;

   --retorna el número de fills del node actual
   FUNCTION f_numfills(pnomfill IN VARCHAR2)
      RETURN NUMBER IS
   BEGIN
      IF pnomfill IS NULL THEN
         RETURN xmldom.getlength(xmldom.getchildnodes(vg_node));
      ELSE
         RETURN xmldom.getlength(xmldom.getchildrenbytagname(xmldom.makeelement(vg_node),
                                                             pnomfill));
      END IF;
   END f_numfills;

   FUNCTION f_vgnode
      RETURN xmldom.domnode IS
   BEGIN
      RETURN vg_node;
   END f_vgnode;

   FUNCTION f_vgdocument
      RETURN xmldom.domdocument IS
   BEGIN
      RETURN vg_domdoc;
   END f_vgdocument;

   FUNCTION buscar_en_arbre_parcial_valor(
      pelement IN xmldom.domelement,
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pttagbuscat IN VARCHAR2,
      ptparebuscat IN VARCHAR2,
      ptatributbuscat IN VARCHAR2,
      pvalorbuscat IN VARCHAR2)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- CPM, EAS 29/09/05
-- Funció que busca dins l'arbre XML rebut, un tag concret (pttagbuscat) o un atribut
--   concret (ptatributbuscat). Si busquem l'atribut, hem d'informar el tagbuscat amb
--   el valor del tag en el que està.
-- A més se li pot dir quin tag és el pare del tag buscat
--   (ptparebuscat), i d'aquesta manera només dóna per bona la recerca si troba
--   el un tagPare-tag que coincideixi.
-- A més se li pot dir quin valor estem buscant de forma que va recorrent-se el xml
--   fins que troba el valorbuscat com a valor del tagbuscat (o atributbuscat) fill
--   del parebuscat.
--  Si no troba res retorna un null. Sino retorna el primer valor que trobi
--    que cumpleixi les condicions explicades.
-----------------------------------------------------------------
      nl             xmldom.domnodelist;
      mynode         xmldom.domnode;
      myelement      xmldom.domelement;
      mytextnode     xmldom.domtext;
      vnoupare       xmldom.domelement;
      velement       xmldom.domelement;
      velementatribut xmldom.domelement;
      vvalor         VARCHAR2(32000);

      CURSOR c_fills IS
         SELECT DISTINCT LEVEL lv, x.tpare, x.ttag
                    FROM map_xml x, map_comodin c
                   WHERE x.cmapead = c.cmapcom
                     AND c.cmapead = pcmapead
                     AND tpare =(NVL(ptpare, '0'))
              START WITH tpare = '0'
              CONNECT BY PRIOR x.ttag = x.tpare
                     AND PRIOR x.cmapead = x.cmapead
                ORDER BY LEVEL;
   BEGIN
      p_map_debug(NULL, pcmapead, ptpare, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, 6,
                  SUBSTR('buscar_en_arbre_parcial_valor. ptagbuscat: ' || pttagbuscat
                         || ', ptparebuscat: ' || ptparebuscat || ', ptatributbuscat: '
                         || ptatributbuscat || ', pvalorbuscat: ' || pvalorbuscat,
                         1, 500));
      velement := pelement;

      FOR vfill IN c_fills LOOP
         IF ptatributbuscat IS NULL THEN
            nl := xmldom.getchildrenbytagname(velement, vfill.ttag);

            IF xmldom.getlength(nl) <> 0 THEN
               FOR i IN 0 ..(xmldom.getlength(nl) - 1) LOOP
                  IF vfill.ttag = pttagbuscat
                     AND(ptpare = ptparebuscat
                         OR ptparebuscat IS NULL) THEN
                     -- hem trobat la fulla que buscavem
                     mynode := xmldom.item(nl, i);
                     mynode := xmldom.getfirstchild(mynode);

                     IF NOT xmldom.isnull(mynode) THEN
                        vvalor := xmldom.getnodevalue(mynode);

                        IF pvalorbuscat IS NULL
                           OR pvalorbuscat = vvalor THEN
                           --no busquem cap valor concret o el valor que busquem és el que hem trobat
                           RETURN vvalor;
                        ELSE
                           --esborrem el valor trobat ja que no ens serveix
                           vvalor := NULL;
                        END IF;
                     ELSE
                        --la fulla que buscavem està buida
                        IF pvalorbuscat = 'NULO' THEN
                           vvalor := 'NULO';
                        END IF;

                        RETURN vvalor;
                     END IF;
                  ELSE   --del if del element buscat
                     --encara no hem trobat la fulla que buscavem -> hem de tornar a cridar
                     --  la funció amb el element que sí que hem trobat al xml com a pare
                     vnoupare := xmldom.makeelement(xmldom.item(nl, i));
                     vvalor := buscar_en_arbre_parcial_valor(vnoupare, pcmapead, vfill.ttag,
                                                             pttagbuscat, ptparebuscat,
                                                             ptatributbuscat, pvalorbuscat);

                     IF vvalor IS NOT NULL THEN
                        RETURN vvalor;
                     ELSE
                        vvalor := NULL;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         ELSE   --de l'atribut
            IF vfill.ttag = pttagbuscat
               AND(ptpare = ptparebuscat
                   OR ptparebuscat IS NULL) THEN
                -- hem trobat la fulla que buscavem
               --estem buscant el valor d'un atribut
               nl := xmldom.getchildrenbytagname(velement, vfill.ttag);

               FOR i IN 0 ..(xmldom.getlength(nl) - 1) LOOP
                  velementatribut := xmldom.makeelement(xmldom.item(nl, i));
                  vvalor := xmldom.getattribute(velementatribut, ptatributbuscat);

                  IF pvalorbuscat IS NULL
                     OR pvalorbuscat = vvalor THEN
                     --no busquem cap valor concret o el valor que busquem és el que hem trobat
                     RETURN vvalor;
                  ELSIF pvalorbuscat = 'NULO'
                        AND vvalor IS NULL THEN
                     vvalor := 'NULO';
                     RETURN vvalor;
                  END IF;
               END LOOP;
            ELSE
               --encara no hem trobat la fulla que buscavem -> hem de tornar a cridar
               --  la funció amb el element que sí que hem trobat al xml com a pare
               nl := xmldom.getchildrenbytagname(velement, vfill.ttag);

               IF xmldom.getlength(nl) <> 0 THEN
                  vnoupare := xmldom.makeelement(xmldom.item(nl, 0));
                  vvalor := buscar_en_arbre_parcial_valor(vnoupare, pcmapead, vfill.ttag,
                                                          pttagbuscat, ptparebuscat,
                                                          ptatributbuscat, pvalorbuscat);

                  IF vvalor IS NOT NULL THEN
                     RETURN vvalor;
                  ELSE
                     vvalor := NULL;
                  END IF;
               END IF;   --d'haver trobat el tag al xml rebut
            END IF;
         END IF;
      END LOOP;

      p_map_debug(NULL, pcmapead, ptpare, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  6,
                  SUBSTR('final de buscar_en_arbre_parcial_valor. vvalor: ' || vvalor
                         || ', ptagbuscat: ' || pttagbuscat || ', ptparebuscat: '
                         || ptparebuscat || ', ptatributbuscat: ' || ptatributbuscat
                         || ', pvalorbuscat: ' || pvalorbuscat,
                         1, 500));
      RETURN vvalor;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_mnttablas.buscar_en_arbre_parcial_valor', 1,
                     'Error al when others de buscar en arbre ', SQLERRM);
         RETURN NULL;
   END buscar_en_arbre_parcial_valor;

   FUNCTION buscar_en_arbre_complert_valor(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pttagbuscat IN VARCHAR2,
      ptparebuscat IN VARCHAR2,
      ptatributbuscat IN VARCHAR2,
      pvalorbuscat IN VARCHAR2)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- CPM, EAS 29/09/05
-- Funció que serveix per ser cridada des d'una select del map, ja que no
--   és possible cridar directament a la funció Buscar_En_arbre_Parcial_Valor
--   degut a que té com a paràmetre un xmldom.domElement. Al cridar a
--   aquesta funció se li passa per paràmetre tot l'arbre XML rebut.
-----------------------------------------------------------------
      velement       xmldom.domelement;
   BEGIN
      velement := xmldom.makeelement(xmldom.makenode(vg_domdoc));
      RETURN buscar_en_arbre_parcial_valor(velement, pcmapead, ptpare, pttagbuscat,
                                           ptparebuscat, ptatributbuscat, pvalorbuscat);
   END buscar_en_arbre_complert_valor;

   FUNCTION f_valor_tag_fill(ptagpare IN VARCHAR2, ptagfill IN VARCHAR2)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 14/07/2004
-- Retorna el valor del tag fill amb nom ptagfill
-----------------------------------------------------------------
      vvalor         VARCHAR2(250);
      nl             xmldom.domnodelist;
      nodelist       xmldom.domnodelist;
      mynode         xmldom.domnode;
      vnodepare      xmldom.domnode;
   BEGIN
      p_map_debug(NULL, NULL, ptagpare, NULL, ptagfill, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, 6,
                  SUBSTR('f_valor_tag_fill:' || 'Nom tag avi ' || xmldom.getnodename(vg_node),
                         1, 500));

      IF ptagpare IS NOT NULL THEN
         vvalor := xmldom.getattribute(xmldom.makeelement(vg_node), ptagfill);

         IF vvalor IS NULL THEN
            nodelist := xmldom.getchildnodes(vg_node);

            FOR i IN 0 ..(xmldom.getlength(nodelist) - 1) LOOP
               --busquem dins els fills del node entrat per paràmetre
               vnodepare := xmldom.item(nodelist, i);
               p_map_debug(NULL, NULL, ptagpare, NULL, ptagfill, NULL, NULL, NULL, NULL, NULL,
                           NULL, NULL, 6,
                           SUBSTR('f_valor_tag_fill:' || 'Valor del fill del pare ='
                                  || xmldom.getnodename(vnodepare),
                                  1, 500));

               IF xmldom.getnodename(vnodepare) = ptagpare THEN
                  EXIT;
               END IF;
            END LOOP;
         END IF;
      ELSE
         vnodepare := vg_node;
      END IF;

      IF vvalor IS NULL THEN
         vvalor := xmldom.getattribute(xmldom.makeelement(vnodepare), ptagfill);

         IF vvalor IS NULL THEN
            nl := xmldom.getchildrenbytagname(xmldom.makeelement(vnodepare), ptagfill);

            IF xmldom.getlength(nl) <> 0 THEN
               --hem trobat l'element
               mynode := xmldom.item(nl, 0);
               mynode := xmldom.getfirstchild(mynode);

               IF NOT xmldom.isnull(mynode) THEN
                  vvalor := xmldom.getnodevalue(mynode);
                  p_map_debug(NULL, NULL, ptagpare, NULL, ptagfill, NULL, NULL, NULL, NULL,
                              NULL, NULL, NULL, 6,
                              SUBSTR('f_valor_tag_fill:' || 'Valor del fill =' || vvalor, 1,
                                     500));
               END IF;
            END IF;
         END IF;
      END IF;

      RETURN vvalor;
   END f_valor_tag_fill;

-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
--------
   FUNCTION f_condicion_valida_unica(
      ptipo IN NUMBER,
      pncondi IN NUMBER,
      plinia IN VARCHAR2,
      psepara IN VARCHAR2,
      pcmapead IN VARCHAR2,
      psmapead IN NUMBER)
      RETURN BOOLEAN IS
-----------------------------------------------------------------
-- EAS, CPM 05/04/04
-- Funció que valida una condició. Es recupera el valor de la condició que només serà
--   certa si el valor del tag coincideix.
-- El valor a cumplir pot ser una constant (estarà al camp tvalcond de la taula
--   MAP_CONDICIONES) o bé entrarà per paràmetre (tindrem la posició i
--   la longitud a la taula MAP_DETALLE per el pncondi).
-----------------------------------------------------------------
      CURSOR c_pares(ptag IN VARCHAR2) IS
         SELECT NULL tatribu, ptag tpare, x.tpare tavi
           FROM map_xml x, map_comodin c
          WHERE x.cmapead = c.cmapcom
            AND c.cmapead = pcmapead
            AND x.ctablafills IS NULL
            AND x.ttag = ptag
            AND NVL(x.catributs, -1) <> 1
         UNION
         SELECT ptag tatribu, x1.ttag tpare, x1.tpare tavi
           FROM map_xml x1, map_comodin c
          WHERE x1.cmapead = c.cmapcom
            AND c.cmapead = pcmapead
            AND x1.ctablafills IS NULL
            AND x1.ttag IN(SELECT x.tpare
                             FROM map_xml x
                            WHERE x.cmapead = c.cmapcom
                              AND x.ctablafills IS NULL
                              AND x.ttag = ptag
                              AND x.catributs = 1);

      vtag           map_detalle.ttag%TYPE;
      vposvalor      map_detalle.nposicion%TYPE;
      vlongvalor     map_detalle.nlongitud%TYPE;
      vvaloractual   VARCHAR2(4000);
      vvaloracumplir map_condicion.tvalcond%TYPE;
      vposcond       map_condicion.nposcond%TYPE;
      vlongcond      map_condicion.nlongcond%TYPE;
      vselcondi      VARCHAR2(32000);
      velement       xmldom.domelement;
      nerror         NUMBER;

      TYPE t_cursor IS REF CURSOR;

      c_condicio     t_cursor;

      FUNCTION buscar_en_arbre(
         pelement IN xmldom.domelement,
         pcmapead IN VARCHAR2,
         ptpare IN VARCHAR2,
         pvalorbuscat IN VARCHAR2,
         pttagbuscat IN VARCHAR2,
         ptparebuscat IN VARCHAR2,
         ptatributbuscat IN VARCHAR2,
         pvalor IN OUT VARCHAR2)
         RETURN NUMBER IS
-----------------------------------------------------------------
-- CPM, EAS 08/04/04
-- Funció que comproba que existeix un tag que té com a nom pttagbuscat i que és fill
--   del tag ptparebuscat si aquest paràmetre no és null (si ho és pot ser fill de
--   qualsevol). A més ha de tenir el mateix valor que el paràmetre pvalor.
--  És una funció recursiva.
--  Si troba el tag buscat retorna el seu valor al paràmetre pvalor, sino a pvalor
--   retorna un null.
-----------------------------------------------------------------
         nl             xmldom.domnodelist;
         mynode         xmldom.domnode;
         myelement      xmldom.domelement;
         mytextnode     xmldom.domtext;
         velementatribut xmldom.domelement;
         vnoupare       xmldom.domelement;
         nerror         NUMBER;

         CURSOR c_fills IS
            SELECT DISTINCT LEVEL lv, x.tpare, x.ttag
                       FROM map_xml x, map_comodin c
                      WHERE x.cmapead = c.cmapcom
                        AND c.cmapead = pcmapead
                        AND tpare =(NVL(ptpare, '0'))
                 START WITH tpare = '0'
                 CONNECT BY PRIOR x.ttag = x.tpare
                   ORDER BY LEVEL;
      BEGIN
         FOR vfill IN c_fills LOOP
            IF ptatributbuscat IS NULL THEN
               nl := xmldom.getelementsbytagname(pelement, vfill.ttag);

               IF xmldom.getlength(nl) <> 0 THEN
                  IF vfill.ttag = pttagbuscat
                     AND(ptpare = ptparebuscat
                         OR ptparebuscat IS NULL) THEN
                     -- hem trobat la fulla que buscavem
                     mynode := xmldom.item(nl, 0);
                     mynode := xmldom.getfirstchild(mynode);

                     IF NOT xmldom.isnull(mynode) THEN
                        pvalor := xmldom.getnodevalue(mynode);
                        RETURN 0;
                     ELSE
                        --la fulla que buscavem està buida
                        IF pvalorbuscat = 'NULO' THEN
                            --busquem un null i l'hem trobat.
                           --Canviem el valor de pvalor per la comparació posterior
                           pvalor := 'NULO';
                        END IF;

                        RETURN 0;
                     END IF;
                  ELSE   --del if del element buscat
                     --encara no hem trobat la fulla que buscavem -> hem de tornar a cridar
                     --  la funció amb el element que sí que hem trobat al xml com a pare
                     vnoupare := xmldom.makeelement(xmldom.item(nl, 0));
                     nerror := buscar_en_arbre(vnoupare, pcmapead, vfill.ttag, pvalorbuscat,
                                               pttagbuscat, ptparebuscat, ptatributbuscat,
                                               pvalor);

                     IF pvalor = pvalorbuscat
                        AND pvalor IS NOT NULL THEN
                        RETURN 0;
                     ELSE
                        pvalor := NULL;
                     END IF;
                  END IF;
               END IF;
            ELSE   --de l'atribut
               IF vfill.ttag = pttagbuscat
                  AND(ptpare = ptparebuscat
                      OR ptparebuscat IS NULL) THEN
                   -- hem trobat la fulla que buscavem
                  --estem buscant el valor d'un atribut
                  nl := xmldom.getchildrenbytagname(pelement, vfill.ttag);

                  IF xmldom.getlength(nl) <> 0 THEN
                     velementatribut := xmldom.makeelement(xmldom.item(nl, 0));
                     pvalor := xmldom.getattribute(velementatribut, ptatributbuscat);

                     IF pvalorbuscat = 'NULO'
                        AND pvalor IS NULL THEN
                        --busquem un null i l'hem trobat.
                        --Canviem el valor de pvalor per la comparació posterior
                        pvalor := 'NULO';
                     END IF;

                     RETURN 0;
                  END IF;
               ELSE
                  --encara no hem trobat la fulla que buscavem -> hem de tornar a cridar
                  --  la funció amb el element que sí que hem trobat al xml com a pare
                  nl := xmldom.getelementsbytagname(pelement, vfill.ttag);

                  IF xmldom.getlength(nl) <> 0 THEN
                     vnoupare := xmldom.makeelement(xmldom.item(nl, 0));
                     nerror := buscar_en_arbre(vnoupare, pcmapead, vfill.ttag, pvalorbuscat,
                                               pttagbuscat, ptparebuscat, ptatributbuscat,
                                               pvalor);

                     IF pvalor = pvalorbuscat
                        AND pvalor IS NOT NULL THEN
                        RETURN 0;
                     ELSE
                        pvalor := NULL;
                     END IF;
                  END IF;   --d'haver trobat el tag al xml rebut
               END IF;
            END IF;
         END LOOP;

         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151637;
      END;
   BEGIN
      IF pncondi <> 0 THEN
         --recuperem el valor del tag de la condició
         BEGIN
            SELECT DISTINCT tc.tvalcond, tc.nposcond, tc.nlongcond, det.nposicion,
                            det.nlongitud, det.ttag,
                            DECODE(tt.ctabla,
                                   NULL, NULL,
                                   'SELECT '
                                   || DECODE(tt.ctabla,
                                             0, '''' || plinia || ''' linea',
                                             'linea') || ' FROM '
                                   || f_map_replace(tt.tfrom, NULL, plinia, pcmapead, psepara,
                                                    vg_linia, psmapead, NULL)) selcondi
                       INTO vvaloracumplir, vposcond, vlongcond,   -- per trobar el valorACumplir
                                                                vposvalor,
                            vlongvalor, vtag,
                            vselcondi   --per trobar el valorActual
                       FROM map_condicion tc, map_tabla tt, map_detalle det, map_comodin c
                      WHERE tt.ctabla(+) = tc.ctabla
                        AND det.norden(+) = tc.nordcond
                        AND(det.cmapead = c.cmapcom
                            OR det.cmapead IS NULL)   -- Per si es una taula (no tenim detall)
                        AND c.cmapead = pcmapead
                        AND tc.ncondicion = ABS(pncondi);
         EXCEPTION
            WHEN OTHERS THEN
               p_map_debug(psmapead, pcmapead, NULL, NULL, NULL, plinia, NULL, NULL, NULL,
                           pncondi, NULL, NULL, 5,
                           SUBSTR('ERROR en valida: ' || pncondi || '->' || SQLERRM, 1, 500));
               p_tab_error(f_sysdate, f_user, 'pac_MAP.f_condicion_valida', 1,
                           'Error al buscar la condición ' || pncondi || '-' || vg_deb_orden,
                           SQLERRM);
               RETURN FALSE;
         END;

         IF vvaloracumplir IS NULL THEN
            -- el valor no era una constant, per tant es un "troç" de la linia de paràmetres
            -- El separador de la linia de paràmetres sempre es '|'
            vvaloracumplir := f_valor_linia('|', vg_liniaini, vposcond, vlongcond);
         END IF;

         p_map_debug(NULL, pcmapead, NULL, NULL, NULL, plinia, vg_linia, NULL, NULL, NULL,
                     pncondi, NULL, 5,
                     SUBSTR('Tipo:' || ptipo || ';tag:' || vtag || ';select:' || vselcondi, 1,
                            500));

         IF vselcondi IS NULL THEN
            IF ptipo = 3
               AND vtag IS NOT NULL THEN
               -- Recuperem el valor del tag trobat des del node que estem tractant.
               vvaloractual := buscartexto(xmldom.makenode(vg_domdoc), vtag);

               IF vvaloractual IS NULL THEN
                  -- si no el trobem com a fill del tag pare (el tag entrat per paràmetre)
                  --   el busquem des de l'inici del xml per tots aquells pares-fills que estiguin
                  --   definits a la taula MAP_XML a aquest efecte
                  velement := xmldom.makeelement(xmldom.makenode(vg_domdoc));

                  FOR cp IN c_pares(vtag) LOOP
                     vvaloractual := buscar_en_arbre_parcial_valor(velement, pcmapead, 0,
                                                                   cp.tpare, cp.tavi,
                                                                   cp.tatribu, vvaloracumplir);

                     IF vvaloractual IS NOT NULL THEN
                        EXIT;
                     ELSE
                        IF vvaloracumplir = 'NULO' THEN
                           --busquem un NULL i no em trobat el tag --> considerem que es compleix la condició
                           vvaloractual := 'NULO';
                        END IF;
                     END IF;
                  END LOOP;
               END IF;
            ELSE
               --hem de buscar el valor que actual que hem de comparar amb el vvalorACumplir
               --  ja que el valor no és una constant. La posició dins línia del fitxer
               --  la indiquen els camps nposicio i nlongitud de la taula MAP_detalle
               --  per la condició
               IF vposvalor IS NOT NULL THEN
                  vvaloractual := f_valor_linia(psepara, plinia, vposvalor, vlongvalor);
               ELSE
                  -- Busquem el valor actual a la linia de paràmetres
                  vvaloractual := f_valor_linia('|', vg_liniaini, vposcond, vlongcond);
               END IF;
            END IF;
         ELSE
            OPEN c_condicio FOR vselcondi;

            FETCH c_condicio
             INTO vvaloractual;
         END IF;

         p_map_debug(NULL, pcmapead, NULL, NULL, NULL, plinia, vg_linia, NULL, NULL, NULL,
                     pncondi, NULL, 5,
                     SUBSTR('Condició a cumplir ' || vvaloracumplir || ' i valor actual '
                            || vvaloractual || ' separador ' || psepara,
                            1, 500));

         IF vvaloractual = vvaloracumplir
            AND pncondi > 0 THEN
            RETURN TRUE;
         ELSIF (vvaloractual <> vvaloracumplir
                OR vvaloractual IS NULL)
               AND pncondi < 0 THEN   -- Neguem la condició
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      ELSE
         RETURN TRUE;
      END IF;
   END f_condicion_valida_unica;

   FUNCTION f_condicion_valida(
      ptipo IN NUMBER,
      pvcondi IN VARCHAR2,
      plinia IN VARCHAR2,
      psepara IN VARCHAR2,
      pcmapead IN VARCHAR2,
      psmapead IN NUMBER)
      RETURN BOOLEAN IS
-----------------------------------------------------------------
-- EAS, CPM 29/07/04
-- Funció que valida una condició complexa (amb AND, OR, ..).
--  Crida a la función f_condicion_valida_unica
-----------------------------------------------------------------
      car            VARCHAR2(1);
      exp_condi      VARCHAR2(2000);
      exp_resul      VARCHAR2(2000);
      i              INTEGER;
      ii             INTEGER;
      token          VARCHAR2(40);
      num_resul      NUMBER := -2;
      num_aux        NUMBER;

      FUNCTION f_continuar
         RETURN NUMBER IS
-----------------------------------------------------------------
-- EAS, CPM 11/10/05
-- Funció que valida el final d'una condició complexa (amb AND, OR, ..).
--  Retorna 0: Si no s'ha de seguir i el resultat es FALSE
--          1: Si no s'ha de seguir i el resultat es TRUE
--          -1: Si s'ha de seguir
-----------------------------------------------------------------
         exp_condi2     VARCHAR2(2000);
         exp_resul2     VARCHAR2(2000);
         num_valid      NUMBER;
      BEGIN
         p_map_debug(psmapead, pcmapead, NULL, NULL, NULL, plinia, NULL, NULL, NULL, pvcondi,
                     NULL, NULL, 6,
                     SUBSTR('Entro en continuar: ' || pvcondi || ' => ' || exp_condi, 1, 500));
         exp_condi2 := exp_condi;
         exp_condi2 := REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(exp_condi2), '-', '1-'), '#',
                                               '1'),
                                       '$', '0'),
                               ';;');

         BEGIN
            exp_resul2 := ' begin :num_valid := ' || exp_condi2 || ' ; end;';

            EXECUTE IMMEDIATE exp_resul2
                        USING OUT num_valid;
         EXCEPTION
            WHEN OTHERS THEN
               BEGIN
                  exp_resul2 := ' begin SELECT ' || exp_condi2
                                || ' INTO :num_valid FROM DUAL; end;';

                  EXECUTE IMMEDIATE exp_resul2
                              USING OUT num_valid;
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, 'pac_map.f_continuar', 1, SQLCODE,
                                 SQLERRM);
                     RETURN -1;
               END;
         END;

         p_map_debug(psmapead, pcmapead, NULL, NULL, NULL, plinia, NULL, NULL, NULL, pvcondi,
                     NULL, NULL, 6, SUBSTR('Surto de continuar: ' || num_valid, 1, 500));

         IF num_valid = 0 THEN
            RETURN num_valid;
         ELSE
            RETURN -1;
         END IF;
      END f_continuar;
   BEGIN
      IF pvcondi = '0' THEN
         RETURN TRUE;
      ELSE
         exp_condi := REPLACE(REPLACE(UPPER(RTRIM(pvcondi)), 'AND', '*'), 'OR', '+') || ';;';
         p_map_debug(psmapead, pcmapead, NULL, NULL, NULL, plinia, NULL, NULL, NULL, pvcondi,
                     NULL, NULL, 5,
                     SUBSTR('Entro en valida: ' || pvcondi || ' => ' || exp_condi, 1, 500));
         i := 1;
         ii := 1;
         token := NULL;

         WHILE i < LENGTH(exp_condi) LOOP
            car := SUBSTR(exp_condi, i, 1);

            IF car IN(' ', '+', '-', '*', '#',   -- Símbol auxiliar para indicar un 1
                                              '$',   -- Símbol auxiliar para indicar un 0
                                                  ';', '(', ')') THEN
               IF token IS NOT NULL THEN
                  num_aux := TO_NUMBER(token);

                  IF f_condicion_valida_unica(ptipo, num_aux, plinia, psepara, pcmapead,
                                              psmapead) THEN
                     -- Es válida, per tant un 1
                     exp_condi := REPLACE(exp_condi, token, LPAD('#', LENGTH(token), ' '));
                  ELSE
                     exp_condi := REPLACE(exp_condi, token, LPAD('$', LENGTH(token), ' '));
                  END IF;

                  num_resul := f_continuar;

                  IF num_resul <> -1 THEN
                     EXIT;
                  END IF;
               END IF;

               token := NULL;
            ELSE
               token := token || car;
            END IF;

            i := i + 1;
            ii := ii + 1;
         END LOOP;

         IF num_resul = -1 THEN
            exp_condi := REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(exp_condi), '-', '1-'), '#',
                                                 '1'),
                                         '$', '0'),
                                 ';;');

            BEGIN
               exp_resul := ' begin :num_resul := ' || exp_condi || ' ; end;';

               EXECUTE IMMEDIATE exp_resul
                           USING OUT num_resul;
            EXCEPTION
               WHEN OTHERS THEN
                  BEGIN
                     exp_resul := ' begin SELECT ' || exp_condi
                                  || ' INTO :num_resul FROM DUAL; end;';

                     EXECUTE IMMEDIATE exp_resul
                                 USING OUT num_resul;
                  EXCEPTION
                     WHEN OTHERS THEN
                        p_tab_error(f_sysdate, f_user, 'pac_map.f_continuar', 1, SQLCODE,
                                    SQLERRM);
                        RETURN FALSE;
                  END;
            END;
         END IF;   -- Em sortit pq ja tenim un valor

         p_map_debug(psmapead, pcmapead, NULL, NULL, NULL, plinia, NULL, NULL, NULL, pvcondi,
                     NULL, NULL, 5,
                     SUBSTR('Execute ' || exp_resul || '-->Resultat:' || num_resul, 1, 500));

         IF num_resul >= 1 THEN
            RETURN TRUE;
         ELSE
            RETURN FALSE;
         END IF;
      END IF;
   END f_condicion_valida;

   PROCEDURE p_carga_parametros_xml(
      pdomdoc IN xmldom.domdocument,
      pliniaini IN VARCHAR2,
      pdebug IN NUMBER DEFAULT 0) IS
   BEGIN
      vg_domdoc := pdomdoc;
      vg_liniaini := pliniaini;
      vg_debug := pdebug;
      vg_deb_orden := 0;
      vg_numlin := 0;
   END p_carga_parametros_xml;

   PROCEDURE p_carga_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0) IS
      vtdesmap       map_cabecera.tdesmap%TYPE;
      vtparpath      map_cabecera.tparpath%TYPE;
      vttipotrat     map_cabecera.ttipotrat%TYPE;
      vpath          VARCHAR2(100);
      v_cfichero     NUMBER;
   BEGIN
      -- recuperem la informació de capçalera del fitxer
      SELECT tdesmap, tparpath, ttipotrat
        INTO vtdesmap, vtparpath, vttipotrat
        FROM map_cabecera
       WHERE cmapead = pcmapead;

      IF vttipotrat <> 'A' THEN
         --Ini Bug.: 14701 - ICV - 27/05/2010
         --Si el tparpath es un númerico miramos si existe en ficheros_rutas
         BEGIN
            v_cfichero := vtparpath;
            vpath := pac_nombres_ficheros.ff_ruta_fichero(pac_md_common.f_get_cxtempresa,
                                                          v_cfichero, 1);   --tpath
         EXCEPTION
            WHEN VALUE_ERROR THEN   --Si da error de no númerico o no existe en la tabla nos quedamos con el tparpath
               NULL;
         END;

         IF vpath IS NULL THEN
            vpath := f_parinstalacion_t(vtparpath);
         END IF;

         --Fin Bug.: 14701
         IF pnomfitxer IS NULL THEN
            --el nom del fitxer és una constant i està a la taula
            vg_idfitxer := UTL_FILE.fopen(vpath, vtdesmap, 'r', 32767);
         ELSE
            --el nom del fitxer és variable i entra per paràmetre
            vg_idfitxer := UTL_FILE.fopen(vpath, pnomfitxer, 'r', 32767);
         END IF;
      END IF;

      vg_liniaini := pliniaini;
      vg_debug := pdebug;
      vg_deb_orden := 0;
      vg_numlin := 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_MAP.carga_fichero', 1,
                     'Error incontrolado al buscar datos en MAP_cabecera', SQLERRM);
   END p_carga_parametros_fichero;

   FUNCTION f_carga_trata_elemento(ptipo IN NUMBER, ptag IN VARCHAR2)
      RETURN BOOLEAN IS
-----------------------------------------------------------------
-- EAS, CPM 22/04/04
-- Valida que estiguem en la posición correcta dintre de l'arbre pel tipus
--  mapejador 3. Per la resta de tipus de mapejador sempre és cert.
-----------------------------------------------------------------
   BEGIN
      IF ptipo = 3 THEN
         RETURN(xmldom.getnodename(vg_node) = ptag);
      ELSE
         RETURN(TRUE);
      END IF;
   END f_carga_trata_elemento;

   ----
   FUNCTION f_carga_buscar_valor(
      ptipo IN NUMBER,
      pttag IN VARCHAR2,
      pnpos IN NUMBER,
      pnlong IN NUMBER,
      psepara IN VARCHAR2,
      pcatributs IN NUMBER)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 22/04/04
-- retorna el valor buscat dins el "contenidor" de dades (si es un xml dins del
--   node, si és un fitxer pla dins la línia)
-----------------------------------------------------------------
      v_msg          VARCHAR2(32000);
   BEGIN
      IF ptipo = 3 THEN
         IF pcatributs = 1 THEN
            RETURN xmldom.getattribute(xmldom.makeelement(vg_node), pttag);
         ELSE
            RETURN(buscartexto(vg_node, pttag));
         END IF;
      ELSE
         RETURN(f_valor_linia(psepara, vg_linia, pnpos, pnlong));
      END IF;
   END f_carga_buscar_valor;

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   FUNCTION carga_map(pcmapead IN VARCHAR2, psmapead OUT NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------
-- EAS, CPM 18/03/04
-- Funció per carregar a la base de dades un XML
--    pcfitxer:  Codi del fitxer
--    psinterf:   ??????
--    pliniain:  Línia on estaran els paràmetres necessaris. En principi,
--      hi haurà el valor de la condició quan aquest sigui variable.
--    pdomdoc:   XML
-----------------------------------------------------------------
      vsepara        map_cabecera.cseparador%TYPE;
      vttipomap      map_cabecera.ttipomap%TYPE;
      vttipotrat     map_cabecera.ttipotrat%TYPE;
      nodearrel      xmldom.domnode;
      nerr           NUMBER;
      nodelistarrel  xmldom.domnodelist;
      v_msg          VARCHAR2(32000);

      CURSOR carrels IS
         --cursor que recupera tots els possibles nodes arrel
         SELECT ttag, nordfill
           FROM map_xml x, map_comodin c
          WHERE x.cmapead = c.cmapcom
            AND c.cmapead = pcmapead
            --  AND ncondicion = 0   Necessari només a XML
            AND tpare = '0';

      FUNCTION f_leer(
         ppare IN VARCHAR2,
         ptag IN VARCHAR2,
         pnordfill IN NUMBER,
         pliniapare IN VARCHAR2)
         RETURN NUMBER IS
         CURSOR ctaulesfulles IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   c.ctabla,
                              -- ini Bug 0016529 - 14/12/2010 - JMF
                              --f_map_replace(tt.tfrom, NULL, pliniapare, pcmapead, vsepara,
                              --              vg_linia, psmapead, ptag) taula,
                              tt.tfrom,
                                       -- fin Bug 0016529 - 14/12/2010 - JMF:
                                       c.tsenten, c.cparam, c.cpragma, trat.tcondicion,
                     c.nveces
                FROM map_xml tx, map_det_tratar trat, map_tabla tt, map_cab_tratar c,
                     map_comodin mc, map_comodin mc1, map_comodin mc2
               WHERE c.nveces = trat.nveces
                 AND c.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND c.ctabla = tt.ctabla
                 AND tt.ctabla = trat.ctabla
                 AND trat.norden = tx.norden
                 AND trat.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.ctablafills IS NULL   -- Es una fulla
                 AND tx.cmapead = mc2.cmapcom
                 AND mc2.cmapead = pcmapead
                 AND tx.tpare = ptag
            GROUP BY c.ctabla, tt.tfrom, c.tsenten, c.cparam, c.cpragma, c.nveces,
                     trat.tcondicion;

         CURSOR cfulles IS
            -- Fills que tenen el seu valor en la seva propia linia
            SELECT   tx.ttag, det.nposicion, det.nlongitud, tx.catributs, det.cmapead,
                     det.norden, tx.nordfill
                FROM map_xml tx, map_detalle det, map_comodin mc, map_comodin mc1
               WHERE det.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND det.norden = tx.norden
                 AND tx.ctablafills IS NULL   -- Es una fulla
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill;

         CURSOR cfullestractar(
            pctaula IN NUMBER,
            pnveces IN NUMBER,
            pncondi IN VARCHAR2,
            p2_cmapead IN VARCHAR2,
            pnorden IN NUMBER) IS
            -- Tractament del detall dels fills que tenen el seu valor en la seva propia linia
            SELECT   trat.tcampo, trat.ctipcampo, trat.tmascara, trat.tsetwhere, trat.norden
                FROM map_det_tratar trat
               WHERE trat.nveces = pnveces
                 AND trat.cmapead = p2_cmapead
                 AND trat.tcondicion = pncondi
                 AND trat.ctabla = pctaula
                 AND trat.norden = pnorden
            ORDER BY trat.nveces;

         CURSOR cbranques IS
            -- Branques
            SELECT   tx.ttag, tx.nordfill
                FROM map_xml tx, map_comodin c
               WHERE   --tx.ctablafills IS NOT NULL   -- Es una branca
                     tx.ttag IN(SELECT tx2.tpare   --Bug.: 14701 - ICV - Cambios del pac_map2
                                  FROM map_xml tx2
                                 WHERE tx.cmapead = tx2.cmapead)
                 AND tx.cmapead = c.cmapcom
                 AND c.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill, tx.ttag;

         vcursor        PLS_INTEGER;
         vnumrows       NUMBER;
         vfrompare      map_tabla.tfrom%TYPE;
         vtablapare     map_tabla.ctabla%TYPE;
         vsent          VARCHAR2(10000);
         vcampos        VARCHAR2(5000);
         vvalores       VARCHAR2(5000);
         vset           VARCHAR2(5000);
         vwhere         VARCHAR2(5000);
         nvalor_camp    NUMBER;
         valor_camp     VARCHAR2(4000);
         valor_tag      VARCHAR2(4000);
         nerror         NUMBER := 0;
         vnode          xmldom.domnode;
         vnodepare      xmldom.domnode;
         vnodepare2     xmldom.domnode;
         nodelist       xmldom.domnodelist;
         vselpare       VARCHAR2(32000);
         vselorden      map_detalle.norden%TYPE;

         TYPE t_cursor IS REF CURSOR;

         c_pare         t_cursor;
         vlinia         VARCHAR2(32000);
      BEGIN
         IF f_carga_trata_elemento(vttipomap, ptag) THEN
            -- si el nom del node és el del ptag que estem buscant seguim.

            -- recuperem la select del tag que estem tractant
            SELECT 'SELECT ' || DECODE(tt.ctabla,
                                       0, '''' || pliniapare || ''' linea',
                                       'linea') || ' FROM '
                   || f_map_replace(tt.tfrom, NULL, pliniapare, pcmapead, vsepara, vg_linia,
                                    psmapead, ptag),
                   tx.norden
              INTO vselpare,
                   vselorden
              FROM map_xml tx, map_tabla tt, map_comodin c
             WHERE tt.ctabla = tx.ctablafills
               AND tx.cmapead = c.cmapcom
               AND c.cmapead = pcmapead
               AND tx.tpare = ppare
               AND tx.nordfill = pnordfill
               AND tx.ttag = ptag;

            p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare, NULL, NULL,
                        NULL, NULL, NULL, NULL, 1,
                        SUBSTR('Vttipomap ' || vttipomap || '; Select Propia ' || vselpare, 1,
                               500));

                        -- Bucle repetitiu per cada vegada que haurem d'escriure el tag. Tantes vegades com
               --   registres torni l'execució de la select del tag (vselpare)
            --p_control_error('maptime', 'abans select propia '||ptag, dbms_utility.get_time);
            OPEN c_pare FOR vselpare;

            FETCH c_pare
             INTO vlinia;

            --p_control_error('maptime', 'despres select propia '||ptag, dbms_utility.get_time);
            LOOP
               IF c_pare%NOTFOUND THEN
                  EXIT;
               ELSE
                  FOR c_condi IN (SELECT trat.tcondicion
                                    FROM map_det_tratar trat, map_comodin c
                                   WHERE trat.cmapead = c.cmapcom
                                     AND c.cmapead = pcmapead
                                     AND trat.norden = vselorden
                                  UNION
                                  SELECT '0'
                                    FROM DUAL
                                   WHERE NOT EXISTS(
                                            SELECT trat.tcondicion
                                              FROM map_det_tratar trat, map_comodin c
                                             WHERE trat.cmapead = c.cmapcom
                                               AND c.cmapead = pcmapead
                                               AND trat.norden = vselorden)) LOOP
                     IF f_condicion_valida(vttipomap, c_condi.tcondicion, vlinia, vsepara,
                                           pcmapead, psmapead) THEN
                        vlinia := f_valor_parametro('|', vlinia, vselorden, pcmapead);
                        vnodepare2 := vg_node;   --guardat per si tenim més d'una fila de la select del pare

                        -- Tractem els fills fulles
                        FOR c_taulaf1 IN ctaulesfulles LOOP
                           -- per cada taula-condicio-nveces que hem de insertar o actualitzar
                           IF vttipotrat = 'A'
                              OR vttipomap = 3 THEN
                               -- No tenim linia del fitxer pq. estem fem un AMBOS (select/insert)
                              -- o bé és una càrrega d'un XML
                              -- La linia a tractar serà la del pare
                              vg_linia := vlinia;
                           END IF;

                           FOR i IN 0 .. ROUND(NVL(LENGTH(c_taulaf1.tsenten), 1) / 500, 0) LOOP
                              p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag,
                                          pliniapare, vlinia, NULL, c_taulaf1.nveces,
                                          c_taulaf1.tcondicion, NULL, c_taulaf1.ctabla, 3,
                                          SUBSTR('FILLS FULLES LINEA PROPI:'
                                                 || c_taulaf1.tsenten,
                                                 i * 500 + 1, 500));
                           END LOOP;

                           IF f_condicion_valida(vttipomap, c_taulaf1.tcondicion, vg_linia,
                                                 vsepara, pcmapead, psmapead) THEN
                              -- si la condició es cumpleix
                              IF NVL(c_taulaf1.cparam, 0) <> 1 THEN
                                 vcampos := NULL;
                                 vvalores := NULL;
                                 vset := NULL;
                                 vwhere := NULL;
                              ELSE
                                 vcampos := 'smapead, cmapead, ';
                                 vvalores := psmapead || ', ''' || pcmapead || ''', ';
                                 vset := NULL;
                                 vwhere := 'smapead = ' || psmapead || ' and cmapead = '''
                                           || pcmapead || ''' and ';
                              END IF;

                              FOR c_fill IN cfulles LOOP
                                 -- per cada camp dins la taula, busquem el valor del tag associat
                                 valor_tag := f_carga_buscar_valor(vttipomap, c_fill.ttag,
                                                                   c_fill.nposicion,
                                                                   c_fill.nlongitud, vsepara,
                                                                   c_fill.catributs);
                                 --Només es remplacen les cometes per valor_Camp. Si el tipus de camp és 4 llavors
                                 --és necessari que les cometes estiguin bé directament al camp tmascara
                                 valor_tag := REPLACE(valor_tag, '''', '''''');
                                 p_map_debug(psmapead, pcmapead, ptag, c_fill.nordfill,
                                             c_fill.ttag, pliniapare, vlinia, NULL,
                                             c_taulaf1.nveces, c_taulaf1.tcondicion, NULL,
                                             c_taulaf1.ctabla, 4,
                                             SUBSTR('Valor camp(tag): ' || valor_tag, 1, 500));

                                 -- Mirem que hi hagi valor (tag)
                                 IF valor_tag IS NOT NULL THEN
                                    FOR c_fill2 IN cfullestractar(c_taulaf1.ctabla,
                                                                  c_taulaf1.nveces,
                                                                  c_taulaf1.tcondicion,
                                                                  c_fill.cmapead,
                                                                  c_fill.norden) LOOP
                                       valor_camp := valor_tag;

                                       --tractem els valors "null"
                                       IF c_fill2.ctipcampo IN(1, 3) THEN
                                           -- es considera que un varchar2 y una data no poden tenir el valor 0
                                          --  si es donés el cas, podria modificarse el ctipcampo i convertir-lo
                                          --  a númeric
                                          IF (c_fill2.ctipcampo = 1
                                              AND c_fill2.tmascara IS NULL)
                                             OR(c_fill2.ctipcampo <> 1) THEN
                                             BEGIN
                                                nvalor_camp := TO_NUMBER(valor_camp);

                                                IF nvalor_camp = 0 THEN
                                                   valor_camp := 'NULL';
                                                ELSE
                                                   valor_camp := '''' || valor_camp || '''';
                                                END IF;
                                             EXCEPTION
                                                WHEN OTHERS THEN
                                                   valor_camp := '''' || valor_camp || '''';
                                             END;
                                          END IF;
                                       END IF;

                                       ---- EXEMPLE DE NUMBER

                                       -- tractem la màscara
                                       IF c_fill2.tmascara IS NOT NULL THEN
                                          IF c_fill2.ctipcampo = 1 THEN
                                             valor_camp :=
                                                'to_char(' || valor_camp || ','''
                                                || c_fill2.tmascara || ''')';
                                          ELSIF c_fill2.ctipcampo = 2 THEN
                                             valor_camp :=
                                                'to_number(to_char(' || valor_camp || ','''
                                                || c_fill2.tmascara || '''))';
                                          ELSIF c_fill2.ctipcampo = 3 THEN
                                             valor_camp :=
                                                'to_date(' || valor_camp || ','''
                                                || c_fill2.tmascara || ''')';
                                          ELSIF c_fill2.ctipcampo = 4 THEN
                                             valor_camp :=
                                                f_map_replace(c_fill2.tmascara, valor_camp,
                                                              pliniapare, pcmapead, vsepara,
                                                              vlinia, psmapead, c_fill.ttag);
                                          ELSIF c_fill2.ctipcampo = 5 THEN
                                             valor_camp :=
                                                f_valor_parametro('|', vlinia,
                                                                  c_fill2.tmascara,
                                                                  c_fill.cmapead);
                                          ELSIF c_fill2.ctipcampo = 6 THEN
                                             EXECUTE IMMEDIATE f_map_replace
                                                                            (c_fill2.tmascara,
                                                                             valor_camp,
                                                                             pliniapare,
                                                                             pcmapead,
                                                                             vsepara, vlinia,
                                                                             psmapead,
                                                                             c_fill.ttag)
                                                         USING OUT valor_camp;
                                          END IF;
                                       ELSE
                                          IF c_fill2.ctipcampo = 2 THEN
                                             valor_camp :=
                                                         'to_number(''' || valor_camp || ''')';
                                          END IF;
                                       END IF;

                                       p_map_debug(psmapead, pcmapead, ptag, c_fill.nordfill,
                                                   c_fill.ttag, pliniapare, vlinia,
                                                   c_fill2.tcampo, c_taulaf1.nveces,
                                                   c_taulaf1.tcondicion, NULL,
                                                   c_taulaf1.ctabla, 4,
                                                   SUBSTR('Valor camp tratado: ' || valor_camp,
                                                          1, 500));

                                       --construim els valors dels camps, valors, i sentències where
                                       IF c_taulaf1.tsenten = 'I' THEN
                                          vcampos := vcampos || c_fill2.tcampo || ', ';
                                          vvalores := vvalores || valor_camp || ', ';
                                       ELSIF c_taulaf1.tsenten = 'U' THEN
                                          IF c_fill2.tsetwhere = 'S' THEN
                                             vset :=
                                                vset || c_fill2.tcampo || ' = ' || valor_camp
                                                || ', ';
                                          ELSIF c_fill2.tsetwhere = 'W' THEN
                                             vwhere :=
                                                vwhere || c_fill2.tcampo || ' = '
                                                || valor_camp || ' and ';
                                          END IF;
                                       ELSIF c_taulaf1.tsenten = 'D' THEN
                                          vwhere :=
                                             vwhere || c_fill2.tcampo || ' = ' || valor_camp
                                             || ' and ';
                                       END IF;
                                    END LOOP;   -- s'acaba el tractament del detall del camp
                                 END IF;
                              END LOOP;   -- s'acaba el tractamente del camp

                              --construim la sentència definitiva
                              IF c_taulaf1.tsenten = 'I' THEN
                                 IF vcampos = 'smapead, cmapead, ' THEN
                                    vsent := NULL;
                                 ELSE
                                    vcampos := SUBSTR(vcampos, 1, LENGTH(vcampos) - 2);
                                    vvalores := SUBSTR(vvalores, 1, LENGTH(vvalores) - 2);
                                    -- ini Bug 0016529 - 14/12/2010 - JMF
                                    --vsent := 'insert into ' || c_taulaf1.taula || ' ('
                                    --         || vcampos || ') values (' || vvalores || ')';
                                    vsent := 'insert into '
                                             || f_map_replace(c_taulaf1.tfrom, NULL,
                                                              pliniapare, pcmapead, vsepara,
                                                              vg_linia, psmapead, ptag)
                                             || ' (' || vcampos || ') values (' || vvalores
                                             || ')';
                                 -- fin Bug 0016529 - 14/12/2010 - JMF

                                 -- insert into informes_err values ('MAP '||f_sysdate||' ' ||vsent);
                                 END IF;
                              ELSIF c_taulaf1.tsenten = 'U' THEN
                                 IF vset IS NULL THEN
                                    vsent := NULL;
                                 ELSE
                                    vset := SUBSTR(vset, 1, LENGTH(vset) - 2);
                                    vwhere := SUBSTR(vwhere, 1, LENGTH(vwhere) - 4);
                                    -- ini Bug 0016529 - 14/12/2010 - JMF
                                    --vsent := 'update ' || c_taulaf1.taula || ' set ' || vset
                                    --         || ' where ' || vwhere;
                                    vsent := 'update '
                                             || f_map_replace(c_taulaf1.tfrom, NULL,
                                                              pliniapare, pcmapead, vsepara,
                                                              vg_linia, psmapead, ptag)
                                             || ' set ' || vset || ' where ' || vwhere;
                                 -- fin Bug 0016529 - 14/12/2010 - JMF
                                 END IF;
                              ELSIF c_taulaf1.tsenten = 'D' THEN
                                 vwhere := SUBSTR(vwhere, 1, LENGTH(vwhere) - 4);
                                 -- ini Bug 0016529 - 14/12/2010 - JMF
                                 --vsent := 'delete ' || c_taulaf1.taula || ' where ' || vwhere;
                                 vsent := 'delete '
                                          || f_map_replace(c_taulaf1.tfrom, NULL, pliniapare,
                                                           pcmapead, vsepara, vg_linia,
                                                           psmapead, ptag)
                                          || ' where ' || vwhere;
                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              END IF;

                              -- Mirem si fem un commit
                              IF NVL(c_taulaf1.cpragma, 0) = 1
                                 AND vsent IS NOT NULL THEN
                                 vsent := 'declare   PRAGMA autonomous_transaction; begin '
                                          || vsent || '; commit; end;';
                              END IF;

                              FOR i IN 0 .. ROUND(NVL(LENGTH(vsent), 1) / 500, 0) LOOP
                                 p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag,
                                             pliniapare, vlinia, NULL, c_taulaf1.nveces,
                                             c_taulaf1.tcondicion, NULL, c_taulaf1.ctabla, 3,
                                             SUBSTR('Sentencia= ' || vsent, i * 500 + 1, 500));
                              END LOOP;

                              IF vsent IS NOT NULL THEN
                                 vcursor := DBMS_SQL.open_cursor;
                                 DBMS_SQL.parse(vcursor, vsent, DBMS_SQL.native);
                                 vnumrows := DBMS_SQL.EXECUTE(vcursor);
                                 DBMS_SQL.close_cursor(vcursor);
                              END IF;
                           END IF;   --condició
                        END LOOP;   --s'acaba el tractament de la taula-condicio-nveces

-------------------------------------------------------------------------------
   -- Tractem els fills branca
                        FOR c_taulaf2 IN cbranques LOOP
                           p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare,
                                       vlinia, NULL, NULL, NULL, NULL, NULL, 2,
                                       SUBSTR('FILLS BRANQUES. tag ' || c_taulaf2.ttag
                                              || ', norden ' || c_taulaf2.nordfill,
                                              1, 500));

                           IF vttipomap = 3 THEN
                              nodelist := xmldom.getchildnodes(vg_node);

                              FOR i IN 0 ..(xmldom.getlength(nodelist) - 1) LOOP
                                  --busquem dins els fills del node entrat per paràmetre si n'hi ha algun que
                                 --   coincideixi el tag amb el recuperat pel cursor cBranques, i si és així
                                 --   seguim baixant pel XML tornant a cridar a la funció f_leer.
                                 vnode := xmldom.item(nodelist, i);

                                 -- Utilitzem la mateixa variable global cada vegada ja que al tornar
                                 --  de la funció no fem res amb ella
                                 IF xmldom.getnodename(vnode) = c_taulaf2.ttag THEN
                                    vnodepare := vg_node;   --guardat per quan tornem de la F_leer
                                    vg_node := vnode;
                                    nerror := f_leer(ptag, c_taulaf2.ttag, c_taulaf2.nordfill,
                                                     REPLACE(vlinia, '''', '''||chr(39)||'''));
                                    vg_node := vnodepare;

                                    IF nerror <> 0 THEN
                                       RETURN nerror;
                                    END IF;
                                 END IF;
                              END LOOP;
                           ELSE   -- Els fitxers plans també poden tenir branques
                              nerror := f_leer(ptag, c_taulaf2.ttag, c_taulaf2.nordfill,
                                               REPLACE(vlinia, '''', '''||chr(39)||'''));

                              IF nerror <> 0 THEN
                                 RETURN nerror;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;   -- Validació de la condició
                  END LOOP;   -- Cursor de la condició
               END IF;   -- Registre de la select

                    -- recuperem el següent registre de la select del tag que tractem
               --p_control_error('maptime', 'abans select propia 2 '||ptag, dbms_utility.get_time);
               FETCH c_pare
                INTO vlinia;

               --p_control_error('maptime', 'abans select propia 2 '||ptag, dbms_utility.get_time);
               vg_node := vnodepare2;
            END LOOP;
         END IF;

         RETURN nerror;
      EXCEPTION
         WHEN OTHERS THEN
            p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare, NULL, NULL,
                        NULL, NULL, NULL, NULL, 1,
                        SUBSTR('Error when others ' || SQLERRM, 1, 500));
            DBMS_SQL.close_cursor(vcursor);
            p_tab_error(f_sysdate, f_user, 'pac_MAP.f_leer', 2, 'Error incontrolado', SQLERRM);
            RETURN(151634);
      END f_leer;
   BEGIN
      IF pcmapead IS NULL THEN
         RETURN(112223);   --es obligatori informar un nom de fitxer
      END IF;

      SELECT smapead.NEXTVAL
        INTO psmapead
        FROM DUAL;

      BEGIN
         -- recuperem la informació de capçalera del fitxer
         SELECT cseparador, ttipomap, ttipotrat
           INTO vsepara, vttipomap, vttipotrat
           FROM map_cabecera
          WHERE cmapead = pcmapead;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_MAP.carga_xml', 1,
                        'Error incontrolado al buscar datos en MAP_cabecera', SQLERRM);
            RETURN(151539);
      END;

      IF vttipomap = 3 THEN
         FOR varrel IN carrels LOOP
            nodelistarrel := xmldom.getchildnodes(xmldom.makenode(vg_domdoc));

            FOR i IN 0 ..(xmldom.getlength(nodelistarrel) - 1) LOOP
                --busquem dins els fills del node entrat per paràmetre si n'hi ha algun que
               --   coincideixi el tag amb el recuperat pel cursor cBranques, i si és així
               --   seguim baixant pel XML tornant a cridar a la funció f_leer.
               vg_node := xmldom.item(nodelistarrel, i);

               IF xmldom.getnodename(vg_node) = varrel.ttag THEN
                  -- per cada un dels nodes arrels cridem a la funció f_leer
                  vg_numlin := vg_numlin + 1;
                  nerr := f_leer('0', varrel.ttag, varrel.nordfill, vg_liniaini);

                  IF nerr <> 0 THEN
                     RETURN nerr;
                  END IF;
               END IF;
            END LOOP;
         END LOOP;
      ELSIF vttipotrat = 'A' THEN   -- Ambos
         nerr := f_leer('0', 'TP', 1, vg_liniaini);
      ELSE
         LOOP
            -- recuperem la línia
            BEGIN
               UTL_FILE.get_line(vg_idfitxer, vg_linia);
               vg_numlin := vg_numlin + 1;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  UTL_FILE.fclose(vg_idfitxer);
                  EXIT;
            END;

            nerr := f_leer('0', 'TP', 1, vg_liniaini);

            IF nerr <> 0 THEN
               RETURN nerr;
            END IF;
         END LOOP;
      END IF;

      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         UTL_FILE.fclose(vg_idfitxer);
         p_tab_error(f_sysdate, f_user, 'pac_MAP.carga_xml', 2, 'Error incontrolado', SQLERRM);
         RETURN(151634);
   END carga_map;

   FUNCTION f_carga_map(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 18/11/2004
-- Función para ser llamada desde un map de procesos. Ejecuta la
--   función carga_MAP. Retorna una cadena con separador '|'.
-- No está pensada para ejecutarse con maps tipo XML ya que en este caso
--   se entiende que será una interfaz online y que se usará la función
--   f_int del package pac_int_online
-----------------------------------------------------------------
      vsmapead       NUMBER;
      nerror         NUMBER;
   BEGIN
      p_carga_parametros_fichero(pcmapead, pliniaini, pnomfitxer, pdebug);
      nerror := carga_map(pcmapead, vsmapead);
      RETURN(nerror || '|' || vsmapead);
   END f_carga_map;

   ---
   ---
   ---
   FUNCTION f_obtener_xml_texto
      RETURN VARCHAR2 IS
      v_msg          VARCHAR2(32700);
   BEGIN
      xmldom.writetobuffer(vg_domdoc, v_msg);
      -- JLB - Para evitar que se envien recibir, caracteres erroneso
      --v_msg := CONVERT (v_msg,'WE8ISO8859P1','UTF8');
      -- F - JLB-
      RETURN(v_msg);
   END f_obtener_xml_texto;

   FUNCTION f_obtener_xml
      RETURN xmldom.domdocument IS
   BEGIN
      RETURN(vg_domdoc);
   END f_obtener_xml;

   PROCEDURE p_genera_parametros_xml(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pdebug IN NUMBER DEFAULT 0) IS
      vtversion      map_cabecera_xml.tversion%TYPE;
      vtcharset      map_cabecera_xml.tcharset%TYPE;
   BEGIN
      -- recuperem la informació de capçalera del XML
      SELECT tversion, tcharset
        INTO vtversion, vtcharset
        FROM map_cabecera_xml
       WHERE cmapead = pcmapead;

      -- Generación del xml

      -- Creem el document
      vg_domdoc := xmldom.newdomdocument;
      -- assignem la versió i el charset
      xmldom.setversion(vg_domdoc, vtversion);
      xmldom.setcharset(vg_domdoc, vtcharset);
      -- creem el primer node
      vg_node := xmldom.makenode(vg_domdoc);
      vg_liniaini := pliniaini;
      vg_debug := pdebug;
      vg_deb_orden := 0;
      vg_numlin := 0;
   END p_genera_parametros_xml;

   PROCEDURE p_genera_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0,
      pcconruta IN NUMBER DEFAULT NULL) IS
      vtdesmap       map_cabecera.tdesmap%TYPE;
      vtparpath      map_cabecera.tparpath%TYPE;
      vpath          VARCHAR2(100);
      v_cfichero     NUMBER;
      wpas           PLS_INTEGER := 0;
   BEGIN
      wpas := 1;

      -- recuperem la informació de capçalera del fitxer
      SELECT tdesmap, tparpath
        INTO vtdesmap, vtparpath
        FROM map_cabecera
       WHERE cmapead = pcmapead;

      --Ini Bug.: 14701 - ICV - 27/05/2010
      --Si el tparpath es un númerico miramos si existe en ficheros_rutas
      BEGIN
         --NMM.2013.01.16.Bug 25376.i.
         wpas := 2;

         IF pcconruta IS NOT NULL THEN
            wpas := 3;
            v_cfichero := vtparpath || pcconruta;
         ELSE
            wpas := 4;
            v_cfichero := vtparpath;
         END IF;

         wpas := 5;
         --NMM.2013.01.16.Bug 25376.f.
         vpath := pac_nombres_ficheros.ff_ruta_fichero(pac_md_common.f_get_cxtempresa,
                                                       v_cfichero, 1);   --TPATH
         wpas := 6;
      EXCEPTION
         WHEN VALUE_ERROR THEN   --Si da error de no númerico o no existe en la tabla nos quedamos con el tparpath
            wpas := 7;
            NULL;
      END;

      IF vpath IS NULL THEN
         wpas := 8;
         vpath := f_parinstalacion_t(vtparpath);
      END IF;

      --Fin Bug.: 14701
      IF pnomfitxer IS NULL THEN
         --el nom del fitxer és una constant que està a la taula
         vg_idfitxer := UTL_FILE.fopen(vpath, vtdesmap, 'w', 32767);
      ELSE
         --el nom del fitxer és variable i entra per paràmetre
         vg_idfitxer := UTL_FILE.fopen(vpath, pnomfitxer, 'w', 32767);
      END IF;

      vg_liniaini := pliniaini;
      vg_debug := pdebug;
      vg_deb_orden := 0;
      vg_numlin := 0;
   --
   EXCEPTION
      WHEN OTHERS THEN
         UTL_FILE.fclose(vg_idfitxer);
         p_tab_error(f_sysdate, f_user, 'pac_MAP.p_genera_parametros_fichero', wpas,
                     ':vtparpath:<' || vtparpath || '>:pcconruta:<' || pcconruta
                     || '>:vpath:<' || vpath || '>',
                     SQLERRM);
   END p_genera_parametros_fichero;

   FUNCTION f_genera_node(
      ptipo IN NUMBER,
      pcmapead IN VARCHAR2,
      ppare IN VARCHAR2,
      ptag IN VARCHAR2,
      plinia IN VARCHAR2,
      psepara IN VARCHAR2)
      RETURN NUMBER IS
      vselatributs   VARCHAR2(4000);

      TYPE t_cursor IS REF CURSOR;

      c_atri         t_cursor;
      vliniaatri     VARCHAR2(2000);
      vnomatri       VARCHAR2(100);
      vvalatri       VARCHAR2(100);
      myelement      xmldom.domelement;
   BEGIN
      IF ptipo = 3 THEN
         myelement := xmldom.createelement(vg_domdoc, ptag);
         -- Afegim un fill al node que entra per paràmetre
         vg_node := xmldom.appendchild(vg_node, xmldom.makenode(myelement));
      ELSE
         vg_linia := '';
      END IF;

      RETURN 0;
   END f_genera_node;

   PROCEDURE p_genera_linia(
      ptipo IN NUMBER,
      pcmapead IN VARCHAR2,
      pvalor IN VARCHAR2,
      ptabla IN NUMBER,
      pnordfill IN NUMBER,
      ptag IN VARCHAR2,
      ptagpare IN VARCHAR2,
      psepara IN VARCHAR2,
      pcatributs IN NUMBER) IS
      vnode          xmldom.domnode;
      vnodepost      xmldom.domnode;

      FUNCTION f_nodeposterior(pnodearrel IN xmldom.domnode)
         RETURN xmldom.domnode IS
         --funció que retorna el node davant el que s'hauria d'insertar el node actual
         CURSOR cordrefills IS
            -- tots els fills d'altres taules que tenen un ordre més gran del pnordfill
            SELECT   tx.nordfill, tx.ttag
                FROM map_xml tx, map_det_tratar trat, map_comodin mc, map_comodin mc1
               WHERE trat.ctabla <> ptabla
                 AND trat.norden = tx.norden
                 AND trat.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.tpare = ptagpare
                 AND tx.nordfill > pnordfill
            ORDER BY tx.nordfill;

         nl             xmldom.domnodelist;
         vxnodepost     xmldom.domnode;
      BEGIN
         FOR reg IN cordrefills LOOP
            nl := xmldom.getelementsbytagname(xmldom.makeelement(pnodearrel), reg.ttag);

            IF xmldom.getlength(nl) <> 0 THEN
               vxnodepost := xmldom.item(nl, 0);
               RETURN(vxnodepost);
            END IF;
         END LOOP;

         RETURN vxnodepost;
      END f_nodeposterior;

      PROCEDURE anadirnodoorden(
         p_doc xmldom.domdocument,
         pnodepare xmldom.domnode,
         pnodepost xmldom.domnode,
         p_tag IN VARCHAR2,
         p_texto IN VARCHAR2) IS
-----------------------------------------------------------------
-- EAS, CPM 29/03/04
-- Funció que insereix un node amb tag p_Tag i valor p_texto,
--   com a fill del pNodePare, tenint en compte que si el pNodeAnt no és null,
--   el node que s'està inserint s'ha d'inserir davant del pNodePost.
--   Si no s'inserirà al final.
-----------------------------------------------------------------
         mynode         xmldom.domnode;
         mynodenew      xmldom.domnode;
         myelement      xmldom.domelement;
         mytextnode     xmldom.domtext;
      BEGIN
         IF pcatributs = 1 THEN   -- Es un atribut del pare
            xmldom.setattribute(xmldom.makeelement(pnodepare), p_tag, p_texto);
         ELSIF pcatributs = 2 THEN   -- Es un valor del pare
            mytextnode := xmldom.createtextnode(p_doc, p_texto);
            mynode := xmldom.appendchild(pnodepare, xmldom.makenode(mytextnode));
         ELSE   -- Es una fulla que penja del pare
            --creem el node actual com a fill del node pare i després del node anterior
            myelement := xmldom.createelement(p_doc, LTRIM(RTRIM(p_tag, '_')));
            mytextnode := xmldom.createtextnode(p_doc, p_texto);

            IF xmldom.isnull(pnodepost) THEN
               mynode := xmldom.appendchild(pnodepare, xmldom.makenode(myelement));
            ELSE
               mynode := xmldom.insertbefore(pnodepare, xmldom.makenode(myelement), pnodepost);
            END IF;

            --"penjem" el text
            mynode := xmldom.appendchild(mynode, xmldom.makenode(mytextnode));
         END IF;
      END;
   BEGIN
      IF ptipo = 3 THEN
         -- busquem el node abans del que s'hauria d'inserir el nou tag
         vnodepost := f_nodeposterior(vg_node);
         -- afegim el nou tag
         anadirnodoorden(vg_domdoc, vg_node, vnodepost, ptag, pvalor);
      ELSIF ptipo = 1 THEN
         vg_linia := vg_linia || pvalor;
      ELSE
         vg_linia := vg_linia || pvalor || psepara;
      END IF;
   END p_genera_linia;

-------------------------------------------------------------------------------
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
   FUNCTION genera_map(pcmapead IN VARCHAR2, psmapead OUT NUMBER)
      RETURN NUMBER IS
-----------------------------------------------------------------
-- EAS, CPM 18/03/04
-- Funció per generar un XML
  -- El paràmetre plineaini és una cadena amb tots els camps d'entrada
  --  necessaris per construir el XML. Vindràn separats per un |
-----------------------------------------------------------------
      vsepara        map_cabecera.cseparador%TYPE;
      vttipomap      map_cabecera.ttipomap%TYPE;
      vttipotrat     map_cabecera.ttipotrat%TYPE;
      varrel         map_xml.tpare%TYPE;
      mynode         xmldom.domnode;
      nerr           NUMBER;
      v_msg          VARCHAR2(32000);

      TYPE registro IS TABLE OF VARCHAR2(32000)
         INDEX BY BINARY_INTEGER;

      TYPE vector IS TABLE OF registro
         INDEX BY BINARY_INTEGER;

      FUNCTION f_genera(
         ppare IN VARCHAR2,
         ptag IN VARCHAR2,
         pnordfill IN NUMBER,
         pliniapare IN VARCHAR2)
         RETURN NUMBER IS
         --Bug.: 14701 - ICV - Cambios del pac_map2
         CURSOR ctaulesfulles(pvlinia IN VARCHAR2) IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   'SELECT '
                     || DECODE(DECODE(tt.ctabla, -1, 0, tt.ctabla),
                               0, '''' || pvlinia || ''' linea',
                               'linea')
                     -- ini Bug 0016529 - 14/12/2010 - JMF
                     --|| ' FROM '
                     --|| f_map_replace(tt.tfrom, NULL, pvlinia, pcmapead, vsepara, NULL, NULL,
                     --                 ptag) selfulles,
                     || ' FROM ' x1,
                     tt.tfrom x2,
                                 -- fin Bug 0016529 - 14/12/2010 - JMF
                                 DECODE(tt.ctabla, -1, 0, tt.ctabla) ctabla
                FROM map_xml tx, map_det_tratar trat, map_tabla tt, map_cab_tratar c,
                     map_comodin mc, map_comodin mc1, map_comodin mc2
               WHERE c.nveces = trat.nveces
                 AND c.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND(c.ctabla = tt.ctabla
                     OR tt.ctabla = 0)
                 AND tt.ctabla = trat.ctabla
                 AND trat.norden = tx.norden
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND(tx.ctablafills IS NULL
                     OR tx.ctablafills = -1)
                 AND tx.cmapead = mc2.cmapcom
                 AND mc2.cmapead = pcmapead
                 AND tx.tpare = ptag
            GROUP BY 'SELECT '
                     || DECODE(DECODE(tt.ctabla, -1, 0, tt.ctabla),
                               0, '''' || pvlinia || ''' linea',
                               'linea')
                     || ' FROM ',
                     tt.tfrom, DECODE(tt.ctabla, -1, 0, tt.ctabla)
            ORDER BY MIN(tx.nordfill);

         CURSOR cfulles_valorpropi(pctaula IN NUMBER) IS
            -- Fills que tenen el seu valor en la seva propia linia
            SELECT   tx.ttag, trat.tcondicion, tx.nordfill, det.nposicion, det.nlongitud,
                     trat.ctipcampo, trat.tmascara, tx.catributs, tx.ctablafills, det.norden
                FROM map_xml tx, map_det_tratar trat, map_detalle det, map_comodin mc,
                     map_comodin mc1
               WHERE trat.cmapead = det.cmapead
                 AND(trat.ctabla = pctaula
                     OR pctaula = 0
                        AND trat.ctabla = -1)
                 AND trat.norden = det.norden
                 AND det.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND det.norden = tx.norden
                 --AND det.ttag = tx.ttag ---OR det.ttag IS NULL)
                 AND(tx.ctablafills IS NULL
                     OR tx.ctablafills = -1)   -- Es una fulla
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill;

         CURSOR ctaulesbranques IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   tx.ttag, tx.nordfill
                FROM map_xml tx, map_comodin c
               WHERE tx.ctablafills IS NOT NULL
                 AND tx.ctablafills <> -1   -- Es una branca
                 AND tx.cmapead = c.cmapcom
                 AND c.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill, tx.ttag;

         vselpare       VARCHAR2(32000);
         vselatributs   VARCHAR2(32000);
         vselorden      map_detalle.norden%TYPE;
         vcondi         map_det_tratar.tcondicion%TYPE;

         TYPE t_cursor IS REF CURSOR;

         c_pare         t_cursor;
         c_atri         t_cursor;
         c_fills        t_cursor;
         vlinia         VARCHAR2(32000);
         vliniaatri     VARCHAR2(32000);
         vliniafills    VARCHAR2(32000);
         vnomatri       VARCHAR2(32000);
         vvalatri       VARCHAR2(32000);
         vvalor         VARCHAR2(32000);
         nerror         NUMBER := 0;
         vnodepare      xmldom.domnode;
         vnodepare2     xmldom.domnode;
      BEGIN
         -- recuperem la select del tag que estem tractant
         SELECT 'SELECT '
                || DECODE(tt.ctabla,
                          0, '''' || pliniapare || ''' linea',
                          -1, '''' || pliniapare || ''' linea',
                          'linea')
                || ' FROM '
                || f_map_replace(tt.tfrom, NULL, pliniapare, pcmapead, vsepara, NULL, NULL,
                                 ptag),
                tx.norden
           INTO vselpare,
                vselorden
           FROM map_xml tx, map_tabla tt, map_comodin c
          WHERE tt.ctabla = tx.ctablafills
            AND tx.cmapead = c.cmapcom
            AND c.cmapead = pcmapead
            AND tx.tpare = ppare
            AND tx.nordfill = pnordfill
            AND tx.ttag = ptag;

         p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare, NULL, NULL, NULL,
                     NULL, NULL, NULL, 1,
                     SUBSTR('Vttipomap ' || vttipomap || '; Select Propia ' || vselpare, 1,
                            500));

                  -- Bucle repetitiu per cada vegada que haurem d'escriure el tag. Tantes vegades com
            --   registres torni l'execució de la select del tag (vselpare)
         --p_control_error('maptime', 'abans select propia '||ptag, dbms_utility.get_time);
         OPEN c_pare FOR vselpare;

         FETCH c_pare
          INTO vlinia;

         --p_control_error('maptime', 'despres select propia '||ptag, dbms_utility.get_time);
         LOOP
            IF c_pare%NOTFOUND THEN
               EXIT;
            ELSE
               FOR c_condi IN (SELECT trat.tcondicion
                                 FROM map_det_tratar trat, map_comodin c
                                WHERE trat.cmapead = c.cmapcom
                                  AND c.cmapead = pcmapead
                                  AND trat.norden = vselorden
                               UNION
                               SELECT '0'
                                 FROM DUAL
                                WHERE NOT EXISTS(
                                         SELECT trat.tcondicion
                                           FROM map_det_tratar trat, map_comodin c
                                          WHERE trat.cmapead = c.cmapcom
                                            AND c.cmapead = pcmapead
                                            AND trat.norden = vselorden)) LOOP
                  IF f_condicion_valida(vttipomap, c_condi.tcondicion, vlinia, vsepara,
                                        pcmapead, NULL) THEN
                     vlinia := f_valor_parametro('|', vlinia, vselorden, pcmapead);
                     vnodepare2 := vg_node;   --guardat per si tenim més d'una fila de la select del pare
                     nerror := f_genera_node(vttipomap, pcmapead, ppare, ptag, vlinia,
                                             vsepara);

                     IF nerror = 0 THEN   -- Si no es vol fer cap tractament s'hauria d'afegir AQUI una condicio
                        -- Tractem els fills fulles que tenen el seu valor en una linia propia
                        FOR c_taulaf1 IN ctaulesfulles(REPLACE(vlinia, '''',
                                                               '''||chr(39)||''')) LOOP
                           -- ini Bug 0016529 - 14/12/2010 - JMF
                           --FOR i IN 0 .. ROUND(NVL(LENGTH(c_taulaf1.ctabla), 1) / 500, 0) LOOP
                           FOR i IN
                              0 .. ROUND
                                     (NVL(LENGTH(c_taulaf1.x1
                                                 || f_map_replace(c_taulaf1.x2, NULL,
                                                                  REPLACE(vlinia, '''',
                                                                          '''||chr(39)||'''),
                                                                  pcmapead, vsepara, NULL,
                                                                  NULL, ptag)),
                                          1)
                                      / 500,
                                      0) LOOP
                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag,
                                          pliniapare, vlinia, NULL, NULL, NULL, NULL,
                                          c_taulaf1.ctabla, 3,
                                          SUBSTR('FILLS FULLES VALOR LINEA PROPI ',
                                                 i * 500 + 1, 500));
                           END LOOP;

                           --p_control_error('maptime', 'abans select fill '||c_taulaf1.ctabla, dbms_utility.get_time);

                           -- ini Bug 0016529 - 14/12/2010 - JMF
                           --OPEN c_fills FOR c_taulaf1.selfulles;
                           OPEN c_fills FOR c_taulaf1.x1
                                            || f_map_replace(c_taulaf1.x2, NULL,
                                                             REPLACE(vlinia, '''',
                                                                     '''||chr(39)||'''),
                                                             pcmapead, vsepara, NULL, NULL,
                                                             ptag);

                           -- fin Bug 0016529 - 14/12/2010 - JMF
                           FETCH c_fills
                            INTO vliniafills;

                           --p_control_error('maptime', 'despres select fill '||c_taulaf1.ctabla, dbms_utility.get_time);
                           LOOP
                              IF c_fills%NOTFOUND THEN
                                 EXIT;
                              ELSE
                                 FOR c_fill2 IN cfulles_valorpropi(c_taulaf1.ctabla) LOOP
                                    p_map_debug(psmapead, pcmapead, ptag, c_fill2.nordfill,
                                                c_fill2.ttag, pliniapare, vlinia,
                                                c_fill2.ttag, NULL, c_fill2.tcondicion, NULL,
                                                c_taulaf1.ctabla, 4,
                                                SUBSTR('Linia pels fills ' || vliniafills, 1,
                                                       500));

                                    --                 IF f_genera_cond_valida(c_fill2.ncondicion, vsepara, vliniafills) THEN
                                    IF f_condicion_valida(vttipomap, c_fill2.tcondicion,
                                                          vliniafills, vsepara, pcmapead,
                                                          NULL) THEN
/***********************************/
                                       IF c_fill2.ctablafills = -1 THEN
                                          -- es compleix la condició, per tant tornem a cridar a la funció amb el c_taulaf2.ttag com a pare
                                          vnodepare := vg_node;   --guardat per quan tornem de la F_genera
                                          nerror :=
                                             f_genera(ptag, c_fill2.ttag, c_fill2.nordfill,
                                                      REPLACE(vliniafills, '''',
                                                              '''||chr(39)||'''));

                                          IF nerror <> 0 THEN
                                             RETURN(nerror);
                                          END IF;

                                          vg_node := vnodepare;
                                       ELSE
/********************************************/

                                          -- es compleix la condició, per tant hen de recuperar el valor i inserir el tag
                                          IF c_fill2.ctipcampo = 4 THEN   -- Mirem si es un valor fixe
                                             vvalor := c_fill2.tmascara;
                                          ELSIF c_fill2.ctipcampo = 6 THEN
                                             vvalor :=
                                                f_valor_linia('|', vliniafills,
                                                              c_fill2.nposicion,
                                                              c_fill2.nlongitud);

                                             EXECUTE IMMEDIATE f_map_replace
                                                                            (c_fill2.tmascara,
                                                                             vvalor,
                                                                             pliniapare,
                                                                             pcmapead,
                                                                             vsepara, vlinia,
                                                                             NULL,
                                                                             c_fill2.ttag)
                                                         USING OUT vvalor;
                                          ELSE
                                             vvalor :=
                                                f_valor_linia('|', vliniafills,
                                                              c_fill2.nposicion,
                                                              c_fill2.nlongitud);
                                          END IF;

                                          p_map_debug(psmapead, pcmapead, ptag,
                                                      c_fill2.nordfill, c_fill2.ttag,
                                                      pliniapare, vlinia, c_fill2.ttag, NULL,
                                                      c_fill2.tcondicion, NULL,
                                                      c_taulaf1.ctabla, 4,
                                                      SUBSTR('Valor trobat ' || vvalor, 1, 500));

                                          IF (vvalor IS NOT NULL) THEN
                                             p_genera_linia(vttipomap, pcmapead, vvalor,
                                                            c_taulaf1.ctabla,
                                                            c_fill2.nordfill, c_fill2.ttag,
                                                            ptag, vsepara, c_fill2.catributs);
                                          END IF;
                                       END IF;
                                    END IF;
                                 END LOOP;

                                 IF vttipomap <> 3 THEN
                                    IF vttipomap = 2 THEN
                                       IF vg_linia IS NOT NULL THEN
                                          vg_linia :=
                                             SUBSTR(vg_linia, 1,
                                                    LENGTH(vg_linia) - LENGTH(vsepara));
                                       END IF;
                                    END IF;

                                    IF vg_linia IS NOT NULL THEN
                                       UTL_FILE.put_line(vg_idfitxer, vg_linia);
                                    END IF;

                                    vg_numlin := vg_numlin + 1;
                                    vg_linia := '';
                                 END IF;
                              END IF;

                              FETCH c_fills
                               INTO vliniafills;
                           END LOOP;
                        END LOOP;

                        -- Tractem els fills branca
                        FOR c_taulaf2 IN ctaulesbranques LOOP
                           p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare,
                                       vlinia, NULL, NULL, NULL, NULL, NULL, 2,
                                       SUBSTR('FILLS BRANQUES. tag ' || c_taulaf2.ttag
                                              || ', norden ' || c_taulaf2.nordfill,
                                              1, 500));
                           -- es compleix la condició, per tant tornem a cridar a la funció amb el c_taulaf2.ttag com a pare
                           vnodepare := vg_node;   --guardat per quan tornem de la F_genera
                           nerror := f_genera(ptag, c_taulaf2.ttag, c_taulaf2.nordfill,
                                              REPLACE(vlinia, '''', '''||chr(39)||'''));

                           IF nerror <> 0 THEN
                              RETURN(nerror);
                           END IF;

                           vg_node := vnodepare;
                        END LOOP;
                     ELSE
                        RETURN(nerror);
                     END IF;
                  END IF;   -- De que es cumpleix la condició
               END LOOP;   -- De les condicions
            END IF;   -- Hem trobat un registre a la taula fills

                 -- recuperem el següent registre de la select del tag que tractem
            --p_control_error('maptime', 'abans select propia 2 '||ptag, dbms_utility.get_time);
            FETCH c_pare
             INTO vlinia;

            --p_control_error('maptime', 'despres select propia 2 '||ptag, dbms_utility.get_time);
            vg_node := vnodepare2;
         END LOOP;

         RETURN nerror;
      END f_genera;

      FUNCTION consultar_jgm(p_tconsulta IN CLOB, p_resultado IN OUT NOCOPY vector)
         RETURN NUMBER IS
         l_thecursor    INTEGER;
         l_columnvalue  VARCHAR2(32000);
         l_desctbl      DBMS_SQL.desc_tab2;   -- MSR Canviat perquè no falli per nom de columnes de 33 o més caracters
         l_colcnt       NUMBER;
         es_consulta    BOOLEAN;
         vr_consulta    DBMS_SQL.varchar2a;
         v_nlongitud    NUMBER;
         v_index        NUMBER;
         v_nparts       NUMBER;
         -- Utilitzat per indicar tipus de dades a DEFINE_COLUMN.
         -- Sempre li direm que es VARCHAR2 independentment del que realemnt sigui la columna
         -- perquè ens faci la conversió implícita a VARCHAR2 si no ho és.
         k_columndatatype CONSTANT VARCHAR2(32767) := NULL;
         -- En cas que ja tingui dades, les afegirem a p_resultado
         k_primer_index NUMBER := NVL(p_resultado.LAST, 0);
         v_filas_procesadas NUMBER;
         v_pasexec      NUMBER := 0;
      BEGIN
         -- Permetem posar espais, tabuladors, .. sense que ens falli la detecció que és un SELECT
         es_consulta := REGEXP_INSTR(p_tconsulta, '^[[:space:]]*SELECT', modifier => 'i') > 0;
         -- BUG10700 Permetem una longitud indeterminada per la consulta
         v_nlongitud := LENGTH(p_tconsulta);
         v_nparts := 1;
         v_index := 1;
         v_pasexec := 1;

         LOOP
            vr_consulta(v_index) := SUBSTR(p_tconsulta, v_nparts, 32767);
            v_nparts := v_nparts + 32767;
            EXIT WHEN v_nparts > v_nlongitud;
            v_index := v_index + 1;
         END LOOP;

         v_pasexec := 2;
         l_thecursor := DBMS_SQL.open_cursor;
         DBMS_SQL.parse(l_thecursor, vr_consulta, 1, v_index, FALSE, DBMS_SQL.native);

         IF es_consulta THEN
            -- Obtenim les columnes que torna el SELECT
            DBMS_SQL.describe_columns2(l_thecursor, l_colcnt, l_desctbl);

            FOR i IN 1 .. l_colcnt LOOP
               -- Indiquem que totes les columnes ens les torni com VARCHAR2
               DBMS_SQL.define_column(l_thecursor, i, k_columndatatype, 32767);
               -- Assignem el nom tornat per la columna a la posicó 0 dels resultat
               p_resultado(0)(i) := l_desctbl(i).col_name;
            END LOOP;
         END IF;

         v_pasexec := 3;
         v_filas_procesadas := DBMS_SQL.EXECUTE(l_thecursor);

         IF es_consulta THEN
            -- Per un SELECT recorrem tots els registres i per cada registre desem
            -- el valor de la columna a la variable 'resultado'
            WHILE(DBMS_SQL.fetch_rows(l_thecursor) > 0) LOOP
               FOR i IN 1 .. l_colcnt LOOP
                  DBMS_SQL.COLUMN_VALUE(l_thecursor, i, l_columnvalue);
                  p_resultado(k_primer_index + DBMS_SQL.last_row_count)(i) := l_columnvalue;
               END LOOP;
            END LOOP;
         END IF;

         v_pasexec := 4;
         DBMS_SQL.close_cursor(l_thecursor);
         RETURN 0;
      EXCEPTION
         WHEN OTHERS THEN
            IF DBMS_SQL.is_open(l_thecursor) THEN
               DBMS_SQL.close_cursor(l_thecursor);
            END IF;

            p_tab_error(f_sysdate, f_user, 'PAC_ISQL.CONSULTAR', v_pasexec, SQLCODE, SQLERRM);
            RAISE;
      END consultar_jgm;

      FUNCTION f_genera_dinamic(
         ppare IN VARCHAR2,
         ptag IN VARCHAR2,
         pnordfill IN NUMBER,
         pliniapare IN VARCHAR2)
         RETURN NUMBER IS
         CURSOR ctaulesfulles(pvlinia IN VARCHAR2) IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   'SELECT '
                     || DECODE(tt.ctabla, 0, '''' || pvlinia || ''' linea', 'linea')
                     -- ini Bug 0016529 - 14/12/2010 - JMF
                     --|| ' FROM '
                     --|| f_map_replace(tt.tfrom, NULL, pvlinia, pcmapead, vsepara, NULL, NULL,ptag) selfulles,
                     || ' FROM ' x1,
                     tt.tfrom x2,
                                 -- fin Bug 0016529 - 14/12/2010 - JMF
                                 tt.ctabla
                FROM map_xml tx, map_det_tratar trat, map_tabla tt, map_cab_tratar c,
                     map_comodin mc, map_comodin mc1, map_comodin mc2
               WHERE c.nveces = trat.nveces
                 AND c.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND(c.ctabla = tt.ctabla
                     OR tt.ctabla = 0)
                 AND tt.ctabla = trat.ctabla
                 AND trat.norden = tx.norden
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.ctablafills IS NULL   -- Es una fulla
                 AND tx.cmapead = mc2.cmapcom
                 AND mc2.cmapead = pcmapead
                 AND tx.tpare = ptag
            GROUP BY 'SELECT ' || DECODE(tt.ctabla, 0, '''' || pvlinia || ''' linea', 'linea')
                     -- ini Bug 0016529 - 14/12/2010 - JMF
                     --|| ' FROM '
                     --|| f_map_replace(tt.tfrom, NULL, pvlinia, pcmapead, vsepara, NULL, NULL,ptag),
                     || ' FROM ',
                     tt.tfrom,
                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              tt.ctabla
            ORDER BY MIN(tx.nordfill);

         CURSOR cfulles_valorpropi(pctaula IN NUMBER) IS
            -- Fills que tenen el seu valor en la seva propia linia
            SELECT   tx.ttag, trat.tcondicion, tx.nordfill, det.nposicion, det.nlongitud,
                     trat.ctipcampo, trat.tmascara, tx.catributs
                FROM map_xml tx, map_det_tratar trat, map_detalle det, map_comodin mc,
                     map_comodin mc1
               WHERE trat.cmapead = det.cmapead
                 AND trat.ctabla = pctaula
                 AND trat.norden = det.norden
                 AND det.cmapead = mc.cmapcom
                 AND mc.cmapead = pcmapead
                 AND det.norden = tx.norden
                 --AND det.ttag = tx.ttag ---OR det.ttag IS NULL)
                 AND tx.ctablafills IS NULL   -- Es una fulla
                 AND tx.cmapead = mc1.cmapcom
                 AND mc1.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill;

         CURSOR ctaulesbranques IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   tx.ttag, tx.nordfill
                FROM map_xml tx, map_comodin c
               WHERE tx.ctablafills IS NOT NULL   -- Es una branca
                 AND tx.cmapead = c.cmapcom
                 AND c.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill, tx.ttag;

         vselpare       VARCHAR2(32000);
         vselatributs   VARCHAR2(32000);
         vselorden      map_detalle.norden%TYPE;
         vcondi         map_det_tratar.tcondicion%TYPE;

         TYPE t_cursor IS REF CURSOR;

         c_pare         t_cursor;
         c_atri         t_cursor;
         c_fills        t_cursor;
         vlinia         VARCHAR2(2000);
         vliniaatri     VARCHAR2(4000);
         vliniafills    VARCHAR2(4000);
         vnomatri       VARCHAR2(100);
         vvalatri       VARCHAR2(4000);
         vvalor         VARCHAR2(32000);
         nerror         NUMBER := 0;
         vnodepare      xmldom.domnode;
         vnodepare2     xmldom.domnode;
      BEGIN
         -- recuperem la select del tag que estem tractant
         SELECT 'SELECT ' || DECODE(tt.ctabla, 0, '''' || pliniapare || ''' linea', 'linea')
                || ' FROM '
                || f_map_replace(tt.tfrom, NULL, pliniapare, pcmapead, vsepara, NULL, NULL,
                                 ptag),
                tx.norden
           INTO vselpare,
                vselorden
           FROM map_xml tx, map_tabla tt, map_comodin c
          WHERE tt.ctabla = tx.ctablafills
            AND tx.cmapead = c.cmapcom
            AND c.cmapead = pcmapead
            AND tx.tpare = ppare
            AND tx.nordfill = pnordfill
            AND tx.ttag = ptag;

         p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag, pliniapare, NULL, NULL, NULL,
                     NULL, NULL, NULL, 1,
                     SUBSTR('Vttipomap ' || vttipomap || '; Select Propia ' || vselpare, 1,
                            500));

         OPEN c_pare FOR vselpare;

         FETCH c_pare
          INTO vlinia;

         LOOP
            IF c_pare%NOTFOUND THEN
               EXIT;
            ELSE
               FOR c_condi IN (SELECT trat.tcondicion
                                 FROM map_det_tratar trat, map_comodin c
                                WHERE trat.cmapead = c.cmapcom
                                  AND c.cmapead = pcmapead
                                  AND trat.norden = vselorden
                               UNION
                               SELECT '0'
                                 FROM DUAL
                                WHERE NOT EXISTS(
                                         SELECT trat.tcondicion
                                           FROM map_det_tratar trat, map_comodin c
                                          WHERE trat.cmapead = c.cmapcom
                                            AND c.cmapead = pcmapead
                                            AND trat.norden = vselorden)) LOOP
                  IF f_condicion_valida(vttipomap, c_condi.tcondicion, vlinia, vsepara,
                                        pcmapead, NULL) THEN
                     vlinia := f_valor_parametro('|', vlinia, vselorden, pcmapead);
                     nerror := f_genera_node(vttipomap, pcmapead, ppare, ptag, vlinia,
                                             vsepara);

                     IF nerror = 0 THEN   -- Si no es vol fer cap tractament s'hauria d'afegir AQUI una condicio
                        -- Tractem els fills fulles que tenen el seu valor en una linia propia
                        FOR c_taulaf1 IN ctaulesfulles(REPLACE(vlinia, '''',
                                                               '''||chr(39)||''')) LOOP
                           FOR i IN 0 .. ROUND(NVL(LENGTH(c_taulaf1.ctabla), 1) / 500, 0) LOOP
                              p_map_debug(psmapead, pcmapead, ppare, pnordfill, ptag,
                                          pliniapare, vlinia, NULL, NULL, NULL, NULL,
                                          c_taulaf1.ctabla, 3,
                                          SUBSTR('FILLS FULLES VALOR LINEA PROPI ',
                                                 i * 500 + 1, 500));
                           END LOOP;

                           -- ini Bug 0016529 - 14/12/2010 - JMF
                           --IF INSTR(SUBSTR(UPPER( c_taulaf1.selfulles ), 19), 'SELECT') = 0
                           IF INSTR
                                   (SUBSTR(UPPER(c_taulaf1.x1
                                                 || f_map_replace(c_taulaf1.x2, NULL,
                                                                  REPLACE(vlinia, '''',
                                                                          '''||chr(39)||'''),
                                                                  pcmapead, vsepara, NULL,
                                                                  NULL, ptag)),
                                           19),
                                    'SELECT') = 0
                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              AND c_taulaf1.ctabla <> 0 THEN   --SI cosa_pac_cuadre
                              DECLARE
                                 valoressql     vector;
                                 v_result       NUMBER;
                                 w_sentencia    VARCHAR2(32000);   -- Bug 12600.NMM.01/2010. Ampliem la longitud de w_sortida
                              BEGIN
                                 --NOTA: El código tiene que tener el formato de una función PL/SQL
                                 --sin comentarios ni puntos y coma ni varias lineas;
                                 --por ejemplo:
                                 --pac_cuadre_adm.f_selec_cuenta(to_number(Pac_MAP.f_valor_parametro('|','#lineaini',1,#cmapead)),'2',f_sysdate,1,0)
                                 -- Bug 12600.NMM.01/2010. Ampliem la longitud de w_sortida
                                 EXECUTE IMMEDIATE ' declare w_sortida VARCHAR2(32000);begin w_sortida:='
                                                   -- ini Bug 0016529 - 14/12/2010 - JMF
                                                   --|| SUBSTR(c_taulaf1.selfulles, 19)
                                                   || SUBSTR
                                                        (c_taulaf1.x1
                                                         || f_map_replace
                                                                  (c_taulaf1.x2, NULL,
                                                                   REPLACE(vlinia, '''',
                                                                           '''||chr(39)||'''),
                                                                   pcmapead, vsepara, NULL,
                                                                   NULL, ptag),
                                                         19)
                                                   -- fin Bug 0016529 - 14/12/2010 - JMF
                                                   || '; :w_sentencia := w_sortida; end;'
                                             USING OUT w_sentencia;

                                 v_result := consultar_jgm(w_sentencia, valoressql);

                                 FOR contador IN valoressql.FIRST + 1 .. valoressql.LAST LOOP
                                    FOR v_i IN 1 .. valoressql(0).LAST LOOP
                                       vg_linia :=
                                               vg_linia || valoressql(contador)(v_i)
                                               || vsepara;
                                    END LOOP;

                                    IF vttipomap <> 3 THEN
                                       IF vttipomap = 2 THEN
                                          IF vg_linia IS NOT NULL THEN
                                             vg_linia :=
                                                SUBSTR(vg_linia, 1,
                                                       LENGTH(vg_linia) - LENGTH(vsepara));
                                          END IF;
                                       END IF;

                                       IF vg_linia IS NOT NULL THEN
                                          UTL_FILE.put_line(vg_idfitxer, vg_linia);
                                       END IF;

                                       vg_numlin := vg_numlin + 1;
                                       vg_linia := '';
                                    END IF;
                                 END LOOP;
                              END;
                           ELSE
                              -- ini Bug 0016529 - 14/12/2010 - JMF
                              --OPEN c_fills FOR c_taulaf1.selfulles;
                              OPEN c_fills FOR c_taulaf1.x1
                                               || f_map_replace(c_taulaf1.x2, NULL,
                                                                REPLACE(vlinia, '''',
                                                                        '''||chr(39)||'''),
                                                                pcmapead, vsepara, NULL, NULL,
                                                                ptag);

                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              FETCH c_fills
                               INTO vliniafills;

                              LOOP
                                 IF c_fills%NOTFOUND THEN
                                    EXIT;
                                 ELSE
                                    FOR c_fill2 IN cfulles_valorpropi(c_taulaf1.ctabla) LOOP
                                       p_map_debug(psmapead, pcmapead, ptag, c_fill2.nordfill,
                                                   c_fill2.ttag, pliniapare, vlinia,
                                                   c_fill2.ttag, NULL, c_fill2.tcondicion,
                                                   NULL, c_taulaf1.ctabla, 4,
                                                   SUBSTR('Linia pels fills ' || vliniafills,
                                                          1, 500));

                                       --                 IF f_genera_cond_valida(c_fill2.ncondicion, vsepara, vliniafills) THEN
                                       IF f_condicion_valida(vttipomap, c_fill2.tcondicion,
                                                             vliniafills, vsepara, pcmapead,
                                                             NULL) THEN
                                          -- es compleix la condició, per tant hen de recuperar el valor i inserir el tag
                                          IF c_fill2.ctipcampo = 4 THEN   -- Mirem si es un valor fixe
                                             vvalor := c_fill2.tmascara;
                                          ELSIF c_fill2.ctipcampo = 6 THEN
                                             vvalor :=
                                                f_valor_linia('|', vliniafills,
                                                              c_fill2.nposicion,
                                                              c_fill2.nlongitud);

                                             EXECUTE IMMEDIATE f_map_replace
                                                                            (c_fill2.tmascara,
                                                                             vvalor,
                                                                             pliniapare,
                                                                             pcmapead,
                                                                             vsepara, vlinia,
                                                                             NULL,
                                                                             c_fill2.ttag)
                                                         USING OUT vvalor;
                                          ELSE
                                             vvalor :=
                                                f_valor_linia('|', vliniafills,
                                                              c_fill2.nposicion,
                                                              c_fill2.nlongitud);
                                          END IF;

                                          p_map_debug(psmapead, pcmapead, ptag,
                                                      c_fill2.nordfill, c_fill2.ttag,
                                                      pliniapare, vlinia, c_fill2.ttag, NULL,
                                                      c_fill2.tcondicion, NULL,
                                                      c_taulaf1.ctabla, 4,
                                                      SUBSTR('Valor trobat ' || vvalor, 1, 500));
                                          p_genera_linia(vttipomap, pcmapead, vvalor,
                                                         c_taulaf1.ctabla, c_fill2.nordfill,
                                                         c_fill2.ttag, ptag, vsepara,
                                                         c_fill2.catributs);
                                       END IF;
                                    END LOOP;

                                    IF vttipomap <> 3 THEN
                                       IF vttipomap = 2 THEN
                                          IF vg_linia IS NOT NULL THEN
                                             vg_linia :=
                                                SUBSTR(vg_linia, 1,
                                                       LENGTH(vg_linia) - LENGTH(vsepara));
                                          END IF;
                                       END IF;

                                       IF vg_linia IS NOT NULL THEN
                                          UTL_FILE.put_line(vg_idfitxer, vg_linia);
                                       END IF;

                                       vg_numlin := vg_numlin + 1;
                                       vg_linia := '';
                                    END IF;
                                 END IF;

                                 FETCH c_fills
                                  INTO vliniafills;
                              END LOOP;
                           END IF;
                        END LOOP;
                     ELSE
                        RETURN(nerror);
                     END IF;
                  END IF;   -- De que es cumpleix la condició
               END LOOP;   -- De les condicions
            END IF;   -- Hem trobat un registre a la taula fills

            -- recuperem el següent registre de la select del tag que tractem
            FETCH c_pare
             INTO vlinia;

            vg_node := vnodepare2;
         END LOOP;

         RETURN nerror;
      END f_genera_dinamic;
   BEGIN
      IF pcmapead IS NULL THEN
         RETURN(112223);   --es obligatori informar un nom de fitxer
      END IF;

      SELECT smapead.NEXTVAL
        INTO psmapead
        FROM DUAL;

      BEGIN
         -- recuperem la informació de capçalera del fitxer
         SELECT cseparador, ttipomap, ttipotrat
           INTO vsepara, vttipomap, vttipotrat
           FROM map_cabecera
          WHERE cmapead = pcmapead;
      EXCEPTION
         WHEN OTHERS THEN
            p_tab_error(f_sysdate, f_user, 'pac_MAP.genera_xml', 1,
                        'Error incontrolado al buscar datos en MAP_cabecera', SQLERRM);
            RETURN(151539);
      END;

      -- la condició del pare sempre serà 0 sino son fitxers diferents
      SELECT x.ttag
        INTO varrel
        FROM map_xml x, map_comodin c
       WHERE x.cmapead = c.cmapcom
         AND c.cmapead = pcmapead
         AND x.tpare = '0';

      IF vttipotrat = 'D' THEN
         --JGM - bug 11338 - 07/10/2009;
         nerr := f_genera_dinamic('0', varrel, 1, vg_liniaini);
      ELSE
         nerr := f_genera('0', varrel, 1, vg_liniaini);
      END IF;

      UTL_FILE.fclose(vg_idfitxer);
      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         UTL_FILE.fclose(vg_idfitxer);
         p_tab_error(f_sysdate, f_user, 'pac_MAP.genera_MAP', 2, 'Error incontrolado',
                     SQLERRM);
         RETURN(151633);
   END genera_map;

   FUNCTION f_genera_map(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0,
      pcconruta IN NUMBER DEFAULT NULL)
      RETURN VARCHAR2 IS
-----------------------------------------------------------------
-- EAS, CPM 18/11/2004
-- Función para ser llamada desde un map de procesos. Ejecuta la
--   función genera_MAP .
-- No está pensada para ejecutarse con maps tipo XML ya que en este caso
--   se entiende que será una interfaz online y que se usará la función
--   f_int del package pac_int_online
-----------------------------------------------------------------
      vsmapead       NUMBER;
      nerror         NUMBER;
   BEGIN
      p_genera_parametros_fichero(pcmapead, pliniaini, pnomfitxer, pdebug, pcconruta);
      nerror := genera_map(pcmapead, vsmapead);
      RETURN(nerror || '|' || vsmapead);
   END f_genera_map;

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
      pcadena IN VARCHAR2) IS
-----------------------------------------------------------------
-- EAS, CPM 14/07/2005
-- Realitza l'insert en la taula MAP_DEBUG si correspon
-----------------------------------------------------------------
      PRAGMA AUTONOMOUS_TRANSACTION;
      xcmapead       VARCHAR2(5);
      xtpare         VARCHAR2(60);
      xnordfill      NUMBER(4);
      xtag           VARCHAR2(60);
      x              VARCHAR2(32000);
   BEGIN
      IF vg_deb_orden < 9998 THEN
         IF (ptipo <= vg_debug
             AND vg_deb_orden <= 5000)
            OR(ptipo <= LEAST(vg_debug, 3)
               AND vg_deb_orden > 5000) THEN
            IF psmapead IS NULL
               OR pcmapead IS NULL
               OR ptpare IS NULL
               OR nordfill IS NULL
               OR ptag IS NULL THEN
               SELECT cmapead, tpare, nordfill, ttag
                 INTO xcmapead, xtpare, xnordfill, xtag
                 FROM map_debug
                WHERE smapead = vg_deb_smap
                  AND nordendeb = vg_deb_orden;
            ELSIF vg_deb_orden = 0 THEN
               vg_deb_smap := psmapead;
            END IF;

            INSERT INTO map_debug
                        (smapead, cmapead,
                         tpare, nordfill,
                         ttag, nordendeb,
                         tliniapare, tlinia,
                         tcampo, nnumlin, tcondicion,
                         ctabla, nveces, ncondi, ctipo, tmensaje, fdebug)
                 VALUES (vg_deb_smap, NVL(pcmapead, xcmapead),
                         SUBSTR(NVL(ptpare, xtpare), 1, 60), NVL(nordfill, xnordfill),
                         SUBSTR(NVL(ptag, xtag), 1, 60), vg_deb_orden + 1,
                         SUBSTR(pliniapare, 1, 1000), SUBSTR(plinia, 1, 1000),
                         SUBSTR(pcamp, 1, 30), vg_numlin, SUBSTR(ptcondicion, 1, 1000),
                         ptabla, pnveces, pncondi, ptipo, SUBSTR(pcadena, 1, 500), f_sysdate);

            COMMIT;
            vg_deb_orden := vg_deb_orden + 1;
         END IF;
      ELSIF vg_deb_orden = 9998 THEN
         IF psmapead IS NULL
            OR pcmapead IS NULL
            OR ptpare IS NULL
            OR nordfill IS NULL
            OR ptag IS NULL THEN
            SELECT cmapead, tpare, nordfill, ttag
              INTO xcmapead, xtpare, xnordfill, xtag
              FROM map_debug
             WHERE smapead = vg_deb_smap
               AND nordendeb = vg_deb_orden;
         ELSIF vg_deb_orden = 0 THEN
            vg_deb_smap := psmapead;
         END IF;

         INSERT INTO map_debug
                     (smapead, cmapead,
                      tpare, nordfill,
                      ttag, nordendeb,
                      tliniapare, tlinia,
                      tcampo, nnumlin, tcondicion, ctabla,
                      nveces, ncondi, ctipo, tmensaje, fdebug)
              VALUES (vg_deb_smap, NVL(pcmapead, xcmapead),
                      SUBSTR(NVL(ptpare, xtpare), 1, 60), NVL(nordfill, xnordfill),
                      SUBSTR(NVL(ptag, xtag), 1, 60), vg_deb_orden + 1,
                      SUBSTR(pliniapare, 1, 1000), SUBSTR(plinia, 1, 1000),
                      SUBSTR(pcamp, 1, 30), vg_numlin, SUBSTR(ptcondicion, 1, 1000), ptabla,
                      pnveces, pncondi, ptipo, 'Máximo número de lineas en el DEBUG', f_sysdate);

         COMMIT;
         vg_deb_orden := vg_deb_orden + 1;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_MAP.p_map_debug', 2, 'Error incontrolado',
                     SUBSTR(SQLERRM, 1, 2500));
         COMMIT;
   END p_map_debug;

-----------------------------------------------------------------
-- SBG 10/2008
-- Funció NO genèrica, només extraccions (maps que no generin XML)
-----------------------------------------------------------------
   FUNCTION f_extraccion(
      p_cmapead IN VARCHAR2,
      p_linea IN VARCHAR2,
      p_fich_in IN VARCHAR2 DEFAULT NULL,
      p_fich_out OUT VARCHAR2)
      RETURN NUMBER IS
      num_err        NUMBER;
      v_path         map_cabecera.tparpath%TYPE;
      v_ttipomap     NUMBER(2);
      v_ttipotrat    VARCHAR2(1);
      v_tdesmap      VARCHAR2(30);
      v_ruta         VARCHAR2(100);
      v_smapead      NUMBER;
      v_cfichero     NUMBER;
      v_tparpath     map_cabecera.tparpath%TYPE;
      wconruta       NUMBER := NULL;
   --
   BEGIN
      SELECT tparpath || '_C',   -- BUG12913:DRA:10/02/2010
                              tdesmap, ttipomap, ttipotrat, tparpath
        INTO v_path, v_tdesmap, v_ttipomap, v_ttipotrat, v_tparpath
        FROM map_cabecera
       WHERE cmapead = p_cmapead;

      IF v_ttipomap = 3 THEN   -- ES UN FICHERO XML
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_EXTRACCION', 1,
                     'NO SE PUEDE REALIZAR LA EXTRACCIÓN DE UN FORMATO XML', 'TTIPOMAP = 3');
         RETURN -1;   -- NO SE PUEDE REALIZAR LA EXTRACCIÓN DE UN FORMATO XML ? LO PODEMOS DEFINIR EN EL FUTURO
      ELSIF v_ttipomap < 3 THEN   -- ES UN FICHERO PLANO
         --Ini Bug.: 14701 - ICV - 27/05/2010
         --Si el tparpath es un númerico miramos si existe en ficheros_rutas
         BEGIN
            v_cfichero := v_tparpath;
            v_ruta := pac_nombres_ficheros.ff_ruta_fichero(pac_md_common.f_get_cxtempresa,
                                                           v_cfichero, 2);   --TPATH_C
         EXCEPTION
            WHEN VALUE_ERROR THEN   --Si da error de no númerico o no existe en la tabla nos quedamos con el tparpath
               NULL;
         END;

         IF v_ruta IS NULL THEN
            v_ruta := f_parinstalacion_t(v_path);
         END IF;

         --Fin Bug.: 14701
         p_fich_out := v_ruta || '\' || NVL(p_fich_in, v_tdesmap);
      END IF;

      IF v_ttipotrat NOT IN('G', 'D') THEN   --OPCION GENERACION or dinamico --JGM bug 13461 - 08/04/2010
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_EXTRACCION', 2,
                     'NO ES UN MAP DE GENERACIÓN', 'TTIPOTRAT <> ''G''');
         RETURN -2;   -- ERROR NO ES UN MAP DE GENERACION
      END IF;

      pac_map.p_genera_parametros_fichero(p_cmapead, p_linea, NVL(p_fich_in, v_tdesmap), 0,
                                          wconruta);
      num_err := pac_map.genera_map(p_cmapead, v_smapead);
      RETURN num_err;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_EXTRACCION', 3, 'Error no controlado',
                     SQLERRM);
         RETURN -3;
   END f_extraccion;

   /*************************************************************************
       FUNCTION F_GET_NOMFICHERO
       Función que retornará la ruta y el fichero creado.
       param in PMAP: Id. del Map
       return             : Devolverá una cadena con la ruta y código del fichero generado.
   *************************************************************************/
   FUNCTION f_get_nomfichero(pmap IN VARCHAR2)
      RETURN VARCHAR2 IS
      wpath          map_cabecera.tparpath%TYPE;
      wtdesmap       map_cabecera.tdesmap%TYPE;
      wttipomap      map_cabecera.ttipomap%TYPE;
      wruta          parinstalacion.tvalpar%TYPE;
      vtparpath      map_cabecera.tparpath%TYPE;
      v_cfichero     NUMBER;
   BEGIN
      SELECT tparpath || '_C', tdesmap, ttipomap, tparpath
        INTO wpath, wtdesmap, wttipomap, vtparpath
        FROM map_cabecera
       WHERE cmapead = pmap;

      IF wttipomap < 3 THEN   -- ES UN FICHERO PLANO
         --Ini Bug.: 14701 - ICV - 27/05/2010
         --Si el tparpath es un númerico miramos si existe en ficheros_rutas
         BEGIN
            v_cfichero := vtparpath;
            wruta := pac_nombres_ficheros.ff_ruta_fichero(pac_md_common.f_get_cxtempresa,
                                                          v_cfichero, 2);   --tpath_c
         EXCEPTION
            WHEN VALUE_ERROR THEN   --Si da error de no númerico o no existe en la tabla nos quedamos con el tparpath
               NULL;
         END;

         IF wruta IS NULL THEN
            wruta := f_parinstalacion_t(wpath);
         END IF;
      --Fin Bug.: 14701
      END IF;

      RETURN wruta || '\' || wtdesmap;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_GET_NOMFICHERO', 1,
                     'Error buscando el map, PMAP :' || pmap, SQLERRM);
         RETURN NULL;
   END f_get_nomfichero;

   /*************************************************************************
       FUNCTION F_get_tipomap
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       return             : Devolverá una numérico con el tipo de fichero que genera el map.
   *************************************************************************/
   FUNCTION f_get_tipomap(pmap IN VARCHAR2)
      RETURN NUMBER IS
      v_ttipomap     map_cabecera.ttipomap%TYPE;
   BEGIN
      SELECT ttipomap
        INTO v_ttipomap
        FROM map_cabecera
       WHERE cmapead = pmap;

      RETURN v_ttipomap;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_GET_TIPOMAP', 1,
                     'Error buscando el tipo de map, PMAP :' || pmap, SQLERRM);
         RETURN NULL;
   END f_get_tipomap;

   /*************************************************************************
       FUNCTION F_get_ejereport
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       return             : Devolverá una numérico indicando si puede ejecutar reports.
                            0- No 1 - Si

       Bug 14067 - 13/04/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_ejereport(pmap IN VARCHAR2)
      RETURN NUMBER IS
      v_report       map_cabecera.genera_report%TYPE;
   BEGIN
      SELECT NVL(genera_report, 0)
        INTO v_report
        FROM map_cabecera
       WHERE cmapead = pmap;

      RETURN v_report;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_get_ejereport', 1,
                     'Error buscando si puede generar reports un map, PMAP :' || pmap,
                     SQLERRM);
         RETURN NULL;
   END f_get_ejereport;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmapead =' || pcmapead || ' - pttipomap =' || pttipomap || ' - pcseparador ='
            || pcseparador || ' - pcmapcomodin =' || pcmapcomodin || ' - pttipotrat ='
            || pttipotrat || ' - ptcomentario =' || ptcomentario || ' - ptparametros ='
            || ptparametros || ' - pcmanten =' || pcmanten || ' - ptparametros ='
            || ptparametros || ' - pgenera_report =' || pgenera_report;
      vobject        VARCHAR2(200) := 'PAC_MAP.F_set_mapcabecera';
      vnumerr        NUMBER := 0;
      trobat         BOOLEAN := FALSE;
      vcmapead       VARCHAR2(20) := pcmapead;
   BEGIN
      IF pcmapead IS NULL THEN
         FOR i IN (SELECT   cmapead
                       FROM map_cabecera
                   ORDER BY cmapead DESC) LOOP
            BEGIN
               vcmapead := TO_NUMBER(i.cmapead);
               vcmapead := vcmapead + 1;
               EXIT;
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END LOOP;

         INSERT INTO map_codigos
                     (cmapead, tmapead)
              VALUES (vcmapead, ptdesmap);
      END IF;

      BEGIN
         INSERT INTO map_cabecera
                     (cmapead, tdesmap, tparpath, ttipomap, cseparador, cmapcomodin,
                      ttipotrat, tcomentario, tparametros, cmanten, genera_report)
              VALUES (vcmapead, ptdesmap, ptparpath, pttipomap, pcseparador, pcmapcomodin,
                      pttipotrat, ptcomentario, ptparametros, pcmanten, pgenera_report);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_cabecera
               SET tdesmap = ptdesmap,
                   tparpath = ptparpath,
                   ttipomap = pttipomap,
                   cseparador = pcseparador,
                   cmapcomodin = pcmapcomodin,
                   ttipotrat = pttipotrat,
                   tcomentario = ptcomentario,
                   tparametros = ptparametros,
                   cmanten = pcmanten,
                   genera_report = pgenera_report
             WHERE cmapead = vcmapead;
      END;

      pcmapead_salida := vcmapead;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.F_set_mapcabecera', 1,
                     'Error insertando map_cabecera, PMAP :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapcabecera;

   FUNCTION f_set_mapcomodin(pcmapead IN VARCHAR2, pcmapcom IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      BEGIN
         INSERT INTO map_comodin
                     (cmapead, cmapcom)
              VALUES (pcmapead, pcmapcom);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_comodin
               SET cmapcom = pcmapcom
             WHERE cmapead = pcmapead;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapcomodin', 1,
                     'Error insertando map_comodin, PMAP :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapcomodin;

   FUNCTION f_del_mapcomodin(pcmapead IN VARCHAR2, pcmapcom IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_comodin
            WHERE cmapead = pcmapead
              AND cmapcom = pcmapcom;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_mapcomodin', 1,
                     'Error insertando map_comodin, PMAP :' || pcmapead, SQLERRM);
         RETURN 108017;
   END f_del_mapcomodin;

   FUNCTION f_set_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptsenten IN VARCHAR2,
      pcparam IN NUMBER,
      pcpragma IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pctabla =' || pctabla || ' - pnveces =' || pnveces
            || ' - ptsenten =' || ptsenten || ' - pcparam =' || pcparam || ' - pcpragma ='
            || pcpragma;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapbabtratar';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM map_tabla
       WHERE ctabla = pctabla;

      IF vcont = 0 THEN
         RETURN 9903584;
      END IF;

      BEGIN
         INSERT INTO map_cab_tratar
                     (cmapead, ctabla, nveces, tsenten, cparam, cpragma)
              VALUES (pcmapead, pctabla, pnveces, ptsenten, pcparam, pcpragma);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_cab_tratar
               SET tsenten = ptsenten,
                   cparam = pcparam,
                   cpragma = pcpragma
             WHERE cmapead = pcmapead
               AND ctabla = pctabla
               AND nveces = pnveces;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapcab_tratar', 1,
                     'Error insertando map_comodin, PMAP :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapcabtratar;

   FUNCTION f_del_mapcabtratar(pcmapead IN VARCHAR2, pctabla IN NUMBER, pnveces IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnveces =' || pnveces || ' - pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapcabtratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_cab_tratar
            WHERE cmapead = pcmapead
              AND ctabla = pctabla
              AND nveces = pnveces;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_map_cabtratar', 1,
                     'Error borrando map_cabtratar, PMAP :' || pcmapead, SQLERRM);
         RETURN 108017;
   END f_del_mapcabtratar;

   FUNCTION f_set_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      pcatributs IN NUMBER,
      pctablafills IN NUMBER,
      pnorden IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - ptpare =' || ptpare || ' - pnordfill ='
            || pnordfill || ' - pttag =' || pttag || ' - pcatributs =' || pcatributs
            || ' - pctablafills =' || pctablafills;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapxml';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      /* SELECT COUNT(1)
         INTO vcont
         FROM map_xml
        WHERE cmapead = pcmapead
          AND tpare = ptpare
          AND nordfill = pnordfill
          AND ttag = pttag;

       IF vcont > 0 THEN
          RETURN 108959;
       END IF;*/
      BEGIN
         INSERT INTO map_xml
                     (cmapead, tpare, nordfill, ttag, catributs, ctablafills, norden)
              VALUES (pcmapead, ptpare, pnordfill, pttag, pcatributs, pctablafills, pnorden);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_xml
               SET catributs = pcatributs,
                   ctablafills = pctablafills,
                   norden = NVL(pnorden, norden)
             WHERE cmapead = pcmapead
               AND tpare = ptpare
               AND nordfill = pnordfill
               AND ttag = pttag;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapxml', 1,
                     'Error insertando mapxml, PMAP :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapxml;

   FUNCTION f_del_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pTPARE =' || ptpare || ' - pNORDFILL ='
            || pnordfill || 'pTTAG = ' || pttag;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapxml';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_xml
            WHERE cmapead = pcmapead
              AND tpare = ptpare
              AND nordfill = pnordfill
              AND ttag = pttag;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_mapxml', 1,
                     'Error borrando map_xml, PMAP :' || pcmapead, SQLERRM);
         RETURN 108017;
   END f_del_mapxml;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      pttag IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden || ' - pnposicion ='
            || pnposicion || ' - pnlongitud =' || pnlongitud || ' - pttag =' || pttag;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapdetalle';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      IF pttag IS NOT NULL THEN
         SELECT COUNT(1)
           INTO vcont
           FROM map_detalle
          WHERE cmapead = pcmapead
            AND ttag = pttag;

         IF vcont > 0 THEN
            RETURN 108959;
         END IF;
      END IF;

      BEGIN
         INSERT INTO map_detalle
                     (cmapead, norden, nposicion, nlongitud, ttag)
              VALUES (pcmapead, pnorden, pnposicion, pnlongitud, pttag);

         UPDATE map_xml
            SET norden = pnorden
          WHERE ttag = pttag
            AND cmapead = pcmapead;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_detalle
               SET nposicion = pnposicion,
                   nlongitud = pnlongitud
             WHERE cmapead = pcmapead
               AND norden = pnorden;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapdetalle', 1,
                     'Error insertando mapdetalle, PMAP :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapdetalle;

   FUNCTION f_del_mapdetalle(pcmapead IN VARCHAR2, pnorden IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapdetalle';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_detalle
            WHERE cmapead = pcmapead
              AND norden = pnorden;

      DELETE      map_det_tratar
            WHERE cmapead = pcmapead
              AND norden = pnorden;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_mapxml', 1,
                     'Error borrando map_xml, PMAP :' || pcmapead, SQLERRM);
         RETURN 108017;
   END f_del_mapdetalle;

   FUNCTION f_set_maptabla(
      pctabla IN NUMBER,
      ptfrom IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pctabla_out OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctabla =' || pctabla || ' - ptfrom =' || ptfrom || ' - ptdescrip =' || ptdescrip;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_maptabla';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
      vctabla        NUMBER := pctabla;
   BEGIN
      /* IF pctabla IS NULL THEN
          RETURN 103135;
       END IF;*/
      IF pctabla IS NULL THEN
         SELECT MAX(ctabla) + 1
           INTO vctabla
           FROM map_tabla;
      END IF;

      BEGIN
         INSERT INTO map_tabla
                     (ctabla, tfrom, tdescrip)
              VALUES (vctabla, ptfrom, ptdescrip);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_tabla
               SET tfrom = ptfrom,
                   tdescrip = ptdescrip
             WHERE ctabla = pctabla;
      END;

      pctabla_out := vctabla;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_maptabla', 1,
                     'Error insertando maptabla, pctabla :' || pctabla, SQLERRM);
         RETURN 806310;
   END f_set_maptabla;

   FUNCTION f_del_maptabla(pctabla IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_maptabla';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pctabla IS NULL THEN
         RETURN 103135;
      END IF;

      SELECT COUNT(1)
        INTO vcont
        FROM map_det_tratar
       WHERE ctabla = pctabla;

      IF vcont > 0 THEN
         RETURN 1000402;
      END IF;

      DELETE      map_tabla
            WHERE ctabla = pctabla;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_maptabla', 1,
                     'Error borrando map_tabla, pctabla :' || pctabla, SQLERRM);
         RETURN 108017;
   END f_del_maptabla;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapdettratar';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pcmapead IS NULL
         OR ptcondicion IS NULL
         OR pnveces IS NULL
         OR pctabla IS NULL
         OR ptcampo IS NULL
         OR pnorden IS NULL
         OR ptsetwhere IS NULL THEN
         RETURN 103135;
      END IF;

      IF pctabla IS NOT NULL THEN
         SELECT COUNT(1)
           INTO vcont
           FROM map_tabla
          WHERE ctabla = pctabla;

         IF vcont = 0 THEN
            RETURN 9903592;
         END IF;
      END IF;

      BEGIN
         INSERT INTO map_det_tratar
                     (cmapead, tcondicion, ctabla, nveces, tcampo, ctipcampo,
                      tmascara, norden, tsetwhere)
              VALUES (pcmapead, ptcondicion, pctabla, pnveces, ptcampo, pctipcampo,
                      ptmascara, pnorden, ptsetwhere);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_det_tratar
               SET ctipcampo = pctipcampo,
                   tmascara = ptmascara
             WHERE cmapead = pcmapead
               AND tcondicion = ptcondicion
               AND ctabla = pctabla
               AND nveces = pnveces
               AND tcampo = ptcampo
               AND norden = pnorden
               AND tsetwhere = ptsetwhere;
      END;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapdettratar', 1,
                     'Error insertando mapdettratar, pcmapead :' || pcmapead, SQLERRM);
         RETURN 806310;
   END f_set_mapdettratar;

   FUNCTION f_del_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapdettratar';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pcmapead IS NULL
         OR ptcondicion IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL
         OR ptcampo IS NULL
         OR pnorden IS NULL
         OR ptsetwhere IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_det_tratar
            WHERE cmapead = pcmapead
              AND tcondicion = ptcondicion
              AND ctabla = pctabla
              AND nveces = pnveces
              AND tcampo = ptcampo
              AND norden = pnorden
              AND tsetwhere = ptsetwhere;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_mapdettratar', 1,
                     'Error borrando mapdettratar, pcmapead :' || pcmapead, SQLERRM);
         RETURN 108017;
   END f_del_mapdettratar;

   FUNCTION f_set_mapcondicion(
      pncondicion IN NUMBER,
      ptvalcond IN VARCHAR2,
      pnposcond IN NUMBER,
      pnlongcond IN NUMBER,
      pnordcond IN NUMBER,
      pctabla IN NUMBER,
      pncondicion_out OUT NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pncondicion =' || pncondicion || ',ptvalcond=' || ptvalcond || ',pnposcond='
            || pnposcond || ',pnlongcond=' || pnlongcond || ',pnordcond=' || pnordcond
            || ',pctabla=' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_set_mapcondicion';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
      vncondicion    NUMBER := pncondicion;
   BEGIN
      IF pncondicion IS NULL THEN
         SELECT MAX(ncondicion) + 1
           INTO vncondicion
           FROM map_condicion;
      END IF;

      IF pctabla IS NOT NULL THEN
         SELECT COUNT(1)
           INTO vcont
           FROM map_tabla
          WHERE ctabla = pctabla;

         IF vcont = 0 THEN
            RETURN 9903592;
         END IF;
      END IF;

      BEGIN
         INSERT INTO map_condicion
                     (ncondicion, tvalcond, nposcond, nlongcond, nordcond, ctabla)
              VALUES (vncondicion, ptvalcond, pnposcond, pnlongcond, pnordcond, pctabla);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE map_condicion
               SET tvalcond = ptvalcond,
                   nposcond = pnposcond,
                   nlongcond = pnlongcond,
                   nordcond = pnordcond,
                   ctabla = pctabla
             WHERE ncondicion = pncondicion;
      END;

      pncondicion_out := vncondicion;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_set_mapcondicion', 1,
                     'Error insertando mapcondicion, pncondicion :' || pncondicion, SQLERRM);
         RETURN 806310;
   END f_set_mapcondicion;

   FUNCTION f_del_mapcondicion(pncondicion IN NUMBER)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pncondicion =' || pncondicion;
      vobject        VARCHAR2(200) := 'PAC_MAP.f_del_mapcondicion';
      vnumerr        NUMBER := 0;
      vcont          NUMBER;
   BEGIN
      IF pncondicion IS NULL THEN
         RETURN 103135;
      END IF;

      DELETE      map_condicion
            WHERE ncondicion = pncondicion;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'PAC_MAP.f_del_mapcondicion', 1,
                     'Error borrando mapcondicion, pncondicion :' || pncondicion, SQLERRM);
         RETURN 108017;
   END f_del_mapcondicion;
/*  */
END pac_map;

/

  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MAP" TO "PROGRAMADORESCSI";
