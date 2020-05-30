--------------------------------------------------------
--  DDL for Package Body PAC_MD_GESTIONPROPUESTA
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY PAC_MD_GESTIONPROPUESTA AS
   /******************************************************************************
    NOMBRE:       PAC_MD_GESTIONPROPUESTA
    PROPÓSITO:    Funciones para gestionar las propuestas retenidas en la capa intermedia

    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        06/10/2008   APD                1. Creación del package.
    2.0        03/03/2009   DRA                2. BUG0009297: IAX - Gestió de propostes - Revisió punts pendents
    3.0        30/03/2009   DRA                3. 0009640: IAX - Modificar missatge de retenció de pòlisses pendents de facultatiu
    4.0        16/03/2009   DRA                4. BUG0009423: IAX - Gestió propostes retingudes: detecció diferències al modificar capitals o afegir garanties
    5.0        15/05/2009   JTS                5. BUG9760 Gestión de retenidas. Búsqueda por tomador
    6.0        19/05/2009   APD                6. BUG10127: IAX- Consultas de pólizas, simulaciones, reembolsos y póliza reteneidas
    6.1        21/05/2009   APD                6.1 BUG10178: IAX - Vista AGENTES_AGENTE por empresa
    7.0        16/09/2009   DRA                7. 0011113: CRE - Incidencias arranque Salud
    8.0        01/10/2009   JRB                8. BUG0011196: Gestión de propuestas retenidas
    9.0        20/10/2009   NMM                9. 11457: CEM - Retención de pólizas según profesión
    10.0       13/10/2009   XVM                10. BUG0011376: CEM - Suplementos y param. DIASATRAS
    11.0       12/11/2009   JTS                11. 10093: CRE - Afegir filtre per RAM en els cercadors
    12.0       01/01/2010   NMM                12. 12712: CEM - Retencion de pólizas, distinguir IMC de cuestionario.
    13.0       23/02/2010   JMF                13. 12803 AGA - Acceso a la vista PERSONAS.
    14.0       22/02/2010   ICV                14. 0009605: AGA - Buscadores
    15.0       19/05/2010   DRA                15. 0012395: CRE200 - GESTIÓ PROP. RETINGUDES: Error validació data efecte suplements retinguts
    16.0       31/08/2010   DRA                16. 0015684: CRE800 - Modificació de garanties en prop. suplement
    17.0       02/11/2010   XPL                17. 16352: CRT702 - Módulo de Propuestas de Suplementos, -- BUG16352:XPL:02112010 INICI
    18.0       16/12/2010   DRA                18. 0016548: CRE - Gestió de propostes retingudes - cerca per prenedor
    19.0       10/01/2011   SRA                19. 0016548: CRE - Gestió de propostes retingudes - cerca per prenedor
    20.0       28/10/2011   APD                20. 0018946: LCOL_P001 - PER - Visibilidad en personas
    21.0       13/11/2012   XVM                21. 0022839: LCOL_T010-LCOL - Funcionalidad Certificado 0
    22.0       06/11/2012   APD                22. 0023940: LCOL_T010-LCOL - Certificado 0 renovable - Renovaci?n colectivos
    23.0       12/12/2012   JMF                0024832 LCOL - Cartera colectivos - Procesos
    24.0       14/01/2013   DCT                0025583 LCOL - Revisión incidencias qtracker(IV)
    25.0       05/02/2013   DCT                0025583 LCOL - Revisión incidencias qtracker(IV)
    26.0       12/08/2013   JDS                0027539: LCOL_T010-LCOL - Revision incidencias qtracker (VII)
    27.0       14/08/2013   RCL                27. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
    28.0       07/10/2013   FPG                28. 0028263: LCOL899-Proceso Emisi?n Vida Grupo - Desarrollo modificaciones de iAxis para BPM
    29.0       22/11/2013   RCL                29. 0027048: LCOL_T010-Revision incidencias qtracker (V)
    30.0       05/12/2013   RCL                30. 0027262: LCOL - Fase Mejoras - Autorización masiva de propuestas retenidas
    31.0       17/12/2013   RCL                31. 0029358: LCOL_T010-LCOL - Revision incidencias qtracker (VIII)
    32.0       04/02/2014   FAL                32. 0029965: RSA702 - GAPS renovación
    33.0       11/03/2014   APD                33. 0030448/169258: LCOL_T010-Revision incidencias qtracker (2014/03)
    34.0       19/03/2014   RCL                34. 0029665: LCOL_PROD-Qtrackers Fase 2 - iAXIS Produccion
    35.0       03/04/2014   JSV                35. 0030448: LCOL_T010-Revision incidencias qtracker (2014/03) - Mejora: Autorización masiva pasa a ser via job,
                                                            pudiendo parametrizar si queremos job o no y número de certificados a partir del cual se lanzará
    36.0       14/04/2014   FAL                36. 0029965: RSA702 - GAPS renovación
    37.0       15/04/2014   dlF                37. 0030779: Problemas al emitir pólizas autorizadas previamente
    38.0       01/07/2015   IGIL             0035888/203837 quitar UPPER a NNUMNIF
    39.0       25/07/2018   VCG                39.0001008: Cuando una propuesta queda retenida, ¡Axis a veces lo incluye en la pantalla de pólizas pendientes de autorizar y otras veces no
    40.0       20/03/2019   CJMR               40. IAXIS-3160: Adición de nuevos campo de búsqueda
    41.0       09/09/2019   ECP                41. IAXIS-3504 Pantallas gestión suplmentos
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Recupera todas las propuestas retenidas
      param in psproduc  : Código del producto
      param in pnpoliza  : Nº de poliza
      param in pnsolici  : Solicitud
      param in pfcancel  : Fecha de cancelación
      param in pnumide   : Documento idenficación persona
      param in pnombre   : Tomador
      param in psnip     : Identificador externo
      param out mensajes : mesajes de error
      return             : T_IAX_POLIZASRETEN
   *************************************************************************/
   FUNCTION f_get_polizasreten(
      psproduc IN NUMBER,
      pnpoliza IN seguros.npoliza%TYPE,
      pnsolici IN NUMBER,
      pfcancel IN DATE,
      pnnumide IN VARCHAR2,
      pnombre IN VARCHAR2,
      psnip IN VARCHAR2,
      pcmotret IN NUMBER,
      pcestgest IN NUMBER,
      pcramo IN NUMBER,
      pcagente IN NUMBER,
      pctipo IN VARCHAR2,
      pcmatric IN VARCHAR2,
      pcpostal IN VARCHAR2,
      ptnatrie IN VARCHAR2,
      ptdomici IN VARCHAR2,
      pcnivelbpm IN NUMBER,
      mensajes OUT t_iax_mensajes,
      pcsucursal IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcadm IN NUMBER DEFAULT NULL,   -- Bug 22839/126886 - 29/10/2012 - AMC
      pcmotor IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pcchasis IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pnbastid IN VARCHAR2 DEFAULT NULL,   -- Bug 25177/133016 - 28/12/2012 - AMC
      pmodo IN VARCHAR2 DEFAULT NULL,   -- Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
      pccontrol IN NUMBER DEFAULT NULL,   -- Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
      pcpolcia IN VARCHAR2 DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretend IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pfretenh IN DATE DEFAULT NULL,   -- Bug 0029965 - 14/04/2014 - FAL
      pcactivi IN NUMBER DEFAULT NULL,       -- CJMR 20/03/2019 IAXIS-3160
      pnnumidease IN VARCHAR2 DEFAULT NULL,  -- CJMR 20/03/2019 IAXIS-3160
      pnombrease IN VARCHAR2 DEFAULT NULL,   -- CJMR 20/03/2019 IAXIS-3160
      ppolretpsu OUT t_iax_polretenpsu)   -- Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
      RETURN t_iax_polizasreten IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(250)
         := 'psproduc: ' || psproduc || ' - pnsolici:' || pnsolici || ' - pfcancel:'
            || pfcancel || ' - pnnumide:' || pnnumide || ' - pnombre:' || pnombre
            || ' - psnip:' || psnip || ' - pcestgest: ' || pcestgest || ' - pcramo: '
            || pcramo || ' - pcagente: ' || pcagente || ' - pctipo: ' || pctipo
            || ' - pcnivelbpm: ' || pcnivelbpm;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Get_PolizasReten';
      polretenidas   t_iax_polizasreten := t_iax_polizasreten();
      polreten       ob_iax_polizasreten := ob_iax_polizasreten();
      cur            sys_refcursor;
      squery         VARCHAR2(4000);
      -- Bug 10127 - APD - 19/05/2009 - Modificar el número máximo de registros a mostrar por el valor del parinstalación
      --                                se añade la subselect con la tabla agentes_agente
      -- Bug 18946 - APD - 28/10/2011 - se sustituye la vista agentes_agente por agentes_agente_pol
      --buscar         VARCHAR2(4000) := ' where rownum<=101 ';
      buscar         VARCHAR2(4000)
         := ' where (s.cagente,s.cempres) in (select cagente, cempres from agentes_agente_pol) ';
         
        
      -- Bug 18946 - APD - 28/10/2011 - fin
      -- Bug 10127 - APD - 19/05/2009 - fin
      subus          VARCHAR2(4000);
      auxnom         VARCHAR2(100);
      vfmovimi       DATE;
      vcramo         NUMBER;
      vcmodali       NUMBER;
      vctipseg       NUMBER;
      vccolect       NUMBER;
      nerr           NUMBER;
      vform          VARCHAR2(4000) := '';
      v_tpsus        t_iax_psu;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      v_testpol      VARCHAR2(400);
      v_cestpol      NUMBER;
      v_cnivelbpm    NUMBER;
      v_tnivelbpm    VARCHAR2(50);
      vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
      vobiaxpolretpsu ob_iax_polretenpsu;
      v_polretenpsu  ob_iax_polretenpsu;
      v_entra        BOOLEAN := FALSE;
      vnnumide       VARCHAR2(100);   -- Fin BUG 38344/217178 - 09/11/2015 - ACL
      vsnip          VARCHAR2(100);   -- Fin BUG 38344/217178 - 09/11/2015 - ACL
   BEGIN
      ppolretpsu := t_iax_polretenpsu();
       buscar  
         := ' where  ';
      IF pmodo IS NULL
         OR pmodo <> 'AUTORIZA_MASIVO' THEN
         buscar := buscar || ' rownum<= NVL('
                   || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG_ESP')),
                          NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null'))
                   || ', rownum) ';
      END IF;

      --BUG 29358/151407 - 16/12/2013 - RCL - En Autorización masiva no se filta por rownum
      IF pmodo IS NULL
         OR pmodo <> 'AUTORIZA_MASIVO' THEN
         buscar := buscar || ' AND rownum<= NVL('
                   || NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG_ESP')),
                          NVL(TO_CHAR(pac_parametros.f_parinstalacion_n('N_MAX_REG')), 'null'))
                   || ', rownum) ';
      END IF;

      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      -- Bug 23940 - APD - 19/10/2012 - se añade el csituac = 17.-Prop. Cartera
      /*buscar := buscar || ' and m.sseguro = s.sseguro '   --and sa.sseguro = s.sseguro '
                || ' and m.nmovimi in (SELECT MAX (nmovimi) FROM movseguro m2 '
                --JLB  18181 18181
                --|| ' WHERE m2.sseguro = s.sseguro) and s.csituac IN (4, 5 ) '
                || ' WHERE m2.sseguro = s.sseguro) and s.csituac IN (4, 5 ,12, 17 ) '
                || ' and (s.creteni in (8,10,11,12,13,14,15,16) or s.creteni = 2 OR '
                -- JLB -18181  18181 nuevo creteni de correduria
                || ' s.creteni = 5 OR ' || '( s.creteni = 1  '
                || ' AND ( EXISTS (SELECT mot.cmotret FROM motretencion mot '
                || ' WHERE mot.sseguro = s.sseguro AND mot.nmovimi = m.nmovimi '
                || ' AND mot.cmotret not IN (1, 20))  ' || '  ) ' || ' ) )';   -- bug 12712.NMM.02/2010.*/
      --Ini-qt-1008-VCG-24/01/2018
      buscar := buscar
                || ' and m.sseguro = s.sseguro '   --and sa.sseguro = s.sseguro '
                || ' and m.nmovimi in (SELECT MAX (nmovimi) FROM movseguro m2 '
                --JLB  18181 18181
                --|| ' WHERE m2.sseguro = s.sseguro) and s.csituac IN (4, 5 ) '
                || ' WHERE m2.sseguro = s.sseguro) and s.csituac IN (4, 5 ,12, 17 ) '
                || ' and (s.creteni in (8,10,11,12,13,14,15,16) or s.creteni = 2 OR '
                -- JLB -18181  18181 nuevo creteni de correduria
                || ' s.creteni = 5 OR ' || '( s.creteni = 1  '
                || ' ) )';   -- bug 12712.NMM.02/2010.
      --Fin-qt-1008-VCG-24/01/2018
      -- Bug 10127 - APD - 19/05/2009 - fin
      IF NVL(psproduc, 0) <> 0 THEN
         buscar := buscar || ' and s.sproduc=' || psproduc;
      END IF;

      IF pcnivelbpm IS NOT NULL THEN
         buscar :=
            buscar
            || ' and EXISTS (SELECT * FROM PSU_RETENIDAS PRR WHERE PRR.SSEGURO = s.sseguro AND PRR.NMOVIMI =  m.nmovimi AND  PRR.CNIVELBPM ='
            || pcnivelbpm || ' ) ';
      END IF;

      vpasexec := 2;

      IF pnsolici IS NOT NULL THEN
         buscar := buscar || ' and s.nsolici=' || pnsolici;
      END IF;

      vpasexec := 3;

      IF pnpoliza IS NOT NULL THEN
         buscar := buscar || ' and s.npoliza=' || pnpoliza;
      END IF;

      IF pfcancel IS NOT NULL THEN
         buscar := buscar || ' and s.fcancel <= TO_DATE(''' || TO_CHAR(pfcancel, 'DDMMYYYY')
                   || ''',''DDMMYYYY'')';
      END IF;

      vpasexec := 4;


      IF pcmotret IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in ( select mot.sseguro'
                   || ' from motretencion  mot' || ' where mot.cmotret = ' || pcmotret || ' )';
      ELSE
         buscar :=
            buscar || ' and ( s.sseguro in ( select mot.sseguro' || ' from motretencion  mot'
            || ' where mot.cmotret not in ( 1 ))
                    OR (s.sseguro IN(SELECT psu.sseguro
                           FROM psucontrolseg psu
                          WHERE psu.sseguro = s.sseguro) )  ) ';   -- bug 12712.NMM.02/2010.
      end if;
      -- Bug 0029965 - 14/04/2014 - FAL
      IF pcpolcia IS NOT NULL THEN
         buscar := buscar || ' and s.cpolcia=' || CHR(39) || pcpolcia || CHR(39);
      END IF;

      IF pfretend IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in ( select mot.sseguro'
                   || ' from motretencion  mot' || ' where mot.freten >= TO_DATE('''
                   || TO_CHAR(pfretend, 'DDMMYYYY') || ''',''DDMMYYYY''))';
      END IF;

      IF pfretenh IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in ( select mot.sseguro'
                   || ' from motretencion  mot' || ' where mot.freten <= TO_DATE('''
                   || TO_CHAR(pfretenh, 'DDMMYYYY') || ''',''DDMMYYYY''))';
      END IF;

      -- FI Bug 0029965 - 14/04/2014 - FAL
      vpasexec := 5;

      --BUG 9760 - JTS - 13/05/2009 - Optimizar busqueda por personas
      -- buscar per personas
      -- ini Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS
      IF (pnnumide IS NOT NULL
          OR NVL(psnip, ' ') <> ' '
          OR pnombre IS NOT NULL) THEN
         IF pnombre IS NOT NULL THEN
            subus :=
               ' and exists (SELECT 1 '
               || ' FROM tomadores a, per_personas pp, per_detper pd '
               || ' WHERE a.sseguro=s.sseguro and a.sperson = pp.sperson'
-- ini bug 16548 - SRA - 10/01/2010: se incluye la visión según permisos del agente
               || ' AND pd.sperson=pp.sperson AND '   --pd.cagente=ff_agente_cpervisio(ff_agenteprod())';
               || 'pd.cagente IN (SELECT r.cagente FROM redcomercial r '
               || 'WHERE fmovfin IS NULL AND LEVEL = DECODE (ff_agente_cpernivel (ff_agenteprod ()), 1, LEVEL, 1) '
               || 'START WITH cagente = ff_agente_cpervisio (ff_agenteprod ()) '
               || 'CONNECT BY PRIOR cagente = cpadre AND PRIOR fmovfin IS NULL) ';
-- fin bug 16548 - SRA - 10/01/2010
            nerr := f_strstd(pnombre, auxnom);   -- En esta función ya se realiza el UPPER
            subus := subus || ' AND pd.tbuscar like ''%' || auxnom || '%''';
         ELSE
            subus := ' and exists (SELECT 1 FROM tomadores a, per_personas pp '
                     || ' WHERE a.sseguro=s.sseguro and a.sperson = pp.sperson';
         END IF;

-- ini bug 16548 - SRA - 10/01/2010: se adapta el código para cumplir la regla de entrega 3.7
         IF pnnumide IS NOT NULL THEN
            -- Inicio BUG 38344/217178 - 09/11/2015 - ACL
            vnnumide := pnnumide;
            vnnumide := REPLACE(vnnumide, CHR(39), CHR(39) || CHR(39));

            -- Fin BUG 38344/217178 - 09/11/2015 - ACL
                --Bug 371152-21271 Busqueda de NIF minuscula KJSC 26/08/2015
            IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(),
                                                 'NIF_MINUSCULAS'),
                   0) = 1 THEN
               subus := subus || ' AND UPPER(pp.nnumide) = UPPER(' || CHR(39)
                        || vnnumide   -- BUG 38344/217178 - 09/11/2015 - ACL
                                   || CHR(39) || ')';
            ELSE
               subus := subus || ' AND pp.nnumide LIKE ' || CHR(39) || vnnumide || CHR(39);   -- BUG 38344/217178 - 09/11/2015 - ACL
            END IF;
         END IF;

         IF NVL(psnip, ' ') <> ' ' THEN
            -- Inicio BUG 38344/217178 - 29/10/2015 - ACL
            vsnip := psnip;
            vsnip := REPLACE(vsnip, CHR(39), CHR(39) || CHR(39));
            subus := subus || ' AND upper (pp.snip) =' || CHR(39) || UPPER(vsnip) || CHR(39);
         -- Fin BUG 38344/217178 - 09/11/2015 - ACL
         END IF;

-- fin bug 16548 - SRA - 10/01/2010
         subus := subus || ')';
      END IF;

      -- fin Bug 0012803 - 19/02/2010 - JMF: AGA - Acceso a la vista PERSONAS
      vpasexec := 6;

      --BUG 11196 - JRB - 01/10/2009 - Estados de gestión de propuesta retenida
      IF pcestgest IS NOT NULL THEN
         buscar := buscar
                   || ' AND s.sseguro IN (select sseguro from motretencion where cestgest ='
                   || pcestgest || ') ';
      END IF;

      --BUG 10093 - JTS - 12/11/2009
      IF pcramo IS NOT NULL THEN
         buscar := buscar || ' and s.cramo = ' || pcramo;
      END IF;

      IF pcagente IS NOT NULL THEN
         buscar := buscar || ' and s.cagente = ' || pcagente;
      END IF;

      --Ini Bug.: 0009605: AGA - Buscadores - ICV - 22/02/2010
      IF pcmatric IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
                   || ' where s.sseguro = aut.sseguro and aut.cmatric like ''%' || pcmatric
                   || '%''';
         buscar := buscar || ') ';
      END IF;

      -- Bug 25177/133016 - 28/12/2012 - AMC
      IF pcmotor IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
                   || ' where s.sseguro = aut.sseguro and upper(aut.codmotor) like upper(''%'
                   || pcmotor || '%'')) ';
      END IF;

      IF pcchasis IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
                   || ' where s.sseguro = aut.sseguro and upper(aut.cchasis) like upper(''%'
                   || pcchasis || '%'')) ';
      END IF;

      IF pnbastid IS NOT NULL THEN
         buscar := buscar || ' and s.sseguro in (select aut.sseguro from autriesgos aut '
                   || ' where s.sseguro = aut.sseguro and upper(aut.nbastid) like upper(''%'
                   || pnbastid || '%'')) ';
      END IF;

      -- Fi Bug 25177/133016 - 28/12/2012 - AMC
      IF pcpostal IS NOT NULL THEN
         buscar :=
            buscar
            || ' and s.sseguro in (select sit.sseguro from sitriesgo sit where sit.sseguro = s.sseguro and sit.cpostal like ''%'
            || pcpostal || '%''' || ') ';
      END IF;

      IF ptdomici IS NOT NULL THEN
         buscar :=
            buscar
            || ' and s.sseguro in (select sit.sseguro from sitriesgo sit where  sit.sseguro = s.sseguro and sit.tdomici like ''%'
            || ptdomici || '%''' || ') ';
      END IF;

      -- INI CJMR 20/03/2019 IAXIS-3160
      IF pcactivi IS NOT NULL THEN
         buscar := buscar || ' AND s.cactivi=' ||  pcactivi ;
      END IF;

	  -- Número de identificación y/o nombre del asegurado
      IF pnnumidease IS NOT NULL OR pnombrease IS NOT NULL THEN
            subus := subus || ' AND s.sseguro IN (SELECT a.sseguro FROM asegurados a, ' ||
                     ' per_personas pp, per_detper pdp WHERE a.sperson = pp.sperson ' ||
                     ' AND a.sperson = pdp.sperson ' ||
                     ' AND pdp.cagente = ff_agente_cpervisio (s.cagente, f_sysdate, s.cempres)' ||
                     ' AND a.ffecfin IS NULL';

            IF pnnumidease IS NOT NULL THEN
               IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa(), 'NIF_MINUSCULAS'), 0) = 1 THEN
                  subus := subus || ' AND UPPER(pp.nnumide) = UPPER(' || chr(39) || ff_strstd(pnnumidease) || chr(39) || ')';
               ELSE
                  subus := subus || ' AND pp.nnumide LIKE ' || chr(39) || '%' || ff_strstd(pnnumidease) || '%' || chr(39) || '';
               END IF;
            END IF;

            IF pnombrease IS NOT NULL THEN
               nerr := f_strstd(pnombrease, auxnom);

               subus := subus || ' AND UPPER ( REPLACE ( pdp.tbuscar, ' || 
                        chr(39) || '  ' || chr(39) || ',' || chr(39) || ' ' ||
                        chr(39) || ' )) LIKE UPPER(''%' || auxnom || '%' ||
                        chr(39) || ')';
            END IF;

            subus := subus || ')';
      END IF;
      -- FIN CJMR 20/03/2019 IAXIS-3160

      IF ptnatrie IS NOT NULL THEN
         buscar :=
            buscar
            || ' and s.sseguro in (select rie.sseguro from riesgos rie where rie.sseguro = s.sseguro and rie.tnatrie like ''%'
            || ptnatrie || '%''' || ') ';
      END IF;

      --Fin Bug.: 0009605: AGA - Buscadores - ICV - 22/02/2010

      --Fi BUG 10093

      --Fi BUG 9760 - JTS - 13/05/2009 - Optimizar busqueda por personas
      vpasexec := 7;
      -- Bug 22839/126886 - 29/10/2012 - AMC
      vform := 'from seguros s, movseguro m ';

      IF pcsucursal IS NOT NULL
         OR pcadm IS NOT NULL THEN
         vform := vform || ' ,seguredcom src ';
         buscar := buscar || ' AND s.sseguro = src.sseguro ';

         IF pcsucursal IS NOT NULL THEN
            buscar := buscar || ' AND src.c02 = ' || pcsucursal;
         END IF;

         IF pcadm IS NOT NULL THEN
            buscar := buscar || ' AND src.c03 = ' || pcadm;
         END IF;
      END IF;

      -- Fi Bug 22839/126886 - 29/10/2012 - AMC

      -- Inici Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
      IF pccontrol IS NOT NULL THEN
         buscar := buscar || ' AND s.sseguro in (SELECT e.sseguro FROM psucontrolseg e '
                   || '             WHERE e.cnivelr <> 0 '
                   || '             AND NVL(e.isvisible, 1) = 1 '
                   || '             AND e.nmovimi = m.nmovimi '
                   || '             AND e.sseguro = s.sseguro '
                   || '             AND e.ccontrol = ' || pccontrol
                   --BUG 27048/160928 - RCL - 09/12/2013
                   || '             AND e.nocurre = (SELECT MAX(x.nocurre) '
                   || '                           	   FROM psucontrolseg x '
                   || '                               WHERE x.sseguro = s.sseguro '
                   || '                                 AND x.nmovimi = e.nmovimi) ' || ' ) ';
      END IF;

      IF pmodo = 'AUTORIZA_MASIVO' THEN
         buscar := buscar || ' AND s.ncertif <> 0 ';
      END IF;

      -- Fi Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
      -- Bug 10127 - APD - 19/05/2009 - se elimina la vista seguros_agente
      squery := 'select s.sseguro, m.nmovimi, s.nsuplem, s.nsolici, s.npoliza,'
                || ' s.ncertif, s.sproduc, s.fefecto, s.femisio, s.csituac, '
                || ' s.creteni, m.fmovimi, s.cramo, s.cmodali, s.ctipseg, '
                 -- Ini IAXIS-3504--ECP -- 09/09/2019
                || ' s.ccolect, s.fcancel, m.cusumov, m.cmotmov , (select tmotmov from motmovseg where cmotmov  = m.cmotmov and cidioma = '||pac_md_common.f_get_cxtidioma||') tmotmov '   -- Bug 22839/125653 - 26/10/2010 - AMC
                || vform || buscar || subus || ' order by s.npoliza, s.ncertif';
                
                 -- Ini IAXIS-3504--ECP -- 09/09/2019
       p_tab_error (f_sysdate,
                                  f_user,
                                  'PAC_MD_GESTIONPROPUESTA.F_GET_POLIZASRETEN',
                                  1,
                                  1,
                                    squery
                                 );
      -- Bug 10127 - APD - 19/05/2009 - fin
      IF pac_md_log.f_log_consultas(squery, 'PAC_MD_GESTIONPROPUESTA.F_GET_POLIZASRETEN', 1, 4,
                                    mensajes) <> 0 THEN
         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(squery, mensajes);

      LOOP
         FETCH cur
          INTO polreten.sseguro, polreten.nmovimi, polreten.nsuplem, polreten.nsolici,
               polreten.npoliza, polreten.ncertif, polreten.sproduc, polreten.fefecto,
               polreten.femisio, polreten.csituac, polreten.creteni, polreten.fmovimi, vcramo,
               -- Ini IAXIS-3504--ECP -- 09/09/2019
               vcmodali, vctipseg, vccolect, polreten.fcancel, polreten.cusumov,  polreten.cmotmov, polreten.tmotmov;   -- Bug 22839/125653 - 26/10/2010 - AMC
                -- Fin IAXIS-3504--ECP -- 09/09/2019

         EXIT WHEN cur%NOTFOUND;

         -- Inici Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
         IF pmodo = 'AUTORIZA_MASIVO' THEN
            --Reinicialitzem v_tpsus...
            v_tpsus := t_iax_psu();
            -- Recuperamos las PSUs del sseguro
            nerr := pac_md_psu.f_get_colec_psu(polreten.sseguro, polreten.nmovimi, NULL,
                                               pac_md_common.f_get_cxtidioma, 'POL',
                                               v_testpol, v_cestpol, v_cnivelbpm, v_tnivelbpm,
                                               vobpsu_retenidas, v_tpsus, mensajes);

            IF v_tpsus IS NOT NULL THEN
               IF v_tpsus.COUNT > 0 THEN
                  -- Para cada PSU
                  FOR i IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                     BEGIN
                        w_tpsus := v_tpsus(i);

                        IF ppolretpsu IS NOT NULL THEN
                           IF ppolretpsu.COUNT > 0 THEN
                              v_entra := FALSE;

                              FOR j IN ppolretpsu.FIRST .. ppolretpsu.LAST LOOP
                                 IF ppolretpsu(j).ccontrol = w_tpsus.ccontrol THEN
                                    v_entra := TRUE;
                                    ppolretpsu(j).contador := ppolretpsu(j).contador + 1;

                                    IF w_tpsus.cautrec = 1 THEN   --AUTORIZADA
                                       ppolretpsu(j).contaut := ppolretpsu(j).contaut + 1;
                                    ELSIF w_tpsus.cautrec = 2 THEN   --RECHAZADA
                                       ppolretpsu(j).contrec := ppolretpsu(j).contrec + 1;
                                    ELSE   --PENDIENTE
                                       ppolretpsu(j).contpdte := ppolretpsu(j).contpdte + 1;
                                    END IF;
                                 END IF;
                              END LOOP;
                           END IF;
                        END IF;

                        IF (NOT v_entra)
                           OR ppolretpsu.COUNT = 0 THEN
                           vobiaxpolretpsu := ob_iax_polretenpsu();
                           vobiaxpolretpsu.ccontrol := w_tpsus.ccontrol;
                           vobiaxpolretpsu.tcontrol := w_tpsus.tcontrol;
                           vobiaxpolretpsu.contador := 1;

                           IF w_tpsus.tautrec LIKE '%(M)' THEN
                              vobiaxpolretpsu.autmanual := 'M';   --PSU MANUAL
                           ELSE
                              vobiaxpolretpsu.autmanual := 'A';   --PSU AUTOMATICA
                           END IF;

                           IF w_tpsus.cautrec = 1 THEN   --AUTORIZADA
                              vobiaxpolretpsu.contaut := 1;
                              vobiaxpolretpsu.contrec := 0;
                              vobiaxpolretpsu.contpdte := 0;
                           ELSIF w_tpsus.cautrec = 2 THEN   --RECHAZADA
                              vobiaxpolretpsu.contaut := 0;
                              vobiaxpolretpsu.contrec := 1;
                              vobiaxpolretpsu.contpdte := 0;
                           ELSE   --PENDIENTE
                              vobiaxpolretpsu.contaut := 0;
                              vobiaxpolretpsu.contrec := 0;
                              vobiaxpolretpsu.contpdte := 1;
                           END IF;

                           ppolretpsu.EXTEND;
                           ppolretpsu(ppolretpsu.LAST) := vobiaxpolretpsu;
                        END IF;
                     END;
                  END LOOP;
               END IF;
            END IF;
         END IF;

         -- Fi Bug 0027262/0149107 - 14/08/2013 - RCL - Autorzación masiva propuestas retenidas
         nerr := pac_seguros.f_get_nsolici_npoliza(polreten.sseguro, NULL, polreten.sproduc,
                                                   polreten.csituac, polreten.nsolici,
                                                   polreten.npoliza, polreten.ncertif);

         IF nerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;

         polreten.nnumide := pac_iax_listvalores.f_get_numidetomador(polreten.sseguro, 1);
         polreten.tomador := pac_iax_listvalores.f_get_nametomador(polreten.sseguro, 1);
         polreten.treteni := pac_iax_listvalores.f_get_retencionpoliza(polreten.creteni);
         polreten.tsituac := pac_iax_listvalores.f_get_situacionpoliza(polreten.sseguro);
         polreten.cedit := 0;
         vpasexec := 9;
         nerr := f_desproducto(vcramo, vcmodali, 2, pac_md_common.f_get_cxtidioma,
                               polreten.trotulo, vctipseg, vccolect);

         IF nerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;

         polreten.docreq := pac_iax_docrequerida.f_tienerequerida(polreten.sproduc);
         polretenidas.EXTEND;
         polretenidas(polretenidas.LAST) := polreten;
         polreten := ob_iax_polizasreten();
      END LOOP;

      CLOSE cur;

      RETURN polretenidas;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN NULL;
   END f_get_polizasreten;

   /*************************************************************************
      Recupera los motivos de retención de las propuestas
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param out mensajes : mesajes de error
      return             : T_IAX_POLMVTRETEN
   *************************************************************************/
   FUNCTION f_get_motretenmov(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN t_iax_polmvtreten IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Get_MotRetenMov';
      obj            t_iax_polmvtreten;
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      obj := pac_md_produccion.f_get_motretenmov(psseguro, pnmovimi, mensajes);
      RETURN obj;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN obj;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN obj;
   END f_get_motretenmov;

   /*************************************************************************
      Recupera la fecha de efecto de la propuesta y las observaciones a mostrar
      param in psseguro  : Código seguro
      param out pfefecto  : Fecha efecto
      param out pobserv  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_infopropreten(
      psseguro IN NUMBER,
      pfefecto OUT DATE,
      pobserv OUT VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Get_InfoPropReten';
      vmail          VARCHAR2(4000);
      vasunto        VARCHAR2(200);
      vfrom          VARCHAR2(200);
      vto            VARCHAR2(200);
      vto2           VARCHAR2(200);
      nerror         NUMBER;
      vparampsu      NUMBER;
      vsproduc       NUMBER;
      v_tipo_fefecto NUMBER;
      v_csituac      NUMBER(2);
      vnpoliza       VARCHAR2(50);
      vnsolici       VARCHAR2(50);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      nerror := pac_md_gestionpropuesta.f_get_fefecto(psseguro, pfefecto, mensajes);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 4;
      -- BUG9423:16-03-2009:DRA
      nerror := pac_seguros.f_get_csituac(psseguro, 'SEG', v_csituac);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      SELECT sproduc
        INTO vsproduc
        FROM seguros
       WHERE sseguro = psseguro;

      vpasexec := 5;
      -- 11408 - Per determinar si anem pel nou sistema PSU o pel tracional.
      vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

      IF NVL(vparampsu, 0) = 0 THEN
         IF v_csituac = 5 THEN
            -- Se recuperan la observaciones
            nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 6,
                                                               pac_md_common.f_get_cxtidioma,
                                                               'SIMULACION', vmail, vasunto,
                                                               vfrom, vto, vto2);
         ELSE
            -- Se recuperan la observaciones
            nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 5,
                                                               pac_md_common.f_get_cxtidioma,
                                                               'SIMULACION', vmail, vasunto,
                                                               vfrom, vto, vto2);
         END IF;

         IF nerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
            RAISE e_object_error;
         END IF;

         pobserv := REPLACE(vmail, '?', '');
      ELSE
         --PSU, cuando se tenga claro el circuito de BPM se preparar el envio de mail
         IF v_csituac = 5 THEN
            -- suplemento
            SELECT npoliza
              INTO vnpoliza
              FROM seguros
             WHERE sseguro = psseguro;

            pobserv := f_axis_literales(9902737, pac_md_common.f_get_cxtidioma) || ' '
                       || vnpoliza;
         ELSE
            -- nueva produccion
            SELECT nsolici
              INTO vnsolici
              FROM seguros
             WHERE sseguro = psseguro;

            pobserv := f_axis_literales(9902737, pac_md_common.f_get_cxtidioma) || ' '
                       || vnsolici;
         END IF;
      END IF;

      vpasexec := 7;
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
   END f_get_infopropreten;

   /*************************************************************************
      Acepta la propuesta retenida
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param in pfefecto  : Fecha efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_aceptarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfefecto IN DATE,
      ptobserv IN VARCHAR2,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pfefecto:'
            || pfefecto;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_AceptarPropuesta';
      nerror         NUMBER;
      v_fvencim      seguros.fvencim%TYPE;
      v_cduraci      seguros.cduraci%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      vparampsu      NUMBER;
      v_csituac      seguros.csituac%TYPE;   -- Bug 23940 - APD - 22/10/2012
      v_femisio      movseguro.femisio%TYPE;
      v_cmotven      movseguro.cmotven%TYPE;
      v_tpsus        t_iax_psu;
      v_testpol      VARCHAR2(400);
      v_cestpol      NUMBER;
      v_cnivelbpm    NUMBER;
      v_tnivelbpm    VARCHAR2(50);
      vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
      -- BUG 29965 - FAL - 03/02/2014
      vmail          VARCHAR2(4000);
      vasunto        VARCHAR2(200);
      vfrom          VARCHAR2(200);
      vto            VARCHAR2(200);
      vto2           VARCHAR2(200);

       P_TO           VARCHAR2(500);
       P_TO2          VARCHAR2(500);
       P_FROM         VARCHAR2(500);
       PSUBJECT       VARCHAR2(500);
       PTEXTO         VARCHAR2(500);
       v_creteni      seguros.creteni%TYPE;
   -- BUG 29965 - FAL - 03/02/2014
   BEGIN
     p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 1, psseguro:'||
     psseguro||' pnmovimi:'||pnmovimi||' pfefecto:'||pfefecto );
     
      
     
     
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 1;

      -- Bug 23940 - APD - 22/10/2012 - se añade el csituac
      SELECT seg.fvencim, seg.cduraci, seg.sproduc, seg.csituac
        INTO v_fvencim, v_cduraci, v_sproduc, v_csituac
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      -- fin Bug 23940 - APD - 22/10/2012
      vpasexec := 2;
      vparampsu := pac_parametros.f_parproducto_n(v_sproduc, 'PSU');
      p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 2, vparampsu:'||vparampsu);
      IF NVL(vparampsu, 0) = 1 THEN
         p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 3, vparampsu:'||vparampsu);
         nerror := pac_md_psu.f_get_colec_psu(psseguro, pnmovimi, NULL,
                                              pac_md_common.f_get_cxtidioma, 'POL', v_testpol,
                                              v_cestpol, v_cnivelbpm, v_tnivelbpm,
                                              vobpsu_retenidas, v_tpsus, mensajes);
         vpasexec := 40;
p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 4, vparampsu:'||vparampsu);
         --Verificamos si el control que estamos tratando actualmente (p_controls(i).ccontrol) existe en esta póliza
         IF v_tpsus IS NOT NULL THEN
           p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 5, vparampsu:'||vparampsu);
            IF v_tpsus.COUNT > 0 THEN
              p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 6, vparampsu:'||vparampsu);
               FOR j IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                  p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 7');
                  -- Bug 30448/169258 - APD - 11/03/2014 - se añade cgarant a la funcion
                     
                     IF v_tpsus(j).ccontrol = 526031 THEN
                     nerror := PAC_PSU_CONF.F_FACULTATIVO(-1, psseguro, to_number(to_char(pfefecto,'ddmmyyyy')), pnmovimi);
                     p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 7_1, nerror:'||nerror);     
                     
                        IF nerror <> 0 THEN
                          pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9002121);   -- Solicitud aceptada
                          RAISE e_object_error;
                        END IF;
                     END IF;
                     
                  IF pac_psu.f_esta_control_pendiente(psseguro, 'POL', v_tpsus(j).ccontrol,
                                                      v_tpsus(j).nriesgo, v_tpsus(j).cgarant) IN
                                                                                        (0, 2) THEN   -- Esta pendiente
                     -- fin Bug 30448/169258 - APD - 11/03/2014
                     p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 8');
                     
                     nerror :=
                        pac_md_psu.f_gestion_control
                                (psseguro, v_tpsus(j).nriesgo, v_tpsus(j).nmovimi,
                                 v_tpsus(j).cgarant, v_tpsus(j).ccontrol, ptobserv, 1,
                                 v_tpsus(j).nvalortope, v_tpsus(j).nocurre, v_tpsus(j).nvalor,
                                 v_tpsus(j).nvalorinf, v_tpsus(j).nvalorsuper,
                                 v_tpsus(j).cnivelr, v_tpsus(j).establoquea,
                                 v_tpsus(j).autmanual, 'POL', 4,   --BUG 27262/160330 - 03/12/2013 - RCL - 4 = 'AUTORIZA_TODO'
                                 NULL, mensajes);

                     IF nerror <> 0 THEN
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      /*
      nerror := pac_md_psu.f_gestion_control(psseguro, NULL, NULL, NULL, NULL, NULL, 1,
                                             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                             NULL, 'POL', NULL, mensajes);

      -- Bug 20759/104009 - 16/01/2012 - AMC - Se quita la creacion del error ya qye viene creado ya
      IF nerror <> 0 THEN
         RAISE e_object_error;
      END IF;
      */
      END IF;
p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 9, v_csituac:'||v_csituac);
      -- Bug 23940 - APD - 22/10/2012 - si el csituac = 17.-Prop.Cartera
      -- no se debe validar la fefecto
      -- ya que la fefecto no se puede modificar y debe ser la que devuelve la
      -- funcion f_get_fefecto (que será la fefecto del max(nmovimi) de movseguro)
      IF v_csituac <> 17 THEN
         -- fin Bug 23940 - APD - 22/10/2012
p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 10');
         -- BUG12395:DRA:19/05/2010:Inici
         IF pnmovimi = 1 THEN
            nerror := pac_seguros.f_valida_fefecto(v_sproduc, pfefecto, v_fvencim, v_cduraci);
         ELSIF pnmovimi > 1 THEN
            IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1
               AND pac_seguros.f_es_col_admin(psseguro, 'SEG') = 1 THEN
               -- Si está en csituac = 5 --> Propuesta de suplemento. Pero tenemos que distinguir
               -- de si está en propuesta de suplemento por un Abrir suplemento o por un suplemento hecho en el 0 y retenido.
               -- Si femisio es NULL y el cmotven está a NULL es que el suplemento en el cero está pendiente de emisión y
               -- es un suplemento normal. De esta forma evitaremos que aparezca el botón Emitir Colectivo y el Abrir Suplemento.
               IF v_csituac = 5 THEN
                  SELECT femisio, cmotven
                    INTO v_femisio, v_cmotven
                    FROM movseguro
                   WHERE sseguro = psseguro
                     AND nmovimi = pnmovimi;

                  IF v_femisio IS NULL
                     AND v_cmotven IS NOT NULL THEN
                     NULL;   -- Ntd
                  END IF;
               END IF;
            ELSE
               nerror := pk_suplementos.f_valida_fefecto(v_sproduc, pfefecto, v_fvencim,
                                                         v_cduraci);
            END IF;
         END IF;
      END IF;   -- fin Bug 23940 - APD - 22/10/2012
p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 11');
      -- BUG12395:DRA:19/05/2010:Fi
      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      -- BUG9297:DRA:03-03-2009
p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 12');
      nerror := pac_gestion_retenidas.f_aceptar_propuesta(psseguro, pnmovimi, 1, pfefecto,
                                                          ptobserv);

p_control_error('PAC_MD_GESTIONPROPUESTA', 'f_aceptarpropuesta','1.-paso 13');
      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      -- BUG 18351 - 21/09/2011 - RSC - LCOL003 - Documentación requerida en contratación y suplementos
      vpasexec := 4;
      nerror := pac_md_docrequerida.f_subir_docsgedox(psseguro, pnmovimi, mensajes);

      IF nerror > 0 THEN
         vpasexec := 5;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      -- BUG 28263 - 07/10/2013 - FPG - Inicio
      IF nerror = 0 THEN
         nerror := pac_md_bpm.f_lanzar_proceso(psseguro, pnmovimi, NULL, '*', 'APROBADA',
                                               mensajes);
      END IF;

      -- BUG 28263 - 07/10/2013 - FPG - Final
      -- FIn Bug 16106

      -- BUG 29965 - FAL - 03/02/2014
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'MAIL_GESTION_PROP'),
             0) = 1 THEN
         IF v_csituac = 5 THEN
            nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 6,
                                                               pac_md_common.f_get_cxtidioma,
                                                               'REAL', vmail, vasunto, vfrom,
                                                               vto, vto2);
         ELSE
            nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 5,
                                                               pac_md_common.f_get_cxtidioma,
                                                               'REAL', vmail, vasunto, vfrom,
                                                               vto, vto2);
         END IF;

         IF nerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
            RAISE e_object_error;
         END IF;
      END IF;

      -- BUG 29965 - FAL - 03/02/2014

	  SELECT seg.fvencim, seg.cduraci, seg.sproduc, seg.csituac, seg.creteni
        INTO v_fvencim, v_cduraci, v_sproduc, v_csituac, v_creteni
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      p_control_error('FFO2','1','v_modo: '||v_csituac);
	    p_control_error('FFO2','2','v_creteni: '||v_creteni);
      IF NVL(pac_parametros.f_parempresa_n(PAC_MD_COMMON.F_GET_CXTEMPRESA(), 'MAIL_CAMBIOS_ESTADO'), 0) = 1 THEN
          IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'MAIL_SITUACION_POL'), 0) = 1 THEN
            IF v_csituac = 4 AND v_creteni = 0 THEN
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
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 151984);   -- Solicitud aceptada
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
   END f_aceptarpropuesta;

   /*************************************************************************
      Rechaza la propuesta retenida
      param in psseguro  : Código seguro
      param in pnmovimi  : Número de movimiento
      param in pcmotmov  : Código motivo rechazo
      param in pnsuplem  : Código suplemento
      param in ptobserva  : Observaciones
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_rechazarpropuesta(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotmov IN NUMBER,
      pnsuplem IN NUMBER,
      ptobserva IN VARCHAR2,
      ptpostpper IN psu_retenidas.postpper%TYPE,
      pcperpost IN psu_retenidas.perpost%TYPE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := SUBSTR('psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pcmotmov:'
                   || pcmotmov || ' - pnsuplem:' || pnsuplem || ' - ptobserva:' || ptobserva,
                   1, 2000);   -- BUG9423:DRA:03-04-2009
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_RechazarPropuesta';
      nerror         NUMBER;
      vparampsu      NUMBER;
      v_sproduc      NUMBER;
      vcmotven       NUMBER;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      isaltacol      BOOLEAN := FALSE;
      v_tpsus        t_iax_psu;
      v_testpol      VARCHAR2(400);
      v_cestpol      NUMBER;
      v_cnivelbpm    NUMBER;
      v_tnivelbpm    VARCHAR2(50);
      vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
      vnpoliza       NUMBER;
      -- BUG 29965 - FAL - 03/02/2014
      vmail          VARCHAR2(4000);
      vasunto        VARCHAR2(200);
      vfrom          VARCHAR2(200);
      vto            VARCHAR2(200);
      vto2           VARCHAR2(200);
   -- BUG 29965 - FAL - 03/02/2014
     v_csituac      seguros.csituac%TYPE;
     v_creteni      seguros.creteni%TYPE;
     P_TO           VARCHAR2(500);
     P_TO2          VARCHAR2(500);
     P_FROM         VARCHAR2(500);
     PSUBJECT       VARCHAR2(500);
     PTEXTO         VARCHAR2(500);
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL
         OR pnsuplem IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT seg.sproduc, seg.csituac, seg.creteni
        INTO v_sproduc, v_csituac, v_creteni
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      vpasexec := 1;

      IF pcmotmov IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000350);
         RAISE e_object_error;
      END IF;

      vpasexec := 2;

      IF ptobserva IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000874);
         RAISE e_object_error;
      END IF;

      vparampsu := pac_parametros.f_parproducto_n(v_sproduc, 'PSU');

      IF NVL(vparampsu, 0) = 1 THEN
         nerror := pac_md_psu.f_get_colec_psu(psseguro, pnmovimi, NULL,
                                              pac_md_common.f_get_cxtidioma, 'POL', v_testpol,
                                              v_cestpol, v_cnivelbpm, v_tnivelbpm,
                                              vobpsu_retenidas, v_tpsus, mensajes);

         --Verificamos si el control que estamos tratando actualmente (p_controls(i).ccontrol) existe en esta póliza
         IF v_tpsus IS NOT NULL THEN
            IF v_tpsus.COUNT > 0 THEN
               FOR j IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                  -- Bug 30448/169258 - APD - 11/03/2014 - se añade cgarant a la funcion
                  IF pac_psu.f_esta_control_pendiente(psseguro, 'POL', v_tpsus(j).ccontrol,
                                                      v_tpsus(j).nriesgo, v_tpsus(j).cgarant) IN
                                                                                        (0, 1) THEN   -- Esta pendiente o autorizado
                     -- fin Bug 30448/169258 - APD - 11/03/2014
                     nerror :=
                        pac_md_psu.f_gestion_control
                                (psseguro, v_tpsus(j).nriesgo, v_tpsus(j).nmovimi,
                                 v_tpsus(j).cgarant, v_tpsus(j).ccontrol, ptobserva, 2,
                                 v_tpsus(j).nvalortope, v_tpsus(j).nocurre, v_tpsus(j).nvalor,
                                 v_tpsus(j).nvalorinf, v_tpsus(j).nvalorsuper,
                                 v_tpsus(j).cnivelr, v_tpsus(j).establoquea,
                                 v_tpsus(j).autmanual, 'POL', 5,   --BUG 27262/160330 - 03/12/2013 - RCL - 5 = 'RECHAZAR_TODO'
                                 NULL, mensajes);

                     IF nerror <> 0 THEN
                        RAISE e_object_error;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;
      /*nerror := pac_md_psu.f_gestion_control(psseguro, NULL, NULL, NULL, NULL, NULL, 2,
                                             NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                             NULL, 'POL', NULL, mensajes);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;*/
      END IF;

      --BUG 0025583 - 137169 - INICIO - DCT 05-02-2014
      --BUG25583: INICIO - DCT  - 14/01/2013
      vpasexec := 3;

      --Si el producto admite certificados (hijos)
      IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
         --Si es colectivo administrado y es certificado 0 (padre)
         IF pac_seguros.f_es_col_admin(psseguro) = 1 THEN
            --v_existe := pac_seguros.f_get_escertifcero(NULL, psseguro);
            SELECT npoliza
              INTO vnpoliza
              FROM seguros
             WHERE sseguro = psseguro;

            v_existe := pac_seguros.f_get_escertifcero(vnpoliza);
            v_escertif0 := pac_seguros.f_get_escertifcero(NULL, psseguro);

            IF v_escertif0 > 0 THEN
               isaltacol := TRUE;
            ELSE
               IF v_existe <= 0 THEN
                  isaltacol := TRUE;
               END IF;
            END IF;

            IF isaltacol THEN
               nerror := pac_md_rechazo.rechazo_col(psseguro, pcmotmov, pnmovimi, 3,
                                                    ptobserva, mensajes);

               IF nerror <> 0 THEN
                  RETURN nerror;
               ELSE
                  vparampsu := pac_parametros.f_parproducto_n(v_sproduc, 'PSU');

                  IF NVL(vparampsu, 0) = 0 THEN
                     UPDATE motretencion
                        SET cestgest = 6
                      WHERE sseguro = psseguro
                        AND nriesgo = 1
                        AND nmovimi = pnmovimi;
                  ELSIF NVL(vparampsu, 0) = 1 THEN
                     UPDATE psu_retenidas
                        SET cmotret = 4,
                            observ = ptobserva,
                            cusuaut = f_user,
                            cdetmotrec = pcmotmov,
                            ffecaut = f_sysdate
                      WHERE sseguro = psseguro
                        AND nmovimi = pnmovimi;
                  END IF;

                  -- BUG 28263 - 07/10/2013 - FPG - Inicio
                  nerror := pac_md_bpm.f_lanzar_proceso(psseguro, pnmovimi, NULL, '*',
                                                        'RECHAZADA', mensajes);
                  -- BUG 28263 - 07/10/2013 - FPG - Final
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 700341);
                  RETURN 0;
               END IF;
            END IF;
         END IF;
      END IF;

      --BUG25583: FIN - DCT  - 14/01/2013
      --BUG 0025583 - 137169 - FIN - DCT 05-02-2014
      vpasexec := 4;
      nerror := pac_gestion_retenidas.f_rechazar_propuesta(psseguro, pnmovimi, 1, pcmotmov,
                                                           pnsuplem, ptobserva, ptpostpper,
                                                           pcperpost);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      -- BUG 28263 - 07/10/2013 - FPG - Inicio
      IF nerror = 0 THEN
         nerror := pac_md_bpm.f_lanzar_proceso(psseguro, pnmovimi, NULL, '*', 'RECHAZADA',
                                               mensajes);
      END IF;

      -- BUG 28263 - 07/10/2013 - FPG - Final

      -- BUG 29965 - FAL - 03/02/2014
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'MAIL_GESTION_PROP'),
             0) = 1 THEN
         nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 2,
                                                            pac_md_common.f_get_cxtidioma,
                                                            'REAL', vmail, vasunto, vfrom,
                                                            vto, vto2);

         IF nerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
            RAISE e_object_error;
         END IF;
      END IF;

      -- BUG 29965 - FAL - 03/02/2014
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 700341);   -- Solicitud Anulada
	  SELECT seg.sproduc, seg.csituac, seg.creteni
        INTO v_sproduc, v_csituac, v_creteni
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

		  IF NVL(pac_parametros.f_parempresa_n(PAC_MD_COMMON.F_GET_CXTEMPRESA(), 'MAIL_CAMBIOS_ESTADO'), 0) = 1 THEN
          IF NVL(pac_parametros.f_parproducto_n(v_sproduc, 'MAIL_SITUACION_POL'), 0) = 1 THEN
            IF v_csituac = 4 AND v_creteni = 3 THEN
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
   END f_rechazarpropuesta;

      /*************************************************************************
       Acepta las propuestas retenidas
       param in p_cautrec:
       param in p_npoliza: Numero de poliza
       param in ptobserv: Observaciones
       param in p_controls: CCONTROLS de las psu's
       param out mensajes : mesajes de error
       return : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
       *************************************************************************/-- Bug 30448/0171427 - INI
       /*
      FUNCTION f_aceptarpropuesta_masivo(
         p_cautrec IN NUMBER,
         p_npoliza IN NUMBER,
         ptobserv IN VARCHAR2,
         p_controls IN t_lista_id,
         mensajes OUT t_iax_mensajes)
         RETURN NUMBER IS

         vpasexec       NUMBER(8) := 1;
         vparam         VARCHAR2(200)
            := 'p_cautrec: ' || p_cautrec || ' - p_npoliza:' || p_npoliza || ' - ptobserv:'
               || ptobserv;
         vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_aceptarpropuesta_masivo';
         v_sproces      NUMBER;
         nerr           NUMBER := 0;
         ob_controls    ob_lista_id := ob_lista_id();
         vlistapols     t_iax_psu;
         wlistapols     ob_iax_psu := ob_iax_psu();
         v_tpsus        t_iax_psu;
         w_tpsus        ob_iax_psu := ob_iax_psu();
         v_testpol      VARCHAR2(400);
         v_cestpol      NUMBER;
         v_cnivelbpm    NUMBER;
         v_tnivelbpm    VARCHAR2(50);
         vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
         v_fvencim      seguros.fvencim%TYPE;
         v_cduraci      seguros.cduraci%TYPE;
         v_sproduc      seguros.sproduc%TYPE;
         v_csituac      seguros.csituac%TYPE;
         v_fefecto      seguros.fefecto%TYPE;

         --Estructura de tipo tabla con el resultado de cada control
         TYPE r_indice IS RECORD(
            indice         NUMBER,
            indice_ok      NUMBER,
            indice_ko      NUMBER
         );

         TYPE tr_indice IS TABLE OF r_indice
            INDEX BY PLS_INTEGER;

         v_indice       tr_indice;
         v_mensaje      VARCHAR2(4000);

      BEGIN
         --Inicialitzem l'escriptura del proces
         nerr :=
            f_procesini
               (pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtempresa,
                'AUTORIZA_MASIVO',
                f_axis_literales(9905850, pac_md_common.f_get_cxtidioma) || ' - '
                || f_axis_literales(9905858, pac_md_common.f_get_cxtidioma),   --Autorización masiva de propuestas retenidas
                v_sproces);
         vpasexec := 10;

         -- Recorremos las PSUs seleccionadas T_LISTA_ID
         IF p_controls IS NOT NULL THEN
            IF p_controls.COUNT > 0 THEN
               FOR i IN p_controls.FIRST .. p_controls.LAST LOOP
                  vlistapols := t_iax_psu();
                  ob_controls := p_controls(i);
                  nerr := 0;
                  vpasexec := 20;

                  --Obtener y realizar cursor (regs) de los certificados retenidos de ese colectivo que tengan esa PSUs implicada
                  FOR regs IN (SELECT s.sseguro, m.nmovimi
                                 FROM seguros s, movseguro m
                                WHERE npoliza = p_npoliza
                                  AND ncertif <> 0
                                  AND creteni = 2
                                  AND s.sseguro = m.sseguro
                                  AND m.nmovimi = (SELECT MAX(nmovimi)
                                                     FROM movseguro m2
                                                    WHERE sseguro = s.sseguro)) LOOP
                     vpasexec := 30;
                     mensajes := NULL;
                     v_tpsus := t_iax_psu();
                     nerr := pac_md_psu.f_get_colec_psu(regs.sseguro, regs.nmovimi, NULL,
                                                        pac_md_common.f_get_cxtidioma, 'POL',
                                                        v_testpol, v_cestpol, v_cnivelbpm,
                                                        v_tnivelbpm, vobpsu_retenidas, v_tpsus,
                                                        mensajes);
                     vpasexec := 40;

                     --Verificamos si el control que estamos tratando actualmente (p_controls(i).ccontrol) existe en esta póliza
                     IF v_tpsus IS NOT NULL THEN
                        IF v_tpsus.COUNT > 0 THEN
                           FOR j IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                              w_tpsus := v_tpsus(j);

                              IF ob_controls.idd = w_tpsus.ccontrol THEN
                                 vlistapols.EXTEND;
                                 vlistapols(vlistapols.LAST) := w_tpsus;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END LOOP;

                  vpasexec := 50;

                  --Recorremos la lista de polizas obtenidas y pasamos a autorizar póliza a póliza (certificado a certificado)
                  --el control que estamos tratando actualmente
                  IF vlistapols IS NOT NULL THEN
                     IF vlistapols.COUNT > 0 THEN
                        FOR j IN vlistapols.FIRST .. vlistapols.LAST LOOP
                           vpasexec := 60;
                           wlistapols := vlistapols(j);
                           nerr := pac_md_psu.f_gestion_control(wlistapols.sseguro,
                                                                wlistapols.nriesgo,
                                                                wlistapols.nmovimi,
                                                                wlistapols.cgarant,
                                                                wlistapols.ccontrol, ptobserv, 1,
                                                                wlistapols.nvalortope,
                                                                wlistapols.nocurre,
                                                                wlistapols.nvalor,
                                                                wlistapols.nvalorinf,
                                                                wlistapols.nvalorsuper,
                                                                wlistapols.cnivelr,
                                                                wlistapols.establoquea,
                                                                wlistapols.autmanual, 'POL',
                                                                NULL, mensajes);

                           IF nerr <> 0 THEN
                              --GRABAR_EN_PROCESOS_LIN_KO;
                              IF v_indice.EXISTS(ob_controls.idd) THEN
                                 v_indice(ob_controls.idd).indice_ko :=
                                                          v_indice(ob_controls.idd).indice_ko + 1;
                                 v_indice(ob_controls.idd).indice :=
                                                             v_indice(ob_controls.idd).indice + 1;
                              ELSE
                                 v_indice(ob_controls.idd).indice_ko := 1;
                                 v_indice(ob_controls.idd).indice := 1;
                              END IF;
                           ELSE
                              vpasexec := 70;

                              --Si estamos con la ultima PSU autorizada de la poliza, aceptamos la propuesta.
                              IF pac_md_psu.f_hay_controles_pendientes(vlistapols(j).sseguro,
                                                                       'POL', mensajes) = 0 THEN
                                 SELECT seg.fvencim, seg.cduraci, seg.sproduc, seg.csituac
                                   INTO v_fvencim, v_cduraci, v_sproduc, v_csituac
                                   FROM seguros seg
                                  WHERE seg.sseguro = vlistapols(j).sseguro;

                                 --Inici BUG 29665/170080 - 19/03/2014 - RCL
                                 SELECT fefecto
                                   INTO v_fefecto
                                   FROM movseguro
                                  WHERE sseguro = vlistapols(j).sseguro
                                    AND nmovimi = vlistapols(j).nmovimi;

                                 --Fi BUG 29665/170080 - 19/03/2014 - RCL
                                 vpasexec := 80;
                                 nerr :=
                                    pac_gestion_retenidas.f_aceptar_propuesta
                                                                            (vlistapols(j).sseguro,
                                                                             vlistapols(j).nmovimi,
                                                                             1, v_fefecto,
                                                                             ptobserv);

                                 IF nerr <> 0 THEN
                                    --GRABAR_EN_PROCESOS_LIN_KO;
                                    IF v_indice.EXISTS(ob_controls.idd) THEN
                                       v_indice(ob_controls.idd).indice_ko :=
                                                          v_indice(ob_controls.idd).indice_ko + 1;
                                       v_indice(ob_controls.idd).indice :=
                                                             v_indice(ob_controls.idd).indice + 1;
                                    ELSE
                                       v_indice(ob_controls.idd).indice_ko := 1;
                                       v_indice(ob_controls.idd).indice := 1;
                                    END IF;
                                 ELSE
                                    vpasexec := 90;
                                    nerr :=
                                       pac_md_docrequerida.f_subir_docsgedox
                                                                           (vlistapols(j).sseguro,
                                                                            vlistapols(j).nmovimi,
                                                                            mensajes);

                                    IF nerr > 0 THEN
                                       --GRABAR_EN_PROCESOS_LIN_KO;
                                       IF v_indice.EXISTS(ob_controls.idd) THEN
                                          v_indice(ob_controls.idd).indice_ko :=
                                                          v_indice(ob_controls.idd).indice_ko + 1;
                                          v_indice(ob_controls.idd).indice :=
                                                             v_indice(ob_controls.idd).indice + 1;
                                       ELSE
                                          v_indice(ob_controls.idd).indice_ko := 1;
                                          v_indice(ob_controls.idd).indice := 1;
                                       END IF;
                                    -- BUG 28263 - 07/10/2013 - FPG - Inicio
                                    ELSE
                                       vpasexec := 95;
                                       nerr := pac_md_bpm.f_lanzar_proceso(vlistapols(j).sseguro,
                                                                           vlistapols(j).nmovimi,
                                                                           NULL, '*', 'APROBADA',
                                                                           mensajes);
                                       nerr := 0;
                                    -- BUG 28263 - 07/10/2013 - FPG - Final
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;

                           --GRABAR_EN_PROCESOS_LIN_OK;
                           vpasexec := 100;

                           IF nerr = 0 THEN
                              IF v_indice.EXISTS(ob_controls.idd) THEN
                                 v_indice(ob_controls.idd).indice_ok :=
                                                          v_indice(ob_controls.idd).indice_ok + 1;
                                 v_indice(ob_controls.idd).indice :=
                                                             v_indice(ob_controls.idd).indice + 1;
                              ELSE
                                 v_indice(ob_controls.idd).indice_ok := 1;
                                 v_indice(ob_controls.idd).indice := 1;
                              END IF;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END LOOP;
            END IF;
         END IF;

         --construir el mensaje final
         vpasexec := 110;
         mensajes := NULL;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 0,
                                              f_axis_literales(9905939,
                                                               pac_md_common.f_get_cxtidioma)
                                              || ' ' || v_sproces);

         IF v_indice IS NOT NULL THEN
            IF v_indice.COUNT > 0 THEN
               FOR k IN v_indice.FIRST .. v_indice.LAST LOOP
                  IF v_indice.EXISTS(k) THEN
                     v_mensaje := '';

                     SELECT tcontrol
                       INTO v_mensaje
                       FROM psu_descontrol
                      WHERE ccontrol = k
                        AND cidioma = pac_md_common.f_get_cxtidioma;

                     v_mensaje :=
                        '- ' || v_mensaje || '. '
                        || f_axis_literales(9905903, pac_md_common.f_get_cxtidioma)   --Nº procesadas:
                        || ' ' || NVL(v_indice(k).indice, 0) || ', '
                        || f_axis_literales(9905904, pac_md_common.f_get_cxtidioma)   --Nº OK:
                        || ' ' || NVL(v_indice(k).indice_ok, 0) || ', '
                        || f_axis_literales(9905905, pac_md_common.f_get_cxtidioma)   --Nº KO
                        || ' ' || NVL(v_indice(k).indice_ko, 0);
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 0, v_mensaje);
                  END IF;
               END LOOP;
            END IF;
         END IF;

         nerr := f_procesfin(v_sproces, 0);
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
      END f_aceptarpropuesta_masivo;
   */

   /*************************************************************************
      Acepta las propuestas retenidas (antigua f_aceptarpropuesta_masivo)
      param in p_cautrec:
      param in p_npoliza: Numero de poliza
      param in ptobserv: Observaciones
      param in p_controls: CCONTROLS de las psu's
      param out mensajes : mesajes de error
      return : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
      *************************************************************************/
   FUNCTION f_autmasiva(
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN t_lista_id,
      pparam IN NUMBER,
      psproces IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /* INICIO DECLARACIONES */
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'p_cautrec: ' || p_cautrec || ' - p_npoliza:' || p_npoliza || ' - ptobserv:'
            || ptobserv;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_autmasiva';
      v_sproces      NUMBER;
      nerr           NUMBER := 0;
      ob_controls    ob_lista_id := ob_lista_id();
      vlistapols     t_iax_psu;
      wlistapols     ob_iax_psu := ob_iax_psu();
      v_tpsus        t_iax_psu;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      v_testpol      VARCHAR2(400);
      v_cestpol      NUMBER;
      v_cnivelbpm    NUMBER;
      v_tnivelbpm    VARCHAR2(50);
      vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();
      v_fvencim      seguros.fvencim%TYPE;
      v_cduraci      seguros.cduraci%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_csituac      seguros.csituac%TYPE;
      v_fefecto      seguros.fefecto%TYPE;
      v_certifs_tratar NUMBER;
      v_plsql        VARCHAR2(1000);
      vprolin        NUMBER;

      --Estructura de tipo tabla con el resultado de cada control
      TYPE r_indice IS RECORD(
         indice         NUMBER,
         indice_ok      NUMBER,
         indice_ko      NUMBER
      );

      TYPE tr_indice IS TABLE OF r_indice
         INDEX BY PLS_INTEGER;

      v_indice       tr_indice;
      v_mensaje      VARCHAR2(4000);
      v_sseguro_0    NUMBER;
      v_creteni      seguros.creteni%TYPE;   -- BUG 32786/0188404 - FAL - 29/09/2014
   /* FIN DECLARACIONES */
   BEGIN
      v_sproces := psproces;

      -- Recorremos las PSUs seleccionadas T_LISTA_ID
      IF p_controls IS NOT NULL THEN
         IF p_controls.COUNT > 0 THEN
            FOR i IN p_controls.FIRST .. p_controls.LAST LOOP
               vlistapols := t_iax_psu();
               ob_controls := p_controls(i);
               nerr := 0;
               vpasexec := 20;

               --Obtener y realizar cursor (regs) de los certificados retenidos de ese colectivo que tengan esa PSUs implicada
               FOR regs IN (SELECT s.sseguro, m.nmovimi
                              FROM seguros s, movseguro m
                             WHERE npoliza = p_npoliza
                               AND ncertif <> 0
                               AND creteni = 2
                               AND s.sseguro = m.sseguro
                               AND m.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM movseguro m2
                                                 WHERE sseguro = s.sseguro)) LOOP
                  -- BUG 32786/0188404 - FAL - 29/09/2014. EVITAR AUTORIZAR SI DURANTE EL PROCESO MASIVO SE HA RECHAZADO.
                  SELECT creteni
                    INTO v_creteni
                    FROM seguros
                   WHERE sseguro = regs.sseguro;

                  IF v_creteni = 2 THEN
                     vpasexec := 30;
                     mensajes := NULL;
                     v_tpsus := t_iax_psu();
                     nerr := pac_md_psu.f_get_colec_psu(regs.sseguro, regs.nmovimi, NULL,
                                                        pac_md_common.f_get_cxtidioma, 'POL',
                                                        v_testpol, v_cestpol, v_cnivelbpm,
                                                        v_tnivelbpm, vobpsu_retenidas,
                                                        v_tpsus, mensajes);
                     vpasexec := 40;

                     --Verificamos si el control que estamos tratando actualmente (p_controls(i).ccontrol) existe en esta póliza
                     IF v_tpsus IS NOT NULL THEN
                        IF v_tpsus.COUNT > 0 THEN
                           FOR j IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                              w_tpsus := v_tpsus(j);

                              IF ob_controls.idd = w_tpsus.ccontrol THEN
                                 vlistapols.EXTEND;
                                 vlistapols(vlistapols.LAST) := w_tpsus;
                              END IF;
                           END LOOP;
                        END IF;
                     END IF;
                  END IF;
               -- FI BUG 32786/0188404 - FAL - 29/09/2014
               END LOOP;

               vpasexec := 50;

               --Recorremos la lista de polizas obtenidas y pasamos a autorizar póliza a póliza (certificado a certificado)
               --el control que estamos tratando actualmente
               IF vlistapols IS NOT NULL THEN
                  IF vlistapols.COUNT > 0 THEN
                     FOR j IN vlistapols.FIRST .. vlistapols.LAST LOOP
                        vpasexec := 60;
                        wlistapols := vlistapols(j);
                        nerr := pac_md_psu.f_gestion_control(wlistapols.sseguro,
                                                             wlistapols.nriesgo,
                                                             wlistapols.nmovimi,
                                                             wlistapols.cgarant,
                                                             wlistapols.ccontrol, ptobserv, 1,
                                                             wlistapols.nvalortope,
                                                             wlistapols.nocurre,
                                                             wlistapols.nvalor,
                                                             wlistapols.nvalorinf,
                                                             wlistapols.nvalorsuper,
                                                             wlistapols.cnivelr,
                                                             wlistapols.establoquea,
                                                             wlistapols.autmanual, 'POL',
                                                             NULL, NULL, mensajes);

                        IF nerr <> 0 THEN
                           --GRABAR_EN_PROCESOS_LIN_KO;
                           IF v_indice.EXISTS(ob_controls.idd) THEN
                              v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                              v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                           ELSE
                              v_indice(ob_controls.idd).indice_ko := 1;
                              v_indice(ob_controls.idd).indice := 1;
                           END IF;
                        ELSE
                           vpasexec := 70;

                           --Si estamos con la ultima PSU autorizada de la poliza, aceptamos la propuesta.
                           IF pac_md_psu.f_hay_controles_pendientes(vlistapols(j).sseguro,
                                                                    'POL', mensajes) = 0 THEN
                              SELECT seg.fvencim, seg.cduraci, seg.sproduc, seg.csituac,
                                     seg.fefecto
                                INTO v_fvencim, v_cduraci, v_sproduc, v_csituac,
                                     v_fefecto
                                FROM seguros seg
                               WHERE seg.sseguro = vlistapols(j).sseguro;

                              vpasexec := 80;
                              nerr :=
                                 pac_gestion_retenidas.f_aceptar_propuesta
                                                                         (vlistapols(j).sseguro,
                                                                          vlistapols(j).nmovimi,
                                                                          1, v_fefecto,
                                                                          ptobserv);

                              IF nerr <> 0 THEN
                                 --GRABAR_EN_PROCESOS_LIN_KO;
                                 IF v_indice.EXISTS(ob_controls.idd) THEN
                                    v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                                    v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                                 ELSE
                                    v_indice(ob_controls.idd).indice_ko := 1;
                                    v_indice(ob_controls.idd).indice := 1;
                                 END IF;
                              ELSE
                                 vpasexec := 90;
                                 nerr :=
                                    pac_md_docrequerida.f_subir_docsgedox
                                                                        (vlistapols(j).sseguro,
                                                                         vlistapols(j).nmovimi,
                                                                         mensajes);

                                 IF nerr > 0 THEN
                                    --GRABAR_EN_PROCESOS_LIN_KO;
                                    IF v_indice.EXISTS(ob_controls.idd) THEN
                                       v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                                       v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                                    ELSE
                                       v_indice(ob_controls.idd).indice_ko := 1;
                                       v_indice(ob_controls.idd).indice := 1;
                                    END IF;
                                 -- BUG 28263 - 07/10/2013 - FPG - Inicio
                                 ELSE
                                    vpasexec := 95;
                                    nerr := pac_md_bpm.f_lanzar_proceso(vlistapols(j).sseguro,
                                                                        vlistapols(j).nmovimi,
                                                                        NULL, '*', 'APROBADA',
                                                                        mensajes);
                                    nerr := 0;
                                 -- BUG 28263 - 07/10/2013 - FPG - Final
                                 END IF;
                              END IF;
                           END IF;
                        END IF;

                        --GRABAR_EN_PROCESOS_LIN_OK;
                        vpasexec := 100;

                        IF nerr = 0 THEN
                           IF v_indice.EXISTS(ob_controls.idd) THEN
                              v_indice(ob_controls.idd).indice_ok :=
                                                       v_indice(ob_controls.idd).indice_ok + 1;
                              v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                           ELSE
                              v_indice(ob_controls.idd).indice_ok := 1;
                              v_indice(ob_controls.idd).indice := 1;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      --construir el mensaje final
      vpasexec := 110;
      mensajes := NULL;

      IF pparam = 1 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 0, 0,
                                             f_axis_literales(9905939,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' ' || v_sproces);
      END IF;

      IF v_indice IS NOT NULL THEN
         IF v_indice.COUNT > 0 THEN
            FOR k IN v_indice.FIRST .. v_indice.LAST LOOP
               IF v_indice.EXISTS(k) THEN
                  v_mensaje := '';

                  SELECT tcontrol
                    INTO v_mensaje
                    FROM psu_descontrol
                   WHERE ccontrol = k
                     AND cidioma = pac_md_common.f_get_cxtidioma;

                  v_mensaje :=
                     '- ' || v_mensaje || '. '
                     || f_axis_literales(9905903, pac_md_common.f_get_cxtidioma)   --Nº procesadas:
                     || ' ' || NVL(v_indice(k).indice, 0) || ', '
                     || f_axis_literales(9905904, pac_md_common.f_get_cxtidioma)   --Nº OK:
                     || ' ' || NVL(v_indice(k).indice_ok, 0) || ', '
                     || f_axis_literales(9905905, pac_md_common.f_get_cxtidioma)   --Nº KO
                     || ' ' || NVL(v_indice(k).indice_ko, 0);

                  IF pparam = 2 THEN
                     vprolin := NULL;
                     nerr := f_proceslin(v_sproces, v_mensaje, 4, vprolin, 4);
                  ELSE
                     pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 0, v_mensaje);
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      RETURN nerr;
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
   END f_autmasiva;

   FUNCTION f_aceptarpropuesta_masivo(
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN t_lista_id,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /* INICIO DECLARACIONES */
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'p_cautrec: ' || p_cautrec || ' - p_npoliza:' || p_npoliza || ' - ptobserv:'
            || ptobserv;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_aceptarpropuesta_masivo';
      v_sproces      NUMBER;
      nerr           NUMBER := 0;
      v_plsql        VARCHAR2(1000);
      v_mensaje      VARCHAR2(4000);
      vaux           VARCHAR2(100);
      v_sproduc      NUMBER;
      v_certifs_tratar NUMBER;
      vtclave        job_colaproces.tclave%TYPE;
      v_jobtype      NUMBER;
   /* FIN DECLARACIONES */
   BEGIN
      SELECT sproduc
        INTO v_sproduc
        FROM seguros
       WHERE npoliza = p_npoliza
         AND ncertif = 0;

      SELECT COUNT(1)
        INTO v_certifs_tratar
        FROM seguros
       WHERE npoliza = p_npoliza
         AND ncertif <> 0
         AND creteni <> 0;

-- Si el producto está parametrizado para realizar autorizacion via job, y el número de certificados supera NUM_DIF_AUTMASIVA, lanzamos job
-- sino se autoriza online
      IF NVL(pac_md_param.f_get_parproducto_n(v_sproduc, 'DIF_AUTMASIVA_JOB', mensajes), 0) = 1
         AND v_certifs_tratar > NVL(pac_md_param.f_get_parproducto_n(v_sproduc,
                                                                     'NUM_DIF_AUTMASIVA',
                                                                     mensajes),
                                    0) THEN
         nerr :=
            f_procesini
               (pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtempresa,
                'AUTORIZA_MASIVO',
                f_axis_literales(9905850, pac_md_common.f_get_cxtidioma) || ' - '
                || f_axis_literales(9905858, pac_md_common.f_get_cxtidioma),   --Autorización masiva de propuestas retenidas
                v_sproces);
         pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 0, 0,
                                             f_axis_literales(9906685,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' ' || v_sproces);
         vaux := '';

-- Introducimos las psu seleccionadas en un varchar porque no se puede enviar en un sql dinamico
         IF p_controls IS NOT NULL THEN
            IF p_controls.COUNT > 0 THEN
               FOR i IN p_controls.FIRST .. p_controls.LAST LOOP
                  vaux := vaux || TO_CHAR(p_controls(i).idd) || '-';
               END LOOP;
            END IF;
         END IF;

         IF vaux IS NOT NULL THEN
            vaux := SUBSTR(vaux, 1, LENGTH(vaux) - 1);
         END IF;

         v_plsql := 'declare num_err NUMBER; begin ' || CHR(10)
                    || 'num_err:= pac_contexto.f_inicializarctx(' || CHR(39) || f_user
                    || CHR(39) || ');' || CHR(10)
                    || ' num_err:=PAC_MD_GESTIONPROPUESTA.F_LANZAJOB_AUTMASIVA('
                    || TO_CHAR(v_sproces) || ',' || TO_CHAR(p_cautrec) || ','
                    || TO_CHAR(p_npoliza) || ',''' || ptobserv || ''',''' || vaux || '''); '
                    || CHR(10) || ' end;';
         v_jobtype := NVL(pac_md_param.f_parinstalacion_nn('JOB_TYPE', mensajes), 0);

         IF v_jobtype = 0 THEN
            nerr := pac_jobs.f_ejecuta_job(NULL, v_plsql, NULL);
         ELSIF v_jobtype IN(1, 2) THEN
            nerr := pac_seguros.f_get_sseguro(p_npoliza, 0, 'POL', vtclave);
            nerr := pac_jobs.f_inscolaproces(2, v_plsql,
                                             'Parámetros: pnpoliza=' || p_npoliza
                                             || '; psproces='
                                             || NVL(TO_CHAR(v_sproces), 'null'),
                                             vtclave);
         END IF;

         IF nerr <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerr);
            RAISE e_object_error;
         END IF;
      ELSE
         --Inicialitzem l'escriptura del proces
         nerr :=
            f_procesini
               (pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtempresa,
                'AUTORIZA_MASIVO',
                f_axis_literales(9905850, pac_md_common.f_get_cxtidioma) || ' - '
                || f_axis_literales(9905858, pac_md_common.f_get_cxtidioma),   --Autorización masiva de propuestas retenidas
                v_sproces);
         vpasexec := 10;
         nerr := f_autmasiva(p_cautrec, p_npoliza, ptobserv, p_controls, 1, v_sproces,
                             mensajes);
         nerr := f_procesfin(v_sproces, 0);
      END IF;

      RETURN nerr;
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
   END f_aceptarpropuesta_masivo;

   /*************************************************************************
        Acepta las propuestas retenidas via job
        param in p_cautrec:
        param in p_npoliza: Numero de poliza
        param in ptobserv: Observaciones
        param in p_controls: CCONTROLS de las psu's
        param out mensajes : mesajes de error
        return : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
        *************************************************************************/
   FUNCTION f_lanzajob_autmasiva(
      p_sproces IN NUMBER,
      p_cautrec IN NUMBER,
      p_npoliza IN NUMBER,
      ptobserv IN VARCHAR2,
      ptaux IN VARCHAR2)
      RETURN NUMBER IS
      /* INICIO DECLARACIONES */
      v_controls     t_lista_id;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'p_cautrec: ' || p_cautrec || ' - p_npoliza:' || p_npoliza || ' - ptobserv:'
            || ptobserv;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_LANZAJOB_AUTMASIVA';
      v_sproces      NUMBER;
      nerr           NUMBER := 0;
      v_certifs_tratar NUMBER;
      v_plsql        VARCHAR2(1000);
      mensajes       t_iax_mensajes;

      TYPE t_array IS TABLE OF VARCHAR2(50)
         INDEX BY BINARY_INTEGER;

      str            t_array;

      FUNCTION recupera_psus(p_in_string VARCHAR2, p_delim VARCHAR2)
         RETURN t_array IS
         i              NUMBER := 0;
         pos            NUMBER := 0;
         lv_str         VARCHAR2(50) := p_in_string;
         strings        t_array;
         conta          NUMBER;
      BEGIN
         pos := INSTR(lv_str, p_delim, 1, 1);

         IF pos != 0 THEN
            WHILE(pos != 0) LOOP
               i := i + 1;
               strings(i) := SUBSTR(lv_str, 1, pos);
               conta := INSTR(strings(i), p_delim);

               IF conta > 0 THEN
                  strings(i) := SUBSTR(strings(i), 1, LENGTH(strings(i)) - 1);
               END IF;

               lv_str := SUBSTR(lv_str, pos + 1, LENGTH(lv_str));
               pos := INSTR(lv_str, p_delim, 1, 1);

               IF pos = 0 THEN
                  strings(i + 1) := lv_str;
               END IF;
            END LOOP;
         ELSE
            IF p_in_string IS NOT NULL THEN
               i := i + 1;
               strings(i) := p_in_string;
            END IF;
         END IF;

         RETURN strings;
      END recupera_psus;
   BEGIN
      -- Recuperamos las psu seleccionadas del varchar y las ponemos en una estructura que recibirá el procedimiento de autorización
      str := recupera_psus(ptaux, '-');
      v_controls := t_lista_id();

      FOR i IN 1 .. str.COUNT LOOP
         v_controls.EXTEND;
         v_controls(v_controls.LAST) := ob_lista_id();
         v_controls(v_controls.LAST).idd := str(i);
      END LOOP;

      nerr := f_autmasiva(p_cautrec, p_npoliza, ptobserv, v_controls, 2, p_sproces, mensajes);
      nerr := f_procesfin(p_sproces, 0);
      RETURN nerr;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_lanzajob_autmasiva;

-- Bug 30448/0171427 - FIN

   /*************************************************************************
    Rechaza las propuestas retenida masivamente
    param in p_npoliza : Numero de poliza
    param in pcmotmov  : CÃ³digo motivo rechazo
    param in ptobserv  : Observaciones
    param in p_controls: CCONTROLS de las psu's
    param out mensajes : mesajes de error
    return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
    *************************************************************************/
   FUNCTION f_rechazarpropuesta_masivo(
      p_npoliza IN NUMBER,
      pcmotmov IN NUMBER,
      ptobserv IN VARCHAR2,
      p_controls IN t_lista_id,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      /* INICIO DECLARACIONES */
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000)
         := SUBSTR('p_npoliza: ' || p_npoliza || ' - pcmotmov: ' || pcmotmov || ' - ptobserv:'
                   || ptobserv,
                   1, 2000);
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_RechazarPropuesta_masivo';
      v_sproduc      NUMBER;
      v_existe       NUMBER;
      v_escertif0    NUMBER;
      isaltacol      BOOLEAN := FALSE;
      v_nsuplem      NUMBER;
      v_sproces      NUMBER;
      nerr           NUMBER := 0;
      ob_controls    ob_lista_id := ob_lista_id();
      vlistapols     t_iax_psu;
      wlistapols     ob_iax_psu := ob_iax_psu();
      v_tpsus        t_iax_psu;
      w_tpsus        ob_iax_psu := ob_iax_psu();
      v_testpol      VARCHAR2(400);
      v_cestpol      NUMBER;
      v_cnivelbpm    NUMBER;
      v_tnivelbpm    VARCHAR2(50);
      vobpsu_retenidas ob_iax_psu_retenidas := ob_iax_psu_retenidas();

      --Estructura de tipo tabla con el resultado de cada control
      TYPE r_indice IS RECORD(
         indice         NUMBER,
         indice_ok      NUMBER,
         indice_ko      NUMBER
      );

      TYPE tr_indice IS TABLE OF r_indice
         INDEX BY PLS_INTEGER;

      v_indice       tr_indice;
      v_mensaje      VARCHAR2(4000);
   /* FIN DECLARACIONES */
   BEGIN
      IF pcmotmov IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 1000350);
         RAISE e_object_error;
      END IF;

      vpasexec := 10;

      IF ptobserv IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9000874);
         RAISE e_object_error;
      END IF;

      vpasexec := 20;
      --Inicialitzem l'escriptura del proces
      nerr :=
         f_procesini
            (pac_md_common.f_get_cxtusuario, pac_md_common.f_get_cxtempresa, 'AUTORIZA_MASIVO',
             f_axis_literales(9905850, pac_md_common.f_get_cxtidioma) || ' - '
             || f_axis_literales(9000545, pac_md_common.f_get_cxtidioma),   --Autorización masiva de propuestas retenidas
             v_sproces);
      vpasexec := 30;

      -- Recorremos las PSUs seleccionadas T_LISTA_ID
      IF p_controls IS NOT NULL THEN
         IF p_controls.COUNT > 0 THEN
            FOR i IN p_controls.FIRST .. p_controls.LAST LOOP
               vlistapols := t_iax_psu();
               ob_controls := p_controls(i);
               nerr := 0;
               vpasexec := 40;

               --Obtener y realizar cursor (regs) de los certificados retenidos de ese colectivo que tengan esa PSUs implicada
               FOR regs IN (SELECT s.sseguro, m.nmovimi
                              FROM seguros s, movseguro m
                             WHERE npoliza = p_npoliza
                               AND ncertif <> 0
                               AND creteni = 2
                               AND s.sseguro = m.sseguro
                               AND m.nmovimi = (SELECT MAX(nmovimi)
                                                  FROM movseguro m2
                                                 WHERE sseguro = s.sseguro)) LOOP
                  vpasexec := 50;
                  mensajes := NULL;
                  v_tpsus := t_iax_psu();
                  nerr := pac_md_psu.f_get_colec_psu(regs.sseguro, regs.nmovimi, NULL,
                                                     pac_md_common.f_get_cxtidioma, 'POL',
                                                     v_testpol, v_cestpol, v_cnivelbpm,
                                                     v_tnivelbpm, vobpsu_retenidas, v_tpsus,
                                                     mensajes);
                  vpasexec := 60;

                  --Verificamos si el control que estamos tratando actualmente (p_controls(i).ccontrol) existe en esta póliza
                  IF v_tpsus IS NOT NULL THEN
                     IF v_tpsus.COUNT > 0 THEN
                        FOR j IN v_tpsus.FIRST .. v_tpsus.LAST LOOP
                           w_tpsus := v_tpsus(j);

                           IF ob_controls.idd = w_tpsus.ccontrol THEN
                              vlistapols.EXTEND;
                              vlistapols(vlistapols.LAST) := w_tpsus;
                           END IF;
                        END LOOP;
                     END IF;
                  END IF;
               END LOOP;

               vpasexec := 70;

               --Recorremos la lista de polizas obtenidas y pasamos a rechazar la póliza
               IF vlistapols IS NOT NULL THEN
                  IF vlistapols.COUNT > 0 THEN
                     FOR j IN vlistapols.FIRST .. vlistapols.LAST LOOP
                        vpasexec := 80;
                        wlistapols := vlistapols(j);
                        nerr := pac_md_psu.f_gestion_control(wlistapols.sseguro, NULL, NULL,
                                                             NULL, NULL, NULL, 2, NULL, NULL,
                                                             NULL, NULL, NULL, NULL, NULL,
                                                             NULL, 'POL', NULL, NULL,
                                                             mensajes);

                        IF nerr <> 0 THEN
                           --GRABAR_EN_PROCESOS_LIN_KO;
                           IF v_indice.EXISTS(ob_controls.idd) THEN
                              v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                              v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                           ELSE
                              v_indice(ob_controls.idd).indice_ko := 1;
                              v_indice(ob_controls.idd).indice := 1;
                           END IF;
                        ELSE
                           vpasexec := 90;

                           SELECT seg.sproduc
                             INTO v_sproduc
                             FROM seguros seg
                            WHERE seg.sseguro = vlistapols(j).sseguro;

                           IF NVL(f_parproductos_v(v_sproduc, 'ADMITE_CERTIFICADOS'), 0) = 1 THEN
                              --Si es colectivo administrado y es certificado 0 (padre)
                              IF pac_seguros.f_es_col_admin(vlistapols(j).sseguro) = 1 THEN
                                 vpasexec := 100;
                                 v_existe :=
                                    pac_seguros.f_get_escertifcero(NULL,
                                                                   vlistapols(j).sseguro);
                                 v_escertif0 :=
                                    pac_seguros.f_get_escertifcero(NULL,
                                                                   vlistapols(j).sseguro);

                                 IF v_escertif0 > 0 THEN
                                    isaltacol := TRUE;
                                 ELSE
                                    IF v_existe <= 0 THEN
                                       isaltacol := TRUE;
                                    END IF;
                                 END IF;

                                 IF isaltacol THEN
                                    vpasexec := 110;
                                    nerr := pac_md_rechazo.rechazo_col(vlistapols(j).sseguro,
                                                                       pcmotmov,
                                                                       vlistapols(j).nmovimi,
                                                                       3, ptobserv, mensajes);

                                    IF nerr <> 0 THEN
                                       --GRABAR_EN_PROCESOS_LIN_KO;
                                       IF v_indice.EXISTS(ob_controls.idd) THEN
                                          v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                                          v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                                       ELSE
                                          v_indice(ob_controls.idd).indice_ko := 1;
                                          v_indice(ob_controls.idd).indice := 1;
                                       END IF;
                                    END IF;
                                 END IF;
                              END IF;
                           END IF;

                           IF NOT isaltacol
                              AND nerr = 0 THEN
                              vpasexec := 120;

                              --Recuperamos el NSUPLEM
                              SELECT s.nsuplem
                                INTO v_nsuplem
                                FROM seguros s
                               WHERE npoliza = p_npoliza
                                 AND ncertif <> 0
                                 AND creteni = 2
                                 AND s.sseguro = vlistapols(j).sseguro;

                              vpasexec := 130;
                              nerr :=
                                 pac_gestion_retenidas.f_rechazar_propuesta
                                                                         (vlistapols(j).sseguro,
                                                                          vlistapols(j).nmovimi,
                                                                          1, pcmotmov,
                                                                          v_nsuplem, ptobserv,
                                                                          NULL, NULL);

                              IF nerr <> 0 THEN
                                 --GRABAR_EN_PROCESOS_LIN_KO;
                                 IF v_indice.EXISTS(ob_controls.idd) THEN
                                    v_indice(ob_controls.idd).indice_ko :=
                                                       v_indice(ob_controls.idd).indice_ko + 1;
                                    v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                                 ELSE
                                    v_indice(ob_controls.idd).indice_ko := 1;
                                    v_indice(ob_controls.idd).indice := 1;
                                 END IF;
                              -- BUG 28263 - 07/10/2013 - FPG - Inicio
                              ELSE
                                 vpasexec := 95;
                                 nerr := pac_md_bpm.f_lanzar_proceso(vlistapols(j).sseguro,
                                                                     vlistapols(j).nmovimi,
                                                                     NULL, '*', 'RECHAZADA',
                                                                     mensajes);
                                 nerr := 0;
                              -- BUG 28263 - 07/10/2013 - FPG - Final
                              END IF;
                           END IF;

                           --GRABAR_EN_PROCESOS_LIN_OK si nerr = 0;
                           vpasexec := 140;

                           IF nerr = 0 THEN
                              IF v_indice.EXISTS(ob_controls.idd) THEN
                                 v_indice(ob_controls.idd).indice_ok :=
                                                       v_indice(ob_controls.idd).indice_ok + 1;
                                 v_indice(ob_controls.idd).indice :=
                                                          v_indice(ob_controls.idd).indice + 1;
                              ELSE
                                 v_indice(ob_controls.idd).indice_ok := 1;
                                 v_indice(ob_controls.idd).indice := 1;
                              END IF;
                           END IF;
                        END IF;
                     END LOOP;
                  END IF;
               END IF;
            END LOOP;
         END IF;
      END IF;

      --construir el mensaje final
      vpasexec := 150;
      mensajes := NULL;
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 0,
                                           f_axis_literales(9905939,
                                                            pac_md_common.f_get_cxtidioma)
                                           || ' ' || v_sproces);

      IF v_indice IS NOT NULL THEN
         IF v_indice.COUNT > 0 THEN
            FOR k IN v_indice.FIRST .. v_indice.LAST LOOP
               IF v_indice.EXISTS(k) THEN
                  v_mensaje := '';

                  SELECT tcontrol
                    INTO v_mensaje
                    FROM psu_descontrol
                   WHERE ccontrol = k
                     AND cidioma = pac_md_common.f_get_cxtidioma;

                  v_mensaje :=
                     '- ' || v_mensaje || '. '
                     || f_axis_literales(9905903, pac_md_common.f_get_cxtidioma)   --Nº procesadas:
                     || ' ' || NVL(v_indice(k).indice, 0) || ', '
                     || f_axis_literales(9905904, pac_md_common.f_get_cxtidioma)   --Nº OK:
                     || ' ' || NVL(v_indice(k).indice_ok, 0) || ', '
                     || f_axis_literales(9905905, pac_md_common.f_get_cxtidioma)   --Nº KO
                     || ' ' || NVL(v_indice(k).indice_ko, 0);
                  pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 0, 0, v_mensaje);
               END IF;
            END LOOP;
         END IF;
      END IF;

      nerr := f_procesfin(v_sproces, 0);
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
   END f_rechazarpropuesta_masivo;

   /*************************************************************************
      Recupera la fecha actual/nueva de cancelación de la propuesta
      param in psseguro  : Código seguro
      param in psproduc  : Código producto
      param out pfcancel  : Fecha actual de cancelación
      param out pfcancelnueva  : Nueva fecha de cancelación
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fechacancel(
      psseguro IN NUMBER,
      psproduc IN NUMBER,
      pfcancel OUT DATE,
      pfcancelnueva OUT DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - psproduc:' || psproduc;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Get_FechaCancel';
      nerror         NUMBER;
      meses_prop     NUMBER;
      vfefecto       DATE;
   BEGIN
      IF psseguro IS NULL
         OR psproduc IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;

      -- Se recupera la fecha actual de cancelación
      BEGIN
         SELECT fcancel, fefecto
           INTO pfcancel, vfefecto
           FROM seguros s
          WHERE s.sseguro = psseguro;
      EXCEPTION
         WHEN OTHERS THEN
            pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                              psqcode => SQLCODE, psqerrm => SQLERRM);
            RETURN 1;
      END;

      vpasexec := 5;

      /*-- Se recupera la nueva fecha de cancelación
      meses_prop := NVL(f_parproductos_v(psproduc, 'MESES_PROPOST_VALIDA'), 0);
      pfcancelnueva := ADD_MONTHS(pfcancel, meses_prop);*/
      IF pfcancel IS NULL THEN
         --BUG 15304 - 09/07/2010 - JRB - Se inserta la fecha de cancelacion de la propuesta a partir de DIAS_PROPOST_VALIDA
         IF NVL(f_parproductos_v(psproduc, 'DIAS_PROPOST_VALIDA'), 0) > 0 THEN
            pfcancelnueva := vfefecto + f_parproductos_v(psproduc, 'DIAS_PROPOST_VALIDA');
         ELSE
            -- si no está informada la fecha de cancelación de la propuesta
            meses_prop := NVL(f_parproductos_v(psproduc, 'MESES_PROPOST_VALIDA'), 0);

            IF meses_prop > 0 THEN
               /*v_fcancel := TO_DATE('01'
                                    || TO_CHAR(ADD_MONTHS(f_sysdate, meses_prop + 1), 'mmyyyy'),
                                    'ddmmyyyy');*/
               pfcancelnueva := ADD_MONTHS(vfefecto, meses_prop);
            ELSE
               pfcancelnueva := NULL;
            END IF;
         END IF;
      END IF;

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
   END f_get_fechacancel;

   /*************************************************************************
      Cambia la fecha de cancelación de la propuesta a la nueva fecha
      param in psseguro  : Código seguro
      param in pnmovimi  : Número movimiento
      param out pfcancelnueva  : Nueva fecha de cancelación
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_cambio_fcancel(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pfcancelnueva IN DATE,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pnmovimi:' || pnmovimi || ' - pfcancelnueva:'
            || pfcancelnueva;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Cambio_FCancel';
      nerror         NUMBER;
      -- BUG 29965 - FAL - 03/02/2014
      vmail          VARCHAR2(4000);
      vasunto        VARCHAR2(200);
      vfrom          VARCHAR2(200);
      vto            VARCHAR2(200);
      vto2           VARCHAR2(200);
   -- BUG 29965 - FAL - 03/02/2014
   BEGIN
      IF psseguro IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- BUG9297:DRA:03-03-2009
      vpasexec := 2;

      IF pfcancelnueva < TRUNC(f_sysdate) THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 9001135);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      nerror := pac_gestion_retenidas.f_cambio_fcancel(psseguro, pnmovimi, pfcancelnueva);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      -- BUG 29965 - FAL - 03/02/2014
      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'MAIL_GESTION_PROP'),
             0) = 1 THEN
         nerror := pac_gestion_retenidas.f_lanzar_tipo_mail(psseguro, 7,
                                                            pac_md_common.f_get_cxtidioma,
                                                            'REAL', vmail, vasunto, vfrom,
                                                            vto, vto2);

         IF nerror <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
            RAISE e_object_error;
         END IF;
      END IF;

      -- BUG 29965 - FAL - 03/02/2014
      pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, 103887);   -- El cambio se ha realizado con éxito
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
   END f_cambio_fcancel;

   /*************************************************************************
      Limpia los datos temporales de la modificación de propuesta
      param in psseguro  : Código seguro
   *************************************************************************/
   PROCEDURE limpiartemporales(psseguro IN NUMBER) IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.LimpiarTemporales';
      msj            t_iax_mensajes;
      vmsj           VARCHAR2(2000);
      num_err        NUMBER;
      reg_seg        estseguros%ROWTYPE;
      c_ctapres      VARCHAR2(20);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 3;
      --BUG 15304 - 26/07/2010 - JRB - Se comenta el código que anula la propuesta.
      /*SELECT *
        INTO reg_seg
        FROM estseguros
       WHERE sseguro = psseguro;

      IF reg_seg.creteni = 0
         AND reg_seg.npoliza <> reg_seg.ssegpol THEN
         num_err := pk_rechazo_movimiento.f_rechazo(reg_seg.ssegpol, 509,   --Anulación sin efecto
                                                    reg_seg.nsuplem, 4, NULL);

         IF num_err <> 0 THEN
            pac_iobj_mensajes.crea_nuevo_mensaje(msj, 1, num_err);
            RAISE e_object_error;
         ELSE
            vmsj := pac_iobj_mensajes.f_get_descmensaje(103964,
                                                        pac_iax_common.f_get_cxtidioma);
            vmsj := vmsj || TO_CHAR(reg_seg.npoliza);
            pac_iobj_mensajes.crea_nuevo_mensaje(msj, 1, 103964, vmsj);
         END IF;

         -- borramos la tabla temporal de titulares en el caso de un producto de vinculados
         IF f_prod_vinc(reg_seg.sproduc) = 1 THEN
            BEGIN
               SELECT DISTINCT ctapres
                          INTO c_ctapres
                          FROM estpresttitulares
                         WHERE sseguro = psseguro;

               DELETE      estpresttitulares
                     WHERE ctapres = c_ctapres;

               --borramos la tabla de bloqueos de los contratos
               pac_lock.p_unlock(c_ctapres);
            EXCEPTION
               WHEN OTHERS THEN
                  NULL;
            END;
         END IF;
      END IF;  */
      pac_alctr126.borrar_tablas_est(psseguro);
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000005, vpasexec, vparam);
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000006, vpasexec, vparam);
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(msj, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
   END limpiartemporales;

   /*************************************************************************
      Habilita la modificación de la propuesta retenida
      param in psseguro  : Código seguro
      param in pcmodo  : Modo de trabajo
      param in pcform  : Nombre formulario
      param in pccampo  : Nombre del botón pulsado
      param out oestsseguro  : Código seguro temporal
      param out onmovimi  : Número movimiento
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_inicializar_modificacion(
      psseguro IN NUMBER,
      pcmodo IN VARCHAR2,
      pcform IN VARCHAR2,
      pccampo IN VARCHAR2,
      oestsseguro OUT NUMBER,
      onmovimi OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      --
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' - pcmodo:' || pcmodo || ' - pcform:' || pcform
            || ' - pccampo:' || pccampo;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_Inicializar_Modificacion';
      nerror         NUMBER;
      -- BUG15684:DRA:31/08/2010:Inici
      v_csituac      NUMBER(2);   -- Bug 16800 - 13/12/2010 - AMC
      v_fefesup      DATE;
   -- BUG15684:DRA:31/08/2010:Fi
   BEGIN
      IF psseguro IS NULL
         OR pcmodo IS NULL
         OR pcform IS NULL
         OR pccampo IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- BUG15684:DRA:31/08/2010:Inici
      vpasexec := 2;
      nerror := pac_seguros.f_get_csituac(psseguro, 'POL', v_csituac);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;

      -- Bug 23940 - APD - 12/11/2012 - se añade el csituac = 17.-Prop. Cartera
      IF v_csituac IN(5, 17) THEN
         SELECT m.fefecto
           INTO v_fefesup
           FROM movseguro m
          WHERE m.sseguro = psseguro
            AND m.nmovimi = (SELECT MAX(m1.nmovimi)
                               FROM movseguro m1
                              WHERE m1.sseguro = m.sseguro);

         nerror := pk_suplementos.f_inicializar_suplemento(psseguro, pcmodo, v_fefesup, pcform,
                                                           pccampo, NULL, oestsseguro,
                                                           onmovimi);
      ELSE
         nerror := pk_nueva_produccion.f_inicializar_modificacion(psseguro, oestsseguro,
                                                                  onmovimi, pcmodo, pcform,
                                                                  pccampo);
      END IF;

      -- BUG15684:DRA:31/08/2010:Fi
      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

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
   END f_inicializar_modificacion;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : Código seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_grabar_alta_poliza(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_GRABAR_ALTA_POLIZA';
      nerror         NUMBER;
      v_csituac      seguros.csituac%TYPE;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      -- BUG9107:DRA:19-02-2009
      nerror := pac_seguros.f_get_csituac(psseguro, 'EST', v_csituac);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      -- BUG9107:DRA:19-02-2009
      -- bug 0024832  afegir 17
      IF v_csituac IN(5, 17) THEN
         vpasexec := 2;
         nerror := pk_suplementos.f_grabar_suplemento_poliza(psseguro,
                                                             pac_iax_produccion.vnmovimi);
      ELSE
         vpasexec := 3;
         nerror := pk_nueva_produccion.f_grabar_alta_poliza(psseguro);
      END IF;

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

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
   END f_grabar_alta_poliza;

   /*************************************************************************
      Mira si se puede asignar el número de póliza al emitir
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_npolizaenemision(pcont OUT NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200);   --:='psseguro: '||psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_GET_NPOLIZAENEMISION';
      nerror         NUMBER;
   BEGIN
      BEGIN
         SELECT COUNT(*)
           INTO pcont
           FROM parproductos
          WHERE cparpro = 'NPOLIZA_EN_EMISION'
            AND cvalpar = 1;
      EXCEPTION
         WHEN OTHERS THEN
            pcont := 0;
      END;

      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_get_npolizaenemision;

   /*************************************************************************
      Recupera la fecha de efecto
      param in psseguro  : Código seguro
      param out pfefecto : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_get_fefecto(psseguro IN NUMBER, pfefecto OUT DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_get_fefecto';
      nerror         NUMBER;
      v_sproduc      NUMBER(6);
      v_csituac      NUMBER(2);
      v_tipo_fefecto NUMBER(8);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      nerror := pac_seguros.f_get_sproduc(psseguro, 'SEG', v_sproduc);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      vpasexec := 3;
      -- Se recupera la fecha de efecto
      v_tipo_fefecto := NVL(f_parproductos_v(v_sproduc, 'FEFECTO_PROP_RETEN'), 0);

      IF v_tipo_fefecto = 0 THEN
         pfefecto := TRUNC(f_sysdate);
      -- Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente
      ELSIF v_tipo_fefecto IN(1, 3, 4) THEN   -- BUG9297:DRA:03-03-2009
         -- fin Bug 30779 - dlF - 15-IV-2014
         SELECT seg.fefecto, seg.csituac
           INTO pfefecto, v_csituac
           FROM seguros seg
          WHERE seg.sseguro = psseguro;

         -- BUG9297:12-03-2009:DRA: Si es una prop.suplemento hay que coger la fefecto del suplemento
         -- Bug 23940 - APD - 22/10/2012 - se añade csituac = 17.-Prop. cartera
         IF v_csituac IN(5, 17) THEN
            -- fin Bug 23940 - APD - 22/10/2012
            SELECT mov.fefecto
              INTO pfefecto
              FROM movseguro mov
             WHERE mov.sseguro = psseguro
               AND mov.nmovimi = (SELECT MAX(nmi.nmovimi)
                                    FROM movseguro nmi
                                   WHERE nmi.sseguro = mov.sseguro);
         END IF;
      ELSIF v_tipo_fefecto = 2 THEN
         pfefecto := LAST_DAY(TRUNC(f_sysdate)) + 1;
      ELSE
         nerror := 108592;
      END IF;

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

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
   END f_get_fefecto;

   /*************************************************************************
      Comprueba si se puede modificar la fecha de efecto o no
      param in psseguro  : Código seguro
      param out mensajes : mesajes de error
      return             : NUMBER (0 --> NO se puede modificar la Fecha de efecto)
                                  (1 --> SI se puede modificar la Fecha de efecto)
   *************************************************************************/
   FUNCTION f_permite_cambio_fefecto(psseguro IN NUMBER, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_permite_cambio_fefecto';
      nerror         NUMBER;
      v_csituac      seguros.csituac%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      v_ret          NUMBER;
      nparanefecto   NUMBER(1);
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT seg.csituac, seg.sproduc
        INTO v_csituac, v_sproduc
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      -- Bug 23940 - APD - 22/10/2012 - se añade csituac = 17.-Prop. cartera
      IF v_csituac IN(5, 17) THEN
         -- fin Bug 23940 - APD - 22/10/2012

         -- Es una propuesta de suplemento, por tanto no lo permitimos
         v_ret := 1;
      ELSE
         v_ret := 0;
      END IF;

      nparanefecto := NVL(f_parproductos_v(v_sproduc, 'FEFECTO_PROP_RETEN'), 0);

      IF nparanefecto = 3 THEN
         v_ret := 1;
      -- Bug 30779 - dlF - 15-IV-2014 - Problemas al emitir pólizas autorizadas previamente
      ELSIF nparanefecto = 4 THEN
         v_ret := 0;
      -- fin Bug 30779 - dlF - 15-IV-2014
      END IF;

      RETURN v_ret;
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
   END f_permite_cambio_fefecto;

   /*************************************************************************
      Valida que la fecha de efecto sea correcta
      param in psseguro  : Código seguro
      param in pfefecto  : Fecha de efecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_valida_fefecto(psseguro IN NUMBER, pfefecto IN DATE, mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_valida_fefecto';
      nerror         NUMBER;
      v_fvencim      seguros.fvencim%TYPE;
      v_cduraci      seguros.cduraci%TYPE;
      v_sproduc      seguros.sproduc%TYPE;
      vcontmov       NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pfefecto IS NULL THEN
         RAISE e_param_error;
      END IF;

      SELECT seg.fvencim, seg.cduraci, seg.sproduc
        INTO v_fvencim, v_cduraci, v_sproduc
        FROM seguros seg
       WHERE seg.sseguro = psseguro;

      --BUG11376-XVM-13102009 inici
      SELECT COUNT('1')
        INTO vcontmov
        FROM movseguro
       WHERE sseguro = psseguro;

      IF vcontmov > 1 THEN
         nerror := pk_suplementos.f_valida_fefecto(v_sproduc, pfefecto, v_fvencim, v_cduraci);
      END IF;

      --BUG11376-XVM-13102009 fi
      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

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
   END f_valida_fefecto;

         /*************************************************************************
      Habilita la modificación de la propuesta retenida
      param in psseguro  : Código seguro
      param in pnriesgo  : Número del riesgo
      param in pnmovimi  : Número movimiento
      param in pcmotret  : Número motivo retención
      param in pnmotret  : Número retención
      param in pcestgest : Código estado gestión
      param in ptodos    : Todos 0 por defecto
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_act_estadogestion(
      psseguro IN NUMBER,
      pnriesgo IN NUMBER,
      pnmovimi IN NUMBER,
      pcmotret IN NUMBER,
      pnmotret IN NUMBER,
      pcestgest IN NUMBER,
      ptodos IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'psseguro: ' || psseguro || ' pnriesgo: ' || pnriesgo || ' - pnmovimi: '
            || pnmovimi || ' - pcmotret: ' || pcmotret || ' - pnmotret: ' || pnmotret
            || ' - pcestgest: ' || pcestgest || ' - ptodos: ' || ptodos;
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.F_ACT_ESTADOGESTION';
      nerror         NUMBER;
   BEGIN
      IF psseguro IS NULL
         OR pnriesgo IS NULL
         OR pnmovimi IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;
      nerror := pac_gestion_retenidas.f_act_estadogestion(psseguro, pnriesgo, pnmovimi,
                                                          pcmotret, pnmotret, pcestgest,
                                                          ptodos);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

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
   END f_act_estadogestion;

--BUG16352:XPL:02112010 INICI
   /***********************************************************************
        Recupera las solicitudes según los filtros introducidos
        psseguro IN NUMBER,
        pnmovimi IN NUMBER,
        pnriesgo IN NUMBER,
        param out mensajes : mensajes de error
        return             : ref cursor
     ***********************************************************************/
   FUNCTION f_get_solicitudsuplementos(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      psolicitudes OUT sys_refcursor,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      squery         VARCHAR(2000);
      cur            sys_refcursor;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500)
         := 'psseguro=' || psseguro || ' pnmovimi =' || pnmovimi || ' pnriesgo = ' || pnriesgo;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION.F_Get_solicitudsuplementos';
      vwhere         VARCHAR2(200);
      vquery         VARCHAR2(2000);
      vnerror        NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      vnerror := pk_suplementos.f_get_solicitudsuplementos(psseguro, pnmovimi, pnriesgo,
                                                           pac_md_common.f_get_cxtidioma,
                                                           squery);

      IF vnerror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
      END IF;

      psolicitudes := pac_iax_listvalores.f_opencursor(squery, mensajes);
      RETURN 0;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);

         IF psolicitudes%ISOPEN THEN
            CLOSE psolicitudes;
         END IF;

         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);

         IF psolicitudes%ISOPEN THEN
            CLOSE psolicitudes;
         END IF;

         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF psolicitudes%ISOPEN THEN
            CLOSE psolicitudes;
         END IF;

         RETURN 1;
   END f_get_solicitudsuplementos;

   /*************************************************************************
      Graba las modificaciones realizadas a la propuesta
      param in psseguro  : CÃ³digo seguro
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_actualizar_sol_suplemento(
      psseguro IN NUMBER,
      psolici IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      squery         VARCHAR(2000);
      cur            sys_refcursor;
      vidioma        NUMBER := pac_md_common.f_get_cxtidioma;
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(500) := 'psseguro=' || psseguro || ' psolici =' || psolici;
      vobject        VARCHAR2(200) := 'PAC_MD_PRODUCCION.f_actualizar_sol_suplemento';
      vnerror        NUMBER;
   BEGIN
      vnerror := pk_suplementos.f_actualizar_sol_suplemento(psseguro, psolici);

      IF vnerror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnerror);
      END IF;

      vpasexec := 3;
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
   END f_actualizar_sol_suplemento;

--BUG16352:XPL:02112010 fi
   /*************************************************************************
      Actualiza el estado de la solicitud del suplemento
      param in psseguro  : Cdigo seguro
      param in pnmovimi  : Num. Movimiento
      param in pnriesgo  : N. riesgo
      param in pcestsupl  : Estado suplemento
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/
   FUNCTION f_set_actualizarestado_supl(
      psseguro IN NUMBER,
      pnmovimi IN NUMBER,
      pnriesgo IN NUMBER,
      pcmotmov IN NUMBER,
      pcgarant IN NUMBER,
      pcpregun IN NUMBER,
      pcestado IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_set_actualizarestado_supl';
      nerror         NUMBER;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsseguro       NUMBER;
   BEGIN
      IF psseguro IS NULL THEN
         RAISE e_param_error;
      END IF;

      nerror := pk_suplementos.f_set_actualizarestado_supl(psseguro, pnmovimi, pnriesgo,
                                                           pcmotmov, pcgarant, pcpregun,
                                                           pcestado);

      IF nerror != 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
      END IF;

      RETURN nerror;
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
   END f_set_actualizarestado_supl;

   FUNCTION f_emision_masiva_marcar(
      ppolizas IN t_iax_info,
      pcestado IN NUMBER,
      psproces_in IN NUMBER,
      psproces_out OUT NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.f_emision_masiva_marcar';
      nerror         NUMBER := 0;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsproces       NUMBER;
      vmens          VARCHAR2(2000);
   BEGIN
      IF ppolizas IS NOT NULL
         AND ppolizas.COUNT > 0 THEN
         --BUG 27048/158857 - 22/11/2013 - RCL - Emision masiva
         IF psproces_in IS NULL THEN
            SELECT sproces.NEXTVAL
              INTO psproces_out
              FROM DUAL;
         ELSE
            psproces_out := psproces_in;
         END IF;

         FOR i IN ppolizas.FIRST .. ppolizas.LAST LOOP
            IF NVL(ppolizas(i).seleccionado, 0) = 1 THEN
               BEGIN
                  INSERT INTO emision_masiva
                              (sproces, sseguro, cestado, cusuario, falta)
                       VALUES (psproces_out, ppolizas(i).valor_columna, 0, f_user, f_sysdate);
               EXCEPTION
                  WHEN DUP_VAL_ON_INDEX THEN
                     UPDATE emision_masiva
                        SET cestado = 0
                      WHERE sproces = psproces_out
                        AND sseguro = ppolizas(i).valor_columna;
               END;
            ELSE   --BUG 27048/158857 - 22/11/2013 - RCL - Emision masiva
               DELETE      emision_masiva
                     WHERE sseguro = ppolizas(i).valor_columna;
            END IF;
         END LOOP;
      END IF;

      RETURN nerror;
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
   END f_emision_masiva_marcar;

   FUNCTION f_emision_masiva_job(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 10;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_emision_masiva_job';
      nerror         NUMBER := 0;
      vidioma        NUMBER;
      vcount         NUMBER;
   BEGIN
      vidioma := pac_md_common.f_get_cxtidioma;

      --COMPROBAR QUE NO HI HAGI CAP SSEGURO JA EXECUTANT-SE O EMES (1,3) EN UN ALTRE SPROCES...
      SELECT COUNT(1)
        INTO vcount
        FROM emision_masiva
       WHERE sseguro IN(SELECT sseguro
                          FROM emision_masiva
                         WHERE sproces = psproces)
         AND cestado IN(1, 3);

      IF vcount > 0 THEN
         --9905979
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, NULL,
                                              f_axis_literales(9905979, vidioma));
         RETURN 1;
      END IF;

      -- Damos de alta el proceso
      INSERT INTO procesoscab
                  (sproces, cempres, cusuari, cproces,
                   tproces, fproini, fprofin, nerror)
           VALUES (psproces, pac_md_common.f_get_cxtempresa, f_user, 'EMISION_MASICA',
                   'Emision masiva', f_sysdate, NULL, 0);

      COMMIT;

      --RCL BUG 27048/158857 (Marcamos los registros como pendientes)
      UPDATE emision_masiva
         SET cestado = 3
       WHERE sproces = psproces;

      vpasexec := 20;

      IF NVL(pac_parametros.f_parempresa_n(pac_md_common.f_get_cxtempresa, 'EMIMASIVA_BATCH'),
             0) = 1 THEN
         nerror :=
            pac_jobs.f_ejecuta_job
                             (NULL,
                              'declare num_err NUMBER; vxmensajes  t_iax_mensajes; begin '
                              || ' num_err:= pac_contexto.f_inicializarctx(' || CHR(39)
                              || f_user || CHR(39) || ');' || CHR(10)
                              || ' num_err := pac_md_gestionpropuesta.f_emision_masiva('
                              || psproces || ', vxmensajes); END;',
                              NULL);
         vpasexec := 30;

         IF nerror > 0 THEN
            p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, ' men=' || nerror);
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 6, nerror);
            RETURN 1;
         ELSE
            -- Proceso diferido
            pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 0,
                                                 f_axis_literales(9904687, vidioma) || ' '
                                                 || psproces);

            DELETE      emision_masiva
                  WHERE sproces = psproces
                    AND cestado = 1;   --Borramos los emitidos para no crear conflictos con otras busquedas y otros movimientos
         END IF;
      ELSE
         nerror := pac_md_gestionpropuesta.f_emision_masiva(psproces, mensajes);
      END IF;

      RETURN nerror;
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
   END f_emision_masiva_job;

   FUNCTION f_emision_masiva(psproces IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := '';
      vobject        VARCHAR2(200) := 'PAC_MD_GESTIONPROPUESTA.f_emision_masiva';
      nerror         NUMBER := 0;
      vselect        VARCHAR2(2000);
      vfrom          VARCHAR2(200);
      vwhere         VARCHAR2(2000);
      pquery         VARCHAR2(4000);
      vsproces       NUMBER;
      n_mov          NUMBER;
      vok            NUMBER := 0;
      vnook          NUMBER := 0;
      polnoemitidas  VARCHAR2(2000) := '';
      polemitidas    VARCHAR2(2000) := '';
      vnumerr        NUMBER;
      vnpoliza       NUMBER;
      vmens          VARCHAR2(2000);
      vcreteni       NUMBER;
      vsproduc       NUMBER;
      vparampsu      NUMBER;
      vnoemite       NUMBER;
      vcsituac       NUMBER;
      mensajes2      t_iax_mensajes;
      vttexto        VARCHAR2(2000);
      num_lin        NUMBER;
      num_err        NUMBER;
   BEGIN
      --select * from axis_literales where slitera = 103148
      FOR i IN (SELECT *
                  FROM emision_masiva
                 WHERE sproces = psproces
                   AND cestado IN(0, 2, 3))   --PENDIENTE, ENPROCESO
                                           LOOP
         vnoemite := 0;
         num_lin := NULL;

         SELECT npoliza, sproduc
           INTO vnpoliza, vsproduc
           FROM seguros
          WHERE sseguro = i.sseguro;

         --Comprovem l'estat en que es troba la proposta
         vnumerr := pac_gestion_retenidas.f_estado_propuesta(i.sseguro, vcreteni);

         IF vnumerr <> 0 THEN
            vnoemite := 1;
            num_lin := NULL;
            vttexto := f_axis_literales(vnumerr, pac_md_common.f_get_cxtidioma) || ' : '
                       || vnpoliza;
            num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
           --Error recuperant el tipus de retenció de la pòlissa.
         /*  pac_iobj_mensajes.crea_nuevo_mensaje
                                           (mensajes, 2, NULL,
                                            f_axis_literales(vnumerr,
                                                             pac_md_common.f_get_cxtidioma)
                                            || ' : ' || vnpoliza);*/
         END IF;

         vpasexec := 3;

         --Actuem segons l'estat de la proposta
         IF vcreteni = 2 THEN
            vnoemite := 1;
            --Proposta pendent d'autorització => No es pot emetre la proposta.
            num_lin := NULL;
            vttexto := f_axis_literales(140598, pac_md_common.f_get_cxtidioma) || ' : '
                       || vnpoliza;
            num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
         ELSIF vcreteni IN(3, 4) THEN
            vnoemite := 1;
            --Proposta anulada o rebutjada => No es pot emetre la proposta.
            num_lin := NULL;
            vttexto := f_axis_literales(151177, pac_md_common.f_get_cxtidioma) || ' : '
                       || vnpoliza;
            num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
         ELSIF vcreteni = 1 THEN
            vnoemite := 1;
            vpasexec := 5;
            vparampsu := pac_parametros.f_parproducto_n(vsproduc, 'PSU');

            IF NVL(vparampsu, 0) = 0 THEN
               num_lin := NULL;
               vttexto := f_axis_literales(151237, pac_md_common.f_get_cxtidioma) || ' : '
                          || vnpoliza;
               num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
            ELSE
               num_lin := NULL;
               vttexto := f_axis_literales(1000129, pac_md_common.f_get_cxtidioma) || ' : '
                          || vnpoliza;
               num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
            -- No deixem emetre mai si la pòlissa es creteni = 1
            END IF;
         END IF;

         IF vnoemite != 1 THEN
            SELECT MAX(nmovimi)
              INTO n_mov
              FROM movseguro
             WHERE sseguro = i.sseguro;

            vnumerr := pac_iax_produccion.f_emitirpropuesta(i.sseguro, n_mov, vnpoliza,
                                                            mensajes2);

            SELECT csituac, creteni
              INTO vcsituac, vcreteni
              FROM seguros
             WHERE sseguro = i.sseguro;

            IF vcsituac = 0
               AND vcreteni = 0 THEN
               vok := NVL(vok, 0) + 1;

               SELECT npoliza
                 INTO vnpoliza
                 FROM seguros
                WHERE sseguro = i.sseguro;

               UPDATE emision_masiva
                  SET cestado = 1   --EMITIDA
                WHERE sproces = i.sproces
                  AND sseguro = i.sseguro;

               IF polemitidas IS NULL THEN
                  polemitidas := f_axis_literales(9902164, pac_md_common.f_get_cxtidioma)
                                 || ': ' || vnpoliza;
               ELSE
                  polemitidas := polemitidas || ', ' || vnpoliza;
               END IF;
            ELSE
               vnook := NVL(vnook, 0) + 1;

               SELECT npoliza
                 INTO vnpoliza
                 FROM seguros
                WHERE sseguro = i.sseguro;

               UPDATE emision_masiva
                  SET cestado = 2   --EMITIDA CON ERRORES
                WHERE sproces = i.sproces
                  AND sseguro = i.sseguro;

               IF polnoemitidas IS NULL THEN
                  polnoemitidas := f_axis_literales(9902164, pac_md_common.f_get_cxtidioma)
                                   || ': ' || vnpoliza;
               ELSE
                  polnoemitidas := polnoemitidas || ', ' || vnpoliza;
               END IF;

               --Bug 22839-XVM-13/11/2012.Inicio
               num_lin := NULL;
               vttexto := f_axis_literales(151237, pac_md_common.f_get_cxtidioma) || ' : '
                          || vnpoliza;
               num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
            --Bug 22839-XVM-13/11/2012.Fin
            END IF;
         ELSE
            vnook := NVL(vnook, 0) + 1;

            SELECT npoliza
              INTO vnpoliza
              FROM seguros
             WHERE sseguro = i.sseguro;

            UPDATE emision_masiva
               SET cestado = 2   --EMITIDA CON ERRORES
             WHERE sproces = i.sproces
               AND sseguro = i.sseguro;

            IF polnoemitidas IS NULL THEN
               polnoemitidas := f_axis_literales(9902164, pac_md_common.f_get_cxtidioma)
                                || ': ' || vnpoliza;
            ELSE
               polnoemitidas := polnoemitidas || ', ' || vnpoliza;
            END IF;

            --Bug 22839-XVM-13/11/2012.Inicio
            num_lin := NULL;
            vttexto := f_axis_literales(151237, pac_md_common.f_get_cxtidioma) || ' : '
                       || vnpoliza;
            num_err := f_proceslin(psproces, vttexto, i.sseguro, num_lin);
         --Bug 22839-XVM-13/11/2012.Fin
         END IF;

         COMMIT;
      END LOOP;

      IF vnook > 0
         OR vok > 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje
                                            (mensajes, 2, NULL,
                                             f_axis_literales(9000493,
                                                              pac_md_common.f_get_cxtidioma)
                                             || ' : ' || psproces);
         vmens := f_axis_literales(9904420, pac_md_common.f_get_cxtidioma) || TO_CHAR(vok)
                  || ', ' || polemitidas || ' | '
                  || f_axis_literales(103149, pac_md_common.f_get_cxtidioma) || vnook || ', '
                  || polnoemitidas;
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, NULL, vmens);

         IF vnook > 0 THEN
            nerror := 1;
         END IF;
      ELSE
         nerror := 1;
      END IF;

      num_err := f_procesfin(psproces, nerror);
      COMMIT;
      RETURN nerror;
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
   END f_emision_masiva;

    /*************************************************************************
      Recupera movimiento de tabla est para reinicio de poliza    21/06/2017
      param in psseguro  : Código seguro
      param in pcmotmov : Motivo de movimiento
	  param out outnmovimi : Movimiento a retornar
      param out mensajes : mesajes de error
      return             : NUMBER (1 se ha producido un error, 0 ha ido todo bien)
   *************************************************************************/

	     FUNCTION f_get_rei_nmovimi(psseguro IN NUMBER
   , pcmotmov IN NUMBER
   ,outnmovimi OUT NUMBER
   ,  mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'psseguro: ' || psseguro || ' - pcmotmov:' || pcmotmov;
      vobject        VARCHAR2(200) := 'PAC_IAX_GESTIONPROPUESTA.F_GET_REI_NMOVIMI';
      nerror         NUMBER;

	 BEGIN
      IF psseguro IS NULL
         OR pcmotmov IS NULL THEN
         RAISE e_param_error;
      END IF;

      vpasexec := 2;

      SELECT nmovimi
	    INTO outnmovimi
	    FROM pds_estsegurosupl
		WHERE sseguro=psseguro AND cmotmov= pcmotmov;


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
   END f_get_rei_nmovimi;



END pac_md_gestionpropuesta;

/