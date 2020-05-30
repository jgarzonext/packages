create or replace PACKAGE BODY        "PAC_MD_LISTVALORES_SIN" AS
/******************************************************************************
   NOMBRE:       PAC_MD_LISTVALORES_SIN
   PROPÓSITO:  Funciones para recuperar valores

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        25/01/2008   ACC                1. Creación del package.
   2.0        20/05/2009   AMC                2. Se añaden nuevas funciones bug 8816.
   3.0        01/10/2009   DCT                1. Bug 10393 Crear parametrización de documentacion a solicitar por producto/causa
   4.0        21/10/2009   DCT                1. Bug 10211 Procesos cambio estado siniestro/tramitación
   5.0        10/12/2009   AMC                5. Bug 0012211: Mant. Eventos
   6.0        05/01/2010   AMC                6. Bug 12573 - se modifica la función f_get_lstestado
   7.0        14/01/2010   AMC                7. Bug 12605 - Destinatarios siniestros según parametrización
   8.0        09/02/2010   AMC                8. Bug 0012822 CEM - RT - Tratamiento fiscal rentas a 2 cabezas
   9.0        01/03/2010   JMF                8. 0013070 AGA - Error al generar rescates 'Error no controlado'
   10.0       05/03/2010   AMC                9. Bug 13312 se añade la funcion f_get_lsctestmov
   12.0       30/10/2010   JRH                10. BUG 15669 : Campos nuevos
   13.0       14/02/2011   JRH                13. 0017247: ENSA103 - Instalar els web-services als entorns CSI
   14.0       16/03/2011   JMF                14. 0017970: ENSA101- Campos pantallas de siniestros y mejoras
   15.0       17/06/2011   APD                15. 0018670: ENSA102- Permitir escoger las formas posibles de prestación a partir del tipo de siniestro
   16.0       01/07/2011   APD                16. 0018913: CRE998 - Afegir motiu de Rescats
   17.0       23/07/2012   ASN                17. 0022945: MDP_S001-SIN - Parametrizar varios tramitadores
   18.0       15/10/2013   MMM                18. 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos
   19.0       25/11/2014   AGG                19. 0033574: POSPT500-VG REGISTRO DESTINATARIO DE PAGO (bug hermano interno)
   20.0		  29/03/2019   Swapnil		      20. Cambio de IAXIS-2168
******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

/*************************************************************************
   FUNCTION f_get_causasini
   Recupera les possibles causes de sinistres de pòlisses d'un determinat producte
   param in psproduc  : codi del producte
   param in psseguro  : codi del segur
   param in pcactivi  : codi de l'activitat
   param in pnriesgo  : codi del risc
   param in pfsinies  : data d'ocurrència del sinistre
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_causasini(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      /*Cambios de IAXIS-2168 : Start*/
      psseguro IN NUMBER,
      /*Cambios de IAXIS-2168 : End*/
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi
						/*Cambios de IAXIS-2168 : Start*/
						|| ' - psseguro:' || psseguro
						/*Cambios de IAXIS-2168 : End*/
						;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_CausaSini';
      v_tcausin      axis_literales.tlitera%TYPE;
   BEGIN
      IF psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      IF NVL(pac_parametros.f_parproducto_n(psproduc, 'PRESTACION'), 0) = 1 THEN
         v_tcausin := 'f_axis_literales(9900994,' || pac_md_common.f_get_cxtidioma() || ')';
      ELSE
         v_tcausin := 'sdc.tcausin';
      END IF;

      -- Bug 0012822 - 09/02/2010 - JMF: Evitar que es puguin seleccionar les causes (3,4,5,8)
      cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT DISTINCT sgc.ccausin, DECODE(sgc.ccausin,1,' || v_tcausin
             || ',sdc.tcausin) tcausin' || '  FROM sin_gar_causa sgc, sin_descausa sdc'
             || ' WHERE sdc.cidioma = ' || pac_md_common.f_get_cxtidioma()
             || '   AND sgc.cactivi = ' || pcactivi || '   AND sgc.ccausin = sdc.ccausin '
             || '   AND sgc.sproduc = ' || psproduc || '   AND sgc.ccausin not in (3,4,5,8) '
			 /*Cambios de IAXIS-2168 : Start*/
             || ' AND SGC.CGARANT IN (SELECT DISTINCT G.CGARANT FROM GARANSEG G WHERE G.SSEGURO = '|| psseguro
             || ' AND G.NMOVIMI = (SELECT MAX(GA.NMOVIMI) FROM GARANSEG GA WHERE GA.SSEGURO = '|| psseguro ||'))'
   			 /*Cambios de IAXIS-2168 : End*/
             || 'UNION ' || ' SELECT DISTINCT sgc.ccausin,  DECODE(sgc.ccausin,1,' || v_tcausin
             || ',sdc.tcausin) tcausin' || '  FROM sin_gar_causa sgc, sin_descausa sdc'
             || ' WHERE sdc.cidioma = ' || pac_md_common.f_get_cxtidioma()
             || '   AND sgc.cactivi = 0'
             || '   AND NOT EXISTS (SELECT 1 FROM sin_gar_causa WHERE sproduc = sgc.sproduc AND cactivi = '
             || pcactivi || ')' || '   AND sgc.ccausin = sdc.ccausin '
             || '   AND sgc.sproduc = ' || psproduc || '   AND sgc.ccausin not in (3,4,5,8) '
			 /*Cambios de IAXIS-2168 : Start*/
             || ' AND SGC.CGARANT IN (SELECT DISTINCT G.CGARANT FROM GARANSEG G WHERE G.SSEGURO = '|| psseguro
             || ' AND G.NMOVIMI = (SELECT MAX(GA.NMOVIMI) FROM GARANSEG GA WHERE GA.SSEGURO = '|| psseguro ||'))'
			 /*Cambios de IAXIS-2168 : End*/
             || ' ORDER BY ccausin',
             mensajes);
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
   END f_get_causasini;

/*************************************************************************
   FUNCTION F_Get_MotivosSini
   Recupera llista amb els motius de sinistres per producte
   param in psproduc  : codi del producte
   param in pccausa   : codi de la causa del sinistre
   param in psseguro  : codi del segur
   param in pcactivi  : codi de l'activitat
   param in pnriesgo  : codi del risc
   param in pfsinies  : data d'ocurrència del sinistre
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_motivossini(
      psproduc IN NUMBER,
      pccausa IN NUMBER,
      pcactivi IN NUMBER,
      psseguro IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      -- Bug 0012822 - 09/02/2010 - JMF: Afegir paràmetre seguro.
      n_cas          NUMBER;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'paràmetres - psproduc: ' || psproduc || ' - pccausa:' || pccausa
            || ' - pcactivi:' || pcactivi;
      vobject        VARCHAR2(50) := 'PAC_MD_LISTVALORES_SIN.F_Get_MotivosSini';
      vsquery        VARCHAR2(500);
      cur            sys_refcursor;
   BEGIN
      -- Comprovació pas de paràmetres
      IF psproduc IS NULL
         OR pccausa IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- ini Bug 0012822 - 09/02/2010 - JMF
      IF NVL(f_parproductos_v(psproduc, 'FISCALIDAD_2_CABEZAS'), 0) = 1 THEN
         SELECT COUNT(1)
           INTO n_cas
           FROM asegurados
          WHERE sseguro = psseguro
            AND ffecmue IS NULL;

         IF n_cas = 1 THEN
            -- Un assegurat, només mot. 0-defunció.
            n_cas := 0;
         ELSIF n_cas > 1 THEN
            -- Més d'un assegurat, que no surti 0-defunció.
            n_cas := 1;
         ELSE
            -- Altres casos no controlats.
            n_cas := 2;
         END IF;
      ELSE
         -- Altres casos: Sortiran tots els motius.
         n_cas := 2;
      END IF;

      -- fin Bug 0012822 - 09/02/2010 - JMF

      /*  vpasexec := 2;
        vsquery :=
           'SELECT DISTINCT C.CMOTSIN,D.TMOTSIN '
           || '  FROM SIN_DESMOTCAU DES, SIN_CODMOTCAU COD, SIN_GAR_CAUSA GAR'
           || ' WHERE DES.CIDIOMA = ' || pac_md_common.f_get_cxtidioma
           || '   AND DES.CMOTSIN = COD.CMOTSIN' || '   AND DES.CCAUSIN = COD.CCAUSIN'
           || '   AND DES.CRAMO   = COD.CRAMO' || '   AND COD.CCAUSIN = ' || pccausa
           || '   AND GAR.SPRODUC = ' || psproduc || '   AND GAR.CACTIVI = ' || pcactivi
           || '   AND GAR.CGARANT   IN (SELECT GSEG.CGARANT
                                                 FROM GARANSEG
                                                WHERE SSEGURO ='
           || psseguro || '                            AND NRIESGO =' || pnriesgo
           || '                            AND NMOVIMI IN (SELECT MAX(NMOVIMI)'
           || '                                               FROM GARANSEG'
           || '                                              WHERE SSEGURO=' || psseguro
           || '                                               AND (FFINEFE IS NULL'
           || '                                                     OR (FINIEFE <=' || pfsinies
           || '                                                         AND FFINEFE >'
           || pfsinies || ')))' || '   AND GAR.CMOTSIN = COD.CMOTSIN'
           || '   AND GAR.CCAUSIN = COD.CCAUSIN' || ' ORDER BY COD.CMOTSIN';*/

      -- Bug 0012822 - 09/02/2010 - JMF: Afegir casos en funció del seguro.
      cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT DISTINCT sgc.cmotsin,  sdm.tmotsin '
             || '  FROM sin_gar_causa sgc, sin_desmotcau sdm' || ' WHERE sdm.cidioma = '
             || pac_md_common.f_get_cxtidioma() || '   AND sgc.cactivi = ' || pcactivi
             || '   AND sgc.ccausin = ' || pccausa || '   AND sgc.ccausin = sdm.ccausin '
             || '   AND sgc.cmotsin = sdm.cmotsin ' || '   AND sgc.sproduc = ' || psproduc
             || '    AND (sgc.ccausin<>1 OR (sgc.ccausin=1 AND (' || n_cas || '=2 OR ('
             || n_cas || '=0 AND sgc.CMOTSIN=0) OR (' || n_cas || '=1 AND sgc.cmotsin<>0))))'
             || 'UNION ' || 'SELECT DISTINCT sgc.cmotsin,  sdm.tmotsin '
             || '  FROM sin_gar_causa sgc, sin_desmotcau sdm' || ' WHERE sdm.cidioma = '
             || pac_md_common.f_get_cxtidioma() || '   AND sgc.cactivi = 0'
             || '   AND NOT EXISTS (SELECT 1 FROM sin_gar_causa WHERE sproduc = sgc.sproduc AND cactivi = '
             || pcactivi || ')' || '   AND sgc.ccausin = ' || pccausa
             || '   AND sgc.ccausin = sdm.ccausin ' || '   AND sgc.cmotsin = sdm.cmotsin '
             || '   AND sgc.sproduc = ' || psproduc
             || '    AND (sgc.ccausin<>1 OR (sgc.ccausin=1 AND (' || n_cas || '=2 OR ('
             || n_cas || '=0 AND sgc.CMOTSIN=0) OR (' || n_cas || '=1 AND sgc.cmotsin<>0))))'
             || ' ORDER BY cmotsin',
             mensajes);
      vpasexec := 3;
      -- vcursor := pac_md_listvalores.f_opencursor(vsquery, mensajes);
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
   END f_get_motivossini;

/*************************************************************************
   FUNCTION f_get_tiptrami
   Recupera els tipus de tramitacions d'un determinat producte
   param in psseguro  : codi del seguro
   param in pcactivi  : codi de l'activitat
   param in pccausin  : codi de la causa del sinistre
   param in pmotsin   : codi de motiu del sinistre
   param in psproduc  : codi del producte
   param in pmodo     : mode 'ALTA' o 'MODIF' del siniestre
   param in pcestsin  : estado del siniestro.
   param out mensajes : missatges d'error
   return             : refcursor

   Bug 15153 - 28/06/2010 - AMC - Se añade el parametro pmodo
   CONF-513  - 20/12/2016 - OGQ - Se añade el parametro pcestsin
*************************************************************************/
   FUNCTION f_get_tiptrami(
      psseguro IN NUMBER,
      pcactivi IN NUMBER,
      pccausin IN NUMBER,
      pmotsin IN NUMBER,
      psproduc IN NUMBER,
      pmodo IN VARCHAR2,
      pctramte IN NUMBER,
      pcestsin IN NUMBER DEFAULT NULL,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                        := 'paràmetres - psproduc: ' || psproduc || ' - pcactivi:' || pcactivi;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_tiptrami';
      vsquery        VARCHAR2(2000);
      vparemp        parempresas.nvalpar%TYPE;--OGQ CONF-513
   BEGIN
      IF psproduc IS NULL
         AND pcactivi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      vsquery := 'SELECT DISTINCT dest.ctramit,  dest.ttramit, codt.ctiptra, codt.ctcausin'
                 || ' FROM SIN_DESTRAMITACION dest, SIN_CODTRAMITACION codt'
                 || ' where dest.ctramit = codt.ctramit' || ' AND dest.cidioma = '
                 || pac_md_common.f_get_cxtidioma() || ' and dest.ctramit IN ('
                 || ' SELECT CTRAMIT FROM SIN_PRO_TRAMITACION WHERE SPRODUC =' || psproduc
                 || ' AND CACTIVI = ' || pcactivi || ' AND CTRAMTE = ' || NVL(pctramte, 0)
                 || ' )';

      -- Bug 15153 - 28/06/2010 - AMC
      IF pmodo <> 'MOD'
         AND pmodo <> 'CONS' THEN
         -- Bug 14953 - 11/06/2010 - AMC
         vsquery := vsquery || 'AND dest.ctramit NOT IN (SELECT st.ctramit'
                    || ' FROM sin_tramitacion st,sin_siniestro si'
                    || ' WHERE st.nsinies = si.nsinies' || ' AND si.sseguro = ' || psseguro
                    || ' AND st.ctramit = 0)';
      --Fi Bug 14953 - 11/06/2010 - AMC
      END IF;
      --Ini CONF-513 OGQ
      vparemp := pac_parametros.f_parempresa_n(f_empres,'TRAM_COMUNI');
      --
      IF vparemp = 1 AND pcestsin is not null THEN
         vsquery := vsquery || 'AND codt.ctramit NOT IN ( SELECT nvalpar FROM parempresas WHERE '
                            || 'cempres = ' || f_empres || ' AND cparam = TO_CHAR('|| pcestsin ||')) ';

      END IF;
      --Fin CONF-513 OGQ

      -- Fi Bug 15153 - 28/06/2010 - AMC
      vsquery := vsquery || ' ORDER BY dest.ttramit';

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      /*
       cur :=
          pac_md_listvalores.f_opencursor
             ('SELECT DISTINCT dest.ctramit,  dest.ttramit, codt.ctiptra '
              || ' FROM SIN_DESTRAMITACION dest, SIN_CODTRAMITACION codt, SIN_PRO_TRAMITACION prot
                     WHERE prot.sproduc = '
              || psproduc || '  AND prot.cactivi = ' || pcactivi
              || '   AND codt.ctramit = prot.ctramit'
              || '   AND dest.ctramit = codt.ctramit
                     AND dest.cidioma = ' || pac_md_common.f_get_cxtidioma()
              || 'ORDER BY dest.ttramit',
              mensajes);*/
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
   END f_get_tiptrami;

/*************************************************************************
   FUNCTION f_get_tcompania
   Recupera els tipus de tramitacions d'un determinat producte
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_tcompania(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres:';
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_tcompania';
   BEGIN
      vpasexec := 2;
      cur :=
         pac_md_listvalores.f_opencursor
                                 ('SELECT ccompani, tcompani '
                                  || ' FROM COMPANIAS WHERE (ctipcom = 0 or ctipcom is null)'
                                  -- 18.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos  - Inicio
                                  || ' AND (fbaja IS NULL OR fbaja > f_sysdate) '
                                  -- 18.0 - 15/10/2013 - MMM - 0025502 - Nota 0155491 - LCOL_T020-Qtracker: 0005655: Validacion campos pantalla facultativos  - Fin
                                  || 'ORDER BY tcompani',
                                  mensajes);
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
   END f_get_tcompania;

/*************************************************************************
   FUNCTION f_get_cunitra
   Recupera les unitats tramitadores amb les seves descripcions
   param in pcempres  : codi empresa
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_cunitra(pcempres IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'paràmetres - pcempres: ' || pcempres;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_cunitra';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT DISTINCT codt.ctramitad, codt.ttramitad'
             || ' FROM sin_codtramitador codt, sin_redtramitador redt
                WHERE redt.cempres = '
             || pcempres
             || ' AND redt.ctiptramit = 2'   -- descomentamos esta linea 22945:ASN:23/07/2012
             || ' AND redt.fmovini <= f_sysdate
             AND (redt.fmovfin IS NULL OR redt.fmovfin > f_sysdate)
             AND codt.ctramitad = redt.ctramitad
             AND NVL(codt.fbaja, f_sysdate) >= f_sysdate',   --BUG 29045:NSS:22/11/2013
             mensajes);
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
   END f_get_cunitra;

/*************************************************************************
   FUNCTION f_get_ctramitad
   Recupera els tramidors amb les seves descripcions
   param in pcempres  : codi empresa
   param in pctramitpad  : codi tramitador pare
   param out mensajes : missatges d'error
   return             : refcursor
*************************************************************************/
   FUNCTION f_get_ctramitad(
      pcempres IN NUMBER,
      pctramitpad IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
                  := 'paràmetres - pcempres: ' || pcempres || ' - pctramitpad:' || pctramitpad;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_ctramitad';
   BEGIN
      IF pcempres IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      cur :=
         pac_md_listvalores.f_opencursor
            ('SELECT DISTINCT codt.ctramitad, codt.ttramitad'
             || ' FROM sin_codtramitador codt, sin_redtramitador redt
             WHERE redt.cempres = '
             || pcempres
             || ' AND redt.ctiptramit > (select max(ctiptramit) from sin_redtramitador where ctramitad = '''
             || pctramitpad || ''' and cempres = ' || pcempres
             || ')
             AND TRUNC(redt.fmovini) <= F_SYSDATE
             AND (TRUNC(redt.fmovfin) IS NULL OR TRUNC(redt.fmovfin)>= F_SYSDATE)
             AND codt.ctramitad = redt.ctramitad
             AND NVL(codt.fbaja, f_sysdate) >= f_sysdate '   --BUG 29045:NSS:22/11/2013
             || ' START WITH redt.ctramitad = ''' || pctramitpad
             || '''
             CONNECT BY PRIOR  redt.ctramitad = ctramitpad',
             mensajes);
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
   END f_get_ctramitad;

/*************************************************************************
       Recupera las actividades profesionales
       param out mensajes : mensajes de error
       return : ref cursor

          30/03/2009   XPL                 Sinistres.  Bug: 9020
*************************************************************************/
   FUNCTION f_get_lstcactprof(mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.F_Get_lstcactprof';
      terror         VARCHAR2(200) := 'Error recuperar lstcactprof';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor
            ('select cactpro, tactpro
                           from activiprof
                           where  cidioma = '
             || pac_md_common.f_get_cxtidioma || ' order by TACTPRO',
             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcactprof;

      /*************************************************************************
          Recupera las Causas Siniestro de sin_codmotcau
          param out mensajes : mensajes de error
          return : ref cursor

          20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstcassin_codmotcau(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcassin_codmotcau';
      terror         VARCHAR2(200) := 'Error recuperar LSTCASSIN_CODMOTCAU';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor
                          ('SELECT distinct sdmc.ccausin, sdc.tcausin'
                           || ' FROM sin_desmotcau sdmc, sin_descausa sdc, sin_gar_causa sgc'
                           || ' WHERE sdmc.ccausin = sdc.ccausin'
                           || ' AND sdmc.cidioma = sdc.cidioma'
                           || ' AND sgc.ccausin = sdmc.ccausin' || ' AND sdmc.cidioma = '
                           || pac_md_common.f_get_cxtidioma() || ' ORDER BY sdmc.ccausin',
                           mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcassin_codmotcau;

   /*************************************************************************
       Recupera los Motivos Siniestro de sin_codmotcau
       param  in pccausin : código de la causa del siniestro
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmotsin_codmotcau(pccausin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstmotsin_codmotcau';
      terror         VARCHAR2(200) := 'Error recuperar lstmotsin_codmotcau';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT sdmc.cmotsin, sdmc.tmotsin'
                                             || ' FROM sin_desmotcau sdmc, sin_descausa sdc'
                                             || ' WHERE sdmc.ccausin = sdc.ccausin'
                                             || ' AND sdmc.ccausin =' || pccausin
                                             || ' AND sdmc.cidioma = sdc.cidioma'
                                             || ' AND sdmc.cidioma ='
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' ORDER BY sdmc.ccausin',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotsin_codmotcau;

   /*************************************************************************
       Recupera los Motivos Movimientos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmotmovi(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstmotmovi';
      terror         VARCHAR2(200) := 'Error recuperar lstmotmovi';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT c.cmotmov, m.tmotmov'
                                             || ' FROM codimotmov C, motmovseg M'
                                             || ' WHERE c.cactivo = 1' || ' AND m.cidioma ='
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' AND c.cmotmov = m.cmotmov'
                                             || ' ORDER BY c.cmotmov',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotmovi;

   /*************************************************************************
      Recupera los Códigos Movimiento Cuenta Seguro
      param out mensajes : mensajes de error
      return : ref cursor

      20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lstcodctaseguro(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcodctaseguro';
      terror         VARCHAR2(200) := 'Error recuperar lstcodctaseguro';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(83, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcodctaseguro;

   /*************************************************************************
       Recupera los Tipo Destinatario
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lsttipdestinatario(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lsttipdestinatario';
      terror         VARCHAR2(200) := 'Error recuperar lsttipdestinatario';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(328, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipdestinatario;

   /*************************************************************************
       Recupera los Modelos fiscales
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstmodfiscales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstmodfiscales';
      terror         VARCHAR2(200) := 'Error recuperar lstmodfiscales';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(320, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmodfiscales;

   /*************************************************************************
       Recupera los elementos
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstelemento(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstelemento';
      terror         VARCHAR2(200) := 'Error recuperar lstelemento';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT ccampo, tcampo' || ' FROM codcampo'
                                             || ' WHERE cutili = 2' || ' ORDER BY ccampo',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstelemento;

   /*************************************************************************
       Recupera las formulas
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstformula(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstformula';
      terror         VARCHAR2(200) := 'Error recuperar lstformula';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT clave, descripcion'
                                             || ' FROM sgt_formulas'
                                             || ' where NVL(cutili,2) = 2',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstformula;

   /*************************************************************************
       Recupera las causas y motivos por producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstproductossin(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.lstproductossin';
      terror         VARCHAR2(200) := 'Error recuperar lstproductossin';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor('SELECT DISTINCT sgc.sproduc, t.ttitulo'
                                         || ' FROM sin_gar_causa sgc,sin_causa_motivo scm,'
                                         || ' productos p, titulopro t, codiram c'
                                         || ' WHERE scm.ccausin = sgc.ccausin'
                                         || ' AND scm.cmotsin = sgc.cmotsin'
                                         || ' AND p.sproduc = sgc.sproduc'
                                         || ' AND t.cramo = p.cramo'
                                         || ' AND t.cmodali = p.cmodali'
                                         || ' AND t.ctipseg = p.ctipseg'
                                         || ' AND t.ccolect = p.ccolect' || ' AND t.cidioma ='
                                         || pac_md_common.f_get_cxtidioma()
                                         || ' AND c.CEMPRES ='
                                         || pac_md_common.f_get_cxtempresa()
                                         || ' AND c.CRAMO = p.CRAMO ' || ' ORDER BY t.ttitulo',
                                         mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstproductossin;

   /*************************************************************************
       Recupera las actividades del producto escogido
       param in psproduc : código del producto
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstactiviprodsin(psproduc IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstactiviprodsin';
      terror         VARCHAR2(200) := 'Error recuperar lstproductossin';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor('SELECT ap.cactivi, ac.ttitulo'
                                         || ' FROM activiprod ap,activisegu ac,productos p'
                                         || ' WHERE ac.cidioma ='
                                         || pac_md_common.f_get_cxtidioma()
                                         || ' AND ac.cramo = ap.cramo'
                                         || ' AND ap.cactivi = ac.cactivi'
                                         || ' AND ap.cramo = p.cramo'
                                         || ' AND ap.cmodali = p.cmodali'
                                         || ' AND ap.ctipseg = p.cmodali'
                                         || ' AND ap.ccolect = p.ccolect'
                                         || ' AND p.sproduc = ' || psproduc
                                         || ' ORDER BY ap.cactivi',
                                         mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstactiviprodsin;

   /*************************************************************************
       Recupera las garantias del producto y actividad escogidos
       param in psproduc : código del producto
       param in pcactivi : código de la actividad
       param out mensajes : mensajes de error
       return : ref cursor

       20/05/2009   AMC                 Sinistres.  Bug: 8816
    *************************************************************************/
   FUNCTION f_get_lstgaransin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstgaransin';
      terror         VARCHAR2(200) := 'Error recuperar lstgaransin';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT gp.cgarant, gg.tgarant'
                                             || ' FROM garanpro gp, garangen gg'
                                             || ' WHERE gg.cgarant = gp.cgarant'
                                             || ' AND gg.cidioma = '
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' AND gp.sproduc = ' || psproduc
                                             || ' AND gp.cactivi = ' || pcactivi || ' UNION'
                                             || ' SELECT gp.cgarant, gg.tgarant'
                                             || ' FROM garanpro gp,garangen gg'
                                             || ' WHERE gg.cgarant = gp.cgarant'
                                             || ' AND gg.cidioma = '
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' AND gp.sproduc = ' || psproduc
                                             || ' AND gp.cactivi = 0'
                                             || ' AND NOT EXISTS (SELECT 1'
                                             || ' FROM garanpro gp' || ' WHERE gp.sproduc = '
                                             || psproduc || ' AND gp.cactivi = ' || pcactivi
                                             || ')',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstgaransin;

     /*************************************************************************
      Recupera las garantias del producto y actividad escogidos
      param in psproduc : código del producto
      param in pcactivi : código de la actividad
      param in pcgarant : código de la garantia
      param out mensajes : mensajes de error
      return : ref cursor

      20/05/2009   AMC                 Sinistres.  Bug: 8816
   *************************************************************************/
   FUNCTION f_get_lsttramisin(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pcgarant IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lsttramisin';
      terror         VARCHAR2(200) := 'Error recuperar lsttramisin';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor
                                   ('SELECT sdt.ctramit, sdt.ttramit'
                                    || ' FROM sin_gar_tramitacion sgt,sin_destramitacion sdt'
                                    || ' WHERE sgt.ctramit = sdt.ctramit'
                                    || ' AND sdt.cidioma =' || pac_md_common.f_get_cxtidioma
                                                                                            ()
                                    || ' AND sgt.sproduc = ' || psproduc
                                    || ' AND sgt.cactivi = ' || pcactivi
                                    || ' AND sgt.cgarant = ' || pcgarant || ' UNION'
                                    || ' SELECT sdt.ctramit, sdt.ttramit'
                                    || ' FROM sin_gar_tramitacion sgt,sin_destramitacion sdt'
                                    || ' WHERE sgt.ctramit = sdt.ctramit'
                                    || ' AND sdt.cidioma = '
                                    || pac_md_common.f_get_cxtidioma()
                                    || ' AND sgt.sproduc = ' || psproduc
                                    || ' AND sgt.cactivi = 0' || ' AND sgt.cgarant = '
                                    || pcgarant || ' AND NOT EXISTS (SELECT 1'
                                    || ' FROM sin_gar_tramitacion' || ' WHERE sproduc = '
                                    || psproduc || ' AND cactivi = ' || pcactivi
                                    || ' AND cgarant = ' || pcgarant || ')',
                                    mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttramisin;

   /*************************************************************************
      Recupera los estados de las causas de un siniestro
      param in pcestsin : código estado
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 10211
   *************************************************************************/
   FUNCTION f_get_lstestado(pcestsin IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstestado';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstestado';
   BEGIN
      -- Bug 12573 - 05/01/2010 - AMC - Se añade la join sc.cestsin = sd.cestsin
      cur := pac_md_listvalores.f_opencursor('SELECT sc.ccauest, sd.tcauest'
                                             || ' FROM sin_codcauest sc, sin_descauest sd'
                                             || ' WHERE sc.ccauest = sd.ccauest'
                                             || ' AND sc.cestsin = sd.cestsin'
                                             || ' AND sc.cestsin = ' || pcestsin
                                             || ' AND sd.cidioma ='
                                             || pac_md_common.f_get_cxtidioma(),
                                             mensajes);
      -- Fi Bug 12573 - 05/01/2010 - AMC
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestado;

   /*************************************************************************
      Recupera la lista de causas
      param out mensajes : mensajes de error
      return : ref cursor

      29/07/2009   XVM                 Sinistres.  Bug: 8820
   *************************************************************************/
   FUNCTION f_get_lstcausas(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstestado';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstestado';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT sdc.ccauest, sdc.tcauest'
                                             || ' FROM sin_codcauest scc, sin_descauest sdc'
                                             || ' WHERE scc.ccauest = sdc.ccauest'
                                             || ' AND sdc.cidioma = '
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' ORDER BY sdc.tcauest',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcausas;

    /*************************************************************************
   FUNCTION f_get_lstcdocume
       Recupera codi del document i el títol del document
      param out mensajes : missatges d'error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcdocume(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcdocume';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstcdocume';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT CDOCUME, TTITDOC'
                                             || ' FROM DOC_DESDOCUMENTO '
                                             || ' WHERE CIDIOMA = '
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' ORDER BY TTITDOC',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcdocume;

    /*************************************************************************
   FUNCTION f_get_lstesttra
      Recupera llista estats tramitació
      param in  pcesttra : estado tramitación
      param out mensajes : mensajes de error
      return             : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstesttra(pcesttra IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstesttra';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstesttra';
   BEGIN
      -- Bug 14722 - 26/05/2010 - AMC
      IF pcesttra = 0 THEN
         cur := pac_md_listvalores.f_opencursor('SELECT catribu, tatribu '
                                                || ' FROM DETVALORES ' || ' WHERE CIDIOMA = '
                                                || pac_md_common.f_get_cxtidioma()
                                                || ' AND cvalor = 930 '-- JGONZALEZ se cambia cvalor=6
                                                || ' AND catribu IN (0,1,2,3)'
                                                || ' ORDER BY catribu',
                                                mensajes);
      ELSIF pcesttra = 1 THEN
         cur := pac_md_listvalores.f_opencursor('SELECT catribu, tatribu '
                                                || ' FROM DETVALORES ' || ' WHERE CIDIOMA = '
                                                || pac_md_common.f_get_cxtidioma()
                                                || ' AND cvalor = 930 '-- JGONZALEZ se cambia cvalor=6
                                                || ' AND catribu in(1,4) '
                                                || ' ORDER BY catribu',
                                                mensajes);
      ELSIF pcesttra = 2 THEN
         cur := pac_md_listvalores.f_opencursor('SELECT catribu, tatribu '
                                                || ' FROM DETVALORES ' || ' WHERE CIDIOMA = '
                                                || pac_md_common.f_get_cxtidioma()
                                                || ' AND cvalor = 930 ' || ' AND catribu = 2 '-- JGONZALEZ se cambia cvalor=6
                                                || ' ORDER BY catribu',
                                                mensajes);
      ELSIF pcesttra = 3 THEN
         cur := pac_md_listvalores.f_opencursor('SELECT catribu, tatribu '
                                                || ' FROM DETVALORES ' || ' WHERE CIDIOMA = '
                                                || pac_md_common.f_get_cxtidioma()
                                                || ' AND cvalor = 930 ' || ' AND catribu = 3 '-- JGONZALEZ se cambia cvalor=6
                                                || ' ORDER BY catribu',
                                                mensajes);
      ELSIF pcesttra = 4 THEN
         cur := pac_md_listvalores.f_opencursor('SELECT catribu, tatribu '
                                                || ' FROM DETVALORES ' || ' WHERE CIDIOMA = '
                                                || pac_md_common.f_get_cxtidioma()
                                                || ' AND cvalor = 930 '-- JGONZALEZ se cambia cvalor=6
                                                || ' AND catribu IN (1,2,3,4) '
                                                || ' ORDER BY catribu',
                                                mensajes);
      END IF;

      -- Fi Bug 14722 - 26/05/2010 - AMC
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstesttra;

   /*************************************************************************
    Función f_get_lsteventos
    Recupera el listado de eventos
    param out mensajes   : mensajes de error
    return              : sys_refcursor
   *************************************************************************/
   FUNCTION f_get_lsteventos(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000);
      vobject        VARCHAR2(200) := 'PAC_MD_EVENTOS_SIN.f_get_lsteventos';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstesttra';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('SELECT sde.cevento, sde.ttiteve'
                                             || ' FROM sin_codevento sce,'
                                             || ' sin_desevento sde'
                                             || ' WHERE sce.cevento = sde.cevento'
                                             || ' AND sde.cidioma = '
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' ORDER BY sde.cevento',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsteventos;

   /*************************************************************************
    Función f_get_lsttipdes
    Recupera el listado de los tipos de destinatarios
    param in psproduc : código del producto
    param in pcactivi : codigo de la actividad
    param in pctramit : código del tipo de tramitación
    param in pccausin : código de la causa del siniestro
    param in pcmotsin : código del motivo del siniestro
    param in psseguro : código de seguro
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 12605 - 14/01/2010- AMC
   *************************************************************************/
   FUNCTION f_get_listtipdes(
      psproduc IN NUMBER,
      pcactivi IN NUMBER,
      pctramit IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin IN NUMBER,
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psproduc=' || psproduc || ' pcactivi=' || pcactivi || ' pctramit=' || pctramit
            || ' pccausin=' || pccausin || ' pcmotsin=' || pcmotsin || ' psseguro='
            || psseguro;
      vobject        VARCHAR2(50) := 'PAC_MD_LISTVALORES_SIN.f_get_listtipdes';
      vcursor        sys_refcursor;
   BEGIN
      IF psproduc IS NULL
         OR pcactivi IS NULL
         OR pctramit IS NULL
         OR pccausin IS NULL
         OR pcmotsin IS NULL
         OR psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- Bug 34496 - XBA - 03/02/2015 - MSV - Modifications in manual pledge
      -- Si la poliza está pignorada (o bloqueada), el beneficiario del siniestro debe ser el beneficiario de la pignoración.
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                           'FORZAR_BENEF_PIGNO'),
             0) = 1
         AND f_bloquea_pignorada(psseguro, f_sysdate) <> 0 THEN
         vcursor := pac_md_listvalores.f_opencursor(' SELECT dv.catribu, dv.tatribu'
                                                    || ' FROM DETVALORES dv'
                                                    || ' WHERE dv.cvalor = 10'
                                                    || ' AND dv.cidioma = '
                                                    || pac_md_common.f_get_cxtidioma()
                                                    || ' AND dv.catribu = 50 ',
                                                    mensajes);
      ELSE
         -- bug 16832 - 20/01/2011 - AMC
         vcursor :=
            pac_md_listvalores.f_opencursor
                            (' SELECT dv.catribu, dv.tatribu' || ' FROM DETVALORES dv'
                             || ' WHERE dv.cvalor = 10' || ' AND dv.cidioma = '
                             || pac_md_common.f_get_cxtidioma()
                             || ' AND NOT EXISTS (SELECT 1 '
                             || ' FROM SIN_GAR_CAUSA_MOTIVO sgcm, SIN_DET_CAUSA_MOTIVO sdcm'
                             || ' WHERE sgcm.sproduc =' || psproduc
                             || ' AND sgcm.cactivi IN(0,' || pcactivi || ')'
                             || ' AND sgcm.ctramit =' || pctramit
                             || ' AND sgcm.scaumot = sdcm.scaumot )' || ' UNION'
                             || ' SELECT distinct sdcm.ctipdes catribu, dv.tatribu'
                             || ' FROM SIN_DET_CAUSA_MOTIVO sdcm, SIN_CAUSA_MOTIVO scm,'
                             || ' SIN_GAR_CAUSA_MOTIVO sgcm, DETVALORES dv'
                             || ' WHERE sdcm.scaumot = scm.scaumot' || ' AND scm.ccausin = '
                             || pccausin || ' AND scm.cmotsin = ' || pcmotsin
                             || ' AND dv.catribu = sdcm.ctipdes' || ' AND dv.cidioma = '
                             || pac_md_common.f_get_cxtidioma() || ' AND dv.cvalor = 10'
                             || ' AND sgcm.scaumot = scm.scaumot' || ' AND sgcm.sproduc ='
                             || psproduc || ' AND sgcm.cactivi =' || pcactivi
                             || ' AND sgcm.cactivi <> 0' || ' AND sgcm.ctramit =' || pctramit
                             || ' UNION'
                             || ' SELECT distinct sdcm.ctipdes catribu, dv.tatribu'
                             || ' FROM SIN_DET_CAUSA_MOTIVO sdcm, SIN_CAUSA_MOTIVO scm,'
                             || ' SIN_GAR_CAUSA_MOTIVO sgcm, DETVALORES dv'
                             || ' WHERE sdcm.scaumot = scm.scaumot' || ' AND scm.ccausin = '
                             || pccausin || ' AND scm.cmotsin = ' || pcmotsin
                             || ' AND dv.catribu = sdcm.ctipdes' || ' AND dv.cidioma = '
                             || pac_md_common.f_get_cxtidioma() || ' AND dv.cvalor = 10'
                             || ' AND sgcm.scaumot = scm.scaumot' || ' AND sgcm.sproduc = '
                             || psproduc || ' AND sgcm.cactivi = 0'
                             || ' AND NOT EXISTS (SELECT 1'
                             || ' FROM SIN_GAR_CAUSA_MOTIVO sgcm2,SIN_DET_CAUSA_MOTIVO sdcm2'
                             || ' WHERE sgcm2.scaumot = sgcm.scaumot'
                             || ' AND sgcm2.sproduc = sgcm.sproduc' || ' AND sgcm2.cactivi = '
                             || pcactivi || ' AND sgcm2.cactivi <> 0'
                             || ' AND sgcm2.scaumot = sdcm2.scaumot)'
                             || ' AND sgcm.ctramit = ' || pctramit,
                             mensajes);
      END IF;

      -- Fi bug 16832 - 20/01/2011 - AMC
      IF vcursor IS NULL THEN
         RAISE e_object_error;
      END IF;

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
   END f_get_listtipdes;

   /*************************************************************************
    Función f_get_lsctestmov
    Recupera el listado del estado del pago dependiendo del estado anterior
    param in pestvalant : Estado de la validacion anterior
    param in pestpagant : Estado del pago anterior
    param in pestval: Estado de la validacion actual
    param out mensajes   : mensajes de error
    return              : sys_refcursor

    -- Bug 13312 - 05/03/2010 - AMC
   *************************************************************************/
   FUNCTION f_get_lsctestmov(
      pestvalant IN NUMBER,
      pestpagant IN NUMBER,
      pestval IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'pestvalant=' || pestvalant || ' pestpagant=' || pestpagant || ' pestval='
            || pestval;
      vobject        VARCHAR2(50) := 'PAC_MD_LISTVALORES_SIN.f_get_lsctestmov';
      vcursor        sys_refcursor;
   BEGIN
      IF pestvalant IS NULL
         OR pestpagant IS NULL
         OR pestval IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- "Pendiente de Validar" & "Pendiente"
      IF pestvalant = 0
         AND pestpagant = 0 THEN
         IF pestval = 1 THEN
            vcursor :=
               pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                               || ' where cidioma ='
                                               || pac_md_common.f_get_cxtidioma()
                                               || ' and cvalor= 3'
                                               || ' and catribu in (0,1,2)',
                                               mensajes);

            IF vcursor IS NULL THEN
               p_tab_error(f_sysdate, f_user, 'pac_md_listvalores_sin', 1, 'error:', SQLERRM);
               RAISE e_object_error;
            END IF;
         ELSIF pestval = 0 THEN
            vcursor :=
               pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                               || ' where cidioma ='
                                               || pac_md_common.f_get_cxtidioma()
                                               || ' and cvalor= 3' || ' and catribu = 8',
                                               mensajes);

            IF vcursor IS NULL THEN
               RAISE e_object_error;
            END IF;
         END IF;
      -- "Validado" & "Pendiente"
      ELSIF pestvalant = 1
            AND pestpagant = 0 THEN
         IF pestval = 1 THEN
            vcursor :=
               pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                               || ' where cidioma ='
                                               || pac_md_common.f_get_cxtidioma()
                                               || ' and cvalor= 3'
                                               || ' and catribu in (1,2,8)',
                                               mensajes);

            IF vcursor IS NULL THEN
               RAISE e_object_error;
            END IF;
         END IF;
      -- "Validado" & "Aceptado"
      ELSIF pestvalant = 1
            AND pestpagant = 1 THEN
         IF pestval = 1 THEN
            vcursor :=
               pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                               || ' where cidioma ='
                                               || pac_md_common.f_get_cxtidioma()
                                               || ' and cvalor= 3' || ' and catribu in (2,8)',
                                               mensajes);

            IF vcursor IS NULL THEN
               RAISE e_object_error;
            END IF;
         END IF;
      -- "Validado" & "Pagado"
      ELSIF pestvalant = 1
            AND pestpagant = 2 THEN
         IF pestval = 1 THEN
            vcursor :=
               pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                               || ' where cidioma ='
                                               || pac_md_common.f_get_cxtidioma()
                                               || ' and cvalor= 3' || ' and catribu = 0',
                                               mensajes);

            IF vcursor IS NULL THEN
               RAISE e_object_error;
            END IF;
         END IF;
      -- "Validado" & "Anulado"
      ELSIF pestvalant = 1
            AND pestpagant = 8 THEN
         -- No se puede modificar
         RETURN NULL;
      ELSIF pestvalant = 1
            AND pestpagant = 9 THEN   --Solo se permite anular
            -- BUG 17247-  02/2011 - JRH  - 0017247: Envio pagos SAP
         --IF pestval = 1 THEN
         vcursor :=
            pac_md_listvalores.f_opencursor('select catribu,tatribu from detvalores '
                                            || ' where cidioma ='
                                            || pac_md_common.f_get_cxtidioma()
                                            || ' and cvalor= 3' || ' and catribu = 8',
                                            mensajes);

         IF vcursor IS NULL THEN
            RAISE e_object_error;
         END IF;
         -- BUG 17247-  02/2011 - JRH
      --END IF;
      END IF;

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
   END f_get_lsctestmov;

   -- Bug 0015669 - JRH - 30/09/2010 - Alta prestaciones

   /*************************************************************************
    Función f_get_lstEstadoPrest
    Recupera el listado de estados de una prestación
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstestadoprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstestadoprest';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstestadoprest';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(1011, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestadoprest;

   /*************************************************************************
     Función f_get_lstEstPagosPrest
     Recupera el listado de estado de pagos de una prestación
     param out mensajes   : mensajes de error
     return              : sys_refcursor


    *************************************************************************/
   FUNCTION f_get_lstestpagosprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstestpagosprest';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstestpagosprest';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(230, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstestpagosprest;

/*************************************************************************
    Función f_get_lstprofesionales
    Recupera a los profesionales
       param out mensajes : mensajes de error
       return : ref cursor

       29/05/2012   JLTS                 Sinistres.  Bug: 21838
   *************************************************************************/
   FUNCTION f_get_lstprofesionales(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstprofesionales';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstprofesionales';
   BEGIN
      cur :=
         pac_md_listvalores.f_opencursor
                                   ('select spp.sprofes, f_nombre (spp.sperson,1) nombre '
                                    || ' from SIN_PROF_PROFESIONALES spp',
                                    mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstprofesionales;

   /*************************************************************************
      Función f_get_lstDurPrest
      Recupera el listado de duraciones de prestación
      param out mensajes   : mensajes de error
      return              : sys_refcursor


     *************************************************************************/
   FUNCTION f_get_lstdurprest(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstdurprest';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstdurprest';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(1010, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstdurprest;

   /*************************************************************************
      Función f_get_lstTipCap
      Recupera el listado de formas de pago de prestación
      param in  pnsinies   : siniestro -- Bug 0017970 - 16/03/2011 - JMF
      param out mensajes   : mensajes de error
      return              : sys_refcursor


     *************************************************************************/
   FUNCTION f_get_lsttipcap(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pnsinies=' || pnsinies;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lsttipcap';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lsttipcap';
      -- Bug 0017970 - 16/03/2011 - JMF
      v_ccausin      sin_siniestro.ccausin%TYPE;
      v_cmotsin      sin_siniestro.cmotsin%TYPE;
      v_sseguro      sin_siniestro.sseguro%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_cfprest      seguros_aho.cfprest%TYPE;

      -- Bug 18670 - APD - 16/06/2011 - se crea la subfuncion f_get_prestaciones
      -- para recuperar de la tabla FPRESTAPROD todas las posibles formas de prestacion
      FUNCTION f_get_prestaciones(
         psproduc IN NUMBER,
         pccausin IN NUMBER,
         pcmotsin IN NUMBER,
         pcgarant IN NUMBER)
         RETURN VARCHAR2 IS
         v_var          VARCHAR2(2000) := NULL;
         v_hayregistros BOOLEAN := FALSE;
      BEGIN
         FOR reg IN (SELECT ctippres
                       FROM fprestaprod
                      WHERE sproduc = psproduc
                        AND ccausin = pccausin
                        AND cmotsin = pcmotsin
                        AND cgarant = pcgarant) LOOP
            IF v_var IS NULL THEN
               v_var := reg.ctippres;
            ELSE
               v_var := v_var || ',' || reg.ctippres;
            END IF;

            v_hayregistros := TRUE;
         END LOOP;

         IF NOT v_hayregistros THEN
            FOR reg IN (SELECT ctippres
                          FROM fprestaprod
                         WHERE sproduc = psproduc
                           AND ccausin = pccausin
                           AND cmotsin = pcmotsin
                           AND cgarant IS NULL) LOOP
               IF v_var IS NULL THEN
                  v_var := reg.ctippres;
               ELSE
                  v_var := v_var || ',' || reg.ctippres;
               END IF;

               v_hayregistros := TRUE;
            END LOOP;
         END IF;

         IF NOT v_hayregistros THEN
            FOR reg IN (SELECT ctippres
                          FROM fprestaprod
                         WHERE sproduc = psproduc
                           AND ccausin = pccausin
                           AND cmotsin IS NULL
                           AND cgarant IS NULL) LOOP
               IF v_var IS NULL THEN
                  v_var := reg.ctippres;
               ELSE
                  v_var := v_var || ',' || reg.ctippres;
               END IF;

               v_hayregistros := TRUE;
            END LOOP;
         END IF;

         IF NOT v_hayregistros THEN
            FOR reg IN (SELECT ctippres
                          FROM fprestaprod
                         WHERE sproduc = psproduc
                           AND ccausin IS NULL
                           AND cmotsin IS NULL
                           AND cgarant IS NULL) LOOP
               IF v_var IS NULL THEN
                  v_var := reg.ctippres;
               ELSE
                  v_var := v_var || ',' || reg.ctippres;
               END IF;

               v_hayregistros := TRUE;
            END LOOP;
         END IF;

         RETURN v_var;
      END f_get_prestaciones;
   -- Fin Bug 18670 - APD - 16/06/2011
   BEGIN
      -- Bug 0017970 - 16/03/2011 - JMF
      vpasexec := 10;

      SELECT a.ccausin, a.cmotsin, a.sseguro, b.sproduc
        INTO v_ccausin, v_cmotsin, v_sseguro, v_sproduc
        FROM sin_siniestro a, seguros b
       WHERE a.nsinies = pnsinies
         AND b.sseguro = a.sseguro;

      vpasexec := 15;

      IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'PRESTACION'), 0) = 1 THEN
         vpasexec := 20;

         -- Bug 18670 - APD - 20/06/2011 -
         -- se añaden los motivos 3, 5, 28 y 29
         IF v_ccausin = 1
            AND v_cmotsin IN(0, 1, 2, 9, 3, 5, 28, 29) THEN
            -- Fin Bug 18670 - APD - 20/06/2011 -
            vpasexec := 25;

            SELECT MAX(cfprest)
              INTO v_cfprest
              FROM seguros_aho
             WHERE sseguro = v_sseguro;

            vpasexec := 30;

            IF v_cfprest IS NOT NULL THEN
               vpasexec := 35;
               cur :=
                  pac_md_listvalores.f_opencursor
                                                ('select catribu,tatribu from detvalores '
                                                 || ' where cidioma ='
                                                 || pac_md_common.f_get_cxtidioma()
                                                 || ' and cvalor= 205' || ' and catribu = '
                                                 || v_cfprest,
                                                 mensajes);
            ELSE
               vpasexec := 40;
               -- Bug 18670 - APD - 15/06/2011 - las posibles formas de prestación se recuperan
               -- de la subfuncion f_get_prestaciones
/*
               cur :=
                  pac_md_listvalores.f_opencursor
                       ('select catribu,tatribu from detvalores ' || ' where cidioma ='
                        || pac_md_common.f_get_cxtidioma() || ' and cvalor= 205'
                        || ' and catribu in (select ctippres from FPRESTAPROD where sproduc='
                        || v_sproduc || ' )' || ')',
                        mensajes);
*/
               cur :=
                  pac_md_listvalores.f_opencursor
                                                ('select catribu,tatribu from detvalores '
                                                 || ' where cidioma ='
                                                 || pac_md_common.f_get_cxtidioma()
                                                 || ' and cvalor= 205' || ' and catribu in ('
                                                 || f_get_prestaciones(v_sproduc, v_ccausin,
                                                                       v_cmotsin, NULL)
                                                 || ')',
                                                 mensajes);
            -- fin Bug 18670 - APD - 15/06/2011
            END IF;
         ELSE
            vpasexec := 45;
            RETURN cur;
         END IF;
      ELSE
         vpasexec := 50;
         RETURN cur;
      END IF;

      vpasexec := 60;
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttipcap;

   /*************************************************************************
     Función f_get_lstTipRelAse
     Recupera el listado de formas de relación con el asegurados
     param out mensajes   : mensajes de error
     return              : sys_refcursor


    *************************************************************************/
   FUNCTION f_get_lsttiprelase(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lsttiprelase';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lsttiprelase';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(1018, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttiprelase;

   /*************************************************************************
     Función f_get_lstNivelSini
     Recupera el listado de niveles de siniestro
     param out mensajes   : mensajes de error
     return              : sys_refcursor


    *************************************************************************/
   FUNCTION f_get_lstnivelsini(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstnivelsini';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstnivelsini';
   BEGIN
      cur := pac_md_listvalores.f_detvalores(1017, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstnivelsini;

   /*************************************************************************
    Función f_get_lstPersonasCaus
    Recupera el listado de causantes del siniestro
    param in psseguro : Código seguro
    param in pccausin : Causa siniestro
    param in pcmotsin : Motivo siniestro
    param in pcnivel :  Nivel siniestro
    param out mensajes   : mensajes de error
    return              : sys_refcursor


   *************************************************************************/
   FUNCTION f_get_lstpersonascaus(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      pcmotsin NUMBER,
      pcnivel IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
              := 'pccausin=' || pccausin || ' pcmotsin=' || pcmotsin || ' pcnivel=' || pcnivel;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstnivelsini';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstnivelsini';
      vsquery        VARCHAR2(2000);
      vcagente       seguros.cagente%TYPE;
   BEGIN
      SELECT cagente
        INTO vcagente
        FROM seguros s
       WHERE s.sseguro = psseguro;

      IF pccausin = 1
         AND NVL(pcnivel, 1) = 1 THEN
         IF pcmotsin = 1 THEN
            vsquery := ' select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente
                       || ' ) tatribu ' || ' from ' || ' asegurados a ' || ' where sseguro= '
                       || psseguro || ' order by a.norden';
         ELSIF pcmotsin = 4 THEN
            vsquery := ' select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente
                       || ' ) tatribu ' || ' from ' || ' asegurados a ' || ' where sseguro= '
                       || psseguro || ' order by a.norden';
         ELSIF pcmotsin = 12 THEN
            vsquery := ' select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente
                       || ' ) tatribu ' || ' from ' || ' asegurados a ' || ' where sseguro= '
                       || psseguro || ' and a.norden=1 order by a.norden';
         ELSIF pcmotsin = 13 THEN
            vsquery := ' select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente
                       || ' )  tatribu ' || ' from ' || ' asegurados a ' || ' where sseguro= '
                       || psseguro || ' and a.norden=2 order by a.norden';
         ELSE
            vsquery := ' select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente
                       || ' ) tatribu ' || ' from ' || ' asegurados a ' || ' where sseguro= '
                       || psseguro || ' order by a.norden';
         END IF;
      ELSIF pccausin = 1
            AND NVL(pcnivel, 1) > 1 THEN
         vsquery :=
            '   select a.sperson catribu,f_nombre(a.sperson,1, ' || vcagente || ' ) '
            || ' from sin_tramita_destinatario d,sin_siniestro sin,seguros s, asegurados a '
            || ' where ' || ' s.sseguro=' || psseguro || ' '
            || ' and a.sseguro = sin.sseguro and sin.sseguro=s.sseguro and nvl(sin.cnivel,1)< '
            || pcnivel || ' and d.nsinies=sin.nsinies ';
      ELSE
         RETURN NULL;
      END IF;

      cur := pac_md_listvalores.f_opencursor(vsquery, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpersonascaus;

-- Fi Bug 0015669 - JRH - 30/09/2010

   /*************************************************************************
       Recupera los Motivos de Rescate de sin_desmotresccau
       param  in psseguro : identificador del seguro
       param  in pccausin : código de la causa del siniestro
       param out mensajes : mensajes de error
       return : ref cursor
    *************************************************************************/
   -- Bug 18913 - APD - 01/07/2011 - se crea la función
   FUNCTION f_get_lstmotresc(
      psseguro IN NUMBER,
      pccausin IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro - ' || psseguro || '; pccausin - ' || pccausin;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstmotresc';
      terror         VARCHAR2(200) := 'Error recuperar lstmotresc';
      vsproduc       seguros.sproduc%TYPE;
   BEGIN
      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor('SELECT sdmc.cmotresc, sdmc.tmotresc'
                                             || ' FROM sin_desmotresccau sdmc'
                                             || ' WHERE sdmc.ccausin =' || pccausin
                                             || ' AND sdmc.cidioma ='
                                             || pac_md_common.f_get_cxtidioma()
                                             || ' AND (sdmc.sproduc = ' || vsproduc
                                             || '      OR sdmc.sproduc = 0) '
                                             || ' ORDER BY sdmc.cmotresc',
                                             mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstmotresc;

-- Fin Bug 18913 - APD - 01/07/2011

   /*************************************************************************
       Recupera los subtipos de tipos de tramitación (valores dependientes)
       param  in pcempres : Código Empresa
       param  in pctramit : Código Tramitación
       param out mensajes : mensajes de error
       return : ref cursor
       -- BUG 0023536 - 04/10/2012 - JMF
    *************************************************************************/
   FUNCTION f_get_lstsubtiptra(
      pcempres IN NUMBER,
      pctramit IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstsubtiptra';
      vparam         VARCHAR2(200) := 'pcempres=' || pcempres || ' pctramit=' || pctramit;
      vpasexec       NUMBER(2) := 1;
      cur            sys_refcursor;
      v_cvalordep    detvalores_dep.cvalordep%TYPE;
   BEGIN
      vpasexec := 2;

      IF pctramit IS NOT NULL THEN
         vpasexec := 3;

         SELECT MAX(cvalordep)
           INTO v_cvalordep
           FROM detvalores_dep
          WHERE cempres = pcempres
            AND cvalor = 800
            AND catribu = pctramit;

         vpasexec := 4;

         IF v_cvalordep IS NOT NULL THEN
            cur := pac_md_listvalores.f_detvalores_dep(pcempres, 800, pctramit, v_cvalordep,
                                                       mensajes);
         END IF;
      END IF;

      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           'OTHERS', SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsubtiptra;

--Ini BUG 27909:NSS:04/09/2013
   /*************************************************************************
   FUNCTION f_get_lstcconpag
      Recupera concepte pagament
      param  out mensajes : missatges d'error
      return              : ref cursor
   *************************************************************************/
   FUNCTION f_get_lstcconpag(psproduc IN NUMBER DEFAULT NULL, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcconpag';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstcconpag';
   BEGIN
      cur := pac_propio.f_get_lstcconpag(psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcconpag;

   /*************************************************************************
   FUNCTION f_get_lstcconpag_dep
      Recupera concepte pagament (dependiendo del tipo de pago)
      param  in  ctippag  : tipo de pago
      param  out mensajes : missatges d'error
      return              : ref cursor
      bug 21720:ASN:20/03/2012 - creacion
   *************************************************************************/
   FUNCTION f_get_lstcconpag_dep(
      pctippag IN NUMBER,
      psproduc IN NUMBER DEFAULT NULL,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(100) := 'pctippag= ' || pctippag || 'psproduc= ' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcconpag_dep';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstcconpag_dep';
   BEGIN
      cur := pac_propio.f_get_lstcconpag_dep(pctippag, psproduc, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstcconpag_dep;

--Fin BUG 27909:NSS:04/09/2013

   /*************************************************************************
    FUNCTION f_get_lispignorados
        Recupera los beneficiarios de las pignoraciones
        param  in sseguro :
        param out mensajes : mensajes de error
        return : ref cursor
        BUG 27766:
    *************************************************************************/
   FUNCTION f_get_lispignorados(psseguro IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vcursor        VARCHAR2(500);
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lispignorados';
      vagente        NUMBER;
      terror         VARCHAR2(200) := 'Error recuperar los beneficiarios de las pignoraciones';
   BEGIN
      SELECT cagente
        INTO vagente
        FROM seguros
       WHERE sseguro = psseguro;

      vcursor :=
         'SELECT DISTINCT sperson, tnombre, tapelli1, tapelli2
                    FROM per_detper
                    WHERE sperson IN ( SELECT DISTINCT sperson'
         || ' FROM bloqueoseg' || ' WHERE sseguro = ' || psseguro || ' AND cmotmov = 261 '
         || ' AND ffinal IS NULL )';
      cur := pac_md_listvalores.f_opencursor(vcursor, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lispignorados;

   /*************************************************************************
   FUNCTION f_get_beneficiarios_nominales
       Recupera los beneficiarios de las pignoraciones
       param  in sseguro : identificador del seguro
       param  in fsinies : fecha del siniestro
       param out mensajes : mensajes de error
       return : ref cursor
       BUG 27766:
    *************************************************************************/
      FUNCTION f_get_beneficiarios_nominales(
      psseguro IN NUMBER,
      pfsinies IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      ref_cursor     sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vcursor        VARCHAR2(500);
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_beneficiarios_nominales';
      terror         VARCHAR2(200) := 'Error recuperar los beneficiarios nominales';
      vnmovimi       NUMBER(2);
   BEGIN
      SELECT MAX(nmovimi)
        INTO vnmovimi
        FROM movseguro
       WHERE sseguro = psseguro
         AND fefecto < pfsinies;

      IF vnmovimi IS NOT NULL THEN
         vcursor :=
            'SELECT sperson, tnombre, tapelli1, tapelli2
                        FROM per_detper
                        WHERE cidioma = '
            || pac_md_common.f_get_cxtidioma()
            || 'AND cagente = ff_agente_Cpervisio((select cagente from seguros s where s.sseguro = ' --ramiro
            || psseguro || '))' --ramiro
            || ' AND sperson IN ( '
            || ' SELECT DISTINCT sperson FROM benespseg WHERE sseguro = ' || psseguro
            || ' AND nmovimi = ' || vnmovimi || ')';
         ref_cursor := pac_md_listvalores.f_opencursor(vcursor, mensajes);
      END IF;

      RETURN ref_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF ref_cursor%ISOPEN THEN
            CLOSE ref_cursor;
         END IF;

         RETURN ref_cursor;
   END f_get_beneficiarios_nominales;

   /*************************************************************************
   FUNCTION f_get_aseginnominado
       Recupera los asegurados innominados
       param  in pnsinies : identificador del siniestro
       param  in pntramit : identificador del tramite
       param out mensajes : mensajes de error
       return : ref cursor
       BUG 35676:
    *************************************************************************/
   FUNCTION f_get_aseginnominado(
      pnsinies IN NUMBER,
      pntramit IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      ref_cursor     sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vcursor        VARCHAR2(500);
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_aseginnominado';
      terror         VARCHAR2(200) := 'Error recuperar los asegurados innominados';
      vnmovimi       NUMBER(2);
   BEGIN
      vcursor :=
         'SELECT DISTINCT (sperson), tnombre, tapelli1, tapelli2
                    FROM sin_tramita_personasrel
                    WHERE nsinies = '
         || pnsinies
         || '
                    AND ctiprel = 4
                    AND ntramit = ' || pntramit;
      ref_cursor := pac_md_listvalores.f_opencursor(vcursor, mensajes);
      RETURN ref_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF ref_cursor%ISOPEN THEN
            CLOSE ref_cursor;
         END IF;

         RETURN ref_cursor;
   END f_get_aseginnominado;
  FUNCTION f_get_lstgarantias_cap(
      psseguro IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      ref_cursor     sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vcursor        VARCHAR2(2000);
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstgarantias_cap';
      terror         VARCHAR2(200) := 'Error recuperar las garantias del seguro con su capital';
      vnmovimi       NUMBER(2);
   BEGIN
      --IAXIS 4100 AABC cambio de amparos afectados 
      vcursor :=
         'SELECT DISTINCT par.cgarant, par.tgarant, gar.ICAPTOT, ' ||
         ' (SELECT pac_monedas.f_cmoneda_t(p.cdivisa)  FROM productos p, seguros s ' ||
	     ' WHERE  s.sseguro = seg.sseguro   AND p.sproduc = s.sproduc ) CMONEDA ' ||
         '  FROM seguros seg, movseguro mov, garanseg gar, garangen par ' ||
         ' WHERE seg.sseguro = mov.sseguro ' ||
         '   AND gar.sseguro = mov.sseguro ' ||
         '   AND gar.nmovimi = mov.nmovimi ' ||
         '   AND par.cidioma = pac_md_common.f_get_cxtidioma ' ||
         '   AND gar.ffinefe IS NULL ' ||
         '   AND par.cgarant = gar.cgarant ' ||
         '   AND seg.sseguro = '  || psseguro;
      ref_cursor := pac_md_listvalores.f_opencursor(vcursor, mensajes);
      RETURN ref_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF ref_cursor%ISOPEN THEN
            CLOSE ref_cursor;
         END IF;

         RETURN ref_cursor;
  END f_get_lstgarantias_cap;

   FUNCTION f_get_procesos_tramitador(
      pctramitad IN VARCHAR2,
      pctipo IN NUMBER,
      pctramit IN VARCHAR2,
      mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      ref_cursor     sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vcursor        VARCHAR2(2000);
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_procesos_tramitador';
      terror         VARCHAR2(200) := 'Error recuperar procesos del tramitador';
      vnmovimi       NUMBER(2);
   BEGIN

      IF pctipo = 1 THEN
        vcursor :=               '   SELECT c.ctramitad,' ||
              '     c.ttramitad,' ||
              '     (SELECT COUNT(*)' ||
              '        FROM sin_tramita_movimiento m join sin_tramitacion st on m.nsinies=st.nsinies and m.ntramit=st.ntramit' ||
--              '             SIN_TRAMITA_JUDICIAL    p' ||
              '       join sin_movsiniestro  sm on sm.nsinies=m.nsinies
  and sm.CESTSIN not in (1)  and cesttra not in (1)
   WHERE 
    (sm.nsinies,sm.nmovsin) in (select nsinies,max(nmovsin) from sin_movsiniestro group by nsinies)  
    and sm.nsinies in
    (select nsinies from SIN_TRAMITA_JUDICIAL
   union 
   select nsinies from SIN_TRAMITA_FISCAL
   union
   select nsinies from SIN_TRAMITA_LOCALIZA) 
   and (m.nsinies,m.ctramitad ,ctramit) not in ( select m2.nsinies,ctramitad,count(*)*0 from sin_tramitacion m2
    join sin_tramita_movimiento m3 on m2.nsinies=m3.nsinies and m2.ntramit = m3.ntramit  
    AND nmovtra = (SELECT MAX(nmovtra)                          FROM sin_tramita_movimiento ms                    
   WHERE ms.nsinies = m.nsinies                           AND ms.ntramit = m3.ntramit) and  m2.ntramit>0  and cesttra not in (1)
   group by m2.nsinies,ctramitad)
   and m.ctramitad = c.ctramitad' ||
--              '         AND m.nsinies = p.nsinies' ||
--              '         AND m.ntramit = p.ntramit' ||
              '         AND nmovtra = (SELECT MAX(nmovtra)' ||
              '                          FROM sin_tramita_movimiento ms' ||
              '                         WHERE ms.nsinies = m.nsinies' ||
              '                           AND ms.ntramit = m.ntramit)) procesos ' ||
              'FROM (SELECT DISTINCT codt.ctramitad,' ||
              '                     codt.ttramitad' ||
              '       FROM sin_codtramitador codt,' ||
              '            sin_redtramitador redt' ||
              '      WHERE redt.cempres = ' || pac_md_common.f_get_cxtempresa() ||
              '        AND redt.ctiptramit > (SELECT MAX(ctiptramit)' ||
              '                                 FROM sin_redtramitador' ||
              '                                WHERE ctramitad = '||'''' ||pctramitad  ||''''||
              '                                  AND cempres = '|| pac_md_common.f_get_cxtempresa() || ') '||
              '        AND TRUNC(redt.fmovini) <= f_sysdate' ||
              '        AND (TRUNC(redt.fmovfin) IS NULL OR' ||
              '            TRUNC(redt.fmovfin) >= f_sysdate)' ||
              '        AND codt.ctramitad = redt.ctramitad' ||
              '        AND NVL(codt.fbaja, f_sysdate) >= f_sysdate' ||
              '      START WITH redt.ctramitad =''' ||pctramitad  ||''''||
              '     CONNECT BY PRIOR redt.ctramitad = ctramitpad) c ';
      ELSIF pctipo = 2 THEN
        vcursor :=    ' SELECT c.ctramitad,' ||
            '       c.ttramitad,' ||
            '       po.tpoblac,' ||
            '       COUNT(po.tpoblac) procesos' ||
            '  FROM sin_codtramitador      c,' ||
            '       sin_tramita_movimiento m,';
            IF pctramit = 20 THEN
              vcursor := vcursor || ' SIN_TRAMITA_JUDICIAL  p,';
            ELSIF  pctramit = 21 THEN
              vcursor := vcursor || ' SIN_TRAMITA_FISCAL    p,';
            ELSIF  pctramit = 0 THEN
              vcursor := vcursor || ' SIN_TRAMITA_LOCALIZA  p, sin_tramitacion st ,';
            END IF;
            vcursor := vcursor ||
            '       poblaciones            po' ||
            ' WHERE c.ctramitad = m.ctramitad' ||
            '   AND m.nsinies = p.nsinies' ||
            '   AND m.ntramit = p.ntramit' ||
            '   AND  DECODE(p.cprovin,NULL,0,p.cprovin) = po.cprovin';
            IF pctramit = 21 THEN
              vcursor := vcursor || ' AND DECODE(p.cprovin,NULL,0,p.ccontra) = po.cpoblac';
            ELSE
              vcursor := vcursor || ' AND DECODE(p.cprovin,NULL,0,p.cpoblac) = po.cpoblac';
            END IF;
            vcursor := vcursor ||
            '   AND m.nmovtra = (SELECT MAX(nmovtra)' ||
            '                      FROM sin_tramita_movimiento ms' ||
            '                     WHERE ms.nsinies = m.nsinies' ||
            '                       AND ms.ntramit = m.ntramit) ';
        IF pctramitad IS NOT NULL THEN
          vcursor := vcursor || ' AND c.ctramitad = ''' ||pctramitad  ||'''  and cesttra not in (1)';
        END IF;
		-- BUG 4961 ABJ 
		 IF pctramit = 0 THEN
        vcursor := vcursor || 'AND p.NSINIES NOT IN '|| 
        ' (SELECT  CR.NSINIES  FROM (SELECT NSINIES,CUSUALT FROM SIN_TRAMITA_LOCALIZA WHERE ntramit =0) CR,'|| 
        ' (SELECT NSINIES,CUSUALT FROM SIN_TRAMITA_LOCALIZA WHERE ntramit !=0) SC WHERE CR.NSINIES=SC.NSINIES AND CR.CUSUALT=SC.CUSUALT)
        and m.nsinies=st.nsinies and m.ntramit=st.ntramit and (p.NSINIES,c.ctramitad,ctramit) not in ( select m2.nsinies,ctramitad,count(*)*0 from sin_tramitacion m2
    join sin_tramita_movimiento m3 on m2.nsinies=m3.nsinies and m2.ntramit = m3.ntramit  
    AND nmovtra = (SELECT MAX(nmovtra)                          FROM sin_tramita_movimiento ms                    
   WHERE ms.nsinies = m.nsinies                           AND ms.ntramit = m3.ntramit) and  m2.ntramit>0  and cesttra not in (1)
   group by m2.nsinies,ctramitad)  and cesttra not in (1)
        ';
		END IF;

        vcursor := vcursor ||
          ' GROUP BY c.ctramitad,' ||
          '          c.ttramitad,' ||
          '          po.tpoblac ';
      ELSIF pctipo = 3 THEN
        vcursor :=    ' SELECT c.ctramitad,' ||
            '       c.ttramitad,' ||
            '       PAC_REDCOMERCIAL.ff_desagente (s.cagente, f_usu_idioma ,4 ) tpoblac,' ||
            '       COUNT(s.cagente) procesos' ||
            '  FROM sin_codtramitador      c,' ||
            '       sin_tramita_movimiento m,' ||
            '       sin_siniestro          n,' ||
            '       seguros                s' ||
            ' WHERE c.ctramitad = m.ctramitad' ||
            '   AND m.nsinies = n.nsinies' ||
            '   AND n.sseguro = s.sseguro' ||
            '   AND m.ntramit = 0        ' ||
            '   AND m.nmovtra = (SELECT MAX(nmovtra)' ||
            '                      FROM sin_tramita_movimiento ms' ||
            '                     WHERE ms.nsinies = m.nsinies' ||
            '                       AND ms.ntramit = m.ntramit) ';
        IF pctramitad IS NOT NULL THEN
          vcursor := vcursor || ' AND c.ctramitad = ''' ||pctramitad  ||'''';
        END IF;

        vcursor := vcursor ||
          ' GROUP BY c.ctramitad,' ||
          '          c.ttramitad,' ||
          '          PAC_REDCOMERCIAL.ff_desagente (s.cagente, f_usu_idioma ,4 )';
      END IF;

      ref_cursor := pac_md_listvalores.f_opencursor(vcursor, mensajes);
      RETURN ref_cursor;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF ref_cursor%ISOPEN THEN
            CLOSE ref_cursor;
         END IF;

         RETURN ref_cursor;
  END f_get_procesos_tramitador;

       /*************************************************************************
      f_get_lstsoldoc
       Recupera beneficiarios de las pignoraciones
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstsoldoc(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstsoldoc';
      terror         VARCHAR2(200) := '';
      vsproduc       NUMBER(8);
   BEGIN
      SELECT sproduc INTO vsproduc
        FROM seguros
      WHERE sseguro = (SELECT sseguro FROM sin_siniestro
                          WHERE nsinies = pnsinies);
      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor('SELECT  ppc.ctipo, dv.tatribu
                                              FROM prod_plant_cab ppc, detplantillas d, detvalores dv
                                              WHERE  ppc.ccodplan = d.ccodplan
                                              AND ppc.ctipo = dv.catribu
                                              AND dv.cvalor = 2100
                                              AND dv.cidioma =  ' || pac_md_common.f_get_cxtidioma() ||
                                              'AND d.cidioma = '  || pac_md_common.f_get_cxtidioma() ||
                                              'ORDER BY dv.tatribu',
                                              mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstsoldoc;

   /*************************************************************************
      f_get_lsttramit
       Recupera beneficiarios de las pignoraciones
         pnsinies  in
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
     FUNCTION f_get_lsttramit(pnsinies IN VARCHAR2, mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lsttramit';
      terror         VARCHAR2(200) := '';
   BEGIN
      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor('SELECT tram.ntramit, ff_desvalorfijo(800,'|| pac_md_common.f_get_cxtidioma() ||',codtram.ctiptra) ttiptra, '
                                              ||' pac_siniestros.FF_GET_TIPUSTRAM(tram.nsinies,tram.ntramit,codtram.ctiptra,'|| pac_md_common.f_get_cxtidioma() ||') ttramit '
                                              ||' FROM sin_codtramitacion codtram, sin_tramitacion tram '
                                              ||' WHERE tram.nsinies = '||pnsinies|| 'AND codtram.ctramit = tram.ctramit ',
                                              mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lsttramit;

  /*************************************************************************
      f_get_lstpagos
         pnsinies  in varchar2
         pntramit in number
         param out mensajes : mensajes de error
         return             : ref cursor
    *************************************************************************/-- Bug 27766 - 10/12/2013 - se crea la funcion
   FUNCTION f_get_lstpagos(pnsinies IN VARCHAR2, pntramit IN NUMBER,  mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor  IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstpagos';
      terror         VARCHAR2(200) := '';
      Vsql            VARCHAR2(1000);
   BEGIN

      vpasexec := 2;
      cur := pac_md_listvalores.f_opencursor('SELECT trap.sidepag, pd.tnombre  ||'' ''||     pd.tapelli1  ||'' ''||    pd.tapelli2 AS TDESTINATARIO '||
                                               'FROM sin_tramita_pago trap, per_personas p, per_detper pd, sin_tramita_destinatario d '||
                                               'WHERE trap.sperson = p.sperson '||
                                                     ' AND trap.nsinies = ' || pnsinies ||
                                                     ' AND trap.ntramit = '|| NVL(to_char(pntramit), 'trap.ntramit') ||
                                                     ' AND  pd.sperson = p.sperson '||
                                            ' AND((p.swpubli = 0 '||
                                                   ' AND pd.fmovimi = (SELECT MAX(fmovimi) '||
                                                                       ' FROM per_detper dd, agentes_agente aa2 '||
                                                                      ' WHERE dd.sperson = pd.sperson '||
                                                                        ' AND dd.cagente = aa2.cagente)) '||
                                                  ' OR(p.swpubli = 1 '||
                                                     ' AND pd.cagente = p.cagente)) '||
                                            ' AND d.nsinies = trap.nsinies '||
                                            ' AND d.ntramit= trap.ntramit '||
                                            ' AND d.sperson = trap.sperson '||
                                            ' AND d.ctipdes = trap.ctipdes ',
                                              mensajes);

      Vsql := 'SELECT trap.sidepag, pd.tnombre  ||'' ''||     pd.tapelli1  ||'' ''||    pd.tapelli2 AS TDESTINATARIO '||
                                               'FROM sin_tramita_pago trap, per_personas p, per_detper pd, sin_tramita_destinatario d '||
                                               'WHERE trap.sperson = p.sperson '||
                                                     ' AND trap.nsinies = ' || pnsinies ||
                                                     ' AND trap.ntramit = '|| NVL(to_char(pntramit), 'trap.ntramit') ||
                                                     ' AND  pd.sperson = p.sperson '||
                                            ' AND((p.swpubli = 0 '||
                                                   ' AND pd.fmovimi = (SELECT MAX(fmovimi) '||
                                                                       ' FROM per_detper dd, agentes_agente aa2 '||
                                                                      ' WHERE dd.sperson = pd.sperson '||
                                                                        ' AND dd.cagente = aa2.cagente)) '||
                                                  ' OR(p.swpubli = 1 '||
                                                     ' AND pd.cagente = p.cagente)) '||
                                            ' AND d.nsinies = trap.nsinies '||
                                            ' AND d.ntramit= trap.ntramit '||
                                            ' AND d.sperson = trap.sperson '||
                                            ' AND d.ctipdes = trap.ctipdes ';
                                              p_control_error(1,'sql  =  ',Vsql);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           terror, SQLCODE, SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_get_lstpagos;
   
   
   
   /*************************************************************************
     Funciones : f_get_lstcontingencia
     Consulta de datos para la lista contingencia  de siniestros
     param out mensajes   : mensajes de error
     return              : sys_refcursor
    *************************************************************************/
   FUNCTION f_get_lstcontingencia(mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcontingencia';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstcontingencia';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002018 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
     RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
         RETURN cur;
   END f_get_lstcontingencia;
   
    /*************************************************************************
     Funciones : f_get_lstriesgos
     Consulta de datos para lista de  riesgo de siniestros
     param out mensajes   : mensajes de error
     return              : sys_refcursor
    *************************************************************************/
   FUNCTION f_get_lstriesgos (mensajes OUT t_iax_mensajes)
     RETURN sys_refcursor IS
      cur            sys_refcursor;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(1) := NULL;
      vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstriesgos';
      terror         VARCHAR2(200) := 'Error recuperar f_get_lstriesgos';
   BEGIN
      cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002019 and cidioma= ' || pac_md_common.f_get_cxtidioma() , mensajes);
      RETURN cur;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
         RETURN cur;
   END f_get_lstriesgos;
   /*************************************************************************
         Funciones : f_get_lstclaseproceso
         Autor: EA 21/02/2020
         Consulta de datos para la lista Clase de proceso de siniestros
         param out mensajes   : mensajes de error
         return              : sys_refcursor
        Bug o Tarea 3603
        *************************************************************************/
       FUNCTION f_get_lstclaseproceso(mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor IS
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstclaseproceso';
          terror         VARCHAR2(200) := 'Error recuperar f_get_lstclaseproceso';
       BEGIN
          cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002029 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
         RETURN cur;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;
             RETURN cur;
       END f_get_lstclaseproceso;
 /*************************************************************************
         Funciones : f_get_lstinstanciaproceso
         Autor: EA 21/02/2020
         Consulta de datos para la lista Instancia del Proceso de siniestros
         param out mensajes   : mensajes de error
         return              : sys_refcursor
        Bug o Tarea 3603
        *************************************************************************/
       FUNCTION f_get_lstinstanciaproceso(mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor IS
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstinstanciaproceso';
          terror         VARCHAR2(200) := 'Error recuperar f_get_lstinstanciaproceso';
       BEGIN
          cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002030 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
         RETURN cur;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;
             RETURN cur;
       END f_get_lstinstanciaproceso;
 /*************************************************************************
         Funciones : f_get_lstcontingenciafallo
         Autor: EA 21/02/2020
         Consulta de datos para la lista Fallo de siniestros
         param out mensajes   : mensajes de error
         return              : sys_refcursor
        Bug o Tarea 3603
        *************************************************************************/
       FUNCTION f_get_lstcontingenciafallo(mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor IS
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcontingenciafallo';
          terror         VARCHAR2(200) := 'Error recuperar f_get_lstcontingenciafallo';
       BEGIN
          cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002031 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
         RETURN cur;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;
             RETURN cur;
       END f_get_lstcontingenciafallo;
 /*************************************************************************
         Funciones : f_get_lstcalifmotivo
         Autor: EA 21/02/2020
         Consulta de datos para la lista Calificación Motivos de siniestros
         param out mensajes   : mensajes de error
         return              : sys_refcursor
        Bug o Tarea 3603
        *************************************************************************/
       FUNCTION f_get_lstcalifmotivo(mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor IS
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstcalifmotivo';
          terror         VARCHAR2(200) := 'Error recuperar f_get_lstcalifmotivo';
       BEGIN
          cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002032 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
         RETURN cur;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;
             RETURN cur;
       END f_get_lstcalifmotivo;
 /*************************************************************************
         Funciones : f_get_lstoralproceso
         Autor: EA 21/02/2020
         Consulta de datos para la lista ¿El proceso se llevara a cabo de manera Oral? de siniestros
         param out mensajes   : mensajes de error
         return              : sys_refcursor
        Bug o Tarea 12959
        *************************************************************************/
       FUNCTION f_get_lstoralproceso(mensajes OUT t_iax_mensajes)
          RETURN sys_refcursor IS
          cur            sys_refcursor;
          vpasexec       NUMBER(8) := 1;
          vparam         VARCHAR2(1) := NULL;
          vobject        VARCHAR2(200) := 'PAC_MD_LISTVALORES_SIN.f_get_lstoralproceso';
          terror         VARCHAR2(200) := 'Error recuperar f_get_lstoralproceso';
       BEGIN
          cur := pac_md_listvalores.f_opencursor('select  CATRIBU, TATRIBU from detvalores where cvalor = 8002033 and cidioma= ' || pac_md_common.f_get_cxtidioma(), mensajes);
         RETURN cur;
       EXCEPTION
          WHEN OTHERS THEN
             pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,  terror, SQLCODE, SQLERRM);
             IF cur%ISOPEN THEN
                CLOSE cur;
             END IF;
             RETURN cur;
       END f_get_lstoralproceso;
   
END pac_md_listvalores_sin;
/