--------------------------------------------------------
--  DDL for Package Body PAC_MD_LISTVALORES_AUT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_LISTVALORES_AUT" AS
   /******************************************************************************
    NOMBRE: PAC_MD_LISTVALORES_AUT
    PROP脫SITO: Funciones para recuperar valores

    REVISIONES:
    Ver        Fecha      Autor           Descripci贸n
    --------- ---------- --------------- ------------------------------------
    1.0                                   1. Creacion del Package
    1.1       26/02/2009  DCM             BUG 9198 - 3 Parte
    1.2       19/06/2009  JJG             BUG 10452
    1.3       16/10/2010  FAL             BUG 16458
    2.0       25/07/2011  DRA             2.0 0017255: CRT003 - Definir propuestas de suplementos en productos
    3.0       22/10/2012  JMF             0024167: LCOL_S001-SIN - Rendimiento tablas autos (F3)
    4.0       27/10/2012  JMF             0024581: LCOL_S001-SIN - Anadir el campo cempres al modelo de datos autos
    5.0       01/03/2013  JDS             0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428 NOTA :138478
    6.0       19/03/2013  JDS             0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428
    7.0       28/03/2013  JDS             0025840: LCOL_T031-LCOL - Fase 3 - (Id 111, 112, 115) - Parametrizaci髇 suplementos
    8.0       26/03/2013  ECP             0025202: LCOL_T031 - Adaptar pantalla riesgo - autos. Id 428. Nota 135707
    9.0       25/04/2013  ECP             0026419: LCOL - TEC - Revisi髇 Q-Trackers Fase 3A. Nota 143274
   10.0       31/05/2013  ASN             0027045: LCOL_S010-SIN - Eliminar filtrado por producto en tramitaci髇 veh韈ulo contrario (Id=7846)
   11.0       31/07/2013  JSV             0025894: LCOL_T031-LCOL - Parametrizaci?n AUTOS AX - MY CAR (6032)
   11.1       19/08/2013  JSV             0025894: LCOL_T031-LCOL - Parametrizaci?n AUTOS AX - MY CAR (6032) - Se reajusta el filtro de marcas y modelos
   11.2       24/02/2014  JDS             0030256: LCOL999-Modificar modelo autos a?adiendo : CPESO, CTRANSMISION, NPUERTAS
   11.3       25/03/2014  JDS             0030700: LCOL_T031-Revisi髇 Q-Trackers Fase 3A Puesta en producci髇
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   v_cidioma      VARCHAR2(10) := pac_md_common.f_get_cxtidioma;
   v_empres       NUMBER(2) := pac_md_common.f_get_cxtempresa;

   -- BUG 9198 - 26/02/2009 - DCM 驴 Se crean funciones para AUTOS.
   /*************************************************************************
     Recupera paratro para filtrar marca, model y version
     param out : parametre
     return : number

     Bug 0025894 - JSV (30/07/2013)
     *************************************************************************/
   FUNCTION f_return_parametre_autos(psproduc NUMBER)
      RETURN NUMBER IS
      vcvalpar       NUMBER;
   BEGIN
      vcvalpar := 0;

      BEGIN
         SELECT cvalpar
           INTO vcvalpar
           FROM parproductos
          WHERE cparpro = 'TIPO_FILTRO_AUTOS'
            AND sproduc = psproduc;

         RETURN vcvalpar;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            RETURN 0;
      END;
   END;

   /*************************************************************************
   Recupera los accesorios que se pueden dar de alta como accesorios extras,
   es decir no entran de serie, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.F_Get_lstaccesoriosnoserie';
      v_v_terror     VARCHAR2(200) := 'Error recuperar accesorios';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT cversion,caccesorio,copcpack,taccesorio,cmoneda,ivalpubl,iivalfabrica,
                 finicio,ffin,cactivo,cvehb7
            FROM aut_accesorios
           WHERE cversion = '
         || CHR(39) || p_cversion || CHR(39);   -- BUG 10452 - 19/06/2009 - JJG  Cambio formato de campo versi贸n para consulta.
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesoriosnoserie;

   FUNCTION f_get_lstdispositivosnoserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.F_Get_lstdispositivosnoserie';
      v_v_terror     VARCHAR2(200) := 'Error recuperar accesorios';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'select
a.cversion, a.cdispositivo, a.tdispositivo,
   a.cmoneda, a.ivalpubl, a.iivalfabrica,
   a.finicio, a.ffin, a.cactivo,
   a.cvehb7, a.cpropdisp
            FROM aut_dispositivos a
           WHERE a.cversion = '
         || CHR(39) || p_cversion || CHR(39);   -- BUG 10452 - 19/06/2009 - JJG  Cambio formato de campo versi贸n para consulta.
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdispositivosnoserie;

   /*************************************************************************
   Recupera los accesorios de serie segun la version,
   devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstaccesoriosserie(p_cversion IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.F_Get_lstaccesoriosserie';
      v_terror       VARCHAR2(200) := 'Error recuperar accesorios de serie';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT s.cserie, s.ttapiceria, s.tequipaudio, s.tcasete, s.tcd, s.taireacond, s.tclimatiza,
                 s.tabs, s.tbombillaf, s.tllanta, s.tcambio, s.tembraut, s.ttracci髇, s.tnavegador,
                 s.tcambseq
            FROM aut_series s
           WHERE s.cversion = '
         || CHR(39) || p_cversion || CHR(39);   -- BUG 10452 - 19/06/2009 - JJG  Cambio formato de campo versi贸n para consulta.
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesoriosserie;

   /*************************************************************************
   Recupera los datos de una version, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_version(
      p_cversion IN VARCHAR2,
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      phomologar IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_version';
      v_terror       VARCHAR2(200) := 'Error recuperar los datos de version';
      v_tsquery      VARCHAR2(4000);
      vcont          NUMBER;
      vcversion      VARCHAR2(200);
      vcvalpar       NUMBER;
   BEGIN
      IF p_cversion IS NOT NULL THEN
         vcversion := p_cversion;

         IF (phomologar > 0)   --si es phomologar=0 no se debe comprobar si existe la versi髇 o tiene homologo.
            OR NVL(pctramit, 1) <> 2   -- 27491:ASN:28/06/2013 No comprobamos nada en siniestros
                                    THEN
            -- 27045:ASN:31/05/2013 ini
            IF NVL(pctramit, 1) = 2 THEN   -- (Siniestros) si es vehiculo contrario no filtramos por producto
               SELECT COUNT(1)
                 INTO vcont
                 FROM aut_versiones av
                WHERE av.cversion = p_cversion
                  --AND(av.cestado NOT IN(2)) -- 27491:ASN:27/06/2013
                  AND av.cempres = pac_md_common.f_get_cxtempresa;
            ELSE
               -- 27045:ASN:31/05/2013 fin
               vcvalpar := f_return_parametre_autos(psproduc);

               SELECT COUNT(1)
                 INTO vcont
                 FROM aut_versiones av, aut_tipoactiprod t0
                WHERE av.cversion = p_cversion
                  AND av.ctipveh = t0.ctipveh
                  AND t0.cactivi = pcactivi
                  AND t0.sproduc = psproduc
                  AND av.cempres = t0.cempres
                  AND(av.cestado NOT IN(2))
                  AND((vcvalpar = 1
                       AND(av.cmarca, av.cmodelo, av.cversion) IN(
                                          SELECT cmarca, cmodelo, cversion
                                            FROM aut_marcas_prod a
                                           WHERE a.cempres = av.cempres
                                             AND a.sproduc = psproduc))
                      OR(vcvalpar = 2
                         AND(av.cmarca, av.cmodelo, av.cversion) NOT IN(
                                          SELECT cmarca, cmodelo, cversion
                                            FROM aut_marcas_prod a
                                           WHERE a.cempres = av.cempres
                                             AND a.sproduc = psproduc))
                      OR(NVL(vcvalpar, 0) = 0))
                  AND av.cempres = pac_md_common.f_get_cxtempresa;
            END IF;   -- 27045:ASN:31/05/2013

            IF vcont = 0 THEN
               --pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9904758);

               -- Ini bug 26419 -- ECP -- 25/04/2013
               pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, 42321,
                                             f_axis_literales(9906038,
                                                              pac_md_common.f_get_cxtidioma)
                                             || '. '
                                             || f_axis_literales
                                                                (9000577,
                                                                 pac_md_common.f_get_cxtidioma)
                                             || ' ' || p_cversion);
               -- Ini bug 26419 -- ECP -- 25/04/2013
               RETURN NULL;
            ELSE
               BEGIN
                  -- 27045:ASN:31/05/2013 ini
                  IF NVL(pctramit, 1) = 2 THEN
                     SELECT av.cversionhomologo
                       INTO vcversion
                       FROM aut_versiones av
                      WHERE av.cversion = p_cversion
                        AND(av.cestado IN(3));
                  ELSE
                     vcvalpar := f_return_parametre_autos(psproduc);

                     -- 27045:ASN:31/05/2013 fin
                     SELECT av.cversionhomologo
                       INTO vcversion
                       FROM aut_versiones av, aut_tipoactiprod t0
                      WHERE av.cversion = p_cversion
                        AND av.ctipveh = t0.ctipveh
                        AND t0.cactivi = pcactivi
                        AND t0.sproduc = psproduc
                        AND av.cempres = t0.cempres
                        AND((vcvalpar = 1
                             AND(av.cmarca, av.cmodelo, av.cversion) IN(
                                          SELECT cmarca, cmodelo, cversion
                                            FROM aut_marcas_prod a
                                           WHERE a.cempres = av.cempres
                                             AND a.sproduc = psproduc))
                            OR(vcvalpar = 2
                               AND(av.cmarca, av.cmodelo, av.cversion) NOT IN(
                                          SELECT cmarca, cmodelo, cversion
                                            FROM aut_marcas_prod a
                                           WHERE a.cempres = av.cempres
                                             AND a.sproduc = psproduc))
                            OR(NVL(vcvalpar, 0) = 0))
                        AND(av.cestado IN(3));
                  END IF;   -- 27045:ASN:31/05/2013

                  IF vcversion IS NOT NULL THEN
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, 42321,
                                             f_axis_literales(9905130,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' ' || p_cversion || ' '
                                             || f_axis_literales
                                                                (9905131,
                                                                 pac_md_common.f_get_cxtidioma)
                                             || ' ' || vcversion);
                  ELSE
                     pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, 42321,
                                             f_axis_literales(9906038,
                                                              pac_md_common.f_get_cxtidioma)
                                             || '. '
                                             || f_axis_literales
                                                                (9000577,
                                                                 pac_md_common.f_get_cxtidioma)
                                             || ' ' || vcversion);
                     RETURN NULL;
                  END IF;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     vcversion := p_cversion;
               END;
            END IF;
         END IF;

         v_tsquery :=
            'SELECT ma.tmarca, m.tmodelo, dc.cclaveh, dc.tclaveh, dt.ctipveh, dt.ttipveh, v.tversion, ff_desvalorfijo(291,'
            || v_cidioma
            || ', v.cmotor) des_version, v.CVERSION, v.CMODELO, v.CMARCA, v.CCLAVEH, v.CTIPVEH, v.TVERSION,'
            || ' v.TVARIAN, v.NPUERTA, v.NPUERTL, v.NPUERTT, v.FLANZAM, v.NTARA, v.NPMA, v.NVOLCAR, v.NLONGIT, v.NVIA,'
            || ' v.NNEUMAT, v.CVEHCHA, v.CVEHLOG, v.CVEHACR, v.CVEHCAJ CCAJA, v.CVEHTEC, v.CMOTOR, v.NCILIND CCILINDRAJE, v.NPOTECV,'
            || ' v.NPOTEKW, v.NPLAZAS, v.NACE100, v.NACE400, v.NVELOC, v.CVEHB7, v.CUSUALT, v.FALTA, v.CUSUMOD, v.FMODIFI, v.FBAJA,'
            || ' v.CEMPRES, v.CCOMODIN, v.CVERSIONHOMOLOGO, v.CSERVICIO, v.CPESO,v.CORIGEN, v.CMARCA_HOMOLOGACION, v.CCLAVEH_HOMOLOGACION, '
            || ' v.CTIPVEH_HOMOLOGACION, v.CAGRMARCA, v.CAGRCLASE,   v.CAGRTIPO, v.FHOMOLOGACION, v.CFORMA_HOMOLOGACION,v.CCLASESOAT, v.CESTADO, '
            || ' v.VALOR_NUEVO, v.CTRANSMISION '   --BUG 30256/168637 - RCL - 05/03/2014 - CTRANSMISION
            || ' FROM aut_versiones v, aut_modelos m, aut_marcas ma, aut_desclaveh dc, aut_destipveh dt'
            || '  WHERE v.cmodelo = m.cmodelo ' || '  AND v.cmarca = m.cmarca '
            || '  AND v.cempres = m.cempres ' || ' AND ma.cempres = m.cempres '
            || '  AND v.cmarca = ma.cmarca ' || '  AND v.cclaveh = dc.cclaveh '
            || '  AND v.ctipveh = dt.ctipveh ' || '  AND dc.cidioma = dt.cidioma '
            || '  AND dt.cidioma = ' || v_cidioma || ' AND v.cversion = ' || CHR(39)
            ||(vcversion) || CHR(39) || ' and ma.cempres = ' || v_empres
            || ' order by ma.tmarca, m.tmodelo, v.tversion';   -- BUG 10452 - 19/06/2009 - JJG  Cambio formato de campo versi贸n para consulta.
         cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_version;

   /*************************************************************************
   Recupera las marcas segun el producto, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmarcas(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,   -- 27045:ASN:30/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstmarcas';
      v_terror       VARCHAR2(200) := 'Error recuperar marcas segun producto';
      v_tsquery      VARCHAR2(2500);
      v_autversion   parempresas.tvalpar%TYPE;
   BEGIN
      IF NVL(pctramit, 1) = 2 THEN   -- para la tramitacion de vehiculo contrario no filtramos por producto
         v_tsquery :=
            'SELECT DISTINCT m0.cmarca, m0.tmarca tmarca
                       FROM aut_marcas m0, aut_versiones v0
                      WHERE m0.cmarca = v0.cmarca '
            || ' AND m0.cempres= v0.cempres ' || ' AND m0.cempres = ' || v_empres;
      ELSE
         v_tsquery :=
            'SELECT DISTINCT m0.cmarca, m0.tmarca tmarca
                       FROM aut_marcas m0, aut_versiones v0, aut_tipoactiprod t0
                      WHERE m0.cmarca = v0.cmarca '
            || ' AND m0.cempres= v0.cempres ' || ' AND m0.cempres= t0.cempres '
            || '         AND  v0.ctipveh =  t0.ctipveh ' || '     AND t0.sproduc = '
            || CHR(39) || psproduc || CHR(39) || ' AND t0.cactivi = ' || CHR(39)
            || NVL(pcactivi, 0) || CHR(39) || ' AND m0.cempres = ' || v_empres;
      END IF;

      v_autversion := pac_parametros.f_parempresa_t(pac_md_common.f_get_cxtempresa,
                                                    'AUTVERSION_NO_DEFIN');

      IF v_autversion IS NOT NULL THEN
         v_tsquery :=
            v_tsquery
            || ' UNION SELECT m0.cmarca, m0.tmarca tmarca
                    FROM aut_marcas m0, aut_versiones v0
                    WHERE m0.cmarca = v0.cmarca '
            || ' AND m0.cempres = v0.cempres ' || ' AND v0.cversion = ' || CHR(39)
            || v_autversion || CHR(39) || ' AND m0.cempres = ' || v_empres;
         -- BUG 10452 - 19/06/2009 - JJG  Ordenaci髇 de salida del consulta.
      -- Fi Bug 16458
      END IF;

--Bug 0025894 - JSV (30/07/2013) - INI
      v_tsquery := v_tsquery || f_filtra_marcas(psproduc);
      --Bug 0025894 - JSV (30/07/2013) - FIN
      v_tsquery := v_tsquery || ' ORDER BY tmarca';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmarcas;

   /*************************************************************************
   Recupera las modelos segun la marca, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstmodelos(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      p_cmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstmodelos';
      v_terror       VARCHAR2(200) := 'Error recuperar modelos segun marca y tipo vehiculo';
      v_tsquery      VARCHAR2(600);
      v_from         VARCHAR2(200);
   BEGIN
      -- 27045:ASN:31/05/2013 ini
      /*
      IF pctipveh IS NULL THEN
         v_from := ' FROM aut_modelos md, aut_versiones v0, aut_tipoactiprod t0 ';
      ELSE
         v_from := ' FROM aut_modelos md, aut_versiones v0 ';
      END IF;
      */
      IF pctipveh IS NOT NULL
         OR NVL(pctramit, 1) = 2 THEN   -- (siniestros) para tramitacion de vehiculo contrario no consideramos el producto
         v_from := ' FROM aut_modelos md, aut_versiones v0';
      ELSE
         v_from := ' FROM aut_modelos md, aut_versiones v0, aut_tipoactiprod t0 ';
      END IF;

      -- 27045:ASN:31/05/2013 fin

      -- BUG 10653 - 14/07/2009 - JJG Modificaciones para la simulaci贸n de autos y modalidades.
      v_tsquery := 'SELECT distinct md.cmodelo, md.tmodelo ' || v_from;

        -- 27045:ASN:31/05/2013 ini
        /*
        IF pctipveh IS NULL THEN
           v_tsquery :=
              v_tsquery
              || ' WHERE md.cempres= v0.cempres
            AND md.cempres = t0.cempres  and md.cempres = '
              || v_empres || '
      and v0.cmarca = ' || CHR(39) || p_cmarca || CHR(39) || ' and md.cmodelo = v0.cmodelo'
              || ' and v0.ctipveh = t0.ctipveh' || ' and md.cmarca = ' || CHR(39) || p_cmarca
              || CHR(39) || ' and t0.sproduc = ' || psproduc || ' and t0.cactivi = ' || pcactivi;

           IF pcclaveh IS NOT NULL THEN
              v_tsquery := v_tsquery || ' and v0.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
           END IF;

           v_tsquery := v_tsquery || ' order by tmodelo';
        ELSE
           v_tsquery := v_tsquery
                        || ' WHERE md.cempres= v0.cempres
            and md.cempres = ' || v_empres || '
      and v0.cmarca = ' || CHR(39) || p_cmarca || CHR(39) || ' and md.cmodelo = v0.cmodelo'
                        || ' and v0.ctipveh = ' || pctipveh || ' and md.cmarca = ' || CHR(39)
                        || p_cmarca || CHR(39);

           IF pcclaveh IS NOT NULL THEN
              v_tsquery := v_tsquery || ' and v0.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
           END IF;

           v_tsquery := v_tsquery || ' order by tmodelo';
        END IF;
        */
      IF pctipveh IS NOT NULL THEN
         v_tsquery := v_tsquery
                      || ' WHERE md.cempres= v0.cempres
          and md.cempres = ' || v_empres || '
          and v0.cmarca = ' || CHR(39) || p_cmarca || CHR(39)
                      || ' and md.cmodelo = v0.cmodelo' || ' and v0.ctipveh = ' || pctipveh
                      || ' and md.cmarca = ' || CHR(39) || p_cmarca || CHR(39);

         IF pcclaveh IS NOT NULL THEN
            v_tsquery := v_tsquery || ' and v0.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
         END IF;
      ELSIF NVL(pctramit, 1) = 2 THEN
         v_tsquery := v_tsquery
                      || ' WHERE md.cempres= v0.cempres
          and md.cempres = ' || v_empres || '
          and v0.cmarca = ' || CHR(39) || p_cmarca || CHR(39)
                      || ' and md.cmodelo = v0.cmodelo' || ' and md.cmarca = ' || CHR(39)
                      || p_cmarca || CHR(39);

         IF pcclaveh IS NOT NULL THEN
            v_tsquery := v_tsquery || ' and v0.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
         END IF;
      ELSE
         v_tsquery :=
            v_tsquery
            || ' WHERE md.cempres= v0.cempres
          AND md.cempres = t0.cempres  and md.cempres = '
            || v_empres || '
          and v0.cmarca = ' || CHR(39) || p_cmarca || CHR(39)
            || ' and md.cmodelo = v0.cmodelo' || ' and v0.ctipveh = t0.ctipveh'
            || ' and md.cmarca = ' || CHR(39) || p_cmarca || CHR(39) || ' and t0.sproduc = '
            || psproduc || ' and t0.cactivi = ' || pcactivi;

         IF pcclaveh IS NOT NULL THEN
            v_tsquery := v_tsquery || ' and v0.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
         END IF;
      END IF;

      --Bug 0025894 - JSV (30/07/2013) - INI
      v_tsquery := v_tsquery || f_filtra_modelos(psproduc);
      --Bug 0025894 - JSV (30/07/2013) - FIN
      v_tsquery := v_tsquery || ' order by tmodelo';
      -- 27045:ASN:31/05/2013 fin
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodelos;

   /*************************************************************************
    Recupera el numero de puertas de un modelo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstnumpuertas(
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstnumpuertas';
      v_terror       VARCHAR2(200) := 'Error recuperar modelos segun marca';
      v_tsquery      VARCHAR2(500);
   BEGIN
      --Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      v_tsquery :=
         'SELECT DISTINCT npuerta
           FROM aut_versiones
          WHERE cmarca = ' || CHR(39) || p_cmarca || CHR(39) || '
            AND cmodelo = ' || CHR(39) || p_cmodelo || CHR(39)
         || '
            AND cempres= ' || v_empres || ' order by npuerta asc';
      --Fin Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstnumpuertas;

   /*************************************************************************
    Recupera los usos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se a馻den los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(200)
         := ' p_cclaveh = ' || p_cclaveh || ' p_ctipveh = ' || p_ctipveh || ' p_sproduc = '
            || p_sproduc || ' p_cactivi = ' || p_cactivi;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstuso';
      v_terror       VARCHAR2(200) := 'Error recuperar marcas de un vehiculo';
      v_tsquery      VARCHAR2(4000);
      v_cont         NUMBER;   -- Bug 25566 - APD - 16/03/2013
   BEGIN
      -- Bug 25566 - APD - 16/03/2013 - se busca si hay parametracion definida
      -- para el producto
      SELECT COUNT(1)
        INTO v_cont
        FROM aut_usosubuso_prod UP
       WHERE UP.ctipveh = p_ctipveh
         AND UP.sproduc = p_sproduc
         AND UP.cactivi = p_cactivi;

      -- fin Bug 25566 - APD - 16/03/2013

      -- Bug 25566 - APD - 16/03/2013 - si no hay parametrizacion definida
      -- para el producto, se muestra para la parametrizacion generica
      IF v_cont = 0 THEN
         -- fin Bug 25566 - APD - 16/03/2013
         v_tsquery := 'SELECT DISTINCT d.cuso, d.tuso FROM aut_desuso d, aut_usosubuso u'
                      || ' WHERE d.cuso = u.cuso AND d.cempres = u.cempres ';
         /*   IF p_cclaveh IS NOT NULL THEN
               v_tsquery := v_tsquery || ' AND u.cclaveh = ' || CHR(39) || p_cclaveh || CHR(39);
            END IF;*/
         v_tsquery := v_tsquery || ' AND u.ctipveh = ' || CHR(39) || p_ctipveh || CHR(39)
                      || ' ' || ' AND d.fbaja IS NULL' || ' AND u.fbaja IS NULL'
                      || ' AND d.cidioma = ' || v_cidioma || ' AND u.cempres = ' || v_empres
                      || ' order by d.tuso ';
      -- Bug 25566 - APD - 16/03/2013 - si hay parametrizacion definida
      -- para el producto, se muestra para la parametrizacion del producto
      ELSE
         v_tsquery :=
            'SELECT DISTINCT d.cuso, d.tuso FROM aut_desuso d, aut_usosubuso_prod up'
            || ' WHERE d.cuso = up.cuso AND d.cempres = up.cempres ';
         /*   IF p_cclaveh IS NOT NULL THEN
               v_tsquery := v_tsquery || ' AND up.cclaveh = ' || CHR(39) || p_cclaveh || CHR(39);
            END IF;*/
         v_tsquery := v_tsquery || ' AND up.ctipveh = ' || CHR(39) || p_ctipveh || CHR(39)
                      || ' AND up.sproduc = ' || p_sproduc || ' AND up.cactivi = '
                      || p_cactivi || '  AND d.fbaja IS NULL' || ' AND up.fbaja IS NULL'
                      || ' AND d.cidioma = ' || v_cidioma || ' AND up.cempres = ' || v_empres
                      || ' order by d.tuso ';
      END IF;

      -- fin Bug 25566 - APD - 16/03/2013
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstuso;

   /*************************************************************************
    Recupera los subusos de un vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    -- Bug 25566 - APD - se a馻den los parametros p_sproduc y p_cactivi
    *************************************************************************/
   FUNCTION f_get_lstsubuso(
      p_cclaveh IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      p_uso IN VARCHAR2,
      p_sproduc IN NUMBER,
      p_cactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(200)
         := ' p_cclaveh = ' || p_cclaveh || ' p_ctipveh = ' || p_ctipveh || ' p_uso = '
            || p_uso || ' p_sproduc = ' || p_sproduc || ' p_cactivi = ' || p_cactivi;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstsubuso';
      v_terror       VARCHAR2(200) := 'Error recuperar marcas de un vehiculo';
      v_tsquery      VARCHAR2(1000);
      v_cont         NUMBER;   -- Bug 25566 - APD - 16/03/2013
   BEGIN
      -- Bug 25566 - APD - 16/03/2013 - se busca si hay parametracion definida
      -- para el producto
      SELECT COUNT(1)
        INTO v_cont
        FROM aut_usosubuso_prod UP
       WHERE UP.ctipveh = p_ctipveh
         AND UP.sproduc = p_sproduc
         AND UP.cactivi = p_cactivi;

      -- fin Bug 25566 - APD - 16/03/2013

      -- Bug 25566 - APD - 16/03/2013 - si no hay parametrizacion definida
      -- para el producto, se muestra para la parametrizacion generica
      IF v_cont = 0 THEN
         -- fin Bug 25566 - APD - 16/03/2013

         --Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
         v_tsquery :=
            'SELECT DISTINCT d.csubuso, d.tsubuso FROM aut_dessubuso d, aut_usosubuso u'
            || ' WHERE d.csubuso = u.csubuso AND d.cempres = u.cempres '
            || ' AND u.cclaveh = ' || CHR(39) || p_cclaveh || CHR(39) || ' '
            || ' AND u.ctipveh = ' || CHR(39) || p_ctipveh || CHR(39) || ' '
            || ' AND u.cuso = ' || CHR(39) || p_uso || CHR(39) || ' '
            || ' AND d.fbaja IS NULL' || ' AND u.fbaja IS NULL' || ' AND d.cidioma = '
            || v_cidioma || ' AND u.cempres = ' || v_empres || ' order by d.tsubuso ';
      --Fin Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      -- Bug 25566 - APD - 16/03/2013 - si hay parametrizacion definida
      -- para el producto, se muestra para la parametrizacion del producto
      ELSE
         v_tsquery :=
            'SELECT DISTINCT d.csubuso, d.tsubuso FROM aut_dessubuso d, aut_usosubuso_prod up'
            || ' WHERE d.csubuso = up.csubuso AND d.cempres = up.cempres '
            || ' AND up.cclaveh = ' || CHR(39) || p_cclaveh || CHR(39) || ' AND up.ctipveh = '
            || CHR(39) || p_ctipveh || CHR(39) || ' AND up.cuso = ' || CHR(39) || p_uso
            || CHR(39) || ' AND up.sproduc = ' || p_sproduc || ' AND up.cactivi = '
            || p_cactivi || ' AND d.fbaja IS NULL' || ' AND up.fbaja IS NULL'
            || ' AND d.cidioma = ' || v_cidioma || ' AND up.cempres = ' || v_empres
            || ' order by d.tsubuso ';
      END IF;

      -- fin Bug 25566 - APD - 16/03/2013
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubuso;

   /*************************************************************************
    Recupera las versiones que existen en funci贸n de la marca, modelo,
   n煤mero de puestas y motor de un veh铆culo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstversiones(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      p_cmarca IN VARCHAR2,
      p_cmodelo IN VARCHAR2,
      p_numpuertas IN VARCHAR2,
      p_cmotor IN VARCHAR2,
      pctipveh IN VARCHAR2,
      pcclaveh IN VARCHAR2,
      pcversion IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstversiones';
      v_terror       VARCHAR2(200)
                            := 'Error recuperar versiones segun marca, modelo, puetas y motor';
      v_tsquery      VARCHAR2(4000);
   BEGIN
      -- 27045:ASN:31/05/2013 ini
      /*
      v_tsquery :=
         'SELECT   pac_autos.f_desmarca ( v.cmarca) tmarca,
                 pac_autos.f_desmodelo( v.cmodelo, v.cmarca) tmodelo,
                 pac_autos.f_desclaveh( v.cclaveh, '
         || v_cidioma || ' )tclaveh,
                 pac_autos.f_destipveh( v.ctipveh, ' || v_cidioma
         || ') ttipveh,
                 v.cversion, v.tversion,
                 ff_desvalorfijo(291,  '
         || v_cidioma
         || ', v.cmotor) || ''  '' || v.npotecv || '' CV  ''||DECODE(v.npuerta, NULL, NULL, f_axis_literales ( 9001053, '
         || v_cidioma
         || ')|| v.npuerta ) des_version,
                 cvehb7, flanzam,
                 v.CTIPVEH,v.CCLAVEH,v.CMODELO,V.CMARCA
            FROM aut_versiones v, aut_tipoactiprod t
           WHERE v.ctipveh = t.ctipveh '
         || ' AND v.cempres = t.cempres ' || ' AND t.cactivi =  ' || pcactivi
         || ' AND t.sproduc =  ' || psproduc || ' AND v.cempres = ' || v_empres
         || ' AND v.cestado= 1';
      */
      v_tsquery :=
         'SELECT   pac_autos.f_desmarca ( v.cmarca) tmarca,
                 pac_autos.f_desmodelo( v.cmodelo, v.cmarca) tmodelo,
                 pac_autos.f_desclaveh( v.cclaveh, '
         || v_cidioma || ' )tclaveh,
                 pac_autos.f_destipveh( v.ctipveh, ' || v_cidioma
         || ') ttipveh,
                 v.cversion, v.tversion,
                 ff_desvalorfijo(291,  '
         || v_cidioma
         || ', v.cmotor) || ''  '' || v.npotecv || '' CV  ''||DECODE(v.npuerta, NULL, NULL, f_axis_literales ( 9001053, '
         || v_cidioma
         || ')|| v.npuerta ) des_version,
                 cvehb7, flanzam,
                 v.CTIPVEH,v.CCLAVEH,v.CMODELO,V.CMARCA ';

      IF NVL(pctramit, 1) = 2 THEN
         v_tsquery := v_tsquery || ' FROM aut_versiones v
           WHERE v.cempres = ' || v_empres;
      --|| ' AND v.cestado= 1'; -- 27491:ASN:27/06/2013
      ELSE
         v_tsquery :=
            v_tsquery
            || ' FROM aut_versiones v, aut_tipoactiprod t
           WHERE v.ctipveh = t.ctipveh '
            || ' AND v.cempres = t.cempres ' || ' AND t.cactivi =  ' || pcactivi
            || ' AND t.sproduc =  ' || psproduc || ' AND v.cempres = ' || v_empres
            || ' AND v.cestado= 1';
      END IF;

      -- 27045:ASN:31/05/2013 fin
      IF p_cmarca IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.cmarca = ' || CHR(39) ||(p_cmarca) || CHR(39);
      END IF;

      IF p_cmodelo IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.cmodelo = ' || CHR(39) || p_cmodelo || CHR(39);
      END IF;

      IF p_numpuertas IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.npuerta = ' || CHR(39) || p_numpuertas || CHR(39);
      END IF;

      IF p_cmotor IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.cmotor = ' || p_cmotor;
      END IF;

      IF pctipveh IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.ctipveh = ' || CHR(39) || pctipveh || CHR(39);
      END IF;

      IF pcclaveh IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.cclaveh = ' || CHR(39) || pcclaveh || CHR(39);
      END IF;

      IF pcversion IS NOT NULL THEN
         v_tsquery := v_tsquery || ' AND v.cversion = ' || CHR(39) || pcversion || CHR(39);
      END IF;

--Bug 0025894 - JSV (30/07/2013) - INI
      v_tsquery := v_tsquery || f_filtra_versiones(psproduc);
      --Bug 0025894 - JSV (30/07/2013) - FIN
      v_tsquery := v_tsquery || ' order by v.tversion';
      --FIN Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstversiones;

   /*************************************************************************
    Recupera los diferentes tipos de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstctipveh(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstctipveh';
      v_terror       VARCHAR2(200) := 'Error recuperar modelos segun marca';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT ctipveh, ttipveh
            FROM aut_destipveh WHERE cidioma = ' || v_cidioma || ' AND cempres = ' || v_empres
         || ' order by ttipveh';
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh;

   FUNCTION f_get_lstctipveh_pormarca(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcmarca IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstctipveh_pormarca';
      v_terror       VARCHAR2(200) := 'Error recuperar marcas segun producto';
      v_tsquery      VARCHAR2(2500);
   BEGIN
      IF NVL(pctramit, 1) = 2 THEN
         v_tsquery :=
            'SELECT DISTINCT t0.ctipveh, t0.ttipveh
                       FROM  aut_versiones v0, aut_destipveh t0
               WHERE v0.cmarca = '
            || CHR(39) || pcmarca || CHR(39)
            || '   AND  v0.ctipveh =  t0.ctipveh
                        and cidioma = ' || v_cidioma || ' order by ttipveh';
      ELSE
         v_tsquery :=
            'SELECT DISTINCT t0.ctipveh, t0.ttipveh
                       FROM  aut_versiones v0, aut_destipveh t0, aut_tipoactiprod t
               WHERE v0.ctipveh = t.ctipveh and t.sproduc = '
            || psproduc || ' and cactivi = ' || pcactivi
            || '
                    and v0.cmarca = ' || CHR(39) || pcmarca || CHR(39)
            || '
                        AND  v0.ctipveh =  t0.ctipveh
                        and cidioma = '
            || v_cidioma || ' order by ttipveh';
      END IF;

      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh_pormarca;

   /*************************************************************************
    Recupera los diferentes clases de vehiculo, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstclaveh(p_ctipveh IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstclaveh';
      v_v_terror     VARCHAR2(200) := 'Error recuperar modelos segun marca';
      v_tsquery      VARCHAR2(500);
   BEGIN
      --Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      v_tsquery :=
         'SELECT c.cclaveh, c.tclaveh
            FROM aut_tipoclase t, aut_desclaveh c
           WHERE t.cempres = c.cempres '
         || ' AND ctipveh = ' || CHR(39) || p_ctipveh || CHR(39)
         || ' AND t.cclaveh = c.cclaveh AND c.cidioma = ' || v_cidioma || ' AND t.cempres = '
         || v_empres || ' order by  c.tclaveh';
      --Fin Bug 24581. -27/12/2012   - FAC modificacion se adiciona el camp cempres
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstclaveh;

   /*************************************************************************
   Recupera los diferentes clases de vehiculo, devuelve un SYS_REFCURSOR
   param out : mensajes de error
   return : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstclaveh_pormarca(
      pcmarca IN VARCHAR2,
      p_ctipveh IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstclaveh_pormarca';
      v_v_terror     VARCHAR2(200) := 'Error recuperar modelos segun marca';
      v_tsquery      VARCHAR2(500);
   BEGIN
      v_tsquery :=
         'SELECT distinct c.cclaveh, c.tclaveh
            FROM aut_tipoclase t, aut_desclaveh c, aut_versiones v0
           WHERE v0.cmarca = '
         || CHR(39) || pcmarca || CHR(39) || ' and t.ctipveh = ' || CHR(39) || p_ctipveh
         || CHR(39)
         || ' AND t.cclaveh = c.cclaveh AND t.ctipveh = v0.ctipveh and t.cclaveh = v0.cclaveh and c.cidioma = '
         || v_cidioma || ' order by tclaveh';
      /* v_tsquery :=
      'SELECT DISTINCT t0.ctipveh, t0.ttipveh
                FROM  aut_versiones v0, aut_destipveh t0
               WHERE v0.cmarca = '
      || pcmarca
      || '
                 AND  v0.ctipveh =  t0.ctipveh
                 and cidioma = '
      || v_cidioma;*/
      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstclaveh_pormarca;

-- FI BUG 9198 - 26/02/2009 - DCM 驴 Se crean funciones para AUTOS.

   -- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_get_lstmodalidades
   /*************************************************************************
    Recupera las modalidades permitidas en un producto y actividad, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor
    *************************************************************************/
   FUNCTION f_get_lstmodalidades(
      p_cramo IN NUMBER,
      p_cmodali IN NUMBER,
      p_ctipseg IN NUMBER,
      p_ccolect IN NUMBER,
      p_cactivi IN NUMBER,
      p_csimula IN BOOLEAN,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstmodalidades';
      v_terror       VARCHAR2(200)
                  := 'Error recuperar las modalidades permitidas para un producto y actividad';
      v_tsquery      VARCHAR2(1000);
   BEGIN
-- BUG 10653 - 14/07/2009 - JJG Modificaciones para la simulaci贸n de autos y modalidades.
      IF p_csimula THEN
         v_tsquery :=
            'SELECT distinct  d.cmodalidad, d.tmodalidad
                    FROM garanpromodalidad g, aut_desmodalidad d, aut_codmodalidad c
                    WHERE g.cmodalidad = d.cmodalidad
                      AND g.cmodalidad = c.cmodalidad
                      AND g.cramo = '
            || p_cramo || ' AND g.cmodali = ' || p_cmodali || ' AND g.ctipseg = ' || p_ctipseg
            || ' AND g.ccolect = ' || p_ccolect || ' AND g.cactivi = ' || NVL(p_cactivi, 0)
            || ' AND d.cidioma = ' || pac_md_common.f_get_cxtidioma
            || ' and c.csimula = 1 ORDER BY d.tmodalidad';
      -- Fin BUG 10653 - 14/07/2009 - JJG Modificaciones para la simulaci贸n de autos y modalidades.
      ELSE
         v_tsquery :=
            'SELECT distinct  d.cmodalidad, d.tmodalidad
                    FROM garanpromodalidad g, aut_desmodalidad d
                    WHERE g.cmodalidad = d.cmodalidad
                      AND g.cramo = '
            || p_cramo || ' AND g.cmodali = ' || p_cmodali || ' AND g.ctipseg = ' || p_ctipseg
            || ' AND g.ccolect = ' || p_ccolect || ' AND g.cactivi = ' || NVL(p_cactivi, 0)
            || ' AND d.cidioma = ' || pac_md_common.f_get_cxtidioma || 'ORDER BY d.tmodalidad';
      END IF;

      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodalidades;

-- Bug 9247 - APD - 23/03/2009 -- Se crea la funcion f_get_lstmodalidades
   FUNCTION f_get_anyos_version(
      p_cversion IN VARCHAR2,
      p_nriesgo IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_pasexec      NUMBER(8) := 1;
      v_param        VARCHAR2(200) := NULL;
      v_object       VARCHAR2(200) := 'PAC_md_LISTVALORES_AUT.f_get_anyos_version';
      v_tsquery      VARCHAR2(1000);
      v_ssegpol      NUMBER;
      v_anyo         NUMBER;
      vobauto        ob_iax_autriesgos := ob_iax_autriesgos();
   BEGIN
      vobauto := pac_iax_produccion_aut.f_lee_riesauto(NVL(p_nriesgo, 1), mensajes);

      IF (vobauto.sseguro IS NOT NULL) THEN
         --En nueva producci髇, la lista de modelos no deben salir los registros con valor comercial 0,
         --pero si que debe salir un modelo con valor comercial 0 si este es el que esta contratado.
         --esto se tendra en cuenta en la query a partir del valor recuperado en v_anyo
         BEGIN
            SELECT anyo
              INTO v_anyo
              FROM estautriesgos
             WHERE sseguro = vobauto.sseguro;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               SELECT anyo
                 INTO v_anyo
                 FROM autriesgos
                WHERE sseguro = vobauto.sseguro
                  AND nmovimi = (SELECT MAX(nmovimi)
                                   FROM autriesgos
                                  WHERE sseguro = vobauto.sseguro);
         END;
      END IF;

      v_tsquery :=
         'SELECT   d.cversion,anyo, d.VCOMERCIAL,autv.CPESO,autv.NPUERTA,autv.CTRANSMISION,autv.NTARA,
         (SELECT vcomercial
            FROM aut_versiones_anyo d
           WHERE d.cversion = '
         || p_cversion
         || '
             AND anyo = (SELECT MAX(anyo)
                           FROM aut_versiones_anyo d
                          WHERE d.cversion = '
         || p_cversion
         || ')) vnuevo
                    FROM aut_versiones_anyo d, aut_versiones autv
                    WHERE d.cversion = '
         || p_cversion || ' AND (anyo=''' || v_anyo
         || ''' OR vcomercial > 0 ) AND d.cversion = autv.cversion ORDER BY d.anyo desc';

      IF pac_iax_log.f_log_consultas(v_tsquery, 'PAC_MD_LISTVALORES_AUT.f_get_anyos_version',
                                     1, 2, mensajes) <> 0 THEN
         RAISE e_object_error;
      END IF;

      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000005, v_pasexec, v_param);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_object, 1000001, v_pasexec, v_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_anyos_version;

   FUNCTION f_get_lstaccesorios(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_lstaccesorios';
      terror         VARCHAR2(200) := 'Error recuperar lista de accesorios';
      v_query        VARCHAR2(1000);
   BEGIN
      v_query :=
         'SELECT caccesorio,taccesorio from aut_accesorios where cversion = 0 order by taccesorio';
      cur := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstaccesorios;

   FUNCTION f_get_taccesorio(pcaccesorio IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN VARCHAR2 IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_lstaccesorios';
      terror         VARCHAR2(200) := 'Error recuperar lista de accesorios';
      v_query        VARCHAR2(1000);
      vtaccesorio    VARCHAR2(2000);
   BEGIN
      SELECT taccesorio
        INTO vtaccesorio
        FROM aut_accesorios
       WHERE cversion = 0
         AND caccesorio = pcaccesorio;

      RETURN vtaccesorio;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN '';
   END f_get_taccesorio;

   FUNCTION f_get_lstdispositivos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_lstdispositivos';
      terror         VARCHAR2(200) := 'Error recuperar lista de dispositivos';
      v_query        VARCHAR2(1000);
   BEGIN
      v_query :=
         'SELECT cdispositivo,tdispositivo from aut_dispositivos where cversion = 0   order by tdispositivo';
      cur := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdispositivos;

   /*************************************************************************
    Recupera si un accesorio es asegurable, devuelve un SYS_REFCURSOR
    param out : mensajes de error
    return : ref cursor

    Bug 25578/135876 - 04/02/2013 - AMC
    *************************************************************************/
   FUNCTION f_get_lstasegurables(
      psproducto IN NUMBER,
      pcactivi IN NUMBER,
      pcaccesorio IN VARCHAR2,
      pctipo IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproducto:' || psproducto || ' pcactivi:' || pcactivi || ' pcaccesorio:'
            || pcaccesorio;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstasegurables';
      terror         VARCHAR2(200) := 'Error recuperar lista de accesorios';
      v_query        VARCHAR2(1000);
   BEGIN
      v_query :=
         'SELECT SPRODUC,CACTIVI,CACCESORIO,CASEGURABLE  FROM PROD_ACTIVI_ACCESORIO WHERE 1=1';

      IF psproducto IS NOT NULL THEN
         v_query := v_query || ' AND SPRODUC = ' || psproducto;
      END IF;

      IF pcactivi IS NOT NULL THEN
         v_query := v_query || ' AND CACTIVI = ' || pcactivi;
      END IF;

      IF pcaccesorio IS NOT NULL THEN
         v_query := v_query || ' AND CACCESORIO = ' || CHR(39) || pcaccesorio || CHR(39);
      END IF;

      IF pctipo IS NOT NULL THEN
         v_query := v_query || ' AND CTIPACC =' || pctipo;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN cur;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstasegurables;

   /*************************************************************************
     Recupera la lista del peso de veh靋ulos, devuelve un SYS_REFCURSOR
     param out : mensajes de error
     return : ref cursor

     Bug 25202/135707- 15/02/2013 - ECP
     *************************************************************************/
   FUNCTION f_get_lstpesos(psproduc IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES.f_get_lstpesos';
      terror         VARCHAR2(200) := 'Error recuperar lista de pesos';
      v_query        VARCHAR2(1000);
      v_cont         NUMBER;
      v_sproduc      NUMBER;
   BEGIN
      SELECT COUNT(1)
        INTO v_cont
        FROM aut_prod_pesos
       WHERE sproduc = psproduc
         AND cidioma = pac_md_common.f_get_cxtidioma;

      IF v_cont > 0 THEN
         v_sproduc := psproduc;
      ELSE
         v_sproduc := 0;
      END IF;

      v_query := 'SELECT cpeso, tpeso from aut_prod_pesos where sproduc = ' || v_sproduc
                 || ' and cidioma = ' || pac_md_common.f_get_cxtidioma || ' order by tpeso';
      cur := pac_iax_listvalores.f_opencursor(v_query, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpesos;

   -- BUG 26968 - FAL - 29/07/2013
   FUNCTION f_get_lstctipveh_pormarcamodel(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcmarca IN VARCHAR2,
      pcmodelo IN VARCHAR2,
      pctramit IN NUMBER,   -- 27045:ASN:31/05/2013
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      v_npasexec     NUMBER(8) := 1;
      v_tparam       VARCHAR2(1) := NULL;
      v_tobject      VARCHAR2(200) := 'PAC_MD_LISTVALORES_AUT.f_get_lstctipveh_pormarcamodel';
      v_terror       VARCHAR2(200) := 'Error recuperar marcas segun producto';
      v_tsquery      VARCHAR2(2500);
   BEGIN
      IF NVL(pctramit, 1) = 2 THEN
         v_tsquery :=
            'SELECT DISTINCT t0.ctipveh, t0.ttipveh
                       FROM  aut_versiones v0, aut_destipveh t0
               WHERE v0.cmarca = '
            || CHR(39) || pcmarca || CHR(39) || '   AND v0.cmodelo = ' || CHR(39) || pcmodelo
            || CHR(39)
            || '   AND  v0.ctipveh =  t0.ctipveh
                        and cidioma = ' || v_cidioma || ' order by ttipveh';
      ELSE
         v_tsquery :=
            'SELECT DISTINCT t0.ctipveh, t0.ttipveh
                       FROM  aut_versiones v0, aut_destipveh t0, aut_tipoactiprod t
               WHERE v0.ctipveh = t.ctipveh and t.sproduc = '
            || psproduc || ' and cactivi = ' || pcactivi
            || '
                    and v0.cmarca = ' || CHR(39) || pcmarca || CHR(39)
            || '
                    and v0.cmodelo = ' || CHR(39) || pcmodelo || CHR(39)
            || '
                        AND  v0.ctipveh =  t0.ctipveh
                        and cidioma = '
            || v_cidioma || ' order by ttipveh';
      END IF;

      cur := pac_md_listvalores.f_opencursor(v_tsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, v_tobject, 1000001, v_npasexec, v_tparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstctipveh_pormarcamodel;

   /*************************************************************************
      Filtra marcas por desplegable de marcas
      param out : Condicio
      return : VARCHAR2

      Bug 0025894 - JSV (30/07/2013)
      *************************************************************************/
   FUNCTION f_filtra_marcas(psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vretorn        VARCHAR2(500);
      vcvalpar       NUMBER;
   BEGIN
      vretorn := ' ';
      vcvalpar := f_return_parametre_autos(psproduc);

      IF vcvalpar = 1 THEN
         vretorn :=
            ' AND m0.cmarca in (select cmarca from aut_marcas_prod a where a.CEMPRES=m0.cempres and a.SPRODUC='
            || psproduc || ')';
      ELSIF vcvalpar = 2 THEN
         vretorn :=

            -- Bug 0025894 - JSV (19/08/2013) - Reajuste
               --' AND m0.cmarca not in (select cmarca from aut_marcas_prod a where a.CEMPRES=m0.cempres and a.SPRODUC='|| psproduc || ')';
            ' AND m0.cmarca in (select distinct cmarca from aut_versiones a  where a.cempres=m0.cempres and a.cversion not in
             (select cversion from aut_marcas_prod b where b.CEMPRES=m0.cempres and b.SPRODUC='
            || psproduc || '))';
      END IF;

      RETURN vretorn;
   END;

   /*************************************************************************
       Filtra modelos por desplegable de modelos
       param out : Condicio
       return : VARCHAR2

       Bug 0025894 - JSV (30/07/2013)
       *************************************************************************/
   FUNCTION f_filtra_modelos(psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vretorn        VARCHAR2(500);
      vcvalpar       NUMBER;
   BEGIN
      vretorn := ' ';
      vcvalpar := f_return_parametre_autos(psproduc);

      IF vcvalpar = 1 THEN
         vretorn :=
            ' AND (md.cmarca, md.cmodelo) in (select cmarca, cmodelo from aut_marcas_prod a where a.CEMPRES=md.cempres and a.SPRODUC='
            || psproduc || ')';
      ELSIF vcvalpar = 2 THEN
         vretorn :=

            -- Bug 0025894 - JSV (19/08/2013) - Reajuste
            --' AND (md.cmarca,md.cmodelo) not in (select cmarca,cmodelo from aut_marcas_prod a where a.CEMPRES=md.cempres and a.SPRODUC='|| psproduc || ')';
            ' AND (md.cmarca,md.cmodelo) in (select distinct cmarca, cmodelo from aut_versiones a where a.cempres=md.cempres and a.cversion not in
             (select cversion from aut_marcas_prod b where b.CEMPRES=md.cempres and b.SPRODUC='
            || psproduc || '))';
      END IF;

      RETURN vretorn;
   END;

   /*************************************************************************
     Filtra versiones
     param out : Condicio
     return : VARCHAR2

     Bug 0025894 - JSV (31/07/2013)
     *************************************************************************/
   FUNCTION f_filtra_versiones(psproduc IN NUMBER)
      RETURN VARCHAR2 IS
      vretorn        VARCHAR2(500);
      vcvalpar       NUMBER;
   BEGIN
      vretorn := ' ';
      vcvalpar := f_return_parametre_autos(psproduc);

      IF vcvalpar = 1 THEN
         vretorn :=
            ' AND (v.cmarca, v.cmodelo, v.cversion) in (select cmarca, cmodelo, cversion from aut_marcas_prod a where a.CEMPRES=v.cempres and a.SPRODUC='
            || psproduc || ')';
      ELSIF vcvalpar = 2 THEN
         vretorn :=
            ' AND (v.cmarca, v.cmodelo, v.cversion) not in (select cmarca,cmodelo, cversion from aut_marcas_prod a where a.CEMPRES=v.cempres and a.SPRODUC='
            || psproduc || ')';
      END IF;

      RETURN vretorn;
   END;
END pac_md_listvalores_aut;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_LISTVALORES_AUT" TO "PROGRAMADORESCSI";
