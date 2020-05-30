--------------------------------------------------------
--  DDL for Package Body PAC_MD_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_MAP" AS
/******************************************************************************
   NOMBRE:       DEMO_CORREDURIA2.PAC_MD_MAP
   PROPÓSITO:  Package para gestionar los MAPS

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        06/05/2009   ICV                1. Creación del package. Bug.: 9940
   2.0        15/03/2010   AMC                2. Bug 13461. Se modifica la funcion f_ejecuta para que el nombre del fichero incorpore los parametros
   3.0        01/02/2012   MDS                3. 0021128: LCOL898- UAT - Errores Interfase Produccion Mensual de Comisiones
 ******************************************************************************/

   /*************************************************************************
      FUNCTION f_get_datmap
      Función para devolver los campos descriptivos de un map.
      param in PMAP: Tipo carácter. Id. del map.
      param in out MENSAJES: Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
      return             : Retorna un sys_refcursor con los campos descriptivos de un map.
   *************************************************************************/

   /*FUNCION PRIVADA*/
   FUNCTION f_get_datmap(pmap IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pmap = ' || pmap;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_get_datmap';
      vcursor        sys_refcursor;
      vsquery        VARCHAR2(400);
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery := 'SELECT TCOMENTARIO, TPARAMETROS FROM MAP_CABECERA WHERE CMAPEAD = ''' || pmap
                 || '''';
      vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN vcursor;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF vcursor%ISOPEN THEN
            CLOSE vcursor;
         END IF;

         RETURN vcursor;
   END f_get_datmap;

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
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                   := 'parámetros - pmap = ' || pmap || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_ejecuta';
      vnerror        NUMBER := 0;
      v_ttipomap     map_cabecera.ttipomap%TYPE;
      v_nomfich      VARCHAR2(800);
      v_smapead      NUMBER;
      v_texto        VARCHAR2(800);
      v_cidioma      idiomas.cidioma%TYPE;
      v_nomfitx      VARCHAR2(800);
      vparam2        VARCHAR2(800);
      params_out     VARCHAR2(800);
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Es busca el tipus de map.
      v_ttipomap := pac_map.f_get_tipomap(pmap);

      IF v_ttipomap IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
         RAISE e_object_error;
      END IF;

      v_cidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 3;

      IF v_ttipomap = 3 THEN   --XML
         pac_map.p_genera_parametros_xml(pmap, pparam);
         vnerror := pac_map.genera_map(pmap, v_smapead);
      ELSE
         -- Bug 13461 - 15/03/2010 - AMC
         SELECT REPLACE(pparam, '|')
           INTO vparam2
           FROM DUAL;

         v_nomfitx := pac_map.f_get_nomfichero(pmap);
         v_nomfitx := SUBSTR(v_nomfitx, INSTR(v_nomfitx, '\', -1) + 1);
         v_nomfitx := REPLACE(v_nomfitx, '.csv', '_' || vparam2 || '.csv');
         -- ini BUG 21128 - MDS - 01/02/2012
         -- tener en cuenta ficheros que se quieran con formato yyyymmddhh24miss
         v_nomfitx := REPLACE(v_nomfitx, 'yyyymmddhh24miss',
                              TO_CHAR(f_sysdate, 'yyyymmddhh24miss'));
         --BUG 27699/165546 - RCL
         v_nomfitx := REPLACE(v_nomfitx, 'yyyymmddhhmiss',
                              TO_CHAR(f_sysdate, 'yyyymmddhhmiss'));
         --
         -- fin BUG 21128 - MDS - 01/02/2012
         vnerror := pac_map.f_extraccion(pmap, pparam, v_nomfitx, params_out);
      -- Fi Bug 13461 - 15/03/2010 - AMC

      --pac_map.p_genera_parametros_fichero(pmap, pparam);
      END IF;

      vpasexec := 4;

      -- Bug 13461 - 15/03/2010 - AMC
      --vnerror := pac_map.genera_map(pmap, v_smapead);
      -- Fi Bug 13461 - 15/03/2010 - AMC
      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF v_ttipomap = 3 THEN
         v_nomfich := pac_map.f_obtener_xml_texto;

         IF v_nomfich IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
            RAISE e_object_error;
         END IF;

         --Mensaje de Se ha generado XML
         v_texto := f_axis_literales(9001590, v_cidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_texto);
      ELSE
         v_nomfich := pac_map.f_get_nomfichero(pmap);

         IF v_nomfich IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
            RAISE e_object_error;
         END IF;

         -- Bug 13461 - 15/03/2010 - AMC
         IF v_nomfitx IS NOT NULL THEN
            v_nomfich := SUBSTR(v_nomfich, 0, INSTR(v_nomfich, '\', -1)) || v_nomfitx;
         END IF;

         -- Fi Bug 13461 - 15/03/2010 - AMC

         --Mensaje de Se ha generado map y ruta
         v_texto := f_axis_literales(105267, v_cidioma) || v_nomfich;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_texto);
      END IF;

      vpasexec := 6;
      -- Bug 14067 - 13/04/2010 - AMC
      pejecutarep := pac_map.f_get_ejereport(pmap);
      -- Fi Bug 14067 - 13/04/2010 - AMC
      RETURN v_nomfich;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_ejecuta;

    /*************************************************************************
       FUNCTION F_get_tipomap
       Función que retornará el tipo de fichero que genera el map
       param in PMAP: Id. del Map
       param in out MENSAJES: Tipo t_iax_mensajes. Parámetro de Entrada / Salida. Mensaje de error
       return             : Devolverá una numérico con el tipo de fichero que genera el map.
   *************************************************************************/
   FUNCTION f_get_tipomap(pmap IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'parámetros - pmap = ' || pmap;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_get_tipomap';
      v_ttipomap     map_cabecera.ttipomap%TYPE;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      v_ttipomap := pac_map.f_get_tipomap(pmap);

      IF v_ttipomap IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
         RAISE e_object_error;
      END IF;

      RETURN v_ttipomap;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_tipomap;

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
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                 := 'parámetros - pmaps = ' || pmaps || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_ejecuta_multimap';
      vnerror        NUMBER(10) := 0;
      v_ttipomap     map_cabecera.ttipomap%TYPE;
      v_fitxers      VARCHAR2(400);
      v_smapead      NUMBER(10);
      v_texto        VARCHAR2(400);
      v_cidioma      idiomas.cidioma%TYPE;
      v_pos_map      NUMBER(2);
      v_cempres      VARCHAR2(1);
      v_fecha        VARCHAR2(8);
      v_substr       VARCHAR2(50) := pmaps;
      v_sortida      VARCHAR2(200);
      v_retorno      VARCHAR2(1000);
      v_proces       VARCHAR2(10);
      v_cmap         VARCHAR2(6);
      vejecutarep    NUMBER;
   BEGIN
      --Comprovem els paràmetres d'entrada.
      IF pmaps IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;
      v_pos_map := INSTR(v_substr, '@', 1);

      WHILE v_pos_map > 1 LOOP
         BEGIN
            v_cmap := SUBSTR(v_substr, 1, v_pos_map - 1);   -- extraigo el primero
            v_substr := SUBSTR(v_substr, v_pos_map + 1);   -- reduzco el string
            v_sortida := f_ejecuta(v_cmap, pparam, vejecutarep, mensajes);
         EXCEPTION
            WHEN OTHERS THEN
               RAISE e_object_error;
         END;

         v_retorno := v_sortida || '@' || v_retorno;
         v_pos_map := INSTR(v_substr, '@', 1);
      END LOOP;

      RETURN v_retorno;
------------------------------------------------------------------
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_ejecuta_multimap;

   FUNCTION f_get_arbol(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_arbol';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vsquery        VARCHAR2(3000);
   BEGIN
      IF pcmapead IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      vsquery :=
         '         SELECT NVL
                       ((SELECT 1
                           FROM map_xml xx
                          WHERE xx.cmapead IN('''
         || pcmapead || ''', ''0'', ''3'',''' || pcmapead
         || ''')
                            AND xx.ttag = x.ttag
                            AND xx.tpare = x.tpare
                            AND(xx.ttag IN(SELECT     xxx.ttag
                                                 FROM map_xml xxx
                                                WHERE xxx.cmapead IN
                                                                 ('''
         || pcmapead || ''', ''0'', ''3'',''' || pcmapead
         || ''')
                                           START WITH xxx.ttag =
                                                         (SELECT ttag
                                                            FROM map_xml
                                                           WHERE cmapead = '''
         || pcmapead
         || '''
                                                             AND ROWNUM = 1)
                                           CONNECT BY PRIOR xxx.tpare = xxx.ttag
                                                  AND PRIOR xxx.cmapead IN(
                                                                       SELECT cmapcom
                                                                         FROM map_comodin
                                                                        WHERE cmapead ='''
         || pcmapead
         || '''))
                                OR xx.tpare IN(''0'', ''C''))),
                        -1) dummy,
                    LEVEL codigo, x.ttag, tpare,
                    DECODE(x.ctablafills,
                           NULL, DECODE(x.catributs, 1, ''execute'', ''AFaccept''),
                           ''collaps'') tabla,
                    x.cmapead, x.tpare, x.nordfill,
                    x.cmapead || ''-'' || x.tpare || ''-'' || x.nordfill resum, ROWNUM + 1 ID,
                    DECODE(LEVEL, 1, 1,(ROWNUM + 1) - 1) padre
               FROM map_xml x
              WHERE x.cmapead IN('''
         || pcmapead || ''', ''0'', ''3'',''' || pcmapead
         || ''')
         START WITH (x.tpare = ''0''
                     OR(x.tpare = ''C''
                        AND 2 = 4))
         CONNECT BY x.tpare = PRIOR x.ttag
                AND PRIOR x.cmapead IN('''
         || pcmapead || ''', ''0'', ''3'',''' || pcmapead
         || ''')
           ORDER SIBLINGS BY x.nordfill';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_arbol;

   FUNCTION f_get_listadomaps(
      ptiptrat IN VARCHAR2,
      ptipmap IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'ptiptrat = ' || ptiptrat || ' - ptipmap = ' || ptipmap;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_listadomaps';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(7);
      vsquery        VARCHAR2(500);
   BEGIN
      IF ptiptrat = '1' THEN
         vtiptrat := '''C''';
      ELSIF ptiptrat = '2' THEN
         vtiptrat := '''G''';
      ELSIF ptiptrat = '3' THEN
         vtiptrat := '''A''';
      END IF;

      vsquery :=
         'SELECT   cmapead, cmapead || ''.-'' || ttipotrat || ''-'' || tcomentario descripcio
                 FROM map_cabecera
                WHERE cmanten = 1 and ttipotrat = NVL('
         || NVL(TO_CHAR(vtiptrat), 'NULL')
         || ', ttipotrat)
                  AND ttipomap = NVL(' || NVL(TO_CHAR(ptipmap), 'NULL')
         || ', ttipomap)
             ORDER BY LPAD(cmapead, 9, ''0'')';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_listadomaps;

   FUNCTION f_get_cabeceramap(
      pcmapead IN VARCHAR2,
      ptcomentario IN OUT VARCHAR2,
      ptipotrat IN OUT VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_cabeceramap';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
   BEGIN
      SELECT tcomentario, ttipotrat
        INTO ptcomentario, ptipotrat
        FROM map_cabecera
       WHERE cmapead LIKE pcmapead;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_cabeceramap;

   FUNCTION f_get_lsttablahijos(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_lsttablahijos';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT DISTINCT t.ctabla, t.ctabla || ''.-'' || t.tdescrip descripcio
                    FROM map_tabla t, map_cab_tratar c, map_comodin m
                   WHERE t.ctabla = c.ctabla
                     AND m.cmapead = '''
         || pcmapead
         || '''
                     AND c.cmapead = m.cmapcom
                   UNION
                   SELECT   t.ctabla, t.ctabla || ''.-'' || t.tdescrip descripcio
                    FROM map_tabla t
                   WHERE t.ctabla = 0
                   ORDER BY 1';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_lsttablahijos;

   FUNCTION f_get_objeto(
      node_value IN VARCHAR2,
      node_label IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                          := 'node_value = ' || node_value || ' - node_label = ' || node_label;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_objeto';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      pos1 := INSTR(node_value, '-', 1);
      pos2 := INSTR(node_value, '-', -1);
      vsquery :=
         'SELECT ttag, tpare, ctablafills, norden, nordfill,
                catributs
           FROM map_xml
          WHERE cmapead = SUBSTR('''
         || node_value || ''', 1,' ||(pos1 - 1) || ')
            AND tpare = SUBSTR(''' || node_value || ''',' ||(pos1 + 1) || ','
         ||(pos2 - pos1 - 1) || ')
            AND ttag = ''' || node_label || '''
            AND nordfill = SUBSTR(''' || node_value || ''',' ||(pos2 + 1) || ')';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_objeto;

   FUNCTION f_get_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - pnorden = ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapdetalle';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT cmapead, norden, nposicion, nlongitud, ttag
                    FROM map_detalle
                  WHERE cmapead = '''
         || pcmapead || '''
                    AND norden = NVL(' || NVL(TO_CHAR(pnorden), 'NULL') || ', norden)';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapdetalle;

   FUNCTION f_get_mapdettratar(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - pnorden = ' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT   md.*, mt.tdescrip
                  FROM map_det_tratar md, map_tabla mt
                  WHERE cmapead = '''
         || pcmapead || '''
                    AND norden = NVL(' || NVL(TO_CHAR(pnorden), 'NULL')
         || ', norden)
                    AND md.ctabla = mt.ctabla
                 ORDER BY md.ctabla DESC';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapdettratar;

   FUNCTION f_set_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcampo IN VARCHAR2,
      ptmascara IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      pctipcampo IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead = ' || pcmapead || ' - ptcampo = ' || ptcampo;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      UPDATE map_det_tratar
         SET tcondicion = ptcondicion,
             tmascara = ptmascara,
             ctipcampo = pctipcampo
       WHERE cmapead = pcmapead
         AND ctabla = pctabla
         AND nveces = pnveces
         AND tcampo = ptcampo;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_mapdettratar;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden || ' - pnposicion ='
            || pnposicion || ' - pnlongitud =' || pnlongitud;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapdetalle';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
   BEGIN
      UPDATE map_detalle
         SET nposicion = pnposicion,
             nlongitud = pnlongitud
       WHERE cmapead = pcmapead
         AND norden = pnorden;

      COMMIT;
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         ROLLBACK;
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         ROLLBACK;
         RETURN 1;
   END f_set_mapdetalle;

   FUNCTION f_get_mapcabecera(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapcabecera';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT *
                    FROM map_cabecera
                    WHERE cmapead = '''
         || pcmapead || '''';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcabecera;

   FUNCTION f_get_mapcomodin(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapcomodin';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT *
                    FROM map_comodin
                    WHERE cmapead = '''
         || pcmapead || '''';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcomodin;

   FUNCTION f_get_mapcabtratar(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapcabtratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT *
                    FROM map_cab_tratar
                    WHERE cmapead = '''
         || pcmapead || '''';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcabtratar;

   FUNCTION f_get_maptabla(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_maptabla';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT   ctabla, tdescrip, tfrom
                FROM map_tabla
                WHERE (ctabla IN(SELECT ctabla
                               FROM map_cab_tratar t, map_comodin c
                              WHERE t.cmapead = c.cmapcom
                                AND c.cmapead = '''
         || pcmapead || ''')
                   OR(ctabla LIKE ''' || pcmapead || '%''' || '))
         ORDER BY ctabla';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_maptabla;

   FUNCTION f_get_mapcondicion(pcmapead IN VARCHAR2, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery := 'Select * from map_condicion order by ncondicion';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_mapcondicion;

   FUNCTION f_generar_listados(
      pmap IN VARCHAR2,
      pparam IN VARCHAR2,
      pejecutarep OUT NUMBER,
      vtimp OUT t_iax_impresion,
      mensajes IN OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
                                   := 'parámetros - pmap = ' || pmap || ' pparam = ' || pparam;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_ejecuta';
      vnerror        NUMBER(10) := 0;
      v_ttipomap     map_cabecera.ttipomap%TYPE;
      v_nomfich      VARCHAR2(400);
      v_smapead      NUMBER(10);
      v_texto        VARCHAR2(400);
      v_cidioma      idiomas.cidioma%TYPE;
      v_nomfitx      VARCHAR2(200);   -- Bug 21838 - 22/05/2012 - JLTS
      vparam2        VARCHAR2(200);   -- Bug 21838 - 22/05/2012 - JLTS
      params_out     VARCHAR2(200);   -- Bug 21838 - 22/05/2012 - JLTS
      vobimp         ob_iax_impresion := ob_iax_impresion();
      perror         VARCHAR2(200);
      preport        VARCHAR2(200);
   BEGIN
      --Comprovem els paràmetres d'entrada.
      vtimp := t_iax_impresion();

      IF pmap IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      --Es busca el tipus de map.
      v_ttipomap := pac_map.f_get_tipomap(pmap);

      IF v_ttipomap IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
         RAISE e_object_error;
      END IF;

      v_cidioma := pac_md_common.f_get_cxtidioma;
      vpasexec := 3;

      IF v_ttipomap = 3 THEN   --XML
         pac_map.p_genera_parametros_xml(pmap, pparam);
         vnerror := pac_map.genera_map(pmap, v_smapead);
      ELSE
         -- Bug 13461 - 15/03/2010 - AMC
         SELECT REPLACE(pparam, '|')
           INTO vparam2
           FROM DUAL;

         v_nomfitx := pac_map.f_get_nomfichero(pmap);
         v_nomfitx := SUBSTR(v_nomfitx, INSTR(v_nomfitx, '\', -1) + 1);
         v_nomfitx := REPLACE(v_nomfitx, '.csv', '_' || vparam2 || '.csv');
         vnerror := pac_map.f_extraccion(pmap, pparam, v_nomfitx, params_out);
      -- Fi Bug 13461 - 15/03/2010 - AMC

      --pac_map.p_genera_parametros_fichero(pmap, pparam);
      END IF;

      vpasexec := 4;

      -- Bug 13461 - 15/03/2010 - AMC
      --vnerror := pac_map.genera_map(pmap, v_smapead);
      -- Fi Bug 13461 - 15/03/2010 - AMC
      IF vnerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 5;

      IF v_ttipomap = 3 THEN
         v_nomfich := pac_map.f_obtener_xml_texto;

         IF v_nomfich IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
            RAISE e_object_error;
         END IF;

         --Mensaje de Se ha generado XML
         v_texto := f_axis_literales(9001590, v_cidioma);
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_texto);
      ELSE
         v_nomfich := pac_map.f_get_nomfichero(pmap);

         IF v_nomfich IS NULL THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001538);
            RAISE e_object_error;
         END IF;

         -- Bug 13461 - 15/03/2010 - AMC
         IF v_nomfitx IS NOT NULL THEN
            v_nomfich := SUBSTR(v_nomfich, 0, INSTR(v_nomfich, '\', -1)) || v_nomfitx;
         END IF;

         -- Fi Bug 13461 - 15/03/2010 - AMC

         --Mensaje de Se ha generado map y ruta
         v_texto := f_axis_literales(105267, v_cidioma) || v_nomfich;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0, v_texto);
      END IF;

      vpasexec := 6;
      -- Bug 14067 - 13/04/2010 - AMC
      pejecutarep := pac_map.f_get_ejereport(pmap);

      -- Fi Bug 14067 - 13/04/2010 - AMC
      IF v_nomfich IS NOT NULL THEN
         --BUG20357 - JTS - 16/12/2011
         IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa, 'SO_SERV_FICH'),
                'WINDOWS') = 'UNIX' THEN
            vobimp.fichero := REPLACE(v_nomfich, '\', '/');
         ELSE
            vobimp.fichero := v_nomfich;
         END IF;

         --FiBUG20357
         vtimp.EXTEND;
         vtimp(vtimp.LAST) := vobimp;

         IF pejecutarep > 0 THEN
            vnerror := pac_md_listado.f_genera_report(NULL, pac_md_common.f_get_cxtempresa,
                                                      v_nomfich,
                                                      pac_md_common.f_get_cxtidioma, pmap,
                                                      perror, preport, mensajes);
            vobimp := ob_iax_impresion();

            --BUG20357 - JTS - 16/12/2011
            IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'SO_SERV_FICH'),
                   'WINDOWS') = 'UNIX' THEN
               vobimp.fichero := REPLACE(preport, '\', '/');
            ELSE
               vobimp.fichero := preport;
            END IF;

            --FiBUG20357
            vtimp.EXTEND;
            vtimp(vtimp.LAST) := vobimp;
         END IF;

         IF pejecutarep > 1 THEN
            vnerror := pac_md_listado.f_genera_report(NULL, pac_md_common.f_get_cxtempresa,
                                                      v_nomfich,
                                                      pac_md_common.f_get_cxtidioma, pmap,
                                                      perror, preport, mensajes, 2);
            vobimp := ob_iax_impresion();

            --BUG20357 - JTS - 16/12/2011
            IF NVL(pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                 'SO_SERV_FICH'),
                   'WINDOWS') = 'UNIX' THEN
               vobimp.fichero := REPLACE(preport, '\', '/');
            ELSE
               vobimp.fichero := preport;
            END IF;

            --FiBUG20357
            vtimp.EXTEND;
            vtimp(vtimp.LAST) := vobimp;
         END IF;
      END IF;

      RETURN v_nomfich;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_generar_listados;

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
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := 'pcmapead =' || pcmapead || ' - pttipomap =' || pttipomap || ' - pcseparador ='
            || pcseparador || ' - pcmapcomodin =' || pcmapcomodin || ' - pttipotrat ='
            || pttipotrat || ' - ptcomentario =' || ptcomentario || ' - ptparametros ='
            || ptparametros || ' - pcmanten =' || pcmanten || ' - ptparametros ='
            || ptparametros || ' - pgenera_report =' || pgenera_report;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapcabecera';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_map.f_set_mapcabecera(pcmapead, ptdesmap, ptparpath, pttipomap,
                                           pcseparador, pcmapcomodin, pttipotrat,
                                           ptcomentario, ptparametros, pcmanten,
                                           pgenera_report, pcmapead_salida);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapcabecera;

   FUNCTION f_set_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_set_mapcomodin(pcmapead, pcmapcom);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapcomodin;

   FUNCTION f_del_mapcomodin(
      pcmapead IN VARCHAR2,
      pcmapcom IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pcmapcom =' || pcmapcom;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapcomodin';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pcmapcom IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_mapcomodin(pcmapead, pcmapcom);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapcomodin;

   FUNCTION f_set_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptsenten IN VARCHAR2,
      pcparam IN NUMBER,
      pcpragma IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pctabla =' || pctabla || ' - pnveces =' || pnveces
            || ' - ptsenten =' || ptsenten || ' - pcparam =' || pcparam || ' - pcpragma ='
            || pcpragma;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapcabtratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_set_mapcabtratar(pcmapead, pctabla, pnveces, ptsenten, pcparam,
                                            pcpragma);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapcabtratar;

   FUNCTION f_del_mapcabtratar(
      pcmapead IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnveces =' || pnveces || ' - pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapcabtratar';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pctabla IS NULL
         OR pnveces IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_mapcabtratar(pcmapead, pctabla, pnveces);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapcabtratar;

   FUNCTION f_set_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      pcatributs IN NUMBER,
      pctablafills IN NUMBER,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pTPARE =' || ptpare || ' - pNORDFILL ='
            || pnordfill || ' - pTTAG =' || pttag || ' - pCATRIBUTS =' || pcatributs
            || ' - pCTABLAFILLS =' || pctablafills;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapxml';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_set_mapxml(pcmapead, ptpare, pnordfill, pttag, pcatributs,
                                      pctablafills, pnorden);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapxml;

   FUNCTION f_del_mapxml(
      pcmapead IN VARCHAR2,
      ptpare IN VARCHAR2,
      pnordfill IN NUMBER,
      pttag IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pTPARE =' || ptpare || ' - pNORDFILL ='
            || pnordfill || 'pTTAG = ' || pttag;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapxml';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR ptpare IS NULL
         OR pnordfill IS NULL
         OR pttag IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_mapxml(pcmapead, ptpare, pnordfill, pttag);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapxml;

   FUNCTION f_set_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      pnposicion IN NUMBER,
      pnlongitud IN NUMBER,
      pttag IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden || ' - pnposicion ='
            || pnposicion || ' - pnlongitud =' || pnlongitud || ' - pttag =' || pttag;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapdetalle';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_set_mapdetalle(pcmapead, pnorden, pnposicion, pnlongitud, pttag);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapdetalle;

   FUNCTION f_del_mapdetalle(
      pcmapead IN VARCHAR2,
      pnorden IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pcmapead =' || pcmapead || ' - pnorden =' || pnorden;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapdetalle';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pcmapead IS NULL
         OR pnorden IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_mapdetalle(pcmapead, pnorden);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapdetalle;

   FUNCTION f_set_maptabla(
      pctabla IN NUMBER,
      ptfrom IN VARCHAR2,
      ptdescrip IN VARCHAR2,
      pctabla_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pctabla =' || pctabla || ' - ptfrom =' || ptfrom || ' - ptdescrip =' || ptdescrip;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_maptabla';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_map.f_set_maptabla(pctabla, ptfrom, ptdescrip, pctabla_out);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_maptabla;

   FUNCTION f_del_maptabla(pctabla IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_maptabla';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pctabla IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_maptabla(pctabla);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
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
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapdettratar';
      vnumerr        NUMBER := 0;
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

      vnumerr := pac_map.f_set_mapdettratar(pcmapead, ptcondicion, pctabla, pnveces, ptcampo,
                                            pctipcampo, ptmascara, pnorden, ptsetwhere);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapdettratar;

   FUNCTION f_del_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapdettratar';
      vnumerr        NUMBER := 0;
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

      vnumerr := pac_map.f_del_mapdettratar(pcmapead, ptcondicion, pctabla, pnveces, ptcampo,
                                            pnorden, ptsetwhere);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapdettratar;

   FUNCTION f_set_mapcondicion(
      pncondicion IN NUMBER,
      ptvalcond IN VARCHAR2,
      pnposcond IN NUMBER,
      pnlongcond IN NUMBER,
      pnordcond IN NUMBER,
      pctabla IN NUMBER,
      pncondicion_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pncondicion =' || pncondicion || ',ptvalcond=' || ptvalcond || ',pnposcond='
            || pnposcond || ',pnlongcond=' || pnlongcond || ',pnordcond=' || pnordcond
            || ',pctabla=' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_set_mapcondicion';
      vnumerr        NUMBER := 0;
   BEGIN
      vnumerr := pac_map.f_set_mapcondicion(pncondicion, ptvalcond, pnposcond, pnlongcond,
                                            pnordcond, pctabla, pncondicion_out);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_mapcondicion;

   FUNCTION f_del_mapcondicion(pncondicion IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pncondicion =' || pncondicion;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_del_mapcondicion';
      vnumerr        NUMBER := 0;
   BEGIN
      IF pncondicion IS NULL THEN
         RETURN 103135;
      END IF;

      vnumerr := pac_map.f_del_mapcondicion(pncondicion);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_del_mapcondicion;

   FUNCTION f_get_unico_mapdettratar(
      pcmapead IN VARCHAR2,
      ptcondicion IN VARCHAR2,
      pctabla IN NUMBER,
      pnveces IN NUMBER,
      ptcampo IN VARCHAR2,
      pnorden IN NUMBER,
      ptsetwhere IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'pcmapead =' || pcmapead || ',ptcondicion=' || ptcondicion || ',pctabla='
            || pctabla || ',pnveces=' || pnveces || ',ptcampo=' || ptcampo || ',pnorden='
            || pnorden || ',ptsetwhere=' || ptsetwhere;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.f_get_unico_mapdettratar';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery :=
         'SELECT   md.*, mt.tdescrip
                  FROM map_det_tratar md, map_tabla mt
                  WHERE cmapead = '''
         || pcmapead || '''
                    AND norden = NVL(' || NVL(TO_CHAR(pnorden), 'NULL')
         || ', norden)
                    AND md.ctabla = mt.ctabla' || ' and md.CTABLA = ' || pctabla
         || ' and md.tcondicion = ''' || ptcondicion || ''' and md.nveces = ' || pnveces
         || ' and md.tcampo = ''' || ptcampo || ''' and md.tsetwhere = ''' || ptsetwhere
         || ''' ORDER BY md.ctabla DESC';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_mapdettratar;

   FUNCTION f_get_unico_mapcondicion(pncondicion IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pncondicion =' || pncondicion;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_unico_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery := 'Select * from map_condicion WHERE NCONDICION = ' || pncondicion
                 || ' order by ncondicion';
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_mapcondicion;

   FUNCTION f_get_unico_maptabla(pctabla IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pctabla =' || pctabla;
      vobject        VARCHAR2(200) := 'PAC_MD_MAP.F_get_unico_mapcondicion';
      cur            sys_refcursor;
      nivelmin       NUMBER;
      v_inici        NUMBER := 0;
      vtiptrat       VARCHAR2(1);
      pos1           NUMBER;
      pos2           NUMBER;
      vsquery        VARCHAR2(500);
   BEGIN
      vsquery := 'Select * from map_tabla WHERE CTABLA = ' || pctabla;
      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN NULL;
   END f_get_unico_maptabla;
END pac_md_map;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_MAP" TO "PROGRAMADORESCSI";
