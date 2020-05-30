--------------------------------------------------------
--  DDL for Package Body PAC_CAMPANAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CAMPANAS" IS
   /******************************************************************************
      NOMBRE:       PAC_CAMPANAS
      PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla CAMPANAS

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        30/08/2011   FAL                1. Creación del package.0019298: LCOL_C001 - Desarrollo de campañas
   ******************************************************************************/

   TYPE fichero_mail IS RECORD(
      cagente  NUMBER,
      pnomfich VARCHAR2(200));

   TYPE t_fichero_mail IS TABLE OF fichero_mail;
   fichero t_fichero_mail;

   /*************************************************************************
    Función que realiza la búsqueda de campañas a partir de los criterios de consulta entrados
    param in pccodigo     : codigo campaña
    param in pcestado     : estado campaña
    param in pfinicam     : fecha inicio campaña
    param in pffincam     : fecha fin campaña
    param out pquery      : colección de objetos ob_iax_campana
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_buscar(pccodigo IN VARCHAR2,
                     pcestado IN VARCHAR2,
                     pfinicam IN DATE,
                     pffincam IN DATE,
                     pquery   OUT VARCHAR2) RETURN NUMBER IS
      vpar   VARCHAR2(2000) := ' c=' || pccodigo || ' e=' || pcestado ||
                               ' fi=' || pfinicam || ' ff=' || pffincam;
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_buscar';
      vwhere VARCHAR2(2000);
   BEGIN
      IF pccodigo IS NOT NULL
      THEN
         vwhere := vwhere || ' and ccodigo = ' || pccodigo;
      END IF;

      IF pcestado IS NOT NULL
      THEN
         vwhere := vwhere || ' and cestado = ' || pcestado;
      END IF;

      IF pfinicam IS NOT NULL
      THEN
         vwhere := vwhere || ' and trunc(finicam) >= ' || chr(39) ||
                   pfinicam || chr(39);
      END IF;

      IF pffincam IS NOT NULL
      THEN
         vwhere := vwhere || ' and trunc(ffincam) <= ' || chr(39) ||
                   pffincam || chr(39) || ' OR ffincam is null';
      END IF;

      pquery := 'SELECT CCODIGO, TDESCRIP, CESTADO, FINICAM, FFINCAM, IVALINI, IPREMIO, IVTAPRV, IVTAREA,CMEDIOS,
          NAGECAM, NAGEGAN, TOBSERV, CEXCCRR, CEXCNEWP, FINIREC, FFINREC, CCONVEN
          FROM CAMPANAS WHERE 1=1 ';
      pquery := pquery || vwhere || ' order by ccodigo ';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_buscar;

   /*************************************************************************
    Función que permite ver/editar el detalle de la campaña
    param in pccodigo     : codigo campaña
    param out pobcampana  : objeto ob_iax_campana
         return             : 0 edición correcta
                           <> 0 edición incorrecta
   *************************************************************************/
   FUNCTION f_editar(pccodigo IN VARCHAR2,
                     pquery   OUT VARCHAR2,
                     pquery2  OUT VARCHAR2,
                     pquery3  OUT VARCHAR2,
                     pquery4  OUT VARCHAR2) RETURN NUMBER IS
   BEGIN
      IF pccodigo IS NULL
      THEN
         RETURN 1;
      END IF;

      -- select para obtener la informacion de campañas
      pquery := 'SELECT CCODIGO, TDESCRIP, CESTADO, FINICAM, FFINCAM, IVALINI, IPREMIO, IVTAPRV, IVTAREA,
          CMEDIOS,
          NAGECAM, NAGEGAN, TOBSERV, CEXCCRR, CEXCNEWP, FINIREC, FFINREC, CCONVEN FROM CAMPANAS WHERE ccodigo = ' ||
                pccodigo;
      --´select para obtener la productos asociados a una campaña
      pquery2 := 'SELECT ccodigo, cp.sproduc,
       (SELECT ttitulo FROM titulopro WHERE cramo = pr.cramo AND cmodali = pr.cmodali AND ctipseg = pr.ctipseg AND ccolect = pr.ccolect AND cidioma = ' ||
                 f_idiomauser ||
                 ') tproduc, cp.cactivi, decode(cp.cactivi, -1, null, (SELECT ttitulo FROM activisegu WHERE cactivi = gp.cactivi AND cramo = pr.cramo AND cidioma = ' ||
                 f_idiomauser ||
                 ')) tactivi, cp.cgarant, decode (cp.cgarant, -1, null,(SELECT tgarant FROM garangen WHERE cgarant = gp.cgarant AND cidioma = ' ||
                 f_idiomauser ||
                 ')) tgarant FROM campaprd cp, productos pr, garanpro gp WHERE ccodigo = ' ||
                 pccodigo || '  AND pr.sproduc = cp.sproduc ' ||
                 '  AND gp.cramo = pr.cramo ' ||
                 '  AND gp.cmodali = pr.cmodali ' ||
                 '  AND gp.ctipseg = pr.ctipseg ' ||
                 '  AND gp.ccolect = pr.ccolect ' ||
                 '  AND cp.cgarant = gp.cgarant' ||
                 ' union SELECT distinct(ccodigo), cp.sproduc, ' ||
                 '  (SELECT ttitulo FROM titulopro ' ||
                 '  WHERE cramo = pr.cramo ' ||
                 '  AND cmodali = pr.cmodali ' ||
                 '  AND ctipseg = pr.ctipseg ' ||
                 '  AND ccolect = pr.ccolect ' || '  AND cidioma = ' ||
                 f_idiomauser || ') tproduc, ' || '  -1, null, -1, null ' ||
                 '  FROM campaprd cp, productos pr ' ||
                 '  WHERE cp.ccodigo =  ' || pccodigo ||
                 ' AND pr.sproduc = cp.sproduc and cgarant = -1 ';
      --´select para obtener los agentes asignados a una campaña
      pquery3 := 'SELECT CCODIGO, CAGENTE, F_DESAGENTE_T(CAGENTE) TAGENTE, FINICAM, FFINCAM
                  FROM CAMPAAGE WHERE ccodigo = ' ||
                 pccodigo || ' AND BGANADOR = ''N''';
      --´select para obtener los agentes ganadores asignados a una campaña
      pquery4 := 'SELECT CCODIGO, CAGENTE, F_DESAGENTE_T(CAGENTE) TAGENTE, FINICAM, FFINCAM
                  FROM CAMPAAGE WHERE ccodigo = ' ||
                 pccodigo || ' AND BGANADOR = ''S''';
      RETURN 0;
   END f_editar;

   /*************************************************************************
    Función que permite guardar los cambios realizados en  el detalle de la campaña
    param in pccodigo     : codigo campaña
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/
   FUNCTION f_grabar(pccodigo  IN VARCHAR2,
                     ptdescrip IN VARCHAR2,
                     pcestado  IN VARCHAR2,
                     pfinicam  IN DATE,
                     pffincam  IN DATE,
                     pivalini  IN NUMBER,
                     pipremio  IN NUMBER,
                     pivtaprv  IN NUMBER,
                     pivtarea  IN NUMBER,
                     pcmedios  IN VARCHAR2,
                     pnagecam  IN NUMBER,
                     pnagegan  IN NUMBER,
                     ptobserv  IN VARCHAR2,
                     pcexccrr  IN NUMBER,
                     pcexcnewp IN NUMBER,
                     pfinirec  IN DATE,
                     pffinrec  IN DATE,
                     pcconven  IN VARCHAR2) RETURN NUMBER IS
      vcmedios VARCHAR2(8);
      vmodif   NUMBER(1) := 0;
   BEGIN
      BEGIN
         INSERT INTO campanas
            (ccodigo, tdescrip, cestado, finicam, ffincam, ivalini, ipremio,
             ivtaprv, ivtarea, cmedios, nagecam, nagegan, tobserv, cexccrr,
             cexcnewp, finirec, ffinrec, cconven)
         VALUES
            (pccodigo, ptdescrip, pcestado, pfinicam, pffincam, pivalini,
             pipremio, pivtaprv, pivtarea, pcmedios, pnagecam, pnagegan,
             ptobserv, pcexccrr, pcexcnewp, pfinirec, pffinrec, pcconven);
      EXCEPTION
         WHEN dup_val_on_index THEN
            UPDATE campanas
               SET tdescrip = ptdescrip,
                   cestado  = pcestado,
                   finicam  = pfinicam,
                   ffincam  = pffincam,
                   ivalini  = pivalini,
                   ipremio  = pipremio,
                   ivtaprv  = pivtaprv,
                   ivtarea  = pivtarea,
                   cmedios  = pcmedios,
                   nagecam  = pnagecam,
                   nagegan  = pnagegan,
                   tobserv  = ptobserv,
                   cexccrr  = pcexccrr,
                   cexcnewp = pcexcnewp,
                   finirec  = pfinirec,
                   ffinrec  = pffinrec,
                   cconven  = pcconven
             WHERE ccodigo = pccodigo;

            vmodif := 1;
      END;

      IF vmodif = 0
      THEN
         --Una vez grabada la campaña, grabamos la documentación
         BEGIN
            INSERT INTO campadoc
            VALUES
               (pccodigo, 1, 'Documento de Alta (Carta_Alta.jrxml)');

            INSERT INTO campadoc
            VALUES
               (pccodigo, 2, 'Documento de Baja (Carta_Baja.jrxml)');
         EXCEPTION
            WHEN OTHERS THEN
               RETURN 1;
         END;
      END IF;

      -- Si viene informada la finalización de campaña, grabamos las fechas de finalización a los agentes
      IF pcestado = 2
      THEN
         UPDATE campaage
            SET ffincam = NVL(pffincam, f_sysdate)
          WHERE ccodigo = pccodigo
            AND ffincam IS NULL;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_grabar;

   /*************************************************************************
    Función que permite guardar los cambios realizados en los prods/activs/garants asociados a la campaña
    param in pccodigo     : código campaña
    param in psproduc     : código producto asociado a campaña
    param in pcactivi     : código actividad asociado a campaña
    param in pcgarant     : código garantia asociado a campaña
         return             : 0 grabación correcta
                           <> 0 grabación incorrecta
   *************************************************************************/
   FUNCTION f_grabar_campaprd(pccodigo IN VARCHAR2,
                              psproduc IN NUMBER,
                              pcactivi IN NUMBER,
                              pcgarant IN NUMBER) RETURN NUMBER IS
   BEGIN
      DELETE FROM campaprd
       WHERE ccodigo = pccodigo
         AND sproduc = psproduc;

      INSERT INTO campaprd
         (ccodigo, sproduc, cactivi, cgarant)
      VALUES
         (pccodigo, psproduc, pcactivi, pcgarant);

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 1;
   END f_grabar_campaprd;

   /*************************************************************************
    Función que permite generar las cartas de alta/anulación de la campaña a los agentes asociados
    param in pccodigo     : codigo campaña
         return             : 0 generación cartas correcta
                           <> 0 generación cartas incorrecta
   *************************************************************************/
   FUNCTION f_cartear(pctipocarta IN VARCHAR2,
                      pccodigo    IN VARCHAR2) RETURN NUMBER IS
   BEGIN
      /*
      IF pctipocarta = 'ALTA' THEN
        select
        from campadoc C, doc_docurequerida D, campaagedoc G, campaprd P
        where C.cdocume = D.cdocume AND
              C.ctipdoc = -- v.f. tipocarta...pdte.definir "ANULA" AND
              C.ccodigo = pccodigo AND
              C.ccodigo = G.ccodigo AND
              G.cdocume = C.cdocume AND
              G.bgenerado <> 'S' AND
              D.sproduc = P.sproduc AND
              D.cactivi = P.cactivi AND
              C.ccodigo = P.ccodigo;
      ELSIF pctipocarta = 'ANULA' THEN
        select
        from campadoc C, doc_docurequerida D, campaagedoc G, campaprd P
        where C.cdocume = D.cdocume AND
              C.ctipdoc = -- v.f. tipocarta...pdte.definir "ANULA" AND
              C.ccodigo = pccodigo AND
              C.ccodigo = G.ccodigo AND
              G.cdocume = C.cdocume AND
              G.bgenerado <> 'S' AND
              D.sproduc = P.sproduc AND
              D.cactivi = P.cactivi AND
              C.ccodigo = P.ccodigo;
      END IF;
      */
      NULL;
   END f_cartear;

   -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
   /*************************************************************************
    FUNCTION f_get_agentes_campa
    Funcion que permite buscar agentes que pueden participar en las campañas
    param in pcmodo     : modo acceso (ASIGNAR'|'DESASIGNAR')
    param in pccodigo   : código campaña
    param in pfinicam   : fecha inicio campaña
    param in pctipage   : tipo agente
    param in pcagente   : código agente
    param out pquery    : select a ejecutar
    return              : number
   *************************************************************************/
   FUNCTION f_get_agentes_campa(pcmodo   IN VARCHAR2,
                                pccodigo IN NUMBER,
                                pfinicam IN DATE,
                                pctipage IN NUMBER,
                                pcagente IN NUMBER,
                                pempresa IN NUMBER,
                                pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_get_agentes_campa';
      vwhere VARCHAR2(2000);
      vpar   VARCHAR2(2000) := ' c=' || pcmodo || ' e=' || pccodigo ||
                               ' fi=' || pfinicam || ' t=' || pctipage ||
                               ' a=' || pcagente;
   BEGIN
      IF pcmodo = 'ASIGNAR'
      THEN
         pquery := 'SELECT C.cagente, C.ctipage, P.tnombre || ' || chr(39) || ' ' ||
                   chr(39) || ' ||  P.tapelli1 || ' || chr(39) || ' ' ||
                   chr(39) ||
                   ' || P.tapelli2 Nombre, (SELECT CP.IMETA FROM CAMPAAGE CP WHERE CP.CAGENTE= C.CAGENTE AND CP.CCODIGO = NVL( ' ||
                   pccodigo || ', NULL)) ' ||
                   ' FROM agentes C, redcomercial R, per_detper P WHERE C.cagente = R.cagente  ' ||
                   ' AND c.cagente = NVL(' ||
                   NVL(TO_CHAR(pcagente), 'NULL') || ',c.cagente)' ||
                   ' AND C.cactivo = 1 ' || ' AND C.ctipage = NVL(' ||
                   NVL(TO_CHAR(pctipage), 'NULL') || ',c.ctipage)' ||
                   ' AND (C.fbajage IS NULL OR trunc(C.fbajage) >= trunc(f_sysdate))' ||
                   ' AND R.cempres = ' || TO_CHAR(pempresa) ||
                   ' AND R.fmovfin is null ' ||
                   ' AND P.sperson = C.sperson (+) ' ||
                   ' AND NOT EXISTS (SELECT 1 FROM campaage WHERE cagente = C.cagente AND ccodigo = ' ||
                   TO_CHAR(pccodigo) || ' AND ffincam is null) order by 1 ';
      ELSIF pcmodo = 'DESASIGNAR'
      THEN
         pquery := 'SELECT C.ccodigo, C.cagente, C.ctipage, C.finicam, C.ffincam, C.bganador, P.tnombre || ' ||
                   chr(39) || ' ' || chr(39) || ' ||  P.tapelli1 || ' ||
                   chr(39) || ' ' || chr(39) ||
                   ' || P.tapelli2 Nombre FROM campaage C, per_detper P,  agentes G WHERE C.cagente = G.cagente and p.sperson = g.sperson ' ||
                   ' AND ccodigo = NVL( ' || NVL(TO_CHAR(pccodigo), 'NULL') ||
                   ', ccodigo)' || ' AND c.cagente = NVL(' ||
                   NVL(TO_CHAR(pcagente), 'NULL') || ',c.cagente)' ||
                   ' AND trunc(finicam) = NVL(' || chr(39) ||
                   TO_CHAR(pfinicam) || chr(39) || ',finicam)' ||
                   ' AND c.ctipage = NVL(' ||
                   NVL(TO_CHAR(pctipage), 'NULL') ||
                   ',c.ctipage) order by 1,2 ';
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_agentes_campa;

   /*************************************************************************
    FUNCTION f_set_agentes_campa
    Funcion que permite asignar/eliminar agentes a las campaña
    return             : number
   *************************************************************************/
   FUNCTION f_set_agentes_campa(pcmodo   IN VARCHAR2,
                                pccodigo IN NUMBER,
                                pcagente IN NUMBER,
                                pctipage IN NUMBER,
                                pfinicam IN DATE,
                                pffincam IN DATE,
                                pimeta   IN NUMBER) RETURN NUMBER IS
      vlin NUMBER;
      vobj VARCHAR2(200) := 'pac_campanas.f_set_agentes_campa';
      vpar VARCHAR2(2000) := 'pcmodo-pccodigo-pcagente-pfinicam-pctipage-pffincam-pimeta: ' ||
                             pcmodo || '-' || pccodigo || '-' || pcagente || '-' ||
                             pfinicam || '-' || pctipage || '-' || pffincam || '-' ||
                             pimeta;
   BEGIN
      IF pcmodo = 'ASIGNAR'
      THEN
         BEGIN
            INSERT INTO campaage
               (ccodigo, cagente, ctipage, finicam, ffincam, bganador,
                imeta)
            VALUES
               (pccodigo, pcagente, pctipage, pfinicam, pffincam, 'N',
                pimeta);
         EXCEPTION
            WHEN dup_val_on_index THEN
               UPDATE campaage
                  SET ffincam = NULL
                WHERE ccodigo = pccodigo
                  AND cagente = pcagente
                  AND imeta = pimeta;
         END;
      ELSIF pcmodo = 'DESASIGNAR'
      THEN
         UPDATE campaage
            SET ffincam = pffincam
          WHERE ccodigo = pccodigo
            AND cagente = pcagente
            AND imeta = pimeta;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_set_agentes_campa;

   -- Fi Bug 0019298

   -- 31/08/2011. FAL. 0019298: LCOL_C001 - Desarrollo de campañas
   /*************************************************************************
    FUNCTION f_get_productos_campa
    Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
    param in pcramo     : codigo del ramo
    param in psproduc   : código del producto
    param in pcactivi   : codigo de la actividad
    param in pcgarant   : codigo de la garantia
    param in pcidioma   : codigo del idioma
    param out pquery  : select de los productos
    return              : number
   *************************************************************************/
   FUNCTION f_get_productos_campa(pcramo   IN NUMBER,
                                  psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pcgarant IN NUMBER,
                                  pcidioma IN NUMBER,
                                  pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin     NUMBER;
      vobj     VARCHAR2(200) := 'pac_campanas.f_get_productos_campa';
      vwhere   VARCHAR2(2000);
      vpar     VARCHAR2(2000) := ' pcramo=' || pcramo || ' psproduc=' ||
                                 psproduc || ' pcactivi=' || pcactivi ||
                                 ' pcgarant=' || pcgarant;
      vcidioma NUMBER := pac_iax_common.f_get_cxtidioma();
   BEGIN
      pquery := 'select p.cramo,
                 (select tramo from ramos where cramo = p.cramo and cidioma = ' ||
                vcidioma ||
                ') tcramo,
                 p.sproduc, (select ttitulo from titulopro where cramo = p.cramo and cmodali = p.cmodali and ctipseg = p.ctipseg and ccolect = p.ccolect and cidioma = ' ||
                vcidioma ||
                ') tproduc,
                 p.cactivi, (select ttitulo from activisegu where cactivi = p.cactivi and cramo = p.cramo and cidioma = ' ||
                vcidioma ||
                ') tactivi,
                 p.cgarant, (select tgarant from garangen where cgarant = p.cgarant and cidioma = ' ||
                vcidioma || ') tgarant
                   from garanpro p, garangen g, productos pp
                  where g.cgarant = p.cgarant
                    and g.cidioma = ' || pcidioma ||
                ' and pp.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'null') ||
                ',pp.sproduc)' || ' and pp.cramo = NVL(' ||
                NVL(TO_CHAR(pcramo), 'null') || ', pp.cramo)' ||
                ' and p.cramo = pp.cramo' || ' and p.cmodali = pp.cmodali' ||
                ' and p.ctipseg = pp.ctipseg' ||
                ' and p.ccolect = pp.ccolect' || ' and p.cactivi = NVL(' ||
                NVL(TO_CHAR(pcactivi), 'null') || ', p.cactivi)' ||
                ' and p.cgarant = NVL(' || NVL(TO_CHAR(pcgarant), 'null') ||
                ', p.cgarant)' || ' union ' ||
                ' select distinct(p.cramo),
                 (select tramo from ramos where cramo = p.cramo and cidioma = ' ||
                vcidioma ||
                ') tcramo,
                 p.sproduc, (select ttitulo from titulopro where cramo = p.cramo and cmodali = p.cmodali and ctipseg = p.ctipseg and ccolect = p.ccolect and cidioma = ' ||
                vcidioma || ') tproduc,
                 null cactivi, null tactivi, null cgarant, null tgarant
                   from garanpro p, garangen g, productos pp
                  where g.cgarant = p.cgarant
                    and g.cidioma = ' || pcidioma ||
                ' and pp.sproduc = NVL(' || NVL(TO_CHAR(psproduc), 'null') ||
                ',pp.sproduc)' || ' and pp.cramo = NVL(' ||
                NVL(TO_CHAR(pcramo), 'null') || ', pp.cramo)' ||
                ' and p.cramo = pp.cramo' || ' and p.cmodali = pp.cmodali' ||
                ' and p.ctipseg = pp.ctipseg' ||
                ' and p.ccolect = pp.ccolect' || ' and p.cactivi = NVL(' ||
                NVL(TO_CHAR(pcactivi), 'null') || ', p.cactivi)' ||
                ' and p.cgarant = NVL(' || NVL(TO_CHAR(pcgarant), 'null') ||
                ', p.cgarant)' ||
                ' order by cramo, sproduc, cactivi, cgarant';
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_productos_campa;

   /*************************************************************************
    FUNCTION f_set_productos_campa
    Funcion que permite asignar productos a las campaña
    param in pccodigo     : codigo campaña
    param in plistprod  : lista de productos seleccionados
    return              : number
   *************************************************************************/
   FUNCTION f_set_productos_campa(pccodigo IN NUMBER,
                                  psproduc IN NUMBER,
                                  pcactivi IN NUMBER,
                                  pcgarant NUMBER) RETURN NUMBER IS
      vlin NUMBER;
      vobj VARCHAR2(200) := 'pac_campanas.f_set_productos_campa';
      vpar VARCHAR2(2000) := 'pccodigo-psproduc-pcactivi-pcgarant: ' ||
                             pccodigo || '-' || psproduc || '-' || pcactivi || '-' ||
                             pcgarant;
   BEGIN
      INSERT INTO campaprd
         (ccodigo, sproduc, cactivi, cgarant)
      VALUES
         (pccodigo, psproduc, NVL(pcactivi, -1), NVL(pcgarant, -1));

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_set_productos_campa;

   -- Fi Bug 0019298
   /*************************************************************************
    FUNCTION f_get_campaprd
    Funcion que perminte buscar productos/actividades/garantias de una EMPRESA a partir de los criterios de consulta entrados
    param in pccodigo     : codigo del ramo
    param out pquery  : select de los productos
    return              : number
   *************************************************************************/
   FUNCTION f_get_campaprd(pccodigo IN NUMBER,
                           pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_get_campaprd';
      vwhere VARCHAR2(2000);
      vpar   VARCHAR2(2000) := ' pccodigo=' || pccodigo;
   BEGIN
      pquery := 'select sproduc, cactivi, cgarant from campaprd where ccodigo = ' ||
                pccodigo;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_campaprd;

   /*************************************************************************
    FUNCTION f_get_campa
    Funcion que perminte buscar campanas de una EMPRESA a partir de los criterios de consulta entrados
    param in pccodigo     : codigo del ramo
    param out pquery  : select de los productos
    return              : number
   *************************************************************************/
   FUNCTION f_get_campa(pccodigo IN NUMBER,
                        pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_get_campa';
      vwhere VARCHAR2(2000);
      vpar   VARCHAR2(2000) := ' pccodigo=' || pccodigo;
   BEGIN
      pquery := 'SELECT c.ffincam, c.finicam, c.finirec, c.ffinrec, (SELECT DISTINCT TRUNC(fcierre)
          FROM campa_age_cierre WHERE ccampana = c.ccodigo) fcierre FROM campanas c WHERE c.ccodigo = ' ||
                pccodigo;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_campa;
   /*************************************************************************
    FUNCTION f_del_productos_campa
    Funcion que permite eliminar productos de una campaña
    param in pccodigo     : codigo campaña
    param in pcproduc  : código de producto
    return              : number
   *************************************************************************/
   FUNCTION f_del_productos_campa(pccodigo IN NUMBER) RETURN NUMBER IS
      vlin  NUMBER;
      vobj  VARCHAR2(200) := 'pac_campanas.f_del_productos_campa';
      vpar  VARCHAR2(2000) := 'pccodigo-pcproduc: ' || pccodigo;
      vcont NUMBER;
   BEGIN
      --seleccionamos los productos de la campaña
      SELECT COUNT(pregunpolseg.sseguro)
        INTO vcont
        FROM pregunpolseg,
             seguros
       WHERE seguros.sseguro = pregunpolseg.sseguro
         AND pregunpolseg.cpregun = 9134
         AND pregunpolseg.crespue = pccodigo
         AND seguros.sproduc IN
             (SELECT DISTINCT sproduc FROM campaprd WHERE ccodigo = pccodigo);

      IF vcont = 0
      THEN
         --no existen pólizas asociadas a los productos de la campaña y eliminamos los productos
         DELETE FROM campaprd WHERE ccodigo = pccodigo;

         RETURN 0;
      ELSE
         --existen pólizas asociadas a los productos de la campaña
         RETURN 9906782;
      END IF;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_del_productos_campa;

   /*************************************************************************
    FUNCTION f_get_agentecampanyes
    Funcion que perminte buscar las campañas en las que está un agente
    param in pcagente    : codigo de agente
    param out pquery  : select de llas campañas
    return              : number
   *************************************************************************/
   FUNCTION f_get_agentecampanyes(pcagente IN NUMBER,
                                  pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_get_agentecampanyes';
      vwhere VARCHAR2(2000);
      vpar   VARCHAR2(2000) := ' pcagente=' || pcagente;
   BEGIN
      pquery := 'select ca.tdescrip from campanas ca, campaage cg where ca.ccodigo = cg.ccodigo and  cg.cagente =' ||
                pcagente;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_agentecampanyes;

   /*************************************************************************
    FUNCTION f_set_ageganador
    Funcion que permite asignar productos a las campaña
    param in pccodigo     : codigo campaña
    param in pcagente     : agente
    param in ptganador    : ganador (S/N)
    return              : number
   *************************************************************************/
   FUNCTION f_set_ageganador(pccodigo  IN NUMBER,
                             pcagente  IN NUMBER,
                             ptganador IN VARCHAR2) RETURN NUMBER IS
      vlin NUMBER;
      vobj VARCHAR2(200) := 'pac_campanas.f_set_ageganador';
      vpar VARCHAR2(2000) := 'pccodigo-pcagente-pcactivi-ptganador: ' ||
                             pccodigo || '-' || pcagente || '-' ||
                             ptganador;
   BEGIN
      UPDATE campaage
         SET bganador = ptganador
       WHERE ccodigo = pccodigo
         AND cagente = pcagente;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN 1;
   END f_set_ageganador;

   FUNCTION f_ramos(pccodigo IN NUMBER) RETURN VARCHAR2 IS
      vret  VARCHAR(4000) := ' ';
      vramo VARCHAR2(300);

      CURSOR c1 IS
         SELECT DISTINCT pr.cramo
           FROM campaprd  cp,
                productos pr
          WHERE cp.ccodigo = pccodigo
            AND pr.sproduc = cp.sproduc;
   BEGIN
      FOR cur_prd IN c1
      LOOP
         vramo := pac_isqlfor.f_ramo(cur_prd.cramo, f_idiomauser);

         IF vret = ' '
         THEN
            vret := vramo;
         ELSE
            vret := vret || ',' || vramo;
         END IF;
      END LOOP;

      RETURN vret;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN ' ';
   END;

   /*************************************************************************
    FUNCTION f_get_documentos
    Funcion que perminte mostrar los deocumentos de una campañas
    param in pccodigo    : codigo de campaña
    param out pquery  : select de los documentos
    return              : number
   *************************************************************************/
   FUNCTION f_get_documentos(pccodigo IN NUMBER,
                             pquery   OUT VARCHAR2) RETURN NUMBER IS
      vlin   NUMBER;
      vobj   VARCHAR2(200) := 'pac_campanas.f_get_documentos';
      vwhere VARCHAR2(2000);
      vpar   VARCHAR2(2000) := ' pccodigo=' || pccodigo;
   BEGIN
      pquery := 'select tnombre from campadoc where ccodigo =  ' ||
                pccodigo;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     vobj,
                     vlin,
                     vpar,
                     SQLCODE || chr(10) || pquery);
         RETURN 1;
   END f_get_documentos;

   /***********************************************************************
      F_DESPRODUCTO: Obtención del Título o Rótulo de un Producto.
   ***********************************************************************/
   FUNCTION f_desproducto(psproduc IN NUMBER,
                          pcidioma IN NUMBER) RETURN VARCHAR2 IS
      vttexto VARCHAR2(40);
   BEGIN
      SELECT ttitulo
        INTO vttexto
        FROM titulopro t,
             productos p
       WHERE t.ctipseg = p.ctipseg
         AND t.cramo = p.cramo
         AND t.cmodali = p.cmodali
         AND t.ccolect = p.ccolect
         AND t.cidioma = pcidioma
         AND p.sproduc = psproduc;

      RETURN vttexto;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   /***********************************************************************
   ***********************************************************************/

   FUNCTION f_get_agente_importe(pcagente  IN NUMBER,
                                 pccampana IN NUMBER,
                                 pnmes     IN NUMBER,
                                 pnano     IN NUMBER,
                                 pcramo    IN NUMBER,
                                 pcempres  IN NUMBER,
                                 psproduc  IN NUMBER,
                                 pcsucurs  IN NUMBER) RETURN SYS_REFCURSOR IS

      mensajes  t_iax_mensajes;
      v_sele1   VARCHAR2(32000);
      cam_c1    SYS_REFCURSOR;
      v_fcierre DATE;
      v_mes     VARCHAR2(3);
      v_desde   DATE;
      vlin      VARCHAR2(100);
      vobj      VARCHAR2(100) := 'PAC_CAMPANAS.f_get_agente_importe';
      vpar      VARCHAR2(1000) := 'pcagente=' || pcagente || 'pccampana=' ||
                                  pccampana || ' pnmes=' || pnmes ||
                                  'pnano= ' || pnano || 'pcramo= ' ||
                                  pcramo || 'pcempres= ' || pcempres ||
                                  'psproduc= ' || psproduc || 'pcsucurs= ' ||
                                  pcsucurs;

   BEGIN
      p_control_error('AP', '102', 'pnano' || pnano);

      IF (pnmes IS NOT NULL AND pnano IS NOT NULL)
      THEN

         IF length(pnmes) = 1
         THEN
            v_mes := '0' || pnmes;
         ELSE
            v_mes := pnmes;
         END IF;

         p_control_error('AP', '101', 'pnmes' || v_mes);
         v_fcierre := last_day(TO_DATE('01' || v_mes || pnano, 'ddmmyyyy'));
      ELSE
         v_fcierre := f_sysdate;
      END IF;

      v_desde := TRUNC(v_fcierre, 'mm');

      v_sele1 := 'SELECT DISTINCT seg.sproduc, cag.ccodigo campana, seg.cagente,
                (SELECT SUM(v.itotalr)
                   FROM seguros s, recibos r, vdetrecibos_monpol v
                  WHERE s.sseguro = r.sseguro
                    AND r.nrecibo = v.nrecibo
                    AND f_cestrec(r.nrecibo,
                                  to_date(''' || v_fcierre || ''',
                                          '' dd / mm / yy '')) <> 2
                    AND s.sproduc = seg.sproduc
                    AND s.cagente = seg.cagente
                    AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                    AND s.cempres = NVL(24, pac_md_common.f_get_cxtempresa())
                    AND s.fefecto < = to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')
                    AND s.fefecto > = to_date(''' ||
                 v_desde ||
                 ''', '' dd / mm / yy '')
                    AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                  GROUP BY s.sproduc, s.cagente) total_prod,
                (SELECT SUM(v.itotalr)
                   FROM seguros s, recibos r, vdetrecibos_monpol v
                  WHERE s.sseguro = r.sseguro
                    AND r.nrecibo = v.nrecibo
                    AND f_cestrec(r.nrecibo, to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')) = 1
                    AND s.cempres = NVL(24, pac_md_common.f_get_cxtempresa())
                    AND s.sproduc = seg.sproduc
                    AND s.cagente = seg.cagente
                    AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                    AND s.fefecto < = to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')
                    AND s.fefecto > = to_date(''' ||
                 v_desde ||
                 ''', '' dd / mm / yy '')
                    AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                  GROUP BY s.sproduc, s.cagente) total_recaudo,
                (SELECT COUNT(DISTINCT s.npoliza)
                   FROM seguros s, recibos r, vdetrecibos_monpol v
                  WHERE s.sseguro = r.sseguro
                    AND r.nrecibo = v.nrecibo
                    AND f_cestrec(r.nrecibo, to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')) <> 2
                    AND s.sproduc = seg.sproduc
                    AND s.cagente = seg.cagente
                    AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                    AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                  GROUP BY s.sproduc, s.cagente) total_poliz_prod,
                (SELECT COUNT(DISTINCT s.npoliza)
                   FROM seguros s, recibos r, vdetrecibos_monpol v
                  WHERE s.sseguro = r.sseguro
                    AND r.nrecibo = v.nrecibo
                    AND f_cestrec(r.nrecibo, to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')) = 1
                    AND s.sproduc = seg.sproduc
                    AND s.cagente = seg.cagente
                    AND NOT EXISTS (SELECT * FROM cesionesrea WHERE ctramo = 5 AND sseguro = s.sseguro)
                    AND s.cempres = NVL(24, pac_md_common.f_get_cxtempresa())
                    AND s.fefecto < = to_date(''' ||
                 v_fcierre ||
                 ''', '' dd / mm / yy '')
                    AND s.fefecto > = to_date(''' ||
                 v_desde || ''', '' dd / mm / yy '')
                    AND (s.fanulac IS NULL OR s.fanulac > (SYSDATE - 31))
                  GROUP BY s.sproduc, s.cagente) total_poliz_reca,
                  pac_campanas.f_get_porc_agente_sinies(seg.cagente) isinies
  FROM campanas c, campaage cag, seguros seg
 WHERE c.ccodigo = cag.ccodigo
   AND cag.cagente = seg.cagente';

      IF pcagente IS NOT NULL
      THEN
         v_sele1 := v_sele1 || ' and seg.cagente = ' || pcagente;
      END IF;

      IF psproduc IS NOT NULL
      THEN
         v_sele1 := v_sele1 || ' and seg.sproduc = ' || psproduc;
      END IF;

      INSERT INTO log_consultas
         (slogconsul, fconsulta, cusuari, corigen, ctipo, tconsulta,
          tllamada)
         SELECT slogconsul.nextval,
                f_sysdate,
                f_user,
                3,
                1,
                v_sele1,
                vobj
           FROM log_consultas;

      COMMIT;
      cam_c1 := pac_iax_listvalores.f_opencursor(v_sele1, mensajes);

      RETURN cam_c1;

   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLCODE);
         RETURN NULL;

   END f_get_agente_importe;

   /***********************************************************************
   ***********************************************************************/

   FUNCTION f_get_porc_agente_sinies(pcagente IN NUMBER) RETURN NUMBER IS
      v_pagados  NUMBER;
      v_reservas NUMBER;
      v_prima    NUMBER;
      v_sinies   NUMBER;

      vlin VARCHAR2(100);
      vobj VARCHAR2(100) := 'PAC_CAMPANAS.f_get_porc_agente_sinies';
      vpar VARCHAR2(1000) := 'pcagente=' || pcagente;

   BEGIN
      --
      SELECT NVL(SUM(stp.isinret), 0)
        INTO v_pagados
        FROM sin_tramita_pago stp,
             sin_siniestro    ss,
             seguros          s,
             productos        p
       WHERE stp.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND s.fefecto >= add_months(SYSDATE, -36)
         AND s.cramo = p.cramo
         AND s.cagente = pcagente;

      SELECT NVL(SUM(str.ipago), 0) AS reservas
        INTO v_reservas
        FROM sin_tramita_reserva str,
             sin_siniestro       ss,
             seguros             s,
             productos           p
       WHERE str.nsinies = ss.nsinies
         AND ss.sseguro = s.sseguro
         AND s.fefecto >= add_months(SYSDATE, -36)
         AND s.cramo = p.cramo
         AND s.cagente = pcagente;

      SELECT NVL(SUM(v.itotpri), 0) AS prima
        INTO v_prima
        FROM vdetrecibos v,
             recibos     r,
             seguros     s,
             productos   p
       WHERE r.nrecibo = v.nrecibo
         AND r.cagente = s.cagente
         AND s.fefecto >= add_months(SYSDATE, -36)
         AND s.cramo = p.cramo
         AND s.cagente = pcagente;

      v_sinies := ((v_pagados + v_reservas) / v_prima) * 100;

      RETURN v_sinies;
      --
   END f_get_porc_agente_sinies;

   /***********************************************************************
   ***********************************************************************/

   FUNCTION f_get_campa_cierre(pctipo    IN NUMBER,
                               pcagente  IN NUMBER,
                               pccampana IN NUMBER,
                               pnmes     IN NUMBER,
                               pnano     IN NUMBER,
                               pcramo    IN NUMBER,
                               pcempres  IN NUMBER,
                               psproduc  IN NUMBER,
                               pcsucurs  IN NUMBER) RETURN SYS_REFCURSOR IS

      mensajes t_iax_mensajes;
      v_sele   VARCHAR(32000);
      cam_c    SYS_REFCURSOR;

      vlin     VARCHAR2(100);
      vobj     VARCHAR2(100) := 'PAC_CAMPANAS.F_GET_CAMPA_CIERRE';
      vpar     VARCHAR2(1000) := 'pctipo=' || pctipo || 'pcagente=' ||
                                 pcagente || ' pccampana=' || pccampana ||
                                 'pnmes= ' || pnmes || 'pnano= ' || pnano ||
                                 'pcramo= ' || pcramo || 'pcempres= ' ||
                                 pcempres || 'psproduc= ' || psproduc ||
                                 ' pcsucurs=' || pcsucurs;
      vpasexec NUMBER := -1;

   BEGIN
      vpasexec := 0;
      v_sele   := 'SELECT cc.ccampana, cc.sproduc, cc.cagente, cc.cnumpol, cc.iproduccion, cc.irecaudo,  cc.isiniest ' ||
                  'FROM CAMPA_AGE_CIERRE cc, CAMPANAS C, PRODUCTOS p, codiram r ' ||
                  'where cc.ccampana = c.ccodigo ' ||
                  'and p.sproduc = cc.sproduc ' || 'AND p.cramo = r.cramo ';

      vpasexec := 1;
      IF pcempres IS NOT NULL
      THEN
         v_sele := v_sele || ' and r.cempres = ' || pcempres;
      END IF;
      vpasexec := 2;

      IF pccampana IS NOT NULL
      THEN
         v_sele := v_sele || ' and c.ccodigo  = ' || pccampana;
      END IF;
      vpasexec := 5;

      IF pcagente IS NOT NULL
      THEN
         v_sele := v_sele || ' and cc.cagente = ' || pcagente;
      END IF;
      vpasexec := 4;

      IF pctipo IS NOT NULL
      THEN
         v_sele := v_sele || ' and cc.ctipo = ' || pctipo;
      END IF;
      vpasexec := 3;

      IF pcramo IS NOT NULL
      THEN
         v_sele := v_sele || ' and p.cramo = ' || pcramo;
      END IF;
      vpasexec := 6;

      IF psproduc IS NOT NULL
      THEN
         v_sele := v_sele || ' and cc.sproduc = ' || psproduc;
      END IF;
      vpasexec := 7;

      IF pnano IS NOT NULL
      THEN
         v_sele := v_sele || ' AND EXTRACT(month FROM FCIERRE) = ' || pnmes;
      END IF;
      vpasexec := 8;

      IF pnmes IS NOT NULL
      THEN
         v_sele := v_sele || ' AND EXTRACT (YEAR FROM FCIERRE) = ' || pnano;
      END IF;
      vpasexec := 9;

      v_sele   := v_sele || ' ORDER BY FCIERRE';
      vpasexec := 10;

      INSERT INTO log_consultas
         (slogconsul, fconsulta, cusuari, tllamada, ctipo, tconsulta,
          corigen)
      VALUES
         (slogconsul.nextval, f_sysdate, f_user, ' prueba', 1, v_sele, 1);

      COMMIT;
      OPEN cam_c FOR v_sele;

      RETURN cam_c;

   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE);
         RETURN NULL;

   END f_get_campa_cierre;

   /***********************************************************************
   Este procedure, se encargara de calcular los “incentivos” de cada agente – campaña, e insértalos en la tabla nueva CAMPA_AGE_CIERRE
   ***********************************************************************/
   PROCEDURE proceso_batch_cierre(pmodo    IN NUMBER,
                                  pcempres IN NUMBER,
                                  pmoneda  IN NUMBER,
                                  pcidioma IN NUMBER,
                                  pfperini IN DATE,
                                  pfperfin IN DATE,
                                  pfcierre IN DATE,
                                  pcerror  OUT NUMBER,
                                  psproces OUT NUMBER,
                                  pfproces OUT DATE) IS
      v_cierre SYS_REFCURSOR;

      vccodigo          NUMBER;
      vtdescrip         VARCHAR2(1000);
      vsproduc          NUMBER;
      vcagente          NUMBER;
      vtotal_prod       NUMBER;
      vtotal_recaudo    NUMBER;
      vtotal_poliz_prod NUMBER;
      vtotal_poliz_reca NUMBER;
      vtcampana         VARCHAR2(1000);
      vtproduc          VARCHAR2(1000);
      visiniest         NUMBER;

      vccodigo2          NUMBER;
      vtdescrip2         NUMBER;
      vsproduc2          NUMBER;
      vcagente2          NUMBER;
      vtotal_prod2       NUMBER;
      vtotal_recaudo2    NUMBER;
      vtotal_poliz_prod2 NUMBER;
      vtotal_poliz_reca2 NUMBER;
      vtcampana2         NUMBER;
      vtproduc2          NUMBER;
      visiniest2         NUMBER;
      par_tprolin        VARCHAR2(1000) := 'Se inserto registro en la tabla CAMPA_AGE_CIERRE ' ||
                                           vccodigo || vcagente;
      pnpronum           NUMBER := 1;
      pnprolin           NUMBER := 1;
      pctiplin           NUMBER := 1;
      v_premio           NUMBER;

      num_err  NUMBER;
      v_titulo VARCHAR2(200) := 'PAC_CAMPANAS.proceso_batch_cierre';
      vlin     NUMBER;
      vobj     VARCHAR2(100) := 'PAC_CAMPANAS.proceso_batch_cierre';
      vpar     VARCHAR2(1000) := 'pmodo=' || pmodo || 'pcempres=' ||
                                 pcempres || ' pmoneda=' || pmoneda ||
                                 'pcidioma= ' || pcidioma || 'pfperini= ' ||
                                 pfperini || 'pfperfin= ' || pfperfin ||
                                 'pfcierre= ' || pfcierre || 'pcerror= ' ||
                                 pcerror || 'psproces' || psproces ||
                                 ' pfproces' || pfproces;
      vpasexec NUMBER := -1;

   BEGIN
      --
      pcerror  := 0;
      vpasexec := 1;
      --
      num_err := pac_contexto.f_inicializarctx(pac_parametros.f_parempresa_t(pcempres,
                                                                             'USER_BBDD'));
      --
      v_cierre := f_get_agente_importe(NULL,
                                       NULL,
                                       to_number(TO_CHAR(pfcierre, 'mm')),
                                       to_number(TO_CHAR(pfcierre, 'yyyy')),
                                       NULL,
                                       24,
                                       NULL,
                                       NULL);
      num_err  := f_procesini(f_user,
                              pcempres,
                              'CIERRE CAMPAÑAS',
                              v_titulo,
                              psproces);

      vpasexec := 2;
      IF v_cierre%ISOPEN
      THEN
         LOOP
            FETCH v_cierre
               INTO vsproduc,
                    vccodigo,
                    vcagente,
                    vtotal_prod,
                    vtotal_recaudo,
                    vtotal_poliz_prod,
                    vtotal_poliz_reca,
                    visiniest;

            EXIT WHEN v_cierre%NOTFOUND;

            vpasexec := 21;
            IF pmodo = 1
            THEN
               INSERT INTO campa_age_cierre
                  (ccampana, cagente, sproduc, cnumpol, iproduccion,
                   irecaudo, fcierre, isiniest, ctipo)
               VALUES
                  (vccodigo, vcagente, vsproduc, vtotal_poliz_prod,
                   vtotal_prod, vtotal_recaudo, f_sysdate, visiniest, 1);
               vpasexec := 3;
               num_err  := f_proceslin(psproces,
                                       par_tprolin,
                                       pnpronum,
                                       pnprolin,
                                       pctiplin);
               pnpronum := pnpronum + 1;
               pnprolin := pnprolin + 1;

               vpasexec := 4;
            ELSE
               INSERT INTO campa_age_cierre
                  (ccampana, cagente, sproduc, cnumpol, iproduccion,
                   irecaudo, fcierre, isiniest, ctipo)
               VALUES
                  (vccodigo, vcagente, vsproduc, vtotal_poliz_prod,
                   vtotal_prod, vtotal_recaudo, f_sysdate, visiniest, 0);

               SELECT c.ipremio
                 INTO v_premio
                 FROM campanas         c,
                      campa_age_cierre ca
                WHERE ca.ccampana = c.ccodigo
                  AND c.ccodigo = vccodigo;

               INSERT INTO ctactes
                  (cagente, nnumlin, cdebhab, cconcta, cestado, ffecmov,
                   iimport, tdescrip, cmanual, cempres, fvalor, sproces,
                   sproduc, ccompani)
               VALUES
                  (vcagente, 1, 1, 27, 1, SYSDATE, v_premio, 'Incentivos',
                   1, 24, SYSDATE, psproces, vsproduc, 0);

            END IF;

         END LOOP;
         CLOSE v_cierre;
      END IF;

      num_err := f_procesfin(psproces, num_err);
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE);
   END proceso_batch_cierre;

   /***********************************************************************************************
   ************************************************************************************************
   ************************************************************************************************
   ************************************************************************************************/

   FUNCTION f_generar_correo(pctipo    IN NUMBER,
                             pcagente  IN NUMBER,
                             pccampana IN NUMBER,
                             pnmes     IN NUMBER,
                             pnano     IN NUMBER,
                             pcramo    IN NUMBER,
                             pcempres  IN NUMBER,
                             psproduc  IN NUMBER,
                             pcsucurs  IN NUMBER) RETURN NUMBER IS

      mensajes t_iax_mensajes;
      vobj     VARCHAR2(100) := 'PAC_CAMPANAS.F_GENERAR_CORREO';
      vpar     VARCHAR2(1000) := 'pctipo=' || pctipo || 'pcagente=' ||
                                 pcagente || ' pccampana=' || pccampana ||
                                 'pnmes= ' || pnmes || 'pnano= ' || pnano ||
                                 'pcramo= ' || pcramo || 'pcempres= ' ||
                                 pcempres || 'psproduc= ' || psproduc ||
                                 ' pcsucurs=' || pcsucurs;

      pparams   t_iax_info := t_iax_info();
      params    ob_iax_info := ob_iax_info();
      vnumerr   NUMBER := 0;
      v_tcorreo VARCHAR2(100);
      pnomfich  VARCHAR2(200);
      pofich    VARCHAR2(200);
      vpasexec  NUMBER := -1;
      pfini     DATE;
      pfin      DATE;
      v_cierre  SYS_REFCURSOR;

      vccodigo          NUMBER;
      vsproduc          NUMBER;
      vcagente          NUMBER;
      vtotal_prod       NUMBER;
      vtotal_recaudo    NUMBER;
      vtotal_poliz_prod NUMBER;
      visiniest         NUMBER;
      i                 NUMBER := 0;

   BEGIN
      --
      fichero := t_fichero_mail();
      --

      v_cierre := f_get_campa_cierre(pctipo,
                                     pcagente,
                                     pccampana,
                                     pnmes,
                                     pnano,
                                     pcramo,
                                     pcempres,
                                     psproduc,
                                     pcsucurs);
      -- llamar get cierre
      vpasexec := 99;

      LOOP
         FETCH v_cierre
            INTO vccodigo,
                 vsproduc,
                 vcagente,
                 vtotal_poliz_prod,
                 vtotal_prod,
                 vtotal_recaudo,
                 visiniest;
         EXIT WHEN v_cierre%NOTFOUND;
         -- cc.ccampana, cc.sproduc, cc.cagente, cc.cnumpol, cc.iproduccion, cc.irecaudo,  cc.isiniest
         vpasexec := 11;
         pparams  := t_iax_info();
         pparams.extend;
         params.nombre_columna := 'PCAGENTE';
         params.valor_columna := vcagente;
         params.tipo_columna := 1;
         pparams(pparams.last) := params;
         pparams.extend;
         params.nombre_columna := 'PCCAMPANA';
         params.valor_columna := vccodigo;
         params.tipo_columna := 1;
         pparams(pparams.last) := params;
         vpasexec := 1;

         BEGIN
            --
            SELECT tcorreo
              INTO v_tcorreo
              FROM agentes_correo
             WHERE cagente = vcagente;
            --
         EXCEPTION
            WHEN OTHERS THEN
               v_tcorreo := NULL;
         END;
         --
         IF v_tcorreo IS NOT NULL
         THEN
            --
            vnumerr  := pac_iax_informes.f_ejecuta_informe('reporteCampana',
                                                           pcempres,
                                                           'PDF',
                                                           pparams,
                                                           pac_md_common.f_get_cxtidioma(),
                                                           0,
                                                           NULL,
                                                           pnomfich,
                                                           pofich,
                                                           mensajes,
                                                           0);
            vpasexec := 12;
            --
            i := i + 1;
            fichero.extend();
            fichero(i).cagente := vcagente;
            fichero(i).pnomfich := pnomfich;
            --
            vpasexec := 5;
            --
         END IF;
         --
      END LOOP;
      --
      CLOSE v_cierre;
      --
      vnumerr := f_envia_correo();
      --
      RETURN vnumerr;
      --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE);
         RETURN NULL;

   END f_generar_correo;

   /***********************************************************************
   f_envia_correo: Envía mail
   ***********************************************************************/
   FUNCTION f_envia_correo RETURN NUMBER IS
      --
      vobj           VARCHAR2(100) := 'PAC_CAMPANAS.f_envia_correo';
      vpar           VARCHAR2(1000) := NULL;
      vpasexec       NUMBER := 1;
      v_scorreo      NUMBER := 1913;
      vnumerr        NUMBER;
      v_ficherodummy utl_file.file_type;
      --
   BEGIN
      --
      FOR i IN fichero.first .. fichero.last
      LOOP
         --
         vnumerr := pac_correo.f_envia_correo_agentes(pcagente    => fichero(i)
                                                                     .cagente,
                                                      pvidioma    => pac_md_common.f_get_cxtidioma(),
                                                      pscorreo    => v_scorreo,
                                                      pfini       => NULL,
                                                      pffin       => NULL,
                                                      pdirectorio => 'GEDOXTEMPORAL',
                                                      pfichero    => fichero(i)
                                                                     .pnomfich,
                                                      pctipo      => 17);
         --
      END LOOP;
      --
      RETURN vnumerr;
      --
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vpasexec, vpar, SQLCODE);
         RETURN NULL;
   END f_envia_correo;

END pac_campanas;

/

  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CAMPANAS" TO "PROGRAMADORESCSI";
