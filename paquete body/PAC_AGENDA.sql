--------------------------------------------------------
--  DDL for Package Body PAC_AGENDA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_AGENDA" AS
/******************************************************************************
   NOMBRE:       PAC_AGENDA
   PROPÓSITO: Gestion de la agenda

    REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        17/11/2010   XPL                Creación package
   2.0        25/02/2011   JMF              0017744: CRT - Mejoras en agenda
   3.0        25/03/2011   XPL              0017770 - MDP003 - Anàlisi de l'agenda
   4.0        25/07/2011   ICV              0018845: CRT901 - Modificacionas tareas usuario: boton responder, grupos, envio de mail al crear tarea,etc
   5.0        08/06/2012   APD              0022342: MDP_A001-Devoluciones
   6.0        31/08/2012   ASN              0023101: LCOL_S001-SIN - Apuntes de agenda automáticos - Se añade ntramit para apuntes automaticos de siniestros
   7.0        15/03/2013   AMJ              0026173: LCOL_T001- Modificar mensajes de errores
   8.0        11/08/2017   JGONZALEZ        CONF-1005: Desarrollo de GAP 67 solicitud de apoyo tecnico
   9.0        17/04/2019   SGM              IAXIS 3482 SGM  17/04/2019  se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
******************************************************************************/
   FUNCTION f_get_literal_grupo(pcgrupo IN VARCHAR2, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vliteral       VARCHAR2(200) := '';
      vcont          NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO vcont
        FROM agd_grupos
       WHERE cgrupo = pcgrupo
         AND cempres = pcempres;

      IF vcont = 0 THEN
         SELECT ff_desvalorfijo(800032, pcidioma, pcgrupo)
           INTO vliteral
           FROM DUAL;
      ELSE
         SELECT f_axis_literales(9001801, pcidioma) || ' - ' || tdesc
           INTO vliteral
           FROM agd_grupos
          WHERE cempres = pcempres
            AND cidioma = pcidioma
            AND cgrupo = pcgrupo;
      END IF;

      RETURN vliteral;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END;

   FUNCTION f_nombre_grupo(pcempres IN NUMBER, ptgrupo IN VARCHAR2, pcidioma IN NUMBER)
      RETURN VARCHAR2 IS
      vliteral       VARCHAR2(200) := '';
      vcont          NUMBER;
   BEGIN
      IF ptgrupo IS NOT NULL THEN
         SELECT COUNT(1)
           INTO vcont
           FROM agd_grupos
          WHERE csubgrup = ptgrupo
            AND cempres = pcempres;

         IF vcont = 0 THEN
            vliteral := ff_desagente(ptgrupo);
         ELSE
            SELECT f_axis_literales(9001801, pcidioma) || ' - ' || tdesc
              INTO vliteral
              FROM agd_grupos
             WHERE cempres = pcempres
               AND cidioma = pcidioma
               AND csubgrup = ptgrupo;
         END IF;
      END IF;

      RETURN vliteral;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END;

   FUNCTION f_get_lstapuntes(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcidioma IN NUMBER,
      pfapunte IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pcusuari IN VARCHAR2,
      pcapuage IN VARCHAR2,
      pquery OUT CLOB,
      pcempres IN NUMBER,
      pcusuario IN VARCHAR2,
      pntramit IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(200) := 'pac_agenda.f_get_lstapuntes';
      vpar           VARCHAR2(4000)
         := ' a=' || pidapunte || ' g=' || pidagenda || ' c=' || pcclagd || ' t=' || ptclagd
            || ' c=' || pcconapu || ' e=' || pcestapu || ' g=' || pcgrupo || ' t=' || ptgrupo
            || ' a=' || pttitapu || ' c=' || pctipapu || ' p=' || pcperagd || ' a='
            || pcambito || ' p=' || pcpriori || ' i=' || pcidioma || ' f=' || pfapunte
            || ' a=' || pfalta || ' r=' || pfrecordatorio || ' u=' || pcusuari || ' a='
            || pcapuage || ' uss=' || pcusuario || ' ntr=' || pntramit;
      vlin           NUMBER;
      vwhere         CLOB;
      vcont          NUMBER;
      vctipage       NUMBER;
      vcagente       NUMBER;
   BEGIN
      vlin := 1000;

      IF pidapunte IS NOT NULL THEN
         vlin := 1005;
         vwhere := vwhere || ' and ap.idapunte = ' || pidapunte;
      END IF;

      IF pidagenda IS NOT NULL THEN
         vwhere := vwhere || ' and agd.idagenda = ' || pidagenda;
      END IF;

      IF pcclagd IS NOT NULL THEN
         vlin := 1010;
         vwhere := vwhere || ' and agd.cclagd IN (' || pcclagd||',3)';

         IF ptclagd IS NOT NULL THEN
            vlin := 1015;
            vwhere := vwhere || ' and agd.tclagd = ' || CHR(39) || ptclagd || CHR(39);
         END IF;
      END IF;

      IF pcconapu IS NOT NULL THEN
         vlin := 1020;
         vwhere := vwhere || ' and ap.cconapu = ' || pcconapu;
      END IF;

      IF pcestapu IS NOT NULL THEN
         vlin := 1025;
         vwhere := vwhere || ' and agm.cestapu = ' || pcestapu;
      END IF;

      IF pttitapu IS NOT NULL THEN
         vlin := 1030;
         vwhere := vwhere || ' AND upper(ap.ttitapu) like upper(''%' || pttitapu || '%'')';
      END IF;

      IF pctipapu IS NOT NULL THEN
         vlin := 1035;
         vwhere := vwhere || ' and ap.ctipapu = ' || pctipapu;
      END IF;

      IF pcperagd IS NOT NULL THEN
         vlin := 1040;
         vwhere := vwhere || ' and ap.cperagd = ' || pcperagd;
      END IF;

      IF pfalta IS NOT NULL THEN
         vlin := 1045;
         vwhere := vwhere || ' and trunc(ap.falta) = ' || CHR(39) || pfalta || CHR(39);
      END IF;

      IF pfrecordatorio IS NOT NULL THEN
         vlin := 1050;
         vwhere := vwhere || ' and trunc(ap.frecordatorio) = ' || CHR(39) || pfrecordatorio
                   || CHR(39);
      END IF;

      IF pfapunte IS NOT NULL THEN
         vlin := 1055;
         vwhere := vwhere || ' and trunc(ap.fapunte) = ' || CHR(39) || pfapunte || CHR(39);
      END IF;

      IF pntramit  IS NOT NULL THEN
         vlin := 1056;
         vwhere := vwhere || ' and agd.ntramit = ' || pntramit;
      END IF;

      -- INI BUG 17048 JBN --
      vlin := 1060;

      SELECT r.ctipage, r.cagente
        INTO vctipage, vcagente
        FROM redcomercial r, usuarios uu
       WHERE uu.cusuari = pcusuario
         AND r.cagente = uu.cdelega
         AND r.cempres = pcempres
         AND uu.cempres = r.cempres
         AND r.fmovfin IS NULL
         AND uu.cidioma = pcidioma;

      IF pidapunte IS NULL
         OR pidagenda IS NULL THEN
         IF ptgrupo IS NOT NULL THEN
            -- SUBGRUP
            vlin := 1062;
            vwhere := vwhere || ' AND agd.cusuari = ' || CHR(39) || ptgrupo || CHR(39);
         END IF;

         -- ini Bug 0017744 - 25/02/2011 - JMF
         IF pcapuage = 0 THEN   -- Todos
            vlin := 1065;
            NULL;
         ELSIF pcapuage = 1 THEN   -- Asignados a mi
            vlin := 1070;
            vwhere := vwhere || ' AND agd.cusuari =' || CHR(39) || pcusuario || CHR(39);
         ELSIF pcapuage = 2 THEN   -- Creados por mi
            vlin := 1075;
            vwhere := vwhere || ' AND ama.CUSUARI_ORI =' || CHR(39) || pcusuario || CHR(39);
         ELSIF pcapuage = 3 THEN   -- Asignados a mi y al grupo
            vlin := 1080;

            IF pcgrupo IS NOT NULL
               AND ptgrupo IS NOT NULL THEN
               vwhere := vwhere || '  and (( agd.cgrupo = ''' || pcgrupo||'''';
               vwhere :=
                  vwhere
                  || '  and ( agd.tgrupo is null or (agd.tgrupo is not null and agd.tgrupo = '''
                  || ptgrupo || ''') ) )';
            ELSIF pcgrupo IS NOT NULL THEN
               vwhere := vwhere || '  and ( ( agd.cgrupo = ''' || pcgrupo || ''')'; 
            ELSE
               vwhere := vwhere || '  and ( (''' || pcgrupo || ''' is not null ) ';
            END IF;

            vwhere :=
               vwhere || ' or (agd.CUSUARI is not null and upper(agd.CUSUARI) like upper('''
               || pcusuario
               || '''))
               or (ama.CUSUARI_DEST is not null and upper(ama.CUSUARI_DEST) like upper('''
               || pcusuario || '''))
                 ';
            vwhere :=
               vwhere
               || ' OR ( (ama.tgrupo_DEST is not null and ama.cgrupo_dest is not null and '
               || '          ama.tgrupo_dest in (select distinct(agg.CSUBGRUP) from agd_grupos agg, agd_grupos_usu aguu where '
               || '                               agg.cgrupo = ama.cgrupo_dest and agg.CSUBGRUP = aguu.CGRUPO '
               || '                                 and agg.cempres = ' || pcempres
               || ' and agg.cempres = aguu.cempres '
               || '                               and upper(aguu.CUSUARIO) like upper('''
               || pcusuario || ''') ' || '  ) )    ) OR ( ama.cgrupo_dest = ''' || vctipage
               || ''' and ama.tgrupo_dest = ''' || vcagente || ''' )     ) ';
         ELSIF pcapuage = 4 THEN   -- Al grupo seleccionado
            vlin := 1110;

            IF pcgrupo IS NULL THEN
               RETURN 103135;
            END IF;

            vwhere := vwhere || '  and  agd.cgrupo = ''' || pcgrupo || '''';

            IF ptgrupo IS NOT NULL THEN
               vwhere :=
                  vwhere
                  || '  and ( agd.tgrupo is null or (agd.tgrupo is not null and agd.tgrupo = '''
                  || ptgrupo || ''') )';
            END IF;
         ELSIF pcapuage = 5 THEN   -- Asignados/creados por mi
            vlin := 1115;
            vwhere := vwhere || ' AND (agd.cusuari =' || CHR(39) || pcusuario || CHR(39)
                      || ' OR agd.cusualt =' || CHR(39) || pcusuario || CHR(39) || ') ';
         END IF;
      -- fin Bug 0017744 - 25/02/2011 - JMF
      END IF;

      --ctipage ho veu tot
      IF vctipage <> 0 THEN
         vwhere :=
            vwhere || '   and   (( (  ama.tgrupo_dest is not null and  ama.tgrupo_dest in'
            || '         (SELECT a.cagente '
            || '                   FROM (SELECT     LEVEL nivel, cagente '
            || '                                 FROM redcomercial r '
            || '                                WHERE '
            || '                                   r.fmovfin is null '
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || pcempres
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )'
            || '  or (ama.tgrupo_dest is not null and ama.cgrupo_dest is not null and '
            || '          agd.tgrupo in (select distinct(agg.CSUBGRUP) from agd_grupos agg, agd_grupos_usu aguu where '
            || '                               agg.cgrupo = ama.cgrupo_dest and agg.CSUBGRUP = aguu.CGRUPO '
            || '                                 and agg.cempres = ' || pcempres
            || ' and agg.cempres = aguu.cempres '
            || '                               and upper(aguu.CUSUARIO) like upper('''
            || pcusuario || ''') '
            || '  ) ) or (ama.cusuari_dest is not null and ( upper(ama.cusuari_dest) like upper('''
            || pcusuario || ''') ' || ' or ( ama.cusuari_dest in '
--            || '         (SELECT cusuari ' -- 21839:ASN:13/04/2012
            || '         (SELECT rr.cusuari '
            || '                   FROM (SELECT     u.cusuari, r.cagente '
            || '                                 FROM redcomercial r, usuarios u '
            || '                                WHERE '
            || '                                   r.fmovfin is null and r.cagente = u.cdelega'
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || pcempres
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )' || ') ' || ' ) ' || ') ';
         vwhere :=
            vwhere || '   or  ( ( ama.TGRUPO_ORI is not null and  ama.TGRUPO_ORI in'
            || '         (SELECT a.cagente '
            || '                   FROM (SELECT     LEVEL nivel, cagente '
            || '                                 FROM redcomercial r '
            || '                                WHERE '
            || '                                   r.fmovfin is null '
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || pcempres
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )'
            || '  or (ama.TGRUPO_ORI is not null and ama.CGRUPO_ORI is not null and '
            || '          ama.TGRUPO_ORI in (select distinct(agg.CSUBGRUP) from agd_grupos agg, agd_grupos_usu aguu where '
            || '                               agg.cgrupo = ama.CGRUPO_ORI and agg.CSUBGRUP = aguu.CGRUPO '
            || '                                 and agg.cempres = ' || pcempres
            || ' and agg.cempres = aguu.cempres '
            || '                               and upper(aguu.CUSUARIO) like upper('''
            || pcusuario || ''') '
            || '  ) ) or (ama.CUSUARI_ORI is not null and ( upper(ama.CUSUARI_ORI) like upper('''
            || pcusuario || ''') ' || ' or ( ama.CUSUARI_ORI in '
--            || '         (SELECT cusuari ' -- 21839:ASN:13/04/2012
            || '         (SELECT rr.cusuari '
            || '                   FROM (SELECT     u.cusuari, r.cagente '
            || '                                 FROM redcomercial r, usuarios u '
            || '                                WHERE '
            || '                                   r.fmovfin is null and r.cagente = u.cdelega'
            || '                           START WITH '
            || '                                   r.CTIPAGE =  ' || vctipage
            || '                                   AND r.cempres = ' || pcempres
            || '                                   AND R.CAGENTE = ' || vcagente
            || '                                   and r.fmovfin is null '
            || '                           CONNECT BY PRIOR r.cagente =(r.cpadre + 0) '
            || '                                  AND PRIOR r.cempres =(r.cempres + 0) '
            || '                                  and r.fmovfin is null '
            || '                                  AND r.cagente >= 0) rr, '
            || '                         agentes a '
            || '                    where rr.cagente = a.cagente ) )' || ') ' || ' ) '
            || ')) ';
      /*   || '  ) ) or (ama.CUSUARI_ORI is not null and upper(ama.CUSUARI_ORI) like upper('''
         || pcusuario || ''')) ) )     ';*/
      END IF;

      -- FI BUG 17048 JBN --
      vlin := 1200;
      pquery :=
         'SELECT ap.idapunte, agd.idagenda, ap.cconapu, ff_desvalorfijo(800031,' || pcidioma
         || ', ap.cconapu) tconapu, agd.cclagd, agd.tclagd, decode (agd.cclagd,1,(select npoliza ||''-''||ncertif from seguros where agd.tclagd = to_char(seguros.sseguro)),agd.tclagd) tclagd_out, ff_desvalorfijo(800029,'
         || pcidioma || ', agd.cclagd) destclagd, ap.ctipapu,ff_desvalorfijo(323,' || pcidioma
         || ', ap.ctipapu) ttipapu, ap.falta, agd.cusuari,ap.ttitapu, agd.cgrupo, agd.ntramit,
         (SELECT u.tusunom tvalor
          FROM agd_grupos     g,
               agd_grupos_usu s,
               usuarios       u
         WHERE g.cgrupo = s.cgrupo
           AND s.cusuario = u.cusuari
           AND g.cgrupo = agd.tgrupo) destgrupo, agd.tgrupo,
         agm.cestapu, ff_desvalorfijo(29,'
         || pcidioma
         || ', agm.cestapu) testapu, ap.tapunte,agm.FESTAPU, agd.cperagd, ap.CUSUALT, ap.frecordatorio, pac_agenda.f_get_literal_grupo(agd.cgrupo, '
         || pcempres || ',' || pcidioma
         || ') tlistgrupo,
          ama.CUSUARI_ori, ama.cgrupo_ori,
          (SELECT tdesc tvalor
             FROM agd_grupos a
            WHERE a.cempres = '
         || pcempres
         || ' AND a.cgrupo = ama.tgrupo_ori) destgrupo_ori, ama.tgrupo_ori,
                         pac_agenda.f_get_literal_grupo(ama.cgrupo_ori, '
         || pcempres || ',' || pcidioma
         || ')  tlistgrupo_ori,
        DECODE(agd.CUSUARI,ama.cusuari_dest||decode(ama.tgrupo_dest,null,null,( decode(ama.cusuari_DEST,null,null,'' / '')))||ama.TGRUPO_DEST,
            ama.cusuari_dest||decode(ama.tgrupo_dest,null,null,( decode(ama.cusuari_DEST,null,null,'' / '')))||ama.TGRUPO_DEST,agd.CUSUARI) tdestino,
         ama.cusuari_ori||decode(ama.tgrupo_ori,null,null,( decode(ama.cusuari_ori,null,null,'' / '')))||ama.tgrupo_ori torigen,
         pac_agenda.f_nombre_grupo('
         || pcempres || ',ama.TGRUPO_DEST,' || pcidioma
         || ') tdescgrupo, (select cdelega from usuarios u where ama.CUSUARI_ORI = u.cusuari) tusuoridelega,
         pac_agenda.f_nombre_grupo(7, ama.tgrupo_ori, 2) tusuoridesc,
         decode(agm.cestapu,1,(select tusunom from usuarios usu where usu.cusuari = agm.cusualt),null) tusufinapu,
         agd.TRESP
         from agd_apunte ap, agd_agenda agd, agd_movapunte agm, agd_movagenda ama
         where ap.idapunte = agd.idapunte and
         agd.idapunte = agm.IDAPUNTE and
         ama.idapunte = ap.idapunte
         and ama.idagenda = agd.idagenda
         and ama.nmovagd = (SELECT MAX(m.nmovagd)
                          FROM agd_movagenda m
                         WHERE m.idapunte = ama.idapunte
                         and  m.idagenda = ama.idagenda)
         and agm.NMOVAPU = (select max(m.nmovapu) from agd_movapunte m where m.idapunte = agd.idapunte ) ';
      vlin := 1205; --CONF-347-01/12/2016-RCS
      pquery := pquery || vwhere
                || ' order by ap.idapunte desc, agm.FESTAPU desc,ap.frecordatorio desc';
      --IAXIS-2134 AABC CAMBIO DEL ORDEN EN PANTALLA.        
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobj, vlin, vpar, SQLERRM);
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 1, 2000));
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 2000, 2000));
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 4000, 2000));
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 6000, 2000));
         p_tab_error(f_sysdate, f_user, vobj, 999, vpar, SUBSTR(pquery, 8000, 2000));
         RETURN 1;
   END f_get_lstapuntes;

   FUNCTION f_set_apunte(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcconapu IN NUMBER,
      pcestapu IN NUMBER,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pttitapu IN VARCHAR2,
      ptapunte IN VARCHAR2,
      pctipapu IN NUMBER,
      pcperagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcusuari IN VARCHAR2,
      pfapunte IN DATE,
      pfestapu IN DATE,
      pfalta IN DATE,
      pfrecordatorio IN DATE,
      pidapunte_out OUT NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_apunte';
      vparam         VARCHAR2(4000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcconapu:' || pcconapu
            || ' pcestapu:' || pcestapu || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pttitapu:' || pttitapu || ' pctipapu:' || pctipapu || ' pcperagd:'
            || pcperagd || ' pcambito:' || pcambito || ' pcpriori:' || pcpriori
            || ' pfapunte:' || pfapunte || ' pfalta:' || pfalta;
      vpasexec       NUMBER(5) := 1;
      vcount         NUMBER(5);
      vcmonres       VARCHAR2(10);
      vfmovres       DATE;
      vidapunte      NUMBER := pidapunte;
      vnumerr        NUMBER;
      vusuarii_ori   VARCHAR2(200);

       P_TO           VARCHAR2(500);
       P_TO2          VARCHAR2(500);
       P_FROM         VARCHAR2(500);
       PSUBJECT       VARCHAR2(500);
       PTEXTO         VARCHAR2(500);
       v_creteni      seguros.creteni%TYPE;
       v_csituac      seguros.csituac%TYPE;
       psseguro       seguros.sseguro%TYPE;
       v_sproduc      seguros.sproduc%TYPE;
       nerror         NUMBER;

   BEGIN
      IF vidapunte IS NULL THEN
         vpasexec := 2;

         BEGIN
            SELECT NVL(MAX(idapunte) + 1, 1)
              INTO vidapunte
              FROM agd_apunte;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vidapunte := 1;
         END;
      ELSIF pcestapu IS NOT NULL
            AND pcestapu = 1
            AND pidagenda IS NOT NULL
-- JLB - 26/10/2012 -- Parametrización que permite cambiar el estado a finalizado aunque no seas el credor
            AND NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa,
                                                  'USU_ORI_FINALI_TAREA'),
                    0) = 1 THEN
-- JLB - 26/10/2012 -- Parametrización que permite cambiar el estado a finalizado aunque no seas el credor
         vpasexec := 3;

         SELECT cusuari_ori
           INTO vusuarii_ori
           FROM agd_movagenda amm
          WHERE amm.idapunte = vidapunte
            AND amm.idagenda = pidagenda
            AND amm.nmovagd = (SELECT MAX(am.nmovagd)
                                 FROM agd_movagenda am
                                WHERE am.idapunte = amm.idapunte
                                  AND am.idagenda = amm.idagenda);

         IF vusuarii_ori IS NOT NULL
            AND f_user <> vusuarii_ori THEN
            RETURN 9907456;
         END IF;
      END IF;

      vpasexec := 4;
      pidapunte_out := vidapunte;

      BEGIN
         vpasexec := 5;

         INSERT INTO agd_apunte
                     (idapunte, cconapu, ctipapu, ttitapu, tapunte, fapunte,
                      cusualt, falta, frecordatorio)
              VALUES (vidapunte, pcconapu, NVL(pctipapu, 0), pttitapu, ptapunte, pfapunte,
                      f_user, NVL(pfalta, f_sysdate), pfrecordatorio);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            vpasexec := 6;

            UPDATE agd_apunte
               SET cconapu = pcconapu,
                   --ctipapu = NVL(pctipapu, 1),
                   ttitapu = pttitapu,
                   tapunte = ptapunte,
                   fapunte = pfapunte,
                   frecordatorio = pfrecordatorio
             WHERE idapunte = vidapunte;
      END;

      vpasexec := 7;
      vnumerr := f_set_movapunte(vidapunte, NULL, pcestapu, NVL(pfestapu, pfalta));

      IF vnumerr != 0 THEN
         RETURN vnumerr;
      END IF;

      IF PCCLAGD = 1 THEN
          IF PCCONAPU = 3 THEN
              IF PCESTAPU = 0 THEN



                  psseguro := ptclagd;

				  p_control_error('FFO10','4','pssegur: '||psseguro);

                   SELECT  seg.csituac, seg.creteni, seg.sproduc
                    INTO v_csituac, v_creteni, v_sproduc
                    FROM seguros seg
                   WHERE seg.sseguro = psseguro;

                  IF NVL(pac_parametros.f_parempresa_n(PAC_MD_COMMON.F_GET_CXTEMPRESA(), 'MAIL_CAMBIOS_ESTADO'), 0) = 1 THEN
                      IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'MAIL_SITUACION_POL'), 0) = 1 THEN
                        IF v_csituac = 4 AND v_creteni = 1 THEN

                          nerror := pac_correo.f_destinatario(PSCORREO => 316,
                                                            PSSEGURO => psseguro,
                                                            P_TO => P_TO,
                                                            P_TO2 => P_TO2,
                                                            PCMOTMOV => NULL);

                              nerror := pac_correo.f_origen(	PSCORREO => 316,
                                                    P_FROM => P_FROM,
                                                    PAVISO => NULL);

                              nerror := pac_correo.f_asunto(PSCORREO => 316,
                                                PCIDIOMA => 8,
                                                PSUBJECT => PSUBJECT,
                                                PSSEGURO => psseguro,
                                                PCMOTMOV => NULL,
                                                PTASUNTO => NULL);

                             nerror := pac_correo.f_cuerpo(PSCORREO => 316,
                                             PCIDIOMA => 8,
                                             PTEXTO => PTEXTO,
                                             PSSEGURO => psseguro,
                                             PNRIESGO => 1,
                                             PNSINIES => NULL,
                                             PCMOTMOV => NULL,
                                             PTCUERPO => NULL,
                                             PCRAMO =>801);

                            nerror := pac_md_informes.f_enviar_mail(
                                          PIDDOC         => NULL,
                                          PMAILGRC       => P_TO,
                                          PRUTAFICHERO   =>  NULL,
                                          PFICHERO       => NULL,
                                          PSUBJECT       => PSUBJECT,
                                          PCUERPO        => PTEXTO,
                                          PMAILCC        => NULL,
                                          PMAILCCO       => NULL,
                                          PDIRECTORIO    => NULL,
                                          PFROM          => P_FROM,
                                          PDIRECTORIO2   => NULL,
                                          PFICHERO2      => NULL);
                         END IF;
                      END IF;
                    END IF;
              END IF;
          END IF;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_apunte;

   FUNCTION f_set_movapunte(
      pidapunte IN NUMBER,
      pnmovapu IN NUMBER,
      pcestapu IN NUMBER,
      pfestapu IN DATE,
      pcusualt IN VARCHAR2 DEFAULT NULL,
      pfalta IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_movapunte';
      vparam         VARCHAR2(500)
         := 'parámetros - pidapunte: ' || pidapunte || ' pnmovapu:' || pnmovapu
            || ' pcestapu:' || pcestapu || ' pfestapu:' || pfestapu || ' pcusualt:' || pcusualt || ' pfalta:' || pfalta;
      vpasexec       NUMBER(5) := 1;
      vnmovapu       NUMBER := pnmovapu;
   BEGIN
      IF pidapunte IS NULL THEN
         RETURN 103135;
      END IF;

      IF pnmovapu IS NULL THEN
         BEGIN
            SELECT NVL(MAX(nmovapu) + 1, 1)
              INTO vnmovapu
              FROM agd_movapunte
             WHERE idapunte = pidapunte;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnmovapu := 1;
         END;
      END IF;

      BEGIN
         INSERT INTO agd_movapunte
                     (idapunte, nmovapu, cestapu, festapu,
                      cusualt, falta)
              VALUES (pidapunte, vnmovapu, pcestapu, NVL(pfestapu, f_sysdate),
                      NVL(pcusualt, f_user), NVL(pfalta, f_sysdate));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agd_movapunte
               SET cestapu = pcestapu,
                   festapu = pfestapu
             WHERE idapunte = pidapunte
               AND nmovapu = vnmovapu;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_movapunte;

   FUNCTION f_asunto(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      psubject OUT VARCHAR2,
      psseguro IN NUMBER,
      pnapunte IN NUMBER,
      pnsinies IN VARCHAR2,
      pcmotmov IN NUMBER)
      RETURN NUMBER IS
      pos            NUMBER;
   BEGIN
      BEGIN
         SELECT asunto
           INTO psubject
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No esixte ningún Subject para este tipo de correo.
      END;

      --sustitución de los npolizas de los mails
      pos := INSTR(psubject, '#NPOLIZA#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NPOLIZA#', pac_correo.f_poliza(psseguro));
      END IF;

      --sustitución de los ncertificado de los mails
      pos := INSTR(psubject, '#CERTIFICADO#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#CERTIFICADO#', pac_correo.f_certificado(psseguro));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#MOVIMIENTO#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#MOVIMIENTO#',
                             pac_correo.f_tipomov(pcmotmov, pcidioma, 1));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#NSOLICI#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NSOLICI#', pac_correo.f_solicitud(psseguro));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#NAPUNTE#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NAPUNTE#', pnapunte);
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#NSINIES#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NSINIES#', psseguro);
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(psubject, '#NTRAMIT#', 1);

      IF pos > 0 THEN
         psubject := REPLACE(psubject, '#NTRAMIT#', pnsinies);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 180285;   -- Error en el Subject del mensaje
   END f_asunto;

   FUNCTION f_cuerpo(
      pscorreo IN NUMBER,
      pcidioma IN NUMBER,
      ptexto OUT VARCHAR2,
      pnapunte IN NUMBER,
      psseguro IN NUMBER,
      pnsinies IN NUMBER DEFAULT NULL,
      pcmotmov IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      pos            NUMBER;
   BEGIN
      BEGIN
         SELECT cuerpo
           INTO ptexto
           FROM desmensaje_correo
          WHERE scorreo = pscorreo
            AND cidioma = pcidioma;
      EXCEPTION
         WHEN OTHERS THEN
            RETURN 151422;
      --No esixte ningún Subject para este tipo de correo.
      END;

      --sustitución de los npolizas de los mails
      pos := INSTR(ptexto, '#NAPUNTE#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NAPUNTE#', pnapunte);
      END IF;

      --sustitución de los npolizas de los mails
      pos := INSTR(ptexto, '#NPOLIZA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NPOLIZA#', pac_correo.f_poliza(psseguro));
      END IF;

      --sustitución de los ncertificado de los mails
      pos := INSTR(ptexto, '#CERTIFICADO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CERTIFICADO#', pac_correo.f_certificado(psseguro));
      END IF;

      --sustitución de los nsolici de los mails
      pos := INSTR(ptexto, '#NSOLICI#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSOLICI#', pac_correo.f_solicitud(psseguro));
      END IF;

      --sustitución de las clauslas de los mails
      pos := INSTR(ptexto, '#CLAUSULA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#CLAUSULA#', pac_correo.f_clausula(psseguro));
      END IF;

      pos := INSTR(ptexto, '#NSINIES#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSINIES#', psseguro);
      END IF;

      --sustitución de los datos de la oficina gestión
      pos := INSTR(ptexto, '#GESTION#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#GESTION#', pac_correo.f_gestion(psseguro));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(ptexto, '#MOVIMIENTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#MOVIMIENTO#',
                           pac_correo.f_movimiento(pcmotmov, pcidioma));
      END IF;

      --sustitución de los datos del motivo del movimiento
      pos := INSTR(ptexto, '#TIPOMOV#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#TIPOMOV#', pac_correo.f_tipomov(pcmotmov, pcidioma, 0));
      END IF;

      --sustitución de los datos del ramo
      pos := INSTR(ptexto, '#RAMO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#RAMO#', pac_correo.f_ramo(psseguro, pcidioma));
      END IF;

      --sustitución de la ofi. tramitadora
      pos := INSTR(ptexto, '#OFITRAMITADORA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#OFITRAMITADORA#', pac_correo.f_tramitadora);
      END IF;

      --sustitución de la matrícula del gestor
      pos := INSTR(ptexto, '#MATRICGESTOR#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#MATRICGESTOR#', f_user);
      END IF;

      --sustitución de la descripción del producto
      pos := INSTR(ptexto, '#PRODUCTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#PRODUCTO#', pac_correo.f_producto(psseguro, pcidioma));
      END IF;

      --sustitución de la fecha de alta solicitud
      pos := INSTR(ptexto, '#FALTA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FALTA#', pac_correo.f_falta(psseguro));
      END IF;

      --sustitución de la nueva nsolicit que reemplaza
      pos := INSTR(ptexto, '#NSOLICIREEMPL#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NSOLICIREEMPL#', pac_correo.f_solicitud_reempl(psseguro));
      END IF;

      -- Sustitucion de la fecha efecto de la póliza
      pos := INSTR(ptexto, '#FEFECTO#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FEFECTO#', pac_correo.f_fefecto(psseguro));
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#FCANCEL#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FCANCEL#', pac_correo.f_fcancel(psseguro));
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#FECHA#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#FECHA#', pac_correo.f_sistema);
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#ORIGEN#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#ORIGEN#', pac_correo.f_origen_tarea(psseguro, pnsinies, pnapunte));
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#DESCRIPCION#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#DESCRIPCION#', pac_correo.f_descripcion_tarea(pnapunte));
      END IF;

      -- Sustitucion de la fecha cancelacion de la póliza
      pos := INSTR(ptexto, '#NTRAMIT#', 1);

      IF pos > 0 THEN
         ptexto := REPLACE(ptexto, '#NTRAMIT#', pnsinies);
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN 152556;   -- Error en el cuerpo del mensaje
   END f_cuerpo;

   FUNCTION f_set_agenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,   --18845 - 25/07/2011 - Se añade el tgrupo
      pcclagd IN NUMBER,
      ptclagd IN VARCHAR2,
      pcperagd IN NUMBER,
      pcusuari_ori IN VARCHAR2 DEFAULT '',
      pcgrupo_ori IN VARCHAR2 DEFAULT '',
      ptgrupo_ori IN VARCHAR2 DEFAULT '',
      pcempres IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL,
      ptevento IN VARCHAR2 DEFAULT 'NUEVA_TAREA',
      pntramit IN NUMBER DEFAULT NULL,   -- 23101:ASN:31/08/2012
      PTRESP IN VARCHAR2 default null)   --CONF-347-01/12/2016-RCS
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_agenda';
      vparam         VARCHAR2(4000)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcusuari:' || pcusuari || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pcclagd:' || pcclagd || ' ptclagd:' || ptclagd || ' pcperagd:' || pcperagd;
      vpasexec       NUMBER(5) := 1;
      vidagenda      NUMBER := pidagenda;
      vnumerr        NUMBER := 0;
      v_cgrupo_ori   VARCHAR2(400);
      v_cusuari_ori  VARCHAR2(400);
      v_trgrupo_ori  VARCHAR2(400);
      v_cgrupo_dest  VARCHAR2(400);
      v_cusuari_dest VARCHAR2(400);
      v_trgrupo_dest VARCHAR2(400);
      v_cestagd      NUMBER;
      v_remi         VARCHAR2(400);
      v_tmail        VARCHAR2(400);
      v_ttexto       VARCHAR2(4000);
      vtgrupo        VARCHAR2(300) := ptgrupo;
      vvtgrupo_ori   VARCHAR2(400) := ptgrupo_ori;
      v_scorreo      NUMBER;
      v_ttextocuerpo VARCHAR2(2000);
      vcgrupo_ori    VARCHAR2(200) := pcgrupo_ori;
      vcgrupo        VARCHAR2(200) := pcgrupo;
      vcusuari       VARCHAR2(200) := pcusuari;
      vcusuari_ori   VARCHAR2(200) := pcusuari_ori;
      conn           utl_smtp.connection;
   BEGIN
      IF pidapunte IS NULL THEN
         RETURN 103135;
      END IF;

      vpasexec := 2;

      IF vidagenda IS NULL THEN
         BEGIN
            SELECT NVL(MAX(idagenda) + 1, 1)
              INTO vidagenda
              FROM agd_agenda;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vidagenda := 1;
         END;
      END IF;

      vpasexec := 3;

      IF pcgrupo IS NOT NULL AND ptgrupo IS NOT NULL THEN
         vcusuari := NULL;
      ELSIF vcusuari IS NOT NULL THEN
         vcgrupo := NULL;
         vtgrupo := NULL;
      END IF;

      vpasexec := 4;

      IF pcgrupo_ori IS NOT NULL AND ptgrupo_ori IS NOT NULL THEN
         vcusuari_ori := NULL;
      ELSIF vcusuari_ori IS NOT NULL THEN
         vcgrupo_ori := NULL;
         vvtgrupo_ori := NULL;
      END IF;

      vpasexec := 5;   --AGD_MOVAGENDA

      BEGIN
         INSERT INTO agd_agenda
                     (idagenda, idapunte, cusuari, cgrupo, tgrupo, cclagd, tclagd,
                      cperagd, cusualt, falta, ntramit,TRESP)   -- 23101:ASN:31/08/2012 --CONF-347-01/12/2016-RCS
              VALUES (vidagenda, pidapunte, vcusuari, vcgrupo, vtgrupo, pcclagd, ptclagd,
                      NVL(pcperagd, 0), f_user, f_sysdate, pntramit,PTRESP);   -- 23101:ASN:31/08/2012 --CONF-347-01/12/2016-RCS

         vnumerr := f_set_movagenda(pidapunte, vidagenda, 0, NULL, vcusuari_ori, vcgrupo_ori,
                                    vvtgrupo_ori, vcusuari, vcgrupo, vtgrupo, f_user, f_sysdate);

         --Miramos si tenemos que enviar mail de apunte nuevo a la agenda
         --18845
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'ENV_MAIL_AGEN'), 0) = 1 THEN
            IF pcgrupo IS NOT NULL AND vtgrupo IS NOT NULL THEN
               SELECT u.mail_usu
                 INTO v_tmail
                 FROM agd_grupos_usu a,
                      usuarios       u
                WHERE a.cusuario = u.cusuari
                  AND a.cempres  = pcempres
                  AND a.cempres  = u.cempres
                  AND a.cgrupo   = pcgrupo
                  AND a.cusuario = vtgrupo;
            ELSIF vcusuari IS NOT NULL THEN
               BEGIN
                  SELECT mail_usu
                    INTO v_tmail
                    FROM usuarios
                   WHERE cusuari = vcusuari;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_tmail := NULL;
               END;

               if v_tmail is null THEN
                  IF LENGTH(vcusuari) < 4 THEN
                     v_tmail := TO_CHAR(vcusuari, '0009');
                  ELSE
                     v_tmail := vcusuari;
                  END IF;

                  v_tmail := 'U' || vcusuari || pac_parametros.f_parempresa_t(pcempres, 'DOM_MAIL');
               end if;
            END IF;

            IF v_tmail IS NOT NULL THEN
               v_remi := pac_parametros.f_parempresa_t(pcempres, 'REM_MAIL');
               v_ttexto := REPLACE(f_axis_literales(9902269, pcidioma), '#NAPUNTE#',
                                   pidapunte);

               BEGIN
                  vpasexec := 6;

                  SELECT scorreo
                    INTO v_scorreo
                    FROM cfg_notificacion
                   WHERE cempres = pcempres
                     AND cmodo = 'GENERAL'
                     AND sproduc = 0
                     AND tevento = NVL(ptevento, pac_parametros.f_parempresa_t(pcempres, 'NUEVA_TAREA'));
                  vpasexec := 7;

                  vnumerr := pac_agenda.f_asunto(v_scorreo, pcidioma, v_ttexto, ptclagd,

                                                 -- BUG 20694 - FAL - 29/02/2012 - añadir sseguro (ptclagd)
                                                 pidapunte, pntramit, NULL);
                  vpasexec := 8;
                  vnumerr := pac_agenda.f_cuerpo(v_scorreo, pcidioma, v_ttextocuerpo,
                                                 pidapunte, ptclagd, pntramit, NULL);
                  -- BUG 20694 - FAL - 29/02/2012 - añadir sseguro (ptclagd)

                  vpasexec := 9;
		   -- IAXIS-2134 AABC ENVIO DE CORREO 
                   p_enviar_correo(p_from => v_remi,
                                   p_to => v_tmail,
                                   p_from2 => v_remi,
                                   p_to2 => NULL,
                                   p_subject => v_ttexto,
                                   p_message => v_ttextocuerpo,
                                   p_cc => NULL);
                  --
                  conn := pac_send_mail.begin_mail(sender     => v_remi,
                                                   recipients => v_tmail,
                                                   cc         => NULL,
                                                   subject    => v_ttexto,
                                                   mime_type  => pac_send_mail.multipart_mime_type || '; charset=UTF-8');

                  vpasexec := 10;

                  pac_send_mail.attach_text(conn      => conn,
                                            data      => v_ttextocuerpo,
                                            mime_type => 'text/html');
                  vpasexec := 11;
                  pac_send_mail.end_mail(conn => conn);
                  vpasexec := 12;

               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                                 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            SELECT cgrupo_ori, cusuari_ori, tgrupo_ori, cestagd, cgrupo_dest,
                   cusuari_dest, tgrupo_dest
              INTO v_cgrupo_ori, v_cusuari_ori, v_trgrupo_ori, v_cestagd, v_cgrupo_dest,
                   v_cusuari_dest, v_trgrupo_dest
              FROM agd_movagenda am
             WHERE am.idagenda = vidagenda
               AND am.idapunte = pidapunte
               AND am.nmovagd = (SELECT MAX(nmovagd)
                                   FROM agd_movagenda am2
                                  WHERE am2.idagenda = am.idagenda
                                    AND am2.idapunte = am.idapunte);

            UPDATE agd_agenda
               SET cclagd = pcclagd,
                   tclagd = ptclagd,
                   CPERAGD = NVL(PCPERAGD, 0),
                   TRESP = PTRESP --CONF-347-01/12/2016-RCS
             WHERE idagenda = vidagenda
               AND idapunte = pidapunte;

            IF (vcusuari IS NOT NULL
                OR pcgrupo IS NOT NULL
                OR ptgrupo IS NOT NULL) THEN
               IF NVL(vcusuari, '-1') <> NVL(v_cusuari_dest, '-1')
                  OR NVL(pcgrupo, '-1') <> NVL(v_cgrupo_dest, '-1')
                  OR NVL(ptgrupo, '-1') <> NVL(v_trgrupo_dest, '-1') THEN
                  UPDATE agd_agenda
                     SET cusuari = vcusuari,
                         cgrupo = pcgrupo,
                         tgrupo = ptgrupo
                   WHERE idagenda = vidagenda
                     AND idapunte = pidapunte;

                  vnumerr := f_set_movagenda(pidapunte, vidagenda, v_cestagd, NULL,
                                             v_cusuari_ori, v_cgrupo_ori, v_trgrupo_ori,
                                             vcusuari, pcgrupo, ptgrupo, f_user, f_sysdate);

                  --Miramos si tenemos que enviar mail de apunte nuevo a la agenda
                          --18845
                  IF NVL(pac_parametros.f_parempresa_n(pcempres, 'ENV_MAIL_AGEN'), 0) = 1 THEN
                     IF pcgrupo IS NOT NULL AND vtgrupo IS NOT NULL THEN
                        SELECT u.mail_usu
                          INTO v_tmail
                          FROM agd_grupos_usu a,
                               usuarios       u
                         WHERE a.cusuario = u.cusuari
                           AND a.cempres  = pcempres
                           AND a.cempres  = u.cempres
                           AND a.cgrupo   = pcgrupo
                           AND a.cusuario = vtgrupo;
                     ELSIF vcusuari IS NOT NULL THEN
                        BEGIN
                           SELECT mail_usu
                             INTO v_tmail
                             FROM usuarios
                            WHERE cusuari = vcusuari;
                        EXCEPTION
                           WHEN OTHERS THEN
                              v_tmail := NULL;
                        END;

                        if v_tmail is null THEN
                           IF LENGTH(vcusuari) < 4 THEN
                              v_tmail := TO_CHAR(vcusuari, '0009');
                           ELSE
                              v_tmail := vcusuari;
                           END IF;

                           v_tmail := 'U' || vcusuari || pac_parametros.f_parempresa_t(pcempres, 'DOM_MAIL');
                        end if;
                     END IF;

                     IF v_tmail IS NOT NULL THEN
                        v_remi := pac_parametros.f_parempresa_t(pcempres, 'REM_MAIL');
                        v_ttexto := REPLACE(f_axis_literales(9902269, pcidioma), '#NAPUNTE#',
                                            pidapunte);

                        BEGIN
                           vpasexec := 6;

                           SELECT scorreo
                             INTO v_scorreo
                             FROM cfg_notificacion
                            WHERE cempres = pcempres
                              AND cmodo = 'GENERAL'
                              AND sproduc = 0
                              AND tevento = NVL(ptevento, pac_parametros.f_parempresa_t(pcempres, 'NUEVA_TAREA'));
                           vpasexec := 7;

                           vnumerr := pac_agenda.f_asunto(v_scorreo, pcidioma, v_ttexto, ptclagd,

                                                          -- BUG 20694 - FAL - 29/02/2012 - añadir sseguro (ptclagd)
                                                          pidapunte, pntramit, NULL);
                           vpasexec := 8;
                           vnumerr := pac_agenda.f_cuerpo(v_scorreo, pcidioma, v_ttextocuerpo,
                                                          pidapunte, ptclagd, pntramit, NULL);
                           -- BUG 20694 - FAL - 29/02/2012 - añadir sseguro (ptclagd)

                           vpasexec := 9;
                           conn := pac_send_mail.begin_mail(sender     => v_remi,
                                                            recipients => v_tmail,
                                                            cc         => NULL,
                                                            subject    => v_ttexto,
                                                            mime_type  => pac_send_mail.multipart_mime_type || '; charset=UTF-8');

                           vpasexec := 10;

                           pac_send_mail.attach_text(conn      => conn,
                                                     data      => v_ttextocuerpo,
                                                     mime_type => 'text/html');
                           vpasexec := 11;
                           pac_send_mail.end_mail(conn => conn);
                           vpasexec := 12;

                        EXCEPTION
                           WHEN OTHERS THEN
                              p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                                          'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
                        END;
                     END IF;
                  END IF;
               END IF;
            END IF;
      END;

      vpasexec := 7;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_agenda;

/*************************************************************************
        Devuelve la lista de registros del chat de un apunte
        pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2)
        param out pquery  : Query con los conceptos a mostrar
        return                : 0/1 OK/KO

     *************************************************************************/
   FUNCTION f_get_lstchat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2,
      pcempres IN NUMBER)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstchat';
      vparam         VARCHAR2(1000) := 'parámetros ';
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vwhere         VARCHAR2(2000);
   BEGIN
      IF pnmovagd IS NOT NULL THEN
         vwhere := vwhere || ' and nmovagd = ' || pnmovagd;
      END IF;

      IF pnmovchat IS NOT NULL THEN
         vwhere := vwhere || ' and nmovchat = ' || pnmovchat;
      END IF;

      IF pcusuari IS NOT NULL THEN
         vwhere := vwhere || ' and cusuari = ' || CHR(39) || pcusuari || CHR(39);
      END IF;

      IF pcgrupo IS NOT NULL THEN
         vwhere := vwhere || ' and cgrupo = ' || CHR(39) || pcgrupo || CHR(39);
      END IF;

      IF ptgrupo IS NOT NULL THEN
         vwhere := vwhere || ' and tgrupo = ' || CHR(39) || ptgrupo || CHR(39);
      END IF;

      pquery :=
         ' SELECT IDAGENDA, IDAPUNTE, NMOVAGD, NMOVCHAT, TTEXTO, CUSUARI, TGRUPO, CUSUALT,FALTA, pac_agenda.f_get_literal_grupo(cgrupo , '
         || pcempres || ', ' || pcidioma || ' ) CGRUPO '
         || ', (SELECT DISTINCT A.TRESPUE FROM AGD_ACCIONES A, AGD_AGENDA G WHERE A.CTIPRES = C.CTIPRES AND A.CIDIOMA = '
         || pcidioma || ' AND G.IDAGENDA = C.IDAGENDA AND  A.CCLAGD = G.CCLAGD) TRESPUE'
         || ' FROM AGD_CHAT C WHERE IDAGENDA =  ' || pidagenda || 'AND IDAPUNTE = '
         || pidapunte;
      pquery := pquery || vwhere || ' order by nmovchat desc';
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901934;
   END f_get_lstchat;

   FUNCTION f_set_chat(
      pidagenda IN NUMBER,
      pidapunte IN NUMBER,
      pnmovagd IN NUMBER,
      pnmovchat IN NUMBER,
      pttexto IN VARCHAR2,
      pcusuari IN VARCHAR2,
      pcgrupo IN VARCHAR2,
      ptgrupo IN VARCHAR2,
      pctipres IN NUMBER,
      pcempres IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pcidioma IN NUMBER DEFAULT NULL,
      ptevento IN VARCHAR2 DEFAULT 'GENERAL')
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_chat';
      vparam         VARCHAR2(500)
         := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda:' || pidagenda
            || ' pcusuari:' || pcusuari || ' pcgrupo:' || pcgrupo || ' ptgrupo:' || ptgrupo
            || ' pnmovagd:' || pnmovagd || ' pnmovchat:' || pnmovchat;
      vpasexec       NUMBER(5) := 1;
      vidapunte      NUMBER := pidapunte;
      vidagenda      NUMBER := pidagenda;
      vnumerr        NUMBER := 0;
      vnmovchat      NUMBER := pnmovchat;
      v_cestapu      NUMBER;
      v_orig         NUMBER := 0;
      v_dest         NUMBER := 0;
      v_cus_ori      agd_movagenda.cusuari_ori%TYPE;
      v_cgrup_ori    agd_movagenda.cgrupo_ori%TYPE;
      v_tgrup_ori    agd_movagenda.tgrupo_ori%TYPE;
      v_cus_dest     agd_movagenda.cusuari_dest%TYPE;
      v_cgrup_dest   agd_movagenda.cgrupo_dest%TYPE;
      v_tgrup_dest   agd_movagenda.tgrupo_dest%TYPE;
      v_cus_env      agd_movagenda.cusuari_ori%TYPE;
      v_cgrup_env    agd_movagenda.cgrupo_ori%TYPE;
      v_tgrup_env    agd_movagenda.tgrupo_ori%TYPE;
      v_tmail        VARCHAR2(4000);
      v_dummy        NUMBER := 0;
      v_remi         VARCHAR2(4000);
      v_ttexto       VARCHAR2(4000);
      v_scorreo      NUMBER;
      vtevento       VARCHAR2(200) := 'GENERAL';
      v_ttextocuerpo VARCHAR2(2000);
   BEGIN
      IF pidapunte IS NULL
         OR pidagenda IS NULL THEN
         RETURN 103135;
      END IF;

      IF vnmovchat IS NULL THEN
         BEGIN
            SELECT NVL(MAX(nmovchat) + 1, 1)
              INTO vnmovchat
              FROM agd_chat
             WHERE idapunte = pidapunte
               AND idagenda = pidagenda
               AND nmovagd = NVL(pnmovagd, 0);
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnmovchat := 1;
         END;
      END IF;

      BEGIN
         INSERT INTO agd_chat
                     (idagenda, idapunte, nmovagd, nmovchat, ttexto, cusuari,
                      cgrupo, tgrupo, cusualt, falta, ctipres)
              VALUES (pidagenda, pidapunte, NVL(pnmovagd, 0), vnmovchat, pttexto, pcusuari,
                      pcgrupo, ptgrupo, f_user, f_sysdate, pctipres);

          --Miramos si tenemos que enviar mail de respuesta y a quien
         --18845
         IF NVL(pac_parametros.f_parempresa_n(pcempres, 'ENV_MAIL_AGEN'), 0) = 1 THEN
            --Comprobamos quien responde, para ello miramos si el usuario esta en el origen o en el destino para responder al contrario
            --o en caso de ambos no responder..
            SELECT cusuari_ori, cgrupo_ori, tgrupo_ori, cusuari_dest, cgrupo_dest, tgrupo_dest
              INTO v_cus_ori, v_cgrup_ori, v_tgrup_ori, v_cus_dest, v_cgrup_dest, v_tgrup_dest
              FROM agd_movagenda agm
             WHERE agm.idagenda = pidagenda
               AND agm.idapunte = pidapunte
               AND agm.nmovagd = NVL(pnmovagd, 0);

            IF v_cgrup_ori IS NOT NULL THEN   --Miramos si pertenece al grupo de origen
               BEGIN
                  SELECT DISTINCT '1'
                             INTO v_dummy
                             FROM redcomercial rc, agentes a, usuarios u
                            WHERE rc.cempres = pcempres
                              AND rc.cagente = a.cagente
                              AND rc.ctipage = v_cgrup_ori
                              AND fmovfin IS NULL
                              AND rc.cagente IN(SELECT cagente
                                                  FROM redcomercial
                                                 WHERE ctipage = v_cgrup_ori
                                                   AND fmovfin IS NULL
                                                   AND cempres = pcempres)
                              AND rc.cagente = pcagente;

                  v_orig := v_dummy;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_orig := 0;
               END;
            --v_orig := 1;
            ELSE
               IF v_cus_ori = f_user THEN
                  v_orig := 1;
               --El usuario no es el orgien
               END IF;
            END IF;

            IF v_cgrup_dest IS NOT NULL THEN   --Miramos si pertenece al grupo de destino
               BEGIN
                  SELECT DISTINCT '1'
                             INTO v_dummy
                             FROM redcomercial rc, agentes a, usuarios u
                            WHERE rc.cempres = pcempres
                              AND rc.cagente = a.cagente
                              AND fmovfin IS NULL
                              AND rc.ctipage = v_cgrup_dest
                              AND rc.cagente IN(SELECT cagente
                                                  FROM redcomercial
                                                 WHERE ctipage = v_cgrup_dest
                                                   AND fmovfin IS NULL
                                                   AND cempres = pcempres)
                              AND rc.cagente = pcagente;

                  v_dest := v_dummy;
               EXCEPTION
                  WHEN OTHERS THEN
                     v_dest := 0;
               END;
            --v_dest := 1;
            ELSE
               IF v_cus_dest = f_user THEN
                  v_dest := 1;
               END IF;
            END IF;

            IF v_orig = 1
               AND v_dest = 0 THEN   --Responde el origen al destino, enviamos mail al destino
               v_cgrup_env := v_cgrup_dest;
               v_tgrup_env := v_tgrup_dest;
               v_cus_env := v_cus_dest;
            ELSIF v_dest = 1
                  AND v_orig = 0 THEN
               --Responde el destino al origen, enviamos mail al destino
               v_cgrup_env := v_cgrup_ori;
               v_tgrup_env := v_tgrup_ori;
               v_cus_env := v_cus_ori;
            ELSE
               v_cgrup_env := NULL;
               v_tgrup_env := NULL;
               v_cus_env := NULL;
            END IF;

            IF v_cgrup_env IS NOT NULL
               OR v_cus_env IS NOT NULL THEN
               IF v_cgrup_env IS NOT NULL THEN
                  BEGIN
                     SELECT tmail
                       INTO v_tmail
                       FROM agd_grupos ag
                      WHERE ag.cempres = pcempres
                        AND ag.cidioma = pcidioma
                        AND ag.cgrupo = v_cgrup_env
                        AND ag.csubgrup = v_tgrup_env;
                  EXCEPTION
                     WHEN OTHERS THEN
                        BEGIN
                           SELECT per.tvalcon
                             INTO v_tmail
                             FROM redcomercial r, per_contactos per, agentes aa
                            WHERE r.ctipage = v_cgrup_env
                              AND r.cagente = v_tgrup_env
                              AND fmovfin IS NULL
                              AND per.sperson = aa.sperson
                              AND r.cagente = aa.cagente
                              AND per.ctipcon = 3;

                           IF SUBSTR(v_tmail, 0, INSTR(v_tmail, '@') - 1) IS NOT NULL THEN
                              v_tmail := SUBSTR(v_tmail, 0, INSTR(v_tmail, '@') - 1);
                           END IF;

                           IF LENGTH(v_tmail) < 4 THEN
                              v_tmail := TO_CHAR(v_tmail, '0009');
                           ELSE
                              v_tmail := v_tmail;
                           END IF;

                           v_tmail := v_tmail
                                      || pac_parametros.f_parempresa_t(pcempres, 'DOM_MAIL');
                        EXCEPTION
                           WHEN OTHERS THEN
                              IF LENGTH(v_tgrup_env) < 4 THEN
                                 v_tmail := TO_CHAR(v_tgrup_env, '0009');
                              ELSE
                                 v_tmail := v_tgrup_env;
                              END IF;

                              v_tmail := v_tmail
                                         || pac_parametros.f_parempresa_t(pcempres, 'DOM_MAIL');
                        END;
                  END;
               ELSE
                  IF LENGTH(v_cus_env) < 4 THEN
                     v_cus_env := TO_CHAR(v_cus_env, '0009');
                  END IF;

                  v_tmail := 'U' || v_cus_env
                             || pac_parametros.f_parempresa_t(pcempres, 'DOM_MAIL');
               END IF;
            END IF;

            IF v_tmail IS NOT NULL THEN
               v_remi := pac_parametros.f_parempresa_t(pcempres, 'REM_MAIL');
               v_ttexto := REPLACE(f_axis_literales(9902269, pcidioma), '#1#', pidapunte);

               BEGIN
                  SELECT scorreo
                    INTO v_scorreo
                    FROM cfg_notificacion
                   WHERE cempres = pcempres
                     AND cmodo = 'GENERAL'
                     AND sproduc = 0
                     AND tevento = ptevento;

                  vnumerr := pac_agenda.f_asunto(v_scorreo, pcidioma, v_ttexto, NULL,
                                                 pidapunte, NULL, NULL);
                  vnumerr := pac_agenda.f_cuerpo(v_scorreo, pcidioma, v_ttextocuerpo,
                                                 pidapunte, NULL, NULL, NULL);
                  p_enviar_correo(v_remi, v_tmail, NULL, NULL, v_ttexto, v_ttexto);
               EXCEPTION
                  WHEN OTHERS THEN
                     p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                                 'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
               END;
            END IF;
         END IF;
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agd_chat
               SET ttexto = pttexto,
                   cusuari = pcusuari,
                   cgrupo = pcgrupo,
                   tgrupo = ptgrupo
             WHERE idagenda = pidagenda
               AND idapunte = pidapunte
               AND nmovagd = NVL(pnmovagd, 0)
               AND nmovchat = NVL(pnmovchat, 1);
      END;

      --Bug.: 18845 - 25/07/2011 - ICV
      SELECT cestapu
        INTO v_cestapu
        FROM agd_movapunte am
       WHERE am.idapunte = pidapunte
         AND am.nmovapu = (SELECT MAX(nmovapu)
                             FROM agd_movapunte am2
                            WHERE am2.idapunte = am.idapunte);

      vnumerr := pac_agenda.f_set_movapunte(pidapunte, NULL, v_cestapu, f_sysdate, NULL, NULL);

      IF vnumerr <> 0 THEN
         RETURN vnumerr;
      END IF;

      --fi Bug.:18845
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_chat;

   FUNCTION f_set_movagenda(
      pidapunte IN NUMBER,
      pidagenda IN NUMBER,
      pnmovagd IN NUMBER,
      pcestagd IN NUMBER,
      pcusuari_ori IN VARCHAR2,
      pcgrupo_ori IN VARCHAR2,
      ptgrupo_ori IN VARCHAR2,
      pcusuari_dest IN VARCHAR2,
      pcgrupo_dest IN VARCHAR2,
      ptgrupo_dest IN VARCHAR2,
      pcusualt IN VARCHAR2 DEFAULT NULL,
      pfalta IN DATE DEFAULT NULL)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_movagenda';
      vparam         VARCHAR2(500) := 'parámetros - pidapunte: ' || pidapunte || ' pidagenda: ' || pidagenda || ' pnmovagd:' || pnmovagd || ' pcestagd:' || pcestagd || ' pcusuari_ori: ' || pcusuari_ori
                                   || ' pcgrupo_ori: ' || pcgrupo_ori || ' ptgrupo_ori:' || ptgrupo_ori || ' pcusuari_dest:' || pcusuari_dest || ' pcgrupo_dest:' || pcgrupo_dest || ' ptgrupo_dest:' || ptgrupo_dest
                                   || ' pcusualt:' || pcusualt ||' pfalta:' || pfalta;
      vpasexec       NUMBER(5) := 1;
      vnmovagd       NUMBER := pnmovagd;
   BEGIN

      IF pidapunte IS NULL
         OR pidagenda IS NULL THEN
         RETURN 103135;
      END IF;

      IF pnmovagd IS NULL THEN
         BEGIN
            SELECT NVL(MAX(nmovagd) + 1, 1)
              INTO vnmovagd
              FROM agd_movagenda
             WHERE idapunte = pidapunte
               AND idagenda = pidagenda;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnmovagd := 0;
         END;
      END IF;

      BEGIN

         INSERT INTO agd_movagenda
                     (idagenda, idapunte, nmovagd, cestagd, cusuari_ori, cgrupo_ori,
                      tgrupo_ori, cusuari_dest, cgrupo_dest, tgrupo_dest,
                      cusualt, falta)
              VALUES (pidagenda, pidapunte, vnmovagd, pcestagd, pcusuari_ori, pcgrupo_ori,
                      ptgrupo_ori, pcusuari_dest, pcgrupo_dest, ptgrupo_dest,
                      NVL(pcusualt, f_user), NVL(pfalta, f_sysdate));
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agd_movagenda
               SET cestagd = pcestagd,
                   cusuari_ori = pcusuari_ori,
                   cgrupo_ori = pcgrupo_ori,
                   tgrupo_ori = ptgrupo_ori,
                   cusuari_dest = pcusuari_dest,
                   cgrupo_dest = pcgrupo_dest,
                   tgrupo_dest = ptgrupo_dest
             WHERE idagenda = pidagenda
               AND idapunte = pidapunte
               AND nmovagd = pnmovagd;
      END;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_movagenda;

     --XPL bug 17770 25/03/2011 inici
   /*************************************************************************
        Devuelve la visibilidad de un apu/obs según la visión parametrizada para ese apunte.
        Dependerá del rol propietario del tipo de agenda, del usuario o del rol del usuario
        param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
        param in pidobs       : número obs/apu
        return                : 0/1 visión del apunte (1 visible para el usuario conectado, 0 No)
     *************************************************************************/
   FUNCTION f_obs_isvisible(pcempres IN NUMBER, pctipagd IN NUMBER, pidobs IN NUMBER)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_obs_isvisible';
      vparam         VARCHAR2(1000)
                          := 'parámetros - pctipAGD = ' || pctipagd || ', pidobs = ' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      cvisible_usu   NUMBER;
      cvisible_rol   NUMBER;
      vcvision       NUMBER;
      v_cont         NUMBER;
   BEGIN
      --Comprobamos si hay visibilidad y cual para el usuario conectado
      BEGIN
         SELECT cvisible
           INTO cvisible_usu
           FROM agd_obs_vision
          WHERE idobs = pidobs
            AND ctipvision = 2   --Tipo visión Usuario
            AND ttipvision = f_user;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            cvisible_usu := NULL;
      END;

      IF cvisible_usu IS NOT NULL THEN
         --En caso de que haya visión definida para este usuario será la visión que dominará
         vcvision := cvisible_usu;
      ELSE
         --Si no hay visibilidad definida para el usuario, miraremos si el usuario pertenece
         --al rol propietario, si pertenece devoleremos 1
         SELECT COUNT(1)
           INTO v_cont
           FROM agd_obs_config
          WHERE cempres = pcempres
            AND ctipagd = pctipagd
            AND crolprop IN(SELECT crolobs
                              FROM agd_usu_rol
                             WHERE cusuari = f_user);

         IF v_cont > 0 THEN
            vcvision := 1;
         ELSE
            --En caso de que no pertenezca miraremos si el usuario tiene algun rol
            --definido en la tabla de visión como visible. Si hay devolveremos 1
            -- en caso contrario 0.
            SELECT COUNT(1)
              INTO cvisible_rol
              FROM agd_obs_vision
             WHERE cempres = pcempres
               AND idobs = pidobs
               AND ctipvision = 1
               AND cvisible = 1
               AND ttipvision IN(SELECT crolobs
                                   FROM agd_usu_rol
                                  WHERE cusuari = f_user);

            IF cvisible_rol > 0 THEN
               vcvision := 1;
            ELSE
               vcvision := 0;
            END IF;
         END IF;
      END IF;

      RETURN vcvision;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 0;
   END f_obs_isvisible;

     --XPL bug 17770 25/03/2011 inici
   /*************************************************************************
        Devuelve la visibilidad de un apu/obs según la visión parametrizada para ese apunte.
        Dependerá del rol propietario del tipo de agenda, del usuario o del rol del usuario
        param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
        param in pidobs       : número obs/apu
        return                : 0/1 visión del apunte (1 visible para el usuario conectado, 0 No)
     *************************************************************************/
   FUNCTION f_get_entidad(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      ppfiltro IN VARCHAR2,
      pvalorfiltro IN VARCHAR2)
      RETURN VARCHAR2 IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_entidad';
      vparam         VARCHAR2(1000) := 'parámetros - pidobs = ' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      v_cont         NUMBER;
      vctipagd       NUMBER(5);
      vquery         VARCHAR2(500);
      v_param        VARCHAR2(2000);
      v_param2       VARCHAR2(1000);
      vtfuncio       VARCHAR2(500);
      vtparam        VARCHAR2(500);
      vttabla        VARCHAR2(500);
      vout           VARCHAR2(500);
      vtfiltro       VARCHAR2(400);
      vtfiltro_cab   VARCHAR2(400);
      vtparam2       VARCHAR2(500);
   BEGIN
      IF pidobs IS NOT NULL THEN
         SELECT aoc.tparam_vis, tfunc_paramout, aoc.ttabla, aoc.tfiltro
           INTO vtparam, vtfuncio, vttabla, vtfiltro
           FROM agd_obs_config aoc, agd_observaciones ao
          WHERE aoc.cempres = pcempres
            AND aoc.cempres = ao.cempres
            AND aoc.ctipagd = ao.ctipagd
            AND ao.idobs = pidobs;
      ELSE
         SELECT aoc.tparam_vis, tfunc_paramout, aoc.ttabla
           INTO vtparam, vtfuncio, vttabla
           FROM agd_obs_config aoc
          WHERE aoc.cempres = pcempres
            AND aoc.ctipagd = pctipagd;
      END IF;

      IF ppfiltro IS NULL
         AND pvalorfiltro IS NULL THEN
         vtfiltro := REPLACE(vtfiltro, ',', '||'',''||');
         vquery := 'begin select ' || vtfiltro
                   || ' INTO :vout  from agd_observaciones where idobs = ' || pidobs
                   || '; end;';

         EXECUTE IMMEDIATE vquery
                     USING OUT vout;

         vout := REPLACE(vout, ',', '||'',''||');
      ELSE
         vtfiltro := ppfiltro;
         vout := pvalorfiltro;
      END IF;

      IF vtparam IS NOT NULL THEN
         vtparam := REPLACE(vtparam, ',', '||'' - ''||');
         vquery := 'begin select ' || vtparam || ' into :v_param from ' || vttabla
                   || ' where (' || vtfiltro || ') = (' || vout || '); end;';

         EXECUTE IMMEDIATE vquery
                     USING OUT v_param;
      END IF;

      IF vtfuncio IS NOT NULL THEN
         -- a tota funció li passarem el parametre d'entrada, concatenat amb ; si hi ha més d'un i el pcidioma
         vquery := 'begin :v_param := ' || vtfuncio || '('''
                   || REPLACE(vout, '||'',''||', ';') || ''',' || pcidioma || '); end;';

         EXECUTE IMMEDIATE vquery
                     USING OUT v_param2;

         IF v_param IS NOT NULL THEN
            v_param := v_param || ' - ' || v_param2;
         END IF;
      END IF;

      RETURN v_param;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN NULL;
   END f_get_entidad;

/*************************************************************************
        Devuelve la lista de los conceptos según el tipo de agenda
        del usuario, de su rol o del rol propietario de la agenda
        param in pctipagd     : Tipo de Agenda (póliza, recibo, siniestro...)
        param out pquery  : Query con los conceptos a mostrar
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lstconceptos(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pctipagd IN NUMBER,
      pcmodo       IN       VARCHAR2,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstconceptos';
      vparam         VARCHAR2(1000)
         := 'parámetros - pctipagd :' || pctipagd || ',pcempres :' || pcempres
            || ',pcidioma :' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
      vsqueryand    VARCHAR2(500) := '';
   BEGIN
      BEGIN
         SELECT cconobs
           INTO vcconobs
           FROM agd_obs_config
          WHERE ctipagd = pctipagd
            AND cempres = pcempres;
      EXCEPTION
         WHEN OTHERS THEN
            vcconobs := 800031;
      END;
    if pcmodo is not null and pcmodo='MODIF_SINIESTROS' then
    vsqueryand:='  and catribu  in (1,2,13,3,45,25,26,5,12,42,14,11,40,7,4,9,10,6,46,47,48,49) ';
    end if;
      pquery := 'select catribu,tatribu from detvalores  where cidioma =' || pcidioma
                || ' and cvalor=' || vcconobs|| vsqueryand ||' order by tatribu';
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901934;
   END f_get_lstconceptos;

   /*************************************************************************
        Devuelve la lista de los tipos de agenda
        param out pquery       : query que devolveremos
        return                : 0/1 OK/KO
     *************************************************************************/
   FUNCTION f_get_lsttiposagenda(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstconceptos';
      vparam         VARCHAR2(1000)
                         := 'parámetros - pcempres :' || pcempres || ',pcidioma :' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
   BEGIN
      pquery :=
         'select ad.ctipagd, ttipagd from agd_destiposagenda ad, agd_coditiposagenda ac where ad.cempres ='
         || pcempres || '
      and ad.cidioma = ' || pcidioma
         || ' and  ad.CEMPRES = ac.cempres and ad.CTIPAGD = ac.ctipagd';
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_lsttiposagenda;

/*************************************************************************
      Guardarem la obs/apu i crearem un apunt.
      Passarem en un objecte els valors SSEGURO, NRECIBO...
      En el cas que s'afegis una nova entitat de l'axis a l'agenda només hauriem
      de modificar la capa de negoci i afegir el nou camp ja que vindria en aquest objecte desde java.
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      psseguro IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL,
      pidobs_out OUT VARCHAR2
      return                : 0/1 OK/KO
   -- Bug 22342 - APD - 11/06/2012 - se añaden los parametros psseguro, pnrecibo,
   --  pcagente, pnsinies, pntramit
   *************************************************************************/
   FUNCTION f_set_obs(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pcconobs IN NUMBER,
      pctipobs IN NUMBER,
      pttitobs IN VARCHAR2,
      ptobs IN VARCHAR2,
      pfobs IN DATE,
      pfrecordatorio IN DATE,
      pctipagd IN NUMBER,
      pcambito IN NUMBER,
      pcpriori IN NUMBER,
      pcprivobs IN NUMBER,
      ppublico IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      pidobs_out OUT VARCHAR2,
      pdescripcion IN VARCHAR2 DEFAULT NULL,
      ptfilename IN VARCHAR2 DEFAULT NULL,
      piddocgedox IN NUMBER DEFAULT NULL,
      psseguro IN NUMBER DEFAULT NULL,
      pnrecibo IN NUMBER DEFAULT NULL,
      pcagente IN NUMBER DEFAULT NULL,
      pnsinies IN NUMBER DEFAULT NULL,
      pntramit IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_set_obs';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs: ' || pidobs || ' cconobs:' || pcconobs || ' pctipobs:'
             --  BUG: 26173  15/03/2013  AMJ  0026173: LCOL_T001- Modificar mensajes de errores
            --|| pctipobs || ' pttitobs:' || pttitobs || ' ptobs:' || ptobs || ' pfobs:'
            || pctipobs || ' pttitobs:' || pttitobs || ' pfobs:' || pfobs
            || ' pfrecordatorio:' || pfrecordatorio || ' pctipagd:' || pctipagd
            || ' pcambito:' || pcambito || ' pcpriori:' || pcpriori || ' pcprivobs:'
            || pcprivobs || ' pcestobs:' || pcestobs || ' pfestobs:' || pfestobs
            || ' ppublico:' || ppublico || ' psseguro:' || psseguro || ' pnrecibo:'
            || pnrecibo || ' pcagente:' || pcagente || ' pnsinies:' || pnsinies
            || ' pntramit:' || pntramit;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
      vidobs         NUMBER := pidobs;
   BEGIN
      IF vidobs IS NULL THEN
         BEGIN
            SELECT NVL(MAX(idobs) + 1, 1)
              INTO vidobs
              FROM agd_observaciones;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vidobs := 1;
         END;
      END IF;

      pidobs_out := vidobs;

      BEGIN
         INSERT INTO agd_observaciones
                     (cempres, idobs, cconobs, ctipobs, ttitobs, tobs, fobs,
                      frecordatorio, ctipagd, cambito, cpriori, cprivobs, publico,
                      sseguro, nrecibo, cagente, nsinies, ntramit, descripcion, tfilename, iddocgedox)
              VALUES (pcempres, vidobs, pcconobs, NVL(pctipobs, 1), pttitobs, ptobs, pfobs,
                      pfrecordatorio, pctipagd, pcambito, pcpriori, pcprivobs, ppublico,
                      psseguro, pnrecibo, pcagente, pnsinies, pntramit, pdescripcion, ptfilename, piddocgedox);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
         --INI SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
            IF pctipagd = 2 THEN--creara historico en agd_movobs para las observaciones de los recibos   
                vnumerr := f_set_movobs(pcempres, pidobs, NULL, pcestobs, pfestobs,ptobs);
                IF vnumerr != 0 THEN
                    RETURN vnumerr;
                END IF;                
                RETURN 0;
            ELSE   
                UPDATE agd_observaciones
                   SET cconobs = pcconobs,
                       ctipobs = NVL(pctipobs, 1),
                       ttitobs = pttitobs,
                       tobs = ptobs,
                       fobs = pfobs,
                       frecordatorio = pfrecordatorio,
                       ctipagd = pctipagd,
                       cambito = pcambito,
                       cpriori = pcpriori,
                       cprivobs = pcprivobs,
                       publico = ppublico,
                       descripcion = pdescripcion,
                       tfilename = ptfilename,
                       iddocgedox = piddocgedox,
                       sseguro = NVL(psseguro, sseguro),
                       nrecibo = NVL(pnrecibo, nrecibo),
                       cagente = NVL(pcagente, cagente),
                       nsinies = NVL(pnsinies, nsinies),
                       ntramit = NVL(pntramit, ntramit)
                 WHERE cempres = pcempres
                   AND idobs = pidobs;
            END IF;
           --FIN SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
      END;
           --INI SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes 
        IF pctipagd = 2 THEN--creara historico en agd_movobs para las observaciones de los recibos 
                vnumerr := f_set_movobs(pcempres, vidobs, NULL, pcestobs, pfestobs,ptobs);
                IF vnumerr != 0 THEN
                    RETURN vnumerr;
                END IF;
                RETURN 0;
        ELSE
            vnumerr := f_set_movobs(pcempres, vidobs, NULL, pcestobs, pfestobs);
            IF vnumerr != 0 THEN
                 RETURN vnumerr;
             END IF;
        END IF;
          --FIN SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_obs;

/*************************************************************************
      Creamos un nuevo movimiento para el obs/apu
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pnmovobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_set_movobs(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pnmovobs IN NUMBER,
      pcestobs IN NUMBER,
      pfestobs IN DATE,
      ptobs    IN VARCHAR2 DEFAULT NULL) --SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'pac_agenda.f_set_movobs';
      vparam         VARCHAR2(500)
         := 'parámetros - pidobs: ' || pidobs || ' pnmovobs:' || pnmovobs || ' pcestobs:'
            || pcestobs || ' pfestobs:' || pfestobs;
      vpasexec       NUMBER(5) := 1;
      vnmovobs       NUMBER := pnmovobs;
      vcestobs       NUMBER;
      vfestobs       DATE;
      vtobs          VARCHAR2(500);----SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
   BEGIN  
      IF pidobs IS NULL THEN
         RETURN 103135;
      END IF;

      IF pnmovobs IS NULL THEN
         BEGIN
            SELECT NVL(MAX(nmovobs) + 1, 1)
              INTO vnmovobs
              FROM agd_movobs
             WHERE idobs = pidobs
               AND cempres = pcempres;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               vnmovobs := 1;
         END;
      END IF;

      BEGIN
         SELECT cestobs, festobs, tobs--SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
           INTO vcestobs, vfestobs, vtobs--SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar mejor los apuntes
           FROM agd_movobs
          WHERE idobs = pidobs
            AND nmovobs = vnmovobs - 1
            AND cempres = pcempres;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            vcestobs := -1;
            vfestobs := NULL;
      END;

      IF vcestobs <> pcestobs
         OR(vfestobs IS NULL
            OR pfestobs <> vfestobs)
                OR(vtobs IS NULL
                    OR vtobs != ptobs) THEN--SGM       
         BEGIN
            INSERT INTO agd_movobs
                        (cempres, idobs, nmovobs, cestobs, festobs,tobs)
                 VALUES (pcempres, pidobs, vnmovobs, pcestobs, NVL(pfestobs, f_sysdate),ptobs);
				 
     --INI SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar los apuntes
     --finaliza todos los movimientos de dicha anotacion                 
			 BEGIN
				IF pcestobs = 1 THEN 
				  UPDATE agd_movobs
					 SET cestobs = pcestobs
				   WHERE idobs = pidobs;
				END IF;           
			 END;                 
     --FIN SGM IAXIS 3482 SGM  17/04/2019 se agrega columna a la tabla agd_movobs para trazar los apuntes 				 
                 
         EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
               UPDATE agd_movobs
                  SET cestobs = pcestobs,
                      festobs = pfestobs
                WHERE idobs = pidobs
                  AND nmovobs = vnmovobs
                  AND cempres = pcempres;
         END;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_movobs;

   /*************************************************************************
          Devuelve la lista de los roles de la agenda, si nos pasan el tipo de agenda no devolveremos el rol
          propietario ya que no se podrá gestionar este rol, siempre será visible
           pcempres IN NUMBER,
           pcidioma IN NUMBER,
          pctipagd IN NUMBER,
          param out pquery       : query que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstroles(
      pcempres IN NUMBER,
      pcidioma IN NUMBER,
      pctipagd IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstconceptos';
      vparam         VARCHAR2(1000)
                         := 'parámetros - pcempres :' || pcempres || ',pcidioma :' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
   BEGIN
      pquery :=
         'select ad.CROLOBS, ad.TROLOBS from
   agd_codirolobs ac, agd_desrolobs ad
   where ac.CEMPRES = ad.CEMPRES and ac.CROLOBS = ad.CROLOBS
   and ac.CEMPRES = '
         || pcempres || 'and ad.CIDIOMA = ' || pcidioma;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_lstroles;

   /*************************************************************************
           Devuelve la lista de la visión del obs/apu dependiendo el tipo que le pasamos
           pcempres IN NUMBER,
           pidobs IN NUMBER,
           pctipvision IN NUMBER,
           pcidioma IN NUMBER,
           param out pquery       : query que devolveremos
           return                : 0/1 OK/KO
        *************************************************************************/
   FUNCTION f_get_lstvision(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipagd IN NUMBER,
      pctipvision IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstvision';
      vparam         VARCHAR2(1000)
         := 'parámetros - pidobs :' || pidobs || ',pcempres :' || pcempres || ',pcidioma :'
            || pcidioma || ',pctipvision ' || pctipvision;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
   BEGIN
      IF pctipvision = 1 THEN   --rols
         IF pidobs IS NOT NULL THEN
            pquery :=
               '  select nvl(CTIPVISION,1),f_axis_literales(9901939,' || pcidioma
               || ') destipvision ,nvl(TTIPVISION,ac.crolobs) , ades.trolobs desttipvision ,CVISIBLE cvisible
   from agd_obs_vision aob, agd_codirolobs ac, agd_desrolobs ades
   where CTIPVISION(+) = '
               || pctipvision;

            IF pidobs IS NOT NULL THEN
               pquery := pquery || ' AND IDOBS(+) = ' || pidobs;
            END IF;

            IF pctipagd IS NOT NULL THEN
               pquery :=
                  pquery
                  || ' and ac.crolobs not in (select crolprop from agd_obs_config where cempres = '
                  || pcempres || ' and ctipagd=' || pctipagd || ')';
            END IF;

            pquery :=
               pquery || ' and ac.cempres = ' || pcempres
               || '
   and aob.cempres(+) = ades.cempres
   and ades.cidioma = ' || pcidioma
               || '
   and ades.crolobs = aob.ttipvision(+)
   and ac.CROLOBS = ades.CROLOBS
   and ac.cempres = ades.cempres';
         ELSE
            pquery :=
               '  select 1,f_axis_literales(9901939,' || pcidioma
               || ') destipvision ,ac.crolobs , ades.trolobs desttipvision ,0 cvisible
   from agd_codirolobs ac, agd_desrolobs ades
   where   ac.cempres = '
               || pcempres || '
   and ades.cidioma = ' || pcidioma
               || '
   and ac.CROLOBS = ades.CROLOBS
   and ac.cempres = ades.cempres ';

            --and exists(select 1 from agd_usu_rol aur where ac.crolobs = aur.crolobs) ';
            IF pctipagd IS NOT NULL THEN
               pquery :=
                  pquery
                  || ' and ac.crolobs not in (select crolprop from agd_obs_config where cempres = '
                  || pcempres || ' and ctipagd=' || pctipagd || ')';
            END IF;
         END IF;
      ELSIF pctipvision = 2 THEN   --usuaris
         pquery :=
            '  select nvl(CTIPVISION,2),f_axis_literales(100894,' || pcidioma
            || ') destipvision ,nvl(TTIPVISION,u.cusuari) , u.tusunom desttipvision ,nvl(CVISIBLE,0) cvisible
   from agd_obs_vision aob, usuarios u
   where CTIPVISION = '
            || pctipvision || '
   AND IDOBS = ' || pidobs || '
   and u.cempres = ' || pcempres
            || '
   and aob.cempres = u.cempres
   and u.cusuari = aob.ttipvision(+)';
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 9901934;
   END f_get_lstvision;

/*************************************************************************
      Guardarem la visió d'un apunt
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER
      return                : 0/1 OK/KO
   *************************************************************************/
   FUNCTION f_set_vision(
      pcempres IN NUMBER,
      pidobs IN NUMBER,
      pctipvision IN NUMBER,
      pttipvision IN VARCHAR2,
      pcvisible IN NUMBER)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_set_vision';
      vparam         VARCHAR2(1000)
         := 'parámetros - pCEMPRES: ' || pcempres || ' pIDOBS:' || pidobs || ' pCTIPVISION:'
            || pctipvision || ' pTTIPVISION:' || pttipvision || ' pCVISIBLE:' || pcvisible;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
      vidobs         NUMBER := pidobs;
   BEGIN
      /*IF pcvisible = 0
         AND pctipvision <> 2 THEN
         DELETE      agd_obs_vision
               WHERE cempres = pcempres
                 AND idobs = pidobs
                 AND ctipvision = pctipvision
                 AND ttipvision = pttipvision;
      ELSE*/
      BEGIN
         INSERT INTO agd_obs_vision
                     (cempres, idobs, ctipvision, ttipvision, cvisible)
              VALUES (pcempres, pidobs, pctipvision, pttipvision, pcvisible);
      EXCEPTION
         WHEN DUP_VAL_ON_INDEX THEN
            UPDATE agd_obs_vision
               SET cvisible = pcvisible
             WHERE cempres = pcempres
               AND idobs = pidobs
               AND ctipvision = pctipvision
               AND ttipvision = pttipvision;
      END;

      --  END IF;
      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_set_vision;

   /*************************************************************************
            Borramos un apunte/observacion
            pidobs IN NUMBER,
            return                : 0/1 OK/KO
         *************************************************************************/
   FUNCTION f_del_observacion(pcempres IN NUMBER, pidobs IN NUMBER)
      RETURN NUMBER IS
      cur            sys_refcursor;
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.del_observacion';
      vparam         VARCHAR2(1000)
                              := 'parámetros - pCEMPRES: ' || pcempres || ' pIDOBS:' || pidobs;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vtext          VARCHAR2(200);
      vidobs         NUMBER := pidobs;
   BEGIN
      DELETE      agd_obs_vision
            WHERE idobs = pidobs
              AND cempres = pcempres;

      DELETE      agd_movobs
            WHERE idobs = pidobs
              AND cempres = pcempres;

      DELETE      agd_observaciones
            WHERE idobs = pidobs
              AND cempres = pcempres;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 806310;
   END f_del_observacion;

   /*************************************************************************
          Devuelve la lista grupos
           pcempres IN NUMBER,
           pcidioma IN NUMBER,
           param out pquery       : query que devolveremos
          return                : 0/1 OK/KO
       *************************************************************************/
   FUNCTION f_get_lstgrupos(pcempres IN NUMBER, pcidioma IN NUMBER, pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_lstgrupos';
      vparam         VARCHAR2(1000)
                         := 'parámetros - pcempres :' || pcempres || ',pcidioma :' || pcidioma;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
   BEGIN
      pquery :=
         ' select to_char(catribu) CATRIBU, tatribu from detvalores where cvalor = 800032
and cidioma = '
         || pcidioma || ' union ' || ' select ag.cgrupo CATRIBU,f_axis_literales(9001801,'
         || pcidioma
         || ') ||'' - ''||  tdesc TATRIBU from AGD_GRUPOS AG where  '
         || ' AG.CEMPRES = ' || pcempres || ' and ag.cidioma = ' || pcidioma;
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_lstgrupos;

      /*Funció que retorna el valor a mostrar per pantalla.
   Si es un apunt de pòlissa, retornarà npol + ncertif, si és de rebut nrecibo i si és sinistre el nsinies.
   XPL#14102011#
   */
   FUNCTION f_get_valorclagd(pcclagd IN VARCHAR2, ptclagd IN VARCHAR2, pquery OUT VARCHAR2)
      RETURN NUMBER IS
      vsquery        VARCHAR2(5000);
      vobjectname    VARCHAR2(500) := 'PAC_AGENDA.f_get_valorclagd';
      vparam         VARCHAR2(1000)
                             := 'parámetros - pcclagd :' || pcclagd || ',ptclagd :' || ptclagd;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      vcconobs       NUMBER;
   BEGIN
      IF pcclagd IS NOT NULL
         AND pcclagd IN (1, 3)
      THEN
         pquery := ' select npoliza,ncertif
         from seguros where sseguro =  ' || ptclagd;
      END IF;

      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, vobjectname, vpasexec, vparam,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
         RETURN 140999;
   END f_get_valorclagd;

   /*Funció que crear tasca de la solicitud de projecte
    XPL#24102011#
    */
   FUNCTION f_tarea_sol_proyecto(psseguro IN NUMBER, pcempres IN NUMBER, pcidioma IN NUMBER)
      RETURN NUMBER IS
      vobjectname    VARCHAR2(500) := 'PAC_IAX_AGENDA.f_tarea_sol_proyecto';
      vparam         VARCHAR2(1000) := 'parámetros - psseguro: ' || psseguro;
      vpasexec       NUMBER(5) := 1;
      vnumerr        NUMBER(8) := 0;
      wnpoliza       VARCHAR2(50);
      v_ctipage      NUMBER;
      v_cagente      NUMBER;
      pcclagd        NUMBER;
      ptclagd        VARCHAR2(50);
      vidapunte      NUMBER;
      wcsituac       NUMBER;
      vtevento       VARCHAR2(200);
      vslit          NUMBER;
      vpolini        VARCHAR2(20);
   BEGIN
      SELECT npoliza, csituac
        INTO wnpoliza, wcsituac
        FROM seguros
       WHERE sseguro = psseguro;

      SELECT s.cagente, r.ctipage
        INTO v_cagente, v_ctipage
        FROM seguros s, redcomercial r
       WHERE s.sseguro = psseguro
         AND r.cagente = s.cagente
         AND r.cempres = pcempres
         -- BUG 20694 - FAL - 29/02/2012 -- Añadir filtro por empresa
         AND r.fmovini = (SELECT MAX(rr.fmovini)
                            FROM redcomercial rr
                           WHERE rr.cempres = pcempres
                             AND rr.cagente = s.cagente);

      pcclagd := 1;   -- Código Clave Agenda 0:siniestro / 1:poliza / 2:recibos
      ptclagd := wnpoliza;   -- Valor Clave Agenda

      IF wcsituac = 12 THEN
         vtevento := 'SOL_PROYECTO';
         vslit := 9902010;
      ELSIF wcsituac = 4 THEN
         vtevento := 'SOL_EMISION';
         vslit := 9903017;

         BEGIN
            INSERT INTO sup_solicitud
                        (sseguro, nmovimi, cmotmov, nriesgo, cgarant, tvalora,
                         tvalord, cpregun, cestsup,
                         festsup, norden)
                 VALUES (psseguro, 1, 100, 1, 0, '',
                         f_axis_literales(vslit, pcidioma) || ' ' || wnpoliza, 0, 0,
                         f_sysdate, 1);
         EXCEPTION
            WHEN OTHERS THEN
               p_tab_error(f_sysdate, f_user, 'pac_agenda. f_tarea_sol_proyecto', 1,
                           'Error insertando en sup_solicitud', SQLERRM);
         END;

         BEGIN
            SELECT polissa_ini
              INTO vpolini
              FROM cnvpolizas
             WHERE sseguro = psseguro;
         EXCEPTION
            WHEN TOO_MANY_ROWS THEN
               vpolini := '-1';
         END;

         IF vpolini != -1 THEN
            UPDATE seguros
               SET csituac = 16
             WHERE npoliza = vpolini;
         END IF;
      ELSE
         vtevento := 'ALTA_POLIZA';
         vslit := 9902010;
      END IF;

      vnumerr := pac_agenda.f_set_apunte(NULL, NULL, pcclagd, psseguro, 0, 0, 0,
                                         pac_parametros.f_parempresa_t(pcempres,
                                                                       'ENV_TAREAS_DEF'),
                                         f_axis_literales(vslit, pcidioma),
                                         f_axis_literales(vslit, pcidioma) || ' ' || wnpoliza,
                                         0, 0, NULL, NULL, f_user, NULL, f_sysdate, f_sysdate,
                                         NULL, vidapunte);
      vnumerr := pac_agenda.f_set_agenda(vidapunte, NULL, NULL, 0,   --Lo enviamos al nodo superior de la red comercial
                                         pac_parametros.f_parempresa_t(pcempres,
                                                                       'ENV_TAREAS_DEF'),

                                         --enviamos la tarea al grupo definido como defecto
                                         pcclagd, psseguro, NULL, f_user, v_ctipage, v_cagente,
                                         pcempres, pcidioma, vtevento);
      RETURN vnumerr;
   EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate, f_user, 'pac_agenda. f_tarea_sol_proyecto', 1,
                     'Error no controlado', SQLERRM);
         RETURN 1;
   END f_tarea_sol_proyecto;
END pac_agenda;

/

  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_AGENDA" TO "CONF_DWH";
