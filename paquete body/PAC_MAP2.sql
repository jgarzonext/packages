--------------------------------------------------------
--  DDL for Package Body PAC_MAP2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MAP2" IS
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
   END;

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
   END;

   FUNCTION f_vgnode
      RETURN xmldom.domnode IS
   BEGIN
      RETURN vg_node;
   END;

   FUNCTION f_vgdocument
      RETURN xmldom.domdocument IS
   BEGIN
      RETURN vg_domdoc;
   END;

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
         RETURN NULL;
   END;

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
   END;

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
   END;

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
   -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
   EXCEPTION
      WHEN OTHERS THEN
         IF c_condicio%ISOPEN THEN
            CLOSE c_condicio;
         END IF;

         RETURN FALSE;
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
                     RETURN -1;
               --               dbms_sql.close_cursor(ncursor);
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
   END;

   PROCEDURE p_carga_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0) IS
      vtdesmap       map_cabecera.tdesmap%TYPE;
      vtparpath      map_cabecera.tparpath%TYPE;
      vttipotrat     map_cabecera.ttipotrat%TYPE;
      vpath          VARCHAR2(100);
   BEGIN
      -- recuperem la informació de capçalera del fitxer
      SELECT tdesmap, tparpath, ttipotrat
        INTO vtdesmap, vtparpath, vttipotrat
        FROM map_cabecera
       WHERE cmapead = pcmapead;

      IF vttipotrat <> 'A' THEN
         vpath := f_parinstalacion_t(vtparpath);

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
   END;

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
                              --f_map_replace (tt.tfrom,NULL,pliniapare,pcmapead,vsepara,vg_linia,psmapead,ptag) taula,
                              tt.tfrom,
                                       -- fin Bug 0016529 - 14/12/2010 - JMF
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
                     tx.ttag IN(SELECT tx2.tpare
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
                                 vvalores := psmapead || ', ' || pcmapead || ', ';
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
                                       /*
                                       --sense mascara
                                        SELECT TO_NUMBER('23,23') FROM dual;
                                           SQL> 23,23

                                       --amb mascara
                                       SELECT TO_NUMBER(TO_CHAR(2323, '99,99')) FROM dual;
                                       SQL> 23,23
                                       SELECT TO_NUMBER(TO_CHAR(23.23, '99D99')) FROM dual;
                                       SQL> 23,23
                                       */

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
                                    --vsent := 'insert into '||c_taulaf1.taula||' ('||vcampos||') values ('||vvalores||')';
                                    vsent := 'insert into '
                                             || f_map_replace(c_taulaf1.tfrom, NULL,
                                                              pliniapare, pcmapead, vsepara,
                                                              vg_linia, psmapead, ptag)
                                             || ' (' || vcampos || ') values (' || vvalores
                                             || ')';
                                 -- fin Bug 0016529 - 14/12/2010 - JMF
                                 END IF;
                              ELSIF c_taulaf1.tsenten = 'U' THEN
                                 IF vset IS NULL THEN
                                    vsent := NULL;
                                 ELSE
                                    vset := SUBSTR(vset, 1, LENGTH(vset) - 2);
                                    vwhere := SUBSTR(vwhere, 1, LENGTH(vwhere) - 4);
                                      -- ini Bug 0016529 - 14/12/2010 - JMF
                                    --vsent := 'update '||c_taulaf1.taula||' set '||vset||' where '||vwhere;
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
                                 --vsent := 'delete '||c_taulaf1.taula||' where '||vwhere;
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
               FETCH c_pare
                INTO vlinia;

               vg_node := vnodepare2;
            END LOOP;
         END IF;

         RETURN nerror;
      EXCEPTION
         WHEN OTHERS THEN
            -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
            IF c_pare%ISOPEN THEN
               CLOSE c_pare;
            END IF;

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
      v_msg := CONVERT(v_msg, 'WE8ISO8859P1', 'UTF8');
      RETURN(v_msg);
   END;

   FUNCTION f_obtener_xml
      RETURN xmldom.domdocument IS
   BEGIN
      RETURN(vg_domdoc);
   END;

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
   END;

   PROCEDURE p_genera_parametros_fichero(
      pcmapead IN VARCHAR2,
      pliniaini IN VARCHAR2,
      pnomfitxer IN VARCHAR2 DEFAULT NULL,
      pdebug IN NUMBER DEFAULT 0) IS
      vtdesmap       map_cabecera.tdesmap%TYPE;
      vtparpath      map_cabecera.tparpath%TYPE;
      vpath          VARCHAR2(100);
   BEGIN
      -- recuperem la informació de capçalera del fitxer
      SELECT tdesmap, tparpath
        INTO vtdesmap, vtparpath
        FROM map_cabecera
       WHERE cmapead = pcmapead;

      vpath := f_parinstalacion_t(vtparpath);

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
   EXCEPTION
      WHEN OTHERS THEN
         UTL_FILE.fclose(vg_idfitxer);
         p_tab_error(f_sysdate, f_user, 'pac_MAP.p_genera_parametros_fichero', 1,
                     'Error incontrolado al abrir fichero', SQLERRM);
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
      varrel         map_xml.tpare%TYPE;
      mynode         xmldom.domnode;
      nerr           NUMBER;
      v_msg          VARCHAR2(32000);

      FUNCTION f_genera(
         ppare IN VARCHAR2,
         ptag IN VARCHAR2,
         pnordfill IN NUMBER,
         pliniapare IN VARCHAR2)
         RETURN NUMBER IS
         CURSOR ctaulesfulles(pvlinia IN VARCHAR2) IS
            -- Taules dels fills que tenen el seu valor en la seva propia linia
            --  Agrupem per les diferents taules per tractar-los a l'hora
            SELECT   'SELECT '
                     || DECODE(DECODE(tt.ctabla, -1, 0, tt.ctabla),
                               0, '''' || pvlinia || ''' linea',
                               'linea')
                     ||
                          -- ini Bug 0016529 - 14/12/2010 - JMF
                        --' FROM '||f_map_replace (tt.tfrom, NULL, pvlinia, pcmapead, vsepara, NULL, NULL,ptag) selFulles,
                     ' FROM ' x1,
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
                     OR tx.ctablafills = -1)   -- Es una fulla
                 AND tx.cmapead = mc2.cmapcom
                 AND mc2.cmapead = pcmapead
                 AND tx.tpare = ptag
            GROUP BY 'SELECT '
                     || DECODE(DECODE(tt.ctabla, -1, 0, tt.ctabla),
                               0, '''' || pvlinia || ''' linea',
                               'linea')
                     ||
                          -- ini Bug 0016529 - 14/12/2010 - JMF
                        --' FROM '||f_map_replace (tt.tfrom, NULL, pvlinia, pcmapead, vsepara,NULL, NULL,ptag),
                     ' FROM ',
                     tt.tfrom,
                              -- fin Bug 0016529 - 14/12/2010 - JMF
                              DECODE(tt.ctabla, -1, 0, tt.ctabla)
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
                 --tx.ttag IN (select tx2.tpare from MAP_XML tx2 WHERE tx.cmapead = tx2.cmapead)
                 AND tx.cmapead = c.cmapcom
                 AND c.cmapead = pcmapead
                 AND tx.tpare = ptag
            ORDER BY tx.nordfill, tx.ttag;

         vselpare       VARCHAR2(4000);
         vselatributs   VARCHAR2(4000);
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
         vvalor         VARCHAR2(4000);
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
                     vnodepare2 := vg_node;   --guardat per si tenim més d'una fila de la select del pare
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
                           --OPEN c_fills FOR c_taulaf1.selFulles;
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
            FETCH c_pare
             INTO vlinia;

            vg_node := vnodepare2;
         END LOOP;

         RETURN nerror;
      -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos, se adiciona EXCEPTION
      EXCEPTION
         WHEN OTHERS THEN
            IF c_pare%ISOPEN THEN
               CLOSE c_pare;
            END IF;

            IF c_fills%ISOPEN THEN
               CLOSE c_fills;
            END IF;
      END f_genera;
   BEGIN
      IF pcmapead IS NULL THEN
         RETURN(112223);   --es obligatori informar un nom de fitxer
      END IF;

      SELECT smapead.NEXTVAL
        INTO psmapead
        FROM DUAL;

      BEGIN
         -- recuperem la informació de capçalera del fitxer
         SELECT cseparador, ttipomap
           INTO vsepara, vttipomap
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

      nerr := f_genera('0', varrel, 1, vg_liniaini);
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
      pdebug IN NUMBER DEFAULT 0)
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
      p_genera_parametros_fichero(pcmapead, pliniaini, pnomfitxer, pdebug);
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
      RETURN NUMBER IS
      v_obj          VARCHAR2(0100) := 'Pac_Map2.f_genera_xml';
      v_par          VARCHAR2(1000)
            := 'pcmapead=' || pcmapead || ' pparam=' || pparam || ' pnomfitxer=' || pnomfitxer;
      v_error        NUMBER;
      vsmapead       NUMBER;

      CURSOR c_xml(pcmapead IN VARCHAR2) IS
         SELECT x.tcharset
           FROM map_cabecera_xml x
          WHERE x.cmapead = pcmapead;

      r_xml          c_xml%ROWTYPE;
      vnom           VARCHAR2(50);
      doc            xmldom.domdocument;
      e_map_error    EXCEPTION;
      vdescerror     VARCHAR2(512);
      v_nomfitx      VARCHAR2(100);
   BEGIN
      p_genera_parametros_xml(pcmapead, pparam);
      v_error := pac_map2.genera_map(pcmapead, vsmapead);

      IF v_error <> 0 THEN
         vdescerror := 'Error el generar el MAP ' || pcmapead;
         RAISE e_map_error;
      END IF;

      OPEN c_xml(pcmapead);

      FETCH c_xml
       INTO r_xml;

      CLOSE c_xml;

      vnom := f_parinstalacion_t('INFORMES');

      IF pnomfitxer IS NULL THEN
         v_nomfitx := pac_map.f_get_nomfichero(pcmapead);
         v_nomfitx := SUBSTR(v_nomfitx, INSTR(v_nomfitx, '\', -1) + 1);
      ELSE
         v_nomfitx := pac_map.f_get_nomfichero(pcmapead);
         v_nomfitx := SUBSTR(v_nomfitx, INSTR(v_nomfitx, '\', -1) + 1);
         v_nomfitx := v_nomfitx || '_' || pnomfitxer;
      END IF;

      doc := f_obtener_xml;
      xmldom.writetofile(doc, vnom || '\' || v_nomfitx || '.xml', NVL(r_xml.tcharset, 'UTF-8'));
      p_fgenerado := f_parinstalacion_t('INFORMES_C') || '\' || v_nomfitx || '.xml';
      RETURN 0;
   EXCEPTION
      WHEN e_map_error THEN
         p_tab_error(f_sysdate, f_user, v_obj || ' ' || pcmapead, 1,
                     vdescerror || ':' || SQLCODE || ':' || v_par, SQLERRM);
         RETURN 1;
      WHEN OTHERS THEN
         -- BUG -21546_108724- 07/02/2012 - JLTS - Cierre de posibles cursores abiertos
         IF c_xml%ISOPEN THEN
            CLOSE c_xml;
         END IF;

         p_tab_error(f_sysdate, f_user, 'pac_MAP2.f_genera_xml', 2, 'Error incontrolado',
                     SUBSTR(SQLERRM, 1, 2500));
         RETURN 1;
   END f_genera_xml;
END;

/

  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MAP2" TO "PROGRAMADORESCSI";
